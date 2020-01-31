local C = class('Poker', function()  return display.newSprite("#bg_front.png") end)

C.cardtype=1    --牌图集有两种，1为整张牌，2为散件牌，需要重新组装的

function C:ctor( parent, position, cardId, isFront ) 
	self:setPosition(cc.p(position.x,position.y))
	self:addTo(parent)

	self.cardId = cardId

	if isFront then
		self:createFront()
	else
		self:createBack()
	end
end

function C:createFront()
	self:removeAllChildren(true)

	if self.cardtype==1 then
		--整张牌
		self:createOverAllCard()
	elseif self.cardtype==2 then
		--散件牌
		self:createPartCard()
	end
end

function C:createOverAllCard()
	local width = self:getContentSize().width
	local height = self:getContentSize().height

	local color = self:getShapeById()
	local number = self:getValueNumById()
	local sprite = display.newSprite("#" .. color .."_".. number .. ".png")
	sprite:addTo(self)
	sprite:setPosition(cc.p(width / 2, height / 2))
end

function C:createPartCard()
	local width = self:getContentSize().width
	local height = self:getContentSize().height

	-- top value
	local valueSp = display.newSprite("#" .. self:getValueColorGroupById() .. self:getValueNumResById() .. ".png")
	valueSp:setPosition(cc.p(5 + valueSp:getContentSize().width / 2, height - valueSp:getContentSize().height / 2 - 5))
	valueSp:addTo(self)

	-- main shape
	local mainImg = ""
	local mainSpPosition = cc.p(0,0)
	local scale = 1

	if self:getValueNumById() >= 11  and self:getValueNumById() <= 13 then
		mainImg = "#" .. "role_" .. self:getShapeById() .. "_" .. self:getValueCharById() .. ".png"
		mainSpPosition = cc.p(width / 2, height / 2)
	else
		local detail = ""
		if self:getShapeById() == HhdzDefine.cardColors.Diamond then
			detail = "diamond"
		elseif self:getShapeById() == HhdzDefine.cardColors.Club then
			detail = "club"
		elseif self:getShapeById() == HhdzDefine.cardColors.Heart then
			detail = "heart"
		elseif self:getShapeById() == HhdzDefine.cardColors.Spade then
			detail = "spade"	
		end

		mainImg = "#" .. "shape_" .. detail .. ".png"
		mainSpPosition = cc.p(width - 80 / 2, 82 / 2)
		scale = 0.7
	end

	local mainSp = display.newSprite(mainImg)
	mainSp:setPosition(cc.p(mainSpPosition.x,mainSpPosition.y + 3))
	mainSp:addTo(self)
	mainSp:setScale(scale)

	-- title shape
	local titleImg = ""
	
	if self:getShapeById() == HhdzDefine.cardColors.Diamond then
		titleImg = "diamond_s"
	elseif self:getShapeById() == HhdzDefine.cardColors.Club then
		titleImg = "club_s"
	elseif self:getShapeById() == HhdzDefine.cardColors.Heart then
		titleImg = "heart_s"
	elseif self:getShapeById() == HhdzDefine.cardColors.Spade then
		titleImg = "spade_s"	
	end

	local titleSp = display.newSprite("#" .. "shape_" .. titleImg .. ".png")
	titleSp:setPosition(cc.p(5 + titleSp:getContentSize().width / 2,valueSp:getPositionY() - valueSp:getContentSize().height / 2 - 23))
	titleSp:addTo(self)
	titleSp:setScale(0.7)
end

function C:createBack()
	self:removeAllChildren(true)

	local width = self:getContentSize().width
	local height = self:getContentSize().height

	local bg = display.newSprite("#bg_back.png")
	bg:setPosition(cc.p(width / 2, height / 2))
	bg:addTo(self)
end

function C:getShapeById()
	return math.floor((self.cardId - 1) / 13)
end

function C:getValueCharById()
	return HhdzDefine.cardValues[(self.cardId - 1) % 13]
end

function C:getValueNumById()
	return (self.cardId - 1) % 13 + 1
end

function C:getValueNumResById()
	return self:getValueNumById()
end

function C:getValueColorGroupById()
    if self:getShapeById() == HhdzDefine.cardColors.Diamond or self:getShapeById() == HhdzDefine.cardColors.Heart then
    	return "num_red_"
    elseif self:getShapeById() == HhdzDefine.cardColors.Club or self:getShapeById() == HhdzDefine.cardColors.Spade then
    	return "num_black_"
    end
end

return C