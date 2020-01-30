local C = class("GameModelBase")
GameModelBase = C

--游戏最多人数
C.PLAYER_MAX = 0
--房间信息
C.roomInfo = nil
--我的信息
C.myInfo = nil
--我的账号ID
C.myPlayerId = nil
--我的座位ID
C.mySeatId = 0
--是否正在游戏
C.isGaming = false
--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = nil

return GameModelBase