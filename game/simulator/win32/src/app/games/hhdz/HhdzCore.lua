local C = class("HhdzCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.hhdz"
--场景配置
C.SCENE_CONFIG = {scenename = "hhdz_scene", filename = "HhdzScene", logic="HhdzLogic", define="HhdzDefine", model="HhdzModel"}

C.preform = false

function C:ctor(roomInfo)
	C.super.ctor(self,roomInfo)
end

function C:start()
    --注册协议
    self:registerAll()
    self.model.myInfo.seat = 7
    C.super.start(self)
end

function C:exit()
	--注销协议
    self:unregisterAll()
	C.super.exit(self)
end

function C:registerAll()
    self:registerGameMsg(self.define.proto.SC_HH_GAMESTATE_P,  handler(self,self.s2cSetGameState));     --游戏状态
    self:registerGameMsg(self.define.proto.SC_HH_BET_P,  handler(self,self.s2cBet));                    --玩家下注
    self:registerGameMsg(self.define.proto.SC_HH_FOLLOW_BUY_P,  handler(self,self.s2cFollowBet));       --续投返回
    self:registerGameMsg(self.define.proto.SC_HH_HISTORY_P,  handler(self,self.s2cHistory));            --返回历史信息
    self:registerGameMsg(self.define.proto.SC_HH_PLAYERLIST_P,  handler(self,self.s2cPlayerList));      --返回玩家列表信息
    self:registerGameMsg(self.define.proto.SC_HH_JIESUAN_P,  handler(self,self.s2cSettlement));         --结算
    self:registerGameMsg(self.define.proto.SC_HH_ERROR_P,  handler(self,self.s2cError));                --错误信息
    self:registerGameMsg(self.define.proto.SC_HH_DESK_PLAYER_P,  handler(self,self.s2cDeskPlayers));    --上桌的玩家
    self:registerGameMsg(self.define.proto.SC_HH_BET_END_P,  handler(self,self.s2cBetEnd));             --同步下注信息
end

function C:unregisterAll()
    self:unregisterGameMsg(self.define.proto.SC_HH_GAMESTATE_P);        --游戏状态
    self:unregisterGameMsg(self.define.proto.SC_HH_BET_P);              --玩家下注
    self:unregisterGameMsg(self.define.proto.SC_HH_FOLLOW_BUY_P);       --续投返回
    self:unregisterGameMsg(self.define.proto.SC_HH_HISTORY_P);          --返回历史信息
    self:unregisterGameMsg(self.define.proto.SC_HH_PLAYERLIST_P);       --返回玩家列表信息
    self:unregisterGameMsg(self.define.proto.SC_HH_JIESUAN_P);          --结算
    self:unregisterGameMsg(self.define.proto.SC_HH_ERROR_P);            --错误信息
    self:unregisterGameMsg(self.define.proto.SC_HH_DESK_PLAYER_P);      --上桌的玩家
    self:unregisterGameMsg(self.define.proto.SC_HH_BET_END_P);          --同步下注信息
end

--region S2C Common
    
--玩家进入房间
function C:onPlayerEnter(s)
    -- printInfo("<==================玩家进入==================>")
    --dump(s,nil,10)
end

--房间信息
function C:onRoomInfo(s)
    -- printInfo("<==================房间信息==================>")
end

--房间状态
function C:onRoomState(s)
    -- printInfo("<==================房间状态==================>")
end

--玩家退出
function C:onPlayerQuit(s)
    -- printInfo("<==================玩家退出==================>")
    --dump(s,nil,10)
end

--玩家被踢
function C:onDeletePlayer(s)
    -- printInfo("<==================玩家被踢==================>")
    C.super.onDeletePlayer(self,s)
end

function C:onQuitGame(info)
	dump(info,"onQuitGame>>>")
	if SCENE_NAME ~= "Hall" then
		local reason=info["sxreason"]
		if reason==4 then
			DialogLayer.new():show("您被踢出房间", function()
				self:quitGame();
			end, false);
		end
    end
end

--断线重连
function C:onToOtherRoom(s)
    printInfo("<==================断线重连==================>")
    dump(s,"onToOtherRoom",10)

    self.scene:clean()

    self.model.needMoney = s.BetNeed
    self.model.bets = s.Bet
    self.model.gameState = s.state

    --桌面玩家
    local desks = s.deskInfo.desks
    if desks then
        for i=1,5 do
            if desks[i] then
                desks[i].seat = i
                self.scene:showPlayer(i,desks[i])
            end
        end
        if s.deskInfo.lucky then
            self.scene:showPlayer(6,s.deskInfo.lucky)
            s.deskInfo.lucky.seat = 6
            self.model:addPlayerInfo(s.deskInfo.lucky)
        end
        self.model:setPlayerInfos(desks)
    end
    self.model:addPlayerInfo(self.model.myInfo)

    --下注按钮
    local bets = {}
    for k,v in pairs(s.Bet) do
        bets[k] = v / MONEY_SCALE
    end
    self.scene:setBetValues(bets)
    self.model.currentBet = 1
    self:updateAllButtons()

    --下注区 
    self.model.myRedBet = (s.dirction1 or 0) / MONEY_SCALE
    self.model.myBlackBet = (s.dirction2 or 0) / MONEY_SCALE
    self.model.myLuckyBet = (s.dirction3 or 0) / MONEY_SCALE

    self.model.allRedBet = (s.dirctionall1 or 0)
    self.model.allBlackBet = (s.dirctionall2 or 0)
    self.model.allLuckyBet = (s.dirctionall3 or 0)

    self.scene:setMyRedBet(self.model.myRedBet)
    self.scene:setMyBlackBet(self.model.myBlackBet)
    self.scene:setMyLuckyBet(self.model.myLuckyBet)

    self.scene:setAllRedBet(self.model.allRedBet / MONEY_SCALE)
    self.scene:setAllBlackBet(self.model.allBlackBet / MONEY_SCALE)
    self.scene:setAllLuckyBet(self.model.allLuckyBet / MONEY_SCALE)

    if s.state == self.define.roomState.Betting or (s.state == self.define.roomState.Result and s.TimeLeft and s.TimeLeft >= 1) then
        local chips = nil

        if s.dirctionall1 and s.dirctionall1 > 0 then
            chips = self:money2Chips(s.dirctionall1)
            for k,v in pairs(chips) do
                for i=1,v do
                    self.scene:throwChip(8,1,k,false,false)
                end
            end
        end
 
        if s.dirctionall2 and s.dirctionall2 > 0 then
            chips = self:money2Chips(s.dirctionall2)
            for k,v in pairs(chips) do
                for i=1,v do
                    self.scene:throwChip(8,2,k,false,false)
                end
            end
        end

        if s.dirctionall3 and s.dirctionall3 > 0 then
            chips = self:money2Chips(s.dirctionall3)
            for k,v in pairs(chips) do
                for i=1,v do
                    self.scene:throwChip(8,3,k,false,false)
                end
            end
        end
    end

    --剩余时间
    if s.TimeLeft and s.state == self.define.roomState.Betting then
        self.scene:startTimer(math.floor(s.TimeLeft)-1)
        self.isGaming = true
    end
    --历史记录
    self.logic:initTrends({winner = s.HistoryWin,cardType = s.HistoryPX})
    self.scene:createTrend()

    --扑克牌
    if s.state == self.define.roomState.Betting or s.state == self.define.roomState.Wait then
        self.scene:createCards()
    elseif s.state == self.define.roomState.Result then
        local cards = {}
        for i=1,3 do
            local black = s.cards.hei[i]
            local red = s.cards.hong[i]
            cards[i] = self.logic:colorNumber2Id(black.color,black.number)
            cards[3+i] = self.logic:colorNumber2Id(red.color,red.number)
        end
        local types = {s.cards.hei.px,s.cards.hong.px}
        local showCardTime = math.floor(math.max(4 - s.TimeLeft,0))
        self:delayInvoke(math.max(s.TimeLeft-4,0),function()
            self.scene:cleanCards()
            self.scene:showCards(cards,types,showCardTime,nil)
        end)
    end

    --请耐心等待下一局开始...
    if s.state == self.define.roomState.Result or s.state == self.define.roomState.Rest then
        self.scene:showWaiting()
    end

    self.preform = false

   if s["HistoryPX"] and s["HistoryWin"] then
       self.scene:reloadHistory(s["HistoryWin"],s["HistoryPX"])
   end
end

--更新金币
function C:updatePlayerMoney(s)
    C.super.updatePlayerMoney(self,s)
    local info = self.model:getPlayerInfo(s.playerid)
    if info then
        self.scene:setMoney(info.seat,s.coin)
    end
    if s.playerid == self.model.myInfo.playerid then
        if self.model.currentBet <= 0 then
            self.model.currentBet = 1
        end
        self.model.myInfo.money = s.coin
        self:updateAllButtons()
    end
end

--结算
function C:onSettlement(s)
    -- printInfo("<==================显示结算==================>")
end

--endregion

--region S2C Game

function C:s2cSetGameState(s)
    -- printInfo("<==================游戏状态==================>")
    --dump(s,nil,10)   
    self.model.gameState = s.state
    if s.state == self.define.roomState.Betting then
        self.model.currentBet = self.model.lastSelectedBet
    end
    self:updateAllButtons()
    if s.state == self.define.roomState.Wait then
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
        self.scene:hideWaiting()
        self.scene:startTimer(math.floor(s.TimeLimit.BetTime)-1)
        self.model.betTime = s.TimeLimit.BetTime
        self.model.settlementTime = s.TimeLimit.JieSuanTime
        self.model.showTime = s.TimeLimit.ShowTime
        self.model.waitTime = s.TimeLimit.WaitTime
        self.model.isGaming = false
    elseif s.state == self.define.roomState.Result then
        --停止下注:距离结算还有5秒
        local time = self.scene:playStopBetAnim()
        local cards = {}
        for i=1,3 do
            local black = s.cards.hei[i]
            local red = s.cards.hong[i]
            cards[i] = self.logic:colorNumber2Id(black.color,black.number)
            cards[3+i] = self.logic:colorNumber2Id(red.color,red.number)
        end
        local types = {s.cards.hei.px,s.cards.hong.px}
        self:delayInvoke(time,function()
            self.scene:showCards(cards,types,0,function(time)
                --等待结算协议...
            end)
        end)
    elseif s.state == self.define.roomState.Rest then
        printInfo("休息一下:"..os.date("%Y-%m-%d %H:%M:%S"))
        self.model.isGaming = false
    end
end

function C:s2cBet(s)
    -- printInfo("<==================玩家下注==================>")

    local seat = 8
    local info = self.model:getPlayerInfo(s.playerid)

    if info then
        seat = info.seat
    end

    local betIndex = self.model:getBetIndex(s.bet)
    if not betIndex then
        betIndex = 1
    end

    --如果是神算子玩家也在富豪榜上，优先从神算子头像下注，如果神算子是自己，那么从自己头像下注，从神算子头像飞星星
    local isShensuanzi = false
    if self.scene.players[6] and self.scene.players[6].playerInfo and self.scene.players[6].playerInfo.playerid == s.playerid then
        isShensuanzi = true
    end
    if isShensuanzi and s.playerid ~= self.model.myInfo.playerid then
        seat = 6
    end

    --判断自己是否已经预先表现了
    if s.playerid ~= self.model.myInfo.playerid or not self.preform then
        self.scene:throwChip(seat,s.target,betIndex,true,true)
    end

    --服务器没有告诉自己下注了多少，需要自己统计
    if s.playerid == self.model.myInfo.playerid then
        if s.target == HhdzDefine.betType.Black then
            self.model.myBlackBet = self.model.myBlackBet + s.bet / MONEY_SCALE
            self.scene:setMyBlackBet(self.model.myBlackBet)
        elseif s.target == HhdzDefine.betType.Red then
            self.model.myRedBet = self.model.myRedBet + s.bet / MONEY_SCALE
            self.scene:setMyRedBet(self.model.myRedBet,self.define.betType.Red)
        elseif s.target == HhdzDefine.betType.Lucky then
            self.model.myLuckyBet = self.model.myLuckyBet + s.bet / MONEY_SCALE
            self.scene:setMyLuckyBet(self.model.myLuckyBet,self.define.betType.Lucky)
        end

        --更新押注按钮
        self.model.myInfo.money = s.money
        self:updateAllButtons()

        self.model.isGaming = true
    end

    --显示并累加已经扔过筹码的下注总额，因为在同步下注信息的时候，由于存在时间差有可能会多扔金币
    local betAll = s.dirctionall / MONEY_SCALE
    if s.target == HhdzDefine.betType.Black then
        self.scene:setAllBlackBet(betAll)
        self.model.allBlackBet = self.model.allBlackBet + s.bet
    elseif s.target == HhdzDefine.betType.Red then
        self.scene:setAllRedBet(betAll)
        self.model.allRedBet = self.model.allRedBet + s.bet
    elseif s.target == HhdzDefine.betType.Lucky then
        self.scene:setAllLuckyBet(betAll)
        self.model.allLuckyBet = self.model.allLuckyBet + s.bet
    end

    --更新玩家金币
    local player = self.model:getPlayerInfo(s.playerid)
    if player then
        self.scene:setMoney(player.seat,s.money)
    end

    --更新神算子金币（有可能神算子/大富豪都是自己）
    if isShensuanzi then
        self.scene:setMoney(6,s.money)
    end

    if s.playerid == self.model.myInfo.playerid then
        self.scene:setMoney(7,s.money)
    end

    --神算子，扔星星，有可能自己是神算子
    if seat == 6 or isShensuanzi then
        self.scene:flyLuckyStar(s.target,true)
    end
end

function C:s2cFollowBet(s)
    -- printInfo("<==================续投返回==================>")
end

function C:s2cHistory(s)
    -- printInfo("<==================历史信息==================>")
    dump(s,"s2cHistory",10)
    if s["HistoryPX"] and s["HistoryWin"] then
        self.scene:reloadHistory(s["HistoryWin"],s["HistoryPX"])
        self.model.lastRefreshHistoryTime = os.time()
    end
end

function C:s2cPlayerList(s)
    -- printInfo("<==================玩家列表信息==================>")
    local list = {}
    for i,v in ipairs(s) do
        list[i] = v
    end
    self.scene:setPlayerList(list)
end

function C:s2cSettlement(s)
    printInfo("<==================结算==================>")
    -- dump(s,"s2cSettlement",10)

    --统计中奖座位号
    local numberSeats = nil
    local chipSeats = nil
    if s.data then
        numberSeats = {}
        chipSeats = {}
        for k,v in pairs(s.data) do
            if v.nChange ~= 0 then
                local seat = 8
                local player = self.model:getPlayerInfo(v.playerid)
                if player then
                    seat = player.seat
                    table.insert(numberSeats,{seat = seat,money = v.nChange})
                end
                if v.nChange > 0 then
                    chipSeats[seat] = 1
                end
            end
        end
        chipSeats = table.keys(chipSeats)
    end

    local function callback()
        if numberSeats or chipSeats then
            self.scene:getChips(numberSeats,chipSeats)
            self.scene:updateTrend()
        end
    end

    --闪烁中奖区域，完成后在回调里飞回筹码
    if s.win == 1 then
        self.scene:showRedWinBlink(callback)
    else
        self.scene:showBlackWinBlink(callback)
    end
    if s.xyyj > 0 then
        self.scene:showLuckyWinBlink()
    end

    --添加到历史纪录
    self.logic:addTrend(s.win,s.wintype)
    if s.win and s.wintype then
        self.scene:addHistory(s.win,s.wintype)
    end

    --由于走势图不能自己移除多余走势结果，暂每30分钟清理一次
    --local nowTime = os.time()
    --if nowTime-self.model.lastRefreshHistoryTime >= 30*60 then
    --    self:c2sHistory()
    --end

    self.model.isGaming = false
end

function C:s2cError(s)
    -- printInfo("<==================错误信息==================>")
    --dump(s,"错误信息")
    local code = s["code"]
    if code == self.define.errorCode.OneFaction then
        toastLayer:show("不能同时在红黑方下注！")
    elseif code == self.define.errorCode.NotEnoughMoney then
        toastLayer:show("没有足够的钱下注")
    elseif code == self.define.errorCode.NoMoney then
        toastLayer:show("没有达到下注的最低要求")
    end    

end

function C:s2cDeskPlayers(s)
    -- printInfo("<==================上桌的玩家==================>")

    local desks = s.desks
    for i=1,5 do
        desks[i].seat = i
        self.scene:showPlayer(i,desks[i])
    end
    self.scene:showPlayer(6,s.lucky)

    s.lucky.seat = 6
    self.model:setPlayerInfos(desks)
    self.model:addPlayerInfo(s.lucky)
    self.model:addPlayerInfo(self.model.myInfo)
end

function C:s2cBetEnd(s)
    -- printInfo("<==================同步下注信息==================>")

    self.scene:setAllRedBet((s.dirctionall1 or 0) / MONEY_SCALE)
    self.scene:setAllBlackBet((s.dirctionall2 or 0) / MONEY_SCALE)
    self.scene:setAllLuckyBet((s.dirctionall3 or 0) / MONEY_SCALE)

    local chips = nil

    if s.cache1 and s.cache1 > 0 then
        local realCache = math.max(s.dirctionall1 - self.model.allRedBet,0)
        self.model.allRedBet = s.dirctionall1
        chips = self:money2Chips(realCache)
        for k,v in pairs(chips) do
            for i=1,v do
                self.scene:throwChip(8,1,k,true,false)
            end
        end
    end

    if s.cache2 and s.cache2 > 0 then
        local realCache = math.max(s.dirctionall2 - self.model.allBlackBet,0)
        self.model.allBlackBet = s.dirctionall2
        chips = self:money2Chips(realCache)
        for k,v in pairs(chips) do
            for i=1,v do
                self.scene:throwChip(8,2,k,true,false)
            end
        end
    end

    if s.cache3 and s.cache3 > 0 then
        local realCache = math.max(s.dirctionall3 - self.model.allLuckyBet,0)
        self.model.allLuckyBet = s.dirctionall3
        chips = self:money2Chips(realCache)
        for k,v in pairs(chips) do
            for i=1,v do
                self.scene:throwChip(8,3,k,true,false)
            end
        end
    end
end

--endregion

--region C2S

--下注
function C:c2sBet(betValue,betType)
    self:sendGameMsg(self.define.proto.CS_HH_BET_P, {bet = betValue, target = betType})
end

--续投
function C:c2sFollowBet()
    self:sendGameMsg(self.define.proto.CS_HH_FOLLOW_BUY_P)
end

--请求历史信息
function C:c2sHistory()
    self:sendGameMsg(self.define.proto.CS_HH_HISTORY_P)
end

--请求玩家列表
function C:c2sPlayerList()
    self:sendGameMsg(self.define.proto.CS_HH_PLAYERLIST_P)
end

--endregion

--region UI Event

--押注黑方
function C:blackBet()
    
    if not self:canBet() then
        return
    end

    if self.model.myRedBet > 0 then
        toastLayer:show("不能同时在红黑方下注！")
        return
    end

    self.scene:throwChip(7,self.define.betType.Black,self.model.currentBet,true,true)
    self:c2sBet(self.model:getCurrentBetValue(),self.define.betType.Black)
    self.preform = true
end

--押注红方
function C:redBet()
    if not self:canBet() then
        return
    end

    if self.model.myBlackBet > 0 then
        toastLayer:show("不能同时在红黑方下注！")
        return
    end

    self.scene:throwChip(7,self.define.betType.Red,self.model.currentBet,true,true)
    self:c2sBet(self.model:getCurrentBetValue(),self.define.betType.Red)
    self.preform = true
end

--押注幸运一击
function C:luckyBet()
    if not self:canBet() then
        return
    end

    self.scene:throwChip(7,self.define.betType.Lucky,self.model.currentBet,true,true)
    self:c2sBet(self.model:getCurrentBetValue(),self.define.betType.Lucky)
    self.preform = true
end

--endregion

--region Other

function C:updateAllButtons()

    if self.model.gameState ~= self.define.roomState.Betting then
        self.scene:disableAllButtons()
        return
    end
    
    for i = #self.model.bets,1,-1 do
        local enable = self.model.bets[i] <= self.model.myInfo.money and  self.model.myInfo.money >= self.model.needMoney
        self.scene:enableBetButton(i,enable)
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
        return false
    end

    if self.model.bets[1] > self.model.myInfo.money or  self.model.myInfo.money < self.model.needMoney then
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
    utils:delayInvoke("hhdz.lockmsg",time, function()
        UnlockMsg2()
    end)
end

--延迟调用
function C:delayInvoke(time,callback)
    self.scene:delayInvoke(time,callback)
end

--将金额分解成筹码
function C:money2Chips(money)
    local srcMoney = money
    local chips = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}
    for i=5,1,-1 do
        local num = math.floor(money / self.model.bets[i])
        if num > 0 then
            chips[i] = num
        end
        money = money % self.model.bets[i]
        if money <= 0 then
            break
        end
    end
    if chips[3] > 1 and chips[2] < 5 then
        chips[3] = chips[3]-1
        chips[2] = chips[2]*5
    end
    if chips[2] > 1 and chips[1] < 5 then
        chips[2] = chips[2]-1
        chips[1] = chips[1]*10
    end
    return chips
end

--endregion

return C