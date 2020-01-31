local C = class("HhdzLogic")

local MAX_TREND_NUM = 70

C.trendVec = {}
C.allTrend = {}
C.winTypes = {}

--初始化记录
function C:initTrends(trend)
	self.trendVec = {}
	self.allTrend = {}
    self.winTypes = {}
	if trend and type(trend) == "table" then
		if trend.winner and type(trend.winner) == "table" and trend.cardType and type(trend.cardType) == "table" then
			local startIndex = #trend.winner > MAX_TREND_NUM and (#trend.winner - MAX_TREND_NUM + 1) or 1
		    local endIndex = #trend.winner

            local length = math.min(math.max(#trend.winner,#trend.winner),MAX_TREND_NUM)
            local winnerIndex = #trend.winner - length + 1
            local typeIndex = #trend.cardType - length + 1

		    for i = 1,length do
                
		        local info = {}
		        info.winner = trend.winner[math.max(winnerIndex,1)]
		        info.cardType = trend.cardType[math.max(typeIndex,1)] or 1

                winnerIndex = winnerIndex + 1
                typeIndex = typeIndex + 1

                table.insert(self.winTypes, info.cardType)
			    table.insert(self.trendVec, info)
			    table.insert(self.allTrend, info.winner)
		    end
		end
	end
end

--新增一局记录
function C:addTrend(winner, cardType)
	local trend = {}
	trend.winner = winner
	trend.cardType = cardType

    table.insert(self.winTypes, cardType)
	table.insert(self.allTrend, winner)
	table.insert(self.trendVec, trend)

	if #self.trendVec > MAX_TREND_NUM then
        table.remove(self.winTypes, 1)
		table.remove(self.trendVec, 1)
		table.remove(self.allTrend, 1)
	end
end

--清空记录
function C:clearTrends()
	self.allTrend = {}
end


--索引历史纪录
function C:getTrendByIndex(index)
	if index <= #self.trendVec then
		return self.trendVec[index]
	end
	return nil
end

--获取最后一个记录
function C:getLastTrend()
	return self.trendVec[#self.trendVec]
end

--获取记录数
function C:getTrendVecCount()
	return #self.trendVec
end

--扑克花色、点数转为id值
function C:colorNumber2Id(color,number)
    if number == 15 then
        return 53
    elseif number == 16 then
        return 54
    end
    color = color - 3
    return number + color * 13
end

--扑克id值转为花色、点数
function C:id2ColorNumber(id)
    if id == 53 then
        return {cardcolor = 2,cardnumber = 15}
    end
    if id == 54 then
        return {cardcolor = 2,cardnumber = 16}
    end
    local color = math.floor((id - 1) / 13) + 3
    local num = id % 13
    num = num + 1
    return {cardcolor = color,cardnumber = num}
end



return C
