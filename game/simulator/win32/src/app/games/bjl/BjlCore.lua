--BjlCore.lua
--Date 2019年12月13日16:59:22
local C = class("BjlCore", GameCoreBase)
--模块路径
C.MODULE_PATH = "app.games.bjl"
--场景配置
C.SCENE_CONFIG = {
    scenename = "bjl_scene",
    filename = "BjlScene",
    logic = "BjlLogic",
    define = "BjlDefine",
    model = "BjlModel"
}

C.preform = false

--region BASIC
function C:ctor(roomInfo)
    C.super.ctor(self, roomInfo)
end

function C:start()
    C.super.start(self)
    --注册协议
    self:registerAll()
    self.model.myInfo.seat = 1
end

function C:exit()
    --注销协议
    self:unregisterAll()
    C.super.exit(self)
end

function C:registerAll()
    self:registerGameMsg(self.define.proto.SC_BJL_CONFIG_P, handler(self, self.s2cSetConfig)) --发送配置
    self:registerGameMsg(self.define.proto.SC_BJL_GAMESTATE_P, handler(self, self.s2cSetGameState)) --游戏状态切换
    self:registerGameMsg(self.define.proto.SC_BJL_BUYHORSE_P, handler(self, self.s2cBet)) --玩家下注
    self:registerGameMsg(self.define.proto.SC_BJL_SHOWCARD_P, handler(self, self.s2cShowCard)) --通知亮牌操作
    self:registerGameMsg(self.define.proto.SC_BJL_SETTLEMENT_P, handler(self, self.s2cSettlement)) --比牌结果&结算
    self:registerGameMsg(self.define.proto.SC_BJL_OPER_ERROR_P, handler(self, self.s2cOperError)) --服务端返回操作错误码
    self:registerGameMsg(self.define.proto.SC_BJL_HISTORY_P, handler(self, self.s2cHistory)) --历史记录
    self:registerGameMsg(self.define.proto.SC_BJL_FOLLOW_BUY_P, handler(self, self.s2cFollowBuy)) --续押
    self:registerGameMsg(self.define.proto.SC_BJL_BET_END_P, handler(self, self.s2cBetEnd)) --同步下注信息
    self:registerGameMsg(self.define.proto.SC_BJL_PLAYERLIST_P, handler(self, self.s2cPlayerList)) --玩家列表信息

end

function C:unregisterAll()
    self:unregisterGameMsg(self.define.proto.SC_BJL_CONFIG_P) --发送配置
    self:unregisterGameMsg(self.define.proto.SC_BJL_GAMESTATE_P) --游戏状态切换
    self:unregisterGameMsg(self.define.proto.SC_BJL_BUYHORSE_P) --玩家下注
    self:unregisterGameMsg(self.define.proto.SC_BJL_SHOWCARD_P) --通知亮牌操作
    self:unregisterGameMsg(self.define.proto.SC_BJL_SETTLEMENT_P) --比牌结果&结算
    self:unregisterGameMsg(self.define.proto.SC_BJL_OPER_ERROR_P) --服务端返回操作错误码
    self:unregisterGameMsg(self.define.proto.SC_BJL_HISTORY_P) --历史记录
    self:unregisterGameMsg(self.define.proto.SC_BJL_FOLLOW_BUY_P) --续押
    self:unregisterGameMsg(self.define.proto.SC_BJL_BET_END_P) --同步下注信息
    self:unregisterGameMsg(self.define.proto.SC_BJL_PLAYERLIST_P) --玩家列表信息
end
--endregion
--region S2C Common
--玩家进入房间
function C:onPlayerEnter(s)
    --printInfo("<==================玩家进入==================>")
    --dump(s, nil, 10)
end

--房间信息
function C:onRoomInfo(s)
    --printInfo("<==================房间信息==================>")
end

--房间状态
function C:onRoomState(s)
    --printInfo("<==================房间状态==================>")
end

--玩家退出
function C:onPlayerQuit(s)
    --printInfo("<==================玩家退出==================>")
    --dump(s, nil, 10)
end

--玩家被踢
function C:onDeletePlayer(s)
    --printInfo("<==================玩家被踢==================>")
    C.super.onDeletePlayer(self, s)
end

function C:onQuitGame(info)
    --dump(info, "onQuitGame>>>")
    if SCENE_NAME ~= "Hall" then
        local reason = info["sxreason"]
        if reason == 4 then
            DialogLayer.new():show(
            "您被踢出房间",
            function()
                self:quitGame()
            end,
            false
            )
        end
    end
end

--断线重连
function C:onToOtherRoom(s)
    printInfo("<==================断线重连==================>")
    --dump(s, "onToOtherRoom", 10)
    self.scene:clean()

    self.model.bets = s.config.Bet
    self.model.gameState = s.state
    self.scene:setGameStateLabel(self.model.gameState)

    local bets = {}
    for k, v in pairs(s.config.Bet) do
        bets[k] = v / MONEY_SCALE
    end

    self.scene:setBetValues(bets)
    self.model.currentBet = 1
    self.model.needMoney = s.betneed
    self.model.betLimit = {}
    self:updateAllButtons()

    --下注区
    self.model.allBankerBet = (s.buyhorse[1] or 0)
    self.model.allPlayerBet = (s.buyhorse[2] or 0)
    self.model.allTieBet = (s.buyhorse[3] or 0)
    self.model.allBankerPairBet = (s.buyhorse[4] or 0)
    self.model.allPlayerPairBet = (s.buyhorse[5] or 0)

    self.model.myBankerBet = (s.currbuy[1] or 0)
    self.model.myPlayerBet = (s.currbuy[2] or 0)
    self.model.myTieBet = (s.currbuy[3] or 0)
    self.model.myBankerPairBet = (s.currbuy[4] or 0)
    self.model.myPlayerPairBet = (s.currbuy[5] or 0)

    self.scene:setMyBankerBet(self.model.myBankerBet / MONEY_SCALE)
    self.scene:setMyPlayerBet(self.model.myPlayerBet / MONEY_SCALE)
    self.scene:setMyTieBet(self.model.myTieBet / MONEY_SCALE)
    self.scene:setMyBankerPairBet(self.model.myBankerPairBet / MONEY_SCALE)
    self.scene:setMyPlayerPairBet(self.model.myPlayerPairBet / MONEY_SCALE)

    self.scene:setAllBankerBet(self.model.allBankerBet / MONEY_SCALE)
    self.scene:setAllPlayerBet(self.model.allPlayerBet / MONEY_SCALE)
    self.scene:setAllTieBet(self.model.allTieBet / MONEY_SCALE)
    self.scene:setAllBankerPairBet(self.model.allBankerPairBet / MONEY_SCALE)
    self.scene:setAllPlayerPairBet(self.model.allPlayerPairBet / MONEY_SCALE)

    self.model.myInfo.money = s.chouma
    self.scene:setPlayerMoney(self.model.myInfo.money)
    self.scene:setPlayerName(s.nickname)

    self:setBetLimit(s);
    self.scene:setTrendMaps(s.data)

    if
    s.state == self.define.roomState.Betting or
    (s.state == self.define.roomState.Result and s.nexttime and s.nexttime >= 1)
    then
        local chips = nil
        for i = 1, 5 do
            if s.buyhorse[i] and s.buyhorse[i] > 0 then
                chips = self:money2Chips(s.buyhorse[i])
                for k, v in pairs(chips) do
                    for j = 1, v do
                        self.scene:throwChip(2, i, k, false, false)
                    end
                end
            end
        end
    end

    --剩余时间
    if s.nexttime then --and s.state == self.define.roomState.Betting then
        self.scene:startTimer(math.floor(s.nexttime) - 1)
    end

    --设置牌面
    if s.state == self.define.roomState.Betting then
        --self:showCardsBack()
        self.isGaming = true
        self.scene:showPoints(false)
    elseif s.cards then
        --self:showCardsFace(s)
        self.scene:showAllCardsWithoutAnim(s)
    end
    self:show4Cards();

end

--更新金币
function C:updatePlayerMoney(s)
    if s.playerid == self.model.myInfo.playerid then
        if self.model.currentBet <= 0 then
            self.model.currentBet = 1
        end
        self.scene:setFloatBenefit(s.coin - self.model.myInfo.money)
        self.model.myInfo.money = s.coin
        self.scene:setPlayerMoney(self.model.myInfo.money)

        self:updateAllButtons()
    end
    C.super.updatePlayerMoney(self, s)
end

--结算
function C:onSettlement(s)
    --printInfo("<==================显示结算==================>")
end

--endregion
--region S2C Game
--初始化游戏配置
function C:s2cSetConfig(s)
    --printInfo("<==================获得配置==================>")
    --dump(s, "s2cSetConfig", 10)
    self.model.gameState = s.state
    if s.state == self.define.roomState.Betting then
        self.model.currentBet = self.model.lastSelectedBet
    end
end
--设置游戏状态
function C:s2cSetGameState(s)
    printInfo("<==================游戏状态==================>")
    --dump(s, "s2cSetGameState", 10)
    self.model.gameState = s.state
    self.scene:setGameStateLabel(self.model.gameState)
    if s.nexttime then
        self.scene:startTimer(math.floor(s.nexttime) - 1)
    end

    if s.state == self.define.roomState.Betting then
        self.model.currentBet = self.model.lastSelectedBet
        self.scene:showPoints(false);
    end
    self:updateAllButtons()
    if s.state == self.define.roomState.Wait then --暂无
        self.scene:cleanCards()
        self.scene:cleanChips()
        self.scene:hideWaiting()
        self.scene:playStartBetAnim()
        self.scene:setAllRedBet(0)
        self.scene:setAllBlackBet(0)
        self.scene:setAllLuckyBet(0)
        self.scene:setMyRedBet(0)
        self.scene:setMyBlackBet(0)
        self.scene:setMyLuckyBet(0)
        self.model:reset()
        self.scene:updateBattery()
        self.model.isGaming = false
    elseif s.state == self.define.roomState.Betting then
        --self:showCardsBack()
        self.model.isGaming = false
    elseif s.state == self.define.roomState.Result then
        self:showCardsBack()
        self:show4Cards();
    elseif s.state == self.define.roomState.Rest then
        --printInfo("休息一下:" .. os.date("%Y-%m-%d %H:%M:%S"))
        --self.model.isGaming = false
    elseif s.state == self.define.roomState.Deal then
        self.scene:showPoints(false);
        self:showCardsBack()
        self:dealCards();
        self.scene:playSoundDC();
        self.model.allBankerBet = 0
        self.model.allPlayerBet = 0
        self.model.allTieBet = 0
        self.model.allBankerPairBet = 0
        self.model.allPlayerPairBet = 0

        self.scene:setAllBankerBet(self.model.allBankerBet / MONEY_SCALE)
        self.scene:setAllPlayerBet(self.model.allPlayerBet / MONEY_SCALE)
        self.scene:setAllTieBet(self.model.allTieBet / MONEY_SCALE)
        self.scene:setAllBankerPairBet(self.model.allBankerPairBet / MONEY_SCALE)
        self.scene:setAllPlayerPairBet(self.model.allPlayerPairBet / MONEY_SCALE)

        self.model.myBankerBet = 0
        self.model.myPlayerBet = 0
        self.model.myTieBet = 0
        self.model.myBankerPairBet = 0
        self.model.myPlayerPairBet = 0

        self.scene:setMyBankerBet(self.model.myBankerBet)
        self.scene:setMyPlayerBet(self.model.myPlayerBet)
        self.scene:setMyTieBet(self.model.myTieBet)
        self.scene:setMyBankerPairBet(self.model.myBankerPairBet)
        self.scene:setMyPlayerPairBet(self.model.myPlayerPairBet)


        self.model.isGaming = false
    end
    self.scene:showStateAni(s.state)
end
--玩家下注
function C:s2cBet(s)
    --printInfo("<==================玩家下注==================>")
    --dump(s, "s2cBet")
    local betIndex = self.model:getBetIndex(s.bet)
    if not betIndex then
        betIndex = 1
    end

    --判断自己是否已经预先表现了
    --if s.playerid ~= self.model.myInfo.playerid or not self.preform then
    --self.scene:throwChip(2, s.target, betIndex, true, true)
    --end
    local switch = {
        [1] = function()
            self.model.myBankerBet = s.buyall
            self.scene:setMyBankerBet(self.model.myBankerBet / MONEY_SCALE)
            --self.model.allBankerBet = s.dirctionall
            --self.scene:setAllBankerBet(self.model.allBankerBet / MONEY_SCALE)
        end,
        [2] = function()
            self.model.myPlayerBet = s.buyall
            self.scene:setMyPlayerBet(self.model.myPlayerBet / MONEY_SCALE)
            --self.model.allPlayerBet = s.dirctionall
            --self.scene:setAllPlayerBet(self.model.allPlayerBet / MONEY_SCALE)
        end,
        [3] = function()
            self.model.myTieBet = s.buyall
            self.scene:setMyTieBet(self.model.myTieBet / MONEY_SCALE)
            --self.model.allTieBet = s.dirctionall
            --self.scene:setAllTieBet(self.model.allTieBet / MONEY_SCALE)
        end,
        [4] = function()
            self.model.myBankerPairBet = s.buyall
            self.scene:setMyBankerPairBet(self.model.myBankerPairBet / MONEY_SCALE)
            --self.model.allBankerPairBet = s.dirctionall
            --self.scene:setAllBankerPairBet(self.model.allBankerPairBet / MONEY_SCALE)
        end,
        [5] = function()
            self.model.myPlayerPairBet = s.buyall
            self.scene:setMyPlayerPairBet(self.model.myPlayerPairBet / MONEY_SCALE)
            --self.model.allPlayerPairBet = s.dirctionall
            --self.scene:setAllPlayerPairBet(self.model.allPlayerPairBet / MONEY_SCALE)
        end
    }
    if s.playerid == self.model.myInfo.playerid then
        local f = switch[s.direction]
        if (f) then
            f();
            PLAY_SOUND(GAME_BJL_SOUND_RES .. "bet.mp3")
        else
            print "Case default."
        end
    end
    self.model.myInfo.money = s.chouma
    self.scene:setPlayerMoney(self.model.myInfo.money)
    self:updateAllButtons()

    self.model.isGaming = true
end
--亮牌数据
function C:s2cShowCard(s)
    --printInfo("<==================通知亮牌操作==================>")
    --dump(s, "s2cShowCard")
    self.scene:resetPoints();
    self:showCardsFace(s)
    --self:setResultPoints(s)
end
--结算数据
function C:s2cSettlement(s)
    printInfo("<==================比牌结果&结算==================>")
    --dump(s, "s2cSettlement")
    local switch = {
        [1] = function()
            self.scene:showBankerWinBlink()
        end,
        [2] = function()
            self.scene:showPlayerWinBlink()
        end,
        [3] = function()
            self.scene:showTieWinBlink()
        end
    }
    local f = switch[s.resultpos]
    if (f) then
        f()
        self.scene:showWinAniWithDelay(s.resultpos)
    else
        print("不是莊閑和？")
    end

    local switchPair = {
        [0] = function()
            return
        end,
        [1] = function()
            self.scene:showBankerPairWinBlink()
        end,
        [2] = function()
            self.scene:showPlayerPairWinBlink()
        end,
        [3] = function()
            self.scene:showBankerPairWinBlink()
            self.scene:showPlayerPairWinBlink()
        end
    }
    local fp = switchPair[s.resultpair]
    if (fp) then
        fp()
    else
        print("非0123对子？")
    end
    self.scene:addRoadDots(s)
    self.scene:getChips()
end
--错误返回
function C:s2cOperError(s)
    printInfo("<==================服务端返回操作错误码==================>")
    dump(s, "s2cOperError")
end
--历史记录
function C:s2cHistory(s)
    --printInfo("<==================历史记录==================>")
    --dump(s, "s2cHistory")
end
--续押 【暂无】
function C:s2cFollowBuy(s)
    --printInfo("<==================续押==================>")
    --dump(s, "s2cFollowBuy")
end
--所有玩家下注
function C:s2cBetEnd(s)
    --printInfo("<==================同步下注信息==================>")
    --dump(s, "s2cBetEnd")
    self.scene:setAllBankerBet((s.dirctionall1 or 0) / MONEY_SCALE)
    self.scene:setAllPlayerBet((s.dirctionall2 or 0) / MONEY_SCALE)
    self.scene:setAllTieBet((s.dirctionall3 or 0) / MONEY_SCALE)
    self.scene:setAllBankerPairBet((s.dirctionall4 or 0) / MONEY_SCALE)
    self.scene:setAllPlayerPairBet((s.dirctionall5 or 0) / MONEY_SCALE)

    local chips = nil

    if s.cache1 and s.cache1 > 0 then
        local realCache = math.max(s.dirctionall1 - self.model.allBankerBet - self.model.myBankerBet, 0)
        self.model.allBankerBet = s.dirctionall1
        chips = self:money2Chips(realCache)
        for k, v in pairs(chips) do
            for i = 1, v do
                self.scene:throwChip(2, 1, k, true, false)
            end
        end
        PLAY_SOUND(GAME_BJL_SOUND_RES .. "bet.mp3")
    end

    if s.cache2 and s.cache2 > 0 then
        local realCache = math.max(s.dirctionall2 - self.model.allPlayerBet - self.model.myPlayerBet, 0)
        self.model.allPlayerBet = s.dirctionall2
        chips = self:money2Chips(realCache)
        for k, v in pairs(chips) do
            for i = 1, v do
                self.scene:throwChip(2, 2, k, true, false)
            end
        end
        PLAY_SOUND(GAME_BJL_SOUND_RES .. "bet.mp3")
    end

    if s.cache3 and s.cache3 > 0 then
        local realCache = math.max(s.dirctionall3 - self.model.allTieBet - self.model.myTieBet, 0)
        self.model.allTieBet = s.dirctionall3
        chips = self:money2Chips(realCache)
        for k, v in pairs(chips) do
            for i = 1, v do
                self.scene:throwChip(2, 3, k, true, false)
            end
        end
        PLAY_SOUND(GAME_BJL_SOUND_RES .. "bet.mp3")
    end

    if s.cache4 and s.cache4 > 0 then
        local realCache = math.max(s.dirctionall4 - self.model.allBankerPairBet - self.model.myBankerPairBet, 0)
        self.model.allBlackPairBet = s.dirctionall4
        chips = self:money2Chips(realCache)
        for k, v in pairs(chips) do
            for i = 1, v do
                self.scene:throwChip(2, 4, k, true, false)
            end
        end
        PLAY_SOUND(GAME_BJL_SOUND_RES .. "bet.mp3")
    end

    if s.cache5 and s.cache5 > 0 then
        local realCache = math.max(s.dirctionall5 - self.model.allPlayerPairBet - self.model.myPlayerPairBet, 0)
        self.model.allPlayerPairBet = s.dirctionall5
        chips = self:money2Chips(realCache)
        for k, v in pairs(chips) do
            for i = 1, v do
                self.scene:throwChip(2, 5, k, true, false)
            end
        end
        PLAY_SOUND(GAME_BJL_SOUND_RES .. "bet.mp3")
    end
end
--玩家列表
function C:s2cPlayerList(s)
    printInfo("<==================玩家列表信息==================>")
    --dump(s, "s2cPlayerList")
    self.scene:setPlayerList(s)
end
--endregion
--region C2S 
--下注
function C:c2sBet(betValue, betType)
    self:sendGameMsg(self.define.proto.CS_BJL_BUYHORSE_P, { odds = betValue, direction = betType })
end

--续投
function C:c2sFollowBet()
    self:sendGameMsg(self.define.proto.CS_BJL_FOLLOW_BUY_P)
end

--请求历史信息
function C:c2sHistory()
    self:sendGameMsg(self.define.proto.CS_BJL_HISTORY_P)
end

--请求玩家列表
function C:c2sPlayerList()
    self:sendGameMsg(self.define.proto.CS_BJL_PLAYERLIST_P)
end

--endregion
--region UI Event
--押注庄家
function C:bankerBet()
    if not self:canBet() then
        return
    end
    if self.model.bets[self.model.currentBet] + self.model.myBankerBet > self.model.betLimit[1] then
        toastLayer:show("超过限红")
        return false
    end
    if self.model.myPlayerBet > 0 then
        toastLayer:show("不能同时在庄闲方下注！")
        return
    end
    self.scene:throwChip(1, self.define.betType.Banker, self.model.currentBet, true, true)
    self:c2sBet(self.model:getCurrentBetValue(), self.define.betType.Banker)
    self.preform = true
end

--押注闲家
function C:playerBet()
    if not self:canBet() then
        return
    end
    if self.model.bets[self.model.currentBet] + self.model.myPlayerBet > self.model.betLimit[1] then
        toastLayer:show("超过限红")
        return false
    end
    if self.model.myBankerBet > 0 then
        toastLayer:show("不能同时在庄闲方下注！")
        return
    end
    self.scene:throwChip(1, self.define.betType.Player, self.model.currentBet, true, true)
    self:c2sBet(self.model:getCurrentBetValue(), self.define.betType.Player)
    self.preform = true
end

--押注和局
function C:tieBet()
    if not self:canBet() then
        return
    end
    if self.model.bets[self.model.currentBet] + self.model.myTieBet > self.model.betLimit[2] then
        toastLayer:show("超过限红")
        return false
    end
    self.scene:throwChip(1, self.define.betType.Tie, self.model.currentBet, true, true)
    self:c2sBet(self.model:getCurrentBetValue(), self.define.betType.Tie)
    self.preform = true
end

--押注庄对
function C:bankerPairBet()
    if not self:canBet() then
        return
    end
    if self.model.bets[self.model.currentBet] + self.model.myBankerPairBet > self.model.betLimit[3] then
        toastLayer:show("超过限红")
        return false
    end
    self.scene:throwChip(1, self.define.betType.BankerPair, self.model.currentBet, true, true)
    self:c2sBet(self.model:getCurrentBetValue(), self.define.betType.BankerPair)
    self.preform = true
end

--押注闲对
function C:playerPairBet()
    if not self:canBet() then
        return
    end
    if self.model.bets[self.model.currentBet] + self.model.myPlayerPairBet > self.model.betLimit[3] then
        toastLayer:show("超过限红")
        return false
    end
    self.scene:throwChip(1, self.define.betType.PlayerPair, self.model.currentBet, true, true)
    self:c2sBet(self.model:getCurrentBetValue(), self.define.betType.PlayerPair)
    self.preform = true
end

--endregion
--region Other
function C:updateAllButtons()
    if self.model.gameState ~= self.define.roomState.Betting then
        self.scene:disableAllButtons()
        return
    end

    for i = #self.model.bets, 1, -1 do
        local enable = self.model.bets[i] <= self.model.myInfo.money and self.model.myInfo.money >= self.model.needMoney
        self.scene:enableBetButton(i, enable)
        if self.model.currentBet == i and not enable then
            self.model.currentBet = self.model.currentBet - 1
        end
        if enable and self.model.currentBet < 1 then
            self.model.currentBet = 1
        end
    end

    if self.model.currentBet > 0 then
        self.scene:selectBetButton(self.model.currentBet)
    else
        self.model.currentBet = 0
        self.scene:disableAllButtons()
    end
end

function C:canBet()
    if self.model.gameState ~= self.define.roomState.Betting then
        --print(
        --"###################LineCode:" ..
        --debug.getinfo(1).currentline ..
        --"@X@Function:" .. debug.getinfo(1).name .. "@X@File:" .. debug.getinfo(1).source
        --)
        return false
    end

    if self.model.bets[self.model.currentBet] > self.model.myInfo.money or self.model.myInfo.money - self.model.bets[self.model.currentBet] < self.model.needMoney then
        toastLayer:show("金币不足")
        return false
    end

    if self.model.currentBet < 1 or self.model.currentBet > #self.model.bets then
        return false
    end

    return true
end

--阻塞消息
function C:lockMsgForTime(time)
    LockMsg2()
    utils:delayInvoke(
    "bjl.lockmsg",
    time,
    function()
        UnlockMsg2()
    end
    )
end

--延迟调用
function C:delayInvoke(time, callback)
    self.scene:delayInvoke(time, callback)
end

--将金额分解成筹码
function C:money2Chips(money)
    local srcMoney = money
    local chips = {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0 }
    for i = 6, 1, -1 do
        local num = math.floor(money / self.model.bets[i])
        if num > 0 then
            chips[i] = num
        end
        money = money % self.model.bets[i]
        if money <= 0 then
            break
        end
    end
    return chips
end

function C:showCardsBack()
    for i = 1, 6 do
        self.scene:setCardImage(i, 0)
    end
end
function C:show4Cards()
    self.scene:show4Cards();
end
function C:dealCards()
    local rank = { 5, 4, 1, 2, 6, 3 }
    for i = 1, 4 do
        self.scene:dealCards(rank[i])
    end
end

function C:showCardsFace(s)
    if s.cards then
        for i = 1, 6 do
            if 0 ~= s.cards[i].color then
                self.scene:setCardImage(i, self.logic:colorNumber2Id(s.cards[i].color, s.cards[i].number))
            end
        end
    end
end

function C:setResultPoints(s)
    if s.cards then
        self.scene:setResultPoints(s.cards)
    end
end

function C:setBetLimit(s)
    for i = 1, 3 do
        if s["maxbet" .. i] then
            self.model.betLimit[i] = tonumber(s["maxbet" .. i])
        end
        if s["minbet" .. i] then
            self.model.betLimit[i + 3] = tonumber(s["minbet" .. i])
        end
    end
end

--endregion
return C