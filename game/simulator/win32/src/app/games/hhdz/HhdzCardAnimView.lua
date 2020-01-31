local C = class("HhdzCardAnimView",BaseLayer)

local JumpAnim = import(".HhdzJumpAnimView")
local Card = import(".HhdzPokerView")

local SCALE_RATIO = 0.45

local FLIP_TIME = 0.4
local FLIP_DELAY_TIME = FLIP_TIME/2
local SCALE_TIME = 0.3
local POS_X = {120, 240, 360, 500, 620, 740}
local POS_Y = 500

local SCALE_DELAY_TIME = 0.2
local SCALE_RECOVER_TIME = SCALE_TIME * 0.4
local SPECIAL_FLIP_TIME = SCALE_TIME + FLIP_TIME + SCALE_DELAY_TIME + SCALE_RECOVER_TIME
local ALL_TIME = FLIP_TIME + SPECIAL_FLIP_TIME * 2

local FLIP_CARD_SOUND =  GAME_HHDZ_SOUND_RES.."flipcard.mp3"
local CARD_IMG = GAME_HHDZ_IMAGES_RES.."card.png"

-- 牌的位置
local CARD_POS = {
        cc.p(568-195, display.top-52),
        cc.p(568-135, display.top-52),
        cc.p(568-75, display.top-52),
        cc.p(568+75, display.top-52),
        cc.p(568+135, display.top-52),
        cc.p(568+195, display.top-52),
    }


function C:ctor()
    C.super.ctor(self)

    self.cardsLayer = display.newNode()
    self.cardsLayer:addTo(self)

    if not self.jumpAnim then
        self.jumpAnim = JumpAnim.new()
    end
end

function C:onCreate()
    C.super.onCreate(self);
end

function C:animJump(jumpTime, data, backCards, blackCallback, redCallback)
    -- time 最早赋值
    self.jumpTime = jumpTime
    self.node = CCSpriteBatchNode:create(CARD_IMG):addTo(self.cardsLayer);

    self.showCard = {}

    self.data = data
    self.backCards = backCards
    for i, v in ipairs(backCards) do
        local x, y = v:getPositionX(), v:getPositionY()
        v:retain()
        v:removeFromParent(true)
        v:addTo(self.cardsLayer)
        v:setPosition(cc.p(x, y))
    end
    self:addFrontCard()

    self.blackCallback = blackCallback
    self.redCallback = redCallback
    self:jump(jumpTime)
end

function C:addCardsLayer(jumpTime, backCards, isCountdown, blackCallback, redCallback)
    self.allAnims = {}  --这里存所有的anims，然后生成一个node，运行一个seq，把这个丢进去
    self.jumpTime = jumpTime or 0

    self.node = CCSpriteBatchNode:create(CARD_IMG):addTo(self.cardsLayer);

    self.data = {}

    self.showCard = {}

    -- 一般来说backCards都要有的，外面传进来，即使是半途进入
    if backCards then
        if jumpTime < ALL_TIME then
            for i, v in ipairs(backCards) do
                table.insert(self.data, v.cardId)
                local x, y = v:getPositionX(), v:getPositionY()
                v:removeFromParent(true)
                if self:isFin(i) then
                    v:setVisible(false)
                end
                v:addTo(self.cardsLayer)
                v:setPosition(cc.p(x, y))
            end
            self.backCards = backCards
        else
            for _, v in ipairs(backCards) do
                v:removeFromParent(true)
            end        
        end
    end

    self.redCallback = redCallback
    self.blackCallback = blackCallback
    self:addCompleteAnim()

    -- -- 表示还剩多少时间结束的时候，需要减一下
    if isCountdown then
        self.jumpTime = self.jumpAnim:getCompleteTime() - self.jumpTime 
    end

    -- 2的位置有问题。。。移成1.8
    if self.jumpTime == 2 then
        self.jumpTime = 1.8
    elseif self.jumpTime == 3 then
        self.jumpTime = 5 * FLIP_TIME + 2 * SCALE_TIME + 0.2
    end
    self:jumpAnimAt(self.jumpTime)

end

function C:getStartIndex(jumpTime)
    local t = {1, 4, 3, 6}
    return t[jumpTime-1]
end

function C:isFinAnim(index)
    local getEndTime = function(index)
        if index == 1 or index == 2 then
            return index * FLIP_TIME
        elseif index == 4 or index == 5 then
            return (index - 1) * FLIP_TIME
        elseif index == 3 then
            return 4 * FLIP_TIME + SPECIAL_FLIP_TIME
        elseif index == 6 then
            return 4 * FLIP_TIME + SPECIAL_FLIP_TIME * 2
        else
            assert(false)
        end
    end
    return (self.jumpTime >= getEndTime(index) )
end

function C:jump(t)
    if t == 0 then
        self:jumpStartByCard(1)
    elseif t == 1 then
        self:jumpStartByCard(4)
    elseif t == 2 then
        self:jumpStartByCard(3)
    elseif t == 3 then
        self:jumpStartByCard(6)
    else
        self:jumpStartByCard(7)
    end

end

function C:jumpStartByCard(index)
    print("jumpStartByCard " .. index)
    if index == 1 then
        -- 第一张开始
        for i = 1, 6 do
            self:createFlipAnim(i)
        end
    elseif index == 4 then
        self:createFinFlip(1)
        self:createFinFlip(2)
        self:createFlipAnim(4)
        self:createFlipAnim(5)
        self:createSpecialFlip(3)
        self:createSpecialFlip(6)
    elseif index == 3 then
        self:createFinFlip(1)
        self:createFinFlip(2)
        self:createFinFlip(4)
        self:createFinFlip(5)
        self:createSpecialFlip(3)
        self:createSpecialFlip(6)
    elseif index == 6 then
        for i = 1, 5 do
            self:createFinFlip(i)
        end
        if self.blackCallback then
            self.blackCallback(false)
        end
        self:createSpecialFlip(6)
    elseif index > 6 then
        -- over
        for i = 1, 6 do
            self:createFinFlip(i)
        end
        -- 播完给true，跳完给false
        if self.redCallback then
            self.redCallback(false)
        end
        if self.blackCallback then
            self.blackCallback(false)
        end
    else
        assert(false)        
    end

    self:jumpAnimAt(0)
end

function C:getAnimTime(index)
    if index == 3 or index == 6 then
        return SPECIAL_FLIP_TIME
    else
        return FLIP_TIME
    end
end


function C:createFinFlip(index)
    self.backCards[index]:setVisible(false)
    self.showCard[index]:setVisible(true)
end

function C:createFlipAnim(index)
    if index == 3 or index == 6 then
        self:createSpecialFlip(index)
    else
        self:createCommonFlip(index)
    end
end

function C:createCommonFlip(index, scale, rightnow)
    local callback = function()
        local scale = scale or SCALE_RATIO
        local back, front = self.backCards[index], self.showCard[index]

        local backSeq = transition.sequence({CCDelayTime:create(FLIP_DELAY_TIME), CCHide:create(), CCDelayTime:create(FLIP_DELAY_TIME), CCCallFunc:create(function() back:removeFromParent(true) end)})
        local scaleBack = CCScaleTo:create(FLIP_TIME, -scale, scale)
        local spawnBack = transition.spawn({backSeq, scaleBack})
        if isFin then
            back:setVisible(false)
        else
            back:runAction(spawnBack)
        end
        local soundAnim = transition.sequence({CCDelayTime:create(0), CCCallFunc:create(function()
            PLAY_SOUND(FLIP_CARD_SOUND)
        end)})

        local frontSeq = transition.sequence({soundAnim,CCDelayTime:create(FLIP_DELAY_TIME), CCShow:create(), CCDelayTime:create(FLIP_DELAY_TIME), CCCallFunc:create(function()
                if index == 3 or index == 6 then
                    local anim = transition.sequence({ CCDelayTime:create(SCALE_DELAY_TIME), CCScaleTo:create(SCALE_RECOVER_TIME, SCALE_RATIO), CCCallFunc:create(function()
                            -- 能走回调的，肯定是播放完的，因为跳的没有动画，直接放上去了
                            if index == 3 and self.blackCallback then
                                self.blackCallback(true)
                            end
                            if index == 6 and self.redCallback then
                                self.redCallback(true)
                            end
                        end)}) 
                    self.showCard[index]:runAction(anim)
                end
            end)})
        local scaleFront = CCScaleTo:create(FLIP_TIME, scale, scale)
        local spawnFront = transition.spawn({frontSeq, scaleFront})
        front:runAction(spawnFront)
    end
    if rightnow then
        callback()
    else
        self:addNodeAnim(callback, 0, FLIP_TIME)
    end
end


function C:createSpecialFlip(index)
    local factor = 1.3
    local card = self.backCards[index]
    local anim = transition.sequence({CCScaleTo:create(SCALE_TIME, SCALE_RATIO*factor), CCCallFunc:create(function()
            self:createCommonFlip(index, SCALE_RATIO*factor, true)
        end)})
    self.jumpAnim:addOneUnitAction(card, anim, SPECIAL_FLIP_TIME)
    -- return anim
end

-- ----------------------------------------------------------------- old -----------------------------------------

function C:isFin(index)
    local isFin = false
    if index == 1 or index == 2 then
        isFin = index * FLIP_TIME <= self.jumpTime + 0.1
    elseif index == 4 or index == 5 then
        isFin = (index-1) * FLIP_TIME <= self.jumpTime + 0.1
    elseif index == 3 then
        isFin = 5 * FLIP_TIME + 2 * SCALE_TIME + 0.2 <= self.jumpTime + 0.1
    elseif index == 6 then
        isFin = self.jumpAnim:getCompleteTime() <= self.jumpTime + 0.1
    end
    return isFin 
end

function C:removeCardsLayer()
    print("remove cards layer ")
    self.jumpAnim:reset()
    local time = self.jumpTime
    self.jumpTime = 0
    if self.backCards then
        for i, v in ipairs(self.backCards) do
            v:release()
        end
    end
    self.backCards = {}
    self.cardsLayer:removeAllChildren(true)
end

function C:jumpAnimAt(time)
    self.jumpAnim:jumpAt(time)
end

function C:addCompleteAnim()
    self:addCardAnim()
end

function C:createNodeAnim(callback, time)
    local node = display.newNode():addTo(self.cardsLayer)
    local anim = transition.sequence({CCDelayTime:create(0), CCCallFunc:create(function() 
            node:removeFromParent(true) 
            if callback then
                callback() 
            end
        end)})    
    return anim
end

function C:addNodeAnim(callback, animTime, unitTime)
    -- 注意如果存在callback调用了seq，比如这里的addPrepareCardAnim，都需要和jump time判断然后算出正确的时间，因为这个callback的动画时间jump anim可管不到
    local node = display.newNode():addTo(self.cardsLayer)
    local anim = transition.sequence({CCDelayTime:create(animTime or 0), CCCallFunc:create(function() 
            node:removeFromParent(true) 
            if callback then
                callback() 
            end
        end)})
    self.jumpAnim:addOneUnitAction(node, anim, unitTime or animTime or 0)
end

function C:addRedCallback()
    if self.redCallback then
        self:addNodeAnim(function()
                self.redCallback(self.jumpTime >= ALL_TIME)
            end, 0, 0)
    end
end

function C:addBlackCallback()
    if self.blackCallback then
        self:addNodeAnim(function()
                self.blackCallback(self.jumpTime >= self.blackTime)
            end, 0, 0)
    end
end

function C:addCardAnim()
    if ALL_TIME <= self.jumpTime then
        print("all fin jump time ", self.jumpTime)
        for _, v in pairs(self.backCards) do
            v:removeFromParent(true)
        end
        if self.redCallback and self.blackCallback then
            self.redCallback(false)
            self.blackCallback(false)
        end
        self:addFrontCard(true)
    else
        self:addFrontCard(false)
        self:addFlipAnim(1)
        self:addFlipAnim(2)
        self:addFlipAnim(4)
        self:addFlipAnim(5)
        self:addSpecialFlipAnim(3)
        self.blackTime = self.jumpAnim:getCompleteTime()
        self:addBlackCallback()
        self:addSpecialFlipAnim(6)
        self:addRedCallback()
    end
    
end

function C:addSpecialFlipAnim(index)
    local isFin 
    if index == 3 then
        isFin = 5 * FLIP_TIME + 2 * SCALE_TIME + 0.2 <= self.jumpTime
    else
        isFin = ALL_TIME <= self.jumpTime
    end

    local factor = 1.3
    local card = self.backCards[index]
    local anim1 = CCScaleTo:create(SCALE_TIME, SCALE_RATIO*factor) 

    self.jumpAnim:addOneUnitAction(card, anim1, SCALE_TIME)

    self:addFlipAnim(index, isFin and SCALE_RATIO or SCALE_RATIO*factor)
    local waitTime = isFin and 0.2 or 0.2
    self:addNodeAnim(function()
            print("wait anim >>>>")
        end, 0.2, 0.2)

    local card2 = self.showCard[index]
    local anim2 = transition.sequence({CCScaleTo:create(SCALE_RECOVER_TIME, SCALE_RATIO), CCCallFunc:create(function()
            if index == 3 or index == 6 then
                print(self.showCard[3]:getScaleX())
            end
        end)})
    self.jumpAnim:addOneUnitAction(card2, anim2, SCALE_TIME)
end

function C:addFlipAnim(index, scale)
    local isFin = self:isFin(index)
    local time = isFin and 0 or FLIP_TIME
    print("show time index time", index, time)

    local func = function()
        local scale = scale or SCALE_RATIO
        local back, front = self.backCards[index], self.showCard[index]
        local dt = FLIP_DELAY_TIME

        local backSeq = transition.sequence({CCDelayTime:create(dt), CCHide:create(), CCDelayTime:create(dt), CCCallFunc:create(function() back:removeFromParent(true) end)})
        local scaleBack = CCScaleTo:create(dt, -scale, scale)
        local spawnBack = transition.spawn({backSeq, scaleBack})

        print("index isvisible ",index, back:isVisible())
        if isFin then
            print("set visible2 " .. index)
            back:setVisible(false)
        else
            back:runAction(spawnBack)
        end

        -- 这里flipx没用是因为只是flip了bg，而没有flip里面的梅花，这是组合精灵，需要自己写
        local frontSeq = transition.sequence({CCDelayTime:create(dt), CCShow:create(), CCDelayTime:create(dt)})
        local scaleFront = CCScaleTo:create(dt, scale, scale)
        local spawnFront = transition.spawn({frontSeq, scaleFront})

        if not isFin then
            print("front run " .. index)
            front:runAction(spawnFront)
        end
    end
    -- self.jumpAnim:addOneUnitAction(self.backCards[index], CCScaleTo:create(FLIP_TIME, 0.1), FLIP_TIME)
    self:addNodeAnim(func, 0, FLIP_TIME)
end

function C:addShowAnim(index, scale)
    local func = function()
        local card = self.backCards[index]
        local pos = cc.p(card:getPositionX(),card:getPositionY())
        card:removeFromParent(true)
        card = self:createCard(pos, self.data[index])
        local value = scale or SCALE_RATIO
        card:setScale(value)
        local anim = CCScaleTo:create(time, value, -value)
        self.jumpAnim:addOneUnitAction(card, anim, FLIP_TIME2)
        table.insert(self.showCard, index, card)
    end
    self:addNodeAnim(func, FLIP_TIME2)
end

function C:addFrontCard(isFin)
    for i = 1, 6 do
        local pos = CARD_POS[i]
        local card = self:createCard(pos, self.data[i])

        card:setScale(SCALE_RATIO)

        if not self:isFinAnim(i) then
            card:runAction(CCSpeed:create(CCScaleTo:create(0, -SCALE_RATIO, SCALE_RATIO), 100))
        end
        table.insert(self.showCard, card)
    end
end

function C:addBackCard()
    self.backCards = {}
    for i = 1, 6 do
        local back = Card.new(self.cardsLayer, CARD_POS[i], i)
        back:setScale(SCALE_RATIO)
        table.insert(self.backCards, back)
    end
end

function C:createCard(pos, id)
    local c = Card.new(self.node, pos, id, true)
    return c
end
return C