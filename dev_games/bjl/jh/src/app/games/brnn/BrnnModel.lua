import(".BrnnDefine")

local C = class("BrnnModel",GameModelBase)

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "brnn"
C.difen = 0
C.inmoney = 0
C.betTime = 12
C.betNeed = 5000

C.bankerMaxTurn = 6
C.bankerMinTurn = 1
C.bankerNeed = 5000000
C.bankerId = 0
C.bankerInfo = nil
C.bankerList = nil
C.inBankerList = false
C.isBanker = false

C.currentChip = 100
C.currentChipLevel = 1
C.currentStatus = BRNN.STATUS.NONE
C.currentLefttime = 0
C.lastSelectedChipLevel = 3

C.playerBetPool = nil
C.areaBetPool = nil
--收到在线玩家下注前自己已经下了多少，用于当自己处于在线玩家时过滤
C.myLastBetPool = nil
C.tablePlayerList = nil
C.allPlayerList = {}
C.hadFlyStarArr = {false,false,false,false}
--上局是否下注，用于续押按钮
C.lastHadBet = false
--上次刷新走势图数据时间
C.lastRefreshHistoryTime = 0
--本轮自己还可以下注金额
C.selfCanBetMoney = 0

C.BET_CONFIGS = {
	[1] = 100,
	[2] = 1000,
	[3] = 5000,
	[4] = 10000,
	[5] = 50000,
}

C.TYPE_BEI_CONFIGS = {
	[BRNN.TYPE_BEI.NONE] = 1,
	[BRNN.TYPE_BEI.NORMAL_NIU] = 1,
	[BRNN.TYPE_BEI.NIU_8] = 2,
	[BRNN.TYPE_BEI.NIU_9] = 2,
	[BRNN.TYPE_BEI.NIU_NIU] = 3,
	[BRNN.TYPE_BEI.TONGHUA] = 3,
	[BRNN.TYPE_BEI.SHUNZI] = 3,
	[BRNN.TYPE_BEI.HULU] = 3,
	[BRNN.TYPE_BEI.WUHUANIU] = 4,
	[BRNN.TYPE_BEI.ZHADAN] = 4,
	[BRNN.TYPE_BEI.TONGHUASHUN] = 4,
	[BRNN.TYPE_BEI.WUXIAONIU] = 5,
}

function C:reset()
	self.bankerId = 0
	self.bankerInfo = nil
	self.bankerList = nil
	self.inBankerList = false
	self.isBanker = false
	self.currentChip = 100
	self.currentChipLevel = 1
	self.currentStatus = BRNN.STATUS.NONE
	self.currentLefttime = 0
	self.playerBetPool = nil
	self.areaBetPool = nil
	--收到在线玩家下注前自己已经下了多少，用于当自己处于在线玩家时过滤
	self.myLastBetPool = nil
	self.tablePlayerList = nil
	self.allPlayerList = {}
	self.hadFlyStarArr = {false,false,false,false}
	--上局是否下注，用于续押按钮
	self.lastHadBet = false
	--上次刷新走势图数据时间
	self.lastRefreshHistoryTime = 0
	--本轮自己还可以下注金额
	self.selfCanBetMoney = 0
end

function C:updateAllPlayerList( list )
	if list == nil then
		return
	end
	self.allPlayerList = list
end

function C:addPlayer( info )
	if info == nil then
		return
	end
	if self.allPlayerList == nil then
		self.allPlayerList = {}
	end
	table.insert(self.allPlayerList,info)
end

function C:removePlayer( playerId )
	if self.allPlayerList == nil then
		return
	end
	for k,v in pairs(self.allPlayerList) do
		if v["playerid"] == playerId then
			table.remove(self.allPlayerList,k)
			break
		end
	end
end

function C:getPlayer( playerId )
	local info = nil
	for k,v in pairs(self.allPlayerList) do
		if v["playerid"] == playerId then
			info = v
			break
		end
	end
	return info
end

function C:updateBanker( info )
	self.bankerId = info["zhuangid"]
	self.isBanker = self.bankerId == self.myInfo["playerid"]
	if self.bankerId ~= 0 then
		self.bankerInfo = self:getPlayer(self.bankerId)
		self.bankerInfo["money"] = info["chouma"]
	end
end

function C:updateBankerList( list )
	self.bankerList = list
	if self.bankerList then
		table.sort( self.bankerList, function( a, b )
			return a.index < b.index
		end )
	end
	if self.bankerList == nil then
		self.inBankerList = false
	else
		for k,v in pairs(self.bankerList) do
			if v["playerid"] == self.myInfo["playerid"] then
				self.inBankerList = true
				break
			end
		end
	end
end

function C:getChipLevel( money )
	local level = 1
	for k,v in pairs(self.BET_CONFIGS) do
		if v == money then
			level = k
			break
		end
	end
	return level
end

function C:addPlayerBet( playerId, area, money )
	playerId = tostring(playerId)
	area = tostring(area)
	if self.playerBetPool == nil then
		self.playerBetPool = {}
	end
	if self.playerBetPool[playerId] == nil then
		self.playerBetPool[playerId] = {}
	end
	if self.playerBetPool[playerId][area] == nil then
		self.playerBetPool[playerId][area] = 0
	end
	self.playerBetPool[playerId][area] = self.playerBetPool[playerId][area]+money
end

function C:getPlayerBetChips( playerId, area )
	playerId = tostring(playerId)
	area = tostring(area)
	local money = 0
	if self.playerBetPool and self.playerBetPool[playerId] and self.playerBetPool[playerId][area] then
		money = self.playerBetPool[playerId][area]
	end
	return money
end

function C:updateAreaBetChips( area, money )
	area = tostring(area)
	if self.areaBetPool == nil then
		self.areaBetPool = {}
	end
	self.areaBetPool[area] = money
end

function C:getAreaBetChips( area )
	area = tostring(area)
	local money = 0
	if self.areaBetPool and self.areaBetPool[area] then
		money = self.areaBetPool[area]
	end
	return money
end

function C:getOnlinePlayerBetChips( area )
	area = tostring(area)
	local totalBetChips = self:getAreaBetChips(area)
	local tablePlayerBetChips = 0
	if self.tablePlayerList then
		for i,v in ipairs(self.tablePlayerList) do
			tablePlayerBetChips = tablePlayerBetChips+self:getPlayerBetChips(v.playerid,area)
		end
	end
	return totalBetChips - tablePlayerBetChips
end

function C:getMaxSupplementChips()
	return self.BET_CONFIGS[4]+self.BET_CONFIGS[3]+self.BET_CONFIGS[2]+self.BET_CONFIGS[1]
end

function C:addMyLastBet( area,money )
	area = tostring(area)
	if self.myLastBetPool == nil then
		self.myLastBetPool = {}
	end
	if self.myLastBetPool[area] == nil then
		self.myLastBetPool[area] = 0
	end
	self.myLastBetPool[area] = self.myLastBetPool[area]+money
end

function C:getMyLastBet( area )
	area = tostring(area)
	local money = 0
	if self.myLastBetPool and self.myLastBetPool[area] then
		money = self.myLastBetPool[area]
	end
	return money
end

function C:clearMyLastBet()
	self.myLastBetPool = nil
end

function C:setHadFlyLuckyStar( area )
	self.hadFlyStarArr[area] = true
end

function C:getHadFlyLuckyStar( area )
	return self.hadFlyStarArr[area]
end

function C:getMaxTypeBei()
	local bei = 3
	--TODO:与服务器一致，设置3倍
	-- for k,v in pairs(self.TYPE_BEI_CONFIGS) do
	-- 	if bei < v then
	-- 		bei = v
	-- 	end
	-- end
	return bei
end

function C:clearBetPool()
	self.playerBetPool = nil	
	self.areaBetPool = nil
	self.myLastBetPool = nil
	self.hadFlyStarArr = {false,false,false,false}
	self.currentChip = self.BET_CONFIGS[1]
	self.currentChipLevel = 1
end

return C