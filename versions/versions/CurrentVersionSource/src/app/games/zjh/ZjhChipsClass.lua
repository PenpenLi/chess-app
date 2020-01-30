local C = class("ZjhChipsClass",ViewBaseClass)

C.BINDING = {
	templateChip1 = {path="chip_1"},
	templateChip2 = {path="chip_2"},
	chipsPool = {path="chips_pool"},
	leftHand = {path="left_hand"},
	rightHand = {path="right_hand"},
}
C.MAX_CHIPS_NUM = 200
C.allChipArr = nil
C.baseMoney = 100
C.mutilConfigs = {1,2,5,10}
C.playerPosArr = {cc.p(391,147),cc.p(986,285),cc.p(986,470),cc.p(150,470),cc.p(150,285)}
C.isChipsAnimation = false
C.curAnimChipIndex = 0

function C:onCreate()
	C.super.onCreate(self)
	self.templateChip1:setVisible(false)
	self.templateChip2:setVisible(false)
	self.leftHand:setVisible(false)
	self.rightHand:setVisible(false)
	self.allChipArr = {}
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
end

--设置底注
function C:setBaseMoney( money )
	self.baseMoney = money
end

function C:startChipsAnimation()
	self:stopChipsAnimation()
	self.isChipsAnimation = true
	utils:createTimer("zjh.chips_ani",0.85,function()
		self:playChipsAnimation()
	end)
	utils:createTimer("zjh.chips_ani2",0.2,function()
		self:playChipsParticle()
	end)
end

function C:stopChipsAnimation()
	self.isChipsAnimation = false
	utils:removeTimer("zjh.chips_ani")
	utils:removeTimer("zjh.chips_ani2")
end

function C:clean()
	self:stopChipsAnimation()
	self.chipsPool:stopAllActions()
	self.chipsPool:removeAllChildren(true)
    self.allChipArr = {}
	self.leftHand:setVisible(false)
	self.rightHand:setVisible(false)
end

--创建新的筹码level:1/2/3/4
function C:createChip( level )
	local chip = nil
	local maxWidth = 0
	local money = 0
	if level == 4 then
		--10=1x10
		chip = self.templateChip2:clone()
		maxWidth = 70
		money = self.baseMoney * self.mutilConfigs[4]
	elseif level == 3 then
		--5=1x5
		chip = self.templateChip1:clone()
		maxWidth = 35
		money = self.baseMoney * self.mutilConfigs[3]
	elseif level == 2 then
		--2=1x2
		chip = self.templateChip1:clone()
		maxWidth = 35
		money = self.baseMoney * self.mutilConfigs[2]
	else
		--1=1x1
		chip = self.templateChip1:clone()
		maxWidth = 35
		money = self.baseMoney * self.mutilConfigs[1]
	end
	local text = utils:moneyString(money)
	local label = chip:getChildByName("label")
	label:setString(text)
	local size = label:getContentSize()
	local scale = maxWidth/size.width
	if scale > 0.7 then
		scale = 0.7
	end
	label:setScale( scale )
	label:setVisible(true)
	chip:setVisible(true)
	chip.level = level
	self.chipsPool:addChild(chip)
	return chip
end

--获取筹码随机位置
function C:getRandomPos()
	local x = math.random( 568 - 140, 568 + 140 )
	local y = math.random( 320 - 25, 320 + 115 )
	return cc.p( x, y ) 
end

function C:getRandomPosNearby( pos )
	local x = 0
	local y = 0
	if math.random(1,100) > 50 then
		x = math.random( -60, -30 ) + pos.x
	else
		x = math.random( 30, 60 ) + pos.x
	end
	if math.random(1,100) > 50 then
		y = math.random( -60, -30 ) + pos.y
	else
		y = math.random( 30, 60 ) + pos.y
	end

	if x < 568-140 then
		x = 568-140
	elseif x > 568+140 then
		x = 568+140
	end
	if y < 320-25 then
		y = 320-25
	elseif y > 320+115 then
		y = 320+115
	end
	return cc.p( x, y )
end

function C:chipAction( chip, to, animation )
	local degree = math.random(-90,90)
	chip:setRotation(degree)
	if animation == false then
		chip:setPosition(to)
		-- table.insert(self.allChipArr,chip)
		-- self:cleanChips()
	else
		local from = cc.p(chip:getPosition())
		local speed = 1400
		local time = cc.pGetDistance(from,to)/speed
		transition.moveTo(chip,{time=time,x=to.x,y=to.y,easing = "IN",onComplete=function()
			-- table.insert(self.allChipArr,chip)
			-- self:cleanChips()
		end})
	end

	table.insert(self.allChipArr,chip)
	self:cleanChips()

	if self.isChipsAnimation == false then
		self:startChipsAnimation()
	end
end

function C:cleanChips()
	if #self.allChipArr > self.MAX_CHIPS_NUM then
		local first = self.allChipArr[1]
		first:removeFromParent(true)
		table.remove(self.allChipArr, 1)
	end
end

function C:getLevelByMoney( money )
	local mutil = math.floor(money/self.baseMoney)
	local level = 1
	for i=1,#self.mutilConfigs do
		if mutil == self.mutilConfigs[i] then
			level = i
			break
		end
	end
	return level
end

--下注筹码 seatId:玩家本地座位号 level:1/2/3/4/5
function C:throwChips( seatId, currentMoney, totalMoney, bettype )
	local level = self:getLevelByMoney(currentMoney)
	local num = math.floor(totalMoney/currentMoney)
	-- if level == 2 then
	-- 	num = num*2
	-- end
	local array = {}
	local interval = 0.4/num
	if interval > 0.1 then
		interval = 0.1
	end
	local tempPos = self:getRandomPos()
	local toPos = tempPos
	for i=1,num do
		array[#array+1] = cc.DelayTime:create((i-1)*interval)
		array[#array+1] = cc.CallFunc:create(function()
			local chip = self:createChip(level)
			chip:setPosition(self.playerPosArr[seatId])
			self:chipAction(chip,toPos)
			toPos = self:getRandomPosNearby(tempPos)
		end)
	end
	--下底注只播放自己的音效
	if (bettype == 0 and seatId == 1) or bettype ~= 0 then
		if level == 4 then
			PLAY_SOUND(GAME_ZJH_SOUND_RES.."chipgold.mp3")
		else
			PLAY_SOUND(GAME_ZJH_SOUND_RES.."fly_gold.mp3")
		end
	end
	self.chipsPool:runAction(cc.Sequence:create(array))
	--bettype=0下底注
	if bettype ~= 0 then
		local isJiazhu = bettype == 3
		self:flyMoney(seatId,totalMoney,isJiazhu)
	end
end

function C:flyMoney(seatId,totalMoney,isJiazhu )
	local label = ccui.TextBMFont:create()
	label:setFntFile(GAME_ZJH_FONT_RES.."jia.fnt")
	if isJiazhu then
		label:setString("加+"..utils:moneyString(totalMoney))
	else
		label:setString("跟+"..utils:moneyString(totalMoney))
	end
	label:setAnchorPoint(cc.p(0.5,0))
	local beginPos = cc.p(self.playerPosArr[seatId].x,self.playerPosArr[seatId].y)
	beginPos.y = beginPos.y+10
	local endPos = cc.p(self.playerPosArr[seatId].x,self.playerPosArr[seatId].y)
	endPos.y = endPos.y+75

	label:setPosition(beginPos)
	self.node:addChild(label)
    local array = {}
    array[#array+1] = cc.MoveTo:create(0.35,endPos)
    array[#array+1] = cc.DelayTime:create(0.5)
    array[#array+1] = cc.FadeOut:create(0.5)
    array[#array+1] = cc.CallFunc:create(function()
        label:removeFromParent(true)
    end)
    label:runAction(cc.Sequence:create(array))
end

--桌面筹码
function C:throwDesktopChips( currentMoney, totalMoney )
	local level = self:getLevelByMoney(currentMoney)
	local chip1Num = 0 --1
	local chip2Num = 0 --2
	local chip3Num = 0 --5
	local chip4Num = 0 --10
	if level <= 1 then
		--x1
		chip1Num = math.floor(totalMoney/self.baseMoney)
	elseif level <= 2 then
		--x2
		chip2Num = math.floor(totalMoney/(self.baseMoney*self.mutilConfigs[2]))
		chip1Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[2])/self.baseMoney)
	elseif level <= 3 then
		--x5
		chip3Num = math.floor(totalMoney/(self.baseMoney*self.mutilConfigs[3]))
		chip2Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[3])/(self.baseMoney*self.mutilConfigs[2]))
		chip1Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[3])%(self.baseMoney*self.mutilConfigs[2])/self.baseMoney)
	elseif level <= 4 then
		--x10
		chip4Num = math.floor(totalMoney/(self.baseMoney*self.mutilConfigs[4]))
		chip3Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[4])/(self.baseMoney*self.mutilConfigs[3]))
		chip2Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[4])%(self.baseMoney*self.mutilConfigs[3])/(self.baseMoney*self.mutilConfigs[2]))
		chip1Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[4])%(self.baseMoney*self.mutilConfigs[3])%(self.baseMoney*self.mutilConfigs[2])/self.baseMoney)
	end
	local doAction = function( level )
		local chip = self:createChip(level)
		local pos = self:getRandomPos()
		self:chipAction(chip,pos,false)
	end
	for i=1,chip1Num do
		doAction(1)
	end
	for i=1,chip2Num do
		doAction(2)
	end
	for i=1,chip3Num do
		doAction(3)
	end
	for i=1,chip4Num do
		doAction(4)
	end
end

--全押筹码
function C:throwAllinChips( seatId, totalMoney )
	local chip4Num = math.floor(totalMoney/(self.baseMoney*self.mutilConfigs[4]))
	local chip3Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[4])/(self.baseMoney*self.mutilConfigs[3]))
	local chip2Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[4])%(self.baseMoney*self.mutilConfigs[3])/(self.baseMoney*self.mutilConfigs[2]))
	local chip1Num = math.floor(totalMoney%(self.baseMoney*self.mutilConfigs[4])%(self.baseMoney*self.mutilConfigs[3])%(self.baseMoney*self.mutilConfigs[2])/self.baseMoney)
	local doAction = function( level )
		local chip = self:createChip(level)
		chip:setPosition(self.playerPosArr[seatId])
		local pos = self:getRandomPos()
		self:chipAction(chip,pos)
	end
	PLAY_SOUND(GAME_ZJH_SOUND_RES.."fly_gold.mp3")
	for i=1,chip1Num do
		doAction(1)
	end
	for i=1,chip2Num do
		doAction(2)
	end
	for i=1,chip3Num do
		doAction(3)
	end
	for i=1,chip4Num do
		doAction(4)
	end
	if chip5Num > 20 then
		chip5Num = 20
	end
end

function C:playChipsAnimation()
	if #self.allChipArr > 0 then
		local idx = math.random(1, #self.allChipArr)
		self:chipsAnimation(self.allChipArr[idx])
	end
end

function C:chipsAnimation( chip )
	-- 金条流光
	if chip.level == 4 then
		local light = utils:createFrameAnim({
            path = GAME_ZJH_IMAGES_RES.."number_chips",
            image = "brick_light",
            endFrame = 17,
            interval = 0.04,
            once = true,
        })
        light:setScaleX(0.8)
        light:setScaleY(0.5)
        
        light:setPosition(chip:getContentSize().width / 2,chip:getContentSize().height / 2 + 2.5)
        light:addTo(chip)
	end
end

function C:playChipsParticle()
	if #self.allChipArr > 0 then
		local idx = math.random(1, #self.allChipArr)
	
		if self.curAnimChipIndex == idx then
			idx = math.random(1, #self.allChipArr)
		end

		self.curAnimChipIndex = idx
		self:chipsParticle(self.allChipArr[self.curAnimChipIndex])
	end
end

function C:chipsParticle( chip )
    if not chip then
        return
    end
	local x = 0
	local y = 0
	-- 金条
	if chip.level == 4 then
		local randX = math.random(0, 100)
		randX = randX > 50 and 0.88 or 0.12

		local randY = math.random(0, 100)
		randY = randY > 50 and 0.88 or 0.22

		x = randX * chip:getContentSize().width
		y = randY * chip:getContentSize().height
	else
		local centerX = chip:getContentSize().width / 2
		local centerY = chip:getContentSize().height / 2
		local distance = chip:getContentSize().width / 2

		x = math.random(-distance, distance) + centerX
		local gapY = math.sqrt(math.pow(distance, 2) - math.pow(centerX - x,2))
		y = math.random(0, 1) == 0 and (centerY - gapY) or (centerY + gapY)

		x = math.max(0.12 * chip:getContentSize().width,x)
		x = math.min(x, 0.89 * chip:getContentSize().width)

		y = math.max(0.16 * chip:getContentSize().height,y)
		y = math.min(y, 0.93 * chip:getContentSize().height)
	end
	local pos = self.chipsPool:convertToNodeSpace(chip:convertToWorldSpace(cc.p(x, y)))

	local particle = CCParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/star02.plist")
    particle:setAutoRemoveOnFinish(true)
    particle:setPosition(pos)
    particle:setScale(0.35)
    particle:addTo(self.chipsPool)
end

--收筹码 seatIds:赢玩家本地座位号
function C:flyChips( seatIds, callback )
	self:stopChipsAnimation()
	if #self.allChipArr < 1 then
		return
	end
	--不再特殊表现自己赢
	-- if #seatIds == 1 and seatIds[1] == 1 then
	-- 	self:flyChipsOnlyMe(callback)
	-- 	return
	-- end
	local posArray = {}
	for i=1,#seatIds do
		local pos = self.playerPosArr[seatIds[i]]
		table.insert(posArray,pos)
	end
	-- sound
	-- local node1 = display.newNode()
	-- node1:addTo(self.chipsPool)

	-- local callfunNode1 = CCCallFunc:create(function (  )
	-- 	PLAY_SOUND(GAME_ZJH_SOUND_RES.."fly_gold.mp3")
	-- end)
	-- local delayNode1 = CCDelayTime:create(0.15)

	-- local seqNode1 = transition.sequence({callfunNode1,delayNode1})
	-- local repNode1 = CCRepeatForever:create(seqNode1)

	-- node1:runAction(repNode1)

	-- local node2 = display.newNode()
	-- node2:addTo(self.chipsPool)

	-- local callfunNode2 = CCCallFunc:create(function (  )
	-- 	PLAY_SOUND(GAME_ZJH_SOUND_RES.."fly_gold.mp3")
	-- end)
	-- local delayNode2 = CCDelayTime:create(0.24)

	-- local seqNode2 = transition.sequence({callfunNode2,delayNode2})
	-- local repNode2 = CCRepeatForever:create(seqNode2)

	-- node2:runAction(repNode2)

	PLAY_SOUND(GAME_ZJH_SOUND_RES.."shou_chouma.mp3")

	local chips = clone(self.allChipArr)
	self.allChipArr = {}

	local gapNum = math.floor(#chips / #posArray)
	local speed = 1600
	local delayGap = 0.016

	if #chips > 150 then
		speed = 3400
		delayGap = 0.003
	elseif #chips > 50 then
		speed = 2200
		delayGap = 0.005
	end

	local curIndex = #chips
	local nextIndex = curIndex - gapNum + 1 > 1 and curIndex - gapNum + 1 or 1

	local curNum = #chips

	for i = 1, #posArray do
		for m = curIndex, nextIndex, -1 do
			local chip = chips[m]
			local layerPos = posArray[i]
			local time = cc.pGetDistance(cc.p(chip:getPosition()), layerPos) / speed

			local delay = CCDelayTime:create(delayGap * (curIndex - m))
			local easeOut = CCEaseOut:create(CCMoveTo:create(time,cc.p(layerPos.x, layerPos.y)),0.8)
			local callfun = CCCallFunc:create(function (  )
				chip:removeFromParent(true)
	 			chip = nil

	 			curNum = curNum - 1

	 			if curNum == 0 then
	 				-- node1:removeFromParent(true)
	 				-- node2:removeFromParent(true)
	 			elseif curNum == #chips - 1 then
	 				if callback then
	 					callback(seatIds)
	 				end
	 			end
			end)
			local seq = transition.sequence({delay,easeOut,callfun})
			chip:stopAllActions()
			chip:runAction(seq)
		end

		curIndex = nextIndex - 1 > 1 and nextIndex - 1 or 1
		nextIndex = curIndex - gapNum + 1 > 1 and curIndex - gapNum + 1 or 1

		if i == #posArray - 1 then
			nextIndex = 1
		end
	end
end

function C:flyChipsOnlyMe( callback )
	if callback then
		callback({1})
	end
	local chips = clone(self.allChipArr)
	self.allChipArr = {}

	local hightPosY = 460

	self.leftHand:setPosition(30,-self.leftHand:getContentSize().height / 2 - 15)
	self.rightHand:setPosition(display.width - 30,-self.rightHand:getContentSize().height / 2 - 60)
	self.leftHand:setVisible(true)
	self.rightHand:setVisible(true)

	-- enter
	local moveEnterL = CCMoveTo:create(0.6,cc.p(568 - 190,hightPosY - self.leftHand:getContentSize().height / 2 + 15))
	local moveEnterR = CCMoveTo:create(0.6,cc.p(568 + 140,hightPosY - self.rightHand:getContentSize().height / 2 + 60))

	-- left
	local moveLeftL = CCMoveTo:create(0.7,cc.p(568 - 190,-self.leftHand:getContentSize().height / 2 - 15))
	local moevLeftR = CCMoveTo:create(0.7,cc.p(568 + 140,-self.rightHand:getContentSize().height / 2 - 60))

	local callfunL = CCCallFunc:create(function()
		self.leftHand:setVisible(false)
	end)

	local callfunR = CCCallFunc:create(function()
		self.rightHand:setVisible(false)
	end)

	-- chips
	local callfunChips = CCCallFunc:create(function()
		for i = #chips, 1, -1 do
			local chip = chips[i]
			local x = 568 - 25
			local y = -40
			local pos = cc.p(x,y)

			local speed = 1800
			local time = cc.pGetDistance(cc.p(chip:getPosition()), pos) / speed
			transition.execute(chip, CCMoveTo:create(time,pos), {
				onComplete = function()
					chip:removeFromParent(true)
					chip = nil
				end,
			})
		end
	end)

	local spawnL = transition.spawn({moveLeftL,callfunChips})

	self.leftHand:runAction(transition.sequence({moveEnterL,spawnL,callfunL}))
	self.rightHand:runAction(transition.sequence({moveEnterR,moevLeftR,callfunR}))

	PLAY_SOUND(GAME_ZJH_SOUND_RES.."shou_chouma.mp3")

	-- sound

	-- local node1 = display.newNode()
	-- node1:addTo(self.chipsPool)

	-- local delayNode11 = CCDelayTime:create(0.7)
	-- local callfunNode1 = CCCallFunc:create(function (  )
	-- 	PLAY_SOUND(GAME_ZJH_SOUND_RES.."fly_gold.mp3")
	-- end)
	-- local delayNode12 = CCDelayTime:create(0.2)

	-- local seqNode1 = transition.sequence({callfunNode1,delayNode12})
	-- local repNode1 = CCRepeat:create(seqNode1,5)

	-- node1:runAction(transition.sequence({delayNode11,repNode1}))

	-- local node2 = display.newNode()
	-- node2:addTo(self.chipsPool)

	-- local delayNode21 = CCDelayTime:create(0.7)
	-- local callfunNode2 = CCCallFunc:create(function (  )
	-- 	PLAY_SOUND(GAME_ZJH_SOUND_RES.."fly_gold.mp3")
	-- end)
	-- local delayNode22 = CCDelayTime:create(0.35)

	-- local seqNode2 = transition.sequence({callfunNode2,delayNode22})
	-- local repNode2 = CCRepeat:create(seqNode2,3)

	-- node2:runAction(transition.sequence({delayNode21,repNode2}))
end

return C