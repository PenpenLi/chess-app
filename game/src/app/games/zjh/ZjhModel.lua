local C = class("ZjhModel",GameModelBase)

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "zjh"
--游戏最多人数
C.PLAYER_MAX = 5
--庄玩家本地座位号
C.zhuangLocalSeatId = nil
--底分
C.difen = 0
--入场限制
C.inmoney = 0
--自己是否被踢出房间
C.isKicked = false
--玩家游戏状态 本地座位号1-5
C.playerGameStatusArr = {0,0,0,0,0}
--当前第几轮
C.currentRound = 0
--当前单注
C.currentSingleChip = 0
--当前总注
C.currentTotalChips = 0
--别人是否全押
C.otherAll = false
--自己是否全押
C.isMeAll = false
--是否自动跟注
C.isAuto = false
--是否轮到自己
C.turnToMe = false
--自己是否点击了弃牌
C.isDrop = false
--是否可以看牌
C.canSee = false
--当前操作玩家本地座位号
C.currentOptLocalSeatId = 0
--当前操作剩余时间
C.currentOptLeftTime = 0
--当前操作总时间
C.currentOptTotalTime = 15
--当前操作配置
C.currentOptConfigs = {}
--玩家列表
C.playerlist = {}

function C:reset()
	self.isGaming = false
	self.zhuangLocalSeatId = nil
	self.playerGameStatusArr = {0,0,0,0,0}
	--当前第几轮
	self.currentRound = 0
	--当前单注
	self.currentSingleChip = 0
	--当前总注
	self.currentTotalChips = 0
	--别人是否全押
	self.otherAll = false
	--自己是否全押
	self.isMeAll = false
	--是否自动跟注
	self.isAuto = false
	--是否轮到自己
	self.turnToMe = false
	--自己是否点击了弃牌
	self.isDrop = false
	--是否可以看牌
	self.canSee = false
	--当前操作配置
	self.currentOptConfigs = {}
	--玩家列表
	self.playerList = {}
end

function C:updateOptConfigs( info )
	self.currentOptConfigs = {}
	local jiazhu = info["filltp"]-1
	if jiazhu < 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.JIAZHU1] = true
	end
	if jiazhu < 2 then
		self.currentOptConfigs[ZJH.BTN_NAME.JIAZHU2] = true
	end
	if jiazhu < 3 then
		self.currentOptConfigs[ZJH.BTN_NAME.JIAZHU3] = true
	end
	if info["bet"] == 1 or info["call"] == 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.GENZHU] = true
	end
	if info["check"] == 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.KANPAI] = true
	end
	if info["competition"] == 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.BIPAI] = true
	end
	if info["fold"] == 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.QIPAI] = true
	end
	if info["showcard"] == 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.GZYZ] = true
	end
	if info["showhand"] == 1 then
		self.currentOptConfigs[ZJH.BTN_NAME.QUANYA] = true
	end
	dump(self.currentOptConfigs,"updateOptConfigs")
end

function C:isMoneyNotEnough()
	local flags = false
	if self.isKicked then
		flags = true
	elseif self.myInfo and self.myInfo["money"] and self.myInfo["money"] < self.inmoney then
		flags = true
	end
	return flags
end

return C