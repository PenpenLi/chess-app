local Card = import(".CPDdzPokerView")
local C = class("CPDdzSelectCards",Card)

function C:ctor(...)
	self.super.ctor(self,...)
	self:createSelectFlag()
end

function C:onTouch(event, x, y)
	if not self.canTouch then
		return false;
	end
	local pos = self:convertToNodeSpace(cc.p(x, y))
	if event == "began" then
		local boxSize = self.bg:getBoundingBox()
		 if cc.rectContainsPoint(boxSize,pos) then
			 if self.up then
				 self:downCard();
			 else
				 self:upCard();
			 end
			 return true;
		 end 
	elseif event == "ended" then
	elseif event == "moved" then
	end
	
	return false
end

function C:downCard()
	if self.up then
		self.up = false
		self.canTouch = true;
        self.delegate:unSelectCard(self.id,self);

		if self.selectFlag then
			self.selectFlag:setVisible(false)
		end
	end 
end 

function C:upCard()
	if not self.up then 
		self.up = true;
        self.canTouch = true;
        self.delegate:selectCard(self.id,self);

		if self.selectFlag then
			self.selectFlag:setVisible(true)
		end
	end
end 

function C:setSelectFlag(isShow)
    if not self.selectFlag then
        self:createSelectFlag()
    end

	if isShow then
		self.up = false
		self:upCard()
	else
		self.up = true
		self:downCard()
	end
end

function C:createSelectFlag()
    if not self.selectFlag then
        local bg = display.newSprite(GAME_CPDDZ_IMAGES_RES .. "lordbb_selected_flag.png")
        bg:align(display.RIGHT_TOP, bg:getContentSize().width/2, bg:getContentSize().height/2);
		bg:addTo(self)
		bg:setVisible(false)
		self.selectFlag = bg
    end
end

return C