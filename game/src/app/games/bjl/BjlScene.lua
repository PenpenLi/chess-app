--BjlScene.lua
--Date 2019-12-14 10:17:54
local ChipsView = import(".BjlChipsView")
local TrendMap = import(".BjlTrendMap")
local OPList = import(".BjlPlayersList")
local HelpLayer = import(".BjlHelpLayer")
local C = class("BjlScene", GameSceneBase)
local scheduler = cc.Director:getInstance():getScheduler()

--资源名
C.RESOURCE_FILENAME = "games/bjl/BjlScene.csb"
--资源绑定
C.RESOURCE_BINDING = {
    --返回按钮
    topBg = { path = "top_panel" },
    menu = { path = "top_panel.menu" },
    menuBtn = {
        path = "top_panel.menu_btn",
        events = { { event = "click", method = "ocMenuBtn" } }
    },
    backBtn = {
        path = "top_panel.menu.back_btn",
        events = { { event = "click", method = "onBack" } }
    },
    helpBtn = {
        path = "top_panel.menu.help_btn",
        events = { { event = "click", method = "showHelpLayer" } }
    },
    settingBtn = {
        path = "top_panel.menu.setting_btn",
        events = { { event = "click", method = "ocSetting" } }
    },
    --下注区
    myBankerBetLabel = { path = "bets_panel.my_banker.label" },
    myPlayerBetLabel = { path = "bets_panel.my_player.label" },
    myTieBetLabel = { path = "bets_panel.my_tie.label" },
    myBankerPairBetLabel = { path = "bets_panel.my_banker_pair.label" },
    myPlayerPairBetLabel = { path = "bets_panel.my_player_pair.label" },
    myBankerBetNode = { path = "bets_panel.my_banker" },
    myPlayerBetNode = { path = "bets_panel.my_player" },
    myTieBetNode = { path = "bets_panel.my_tie" },
    myBankerPairBetNode = { path = "bets_panel.my_banker_pair" },
    myPlayerPairBetNode = { path = "bets_panel.my_player_pair" },
    allBankerBetLabel = { path = "bets_panel.all_banker.label" },
    allPlayerBetLabel = { path = "bets_panel.all_player.label" },
    allTieBetLabel = { path = "bets_panel.all_tie.label" },
    allBankerPairBetLabel = { path = "bets_panel.all_banker_pair.label" },
    allPlayerPairBetLabel = { path = "bets_panel.all_player_pair.label" },
    bankerWinBlinkImg = { path = "bets_panel.banker_wi" },
    playerWinBlinkImg = { path = "bets_panel.player_wi" },
    tieWinBlinkImg = { path = "bets_panel.tie_wi" },
    bankerPairWinBlinkImg = { path = "bets_panel.banker_pair_wi" },
    playerPairWinBlinkImg = { path = "bets_panel.player_pair_wi" },
    --下注按钮
    bet1Btn = {
        path = "chip_btn_panel.Button_1",
        events = { { event = "click", method = "onSelectBet1" } }
    },
    bet2Btn = {
        path = "chip_btn_panel.Button_2",
        events = { { event = "click", method = "onSelectBet2" } }
    },
    bet3Btn = {
        path = "chip_btn_panel.Button_3",
        events = { { event = "click", method = "onSelectBet3" } }
    },
    bet4Btn = {
        path = "chip_btn_panel.Button_4",
        events = { { event = "click", method = "onSelectBet4" } }
    },
    bet5Btn = {
        path = "chip_btn_panel.Button_5",
        events = { { event = "click", method = "onSelectBet5" } }
    },
    bet6Btn = {
        path = "chip_btn_panel.Button_6",
        events = { { event = "click", method = "onSelectBet6" } }
    },
    bet1Label = { path = "chip_btn_panel.Button_1.label" },
    bet2Label = { path = "chip_btn_panel.Button_2.label" },
    bet3Label = { path = "chip_btn_panel.Button_3.label" },
    bet4Label = { path = "chip_btn_panel.Button_4.label" },
    bet5Label = { path = "chip_btn_panel.Button_5.label" },
    bet6Label = { path = "chip_btn_panel.Button_6.label" },
    bet1SelectImg = { path = "chip_btn_panel.Button_1.selected" },
    bet2SelectImg = { path = "chip_btn_panel.Button_2.selected" },
    bet3SelectImg = { path = "chip_btn_panel.Button_3.selected" },
    bet4SelectImg = { path = "chip_btn_panel.Button_4.selected" },
    bet5SelectImg = { path = "chip_btn_panel.Button_5.selected" },
    bet6SelectImg = { path = "chip_btn_panel.Button_6.selected" },
    --小卡牌
    card_1 = { path = "cards_panel.card_1" },
    card_2 = { path = "cards_panel.card_2" },
    card_3 = { path = "cards_panel.card_3" },
    card_4 = { path = "cards_panel.card_4" },
    card_5 = { path = "cards_panel.card_5" },
    card_6 = { path = "cards_panel.card_6" },
    --大卡牌 某些用户无法使手机屏足够靠近眼睛
    big_cards_base = { path = "big_cards" },
    BC_1 = { path = "big_cards.C1" },
    BC_2 = { path = "big_cards.C2" },
    BC_3 = { path = "big_cards.C3" },
    BC_4 = { path = "big_cards.C4" },
    BC_5 = { path = "big_cards.C5" },
    BC_6 = { path = "big_cards.C6" },
    --筹码
    chipPanel = { path = "chip_panel" },
    --下注时间 & 下注状态
    bet_state_label = { path = "bg_img.state_label" },
    betTimerNode = { path = "bet_timer" },
    betTimerLabel = { path = "bet_timer.label" },
    --点数
    z_point_label = { path = "bg_img.z_word.z_points" },
    x_point_label = { path = "bg_img.x_word.x_points" },
    --玩家信息
    player_head_img = { path = "bg_bottom.user_info_bg.head_image" },
    player_money_label = { path = "bg_bottom.user_info_bg.gold_num" },
    player_name_label = { path = "bg_bottom.user_info_bg.guest_name" },
    win_gold = { path = "bg_bottom.user_info_bg.gold_win" },
    other_players = { path = "bg_img.other_players", events = { { event = "click", method = "onClickOtherPlayers" } } },
    enlarge_cards = { path = "bg_img.elg_btn", events = { { event = "click", method = "switchEnlargeCards" } } },
    --走势图
    trendBtn = { path = "bg_bottom.trend_btn", events = { { event = "click", method = "onClickTrendBtn" } } },
    banker_count_label = { path = "bg_bottom.route_bg.count_lbs.banker_count" },
    player_count_label = { path = "bg_bottom.route_bg.count_lbs.player_count" },
    tie_count_label = { path = "bg_bottom.route_bg.count_lbs.tie_count" },
    banker_pair_count_label = { path = "bg_bottom.route_bg.count_lbs.banker_pair_count" },
    player_pair_count_label = { path = "bg_bottom.route_bg.count_lbs.player_pair_count" },
    all_count_label = { path = "bg_bottom.route_bg.count_lbs.all_count" },
    --路单背景图
    ROUTE_ALL = { path = "bg_bottom.route_bg.all_route_map" },
    ROUTE_ZPL = { path = "bg_bottom.route_bg.zp_route_map" },
    ROUTE_DL = { path = "bg_bottom.route_bg.dl_route_map" },
    ----路单选项按钮
    all_route_btn = {
        path = "bg_bottom.route_bg.all_route_btn",
        events = { { event = "click", method = "on_all_route_btn" } }
    },
    big_route_btn = {
        path = "bg_bottom.route_bg.big_route_btn",
        events = { { event = "click", method = "on_big_route_btn" } }
    },
    zp_route_btn = {
        path = "bg_bottom.route_bg.zp_route_btn",
        events = { { event = "click", method = "on_zp_route_btn" } }
    },

    --路单挂载点
    MAP_ZPL = { path = "bg_bottom.route_bg.zp_route_map.zp_panel.qd" },
    MAP_DL = { path = "bg_bottom.route_bg.dl_route_map.dl_panel.qd" },
    MAP_ZPL_MINI = { path = "bg_bottom.route_bg.all_route_map.zp_panel.qd" },
    MAP_DL_MINI = { path = "bg_bottom.route_bg.all_route_map.dl_panel.qd" },
    MAP_DYL = { path = "bg_bottom.route_bg.all_route_map.dyl_panel.qd" },
    MAP_XYL = { path = "bg_bottom.route_bg.all_route_map.xyl_panel.qd" },
    MAP_YYL = { path = "bg_bottom.route_bg.all_route_map.yyl_panel.qd" },

    ZPL_Z = { path = "dots.ZPL_Z" },
    ZPL_X = { path = "dots.ZPL_X" },
    ZPL_H = { path = "dots.ZPL_H" },
    DL_Z = { path = "dots.DL_Z" },
    DL_X = { path = "dots.DL_X" },
    DYL_Z = { path = "dots.DL_Z" },
    DYL_X = { path = "dots.DL_X" },
    XYL_Z = { path = "dots.XYL_Z" },
    XYL_X = { path = "dots.XYL_X" },
    YYL_Z = { path = "dots.YYL_Z" },
    YYL_X = { path = "dots.YYL_X" },

    WZ_1 = { path = "bg_bottom.route_bg.wenlu.w1z" },
    WZ_2 = { path = "bg_bottom.route_bg.wenlu.w2z" },
    WZ_3 = { path = "bg_bottom.route_bg.wenlu.w3z" },
    WX_1 = { path = "bg_bottom.route_bg.wenlu.w1x" },
    WX_2 = { path = "bg_bottom.route_bg.wenlu.w2x" },
    WX_3 = { path = "bg_bottom.route_bg.wenlu.w3x" },
    anim = { path = "anim" },
}
local DOT_SIZE = {
    16,
    16,
    16,
    8,
    8, 16, 16
}
local ROAD_START = {
    cc.p(8, 92), --ZPL_BIG
    cc.p(8, 92), --DL_BIG
    cc.p(8, 92), --DYL
    cc.p(4, 46), --XYL
    cc.p(4, 46), --YYL
    cc.p(8, 92), --ZPL
    cc.p(8, 92), --DL
}
local COLUMN_LIMIT = {
    40,
    40,
    10,
    16,
    16, 8, 14
}

local DEAL_START_POS = cc.p(1950, 1400);

C.bets = {}
C.TrendMaps = nil
C.OtherPlayersList = nil
C.HelpLayer = nil

function C:ctor(core)
    C.super.ctor(self, core)
end

--加载资源
function C:loadResource()
    C.super.loadResource(self)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GAME_BJL_IMAGES_RES .. "mmmC.plist")
end

function C:initialize()
    C.super.initialize(self)
    --适配宽屏
    self:adjustUI(self.topBg, { self.menu, self.menuBtn }, {})

    --初始化下注按钮
    for i = 1, 6 do
        self.bets[i] = {
            btn = self["bet" .. i .. "Btn"],
            sel = self["bet" .. i .. "SelectImg"],
            label = self["bet" .. i .. "Label"],
            pos = cc.p(self["bet" .. i .. "Btn"]:getPosition())
        }
    end
    self:hideBigCards();
    SET_HEAD_IMG(self.player_head_img, dataManager.userInfo.headid, dataManager.userInfo.wxheadurl)
    self:clean()
    self:on_all_route_btn(nil)
end

function C:setGameStateLabel(state)
    local stateText = {
        [1] = "下注中",
        [2] = "开牌中",
        [3] = "派奖中",
        [4] = "发牌中",
    }
    self.bet_state_label:setString(tostring(stateText[state]))
    self.bet_state_label:setVisible(true)
end

function C:setPlayerMoney(money)
    self.player_money_label:setString(utils:moneyString(money))
end

function C:setFloatBenefit(benefit)
    if not (benefit > 0) then
        return
    end

    self.win_gold:setString("+" .. utils:moneyString(benefit));
    self.win_gold:setPosition(cc.p(175, 20))
    self.win_gold:setVisible(true)
    self.win_gold:stopAllActions();
    self.win_gold:runAction(
    cc.Sequence:create(
    cc.FadeIn:create(0.1),
    cc.Spawn:create(
    cc.MoveBy:create(1, cc.p(0, 100)),
    cc.FadeOut:create(1)
    )    )    )
end

function C:setPlayerName(name)
    self.player_name_label:setString(tostring(name))
end

function C:onExitTransitionStart()
    self:clean()
    if self.TrendMaps then
        self.TrendMaps:release()
    end
    if self.OtherPlayersList then
        self.OtherPlayersList:release()
    end
    if self.HelpLayer then
        self.HelpLayer:release()
    end

    eventManager:clear("FLIP_CARD");
    eventManager:clear("HIDE_FOUR_BIG_CARDS");

    C.super.onExitTransitionStart(self)
end

function C:onEnterTransitionFinish()
    C.super.onEnterTransitionFinish(self)
    PLAY_MUSIC(GAME_BJL_SOUND_RES .. "bg.mp3")
    self.TrendMaps = TrendMap.new()
    self.TrendMaps:retain()
    self.OtherPlayersList = OPList.new()
    self.OtherPlayersList:retain()
    self.HelpLayer = HelpLayer.new()
    self.HelpLayer:retain()

    eventManager:on("FLIP_CARD", handler(self, self.onFlipCard));
    eventManager:on("HIDE_FOUR_BIG_CARDS", handler(self, self.hideFourBigCards));

end

function C:clean()
    self:setMyBankerBet(0)
    self:setMyPlayerBet(0)
    self:setMyTieBet(0)
    self:setMyBankerPairBet(0)
    self:setMyPlayerPairBet(0)

    self.bankerWinBlinkImg:setVisible(false)
    self.playerWinBlinkImg:setVisible(false)
    self.tieWinBlinkImg:setVisible(false)
    self.bankerPairWinBlinkImg:setVisible(false)
    self.playerPairWinBlinkImg:setVisible(false)

    if self.chipsView then
        self.chipsView:cleanAll()
        self.chipsView:destroy()
        self.chipsView = nil
    end

end

function C:delayInvoke(time, callback)
    local act =    transition.sequence(
    {
        CCDelayTime:create(time),
        CCCallFunc:create(callback)
    }
    )
    self:runAction(act)
end

function C:onClickTrendBtn(event)
    self.TrendMaps:show()
end

function C:onClickOtherPlayers(event)
    self.core:c2sPlayerList()

end

--region UI Event
--点击菜单三角
function C:ocMenuBtn(event)
    self.menu:setVisible(not self.menu:isVisible())
end
--点击设置按钮
function C:ocSetting(event)
    self:showSettings();
end
--点击返回按钮
function C:onBack(event)
    printInfo("点击了返回")
    self:touchBack("您当前已投注，不能退出游戏！")
    --self:touchBack("您当前已投注，退出游戏系统会自动帮您托管，不影响金币结算，确定退出游戏吗？")
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

--选择押注按钮6
function C:onSelectBet6(event)
    self:selectBetButton(6, true)
    self.model.lastSelectedBet = 6
end

--押注庄家
function C:onBankerBet(event)
    self.core:bankerBet()
end

--押注闲家
function C:onPlayerBet(event)
    self.core:playerBet()
end

--押注和
function C:onTieBet(event)
    self.core:tieBet()
end

--押注庄对
function C:onBankerPairBet(event)
    self.core:bankerPairBet()
end

--押注闲对
function C:onPlayerPairBet(event)
    self.core:playerPairBet()
end

--玩家丢筹码
function C:throwChip(seat, betType, betIndex, isAnim, isDesk)
    local randPos = self.chipsView:getChipFinalPos(betType)
    local callback = nil

    self.chipsView:chipGo(seat, betIndex, randPos, isAnim, isDesk, isAnim and self.playChipSound, callback)

    if self.playChipSound then
        self.playChipSound = false
        self:delayInvoke(
        0.5,
        function()
            self.playChipSound = true
        end
        )
    end
end
--重置路单
function C:resetRoute()
    self.all_route_btn:setEnabled(true)
    self.big_route_btn:setEnabled(true)
    self.zp_route_btn:setEnabled(true)
    self.ROUTE_ALL:setVisible(false)
    self.ROUTE_DL:setVisible(false)
    self.ROUTE_ZPL:setVisible(false)
end
--点击全路按钮
function C:on_all_route_btn(event)
    self:resetRoute();
    self.all_route_btn:setEnabled(false)
    self.ROUTE_ALL:setVisible(true)

end
--点击大路按钮
function C:on_big_route_btn(event)
    self:resetRoute();
    self.big_route_btn:setEnabled(false)
    self.ROUTE_DL:setVisible(true)
end
--点击珠盘路按钮
function C:on_zp_route_btn(event)
    self:resetRoute();
    self.zp_route_btn:setEnabled(false)
    self.ROUTE_ZPL:setVisible(true)
end


--endregion
--region API
--初始化路图界面 & 初始化游戏界面路单
function C:setTrendMaps(data)
    local count = self.TrendMaps:setZpl(data)
    self.TrendMaps:setDl(data)
    self.dld = self.TrendMaps:setXsl(data)
    self.TrendMaps:setBetLimit(self.model.betLimit);
    local askLaneArray = self.TrendMaps:setAskLane();
    self:setAskLane(askLaneArray)
    self:setCountLabel(count)
    self:setZpl(data)
    self:setDl(data)
    self:setDYL(self.dld)
    self:setXYL(self.dld)
    self:setYYL(self.dld)
end

--更新路图
function C:addRoadDots(s)
    local count = self.TrendMaps:insertZPLdot(s)
    self:setCountLabel(count)
    self.TrendMaps:insertDLdot(s)
    self.dld = self.TrendMaps:addDotForXsl(s)
    self.TrendMaps:insertDYLdot()
    self.TrendMaps:insertXYLdot()
    self.TrendMaps:insertYYLdot()
    local askLaneArray = self.TrendMaps:setAskLane();
    self:setAskLane(askLaneArray)

    self:insertZPLdot(s)
    self:insertDLdot(s)
    self:insertDYLdot();
    self:insertXYLdot();
    self:insertYYLdot();
end
function C:setAskLane(askLaneArr)
    for i = 1, 3 do
        if askLaneArr[i] then
            self["WZ_" .. i]:setPositionY(askLaneArr[i] * 20 + 30)
            self["WX_" .. i]:setPositionY(-askLaneArr[i] * 20 + 30);
        end
    end

end
function C:setCountLabel(count)
    self.banker_count_label:setString("庄" .. count.banker)
    self.player_count_label:setString("闲" .. count.player)
    self.tie_count_label:setString("和" .. count.tie)
    self.banker_pair_count_label:setString("庄对" .. count.banker_pair)
    self.player_pair_count_label:setString("闲对" .. count.player_pair)
    self.all_count_label:setString("总数" .. count.all)

    self.banker_count_label:setVisible(true);
    self.player_count_label:setVisible(true);
    self.tie_count_label:setVisible(true);
    self.banker_pair_count_label:setVisible(true);
    self.player_pair_count_label:setVisible(true);
    self.all_count_label:setVisible(true);
end
--珠盘路
function C:setZpl(data)
    self.col = 0;
    self.ZPL_index = 0;
    if not data then return; end
    for data_index = 1, #data do
        self:addDotZPL(data_index, data)
    end
end
function C:insertZPLdot(s)
    self:addDotZPL(1 + self.ZPL_index, nil, s)
end
function C:addDotZPL(data_index, data, unit)
    local switch = {
        [1] = function()
            return self.ZPL_Z:clone();
        end,
        [2] = function()
            return self.ZPL_X:clone();
        end,
        [3] = function()
            return self.ZPL_H:clone();
        end
    }
    local swFun = {
        [0] = function(dot)
            dot:getChildByName("zp"):setVisible(false)
            dot:getChildByName("xp"):setVisible(false)
        end,
        [1] = function(dot)
            dot:getChildByName("zp"):setVisible(true)
            dot:getChildByName("xp"):setVisible(false)
        end,
        [2] = function(dot)
            dot:getChildByName("zp"):setVisible(false)
            dot:getChildByName("xp"):setVisible(true)
        end,
        [3] = function(dot)
            dot:getChildByName("zp"):setVisible(true)
            dot:getChildByName("xp"):setVisible(true)
        end
    }

    if data then
        local i = data_index - 1
        local dot = switch[data[data_index].resultpos]()
        dot:setPosition(math.floor(i / 6) * DOT_SIZE[1], -(i % 6) * DOT_SIZE[1])
        swFun[data[data_index].resultpair](dot)
        self.MAP_ZPL:addChild(dot)
        self.MAP_ZPL_MINI:addChild(dot:clone())
        self.col = math.floor(i / 6)
    elseif unit then
        local i = data_index - 1
        local dot = switch[unit.resultpos]()
        dot:setPosition(math.floor(i / 6) * DOT_SIZE[1], -(i % 6) * DOT_SIZE[1])
        swFun[unit.resultpair](dot)
        self.MAP_ZPL:addChild(dot)
        self.MAP_ZPL_MINI:addChild(dot:clone())
        self.col = math.floor(i / 6)
    end
    self.ZPL_index = data_index

    local overOffset = self.col - COLUMN_LIMIT[1] + 1
    if overOffset > 0 then
        self.MAP_ZPL:setPositionX(ROAD_START[1].x - overOffset * DOT_SIZE[1])
    else
        self.MAP_ZPL:setPositionX(ROAD_START[1].x)
    end
    overOffset = self.col - COLUMN_LIMIT[6] + 1
    if overOffset > 0 then
        self.MAP_ZPL_MINI:setPositionX(ROAD_START[6].x - overOffset * DOT_SIZE[6])
    else
        self.MAP_ZPL_MINI:setPositionX(ROAD_START[6].x)
    end
end
--大路
function C:setDl(data)
    --if nil == data then
    --return
    --end
    self.lastDL = {
        result = nil,
        tieCount = 0,
        limit = 5,
        col_count = 0
    }
    self.indexDotofDL = {
        x = -1,
        y = 0
    }
    self.dotMatrixDL = {}

    if not data then return; end
    for k, v in pairs(data) do
        self:addDLdot(v.resultpos)
    end
end
function C:insertDLdot(s)
    self:addDLdot(s.resultpos)
end
function C:addDLdot(result)
    local switch = {
        [1] = function()
            return self.DL_Z:clone()
        end,
        [2] = function()
            return self.DL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if self.lastDL.result and result == self.lastDL.result then
            self.indexDotofDL.y = self.indexDotofDL.y + 1
        else
            self.indexDotofDL.y = 0
            self.indexDotofDL.x = self.indexDotofDL.x + 1
            self.lastDL.limit = 5
        end

        local col = self.indexDotofDL.x
        local row = self.indexDotofDL.y
        if self.lastDL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixDL[col * 6 + l] then
                    self.lastDL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastDL.limit then
            col = col + row - self.lastDL.limit
            row = self.lastDL.limit
        end

        dot:setPosition(col * DOT_SIZE[2], -row * DOT_SIZE[2])
        self.MAP_DL:addChild(dot)
        self.MAP_DL_MINI:addChild(dot:clone())
        self.dotMatrixDL[col * 6 + row] = true

        self.lastDL.result = result
        if self.lastDL.tieCount and 0 ~= self.lastDL.tieCount then
            dot:getChildByName("lb"):setVisible(true)
            dot:getChildByName("lb"):setString(self.lastDL.tieCount)
            self.lastDL.tieCount = 0
        end

        self.lastDL.col_count = (col > self.lastDL.col_count) and col or self.lastDL.col_count
        local overOffset = self.lastDL.col_count - COLUMN_LIMIT[2] + 1
        if overOffset > 0 then
            self.MAP_DL:setPositionX(ROAD_START[2].x - overOffset * DOT_SIZE[2])
        else
            self.MAP_DL:setPositionX(ROAD_START[2].x)
        end
        overOffset = self.lastDL.col_count - COLUMN_LIMIT[7] + 1
        if overOffset > 0 then
            self.MAP_DL_MINI:setPositionX(ROAD_START[7].x - overOffset * DOT_SIZE[7])
        else
            self.MAP_DL_MINI:setPositionX(ROAD_START[7].x)
        end
    else
        self.lastDL.tieCount = self.lastDL.tieCount + 1
    end
end
--大眼路
function C:setDYL(dld)
    local dylData = {}
    for k = 1, #dld do
        if nil ~= dld[k - 1] then
            for i = 1, dld[k] do
                if i == 1 then
                    if dld[k - 1] and dld[k - 2] then
                        if dld[k - 1] == dld[k - 2] then
                            table.insert(dylData, 1)
                        else
                            table.insert(dylData, 2)
                        end
                    end
                else
                    if 1 == i - dld[k - 1] then
                        table.insert(dylData, 2)
                    else
                        table.insert(dylData, 1)
                    end
                end
            end
        end
    end

    self.lastDYL = {
        result = nil,
        limit = 5,
        col_count = 0
    }
    self.indexDotofDYL = {
        x = -1,
        y = 0
    }
    self.dotMatrixDYL = {}

    if not dylData then return; end
    for k, v in pairs(dylData) do
        self:addDYLdot(v)
    end
end
function C:insertDYLdot()
    self.MAP_DYL:removeAllChildren();
    self:setDYL(self.dld)
end
function C:addDYLdot(result)
    local switch = {
        [1] = function()
            return self.DYL_Z:clone()
        end,
        [2] = function()
            return self.DYL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastDYL.result then
            self.indexDotofDYL.y = self.indexDotofDYL.y + 1
        else
            self.indexDotofDYL.y = 0
            self.indexDotofDYL.x = self.indexDotofDYL.x + 1
            self.lastDYL.limit = 5
        end

        local col = self.indexDotofDYL.x
        local row = self.indexDotofDYL.y
        if self.lastDYL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixDYL[col * 6 + l] then
                    self.lastDYL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastDYL.limit then
            col = col + row - self.lastDYL.limit
            row = self.lastDYL.limit
        end

        dot:setPosition(col * DOT_SIZE[3], -row * DOT_SIZE[3])
        self.MAP_DYL:addChild(dot)
        self.dotMatrixDYL[col * 6 + row] = true
        self.lastDYL.result = result

        self.lastDYL.col_count = (col > self.lastDYL.col_count) and col or self.lastDYL.col_count
        local overOffset = self.lastDYL.col_count - COLUMN_LIMIT[3] + 1
        if overOffset > 0 then
            self.MAP_DYL:setPositionX(ROAD_START[3].x - overOffset * DOT_SIZE[3])
        else
            self.MAP_DYL:setPositionX(ROAD_START[3].x)
        end
    end
end
--小眼路
function C:setXYL(dld)
    local xylData = {}
    for k = 1, #dld do
        if nil ~= dld[k - 2] then
            for i = 1, dld[k] do
                if i == 1 then
                    if dld[k - 2] and dld[k - 3] then
                        if dld[k - 2] == dld[k - 3] then
                            table.insert(xylData, 1)
                        else
                            table.insert(xylData, 2)
                        end
                    end
                else
                    if 1 == i - dld[k - 2] then
                        table.insert(xylData, 2)
                    else
                        table.insert(xylData, 1)
                    end
                end
            end
        end
    end

    self.lastXYL = {
        result = nil,
        limit = 5,
        col_count = 0
    }
    self.indexDotofXYL = {
        x = -1,
        y = 0
    }
    self.dotMatrixXYL = {}

    if not xylData then return; end
    for k, v in pairs(xylData) do
        self:addXYLdot(v)
    end
end
function C:insertXYLdot()
    self.MAP_XYL:removeAllChildren();
    self:setXYL(self.dld)
end
function C:addXYLdot(result)
    local switch = {
        [1] = function()
            return self.XYL_Z:clone()
        end,
        [2] = function()
            return self.XYL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastXYL.result then
            self.indexDotofXYL.y = self.indexDotofXYL.y + 1
        else
            self.indexDotofXYL.y = 0
            self.indexDotofXYL.x = self.indexDotofXYL.x + 1
            self.lastXYL.limit = 5
        end

        local col = self.indexDotofXYL.x
        local row = self.indexDotofXYL.y
        if self.lastXYL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixXYL[col * 6 + l] then
                    self.lastXYL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastXYL.limit then
            col = col + row - self.lastXYL.limit
            row = self.lastXYL.limit
        end

        dot:setPosition(col * DOT_SIZE[4], -row * DOT_SIZE[4])
        self.MAP_XYL:addChild(dot)
        self.dotMatrixXYL[col * 6 + row] = true
        self.lastXYL.result = result

        self.lastXYL.col_count = (col > self.lastXYL.col_count) and col or self.lastXYL.col_count
        local overOffset = self.lastXYL.col_count - COLUMN_LIMIT[4] + 1
        if overOffset > 0 then
            self.MAP_XYL:setPositionX(ROAD_START[4].x - overOffset * DOT_SIZE[4])
        else
            self.MAP_XYL:setPositionX(ROAD_START[4].x)
        end
    end
end
--曱甴路
function C:setYYL(dld)
    local yylData = {}
    for k = 1, #dld do
        if nil ~= dld[k - 3] then
            for i = 1, dld[k] do
                if i == 1 then
                    if dld[k - 3] and dld[k - 4] then
                        if dld[k - 3] == dld[k - 4] then
                            table.insert(yylData, 1)
                        else
                            table.insert(yylData, 2)
                        end
                    end
                else
                    if 1 == i - dld[k - 3] then
                        table.insert(yylData, 2)
                    else
                        table.insert(yylData, 1)
                    end
                end
            end
        end
    end

    self.lastYYL = {
        result = nil,
        limit = 5,
        col_count = 0
    }
    self.indexDotofYYL = {
        x = -1,
        y = 0
    }
    self.dotMatrixYYL = {}

    if not yylData then return; end
    for k, v in pairs(yylData) do
        self:addYYLdot(v)
    end
end
function C:insertYYLdot()
    self.MAP_YYL:removeAllChildren();
    self:setYYL(self.dld)
end
function C:addYYLdot(result)
    local switch = {
        [1] = function()
            return self.YYL_Z:clone()
        end,
        [2] = function()
            return self.YYL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastYYL.result then
            self.indexDotofYYL.y = self.indexDotofYYL.y + 1
        else
            self.indexDotofYYL.y = 0
            self.indexDotofYYL.x = self.indexDotofYYL.x + 1
            self.lastYYL.limit = 5
        end

        local col = self.indexDotofYYL.x
        local row = self.indexDotofYYL.y
        if self.lastYYL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixYYL[col * 6 + l] then
                    self.lastYYL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastYYL.limit then
            col = col + row - self.lastYYL.limit
            row = self.lastYYL.limit
        end

        dot:setPosition(col * DOT_SIZE[5], -row * DOT_SIZE[5])
        self.MAP_YYL:addChild(dot)
        self.dotMatrixYYL[col * 6 + row] = true
        self.lastYYL.result = result

        self.lastYYL.col_count = (col > self.lastYYL.col_count) and col or self.lastYYL.col_count
        local overOffset = self.lastYYL.col_count - COLUMN_LIMIT[5] + 1
        if overOffset > 0 then
            self.MAP_YYL:setPositionX(ROAD_START[5].x - overOffset * DOT_SIZE[5])
        else
            self.MAP_YYL:setPositionX(ROAD_START[5].x)
        end
    end
end

function C:setPlayerList(s)
    self.OtherPlayersList:setInfo(s)
    self.OtherPlayersList:show()
end

function C:showHelpLayer()
    self.HelpLayer:show();
end

function C:setResultPoints(cards)
    local function CardFace2Points(face)
        local point = tonumber(face)
        if point < 10 then
            return tonumber(point)
        elseif 14 == point then
            return 1
        else
            return 0
        end
    end
    local cf2p = CardFace2Points
    self:showPoints(true)
    self.z_point_label:setString(
    (tostring((cf2p(cards[1].number) + cf2p(cards[2].number) + cf2p(cards[3].number)) % 10)) .. "点"
    )
    self.x_point_label:setString(
    (tostring((cf2p(cards[4].number) + cf2p(cards[5].number) + cf2p(cards[6].number)) % 10)) .. "点"
    )
end

function C:showPoints(bool)
    self.z_point_label:setVisible(bool)
    self.x_point_label:setVisible(bool)
end

function C:resetPoints()
    self.z_point_label:setString(tostring(0))
    self.x_point_label:setString(tostring(0))
end

function C:setPoints(card_id, value_id)
    local function imgNo2Point(v)
        return v % 13 + 1 > 9 and 0 or v % 13 + 1
    end
    local in2p = imgNo2Point
    if card_id < 4 then
        self.z_point_label:setVisible(true);
        local str = (tonumber(string.sub(self.z_point_label:getString(), 1, 1)) + in2p(value_id)) % 10
        self.z_point_label:setString(str .. "点")
        self.zp = tostring(str)
    else
        self.x_point_label:setVisible(true);
        local str = (tonumber(string.sub(self.x_point_label:getString(), 1, 1)) + in2p(value_id)) % 10
        self.x_point_label:setString(str .. "点")
        self.xp = tostring(str)
    end

end


function C:setMyBankerBet(bet)
    self.myBankerBetNode:setVisible(tonumber(bet) > 0)
    self.myBankerBetLabel:setString(tostring(bet))
end

function C:setMyPlayerBet(bet)
    self.myPlayerBetNode:setVisible(tonumber(bet) > 0)
    self.myPlayerBetLabel:setString(tostring(bet))
end

function C:setMyTieBet(bet)
    self.myTieBetNode:setVisible(tonumber(bet) > 0)
    self.myTieBetLabel:setString(tostring(bet))
end

function C:setMyBankerPairBet(bet)
    self.myBankerPairBetNode:setVisible(tonumber(bet) > 0)
    self.myBankerPairBetLabel:setString(tostring(bet))
end

function C:setMyPlayerPairBet(bet)
    self.myPlayerPairBetNode:setVisible(tonumber(bet) > 0)
    self.myPlayerPairBetLabel:setString(tostring(bet))
end

function C:setAllBankerBet(bet)
    self.allBankerBetLabel:setString(tostring(bet))
end

function C:setAllPlayerBet(bet)
    self.allPlayerBetLabel:setString(tostring(bet))
end

function C:setAllTieBet(bet)
    self.allTieBetLabel:setString(tostring(bet))
end

function C:setAllBankerPairBet(bet)
    self.allBankerPairBetLabel:setString(tostring(bet))
end

function C:setAllPlayerPairBet(bet)
    self.allPlayerPairBetLabel:setString(tostring(bet))
end

--中奖区域闪烁
function C:winAreaBlink(area, callback)
    area:setVisible(true)
    local fadeIn = CCFadeIn:create(0.5)
    local fadeOut = CCFadeOut:create(0.5)
    local callFun =    CCCallFunc:create(
    function()
        area:setVisible(false)
        if callback then
            callback()
        end
    end
    )
    local seq = transition.sequence({ fadeIn, fadeOut })
    local rep = CCRepeat:create(seq, 2)
    area:runAction(transition.sequence({ rep, callFun }))
end

function C:showBankerWinBlink(callback)
    self:winAreaBlink(self.bankerWinBlinkImg, callback)
end
function C:showPlayerWinBlink(callback)
    self:winAreaBlink(self.playerWinBlinkImg, callback)
end
function C:showTieWinBlink(callback)
    self:winAreaBlink(self.tieWinBlinkImg, callback)
end
function C:showBankerPairWinBlink(callback)
    self:winAreaBlink(self.bankerPairWinBlinkImg, callback)
end
function C:showPlayerPairWinBlink(callback)
    self:winAreaBlink(self.playerPairWinBlinkImg, callback)
end

--玩家获得筹码
function C:getChips()
    self.chipsView:chipsBack(
    function()
        --for k,v in pairs(numberSeats) do
        --self:playResultEffect(v.seat,v.money)
        --end
    end
    )
end

--设置下注按钮数值
function C:setBetValues(values)
    for k, v in ipairs(values) do
        self.bets[k].label:setString(v)
    end
    self.betValues = values

    if not self.chipsView then
        self.chipsView = ChipsView.new(self.chipPanel, values)
        self.chipsView.onBankerBetHandler = handler(self, self.onBankerBet)
        self.chipsView.onPlayerBetHandler = handler(self, self.onPlayerBet)
        self.chipsView.onTieBetHandler = handler(self, self.onTieBet)
        self.chipsView.onBankerPairBetHandler = handler(self, self.onBankerPairBet)
        self.chipsView.onPlayerPairBetHandler = handler(self, self.onPlayerPairBet)
    end
end

--选择按钮
function C:selectBetButton(index, anim)
    self.model.currentBet = index
    for i = 1, 6 do
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

    --self.noticeImg:setVisible(self.model.myInfo.money < self.model.needMoney)
end

--禁用所有按钮
function C:disableAllButtons()
    for i = 1, 6 do
        self:enableBetButton(i, false)
    end
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
    --少于50img
    --self.noticeImg:setVisible(self.model.myInfo.money < self.model.needMoney)
    self:removeClockHandler()
    self.betTimerNode:setVisible(true)
    local leftTime = math.floor(time)
    self.betTimerLabel:setString(tostring(leftTime))
    self.countDownHandler =    scheduler:scheduleScriptFunc(
    function()
        leftTime = leftTime - 1
        if leftTime <= 0 then
            --self:disableAllButtons()
            if callback then
                callback()
            end
            if self and self.betTimerNode then
                self.betTimerNode:setVisible(false)
                self:removeClockHandler()
            end
        else
            if self and self.betTimerLabel then
                self.betTimerLabel:setString(tostring(leftTime))
            end
        end
    end,
    1,
    false
    )
end

--移除定时器回调
function C:removeClockHandler()
    if self.countDownHandler then
        scheduler:unscheduleScriptEntry(self.countDownHandler)
        self.countDownHandler = nil
    end
end

--停止定时器
function C:stopTimer()
    self:removeClockHandler()
    self.betTimerNode:setVisible(false)
end

function C:loadAnim()
    local strAnimName = GAME_BJL_ANIMATION_RES .. "bjl_game_effect_zhuangwin_ske";
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0, "bjl_game_effect_zhuangwin", true)
    self.anim:addChild(skeletonNode)
end

function C:showWinAniWithDelay(index)
    local se_dura = 0.8
    if self.xp and self.zp then
        self:runAction(
        cc.Sequence:create(

        cc.Spawn:create(
        cc.DelayTime:create(se_dura + 0.1),
        cc.CallFunc:create(
        function()
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "xianjia.mp3");
        end
        )    ),

        cc.Spawn:create(
        cc.DelayTime:create(se_dura - 0.1),
        cc.CallFunc:create(
        function()
            if not self.xp then return; end
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "bjl_1" .. self.xp .. ".mp3");
        end
        )    ),

        cc.Spawn:create(
        cc.DelayTime:create(se_dura + 0.1),
        cc.CallFunc:create(
        function()
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "zhuangjia.mp3");
        end
        )    ),

        cc.Spawn:create(
        cc.DelayTime:create(se_dura - 0.1),
        cc.CallFunc:create(
        function()
            if not self.zp then return; end
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "bjl_1" .. self.zp .. ".mp3");
        end
        )    ),
        cc.CallFunc:create(
        function()
            self:showWinAni(index);
            self:hideBigCards();
        end
        )        )        );
    else
        self:runAction(
        cc.Sequence:create(
        cc.DelayTime:create(se_dura * 4),
        cc.CallFunc:create(
        function()
            self:showWinAni(index);
            self:hideBigCards();
        end
        )        )        );
    end
end

function C:showWinAni(index)
    self:hideWinAni()
    self.anim:setVisible(true)
    local strAnimName = GAME_BJL_ANIMATION_RES .. "bjl_game_effect_zhuangwin_ske";
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    local switch = {
        [1] = function()
            skeletonNode:setAnimation(0, "bjl_game_effect_zhuangwin", false);
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "zwin.mp3");
        end,
        [2] = function()
            skeletonNode:setAnimation(0, "bjl_game_effect_xianwin", false);
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "xwin.mp3");
        end,
        [3] = function()
            skeletonNode:setAnimation(0, "bjl_game_effect_hewin", false); end,
    }
    switch[index]();

    self.anim:addChild(skeletonNode);
    skeletonNode:runAction(
    cc.Sequence:create(
    cc.DelayTime:create(1),
    cc.FadeOut:create(1),
    cc.RemoveSelf:create()
    )    );
end

function C:hideWinAni()
    self.anim:removeAllChildren(true)
    self.anim:setVisible(false)
end

function C:showStateAni(index)
    if index ~= 1 and index ~= 2 then return; end
    self:hideStateAni()
    self.anim:setVisible(true)
    local strAnimName = GAME_BJL_ANIMATION_RES .. "zjh_effect_xz_ske";
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    local switch = {
        [1] = function()
            skeletonNode:setAnimation(0, "zjh_effect_xz_star", false);
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "start.mp3");
        end,
        [2] = function()
            skeletonNode:setAnimation(0, "zjh_effect_xz_end", false);
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "stop.mp3");
        end,
    }
    if (switch[index]) then
        switch[index]();
    else
        return;
    end
    self.anim:addChild(skeletonNode);
    skeletonNode:runAction(
    cc.Sequence:create(
    cc.DelayTime:create(1),
    cc.FadeOut:create(0.4),
    cc.RemoveSelf:create()
    )    );

end

function C:hideStateAni()
    --self.anim:removeAllChildren(true)
    self.anim:setVisible(false)
end

function C:dealCards(card_id)
    local delay_sec = { 2, 4, 0, 3, 1, 0 }
    local protoCard = self["card_" .. card_id];
    protoCard:loadTexture("mp_card_" .. 0 .. ".png", ccui.TextureResType.plistType);
    local flyingCard = protoCard:clone();
    flyingCard:addTo(protoCard:getParent());
    local flyingDuration = 0.4;
    flyingCard:setScale(0.1);
    flyingCard:setPosition(DEAL_START_POS);
    flyingCard:runAction(
    cc.Sequence:create(
    cc.DelayTime:create(delay_sec[card_id]),
    cc.CallFunc:create(
    function()
        flyingCard:setVisible(true)
    end
    ),
    cc.Spawn:create(
        cc.CallFunc:create(function ()
            PLAY_SOUND(GAME_BJL_SOUND_RES.."sendcard.mp3")
        end),
    cc.ScaleTo:create(flyingDuration, 1),
    cc.MoveTo:create(flyingDuration, cc.p(protoCard:getPositionX(), protoCard:getPositionY()))),
    cc.RemoveSelf:create(),
    cc.CallFunc:create(
    function()
        protoCard:setVisible(true)
    end
    )));
end

function C:setCardImage(card_id, vaule_id)
    local delay_sec = { 3, 4, 6, 1, 2, 5 };
    local protoCard = self["card_" .. card_id];

    if 0 == vaule_id then
        protoCard:setVisible(false);
        return;
    else
        protoCard:setVisible(true);
    end

    if 3 == card_id or 6 == card_id then

        protoCard:setVisible(false);
        protoCard:stopAllActions();
        protoCard:runAction(
        cc.Sequence:create(
        cc.DelayTime:create(delay_sec[card_id] - 1.2),
        cc.Spawn:create(
        cc.CallFunc:create(
        function()
            if 6 == card_id then
                PLAY_SOUND(GAME_BJL_SOUND_RES .. "xianjia.mp3");
            elseif 3 == card_id then
                PLAY_SOUND(GAME_BJL_SOUND_RES .. "zhuangjia.mp3");
            end
        end
        ),
        cc.DelayTime:create(0.6)),
        cc.Spawn:create(
        cc.CallFunc:create(
        function()
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "bupai.mp3");
        end
        ),
        cc.DelayTime:create(0.6)),
        cc.CallFunc:create(
        function()
            eventManager:publish("HIDE_FOUR_BIG_CARDS");
            --self:hideBigCards();
        end
        ),
        cc.Spawn:create(
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(
        function()
            self:dealCards(card_id);
        end
        )    ),
        cc.CallFunc:create(
        function()
            eventManager:publish("FLIP_CARD", card_id, vaule_id);
        end
        ),
        cc.ScaleTo:create(0.2, 0, 1, 1),
        cc.CallFunc:create(
        function()
            protoCard:loadTexture("mp_card_" .. vaule_id .. ".png", ccui.TextureResType.plistType);
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "flipcard.mp3");
        end
        ),
        cc.ScaleTo:create(0.2, 1, 1, 1),
        cc.CallFunc:create(
        function()
            self:setPoints(card_id, vaule_id);
        end)
        )    );
    else
        protoCard:stopAllActions();
        protoCard:runAction(
        cc.Sequence:create(
        cc.DelayTime:create(delay_sec[card_id]),
        cc.CallFunc:create(
        function()
            eventManager:publish("FLIP_CARD", card_id, vaule_id);
        end
        ),
        cc.ScaleTo:create(0.2, 0, 1, 1),
        cc.CallFunc:create(
        function()
            protoCard:loadTexture("mp_card_" .. vaule_id .. ".png", ccui.TextureResType.plistType);
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "flipcard.mp3");
        end
        ),
        cc.ScaleTo:create(0.2, 1, 1, 1),
        cc.CallFunc:create(
        function()
            self:setPoints(card_id, vaule_id);
        end)
        )    );
    end
end

function C:show4Cards()
    for card_id = 1, 6 do
        local protoCard = self["card_" .. card_id];
        if 3 == card_id or 6 == card_id then
            protoCard:setVisible(false);
        else
            protoCard:setVisible(true);
        end
    end
end

function C:showAllCardsWithoutAnim(s)
    if s.cards then
        for i = 1, 6 do
            if 0 ~= s.cards[i].color then
                self["card_" .. i]:loadTexture("mp_card_" .. tostring(self.logic:colorNumber2Id(s.cards[i].color, s.cards[i].number)) .. ".png", ccui.TextureResType.plistType);
            end
        end
    end
end

function C:playSoundDC()
    PLAY_SOUND(GAME_BJL_SOUND_RES .. "dealCard.mp3");
end

function C:onFlipCard(card_id, value_id)
    local card = self["BC_" .. card_id];
    card:setVisible(true);
    card:loadTexture("mp_card_0.png", ccui.TextureResType.plistType);
    card:runAction(
    cc.Sequence:create(
    cc.ScaleTo:create(0.2, 0, 1, 1),
    cc.CallFunc:create(
    function()
        card:loadTexture("mp_card_" .. value_id .. ".png", ccui.TextureResType.plistType);
    end    ),
    cc.ScaleTo:create(0.2, 1, 1, 1)))
end

function C:hideBigCards()
    for i = 1, 6 do
        local card = self["BC_" .. i];
        card:setVisible(false)
    end
end

function C:hideFourBigCards()
    for i = 1, 6 do
        if i ~= 3 and i ~= 6 then
            local card = self["BC_" .. i];
            card:setVisible(false);
        end
    end
end

function C:switchEnlargeCards()
    self.big_cards_base:setVisible(not self.big_cards_base:isVisible())
end
--endregion
return C