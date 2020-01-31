-- region BjlLogic.lua
-- Date 2019-12-14 10:14:37
local C = class("BjlLogic")

-- 扑克花色、点数转为id值
function C:colorNumber2Id(color, number)
    if number == 15 then
        return 53
    elseif number == 16 then
        return 54
    end
    color = color - 3
    return number + color * 13 - 1
end

-- 扑克id值转为花色、点数
function C:id2ColorNumber(id)
    if id == 53 then
        return { cardcolor = 2, cardnumber = 15 }
    end
    if id == 54 then
        return { cardcolor = 2, cardnumber = 16 }
    end
    local color = math.floor((id - 1) / 13) + 3
    local num = id % 13
    num = num + 1
    return { cardcolor = color, cardnumber = num }
end

return C
-- endregion