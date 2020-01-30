local C = class("HallCore",CoreBase)
HallCore = C

C.MODULE_PATH = "app.base.hall"
C.SCENE_CONFIG = {scenename = "HallScene", filename = "HallScene"}

C.personalLayer = nil
C.rechargeLayer = nil
C.huodongLayer = nil
C.announceLayer = nil
C.serviceLayer = nil
C.bankLayer = nil
C.exchangeLayer = nil
C.rankLayer = nil
C.zcsjLayer = nil
C.xsjlLayer = nil
C.qmdlLayer = nil
C.fromGameId = nil

function C:ctor(fromGameId)
	C.super.ctor(self)
    self.fromGameId = fromGameId
end

function C:registerEvents()

    self.setBlanceHandler = function(money)self.scene:setBlance(money) end
    eventManager:on("Money",self.setBlanceHandler)
    
    self.configsResultHandler = function(s) 
    	loadingLayer:hide() 
    	self.rechargeLayer:show(s) 
   	end
    eventManager:on("ConfigResult",self.configsResultHandler)

    --活动红点
    self.setHuodongRedDotHandler = handler(self,self.setHuodongRedDot)
    eventManager:on("SetHuodongRedDot",self.setHuodongRedDotHandler)

    self.setAnnounceRedDotHandler = handler(self,self.setAnnounceRedDot)
    eventManager:on("SetMailRedDot",self.setAnnounceRedDotHandler)

    self.setServiceRedDotHandler = handler(self,self.setServiceRedDot)
    eventManager:on("SetCustomServiceRedDot",self.setServiceRedDotHandler)

    self.showGameUpdateFlagHandler = handler(self,self.showGameUpdateFlag)
    eventManager:on("ShowGameUpdateFlag",self.showGameUpdateFlagHandler)

    self.showGameUpdateFlagsHandler = handler(self,self.showGameUpdateFlags)
    eventManager:on("ShowGameUpdateFlags",self.showGameUpdateFlagsHandler)

    self.hideGameUpdateFlagHandler = handler(self,self.hideGameUpdateFlag)
    eventManager:on("HideGameUpdateFlag",self.hideGameUpdateFlagHandler)

    self.showGameProgressBarHandler = handler(self,self.showGameProgressBar)
    eventManager:on("UpdateGameProgress",self.showGameProgressBarHandler)

    self.updateGameCompleteHandler = function(id)self:hideGameProgressBar(id) self:hideGameUpdateFlag(id)end
    eventManager:on("UpdateGameComplete",self.updateGameCompleteHandler)

    self.updateGameFailedHandler = handler(self,self.hideGameProgressBar)
    eventManager:on("UpdateGameFailed",self.updateGameFailedHandler)

    self.showMainHandler = handler(self,self.showMain)
    eventManager:on("ShowHall",self.showMainHandler)

    self.onRegisterSuccessHandler = handler(self,self.onRegisterSuccess)
    eventManager:on("BindPhoneSuccess",self.onRegisterSuccessHandler)

    self.onUpdateGameListHandler = handler(self,self.updateGameList)
    eventManager:on("UpdateGameList",self.onUpdateGameListHandler)

    eventManager:publish("RequestMailList")
end

function C:exit()
    eventManager:off("Money",self.setBlanceHandler)
    eventManager:off("ConfigResult",self.configsResultHandler)
    eventManager:off("SetHuodongRedDot",self.setHuodongRedDotHandler)
    eventManager:off("SetMailRedDot",self.setAnnounceRedDotHandler)
    eventManager:off("SetCustomServiceRedDot",self.setServiceRedDotHandler)
    eventManager:off("ShowGameUpdateFlag",self.showGameUpdateFlagHandler)
    eventManager:off("ShowGameUpdateFlags",self.showGameUpdateFlagsHandler)
    eventManager:off("HideGameUpdateFlag",self.hideGameUpdateFlagHandler)
    eventManager:off("UpdateGameProgress",self.showGameProgressBarHandler)
    eventManager:off("UpdateGameComplete",self.updateGameCompleteHandler)
    eventManager:off("UpdateGameFailed",self.updateGameFailedHandler)
    eventManager:off("ShowHall",self.showMainHandler)
    eventManager:off("BindPhoneSuccess",self.onRegisterSuccessHandler)
    eventManager:off("UpdateGameList",self.onUpdateGameListHandler)

    utils:removeTimer("hall.ShowZcsjLayer")
    if self.personalLayer then
		self.personalLayer:release()
	end
	if self.rechargeLayer then
		self.rechargeLayer:release()
	end
	if self.huodongLayer then
		self.huodongLayer:release()
	end
	if self.announceLayer then
		self.announceLayer:release()
	end
	if self.serviceLayer then
		self.serviceLayer:release()
	end
	if self.bankLayer then
		self.bankLayer:release()
	end
	if self.exchangeLayer then
		self.exchangeLayer:release()
	end
	if self.rankLayer then
		self.rankLayer:release()
	end
	if self.zcsjLayer then
		self.zcsjLayer:release()
	end
	if self.xsjlLayer then
		self.xsjlLayer:release()
	end
	if self.qmdlLayer then
		self.qmdlLayer:release()
	end
    C.super.exit(self)
end

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	self.scene:initialize()
	if dataManager.isbindaccount == 0 and self.fromGameId == nil then
		utils:createTimer("hall.ShowZcsjLayer",0.5,function()
			utils:removeTimer("hall.ShowZcsjLayer")
			self:showZcsjLayer()
		end)
	end
    pcall(handler(self,self.bindData))
    self:registerEvents()
    self:handlerFromGameId()
end

--更新游戏房间
function C:updateGameList()
	if self.scene.gameId then
		local items = {}
		for k,v in pairs(dataManager.gamelist) do
			if v.gameid == self.scene.gameId then
				table.insert(items,v)
			end
		end
		table.sort( items, function( a,b )
			return a.orderid > b.orderid
		end )
		if #items > 1 then
			self.scene:showRoomLayer(self.scene.gameId, items, false)
		end
	else
		self.scene:showGameItems(dataManager.sitegamelist)
		self:checkGameUpdateFlags()
	end
end

function C:bindData()
    self.scene:setHeadId(dataManager.userInfo.headid,dataManager.userInfo.wxheadurl)
	self.scene:setFrameId(0)
	local name = dataManager.userInfo["nickname"]
	if name == nil or name == "" then
		name = tostring(dataManager.playerId)
	end
	self.scene:setAccount(name)
	self.scene:setBlance(dataManager.userInfo.money)
	self.scene:showGameItems(dataManager.sitegamelist)
	local showZcsj = dataManager.isbindaccount == 0
	self.scene:showZcsjTabBtn(showZcsj)
	local showProxy = dataManager.promotion == 1
	self.scene:showProxyTabBtn(showProxy)
    self:checkGameUpdateFlags()
end

function C:onRegisterSuccess()
	self.scene:showZcsjTabBtn(false)
end

--从游戏返回大厅，显示房间列表
function C:handlerFromGameId()
	if self.fromGameId then
		local items = {}
		for k,v in pairs(dataManager.gamelist) do
			if v.gameid == self.fromGameId then
				table.insert(items,v)
			end
		end
		table.sort( items, function( a,b )
			return a.orderid > b.orderid
		end )
		if #items > 1 then
			self.scene:showRoomLayer(self.fromGameId, items, false)
		end
		self.fromGameId = nil
	end
end

function C:checkGameUpdateFlags()
    local updateGames = {}
    if dataManager.gameRemoteVersions == nil then return end
    for k,v in pairs(dataManager.gameRemoteVersions) do 
        local localVer = dataManager:getGameLocalVersion(v.gameid)
        local remoteVer = v.gamever
        if device.platform == "ios" then
            remoteVer = v.gameverios
        end
        if remoteVer > localVer then
            table.insert(updateGames,v.gameid)
        else
        end
    end
    self:showGameUpdateFlags(updateGames)
end

--显示更新标识
function C:showGameUpdateFlags(games)
    for k,v in pairs(games) do 
        self:showGameUpdateFlag(v)
    end
end

--显示更新标识
function C:showGameUpdateFlag( gameId )
	self.scene:showGameUpdateFlag(gameId)
end

--隐藏更新标识
function C:hideGameUpdateFlag( gameId )
	self.scene:hideGameUpdateFlag(gameId)
end

--设置更新进度 0-100
function C:showGameProgressBar( gameId, percent )
	self.scene:showGameProgress(gameId,percent)
end

--隐藏游戏进度条
function C:hideGameProgressBar( gameId )
	self.scene:hideGameProgress(gameId)
end

--点击大厅游戏图标
function C:didSelectedGame( gameId, animation )
	--点击捕鱼或者水果机判断是否支持捕鱼水果机
	if gameId == GAMEID_FISH or gameId == GAMEID_FRUIT then
		if SUPPORT_FISH_FRUIT() == false then
			local text = "更加爽快的捕鱼体验，尽在专业版！动动手指，火力全开！点击确定前往官网下载专业版"
			if gameId == GAMEID_FRUIT then
				text = "更加刺激的水果机体验，尽在专业版！动动手指，火力全开！点击确定前往官网下载专业版"
			end
			DialogLayer.new():show(text,function( isOk )
				if isOk then
					--TODO:获取配置的官网地址
					local homeUrl = "http://www.jianghuyule16.com"
					if dataManager.configs ~= nil and dataManager.configs.Url ~= nil and dataManager.configs.Url ~= "" then
						homeUrl = dataManager.configs.Url
					end
					utils:openUrl(homeUrl)
				end
			end)
			return
		end
	end

    --正在更新（直接返回）
    if gameManager:isUpdating(gameId) then
        toastLayer:show("游戏正在更新，请稍后!")
        return
    end

    --有更新（启动更新）
    if dataManager:getGameLocalVersion(gameId) < dataManager:getGameRemoteVersion(gameId) then
        gameManager:startUpdateGame(gameId)
        return
    end

	local items = {}
	for k,v in pairs(dataManager.gamelist) do
		if v.gameid == gameId then
			table.insert(items,v)
		end
	end

	if #items == 0 then
		local name = GAME_LIST[gameId]
		if name == nil then
			name = "该游戏"
		end
		toastLayer:show(name.."即将上线，敬请期待！")
		return
	end

	if #items == 1 then
		self:enterGameRoom(items[1])
		return
	end
	table.sort( items, function( a,b )
		return a.orderid > b.orderid
	end )
	self.scene:showRoomLayer(gameId, items, animation)
end

--进入游戏房间
function C:enterGameRoom( roomInfo )
	if roomInfo == nil then
		return
	end
	--进入游戏
	local doAction = function( info )
    	gameManager:enterGame(roomInfo.gameid,roomInfo.orderid,info,function( code,msg )
    		if code == 3 then
				DialogLayer.new():show(msg,function( isOk )
					if isOk then
						self:showBankLayer(2)
					end
				end)
			elseif code == 4 then
				DialogLayer.new():show(msg,function( isOk )
					if isOk then
						self:showRechargeLayer()
					end
				end)
			end
    	end)
	end
	--炸金花需要定位
	if LOCATION_ENABLED and roomInfo.gameid == GAMEID_ZJH then
		--先判断金币
	    local money = roomInfo.money or 0
	    if tonumber(dataManager.userInfo.money) < tonumber(money) then
	        --保险箱有足够金币
	        if tonumber(dataManager.userInfo.money)+tonumber(dataManager.userInfo.walletmoney) > tonumber(money) then
	            local text = string.format("金币不足，需要"..utils:moneyString(money).."金币才可以进\n是否提取保险箱金币？")
	            DialogLayer.new():show(text,function( isOk )
					if isOk then
						self:showBankLayer(2)
					end
				end)
	            return
	        else
	            local text = string.format("金币不足，需要"..utils:moneyString(money).."金币才可以进\n是否立即充值？")
	            DialogLayer.new():show(text,function( isOk )
					if isOk then
						self:showRechargeLayer()
					end
				end)
	            return
	        end
	    end
		loadingLayer:show("定位中...",120)
		utils:startLocation(function( result )
			loadingLayer:hide()
			printInfo("=============定位："..tostring(result))
			local lat = 0
			local lng = 0
			if result and type(result) == "string" then
				local arr = utils:stringSplit(result,",")
				if #arr == 3 and tonumber(arr[1]) == 1 then
					lat = tonumber(arr[2]) or 0
					lng = tonumber(arr[3]) or 0
				end
			end
			if lat ~= 0 and lng ~= 0 then
				doAction({latitude=lat,longitude=lng})
			else
				DialogLayer.new(false):show("定位失败，请检查网络并开启定位权限")
			end
		end)
	else
		doAction(nil)
	end
end

--显示大厅主界面
function C:showMain()
    self.scene:showHall()
end

--显示个人中心
function C:showPersonalLayer()
	if self.personalLayer == nil then
		self.personalLayer = PersonalLayer.new()
		self.personalLayer:retain()
		self.personalLayer.didSelectedHead = function( headId )
			self.scene:setHeadId(headId)
		end
	end
	self.personalLayer:show()
end

--显示充值页面
function C:showRechargeLayer()
	if self.rechargeLayer == nil then
		self.rechargeLayer = RechargeLayer.new()
		self.rechargeLayer:retain()
	end
    loadingLayer:show("正在获取充值信息...")
    eventManager:publish("Config")
end

---显示活动
function C:showHuodongLayer()
	if self.huodongLayer == nil then
		self.huodongLayer = HuodongLayer.new()
		self.huodongLayer:retain()
	end
	self.huodongLayer:show()
end

--显示公共
function C:showAnnounceLayer()
	if self.announceLayer == nil then
		self.announceLayer = AnnounceLayer.new()
		self.announceLayer:retain()
	end
	self.announceLayer:show()
end

--显示客服
function C:showServiceLayer()
	if self.serviceLayer == nil then
		self.serviceLayer = ServiceLayer.new()
		self.serviceLayer:retain()
	end
	self.serviceLayer:show()
end

--显示保险箱
function C:showBankLayer(index)
	if self.bankLayer == nil then
		self.bankLayer = BankLayer.new()
		self.bankLayer:retain()
	end
	self.bankLayer:show(index)
end

--显示兑换
function C:showExchangeLayer()
	if self.exchangeLayer == nil then
		self.exchangeLayer = ExchangeLayer.new()
		self.exchangeLayer:retain()
	end
	self.exchangeLayer:show()
end

--显示排行榜
function C:showRankLayer()
	if self.rankLayer == nil then
		self.rankLayer = RankLayer.new()
		self.rankLayer:retain()
	end
	self.rankLayer:show(index)
end

--显示注册送金
function C:showZcsjLayer()
	if self.zcsjLayer == nil then
		self.zcsjLayer = ZcsjLayer.new()
		self.zcsjLayer:retain()
	end
	self.zcsjLayer:show()
end

--显示全民代理
function C:showQmdlLayer()
	if tonumber(dataManager.promotion) ~= 1 then
		toastLayer:show("全民推广暂未开发！")
		return
	end
	if self.qmdlLayer == nil then
		self.qmdlLayer = QmdlPopupLayer.new()
		self.qmdlLayer:retain()
	end
	self.qmdlLayer:show()
end

--显示新手奖励
function C:showXsjlLayer()
	if self.xsjlLayer == nil then
		self.xsjlLayer = XsjlLayer.new()
		self.xsjlLayer:retain()
	end
	self.xsjlLayer:show()
end

--设置活动小红点
function C:setHuodongRedDot(visible)
    self.scene:setHuodongRedDot(visible)
end

--设置公告小红点
function C:setAnnounceRedDot(visible)
    self.scene:setAnnounceRedDot(visible)
end

--设置客服小红点
function C:setServiceRedDot(visible)
    self.scene:setServiceRedDot(visible)
end

return HallCore