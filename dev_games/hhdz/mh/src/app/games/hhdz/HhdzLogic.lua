local C = class("HhdzLogic")

local MAX_TREND_NUM = 70

C.trendVec = {}
C.allTrend = {}
C.winTypes = {}

--��ʼ����¼
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

--����һ�ּ�¼
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

--��ռ�¼
function C:clearTrends()
	self.allTrend = {}
end


--������ʷ��¼
function C:getTrendByIndex(index)
	if index <= #self.trendVec then
		return self.trendVec[index]
	end
	return nil
end

--��ȡ���һ����¼
function C:getLastTrend()
	return self.trendVec[#self.trendVec]
end

--��ȡ��¼��
function C:getTrendVecCount()
	return #self.trendVec
end

--�˿˻�ɫ������תΪidֵ
function C:colorNumber2Id(color,number)
    if number == 15 then
        return 53
    elseif number == 16 then
        return 54
    end
    color = color - 3
    return number + color * 13
end

--�˿�idֵתΪ��ɫ������
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
