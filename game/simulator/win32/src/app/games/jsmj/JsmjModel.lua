--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local C = class("JsmjModel")
local JsmjTile = import(".JsmjTile")
local bit = require("bit")

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "jsmj"

C.myInfo = nil
C.mySeat = 0

C.tiles_ = {}
C.myCards = {} --玩家手牌
C.userStatus = {}
C.topLeftNum = 0 --上家的牌数量
C.bankerSeat = 0 --庄家座位
C.curSeat = 1 --当前操作的玩家座位
C.isTuoGuan = false --是否托管状态
C.playerInfos = {} --同桌玩家信息
C.diceNum1 = 1 --骰子1点数 
C.diceNum2 = 1 --骰子2点数
C.leftCardNum = 10 --剩余牌数量
C.outTime = 1 --出牌时间
C.trustTime = 2 --托管时间
C.isGaming = false --是否游戏已经开始
C.playerCount = 2 --玩家数量
C.huFan = 0 --是否能胡牌
C.hasTing = false --是否有听
C.tingInfo = nil --听牌数据
C.chaTinged = false --是否点击了查听按钮
C.winSeat = 0 

C.drawAnimFlag_ = false-- 标记是否播放过抓牌动画

C.awardTiles_ = { }
C.hitTiles_ = { }
C.outCard = {{}, {}}

C.myDispatchCard = 0
C.myOutCard = nil
C.chaTingOutId = nil
C.chaTingOutValue = nil


--重置数据
function C:reset()
    self.myInfo = {}
    self.mySeat = 0

    self.tiles_ = {} -- 自己手牌
    self.myCards = {} --玩家手牌
    self.userStatus = {}
    self.topLeftNum = 0
    self.bankerSeat = 0 --庄家座位
    self.curSeat = 1
    self.isTuoGuan = false --是否托管状态
--    self.playerInfos = {} --同桌玩家信息
    self.diceNum1 = 1 --骰子1点数 
    self.diceNum2 = 1 --骰子2点数
    self.leftCardNum = 0
    self.outTime = 1 --出牌时间
    self.trustTime = 2 --托管时间
    self.isGaming = false
    self.playerCount = 2 --玩家数量
    self.huFan = 0
    self.hasTing = false
    self.tingInfo = nil
    self.chaTinged = false
    self.drawAnimFlag_ = false

    self.awardTiles_ = { }
    self.hitTiles_ = { }
    self.outCard = {{}, {}}

    self.myDispatchCard = 0
    self.myOutCard = nil
    self:removeAllTiles()

    self.chaTingOutId = nil
    self.chaTingOutValue = nil
    self.winSeat = 0

    --self.blindCards = {}

    --self.remainCards = {}
    --self.myShowCards = nil
--    self.selectedCards = nil
--    self.autoShowCard = false
--    self.lastCards = nil
end

function C:reConnect()
    self.myInfo = {}

    self.tiles_ = {} -- 自己手牌
    self.myCards = {} --玩家手牌
    self.topLeftNum = 0
    self.bankerSeat = 0 --庄家座位
    self.curSeat = 1
    self.isTuoGuan = false --是否托管状态
    self.diceNum1 = 1 --骰子1点数 
    self.diceNum2 = 1 --骰子2点数
    self.leftCardNum = 0
    self.outTime = 1 --出牌时间
    self.trustTime = 2 --托管时间
    self.isGaming = false
    self.playerCount = 2 --玩家数量
    self.huFan = 0
    self.hasTing = false
    self.tingInfo = nil
    self.chaTinged = false
    self.drawAnimFlag_ = false

    self.awardTiles_ = { }
    self.hitTiles_ = { }

    self.outCard = {{}, {}}

    self.myDispatchCard = 0
    self.myOutCard = nil
    self:removeAllTiles()

    self.chaTingOutId = nil
    self.chaTingOutValue = nil
    self.winSeat = 0
end

--设置玩家信息
function C:setPlayerInfo(info)
    self.playerInfos[info.playerid] = info
end

--获取玩家信息
function C:getPlayerInfo(playerid)
    return self.playerInfos[playerid]
end

function C:getMyLocal()
    return self:getLocalSeat(self.mySeat)
end

function C:getBankerLocal()
    return self:getLocalSeat(self.bankerSeat)
end

function C:getCurLocal()
    return self:getLocalSeat(self.curSeat)
end

function C:isMyTurn()
    return self.curSeat == self.mySeat
end

function C:getFlowerTileNumber()
    return 5
end
function C:getAwardFlowerAllTiles()
    return self.awardTiles_
end
function C:getAwardFlowerHitTiles()
    return self.hitTiles_
end
--获取本地座位
function C:getLocalSeat(seat)
    if seat < 1 or seat > self.playerCount then
        printInfo("座位ID不正确")
    end
    local s = seat - self.mySeat
	if s < 0 then
		s = s + self.playerCount
	end
	return s+1
end

function C:getMaxTileNumber()
    return 5
end

function C:getTileNumber(seat)
    if seat == self:getMyLocal() then
        return #self.myCards
    else
        return topLeftNum
    end
end

function C:getPlayerCount()
    return self.playerCount
end

function C:getTiles()
    return self.tiles_
end

function C:setDrawAnimFlag(flag)
    self.drawAnimFlag_ = flag
end

--添加自家手牌数据
function C:addTile(tile)
    if tile ~= nil then
        table.insert(self.tiles_, tile)
        table.sort(self.tiles_, self.sortTileGroup)
    end
end

function C.sortTileGroup(a, b)
    if a and b then
        if a.value_ == b.value_ then
            return a.id_ < b.id_
        else
            return a.value_ < b.value_
        end
    end
end

--添加自家手牌数据
function C:addTileById(id)
    if id > 0 then
        table.insert(self.tiles_, JsmjTile.new(id))
    end
end

--从手牌中减去多张牌
function C:removeTiles(list)
    if list ~= nil then
        for k, v in ipairs(list) do
            self:removeTile(v)
        end
    end
end

-- 从手牌中减去单张牌
function C:removeAllTiles()
    self.tiles_ = { }
end

function C:removeTile(id)
    local delIndex = -1
    for k, v in pairs(self.tiles_) do
        if self.tiles_[k].id_ == id then
            delIndex = k
            break
        end
    end
    if delIndex ~= -1 then
        table.remove(self.tiles_, delIndex)
    end
end

function C:getTileIdByValue(value)
    local delIndex = -1
    for i=#self.tiles_,1,-1 do
        if self.tiles_[i].value_ == value then
            return self.tiles_[i].id_
        end
    end
end

--通过座位号获取玩家信息
function C:getPlayerInfoBySeat(seat)
    for k,v in pairs(self.playerInfos) do
        if v.seat == seat then
            return v
        end
    end
end

--将出牌从手牌中移除
function C:removeMyCards(card)
    for k,v in pairs(self.myCards) do
        if bit.band(v,0x00FF) == card then
            table.remove(self.myCards, k)
            break
        end
    end
end

function C:isCanHu()
    return self.huFan > 0
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

function C:setDrawAnimFlag(flag)
    self.drawAnimFlag_ = flag
end

function C:getDrawAnimFlag()
    return self.drawAnimFlag_
end

function C:addOutTileById(seat, id)
    table.insert(self.outCard[seat], JsmjTile.new(id))
end

return C

--endregion
