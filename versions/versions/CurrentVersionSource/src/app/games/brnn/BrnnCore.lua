local C = class("BrnnCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.brnn"
--场景配置
C.SCENE_CONFIG = {scenename = "brnn_scene", filename = "BrnnScene", logic="BrnnLogic", define="BrnnDefine", model="BrnnModel"}

function C:start()
    self:registerGameMsg(BRNN.CMD.SC_CONFIG_P,handler(self,self.onConfigs))
    self:registerGameMsg(BRNN.CMD.SC_GAMESTATE_P,handler(self,self.onGameStatus))
    self:registerGameMsg(BRNN.CMD.SC_BEGIN_INFO_P,handler(self,self.onBeginInfo))
    self:registerGameMsg(BRNN.CMD.SC_FIRST_P,handler(self,self.onFirstPokers))
    self:registerGameMsg(BRNN.CMD.SC_FAPAI_P,handler(self,self.onSecondPokers))
    self:registerGameMsg(BRNN.CMD.SC_OPTTIME_P,handler(self,self.onOperateTime))
    self:registerGameMsg(BRNN.CMD.SC_BUYHORSE_P,handler(self,self.onTablePlayerBet))
    self:registerGameMsg(BRNN.CMD.SC_ZHUANG_LIST_P,handler(self,self.onBankerList))
    self:registerGameMsg(BRNN.CMD.SC_ZHUANG_INFO_P,handler(self,self.onBankerInfo))
    self:registerGameMsg(BRNN.CMD.SC_NO_ZHUANG_P,handler(self,self.onNoBanker))
    self:registerGameMsg(BRNN.CMD.SC_NOTICE_NO_ZHUANG_P,handler(self,self.onCanOffBanker))
    self:registerGameMsg(BRNN.CMD.SC_SHOWCARD_P,handler(self,self.onShowPokers))
    self:registerGameMsg(BRNN.CMD.SC_SETTLEMENT_P,handler(self,self.onResult))
    self:registerGameMsg(BRNN.CMD.SC_OPER_ERROR_P,handler(self,self.onError))
    self:registerGameMsg(BRNN.CMD.SC_HISTORY_P,handler(self,self.onHistory))
    self:registerGameMsg(BRNN.CMD.SC_CLEAR_BUY_P,handler(self,self.onClearBetInfo))
    self:registerGameMsg(BRNN.CMD.SC_FOLLOW_BUY_P,handler(self,self.onFollowBet))
    self:registerGameMsg(BRNN.CMD.SC_NOTICE_ZHUANG_LIST_P,handler(self,self.onNoticeBankerList))
    self:registerGameMsg(BRNN.CMD.SC_BUYHORSE_INFO_P,handler(self,self.onOnlinePlayerBet))
    self:registerGameMsg(BRNN.CMD.SC_COLOR_POOL_P,handler(self,self.onJackpotInfo))
    self:registerGameMsg(BRNN.CMD.SC_RANKLIST_P,handler(self,self.onTablePlayerList))
    self:registerGameMsg(BRNN.CMD.SC_ALLLIST_P,handler(self,self.onAllPlayerList))
    C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(BRNN.CMD.SC_CONFIG_P)
    self:unregisterGameMsg(BRNN.CMD.SC_GAMESTATE_P)
    self:unregisterGameMsg(BRNN.CMD.SC_BEGIN_INFO_P)
    self:unregisterGameMsg(BRNN.CMD.SC_FIRST_P)
    self:unregisterGameMsg(BRNN.CMD.SC_FAPAI_P)
    self:unregisterGameMsg(BRNN.CMD.SC_OPTTIME_P)
    self:unregisterGameMsg(BRNN.CMD.SC_BUYHORSE_P)
    self:unregisterGameMsg(BRNN.CMD.SC_ZHUANG_LIST_P)
    self:unregisterGameMsg(BRNN.CMD.SC_ZHUANG_INFO_P)
    self:unregisterGameMsg(BRNN.CMD.SC_NO_ZHUANG_P)
    self:unregisterGameMsg(BRNN.CMD.SC_NOTICE_NO_ZHUANG_P)
    self:unregisterGameMsg(BRNN.CMD.SC_SHOWCARD_P)
    self:unregisterGameMsg(BRNN.CMD.SC_SETTLEMENT_P)
    self:unregisterGameMsg(BRNN.CMD.SC_OPER_ERROR_P)
    self:unregisterGameMsg(BRNN.CMD.SC_HISTORY_P)
    self:unregisterGameMsg(BRNN.CMD.SC_CLEAR_BUY_P)
    self:unregisterGameMsg(BRNN.CMD.SC_FOLLOW_BUY_P)
    self:unregisterGameMsg(BRNN.CMD.SC_NOTICE_ZHUANG_LIST_P)
    self:unregisterGameMsg(BRNN.CMD.SC_BUYHORSE_INFO_P)
    self:unregisterGameMsg(BRNN.CMD.SC_COLOR_POOL_P)
    self:unregisterGameMsg(BRNN.CMD.SC_RANKLIST_P)
    self:unregisterGameMsg(BRNN.CMD.SC_ALLLIST_P)
	C.super.exit(self)
end

--进入房间，房间信息
function C:onRoomInfo( info )
    C.super.onRoomInfo(self,info)
    self.model:reset()
    self.scene:cleanDesktop()
    if info["playerlist"] then
    	self.model:updateAllPlayerList(info["playerlist"])
    end
end

--玩家加入
function C:onPlayerEnter( info )
    C.super.onPlayerEnter(self,info)
    self.model:addPlayer(info)
end

--玩家离开
function C:onPlayerQuit( info )
    C.super.onPlayerQuit(self,info)
    self.model:removePlayer(info["playerid"])
end

function C:onQuitGame(info)
	dump(info,"onQuitGame>>>")
	if SCENE_NAME ~= "Hall" then
		local reason=info["sxreason"]
		if reason==8 then
			DialogLayer.new():show("由于长时间没有参与游戏，您已经被请出房间", function()
				self:quitGame();
			end, false);
		elseif reason==4 then
			DialogLayer.new():show("您已被踢出房间", function()
				self:quitGame();
			end, false);
		else
			--强退，重新打开游戏，拉进游戏，莫名收到服务器下发协议，reason==0 直接退出房间
			self:quitGame();
		end
    end
end

--断线重连
function C:onToOtherRoom( info )
	C.super.onToOtherRoom(self,info)
	dump(info,"断线重连")
    --牌型倍数配置
    if info["Odds"] then
		self.model.TYPE_BEI_CONFIGS = utils:copyTable(info["Odds"])
		--对倍数进行的一个补救措施，暂时写死5倍场跟10倍场
		if info["Odds"][17] and info["Odds"][17]==5 then
			self.model:setMaxTypeBei(3)
		elseif info["Odds"][17] and info["Odds"][17]==10 then
			self.model:setMaxTypeBei(8)
		end
    end
    --下注筹码配置
    if info["betchoice"] then
    	self.model.BET_CONFIGS = utils:copyTable(info["betchoice"])
    end
    --下注最低金额配置
    if info["betneed"] then
    	self.model.betNeed = info["betneed"]
    end
    --庄家信息
    self.model.bankerNeed  = info["zhuangneed"]
    self.model.bankerMinTurn = info["zhuangminturn"]
    self.model.bankerId = info["zhuangid"]
    self.model.bankerInfo = self.model:getPlayer(self.model.bankerId)
    self.scene:setUpBankerNeedMoney(self.model.bankerNeed)
	if info["zhuangid"] ~= 0 then
		if self.model.bankerId == self.model.myInfo["playerid"] then
			self.model.isBanker = true
			self.model.isGaming = true
			toastLayer:show("您正在坐庄")
		end
		self.scene:setBankerPlayer(self.model.bankerInfo)
	else
		self.scene:setBankerSystem()
	end
	--奖池
	if info["poolvalue"] then
		self.scene:setJackpotMoney(info["poolvalue"])
	end
	--当前状态
	self.model.currentStatus = info["state"]
    self.model.currentLefttime = info["lefttime"]
    --自己本轮还可以下注金额
    if info["canbet"] then
		self.model.selfCanBetMoney = info["canbet"]
		self.model:setMaxTypeBei(self.model.myInfo["money"]/self.model.selfCanBetMoney)
    else
    	self.model.selfCanBetMoney = self.model.myInfo["money"]/self.model:getMaxTypeBei()
    end
	--处理断线重新各种状态
    if self.model.currentStatus == BRNN.STATUS.NONE then
		self:handleOnToOtherRoomStatusNone(info)
	elseif self.model.currentStatus == BRNN.STATUS.START then
		self:handleOnToOtherRoomStatusStart(info)
	elseif self.model.currentStatus == BRNN.STATUS.BET then
		self:handleOnToOtherRoomStatusBet(info)
	elseif self.model.currentStatus == BRNN.STATUS.COMPARE then
		self:handleOnToOtherRoomStatusCompare(info)
	elseif self.model.currentStatus == BRNN.STATUS.RESULT then
		self:handleOnToOtherRoomStatusResult(info)
	end
	--请求奖池信息
	self:requestJackpotInfo()
	--请求走势图信息
	self:requestHistory()
end

--time:1
function C:handleOnToOtherRoomStatusNone( info )
	if self.model.myInfo["money"] < self.model.betNeed then
		self.scene:showBetNeedTips()
	end
end

--time:2
function C:handleOnToOtherRoomStatusStart( info )
	--发牌
	if info["card"] then
		self.scene:sendPokersImm(info["card"])
	end
	if self.model.myInfo["money"] < self.model.betNeed then
		self.scene:showBetNeedTips()
	end
	if self.model.currentLefttime > 1 then
		self.scene:showVsAni()
	end
end

--time:12
function C:handleOnToOtherRoomStatusBet( info )
	--发牌
	self.scene:sendPokersImm(info["card"])
	self.scene:showBetTimer(self.model.currentLefttime)

	--设置筹码
	if info["buyhorse"] then
		for k,v in pairs(info["buyhorse"]) do
			local area = tonumber(k) or 0
			self.model:updateAreaBetChips(area,v)
			self.scene:updateAreaMoney(area,v)
			self.scene:createAreaChips(area,v)
		end
	end

	--他人下注
	if info["players"] then
		for i,player in ipairs(info["players"]) do
			local playerId = player.playerid
			if player.bet then
				for k,money in pairs(player.bet) do
					local area = tonumber(k)
					self.model:addPlayerBet(playerId,area,money)
				end
			end
		end
	end

	--自己下注
	if info["currbuy"] then
		for k,money in pairs(info["currbuy"]) do
			if money > 0 then
				self.model.lastHadBet = true
				self.model.isGaming = true
				local area = tonumber(k)
				self.model:addPlayerBet(self.model.myInfo["playerid"],area,money)
			end
		end
		self.scene:updateMyBetChips()
	end

	if self.model.isGaming then
		if self.model.currentLefttime > 1 then
			if self.model.isBanker == false then
				self.scene:setBetAreaEnabled(true)
				self.scene:updateChipBtnStatus(self.model.lastSelectedChipLevel)
				toastLayer:show("正在下注，您可以继续投注")
			end
		end
	else
		--金币不足
		if self.model.myInfo["money"] < self.model.betNeed then
			self.scene:showBetNeedTips()
		elseif self.model.currentLefttime > 1 then
			if self.model.isBanker == false then
				self.scene:setBetAreaEnabled(true)
				self.scene:updateChipBtnStatus(self.model.lastSelectedChipLevel)
				toastLayer:show("正在下注，您可以投注")
			end
		end
	end
	--幸运星
	self.scene:flyLuckyStarIfNeeded()
end

--time:7
function C:handleOnToOtherRoomStatusCompare( info )
	--发牌
	self.scene:sendPokersImm(info["card"])
	--设置筹码
	if info["buyhorse"] then
		for k,v in pairs(info["buyhorse"]) do
			local area = tonumber(k) or 0
			self.model:updateAreaBetChips(area,v)
			self.scene:updateAreaMoney(area,v)
			self.scene:createAreaChips(area,v)
		end
	end
	--他人下注
	if info["players"] then
		for i,player in ipairs(info["players"]) do
			local playerId = player.playerid
			if player.bet then
				for k,money in pairs(player.bet) do
					local area = tonumber(k)
					self.model:addPlayerBet(playerId,area,money)
				end
			end
		end
	end
	--自己下注
	if info["currbuy"] then
		for k,money in pairs(info["currbuy"]) do
			if money > 0 then
				self.model.lastHadBet = true
				self.model.isGaming = true
				local area = tonumber(k)
				self.model:addPlayerBet(self.model.myInfo["playerid"],area,money)
			end
		end
		self.scene:updateMyBetChips()
	end
	--金币不足
	if self.model.myInfo["money"] < self.model.betNeed  and self.model.isGaming == false then
		self.scene:showBetNeedTips()
	end
	--开牌
	self.scene:openPokers(info["card"],self.model.currentLefttime)
	--幸运星
	self.scene:flyLuckyStarIfNeeded()
end

--time:8
function C:handleOnToOtherRoomStatusResult( info )
	--金币不足
	if self.model.myInfo["money"] < self.model.betNeed then
		self.scene:showBetNeedTips()
	end
	self.scene:showWaitting()
end

--房间状态
function C:onRoomState( info )
    C.super.onRoomState(self,info)
end

--更新玩家金币
function C:updatePlayerMoney( info )
	C.super.updatePlayerMoney(self,info)
    if info.playerid == dataManager.playerId then
        dataManager.userInfo.money = info.coin
        eventManager:publish("Money",info.coin)
        self.model.myInfo["money"] = info.coin
    end
    self.scene:updatePlayerMoney(info.playerid,info.coin)
    --更新下注按钮状态
    if self.model.currentStatus == BRNN.STATUS.BET then
    	self.scene:updateChipBtnStatus(self.model.lastSelectedChipLevel)
    end
end

--配置信息
function C:onConfigs( info )
	dump(info,"onConfigs",10)
	--下注按钮面值
	if info["Bet"] then
		self.model.BET_CONFIGS = utils:copyTable(info["Bet"])
	end
	--牌型倍数
	if info["Odds"] then
		self.model.TYPE_BEI_CONFIGS = utils:copyTable(info["Odds"])
	end
	--下注时间
	self.model.BET_TIME = info["TimeLimit"]["BuyHorse"]
	--上庄条件
	if info["Zhuang"] and self.model.roomInfo.orderid and info["Zhuang"][self.model.roomInfo.orderid] then
		local temp = info["Zhuang"][self.model.roomInfo.orderid]
		self.model.bankerMaxTurn = temp.MaxTurn
		self.model.bankerMinTurn = temp.MinTurn
		self.model.bankerNeed = temp.Need
		self.scene:setUpBankerNeedMoney(self.model.bankerNeed)
	end
	--下注需要金币
	self.model.betNeed = info["betneed"] --or 5000
	--更新下注按钮
	self.scene:updateChipBtnText()
end

--游戏状态
function C:onGameStatus( info )
	dump(info,"onGameStatus",10)
	self.model.currentStatus = info["state"]
	self.model.currentLefttime = info["lefttime"]
	if self.model.currentStatus == BRNN.STATUS.NONE then
		--重置阶段
		self.model.isGaming = false
		self.model:clearBetPool()
		self.scene:cleanDesktop()
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
		if self.model.myInfo["money"] < self.model.betNeed then
			self.scene:showBetNeedTips()
		end
		if self.model.isBanker then
			self.model.isGaming = true
		else
			self.model.isGaming = false
		end
	elseif self.model.currentStatus == BRNN.STATUS.START then
		--开始阶段播放动画
		self.model:clearBetPool()
		-- self.scene:cleanDesktop()
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
		if self.model.myInfo["money"] < self.model.betNeed then
			self.scene:showBetNeedTips()
		end
		self.scene:showVsAni()
		if self.model.isBanker then
			self.model.isGaming = true
		else
			self.model.isGaming = false
		end
	elseif self.model.currentStatus == BRNN.STATUS.BET then
		--开始下注阶段
		self.scene:showStartAni()
		self.scene:showBetTimer(self.model.currentLefttime)
		if self.model.myInfo["money"] > self.model.betNeed then
			if self.model.isBanker == false then
				self.model.selfCanBetMoney = self.model.myInfo["money"]/self.model:getMaxTypeBei()
				self.scene:setBetAreaEnabled(true)
				self.scene:updateChipBtnStatus(self.model.lastSelectedChipLevel)
				self.scene:setXuyaBtnEnabled(self.model.lastHadBet)
			end
		else
			self.scene:showBetNeedTips()
		end
	elseif self.model.currentStatus == BRNN.STATUS.COMPARE then
		--开牌阶段
		self.scene:showStopAni()
		self.scene:hideBetTimer()
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
		self.model.isGaming = false
		if self.model.isBanker then
			self.model.isGaming = true
		end
	elseif self.model.currentStatus == BRNN.STATUS.RESULT then
		--结算阶段
		self.model.isGaming = false
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
		if self.model.isBanker then
			self.model.isGaming = true
		end
	end
end

--开局相关信息
function C:onBeginInfo( info )
	-- --dump(info,"onBeginInfo",10)
end

--发牌 1:east 2:south 3:west 4:north banker:zhuang
function C:onFirstPokers( info )
	--dump(info,"onFirstPokers",10)
	self.scene:sendPokersAni(info)
end

--庄家牌(停用)
function C:onSecondPokers( info )
	--dump(info,"onSecondPokers",10)
end

--操作时间(停用)
function C:onOperateTime( info )
	--dump(info,"onOperateTime")
end

--在桌玩家下注
function C:onTablePlayerBet( info )
	--dump(info,"在桌玩家下注")
	if info["playerid"] == self.model.myInfo["playerid"] then
		self.model.isGaming = true
		if info["chouma"] then
			dataManager.userInfo.money = info["chouma"]
	        eventManager:publish("Money",info["chouma"])
	        self.model.myInfo["money"] = info["chouma"]
		end
		if info["buyall"] and info["direction"] then
			self.scene:updateMyAreaBetChips(info["direction"],info["buyall"])
		end
		if info["canbet"] then
			self.model.selfCanBetMoney = info["canbet"]
			self.scene:updateChipBtnStatus(self.model.currentChipLevel)
			if self.model.selfCanBetMoney < self.model.BET_CONFIGS[1] then
				toastLayer:show("本轮下注达到最大金额")
			end
		end
	end
	
	if info["playerid"] ~= self.model.myInfo["playerid"] then
		self.model:addPlayerBet(info["playerid"],info["direction"],info["odds"])
	end
	self.model:updateAreaBetChips(info["direction"],info["dirctionall"])
	self.scene:updatePlayerMoney(info["playerid"],info["chouma"])
	self.scene:updateAreaMoney(info["direction"],info["dirctionall"])
	local chipLevel = self.model:getChipLevel(info["odds"])
	self.scene:tablePlayerThrowChips(info["playerid"],info["direction"],chipLevel)
end

--玩家续押
function C:onFollowBet( info )
	dump(info,"玩家续押")
	--玩家余额
	self.scene:updatePlayerMoney(info["playerid"],info["chouma"])
	--区域筹码
	if info["alldata"] then
		for k,v in pairs(info["alldata"]) do
			local area = tonumber(k)
			self.model:updateAreaBetChips(area,v)
			self.scene:updateAreaMoney(area,v)
		end
	end
	--丢筹码
	if info["buy"] then
		for k,v in pairs(info["buy"]) do
			local area = tonumber(k)
			self.model:addPlayerBet(info["playerid"],area,v)
			self.scene:followPlayerThrowChips(info["playerid"],area,v)
		end
	end
	--更新自己下注筹码，更新下注按钮
	if info["playerid"] == self.model.myInfo["playerid"] then
		self.model.isGaming = true
		self.scene:updateChipBtnStatus(self.model.currentChipLevel)
		self.scene:updateMyBetChips()
	end
end

--在线玩家下注
function C:onOnlinePlayerBet( info )
	--dump(info,"在线玩家下注")
	for k,v in pairs(info["all"]) do
		local area = tonumber(k) or 0
		self.scene:updateAreaMoney(area,v)
		self.model:updateAreaBetChips(area,v)
	end
	--过滤自己下注
	local isContainSelf = false
	if info["list"] then
		for i,v in ipairs(info["list"]) do
			if v == self.model.myInfo["playerid"] then
				isContainSelf = true
				break
			end
		end
	end
	for k,v in pairs(info["bet"]) do
		if v > 0 then
			local area = tonumber(k) or 0
			local money = v
			if isContainSelf then
				money = money - self.model:getMyLastBet(area)
			end
			self.scene:onlinePlayerThrowChips(area,money)
		end
	end
	self.model:clearMyLastBet()
end

--上庄列表(主动下发)
function C:onBankerList( info )
	dump(info,"onBankerList",10)
	if info["list"] then
		self.model:updateBankerList(info["list"])
	elseif info["isempty"] == 1 then
		self.model:updateBankerList(nil)
	end
	self.scene:refreshBankerList()
end

--当前庄家信息(主动下发)
function C:onBankerInfo( info )
	dump(info,"onBankerInfo",10)
	if info["zhuangid"] ~= self.model.bankerId then
		toastLayer:show("切换庄家")
		self.model:updateBanker(info)
		if self.model.bankerId == 0 then
			self.scene:setBankerSystem()
		else
			local info = self.model.bankerInfo
			self.scene:setBankerPlayer(info)
		end
		--切换庄家的时候刷新等待上庄列表
		self.scene:refreshBankerList()
	end
	if self.model.isBanker and self.model.currentStatus == BRNN.STATUS.RESULT then
		local turn = tonumber(info["zhuangturn"]) or 0
		if turn > 1 then
			toastLayer:show("您已坐庄"..tostring(turn).."局")
		end
	end
end

--玩家下庄
function C:onNoBanker( info )
	--dump(info,"onNoBanker",10)
end

--玩家可以下庄
function C:onCanOffBanker( info )
	--dump(info,"onCanOffBanker",10)
	if info["round"] then
		toastLayer:show("您可以在"..tostring(info["round"]).."局后下庄")
	end
end

--开牌
function C:onShowPokers( info )
	dump(info,"onShowPokers",10)
	self.scene:openPokers(info)
end

--错误提示消息
function C:onError( info )
	dump(info,"onError")
	local code = info["code"]
	if code == BRNN.ERROR.NOT_MONEY then
		--toastLayer:show("每轮下注不能超过自身金币的1/3")
		toastLayer:show("金币不足，下注失败")
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
	elseif code == BRNN.ERROR.BET_LIMIT then
		toastLayer:show("当前下注已达上限")
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
	elseif code == BRNN.ERROR.NOT_ROUND then
		toastLayer:show("坐庄轮次不足 不能下庄")
	elseif code == BRNN.ERROR.OZ_STATE then
		toastLayer:show("当前游戏状态不能下庄")
		self.scene:setBetAreaEnabled(false)
		self.scene:setAllChipBtnSelected(false)
		self.scene:setAllChipBtnEnabled(false)
		self.scene:setXuyaBtnEnabled(false)
	elseif code == BRNN.ERROR.BANKER_NOT_MONEY then
		local text = "上庄需要"..utils:moneyString(self.model.bankerNeed).."金币"
		toastLayer:show(text)
	elseif code == BRNN.ERROR.NEXT_ROUND then
		toastLayer:show("您将在下一局下庄")
	elseif code == BRNN.ERROR.OFF_BANKER_NONIU then
		-- toastLayer:show("当前下注已达上限")
	elseif code == BRNN.ERROR.APPLY_BANKER_OK then
		toastLayer:show("申请上庄成功，已加入上庄列表")
	elseif code == BRNN.ERROR.NOT_MONEY_BET then
		local text = "金币多于"..utils:moneyString(self.model.betNeed).."才可以下注哟~"
		toastLayer:show(text)
		self.scene:showBetNeedTips()
	elseif code == BRNN.ERROR.NOT_BET_HISTORY then
		toastLayer:show("续投失败,没有投注记录")
		self.model.lastHadBet = false
		self.scene:setXuyaBtnEnabled(false)
	elseif code == BRNN.ERROR.SELF_NOT_MONEY_TO_CONTINUE then
		toastLayer:show("您的金币不足，续投失败")
		self.model.lastHadBet = false
		self.scene:setXuyaBtnEnabled(false)
	elseif code == BRNN.ERROR.BANKER_NOT_MONEY_TO_CONTINUE then
		toastLayer:show("庄家金币不足，续投失败")
		self.model.lastHadBet = false
		self.scene:setXuyaBtnEnabled(false)
	end
end

--奖池信息
function C:onJackpotInfo( info )
	-- --dump(info,"onJackpotInfo",10)
	if info["data"] then
		self.scene:reloadRewardPlayerList(info["data"])
	end
end

--走势图返回
function C:onHistory( info )
	-- --dump(info,"onHistory",10)
	if info["data"] then
		self.scene:reloadHistory(info["data"])
		self.model.lastRefreshHistoryTime = os.time()
	end
end

function C:onClearBetInfo( info )
	--dump(info,"onClearBetInfo",10)
	if info["playerid"] == self.model.myInfo["playerid"] then
		self.model.lastHadBet = false
		self.scene:setXuyaBtnEnabled(false)
	end
end

--(未处理)
function C:onNoticeBankerList( info )
	--dump(info,"onNoticeBankerList",10)
end

--在桌玩家列表(主动下发)
function C:onTablePlayerList( info )
	-- --dump(info,"onTablePlayerList",10)
	self.model.tablePlayerList = info["playerlist"]
	self.scene:showTablePlayerList(self.model.tablePlayerList)
end

--玩家列表(请求下发)
function C:onAllPlayerList( info )
	--dump(info,"onAllPlayerList",10)
	self.scene:responsePlayerList(info)
end

--结算消息
function C:onResult( info )
	dump(info,"onResult",10)
	self.scene:doResult(info)
	--每30分钟刷新走势图数据
	local nowTime = os.time()
	if nowTime - self.model.lastRefreshHistoryTime >= 30*60 then
		--奖池信息
		self:requestJackpotInfo()
		--走势图
		self:requestHistory()
	end
end

--发送协议
--下注
function C:sendBet( area, money )
	local info = {}
	info["odds"] = money
	info["direction"] = area
	self:sendGameMsg(BRNN.CMD.CS_BUYHORSE_P,info)
end

--请求申请上庄列表(没看到请求)
function C:requestApplyOnBankerList()
	self:sendGameMsg(BRNN.CMD.CS_REQUEST_ZHUANG_LIST_P,info)
end

--申请上庄
function C:applyOnBanker()
	self:sendGameMsg(BRNN.CMD.CS_REQUEST_ZHUANG_P)
end

--取消申请上庄
function C:cancelApplyOnBanker()
	self:sendGameMsg(BRNN.CMD.CS_REQUEST_NOT_ZHUANG_P)
end

--申请下注(当前自己是庄家)
function C:applyOffBanker()
	self:sendGameMsg(BRNN.CMD.CS_ZHUANG_OFF_P)
end

--请求走势
function C:requestHistory()
	self:sendGameMsg(BRNN.CMD.CS_HISTORY_P)
end

--清除下注(停用)
function C:clearBetHistory( info )
	self:sendGameMsg(BRNN.CMD.CS_CLEAR_BUY_P,info)
end

--续押
function C:followHistoryBet()
	self:sendGameMsg(BRNN.CMD.CS_FOLLOW_BUY_P)
end

--请求奖池信息
function C:requestJackpotInfo()
	self:sendGameMsg(BRNN.CMD.CS_COLOR_POOL_P)
end

--请求在桌玩家(不用请求，服务器主动下发)
function C:requestTablePlayerList()
	self:sendGameMsg(BRNN.CMD.CS_RANKLIST_P)
end

--请求玩家列表
function C:requestAllPlayerList( page )
	local info = {}
	info["page"] = page
	self:sendGameMsg(BRNN.CMD.CS_ALLLIST_P,info)
end

--请求状态时间配置(断线重新正在下注阶段请求)
function C:requestStatusTime()
	self:sendGameMsg(BRNN.CMD.CS_TIME_P)
end

return C