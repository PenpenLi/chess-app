import(".FruitDefine")

local C = class("FruitModel",GameModelBase)

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "fruit"
C.difen = 0
C.inmoney = 0
C.allPlayerList = {}


function C:reset()
end

return C