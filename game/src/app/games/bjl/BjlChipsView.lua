--region BjlChipsView.lua
--Date 2019-12-16 13:56:08
local C = class("BjlChipsView", ViewBaseClass)

local CHIP_ANIM_MAX_NUM = device.platform == "android" and 60 or 80

local CHIPS_BACK_SOUND_TAGS = { 8881, 8882 }

local CHIP_SOUND = GAME_BJL_SOUND_RES .. "bet.mp3"
local CHIP_WIN_SOUND = GAME_BJL_SOUND_RES .. "win_bet.mp3"

local CHIP_SIZE = {
    width = 57,
    height = 57
}

local PLAYERS_POS = {
    [1] = { x = 70, y = 50 },
    [2] = { x = 70, y = 165 }
}

local CHIPS_CSB = {
    [1] = GAME_BJL_PREFAB_RES .. "Chip1.csb",
    [2] = GAME_BJL_PREFAB_RES .. "Chip2.csb",
    [3] = GAME_BJL_PREFAB_RES .. "Chip3.csb",
    [4] = GAME_BJL_PREFAB_RES .. "Chip4.csb",
    [5] = GAME_BJL_PREFAB_RES .. "Chip5.csb",
    [6] = GAME_BJL_PREFAB_RES .. "Chip6.csb"
}

C.BINDING = {
    bankerAreaCon = { path = "banker_area_con", events = { { event = "touch", method = "onBankerBet" } } },
    playerAreaCon = { path = "player_area_con", events = { { event = "touch", method = "onPlayerBet" } } },
    tieAreaCon = { path = "tie_area_con", events = { { event = "touch", method = "onTieBet" } } },
    bankerPairAreaCon = { path = "banker_pair_area_con", events = { { event = "touch", method = "onBankerPairBet" } } },
    playerPairAreaCon = { path = "player_pair_area_con", events = { { event = "touch", method = "onPlayerPairBet" } } }
}

C.bets = nil
C.chipsPool = {}
C.usingChips = {}
C.betAreas = nil
C.chipSize = nil
C.updateScheduler = nil
C.flyChips = nil

--初始化
function C:ctor(node, bets)
    self.bets = bets
    self.curChipAnimNum = 0
    self.usingChips = {}
    C.super.ctor(self, node)
end

function C:onCreate()
    self.betAreas = {
        [1] = self.bankerAreaCon:getBoundingBox(),
        [2] = self.playerAreaCon:getBoundingBox(),
        [3] = self.tieAreaCon:getBoundingBox(),
        [4] = self.bankerPairAreaCon:getBoundingBox(),
        [5] = self.playerPairAreaCon:getBoundingBox()
    }
    self:createChipsPool(self.bets)
    self.flyChips = {}
    self.updateScheduler =    cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.updateChip), 0, false)
end

function C:destroy()
    self.flyChips = {}
    self.flyChipsCallback = nil
    if self.updateScheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateScheduler)
        self.updateScheduler = nil
    end
end

function C:insertFlyChips(chipNode)
    if self.flyChips == nil then
        self.flyChips = {}
    end
    if self.updateScheduler == nil then
        self.updateScheduler =        cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.updateChip), 0, false)
    end
    table.insert(self.flyChips, chipNode)
end

function C:updateChip()
    if self.flyChips and #self.flyChips > 0 then
        local chipNode = table.remove(self.flyChips, 1)
        self:chipAction(chipNode, chipNode.fromPos, chipNode.toPos)
    end
end

--押注莊家
function C:onBankerBet(event)
    if event.name == "ended" then
        if self.onBankerBetHandler then
            self.onBankerBetHandler()
        end
    end
end

--押注閑家
function C:onPlayerBet(event)
    if event.name == "ended" then
        if self.onPlayerBetHandler then
            self.onPlayerBetHandler()
        end
    end
end

--押注和局
function C:onTieBet(event)
    if event.name == "ended" then
        if self.onTieBetHandler then
            self.onTieBetHandler()
        end
    end
end

--押注莊对子
function C:onBankerPairBet(event)
    if event.name == "ended" then
        if self.onBankerPairBetHandler then
            self.onBankerPairBetHandler()
        end
    end
end

--押注闲对子
function C:onPlayerPairBet(event)
    if event.name == "ended" then
        if self.onPlayerPairBetHandler then
            self.onPlayerPairBetHandler()
        end
    end
end

--创建筹码对象池
function C:createChipsPool(bets)
    if bets and type(bets) == "table" then
        self.bets = bets
        self.chipsPool = {}
        for i, v in ipairs(bets) do
            local chips = {}
            for m = 1, 6 do
                local chip = self:createChip(i)
                if chip then
                    chip:setVisible(false)
                    table.insert(chips, chip)
                end
            end
            self.chipsPool[i] = chips
        end
    end
end

--创建筹码
function C:createChip(index)
    local chip = cc.CSLoader:createNode(CHIPS_CSB[index])
    if not chip then
        print("无法创建筹码对象：[" .. tostring(index) .. "]")
        return nil
    end
    chip:setTag(index)
    chip:retain()
    if not self.chipSize then
        self.chipSize = chip:getBoundingBox()
    end
    local text = self.bets[index]
    chip:getChildByName("bg"):getChildByName("text"):setString(tostring(text))
    chip:addTo(self.node)
    return chip
end

--获取一个未使用的筹码
function C:getFreeChip(betIndex, isAnim, isDesk)
    if isAnim then
        if not isDesk then
            if self.curChipAnimNum > CHIP_ANIM_MAX_NUM then
                return nil
            end
        end
        self.curChipAnimNum = self.curChipAnimNum + 1
    end
    if not self.chipsPool[betIndex] then
        self.chipsPool[betIndex] = {}
    end
    if #self.chipsPool[betIndex] <= 0 then
        local chip = self:createChip(betIndex)
        table.insert(self.usingChips, chip)
        self:setChipRotation(chip)
        chip:setLocalZOrder(#self.usingChips)
        return chip
    end

    local count = #self.chipsPool[betIndex]
    for _index = count, 1, -1 do
        local v = self.chipsPool[betIndex][_index]
        self:setChipRotation(v)
        v:setLocalZOrder(#self.usingChips)
        v:setVisible(true)
        table.remove(self.chipsPool[betIndex], _index)
        table.insert(self.usingChips, v)
        return v
    end

    printError("<===============什么情况？出错了？=================>")

    return nil
end

--回收筹码到对象池
function C:cleanChips()
    self.flyChips = {}
    local count = #self.usingChips
    for _index = count, 1, -1 do
        local v = self.usingChips[_index]
        local index = v:getTag()
        v:setVisible(false)
        table.insert(self.chipsPool[index], v)
        table.remove(self.usingChips, _index)
    end

    self.curChipAnimNum = 0

    for k, tagIndex in ipairs(CHIPS_BACK_SOUND_TAGS) do
        local node = self.node:getChildByTag(tagIndex)
        if node then
            node:stopAllActions()
            node:removeFromParent(true)
        end
    end
end

--筹码飞回到玩家位置
function C:chipsBack(callBack)
    if #self.usingChips < 1 then
        if callBack then
            callBack()
        end
        return
    end
    -- chips
    local chips = self.usingChips
    local speed = 1000
    local delayGap = 0.015

    delayGap = 0.58 / #chips
    speed = 1300 + #chips * 2.05
    speed = math.min(1500, speed)

    local curIndex = #chips
    local curNum = #chips

    for m = #chips, 1, -1 do
        local chip = chips[m]
        local chipX = chip:getPositionX()
        local chipY = chip:getPositionY()
        local endPos = PLAYERS_POS[2]
        local time = cc.pGetDistance(cc.p(chipX, chipY), endPos) / speed
        local movePart1 = CCEaseIn:create(CCMoveBy:create(0.2, cc.p((chipX - endPos.x) / 15, (chipY - endPos.y) / 10)), 0.4)
        local movePart2 = CCEaseOut:create(CCMoveTo:create(time, cc.p(endPos.x, endPos.y)), 0.8)
        local delay = CCDelayTime:create(delayGap * (curIndex - m))
        local callFun =        CCCallFunc:create(
        function()
            chip:setVisible(false)
            curNum = curNum - 1
            if curNum == 0 then
                self:cleanChips()
                if callBack then
                    callBack()
                end
            end
        end
        )
        local seq = transition.sequence({ delay, movePart1, movePart2, callFun })
        chip:runAction(seq)
    end
    PLAY_SOUND(CHIP_WIN_SOUND)
end

function C:cleanAll()
    self.flyChips = {}
    for k, v in pairs(self.chipsPool) do
        for k2, v2 in pairs(v) do
            v2:release()
            v2:removeFromParent(true)
        end
    end
    self.chipsPool = {}
    for k, v in pairs(self.usingChips) do
        v:release()
        v:removeFromParent(true)
    end
    self.usingChips = {}
end

--筹码飞往下注区
function C:chipGo(seatIndex, betIndex, pos, isAnim, isDesk, playSound, callback)
    local chip = self:getFreeChip(betIndex, isAnim, isDesk)
    if chip == nil then
        print("************************************超过最大限制**************************************")
        return
    end

    if not isAnim then
        chip:setScale(1)
        chip:setVisible(true)
        chip:setPosition(pos)
        return
    end
    if playSound then
        PLAY_SOUND(CHIP_SOUND)
    end
    self.flyChipsCallback = callback
    if seatIndex == 2 then
        chip:setVisible(false)
        chip.fromPos = PLAYERS_POS[seatIndex]
        chip.toPos = pos
        self:insertFlyChips(chip)
    else
        self:chipAction(chip, PLAYERS_POS[seatIndex], pos)
    end
end
--筹码自转动作
function C:chipAction(chipNode, fromPos, toPos)
    chipNode:setPosition(fromPos)
    chipNode:setVisible(true)
    chipNode:setScale(0.8)
    local distance = cc.pGetLength(cc.pSub(fromPos, toPos)) --cc.pGetDistance(fromPos, toPos)
    local speed = 2000
    local time = distance / speed
    local time2 = math.min(0.1, time)
    local seq = cc.ScaleTo:create(time2, 1.2)
    local move = cc.MoveTo:create(time, toPos)
    local scale = cc.ScaleTo:create(0.05, 1)
    local seq2 = transition.sequence({ move, scale })
    local spawn = transition.spawn({ seq, seq2 })
    transition.execute(
    chipNode,
    spawn,
    {
        onComplete = function()
            self.curChipAnimNum = self.curChipAnimNum - 1
        end
    }
    )
    if self.flyChipsCallback then
        self.flyChipsCallback()
    end
end

--设置随机角度
function C:setChipRotation(chip)
    local rotation = math.random(-70, 70)
    chip:setRotation(rotation)
end

--获取下注区域的一个随机位置
function C:getChipFinalPos(area)
    local rect = self.betAreas[area]
    local startPosX = rect.x
    local startPosY = rect.y

    local width = rect.width
    local height = rect.height

    local basePosX = startPosX + width / 2
    local basePosY = startPosY + height / 2

    local chipWidth = CHIP_SIZE.width / 2
    local chipHeight = CHIP_SIZE.height / 2

    local finalPosX = 0
    local finalPosY = 0

    finalPosX = math.random(startPosX + chipWidth, startPosX + width - chipWidth)
    finalPosY = math.random(startPosY + chipHeight * 1.5, startPosY + height - chipHeight * 1.5)

    return cc.p(finalPosX, finalPosY)
end

return C
--endregion