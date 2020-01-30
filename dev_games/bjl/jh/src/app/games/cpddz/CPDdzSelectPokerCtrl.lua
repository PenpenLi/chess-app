local C = class("CPDdzSelectPokerCtrl")
local Card = import(".CPDdzSelectCards")

function C:ctor(info)
    self.selectCards = info.selectCards
    self.cardsParent = info.cardsParent
    self.timeOut = info.timeOut
    self.countDownCallBack = info.countDownCallBack
    self.canTouch = info.canTouch
    self.updateSelectDataCallBack = info.updateSelectDataCallBack
    self.interval = info.interval or 110
    self.selectData = {}
    for i , v in ipairs(self.selectCards) do
        self.selectData[v] = false
    end
    self.cards = {}
    self:initCards(self.selectCards)
    self:initTouchLayou()

    if info.isStartTimer then
        self:initCountDown()
    end
end

function C:initCards(selectCards)
    local startX = -110
    for i , id in ipairs(selectCards) do
        local card = Card.new({
            id = id,
            delegate = self,
            canTouch = self.canTouch,
        })
        self.cardsParent:addChild(card)
        card:setPosition(cc.p(startX + (i - 1) * self.interval, 0 ))
        card:setScale(0.75)
        table.insert(self.cards,card)
    end
end

function C:initTouchLayou()
    self.layer = display.newLayer()
    self.layer:setTouchEnabled(self.canTouch)
    self.layer:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end, false, 0, false)
    self.cardsParent:addChild(self.layer)
end

function C:onTouch(event,x,y)
    if event == "began" then
        local cards = self:getSelectCardNodes()
        local val = false
        for i , node in ipairs(cards) do
            val = val or node:onTouch(event,x,y)
        end
        return val
    end

    return false;
end

function C:initCountDown()
    local passTime = 0
    utils:createTimer("cpddz.ddzSelectPokerCtrlCount",0.2,function()
        passTime = passTime + 0.2
        if self.countDownCallBack then
            self.countDownCallBack(passTime,self.timeOut)
        end
        if passTime >= self.timeOut then
            utils:removeTimer("cpddz.ddzSelectPokerCtrlCount")
        end
    end)
end

function C:getSelectData()
    local data = {}
    for id , v in pairs(self.selectData) do
        if v then
            table.insert(data,id)
        end
    end
    return data
end

function C:getSelectCardNodes()
    return self.cards
end

function C:selectCard(cardId,obj)
    self.selectData[cardId] = true
    --  obj:setSelectFlag(true)

    if self.updateSelectDataCallBack then
        self.updateSelectDataCallBack()
    end
end

function C:unSelectCard(cardId,obj)
    self.selectData[cardId] = false
    -- obj:setSelectFlag(false)

    if self.updateSelectDataCallBack then
        self.updateSelectDataCallBack()
    end
end

function C:exit()
    utils:removeTimer("cpddz.ddzSelectPokerCtrlCount")
    if self.layer then
        self.layer:setTouchEnabled(false)
        self.layer:removeFromParent(true)
    end
end

return C