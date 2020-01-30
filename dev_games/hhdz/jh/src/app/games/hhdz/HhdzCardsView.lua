local C = class("HhdzCardsView", ViewBaseClass)

local CardAnimLayer =  import(".HhdzCardAnimView")
--local Card = import(".HhdzPokerView")

-- 牌的位置
BLACK_CARD_POS = 
{
    {x = 568 - 195, y = display.top - 52},
    {x = 568 - 135, y = display.top - 52},
    {x = 568 - 75, y = display.top - 52}
}

RED_CARD_POS = 
{
    {x = 568 + 195, y = display.top - 52},
    {x = 568 + 135, y = display.top - 52},
    {x = 568 + 75, y = display.top - 52}
}

local SENDCARD_SOUND = GAME_HHDZ_SOUND_RES.."sendcard.mp3"

local SINGLE_SOUND = GAME_HHDZ_SOUND_RES.."single.mp3"
local PAIRS_SOUND = GAME_HHDZ_SOUND_RES.."pairs.mp3"
local STRAIGHT_SOUND = GAME_HHDZ_SOUND_RES.."straight.mp3"
local FLUSH_SOUND = GAME_HHDZ_SOUND_RES.."gold_flower.mp3"
local STRAIGHT_FLUSH_SOUND = GAME_HHDZ_SOUND_RES.."straight_gold.mp3"
local THREE_KING_SOUND = GAME_HHDZ_SOUND_RES.."panther.mp3"

C.BINDING = 
{
    
}

function C:ctor(node)
	C.super.ctor(self,node)
	self:initData()
end

function C:onCreate()
    -- batchNode
    self.cardsBatch = CCSpriteBatchNode:create(GAME_HHDZ_IMAGES_RES .. "card.png")
    self.cardsBatch:addTo(self.node)

    -- anim
	self.cardAnimLayer = CardAnimLayer.new()
	self.cardAnimLayer:addTo(self.node)

	-- cardType
	self.cardTypesNode = display.newNode()
	self.cardTypesNode:addTo(self.node)
end

function C:clean()
    self:cleanCards()
end

function C:initData()
	self.cards = {}
end


-- 发牌
function C:sendCards()
	self:createCardsWithAnim(true)
	self:createCardsWithAnim(false)
end

-- 开牌
function C:showCards( cardIds, cardTypes, countDown, callBack )

	if cardIds and type(cardIds) == "table" and cardTypes and type(cardTypes) == "table" then

		local beforeTime = os.time()

		if #self.cards == 0 then
			self:createCards(true)
			self:createCards(false)
		end

		if #self.cards > 0 then
			local cards = clone(self.cards)
			self.cards = {}

			local jumpCallBack = function ( isAnim, isBlackCard )
				local cardType = HhdzDefine.cardType.Invalid

				if isBlackCard then
					cardType = cardTypes[1]
				else
					cardType = cardTypes[2]
				end
				
				self:showCardType(cardType,isBlackCard,isAnim,function (  )
					if not isBlackCard then
						if callBack then
							callBack(os.time() - beforeTime)
						end
					end
				end)
			end

			self.cardAnimLayer:animJump(countDown,cardIds,cards,function (isAnim)
				jumpCallBack(isAnim,true)
			end,function ( isAnim )
				jumpCallBack(isAnim,false)
			end)
		end
	end
end

-- 创牌 带动画
function C:createCardsWithAnim( isBlackCard )
	local startPos = cc.p(568, 640 - 52)
	local posArray = nil

	if isBlackCard then
		posArray = BLACK_CARD_POS
	else
		posArray = RED_CARD_POS
	end

	for i = 1,3 do
		local endPos = cc.p(posArray[i].x, posArray[i].y)
		local speed = 900
		local moveTime = math.abs(endPos.x - startPos.x) / speed
		local delayTime = 0

		local card = display.newSprite("#bg_back.png")
		card:setScale(0.45)
		card:setPosition(cc.p(startPos.x,startPos.y))
		card:addTo(self.cardsBatch)

		if isBlackCard then
			delayTime = 0
			card:setLocalZOrder(3 - (i - 1) * 2)
			table.insert(self.cards, card)
		else
			delayTime = moveTime
			card:setLocalZOrder(3 - (i - 1) * 2 - 1)
			table.insert(self.cards, 4, card)
		end

		if i > 1 then
			for m = 1,i - 1 do
				local lastEndPos = cc.p(posArray[m].x, posArray[m].y)
				local lastTime = math.abs(lastEndPos.x - startPos.x) / speed
				delayTime = delayTime + lastTime * 2
			end
		end

		local delay = CCDelayTime:create(delayTime)
		local callFun = CCCallFunc:create(function (  )
			PLAY_SOUND(SENDCARD_SOUND)
		end)
		local move = CCMoveTo:create(moveTime, endPos)
		local seq = transition.sequence({delay,callFun,move})

		card:runAction(seq)
	end
end

-- 创牌
function C:createCards( isBlackCard )
	local posArray = nil

	if isBlackCard then
		posArray = BLACK_CARD_POS
	else
		posArray = RED_CARD_POS
	end

	for i = 1,3 do
		local card = display.newSprite("#bg_back.png")
		card:setScale(0.45)
		card:setPosition(cc.p(posArray[i].x, posArray[i].y))
		card:addTo(self.cardsBatch)

		if isBlackCard then
			table.insert(self.cards, card)
		else
			table.insert(self.cards, 4, card)
		end
	end
end

-- 展示牌型
function C:showCardType(cardType, isBlackCard, isAnim, callBack)
	local pos = nil

	if isBlackCard then
		pos = cc.p(BLACK_CARD_POS[2].x, BLACK_CARD_POS[2].y - 25)
	else
		pos = cc.p(RED_CARD_POS[2].x, RED_CARD_POS[2].y - 25)
	end

	self:showCardTypeEffect(self.cardTypesNode,cardType,pos,isAnim,callBack)
end

--播放牌型特效
function C:showCardTypeEffect( parent, cardType, pos, isAnim, callBack )

    local node = display.newNode()
	node:setPosition(pos)
	node:addTo(parent)

	local spStr = ""
	local isPar = true
	local soundRes = -1

	if cardType == HhdzDefine.cardType.Single then -- 单张
		spStr = "card_type_single.png"
		isPar = false
		soundRes = SINGLE_SOUND
	elseif cardType == HhdzDefine.cardType.Pair or cardType == HhdzDefine.cardType.Pair9A then -- 对子
		spStr = "card_type_pairs.png"
		soundRes = PAIRS_SOUND
	elseif cardType == HhdzDefine.cardType.Straight then -- 顺子
		spStr = "card_type_straight.png"
		soundRes = STRAIGHT_SOUND
	elseif cardType == HhdzDefine.cardType.Flush then -- 金花
		spStr = "card_type_gold_flower.png"
		soundRes = FLUSH_SOUND
	elseif cardType == HhdzDefine.cardType.StraightFlush then -- 顺金
		spStr = "card_type_straight_gold.png"
		soundRes = STRAIGHT_FLUSH_SOUND
	elseif cardType == HhdzDefine.cardType.ThreeKind then -- 豹子
		spStr = "card_type_panther.png"
		soundRes = THREE_KING_SOUND
	end
	
	local sp = display.newSprite(GAME_HHDZ_IMAGES_RES .. spStr)
	sp:addTo(node)

	if isAnim then
		sp:setOpacity(0)

		local delay = CCDelayTime:create(0.2)
		local fadenIn = CCFadeIn:create(0.3)
		local callFun1 = CCCallFunc:create(function (  )
			if isPar then
				local particle = CCParticleSystemQuad:create(GAME_HHDZ_ANIMATION_RES .. "star01.plist")
		    	particle:setAutoRemoveOnFinish(true)
		    	particle:setPosition(cc.p(0,0))
		    	particle:addTo(node)
		    	particle:setScale(0.4)
	    	end
		end)
		local callFun2 = CCCallFunc:create(function (  )
			if callBack then
				callBack()
			end
		end)

		local seq = transition.sequence({delay,callFun1})
		local spawn = transition.spawn({seq,fadenIn})

		sp:runAction(transition.sequence({spawn,callFun2}))

		if soundRes ~= -1 then
			PLAY_SOUND(soundRes)
		end
	else
		if callBack then
			callBack()
		end
	end
end

--清理扑克牌
function C:cleanCards()
    if self.cardAnimLayer then
	    self.cardAnimLayer:removeCardsLayer()
    end
    if self.cardTypesNode then
	    self.cardTypesNode:removeAllChildren(true)
    end
    if self.cardsBatch then
        self.cardsBatch:removeAllChildren(true)
    end
	self.cards = {}
end

return C