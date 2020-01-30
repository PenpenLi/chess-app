--region CoTimer.lua
--Date
--此文件由[BabeLua]插件自动生成
--一个简单的时间记录器

local CoTimer = class("CoTimer")
--local CUtil = require("util")

function CoTimer:ctor(delay)
   self.currentTime = 0
   self.mStart = 0
   self.mDelay = 0
   self:initData(delay)
end

function CoTimer:getCurrentTime()
    self.currentTime = GetUsecTime() * 1000 --CUtil.getCurrentTime()
    return  self.currentTime  --os.time()
end

function CoTimer:initData(delay)
    self.mStart = self:getCurrentTime()
    if delay > 60000 then
       delay = 30000
    end
    self.mDelay = delay
end


function CoTimer:isTimeUp()
--    if self.mStart < 0 then
--        self.mStart = self:getCurrentTime()
--    end
    local timeup = ((self:getCurrentTime() - self.mStart) >= self.mDelay)
    return timeup
end

function CoTimer:getElapsed()
    return self:getCurrentTime() - self.mStart
end

return CoTimer

--endregion
