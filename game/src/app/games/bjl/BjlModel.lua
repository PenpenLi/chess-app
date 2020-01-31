--region BjlModel.lua
--Date 2019-12-14 10:16:45
local C = class("BjlModel")


C.bets = {}
C.currentBet = 1
C.lastSelectedBet = 1
C.needMoney = 10
C.betsLimit = {}

C.BuyHorseTimeLimit    = 10
C.CombineCardTimeLimit = 13
C.RestTimeTimeLimit    = 3
C.ShowCardTimeLimit    = 2


C.myBankerBet = 0
C.myPlayerBet = 0
C.myTieBet = 0
C.myBankerPairBet = 0
C.myPlayerPairBet = 0

C.allBankerBet = 0
C.allPlayerBet = 0
C.allTieBet = 0
C.allBankerPairBet = 0
C.allPlayerPairBet = 0

C.gameState = 0

--重置
function C:reset()
    self.myBankerBet = 0
    self.myPlayerBet = 0
    self.myTieBet = 0
    self.myBankerPairBet = 0
    self.myPlayerPairBet = 0

    self.allBankerBet = 0
    self.allPlayerBet = 0
    self.allTieBet = 0
    self.allBankerPairBet = 0
    self.allPlayerPairBet = 0

    self.isGaming = false
end

--通过押注金额获取押注按钮编号
function C:getBetIndex(betValue)
    for k, v in pairs(self.bets) do
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
--endregion