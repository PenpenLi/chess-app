local C = class("Card",cc.Node)

local BLACK_JOKER = 53;
local RED_JOKER = 54;

local SUIT = 
{
	DIAMOND = 0,
	CLUB = 1,
	HEART = 2,
	SPADE = 3,
};

local COLOR = {
	WHITE = cc.c3b(255, 255, 255),
	BLACK = cc.c3b(0, 0, 0),
	RED = cc.c3b(255, 0, 0),
	GRAY = cc.c3b(128, 128, 128),
    BLUE = cc.c3b(44, 66, 115),
	YELLOW = cc.c3b(255, 222, 0),
	GREEN = cc.c3b(201, 255, 148),
	GREEN_DARK = cc.c3b(68, 145, 41),
	DDZ_GRAY = cc.c3b(131, 142, 160),
	DDZ_GREEN = cc.c3b(0, 145, 13),
	COUNT_GRAY = cc.c3b(131, 142, 160),
	COUNT_GREEN = cc.c3b(0, 145, 13),
    TEXT_BLUE = cc.c3b(62, 149, 147),
    TEXT_BLUE_LIGHT = cc.c3b(109, 222, 245),
}

function C:ctor(params)

    assert(type(params) == "table","Card invalid params");
    self.delegate = params.delegate;
    self.id = params.id;
	self.canTouch = params.canTouch or not params.bottom;
	self.showIdx = params.showIdx or -1;
	self.anim = params.anim or false;
	self.isLord = params.isLord or false;
	self.lastCard = params.lastCard or false;
	self.playing = params.playing or false;
	self.up = false;
	self.isSelect = false;
	self.sound = false;
	self.animVector = {};

	local bg = display.newSprite(params.bottom and "#card_bg_s.png" or "#card_bg.png")
	bg:align(display.RIGHT_TOP, bg:getContentSize().width/2, bg:getContentSize().height/2);
	bg:addTo(self);
	self.bg = bg;

    self:createCard(params.id, bg, params.bottom);

    if self.isLord and self.lastCard  then
    	 local lordIcon = display.newSprite("#card_lordland.png");
    	 lordIcon:align(display.RIGHT_BOTTOM, bg:getContentSize().width - 2, 2);
    	 self:showAnmition(lordIcon);
    	 lordIcon:addTo(bg);
    end 

	local shadow = display.newSprite(params.bottom and "#card_bg_s.png" or "#card_bg.png");
	shadow:setColor(COLOR.BLACK);
	shadow:setOpacity(64);
	shadow:align(display.LEFT_BOTTOM, 0, 0);
	shadow:addTo(bg, 10);
	shadow:hide();
	self.shadow = shadow;

	if params.isBlind then
		bg:setPosition(cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2 + 50));
		local seq = transition.sequence({
				CCDelayTime:create(0.2),
				CCMoveTo:create(0.3, cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2)),
			})
		bg:runAction(seq);
	end 
end

function C:createCard(id, bg, isBottom)
	local w = bg:getContentSize().width;
	local h = bg:getContentSize().height;

	self:showAnmition(bg, true);

	if id == RED_JOKER then
		local image = isBottom and "red_joker_s.png" or "red_joker.png" 
		local card = display.newSprite("#"..image);
		card:setPosition(cc.p(w/2, h/2));
		card:addTo(bg);
		self:showAnmition(card);
	elseif id == BLACK_JOKER then 
		local image = isBottom and "black_joker_s.png" or "black_joker.png" 
		local card = display.newSprite("#"..image);
		card:setPosition(cc.p(w/2, h/2));
		card:addTo(bg);
		self:showAnmition(card);
	else 
		local suit = math.floor((id - 1)/13);
		local num = self:convertNum(id%13==0 and 13 or id%13);
		local numImage = self:isRed(suit) and "#r"..num..".png" or "#b"..num..".png";
		local numSp = display.newSprite(numImage)
		numSp:setPosition(cc.p(w/5 + 3, h*0.8));
		numSp:addTo(bg);
		self:showAnmition(numSp);

		local suitY = isBottom and h*0.3 or h*0.5;
		local suitSmall = display.newSprite(self:getSuitImage(suit,0).."_s.png");
		suitSmall:setPosition(cc.p(numSp:getPositionX() + 2, suitY));
		suitSmall:addTo(bg, 1);
		self:showAnmition(suitSmall);

		if not isBottom then
			if not self.playing or self.lastCard then
				local scale = num > 10 and 1 or 0.8
				local suitBig = display.newSprite(self:getSuitImage(suit, num)..".png");
				suitBig:align(display.RIGHT_BOTTOM, w - 14, 12);
				suitBig:addTo(bg);
				suitBig:setScale(scale);
				self:showAnmition(suitBig);
			end 
		else 
			numSp:setPositionY(h*0.75);
			numSp:setScale(0.6);
			suitSmall:setScale(0.6);
		end 
	end 
end

function C:convertNum(id)
	return (id + 2) % 13 == 0 and 13 or (id + 2) % 13;
end

function C:showAnmition(target, isBg)
	if not isBg then 
		table.insert(self.animVector, target)
	end 
	if self.showIdx >= 0 and self.anim then 
		local x, y = target:getPosition();
		target:setOpacity(0);
		target:setScale(0.3);
		if isBg then
			target:align(display.RIGHT_TOP, x + 10, y + 50);
		end 
		local t = 0.15;
		local spwan = transition.spawn({
   			CCFadeIn:create(t),
   			CCScaleTo:create(t, 1.0),
   			CCMoveTo:create(t, cc.p(x, y)),
        });

		local seq = transition.sequence({
			CCDelayTime:create(0.1+self.showIdx*0.05),
			spwan,
			CCCallFunc:create(function ()
				if not self.sound then 
					self.sound = true;
                    PLAY_SOUND(GAME_DDZ_SOUND_RES.."s_sendcard.mp3")
				end 
			end)
   		});
   		target:runAction(seq);
	end 
end 

function C:isRed(suit)
	return suit == SUIT.HEART or suit == SUIT.DIAMOND;
end 

function C:getSuitImage(suit, num)
	if suit == SUIT.SPADE then 
		return num > 10 and "#card_spade"..num or "#card_spade";
	elseif  suit ==  SUIT.HEART then 
		return num > 10 and "#card_heart"..num or "#card_heart";
	elseif  suit ==  SUIT.DIAMOND then 
		return num > 10 and "#card_diamond"..num or "#card_diamond";
	elseif  suit ==  SUIT.CLUB then 
		return num > 10 and "#card_club"..num or "#card_club";
	end
	return "";
end 

function C:onTouch(event, x, y)

	if not self.canTouch then 
		return false;
	end

	local pos = self:convertToNodeSpace(cc.p(x, y))

	if event == "began" then
		 if cc.rectContainsPoint(self.bg:getBoundingBox(),pos) then
		 	self.shadow:show();
		 	return true;
		 end 
	elseif event == "ended" then
		self.canTouch = false;
		self.shadow:hide();
		if self.up then 
			self:downCard();
		else 
			self:upCard();
		end 
	elseif event == "moved" then
		if not cc.rectContainsPoint(self.bg:getBoundingBox(),pos) then
			return false;
		else
			return true;
		end
	end
	
	return false
end

function C:setTouchEnabled(enable)
	self.canTouch = enable;
end

function C:downCard(recover)
	if self.up then 
		self.canTouch = false;
		self.up = false;
		local seq = transition.sequence({
			CCMoveBy:create(0.1, cc.p(0, -20)),
			CCCallFunc:create(function()
				self.canTouch = true;
	 		end)})
		self.delegate.unSelectCard(self.delegate, self.id);
		if recover then
			self.delegate.unSelectCard(self.delegate, self.id);
			self.bg:setPosition(cc.p(0,0));
		else 
			self.bg:runAction(seq);
		end  
	end 
end 

function C:upCard()
	if not self.up then 
		self.canTouch = false;
		self.up = true;
		local seq = transition.sequence({
			-- CCMoveTo:create(0.1, cc.p(0, 20)),
			CCMoveBy:create(0.1, cc.p(0, 20)),
			CCCallFunc:create(function ( ... )
				self.canTouch = true;
				end)})
		self.delegate.selectCard(self.delegate, self.id);
		self.bg:runAction(seq); 
	end
end 

function C:fadeOut(t)
	local spawn = transition.spawn({
			CCFadeOut:create(t),
			transition.sequence({
					CCMoveBy:create(0.2, cc.p(0, 50));
					CCScaleTo:create(0.1, 0.2),
				}),
		})
	self.bg:runAction(spawn)

	for i, e in pairs(self.animVector) do 
		e:runAction(CCFadeOut:create(t));
	end 
end

function C:isUp()
	return self.up;
end

function C:selected()
	self.isSelect = true;
	self.shadow:show();
end 

function C:unSelected()
	self.isSelect = false;
	self.shadow:hide();
end 

function C:isSelected()
	return self.isSelect;
end 

function C:setSelected(selected)
	self.isSelect = selected;
end 

function C:isLastCard()
	return self.lastCard;
end

function C:onExit()

end

function C:setUserData( data )
	self.data = data
end

return C;