local PlayerClass = import(".QznnPlayerClass")
local ResultClass = import(".QznnResultClass")
local TimerClass = import(".QznnTimerClass")
local CalculateClass = import(".QznnCalculateClass")
local PopupClass = import(".QznnPopupClass")

local C = class("QznnScene", GameSceneBase)
-- 资源名
C.RESOURCE_FILENAME = "games/qznn/QznnScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
	topPanel = {path="top_panel"},
	topBg = {path="top_panel.bg_img"},
	--返回按钮
	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
	--电池进度
	batteryNode = {path="top_panel.battery_node"},
	--电池充电标识
	--batteryLighting = {path="top_panel.battery_img.lighting"},
	--底分文本
	difenLabel = {path="top_panel.difen_img.label"},
	--帮助按钮
	helpBtn = {path="top_panel.help_btn",events={{event="click",method="onClickHelpBtn"}}},
	--设置页面
	settingsBtn = {path="top_panel.settings_btn",events={{event="click",method="onClickSettingsBtn"}}},
	--抢庄页面
	qiangPanel = {path="qiang_panel"},
	--下注页面
	betPanel = {path="bet_panel"},
	--摊牌按钮
	tanpaiBtn = {path="tanpai_btn",events={{event="click",method="onClickTanpaiBtn"}}},
	--计算牌类型页面
	calculatePanel = {path="suanpai_img"},
	--结算页面
	resultPanel = {path="result_panel"},
	--离开/继续页面
	continuePanel = {path="continue_panel"},
	leaveBtn = {path="continue_panel.leave_btn",events={{event="click",method="onClickLeaveBtn"}}},
	continueBtn = {path="continue_panel.continue_btn",events={{event="click",method="onClickContinueBtn"}}},
	--倒计时面板
	timerPanel = {path="timer_panel"},
	--等待其他玩家
	waitOhterPanel = {path="wait_other_panel"},
	--等待下一局
	waitNextPanel = {path="wait_next_panel"},
	--游戏开始
	startImg = {path="start_img"},
	--覆盖层
	maskPanel = {path="mask_panel"},
	choicePanel = {path="choice_panel"},
	--popup页面，点击隐藏玩家popup
	popupPanel = {path="popup_panel"},
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

function C:ctor(core)
	--玩家
	for i=1,5 do
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
	--适配宽屏
	self:adjustUI(self.topBg,{self.backBtn,self.batteryNode},{self.helpBtn,self.settingsBtn})
	self.maskPanel:setContentSize(cc.size(display.width,display.height))
	--zorder 1
	self.playerClassArr = {}
	for i=1,5 do
		local key = string.format("player%d",i)
		local panel = self[key]
		panel:setTag(i)
		panel:setLocalZOrder(self.PLAYER_ZORDER)
		local player = PlayerClass.new(panel)
		player:setVisible(false)
		self.playerClassArr[i] = player
		if i==1 then
			player:setCalculateCallback(function( num1,num2,num3 )
				self.calculateClass:setNumber(num1,num2,num3)
			end)
		end
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
	self.waitOhterPanel:setLocalZOrder(self.OTHER_ZORDER)
	self.waitOhterPanel:setVisible(false)
	self.waitNextPanel:setLocalZOrder(self.OTHER_ZORDER)
	self.waitNextPanel:setVisible(false)
	self.calculateClass = CalculateClass.new(self.calculatePanel)
	self.calculateClass.node:setLocalZOrder(self.OTHER_ZORDER)
	self.calculateClass:setVisible(false)
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
	self.choicePanel:setLocalZOrder(self.MASK_ZORDER)
	self.choicePanel:setVisible(false)
	--zorder 7
	self.continuePanel:setLocalZOrder(self.CONTINUE_ZORDER)
	self.continuePanel:setVisible(false)
	--zorder 8
	self.timerClass = TimerClass.new(self.timerPanel)
	self.timerClass.node:setLocalZOrder(self.TIMER_ZORDER)
	self.timerClass:hide()

	self:setDifen("0")
	self:showPlayer(self.model.myInfo,1)
	--绑定电池节点
	self:bindBatteryNode(self.batteryNode)
	self:updateBattery()
end

function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--播放背景音乐
	PLAY_MUSIC(GAME_QZNN_SOUND_RES.."bg.mp3")
end

function C:onExitTransitionStart()
	STOP_MUSIC()
	self.resultClass:removeTimer()
	self:hideTimer()
	self:hideWaitForOther()
	self:hideWaitForNext()
	utils:removeTimer("ChoiceZhuangAni")
	
	C.super.onExitTransitionStart(self)
end

--加载资源
function C:loadResource()
    C.super.loadResource(self)
    --加载plist图集
	display.loadSpriteFrames(GAME_QZNN_IMAGES_RES.."poker.plist",GAME_QZNN_IMAGES_RES.."poker.png")
end

--卸载资源
function C:unloadResource()
    --移除图集
	display.removeSpriteFrames(GAME_QZNN_IMAGES_RES.."poker.plist",GAME_QZNN_IMAGES_RES.."poker.png")

    C.super.unloadResource(self)
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
	self:hideCalculatePanel()
	self:hideTimer()
	self.playerClassArr[1]:openPoker()
end

--点击抢庄按钮
function C:onClickQiangBtn( event )
	local index = event.target:getTag() - 1
	if index < 0 then
		index = 0
	elseif index > 3 then
		index = 3
	end
	self.core:sendQiangBei(index)
	self:hideQiangPanel()
	self:hideTimer()
	local beishu = 0
	if index == 1 then
		beishu = 1
	elseif index == 2 then
		beishu = 2
	elseif index == 3 then
		beishu = 4
	end
	self.playerClassArr[1]:showQiangTips(beishu,true)
end

--点击下注按钮
function C:onClickBetBtn( event )
	local index = event.target:getTag()
	if index < 1 then
		index = 1
	elseif index > 4 then
		index = 4
	end
	self.core:sendBetBei(index)
	self:hideBetPanel()
	self:hideTimer()
	local beishu = 5
	if index == 2 then
		beishu = 10
	elseif index == 3 then
		beishu = 15
	elseif index == 4 then
		beishu = 20
	end
	self.playerClassArr[1]:showBetTips(beishu,true)
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
	self:hideWaitForOther()
	self:hideWaitForNext()
	self:hideTimer()
	self:hideQiangPanel()
	self:hideBetPanel()
	self:hideTanpaiBtn()
	self:hideCalculatePanel()
	self.resultClass:removeTimer()
end

--设置底分
function C:setDifen( text )
	self.difenLabel:setString(text)
end

--显示等待其他玩家
function C:showWaitForOther()
	self:playDotAni(self.waitOhterPanel)
end

--隐藏等待其他玩家
function C:hideWaitForOther()
	self:stopDotAni(self.waitOhterPanel)
end

--显示等待下一局
function C:showWaitForNext()
	self:playDotAni(self.waitNextPanel)
end

--隐藏等待下一局
function C:hideWaitForNext()
	self:stopDotAni(self.waitNextPanel)
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
	self.timerClass:show(time,ctype,callback)
end

--隐藏倒计时
function C:hideTimer()
	self.timerClass:hide()
end

--显示玩家
function C:showPlayer( playerInfo, localSeatId )
	if localSeatId == nil then
		local seatId = playerInfo["seat"]
		localSeatId = self:getLocalSeatId(seatId)
	end
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:show(playerInfo)

	dump(playerInfo,"__________showPlayer_______________" .. tostring(localSeatId))
end

--隐藏其他玩家
function C:hideOtherPlayers()
	for i=2,5 do
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
	local playerClass = self:getPlayerClassByPlayerId(playerId)
	playerClass:setBlance(blance)
end

--清理玩家
function C:cleanPlayers()
	for i=1,5 do
		local playerClass = self.playerClassArr[i]
		playerClass:clean()
	end
end

--设置玩家游戏状态
function C:setPlayerGameState( isGaming )
	for i=1,5 do
		if self.playerClassArr[i]:isVisible() then
			self.model.playerGameStateArr[i] = isGaming
		end
	end
end

--设置玩家是否正在等待
function C:showPlayerWaitting( localSeatId, flags )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showWaitting(flags)
end

--播放游戏开始动画
function C:playGameStartAni( callback )
	--播放开始游戏音效
	PLAY_SOUND(GAME_QZNN_SOUND_RES.."game_start.mp3")
	self.startImg:setVisible(true)
	local width = self.startImg:getContentSize().width
	local posY = self.startImg:getPositionY()
	self.startImg:setPosition(cc.p(-width/2,posY))
	local array = {}
	array[#array+1] = cc.EaseBackOut:create(cc.MoveTo:create(0.5, cc.p(568, posY )))
	array[#array+1] = cc.DelayTime:create(0.5)
	array[#array+1] = cc.EaseBackIn:create(cc.MoveTo:create(0.5, cc.p( 1136+width/2, posY)))
	-- array[#array+1] = cc.DelayTime:create(0.5)
	array[#array+1] = cc.CallFunc:create(function()
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
	self.maskPanel:setVisible(true)
	self.choicePanel:setVisible(true)
    local pos = {}
    local index = 0
    for i,v in ipairs(playerIds) do
    	local playerClass = self:getPlayerClassByPlayerId(v)
        if playerClass then 
            playerClass.node:setLocalZOrder(self.MASK_ZORDER+1)
            local x = playerClass.node:getPositionX()
            local y = playerClass.node:getPositionY()+1
            local p = cc.p(x,y)
            table.insert(pos, p)
            if v == zhuangId then 
                index = i
            end
        end
    end
    local box = display.newSprite(GAME_QZNN_IMAGES_RES.."choice_box.png")
    self.choicePanel:addChild(box)
    box:setPosition(pos[1])
    local moveX = 5 * #pos + index
    local moveNode = display.newNode()
    moveNode:setPosition(cc.p(0,0))
    self.choicePanel:addChild(moveNode)
    moveNode:runAction(cc.EaseOut:create(cc.MoveTo:create(2, cc.p(moveX, 0)),2))
    local isGo = {}
    utils:createTimer("qznn.ChoiceZhuangAni",1/60,function()
    	local where = math.ceil(moveNode:getPositionX());
        if where < 1 then
            where = 1;
        elseif where > moveX then 
            where = moveX
        end

        if not isGo[where] then
            isGo[where] = true 
            --播放音效
            PLAY_SOUND(GAME_QZNN_SOUND_RES.."choosing.mp3")
        end
        
        local tag = where % #pos
        if tag == 0 then 
            tag = #pos
        end
        box:setPosition(pos[tag])
        
        if where == moveX then
            for i,v in ipairs(playerIds) do
                local playerClass = self:getPlayerClassByPlayerId(v)
		        playerClass.node:setLocalZOrder(self.PLAYER_ZORDER)
            end
            local playerClass = self:getPlayerClassByPlayerId( zhuangId )
			playerClass:playBlinksAni( function()
				playerClass:showBankerTips( self.model.zhuangBei )
			end )
			self.choicePanel:removeAllChildren(true)
			self.choicePanel:setVisible(false)
			self.maskPanel:setVisible(false)
			utils:removeTimer("qznn.ChoiceZhuangAni")
        end
    end)
end

--显示玩家抢庄倍数
function C:showPlayerQiangTips( localSeatId, beishu, ani )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showQiangTips(beishu,ani)
end

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

--发玩家牌
function C:sendPlayerPokerAni( localSeatId, delay )
	local playerClass = self.playerClassArr[localSeatId]
	if localSeatId == 1 then
		playerClass:sendPokerAni(delay,function()
			utils:delayInvoke("qznn.sendpoker",0.1,function()
				playerClass:turnPoker()
			end)
		end)
	else
		playerClass:sendPokerAni(delay)
	end
end

--设置玩家牌信息
function C:setPlayerPokerData( localSeatId,poker )
	local cards = poker["cards"]
	local emtype = poker["emtype"]
	local niun = poker["niun"]
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setPokerData(cards,emtype,niun)
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
end

--隐藏摊牌按钮
function C:hideTanpaiBtn()
	self.tanpaiBtn:setVisible(false)
end

--结算
function C:doSettlement( info )
	local callback = function()
		self:showContinuePanelIfNeeded(info)
		self:playCoinAni(info) 
		self:playChangeMoneyAni(info)
	end
	utils:delayInvoke("qznn.settlement",1,function()
		self:playWinOrLoseAni(info,callback)
	end)
end

--播放自己输赢动画
function C:playWinOrLoseAni( info, callback )
	local flags = false
	for i=1,5 do
		if info[i] then
			local playerId = info[i]["playerid"]
			if playerId == dataManager.userInfo["playerid"] then
				local changemoney = info[i]["changemoney"]
				if changemoney > 0 then
					self.resultClass:showYouWin( callback )
				else
					self.resultClass:showYouLose( callback )
				end
				flags = true
				break
			end
		end
	end
	if flags == false then
		callback()
	end
end

--是否需要显示准备层
function C:showContinuePanelIfNeeded( info )
	for i=1,5 do
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
function C:playCoinAni( info )
	--获取输赢玩家座位信息
	local winLocalSeatIds = {}
	local loseLocalSeatIds = {}
	for i=1,5 do
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
	dump(loseLocalSeatIds,"loseLocalSeatIds")
	dump(winLocalSeatIds,"winLocalSeatIds")
	local zhuangLocalSeatId = self:getLocalSeatIdByPlayerId( self.model.zhuangId )
	self.resultClass:playFlyCoinAnimation( zhuangLocalSeatId, loseLocalSeatIds, winLocalSeatIds, function()
		self:cleanPlayers()
	end)
end

--播放玩家金币变化动画
function C:playChangeMoneyAni( info )
	for i=1,5 do
		if info[i] then
			local playerId = info[i]["playerid"]
			local localSeatId = self:getLocalSeatIdByPlayerId(playerId)
			local changemoney = info[i]["changemoney"]
			local money = utils:moneyString(changemoney,2)
			if changemoney <= 0 then
				self.resultClass:showLoseCoin( localSeatId, money.."元" )
			else
				self.resultClass:showWinCoin( localSeatId, "+"..money.."元" )
			end
			--玩家金币不足
			if playerId == dataManager.userInfo["playerid"] then
				if self.model.isKicked then
					utils:delayInvoke("qznn.alertrecharge",1,function()
						DialogLayer.new(false):show("金币不足,请返回大厅充值！",function( isOk )
							self:onClickBackBtn()
						end)
					end)
				end
			end
		end
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
	for i=1,5 do
		if self.playerClassArr[i].playerInfo ~= nil and self.playerClassArr[i].playerInfo["playerid"] == playerId then
			playerClass = self.playerClassArr[i]
			localSeatId = i
		   	break
		end
	end
	return playerClass,localSeatId
end

return C