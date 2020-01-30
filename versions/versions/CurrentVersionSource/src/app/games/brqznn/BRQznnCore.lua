local C = class("BRQznnCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.brqznn"
--场景配置
C.SCENE_CONFIG = {scenename = "brqznn_scene", filename = "BRQznnScene", logic="BRQznnLogic", define="BRQznnDefine", model="BRQznnModel"}

function C:start()
	self:registerGameMsg(self.define.SC_BRQZNN_GAMESTATE_P,handler(self,self.onGameState))
	self:registerGameMsg(self.define.SC_BRQZNN_CARD,handler(self,self.onSendCard))
	self:registerGameMsg(self.define.SC_BRQZNN_PLAYER_INFO,handler(self,self.onPlayerInfo))
	self:registerGameMsg(self.define.SC_BRQZNN_SHOW_JIESHUAN,handler(self,self.onSettlement))
	self:registerGameMsg(self.define.SC_BRQZNN_SHOWCARD,handler(self,self.onShowCard))
	self:registerGameMsg(self.define.SC_BRQZNN_CUOPAI,handler(self,self.onCuoPai))
	self:registerGameMsg(self.define.SC_BRQZNN_CUOPAI_END,handler(self,self.onCuoPaiFinish))
	self:registerGameMsg(self.define.SC_BRQZNN_INGAME,handler(self,self.onReady))
	self:registerGameMsg(self.define.SC_BRQZNN_CARD_LAST,handler(self,self.onSendLastCard))
	C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(self.define.SC_BRQZNN_GAMESTATE_P)
	self:unregisterGameMsg(self.define.SC_BRQZNN_CARD)
	self:unregisterGameMsg(self.define.SC_BRQZNN_PLAYER_INFO)
	self:unregisterGameMsg(self.define.SC_BRQZNN_SHOW_JIESHUAN)
	self:unregisterGameMsg(self.define.SC_BRQZNN_SHOWCARD)

	self:unregisterGameMsg(self.define.SC_BRQZNN_CUOPAI)
	self:unregisterGameMsg(self.define.SC_BRQZNN_CUOPAI_END)
	self:unregisterGameMsg(self.define.SC_BRQZNN_INGAME)
	self:unregisterGameMsg(self.define.SC_BRQZNN_CARD_LAST)
	C.super.exit(self)
end

--子游戏公共协议
--收到开始匹配
function C:onStartMatch( info )
	C.super.onStartMatch(self,info)
	self.scene:hideOtherPlayers()
	self.scene:cleanDesktop()
	self.model.isGaming = false
end

--收到匹配结束
function C:onFinishMatch( info )
	dump(info,"收到匹配结束")
	C.super.onFinishMatch(self,info)
	self.model.isGaming = true
end

--玩家加入
function C:onPlayerEnter( info )
	dump(info,"玩家加入")
    C.super.onPlayerEnter(self,info)
    self.model.currentPlayerCount = self.model.currentPlayerCount+1
    local localSeatId = self.scene:getLocalSeatId(info["seat"])
    if self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_JIESUAN and
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
		    	self:sendMatchMsg()
    		end
    	end
    else
    	local localSeatId = self.scene:getLocalSeatIdByPlayerId(playerId)
    	if self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_JIESUAN and
		   self.model.playerGameStateArr[localSeatId] == true then
			printInfo(">>>>>>>>>>>延迟退出>>>>>>>>>>>")
    	   --延迟退出
    	   table.insert(self.model.quitPlayerIds,playerId)
		else
			printInfo(">>>>>>>>>>>玩家离开>>>>>>>>>>>")
    		self.scene:hidePlayerByPlayerId(playerId)
    	end
    	self.model.currentPlayerCount = self.model.currentPlayerCount-1
    	if self.model.currentPlayerCount <= 1 then
	    	self.scene:replacePlayers()
	    	self.scene:hideOtherPlayers()
	    	self.scene:cleanPlayers()
	    	self.scene:cleanDesktop()
	    	self.scene:hideContinuePanel()
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
	dump(info,"进入房间，房间信息")
    C.super.onRoomInfo(self,info)
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
	self.scene:setDifen(utils:moneyString(self.model.difen))
	self.scene:setRoomID(info["roomid"])
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
	dump(info,"断线重连")
	C.super.onToOtherRoom(self,info)
	if info["seatid"] then
		self.model.mySeatId=info["seatid"]
	end
	self.scene:cleanDesktop()
	dump(self.model.isGaming,"断线重连1")
	for i=1,self.model.PLAYER_MAX do
		if info[i] then
			local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
			local isGaming = info[i]["isgaming"] == 1
			self.model.playerGameStateArr[localSeatId] = isGaming
		end
	end
	self.model.currentGameState = info["GameState"]
	if self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_NONE or
	self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_XIUXI then
		--0 无状态(等待玩家加入)
		--1 休息秒
		self.scene:hideContinuePanel()
		self.model.isGaming = false	
		self.scene:showTimer(0,self.define.TipState_free)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_QIANGZHUANG or self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_FAPAI then
		--2 等待抢庄,游戏已经开始 
		--5 发牌阶段
		for i=1,self.model.PLAYER_MAX do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				if isGaming then
					if info[i]["beilv"] then
						self.scene:showPlayerQiangTips(localSeatId,info[i]["beilv"],true)
						if localSeatId == 1 then
							self.model.hadQiang = true
							self.scene:showTimer(0,self.define.TipState_waitBanker)
						end
					elseif localSeatId == 1 then
						self.scene:showQiangPanel()
						self.model.hadQiang = false
						self.scene:showTimer(0,self.define.TipState_toBanker)
					end
					--显示牌
					self.scene:sendAllPokers(localSeatId,4)	
					--设置牌信息
					if info[i] and info[i]["allpoker"] then
						local cardData = info[i]["allpoker"]
						dump(cardData,"牌信息")
						local allpoker = {}
						allpoker["cards"]=utils:copyTable(cardData)
						self.scene:setPlayerPokerData(localSeatId,allpoker)
					end
					if localSeatId==1 then
						self.model.isGaming =true
						self.scene:turnSelfPoker(4)
					end
				end
			end
		end
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_DINGZHUANG then
		--3播放抢庄闪烁动画,已确定庄设置庄标识--2秒钟
		for i=1,self.model.PLAYER_MAX do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				if info[i]["iszhuang"] == 1 then
					self.model.zhuangId = info[i]["playerid"]
					self.model.zhuangBei = info[i]["beilv"] or 1
					self.scene:showPlayerQiangTips(localSeatId,self.model.zhuangBei,false)
					self.scene:showPlayerZhuangFlags(localSeatId,false)
				end
				if isGaming then
					--显示牌
					self.scene:sendAllPokers(localSeatId,4)
					--设置牌信息
					if info[i] and info[i]["allpoker"] then
						local cardData = info[i]["allpoker"]
						dump(cardData,"牌信息")
						local allpoker = {}
						allpoker["cards"]=utils:copyTable(cardData)
						self.scene:setPlayerPokerData(localSeatId,allpoker)
					end
					if localSeatId==1 then
						self.model.isGaming =true
						self.scene:turnSelfPoker(4)
					end
				end
			end
		end
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_PEILV  then
		--4等待加注
		for i=1,self.model.PLAYER_MAX do
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
		for i=1,self.model.PLAYER_MAX do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				if isGaming and info[i]["playerid"] ~= self.model.zhuangId then
					--是否已选择下注倍数
					if info[i]["peilv"] then
						self.scene:showPlayerBetTips(localSeatId,info[i]["peilv"],false)
						if localSeatId == 1 then
							self.model.hadBet = true
							self.scene:showTimer(0,self.define.TipState_waitBet)
						end
					elseif localSeatId == 1 then
						self.model.hadBet = false
						self.scene:showTimer(0,self.define.TipState_toBet)
						self.scene:showBetPanel()
					end
				end
				if isGaming then
					--显示牌
					self.scene:sendAllPokers(localSeatId,4)
					if info[i] and info[i]["allpoker"] then
						local cardData = info[i]["allpoker"]
						dump(cardData,"牌信息")
						local allpoker = {}
						allpoker["cards"]=utils:copyTable(cardData)
						self.scene:setPlayerPokerData(localSeatId,allpoker)
					end
					if localSeatId==1 then
						self.model.isGaming =true
						self.scene:turnSelfPoker(4)
					end
				end
				if info[i]["playerid"] == self.model.zhuangId and localSeatId==1 then
					self.scene:showTimer(0,self.define.TipState_waitOther)
				end
			end
		end
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_TANPAI then
		-- 6 等待玩家摊牌 
		--先获取庄信息
		for i=1,self.model.PLAYER_MAX do
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
		for i=1,self.model.PLAYER_MAX do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				if isGaming then
					--闲家已选择下注倍数
					if info[i]["playerid"] ~= self.model.zhuangId then
						self.scene:showPlayerBetTips( localSeatId, info[i]["peilv"], false )
					end
					--显示牌
					self.scene:sendAllPokers(localSeatId,5)
					--设置牌信息
					if info[i][1] and info[i][1]["allpoker"] then
						local cardData = info[i][1]["allpoker"]
						dump(cardData,"牌信息")
						self.scene:setPlayerPokerData(localSeatId,cardData)
					end
					--是否已经摊牌
					local isTanPai = info[i]["tanpai"] == 1
					if localSeatId == 1 then
						self.model.isGaming =true
						self.scene:turnSelfPoker(5)
						self.model.hadTan = isTanPai
						if self.model.hadTan == false then
							self.scene:showTanpaiBtn()
						else
							self.scene:hideTanpaiBtn()
						end
					end
					if isTanPai then
						self.scene:showPlayerPoker( localSeatId )
					end
				end
			end
		end	
		self.scene:showTimer(0,self.define.TipState_checkCard)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_JIESUAN then
		-- 7 游戏结算,等待准备
		self.scene:showTimer(0,self.define.TipState_checkCard)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_READY then
		-- 8 准备
		self.scene:showTimer(0,self.define.TipState_ready)
		self.model.isGaming = false
		--self.scene:showReadyBtn()
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_FAPAI_1 then
		-- 9 发最后一张牌
		self.scene:showTimer(0,self.define.TipState_checkCard)
		--先获取庄信息
		for i=1,self.model.PLAYER_MAX do
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
		for i=1,self.model.PLAYER_MAX do
			if info[i] then
				local localSeatId = self.scene:getLocalSeatId( info[i]["seatid"] )
				local isGaming = info[i]["isgaming"] == 1
				if isGaming then
					--闲家已选择下注倍数
					if info[i]["playerid"] ~= self.model.zhuangId then
						self.scene:showPlayerBetTips( localSeatId, info[i]["peilv"], false )
					end
					--显示牌
					self.scene:sendAllPokers(localSeatId,5)
					--设置牌信息
					if info[i][1] and info[i][1]["allpoker"] then
						local cardData = info[i][1]["allpoker"]
						dump(cardData,"牌信息")
						self.scene:setPlayerPokerData(localSeatId,cardData)
					end
					--是否已经摊牌
					local isTanPai = info[i]["tanpai"] == 1
					if localSeatId == 1 then
						self.model.isGaming =true
						self.scene:turnSelfPoker(5)
						self.model.hadTan = isTanPai
						if self.model.hadTan == false then
							self.scene:showTanpaiBtn()
						else
							self.scene:hideTanpaiBtn()
						end
					end
					if isTanPai then
						self.scene:showPlayerPoker( localSeatId )
					end
				end
			end
		end	
	end
	dump(self.model.isGaming,"断线重连2")
	--设置玩家头像是否灰掉
	for i=1,self.model.PLAYER_MAX do
		local showed = self.model.playerGameStateArr[i] == false
		self.scene:showPlayerWaitting(i,showed)
	end
	if info["config"] then
		--抢庄倍数
		if info["config"]["beilv"] then
			local beilv = info["config"]["beilv"]
			self.model.qiangzhuangConfig={}
			self.model.qiangzhuangConfig[1]=0
			for i = 1, #beilv do
				table.insert(self.model.qiangzhuangConfig,beilv[i])
			end
		end
		dump(self.model.qiangzhuangConfig,"抢庄倍数")
		--加注倍数
		if info["config"]["peilv"] then
			local peilv = info["config"]["peilv"]
			self.model.betConfig=peilv
		end
		dump(self.model.betConfig,"加注倍数")
	end
end

--子游戏协议
--收到配置信息
function C:onConfig( info )
	dump(info,"onConfig")
	--抢庄倍数
	if info["beilv"] then
		local beilv = info["beilv"]
		self.model.qiangzhuangConfig={}
		self.model.qiangzhuangConfig[1]=0
		for i = 1, #beilv do
			table.insert(self.model.qiangzhuangConfig,beilv[i])
		end
	end
	--加注倍数
	if info["peilv"] then
		local peilv = info["peilv"]
		self.model.betConfig=peilv
	end
end

--收到游戏状态
function C:onGameState( info )
	dump(info,"onGameState")
	--设置游戏状态
	self.model.currentGameState = info["state"]
	self.model.currentLeftTime = info["lefttime"]
	--处理游戏状态
	if self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_NONE then
		-- 0 等待玩家加入
		self.scene:cleanDesktop()
		self.scene:cleanPlayers()
		self.scene:replacePlayers()
		self.scene:hideOtherPlayers()
		self.scene:hideContinuePanel()
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_XIUXI then
		--1 休息下一局游戏开始前	
		--self.scene:setPlayerGameState(false)
		self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_free)
		self.model.hadQiang = false
		self.model.hadBet = false
		--self.scene:showReadyBtn()
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_QIANGZHUANG then
		-- 2 正在抢庄
		self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_toBanker,function()
			self.scene:hideQiangPanel()
		end)
		self.scene:hideContinuePanel()
		self.scene:replacePlayers()
		-- if self.model.isGaming then
		-- 	self.scene:showQiangPanel()
		-- end	
		self.scene:hideReadyBtn()
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_DINGZHUANG then
		-- 3 播放选庄闪烁动画
		self.scene:hideQiangPanel()
		--玩家不操作，客户端直接显示不抢
		if self.model.hadQiang == false and self.model.playerGameStateArr[1] ==true then
			self.model.hadQiang = true
			local beishu = self.model.qiangzhuangConfig[1]
			self.scene:showPlayerQiangTips(1,beishu,true)
		end
		self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_waitBanker)
		self.scene:playChoiceZhuangAni(self.model.zhuangId,self.model.qiangZhuangIds)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_PEILV then
		-- 4 加注
		for i=1,self.model.PLAYER_MAX do
			self.scene:hidePlayerQiangTips(i)
		end
		--if self.model.playerGameStateArr[1] then
			if self.model.zhuangId ~= dataManager.userInfo["playerid"] then
				if self.model.hadBet == false and self.model.isGaming == true  then
					self.scene:showBetPanel()
					self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_toBet)
				else
					self.scene:hideBetPanel()
					self.scene:showTimer(0,self.define.TipState_waitBet)
				end
			else
				self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_waitOther)
			end
		--end
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_FAPAI then
		-- 5 发牌,先发四张
		self.scene:hideTimer()	
		--self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_checkCard)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_TANPAI then
		-- 6 摊牌
		self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_checkCard)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_JIESUAN then
		-- 7 结算
		self.scene:showTimer(0,self.define.TipState_doresult)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_READY then
		-- 8 准备
		self.scene:showTimer(0,self.define.TipState_ready)
	elseif self.model.currentGameState == self.define.EM_BRQZNN_GAMESTATE_FAPAI_1 then
		-- 9 发最后一张牌
		self.scene:hideTimer()		
		self.scene:hideBetPanel()
		--self.scene:showTimer(self.model.currentLeftTime,self.define.TipState_checkCard)
	end
end

--收到发牌信息,前面四张
function C:onSendCard( info )
	dump(info,"onSendCard",10)
	self.scene:cleanDesktop()
	self.scene:cleanPlayers()
	local delay = 0
	local temp = {}
	for i=1,self.model.PLAYER_MAX do
		if info[i] then
			local item = info[i]
			local localSeatId = self.scene:getLocalSeatId( item["seatid"] )
			if localSeatId==1 then
				self.model.isGaming =true
			end
			local info = {}
			info.poker=item
			info.seat=localSeatId
			table.insert(temp,info)	
		end
	end
	--在core播声音，这TM尴尬了
	PLAY_SOUND(self.model.soundPath.."gamestart.mp3")
	for i = 1, self.model.PLAYER_MAX do
		local localSeatId = self.model.sendOrder[i]
		for k = 1, #temp do
			if temp[k].seat==localSeatId then				
				self.model.playerGameStateArr[localSeatId] =true
				local item = temp[k].poker
				if item["allpoker"] then
					local allpoker = {}
					allpoker["cards"]=utils:copyTable(item["allpoker"])
					self.scene:setPlayerPokerData( localSeatId, allpoker )
				end
				self.scene:sendPlayerPokerAni(localSeatId,delay)
				delay = delay + 0.1			
			end
		end
	end
	self.scene:setPlayerGameState(true)
end

--收到发牌信息，最后一张
function C:onSendLastCard(info)
	dump(info,"onSendLastCard",10)
	local delay = 1
	local temp = {}
	for i=1,self.model.PLAYER_MAX do
		if info[i] then
			local item = info[i]
			local localSeatId = self.scene:getLocalSeatId( item["seatid"] )
			if localSeatId==1 then
				self.model.isGaming =true
			end
			local info = {}
			info.poker=item
			info.seat=localSeatId
			table.insert(temp,info)
		end
	end
	
	for i = 1, self.model.PLAYER_MAX do
		local localSeatId = self.model.sendOrder[i]
		for k = 1, #temp do
			if temp[k].seat==localSeatId then
				if self.model.playerGameStateArr[localSeatId] then
					local item = temp[k].poker
					if item["allpoker"] then
						self.scene:setPlayerPokerData( localSeatId, item["allpoker"] )
					end
					self.scene:sendPlayerLastPokerAni(localSeatId,delay)
					delay = delay + 0.1
				end
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
	dump(info,"onShowCard",10)
	local localSeatId = self.scene:getLocalSeatId( info["seatid"] )
	if localSeatId~=1 then
		local poker = info["allpoker"]
		self.scene:setPlayerPokerData(localSeatId,poker)	
	end
	self.scene:showPlayerPoker(localSeatId)
end

--收到结算信息
function C:onSettlement( info )
	dump(info,"onSettlement")
	self.model.currentGameState = self.define.EM_BRQZNN_GAMESTATE_JIESUAN
	self.scene:showTimer(0,self.define.TipState_doresult)
	self.model.isGaming = false
	self.scene:updateBattery()
	self.scene:doSettlement(info)
end

--收到搓牌
function C:onCuoPai(info)
	dump(info,"收到搓牌")
	local localSeatId = self.scene:getLocalSeatId( info["seatid"] )
	self.scene:showPlayerCuoPai(localSeatId)
end

--收到搓牌完成
function C:onCuoPaiFinish(info)
	dump(info,"收到搓牌完成")
	--local localSeatId = self.scene:getLocalSeatId( info["seatid"] )
	--self.scene:showPlayerCuoPaiFinish(localSeatId)
end

--玩家准备好
function C:onReady(info)
	local localSeatId = self.scene:getLocalSeatId( info["seatid"] )
	self.scene:showPlayerReady(localSeatId,true,true)
end

--发送抢庄倍数 bei:0,1,2,3
function C:sendQiangBei( bei )
	local info = {}
	info["value"] = bei
	self:sendGameMsg(self.define.CS_BRQZNN_SELECT_QIANGZHUANG,info)
end

--发送下注倍数 bei:1,2,3,4
function C:sendBetBei( bei )
	local info = {}
	info["value"] = bei
	self:sendGameMsg(self.define.CS_BRQZNN_SELECT_PEILV,info)
end

--发送摊牌
function C:sendShowCard()
	self:sendGameMsg(self.define.CS_BRQZNN_SHOWCARD)
end

--发送准备(继续)
function C:sendReady()
	self:sendGameMsg(self.define.CS_BRQZNN_READY)
end

--发送搓牌
function C:sendCuoPai()
	self:sendGameMsg(self.define.CS_BRQZNN_CUOPAI)
end

--发送搓牌
function C:sendCuoPaiFinish()
	self:sendGameMsg(self.define.CS_BRQZNN_CUOPAI_END)
end

return C