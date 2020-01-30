--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local C = class("CPDdzModel")

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "ddz"

C.myInfo = nil
C.mySeat = 0

C.myCards = {}
C.blindCards = {}
C.isLord = false
C.dizhuSeat = 0
C.isMyTurn = false
C.isTuoGuan = false
C.playerInfos = {}
C.logKey = nil
C.remainCards = {}
C.myShowCards = nil
C.selectedCards = nil
C.jiaoFen = 0
C.autoShowCard = false
C.lastCards = nil
C.isGaming = false
C.gameId = nil
C.exchangeInCards = {}
C.gameState = 0

--重置数据
function C:reset()
    self.myInfo = {}
    self.mySeat = 0

    self.myCards = {}
    self.blindCards = {}
    self.isLord = false
    self.lordSeat = 0
    self.isMyTurn = false
    self.playerInfos = {}
    self.logKey = nil
    self.remainCards = {}
    self.myShowCards = nil
    self.selectedCards = nil
    self.jiaoFen = 0
    self.autoShowCard = false
    self.lastCards = nil
    self.isGaming = false
    self.isTuoGuan = false
    self.exchangeInCards = {}
    self.gameState = 0
end

--设置玩家信息
function C:setPlayerInfo(info)
    self.playerInfos[info.playerid] = info
end

--获取玩家信息
function C:getPlayerInfo(playerid)
    return self.playerInfos[playerid]
end

--通过本地座位号获取玩家信息
function C:getPlayerInfoBySeat(seat)
    for k,v in pairs(self.playerInfos) do
        if vertexBuffer.localSeat == seat then
            return v
        end
    end
end

--将出牌从手牌中移除
function C:removeMyCards(cards)
    for k,v in pairs(cards) do 
        for k2,v2 in pairs(self.myCards) do
            if v == v2 then
                self.myCards[k2] = nil
            end
        end
    end
end

--记牌器减少一张牌
function C:minusRemainCard(card,num)
    if card == 2 then
        card = 13
    elseif card == 15 then
        card = 14
    elseif card == 16 then
        card = 15
    else
        card = card - 2
    end
    if not num then
        num = 1
    end
    self.remainCards[card] = self.remainCards[card] - num
end

--设置记牌器
function C:setRemainCard(card,num)
    if card == 2 then
        card = 13
    elseif card == 15 then
        card = 14
    elseif card == 16 then
        card = 15
    else
        card = card - 2
    end
    self.remainCards[card] = num
end

--重置记牌器
function C:resetRemainCard(mycards)
    self.remainCards = {}
    for i = 1,13 do
        self.remainCards[i] = 4
    end
    self.remainCards[14] = 1
    self.remainCards[15] = 1
    if mycards then
        for k,v in pairs(mycards) do
            self:minusRemainCard(v.cardnumber)
        end
    end
end

--是否与我本地出牌相同
function C:isSameShowCards(cards)
    if cards == nil then
        return false
    end
    if self.myShowCards == nil then
        return false
    end
    for k,v in pairs(cards) do
        local contain = false
        for k2,v2 in pairs(self.myShowCards) do
            if v == v2 then
                contain = true
                break
            end
        end
        if not contain then
            return false
        end
    end
    return true
end

-- 是否与我本地牌相同
function C:isSameCards(cards)
    if cards == nil then
        return false
    end
    if self.myCards == nil then
        return false
    end
    for k,v in pairs(cards) do
        local contain = false
        for k2,v2 in pairs(self.myCards) do
            if v == v2 then
                contain = true
                break
            end
        end
        if not contain then
            return false
        end
    end
    return true
end


return C

--endregion
