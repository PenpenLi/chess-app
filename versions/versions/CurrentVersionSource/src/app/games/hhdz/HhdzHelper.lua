local Helper = {}

function Helper.getNextXslData(daluData)
	local dyzlData = Helper.calculateDYZL(daluData)
	local xlData = Helper.calculateXL(daluData)
	local yylData = Helper.calculateYYL(daluData)

	local dyzlResult = 1
	local xlResult = 1
	local yylResult = 1

	if #dyzlData ~= 0 then
		dyzlResult = dyzlData[#dyzlData]
	end

	if #xlData ~= 0 then
		xlResult = xlData[#xlData]
	end

	if #yylData ~= 0 then
		yylResult = yylData[#yylData]
	end

	return dyzlResult, xlResult, yylResult
end

function Helper.calculateDYZL(daluData)
	local item22 = nil
	local item13 = nil
	local daluArray = {}
	for k, v in pairs(daluData) do
		if v.logicRow == 2 and v.logicCol == 2 then
			item22 = v
		elseif v.logicRow == 1 and v.logicCol == 3 then
			item13 = v
		end
		if daluArray[v.logicCol] == nil then
			daluArray[v.logicCol] = {}
		end
		daluArray[v.logicCol][v.logicRow] = v
	end
	
	local dyzlData = {}

	local key = item22 or item13
	if key == nil then
		return dyzlData
	end

	for k, v in pairs(daluData) do
		if v.logicCol > 1 then
			if v.logicRow == 1 then
				if v.logicCol ~= 2 then
					local column1Count = #daluArray[v.logicCol - 1]
					local column2Count = #daluArray[v.logicCol - 2]
					--相等红，不等黑
					if column1Count == column2Count then 
						table.insert(dyzlData,1)
					else
						table.insert(dyzlData,1)
					end
				end
			else
				if daluArray[v.logicCol - 1][v.logicRow] ~= nil then
					-- 有粒为红
					table.insert(dyzlData,1)
				else
					if daluArray[v.logicCol - 1][v.logicRow - 1] == nil then
						-- 连续两个没有，为红
						table.insert(dyzlData,1)
					else
						-- 无粒为黑
						table.insert(dyzlData,2)
					end
				end
			end
		end
	end
	return dyzlData
end

function Helper.calculateXL(daluData)
	local item23 = nil
	local item14 = nil
	local daluArray = {}
	for k, v in pairs(daluData) do
		if v.logicRow == 2 and v.logicCol == 3 then
			item23 = v
		elseif v.logicRow == 1 and v.logicCol == 4 then
			item14 = v
		end
		if daluArray[v.logicCol] == nil then
			daluArray[v.logicCol] = {}
		end
		daluArray[v.logicCol][v.logicRow] = v

	end
	local xlData = {}

	local key = item23 or item14
	if key == nil then
		return xlData
	end

	for k, v in pairs(daluData) do
		if v.logicCol > 2 then
			if v.logicRow == 1 then
				if v.logicCol ~= 3 then
					local column1Count = #daluArray[v.logicCol - 1]
					local column2Count = #daluArray[v.logicCol - 3]
					--相等红，不等黑
					if column1Count == column2Count then 
						table.insert(xlData,1)
					else
						table.insert(xlData,2)
					end
				end
			else
				if daluArray[v.logicCol - 2][v.logicRow] ~= nil then
					-- 有粒为红
					table.insert(xlData,1)
				else
					if daluArray[v.logicCol - 2][v.logicRow - 1] == nil then
						-- 连续两个没有，为红
						table.insert(xlData,1)
					else
						-- 无粒为黑
						table.insert(xlData,2)
					end
				end
			end
		end
	end
	return xlData
end

function Helper.calculateYYL(daluData)
	local item24 = nil
	local item15 = nil
	local daluArray = {}
	for k, v in pairs(daluData) do
		if v.logicRow == 2 and v.logicCol == 4 then
			item24 = v
		elseif v.logicRow == 1 and v.logicCol == 5 then
			item15 = v
		end
		if daluArray[v.logicCol] == nil then
			daluArray[v.logicCol] = {}
		end
		daluArray[v.logicCol][v.logicRow] = v
	end
	
	local yylData = {}

	local key = item24 or item15
	if key == nil then
		return yylData
	end

	for k, v in pairs(daluData) do
		if v.logicCol > 3 then
			if v.logicRow == 1 then
				if v.logicCol ~= 4 then
					local column1Count = #daluArray[v.logicCol - 1]
					local column2Count = #daluArray[v.logicCol - 4]
					--相等红，不等黑
					if column1Count == column2Count then
						table.insert(yylData,1)
					else
						table.insert(yylData,2)
					end
				end
			else
				if daluArray[v.logicCol - 3][v.logicRow] ~= nil then
					-- 有粒为红
					table.insert(yylData,1)
				else
					if daluArray[v.logicCol - 3][v.logicRow - 1] == nil then
						-- 连续两个没有，为红
						table.insert(yylData,1)
					else
						-- 无粒为黑
						table.insert(yylData,2)
					end
				end
			end
		end
	end
	return yylData
end

return Helper