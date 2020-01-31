local C = class("ZjhLogic")

function C:getPokerType( poker1, poker2, poker3 )
	if self:checkPoker(poker1) == false or self:checkPoker(poker2) == false or self:checkPoker(poker3) == false then
        return ZJH.POKER_TYPE.NONE
    end

    if poker1.number == poker2.number and poker2.number == poker3.number then
        return ZJH.POKER_TYPE.BAOZI
    end

    local array = {}
    array[1] = poker1.number
    array[2] = poker2.number
    array[3] = poker3.number
    table.sort(array)

    local num1 = array[1]
    local num2 = array[2]
    local num3 = array[3]

    local isShunzi = self:isShunzi(num1, num2, num3)
    local isJinhua = poker1.color == poker2.color and poker2.color == poker3.color

    if isShunzi and isJinhua then
        return ZJH.POKER_TYPE.SHUNJIN
    end

    if isJinhua then
        return ZJH.POKER_TYPE.JINHUA
    end

    if isShunzi then
        return ZJH.POKER_TYPE.SHUNZI
    end

    if num1 == num2 or num2 == num3 or num1 == num3 then
        return ZJH.POKER_TYPE.DUIZI
    end

    if num1 == 2 and num2 == 3 and num3 == 5 then
        return ZJH.POKER_TYPE.TESHU
    end

    if num3 == 14 then
    	return ZJH.POKER_TYPE.SANPAI_A
    end

    return ZJH.POKER_TYPE.SANPAI
end

function C:checkPoker( poker )
	if poker.color < 3 or poker.color > 6 then
		return false
	end
	if poker.number < 2 or poker.number > 14 then
		return false
	end
	return true
end

function C:isShunzi( num1, num2, num3 )
	if num1 == num2 or num2 == num3 or num1 == num3 then
        return false
    end

    if num1 == 2 and num2 == 3 and num3 == 14 then
        return true
    end

    return num3 - num1 == 2
end

return C