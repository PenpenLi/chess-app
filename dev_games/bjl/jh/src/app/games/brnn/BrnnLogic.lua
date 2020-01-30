import(".BrnnDefine")

local C = class("BrnnLogic")

function C:getPokerTypeArmatureName( ctype, niun )
	local name = ""
	if ctype == BRNN.TYPE.NONE then
		name = "meiniu"
	elseif ctype == BRNN.TYPE.NORMAL_NIU then
		if niun == 1 then
			name = "niuyi"
		elseif niun == 2 then
			name = "niuer"
		elseif niun == 3 then
			name = "niusan"
		elseif niun == 4 then
			name = "niusi"
		elseif niun == 5 then
			name = "niuwu"
		elseif niun == 6 then
			name = "niuliu"
		elseif niun == 7 then
			name = "niuqi"
		end
	elseif ctype == BRNN.TYPE.NIU_8 then
		name = "niuba"
	elseif ctype == BRNN.TYPE.NIU_9 then
		name = "niujiu"
	elseif ctype == BRNN.TYPE.NIU_NIU then
		name = "niuniu"
	elseif ctype == BRNN.TYPE.TONGHUA then
		name = "tonghua"
	elseif ctype == BRNN.TYPE.SHUNZI then
		name = "shunzi"
	elseif ctype == BRNN.TYPE.HULU then
		name = "hulu"
	elseif ctype == BRNN.TYPE.WUHUANIU then
		name = "wuhuaniu"
	elseif ctype == BRNN.TYPE.ZHADAN then
		name = "zhadanniu"
	elseif ctype == BRNN.TYPE.TONGHUASHUN then
		name = "tonghuashun"
	elseif ctype == BRNN.TYPE.WUXIAONIU then
		name = "wuxiaoniu"
	end
	return name
end

function C:getTypeBeiKey( ctype )
	local name = ""
	if ctype == BRNN.TYPE.NONE then
		name = BRNN.TYPE_BEI.NONE
	elseif ctype == BRNN.TYPE.NORMAL_NIU then
		name = BRNN.TYPE_BEI.NORMAL_NIU
	elseif ctype == BRNN.TYPE.NIU_8 then
		name = BRNN.TYPE_BEI.NIU_8
	elseif ctype == BRNN.TYPE.NIU_9 then
		name = BRNN.TYPE_BEI.NIU_9
	elseif ctype == BRNN.TYPE.NIU_NIU then
		name = BRNN.TYPE_BEI.NIU_NIU
	elseif ctype == BRNN.TYPE.TONGHUA then
		name = BRNN.TYPE_BEI.TONGHUA
	elseif ctype == BRNN.TYPE.SHUNZI then
		name = BRNN.TYPE_BEI.SHUNZI
	elseif ctype == BRNN.TYPE.HULU then
		name = BRNN.TYPE_BEI.HULU
	elseif ctype == BRNN.TYPE.WUHUANIU then
		name = BRNN.TYPE_BEI.WUHUANIU
	elseif ctype == BRNN.TYPE.ZHADAN then
		name = BRNN.TYPE_BEI.ZHADAN
	elseif ctype == BRNN.TYPE.TONGHUASHUN then
		name = BRNN.TYPE_BEI.TONGHUASHUN
	elseif ctype == BRNN.TYPE.WUXIAONIU then
		name = BRNN.TYPE_BEI.WUXIAONIU
	end
	return name
end

return C