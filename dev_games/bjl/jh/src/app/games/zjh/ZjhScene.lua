local PlayerClass = import(".ZjhPlayerClass")
local ChipsClass = import(".ZjhChipsClass")
local CompareClass = import(".ZjhCompareClass")
local OperationClass = import(".ZjhOperationClass")
local PopupClass = import(".ZjhPopupClass")
local ResultClass = import(".ZjhResultClass")
local HistoryLayer = import(".ZjhHistoryLayer")

local C = class("ZjhScene",GameSceneBase)
-- 资源名
C.RESOURCE_FILENAME = "games/zjh/ZjhScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
	--举报按钮
	reportBtn = {path="report_btn",events={{event="click",method="onClickReportBtn"}}},
	--筹码框
	chipsBox = {path="chips_box"},
	--top panel
	topPanel = {path="top_panel"},
	--返回按钮
	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
	--电池
	batteryNode = {path="top_panel.battery_node"},
	--庄家第一轮提示
	zhuangTips = {path="top_panel.tips_img"},
	infoImg = {path="top_panel.info_img"},
	--底注
	dizhuLabel = {path="top_panel.info_img.dizhu_label"},
	--顶注
	dingzhuLabel = {path="top_panel.info_img.dingzhu_label"},
	--总注
	zongzhuLabel = {path="top_panel.info_img.zongzhu_label"},
	--轮数
	roundLabel = {path="top_panel.info_img.round_label"},
	--帮助按钮
	helpBtn = {path="top_panel.help_btn",events={{event="click",method="onClickHelpBtn"}}},
	--设置按钮
	settingsBtn = {path="top_panel.settings_btn",events={{event="click",method="onClickSettingsBtn"}}},
	--庄标识
	bankerImg = {path="banker_img"},
	--操作按钮
	operationPanel = {path="operation_panel"},
	gzyzBtn = {path="operation_panel.guzhuyizhi_btn",events={{event="click",method="onClickGzyzBtn"}}},
	genzhuBtn = {path="operation_panel.genzhu_btn",events={{event="click",method="onClickGenzhuBtn"}}},
	kanpaiBtn = {path="operation_panel.kanpai_btn",events={{event="click",method="onClickKanpaiBtn"}}},
	bipaiBtn = {path="operation_panel.bipai_btn",events={{event="click",method="onClickBipaiBtn"}}},
	quanyaBtn = {path="operation_panel.quanya_btn",events={{event="click",method="onClickQuanyaBtn"}}},
	jiazhu1Btn = {path="operation_panel.jiazhu1_btn",events={{event="click",method="onClickJiazhu1Btn"}}},
	jiazhu2Btn = {path="operation_panel.jiazhu2_btn",events={{event="click",method="onClickJiazhu2Btn"}}},
	jiazhu3Btn = {path="operation_panel.jiazhu3_btn",events={{event="click",method="onClickJiazhu3Btn"}}},
	alwaysBtn = {path="operation_panel.always_btn",events={{event="click",method="onClickAlwaysBtn"}}},
	unalwaysBtn = {path="operation_panel.unalways_btn",events={{event="click",method="onClickUnalwaysBtn"}}},
	qipaiBtn = {path="operation_panel.qipai_btn",events={{event="click",method="onClickQipaiBtn"}}},
	--筹码页面
	chipsPanel = {path="chips_panel"},
	--系统自动开牌提示
	autocmpImg = {path="autocmp_img"},
	--比牌页面
	comparePanel = {path="compare_panel"},
	cancelBtn = {path="compare_panel.cancel_btn",events={{event="click",method="onClickCancelBtn"}}},
	--结算页面
	resultPanel = {path="result_panel"},
	--开始倒计时
	startTimer = {path="start_timer"},
	--等待下一局
	waitNextImg = {path="wait_next_img"},
	--等待其他玩家
	waitOtherImg = {path="wait_other_img"},
	--点击玩家头像弹窗popup
	popupPanel = {path="popup_panel"},
	--离开/继续
	continuePanel = {path="continue_panel"},
	leaveBtn = {path="continue_panel.leave_btn",events={{event="click",method="onClickLeaveBtn"}}},
	contineBtn = {path="continue_panel.continue_btn",events={{event="click",method="onClickContinueBtn"}}},
}

C.playerClassArr = nil
C.chipsClass = nil
C.compareClass = nil
C.operationClass = nil
C.popupClass = nil
C.resultClass = nil
C.historyLayer = nil
C.historyInfo = nil
C.bankerPosArr = {cc.p(342,226),cc.p(1004,326),cc.p(942,526),cc.p(194,526),cc.p(132,326)}

function C:ctor(core)
	--玩家
	for i=1,5 do
		local key = string.format("player%d",i)
		local path = string.format("player_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickPlayerPanel"}}}
	end
	--比牌PK按钮
	for i=2,5 do
		local key = string.format("pkBtn%d",i)
		local path = string.format("compare_panel.pk_btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickPKBtn"}}}
	end
	C.super.ctor(self,core)
end

function C:initialize()
	C.super.initialize(self)
	-- self.reportBtn:setVisible(false)
	self.chipsBox:setVisible(false)
	--隐藏轮数
	self.roundLabel:setVisible(false)
	self.zhuangTips:setVisible(false)
	--庄标识
	self.bankerImg:setVisible(false)
	--玩家
	self.playerClassArr = {}
	for i=1,5 do
		local key = string.format("player%d",i)
		local panel = self[key]
		panel:setTag(i)
		local player = PlayerClass.new(panel)
		player:setVisible(false)
		if i==2 or i== 3 then
			player.isLeft = false
		end
		self.playerClassArr[i] = player
	end
	--操作按钮
	for i=2,5 do
		local key = string.format("pkBtn%d",i)
		local btn = self[key]
		btn:setTag(i)
	end
	self.operationClass = OperationClass.new(self.operationPanel)
	self.operationClass:setVisible(false)
	--筹码
	self.chipsClass = ChipsClass.new(self.chipsPanel)
	-- self.chipsClass:setVisible(false)
	--系统自动开牌
	self.autocmpImg:setVisible(false)
	--比牌
	self.compareClass = CompareClass.new(self.comparePanel)
	-- self.compareClass:setVisible(false)
	--结算
	self.resultClass = ResultClass.new(self.resultPanel)
	self.resultClass:setVisible(false)
	--开始倒计时
	self:hideStartTimer()
	--等待下一局
	self:hideWaitNext()
	--等待其他玩家
	self:hideWaitOther()
	--popup
	self.popupClass = PopupClass.new(self.popupPanel)
	--离开/继续
	self:hideContinue()
	--显示玩家自己头像
	self:showPlayer(self.model.myInfo,1)
	--绑定电池节点
	self:bindBatteryNode(self.batteryNode)
	self:updateBattery()
	--底分
	if self.model.difen == 0 then
		self.model.difen = self.model.roomInfo.difen or 0
	end
	self:setDizhu(self.model.difen)
	--总注
	self:setZongzhu(0)
end

--进入场景
function C:onEnter()
	C.super.onEnter(self)
	--播放背景音乐
	PLAY_MUSIC(GAME_ZJH_SOUND_RES.."bg.mp3")
end

--退出场景
function C:onExit()
	STOP_MUSIC()
	self.chipsClass:clean()
	self:hideStartTimer()
	self:hideAllPlayerTimer()
	self:hideWaitNext()
	self:hideWaitOther()
	if self.historyLayer then
		self.historyLayer:release()
	end
	display.removeSpriteFrames(GAME_ZJH_IMAGES_RES.."card.plist",GAME_ZJH_IMAGES_RES.."card.png")
	display.removeSpriteFrames(GAME_ZJH_IMAGES_RES.."number_chips.plist",GAME_ZJH_IMAGES_RES.."number_chips.png")
	display.removeSpriteFrames(GAME_ZJH_IMAGES_RES.."number_throw.plist",GAME_ZJH_IMAGES_RES.."number_throw.png")
	C.super.onExit(self)
end

--点击返回
function C:onClickBackBtn( event )
	self:touchBack()
end

--点击规则
function C:onClickHelpBtn( event )
	self:showRule()
end

--点击设置
function C:onClickSettingsBtn( event )
	self:showSettings()
end

--点击举报
function C:onClickReportBtn( event )
	if self.historyInfo == nil then
		toastLayer:show("暂无牌局信息")
		return
	end
	if self.historyLayer == nil then
		self.historyLayer = HistoryLayer.new(function( historyId,ids )
			self.core:sendReport(historyId,ids)
		end)
		self.historyLayer:retain()
		self.historyLayer:reloadInfo(self.historyInfo)
	end
	self.historyLayer:show()
end

--点击玩家头像
function C:onClickPlayerPanel( event )
	local localSeatId = event.target:getTag()
	self:showPopup(localSeatId)
end

--点击孤注一掷
function C:onClickGzyzBtn( event )
	self.core:sendShowCard()
	local money = self.playerClassArr[1].playerInfo["money"]
	self:throwPlayerChips(1,money,ZJH.OPT.SHOW_CARD)
	self.model.turnToMe = false
	self:updateOperationBtns()
end

--点击跟注
function C:onClickGenzhuBtn( event )
	local info = {}
	info["type"] = ZJH.OPT.CALL
	self.core:sendBet(info)
	local money = self.model.currentSingleChip
	if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
		money = money*2
	end
	self:throwPlayerChips(1,money,ZJH.OPT.CALL)
	self.model.turnToMe = false
	self:updateOperationBtns()
end

--点击加注1
function C:onClickJiazhu1Btn( event )
	local info = {}
	info["type"] = ZJH.OPT.FILL
	info["fill"] = 2
	self.core:sendBet(info)
	local money = self.model.difen * 2
	self.model.currentSingleChip = money
	if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
		money = money*2
	end
	self:throwPlayerChips(1,money,ZJH.OPT.FILL)
	self.model.turnToMe = false
	self:updateOperationBtns()
end

--点击加注2
function C:onClickJiazhu2Btn( event )
	local info = {}
	info["type"] = ZJH.OPT.FILL
	info["fill"] = 3
	self.core:sendBet(info)
	local money = self.model.difen * 5
	self.model.currentSingleChip = money
	if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
		money = money*2
	end
	self:throwPlayerChips(1,money,ZJH.OPT.FILL)
	self.model.turnToMe = false
	self:updateOperationBtns()
end

--点击加注3
function C:onClickJiazhu3Btn( event )
	local info = {}
	info["type"] = ZJH.OPT.FILL
	info["fill"] = 4
	self.core:sendBet(info)
	local money = self.model.difen * 10
	self.model.currentSingleChip = money
	if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
		money = money*2
	end
	self:throwPlayerChips(1,money,ZJH.OPT.FILL)
	self.model.turnToMe = false
	self:updateOperationBtns()
end

--TODO:点击全押(开牌)
function C:onClickQuanyaBtn( event )
	
end

--点击看牌
function C:onClickKanpaiBtn( event )
	self.core:sendCheck()
	-- self:setPlayerSpeak(1,3)
	-- self.model.playerGameStatusArr[1] = ZJH.PLAYER_GAME_STATUS.HAD_LOOKED
	-- self:updateOperationBtns()
end

--点击比牌
function C:onClickBipaiBtn( event )
	local localSeatIds = {}
	dump(self.model.playerTableStatusArr,"playerTableStatusArr")
	dump(self.model.playerGameStatusArr,"playerGameStatusArr")
	for i=2,5 do
		if self.model.playerTableStatusArr[i] == ZJH.PLAYER_TABLE_STATUS.PLAYING and
		   self.model.playerGameStatusArr[i] ~= ZJH.PLAYER_GAME_STATUS.QIPAI and
		   self.model.playerGameStatusArr[i] ~= ZJH.PLAYER_GAME_STATUS.TAOTAI then
		   table.insert(localSeatIds,i)
		end
	end
	if #localSeatIds == 0 then
		return
	end
	if #localSeatIds > 1 then
		self.compareClass:showPK(localSeatIds)
	else
		local seatId = localSeatIds[1]
		local playerClass = self.playerClassArr[seatId]
		if playerClass.playerInfo and playerClass.playerInfo["seat"] then
			self.core:sendCompare(playerClass.playerInfo["seat"])
			local money = self.model.currentSingleChip * 2
			if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
				money = money*2
			end
			self:throwPlayerChips(1,money,ZJH.OPT.COMPETITION)
			self.model.turnToMe = false
			self:updateOperationBtns()
		end
	end
end

--点击取消比牌
function C:onClickCancelBtn( event )
	self:hideComparePanel()
end

--点击PK按钮
function C:onClickPKBtn( event )
	self:hideComparePanel()
	local localSeatId = event.target:getTag()
	local playerClass = self.playerClassArr[localSeatId]
	if playerClass.playerInfo and playerClass.playerInfo["seat"] then
		self.core:sendCompare(playerClass.playerInfo["seat"])
		local money = self.model.currentSingleChip * 2
		if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
			money = money*2
		end
		self:throwPlayerChips(1,money,ZJH.OPT.COMPETITION)
		self.model.turnToMe = false
		self:updateOperationBtns()
	end
end

function C:hideComparePanel()
	self.compareClass:setVisible(false)
end

--点击跟到底
function C:onClickAlwaysBtn( event )
	self.core:sendFollow(1)
	self.model.isAuto = true
	self:updateOperationBtns()
end

--点击取消跟到底
function C:onClickUnalwaysBtn( event )
	self.core:sendFollow(0)
	self.model.isAuto = false
	self:updateOperationBtns()
end

--点击弃牌
function C:onClickQipaiBtn( event )
	self.core:sendFold()
	self.model.isDrop = true
	self.model.playerGameStatusArr[1] = ZJH.PLAYER_GAME_STATUS.QIPAI
	self.model.isGaming = false
	self:setPlayerStatus(1,3)
	self:playPlayerSpeakSound(1,"drop",3)
	self:hidePlayerTimer(1)
	self:updateOperationBtns()
end

function C:onClickLeaveBtn( event )
	self:hideContinue()
	self:onClickBackBtn()
end

function C:onClickContinueBtn( event )
	self:hideContinue()
	self.core:sendReady()
end

--设置底注
function C:setDizhu( money )
	self.chipsClass:setBaseMoney(money)
	self.dizhuLabel:setString(utils:moneyString(money))
	self.dingzhuLabel:setString(utils:moneyString(money*10))
end

--设置总注
function C:setZongzhu( money )
	local str = utils:moneyString(money)
	self.zongzhuLabel:setString(str)
end

--设置轮数
function C:setRound( round )
	local showed = round == 0
	self:showZhuangTips(showed)
end

function C:showZhuangTips( showed )
	self.zhuangTips:setVisible(showed)
	self.infoImg:setVisible(not showed)
end

--创建桌面筹码
function C:createDesktopChips()
	self.chipsBox:setVisible(true)
	self.chipsClass:throwDesktopChips(self.model.currentSingleChip,self.model.currentTotalChips)
end

--显示玩家popup
function C:showPopup( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	if playerClass.playerInfo == nil then
		return
	end
	self.popupClass:show(playerClass.playerInfo,localSeatId)
end

--显示系统自动开牌
function C:showAutoCmpAni( callback )
	local width = self.autocmpImg:getContentSize().width
	local posY = self.autocmpImg:getPositionY()
	local startPos = cc.p(-width/2,posY)
	local pausePos = cc.p(display.cx,posY)
	local endPos = cc.p(display.width+width/2,posY)
	self.autocmpImg:setPosition(startPos)
	self.autocmpImg:setVisible(true)
	self.autocmpImg:runAction(transition.sequence({
		CCEaseBackOut:create(CCMoveTo:create(0.5,pausePos)),
		CCDelayTime:create(0.5),
		CCEaseBackIn:create(CCMoveTo:create(0.5,endPos)),
		CCDelayTime:create(0.5),
		CCCallFunc:create(function()
			self.autocmpImg:setVisible(false)
			if callback then 
				callback()
			end
		end)
	}))
end

--显示开始倒计时
function C:showStartTimer( time )
	self:hideStartTimer()
	if time < 1 then
		return
	end
	self.startTimer:getChildByName("label"):setString(tostring(time))
	self.startTimer:setVisible(true)
	utils:createTimer("zjh.StartTimer",1,function()
		local count = tonumber(self.startTimer:getChildByName("label"):getString()) or 0
		count = count - 1
		self.startTimer:getChildByName("label"):setString(tostring(count))
		if count <= 0 then
			self:hideStartTimer()
			if self.continuePanel:isVisible() then
				self:touchBack()
			end
		end
	end)
end

function C:hideStartTimer()
	utils:removeTimer("zjh.StartTimer")
	self.startTimer:setVisible(false)
end

--显示等待下一局
function C:showWaitNext()
	self:playDotAni(self.waitNextImg)
end

function C:hideWaitNext()
	self.waitNextImg:stopAllActions()
	self.waitNextImg:setVisible(false)
end

--显示等待其他玩家
function C:showWaitOther()
	self:playDotAni(self.waitOtherImg)
end

function C:hideWaitOther()
	self.waitOtherImg:stopAllActions()
	self.waitOtherImg:setVisible(false)
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

--显示离开/继续
function C:showContinue()
	self.continuePanel:setVisible(true)
end

function C:hideContinue()
	self.continuePanel:setVisible(false)
end

--清理桌子
function C:cleanDesktop()
	self.chipsClass:clean()
end

--更新操作按钮
function C:updateOperationBtns()
	local bei = 1
	if self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
		bei = 2
	end
	local jiazhu1Str = "+"..utils:moneyString(self.model.difen * 2 * bei).."元"
	local jiazhu2Str = "+"..utils:moneyString(self.model.difen * 5 * bei).."元"
	local jiazhu3Str = "+"..utils:moneyString(self.model.difen * 10 * bei).."元"
	self.operationClass:updateJiazhu(jiazhu1Str,jiazhu2Str,jiazhu3Str)
	-- dump(self.model.currentOptConfigs,"updateOperationBtns")
	local config = {}
	if self.model.isGaming then
		if self.model.isAuto then
			config[ZJH.BTN_NAME.UNALWAYS] = true
		else
			if self.model.turnToMe then
				config = self.model.currentOptConfigs
			else
				if self.model.isMeAll == false then
					config[ZJH.BTN_NAME.ALWAYS] = true
				end
			end
			if self.model.isMeAll == false then
				config[ZJH.BTN_NAME.QIPAI] = true
			else
				config[ZJH.BTN_NAME.QIPAI] = false
			end
			if self.model.myInfo["money"] < self.model.currentSingleChip*bei*2 then
				config[ZJH.BTN_NAME.QUANYA] = true
				config[ZJH.BTN_NAME.GENZHU] = false
				config[ZJH.BTN_NAME.JIAZHU1] = false
				config[ZJH.BTN_NAME.JIAZHU2] = false
				config[ZJH.BTN_NAME.JIAZHU3] = false
				config[ZJH.BTN_NAME.BIPAI] = false
			end
		end
		-- dump(config,"config")
		local canSee = self.model.currentOptConfigs[ZJH.BTN_NAME.KANPAI] or false
		if canSee and self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.NOT_LOOKED then
			config[ZJH.BTN_NAME.KANPAI] = true
		else
			config[ZJH.BTN_NAME.KANPAI] = false
		end
	end
	self.operationClass:updateBtns(config,self.model.isAuto,self.model.turnToMe)
end

--显示庄
function C:showBankerImg()
	local pos = self.bankerPosArr[self.model.zhuangLocalSeatId]
	if self.bankerImg:isVisible() then
		self.bankerImg:runAction(cc.MoveTo:create(0.5,pos))
	else
		self.bankerImg:setPosition(pos)
		self.bankerImg:setVisible(true)
	end
end

--结算
function C:doSettlement( info )
	--隐藏庄提示
	self:showZhuangTips(false)
	--参与游戏的玩家头像亮起来
	for i=1,5 do
		if self.model.playerTableStatusArr[i] == ZJH.PLAYER_TABLE_STATUS.PLAYING then
			self.playerClassArr[i]:lightHead()
			self.playerClassArr[i]:setSpeak(0)
		end
	end
	--显示所有玩家的牌
	if info["jiesuan"] and info["jiesuan"]["allcard"] then
    	for k,v in pairs(info["jiesuan"]["allcard"]) do
    		local seatId = self:getLocalSeatId(v["seat"])
    		self:showPlayerPoker(seatId,v["cards"],false)
		end
    end

	--显示和自己比过牌的玩家牌
	-- if info["jiesuan"] and info["jiesuan"]["relate"] and info["jiesuan"]["relate"]["player"] then
	-- 	local list = info["jiesuan"]["relate"]["player"]
	-- 	for i,v in ipairs(list) do
	-- 		local seatId = self:getLocalSeatId(v["relateseat"])
	-- 		self:showPlayerPoker(seatId,v["cards"],false)
	-- 	end
	-- end
	-- --显示自己的牌
	-- if info["jiesuan"] and info["jiesuan"]["allcard"] then
 --    	for k,v in pairs(info["jiesuan"]["allcard"]) do
 --    		if v["seat"] == self.model.mySeatId then
 --    			self:showPlayerPoker(1,v["cards"],false)
 --    			break
 --    		end
	-- 	end
 --    end
	local callback = function()
		self:showContinuePanelIfNeeded(info)
		self:playChangeMoneyAni(info)
		if self.model:isMoneyNotEnough() then
			utils:delayInvoke("zjh.alertrecharge",1,function()
				DialogLayer.new(false):show("金币不足,请返回大厅充值！",function( isOk )
					self:onClickBackBtn()
				end)
			end)
		end
	end
	self:playWinOrLoseAni(info,callback)
	--上一局回顾
	local historyInfo = utils:copyTable(info["jiesuan"]["paiju"])
	--获取玩家信息
	local function GetInfoByPlayerID(playerId)
		for k,v in pairs(info["player"]) do
			if v.playerid == playerId then
				return v
			end
		end
	end
	--获取玩家牌
	local function GetCardsBySeatID(seatId)
		for k,v in pairs(info["jiesuan"]["allcard"]) do
			if v.seat == seatId then
				return v.cards
			end
		end
	end
	--设置玩家昵称，牌
	for k,v in pairs(historyInfo["players"]) do
		if v["coinchange"] ~= 0 then
			local playerInfo = GetInfoByPlayerID(v.playerid)
			local cards = GetCardsBySeatID(playerInfo.seat)
			v["nickname"] = playerInfo["nickname"]
			v["cards"] = cards
		end
	end
	dump(historyInfo,"上局回顾",10)
	self.historyInfo = historyInfo
	if self.historyLayer then
		self.historyLayer:reloadInfo(self.historyInfo)
	end
end

function C:playWinOrLoseAni( info, callback )
	if info == nil or info["player"] == nil then
		if callback then
			callback()
		end
		return
	end
	local flags = 0
	for i,v in ipairs(info["player"]) do
		if v["seat"] == self.model.mySeatId then
			if v["changecoin"] > 0 then
				flags = 1
			elseif v["changecoin"] < 0 then
				flags = 2
			end
			break
		end
	end
	if flags == 1 then
		self.resultClass:showYouWin(callback)
	elseif flags == 2 then
		self.resultClass:showYouLose(callback)
	else
		if callback then
			callback()
		end
	end
end

function C:showContinuePanelIfNeeded( info )
	if info == nil or info["jiesuan"] == nil or info["jiesuan"]["player"] == nil then
		return
	end
	for i,v in ipairs(info["jiesuan"]["player"]) do
		if v["nseat"] == self.model.mySeatId then
			if v["NeedReady"] and v["NeedReady"] == 1 then
				self:showContinue()
			end
			break
		end
	end
end

function C:playChangeMoneyAni( info )
	self.chipsBox:setVisible(false)
	if info == nil or info["player"] == nil then
		return
	end
	local seatIds = {}
	for i,v in ipairs(info["player"]) do
		local seatId = self:getLocalSeatId(v["seat"])
		local coin = v["changecoin"]
		if coin > 0 then
			self.resultClass:showWinCoin(seatId,"+"..utils:moneyString(coin,2).."元")
			table.insert(seatIds,seatId)
		elseif coin < 0 then
			self.resultClass:showLoseCoin(seatId,utils:moneyString(coin,2).."元")
		end
	end
	self.chipsClass:flyChips(seatIds,function( array )
		for i,v in ipairs(array) do
			self.resultClass:playWinnerAnimation(v)
		end
	end)
end

function C:hideBankerImg()
	self.bankerImg:setVisible(false)
end

function C:sendPlayerPokerAni( localSeatId, delay, callback )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:sendPokerAni(delay,callback)
end

function C:sendPlayerPokerImm( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:sendPokerImm()
end

function C:showPlayerPoker( localSeatId, dataArr, animated )
	local playerClass = self.playerClassArr[localSeatId]
	local ctype = self.logic:getPokerType(dataArr[1],dataArr[2],dataArr[3])
	playerClass:setPokerData(dataArr,ctype)
	playerClass:openPoker(animated)
end

--设置玩家余额
function C:setPlayerBlanceByPlayerId( playerId, blance )
	local playerClass = self:getPlayerClassByPlayerId(playerId)
	playerClass:setBlance(blance)
end

function C:setPlayerBlanceBySeatId( seatId, blance )
	local playerClass = self.playerClassArr[seatId]
	playerClass:setBlance(blance)
end

--设置玩家下注筹码
function C:setPlayerChips( localSeatId, chips )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setChips(chips)
end

--丢筹码
function C:throwPlayerChips( localSeatId, betchips, bettype )
	self.chipsBox:setVisible(true)
	if bettype == ZJH.OPT.BET or bettype == ZJH.OPT.CALL then
		self:setPlayerSpeak(localSeatId,1)
	elseif bettype == ZJH.OPT.FILL then
		self:setPlayerSpeak(localSeatId,2)
	elseif bettype == ZJH.OPT.COMPETITION then
		self:setPlayerSpeak(localSeatId,4)
	elseif bettype == ZJH.OPT.SHOW_CARD or bettype == ZJH.OPT.SHOW_HAND then
		self:setPlayerSpeak(localSeatId,5)
	end
	if bettype == ZJH.OPT.SHOW_CARD or bettype == ZJH.OPT.SHOW_HAND then
		self.chipsClass:throwAllinChips(localSeatId,betchips)
	else
		self.chipsClass:throwChips(localSeatId,self.model.currentSingleChip,betchips)
	end
end

--玩家比牌
function C:playCompareAni( fromSeatId, winnerSeatId, loserSeatId )
	if fromSeatId ~= 1 then
		self:setPlayerSpeak(fromSeatId,4)
	end
	self:setPlayerStatus(loserSeatId,2)
	if fromSeatId ~= loserSeatId then
		self:setPlayerSpeak(loserSeatId,0)
	end
	local isBoy = (self.playerClassArr[loserSeatId].playerInfo["sex"] or 0) == 0
	self.compareClass:playCompareAni( winnerSeatId, loserSeatId, isBoy )
end

function C:updatePlayerTableStatus( status )
	for i=1,5 do
		if self.playerClassArr[i]:isVisible() then
			self.model.playerTableStatusArr[i] = status
		else
			self.model.playerTableStatusArr[i] = ZJH.PLAYER_TABLE_STATUS.NONE
		end
	end
end

--设置玩家状态 0:隐藏 1:看牌 2:淘汰 3:弃牌
function C:setPlayerStatus( localSeatId, status )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setStatus(status)
end

--设置玩家状态 0:隐藏 1:跟注  2:加注  3:看牌  4:比牌  5:全押
function C:setPlayerSpeak( localSeatId, speak )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setSpeak(speak)
	--播放音效
	if speak == 1 then
		self:playPlayerSpeakSound(localSeatId,"follow",3)
	elseif speak == 2 then
		self:playPlayerSpeakSound(localSeatId,"add",3)
	elseif speak == 3 then
		self:playPlayerSpeakSound(localSeatId,"see",3)
	elseif speak == 4 then
		self:playPlayerSpeakSound(localSeatId,"cmp",3)
	elseif speak == 5 then
		self:playPlayerSpeakSound(localSeatId,"all",4)
	end
end

function C:playPlayerSpeakSound( localSeatId, resname, resnum )
	local index = math.random(1,resnum)
	local isBoy = (self.playerClassArr[localSeatId].playerInfo["sex"] or 0) == 0
	if isBoy then
		resname = string.format(resname.."_boy_%d.mp3",index)
	else
		resname = string.format(resname.."_girl_%d.mp3",index)
	end
	PLAY_SOUND(GAME_ZJH_SOUND_RES..resname)
end

--设置玩家头像灰色
function C:setPlayerGray( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:grayHead()
end

--设置玩家头像亮起
function C:setPlayerLight( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:lightHead()
end

--设置玩家是否正在等待
function C:showPlayerWaitting( localSeatId, flags )
	local playerClass = self.playerClassArr[localSeatId]
	if flags then
		playerClass:showWaitting()
	else
		playerClass:hideWaitting()
	end
end

--显示玩家操作倒计时
function C:showPlayerTimer( localSeatId, leftTime, callback )
	self:hideAllPlayerTimer()
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showTimer(leftTime,callback)
end

function C:hidePlayerTimer( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:hideTimer()
end

function C:hideAllPlayerTimer()
	for i=1,5 do
		local playerClass = self.playerClassArr[i]
		playerClass:hideTimer()
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

--显示玩家
function C:showPlayer( info, localSeatId )
	if localSeatId == nil then
		local seatId = info["seat"]
		localSeatId = self:getLocalSeatId(seatId)
	end
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:show(info)
end

--根据id隐藏玩家
function C:hidePlayerByPlayerId( playerId )
	local playerClass, localSeatId = self:getPlayerClassByPlayerId(playerId)
	playerClass:setVisible(false)
	self.model.playerTableStatusArr[localSeatId] = ZJH.PLAYER_TABLE_STATUS.NONE
	self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.NONE
	if localSeatId == self.model.zhuangLocalSeatId then
		self.model.zhuangLocalSeatId = nil
		self:hideBankerImg()
	end
end

--根据本地座位号隐藏玩家
function C:hidePlayerByLocalSeatId( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setVisible(false)
	self.model.playerTableStatusArr[localSeatId] = ZJH.PLAYER_TABLE_STATUS.NONE
	self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.NONE
	if localSeatId == self.model.zhuangLocalSeatId then
		self.model.zhuangLocalSeatId = nil
		self:hideBankerImg()
	end
end

--隐藏其他玩家
function C:hideOtherPlayers()
	for i=2,5 do
		local playerClass = self.playerClassArr[i]
		playerClass:setVisible(false)
	end
	self.model.zhuangLocalSeatId = nil
	self:hideBankerImg()
end

--清理所有玩家
function C:cleanPlayers()
	for i=1,5 do
		local playerClass = self.playerClassArr[i]
		playerClass:clean()
	end
end

function C:cleanPlayer( localSeatId )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:clean()
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