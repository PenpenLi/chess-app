local C = class("QznnModel",GameModelBase)

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "qznn"
--游戏最多人数
C.PLAYER_MAX = 5
--庄玩家ID
C.zhuangId = nil
--庄倍数
C.zhuangBei = 0
--参与抢庄玩家ID
C.qiangZhuangIds = nil
--底分
C.difen = 0
--入场限制
C.inmoney = 0
--当前游戏状态
C.currentGameState = 0
--当前状态剩余时间
C.currentLeftTime = 0
--当前玩家人数
C.currentPlayerCount = 0
--自己是否被踢出房间
C.isKicked = false
--玩家游戏状态 本地座位号1-5
C.playerGameStateArr = {false,false,false,false,false}
--自己是否已经抢过庄
C.hadQiang = false
--自己是否已经下过注
C.hadBet = false
--自己是否已经摊牌
C.hadTan = false
--延迟退出的玩家ID
C.quitPlayerIds = {}
--延迟加入的玩家ID
C.enterPlayers = {}

function C:reset()
	self.isGaming = false
	self.zhuangId = nil
	self.zhuangBei = 0
	self.qiangZhuangIds = nil
	self.currentGameState = 0
	self.currentLeftTime = 0
	self.currentPlayerCount = 0
	self.isKicked = false
	self.playerGameStateArr = {false,false,false,false,false}
	self.hadQiang = false
	self.hadBet = false
	self.hadTan = false
	self.quitPlayerIds = {}
	self.enterPlayerIds = {}
end

return C