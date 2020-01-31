--Author : WB
--Date   : 2016/6/15

local Accelerator = class("Accelerator", cc.Node)

function Accelerator:ctor(itemNum)
	self.FontSize = 20
	self.StartRotation = 0
	self.MaxAngularVelo = 620
    self.Acceleration = 180
	self.Resistance = 100
	self.RealResistance = self.Resistance	-- 根据中奖需要,微调过的阻力系数
	self.ForceTarget = -1
	self:setItemNum(itemNum)
end
function Accelerator:setItemNum(itemNum)
    self.itemNum = itemNum
	self.itemWidth = 360 / itemNum
end
function Accelerator:setMoveCallBack(handler)
    self.CallBackAtMoving = handler
end
--开始转，在每次schedule中给出引用者需要的数据
function Accelerator:Start(StartAt, StopAt, percent, duration)	--可能从中途开始
	if self.Moving then
		return
	end
	
	math.randomseed(os.clock()*10000)
	self.ForceTarget = StopAt
	if self.ForceTarget < 1 then
		self.ForceTarget = self.itemNum + self.ForceTarget
	end

	self:scheduleUpdateWithPriorityLua(function (deltaT)
		if self.IsBouncing then
			self:UpdateBounce(deltaT)
		else
			self:Update(deltaT)
		end
    end, 1)
	self.TimeAccum = 0
	self.IsAccele = true
	self.IsBouncing = false
	if StartAt > 0 then
		self.StartRotation = (StartAt - 1) * self.itemWidth % 360
	else
		self.StartRotation = self.StartRotation % 360
	end
	self.Moving = true

	percent = math.max(0, math.min(0.95, percent))
	local SummitPercent = self.Resistance / (self.Acceleration + self.Resistance)
	self.SummitTime = self.MaxAngularVelo / self.Acceleration
	local DeceTime = self.MaxAngularVelo / self.Resistance
	local TotalTime = self.MaxAngularVelo / self.Acceleration + self.MaxAngularVelo / self.Resistance
    self.RealAcceleration = self.Acceleration
    self.RealSummitTime = self.SummitTime
    self.RealMaxAngularVelo = self.MaxAngularVelo
    --self.StartTime = os.clock()

	if percent < SummitPercent then
        if percent ~= 0 then
			self.StartRotation = math.random(0, 360)
			self.TimeAccum = TotalTime * percent
        end

		--根据本盘要中的目标计算精确阻力
		local TimeToStop = self.SummitTime * self.Acceleration / self.Resistance
		local SummitRotation = self.SummitTime * self.SummitTime * self.Acceleration / 2 + self.StartRotation
		local WillStopAt = SummitRotation + self.MaxAngularVelo * TimeToStop - self.Resistance * TimeToStop * TimeToStop / 2
		local Offset = WillStopAt % 360 - (self.ForceTarget - 0) * self.itemWidth -- + 90
		if math.abs(Offset) < 180 then
            self.NeedStopAt = WillStopAt - Offset
		elseif Offset ~= 0 then
			self.NeedStopAt = WillStopAt - Offset / math.abs(Offset) * (math.abs(Offset) - 360)
		end
		self.RealResistance = 0.5 * self.MaxAngularVelo * self.MaxAngularVelo / (self.NeedStopAt - SummitRotation)

        if percent == 0 and duration then
--            duration = duration - 1.05
            local len = self.NeedStopAt - self.StartRotation
            self.RealResistance = len / (duration * duration) * 4
            self.RealAcceleration = self.RealResistance
            self.RealSummitTime = duration / 2
            self.RealMaxAngularVelo = self.RealSummitTime * self.RealAcceleration
            return duration
        end
        return self.MaxAngularVelo / self.Acceleration + self.MaxAngularVelo / self.RealResistance - self.TimeAccum + 1.05
	else
		local AccLen = self.SummitTime * self.SummitTime * self.Acceleration / 2
		local DeceLen = DeceTime * self.MaxAngularVelo - DeceTime * DeceTime * self.Resistance / 2
		local LeftTime = TotalTime * (1 - percent)
		self.TimeAccum = self.MaxAngularVelo / self.Resistance - LeftTime
		self.StartRotation = (self.ForceTarget - 1) * self.itemWidth - AccLen - DeceLen + 3600
        self.NeedStopAt = self.StartRotation + AccLen + DeceLen
		self.RealResistance = self.Resistance
        --self.StartTime = self.StartTime - self.TimeAccum
		self.IsAccele = false

        print("self.NeedStopAt = ", self.NeedStopAt)
        return LeftTime + 1.05
	end
end

function Accelerator:SetPos(StartAt)
	self.StartRotation = StartAt * self.itemWidth % 360
	self.CurIndex = StartAt;
	self.CurAngularVelo = 0;
end


function Accelerator:Stopped()
	self:unscheduleUpdate()

--	self.CurIndex = (self.CurIndex) % self.itemNum + 1
--	self.StartRotation = self.CurIndex * self.itemWidth
	self.ForceTarget = -1
	self.Moving = false
end

function Accelerator:Update(deltaT)
    --self.TimeAccum = os.clock() - self.StartTime

	self.TimeAccum = self.TimeAccum + deltaT

	if self.IsAccele then
		if self.TimeAccum * self.RealAcceleration >= self.RealMaxAngularVelo then
			self.IsAccele = false
			self.TimeAccum = self.TimeAccum - self.RealSummitTime
		end
	end

	local IsStopped = false
	local CurAngle = 0
	if self.IsAccele then
		self.CurAngularVelo = self.TimeAccum * self.RealAcceleration
		CurAngle = self.CurAngularVelo * self.TimeAccum / 2 + self.StartRotation
	else
		if self.TimeAccum * self.RealResistance >= self.RealMaxAngularVelo then
			IsStopped = true
			self.TimeAccum = self.RealMaxAngularVelo / self.RealResistance
		end
		self.CurAngularVelo = self.RealMaxAngularVelo - self.TimeAccum * self.RealResistance
		CurAngle = self.RealSummitTime * self.RealSummitTime * self.RealAcceleration / 2 + self.RealMaxAngularVelo * self.TimeAccum
		 - self.TimeAccum * self.TimeAccum * self.RealResistance / 2 + self.StartRotation
	end

	if IsStopped then
		self:Stopped()
	end
	self.CallBackAtMoving(CurAngle, IsStopped, self.CurAngularVelo / self.RealMaxAngularVelo)
end


return Accelerator
