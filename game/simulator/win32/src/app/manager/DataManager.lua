local C = class("DataManager");
DataManager = C

---------持久化成员变量----------

C.playerId = nil;
C.account = "";
C.password = "";
C.random = "";
C.sex=0
C.localBaseVersion = 0;
C.accounts = {}
C.passwords = {}
C.randoms = {}

---------------------------------

--------非持久化成员变量---------
C.installver = 1
C.installurl = ""
C.remoteBaseVersion = 0
C.hallServers = {}
C.gameServers = {}
C.updateUrl = DEFAULT_UPDATE_URL
C.payUrl = DEFAULT_PAY_URL
C.agentUrl = DEFAULT_AGENT_URL
C.gameRuleUrl = DEFAULT_GAME_RULE_URL
C.exchangeLogUrl = DEFAULT_EXCHANGE_LOG_URL

--全民代理相关
C.promotion = 1 --是否显示全民推广
C.styleId = 0 --平台ID
C.homeUrl = "www.jianghuyule16.com"
C.qrcodeUrl = nil --短链
C.shareQrcodeDomain = "http://47.107.183.152:15000"
C.shareQrcodeImgPath = nil

C.cer = nil;
C.agentextips = ""
C.bankextips = ""
C.bindtips = ""
C.chargetips = ""
C.isbindaccount = 0
C.isgame = 0
C.isusa = false
C.officalwebdisplay = 1 -- 是否显示官网地址
C.showcode = 1 -- 是否显示二维码
C.ranktips = ""
C.regsendmoney = 0 -- 注册送金
C.serverip = ""
C.serverport = 0
C.gamelist = {}
C.sitegamelist = {}
C.state = 1 -- 1：大厅状态，2：游戏状态
C.userInfo = {}
C.channel = CHANNEL_ID
C.configs = {}
C.detectVm = false
C.mails = {}
C.gameRemoteVersions = {}

C.goldRankSyncInterval = 300    --金币排行榜同步时间间隔（s）
C.goldRankLastSyncTime = 0      --金币排行榜上一次同步时间（戳）
C.timeRankSyncInterval = 300    --时间排行榜同步时间间隔（s）
C.timeRankLastSyncTime = 0      --时间排行榜上一次同步时间（戳）
C.vipPayListSyncInterval = 300	  --VIP支付列表刷新时间
C.vipPayListLastSyncTime = 0	  --VIP支付列表上一次刷新时间（戳）

C.vipPayList = {}

C.myWinToday = 0            --今日赢钱

--排行榜今日金币
C.rankTodayGoldList = 
{
--    rankIndex = 0,
--    ranks = 
--    {
--        [1]={playerId = "",name = "",money = "0",vip = 0,headId = 1}
--    }
}    

--排行榜今日在线时长
C.rankTodayTimeList = 
{
--    rankIndex = 0,
--    ranks = 
--    {
--        [1]={playerId = "",name = "",time = 300000,vip = 0,headId = 1}
--    }
}  

--我与客服聊天记录
C.customServiceMsgList = 
{
    --[1] = {time = "2018-09-29T10:23:28.326Z",type = "to",content = "哈哈哈哈"}
    --[2] = {time = "2018-09-29T10:23:28.326Z",type = "from",content = "呵呵呵呵"}
}

-- 任务列表
C.renwuInfoList = {}

--登录时间，用于统计在线时长
C.loginTime = os.time()

---------------------------------

local userDefault = cc.UserDefault:getInstance();

function C:getLastRefreshQrcodeUrlTime()
    return userDefault:getDoubleForKey("LastRefreshQrcodeUrlTime",0)
end

function C:setLastRefreshQrcodeUrlTime(time)
    userDefault:setDoubleForKey("LastRefreshQrcodeUrlTime",time)
    userDefault:flush()
end

function C:getLastQrcodeUrl()
    return userDefault:getStringForKey("LastQrcodeUrl")
end

function C:setLastQrcodeUrl( qrcodeUrl )
    --清除上次生成的二维码图片
    local lastQrcodeUrl = self:getLastQrcodeUrl()
    if lastQrcodeUrl then
        local fileUtils = cc.FileUtils:getInstance()
        local _,filepath = self:getQrcodeImgInfo(lastQrcodeUrl)
        if filepath and fileUtils:isFileExist(filepath) then
            local flags = fileUtils:removeFile(filepath)
            printInfo("==========file:"..tostring(flags))
        end
        local _,filepath2 = self:getShareQrcodeImgInfo(lastQrcodeUrl)
        if filepath2 and fileUtils:isFileExist(filepath2) then
            local flags = fileUtils:removeFile(filepath2)
            printInfo("==========file2:"..tostring(flags))
        end
    end
    --设置分享二维码图片路径为空，点击分享的时候需要重新请求
    self.shareQrcodeImgPath = nil
    --设置刷新时间
    self:setLastRefreshQrcodeUrlTime(os.time())
    --保存二维码链接，主要用于删除旧二维码
    userDefault:setStringForKey("LastQrcodeUrl",qrcodeUrl)
    userDefault:flush()
end

--return filename,filepath
function C:getQrcodeImgInfo( qrcodeUrl )
    if not qrcodeUrl or type(qrcodeUrl) ~= "string" then
        return nil,nil
    end
    local filename = "qrcode_"..Md5.sumhexa(qrcodeUrl)..".jpg"
    local filepath = DOWNLOAD_PATH.."res/"..filename
    return filename,filepath
end

function C:getShareQrcodeImgInfo( qrcodeUrl )
    if not qrcodeUrl or type(qrcodeUrl) ~= "string" then
        return nil,nil
    end
    local filename = "qrshare_"..Md5.sumhexa(qrcodeUrl)..".jpg"
    local filepath = DOWNLOAD_PATH.."res/"..filename
    return filename,filepath
end

function C:createQrcodeImg(qrcodeUrl)
    if qrcodeUrl == nil or qrcodeUrl == "" then
        return nil,nil
    end
    local filename,filepath = self:getQrcodeImgInfo(qrcodeUrl)
    if cc.FileUtils:getInstance():isFileExist(filename) == false then
        local result = utils:createQRCode(qrcodeUrl,256,filepath)
        if result == false then
            return nil,nil
        end
    end
    return filename,filepath
end

--获取今日在线时长，返回秒数
function C:getOnlineTime()
    
    return os.time() - self.loginTime + tonumber(self.userInfo["OnlineTime"])
end

-- 1：登录状态 2：退出登录
function C:setLoginStatus( status )
    if status == nil then
        return
    end
    local temp = tonumber(status) or 1
    userDefault:setIntegerForKey("LoginStatus",temp)
    userDefault:flush()
end
function C:getLoginStatus()
    return userDefault:getIntegerForKey("LoginStatus",0)
end

--获取玩家ID
function C:getPlayerId()
    if self.playerId ~= nil and self.playerId ~= "" then
        return self.playerId;
    end
    return userDefault:getStringForKey("playerId","");
end

--设置玩家ID
function C:setPlayerId(playerId)
    self.playerId = playerId;
    userDefault:setStringForKey("playerId",playerId);
    userDefault:flush()
end

--获取登陆账号
function C:getAccount()
    if self.account ~= "" and self.account ~= nil then
        return self.account;
    end
    self.account = userDefault:getStringForKey("account","")
    return self.account
end

--设置登陆账号
function C:setAccount(account)
    self.account = account;
    userDefault:setStringForKey("account",account)
    userDefault:flush()
end

--获取登陆密码
function C:getPassword()
    if self.password ~= "" and self.password ~= nil then
        return self.password;
    end
    self.password = userDefault:getStringForKey("password","")
    return self.password
end

--设置登陆密码
function C:setPassword(password)
    self.password = password;
    userDefault:setStringForKey("password",password);
    userDefault:flush()
end

--获取随机登陆密码
function C:getRandomCer()
    if self.random ~= "" and self.random ~= nil then
        return self.random;
    end
    self.random = userDefault:getStringForKey("random","")
    return self.random
end

--设置随机登陆密码
function C:setRandomCer(random)
    self.random = random;
    userDefault:setStringForKey("random",random);
    userDefault:flush()
end

--设置性别
function C:setSex(sex)
    self.userInfo.sex=sex
end


--获取大厅版本
function C:getLocalBaseVersion()
    self.localBaseVersion = userDefault:getIntegerForKey("localBaseVersion",0)
    local origVer = VERSIONS.pt
    if origVer then
        self.localBaseVersion = math.max(self.localBaseVersion ,tonumber(origVer))
    end
    return self.localBaseVersion 
end

--设置大厅版本
function C:setLocalBaseVersion(version)
    self.localBaseVersion = version;
    userDefault:setIntegerForKey("localBaseVersion",version);
    userDefault:flush()
end

--获取账号列表
function C:getAccounts()

    if self.account == nil or self.account == "" then
        self:getAccount()
    end

    if self.accounts == nil or #self.accounts== 0 then
        local str = userDefault:getStringForKey("accounts",self.account);
        self.accounts = string.split(str,",");
    end
    
    local a = clone(self.accounts)
    for k,v in pairs(a) do
        if v == "" then
            a[k] = "游客"
        end
    end

    return a;
end

--添加账号到账号列表
function C:addAccount(acc,pwd,rand)

    if self.accounts == nil or #self.accounts == 0 then
        self:getAccounts()
    end

    for k,v in pairs(self.accounts) do
        if v == acc then table.remove(self.accounts,k) end
    end
    
    table.insert(self.accounts,1,acc)
    local str = table.concat(self.accounts,",",1,#self.accounts)
    userDefault:setStringForKey("accounts",str);
    
    self:setAccount(acc)

    if pwd ~= nil then
        self.passwords[acc] = pwd
        self:setPassword(pwd)
        userDefault:setStringForKey("A"..acc.."P",pwd);
    end
    if rand ~= nil then
        self.randoms[acc] = rand
        self:setRandomCer(rand)
        userDefault:setStringForKey("A"..acc.."R",rand);
    end

    userDefault:flush()
end

--从账号列表移除账号
function C:removeAccount(acc)
    if self.accounts == nil or #self.accounts == 0 then
        self:getAccounts()
    end
    table.removebyvalue(self.accounts,acc,true)
    local str = table.concat(self.accounts,",",1,#self.accounts)
    userDefault:setStringForKey("accounts",str);
    self.passwords[acc] = nil
    self.randoms[acc] = nil
    userDefault:flush()
end

--获取账号对应的密码
function C:getPasswordByAccount(acc)
    if self.passwords == nil or #self.passwords == 0 then
        self:getAccounts()
        self.passwords = {}
        for k,v in pairs(self.accounts) do
            self.passwords[v] = userDefault:getStringForKey("A"..v.."P","")
        end
    end
    return self.passwords[acc]
end

--获取账号对应的随机登陆密码
function C:getRandomCerByAccount(acc)
    if self.randoms == nil or #self.randoms == 0 then
        self:getAccounts()
        self.randoms = {}
        for k,v in pairs(self.accounts) do
            self.randoms[v] = userDefault:getStringForKey("A"..v.."R","")
            userDefault:flush()
        end
    end
    return self.randoms[acc]
end

--保存游戏版本到本地
function C:setGameLocalVersion(id,version)
    userDefault:setIntegerForKey("game"..tostring(id).."ver",tonumber(version));
    userDefault:flush()
end

--读取游戏本地版本
function C:getGameLocalVersion(id)
    local v = userDefault:getIntegerForKey("game"..tostring(id).."ver",0);
    local origVer = rawget(VERSIONS,GAME_ALIAS[id])
    if origVer then
        return math.max(v,tonumber(origVer))
    end
    return v
end

--读取游戏服务器版本号
function C:getGameRemoteVersion(id)
    for k,v in pairs(self.gameRemoteVersions) do 
        if v.gameid == id then
            if device.platform == "android" then
                return v.gamever
            elseif device.platform == "ios" then
                return v.gameverios
            else
                return v.gamever
            end
        end
    end
    return 1
end

--设置游戏服务器版本号
function C:setGameRemoteVersion(id, version)
    for k,v in pairs(self.gameRemoteVersions) do 
        if v.gameid == id then
			if device.platform == "android" then
				self.gameRemoteVersions[k].gamever = version
			elseif device.platform == "ios" then
				self.gameRemoteVersions[k].gameverios = version
			else
				self.gameRemoteVersions[k].gamever = version
			end
        end
    end
end

--获取游戏房间服务器信息
function C:getGameServerInfo(gameId,orderId,index)
	index = index or 0
	local num = self:getGameServerNum(gameId,orderId)
	index = index % num
	local idx = 0
    for k,v in pairs(self.gamelist) do
        if v.gameid == gameId and v.orderid == orderId then
			if idx == index then
				v.ip = GetCurrentHallServerIp()
				return v
			end
			idx = idx +1
        end
    end
    return nil
end

--获取游戏房间服务器数量
function C:getGameServerNum(gameId,orderId)
	local idx = 0
    for k,v in pairs(self.gamelist) do
        if v.gameid == gameId and v.orderid == orderId then
			idx = idx +1
        end
    end
    return idx
end

--通过端口获取房间信息
function C:getRoomInfoByPort(port)
    for k,v in pairs(self.gamelist) do
        if v.port == port then
            v.ip = GetCurrentHallServerIp()
            return v
        end
    end
end

function C:addGameRoom(roomInfo)
    for k,v in pairs(self.gamelist) do
        if v.gameid == roomInfo.gameid and v.orderid == roomInfo.orderid then
            self.gamelist[k] = roomInfo
            return
        end
    end
    table.insert(self.gamelist,roomInfo)
end

function C:delGameRoom(gameId,port)
    for k,v in pairs(self.gamelist) do
        if v.gameid == gameId and v.port == port then
            self.gamelist[k] = nil
            table.remove(self.gamelist,k)
            break
        end
    end
end

--读取最近一次查看客服消息的时间
function C:getLastReadMsgTime()
    return userDefault:getIntegerForKey("ReadMsgTime",0);
end

--设置最近一次查看客服消息的时间
function C:setLastReadMsgTime(time)
    return userDefault:setIntegerForKey("ReadMsgTime",time);
end

function C:getLastFishSetting()
    return userDefault:getStringForKey("FishLock", string.rep("1", 18));
end

function C:setLastFishSetting(sel)
    return userDefault:setStringForKey("FishLock",sel);
end

function C:getLastFishCannon()
    return userDefault:getIntegerForKey("FishConnon",1);
end

function C:setLastFishCannon(cannon)
    return userDefault:setIntegerForKey("FishConnon",cannon);
end

function C:updateMoney(money)
    self.userInfo.money = money
end

----------------------------任务(活动)----------------------------------------
--活动任务-清除任务列表
function C:clearAllRenwuInfo()
    self.renwuInfoList = {}
end

--活动任务-更新任务，没有的会插入
function C:updateRenwu(info)
    local find = false
    for index, tab in ipairs(self.renwuInfoList) do
        if tab.taskid == info.taskid then
            find = true
            tab.nowVal = info.nowVal
            if tab.nowVal == -1 then
                table.remove(self.renwuInfoList, index)
            end
            return
        end
    end
    --新活动任务
    if not find then
        table.insert(self.renwuInfoList, info)
    end
end

--活动任务-获取任务列表
function C:getRenwuList()
    return self.renwuInfoList
end

--活动任务-根据任务ID获取任务信息
function C:getRenwuInfoByTaskId(taskId)
    --字段已服务器为准
    for index,tab in ipairs(self.renwuInfoList) do
        if tab.taskid == taskId then
            return tab
        end
    end
    return nil
end

dataManager = DataManager.new()

return DataManager;