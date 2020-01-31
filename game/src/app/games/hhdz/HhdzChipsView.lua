local C = class("HhdzChipsView",ViewBaseClass)

local CHIP_BIG_LAYER_WIDTH = 710
local CHIP_BIG_LAYER_HEIGHT = 100

local CHIP_SMALL_LAYER_WIDTH = 355
local CHIP_SMALL_LAYER_HEIGHT = 178

local CHIP_MAX_NUM = 200
local CHIP_ANIM_MAX_NUM = device.platform == "android" and 60 or 80
local CHIP_TOTAL_NUM = device.platform == "android" and 30 or 40

local MINE_LABEL_TAG = 200
local MINE_LABEL_ICON_TAG = 300
local CHIPS_BACK_SOUND_TAGS = {8881,8882}

local CHIP_SOUND = GAME_HHDZ_SOUND_RES.."bet.mp3"
local CHIP_WIN_SOUND = GAME_HHDZ_SOUND_RES.."win_bet.mp3"

local LUCKY_STAR = GAME_HHDZ_IMAGES_RES .. "luckyStar.png"
local LUCKY_STAR_PARTICLE = GAME_HHDZ_ANIMATION_RES.. "luckyStar.plist"

local STAR_POS = 
{
    {x = 568 + 172.5, y = display.cy + 125},
    {x = 568 -175.5, y = display.cy + 125},
    {x = 568 + 0.8, y = display.cy - 50}
}

local CHIP_SIZE = 
{
    width = 57,
    height = 57
}

local PLAYERS_POS = 
{
    [1] = {x = 70, y = display.cy + 165},
    [2] = {x = 70, y = display.cy - 25},
    [3] = {x = 70, y = display.cy - 145},
    [4] = {x = 1136 - 70, y = display.cy -25},
    [5] = {x = 1136 - 70, y = display.cy -145},
    [6] = {x = 1136 - 70, y = display.cy + 165},
    [7] = {x = 70, y = 50},
    [8] = {x = 1136 - 45, y = 45}
}

local CHIPS_CSB = 
{ 
    [1] = GAME_HHDZ_PREFAB_RES.."Chip1.csb",
    [2] = GAME_HHDZ_PREFAB_RES.."Chip2.csb",
    [3] = GAME_HHDZ_PREFAB_RES.."Chip3.csb",
    [4] = GAME_HHDZ_PREFAB_RES.."Chip4.csb",
    [5] = GAME_HHDZ_PREFAB_RES.."Chip5.csb"
}

C.BINDING = 
{
    blackAreaCon = {path="black_area_con",events={{event="touch",method="onBlackBet"}}},
    redAreaCon = {path="red_area_con",events={{event="touch",method="onRedBet"}}},
    luckyAreaCon = {path="lucky_area_con",events={{event="touch",method="onLuckyBet"}}},
}

C.bets = nil
C.chipsPool = {}
C.usingChips = {}
C.betAreas = nil
C.luckyStarNode = nil
C.isSetLuckyStar = {}
C.luckyStar = nil
C.chipSize = nil
C.updateScheduler = nil
C.flyChips = nil

--初始化
function C:ctor(node,bets,luckyStarNode)
    self.bets = bets
    self.luckyStarNode = luckyStarNode
    self.curChipAnimNum = 0
    self.usingChips = {}
    self.isSetLuckyStar = {}
    self.luckyStar ={}
    C.super.ctor(self,node)
end

function C:onCreate()
    self.betAreas = 
    {
        [1] = self.redAreaCon:getBoundingBox(),
        [2] = self.blackAreaCon:getBoundingBox(),
        [3] = self.luckyAreaCon:getBoundingBox()
    }
    self:createChipsPool(self.bets)
    self.flyChips = {}
	self.updateScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateChip), 0, false)
end

function C:destroy()
	self.flyChips = {}
	self.flyChipsCallback = nil
	if self.updateScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateScheduler)
		self.updateScheduler = nil
	end
end

function C:insertFlyChips( chipNode )
	if self.flyChips == nil then
		self.flyChips = {}
	end
	if self.updateScheduler == nil then
		self.updateScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateChip), 0, false)
	end
	table.insert(self.flyChips,chipNode)
end

function C:updateChip()
	if self.flyChips and #self.flyChips > 0 then
		local chipNode = table.remove(self.flyChips,1)
		self:chipAction(chipNode,chipNode.fromPos,chipNode.toPos)
	end
end

--押注黑方
function C:onBlackBet(event)
	if event.name == "ended" then
		if self.onBlackBetHandler then
			self.onBlackBetHandler()
		end
	end
end

--押注红方
function C:onRedBet(event)
	if event.name == "ended" then
		if self.onRedBetHandler then
			self.onRedBetHandler()
		end
	end
end

--押注幸运一击
function C:onLuckyBet(event)
	if event.name == "ended" then
		if self.onLuckyBetHandler then
			self.onLuckyBetHandler()
		end
	end
end


--创建筹码对象池
function C:createChipsPool(bets)
	if bets and type(bets) == "table" then
        self.bets = bets
        self.chipsPool = {}
		for i,v in ipairs(bets) do
            local chips = {}
			for m = 1, 5 do
				local chip = self:createChip(i)
				if chip then
                    chip:setVisible(false)
					table.insert(chips, chip)
				end
			end
            self.chipsPool[i] = chips
		end
	end
end

--创建筹码
function C:createChip(index)
	local chip = cc.CSLoader:createNode(CHIPS_CSB[index])
    if not chip then
        print("无法创建筹码对象：["..tostring(index).."]")
        return nil
    end
    chip:setTag(index)
    chip:retain()
    if not self.chipSize then
        self.chipSize = chip:getBoundingBox()
    end
    local text = self.bets[index]
    chip:getChildByName("bg"):getChildByName("text"):setString(tostring(text))
    chip:addTo(self.node)
	return chip
end

--获取一个未使用的筹码
function C:getFreeChip(betIndex, isAnim, isDesk)
	if isAnim then
		if not isDesk then
			if self.curChipAnimNum > CHIP_ANIM_MAX_NUM then
				return nil
			end
		end
		self.curChipAnimNum = self.curChipAnimNum + 1
	end
	if not self.chipsPool[betIndex] then
		self.chipsPool[betIndex] = {}
	end
    if #self.chipsPool[betIndex] <= 0 then
        local chip = self:createChip(betIndex)
        table.insert(self.usingChips,chip)
        self:setChipRotation(chip)
        chip:setLocalZOrder(#self.usingChips)
        return chip
    end

	local count = #self.chipsPool[betIndex]
	for _index = count , 1, -1 do
		local v = self.chipsPool[betIndex][_index]
		self:setChipRotation(v)
		v:setLocalZOrder(#self.usingChips)
		v:setVisible(true)
		table.remove(self.chipsPool[betIndex],_index)
		table.insert(self.usingChips,v)
		return v
	end

    printError("<===============什么情况？出错了？=================>")

    return nil
end

--回收筹码到对象池
function C:cleanChips()
	self.flyChips = {}
	local count = #self.usingChips
	for _index = count , 1, -1 do
		local v = self.usingChips[_index]
		local index = v:getTag()
		v:setVisible(false)
		table.insert(self.chipsPool[index],v)
		table.remove(self.usingChips,_index)
	end

    self.isSetLuckyStar = {}
    if self.luckyStar then
        for k,v in pairs(self.luckyStar) do
            if v then
                v:setVisible(false)
            end
        end
    end
    self.curChipAnimNum = 0

    for k , tagIndex in ipairs(CHIPS_BACK_SOUND_TAGS) do
        local node = self.node:getChildByTag(tagIndex)
        if node then
            node:stopAllActions()
            node:removeFromParent(true)
        end
    end
end

function C:cleanAll()
	self.flyChips = {}
    for k,v in pairs(self.chipsPool) do 
        for k2,v2 in pairs(v) do
            v2:release()
            v2:removeFromParent(true)
        end
    end
    self.chipsPool = {}
    for k,v in pairs(self.usingChips) do 
        v:release()
        v:removeFromParent(true)
    end
    self.usingChips = {}
    if self.luckyStar then
        for k,v in pairs(self.luckyStar) do
            if v then
                v:removeFromParent(true)
            end
        end
    end
    self.luckyStar = {}
end

--筹码飞往下注区
function C:chipGo(seatIndex,betIndex, pos,isAnim,isDesk,playSound,callback)
    local chip = self:getFreeChip(betIndex,isAnim,isDesk)
    if chip == nil then
        print("************************************超过最大限制**************************************")
        return
    end

    if not isAnim then
    	chip:setScale(1)
    	chip:setVisible(true)
        chip:setPosition(pos)
        return
    end
    if playSound then
		PLAY_SOUND(CHIP_SOUND)
	end
	self.flyChipsCallback = callback
    if seatIndex == 8 then
	    chip:setVisible(false)
	    chip.fromPos = PLAYERS_POS[seatIndex]
	    chip.toPos = pos
	    self:insertFlyChips(chip)
    else
    	self:chipAction(chip,PLAYERS_POS[seatIndex],pos)
    end
end

function C:chipAction( chipNode,fromPos,toPos )
	chipNode:setPosition(fromPos)
	chipNode:setVisible(true)
	chipNode:setScale(0.8)
	local distance = cc.pGetLength(cc.pSub(fromPos,toPos)) --cc.pGetDistance(fromPos, toPos)
	local speed = 2000
	local time = distance / speed
	local time2 =  math.min(0.10,time)
	local seq = cc.ScaleTo:create(time2,1.2)
	local move = cc.MoveTo:create(time,toPos)
	local scale = cc.ScaleTo:create(0.05, 1)
	local seq2 = transition.sequence({move,scale})
	local spawn = transition.spawn({seq,seq2})
	transition.execute(chipNode, spawn, 
    {
    	onComplete = function()
    		self.curChipAnimNum = self.curChipAnimNum - 1
    	end
	})
	if self.flyChipsCallback then
		self.flyChipsCallback()
	end
end

--设置随机角度
function C:setChipRotation(chip)
	local rotation = math.random(-70, 70)
	chip:setRotation(rotation)
end

--获取下注区域的一个随机位置
function C:getChipFinalPos(area)
    local rect = self.betAreas[area]
	local startPosX = rect.x
	local startPosY = rect.y

	local width = rect.width
	local height = rect.height

	local basePosX = startPosX + width / 2
	local basePosY = startPosY + height / 2

	local chipWidth = CHIP_SIZE.width / 2
	local chipHeight = CHIP_SIZE.height / 2

	local finalPosX = 0
	local finalPosY = 0

	-- if area == HhdzDefine.betType.Lucky then
	-- 	local a = width / 3
	-- 	local b = height / 2

	-- 	finalPosX =  basePosX + math.random(-a, a)
	-- 	local gapY = math.sqrt((1 - math.pow(finalPosX - basePosX, 2) / math.pow(a, 2)) * math.pow(b, 2))
	-- 	finalPosY = basePosY + math.random(-gapY, gapY)
	-- else
	-- 	local r = height / 1.2
	-- 	local distance = math.random(0, r)

	-- 	finalPosX = basePosX + math.random(-distance, distance)
	-- 	local gapY = math.sqrt(math.pow(distance, 2) - math.pow(basePosX - finalPosX,2))
	-- 	finalPosY = math.random(0, 1) == 0 and (basePosY - gapY) or (basePosY + gapY)
	-- end

	-- -- 校准
	-- finalPosX = math.min(finalPosX,basePosX + width / 2 - chipWidth * 0.9)
	-- finalPosX = math.max(finalPosX,basePosX - width / 2 + chipWidth * 0.9)

	-- finalPosY = math.min(finalPosY,basePosY + height / 2 - chipHeight * 0.9 ) - 5
	-- finalPosY = math.max(finalPosY,basePosY - height / 2 + chipHeight * 0.9 ) - 5

	finalPosX=math.random(startPosX+chipWidth,startPosX+width-chipWidth)
	finalPosY=math.random(startPosY+chipHeight,startPosY+height-chipHeight)

	return cc.p(finalPosX, finalPosY)
end

--筹码飞回到玩家位置
function C:chipsBack(posArray, callBack)

	if #self.usingChips < 1 then
		if callBack then
	 		callBack()
	 	end
		return
	end

    for k , tagIndex in ipairs(CHIPS_BACK_SOUND_TAGS) do
        local node = self.node:getChildByTag(tagIndex)
        if node then
            node:stopAllActions()
            node:removeFromParent(true)
        end
    end

	-- sound
	local node1 = display.newNode()
    node1:setTag(CHIPS_BACK_SOUND_TAGS[1])
	node1:addTo(self.node)

	local callfunNode1 = CCCallFunc:create(function (  )
		PLAY_SOUND(CHIP_WIN_SOUND)
	end)
	local delayNode1 = CCDelayTime:create(0.25)

	local seqNode1 = transition.sequence({callfunNode1,delayNode1})
	local repNode1 = CCRepeatForever:create(seqNode1)

	node1:runAction(repNode1)

	local node2 = display.newNode()
    node2:setTag(CHIPS_BACK_SOUND_TAGS[2])
	node2:addTo(self.node)

	local callfunNode2 = CCCallFunc:create(function (  )
		PLAY_SOUND(CHIP_WIN_SOUND)
	end)
	local delayNode2 = CCDelayTime:create(0.4)

	local seqNode2 = transition.sequence({callfunNode2,delayNode2})
	local repNode2 = CCRepeatForever:create(seqNode2)

	node2:runAction(repNode2)

	-- chips
	local chips = self.usingChips
	
	local gapNum = math.floor(#chips / #posArray)
	local speed = 1000
	local delayGap = 0.015

	-- if #chips > 150 then
	-- 	speed = 1400
	-- 	delayGap = 0.007
	-- elseif #chips > 50 then
	-- 	speed = 1300
	-- 	delayGap = 0.01
	-- end

	delayGap=0.58/#chips
	speed=1300+ #chips*2.05
	speed=math.min(1500,speed)

	local curIndex = #chips
	local nextIndex = curIndex - gapNum + 1 > 1 and curIndex - gapNum + 1 or 1

	local curNum = #chips

    local testCount = 0
	local isInForeach = false
	for i = 1, #posArray do
		for m = curIndex, nextIndex, -1 do
			isInForeach = true

			local chip = chips[m]
			local chipX = chip:getPositionX()
			local chipY = chip:getPositionY()

			local endPos = PLAYERS_POS[posArray[i]]
			local time = cc.pGetDistance(cc.p(chipX, chipY), endPos) / speed

			local movePart1 = CCEaseIn:create(CCMoveBy:create(0.2, cc.p((chipX - endPos.x) / 15, (chipY - endPos.y) / 10)), 0.4)
			local movePart2 = CCEaseOut:create(CCMoveTo:create(time, cc.p(endPos.x, endPos.y)), 0.8)
			local delay = CCDelayTime:create(delayGap * (curIndex - m))
			local callFun = CCCallFunc:create(function ()
				chip:setVisible(false)
	 			curNum = curNum - 1
	 			if curNum == 0 then
	 				node1:removeFromParent(true)
	 				node2:removeFromParent(true)
                    self:cleanChips()
	 				if callBack then
	 					callBack()
	 				end
	 			end
			end)
			local seq = transition.sequence({delay,movePart1,movePart2,callFun})
			chip:runAction(seq)
		end

		curIndex = nextIndex - 1 > 1 and nextIndex - 1 or 1
		nextIndex = curIndex - gapNum + 1 > 1 and curIndex - gapNum + 1 or 1

		if i == #posArray - 1 then
			nextIndex = 1
		end
	end

	if not isInForeach then
		self:cleanChips()
	end
end

function C:flyLuckyStar(area,isAnim)

	if area > 0 and area <= 3 then

		if not self.isSetLuckyStar[area] then
			self.isSetLuckyStar[area] = true

			local endPos = cc.p(STAR_POS[area].x,STAR_POS[area].y)
            if not self.luckyStar then
                self.luckyStar = {}
            end
            if not self.luckyStar[area] then
			    self.luckyStar[area] = display.newSprite(LUCKY_STAR)
			    self.luckyStar[area]:addTo(self.luckyStarNode)
            end
            self.luckyStar[area]:setPosition(PLAYERS_POS[6])
			self.luckyStar[area]:setOpacity(0)
            self.luckyStar[area]:setVisible(true)

			if isAnim then
				local startPos = cc.p(PLAYERS_POS[6].x,PLAYERS_POS[6].y)
				local speed = 700
    			local time = cc.pGetDistance(startPos, endPos) / speed

    			local p1 = cc.p(startPos.x,startPos.y)
    			local p2 = cc.p(startPos.x + (endPos.x - startPos.x) * 0.5,startPos.y + (endPos.y - startPos.y) * 0.6 + 100)

		    	local bezierConfig = {p1,p2,endPos}

    			local easeOut = CCEaseOut:create(CCBezierTo:create(time,bezierConfig),0.8)

    			self.luckyStar[area]:setOpacity(255)
    			self.luckyStar[area]:runAction(easeOut)
    		
    			-- par
    			local par = CCParticleSystemQuad:create(LUCKY_STAR_PARTICLE)
    			par:setPosition(cc.p(startPos.x,startPos.y))
    			par:addTo(self.luckyStarNode,5)

    			local parEaseOut = CCEaseOut:create(CCBezierTo:create(time,bezierConfig),0.8)
    			local parCallFun = CCCallFunc:create(function()
    				par:removeFromParent(true)
    			end)

    			par:runAction(transition.sequence({parEaseOut,parCallFun}))
			else
				self.luckyStar[area]:setPosition(cc.p(endPos.x,endPos.y))
    			self.luckyStar[area]:setOpacity(255)
			end
		end
	end
end

return C