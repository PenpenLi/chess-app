local C = class("HhdzModel")

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "hhdz"

C.needMoney = 0
C.bets = {}
C.currentBet = 3
C.lastSelectedBet = 3
C.playerInfos = {}

C.betTime = 15
C.settlementTime = 6
C.showTime = 5
C.waitTime = 3

C.myBlackBet = 0
C.myRedBet = 0
C.myLuckyBet = 0

C.allBlackBet = 0
C.allRedBet = 0
C.allLuckyBet = 0

C.gameState = 0

C.lastRefreshHistoryTime = 0

--重置
function C:reset()
    self.myBlackBet = 0
    self.myRedBet = 0
    self.myLuckyBet = 0

    self.allBlackBet = 0
    self.allRedBet = 0
    self.allLuckyBet = 0

    self.isGaming = false
end

--设置玩家信息
function C:setPlayerInfos(infos)
    self.playerInfos = infos
end

--添加玩家信息
function C:addPlayerInfo(info)
    table.insert(self.playerInfos,info)
end

--获取玩家信息
function C:getPlayerInfo(playerid)
    for k,v in pairs(self.playerInfos) do
        if v.playerid == playerid then
            return v
        end
    end
    return nil
end

--通过押注金额获取押注按钮编号
function C:getBetIndex(betValue)
    for k,v in pairs(self.bets) do
        if v == betValue then
            return k
        end
    end
    return nil
end

--获取当前押注金额
function C:getCurrentBetValue()
    if self.bets and self.currentBet then
        return self.bets[self.currentBet]
    end
    return nil
end

return C
