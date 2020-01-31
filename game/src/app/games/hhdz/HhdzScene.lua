local PlayerClass = import(".HhdzPlayerView")
local ChipsView = import(".HhdzChipsView")
local CardsView = import(".HhdzCardsView")
local PlayerListView = import(".HhdzPlayerListView")
local ZoushiLayer = import(".HhdzZoushiLayer")

local C = class("HhdzScene", GameSceneBase)

local scheduler = cc.Director:getInstance():getScheduler()

local CENTER = cc.p(display.cx, display.cy)

local MAX_TREND_POINT_NUM = 20
local MAX_TREND_TYPE_NUM = 7

local TREND_LAYER_WIDTH = 640
local TREND_LAYER_HEIGHT = 65

local TREND_POINT_START_POSX = 32
local TREND_POINT_GAPX = 26
local TREND_POINT_POSY = TREND_LAYER_HEIGHT - 10 - 6

local TREND_TYPE_START_POSX = 42
local TREND_TYPE_GAPX = 78.6
local TREND_TYPE_POSY = 20

local WAITING_CSB = GAME_HHDZ_PREFAB_RES .. "GameWaiting.csb"
local ANIM_LIGHT_CSB = GAME_HHDZ_PREFAB_RES .. "AnimLight.csb"
local START_BET_CSB = GAME_HHDZ_PREFAB_RES .. "GameStart.csb"
local STOP_BET_CSB = GAME_HHDZ_PREFAB_RES .. "GameEnd.csb"

local ALERT_SOUND = GAME_HHDZ_SOUND_RES .. "alert.mp3"
local START_BET_SOUND = GAME_HHDZ_SOUND_RES .. "start.mp3"
local STOP_BET_SOUND = GAME_HHDZ_SOUND_RES .. "stop.mp3"
local STOP_BET_ANIM_SOUND = GAME_HHDZ_SOUND_RES .. "show.mp3"
local COUNTDOWN_SOUND = GAME_HHDZ_SOUND_RES .. "countdown.mp3"

-- 资源名
C.RESOURCE_FILENAME = "games/hhdz/HhdzScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
    --测试按钮
    topBg = { path = "top_panel.bg_img" },
    --返回按钮
    backBtn = { path = "top_panel.back_btn", events = { { event = "click", method = "onBack" } } },
    --电池
    batteryNode = { path = "top_panel.battery_node" },
    --帮助按钮
    helpBtn = { path = "top_panel.help_btn", events = { { event = "click", method = "onHelp" } } },
    --设置页面
    settingsBtn = { path = "top_panel.settings_btn", events = { { event = "click", method = "onSettings" } } },

    --下注区
    myBlackBetLabel = { path = "bets_panel.my_black.bet_label" },
    myRedBetLabel = { path = "bets_panel.my_red.bet_label" },
    myLuckyBetLabel = { path = "bets_panel.my_lucky.bet_label" },
    myBlackBetNode = { path = "bets_panel.my_black" },
    myRedBetNode = { path = "bets_panel.my_red" },
    myLuckyBetNode = { path = "bets_panel.my_lucky" },
    allBlackBetLabel = { path = "bets_panel.all_black.label" },
    allRedBetLabel = { path = "bets_panel.all_red.label" },
    allLuckyBetLabel = { path = "bets_panel.all_lucky.label" },
    blackWinBlinkImg = { path = "bets_panel.black_win_img" },
    redWinBlinkImg = { path = "bets_panel.red_win_img" },
    luckyWinBlinkImg = { path = "bets_panel.lucky_win_img" },
    luckyStarNode = { path = "bets_panel.lucky_star_node" },

    --下注按钮
    bet1Btn = { path = "bottom_panel.bet_btn_1", events = { { event = "click", method = "onSelectBet1" } } },
    bet2Btn = { path = "bottom_panel.bet_btn_2", events = { { event = "click", method = "onSelectBet2" } } },
    bet3Btn = { path = "bottom_panel.bet_btn_3", events = { { event = "click", method = "onSelectBet3" } } },
    bet4Btn = { path = "bottom_panel.bet_btn_4", events = { { event = "click", method = "onSelectBet4" } } },
    bet5Btn = { path = "bottom_panel.bet_btn_5", events = { { event = "click", method = "onSelectBet5" } } },
    bet1Label = { path = "bottom_panel.bet_btn_1.label" },
    bet2Label = { path = "bottom_panel.bet_btn_2.label" },
    bet3Label = { path = "bottom_panel.bet_btn_3.label" },
    bet4Label = { path = "bottom_panel.bet_btn_4.label" },
    bet5Label = { path = "bottom_panel.bet_btn_5.label" },
    bet1SelectImg = { path = "bottom_panel.bet_btn_1.selected" },
    bet2SelectImg = { path = "bottom_panel.bet_btn_2.selected" },
    bet3SelectImg = { path = "bottom_panel.bet_btn_3.selected" },
    bet4SelectImg = { path = "bottom_panel.bet_btn_4.selected" },
    bet5SelectImg = { path = "bottom_panel.bet_btn_5.selected" },
    noticeImg = { path = "bottom_panel.noticeImg" },

    xuyaBtn = { path = "bottom_panel.xuya_btn", events = { { event = "click", method = "onXuYa" } } },

    --走势图
    trendPanel = { path = "trend_panel" },
    trendBtn = { path = "trend_panel.trend_btn", events = { { event = "click", method = "onClickTrendBtn" } } },

    --下注时间
    betTimerNode = { path = "bet_timer" },
    betTimerLabel = { path = "bet_timer.label" },

    --自己的信息
    selfPlayerNode = { path = "bottom_panel.me_info" },

    --筹码
    chipPanel = { path = "chip_panel" },

    --全局特效
    globalEffectNode = { path = "global_effect_panel" },

    --充值按钮
    rechargeBtn = { path = "bottom_panel.recharge_btn", events = { { event = "click", method = "onRecharge" } } },
    otherPlayersBtn = { path = "bottom_panel.online_btn", events = { { event = "click", method = "onOtherPlayers" } } },

    --游戏开始
    gameStartEffectNode = { path = "game_start_panel" },
    --游戏结束
    gameEndEffectNode = { path = "game_end_panel" },
    --等待下一局开始
    gameWaitPanel = { path = "game_wait_panel" },
    --扑克牌
    cardsNode = { path = "cards_panel" },
}

C.bets = {}
C.players = nil
C.selfPalyer = nil
C.betValues = nil
C.cardsView = nil
C.playChipSound = true
C.zoushiLayer = nil
C.lastRequestPlayerListTime = 0
C.isOnlineShaking = false

function C:ctor(core)
    --玩家,第六个玩家是【神算子】
    for i = 1, 6 do
        local key = string.format("player%d", i)
        local path = string.format("player_panel.player_%d", i)
        self.RESOURCE_BINDING[key] = { path = path }
    end

    C.super.ctor(self, core)
end

--加载资源
function C:loadResource()
    C.super.loadResource(self)
    --加载plist图集
    display.loadSpriteFrames(GAME_HHDZ_IMAGES_RES .. "card.plist", GAME_HHDZ_IMAGES_RES .. "card.png")
    display.loadSpriteFrames(GAME_HHDZ_IMAGES_RES .. "chip.plist", GAME_HHDZ_IMAGES_RES .. "chip.png")
    display.loadSpriteFrames(GAME_HHDZ_IMAGES_RES .. "trend.plist", GAME_HHDZ_IMAGES_RES .. "trend.png")
    display.loadSpriteFrames(GAME_HHDZ_IMAGES_RES .. "lzt_bg.plist", GAME_HHDZ_IMAGES_RES .. "lzt_bg.png")
    display.loadSpriteFrames(GAME_HHDZ_IMAGES_RES .. "lzt_item.plist", GAME_HHDZ_IMAGES_RES .. "lzt_item.png")
    display.loadSpriteFrames(GAME_HHDZ_IMAGES_RES .. "winner_area.plist", GAME_HHDZ_IMAGES_RES .. "winner_area.png")
end

--卸载资源
function C:unloadResource()
    display.removeSpriteFrames(GAME_HHDZ_IMAGES_RES .. "card.plist", GAME_HHDZ_IMAGES_RES .. "card.png")
    display.removeSpriteFrames(GAME_HHDZ_IMAGES_RES .. "chip.plist", GAME_HHDZ_IMAGES_RES .. "chip.png")
    display.removeSpriteFrames(GAME_HHDZ_IMAGES_RES .. "trend.plist", GAME_HHDZ_IMAGES_RES .. "trend.png")
    display.removeSpriteFrames(GAME_HHDZ_IMAGES_RES .. "lzt_bg.plist", GAME_HHDZ_IMAGES_RES .. "lzt_bg.png")
    display.removeSpriteFrames(GAME_HHDZ_IMAGES_RES .. "lzt_item.plist", GAME_HHDZ_IMAGES_RES .. "lzt_item.png")
    display.removeSpriteFrames(GAME_HHDZ_IMAGES_RES .. "winner_area.plist", GAME_HHDZ_IMAGES_RES .. "winner_area.png")
    C.super.unloadResource(self)
end

function C:initialize()
    C.super.initialize(self)
    --适配宽屏
    self:adjustUI(self.topBg, { self.backBtn, self.batteryNode }, { self.helpBtn, self.settingsBtn })
    --充值按钮
    self:playRechargeAni()
    --绑定电池节点
    self:bindBatteryNode(self.batteryNode)
    self:updateBattery()

    --初始化下注按钮
    for i = 1, 5 do
        self.bets[i] =         {
            btn = self["bet" .. i .. "Btn"],
            sel = self["bet" .. i .. "SelectImg"],
            label = self["bet" .. i .. "Label"],
            pos = cc.p(self["bet" .. i .. "Btn"]:getPosition())
        }
    end

    --初始化玩家，第六个玩家是【神算子】
    self.players = {}
    for i = 1, 6 do
        local key = string.format("player%d", i)
        local p = self[key]

        local player = PlayerClass.new(p, i, self.globalEffectNode)
        player:hide()
        self.players[i] = player
    end

    self.selfPalyer = PlayerClass.new(self.selfPlayerNode, 0, self.globalEffectNode)
    self.selfPalyer:show(self.model.myInfo)
    self.players[7] = self.selfPalyer

    --扑克牌
    self.cardsView = CardsView.new(self.cardsNode)

    --玩家列表
    self.playerListView = PlayerListView.new()
    self.playerListView:retain()

    self.betTimerNode:setPositionY(self.betTimerNode:getPositionY() + 10)
    self:clean()
end

function C:onEnterTransitionFinish()
    C.super.onEnterTransitionFinish(self)
    PLAY_MUSIC(GAME_HHDZ_SOUND_RES .. "bg.mp3")

    self.zoushiLayer = ZoushiLayer.new()
    self.zoushiLayer:retain()
end

function C:onExitTransitionStart()
    self:clean()
    if self.playerListView then
        self.playerListView:release()
    end
    if self.zoushiLayer then
        self.zoushiLayer:release()
    end
    C.super.onExitTransitionStart(self)
end

--充值动画
function C:playRechargeAni()
    if self.rechargeBtn then
        utils:createTimer("hhdz.rechargea.ani", 8, function()
            local array = {}
            array[#array + 1] = cc.ScaleTo:create(0.2, 1.2) --0.2秒由最小到最大
            array[#array + 1] = cc.ScaleTo:create(0.1, 0.9) --0.1秒由最大到第二小
            array[#array + 1] = cc.ScaleTo:create(0.1, 1.1) --0.1秒由第二小到第二大
            array[#array + 1] = cc.ScaleTo:create(0.1, 1) --0.1秒由第二大到正常
            local action = transition.sequence(array)
            self.rechargeBtn:runAction(action)
        end)
    end
end

function C:clean()
    self:setMyBlackBet(0)
    self:setMyRedBet(0)
    self:setMyLuckyBet(0)
    self:stopTimer()
    self.blackWinBlinkImg:setVisible(false)
    self.redWinBlinkImg:setVisible(false)
    self.luckyWinBlinkImg:setVisible(false)
    self.noticeImg:setVisible(false)

    for k, v in pairs(self.players) do
        v:clean()
    end

    self.cardsView:clean()
    if self.chipsView then
        self.chipsView:cleanAll()
        self.chipsView:destroy()
        self.chipsView = nil
    end

    if self.zoushiLayer then
        self.zoushiLayer:hideSelf()
    end
    self:enableXuYaButton(false)
end

function C:delayInvoke(time, callback)
    local act = transition.sequence({
        CCDelayTime:create(time),
        CCCallFunc:create(callback)
    })
    self:runAction(act)
end

--region UI Event
--点击返回按钮
function C:onBack(event)
    printInfo("点击了返回")
    self:touchBack("您当前已投注，不能退出游戏！")
    -- self:touchBack("您当前已投注，退出游戏系统会自动帮您托管，不影响金币结算，确定退出游戏吗？")
end

--点击帮助按钮
function C:onHelp(event)
    self:showRule()
end

--点击设置按钮
function C:onSettings(event)
    self:showSettings()
end

--选择押注按钮1
function C:onSelectBet1(event)
    self:selectBetButton(1, true)
    self.model.lastSelectedBet = 1
end

--选择押注按钮2
function C:onSelectBet2(event)
    self:selectBetButton(2, true)
    self.model.lastSelectedBet = 2
end

--选择押注按钮3
function C:onSelectBet3(event)
    self:selectBetButton(3, true)
    self.model.lastSelectedBet = 3
end

--选择押注按钮4
function C:onSelectBet4(event)
    self:selectBetButton(4, true)
    self.model.lastSelectedBet = 4
end

--选择押注按钮5
function C:onSelectBet5(event)
    self:selectBetButton(5, true)
    self.model.lastSelectedBet = 5
end

--点击续押按钮
function C:onXuYa(event)
    -- self.core:xuya()
    self.model.canAddLastBet = false
    self:enableXuYaButton(false)
end

--押注黑方
function C:onBlackBet(event)
    self.core:blackBet()
    self.model.canAddLastBet = false
    self:enableXuYaButton(false)
end

--押注红方
function C:onRedBet(event)
    self.core:redBet()
    self.model.canAddLastBet = false
    self:enableXuYaButton(false)
end

--押注幸运一击
function C:onLuckyBet(event)
    self.core:luckyBet()
    self.model.canAddLastBet = false
    self:enableXuYaButton(false)
end

--充值
function C:onRecharge(event)
    self:touchRecharge()
end

--其他玩家
function C:onOtherPlayers(event)
    local nowTime = os.time()
    if nowTime - self.lastRequestPlayerListTime >= 30 then
        self.core:c2sPlayerList()
    end
    self.playerListView:show()
end

--点击走势按钮
function C:onClickTrendBtn(event)
    self.zoushiLayer:show()
end

function C:reloadHistory(dataArr, typeArr)
    self.zoushiLayer:clean()
    self.zoushiLayer:refreshHistory(dataArr, typeArr)
end

function C:addHistory(data, ctype)
    self.zoushiLayer:addHistory(data, ctype)
end

--endregion
--region API
--显示等待下一局
function C:showWaiting()
    self:playEffect(WAITING_CSB, nil, 0, self.gameWaitPanel, CENTER, true, true)
end

--隐藏等待下一局
function C:hideWaiting()
    if self.effectAnims and self.effectAnims[WAITING_CSB] then
        self.effectAnims[WAITING_CSB]:setVisible(false)
    end
end

--设置金币
function C:setMoney(seat, money)
    self.players[seat]:setMoney(money)
    if seat == 7 then
        return
    end
    --自己金币
    if self.players[seat].playerInfo and
    self.players[7].playerInfo and
    self.players[seat].playerInfo["playerid"] == self.players[7].playerInfo["playerid"] then
        self.players[7]:setMoney(money)
    end
end

--设置我的黑方下注
function C:setMyBlackBet(bet)
    if tonumber(bet) > 0 then
        self.myBlackBetLabel:setString(tostring(bet))
        self.myBlackBetNode:setVisible(true)
    else
        self.myBlackBetNode:setVisible(false)
    end
end

--设置我的红方下注
function C:setMyRedBet(bet)
    if tonumber(bet) > 0 then
        self.myRedBetLabel:setString(tostring(bet))
        self.myRedBetNode:setVisible(true)
    else
        self.myRedBetNode:setVisible(false)
    end
end

--设置我的幸运一击下注
function C:setMyLuckyBet(bet)
    if tonumber(bet) > 0 then
        self.myLuckyBetLabel:setString(tostring(bet))
        self.myLuckyBetNode:setVisible(true)
    else
        self.myLuckyBetNode:setVisible(false)
    end
end

--设置黑方总下注
function C:setAllBlackBet(bet)
    self.allBlackBetLabel:setString(tostring(bet))
end

--设置红方总下注
function C:setAllRedBet(bet)
    self.allRedBetLabel:setString(tostring(bet))
end

--设置幸运一击总下注
function C:setAllLuckyBet(bet)
    self.allLuckyBetLabel:setString(tostring(bet))
end

--设置下注按钮数值
function C:setBetValues(values)
    for k, v in ipairs(values) do
        self.bets[k].label:setString(v)
    end
    self.betValues = values
    if not self.chipsView then
        self.chipsView = ChipsView.new(self.chipPanel, values, self.luckyStarNode)
        self.chipsView.onBlackBetHandler = handler(self, self.onBlackBet)
        self.chipsView.onRedBetHandler = handler(self, self.onRedBet)
        self.chipsView.onLuckyBetHandler = handler(self, self.onLuckyBet)
    end
end

--选择按钮
function C:selectBetButton(index, anim)
    self.model.currentBet = index
    for i = 1, 5 do
        if anim then
            if i == index then
                if not self.bets[i].sel:isVisible() then
                    self.bets[i].sel:setVisible(true)
                    local move = CCMoveTo:create(0.1, cc.p(self.bets[i].pos.x, self.bets[i].pos.y + 10))
                    self.bets[i].btn:runAction(move)
                end
            else
                if self.bets[i].sel:isVisible() then
                    self.bets[i].sel:setVisible(false)
                    local move = CCMoveTo:create(0.1, cc.p(self.bets[i].pos.x, self.bets[i].pos.y))
                    self.bets[i].btn:runAction(move)
                end
            end
        else
            self.bets[i].sel:setVisible(i == index)
            self.bets[i].btn:setPositionY(self.bets[i].pos.y + (i == index and 10 or 0))
        end
    end
end

--启用/禁用按钮
function C:enableBetButton(index, enable)
    self.bets[index].btn:setEnabled(enable)
    self.bets[index].btn:setOpacity(enable and 255 or 128)
    if not enable then
        self.bets[index].sel:setVisible(false)
        self.bets[index].btn:setPositionY(self.bets[index].pos.y)
    end

    --toastLayer:show("金币多于" .. self.model.needMoney .. "才能下注哟！",2)
    --self.noticeImg:setVisible(self.model.myInfo.money < self.model.needMoney)
end

--启用/禁用续押按钮
function C:enableXuYaButton(enable)
    -- self.xuyaBtn:setEnabled(enable)
    -- self.xuyaBtn:setEnabled(false)
    self.xuyaBtn:setVisible(false)
end

--禁用所有按钮
function C:disableAllButtons()
    for i = 1, 5 do
        self:enableBetButton(i, false)
    end
    self:enableXuYaButton(false)
end

--开始定时器
function C:startTimer(time, callback)
    if not time or time <= 0 then
        self:stopTimer()
        if callback then
            callback()
        end
        return
    end
    -- 少于50img
    --toastLayer:show("金币多于" .. self.model.needMoney .. "才能下注哟！",2)
    if self.model.needMoney > self.model.myInfo.money then
        toastLayer:show("金币多于" .. self.model.needMoney / MONEY_SCALE .. "才能下注哟！", 2)
    end
    --self.noticeImg:setVisible(self.model.myInfo.money < self.model.needMoney)
    self:removeClockHandler();
    self.betTimerNode:setVisible(true)
    local leftTime = math.floor(time);
    self.betTimerLabel:setString(tostring(leftTime));
    self.countDownHandler = scheduler:scheduleScriptFunc(function()
        leftTime = leftTime - 1;
        if leftTime <= 0 then
            if callback then
                callback()
            end
            self.betTimerNode:setVisible(false)
            self:removeClockHandler();
            -- self:disableAllButtons()
        else
            self.betTimerLabel:setString(tostring(leftTime));
            if leftTime <= 5 then
                PLAY_SOUND(COUNTDOWN_SOUND)
            end
        end
    end, 1, false);
end

--移除定时器回调
function C:removeClockHandler()
    if self.countDownHandler then
        scheduler:unscheduleScriptEntry(self.countDownHandler)
        self.countDownHandler = nil;
    end
end

--停止定时器
function C:stopTimer()
    self:removeClockHandler()
    self.betTimerNode:setVisible(false)
end

--创建走势图小圆点
function C:createTrendPoint(winner)
    local res = { "red_point", "black_point" }

    if res[winner] then
        return display.newSprite("#" .. res[winner] .. ".png")
    end

    return nil
end

--创建走势图牌型
function C:createTrendTypeSp(cardType)
    local resD = { "single_d", "double_d", "straight_d", "flower_d", "straight_flower_d", "bomb_d" }
    local resL = { "single_l", "double_l", "straight_l", "flower_l", "straight_flower_l", "bomb_l" }
    local res = resL

    if cardType == self.core.define.cardType.Single then
        res = resD
    end

    if cardType == self.core.define.cardType.Pair then
        -- res = resD
        cardType = 2
    end

    if res[cardType] then
        return display.newSprite("#" .. res[cardType] .. ".png")
    end

    return nil
end

--创建走势图
function C:createTrend()
    if self.trendLayer then
        self.trendLayer:removeFromParent(true)
        self.trendLayer = nil
    end

    self.trendPoints = {}
    self.trendTypes = {}

    self.trendLayer = display.newLayer()
    self.trendLayer:setContentSize(cc.size(TREND_LAYER_WIDTH, TREND_LAYER_HEIGHT))
    self.trendLayer:setPosition(cc.p(568 - TREND_LAYER_WIDTH / 2 + 2, display.top - 168))
    self.trendLayer:addTo(self.trendPanel)

    -- batch
    self.trendBatch = CCSpriteBatchNode:create(GAME_HHDZ_IMAGES_RES .. "trend.png")
    self.trendBatch:addTo(self.trendLayer)

    local trendCount = self.logic:getTrendVecCount()

    -- point
    local pointStartIndex = trendCount > MAX_TREND_POINT_NUM and (trendCount - MAX_TREND_POINT_NUM + 1) or 1
    local pointEndIndex = trendCount
    local pointCurIndex = 1

    for i = pointStartIndex, pointEndIndex do
        local trend = self.logic:getTrendByIndex(i)

        if trend then
            local point = self:createTrendPoint(trend.winner)

            if point then
                point:setPosition(cc.p(TREND_POINT_START_POSX + TREND_POINT_GAPX * (pointCurIndex - 1), TREND_POINT_POSY))
                point:addTo(self.trendBatch)

                table.insert(self.trendPoints, point)
                pointCurIndex = pointCurIndex + 1
            end
        end
    end

    -- type
    local typeStartIndex = trendCount > MAX_TREND_TYPE_NUM and (trendCount - MAX_TREND_TYPE_NUM + 1) or 1
    local typeEndIndex = trendCount
    local typeCurIndex = 1

    for i = typeStartIndex, typeEndIndex do
        local trend = self.logic:getTrendByIndex(i)

        if trend then
            local typeSp = self:createTrendTypeSp(trend.cardType)

            if typeSp then
                typeSp:setPosition(cc.p(TREND_TYPE_START_POSX + TREND_TYPE_GAPX * (typeCurIndex - 1), TREND_TYPE_POSY))
                typeSp:addTo(self.trendBatch)

                table.insert(self.trendTypes, typeSp)
                typeCurIndex = typeCurIndex + 1
            end
        end
    end
end

--更新历史纪录
function C:updateTrend()
    if self.trendPoints and type(self.trendPoints) == "table" then
        if #self.trendPoints == MAX_TREND_POINT_NUM then
            local point = self.trendPoints[1]

            local fadeOut = CCFadeOut:create(0.2)
            local callfun = CCCallFunc:create(function()
                point:removeFromParent(true)
                table.remove(self.trendPoints, 1)
                self:addAndMoveTrendPoints(true)
            end)

            point:runAction(transition.sequence({ fadeOut, callfun }))
        else
            self:addAndMoveTrendPoints(false)
        end
    end

    if self.trendTypes and type(self.trendTypes) == "table" then
        if #self.trendTypes == MAX_TREND_TYPE_NUM then
            local typeSp = self.trendTypes[1]

            local fadeOut = CCFadeOut:create(0.2)
            local callfun = CCCallFunc:create(function()
                typeSp:removeFromParent(true)
                table.remove(self.trendTypes, 1)
                self:addAndMoveTrendTypes(true)
            end)

            typeSp:runAction(transition.sequence({ fadeOut, callfun }))
        else
            self:addAndMoveTrendTypes(false)
        end
    end

    --通知走势图
    --self.trendLayer:onEventNotify()
end

--新增输赢记录
function C:addAndMoveTrendPoints(needMove)
    if self.trendPoints and type(self.trendPoints) == "table" then
        local trend = self.logic:getLastTrend()
        local lastPoint = self.trendPoints[#self.trendPoints]

        local point = self:createTrendPoint(trend.winner)

        if point then
            point:addTo(self.trendBatch)

            if lastPoint then
                point:setPosition(cc.p(lastPoint:getPositionX() + TREND_POINT_GAPX, lastPoint:getPositionY()))
            else
                point:setPosition(TREND_POINT_START_POSX, TREND_POINT_POSY)
            end

            table.insert(self.trendPoints, point)
        end

        if needMove then
            for i, v in ipairs(self.trendPoints) do
                local move = CCMoveTo:create(0.1, cc.p(v:getPositionX() - TREND_POINT_GAPX, v:getPositionY()))
                local spawn = nil

                if i == #self.trendPoints then
                    v:setOpacity(0)
                    local fadeIn = CCFadeIn:create(0.03)
                    spawn = transition.sequence({ move, fadeIn })
                else
                    spawn = transition.spawn({ move })
                end

                v:runAction(spawn)
            end
        end
    end
end

--新增牌型记录
function C:addAndMoveTrendTypes(needMove)
    if self.trendTypes and type(self.trendTypes) == "table" then
        local trend = self.logic:getLastTrend()
        local lastTypeSp = self.trendTypes[#self.trendTypes]

        local typeSp = self:createTrendTypeSp(trend.cardType)

        if typeSp then
            typeSp:addTo(self.trendBatch)

            if lastTypeSp then
                typeSp:setPosition(cc.p(lastTypeSp:getPositionX() + TREND_TYPE_GAPX, lastTypeSp:getPositionY()))
            else
                typeSp:setPosition(cc.p(TREND_TYPE_START_POSX, TREND_TYPE_POSY))
            end

            table.insert(self.trendTypes, typeSp)
        end

        if needMove then
            for i, v in ipairs(self.trendTypes) do
                local move = CCMoveTo:create(0.1, cc.p(v:getPositionX() - TREND_TYPE_GAPX, v:getPositionY()))
                local spawn = nil

                if i == #self.trendTypes then
                    v:setOpacity(0)
                    local fadeIn = CCFadeIn:create(0.03)
                    spawn = transition.sequence({ move, fadeIn })
                else
                    spawn = transition.spawn({ move })
                end

                v:runAction(spawn)
            end
        end
    end
end


--显示玩家
function C:showPlayer(seat, info)
    self.players[seat]:show(info)
end

--隐藏玩家
function C:hidePlayer(seat)
    self.players[seat]:hide()
end

--播放输赢金币特效
function C:playResultEffect(seat, money)
    if seat < 0 or seat > 7 then return end
    self.players[seat]:playResultEffect(money)
end

--黑方中奖区闪烁
function C:showBlackWinBlink(callback)
    self:winAreaBlink(self.blackWinBlinkImg, callback)
end

--红方中奖区闪烁
function C:showRedWinBlink(callback)
    self:winAreaBlink(self.redWinBlinkImg, callback)
end

--特殊牌中奖区闪烁
function C:showLuckyWinBlink(callback)
    self:winAreaBlink(self.luckyWinBlinkImg, callback)
end

--中奖区域闪烁
function C:winAreaBlink(area, callback)
    area:setVisible(true)
    local fadeIn = CCFadeIn:create(0.5)
    local fadeOut = CCFadeOut:create(0.5)
    local callFun = CCCallFunc:create(function()
        area:setVisible(false)
        if callback then
            callback()
        end
    end)
    local seq = transition.sequence({ fadeIn, fadeOut })
    local rep = CCRepeat:create(seq, 2)

    area:runAction(transition.sequence({ rep, callFun }))
end

--在线玩家甩头
function C:onlineShakeHead()
    if self.isOnlineShaking == false then
        self.isOnlineShaking = true
        local posX = self.otherPlayersBtn:getPositionX()
        local posY = self.otherPlayersBtn:getPositionY()
        local move1 = CCMoveTo:create(0.04, cc.p(posX - 20, posY + 20))
        local move2 = CCMoveTo:create(0.04, cc.p(posX, posY))
        local delay = CCDelayTime:create(0.02)
        local callFun = CCCallFunc:create(function()
            self.isOnlineShaking = false
        end)
        self.otherPlayersBtn:runAction(transition.sequence({ move1, move2, delay, callFun }))
    end
end

--玩家丢筹码
function C:throwChip(seat, betType, betIndex, isAnim, isDesk)
    local randPos = self.chipsView:getChipFinalPos(betType)
    local callback = nil
    if seat == 8 and isAnim then
        callback = function()
            self:onlineShakeHead()
        end
    end
    if seat > 0 and seat < 8 and isAnim then
        self.players[seat]:shakeHead()
    end
    self.chipsView:chipGo(seat, betIndex, randPos, isAnim, isDesk, isAnim and self.playChipSound, callback)

    if self.playChipSound then
        self.playChipSound = false
        self:delayInvoke(0.5, function() self.playChipSound = true end)
    end
end

--玩家获得筹码
function C:getChips(numberSeats, chipSeats)
    self.chipsView:chipsBack(chipSeats, function()
        for k, v in pairs(numberSeats) do
            self:playResultEffect(v.seat, v.money)
        end
    end)
end

--神算子下注星星
function C:flyLuckyStar(betType, isAnim)
    self.chipsView:flyLuckyStar(betType, isAnim)
end

--清理筹码
function C:cleanChips()
    self.chipsView:cleanChips()
end

--播放VS动画
function C:playerVsAnim(callBack)
    local node = display.newNode()
    node:addTo(self.gameStartEffectNode)

    -- 背景
    local offsetX = (display.width - 1136) / 2
    local layer = display.newLayer(cc.c4b(0, 0, 0, 153))
    layer:setPositionX(-offsetX)
    layer:addTo(node)

    -- 黑色横幅
    local black = display.newSprite(GAME_HHDZ_IMAGES_RES .. "anim_black.png")
    black:setOpacity(0)
    black:setPosition(cc.p(568 - 235, display.cy))
    black:addTo(node)

    local blackDelay1 = CCDelayTime:create(0.02)
    local blackFadeIn = CCFadeIn:create(0.06)
    local blackMoveIn = CCMoveTo:create(0.06, cc.p(568 - 95, display.cy))
    local blackDelay2 = CCDelayTime:create(0.05)
    local blackMoveOut1 = CCMoveTo:create(0.05, cc.p(568 - 135, display.cy))
    local blackDelay3 = CCDelayTime:create(1)
    local blackMoveOut2 = CCMoveTo:create(0.05, cc.p(568 - 205, display.cy))
    local blackFadeOut = CCFadeOut:create(0.05)
    local blackSpawnIn = transition.spawn({ blackFadeIn, blackMoveIn })
    local blackSpawnOut = transition.spawn({ blackMoveOut2, blackFadeOut })

    local balckSeq = transition.sequence({ blackDelay1, blackSpawnIn, blackDelay2, blackMoveOut1, blackDelay3, blackSpawnOut })
    black:runAction(balckSeq)

    -- 红色横幅
    local red = display.newSprite(GAME_HHDZ_IMAGES_RES .. "anim_red.png")
    red:setOpacity(0)
    red:setPosition(cc.p(568 + 235, display.cy))
    red:addTo(node)

    local redDelay1 = CCDelayTime:create(0.02)
    local redFadeIn = CCFadeIn:create(0.06)
    local redMoveIn = CCMoveTo:create(0.06, cc.p(568 + 95, display.cy))
    local redDelay2 = CCDelayTime:create(0.05)
    local redMoveOut1 = CCMoveTo:create(0.05, cc.p(568 + 135, display.cy))
    local redDelay3 = CCDelayTime:create(1)
    local redMoveOut2 = CCMoveTo:create(0.05, cc.p(568 + 205, display.cy))
    local redFadeOut = CCFadeOut:create(0.05)
    local redSpawnIn = transition.spawn({ redFadeIn, redMoveIn })
    local redSpawnOut = transition.spawn({ redMoveOut2, redFadeOut })

    local redSeq = transition.sequence({ redDelay1, redSpawnIn, redDelay2, redMoveOut1, redDelay3, redSpawnOut })
    red:runAction(redSeq)

    -- 国王
    local king = display.newSprite(GAME_HHDZ_IMAGES_RES .. "anim_king.png")
    king:setScale(0.6)
    king:setOpacity(0)
    king:setPosition(cc.p(568 - 310, display.cy + 60))
    king:addTo(node)

    local kingDelay1 = CCDelayTime:create(0.02)
    local kingFadeIn = CCFadeIn:create(0.06)
    local kingScaleIn = CCScaleTo:create(0.06, 1, 1)
    local kingMoveIn = CCMoveTo:create(0.06, cc.p(568 - 180, display.cy + 65))
    local kingMoveOut1 = CCMoveTo:create(0.08, cc.p(568 - 210, display.cy + 65))
    local kingDelay2 = CCDelayTime:create(1.02)
    local kingMoveOut2 = CCMoveTo:create(0.05, cc.p(568 - 290, display.cy + 65))
    local kingFadeOut = CCFadeOut:create(0.05)
    local kingSpawnIn = transition.spawn({ kingFadeIn, kingScaleIn, kingMoveIn })
    local kingSpawnOut = transition.spawn({ kingMoveOut2, kingFadeOut })

    local kingSeq = transition.sequence({ kingDelay1, kingSpawnIn, kingMoveOut1, kingDelay2, kingSpawnOut })
    king:runAction(kingSeq)

    -- 皇后
    local queen = display.newSprite(GAME_HHDZ_IMAGES_RES .. "anim_queen.png")
    queen:setScale(0.6)
    queen:setOpacity(0)
    queen:setPosition(cc.p(568 + 325, display.cy + 60))
    queen:addTo(node)

    local queenDelay1 = CCDelayTime:create(0.02)
    local queenFadeIn = CCFadeIn:create(0.06)
    local queenScaleIn = CCScaleTo:create(0.06, 1, 1)
    local queenMoveIn = CCMoveTo:create(0.06, cc.p(568 + 180, display.cy + 70))
    local queenMoveOut1 = CCMoveTo:create(0.08, cc.p(568 + 210, display.cy + 70))
    local queenDelay2 = CCDelayTime:create(1.02)
    local queenMoveOut2 = CCMoveTo:create(0.05, cc.p(568 + 300, display.cy + 70))
    local queenFadeOut = CCFadeOut:create(0.05)
    local queenSpawnIn = transition.spawn({ queenFadeIn, queenScaleIn, queenMoveIn })
    local queenSpawnOut = transition.spawn({ queenMoveOut2, queenFadeOut })

    local queenSeq = transition.sequence({ queenDelay1, queenSpawnIn, queenMoveOut1, queenDelay2, queenSpawnOut })
    queen:runAction(queenSeq)

    -- anim
    anim_light = cc.CSLoader:createNode(ANIM_LIGHT_CSB)
    anim_light_act = cc.CSLoader:createTimeline(ANIM_LIGHT_CSB)
    anim_light:setPosition(cc.p(568, display.cy))
    anim_light:addTo(node)
    anim_light:runAction(anim_light_act)
    anim_light_act:gotoFrameAndPlay(0, false)

    -- vs
    local vsIcon = display.newSprite(GAME_HHDZ_IMAGES_RES .. "anim_vs.png")
    vsIcon:setScale(0)
    vsIcon:setOpacity(0)
    vsIcon:setPosition(cc.p(568, display.cy))
    vsIcon:addTo(node)

    local vs_part1_delay = CCDelayTime:create(0.06)
    local vs_part1_fadeIn = CCFadeIn:create(0.03)
    local vs_part1_scale1 = CCScaleTo:create(0.03, 1.5, 1.5)

    local vs_part1_spawn = transition.spawn({ vs_part1_fadeIn, vs_part1_scale1 })
    local vs_part1_seq = transition.sequence({ vs_part1_delay, vs_part1_spawn })

    local vs_part2_delay = CCDelayTime:create(0.02)
    local vs_part2_scale2 = CCScaleTo:create(0.03, 1, 1)
    local vs_part2_move1 = CCMoveTo:create(0.03, cc.p(568 - 45, display.cy + 30))

    local vs_part2_spawn = transition.spawn({ vs_part2_scale2, vs_part2_move1 })
    local vs_part2_seq = transition.sequence({ vs_part2_delay, vs_part2_spawn })

    local vs_part3_move1 = CCMoveTo:create(0.03, cc.p(568, display.cy))
    local vs_part3_move2 = CCMoveTo:create(0.03, cc.p(568 + 45, display.cy + 30))
    local vs_part3_move3 = CCMoveTo:create(0.03, cc.p(568, display.cy))

    local vs_part3_seq = transition.sequence({ vs_part3_move1, vs_part3_move2, vs_part3_move3 })

    local vs_part4_delay = CCDelayTime:create(0.95)
    local vs_part4_scale = CCScaleTo:create(0.05, 0, 0)

    local vs_part4_seq = transition.sequence({ vs_part4_delay, vs_part4_scale })

    local vsSeq = transition.sequence({ vs_part1_seq, vs_part2_seq, vs_part3_seq, vs_part4_seq })
    vsIcon:runAction(vsSeq)

    -- node
    local nodeDelay1 = CCDelayTime:create(0.07)
    local nodeCallFun1 = CCCallFunc:create(function()
        node.starTail = CCParticleSystemQuad:create(GAME_HHDZ_ANIMATION_RES .. "star_tail.plist")
        node.starTail:setScale(8)
        node.starTail:setPosition(cc.p(568, display.cy))
        node.starTail:addTo(node)

        local starBomb = CCParticleSystemQuad:create(GAME_HHDZ_ANIMATION_RES .. "start_bomb.plist")
        starBomb:setAutoRemoveOnFinish(true)
        starBomb:setPosition(cc.p(568, display.cy))
        starBomb:addTo(node)

        PLAY_SOUND(ALERT_SOUND)
    end)
    local nodeDelay2 = CCDelayTime:create(0.04)
    local nodeCallFun2 = CCCallFunc:create(function()
        if node.starTail then
            node.starTail:removeFromParent(true)
            node.starTail = nil
        end
    end)
    local nodeDelay3 = CCDelayTime:create(1.12 + 0.5)
    local nodeCallFun3 = CCCallFunc:create(function()
        if callBack then
            callBack()
        end

        node:removeFromParent(true)
    end)

    local nodeSeq = transition.sequence({ nodeDelay1, nodeCallFun1, nodeDelay2, nodeCallFun2, nodeDelay3, nodeCallFun3 })
    node:runAction(nodeSeq)
end

--播放开始下注动画
function C:playStartBetAnim()
    self:playerVsAnim(function()
        self:playEffect(START_BET_CSB, START_BET_SOUND, 0, self.gameStartEffectNode, CENTER, true, false)
        self.cardsView:createCardsWithAnim(true)
        self.cardsView:createCardsWithAnim(false)
    end)
end

function C:createCards()
    self.cardsView:createCards(true)
    self.cardsView:createCards(false)
end

--播放停止下注动画
function C:playStopBetAnim()
    self:playSound(STOP_BET_SOUND, 0.1)
    return self:playEffect(STOP_BET_CSB, STOP_BET_ANIM_SOUND, 0, self.gameEndEffectNode, CENTER, true, false)
end

--开牌
function C:showCards(cardIds, cardTypes, time, callBack)
    self:cleanCards()
    self.cardsView:showCards(cardIds, cardTypes, time, callBack)
end

function C:cleanCards()
    self.cardsView:cleanCards()
end

function C:setPlayerList(list)
    dump(list)
    self.playerListView:setInfos(list)
    self.lastRequestPlayerListTime = os.time()
end
--endregion
--region 动画特效
--通用接口
function C:playEffect(anim, sound, soundDeley, parent, pos, worldSpace, loop)
    if self.effectAnims == nil then
        self.effectAnims = {}
    end
    if self.effectAnimActions == nil then
        self.effectAnimActions = {}
    end

    local ani = self.effectAnims[anim]
    local act = self.effectAnimActions[anim]

    if ani == nil or act == nil then
        ani = cc.CSLoader:createNode(anim)
        act = cc.CSLoader:createTimeline(anim)
        ani:runAction(act)
        self.effectAnims[anim] = ani
        self.effectAnimActions[anim] = act
    end

    ani:setVisible(true)

    if not parent then
        parent = self.node    
    end

    if ani:getParent() ~= parent then
        ani:addTo(parent)
    end

    if pos then
        local p = pos
        if worldSpace then
            p = parent:convertToNodeSpace(pos)
        end
        ani:setPosition(p)
    else
        ani:setPosition(cc.p(0, 0))
    end
    loop = loop or false
    act:gotoFrameAndPlay(0, loop)
    if sound then
        soundDeley = soundDeley or 0
        self:playSound(sound, soundDeley)
    end
    return act:getDuration() / 30
end

function C:playSound(sound, delay)
    local seq = transition.sequence({
        CCDelayTime:create(delay),
        CCCallFunc:create(function(...)
            PLAY_SOUND(sound)
        end)
    })
    self.resourceNode:runAction(seq)
end

--endregion
return C