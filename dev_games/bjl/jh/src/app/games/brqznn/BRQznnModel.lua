local C = class("BRQznnModel",GameModelBase)

C.animationPath=GAME_BRQZNN_ANIMATION_RES
C.fontPath=GAME_BRQZNN_FONT_RES
C.imagePath=GAME_BRQZNN_IMAGES_RES
C.soundPath=GAME_BRQZNN_SOUND_RES
--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "brqznn"
--游戏最多人数
C.PLAYER_MAX = 8
--抢庄类型个数
C.qiangzhuangTypes=4
--下注类型个数
C.betTypes=4
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
--玩家游戏状态 本地座位号1-8
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

--抢庄倍数
C.qiangzhuangConfig=
{
	[1]=0,
	[2]=1,
	[3]=2,
	[4]=4,
	[5]=5
}

--下注倍数
C.betConfig={
	[1]=5,
	[2]=10,
	[3]=15,
	[4]=20
}

--发牌顺序
C.sendOrder=
{
	[1]=5,
	[2]=6,
	[3]=4,
	[4]=7,
	[5]=3,
	[6]=1,
	[7]=8,
	[8]=2
}

function C:reset()
	self.isGaming = false
	self.zhuangId = nil
	self.zhuangBei = 0
	self.qiangZhuangIds = nil
	self.currentGameState = 0
	self.currentLeftTime = 0
	self.currentPlayerCount = 0
	self.isKicked = false
	for i = 1, self.PLAYER_MAX do
		self.playerGameStateArr[i] =false
	end
	self.hadQiang = false
	self.hadBet = false
	self.hadTan = false
	self.quitPlayerIds = {}
	self.enterPlayerIds = {}
end

return C