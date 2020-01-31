local PlayerClass = import(".JsmjPlayerView")
local SettlementView = import(".JsmjSettlementView")
local RuleLayer = import(".JsmjRuleLayer")
local JsmjSettingLayer = import(".JsmjSettingLayer")

local JsmjTable = import(".JsmjTable")
local JsmjOpenAnim = import(".JsmjOpenAnim")
local JsmjDiceAnim = import(".JsmjDiceAnim")
local JsmjOwnTileView = import(".JsmjOwnTileView")
local JsmjOtherTiles = import(".JsmjOtherTiles")
local JsmjDiscardTile = import(".JsmjDiscardTile")
local JsmjCurrentDiscard = import(".JsmjCurrentDiscard")
local JsmjAwardFlower = import(".JsmjAwardFlower")
local JsmjTile = import(".JsmjTile")
local JsmjTileImage = import(".JsmjTileImage")
local bit = require("bit")

local C = class("JsmjScene", GameSceneBase)

local scheduler = cc.Director:getInstance():getScheduler()

local WAITING_CSB = GAME_JSMJ_PREFAB_RES.."Waiting.csb"

local PLAYER_COUNT = 2

local LAYER_ID_BG = 1 -- 背景(电池，信号，显示牌张数)
local LAYER_ID_STATIC_INFO = 2
local LAYER_ID_TILE = 3 -- 牌
local LAYER_ID_OWN_TILE = 4 -- 牌
local LAYER_ID_OPERATE = 5 -- 操作
local LAYER_ID_INFO = 6 -- 信息
local LAYER_ID_HANDSELECT = 7 -- 吃碰杠听操作层
local LAYER_ID_ANIM = 8 -- 动画
local LAYER_ID_RESULT = 9 -- 结算

-- 资源名
C.RESOURCE_FILENAME = "games/jsmj/jsmjScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
    --测试按钮
    testBtn1 = {path="TEST_BTN1",events={{event="click",method="onTest1"}}},
    testBtn2 = {path="TEST_BTN2",events={{event="click",method="onTest2"}}},
	--返回按钮
	backBtn = {path="top.btn_return",events={{event="click",method="onBack"}}},
	--帮助按钮
	helpBtn = {path="top.btn_wanfa",events={{event="click",method="onHelp"}}},
	--设置页面
	settingsBtn = {path="top.btn_setting",events={{event="click",method="onSettings"}}},
    leftNode = {path="top.Sprite_di"},
    leftNum = {path="top.Sprite_di.Text_num"},

    bottomNode = {path="bottom"},
    systemTime = {path="bottom.Text_time"},
    difenLabel = {path="bottom.Text_difen"},

    --定时器节点
    imgCenter = {path="center"},
    imgTimer = {path="Image_timer"},
    labelTimer = {path="Image_timer.Text_timer"},
    upChkTimer = {path="Image_timer.CheckBox_top"},
    downChkTimer = {path="Image_timer.CheckBox_bottom"},

    imgBanker = {path="center.Image_banker"},

    imgTuoguan = {path="center.Image_trust"},
    btnTuoguan = {path="center.Image_trust.Button_trust",events={{event="click",method="onClickCancelTuoguan"}}},

    panelTing = {path="center.Panel_ting"},
    btnOut = {path="center.Panel_ting.Button_out",events={{event="click",method="onClickOutCard"}}},
    imgChaTing = {path="center.Panel_ting.Image_chating"},
    labelTingZhang = {path="center.Panel_ting.Image_chating.Label_zhang"},
    labelTingTip = {path="center.Panel_ting.Image_chating.Text_3"},
    imgTingMj = {path="center.Panel_ting.Image_chating.Image_mj"},

    btnChaTing = {path="bottom.Button_ting",events={{event="touch",method="onTouchChaTing"}}},
    btnCancelTing = {path="bottom.Button_cancel",events={{event="click",method="onClickCancelTing"}}},

    btnHu = {path="center.Button_hu",events={{event="click",method="onClickHu"}}},
    labelHuFan = {path="center.Button_hu.Label_fan"},

    settlementNode = {path="result_con"},

    nodeCardBegin1 = {path="Node_cardbegin1"},
    nodeCardBegin2 = {path="Node_cardbegin2"},

    nodeHandCard1 = {path="Node_hand1"},
    nodeHandCard2 = {path="Node_hand2"},

    nodeEffectTop = {path="Node_effecttop"},
    nodeEffectBottom = {path="Node_effectbottom"},
    nodeEffectCenter = {path="Node_effectcenter"},

    nodeMopai1 = {path="Node_mopai1"},
    nodeMopai2 = {path="Node_mopai2"},

    batteryNode = {path="bottom.Node_battery"},

    curDiscardNode = {path="Image_curDiscard"}
}

C.players = nil
C.settlementView = nil
C.ruleLayer = nil
C.settingLayer = nil

function C:ctor(core)
    --玩家
    for i=1,PLAYER_COUNT do
		local key = string.format("player%d",i)
		local path = string.format("player_%d",i)
		self.RESOURCE_BINDING[key] = {path=path}
	end
	C.super.ctor(self,core)
end

function C:initialize()
	C.super.initialize(self)
    self:adjustUI(
        nil,
        {
            self.backBtn,
            self.leftNode,
            self["player1"]:getChildByName("head_con"),
            self["player1"]:getChildByName("Node_head"),
            self["bottomNode"]:getChildByName("Text_name"),
            self["bottomNode"]:getChildByName("Text_score"),
        },
        {
            self.btnHu,
            self.btnOut,
            self.helpBtn,
            self.batteryNode,
            self.settingsBtn,
            self.btnChaTing,
            self.btnCancelTing,
        }
    )

    --绑定玩家
    self.players = {}
    for i=1,PLAYER_COUNT do
        local key = string.format("player%d",i)
        local p = self[key]
        p:setLocalZOrder(LAYER_ID_INFO)
		local player = PlayerClass.new(p,i,self.logic,self.effectNode, self.bottomNode)
        player:hide()
		self.players[i] = player
    end

    self.nodeHandCard = {self.nodeHandCard1, self.nodeHandCard2}
    self.nodeMopai = {self.nodeMopai1, self.nodeMopai2}

    --绑定电池节点
	self:bindBatteryNode(self.batteryNode)
	self:updateBattery()

    --绑定结算面板
    self.settlementView = SettlementView.new(self, self.settlementNode)
    self.settlementNode:setLocalZOrder(LAYER_ID_RESULT)
    self.imgCenter:setLocalZOrder(LAYER_ID_INFO)

    --听牌麻将模板
    self.imgTingMj:setVisible(false)
    self.awardFlowerView_ = nil
    self.bDiscardActionFlag_ = false
    self.mahjongTable_ = JsmjTable.new(self)
    self.mahjongTable_:addTo(self.resourceNode, LAYER_ID_TILE)
    self:initOwnTileView()
    self:initOtherUserTile()
    self:initDiscardTile()
    --绑定对方出牌面板
    self.currentDiscardTile_ = JsmjCurrentDiscard.new(self, self.curDiscardNode)
    self.curDiscardNode:setVisible(false)
    self.curDiscardNode:setLocalZOrder(LAYER_ID_ANIM)

    self:clean()
end

--加载资源
function C:loadResource()
	C.super.loadResource(self)
    local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(GAME_JSMJ_IMAGES_RES.."awardflower/anim/awardflower.ExportJson")
end

--卸载资源
function C:unloadResource()
    local manager = ccs.ArmatureDataManager:getInstance()
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."awardflower/anim/awardflower.ExportJson")
	C.super.unloadResource(self)
end

function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--TODO:播放背景音乐
    PLAY_MUSIC(GAME_JSMJ_SOUND_RES.."bg.mp3")
end

function C:onExitTransitionStart()
	--移除图集
    self:clean()
	C.super.onExitTransitionStart(self)
end

function C:clean()
    self.bDiscardActionFlag_ = false

    for i=1,PLAYER_COUNT do
        self.players[i]:clean()
		self.players[i].headNode:setVisible(false)
    end

    self.bottomNode:setVisible(false)
    self:hideSettlement()
    self:hideBankerOut()
    self:hideLeftCard()
    self:hideTimer()
    self:hideTrust()
    self:hideTingPanel()
    self:hideTingBtn()
    self:hideHuBtn()

    if self.ruleLayer then
		self.ruleLayer:release()
		self.ruleLayer = nil
	end
    if self.settingLayer then
		self.settingLayer:release()
		self.settingLayer = nil
	end
    
    if self.ownTileView_ then
        self.ownTileView_:playViewReset()
    end
    for i = 1, self.model.playerCount do
        if self.otherUserTiles_[i] then
            self.otherUserTiles_[i]:reset()
        end
    end
    for i = 1, self.model.playerCount do
        if self.discardTile_[i] then
            self.discardTile_[i]:reset()
        end
    end
    self:disableCurrentDiscardTile()
end

function C:delayInvoke(time,callback)
    local act = transition.sequence({
		CCDelayTime:create(time),
		CCCallFunc:create(callback)
	})
    self:runAction(act)
end

function C:getAboveImg(value)
    local tilesResArr_normal = {
    {
        "mahjong_tile_big_wan_1", "mahjong_tile_big_wan_2", "mahjong_tile_big_wan_3",
        "mahjong_tile_big_wan_4", "mahjong_tile_big_wan_5", "mahjong_tile_big_wan_6",
        "mahjong_tile_big_wan_7", "mahjong_tile_big_wan_8", "mahjong_tile_big_wan_9"
    },
    { "mahjong_tile_big_zi_zhong", "mahjong_tile_big_zi_fa", "mahjong_tile_big_zi_baiban" }
    }
    local name  = ""
    if value >= 0x31 and value <= 0x33 then
        name = tilesResArr_normal[2][value-0x30] or ""
    else
        name = tilesResArr_normal[1][value] or ""
    end
    local img = GAME_JSMJ_IMAGES_RES .. "tile/" .. name .. ".png"
    return img
end

--region UI Event

--测试
function C:onTest1()
--    for i=1,PLAYER_COUNT do
--        self:showPlayer(i,{headid = 5,playerid = "123456",money = 10000,nickname = "深圳"})
--    end

    self.core:c2sSendTuoGuan(true)

--    self.players[1]:castDice({1,4})

--    self:initTableClockData()
--    self:initOpenDoorFigure()

--    local cards = {}
--    for k,v in pairs(colornumbers) do
--        table.insert(cards,self.logic:colorNumber2Id(v.color,v.num))
--    end

--    for i=1,PLAYER_COUNT do
--        self:showCards(i,cards)
--    end
end

function C:onTest2()
--    self.players[2]:castDice({1,4})
--    --self.core:c2sZhunBei()

--    self:openDoor()

--    self.model.bankerSeat = 2
--    self.model.diceNum1 = 2
--    self.model.diceNum2 = 5
--    self:DealCard()

    local s = { }
    s.LuckyCards = {1,2,3,4,49}
    s.BingoCard = {2,4}
    for k,v in pairs(s.LuckyCards) do
            local drawTile = JsmjTile.new(v)
            if s.BingoCard then
                for l,n in pairs(s.BingoCard) do
                    if v == n then
                        table.insert(self.model.hitTiles_, drawTile)
                        break
                    end
                end
            end
            table.insert(self.model.awardTiles_, drawTile)
        end

    self:showAwardFlowerView(true, true)
end

--点击返回按钮
function C:onBack(event)
    printInfo("点击了返回")
	self:touchBack()
end

--点击帮助按钮
function C:onHelp(event)
	--self:showRule()

    if self.ruleLayer == nil then
        self.ruleLayer = RuleLayer.new()
        self.ruleLayer:retain()
    end
    self.ruleLayer:show()
end

--点击设置按钮
function C:onSettings(event)
	--self:showSettings()

    if self.settingLayer == nil then
        self.settingLayer = JsmjSettingLayer.new()
        self.settingLayer:retain()
    end
    self.settingLayer:show()
end

--点击托管按钮
function C:onTuoGuan(event)
	self.core:c2sSendTuoGuan(1)
end

--点击取消托管按钮
function C:onClickCancelTuoguan()
    self.core:c2sSendTuoGuan(0)
end

function C:onClickOutCard()
    if self.model.chaTingOutId ~= nil and self.model.chaTingOutValue ~= nil then
        self:advanceTakeTile(self.model:getMyLocal(), self.model.chaTingOutId, self.model.chaTingOutValue)
    end
    self:onClickCancelTing()
end

function C:onTouchChaTing(event)
    if event.name == "began" then
		if not self.model:isMyTurn() and self.model.chaTingOutValue then
            self:ShowTingInfo(self.model.chaTingOutValue)
        end
	elseif event.name == "moved" then
	elseif event.name == "ended" then
        if not self.model:isMyTurn() then
            self:onClickCancelTing()
        else
            self.model.chaTinged = true
            self:showTingBtn(self.model.chaTinged )
            if self.ownTileView_ then
                self.ownTileView_:undoDrawCallTile()
                self.ownTileView_:setCanTingTiles()
            end
        end
	elseif event.name == "cancelled" then
		if not self.model:isMyTurn() then
            self:onClickCancelTing()
        end
	end
end

function C:ShowTingInfo(value)
    for j=1,3 do
        if self.imgChaTing:getChildByTag(200+j) then
            self.imgChaTing:getChildByTag(200+j):removeFromParent()
        end
    end
    if self.model:isMyTurn() then
        self.btnOut:setVisible(true)
    else
        self.btnOut:setVisible(false)
    end
    self.imgChaTing:setContentSize(306, 228)
    self.labelTingZhang:setString("0/")
    for i=1,#self.model.tingInfo do
        if  value == self.model.tingInfo[i].OutCardData then
            local tingValue = self.model.tingInfo[i].ListenValue
            local totalZhang = 0
            self.panelTing:setVisible(true)
            local width = 306+120*(#tingValue-1)
            self.imgChaTing:setContentSize(width, 228)
            for j=1,#tingValue do
                local mjInfo = self.imgTingMj:clone()
                mjInfo:setTag(200+j)
                self.imgChaTing:addChild(mjInfo)
                mjInfo:setPosition(cc.p(223+120*(j-1), 140))
                mjInfo:setVisible(true)

                local zhang = 0
                local fan = tingValue[j].Value
                if tingValue[j].Value >= 0x31 and tingValue[j].Value <= 0x33 then
                    fan = 10
                end
                local outed = false
                for k,v in pairs(self.model.tiles_) do
                    if v.value_ == value and outed == false then
                        outed = true
                    else
                        if v.value_ >= 0x31 and v.value_ <= 0x33 then
                            fan = fan + 10
                        else
                            fan = fan + v.value_
                        end
                    end
                    if v.value_ == tingValue[j].Value then
                        zhang = zhang+1
                    end
                end

                for n=1,2 do
                    for k,v in pairs(self.model.outCard[n]) do
                        if v.value_ == tingValue[j].Value then
                            zhang = zhang+1
                        end
                    end
                end

                zhang = 4-zhang
                totalZhang = totalZhang + zhang
                mjInfo:getChildByName("Image_value"):loadTexture(self:getAboveImg(tingValue[j].Value))
                mjInfo:getChildByName("Image_1"):loadTexture(GAME_JSMJ_IMAGES_RES .. "tingview/" .. zhang ..".png")
                mjInfo:getChildByName("Label_fan"):setString(fan .. "番")
            end--for

            if totalZhang > 9 then
                self.labelTingZhang:setScale(0.8)
            else
                self.labelTingZhang:setScale(1)
            end
            self.labelTingZhang:setString(totalZhang .. "/")
            break
        end--if
    end--for
end

function C:onClickCancelTing()
    self.model.chaTinged = false

    self:showTingBtn(self.model.chaTinged )
    self.panelTing:setVisible(false)

    if self.ownTileView_ then
        self.ownTileView_:undoDrawCallTile()
    end
end

function C:onClickHu()
    self.core:c2sSendOperate(1)
    self:hideHuBtn()
end
--endregion 

--显示匹配动画
--设置底分
function C:setDiFen(difen)
    self.difenLabel:setString("底分：" .. tostring(difen * 10))
end

function C:showWaiting()
    if self.waitingAni == nil or self.waitingAct == nil then
        self.waitingAni = cc.CSLoader:createNode(WAITING_CSB)
        self.waitingAct = cc.CSLoader:createTimeline(WAITING_CSB)
        self.waitingAni:runAction(self.waitingAct)
        self.waitingAni:addTo(self)
        self.waitingAni:setPosition(cc.p(display.cx,123))
    end
    self.waitingAni:setVisible(true)
    self.waitingAct:gotoFrameAndPlay(0,true)
end

--隐藏匹配动画
function C:hideWaiting()
    if self.waitingAni then
        self.waitingAni:setVisible(false)
    end
    if self.waitingAct then
        self.waitingAct:stop()
    end
end

--显示玩家
function C:showPlayer(pos,info)
    print("showPlayer"..pos)
    self.players[pos]:show(info)
end

--隐藏玩家
function C:hidePlayer(pos)
    self.players[pos]:hide()
end

--设置金币
function C:setMoney(pos,money)
    self.players[pos]:setMoney(money)
end

--显示庄家出牌
function C:showBankerOut()
    self.imgBanker:setVisible(true)
end

--隐藏庄家出牌
function C:hideBankerOut()
    self.imgBanker:setVisible(false)
end

--显示剩余牌数
function C:showLeftCard(count)
    self.leftNode:setVisible(true)
    self.leftNum:setString(count)
end

--隐藏剩余牌数
function C:hideLeftCard()
    self.leftNode:setVisible(false)
end

--显示托管
function C:showTrust()
    self.imgTuoguan:setVisible(true)
end

--隐藏托管
function C:hideTrust()
    self.imgTuoguan:setVisible(false)
end

--显示查听panel
function C:showTingPanel()
    self.panelTing:setVisible(true)
end

--隐藏查听panel
function C:hideTingPanel()
    self.panelTing:setVisible(false)
end

function C:refreshOperate(bReset)
    if self.model.huFan > 0 then
        self:showHuBtn(self.model.huFan)
        self:hideTingPanel()
        self:hideTingBtn()
    else
        self:hideHuBtn()
        if self.model.hasTing == 1 then
            if bReset then
                self.model.chaTinged = false
            end
            self:showTingBtn(self.model.chaTinged)
            self.panelTing:setVisible(false)
        else
            self:hideTingPanel()
            self:hideTingBtn()
        end
    end
end

--显示查听按钮
function C:showTingBtn(chatinged)
    self.btnChaTing:setVisible(not chatinged)
    self.btnCancelTing:setVisible(chatinged)
end

--隐藏查听按钮
function C:hideTingBtn()
    self.btnChaTing:setVisible(false)
    self.btnCancelTing:setVisible(false)
end

--显示胡按钮
function C:showHuBtn(fan)
    self.btnHu:setVisible(true)
    self.labelHuFan:setString(fan .. "番")
end

--隐藏胡按钮
function C:hideHuBtn()
    self.btnHu:setVisible(false)
end

--显示结算
function C:showSettlement(info)
    self.settlementView:show(info)
end

--隐藏结算
function C:hideSettlement()
    self.settlementView:hide()
end

--显示倒计时
function C:showTimer(time)
    self.imgTimer:setVisible(true)
end

function C:refreshBanker()
    self.imgTimer:setVisible(true)
    self.upChkTimer:setSelectedState(not self.model:isMyTurn())
    self.downChkTimer:setSelectedState(self.model:isMyTurn())
    self.labelTimer:setString(tostring(""))
end
--刷新倒计时
function C:refreshTimer(isTop, time, callback)
    self.upChkTimer:setSelectedState(isTop)
    self.downChkTimer:setSelectedState(not isTop)

    self:removeClockHandler()
    local leftTime = math.floor(time/1000)
    self.labelTimer:setString(tostring(leftTime))

	self.countDownHandler = scheduler:scheduleScriptFunc(function()
        leftTime = leftTime - 1
		if leftTime <= 0 then
            self.labelTimer:setString(0)
			if callback then
				callback()
			end
            self:removeClockHandler()
		else 
            self.labelTimer:setString(tostring(leftTime))
			if leftTime < 4 then 
                PLAY_SOUND(GAME_JSMJ_SOUND_RES.."countdown.mp3")
			end
		end
	end, 1,false)
end

--隐藏倒计时
function C:hideTimer()
    self:removeClockHandler();
    self.imgTimer:setVisible(false)
end

--移除闹钟回调
function C:removeClockHandler()
	if self.countDownHandler then 
		scheduler:unscheduleScriptEntry(self.countDownHandler)
		self.countDownHandler = nil;
	end
end

--[[ 显示及关闭奖花
     @param flag: 显示及关闭 true or false
     @hasAnim: 是不有动画  true or false
 ]]
function C:showAwardFlowerView(flag, hasAnim, callback)
    PLAY_SOUND(GAME_JSMJ_SOUND_RES.."award_flower.mp3")
    if flag then
        --self:showAwardFlowerMask(true)
        if self.awardFlowerView_ then
            self.awardFlowerView_:removeFromParent()
            self.awardFlowerView_ = nil
        end
        self.awardFlowerView_ = JsmjAwardFlower.new(self, hasAnim, callback)
        self.awardFlowerView_:addTo(self.resourceNode, LAYER_ID_ANIM)
        self.awardFlowerView_:setVisible(flag)
    else
        if self.awardFlowerView_ then
            self.awardFlowerView_:removeFromParent()
            self.awardFlowerView_ = nil

            self:drawTileFrontMask(false) --关闭手牌mask
            --self:showAwardFlowerMask(false) --临时
        end
    end
end
function C:drawTileFrontMask(show)
    if self.ownTileView_ then
        self.ownTileView_:drawTileFrontMask(show)
    end
end
--初始化自己手牌
function C:initOwnTileView()
    self.ownTileView_ = JsmjOwnTileView.new(self)
    self.ownTileView_:setOwnTileViewListen(handler(self, self.onOwnTileViewListen))
    self.ownTileView_:addTo(self.resourceNode, LAYER_ID_OWN_TILE)
    self.ownTileView_:playViewReset()
end
--初始化其它玩家手牌
function C:initOtherUserTile()
    local palyerCount = self.model.playerCount
    self.otherUserTiles_ = {}
    for i = 1, palyerCount do
        if i ~=self.define.MahjongPos.POSITION_BOTTOM then
            self.otherUserTiles_[i] = JsmjOtherTiles.new(self, i)
            self.otherUserTiles_[i]:addTo(self.resourceNode, LAYER_ID_TILE)
            if i == self.define.MahjongPos.POSITION_TOP then
                self.otherUserTiles_[i]:setOtherTileViewListen(self)
            end
        end
    end
end

--初始化牌池view
function C:initDiscardTile()
    local palyerCount = self.model.playerCount
    self.discardTile_ = {}
    for i = 1, palyerCount do
        self.discardTile_[i] = JsmjDiscardTile.new(self, i,true)
        self.discardTile_[i]:addTo(self.resourceNode , LAYER_ID_TILE)
    end
end
function C:DealCard()
--    self.bottomNode:setVisible(true)
    --初始化牌堆
    self:initOpenAnim()
    --延迟1秒 头像动画
    if self.openAnim_ then
        self:delayInvoke(0.9, function()
            if self.openAnim_ then
                self.openAnim_:startFigureAnim()
            end
        end)
    end
    --延迟1秒 骰子动画
    if self.openAnim_ then
        self:delayInvoke(1, function()
            self.dicCount = 0
            local isSingle = (self.model.diceNum1+self.model.diceNum2)%2
            if self.model:getBankerLocal() == 1 then
                if isSingle == 0 then
                    isSingle = 2
                end
            else
                if isSingle == 1 then
                    isSingle = 2
                else
                    isSingle = 1
                end
            end
            self:startDiceAnim(isSingle, self.model.diceNum1, self.model.diceNum2)
        end)
    end
end
--初始化开牌动画组件
function C:initOpenAnim()
    if self.openAnim_ == nil then
        self.openAnim_ = JsmjOpenAnim.new(self)
        self.openAnim_:setAnchorPoint(cc.p(0.5,0.5))
        self.openAnim_:setContentSize(display.width, display.height)
        self.openAnim_.onFigureAnimEndListener_ = handler(self, self.doFigureAnimEnd)--头像动画结束
        self.openAnim_.onOpenDoorOverListener_ = handler(self, self.doOpenDoorAnimEnd)--开牌动画结束
        self.openAnim_.onAddTilesListener_ = handler(self, self.doAddTiles)--摸起一堆牌
        self.openAnim_:addTo(self)
    end
end
--开始骰子动画
function C:startDiceAnim(pos, vaule1, vaule2)
    self.dicCount = self.dicCount + 1
    if self.diceAnim_ == nil then
        local width, height = 350, 350
        self.diceAnim_ = JsmjDiceAnim.new(self, 350, 350)
        self.diceAnim_:setPosition((display.width - width) / 2, 175)
        self.diceAnim_:setAnchorPoint(cc.p(0, 0))
        self.diceAnim_:setContentSize(width, height)
        self.diceAnim_:setScale(1)
        self.diceAnim_:setOnAnimEndListener(function() 
            self:delayInvoke(0.2, function()
            if self.dicCount >= 2 then
                self:openDoor() --骰子完发牌
            else
                self:startDiceAnim(self.model:getBankerLocal(), (vaule1+math.random(1,6))%6+1, (vaule2+math.random(1,6))%6+1)
            end
            end)
        end)
        self.diceAnim_:addTo(self)
    end
    PLAY_SOUND(GAME_JSMJ_SOUND_RES.."dice.mp3")
    self.diceAnim_:start(pos, vaule1, vaule2)
end
--骰子完牌局开牌处理（起手拿牌）
function C:openDoor()
    self.ownTileView_:startGetTiles(self.model.myCards, false)
    if self.openAnim_ then
        local fromSeat = math.random(1,2)
        local fromOffset = math.random(1,6)
        self.openAnim_:startDeal(self.model:getBankerLocal(), fromSeat, fromOffset,self.model.myCards)
    end
end
--开牌动画玩家头像移动结束
function C:doFigureAnimEnd()
    --显示玩家名字
    for i=1,PLAYER_COUNT do
        self.players[i].scoreLabel:setVisible(true)
        self.players[i].nameLabel:setVisible(true)
    end
    --显示底部信息条
    self.bottomNode:setVisible(true)
end
--开牌动画时，逐步显示各个玩家手牌
function C:doAddTiles(pos, totalNum)
    if pos == self.define.MahjongPos.POSITION_BOTTOM then
        PLAY_SOUND(GAME_JSMJ_SOUND_RES.."opendoor.mp3")
        if self.ownTileView_ then
            self.ownTileView_:showDealTiles(totalNum)
        end
    elseif self.otherUserTiles_ then
        if self.otherUserTiles_[pos] then
            self.otherUserTiles_[pos].isAnim_ = true
            self.model.topLeftNum = self.model.topLeftNum + totalNum
            self.otherUserTiles_[pos]:setTileNum(self.model.topLeftNum)
            self.otherUserTiles_[pos]:refresh()
        end
    end
end
--开牌动画结束处理
function C:doOpenDoorAnimEnd()
    if self.ownTileView_ then
        self.ownTileView_:setViewPlayState() --设置为play 状态
    end
    self:startDeal()--显示手牌
    self:removerOpenAnim()--隐藏牌堆
--    self.core:c2sSendCardEnd()--向服务器发送开牌动画完成
end
--服务器通知开始游戏处理
function C:RefreshStartGame()
    self:refreshOperate(1)

    --self.bottomNode:setVisible(true)
    self:showTimer()
    self:refreshTimer(not self.model:isMyTurn(), self.model.outTime, nil)
    if self.model.bankerSeat == self.model.mySeat then
        self:showBankerOut()
    end
end
function C:DispatchCard(seat, card)
    self:refreshOperate(1)
    
    self:hideTingPanel()
    self:showLeftCard(self.model.leftCardNum)
    self:refreshTimer(not self.model:isMyTurn(), self.model.outTime, nil)

    if seat == self.model.mySeat then
        local tile = JsmjTile.new(card)
        self.model:addTile(tile)
        self.ownTileView_:setDrawTile(tile, true)
        self.ownTileView_:showDrawTile()
    else
        local pos = self.model:getLocalSeat(seat)
        if self.otherUserTiles_ and self.otherUserTiles_[pos] then
            self.otherUserTiles_[pos]:setTileNum(self.model.topLeftNum)
            self.otherUserTiles_[pos]:setPlayerDrawTile(JsmjTile.new(0), true)
        end
    end
end
function C:OutCard(seat, card,preform)
    self:refreshOperate(1)
    if self.model.bankerSeat == self.model.mySeat then
        self:hideBankerOut()
    end

    self:refreshTimer(not self.model:isMyTurn(), self.model.outTime, nil)
    local pos = self.model:getLocalSeat(seat)
    if seat == self.model.mySeat then
        printInfo(">>>>>>>>>>OutCard>>>>>>>>>>>>1>>>>")
        --fixme:lyt 出牌等服务器返回再做操作
        local sendValue = bit.band(card,0x00FF)
        if self.model.myOutCard == nil or self.model.myOutCard == 0 then
            self.model.myOutCard = self.model:getTileIdByValue(sendValue)
        else
            local mysendValue = bit.band(self.model.myOutCard,0x00FF)
            if mysendValue ~= sendValue then
                self.model.myOutCard = self.model:getTileIdByValue(sendValue)
            end
        end
        if self.model.myOutCard and not preform then
            PLAY_SOUND(GAME_JSMJ_SOUND_RES.."g_" .. sendValue ..".mp3")
            self:discardTile(pos,seat, self.model.myOutCard, sendValue)
            --self:RefreshDiscardTilesByPos(pos, seat)
        else
            printInfo("<==================出牌错误==================>")
--            print(card)
--            print(sendValue)
--            print(self.model.myOutCard)
--            dump(self.model.tiles_)
        end

        if card ~= self.model.myOutCard then --客户端出牌和服务器出牌不一样，容错刷新处理
            printInfo(card..">>>>>>>>>>>>客户端出牌和服务器出牌不一样>>>>>>>>>>>>"..self.model.myOutCard)
            --if self.ownTileView_ then
--                local pos = self.model:getLocalSeat(seat)
--                if self.currentView_.discardTile_[pos] then
--                    self.currentView_.discardTile_[pos]:refresh()
--                end
            --end
        end
    else
        printInfo(">>>>>>>>>>OutCard>>>>>>>>>>>>2>>>>")
        local sendValue = bit.band(card,0x00FF)
        PLAY_SOUND(GAME_JSMJ_SOUND_RES.."g_" .. sendValue ..".mp3")
        self:discardTile(pos,seat, card, sendValue)
    end

    --self:RefreshDiscardTilesByPos(pos, seat)
    --fixme:lyt 出牌等服务器返回再做操作
    self.model.myOutCard = nil
end
--[[--
        刷新牌池显示
        @param seat:玩家座位
        @return none
  ]]
function C:refreshDiscardTiles(seat)
    local pos = self.model:getLocalSeat(seat)
    self:RefreshDiscardTilesByPos(pos, seat)
end

-- 刷新牌池数据
function C:RefreshDiscardTilesByPos(pos, seat)
    --dump(self.model.outCard,"刷新牌池数据")
    if self.discardTile_ and self.discardTile_[pos] then
        self.discardTile_[pos]:setTiles(self.model.outCard[seat])
        self.discardTile_[pos]:refresh()
    end
end

-- 移除牌池显示图片
function C:removeAllDiscardTileImg(pos)
    if self.mahjongTable_ then
        return self.mahjongTable_:removeAllDiscardTileImg(pos)
    end
end
--刷新用户状态，离线和托管状态的头像显示
function C:RefreshStatus()

end
--[[--
    点击自己手牌监听处理
    @param evnet : table type 
    @param id : integet type 时间id
    @param tile : table type 受监听的麻将牌控件
    @param isShow : bool type 是否显示
    @param posX : int type X坐标
    @param posY : int type Y坐标
]]
function C:onOwnTileViewListen(event)
    print(" onOwnTileViewListen eventId=", event.id)
    if event == nil or not self.ownTileView_ then
        return false
    end
    local flag = true
    if event.id == JsmjOwnTileView.TYPE_DISCARD_TILE then
        if event.tile.upper_ == true then
            self.ownTileView_:setDiscardTileFlag(false)
            self:advanceTakeTile(self.model:getMyLocal(), event.tile.id_, event.tile.value_)
        else
            if self.model.chaTinged and not self.ownTileView_:getTileCanTingFlag(event.tile) then
                return flag
            end
            self.ownTileView_:cleanUpper()
            self.ownTileView_:OwnTailsetUpper(event.index, true)
            if self.model.chaTinged then
                self.model.chaTingOutId = event.tile.id_
                self.model.chaTingOutValue = event.tile.value_
                self:ShowTingInfo(event.tile.value_)
            end
        end
    end
    return flag
end
--点击出牌处理动作
function C:advanceTakeTile(seat, tileid, tilevalue)
    printInfo(seat..">>>>>>>>>点击出牌处理动作>>>>>>>>>>"..tilevalue)
    self:hideBankerOut()
    self.ownTileView_:setBankerFlag(false)

    self.model.chaTingOutId = nil
    --self.model.chaTingOutValue = nil

    --fixme:lyt 出牌等服务器返回再做操作
    
    self.model:addOutTileById(self.model.mySeat, tileid)
    self.model.myOutCard = self.model:getTileIdByValue(tilevalue)
    self.model:removeMyCards(tilevalue)
    dump(self.model.myOutCard,"myOutCard")
    PLAY_SOUND(GAME_JSMJ_SOUND_RES.."g_" .. tilevalue ..".mp3")
    self:discardTile(self.model:getMyLocal(),self.model.mySeat, self.model.myOutCard , tilevalue)

    self.core:c2sSendCard(tilevalue)--牌值
end
--出牌刷新界面
function C:discardTile(pos, seat, tileid,tilevalue)
    --self:setCanTingViewFlag(false)
    --如果点击了查听，显示查听界面
    -- 如果不能听了，则取消查听
    -- 如果不能听了，则取消查听

    if self.model and pos == self.model:getMyLocal() then
        -- 隐藏第一局庄家提示
        -- 隐藏出牌时放大的牌张

        self:hideTingPanel()
        self:disableCurrentDiscardTile()
        self.model.chaTingOutValue = tilevalue
        self.drawTileInPlay_ = nil
        if self.ownTileView_ then
            self.ownTileView_:setBankerFlag(false)
            --发送给服务器出牌消息 --fixme:lyt 出牌等服务器返回再做操作
--            self.model.myOutCard = tileid
--            self.core:c2sSendCard(tilevalue)--牌值
            -- 解决听后延迟有时候不生效
            self.ownTileView_:cleanUpper()
            self.model:removeTile(tileid)
            self.ownTileView_:delTile(JsmjTile.new(tileid))
            self.ownTileView_:setDrawTile(nil)
        end
        self:setDiscardActionFlag(false)
    else
        if self.otherUserTiles_ then
            if self.otherUserTiles_[pos] then
                self.otherUserTiles_[pos]:setPlayerDrawTile(nil)
                self.otherUserTiles_[pos]:setTileNum(self.model.topLeftNum)
                self.otherUserTiles_[pos]:refresh()
            end
        end
    end

    local showInfo = self:getDiscardTilePoint(pos)
    dump(showInfo,"showInfo")
    if showInfo then
        self:playDiscardAnim(tileid, pos, seat, showInfo)
    end
end
--获取牌张坐标及缩放
function C:getDiscardTilePoint(seat)
    local showInfo
    if self.discardTile_ and self.discardTile_[seat] then
        showInfo = self.discardTile_[seat]:getNextPoint()
    end
    return showInfo
end
-- 隐藏出牌时放大的牌张
function C:disableCurrentDiscardTile()
    self.isInVisbleCDTFlag_ = false
    self:displayCurrentDiscardTile(nil, self.define.MahjongPos.POSITION_UNKNOW)
end
--[[--
        出牌时，放大出的牌张
        @param t:显示放大牌
        @param pos:玩家位置
  ]]
function C:displayCurrentDiscardTile(t, seat)
    if self.currentDiscardTile_ then
        if t then--显示放大的牌
            local value = bit.band(t,0x00FF)
            self.currentDiscardTile_:show(value)
        else
            self.currentDiscardTile_:hide()--隐藏放大的牌
        end
    end
end
--设置出牌标记
function C:setDiscardActionFlag(flag)
    if self.ownTileView_ then
        self.ownTileView_.bDiscardActionFlag_ = flag
    end
    self.bDiscardActionFlag_ = flag
end
--[[--
        播放出牌动画
        @param tileid:牌张
        @param pos:玩家位置
        @param seat:玩家座位
        @param showInfo:牌张显示状态
        @param callback:动画结束后回调函数
  ]]
function C:playDiscardAnim(tileid, pos, seat, showInfo, callback)
    if tileid <= 0 or not pos or not seat or not showInfo then
        printInfo(">>>>>>>>>playDiscardAnim>>>>>>>1>>>>>>")
        self:refreshDiscardTiles(seat)
        PLAY_SOUND(GAME_JSMJ_SOUND_RES.."discard.mp3")
        if callback then
            callback()
        end
        return
    end
    if not self.mahjongTable_ then
        printInfo(">>>>>>>>>playDiscardAnim>>>>>>>2>>>>>>")
        self:refreshDiscardTiles(seat)
        return
    end

    local tile = JsmjTile.new(tileid)
    local img
    local animtime = 0.12
    local array = { }

    if pos == self.define.MahjongPos.POSITION_TOP then
        img = JsmjTileImage.new(tileid, self.define.MahjongPos.POSITION_DISCARD_TOP,showInfo.tileIndex, self.define.MahjongPos.TILE_SHOW_STATE_FACE, 5)
        local beginInfo = self:getOtherTileShowInfo(pos, 150) -->对家出牌的动画的位置，　150 这个值越大，越靠外
        if not img or not beginInfo then
            printInfo(">>>>>>>>>playDiscardAnim>>>>>>>3>>>>>>")
            self:refreshDiscardTiles(seat)
            return
        end

        img:setPosition(cc.p(beginInfo.x, beginInfo.y))
        img:setScale(showInfo.scale)
        img:setLocalZOrder(showInfo.z)
        table.insert(array, CCMoveTo:create(animtime, cc.p(showInfo.x, showInfo.y)))
    elseif pos == self.define.MahjongPos.POSITION_BOTTOM then
        --_debugInfo(" self discard tile")
        img = JsmjTileImage.new(tileid, self.define.MahjongPos.POSITION_DISCARD_BOTTOM, showInfo.tileIndex, self.define.MahjongPos.TILE_SHOW_STATE_FACE,5)
        if not img or not self.ownTileView_.moveDiscardIdx_ then
            printInfo(">>>>>>>>>playDiscardAnim>>>>>>>4>>>>>>")
            self:refreshDiscardTiles(seat)
            return
        end

        img:setPosition(cc.p(368 + self.ownTileView_.moveDiscardIdx_ * 80, 140))
        img:setScale(showInfo.scale)
        img:setLocalZOrder(showInfo.z)
        table.insert(array, CCMoveTo:create(animtime, cc.p(showInfo.x, showInfo.y)))
    end
    table.insert(array, CCDelayTime:create(0.05))
    if pos == self.define.MahjongPos.POSITION_RIGHT then
        self.mahjongTable_:addChild(img)
    else
        self.mahjongTable_:addChild(img, 10000)
    end

    local function CallFucnCallback1()
        --_debugInfo(" discard tile call back1")
        self.mahjongTable_:removeChild(img)
        printInfo(">>>>>>>>>playDiscardAnim>>>>>>>5>>>>>>")
        self:refreshDiscardTiles(seat)
        if callback then
            callback()
        end
        if pos == self.define.MahjongPos.POSITION_TOP then
            self:displayCurrentDiscardTile(tileid, pos) --显示对家的放大的牌（出的牌）
        else
            -- 如果是自己，打开倒计时
--            if self.tableClock_ then
--                local second = self.mahjongData_:getRulerEx(MahjongRulerInfoDef.RULE18_EX_DISCARDTIME)

--                local checkTime = -2
--                -- 隐藏等待出牌动画
--                self:playWaitOperateAnim(false)
--                self.tableClock_:setDicardPos(MahjongDef.POSITION_TOP)
--                self.tableClock_:setAllowAlert(false)
--                self.tableClock_:setCount(second)
--                self.tableClock_:setCheckTime(checkTime)
--                self.tableClock_:start()
--            end
        end
    end
    table.insert(array, CCCallFuncN:create(CallFucnCallback1))

    local action1 = CCSequence:create(array)
    img:runAction(action1)
end

--endregion
function C:getOpenWallTileImg(pos)
    if self.mahjongTable_ then
        return self.mahjongTable_:getOpenWallTileImg(pos)
    end
end
--添加牌墙显示图片
function C:addOpenWallImg(pos, img)
    if self.mahjongTable_ then
        return self.mahjongTable_:addOpenWallImg(pos, img)
    end
end
--移除开牌动画显示图片
function C:removeAllOpenWallTileImg(pos)
    if self.mahjongTable_ then
        return self.mahjongTable_:removeAllOpenWallTileImg(pos)
    end
end
function C:removerOpenAnim()
    if self.openAnim_ then
        self.openAnim_:removeTileWalls()
        self.openAnim_:removeFromParent()
        self.openAnim_ = nil
    end
end

--移除回收骰子动画相关
function C:recycleDiceView()
    if self.diceAnim_ then
        self.diceAnim_:setVisible(false)
        self.diceAnim_:removeFromParent()
    end
    self.diceAnim_ = nil
end

--[[--
        开牌动画后显示手牌
        @param isHisory:是否是home回来
  ]]
function C:startDeal()
    self:recycleDiceView()
    self:showLeftCard(self.model.leftCardNum)
end

--获取动画参数及位置信息
function C:getAnimInfo(animType, pos)
    if not animType or type(animType) ~= "string" then
        return
    end
    local animInfo = {}
    animInfo.delaySecond = 0
    animInfo.fadeoutSecond = 0
    animInfo.frameScale = 1
    if "abort" == animType then
        animInfo.frameSecond = 0.1
        animInfo.frameCount = 12
        animInfo.frameRect = CCRect(0, 0, 400, 240)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/abort/lj_"
        animInfo.delaySecond = 2
    elseif "pao" == animType then
        animInfo.frameSecond = 0.08
        animInfo.frameCount = 16
        animInfo.frameRect = CCRect(0, 0, 380, 250)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/pao/dp_"
        animInfo.frameScale = 0.6
    elseif "ting" == animType then
        animInfo.frameSecond = 0.1
        animInfo.frameCount = 12
        animInfo.frameRect = CCRect(0, 0, 250, 250)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/ting/ting_"
    elseif "tianting" == animType then
        animInfo.frameSecond = 0.1
        animInfo.frameCount = 13
        animInfo.frameRect = CCRect(0, 0, 440, 240)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/tianting/tianting_"
    elseif "hu" == animType then
        animInfo.frameSecond = 0.1
        animInfo.frameCount = 11
        animInfo.frameRect = CCRect(0, 0, 290, 290)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/hu/hu_"
    elseif "zimo" == animType then
        animInfo.frameSecond = 0.07
        animInfo.frameCount = 16
        animInfo.frameRect = CCRect(0, 0, 540, 220)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/zimo/zim_"
    elseif "tianhu" == animType then
        animInfo.frameSecond = 0.1
        animInfo.frameCount = 11
        animInfo.frameRect = CCRect(0, 0, 400, 230)
        animInfo.frameRes = GAME_JSMJ_IMAGES_RES .. "anim/tianhu/th_"
    else
        animInfo = nil
    end

    if pos == self.define.MahjongPos.POSITION_TOP then
        animInfo.x = self.nodeEffectTop:getPositionX()
        animInfo.y = self.nodeEffectTop:getPositionY()
    elseif pos == self.define.MahjongPos.POSITION_BOTTOM then
        animInfo.x = self.nodeEffectBottom:getPositionX()
        animInfo.y = self.nodeEffectBottom:getPositionY()
    else
        animInfo.x = self.nodeEffectCenter:getPositionX()
        animInfo.y = self.nodeEffectCenter:getPositionY()
    end

    return animInfo
end
function C:playNewAnim(animType, pos, callback)
    -- 动画信息和位置信息
    local animInfo = self:getAnimInfo(animType, pos)
    if not animInfo then
        return
    end

    local array = { }
    for i = 1, animInfo.frameCount do
        local path = animInfo.frameRes .. tostring(i) .. ".png"
        table.insert(array, CCSpriteFrame:create(path, animInfo.frameRect))
    end

    local animation = CCAnimation:createWithSpriteFrames(array, animInfo.frameSecond)
    local displaySprite = display.newSprite()
    local scale = animInfo.frameScale or 1
    displaySprite:setAnchorPoint(cc.p(0.5, 0.5))
    displaySprite:setScale(scale)
    displaySprite:setPosition(animInfo.x, animInfo.y)
    self.resourceNode:addChild(displaySprite, LAYER_ID_ANIM)

    local action = CCAnimate:create(animation)
    local function doRemove()
        self.resourceNode:removeChild(displaySprite)
        if callback then
            callback()
        end
    end

    local rmCall = CCCallFunc:create(function() doRemove() end)
    local delay = CCDelayTime:create(animInfo.delaySecond)
    local fadeOut = CCFadeOut:create(animInfo.fadeoutSecond)

    local arrayCCSequence = { }
    table.insert(arrayCCSequence,action)
    table.insert(arrayCCSequence,delay)
    table.insert(arrayCCSequence, fadeOut)
    table.insert(arrayCCSequence, rmCall)

    displaySprite:runAction(CCSequence:create(arrayCCSequence))
end
--[[--
        获取其它家手牌显示信息
        @param pos:玩家位置
        @param zCoords:显示优先级
  ]]
function C:getOtherTileShowInfo(pos, zCoords)
    if self.mahjongTable_ then
        return self.mahjongTable_:getPlayerMahjongInfo(pos, zCoords)
    end
end
function C:RefreshReconnect(remainTime)
    self:refreshOperate(1)

    for i=1,PLAYER_COUNT do
        self.players[i].scoreLabel:setVisible(true)
        self.players[i].nameLabel:setVisible(true)
        self.players[i].headNode:setPosition(self.players[i].headEndPos)
		self.players[i].headNode:setVisible(true)
    end

    self:showTimer()
    self.bottomNode:setVisible(true)
    self:showLeftCard(self.model.leftCardNum)
    self:refreshTimer(not self.model:isMyTurn(), remainTime, nil)
end
function C:showOtherUserTiles(seat,winSeat, otherTiles, huTile, winFlag)
    local pos = self.model:getLocalSeat(seat)
    if winSeat and seat == winSeat then
        self.otherUserTiles_[pos]:setHuTile(huTile)
    end
    self.otherUserTiles_[pos]:setPlayerTiles(otherTiles, winFlag)
end

--移除其它家手牌显示图片
function C:removeAllOtherTileImg(pos)
    if self.mahjongTable_ then
        return self.mahjongTable_:removeAllOtherTileImg(pos)
    end
end
function C:removeAllOtherHandImg(pos)
    if self.mahjongTable_ then
        return self.mahjongTable_:removeAllOtherHandImg(pos)
    end
end
function C:addOtherTileImg(pos, img)
    if self.mahjongTable_ then
        return self.mahjongTable_:addOtherTileImg(pos, img)
    end
end

-- 获取自家牌池牌张显示信息
function C:getDiscardTileShowInfo(discardPos, discardIndex)
    if self.mahjongTable_ then
        return self.mahjongTable_:getDiscardTileInfo(discardPos, discardIndex)
    end
end

function C:getDiscardTileImg(pos)
    if self.mahjongTable_ then
        return self.mahjongTable_:getDiscardTileImg(pos)
    end
end

function C:addDiscardTileImg(pos, img)
    if self.mahjongTable_ then
        return self.mahjongTable_:addDiscardTileImg(pos, img)
    end
end
--endregion

return C