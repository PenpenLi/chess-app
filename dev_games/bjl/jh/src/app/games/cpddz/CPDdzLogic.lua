
local C = class("CPDdzLogic")

local Constant = 
{
    -- 所有的牌，长度1-K+王=14
    CARD_TYPES = 14,

    -- 黑红草方
    CARD_TYPE_COUNT = 4,
    CARD_SPADES = 1,
    CARD_HEARTS = 2,
    CARD_DIAMONDS = 3,
    CARD_CLUBS = 4,

    CARD_3 = 1,
    CARD_4 = 2,
    CARD_5 = 3,
    CARD_6 = 4,
    CARD_7 = 5,
    CARD_8 = 6,
    CARD_9 = 7,
    CARD_10 = 8,
    CARD_J = 9,
    CARD_Q = 10,
    CARD_K = 11,
    CARD_A = 12,
    CARD_2 = 13,
    CARD_KING = 14,

    -- 大小王下标索引
    CARD_KING_COUNT = 2,
    CARD_KING1 = 1,
    CARD_KING2 = 2,
}


local CardMap = {
    "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "Joke"
}
local KIND_COUNT = 13

function C:ctor()
    -- 拥有的牌
    self.cards = {}
    -- 已选择打算出的牌
    self.playCards = {}
    -- 这个是否是第一手的状态以及其他用户的回合状态等，不该放这里，因为这里专注card，本地测用，等等，我用otherCards表示上家出的牌，同时就可以判断是否自己第一手了
    -- 上家出手的牌，如果没有则为{}
    self.otherCards = {}
    self.willInPlay = {}
end

-- 这个应该第一次发牌和每次出牌回来的协议都会调用这个方法
function C:resetCards()
    -- 他们都是二维数组
    -- self.cards = self:parseData(proto)
    -- self.playCards = {[4]={1,0,1,0}, [8]={0,1,1,0}} 
    self.cards = {}
    self.playCards = {}
    self.otherCards = {}
end

function C:parseData(proto)
    -- 解析成本地需要的格式：大小为52数组，为0表示没有这张牌，平铺是最简单的，需要的对子/顺子的时候动态解析，无论是发送牌还是接受牌，这是权衡的最佳格式，还有问题。。。方块桃花这类怎么存，
    -- 有了，不存个数，直接存table，{1,0,1,0}，黑/红/草/方这样的顺序，这个表示一个黑桃，一个草花，也就是说，其实这是一个二维数组，proto就可以这样定义，那是不是可以直接返回拿来用呢？
    return proto
end

-- function C:convertToProto(data)
--     data = self.playCards
--     local keys = {}
--     local types = {}
--     for k, v in pairs(data) do
--         table.insert(keys, k)
--         -- print(pl.dump(v))
--         local c = DdzProto.CardType({values = v})
--         table.insert(types, c)
--     end
--     -- print(pl.dump(keys))
--     -- print(pl.dump(types))
--     return keys, types
-- end

function C:cardsToProto(cards)
    local cards = cards or self.playCards
    local res = {}
    for k, v in pairs(cards) do
        for k2, v2 in ipairs(v) do
            if v2 ~= 0 then
                local id = (k2 -1) * KIND_COUNT + k
                if k == Constant.CARD_KING then
                    id = 52 + k2
                end
                table.insert(res, id)
            end
        end
    end
    table.sort(res)
    -- print(pl.dump(res))
    -- self:protoToCards(res)
    return res
end

function C:protoToCards(proto)
    local res = {}
    for k, v in pairs(proto) do
        local key = v % KIND_COUNT                      --点数
        local pos = math.floor(v/KIND_COUNT) + 1        --花色
        if key == 0 then
            key = Constant.CARD_2
            pos = pos - 1
        end
        if v == 53 then
            key = Constant.CARD_KING
            pos = 1
        elseif v == 54 then
            key = Constant.CARD_KING
            pos = 2
        end
        -- print("key " .. key)
        if not res[key] then
            res[key] = {0,0,0,0}
        end
        res[key][pos] = 1
    end
    -- print(pl.dump(res))
    -- self:printFormat(res)
    return res
end

function C:idToCard(id)
    local v = id
    local key = v % KIND_COUNT 
    local pos = math.floor(v/KIND_COUNT) + 1
    if key == 0 then
        key = Constant.CARD_2
        pos = pos - 1
    end
    if v == 53 then
        key = Constant.CARD_KING
        pos = 1
    elseif v == 54 then
        key = Constant.CARD_KING
        pos = 2
    end
    -- print("id: " .. id .. " => " .. "key: " .. key ..  " type: " .. pos)
    return key, pos
end

function C:cardToId(num, t)
    assert(num and 0 < num and num < 15, "error num value " .. tostring(num))
    local res = 0
    if num == Constant.CARD_KING then
        res = 52 + t
    else
        res = KIND_COUNT * (num == Constant.CARD_2 and (t-1) or t) + num
    end
    assert(0 < res and res < 55, "error id " .. res)
    -- print("key: " .. num .. " type: " .. t ..  " => id " .. res)
    return res
end

-------------------- Add by Jerry ------------------

function C:colorNumber2Id(color,number)
    if number == 2 then
        number = 13
    elseif number == 15 then
        return 53
    elseif number == 16 then
        return 54
    else
        number = number - 2
    end
    color = color - 3
    return color * 13 + number
end

function C:id2ColorNumber(id)
    if id == 53 then
        return {cardcolor = 2,cardnumber = 15}
    end
    if id == 54 then
        return {cardcolor = 2,cardnumber = 16}
    end
    local color = math.floor((id - 1) / 13) + 3
    local num = id % 13
    num = num + 2
    return {cardcolor = color,cardnumber = num}
end

----------------------------------------------------

function C:getKeys(data)
    local cards = data or self.cards
    local keys = {}
    for k, v in pairs(cards) do
        table.insert(k)
    end
end

function C:isValidCards()
    -- bba.log("--- isValidCards");
    -- bba.printTable(self.playCards);
    -- 验证所有的组合，自己第一手情况，如果自己是后手，可能需要另外地方实现，判断是否能压过上家
    local isFirst = TableLen(self.otherCards) == 0
    local res = false
    if isFirst then
        res = self:isValidFirstCards()
        print("TEST VALID IN FIRST  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. tostring(res))
    else
        res = self:isValidSecondCards()
        print("TEST VALID IN SECOND >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. tostring(res))
    end
    return res
end

function C:isValidFirstCards()
    -- 通过牌的个数猜测可能的结果，比如2张的话基本需要验证的就是对子和王炸
    local count = self:getPlayCardsCount()
    print("play cards count: " .. tostring(count))
    if count < 1 then
        return false
    end

    if count == 1 then
        return true
    elseif count == 2 then
        return self:isDouble() --这里不需要判断王炸，因为王炸就是一对。。肯定合法
    elseif count == 3 then
        return self:isTriple()
    elseif count == 4 then
        return self:isBomb() or self:isTripleWithSingle()
    elseif count == 5 then
        return self:isSingleStraight() or self:isTripleWithDouble() or self:isBombWithWings()
    elseif count == 6 then
        return self:isSingleStraight() or self:isDoubleStraight() or self:isTripleStraight() or self:isBombWithWings()
    else
        return self:isSingleStraight() or self:isDoubleStraight() or self:isTripleStraight() or self:isTripleStraightWithWings() or self:isBombWithWings()
    end
end

function C:isValidSecondCards()
    if not self:isValidFirstCards() then 
        -- 先手的规则不满足，肯定后手也不满足
        print("invalid in first")
        return false
    else
        local res = self:isPlayCardsBiggerThanOther()
        if res then
            print("play cards valid")
        else
            print("invalid in second")
        end
        return res
    end
end

-- 王炸不能带任何swings
function C:isKingBomb(keys, max, swings)
    if max ~= 2 or TableLen(swings) ~= 0 then
        return false
    else
        return keys[1] == Constant.CARD_KING and TableLen(keys) == 1
    end
end

function C:isCommonBomb(keys, max, swings)
    -- print(pl.dump(keys))
    -- print(pl.dump(swings))
    return max == 4 and TableLen(keys) == 1 and TableLen(swings) == 0
end

function C:isOtherBomb(otherKeys, otherMax)

end

function C:isPlayCardsBiggerThanOther()
    -- 只返回的是maxKeys，不包括wings
    local otherKeys, otherMax, otherSwings = self:getOtherMaxKeysTypes()
    local playKeys, playMax, playSwings = self:getPlayMaxKeysTypes()
    -- print(pl.dump(playKeys))
    -- print(playMax)
    -- print(playKeys[14])

    if self:isKingBomb(otherKeys, otherMax, otherSwings) then
        -- 对面王炸，gg
        return false
    end

    -- 普通炸弹&王炸处理
    -- 王炸比较吊，可以压过所有炸弹
    if self:isKingBomb(playKeys, playMax, playSwings) then
        return true
    end

    -- 上家是炸弹，则要炸弹比对方大，如果不是炸弹，比如四带，则任何炸弹都可
    if self:isCommonBomb(otherKeys, otherMax, otherSwings) then
        -- print("other bomb")
        if self:isCommonBomb(playKeys, playMax, playSwings) and playKeys[1] > otherKeys[1] then
            return true
        else
            return false
        end
    else
        -- print("other not bomb " .. tostring(playMax))
        if self:isCommonBomb(playKeys, playMax, playSwings) then
            return true
        end
    end

    -- 对子算一个翅膀，不解析为两个，费劲巴拉的
    -- 符合形式，比如单对单，三对三，四对四？
    if playMax == otherMax then
        -- 符合个数一致，比如三连对 vs 三联对， 7顺子 vs 7顺子
        if TableLen(playKeys) == TableLen(otherKeys) then
            -- 符合最小值比对方大
            if TableLen(playKeys) == 1 then
                -- 大小王比较
            end
            local myKey = playKeys[1]
            local otherKey = otherKeys[1]
            -- 大小王比较，还需要通过type index，我日。。
            if myKey == Constant.CARD_KING and otherKey == Constant.CARD_KING then
                return self.playCards[myKey][2] == 1
            end
            -- 插入翅膀形式判断
            -- print(pl.dump(otherSwings))
            -- print(pl.dump(playSwings))
            -- if not self:isWingsFormatSame(playSwings, otherSwings) then
            if not self:isWingsFormatSame(playKeys, playMax, playSwings, otherKeys, otherMax, otherSwings) then
                return false
            end
            if myKey > otherKey then
                return true
            end
        end
    end
    -- 否则小
    return false
end

function C:isWingsFormatSame(k1, m1, w1, k2, m2, w2)
    local f1, c1 = self:parseWingsFormat(k1, m1, w1)
    local f2, c2 = self:parseWingsFormat(k2, m2, w2)

    print("my    format: " .. tostring(f1) .. ", count: " .. tostring(c1))
    print("other format: " .. tostring(f2) .. ", count: " .. tostring(c2))

    return f1 == f2 and c1 == c2


    -- -- 个数和形式一样才算相等
    -- if TableLen(w1) == TableLen(w2) then
    --     local t1 = {}
    --     for k1, v1 in pairs(w1) do
    --         table.insert(t1, self:getTypesCount(v1))
    --     end
    --     table.sort(t1)
    --     local t2 = {}
    --     for k2, v2 in pairs(w2) do
    --         table.insert(t2, self:getTypesCount(v2))
    --     end
    --     table.sort(t2)

    --     for k, v in ipairs(t1) do
    --         if v ~= t2[k] then
    --             return false
    --         end
    --     end
    --     return true
    -- end
    -- return false
end

function C:getHintCards(isAnyway)
    self.willInPlay = {}
    self.playCards = {}
    print("other Cards >>>>>>>>>>>>>>>>>>>>>")
    -- bba.printTable(self.otherCards)
    if TableLen(self.otherCards) == 0 then
        print("no other hint >>>> " .. tostring(self:getMinHintCard()))
        
        -- self:printFormat(self:getMinHintCard())
        local res, main = self:getMinHintCard()
        if res then
            self.playCards = res
            return res, main
        else
            if TableLen(self.cards) > 0 then
                assert(false, "error when get min cards")
            end
            return nil
        end
    end
    -- 这里的Other是按照按照types个数排序，比如三个6带1应该先
    local otherKeys, otherMax, otherSwingKeys = self:getOtherMaxKeysTypes()
    local format, count, minValue = otherMax, #otherKeys, otherKeys[1]
    local main, bomb = self:getHintFormat(format, count, minValue, otherSwingKeys)
    -- print(pl.dump(main))
    local res = main
    -- 炸弹不能带了吧。。。除非上家也是炸弹带， 如果我是炸弹用法，也不能带翅膀
    -- print("try bomb usage " .. tostring(bomb))
    
    -- 这里应该要for循环根据otherswing加入key了orz
    -- print(pl.dump(otherSwingKeys))
    if main and not bomb then
        local notfoundSwing = false
        for k, _ in pairs(main) do
            -- print(k)
            table.insert(self.willInPlay, k)
        end
        -- print("?")
        -- print(pl.dump(self.willInPlay))

        if isAnyway then
            if TableLen(otherSwingKeys) > 0 then
                local swings = self:getHintSwingFormatAnyway(otherKeys, otherMax, otherSwingKeys)
                if swings then
                    res = TableConcat(res, swings)
                else
                    res = nil
                end
            end
        else
            for _, v in pairs(otherSwingKeys) do 
                -- local count = self.otherCards[k]
                local count = self:getTypesCount(v)
                -- print(count)

                -- temp switch
                -- todo 有问题啊。。。还得排除我已经选的main key。。。。好像不要把，因为main key都是3个以上的，我这里的翅膀就不考虑拆了吧...wocao
                local temp = self.cards
                self.cards = self.cardsBackup
                local swing = self:getHintSwingFormat(count, 1)
                self.cards = temp
                -- temp switch

                if not swing then
                    print("not found swings with format " .. count)
                    notfoundSwing = true
                    break
                else
                    for k, _ in pairs(swing) do
                        table.insert(self.willInPlay, k)
                    end
                    self:printFormat(swing)
                    res = TableConcat(res, swing)
                end
            end 
            -- self:printFormat(res)
            -- 如果没有合适的swings，再找一次炸弹
            if notfoundSwing then
                print("not found all swings, try bomb >>>>>>>>>>>>")
                res = self:getBomb()
            end
        end
    end


    -- if main and (format == 3 or (format == 4 and self:isWithWings(format, count, self.otherCards))) and (not bomb) then
    --     local wings = self:getHintWings(main, TableLen(main) * (format-2))
    --     res = TableConcat(main, wings)
    -- end



    if not res then
        print("\nNOT FOUND HINT CARDS >>>>>>>>>>>>>>>>>>> ")
        -- bba.printTable(self.otherCards)
        -- bba.printTable(self.cards)
        return nil
    else
        print("found hint cards")
        self.playCards = self:getSortedCards(res)
        -- print(pl.dump(self.playCards))
        self:printFormat(self.playCards)
        -- print(pl.dump(self.playCards))
        local isValid = self:isValidSecondCards()
        if isValid then
            print("\nVALID SUCCESS >>>>>>>>>>>>>>>>>>>>>>>")
        else
            print("\nVALID FAIL >>>>>>>>>>>>>>>>>>>>>>")
            self.playCards = {}
        end
        return self.playCards, main;
    end
end

function C:getMinHintCard()
    local keys = {}
    for k, v in pairs(self.cards) do
        table.insert(keys, k)
    end
    table.sort(keys)
    -- print(pl.dump(keys))
    if #keys == 0 then
        return nil
    else
        local res = {}
        local minKey = 1
        if #keys == 1 then
            print("only left one key, show it anyway ")
            table.insert(res, keys[minKey], TableClone(self.cards[keys[minKey]]))
            -- self:printFormat(res)
            return res, res
        end
        for _, k in ipairs(keys) do
            -- 如果只剩下炸弹了，出
            -- print(self:getTypesCount(self.cards[k]))
            -- print("fuck " .. k)
            if self:getTypesCount(self.cards[k]) ~= 4 then
                minKey = _
                break
            end
        end
        -- 5555 6666会走到这= =，如果走到这了，直接返第一个
        local k = keys[minKey]
        local v = self.cards[keys[minKey]]
        -- print("add key ".. k)
        -- bba.printTable(v)
        -- bba.printTable(self.cards)
        assert(self:getTypesCount(v) > 0, "error count 0 in key " .. k)
        table.insert(res, k, TableClone(v))
        if self:getKeyTypesCount(self.cards, k) == 3 then
            -- temp switch
            local temp = self.cards
            self.cards = self.cardsBackup
            print("fuck " .. tostring(self.cards))
            -- todo 应该在排除了k的table里找wings
            local wings = self:getHintWings(res, 1)
            self.cards = temp
            res = TableConcat(res, wings)
            self:printFormat(res)
        end
        -- self:printFormat(res)
        return res, {[k]=v}
    end
end

function C:isWithWings(format, count, cards)
    return (format * count ~= self:getCardsCount(cards))
end

function C:isWithWings2(cards)
    local count
    for k, v in pairs(cards) do
        local c = self:getTypesCount(v)
        if not count then
            count = c
        else
            if count ~= c then
                return true
            end
        end
    end
    return false
end

function TableConcat(t1,t2)
    local res = {}
    for k, v in pairs(t1) do
        res[k] = v
    end
    for k, v in pairs(t2) do
        res[k] = v 
    end
    return res
    -- for i=1,#t2 do
    --     t1[#t1+1] = t2[i]
    -- end
    -- return t1
end

function TableRemove(t, pos)
    local res = {}
    for k, v in pairs(t) do
        if k ~= pos then
            res[k] = v
        end
    end
    return res
end

function TableLen(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function TableClone(t)
    if not t then
        assert(false, "error: want to clone nil table")
    end
    local res = {}
    for k, v in pairs(t) do
        res[k] = v
    end
    return res
end

function C:printFormat(cards)
    -- 如果个数一样，从小到大，如果个数不一样，按个数先排
    if not cards then
        print("NOT CARDS IN PRINTFORMAT")
        return
    end
    local keys = self:getMaxKeysTypes(cards)
    local main = ""
    for _, k in pairs(keys) do
        local count = self:getTypesCount(cards[k])
        for i = 1, count do
            main = main .. CardMap[k]
        end
        main = main .. " "
    end

    local wings = ""
    for k, v in pairs(cards) do
        if not self:isTableContainsKey(keys, k) then
            local count = self:getTypesCount(v)
            for i = 1, count do
                wings = wings .. CardMap[k] 
            end
        end
        wings = wings .. " "
    end 
    print(main .. "- " .. wings)
end

function C:isTableContainsKey(t, key)
    for k, v in pairs(t) do
        if v == key then
            return true
        end
    end
    return false
end

-- 翅膀
function C:getHintWings(mainKeys, wingsCount)
    local res = {}
    local count = 0
    -- print("hint wingsCount: " .. wingsCount)
    -- 从小找到大, 排除主体，三个的不进入
    -- for k, v in pairs(self.cards) do
    for i = 1, Constant.CARD_TYPES do
        if self.cards[i] then
            local k = i
            local v = self.cards[i]
            local c = self:getTypesCount(v)
            -- 不管怎么样，一对王，都不让带
            if k == Constant.CARD_KING and c == 2 then
                break
            else
                if not mainKeys[k] and (1 <= c and c <= 2) then
                    print("hint wings insert " .. k)
                    table.insert(res, k, TableClone(v))
                    count = count + 1
                    if count == wingsCount then
                        break
                    end
                end
            end
        end
    end

    -- 如果有剩余，无脑把剩下的最小都加进入
    if count < wingsCount then
        -- for k, v in pairs(self.cards) do
        for i = 1, Constant.CARD_TYPES do
            if self.cards[i] then
                local k = i
                local v = self.cards[i]
                local c = self:getTypesCount(v)
                -- 不管怎么样，一对王，都不让带
                if k == Constant.CARD_KING and c == 2 then
                    break
                else
                    if self:getKeyTypesCount(self.cards, k) > 0 then
                        -- print("hint wings insert " .. k)
                        table.insert(res, k, TableClone(v))
                        count = count + 1
                        if count == wingsCount then
                            break
                        end
                    end 
                end
            end
        end        
    end

    -- 如果还剩名额？那就说明牌全出了....
    if count < wingsCount then
        print("fuck all cards out , i win >>>>>>>>>>>>>>>>>>>>>>>>> ")
    end
    return res
end

function C:getAllTypeCards(typeValue)
    local res = {}
    for k, v in pairs() do
        if self:getTypesCount() == typeValue then
            table.insert(res, k)
        end
    end
    return res
end

-- function C:getHintFormatAnyway(format, count, minValue, swingsKeys)
--    local remainCount = TableLen(self.cards)
--     for i = 1, Constant.CARD_TYPES do
--         local k = i
--         if self.cards[k] then
--             local v= self.cards[k]
--             if remainCount < count then
--                 break
--             end
--             -- 如果在format > 1的情况，比如对子，就不要找王啦...如果有炸弹下面炸弹会找的
--             if format > 1 and k == Constant.CARD_KING then
--                 break
--             end

--             -- 拆，排除炸弹，而且得排除掉已经加入playCards的key
--             -- 如果是多选情况，炸弹也拆，因为这个时候以出牌量为判断标准
--             local includeBomb = (isFromSelect and true or self:getTypesCount(v) ~= 4)
--             if self:getTypesCount(v) >= format and k > minValue and includeBomb  and (not self:isTableContainsKey(self.willInPlay, k)) then
--                 local res = {}
--                 table.insert(res, k, TableClone(self:getNeededTypes(v, format)))
--                 -- print("droply insert1 " .. k)
--                 if count == 1 then
--                     print("found in droply 1")
--                     return res
--                 else
--                     for i = 1, count-1 do
--                         local nextKey = k + i
--                         local nextValue = self.cards[nextKey]
--                         -- print("nextKey " .. tostring(nextKey ~= Constant.CARD_KING))
--                         -- ~=4 排除炸弹不拆
--                         if nextValue and nextKey < Constant.CARD_2  and self:getTypesCount(nextValue) >= format and includeBomb  and (not self:isTableContainsKey(self.willInPlay, nextKey)) then
--                             nextValue = self:getNeededTypes(nextValue, format)
--                             -- print("droply insert2 " .. nextKey)
--                             table.insert(res, nextKey, TableClone(nextValue))
--                             if TableLen(res) == count then
--                                 print("found in droply")
--                                 return res
--                             end
--                         else
--                             -- return nil
--                             break
--                         end
--                     end            
                    
--                 end
--             end
--             remainCount = remainCount - 1
--         end
--     end
--     -- 先转为解析后的wings format, 然后再传入，如果是一个对子解析为两个单牌，那么需要优先找单牌
--     self:getHintFormat(format, count, minValue, swingKeys, true)
-- end

-- 所有的类型 1/1单牌 1/5+顺子 2/1对子 2/3+双顺子 3/2+ 三顺子 4/1& king/2 炸弹
-- swings形式{1,2}表示一个单牌，一个对子
function C:getHintFormat(format, count, minValue, swingKeys, isFromSelect, isAnyway)
    print("getHintFormat format: " .. format .. ", count: " .. count .. ", minValue: " .. minValue)
    -- 如果是单牌，要先找单牌，没有再拆这样？
    -- 一般来说是遍历两遍，第一遍是找刚好符合类型的，第二遍是需要拆的
    self.cards = self:getSortedCards(self.cards)
    -- local foundExactly = false
    -- important: 这里都依赖于A是12，因为只有这样才会CARD_A > CARD_3
    -- todo 当count > 1，也就是说，2和王不能进入任何顺子，只能能进普通的不连的单/双/三/四
    local remainCount = TableLen(self.cards)
    -- self:printFormat(self.cards)
    -- print(pl.dump(self.cards))
    -- print("remainCount " .. remainCount)
    -- 完，，，ipairs不能用...
    for i = 1, Constant.CARD_TYPES do
    -- for k, v in pairs(self.cards) do
        -- todo key 并不是从小道大 fuck。。。。难道只能1-14判断nil这样遍历了吗ORZ
        local k = i
        -- 没有continue真的烦。。。
        if self.cards[k] then
            local v = self.cards[k]
            -- print("fuck key " .. k)
            if remainCount < count then
                break
            end
            -- 如果在format > 1的情况，比如对子，就不要找王啦...如果有炸弹下面炸弹会找的
            if format > 1 and k == Constant.CARD_KING then
                break
            end

            if self:getTypesCount(v) == format and (k > minValue or (k == Constant.CARD_KING and self.cards[k][2] == 1) ) and (not self:isTableContainsKey(self.willInPlay, k)) then
                local res = {}
                table.insert(res, k, TableClone(v))
                -- print(pl.dump(v))
                -- print("hint main exactly insert key " .. k)
                -- 本来打算在hint的时候直接排除2和王的顺子。。。但是这样感觉没必要，因为找到2了说明已经是最终情况了，反正后面还要验证,
                -- 额。。。但是这样有bug，比如qq,kk,aa,22,jokejoke，这样是可以出炸弹的，但是会被这里当成顺子出去，然后验证失败..，所以，，还是这里也判断吧，只要判断不是王即可，如果加上2的话，连普通对还要额外处理了
                -- 额。。。但是这样也不行，因为同样找到2之后返回了然后验证失败。。但其实我有炸弹...，加上一个判断吧。。单牌、对子好像这层if包括了，也就是说进for的肯定count > 2

                for i = 1, count-1 do
                    local nextKey = k + i
                    local nextValue = self.cards[nextKey]
                    if nextValue and nextKey < Constant.CARD_2 and self:getTypesCount(nextValue) == format then
                        -- print("hint main exactly insert key " .. nextKey)
                        table.insert(res, nextKey, TableClone(nextValue))
                    end
                end
                if TableLen(res) == count then
                    -- print(pl.dump(res))
                    print("found in exactly")
                    return res
                end
            end
            remainCount = remainCount - 1
        end
    end
    print("not found hint card exactly ")

    -- 插入炸弹大小判断
    if format == 4 and count == 1 and TableLen(swingKeys) == 0 then
        local biggerBomb = self:getBombBiggerThan(minValue)
        if biggerBomb then
            print("found bigger bomb than " .. minValue)
        else
            print("not found bigger bomb than " .. minValue)
        end
        return biggerBomb
    end


    -- 上面没return则就会来到这里
    remainCount = TableLen(self.cards)
    for i = 1, Constant.CARD_TYPES do
    -- for k, v in pairs(self.cards) do
        local k = i
        if self.cards[k] then
            local v= self.cards[k]
            if remainCount < count then
                break
            end
            -- 如果在format > 1的情况，比如对子，就不要找王啦...如果有炸弹下面炸弹会找的
            if format > 1 and k == Constant.CARD_KING then
                break
            end

            -- 拆，排除炸弹，而且得排除掉已经加入playCards的key
            -- 如果是多选情况，炸弹也拆，因为这个时候以出牌量为判断标准
            local includeBomb = (isFromSelect and true or self:getTypesCount(v) ~= 4)
            if self:getTypesCount(v) >= format and k > minValue and includeBomb  and (not self:isTableContainsKey(self.willInPlay, k)) then
                local res = {}
                table.insert(res, k, TableClone(self:getNeededTypes(v, format)))
                -- print("droply insert1 " .. k)
                if count == 1 then
                    print("found in droply 1")
                    return res
                else
                    for i = 1, count-1 do
                        local nextKey = k + i
                        local nextValue = self.cards[nextKey]
                        -- print("nextKey " .. tostring(nextKey ~= Constant.CARD_KING))
                        -- ~=4 排除炸弹不拆
                        if nextValue and nextKey < Constant.CARD_2  and self:getTypesCount(nextValue) >= format and includeBomb  and (not self:isTableContainsKey(self.willInPlay, nextKey)) then
                            nextValue = self:getNeededTypes(nextValue, format)
                            -- print("droply insert2 " .. nextKey)
                            table.insert(res, nextKey, TableClone(nextValue))
                            if TableLen(res) == count then
                                print("found in droply")
                                return res
                            end
                        else
                            -- return nil
                            break
                        end
                    end            
                    
                end
                -- if #res == count then
                --     -- print("fuck")
                --     return res
                -- end
            end
            remainCount = remainCount - 1
        end
    end
    print("not found hint card droply ")

    -- 使用炸弹，如果有的话，且上家不能是炸弹用法，如果上家是炸弹应该要进入第一个for，但是上家炸弹带翅膀的话，又是不一样的逻辑了
    -- self:isWithWings(format, count, self.otherCards)
    if not isFromSelect then
        if format ~= 4 or (format == 4 and self:isWithWings(format, count, self.otherCards)) then
            return self:getBomb(), true
        end
    end

    print("not found hint bomb")

    -- 没有大过上家的
    return nil
end

-- 妈的，同时还需要解析出别人到底是单牌还是对子，这个按main key来，如果wings max和总数相同便是单牌，如果和wing keys个数相同便是对子，可行
function C:parseWingsFormat(mainKeys, keysMax, swings)
    -- print(pl.dump(mainKeys))
    -- print(pl.dump(swings))
    if not swings or TableLen(swings) == 0 then
        return 0, 0
    end
    local maxWingsCount = 0
    if keysMax == 4 then
        maxWingsCount = 2
    elseif keysMax == 3 then
        maxWingsCount = #mainKeys * 1
    end
    local swingsCount = self:getCardsCount(swings)

    print("keysMax: " .. tostring(keysMax) .. ", swingsCount: " .. swingsCount .. ", maxWingsCount: " .. tostring(maxWingsCount))
    if swingsCount == maxWingsCount then
        return 1, maxWingsCount
    else
        assert(2 * maxWingsCount == swingsCount)
        return 2, swingsCount
    end
end

-- format:count 1:2 表示两个单牌 2:3表示3个对子
function C:getHintSwingFormatAnyway(keys, keysMax, swings)
    local format, count = self:parseWingsFormat(keys, keysMax, swings)
    print("anyway wings >>>>>>>>>>>>> format: " .. tostring(format) .. " count: " .. tostring(count))
    -- print(pl.dump(keys))
    -- print(pl.dump(swings))
    local remainCount = TableLen(self.cards)
    -- print("fuck " .. tostring(remainCount))
    local needCount = count
    local res = {}
    for i = 1, Constant.CARD_TYPES do
        if self.cards[i] then
            local k = i
            local v = self.cards[i]
            -- if remainCount < needCount then
            --     print(tostring(remainCount) .. "<" .. tostring(needCount))
            --     print("?")
            --     break
            -- end

            local addedCount = format == 1 and self:getTypesCount(v) or format
            -- print("addedCount: " .. tostring(addedCount))
            if addedCount >= format and (not self:isTableContainsKey(self.willInPlay, k)) then
                local putCount = math.min(addedCount, needCount)
                print("add " .. tostring(k) .. " count " .. tostring(putCount))
                if self:getNeededTypes(v, putCount) then 
                    table.insert(res, k, TableClone(self:getNeededTypes(v, putCount)))
                    print("needCount: " .. tostring(needCount))
                    needCount = needCount - putCount
                end 

                if needCount == 0 then
                    print("find anyway success")
                    -- print(pl.dump(res))
                    return res
                end
            end
            -- remainCount = remainCount - 1
        end
    end
    return nil
end

function C:getHintSwingFormat(format, count)
    -- print("getHintSwingFormat format: " .. format .. ", count: " .. count )
    assert(count == 1, "not valid param in getSwingFormat")
    -- self:printFormat(self.cards)
    self.cards = self:getSortedCards(self.cards)
    -- self:printFormat(self.cardsBackup)
    local remainCount = TableLen(self.cards)
    -- for k, v in pairs(self.cards) do
    for i = 1, Constant.CARD_TYPES do
        if self.cards[i] then
            local k = i
            local v = self.cards[i]
            if remainCount < count then
                break
            end
            if self:getTypesCount(v) == format and (not self:isTableContainsKey(self.willInPlay, k)) and k ~= Constant.CARD_KING then
                local res = {}
                table.insert(res, k, TableClone(v))
                return res
            end
            remainCount = remainCount - 1
        end
    end
    -- print("not found hint swing card exactly ")


    remainCount = TableLen(self.cards)
    -- for k, v in pairs(self.cards) do
    for i = 1, Constant.CARD_TYPES do
        if self.cards[i] then
            local k = i
            local v = self.cards[i]
            if remainCount < count then
                break
            end
            if self:getTypesCount(v) >= format and (not self:isTableContainsKey(self.willInPlay, k)) and k ~= Constant.CARD_KING  then
                local res = {}
                table.insert(res, k, TableClone(self:getNeededTypes(v, format)))
                return res
            end
            remainCount = remainCount - 1
        end
    end
    -- print("not found hint swing card droply ")

    -- 没有找到合适的swing
    return nil
end

function C:getBomb()
    local bomb = self:getCommonBomb()
    if bomb then 
        return bomb
    else
        bomb = self:getKingBomb()
        if bomb then
            return bomb
        end
    end
    return nil
end

function C:getBombBiggerThan(bombKey)
    -- for k, v in pairs(self.cards) do
    for i = 1, Constant.CARD_TYPES do
        if self.cards[i] then
            local k = i
            local v = self.cards[i]
            if self:getKeyTypesCount(self.cards, k) == 4 and k > bombKey then
                local res = {}
                table.insert(res, k, TableClone(v))
                return res
            end
        end
    end    
    local kingBomb = self:getKingBomb()
    return kingBomb
end

function C:getCommonBomb()
    for i = 1, Constant.CARD_TYPES do
    -- for k, v in pairs(self.cards) do
        if self.cards[i] then
            local k = i
            local v = self.cards[i]
            if self:getKeyTypesCount(self.cards, k) == 4 then
                local res = {}
                table.insert(res, k, TableClone(v))
                return res
            end
        end
    end    
    return nil
end

function C:getKingBomb()

    local k = Constant.CARD_KING
    local v = self.cards[k]
    if v and self:getTypesCount(v) == 2 then
        local res = {}
        table.insert(res, k, TableClone(v))
        return res
    end
    return nil    
end

function C:getNeededTypes(types, count)
    -- 从后往前抹去
    local ownCount = 0
    if self:getTypesCount(types) ~= count then
        local res = {0, 0, 0, 0}
        for i = 1, #types-1 do
            if types[i] ~= 0 then
                res[i] = types[i]
                ownCount = ownCount + 1
                if ownCount == count then
                    return res
                end
            end
        end
    else
        return types
    end
end

-- function C:getAllSingle()
--     return self:getAllTypeCards(1)
-- end

-- function C:getAllDouble()
--     return self:getAllTypeCards(2)
-- end

-- function C:getAllTriple()
--     return self:getAllTypeCards(3)
-- end

-- function C:getAllBomb()
--     -- todo 王炸
--     return self:getAllTypeCards(4)
-- end

-- function C:getAllStraight(type, count)
--     -- 顺子尼玛还必须得遍历所有类型的。。。对子也得拆...炸弹也拆吗？应该是的，提示应该把炸弹留最后
-- end

function C:getOtherMaxKeysTypes()
    return self:getMaxKeysTypes(self.otherCards)
end

function C:getPlayMaxKeysTypes()
    return self:getMaxKeysTypes(self.playCards)
end

function C:getMaxKeysTypes(cards)
    -- 只获取主数据，没有带翅膀，因为没必要知道，
    -- 需要这这里鉴定出来是单牌还是对子，看getAllHints方法上面的注释，返回需要知道wingsFormat, wingsCount：1,2表示2个单牌, 2:3，表示3个对子
    local mainKeys = {}
    local swingKeys = {}
    local max = self:getMaxType(cards)
    local wingsExistKingBomb = false
    for k, v in pairs(cards) do
        -- wcnm，别人如果带三个。。。这里还得区分开，我日啊
        if self:getTypesCount(v) == max then 
            table.insert(mainKeys, k)
        else
            if k == Constant.CARD_KING and self:getTypesCount(v) == 2 then
                wingsExistKingBomb = true
            end
            table.insert(swingKeys, TableClone(v))
        end
    end
    -- types好像没用，直接通过keys来取就行了, keys现在是存的主数据，并且从小到大排序
    table.sort(mainKeys)

    -- 只有飞机以上才需要排序，而且加这个if判断主要是为了找到所有的三个里面有可能有的三个是翅膀，这里只是为了找到翅膀的伪三个，而一个三个的翅膀需要三个飞机，也就是说至少要四个三个才会进
    if max == 3 and #mainKeys >= 4 then
        local sortedKeys = {}
        local keys = mainKeys
        table.sort(keys)
        -- 有可能是{1,3,4,5}这样，卧槽
        -- 这里有问题。。。。可能需要在两部分找出更连续的。。。不用，我只要找到一个连续的就接着找应该也可以
        -- todo 上家出33344455-jqk，我们出666777888999101010会被解析成不带翅膀的四架飞机，因为他们连着了= = ，这个问题先放着把，能1/10000出我都服你。。。
        for i = 1, #keys do
            if (i-1) > 0 and (keys[i] - keys[i-1] == 1) then
                if not self:isValueInTable(sortedKeys, keys[i-1]) then
                    table.insert(sortedKeys, keys[i-1])
                end
                table.insert(sortedKeys, keys[i])
            end
        end


        for k, v in pairs(keys) do
            if not self:isValueInTable(sortedKeys, v) then
                table.insert(swingKeys, TableClone(cards[v]))
            end
        end

        -- print(pl.dump(mainKeys))
        -- print(pl.dump(swingKeys))
        assert(#sortedKeys > 0, "error: sortedKeys is empty")
        -- print(pl.dump(sortedKeys))
        return sortedKeys, max, swingKeys, wingsExistKingBomb
    else
        return mainKeys, max, swingKeys, wingsExistKingBomb
    end

end

function C:getMaxType(cards)
    local max = 1
    for k, v in pairs(cards) do
        local cur = self:getTypesCount(v)
        if cur > max then
            max = cur
        end
    end
    return max
end

function C:getKeysCount()
    -- 不能用#，只能这样咯...
    -- local keys = self.playCards.keys
    local count = 0
    for _, v in pairs(self.playCards) do
        count = count + 1
    end
    return count
end

function C:getTypesCount(types)
    local count = 0
    for _, v in pairs(types) do
        if v ~= 0 then
            count = count + 1
        end
    end
    return count
end

function C:getKeyTypesCount(cards, key)
    for k, v in pairs(cards) do
        if k == key then
            return self:getTypesCount(v)
        end
    end
    assert(false, "not found key " .. key)
end

function C:getPlayCardsCount()
    return self:getCardsCount(self.playCards)
end

function C:getPlayCardsSingleKey()
    assert(self:getPlayCardsCount() <= 2, "error: play card count must <= 2")
    for k, v in pairs(self.playCards) do
        return k
    end
end

function C:getCardsCount(cards)
    local count = 0
    for _, v in pairs(cards) do
        count = count + self:getTypesCount(v) 
    end
    return count
end

function C:isSmallKing()
    return self:isSingle() and self.playCards[Constant.CARD_KING] and (self.playCards[Constant.CARD_KING][Constant.CARD_KING1] == 1)
end

function C:isBigKing()
    return self:isSingle() and self.playCards[Constant.CARD_KING] and (self.playCards[Constant.CARD_KING][Constant.CARD_KING2] == 1)
end

function C:isDoubleKing()
    return self:isDouble() and self.playCards[Constant.CARD_KING] and (self.playCards[Constant.CARD_KING][Constant.CARD_KING1] == 1) and (self.playCards[Constant.CARD_KING][Constant.CARD_KING2] == 1)
end

function C:isSingle()
    return self:getPlayCardsCount() == 1
end

function C:isDouble()
    -- 如果两张牌，且keys只有一个，那肯定是对了，否则不是
    return self:getPlayCardsCount() == 2 and self:getKeysCount() == 1
end

function C:isTriple()
    -- 同上
    return self:getPlayCardsCount() == 3 and self:getKeysCount() == 1
end

function C:isCountWith(targetCount, count1, count2)
    if self:getKeysCount() ~= targetCount then
        return false
    else
        local c = {}
        for k, v in pairs(self.playCards) do
            local count = self:getTypesCount(v)
            c[#c+1] = count

            -- 如果有带了两王，不让
            if count == 2 and k == Constant.CARD_KING then
                print("error: with two kings")
                return false
            end
        end
        local res = (c[1] == count1 and c[2] == count2) or (c[1] == count2 and c[2] == count1)
        return res
    end
end

function C:isTripleWithSingle()
    return self:isCountWith(2, 3, 1)
end

function C:isTripleWithDouble()
    return self:isCountWith(2, 3, 2)
end

function C:isBomb()
    return self:getKeysCount() == 1
end

function C:isBombWithWings()
    -- 一个炸弹最多能带两种类型
    local wingsMaxCount = 2
    local keys, max, swings, wingsExistKingBomb = self:getPlayMaxKeysTypes()
    if wingsExistKingBomb then
        print("error: with two kings")
        return false
    else
        -- print("max " .. tostring(max))
        if max == 4 and TableLen(keys) == 1 then
            -- if TableLen(swings) <= wingsMaxCount then
                -- print(pl.dump(swings))
                return self:isFormatSame(swings, 2, true)
            -- end
        end
        return false
    end
end

function C:isFormatSame(wings, maxCount, isBomb)
    if TableLen(wings) > maxCount then
        return false
    end
    -- 如果这个是返回1，也就是说是单牌解析了，那直接返回wings总个数，无论key是否相同
    -- 可以如果只传入了一个对子，那么可以解析为单牌，也可以解析为对子我日，而且两个对子也是一样需要处理。。。也就是说min最小如果是2，那么如果2解析不过，还需要重试
    local min = 0
    local totalCount = 0
    local wingsCount = 0
    local wingsFormat = 0
    for k, v in pairs(wings) do
        local format = self:getTypesCount(v)
        -- 因为是无序遍历的，所以有可能两对一单牌221先2走if然后1走else又重置为1了，然后再走2这样wingsCount最后是2.。。我日啊。所以放在一开始处理了，如果key大于maxCount，根本就不需要这里判断了，必错
        if format == min or min == 0 then
            wingsCount = wingsCount + 1
        else
            wingsCount = 1
        end

        totalCount = totalCount + format
        if format > min then
            wingsCount = 1 -- reset 
            min = format
        end

        wingsFormat = format
    end

    print( "min: "..tostring(min) .. ", wingsCount: " .. tostring(wingsCount) .. ", maxCount: " .. tostring(maxCount) .. ", totalCount: " .. tostring(totalCount))

    if min >= 4 then
        return false
    elseif min == 3 or min == 2 then
        -- 2和3的情况都需要计算一遍单牌
        if isBomb and TableLen(wings) == 1 and wingsFormat == 2 then
            -- 如果是炸弹带一对，要解析成单牌
            print("insert parse: bomb with single min: 1")
            min = 1
        end
        return (maxCount == wingsCount or maxCount == totalCount), min
    elseif min == 1 then
        return (maxCount == totalCount) , min
    else
        return true 
    end

    return min, count
end

-- function C:isFormatSame(swingsKeys, wingsTypeMax)
--     local count = 0
--     for k, v in pairs(swingsKeys) do 
--         -- local newCount = self:getKeyTypesCount(self.playCards, v)
--         local newCount = self:getTypesCount(v)
--         -- print("swing count " .. newCount)
--         assert(newCount ~= 0, "error key " .. tostring(v) .. " with count 0")
--         if newCount > 2 then
--             return false
--         end
--         if count == 0 then
--             count = newCount
--         else
--             if newCount ~= count then
--                 return false
--             end
--         end
--     end
--     print("swings format " .. tostring(count))
--     return count
--     -- return true
-- end

-- function C:isBombWithSingle()
--     return self:isCountWith(2, 4, 1)
-- end

-- function C:isBombWithDouble()
--     return self:isCountWith(2, 4, 2)
-- end

function C:isKeysContinuous(data)
    local keys = {}
    if data then
        -- 这里是{2,1,7,8}的keys形式
        keys = data
        table.sort(keys)
    else
        -- {[4]={1,1,1,0}}的完整形式
        local pos = 1
        local cards = data or self.playCards
        for k, v in pairs(cards) do
            -- print(k)
            table.insert(keys, pos, k)
            pos = pos + 1
        end
        
        -- print(pl.dump(cards))

        table.sort(keys)
    end
    -- print(pl.dump(keys))
    -- print(keys[#keys])
    -- print(#keys)
    -- 连续只能从3-A
    local len = TableLen(keys)
    -- print("key len: " .. len)
    if keys[len] > Constant.CARD_A then
        return false
    end

    for i = 1, len-1 do
        if keys[i+1] - keys[i] ~= 1 then
            return false
        end
    end
    -- print(pl.dump(cards))
    -- print(pl.dump(keys))
    return true
end

function C:isEqualWith(value)
    for _, v in pairs(self.playCards) do
        local count = self:getTypesCount(v)
        if count ~= value then
            return false
        end
    end
    return true
end

function C:isStraightWith(value)
    local isEqual = self:typesCountEqualWith(value)
    local isCon = self:isKeysContinuous()
    -- print("isEqual: " .. tostring(isEqual) .. ", isCon: " .. tostring(isCon))
    -- if self:getKeysCount() % value ~= 0 or (not self:isKeysContinuous()) then
    if isEqual and isCon then
        return true
        -- local equalCount = self:getKeysCount() / value
        -- return self:isEqualWith(equalCount)
    else
        return false
    end
end

function C:typesCountEqualWith(value)
    for k, v in pairs(self.playCards) do
        if self:getTypesCount(v) ~= value then
            return false
        end
    end
    return true
end

function C:isSingleStraight()
    return self:isStraightWith(1)
end

function C:isDoubleStraight()
    -- print("not double " .. tostring(self:isStraightWith(2)))
    return self:isStraightWith(2)
end

function C:isTripleStraight()
    return self:isStraightWith(3)
end

function C:isTripleStraightWithWings()
    local keys, wingsTypeMax, wingsTypeCount, swingsKeys = self:getTripleKeysAndWings()
    -- print(pl.dump(swingsKeys))
    -- 至少要两个key才
    -- print("wingsTypeCount " .. wingsTypeCount .. " wingsTypeMax " .. wingsTypeMax )
    -- print(pl.dump(keys))
    -- print(self:isKeysContinuous(keys))

    -- if TableLen(keys) > 1 and self:isKeysContinuous(keys) and (wingsTypeCount == wingsTypeMax) and self:isFormatSame(swingsKeys) then
    if TableLen(keys) > 1 and self:isKeysContinuous(keys) and self:isFormatSame(swingsKeys, wingsTypeMax) then
        -- print("wings true")
        return true
    else
        print("wings false")
        return false
    end 

end

-- function C:isTripleStraightWithFormat(tripleCount, wingsCount, wingsTypeMax)
--     local keys, wingsTypeMax, wingsTypeCount = self:getTripleKeysAndWings()
--     if self:isKeysContinuous(keys) and wingsTypeCount < wingsTypeMax then
--         return true
--     else
--         return false
--     end 
-- end

function C:getTripleKeysAndWings()
    local keys = {}
    local wingsTypeCount = 0
    local wingsTypeMax = 0
    local wingsKeys = {}
    for k, v in pairs(self.playCards) do
        if self:getTypesCount(v) == 3 then
            table.insert(keys, k)
            -- wingsTypeMax = wingsTypeMax + 1
        else
            table.insert(wingsKeys, TableClone(v))
            wingsTypeCount = wingsTypeCount + 1
        end
    end

    table.sort(keys)
    -- print(pl.dump(keys))

    local sortedKeys = {}
    -- 有可能是{1,3,4,5}这样，卧槽
    -- 这里有问题。。。。可能需要在两部分找出更连续的。。。不用，我只要找到一个连续的就接着找应该也可以
    for i = 1, #keys do
        if (i-1) > 0 and (keys[i] - keys[i-1] == 1) then
            if not self:isValueInTable(sortedKeys, keys[i-1]) then
                table.insert(sortedKeys, keys[i-1])
            end
            table.insert(sortedKeys, keys[i])
        end
    end


    for k, v in pairs(keys) do
        if not self:isValueInTable(sortedKeys, v) then
            table.insert(wingsKeys, TableClone(self.playCards[v]))
        end
    end


    wingsTypeMax = #sortedKeys
    -- print("wingsTypeMax: " .. tostring(wingsTypeMax))

    return sortedKeys, wingsTypeMax, wingsTypeCount, wingsKeys
end

function C:isValueInTable(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end


-- 一次只会改一个，注意大小王的处理，最多就是{1,1,0,0}，第一个表示大王
function C:addPlayCard(num, cardType)
    assert(num <= Constant.CARD_TYPES)
    -- 返回的是引用
    local types = self.playCards[num]
    local res = {0, 0, 0, 0}
    if types then
        res = TableClone(types)
        if res[cardType] == 1 then
            -- 算了。。重复添加先放过吧。。。
            -- assert(false, "error: duplicate add in one cardType " .. cardType)
        end
    end

    if num == Constant.CARD_KING then
        assert(cardType <= Constant.CARD_KING_COUNT)
    else
        assert(cardType <= Constant.CARD_TYPE_COUNT)
    end

    res[cardType] = 1
    self.playCards[num] = res
    -- 直接排序，这个没用。。。。
    -- table.sort(self.playCards)
    self.playCards = self:getSortedCards(self.playCards)
    -- print(pl.dump(self.playCards))
end

function C:getSortedCards(cards)
    local keys = {}
    for k, v in pairs(cards) do
        table.insert(keys, k)
    end

    table.sort(keys)
    -- 确实是有序了，但是dump的时候是无序的...
    -- print(pl.dump(keys))
    local res = {}
    for _, k in pairs(keys) do
        table.insert(res, k, TableClone(cards[k]))
    end
    return res
end

function C:removePlayCard(num, cardType)
    print("remove play card " .. tostring(num) .. ", " .. tostring(cardType))
    assert(num <= Constant.CARD_TYPES)
    local singleTypeCard = self.playCards[num]
    if not singleTypeCard then
        assert(false, "error: want to remove num not existed")
        return
    else
        if singleTypeCard[cardType] ~= 1 then
            bba.printTable(singleTypeCard)
            assert(false, "error: want to remove cardType not existed")
            return
        end
    end


    if num == Constant.CARD_KING then
        assert(cardType <= Constant.CARD_KING_COUNT)
    else
        assert(cardType <= Constant.CARD_TYPE_COUNT)
    end

    -- 返回的是引用，直接改完就可以了，但是删除的时候不能直接=nil，因为这样只是取消这个引用而已，并不会修改原数据，要修改元数据必须元数据=nil
    -- attention: 注意这里因为是引用，所以playCards里面存的一定不能是self.cards的引用！！！！
    singleTypeCard[cardType] = 0
    -- bba.printTable(singleTypeCard)
    -- print(pl.dump(singleTypeCard))
    -- print("is empty " .. tostring(self:isEmpty(singleTypeCard)))
    if self:isEmpty(singleTypeCard) then
        -- print("remove key from playCards: " .. num)
        -- 中间存在Nil，则#计算会出问题，所以要直接remove
        -- self.playCards[num] = nil
        -- remove后面前移，会保持原序
        -- 妈的。。。。remove也只能针对pos从1开始的table。。。沃日。。。ORZ
        -- table.remove(self.playCards, num)
        self.playCards = TableRemove(self.playCards, num)
        -- bba.printTable(self.playCards)
        -- print(pl.dump(self.playCards))
    end
    -- print(pl.dump(self.playCards))
end

function C:isEmpty(card)
    for k, v in pairs(card) do
        -- 只有nil/false是false，0是true
        if v == 1 then
            return false
        end
    end
    return true
end

-- function tempSetPlayCards(cards)
--     self.playCards = cards
-- end

function C:resetPlayCards(cards)
    -- must reset when my turn start
    self.playCards = cards or {}
end

function C:setOtherCards(cards)
    -- print("set other cards " .. tostring(cards))
    self.otherCards = cards

    -- temp set for isXXX judge
    self.playCards = cards 
    -- print("set other cards")
    -- self:printFormat(cards)
end

function C:setNewCards(newCards)
    self.cards = newCards
    self.playCards = {}
    self.otherCards = {}
    self.willInPlay = {}
    self:resetHints()
    -- 这个时候才是我的回合结束
end

function C:resetHints()
    self.allHints = nil
    self.hintIndex = 1
end

-- 这里存在一个取舍，因为按照现在的逻辑，三带一的提示简直有十几种，显然是不合适的，所以我认为现在的策略是，如果能找到正常的不拆和对拆，就不会去再找三拆（四拆永远不找，因为永远都能成功提示）
-- ，只有在实在没有的情况下才会去三拆，因为不然用户只能点要不起。。。说实话是对ui的一种弥补，不然不需要这么复杂的。。。唉
-- 妈的，同时还需要解析出别人到底是单牌还是对子，这个按main key来，如果wings max和总数相同便是单牌，如果和wing keys个数相同便是对子，可行
-- 当出现需要anyway情况的时候，重置所有willplay之类的，只找一个，对，目的是只需要找到一个合适的即可，不然你妈逼的还想让提示做多少？？？
function C:getAllHints()
    self.allHints = {}
    local otherKeys, otherMax, otherSwings = self:getOtherMaxKeysTypes()
    if self:isKingBomb(otherKeys, otherMax, otherSwings) then
        -- 对面王炸，gg
        print("other is king bomb ,hint size 0")
        return self.allHints
    end
    self.hintIndex = 1
    -- temp change
    self.cardsBackup = self.cards
    self.cards = self:cloneAllCards()
    -- print(pl.dump(self.cards))

    -- find normal format 
    while true do
        local hintCards, mainKeys = self:getHintCards()
        if not hintCards then
            break
        else
            assert(TableLen(mainKeys) > 0)
            -- todo wings不能排除，顺子的除第一个头外，其他也不能排除吧，我应该找到需要排除的，比如顺子的第一个key，炸弹，三个，怎么写呢，如果每个key的个数不同，那个肯定是wings，如果相同肯定是顺子？
            -- 我应该只排除主体key，也就是 getHintCards里面的main  要找wings的时候应该要去全牌里面找，不能只在这里的self.cards，要去temp里面的完整找的
            -- for k, v in pairs(mainKeys) do
            --     -- 排除已找到的key
            --     -- nil就不会被pairs遍历了，所以这里可以设置为nil表示移除，那我tableremove也可以这样？再说吧
            --     print("set nil to key " .. k)
            --     self.cards[k] = nil
            -- end


            local keys = {}
            for k, v in pairs(mainKeys) do
                table.insert(keys, k)
            end
            table.sort(keys)
            -- 神之一手来一发=。=
            -- 现在逻辑就是如果有完美匹配的情况下，找拆不成功的情况是：除非这个拆的这个key是 （完美匹配的顺子的头 && 是拆匹配的中间），个人觉得已经可以很够了。。。=。=
            -- 还有就是，炸弹是不拆的！！！永远不拆！！！其实更好的是炸弹可拆，因为是循环提示了。。。如果是单个提示的话不拆是对的，如果是可拆我得判断如果是拆炸弹情况，我不能移除，那还就不能简单这样
            -- 找第一个置空了，因为有可能拆的炸弹就是第一个。。。其实也可以无脑置空，就是需要后面再加一个专门找炸弹的方法咯。。。然后放进去，那好复杂啊。。如果上家是炸弹我还得过滤一掉小得炸弹。。不拆吧ORZ
            -- 王。。。单牌情况，我有大小王。。找不到大王了因为是一个key，我日。。。早知道设置成两个key了，这里我用一个逻辑，如果！我有大小王，我要拆的话，肯定小王足以！！！，所以，没问题
            -- 但是。。。王炸还得找啊。。。所以我在下面reset之后专门找了一次...
            self.cards[keys[1]] = nil
            -- if #keys >= 1 then
            --     -- 大于1的情况的话，好像只有顺子？ 我这里是mainKeys，也就是主体部分，这些单体的wings应该会被过滤了，比如，三带，四带。那我是不是无论keys个数，直接无脑置空第一个keys就行了？=。=
            --     self.cards[keys[1]] = nil
            -- end

            self:printFormat(hintCards)
            table.insert(self.allHints, hintCards)
            -- print("FIND")
        end
    end

    local isAnyway = false
    if #self.allHints == 0 then
        isAnyway = true
        local hintCards, mainKeys = self:getHintCards(true)
        print("get hints ANYWAY >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>. " .. tostring(hintCards))
        if hintCards then
            -- assert(TableLen(mainKeys) > 0)
            -- local keys = {}
            -- for k, v in pairs(mainKeys) do
            --     table.insert(keys, k)
            -- end
            -- table.sort(keys)
            -- self.cards[keys[1]] = nil
            table.insert(self.allHints, hintCards)
        else
            -- print("NOT FOUND IN ANYWAY")
        end
    end


    -- reset
    self.cards = self.cardsBackup
    -- self:printFormat(self.cards)

    -- 王炸在reset之后才能找哦。。。
    -- find bomb 我懂了。。因为我炸弹不拆的，所以不需要另外再写，机智啊ORZ
    local kingBomb = self:getKingBomb()
    if kingBomb then
        for k, v in pairs(kingBomb) do
            table.insert(self.allHints, kingBomb)
        end
    end




    print("\nALL HINTS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> " .. (isAnyway and "ANYWAY" or ""))
    for k, n in ipairs(self.allHints) do
        self:printFormat(n)
    end
    print("hints count: " .. #self.allHints)
    return self.allHints
end

function C:getNextHint()
    if not self.allHints then
        self:getAllHints()
    end
    if #self.allHints == 0 then
        return nil
    else
        -- print("get hint index at " .. self.hintIndex)
        local res = self.allHints[self.hintIndex]
        self.playCards = res
        self.hintIndex = self.hintIndex + 1
        if self.hintIndex > #self.allHints then
            -- 重头循环
            self.hintIndex = 1
        end
        return res
    end
end

function C:cloneAllCards()
    -- print(self:cardsToProto(self.cards))
    -- local proto = self:cardsToProto(self.cards)
    -- print(pl.dump(proto))
    return self:protoToCards(self:cardsToProto(self.cards))
end

-- 获取选中牌的应该出的牌
function C:getSelectedHintCards(selectedCards)
    -- 如果选中的已经是有效的了，就不做事情了
    self.playCards = selectedCards
    if self:isValidCards() then
        print("is perfect valid cards")
        return self.playCards
    end

    self:printFormat(selectedCards)
    -- temp swap
    local backup = self.cards
    local backup2 = self.cardsBackup
    self.cardsBackup = selectedCards
    self.cards = selectedCards
    local isFirst = TableLen(self.otherCards) == 0
    local res 
    -- 下面的方法里，self.cards已经是selected cards，所以要用self.cards来做就好
    if isFirst then
        print("first selected ")
        res = self:getFirstHand(backup)
    else
        -- 后手有可能为nil，因为找不到大过上一家的
        print("second selected ")
        res = self:getSecondHand(backup)
    end

    -- reset
    self.cards = backup 
    self.cardsBackup = backup2
    print("GET SELECTED HINT CARDS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.")
    self:printFormat(res)
    -- 只在有res的情况下才会替换成playCards
    if res then
        self.playCards = res
    end
    return res
end

function C:getFirstHand(backup)
    -- 先手策略，就是找到可选牌里可以出牌最多张的那个方案，也就是说，我需要找到所有可能性。。。然后找出能出最多的那个，
    -- 找的顺序应该是 
    -- 顺子：（包括双顺三顺，三顺优先，其实没有优先。。都得找，最多的那个为好） 三顺还需要判断翅膀，如果有符合规则的翅膀在selected，那就选中，如果是少于规则，那就不加翅膀，如果多于规则，那就选出最小的符合规则的
    -- 四带：这个稍微简单，找四个的，然后找翅膀解法和顺子一样
    -- 对子：简单找最小的对子
    -- 单牌：简单找最小的单牌
    -- 炸弹？先手没有炸弹的说法，如果选中四个和另外的牌，就判断为四带而不是炸弹，要炸弹自己只选四个就好

    -- 能不能利用提示的minValue来fake other cards每一个种类型的找法这样呢。。。我想想。。。
    -- 还有一点，优先级如果找到了就不往下找了，也就是说，只有各种顺子类型需要判断，然后始终 顺子 > 四带 所以找到顺子即可返回
    local res 

    local straight = self:getSelectedStraight()
    -- <5 是为了排除三带一
    if straight then
        res = straight
    else
        local bombWith = self:getSelectedBombWith()
        if bombWith then
            res = bombWith
        else 
            local singleTriple = self:getSingleTriple()
            if singleTriple then
                res = singleTriple
            else
                -- 单牌和对子，直接去最小的key就好了，应该就是getMinHintCard的结果
                -- self.cardsBackup = backup
                -- self.cards = backup
                self.cardsBackup = self.cards
                res = self:getMinHintCard()
            end
        end
    end
    -- 先手的话不管怎么样，res都不可能为nil
    -- 有可能为nil，手动把最后一张牌选下来。。这样就是nil了
    -- bba.log(res)
    -- assert(res and TableLen(res) > 0, "res is nil in first hand")



    -- print(pl.dump(res))
    -- print("get first hand cards >>>>>>>>>>>>>>>>>>>>>>>>>>>")
    -- self:printFormat(res)
    return res
end

function C:getMaxCountStraight(format, keysCount, minCount)
    local res 
    local wingsCount
    for i = keysCount, minCount, -1 do
        -- 单顺格式 1/5+
        res = self:getHintFormat(format, i, 0, {}, true)
        if res then
            wingsCount = i
            break
        end
    end

    -- todo 如果format==3还要找翅膀
    if res and format == 3 then
        local cardsFormat = self:getCardsFormat()
        local main = {}
        for k, v in pairs(res) do
            table.insert(main, k)
        end
        local found, wings = self:getNeededWings(wingsCount, main)
        -- self:printFormat(wings)
        if found then
            res = TableConcat(res, wings)
        end

    end

    -- print(pl.dump(res))
    return res, res and self:getCardsCount(res) or 0
end

function C:getSelectedStraight()
    local keysCount = TableLen(self.cards)
    local cardsFormat = self:getCardsFormat()

    -- 这里要有优化，比如我3345667779,这样可能是找5张的，但是实际上key有6个，我还是要先找有没有6顺
    -- 我觉得更好的，是不是应该先找到所有的k-v分布，比如几张单牌，几张对子，几张双这样 {5,2,1,1}表示5张单牌，2个对子，1个三个，1个四个，用index来表示牌型就好

    local singlePossibleCount = self:getPossibleKeysCount(cardsFormat, 1)
    local doublePossibleCount = self:getPossibleKeysCount(cardsFormat, 2)
    local triplePossibleCount = self:getPossibleKeysCount(cardsFormat, 3)
    -- local quadraPossibleCount = self:getPossibleKeysCount(cardsFormat, 1)


    -- 顺子
    -- local singleMaxCount, doubleMaxCount, tripleMaxCount = 0, 0, 0
    -- local singleCards, doubleCards, tripleCards = nil, nil, nil
    local singleMinCount, doubleMinCount, tripleMinCount = 5, 3, 2 -- 这里包括单体三带一
    local singleCards, singleMaxCount = self:getMaxCountStraight(1, singlePossibleCount, singleMinCount)
    local doubleCards, doubleMaxCount = self:getMaxCountStraight(2, doublePossibleCount, doubleMinCount)
    local tripleCards, tripleMaxCount = self:getMaxCountStraight(3, triplePossibleCount, tripleMinCount)
    -- self.willInPlay = {}

    print("single " .. tostring(singleMaxCount) .. ", double " .. tostring(doubleMaxCount) .. ", triple " .. tostring(tripleMaxCount))

    -- 同样牌数，因为如果3344556677 总不能选成34567吧。。。= =，然而并不会出现这种情况。。因为牌数是他两倍了，
    -- 考虑344556678情况，取445566还是345678呢？假设用户头尾是主观选择的，也就是说ai处理的时候应该尽量包含用户选择的头尾部，所以是取单顺子,
    -- 那如果是34455667呢？应该是双顺子好了，因为别人容易要不起，现在的算法，也是取到双顺子，因为双顺有6张牌
    -- 优先级 按照出牌数相同情况下： 单 > 双 > 三 
    -- 677888899910 情况选啥？要不要考虑这种情况呢...按照现在的算法是取到 888 999 - 10 6，我觉得挺好的...当然如果按照上面的说法，要头尾的话应该是单顺子。。但是飞机别人容易要不起，相当于出牌的期望变高，就这样先！！
    -- 另外一种算法是按照key出的数量优先级而不是总牌数，再另外一种是包含头尾的出牌优先级高，再一种是按照牌型别人容易要不起的期望优先级排序，最后一种是单顺子无脑最大，因为最有可能包含头尾，各有各的问题吧。。。
    -- 终极算法：是根据现有的card format各种牌有的情况，包括大小和牌数，来推测出一个可能性value值，按照这个值优先级排序
    -- 妈的，先手比后手费劲太多。。。后手简单的走提示就可以了。。。再选中的牌中找到大于上一家，没毛病吧？
    if singleMaxCount >= doubleMaxCount then
        if singleMaxCount >= tripleMaxCount then
            return singleCards
        else
            return tripleCards
        end
    else
        if doubleMaxCount >= tripleMaxCount then
            return doubleCards
        else
            return tripleCards
        end
    end
end


function C:getSelectedBombWith()
    -- 四带
    local cardsFormat = self:getCardsFormat()
    if cardsFormat[4] ~= nil then
        local main = self:getHintFormat(4, 1, 0, {}, true)
        local play = {}
        for k, v in pairs(main) do
            table.insert(play, k)
        end

        local found, wings = self:getNeededWings(2, play)
        local res = main
        if found then
            print("found wings")
            res = TableConcat(res, wings)
        else
            print("not found wings")
        end
        assert(res, "not found bomb with ")
        return res
    end
end

function C:getSingleTriple()
    -- 三带
    local cardsFormat = self:getCardsFormat()
    local triplePossibleCount = self:getPossibleKeysCount(cardsFormat, 3)
    local singleTriple = self:getMaxCountStraight(3, triplePossibleCount, 1)
    return singleTriple
end

-- count==2 表示要找两个翅膀，调用者不关心是单个还是对子
function C:getNeededWings(count, play)
    print("need wings count " .. tostring(count))
    self.willInPlay = play 
    local notfoundSwing = false
    local wingsRes = {}
    -- 按照minkey的那个类型来找，wings只能是对子以下
    local firstFormat =  math.min(self:getMinWingFormat(), 2)
    local secondFormat = firstFormat == 1 and 2 or 1
    print("wing first format " .. tostring(firstFormat) .. ", second format " .. tostring(secondFormat))
    for i = 1, count do
        local wings = self:getHintSwingFormat(firstFormat, 1)
        if not wings then
            notfoundSwing = true
            break
        else
            for k, _ in pairs(wings) do
                table.insert(self.willInPlay, k)
            end
            wingsRes = TableConcat(wingsRes, wings)
            -- table.insert(wingsRes, wings)
        end
    end

    if notfoundSwing then
        self.willInPlay = play
        wingsRes = {}
        print("not found double wings")
        notfoundSwing = false
        for i = 1, count do
            local wings = self:getHintSwingFormat(secondFormat, 1)
            if not wings then
                notfoundSwing = true
                break
            else
                for k, _ in pairs(wings) do
                    table.insert(self.willInPlay, k)
                end
                -- print("insert " .. tostring(wings))
                -- table.insert(wingsRes, wings)
                wingsRes = TableConcat(wingsRes, wings)
            end
        end            
    end
    -- reset
    self.willInPlay = {}
    -- self:printFormat(wingsRes)
    -- print(pl.dump(wingsRes))
    return not notfoundSwing, wingsRes
end

function C:getMinWingFormat()
    for i = 1, Constant.CARD_TYPES do
        if self.cards[i] and not self.willInPlay[self.cards[i]] then
            return self:getTypesCount(self.cards[i])
        end
    end
end

function C:getMaxCountCards(...)
    if #{...} == 0 then
        return nil
    end
    local maxCount = 0
    local res = nil
    for k, v in pairs(...) do
        local count = self:getCardsCount(v)
        if count > maxCount then
            maxCount = count
            res = v
        end
    end
    -- assert(false, "not found max cards")
    return res
end

function C:getCardsFormat()
    local res = {}
    for k, v in pairs(self.cards) do
        local format = self:getTypesCount(v)
        if not res[format] then
            res[format] = 1
        else
            res[format] = res[format] + 1
        end
    end
    -- print(pl.dump(res))
    return res
end

-- 找到大于format的key的总数，比如单牌1的话，计算index 1234的总和，表示可以利用的总量
function C:getPossibleKeysCount(formatTable, format)
    local count = 0
    for i = format, 4 do
        if formatTable[i] then
            count = count + formatTable[i]
        end
    end
    return count 
end

function C:getSecondHand(backup)
    -- 后手策略，找到最小得打过other cards的方案
    -- return self:getNextHint()
    -- 这个会直接调用getHintCards，需要设置cardsBackup，不然有问题。。因为这个接口现在是为getNextHint服务的，我不能直接调用。。这样怕影响到下一个提示，所以要设置一下
    self.cardsBackup = self.cards
    local res = self:getHintCards()
    -- self.cards = self.cardsBackup
    return res
end

--对扑克排序
function C:sortCards(cards, versace)
	table.sort(cards, function (c1, c2)
		if versace then
			if c1 > 52 or c2 > 52 then 
				return c1 > c2;
			elseif c1%13 == c2%13 then 
				return c1/13 > c2/13;
			else 
				return (c1 + 12)%13 > (c2 + 12)%13;
			end  
		else
			if c1 > 52 or c2 > 52 then 
				return c1 < c2;
			elseif c1%13 == c2%13 then 
				return c1/13 < c2/13;
			else 
				return (c1 + 12)%13 < (c2 + 12)%13;
			end  
		end 
	end)
	return cards;
end 

return C
