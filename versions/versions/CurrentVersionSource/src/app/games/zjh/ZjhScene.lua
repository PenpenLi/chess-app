local PlayerClass = import(".ZjhPlayerClass")
local ChipsClass = import(".ZjhChipsClass")
local CompareClass = import(".ZjhCompareClass")
local OperationClass = import(".ZjhOperationClass")
local ResultClass = import(".ZjhResultClass")
local HistoryLayer = import(".ZjhHistoryLayer")
local PopupClass = import(".ZjhPopupClass")

local C = class("ZjhScene",GameSceneBase)
-- 资源名
C.RESOURCE_FILENAME = "games/zjh/ZjhScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
	--灯光
	dengguangNode = {path="dengguang_node"},
	--举报按钮
	reportBtn = {path="report_btn",events={{event="click",method="onClickReportBtn"}}},
	--top panel
	topPanel = {path="top_panel"},
	topBg = {path="top_panel.bg_img"},
	--返回按钮
	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
	--电池
	batteryNode = {path="top_panel.battery_node"},
	--底分信息
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
	--等待其他玩家
	waitOtherImg = {path="wait_other_img"},
	--继续按钮
	continueBtn = {path="continue_btn",events={{event="touch",method="onClickContinueBtn"}}},
	--popup页面，点击隐藏玩家popup
	popupPanel = {path="popup_panel"},
}

C.playerClassArr = nil
C.popupClass = nil
C.chipsClass = nil
C.compareClass = nil
C.operationClass = nil
C.resultClass = nil
C.historyLayer = nil
C.historyInfo = nil
C.bankerPosArr = {cc.p(339,212),cc.p(934,350),cc.p(934,535),cc.p(202,535),cc.p(202,350)}

function C:ctor(core)
	--玩家
	for i=1,5 do
		local key = string.format("player%d",i)
		local path = string.format("player_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="touch",method="onClickPlayerPanel"}}}
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
	--适配宽屏
	self:adjustUI(self.topBg,{self.backBtn,self.batteryNode},{self.helpBtn,self.settingsBtn})
	--隐藏所有灯光
	self:showDengguan(0)
	--隐藏轮数
	self.roundLabel:setVisible(false)
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
	--系统自动开牌
	self.autocmpImg:setVisible(false)
	--比牌
	self.compareClass = CompareClass.new(self.comparePanel)
	-- self.compareClass:setVisible(false)
	--结算
	self.resultClass = ResultClass.new(self.resultPanel)
	self.resultClass:setVisible(false)
	--显示玩家自己头像
	-- self:showPlayer(self.model.myInfo,1)
	self.popupClass = PopupClass.new(self.popupPanel)
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
	self:hideReportBtn()
	self:hideContinueBtn()
	--隐藏开始倒计时
	self:hideStartTimer()
	self:hideWaitOther()
end

--进入场景
function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--播放背景音乐
	PLAY_MUSIC(GAME_ZJH_SOUND_RES.."bg.mp3")
end

--退出场景
function C:onExitTransitionStart()
	STOP_MUSIC()
	self.chipsClass:clean()
	self:hideAllPlayerTimer()
	if self.historyLayer then
		self.historyLayer:release()
	end
	C.super.onExitTransitionStart(self)
end

--加载资源
function C:loadResource()
    C.super.loadResource(self)
    --加载plist图集
	display.loadSpriteFrames(GAME_ZJH_IMAGES_RES.."card.plist",GAME_ZJH_IMAGES_RES.."card.png")
	display.loadSpriteFrames(GAME_ZJH_IMAGES_RES.."number_chips.plist",GAME_ZJH_IMAGES_RES.."number_chips.png")
	display.loadSpriteFrames(GAME_ZJH_IMAGES_RES.."number_throw.plist",GAME_ZJH_IMAGES_RES.."number_throw.png")
end

--卸载资源
function C:unloadResource()
    --移除图集
	display.removeSpriteFrames(GAME_ZJH_IMAGES_RES.."card.plist",GAME_ZJH_IMAGES_RES.."card.png")
	display.removeSpriteFrames(GAME_ZJH_IMAGES_RES.."number_chips.plist",GAME_ZJH_IMAGES_RES.."number_chips.png")
	display.removeSpriteFrames(GAME_ZJH_IMAGES_RES.."number_throw.plist",GAME_ZJH_IMAGES_RES.."number_throw.png")

    C.super.unloadResource(self)
end

--点击玩家头像
function C:onClickPlayerPanel( event )
	if event.name == "ended" then		
		local localSeatId = event.target:getTag()
		-- if localSeatId==1 then
		-- 	return
		-- end
		PLAY_SOUND_CLICK()
		local playerClass = self.playerClassArr[localSeatId]
		if playerClass.playerInfo == nil then
			printInfo(">>>>>>>>>>该玩家信息为空>>>>>>>>"..localSeatId)
			return
		end
		self.popupClass:show(playerClass.playerInfo,localSeatId)
	end
end

--显示灯光
function C:showDengguan( localSeatId )
	if not localSeatId then
		localSeatId = 0
	end
	for i=1,5 do
		local img = self.dengguangNode:getChildByName("img_"..i)
		img:setVisible(i==localSeatId)
	end
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

--点击继续
function C:onClickContinueBtn( event )
	if event.name == "began" then
        self.continueBtn:setScale(1.1)
    elseif event.name == "moved" then
    elseif event.name == "ended" then
        PLAY_SOUND_CLICK()
        self.continueBtn:setScale(1)
        self:hideOtherPlayers()
		self:cleanDesktop()
		if self.model:isMoneyNotEnough() then
			DialogLayer.new(false):show("金币不足,请返回大厅充值！",function( isOk )
				self:onClickBackBtn()
			end)
		else
			self.core:sendMatchMsg()
			self:showMatchLayer()
		end
    elseif event.name == "cancelled" then
        self.continueBtn:setScale(1)
    end
	
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
	dump(self.model.playerGameStatusArr,"playerGameStatusArr")
	for i=2,5 do
		if self.model.playerGameStatusArr[i] == ZJH.PLAYER_GAME_STATUS.NOT_LOOKED or
		   self.model.playerGameStatusArr[i] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
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
	if self.hadClickPK then
		return
	end
	self.hadClickPK = true
	utils:delayInvoke("zjh.clickpk",0.5,function()
		self.hadClickPK = false
	end)
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
	self:playPlayerSpeakSound(1,"drop",1)
	self:hidePlayerTimer(1)
	self:updateOperationBtns()
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
function C:setRound( round, maxround )
	round = round+1
	local text = "轮数:"..tostring(round).."/"..tostring(maxround)
	self.roundLabel:setString(text)
	self.roundLabel:setVisible(true)
end

--创建桌面筹码
function C:createDesktopChips()
	self.chipsClass:throwDesktopChips(self.model.currentSingleChip,self.model.currentTotalChips)
end

--显示匹配
function C:showMatchLayer()
	self:showWaitOther()
	self:hidePlayerByLocalSeatId(1)
end

function C:hideMatchLayer()
	self:hideWaitOther()
end

--显示系统自动开牌
function C:showAutoCmpAni( callback )
	local width = self.autocmpImg:getContentSize().width
	local posY = self.autocmpImg:getPositionY()
	local startPos = cc.p(-width/2,posY)
	local pausePos = cc.p(568,posY)
	local endPos = cc.p(1136+width/2,posY)
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

function C:showReportBtn()
	self.reportBtn:setVisible(true)
end

function C:hideReportBtn()
	self.reportBtn:setVisible(false)
end

function C:showContinueBtn( time )
	self.continueBtn:setVisible(true)
	if time then
		self.continueBtn:getChildByName("label"):setVisible(true)
		self.continueBtn:getChildByName("text"):setPosition(cc.p(82,42))
		self:showContinueTimer(time)
	else
		self.continueBtn:getChildByName("label"):setVisible(false)
		self.continueBtn:getChildByName("text"):setPosition(cc.p(104,42))
	end
end

function C:hideContinueBtn()
	self:hideContinueTimer()
	self.continueBtn:setVisible(false)
end

--显示继续倒计时倒计时
function C:showContinueTimer( time )
	self:hideContinueTimer()
	self.continueBtn:getChildByName("label"):setString(tostring(time))
	utils:createTimer("zjh.ContinueTimer",1,function()
		local count = tonumber(self.continueBtn:getChildByName("label"):getString()) or 0
		count = count - 1
		self.continueBtn:getChildByName("label"):setString(tostring(count))
		if count <= 0 then
			--超时退出游戏
			self.core:quitGame()
		end
	end)
end

function C:hideContinueTimer()
	utils:removeTimer("zjh.ContinueTimer")
end

--显示开始倒计时
function C:showStartTimer( time )
	self:hideStartTimer()
	if time < 1 then
		self.model.isGaming = true
		return
	end
	self.startTimer:getChildByName("label"):setString(tostring(time))
	self.startTimer:setVisible(true)
	utils:createTimer("zjh.StartTimer",1,function()
		local count = tonumber(self.startTimer:getChildByName("label"):getString()) or 0
		count = count - 1
		self.startTimer:getChildByName("label"):setString(tostring(count))
		if count <= 1 then
			self.model.isGaming = true
		end
		if count <= 0 then
			self:hideStartTimer()
		end
	end)
end

function C:hideStartTimer()
	utils:removeTimer("zjh.StartTimer")
	self.startTimer:setVisible(false)
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

--清理桌子
function C:cleanDesktop()
	self.roundLabel:setVisible(false)
	self:setZongzhu(0)
	self.chipsClass:clean()
	self.resultClass:clean()
	self:cleanPlayers()
	self:showDengguan(0)
	self:hideReportBtn()
	self:hideContinueBtn()
	self:updateOperationBtns()
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
	local isGzyz = false
	if self.model.isGaming then
		--取消跟到底
		if self.model.isAuto then
			config[ZJH.BTN_NAME.UNALWAYS] = true
		end
		--弃牌
		if self.model.isAuto == false and self.model.isMeAll == false then
			config[ZJH.BTN_NAME.QIPAI] = true
		end
		--孤注一掷
		if self.model.isAuto == false and self.model.turnToMe and self.model.myInfo["money"] < self.model.currentSingleChip*bei*2 then
			isGzyz = true
			config[ZJH.BTN_NAME.GZYZ] = true
		end
		--跟注
		if self.model.isAuto == false and self.model.turnToMe and self.model.currentOptConfigs[ZJH.BTN_NAME.GENZHU] then
			config[ZJH.BTN_NAME.GENZHU] = true
		end
		--看牌
		if self.model.isAuto == false 
			and self.model.currentOptConfigs[ZJH.BTN_NAME.KANPAI] 
			and self.model.playerGameStatusArr[1] == ZJH.PLAYER_GAME_STATUS.NOT_LOOKED
			and ((self.model.currentRound > 0) or (self.model.currentRound==0 and self.model.turnToMe)) then
			config[ZJH.BTN_NAME.KANPAI] = true
		end
		--比牌
		if self.model.isAuto == false and self.model.turnToMe and self.model.currentOptConfigs[ZJH.BTN_NAME.BIPAI] then
			config[ZJH.BTN_NAME.BIPAI] = true
		end
		--全押 TODO:没有全押
		--加注3
		if self.model.isAuto == false and self.model.turnToMe and self.model.currentOptConfigs[ZJH.BTN_NAME.JIAZHU3] then
			config[ZJH.BTN_NAME.JIAZHU3] = true
		end
		--加注2
		if self.model.isAuto == false and self.model.turnToMe and self.model.currentOptConfigs[ZJH.BTN_NAME.JIAZHU2] then
			config[ZJH.BTN_NAME.JIAZHU2] = true
		end
		--加注1
		if self.model.isAuto == false and self.model.turnToMe and self.model.currentOptConfigs[ZJH.BTN_NAME.JIAZHU1] then
			config[ZJH.BTN_NAME.JIAZHU1] = true
		end
		--跟到底
		if self.model.isAuto == false and self.model.isMeAll == false then
			config[ZJH.BTN_NAME.ALWAYS] = true
		end
	end
	dump(config,"updateOperationBtns")
	self.operationClass:updateBtns(config,self.model.isAuto,self.model.turnToMe,isGzyz)
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
	--如果已经点了继续游戏，就直接过滤结算协议
	if self.waitOtherImg:isVisible() then
		return
	end
	self:showReportBtn()
	-- self:showContinueBtn(20)
	self:showContinueBtn()
	for i=1,5 do
		local playerClass = self.playerClassArr[i]
		playerClass:lightHead()
	end
	--显示所有玩家的牌
	if info["jiesuan"] and info["jiesuan"]["allcard"] then
    	for k,v in pairs(info["jiesuan"]["allcard"]) do
    		local seatId = self:getLocalSeatId(v["seat"])
    		self:showPlayerPoker(seatId,v["cards"],false)
		end
    end
    self:playChangeMoneyAni(info)
	--上一局回顾
	local historyInfo = utils:copyTable(info["jiesuan"]["paiju"])
	--获取玩家信息
	local function GetInfoByPlayerID(playerId)
		local info = nil
		for i,v in ipairs(self.model.playerlist) do
			if v.playerid == playerId then
				info = v
				break
			end
		end
		return info
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
			if playerInfo then
				local cards = GetCardsBySeatID(playerInfo.seat)
				v["nickname"] = playerInfo["nickname"]
				v["wxheadurl"] = playerInfo["wxheadurl"]
				v["cards"] = cards
				local ctype = ZJH.POKER_TYPE.NONE
				if #cards == 3 then
					ctype = self.logic:getPokerType(cards[1],cards[2],cards[3])
				end
				v["ctype"] = ctype
			end
		end
	end
	dump(historyInfo,"上局回顾",10)
	self.historyInfo = historyInfo
	if self.historyLayer then
		self.historyLayer:reloadInfo(self.historyInfo)
	end
end

function C:playChangeMoneyAni( info )
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
			if seatId == 1 then
				PLAY_SOUND(GAME_ZJH_SOUND_RES.."game_win.mp3")
			end
		elseif coin < 0 then
			self.resultClass:showLoseCoin(seatId,utils:moneyString(coin,2).."元")
			if seatId == 1 then
				PLAY_SOUND(GAME_ZJH_SOUND_RES.."game_over.mp3")
			end
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
	if playerClass:isVisible() == false then
		--return
	end
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
	if bettype == ZJH.OPT.BET or bettype == ZJH.OPT.CALL then
		if self.model.playerGameStatusArr[localSeatId] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
			self:setPlayerSpeak(localSeatId,1)
		else
			self:setPlayerSpeak(localSeatId,6)
		end
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
		self.chipsClass:throwChips(localSeatId,self.model.currentSingleChip,betchips,bettype)
	end
end

--玩家比牌
function C:playCompareAni( fromSeatId, winnerSeatId, loserSeatId )
	--播放发起比牌玩家说话，自己在点击比牌的时候已经说了
	if fromSeatId ~= 1 then
		self:setPlayerSpeak(fromSeatId,4)
	end
	self.compareClass:playCompareAni( winnerSeatId, loserSeatId, function()
		--设置输家状态
		self:setPlayerStatus(loserSeatId,2)
	end )
end

function C:updatePlayerTableStatus( status )
	for i=1,5 do
		if self.playerClassArr[i]:isVisible() then
		else
		end
	end
end

--设置玩家状态 0:隐藏 1:看牌 2:淘汰 3:弃牌
function C:setPlayerStatus( localSeatId, status )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setStatus(status)
end

function C:setPlayerSpeakById( playerId,speak )
	local localSeatId = self:getLocalSeatIdByPlayerId(playerId)
	self:setPlayerSpeak(localSeatId,speak)
end

--设置玩家状态 0:隐藏 1:跟注  2:加注  3:看牌  4:比牌  5:全押 6:蒙跟 7:离开
function C:setPlayerSpeak( localSeatId, speak )
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:setSpeak(speak)
	--播放音效
	if speak == 1 or speak == 6 then
		self:playPlayerSpeakSound(localSeatId,"follow",3)
	elseif speak == 2 then
		self:playPlayerSpeakSound(localSeatId,"add",1)
	elseif speak == 3 then
		self:playPlayerSpeakSound(localSeatId,"see",1)
	elseif speak == 4 then
		self:playPlayerSpeakSound(localSeatId,"cmp",1)
	elseif speak == 5 then
		self:playPlayerSpeakSound(localSeatId,"all",2)
	end
end

function C:playPlayerSpeakSound( localSeatId, resname, resnum )
	local index = 1
	if resnum > 1 then
		index = math.random(1,resnum)
	end
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

--显示玩家操作倒计时
function C:showPlayerTimer( localSeatId, leftTime, callback )
	self:hideAllPlayerTimer()
	local playerClass = self.playerClassArr[localSeatId]
	playerClass:showTimer(leftTime,callback)
	self:showDengguan(localSeatId)
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
	self:showDengguan(0)
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

function C:cleanPlayerByLocalSeatId( localSeatId )
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