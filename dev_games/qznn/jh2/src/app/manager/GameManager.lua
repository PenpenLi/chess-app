local C = class("GameManager");
GameManager = C

C.currentLoginInfo = nil
C.currentGameId = -1
C.currentOrderId = -1
C.currentInfo = nil --进入游戏带的参数，炸金花会传经纬度过来
C.updatingGames = {}
C.updating = false
C.currentGame = nil
C.currentProgress = 0
C.gettingVersion = false
C.logining = false

local DOWNLOAD_SUCCESS = 1      --下载成功
local DECOMPRESS_SUCCESS = 2    --解压成功

function C:ctor()
    self:registerAll()
end

function C:registerAll()
    Register(MainProto.RegLogin,RegLogin.SC_GAMESERVER_LOGIN_P,handler(self,self.s2cLoginGame))
    Register(MainProto.RegLogin,RegLogin.SC_GAME_SERVER_VERSION_P,handler(self,self.s2cGameVersion))
    Register(MainProto.Game,Game.SC_MODE1_ENTER_P,handler(self,self.s2cEnterGame))
    Register(MainProto.RegLogin,RegLogin.SC_SERVER_STOP_P,handler(self,self.s2cServerStop))

	Register(MainProto.Game,Game.SC_MODE2_CREATE_ROOM_P,handler(self,self.s2cCreatePrivateRoom))
	Register(MainProto.Game,Game.SC_MODE2_ENTER_ROOM_P,handler(self,self.s2cEnterPrivateRoom))

    eventManager:on("ExitGame",handler(self,self.exitGame))
    eventManager:on("OnPause",handler(self,self.onPause))
    eventManager:on("OnResume",handler(self,self.onResume))
end

--游戏暂停
function C:onPause()
    print("============GameManager:onPause========")
    CloseGameServer()
end

--游戏恢复
function C:onResume()
    print("============GameManager:onResume========")
--    if self.currentGame ~= nil then
--        ReconnectGameServer()
--    end
end

--更新子游戏
function C:startUpdateGame(gameId)

    if self.updating then
        eventManager:publish("UpdateGameProgress",gameId,0)
        self.updatingGames[gameId] = true
        return
    end

    eventManager:publish("UpdateGameProgress",gameId,0)
    self.updating = true
    self.updatingGames[gameId] = true

    local localVersion = dataManager:getGameLocalVersion(gameId);
    local remoteVersion = dataManager:getGameRemoteVersion(gameId);

    local step = 0

    local url = dataManager.updateUrl.."/"..tostring(GAME_ALIAS[gameId]).."/v"..tostring(remoteVersion).."/v"..tostring(localVersion).."/";
    local gamePackageUrl = url.."package.zip".."?t="..tostring(os.time())..".zip";
    local gameVersionUrl = url.."version".."?t="..tostring(os.time());

    local assetsManager = cc.AssetsManager:new(gamePackageUrl,gameVersionUrl,DOWNLOAD_PATH)
    assetsManager:retain()

    self.currentProgress = -1

    local function onError(errorCode)
        loadingLayer:hide()
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            dataManager:setGameLocalVersion(gameId,remoteVersion)
            eventManager:publish("UpdateGameComplete",gameId)
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            printInfo("网络错误，下载失败（"..url..")")
            toastLayer:show("网络错误，"..tostring(GAME_LIST[gameId]).."更新失败")
            eventManager:publish("UpdateGameFailed",gameId)
        end

        assetsManager:release()
        self.updatingGames[gameId] = nil
        table.remove(self.updatingGames,gameId)
        self.updating = false

        local nextGame = table.keys(self.updatingGames)[1]
                
        if nextGame then
            print("更新下一个游戏："..nextGame)
            self:startUpdateGame(nextGame)
        end
    end

    local function onProgress(percent)
        if self.currentProgress ~= percent then
            self.currentProgress = percent
            eventManager:publish("UpdateGameProgress",gameId,step * 50 + percent * 0.5 )
        end
    end

    local function onSuccess(t)
        printInfo("完成事件："..tostring(t).."?="..DOWNLOAD_SUCCESS)
        if t == DOWNLOAD_SUCCESS then
            --下载完成，开始解压
            print("下载完成，开始解压")
            step = 1
        else
            --解压完成,下载下一个版本
            printInfo("解压完成")

            dataManager:setGameLocalVersion(gameId,remoteVersion)
            assetsManager:release()

            toastLayer:show(GAME_LIST[gameId].."更新完毕")
            
            eventManager:publish("UpdateGameComplete",gameId)

            self.updatingGames[gameId] = nil
            table.remove(self.updatingGames,gameId)
            self.updating = false

            local nextGame = table.keys(self.updatingGames)[1]
                
            if nextGame then
                print("更新下一个游戏："..nextGame)
                self:startUpdateGame(nextGame)
            end
        end
    end

    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR) -- 注册错误回调
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS) -- 注册进度回调
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS) -- 注册更新成功回调
    assetsManager:setConnectionTimeout(3)
    assetsManager:checkUpdate() -- 自带检查版本和更新
end

function C:isUpdating(gameId)
    if self.updatingGames[gameId] then
        return true
    end
    return false
end

--进入游戏 callback(code,msg) 
--code: -1=参数错误 0=条件通过连接游戏 1=正在更新 2=找不到游戏core 3=金币不足(弹窗保险箱) 4=金币不足(弹窗充值) 
function C:enterGame(gameId,orderId,info,callback)
    --参数错误
    if gameId == nil or orderId == nil then
        toastLayer:show("参数错误！")
        if callback then
            callback(-1,"参数错误！")
        end
        return
    end
    
    --正在更新（直接返回）
    if self:isUpdating(gameId) then
        toastLayer:show("游戏正在更新，请稍后!")
        if callback then
            callback(1,"游戏正在更新，请稍后!")
        end
        return
    end

    --有更新（启动更新）
    if dataManager:getGameLocalVersion(gameId) < dataManager:getGameRemoteVersion(gameId) then
        self:startUpdateGame(gameId)
        if callback then
            callback(1,"游戏正在更新，请稍后!")
        end
        return
    end

    --判断是否有游戏core
    local gameCore = GAMECORE_CONFIGS[gameId]
    if gameCore == nil then
        local name = GAME_LIST[gameId]
        if name == nil then
            name = "该游戏"
        end
        toastLayer:show(name.."即将上线，敬请期待！")
        if callback then
            callback(2,name.."即将上线，敬请期待！")
        end
        return
    end

    --断线回来不一定能取到房间信息
    local roomInfo = self:getRoomInfo(gameId,orderId)
    local money = roomInfo.money or 0
    --金币不足
    if tonumber(dataManager.userInfo.money) < tonumber(money) then
        --保险箱有足够金币
        if tonumber(dataManager.userInfo.money)+tonumber(dataManager.userInfo.walletmoney) > tonumber(money) then
            local text = string.format("金币不足，需要"..utils:moneyString(money).."金币才可以进\n是否提取保险箱金币？")
            if callback then
                callback(3,text)
            end
            return
        else
            local text = string.format("金币不足，需要"..utils:moneyString(money).."金币才可以进\n是否立即充值？")
            if callback then
                callback(4,text)
            end
            return
        end
    end

    self.currentGameId = gameId
    self.currentOrderId = orderId
    self.currentInfo = info
    toastLayer:hide()
    loadingLayer:show("连接中...",10000000)
    self:connectGameServer(gameId,orderId)
    printInfo("进入游戏："..gameId.."/"..orderId)

    --回调
    if callback then
        callback(0,"连接游戏")
    end
end

function C:reconnectGame(ip,port)
    local roomInfo = dataManager:getRoomInfoByPort(port)
    if roomInfo then
        self.currentGameId = roomInfo.gameid
        self.currentOrderId = roomInfo.orderid
        ip = GetCurrentHallServerIp()
        print("重连游戏："..ip..":"..port)
        toastLayer:hide()
        loadingLayer:show("连接中...",10000000)
        self:reconnectGameServer(ip,port)
        return true
    end
    return false
end

function C:exitGame()
    CloseGameServer()
    self.currentGameId = -1
    self.currentOrderId = -1
    self.currentGame = nil

    print("主动退出游戏")

    if dataManager:getLocalBaseVersion() < dataManager.remoteBaseVersion then
        DialogLayer.new():show("游戏有新版本，点击确定立即更新",function()
            CloseHallServer()
            ENTER_UPDATE()
        end)
    end
    local games = table.keys(self.updatingGames)
    print("主动退出游戏,正在更新的游戏个数"..#games)
    if #games > 0 then
        for k,v in pairs(games) do
            eventManager:publish("UpdateGameProgress",v,0)
        end
    end
end

--连接游戏服务器
function C:connectGameServer(gameId,orderId)
    local info = dataManager:getGameServerInfo(gameId,orderId)
    if info then
        local function onConnectResult(result)
            if result then
                self:c2sGameVersion()
            else
                loadingLayer:hide()
                if SCENE_NAME == "Game" then
                    eventManager:publish("CloseNetworkDialog")
                    DialogLayer.new(false):show("网络连接失败，请检查您的网络状态\n点击确定重新连接",
                    function(ok)
                        toastLayer:hide()
                        loadingLayer:show("连接中...",10000000)
                        ConnectGameServer(info.ip,info.port,onConnectResult)
                    end,"CloseNetworkDialog")
                else
                    toastLayer:show("连接游戏服务器失败！")
                end
            end
        end
        print("连接游戏服务器："..tostring(info.ip)..":"..tostring(info.port))
        ConnectGameServer(info.ip,info.port,onConnectResult)
    else
        loadingLayer:hide()
        toastLayer:show("连接失败")
    end
end

--重新连接游戏服务器
function C:reconnectGameServer(ip,port)
    if ip then
        local function onConnectResult(result)
            if result then
                self:c2sGameVersion()
            else
                loadingLayer:hide()
                if SCENE_NAME == "Game" then
                    eventManager:publish("CloseNetworkDialog")
                    DialogLayer.new(false):show("网络连接失败，请检查您的网络状态\n点击确定重新连接",
                    function(ok)
                        toastLayer:hide()
                        loadingLayer:show("连接中...",10000000)
                        ConnectGameServer(info.ip,info.port,onConnectResult)
                    end,"CloseNetworkDialog")
                else
                    toastLayer:show("连接游戏服务器失败！")
                end
            end
        end
        print("连接游戏服务器："..tostring(ip)..":"..tostring(port))
        ConnectGameServer(ip,port,onConnectResult)
    else
        loadingLayer:hide()
        toastLayer:show("连接失败")
    end
end

--房间关闭
function C:s2cServerStop(s)
    toastLayer:show(s.str)
	loadingLayer:hide()
	CloseGameServer()
    self:forceQuitRoom()
end

function C:c2sGameVersion()
    print("连接游戏服务器成功，开始请求游戏版本")
    self.gettingVersion = true

    SendGameServer(MainProto.RegLogin,RegLogin.CS_REQUEST_SERVER_VERSION_P,{siteid = dataManager.channel})
    
    if SCENE_NAME == "Game" then
        utils:createTimer("gamemanager.gettingVersion",1,function()
            if self.gettingVersion then
                SendGameServer(MainProto.RegLogin,RegLogin.CS_REQUEST_SERVER_VERSION_P,{siteid = dataManager.channel})
            else
                utils:removeTimer("gamemanager.gettingVersion")
            end
        end)
    end
end

function C:s2cGameVersion(s)
    dump(s)
    self.gettingVersion = false
    utils:removeTimer("gamemanager.gettingVersion")

    if SCENE_NAME == "Update" then
        return
    end

    --优先更新大厅
    if dataManager:getLocalBaseVersion() < dataManager.remoteBaseVersion then
        DialogLayer.new():show("游戏有新版本，点击确定立即更新",function()
            CloseHallServer()
            ENTER_UPDATE()
        end)
        return
    end

    local localVer = dataManager:getGameLocalVersion(s.gameid)
    local remoteVer = s.gamever
    if device.platform == "ios" then
        remoteVer = s.gameverios
    end
    if remoteVer > localVer then
		dataManager:setGameRemoteVersion(s.gameid,remoteVer)
        loadingLayer:hide()
        print("当前游戏需要更新")

		if SCENE_NAME == "Update" or SCENE_NAME == "Login" or SCENE_NAME == "Logining" then
			ENTER_HALL()
			return
		end

        if self:isGaming() then
            DialogLayer.new():show("当前游戏需要更新",function(ok)
                ENTER_HALL()
                self:startUpdateGame(s.gameid)
                CloseGameServer()
            end)
        else
            toastLayer:show("当前游戏需要更新")
            eventManager:publish("ShowHall")
            self:startUpdateGame(s.gameid)
            CloseGameServer()
        end
        
        return
    end    
    self:c2sLoginGame()
end

--登陆游戏
function C:c2sLoginGame()
    print("游戏不需要更新，开始登陆游戏")
    local s = {}
    if device.platform == "android" then
        s.hductp = CONST_UC_TYPE_ANDROID_ID
    else
        s.hductp = CONST_UC_TYPE_ADID
    end
    s.hdtp = device.platform == "android" and CONST_HD_TYPE_ANDROID or CONST_HD_TYPE_APPLE
    s.hduc = device:getUuid()
    s.random = dataManager:getRandomCer()
    s.siteid = dataManager.channel
    --s.cer = dataManager.cer
    s.playerid = dataManager.playerId

    self.logining = true

    SendGameServer(MainProto.RegLogin,RegLogin.CS_GAMESERVER_LOGIN_P,s)

    if SCENE_NAME == "Game" then
        utils:createTimer("gamemanager.login",1,function()
            if self.logining then
                SendGameServer(MainProto.RegLogin,RegLogin.CS_GAMESERVER_LOGIN_P,s)
            else
                utils:removeTimer("gamemanager.login")
            end
        end)
    end
end

--登陆游戏返回
function C:s2cLoginGame(s)
    dump(s)
    print("登陆游戏返回："..tostring(s.code))

    self.logining = false
    utils:removeTimer("gamemanager.login")

    if s.code == 0 then
        self.currentLoginInfo = s
        self.currentGameId = s.gameid
        if tonumber(s.offline) == 1 then

            if self.currentGame ~= nil then
                loadingLayer:hide()
                print("游戏重连成功")
            else
                print("加载游戏:"..tostring(self.currentGameId))
                LockMsg()
                self.currentGame = ENTER_GAME(self.currentGameId,self:getRoomInfo(self.currentGameId,self.currentOrderId))
            end
            
        else
            self:c2sEnterGame()
        end
    else
        self.currentLoginInfo = nil
        loadingLayer:hide()
        toastLayer:show(s.msg)
		CloseGameServer()
        if SCENE_NAME == "Game" then
            ENTER_HALL_ROOM(s.gameid)
		else
			ENTER_HALL()
        end
    end
end

--请求进入游戏
function C:c2sEnterGame()
    print("登陆成功，请求进入游戏")
    if self.currentInfo then
        SendGameServer(MainProto.Game,Game.CS_MODE1_ENTER_P,self.currentInfo)
    else
        SendGameServer(MainProto.Game,Game.CS_MODE1_ENTER_P)
    end
    

	------------------TEST------------------
	--print("创建房间：configid=1，roomname=桃花岛")
	--SendGameServer(MainProto.Game,Game.CS_MODE2_CREATE_ROOM_P,{configid = 1,roomname="桃花岛"})				

	--print("进入房间：index=1")
	--SendGameServer(MainProto.Game,Game.CS_MODE2_ENTER_ROOM_P,{index = 1})	
	------------------------------------------
end

--请求进入游戏返回
function C:s2cEnterGame(s)
    loadingLayer:hide()
    if s.code == 0 then
        if self.currentGame ~= nil and self.currentGame.gameId ~= GAMEID_FISH then
            loadingLayer:hide()
            print("游戏重连成功")
        else
            print("加载游戏:"..self.currentGameId)
            LockMsg()
            self.currentGame = ENTER_GAME(self.currentGameId,self:getRoomInfo(self.currentGameId,self.currentOrderId))
            self.currentInfo = nil
        end
    else
        toastLayer:show("进入失败")
        if SCENE_NAME == "Game" then
            ENTER_HALL_ROOM(s.gameid)
        end
    end
end

function C:isGaming()
    return self.currentGame ~= nil
end

function C:getRoomInfo(gameId,orderId)
    for k,v in pairs(dataManager.gamelist) do
        if v.gameid == gameId and v.orderid ==orderId then
            local str = string.gsub(v.name,"底分","")
		    local num = tonumber(str)
            num = (num or 0)*MONEY_SCALE
            return {gameid = v.gameid,orderid=v.orderid,money=v.money,difen=num}
        end
    end
    return {}
end

function C:forceQuitRoom(gameId,orderId)
    if (gameId == nil or gameId == self.currentGameId) and (orderId == nil or orderId == self.currentOrderId) and self.currentGame ~= nil then
        self.currentGame:quitGame()
    end
end


--------------------------------------------------------------------------

function C:s2cCreatePrivateRoom(s)
	dump(s)
    if s.code==0 then
		LockMsg()
		self.currentGame = ENTER_GAME(self.currentGameId,self:getRoomInfo(self.currentGameId,self.currentOrderId)) 
	end
end

function C:s2cEnterPrivateRoom(s)
	dump(s)
    if s.code==0 then
		LockMsg()
		self.currentGame = ENTER_GAME(self.currentGameId,self:getRoomInfo(self.currentGameId,self.currentOrderId)) 
	end
end

--------------------------------------------------------------------------

gameManager = GameManager.new()

return C
