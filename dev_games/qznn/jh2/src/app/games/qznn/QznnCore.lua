local C = class("QznnCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.qznn"
--场景配置
C.SCENE_CONFIG = {scenename = "qznn_scene", filename = "QznnScene", logic="QznnLogic", define="QznnDefine", model="QznnModel"}

function C:start()
	self:registerGameMsg(self.define.SC_CONFIG_P,handler(self,self.onConfig))
	self:registerGameMsg(self.define.SC_GAMESTATE_P,handler(self,self.onGameState))
	self:registerGameMsg(self.define.SC_CARD,handler(self,self.onSendCard))
	self:registerGameMsg(self.define.SC_PLAYER_INFO,handler(self,self.onPlayerInfo))
	self:registerGameMsg(self.define.SC_SHOW_JIESHUAN,handler(self,self.onSettlement))
	self:registerGameMsg(self.define.SC_SHOWCARD,handler(self,self.onShowCard))
	C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(self.define.SC_CONFIG_P)
	self:unregisterGameMsg(self.define.SC_GAMESTATE_P)
	self:unregisterGameMsg(self.define.SC_CARD)
	self:unregisterGameMsg(self.define.SC_PLAYER_INFO)
	self:unregisterGameMsg(self.define.SC_SHOW_JIESHUAN)
	self:unregisterGameMsg(self.define.SC_SHOWCARD)
	C.super.exit(self)
end

--子游戏公共协议
--收到开始匹配
function C:onStartMatch( info )
	C.super.onStartMatch(self,info)
	self.scene:hideOtherPlayers()
	self.scene:cleanDesktop()
	self.scene:showWaitForOther()
	self.model.isGaming = false
end

--收到匹配结束
function onFinishMatch( info )
	C.super.onFinishMatch(self,info)
	self.scene:hideWaitForOther()
	self.model.isGaming = true
end

--玩家加入
function C:onPlayerEnter( info )
	C.super.onPlayerEnter(self,info)
	dump(info,"玩家加入")
    self.model.currentPlayerCount = self.model.currentPlayerCount+1
    local localSeatId = self.scene:getLocalSeatId(info["seat"])
    if self.model.currentGameState == self.define.GAMESTATE_JIESUAN and
       self.model.playerGameStateArr[localSeatId] == true then
       --延迟加入
       self.model.enterPlayers[localSeatId] = info
    else
    	self.scene:showPlayer(info)
    end
end

--玩家离开
function C:onPlayerQuit( info )
    C.super.onPlayerQuit(self,info)
    local playerId = info["playerid"]
    if playerId == dataManager.userInfo["playerid"] then
    	if self.model.isKicked then
    		--金币不足被踢,结算后会有弹窗提示，点击会退出
    		return
    	else
    		if self.model.currentPlayerCount > 1 then
    			--几局未操作，游戏开始时，被服务器踢
		    	self:quitGame()
		    	return
		    else
		    	--服务器删除房间，踢人，重新发匹配
		    	self.scene:replacePlayers()
		    	self.scene:hideOtherPlayers()
		    	self.scene:cleanPlayers()
		    	self.scene:cleanDesktop()
		    	self.scene:hideContinuePanel()
		    	self.scene:showWaitForOther()
		    	self:sendMatchMsg()
    		end
    	end
    else
    	local localSeatId = self.scene:getLocalSeatIdByPlayerId(playerId)
    	if self.model.currentGameState == self.define.GAMESTATE_JIESUAN and
    	   self.model.playerGameStateArr[localSeatId] == true then
    	   --延迟退出
    	   table.insert(self.model.quitPlayerIds,playerId)
    	else
    		self.scene:hidePlayerByPlayerId(playerId)
    	end
    	self.model.currentPlayerCount = self.model.currentPlayerCount-1
    	if self.model.currentPlayerCount <= 1 then
	    	self.scene:replacePlayers()
	    	self.scene:hideOtherPlayers()
	    	self.scene:cleanPlayers()
	    	self.scene:cleanDesktop()
	    	self.scene:hideContinuePanel()
	    	self.scene:showWaitForOther()
	    	self:sendMatchMsg()
	    end
    end
end

--游戏结束,你条件不满足被踢出房间,如果你在暂离状态,也会被踢出房间
function C:onDeletePlayer( info )
    C.super.onDeletePlayer(self,info)
    self.model.isKicked = true
end

--金币不足，服务器发同意退出，父类收到直接退出，这里需要弹窗，玩家点确定才退出
function C:onQuitGame( info )
    --什么都不做
end

--玩家状态
function C:onPlayerState( info )
    C.super.onPlayerState(self,info)
end

--更新玩家金币
function C:updatePlayerMoney( info )
    C.super.updatePlayerMoney(self,info)
    local playerId = info["playerid"]
    local blance = info["coin"]
    self.scene:setPlayerBlance(blance,playerId)
end

--进入房间，房间信息
function C:onRoomInfo( info )
	C.super.onRoomInfo(self,info)
	dump(info,"进入房间，房间信息")
    --设置model
    self.model:reset()
    self.model.difen = info["difen"] or 0
    self.model.inmoney = info["inmoney"] or 0
    local playerlist = info["playerlist"]
    self.model.currentPlayerCount = #playerlist or 0
    for k,v in pairs(playerlist) do
    	if v["playerid"] == dataManager.userInfo["playerid"] then
    		self.model.mySeatId = v["seat"]
    		break
    	end
    end
    --设置页面
	self.scene:setDifen(utils:moneyString(self.model.difen,1))
	self.scene:hideWaitForOther()
	self.scene:hideWaitForNext()
	self.scene:hideTimer()
	self.scene:hideOtherPlayers()
    for k,v in pairs(playerlist) do
    	self.scene:showPlayer(v)
	end
end

--房间状态
function C:onRoomState( info )
    C.super.onRoomState(self,info)
end

--断线重连
function C:onToOtherRoom( info )
	C.super.onToOtherRoom(self,info)
	dump(info,"断线重连")
    self.model.currentGameState = info["GameState"]
	if self.model.currentGameState == self.define.GAMESTATE_QIANGZHUANG then
		--2等待抢庄,游戏已经开始
		for i=1,5 do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				self.model.playerGameStateArr[localSeatId] = isGaming
				if isGaming then
					if info[i]["beilv"] then
						self.scene:showPlayerQiangTips(localSeatId,info[i]["beilv"],false)
						if localSeatId == 1 then
							self.model.hadQiang = true
						end
					elseif localSeatId == 1 then
						self.model.hadQiang = false
					end
					--显示牌
					self.scene:sendPlayerPoker(localSeatId)
				end
			end
		end
	elseif self.model.currentGameState == self.define.GAMESTATE_QIANGZHUANG2 then
		--3播放抢庄闪烁动画,已确定庄设置庄标识--2秒钟
		for i=1,5 do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				self.model.playerGameStateArr[localSeatId] = isGaming
				if info[i]["iszhuang"] == 1 then
					self.model.zhuangId = info[i]["playerid"]
					self.model.zhuangBei = info[i]["beilv"] or 1
					self.scene:showPlayerQiangTips(localSeatId,self.model.zhuangBei,false)
					self.scene:showPlayerZhuangFlags(localSeatId,false)
				end
				if isGaming then
					--显示牌
					self.scene:sendPlayerPoker(localSeatId)
				end
			end
		end
	elseif self.model.currentGameState == self.define.GAMESTATE_PEILV then
		--4等待加注
		for i=1,5 do
			if info[i] and info[i]["iszhuang"] == 1 then
				self.model.zhuangId = info[i]["playerid"]
				self.model.zhuangBei = info[i]["beilv"] or 1
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				self.scene:showPlayerQiangTips(localSeatId,self.model.zhuangBei,false)
				self.scene:showPlayerZhuangFlags(localSeatId,false)
				break
			end
		end
		--设置玩家是否在游戏，闲家下注信息
		for i=1,5 do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				self.model.playerGameStateArr[localSeatId] = isGaming
				if isGaming and info[i]["playerid"] ~= self.model.zhuangId then
					--是否已选择下注倍数
					if info[i]["peilv"] then
						self.scene:showPlayerBetTips(localSeatId,info[i]["peilv"],false)
						if localSeatId == 1 then
							self.model.hadBet = true
						end
					elseif localSeatId == 1 then
						self.model.hadBet = false
					end
				end
				if isGaming then
					--显示牌
					self.scene:sendPlayerPoker(localSeatId)
				end
			end
		end
	elseif self.model.currentGameState == self.define.GAMESTATE_FAPAI or self.model.currentGameState == self.define.GAMESTATE_TANPAI then
		--5发牌阶段 6等待玩家摊牌 -先获取庄信息
		for i=1,5 do
			if info[i] and info[i]["iszhuang"] == 1 then
				self.model.zhuangId = info[i]["playerid"]
				self.model.zhuangBei = info[i]["beilv"] or 1
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				self.scene:showPlayerQiangTips(localSeatId,self.model.zhuangBei,false)
				self.scene:showPlayerZhuangFlags(localSeatId,false)
				break
			end
		end
		--设置玩家是否在游戏，闲家下注信息
		for i=1,5 do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				self.model.playerGameStateArr[localSeatId] = isGaming
				if isGaming then
					--闲家已选择下注倍数
					if info[i]["playerid"] ~= self.model.zhuangId then
						self.scene:showPlayerBetTips( localSeatId, info[i]["peilv"], false )
					end
					--显示牌
					self.scene:sendPlayerPoker(localSeatId)
					--设置牌信息
					if info[i][1] and info[i][1]["poker"] then
						self.scene:setPlayerPokerData(localSeatId,info[i][1]["poker"])
					end
					--是否已经摊牌
					local isTanPai = info[i]["tanpai"] == 1
					if localSeatId == 1 then
						printInfo(">>>>>>>>>>>等待玩家摊牌>>>>>>>>1>>>>>")
						self.scene:turnSelfPoker()
						self.model.hadTan = isTanPai
						printInfo(">>>>>>>>>>>等待玩家摊牌>>>>>>>>2>>>>>")
						if self.model.hadTan == false then
							self.scene:showTanpaiBtn()
							printInfo(">>>>>>>>>>>等待玩家摊牌>>>>>>>>3>>>>>")
							self.scene:showCalculatePanel()
						else
							self.scene:hideTanpaiBtn()
							self.scene:hideCalculatePanel()
						end
					end
					if isTanPai then
						self.scene:showPlayerPoker( localSeatId )
					end
				end
			end
		end
	end
	--设置玩家头像是否灰掉
	for i=1,5 do
		local showed = self.model.playerGameStateArr[i] == false
		self.scene:showPlayerWaitting(i,showed)
	end
	--设置游戏状态
	if self.model.playerGameStateArr[1] then
		self.model.isGaming = true
	else
		self.model.isGaming = false
		--游戏进行中
		self.scene:showWaitForNext()
	end
end

--子游戏协议
--收到配置信息
function C:onConfig( info )
	dump(info,"onConfig")
end

--收到游戏状态
function C:onGameState( info )
	dump(info,"onGameState")
	--设置游戏状态
	self.model.currentGameState = info["state"]
	self.model.currentLeftTime = info["lefttime"]
	if self.model.playerGameStateArr[1] then
		if self.model.currentGameState == self.define.GAMESTATE_NONE or
		   self.model.currentGameState == self.define.GAMESTATE_XIUXI or
		   self.model.currentGameState == self.define.GAMESTATE_JIESUAN
		then
			self.model.isGaming = false
		else
			self.model.isGaming = true
		end
	else
		self.model.isGaming = false
	end
	--处理游戏状态
	if self.model.currentGameState == self.define.GAMESTATE_NONE then
		-- 0 等待玩家加入
		self.scene:cleanDesktop()
		self.scene:cleanPlayers()
		self.scene:replacePlayers()
		self.scene:hideOtherPlayers()
		self.scene:hideContinuePanel()
		self.scene:showWaitForOther()
	elseif self.model.currentGameState == self.define.GAMESTATE_XIUXI then
		--自动离开
		if self.model.autoQuit then
			self:quitGame()
			return
		end
		-- 1 休息下一局游戏开始前3s	
		self.scene:cleanPlayers()
		self.scene:cleanDesktop()
		self.scene:setPlayerGameState(true)
		self.scene:showTimer(self.model.currentLeftTime,QznnTimerClassTypeGameStart,function( finished,time )
			if time and time <= 1 then
				self.model.isGaming = true
			end
		end)
	elseif self.model.currentGameState == self.define.GAMESTATE_QIANGZHUANG then
		-- 2 正在抢庄5s
		self.scene:hideTimer()
		self.scene:hideContinuePanel()
		self.scene:replacePlayers()
		--self.scene:cleanPlayers()
		for i=1,5 do
			if self.model.playerGameStateArr[i] then
				self.scene:showPlayerWaitting(i,false)
			end
		end
		local showQiangTimer = function( time )
			local callback = function( finished )
				if finished == true then
					self.scene:hideQiangPanel()
				end
			end
			if self.model.playerGameStateArr[1] and self.model.hadQiang == false then
				self.scene:showQiangPanel()
				self.scene:showTimer(time,QznnTimerClassTypeQiangZhuang,callback)
			else
				self.scene:showTimer(time,QznnTimerClassTypeQiangZhuang2,callback)
			end
		end
		if self.model.currentLeftTime >= 4.6 then
			self.scene:playGameStartAni(function()
				--showQiangTimer(self.model.currentLeftTime)
			end)
		end
		local delay = 0.8
		local sort = {2,3,4,5,1}
		for i=1,5 do
			local index = sort[i]
			if self.model.playerGameStateArr[index] then
				self.scene:sendPlayerPokerAni(index,delay)
				delay = delay + 0.2
			end
		end
		utils:delayInvoke("qznn.sendCard",delay,function()
			showQiangTimer(self.model.currentLeftTime-delay)
		end)
		-- if self.model.currentLeftTime > 5 and self.model.playerGameStateArr[1] then
		-- 	self.scene:playGameStartAni(function()
		-- 		showQiangTimer(5)
		-- 		-- local delay = 0
		-- 		-- for i=1,5 do
		-- 		-- 	if self.model.playerGameStateArr[i] then
		-- 		-- 		self.scene:sendPlayerPokerAni(i,delay)
		-- 		-- 		delay = delay + 0.2
		-- 		-- 	end
		-- 		-- end
		-- 	end)
		-- elseif self.model.currentLeftTime > 1 then
		-- 	showQiangTimer(self.model.currentLeftTime)
		-- end
	elseif self.model.currentGameState == self.define.GAMESTATE_QIANGZHUANG2 then
		-- 3 播放选庄闪烁动画2s
		self.scene:hideTimer()
		self.scene:playChoiceZhuangAni(self.model.zhuangId,self.model.qiangZhuangIds)
	elseif self.model.currentGameState == self.define.GAMESTATE_PEILV then
		-- 4 加注4s
		self.scene:hideTimer()
		self.scene:hideQiangPanel()
		--隐藏非庄家的抢庄提示
		local zhuangSeat=self.scene:getLocalSeatIdByPlayerId(self.model.zhuangId)
		for i=1,5 do
			if zhuangSeat~=i then
				self.scene:hidePlayerQiangTips(i)
			end
		end
		if self.model.currentLeftTime > 1 then
			local callback = function( finished )
				if finished == true then
					self.scene:hideBetPanel()
				end
			end
			local ctype = QznnTimerClassTypeXiaZhu3
			if self.model.playerGameStateArr[1] then
				if self.model.zhuangId ~= dataManager.userInfo["playerid"] and self.model.hadBet == false then
					self.scene:showBetPanel()
					ctype = QznnTimerClassTypeXiaZhu
				else
					ctype = QznnTimerClassTypeXiaZhu2
				end
			end
			self.scene:showTimer(self.model.currentLeftTime,ctype,callback)
		end
	elseif self.model.currentGameState == self.define.GAMESTATE_FAPAI then
		-- 5 发牌2s
		--self.scene:hideTimer()
	elseif self.model.currentGameState == self.define.GAMESTATE_TANPAI then
		-- 6 摊牌7s
		self.scene:hideTimer()
		self.scene:hideBetPanel()
		local callback = function( finished )
			if finished == true then
				self.scene:hideTanpaiBtn()
				self.scene:hideCalculatePanel()
			end
		end
		if self.model.playerGameStateArr[1] and self.model.hadTan == false then
			-- self.scene:showTanpaiBtn()
			-- self.scene:showCalculatePanel()
			self.scene:showTanpaiBtn()
			self.scene:showCalculatePanel()
			self.scene:showTimer(self.model.currentLeftTime,QznnTimerClassTypeTanpai,callback)
		else
			self.scene:showTimer(self.model.currentLeftTime,QznnTimerClassTypeTanpai2,callback)
		end
	elseif self.model.currentGameState == self.define.GAMESTATE_JIESUAN then
		-- 7 结算1s
		self.scene:hideTimer()
	elseif self.model.currentGameState == self.define.GAMESTATE_ZHUNBEI then
		-- 8 准备（暂时没有）
		self.scene:hideTimer()
	end
end

--收到发牌信息
function C:onSendCard( info )
	dump(info,"onSendCard")
	local delay = 0
	for i=1,5 do
		if info[i] then
			local item = info[i]
			local localSeatId = self.scene:getLocalSeatId( item["seatid"] )
			if self.model.playerGameStateArr[localSeatId] then
				if item["poker"] and localSeatId==1 then
					self.scene:setPlayerPokerData( localSeatId, item["poker"] )
					self.scene:turnSelfPoker()
					self.scene:showTanpaiBtn()
					self.scene:showCalculatePanel()
				end
				--self.scene:sendPlayerPokerAni(localSeatId,delay)
    			delay = delay + 0.2
			end
		end
	end
end

--收到玩家操作信息
function C:onPlayerInfo( info )
	dump(info,"onPlayerInfo")
	--玩家id
	local playerId = info["playerid"]
	--玩家庄
	if info["iszhuang"] then
		self.model.zhuangId = playerId
		self.model.zhuangBei = info["beilv"]
		self.model.qiangZhuangIds = info["randlist"]
	--抢庄倍数
	elseif info["beilv"] then
		local beilv = info["beilv"]
		self.scene:showPlayerQiangTipsById( playerId, beilv, true )
	--加注倍数
	elseif info["peilv"] then
		local peilv = info["peilv"]
		self.scene:showPlayerBetTipsById( playerId, peilv, true )
	end
end

--收到摊牌信息
function C:onShowCard( info )
	dump(info,"onShowCard")
	local localSeatId = self.scene:getLocalSeatId( info["seatid"] )
	local poker = info["poker"]
	self.scene:setPlayerPokerData(localSeatId,poker)
	self.scene:showPlayerPoker(localSeatId)
	if localSeatId==1 then
		self.scene:hideTanpaiBtn()
		self.scene:hideCalculatePanel()
	end
end

--收到结算信息
function C:onSettlement( info )
	dump(info,"onSettlement")
	self.model.currentGameState = self.define.GAMESTATE_JIESUAN
	self.model.isGaming = false
	self.scene:updateBattery()
	self.scene:hideTimer()
	self.scene:doSettlement(info)
end

--发送抢庄倍数 bei:0,1,2,3
function C:sendQiangBei( bei )
	local info = {}
	info["value"] = bei
	self:sendGameMsg(self.define.CS_SELECT_QIANGZHUANG,info)
end

--发送下注倍数 bei:1,2,3,4
function C:sendBetBei( bei )
	local info = {}
	info["value"] = bei
	self:sendGameMsg(self.define.CS_SELECT_PEILV,info)
end

--发送摊牌
function C:sendShowCard()
	self:sendGameMsg(self.define.CS_SHOWCARD)
end

--发送准备(继续)
function C:sendReady()
	self:sendGameMsg(self.define.CS_REDAY)
end

return C