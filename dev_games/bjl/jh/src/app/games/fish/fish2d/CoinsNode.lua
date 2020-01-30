--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--炮台旁边的堆金币效果

----------------------------------CoinsNode 单列金币--------------------------------------------

local CoinsNode = class("CoinsNode",cc.Node)

local MAX_COIN = 40
local isRed = true

function CoinsNode:ctor()
    self.label_coin_ = nil
    self.spr_coin_ = {}
    self.mCoinBg = nil

    self:initNode()
end

function CoinsNode:initNode()
    for i = 0,MAX_COIN-1 do
        self.spr_coin_[i] = cc.Sprite:createWithSpriteFrameName("jinbi.png")
        self.spr_coin_[i]:setAnchorPoint(cc.p(0.5, 0))
		self.spr_coin_[i]:setVisible(false)
		self.spr_coin_[i]:setPosition(cc.p(0, 5 * i - 15))
		self:addChild(self.spr_coin_[i])
    end
    
    if isRed == true then
        self.mCoinBg = cc.Sprite:createWithSpriteFrameName("coinBg_red.png")
		isRed = false
    else
        self.mCoinBg = cc.Sprite:createWithSpriteFrameName("coinBg_green.png")
		isRed = true
    end
    self:addChild(self.mCoinBg)

    self.label_coin_ = cc.LabelAtlas:_create()
    self.label_coin_:initWithString("100", "games/fish/bmfonts/font_jinbishuzi.png", 14, 19, string.byte("."))
	self.label_coin_:setVisible(false)
	self:addChild(self.label_coin_)
end


function CoinsNode:show_coin(count,score)
    if count >= MAX_COIN then
        count = MAX_COIN
    end
    for i=0,MAX_COIN-1 do
        self.spr_coin_[i]:setVisible(false)
        self.spr_coin_[i]:stopAllActions()
    end

    self.mCoinBg:setAnchorPoint(cc.p(0.5, 0.5))
	self.mCoinBg:setPosition(cc.p(0, 5 * count + 5))
	self.mCoinBg:setVisible(false)

    local showStr = ""
--    if score >= 1000 then
--        showStr = string.format("%d/", score / 1000)
--    else
--        showStr = string.format("%d", score)
--    end
    showStr = utils:moneyString(score, 2)
	self.label_coin_:setString(showStr)
	self.label_coin_:setVisible(false)
	self.label_coin_:setAnchorPoint(cc.p(0.5, 0.5))
	--< +的是字的高度
	self.label_coin_:setPosition(cc.p(0, 5 * count + 5))
        
    for i = 0,count-1 do
		local act

		if (i == count - 1) then
			act = cc.Sequence:create(
				cc.DelayTime:create(0.3 + (i + 1) * 0.02),
				cc.Show:create(),
				cc.CallFunc:create(function ()
                    self.label_coin_:setVisible(true)
--                    self.mCoinBg:setVisible(true)
                  end),
				nil);
		else
			act = cc.Sequence:create(
				cc.DelayTime:create(0.3 + (i + 1) * 0.02),
				cc.Show:create(),
				nil);
		end

		self.spr_coin_[i]:runAction(act);
	end
    

end

function CoinsNode:skewNode()
    local degree = self.label_coin_:getRotationSkewY()
	if (degree<=1) then
		self.label_coin_:setRotationSkewY(180)
	end
end


----------------------------------CoinsNode 多列（一堆）金币--------------------------------------------

local CoinsNodeX = class("CoinsNodeX",cc.Node)

local MAX_COIN_POS = 3

function CoinsNodeX:ctor()
    self.coins_ = {}
    self.using_ = {}
    self.m_currntSkewState = false

    self:initNode()
end

function CoinsNodeX:initNode()

    for i=0,MAX_COIN_POS-1 do
        local coin = CoinsNode:create()
        self:addChild(coin)
        coin:setVisible(false)
        table.insert(self.coins_,coin)
    end
    
end

function CoinsNodeX:show_coin_animtion(count, score, needSkew)
    local node;
    local delayShow = 0.001
    self.m_currntSkewState = needSkew

    if #self.coins_ <= 0 then
        self:pop_front()
        delayShow = 0.3
    end

    node = table.remove(self.coins_,1)
    table.insert(self.using_ ,node)

    local pos = #self.using_ - 1
    node:show_coin(count,score)

    node:setPosition(cc.p(self:get_coin_pos(pos), 0))
	if (pos == 0) then
		node:setVisible(true)
		node:runAction(cc.Sequence:create(
			cc.DelayTime:create(3),
			cc.CallFunc:create(function ()
                 self:pop_front()
              end),
			nil))
	else
		node:setVisible(false)
		node:runAction(cc.Sequence:create(
			cc.DelayTime:create(delayShow),
			cc.Show:create(),
			nil))
	end

end

function CoinsNodeX:pop_front()
    if #self.using_ <= 0 then
        return    
    end

    local node = table.remove(self.using_,1)
    node:stopAllActions()
    node:setVisible(false)
    table.insert(self.coins_,node)

    local pos = 0

    for i,v in pairs(self.using_) do
        local tmp = self.using_[i]
        tmp:stopAllActions()
		tmp:setVisible(true)
		local offset = self:get_coin_pos(pos)
		if (pos == 0) then
			tmp:runAction(cc.Sequence:create(
				cc.MoveTo:create(0.3, cc.p(offset, 0)),
				cc.DelayTime:create(3),
				cc.CallFunc:create(function ()
                        self:pop_front()
                    end),
				nil))
		else
			tmp:runAction(cc.MoveTo:create(0.3, cc.p(offset, 0)))
		end

		pos = pos + 1
    end
end


function CoinsNodeX:get_coin_pos(pos)
    local repos = 0
    if self.m_currntSkewState == true then
        if pos == 0 then
            repos = 0
        elseif pos == 2 then
            repos = -80
        else
            repos = -40
        end
    else
        if pos == 0 then
            repos = 0
        elseif pos == 2 then
            repos = 80
        else
            repos = 40
        end
    end
    return repos
end

return CoinsNodeX

--endregion
