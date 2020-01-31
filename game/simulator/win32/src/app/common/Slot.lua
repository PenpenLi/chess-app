--Author : WB
--Date   : 2018/3/29

local Slot = class("Slot", ccui.Layout)
local AcceleratorUniform = require ("app.common.AcceleratorUniform")
local display = require('cocos.framework.display')


-- something = 背景文件 or 背景大小
function Slot:ctor(itemNum, something, func, itemNumInCol)
    local hasBGFile = (type(something) == "string")
	self.m_itemNum = itemNum;

    self:SetAcc(AcceleratorUniform:create(itemNum))
	self.m_pFrame1 = display.newSprite(hasBGFile and something or nil);
	self.m_pFrame2 = display.newSprite(hasBGFile and something or nil);
    if not hasBGFile then
        self.m_pFrame1:setContentSize(something);
        self.m_pFrame2:setContentSize(something);
    end
    self.m_pFrame1:setAnchorPoint(cc.p(0, 0));
    self.m_pFrame2:setAnchorPoint(cc.p(0, 0));
	self.m_pHead = cc.Node:new();
	self.m_pHead:addChild(self.m_pFrame1);
	self.m_pHead:addChild(self.m_pFrame2);
    self:addChild(self.m_pHead)
	local pFrameSize = self.m_pFrame1:getContentSize();
	self.m_nFrameHeight = pFrameSize.height;
	self.m_CallBackAtEnd = func;
	self:setContentSize(cc.size(pFrameSize.width, self.m_nFrameHeight / itemNum * (itemNumInCol or 1)));
	self:setClippingEnabled(true);
	self:_layout_frames();
end

function Slot:GetAcc(pAcc)
    return self.m_pAcc					
end

function Slot:SetAcc(pAcc)						
	if (self.m_pAcc) then
		self:removeChild(self.m_pAcc);
	end
	self.m_pAcc = pAcc; 
	self:addChild(pAcc);
	pAcc:setMoveCallBack(function(angle, over, speed)
		self:_run_step(angle, over, speed);
	end);
end

function Slot:Start(StopAt, fDuration)
	self.m_pAcc:Start(-1, StopAt, 0, fDuration);
	return 0;
end

function Slot:SetCurItem(index)
	self.m_pAcc.StartRotation = (index * 360 / self.m_itemNum);
	self.m_pAcc:update(0);
end

function Slot:GetFrames()
	return {self.m_pFrame1, self.m_pFrame2};
end

function Slot:_run_step(angle, over, speed)
    if self.tag then
        print("============", angle, over)
    end
	self.m_pHead:setPositionY(-self.m_nFrameHeight * angle / 360);
	self:_layout_frames();
	if (over and self.m_CallBackAtEnd) then
		self.m_pHead:setPositionY(self.m_pHead:getPositionY() % self.m_nFrameHeight);
		self:_layout_frames();
		self.m_CallBackAtEnd();
	end
end

function Slot:_layout_frames()
	local Y = self.m_pHead:getPositionY();
    Y = -(math.abs(Y) % self.m_nFrameHeight) - Y;
	self.m_pFrame1:setPositionY(Y);
	self.m_pFrame2:setPositionY(Y + self.m_nFrameHeight);
end


return Slot
