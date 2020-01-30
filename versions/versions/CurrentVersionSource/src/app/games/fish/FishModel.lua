import(".FishDefine")

local C = class("FishModel",GameModelBase)

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "fish"
C.difen = 0
C.inmoney = 0
C.allPlayerList = {}

C.BET_CONFIGS = {
	[1] = 100,
	[2] = 1000,
	[3] = 5000,
	[4] = 10000,
	[5] = 50000,
}


function C:reset()
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

function C:getPlayer( seatId )
	local info = nil
	for k,v in pairs(self.allPlayerList) do
		if v["seat"] == seatId then
			info = v
			break
		end
	end
	return info
end

function C:getPlayer2( playerid )
	local info = nil
	for k,v in pairs(self.allPlayerList) do
		if v["playerid"] == playerid then
			info = v
			break
		end
	end
	return info
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


return C