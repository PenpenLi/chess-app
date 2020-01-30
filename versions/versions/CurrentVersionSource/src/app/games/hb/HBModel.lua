import(".HBDefine")

local C = class("HBModel",GameModelBase)

--定时器名称(游戏里面调用到的定时器名称前缀)
C.timerName = "hb"
C.difen = 0
C.inmoney = 0
C.allPlayerList = {}


function C:reset()
end

function C:updateAllPlayerList( list )
	if list == nil then
		return
	end
	self.allPlayerList = list
end

function C:getPlayerNum()
	return #self.allPlayerList
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

function C:getPlayer2( seatId )
	local info = nil
	for k,v in pairs(self.allPlayerList) do
		if v["seat"] == seatId then
			info = v
			break
		end
	end
	return info
end

function C:getPlayer( playerid )
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