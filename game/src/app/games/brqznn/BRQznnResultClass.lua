local C = class("BRQznnResultClass",ViewBaseClass)

C.BINDING = {

}
C.playerNodeArr = nil
local beishu = 1
local factory = 1
local goldList={}
local curOrder = 1000

function C:ctor( node )
    for i=1,8 do
        local key = string.format("player%d",i)
        local path = {path=string.format("player_%d",i)}
        self.BINDING[key] = path
    end
	C.super.ctor(self,node)
end

function C:removeTimer()
    utils:removeTimer("brqznn.flyWin")
    utils:removeTimer("brqznn.flyLose")
end

function C:onCreate()
    self.playerNodeArr = {}
    for i=1,8 do
        local key = string.format("player%d",i)
        local node = self[key]
        self.playerNodeArr[i] = node
    end
    curOrder = 1000
end

--设置倍数
function C:setBeishu(_beishu)
    beishu=_beishu
end

function C:setVisible( flags )
	self.node:setVisible(flags)
end

function C:getPositionBySeatId( seatId )
    local playerNode = self.playerNodeArr[seatId]
	return cc.p( playerNode:getPositionX(), playerNode:getPositionY() )
end

function C:playFlyCoinAnimation( banker, losers, winners, callback )
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
    self.node:setVisible(true)
    goldList={}
    local delayWin = self:flyWin(banker,losers, winners)
    self:removeTimer()
    utils:delayInvoke("brqznn.flyWin",delayWin,function()
        local delayLose = self:flyLose(banker,winners,losers,0.1)
        utils:delayInvoke("brqznn.flyLose",delayLose,function()
            if callback then
                callback()
            end
            printInfo(">>>>>>>>>>>>>goldList>>>>>>>>111>>>>"..#goldList)
            for i = 1, #goldList do
                local gold = goldList[i]
                local delay = math.random(10,25)/100
                local arr = {}
                arr[1]=cc.DelayTime:create(delay)
                arr[2]=cc.FadeOut:create(0.2)
                arr[3]=cc.CallFunc:create(function()
                    gold:removeFromParent()
                end)
                gold:stopAllActions()
                gold:runAction(cc.Sequence:create(arr))
            end        
        end)
    end)
end

function C:flyWin(banker,losers, winners,delay)
    if banker == nil or banker == -1 then return end
    if delay==nil then
        delay=0
    end
    local delayWin =0
    if #losers > 0 then
        self:playFLyGoldSound()
        local tomove = #winners>0
        for i = 1, #losers do
            local startPos = self:getPositionBySeatId(losers[i].localSeatId)
            local endPos = self:getPositionBySeatId(banker)
            local count = math.abs(losers[i].changemoney/beishu/MONEY_SCALE) 
            --限制在（15-30） 
            count=math.min(count,30)
            count=math.max(count,15)
            printInfo(i..">>>>>>>>>>>>>flyWin>>>>>>>>>>>>"..count)
            local time = 0
            for i = 1, count do
                local gold = self:createGold(self.node)
                time = 0.02 * (i - 1)+delay
                time=time + self:moveGold(gold,startPos,endPos,time,true,tomove)
                table.insert(goldList,gold)
            end
            delayWin=math.max(delayWin,time)
        end
        printInfo(">>>>>>>>>>>>>delayWin>>>>>>>>>>>>"..delayWin)
    else
        delayWin=delay
    end
    return delayWin
end

function C:flyLose(banker,winners,losers,delay)
    if banker == nil or banker == -1 then return end
    if delay==nil then
        delay=0
    end
    local delayLose =0
    if #winners > 0 then 
        self:playFLyGoldSound()     
        local startPos = self:getPositionBySeatId(banker)
        --self:addGold(losers,winners,startPos)
        local index = 1
        for i = 1, #winners do
            local endPos = self:getPositionBySeatId(winners[i].localSeatId)        
            local count = math.abs(winners[i].changemoney/0.95/beishu/MONEY_SCALE)
            --限制在（15-30）      
            count=math.min(count,35)
            count=math.max(count,20)
            printInfo(i..">>>>>>>>>>>>>flyLose>>>>>>>>>>>>"..count)
            local time = 0
            for i = 1, count do
                local gold = goldList[index]
                if gold==nil then
                    gold=self:createGold(self.node)
                    gold:setPosition(startPos)
                    table.insert(goldList,gold)
                end
                index=index+1
                time = 0.02 * (i - 1)+delay
                time=time + self:moveGold(gold,startPos,endPos,time,false,false)
            end
            delayLose=math.max(delayLose,time)           
        end
        index=index-1
        printInfo(">>>>>>>>>>>>>index>>>>>>>>>>>>"..index)
        printInfo(">>>>>>>>>>>>>goldList>>>>>>>>>>>>"..#goldList)
        if index<#goldList then
            local count = math.ceil((#goldList-index)/#winners)
            if count==0 then
                count=1
            end
            printInfo(">>>>>>>>>>>>>count>>>>>>>>>>>>"..count)
            for i = 1, #winners do
                local endPos = self:getPositionBySeatId(winners[i].localSeatId)        
                local time = 0
                for k = 1, count do
                    local gold = goldList[index+1]
                    if gold==nil then
                        gold=self:createGold(self.node)
                        gold:setPosition(startPos)
                        table.insert(goldList,gold)
                    end
                    index=index+1
                    time = 0.02 * (k - 1)+delay
                    time=time + self:moveGold(gold,startPos,endPos,time,false,false)
                end
                delayLose=math.max(delayLose,time)           
            end
        end
        printInfo(">>>>>>>>>>>>>delayLose>>>>>>>>>>>>"..delayLose)
    else
        delayLose=delay
    end
    return delayLose
end

--创建金币
function C:createGold(parent)
    local gold = display.newSprite(GAME_BRQZNN_IMAGES_RES.."fly_gold1.png")
    --gold:setScale(0.8)
    gold:setLocalZOrder(curOrder)
    curOrder=curOrder+1
    parent:addChild(gold)

    return gold
end

--补齐金币
function C:addGold(losers,winners,startPos)
    local allCount = 0
    for i = 1, #winners do
        allCount=allCount+winners[i].changemoney/0.95/beishu/MONEY_SCALE
    end
    allCount=math.min(allCount,(#winners-#losers)*30)
    printInfo(">>>>>>>>>>补齐金币>>>>>>>>>>"..allCount)
    if allCount>0 then
        for i = 1, allCount do
            local gold = self:createGold(self.node)
            gold:setPosition(startPos)
            table.insert(goldList,gold)
        end
    end
end

--金币移动
function C:moveGold(gold,startPos,endPos,delay,isFisrt,toMove)
    if gold==nil then
        printInfo(">>>>>>>>>>gold为nil>>>>>>>>>>>")
        return
    end
    if isFisrt then
        gold:setPosition(startPos)
    end

    local width = 100 / 4
    local gapX = math.random(-width, width)
    local gapY = math.random(0, width)
    local realEndPos = cc.p(endPos.x+gapX, endPos.y+gapY*factory)
    --金币飞的速度，这速度如果减慢，需要更改上面playFlyCoinAnimation延时调用的时间
    local speed = 2600
    local time = cc.pGetDistance(startPos, realEndPos) / speed

    local p1 = cc.p(startPos.x + (realEndPos.x - startPos.x) * 0.3,startPos.y + (realEndPos.y - startPos.y) * (0.3+factory*0.12))
    local p2 = cc.p(startPos.x + (realEndPos.x - startPos.x) * 0.6,startPos.y + (realEndPos.y - startPos.y) * (0.6-factory*0.12))
    factory=-factory
    local delayAni = cc.DelayTime:create(delay)
    local easeOut = cc.EaseSineInOut:create(cc.BezierTo:create(time,{p1,p2,realEndPos}))
    local delay1 = math.random(7,20)/100
    local delayAni1 = cc.DelayTime:create(delay1)
    local callfun = cc.FadeOut:create(0.2)
    if toMove then
        gold:runAction(cc.Sequence:create({delayAni,easeOut}))
    else
        gold:runAction(cc.Sequence:create({delayAni,easeOut,delayAni1,callfun}))
    end

    return time
end

function C:resetData()
    factory = 1
    --goldList={}
    curOrder = 1000
    --utils:removeTimer("brqznn.flyWin")
    --utils:removeTimer("brqznn.flyLose")
end

function C:playFLyGoldSound()
    PLAY_SOUND(GAME_BRQZNN_SOUND_RES.."coins_fly.mp3")
end


return C