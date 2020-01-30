local PlayerClass = import(".BRQznnPlayerClass")
local ResultClass = import(".BRQznnResultClass")
local PopupClass = import(".BRQznnPopupClass")
local CuoClass = import(".BRQznnCuoClass")

local C = class("BRQznnScene", GameSceneBase)
-- 资源名
C.RESOURCE_FILENAME = "games/brqznn/BRQznnScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
	topPanel = {path="top_panel"},
	--电池
	batteryNode = {path="top_panel.battery_node"},
	-- --电池充电标识
	-- batteryLighting = {path="top_panel.battery_img.lighting"},
	--房号文本
	roomIDLabel = {path="top_panel.roomID"},
	--玩法文本
	roomTypeLabel = {path="top_panel.roomType"},
	--底分文本
	roomDifenLabel = {path="top_panel.roomDiFen"},
	--时间文本
	roomTimeLabel = {path="top_panel.time"},
	--局数文本
	roomTurnLabel = {path="top_panel.roomTurn"},
	--菜单按钮
	menuBtn = {path="top_panel.menu_btn",events={{event="click",method="onClickMenuBtn"}}},
	--菜单界面
	menuPanel = {path="menu_panel",events={{event="click",method="onClickMenuBtn"}}},
	--帮助按钮
	helpBtn = {path="top_panel.help_btn",events={{event="click",method="onClickHelpBtn"}}},
	--返回按钮
	backBtn = {path="menu_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
	--设置页面
	settingsBtn = {path="menu_panel.settings_btn",events={{event="click",method="onClickSettingsBtn"}}},
	--抢庄页面
	qiangPanel = {path="qiang_panel"},
	--下注页面
	betPanel = {path="bet_panel"},

	--摊牌按钮
	tanpaiBtn = {path="opt_panel.tanpai_btn",events={{event="click",method="onClickTanpaiBtn"}}},
	--翻牌按钮
	flippaiBtn = {path="opt_panel.flippai_btn",events={{event="click",method="onClickFlipBtn"}}},
	--搓牌按钮
	cuopaiBtn = {path="opt_panel.cuopai_btn",events={{event="click",method="onClickCuoBtn"}}},
	--准备按钮
	zhunbeiBtn = {path="opt_panel.ready_btn",events={{event="click",method="onClickReadyBtn"}}},

	--计算牌类型页面
	calculatePanel = {path="suanpai_img"},
	--结算页面
	resultPanel = {path="result_panel"},
	--离开/继续页面
	continuePanel = {path="continue_panel"},
	leaveBtn = {path="continue_panel.leave_btn",events={{event="click",method="onClickLeaveBtn"}}},
	continueBtn = {path="continue_panel.continue_btn",events={{event="click",method="onClickContinueBtn"}}},
	--提示面板
	timerPanel = {path="tip_panel"},
	timerLabel = {path="tip_panel.label"},
	--等待其他玩家
	--waitOhterPanel = {path="wait_other_panel"},
	--等待下一局
	--waitNextPanel = {path="wait_next_panel"},
	--游戏开始
	startImg = {path="start_img"},
	--覆盖层
	maskPanel = {path="mask_panel"},
	--popup页面，点击隐藏玩家popup
	popupPanel = {path="popup_panel"},
	--搓牌层
	cuoPanel= {path="cuo_panel"},
}

C.playerClassArr = nil
C.resultClass = nil
C.timerClass = nil
C.calculateClass = nil
C.popupClass = nil

C.TOP_ZORDER = 1
C.OPERATION_ZORDER = 2
C.PLAYER_ZORDER = 3
C.POPUP_ZORDER = 4
C.OTHER_ZORDER = 5
C.MASK_ZORDER = 6
C.CONTINUE_ZORDER = 7
C.TIMER_ZORDER = 8
C.MENU_ZORDER = 10

function C:ctor(core)
	--玩家
	for i=1,8 do
		local key = string.format("player%d",i)
		local path = string.format("player_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickPlayerPanel"}}}
	end
	--抢庄按钮
	for i=1,4 do
		local key = string.format("qiangBtn%d",i)
		local path = string.format("qiang_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickQiangBtn"}}}
	end
	--下注按钮
	for i=1,4 do
		local key = string.format("betBtn%d",i)
		local path = string.format("bet_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickBetBtn"}}}
	end
	C.super.ctor(self,core)
end

function C:initialize()
	C.super.initialize(self)
	--zorder 1
	self.playerClassArr = {}
	for i=1,8 do
		local key = string.format("player%d",i)
		local panel = self[key]
		panel:setTag(i)
		panel:setLocalZOrder(self.PLAYER_ZORDER)
		local player = PlayerClass.new(panel)
		player:setVisible(false)
		self.playerClassArr[i] = player
		-- if i==1 then
		-- 	player:setCalculateCallback(function( num1,num2,num3 )
		-- 		self.calculateClass:setNumber(num1,num2,num3)
		-- 	end)
		-- end
	end
	--zorder 3
	self.topPanel:setLocalZOrder(self.TOP_ZORDER)
	--zorder 4
	for i=1,4 do
		local qiangKey = string.format("qiangBtn%d",i)
		self[qiangKey]:setTag(i)
		local betKey = string.format("betBtn%d",i)
		self[betKey]:setTag(i)
	end
	self.qiangPanel:setLocalZOrder(self.OPERATION_ZORDER)
	self.qiangPanel:setVisible(false)
	self.betPanel:setLocalZOrder(self.OPERATION_ZORDER)
	self.betPanel:setVisible(false)
	self.tanpaiBtn:setLocalZOrder(self.OPERATION_ZORDER)
	self.tanpaiBtn:setVisible(false)
	--zorder 5
	self.resultClass = ResultClass.new(self.resultPanel)
	self.resultClass.node:setLocalZOrder(self.OTHER_ZORDER)
	self.resultClass:setVisible(false)
	self.startImg:setLocalZOrder(self.OTHER_ZORDER)
	self.startImg:setVisible(false)
	self.popupPanel:setLocalZOrder(self.OTHER_ZORDER)
	self.popupClass = PopupClass.new(self.popupPanel)
	--zorder 6
	self.maskPanel:setLocalZOrder(self.MASK_ZORDER)
	self.maskPanel:setVisible(false)
	--zorder 7
	self.continuePanel:setLocalZOrder(self.CONTINUE_ZORDER)
	self.continuePanel:setVisible(false)
	--zorder 8
	self.cuoPanel:setLocalZOrder(self.TIMER_ZORDER)
	self.cuoPanel:setVisible(false)
	self.cuoClass = CuoClass.new(self.cuoPanel)

	--zorder 9
	self.menuPanel:setLocalZOrder(self.MENU_ZORDER)
	self:hideMenuPanel()
	self:setDifen("0")
	self:showPlayer(self.model.myInfo,1)
	--绑定电池节点
	self:bindBatteryNode(self.batteryNode)
	self:updateBattery()
	--时间
	self:setRoomTime()
	--加载plist图集，在CocosStudio里面没用过的不会自动加载
	display.loadSpriteFrames(self.model.imagePath.."red_line.plist",self.model.imagePath.."red_line.png")
end

function C:onEnter()
	C.super.onEnter(self)
	--播放背景音乐
	PLAY_MUSIC(self.model.soundPath.."bg.mp3")
end

function C:onExit()
	STOP_MUSIC()
	self.resultClass:removeTimer()
	self:hideTimer()
	utils:removeTimer(self.model.timerName.."ChoiceZhuangAni")
	utils:removeTimer(self.model.timerName.."fliplastpai")
	utils:removeTimer(self.model.timerName.."TimeUpdate")
	--移除图集
	display.removeSpriteFrames(self.model.imagePath.."card.plist",self.model.imagePath.."card.png")
	display.removeSpriteFrames(self.model.imagePath.."red_line.plist",self.model.imagePath.."red_line.png")
	C.super.onExit(self)
end

--点击菜单按钮
function C:onClickMenuBtn(event)
	if self.menuPanel:isVisible() then
		self:hideMenuPanel()
	else
		self:showMenuPanel()
	end
end

--打开菜单界面
function C:showMenuPanel()
	self.menuBtn:loadTexture(self.model.imagePath.."ann_more2.png")
	self.menuPanel:setVisible(true)
end

--关闭菜单界面
function C:hideMenuPanel()
	self.menuBtn:loadTexture(self.model.imagePath.."ann_more.png")
	self.menuPanel:setVisible(false)
end


--点击返回按钮
function C:onClickBackBtn( event )
	self:touchBack()
end
--点击帮助按钮
function C:onClickHelpBtn( event )
	self:showRule()
end
--点击设置按钮
function C:onClickSettingsBtn( event )
	self:showSettings()
end

--点击摊牌按钮
function C:onClickTanpaiBtn( event )
	self.core:sendShowCard()
	self:hideTanpaiBtn()
	--self.playerClassArr[1]:openPoker()
end

--点击翻牌按钮
function C:onClickFlipBtn(event)
	local playerClass = self.playerClassArr[1]
	playerClass:turnLastPoker()
	utils:delayInvoke(self.model.timerName..".fliplastpai",0.2,function()
		self:showTanpaiBtn()
	end)
	self:hideCuopaiBtn()
	self:hideFlippaiBtn()
end

--点击搓牌按钮
function C:onClickCuoBtn(event)
	self.core:sendCuoPai()
	self:hideCuopaiBtn()
	self:hideFlippaiBtn()
	self:showTanpaiBtn()
	local arr = {}
	arr[1]=cc.DelayTime:create(0.1)
	arr[2]=cc.MoveTo:create(0.24,cc.p(1062,-86))
	self.tanpaiBtn:runAction(cc.Sequence:create(arr))
	self.cuoClass:show(function()
		self.core:sendCuoPaiFinish()
	end)
end

--点击准备按钮
function C:onClickReadyBtn(event)
	self.core:sendReady()
	self.zhunbeiBtn:setVisible(false)
end

--点击抢庄按钮
function C:onClickQiangBtn( event )
	local index = event.target:getTag()
	if index < 0 then
		index = 0
	elseif index > self.model.qiangzhuangTypes then
		index = self.model.qiangzhuangTypes
	end
	self:hideQiangPanel()
	printInfo(">>>>>>>>>>>>>点击抢庄按钮>>>>>>>>>>"..index)
	local beishu = self.model.qiangzhuangConfig[index]
	self.core:sendQiangBei(index-1)
	self.model.hadQiang = true
	self:showTimer(0,self.define.TipState_waitBanker)
end

--点击下注按钮
function C:onClickBetBtn( event )
	local index = event.target:getTag()
	if index < 1 then
		index = 1
	elseif index > self.model.betTypes then
		index = self.model.betTypes
	end
	printInfo(">>>>>>>>>>>>>点击下注按钮>>>>>>>>>>"..index)
	dump(self.model.betConfig,"betConfig")
	self.core:sendBetBei(index)
	self:hideBetPanel()
	local beishu = self.model.betConfig[index]
	self.model.hadBet = true
	self:showTimer(0,self.define.TipState_waitBet)
end

--点击离开按钮
function C:onClickLeaveBtn( event )
	self:hideContinuePanel()
	self:onClickBackBtn()
end

--点击继续按钮
function C:onClickContinueBtn( event )
	self:hideContinuePanel()
	self.core:sendReady()
end

--点击玩家头像
function C:onClickPlayerPanel( event )
	local localSeatId = event.target:getTag()
	local playerClass = self.playerClassArr[localSeatId]
	if playerClass.playerInfo == nil then
		return
	end
	self.popupClass:show(playerClass.playerInfo,localSeatId)
end

--清理桌面
function C:cleanDesktop()
	self:hideTimer()
	self:hideQiangPanel()
	self:hideBetPanel()
	self:hideTanpaiBtn()
	self:hideFlippaiBtn()
	self:hideCuopaiBtn()
	self:hideReadyBtn()
end

--设置房间号
function C:setRoomID(roomID)
	self.roomIDLabel:setString(roomID)
end
--设置玩法
function C:setRoomType(type)
	self.roomTypeLabel:setString(type)
end
--设置底分
function C:setDifen( text )
	self.roomDifenLabel:setString(text)
end
--设置局数
function C:setRoomTurns(turns)
	self.roomTurnLabel:setString(turns)
end
--设置时间
function C:setRoomTime()
	self.roomTimeLabel:setString(os.date("%H:%M"))
	utils:createTimer(self.model.timerName..".TimeUpdate",30,function()
		self.roomTimeLabel:setString(os.date("%H:%M"))
	end)
	
end


--播放点动画
function C:playDotAni( node )
	node:stopAllActions()
	node:setVisible(true)
	local dot1 = node:getChildByName("dot_1")
	local dot2 = node:getChildByName("dot_2")
	local dot3 = node:getChildByName("dot_3")
	local array = {}
	local intervaltime = 0.5
	array[1] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
	array[2] = cc.DelayTime:create(intervaltime)
	array[3] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(false)
	end)
	array[4] = cc.DelayTime:create(intervaltime)
	array[5] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(true)
	end)
	array[6] = cc.DelayTime:create(intervaltime)
	array[7] = cc.CallFunc:create(function()
		dot1:setVisible(false)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
	array[8] = cc.DelayTime:create(intervaltime)
	local repeatAni = cc.RepeatForever:create(cc.Sequence:create(array))
    node:runAction(repeatAni)
end

--停止点动画
function C:stopDotAni( node )
	node:stopAllActions()
	node:setVisible(false)
end

--显示离开/继续浮层
function C:showContinuePanel()
	self.continuePanel:setVisible(true)
end

--隐藏离开/继续浮层
function C:hideContinuePanel()
	self.continuePanel:setVisible(false)
end

--显示倒计时
function C:showTimer( time, ctype, callback )
	self.timerPanel:setVisible(true)
	utils:removeTimer(self.model.timerName..".TimerPanel")
	local timecount = time
	local str = ""
	if ctype==self.define.TipState_free then
		str="下一局即将开始"
	elseif ctype==self.define.TipState_ready then
		str="请准备"
	elseif ctype==self.define.TipState_readyForOther then
		str="请等待其他玩家准备"
	elseif ctype==self.define.TipState_toBanker then
		str="请操作抢庄"
	elseif ctype==self.define.TipState_waitBanker then
		str="等待其他玩家抢庄"
	elseif ctype==self.define.TipState_waitOther then
		str="等待闲家下注"
	elseif ctype==self.define.TipState_toBet then
		str="请选择下注分数"
	elseif ctype==self.define.TipState_waitBet then
		str="等待其他玩家下注"
	elseif ctype==self.define.TipState_checkCard then
		str="查看手牌"
	elseif ctype==self.define.TipState_waitShowCard then
		str="请等待其他玩家亮牌"
	elseif ctype==self.define.TipState_doresult then
		str="开始比牌"
	end
	if time>1 then
		self.timerLabel:setString(str..":"..string.format("%d",timecount))
		local playtimer = function()
			timecount = timecount - 1
			self.timerLabel:setString(str..":"..string.format("%d",timecount))
			if timecount <= 0 then
				if callback then
					callback()
				end
				utils:removeTimer(self.model.timerName..".TimerPanel")
			end
		end
		utils:createTimer(self.model.timerName..".TimerPanel",1,playtimer)
	else
		self.timerLabel:setString(str)
		if callback then
			callback()
		end
	end
end

--隐藏倒计时
function C:hideTimer()
	self.timerPanel:setVisible(false)
	utils:removeTimer(self.model.timerName..".TimerPanel")
end

--显示玩家
function C:showPlayer( playerInfo, localSeatId )
	if localSeatId == nil then
		local seatId = playerInfo["seat"]
		localSeatId = self:getLocalSeatId(seatId)
	end
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:show(playerInfo)
end

--隐藏其他玩家
function C:hideOtherPlayers()
	for i=2,self.model.PLAYER_MAX do
		self:hidePlayerByLocalSeatId(i)
	end
end

--处理延迟退出加入玩家
function C:replacePlayers()
	--移除延迟退出的玩家
	for key,value in ipairs( self.model.quitPlayerIds ) do
   		self:hidePlayerByPlayerId(value)
	end
	self.model.quitPlayerIds = {}

	--插入延迟进入的玩家
	for key,value in ipairs( self.model.enterPlayers ) do
		self:showPlayer(value)
	end
	self.model.enterPlayers = {}
end

--隐藏玩家
function C:hidePlayerByLocalSeatId( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setVisible(false)
	self.model.playerGameStateArr[localSeatId] = false
end

--隐藏玩家
function C:hidePlayerByPlayerId( playerId )
	local playerClass,localSeatId = self:getPlayerClassByPlayerId(playerId)
	playerClass:setVisible(false)
	self.model.playerGameStateArr[localSeatId] = false
end

--设置玩家余额
function C:setPlayerBlance( blance, playerId )
	if self.model.currentGameState ~= self.define.EM_BRQZNN_GAMESTATE_JIESUAN and
	self.model.currentGameState ~= self.define.EM_BRQZNN_GAMESTATE_TANPAI then
		local playerClass = self:getPlayerClassByPlayerId(playerId)
		playerClass:setBlance(blance)
	else		
		local playtimer = function()
			if self.model.currentGameState ~= self.define.EM_BRQZNN_GAMESTATE_JIESUAN and
			self.model.currentGameState ~= self.define.EM_BRQZNN_GAMESTATE_TANPAI then
				local playerClass = self:getPlayerClassByPlayerId(playerId)
				if playerClass then
					playerClass:setBlance(blance)
				end
				utils:removeTimer(self.model.timerName..".setPlayerBlance"..playerId)
			end
		end
		utils:removeTimer(self.model.timerName..".setPlayerBlance"..playerId)
		utils:createTimer(self.model.timerName..".setPlayerBlance"..playerId,0.2,playtimer)
	end
end

--清理玩家
function C:cleanPlayers()
	for i=1,self.model.PLAYER_MAX do
		local playerClass = self.playerClassArr[i]
		playerClass:clean()
	end
end

--设置玩家游戏状态
function C:setPlayerGameState( isGaming )
	for i=1,self.model.PLAYER_MAX do
		if self.playerClassArr[i]:isVisible() then
			self.model.playerGameStateArr[i] = isGaming
			self:showPlayerWaitting(i,not isGaming)
		end
	end
end

--设置玩家是否正在等待
function C:showPlayerWaitting( localSeatId, flags )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showWaitting(flags)
end

--设置玩家已经准备
function C:showPlayerReady(localSeatId, flags,ani)
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showReady(flags,ani)
end

--播放游戏开始动画
function C:playGameStartAni( callback )
	--播放开始游戏音效
	PLAY_SOUND(self.model.soundPath.."game_start.mp3")
	self.startImg:setVisible(true)
	local width = self.startImg:getContentSize().width
	local posY = self.startImg:getPositionY()
	self.startImg:setPosition(cc.p(-width/2,posY))
	local array = {}
	array[1] = cc.EaseBackOut:create(cc.MoveTo:create(0.5, cc.p( display.cx, posY )))
	array[2] = cc.DelayTime:create(0.5)
	array[3] = cc.EaseBackIn:create(cc.MoveTo:create(0.5, cc.p( display.width+width/2, posY)))
	array[4] = cc.DelayTime:create(0.5)
	array[5] = cc.CallFunc:create(function()
		self.startImg:setVisible(false)
		callback()
	end)
	self.startImg:runAction( cc.Sequence:create( array ) )
end

--显示抢庄按钮
function C:showQiangPanel()
	self.qiangPanel:setVisible(true)
end

--隐藏抢庄按钮
function C:hideQiangPanel()
	self.qiangPanel:setVisible(false)
end

--显示下注按钮
function C:showBetPanel()
	self.betPanel:setVisible(true)
end

--隐藏下注按钮
function C:hideBetPanel()
	self.betPanel:setVisible(false)
end

--播放选庄动画
function C:playChoiceZhuangAni( zhuangId, playerIds )
	if #playerIds == 1 then
		local playerClass = self:getPlayerClassByPlayerId( zhuangId )
		playerClass:playBlinksAni( function()
			playerClass:showBankerTips( self.model.zhuangBei )
		end )
		return
	end
	local aa = 0.7/(#playerIds*(1/60)*6)
	aa=math.min(aa,6)
	local times = math.ceil(aa)

	local array = {}
	for i = 1, #playerIds do
		local playerClass = self:getPlayerClassByPlayerId(playerIds[i])
		array[#array+1]=CCCallFunc:create(function()
			playerClass:playChoiceZhuangAni()
		end)
		array[#array+1]=CCDelayTime:create(1/60*6)
	end
	printInfo(aa..">>>>>>>>>>>播放选庄动画>>>>>>>>>>"..times)
	PLAY_SOUND(self.model.soundPath.."xuanzhuang.mp3")
	local arr = {}
	arr[1]=CCDelayTime:create(0.5)
	arr[2]=CCCallFunc:create(function()
		self.maskPanel:setVisible(true)
		end)
	arr[3]=CCRepeat:create(cc.Sequence:create(array),times)
	arr[4]=CCCallFunc:create(function()
		self.maskPanel:setVisible(false)
		local playerClass = self:getPlayerClassByPlayerId( zhuangId )
		playerClass:playBlinksAni( function()
			playerClass:showBankerTips( self.model.zhuangBei )
		end )
	end)
	self.maskPanel:stopAllActions()
	self.maskPanel:runAction(cc.Sequence:create(arr))	
end

--显示玩家抢庄倍数
function C:showPlayerQiangTips( localSeatId, beishu, ani )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showQiangTips(beishu,ani)
end
--显示玩家抢庄倍数
function C:showPlayerQiangTipsById( playerId, beishu, ani )
	local playerClass = self:getPlayerClassByPlayerId(playerId)
	playerClass:showQiangTips(beishu,ani)
end

--隐藏玩家提示
function C:hidePlayerQiangTips( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	if playerClass.playerInfo == nil then
		return
	end
	if playerClass.playerInfo["playerid"] ~= self.model.zhuangId then
		playerClass:hideTips()
	end
end

--显示庄标识
function C:showPlayerZhuangFlags( localSeatId, ani )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showZhuang(ani)
end

--显示下注倍数
function C:showPlayerBetTips( localSeatId, beishu, ani )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showBetTips(beishu,ani)
end

function C:showPlayerBetTipsById( playerId, beishu, ani )
	local playerClass = self:getPlayerClassByPlayerId(playerId)
	playerClass:showBetTips(beishu,ani)
end

--隐藏下注倍数
function C:hidePlayerBetTips( localSeatId, beishu, ani )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:hideTips()
end

--显示玩家牌
function C:sendPlayerPoker( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:sendPoker()
end

--发玩家牌,先发四张
function C:sendPlayerPokerAni( localSeatId, delay )
	local playerClass = self.playerClassArr[localSeatId]
	if localSeatId == 1 then
		playerClass:sendFourPokerAni(delay,function()
			utils:delayInvoke(self.model.timerName..".sendpoker",1/60*6,function()
				playerClass:turnFourPoker()
				self:showQiangPanel()
			end)
		end)
	else
		playerClass:sendFourPokerAni(delay)
	end
end

--发玩家牌,最后一张
function C:sendPlayerLastPokerAni( localSeatId, delay )
	local playerClass = self.playerClassArr[localSeatId]
	if localSeatId == 1 then
		playerClass:sendLastPoker(delay,function()
			--显示搓牌/翻牌按钮
			self:showCuopaiBtn()
			self:showFlippaiBtn()
		end)
	else
		playerClass:sendLastPoker(delay)
	end
end

--断线重连回来直接显示5张牌
function C:sendAllPokers(localSeatId,count)
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:sendFourPoker(count)
end

--设置玩家牌信息,前面四张
function C:setPlayerPokerData( localSeatId,poker )
	local cards = poker["cards"]
	local emtype = nil
	local niun = nil
	if poker["emtype"] then
		emtype = poker["emtype"]
	end
	if poker["niun"] then
		niun = poker["niun"]
	end
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setPokerData(cards,emtype,niun)
	if localSeatId==1 then
		self.cuoClass:setPokerData(cards,emtype,niun)
	end
end

--设置牌信息,最后一张
function C:setPlayerLastPokerData( localSeatId,poker )
	local cards = poker["cards"]
	local emtype = nil
	local niun = nil
	if poker["emtype"] then
		emtype = poker["emtype"]
	end
	if poker["niun"] then
		niun = poker["niun"]
	end
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setLastPokerData(cards,emtype,niun)
end

--翻自己的牌面
function C:turnSelfPoker()
	local playerClass = self.playerClassArr[1]
	playerClass:turnPoker()
end

--显示玩家摊牌
function C:showPlayerPoker( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:openPoker()
	if localSeatId==1 then
		self:hideCuopaiBtn()
		self:hideFlippaiBtn()
		self.tanpaiBtn:setPosition(cc.p(1062,-86))
		self.cuoClass:clean()
	end
end

--显示算牌页面
function C:showCalculatePanel()
	self.calculateClass:setVisible(true)
end

--隐藏算牌页面
function C:hideCalculatePanel()
	self.calculateClass:setVisible(false)
end

--显示摊牌按钮
function C:showTanpaiBtn()
	self.tanpaiBtn:setVisible(true)
	self.tanpaiBtn:setPosition(cc.p(1062,64))
end

--隐藏摊牌按钮
function C:hideTanpaiBtn()
	self.tanpaiBtn:setVisible(false)
end

--显示搓牌按钮
function C:showCuopaiBtn()
	self.cuopaiBtn:setVisible(true)
end

--隐藏搓牌按钮
function C:hideCuopaiBtn()
	self.cuopaiBtn:setVisible(false)
end

--显示翻牌按钮
function C:showFlippaiBtn()
	self.flippaiBtn:setVisible(true)
end

--隐藏翻牌按钮
function C:hideFlippaiBtn()
	self.flippaiBtn:setVisible(false)
end

--显示准备按钮
function C:showReadyBtn()
	self.zhunbeiBtn:setVisible(true)
end

--隐藏准备按钮
function C:hideReadyBtn()
	self.zhunbeiBtn:setVisible(false)
end

--结算
function C:doSettlement( info )
	local callback = function()
		self.model.currentGameState = self.define.EM_BRQZNN_GAMESTATE_NONE
		self:showContinuePanelIfNeeded(info)
		self:playChangeMoneyAni(info)
		for i = 1, self.model.PLAYER_MAX do
			local playerClass = self.playerClassArr[i]
			playerClass:hideBetTip()
		end
	end
	utils:delayInvoke(self.model.timerName..".settlement",1,function()
		self:playCoinAni(info,callback)
	end)
end

--播放自己输赢动画
function C:playWinOrLoseAni( info, callback )
	-- local flags = false
	-- for i=1,self.model.PLAYER_MAX do
	-- 	if info[i] then
	-- 		local playerId = info[i]["playerid"]
	-- 		if playerId == dataManager.userInfo["playerid"] then
	-- 			local changemoney = info[i]["changemoney"]
	-- 			if changemoney > 0 then
	-- 				self.resultClass:showYouWin( callback )
	-- 			else
	-- 				self.resultClass:showYouLose( callback )
	-- 			end
	-- 			flags = true
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- if flags == false then
	-- 	callback()
	-- end
	if callback then
		callback()
	end
end

--是否需要显示准备层
function C:showContinuePanelIfNeeded( info )
	for i=1,self.model.PLAYER_MAX do
		if info[i] then
			local playerId = info[i]["playerid"]
			if playerId == dataManager.userInfo["playerid"] then
				local ready = info[i]["fuck"]
				if ready == 2 then
					self:showContinuePanel()
				end
				break
			end
		end
	end
end

--播放飞金币动画
function C:playCoinAni( info,callback )
	--获取输赢玩家座位信息
	local winLocalSeatIds = {}
	local loseLocalSeatIds = {}
	for i=1,self.model.PLAYER_MAX do
		if info[i] then
			local playerId = info[i]["playerid"]
			if playerId ~= self.model.zhuangId then
				local changemoney = info[i]["changemoney"]
				local localSeatId = self:getLocalSeatIdByPlayerId( playerId )
				if localSeatId > 0 then
					if changemoney <= 0 then
						table.insert(loseLocalSeatIds,localSeatId)
					else
						table.insert(winLocalSeatIds,localSeatId)
					end
				end
			end
		end
	end
	--播放飞金币动画
	local zhuangLocalSeatId = self:getLocalSeatIdByPlayerId( self.model.zhuangId )
	self.resultClass:playFlyCoinAnimation( zhuangLocalSeatId, loseLocalSeatIds, winLocalSeatIds, function()
		if callback then
			callback()
		end
	end)
end

--播放玩家金币变化动画
function C:playChangeMoneyAni( info )
	for i=1,self.model.PLAYER_MAX do
		if info[i] then
			local playerId = info[i]["playerid"]
			local localSeatId = self:getLocalSeatIdByPlayerId(playerId)
			local playerClass = self.playerClassArr[localSeatId]
			local changemoney = info[i]["changemoney"]
			local money = utils:moneyString(changemoney,2)
			if changemoney <= 0 then
				if playerClass then
					playerClass:showLose(money)
				end
			else
				if playerClass then
					playerClass:showWin(money)
				end
			end
			--玩家金币不足
			if playerId == dataManager.userInfo["playerid"] then
				if self.model.isKicked then
					utils:delayInvoke(self.model.timerName..".alertrecharge",1,function()
						DialogLayer.new(false):show("金币不足,请返回大厅充值！",function( isOk )
							self:onClickBackBtn()
						end)
					end)
				end
			end
		end
	end
end

--显示玩家搓牌
function C:showPlayerCuoPai(localSeatId)
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showCuoPaiTip()
end

--显示搓牌完成
function C:showPlayerCuoPaiFinish(localSeatId)
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showPlayerCuoPaiFinish()
	if localSeatId==1 then
		self.cuoClass:clean()
		self.tanpaiBtn:setVisible(true)
		self.tanpaiBtn:runAction(cc.MoveTo:create(0.5,cc.p(1062,64)))
	end
end

--获取玩家本地座位号
function C:getLocalSeatIdByPlayerId( playerId )
	local playerClass,localSeatId = self:getPlayerClassByPlayerId(playerId)
	return localSeatId
end

--获取玩家
function C:getPlayerClassByPlayerId( playerId )
	local playerClass = nil
	local localSeatId = 0
	for i=1,self.model.PLAYER_MAX do
		if self.playerClassArr[i].playerInfo ~= nil and self.playerClassArr[i].playerInfo["playerid"] == playerId then
			playerClass = self.playerClassArr[i]
			localSeatId = i
		   	break
		end
	end
	return playerClass,localSeatId
end

return C