--Author : WB
--Date   : 2018/3/29

local AcceleratorUniform = class("AcceleratorUniform", cc.Node)

function AcceleratorUniform:ctor(itemNum)
	self.StartRotation = 0
    self.CurAngularVelo = 0
	self.ForceTarget = -1
    self.itemNum = itemNum
	self.itemWidth = 360 / itemNum
end

function AcceleratorUniform:setMoveCallBack(handler)
    self.CallBackAtMoving = handler
end

function AcceleratorUniform:SetCurAngularVelo(v)
    self.CurAngularVelo = v
end

function AcceleratorUniform:Start(StartAt, StopAt, percent, duration)	--可能从中途开始
	if self.Moving then
		return
	end
	
	self:scheduleUpdateWithPriorityLua(function (deltaT)
		self:Update(deltaT)
    end, 1)

	if (StartAt >= 0) then
		self.StartRotation = (StartAt - 0) * self.itemWidth % 360
	else
		self.StartRotation = self.StartRotation % 360
    end
	self.TimeAccum = 0
	self.Moving = true

	local WillStopAt = self.StartRotation + duration * self.CurAngularVelo
	local Offset = WillStopAt % 360
	Offset = Offset - (StopAt - 0) * self.itemWidth

	if (math.abs(Offset) < 180) then
		self.NeedStopAt = WillStopAt - Offset;
	elseif (Offset ~= 0) then
		self.NeedStopAt = WillStopAt - Offset / math.abs(Offset) * (math.abs(Offset) - 360)
    end

	if (self.NeedStopAt < self.StartRotation or (duration and self.NeedStopAt == self.StartRotation)) then
		self.NeedStopAt = self.NeedStopAt + 360
    end
	self.m_fRealAngularVelo = (self.NeedStopAt) / duration
end

function AcceleratorUniform:Stop()
	self:unscheduleUpdate()
	self.TimeAccum = 0
	self.CurAngularVelo = 0
	self.Moving = false
	self:Update(0)
end

function AcceleratorUniform:IsMoving()
    return self.Moving
end

function AcceleratorUniform:Update(deltaT)
	self.TimeAccum = self.TimeAccum + deltaT

	local CurAngle = self.TimeAccum * self.m_fRealAngularVelo;
	local bStopped = (self.NeedStopAt <= CurAngle);

	local bMov = self.Moving;
	if (bStopped) then
		self:unscheduleUpdate();
		CurAngle = self.NeedStopAt;
	    self.TimeAccum = 0
		self.Moving = false;
	end

	if (self.CallBackAtMoving and bMov) then
		self.CallBackAtMoving(CurAngle, bStopped, self.m_fRealAngularVelo)
    end
end

return AcceleratorUniform