local C = class("BrnnChipsClass",ViewBaseClass)

C.BINDING = {
	chip1 = {path="chip_1"},
	chip2 = {path="chip_2"},
	chip3 = {path="chip_3"},
	chip4 = {path="chip_4"},
	chip5 = {path="chip_5"},
	chipsPool = {path="chips_pool"},
}

C.CHIP_POS_MIN_X = 24
C.CHIP_POS_MAX_X = 170
C.CHIP_POS_MIN_Y = 170
C.CHIP_POS_MAX_Y = 288
C.AREA_POS = {
	[1] = cc.p(169,136),
	[2] = cc.p(370,136),
	[3] = cc.p(571,136),
	[4] = cc.p(772,136),
}
C.STAR_POS = {
	[1] = cc.p(340,464),
	[2] = cc.p(540,464),
	[3] = cc.p(740,464),
	[4] = cc.p(940,464),
}
--seatId:1~6=桌子上的玩家，7=自己，8=在线玩家，9=庄家，10=奖池
C.PLAYER_POS = {
	[1] = cc.p(1074,486),
	[2] = cc.p(62,486),
	[3] = cc.p(62,296),
	[4] = cc.p(62,176),
	[5] = cc.p(1074,296),
	[6] = cc.p(1074,176),
	[7] = cc.p(62,50),
	[8] = cc.p(1087,42),
	[9] = cc.p(338,586),
	[10] = cc.p(926,560),
}
C.CHIP_CONFIGS = {
	[1] = 100,
	[2] = 1000,
	[3] = 5000,
	[4] = 10000,
	[5] = 50000,
}

C.areaChips = nil
C.playChipSound = true
C.updateScheduler = nil
C.flyChips = nil
C.flyChipsCallback = nil

function C:destroy()
	self.BINDING = nil
	self.AREA_POS = nil
	self.STAR_POS = nil
	self.PLAYER_POS = nil
	self.CHIP_CONFIGS = nil
	self.areaChips = nil
	self.flyChipsCallback = nil
	if self.updateScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateScheduler)
		self.updateScheduler = nil
	end
end

function C:onCreate()
	C.super.onCreate(self)
	self.chip1:setVisible(false)
	self.chip2:setVisible(false)
	self.chip3:setVisible(false)
	self.chip4:setVisible(false)
	self.chip5:setVisible(false)
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
	self.areaChips = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	}
	self:updateChipsText(self.CHIP_CONFIGS)
	self.flyChips = {}
	self.updateScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateChip), 0, false)
end

function C:clean()
	self.flyChips = {}
	self.chipsPool:removeAllChildren(true)
	self.areaChips = { [1] = {}, [2] = {}, [3] = {}, [4] = {}}
end

function C:updateChipsText( configs )
	if #configs < 5 then
		return
	end
	self.CHIP_CONFIGS = configs
	for i=1,5 do
		if configs[i] then
			local key = string.format("chip%d",i)
			local label = self[key]:getChildByName("label")
			local text = utils:moneyString(configs[i])
			label:setString(text) 
		end
	end
end

function C:insertFlyChips( seatId,area,chipNode )
	if seatId == 8 then
		area = 1
	end
	local key = tostring(seatId).."_"..tostring(area)
	if self.flyChips[key] == nil then
		self.flyChips[key] = {}
	end
	if self.updateScheduler == nil then
		self.updateScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateChip), 0, false)
	end
	table.insert(self.flyChips[key],chipNode)
end

function C:updateChip()
	for seatId=1,10 do
		for area=1,4 do
			local key = tostring(seatId).."_"..tostring(area)
			if self.flyChips[key] and #self.flyChips[key] > 0 then
				local chipNode = table.remove(self.flyChips[key],1)
				self:chipAction(chipNode,chipNode.fromPos,chipNode.toPos)
			end
		end
	end
end

--断线重连回来创建筹码
function C:createAreaChips( area, chips )
	if chips == 0 then
		return
	end
	local chipsNumberArr = self:getChipsNumberArr(chips)
	for k,v in pairs(chipsNumberArr) do
		if v > 0 then
			for i=1,v do
				local chipNode = self:createChip(k)
				table.insert(self.areaChips[area],chipNode)
				local pos = self:getRandomPos(area)
				chipNode:setPosition(pos)
				chipNode:setVisible(true)
			end
		end
	end
end

--丢一颗筹码
function C:throwOneChip( seatId, area, chip, fromMany )
	if area < 1 or area > 4 then
		return
	end
	local chipNode = self:createChip(chip)
	if chipNode == nil then
		return
	end
	table.insert(self.areaChips[area],chipNode)
	local fromPos = self.PLAYER_POS[seatId]
	local toPos = self:getRandomPos(area)
	if fromMany then
		chipNode.fromPos = fromPos
		chipNode.toPos = toPos
		self:insertFlyChips(seatId,area,chipNode)
	else
		self:chipAction(chipNode,fromPos,toPos)
		if self.playChipSound then
			if seatId == 8 then
				PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_bet.mp3")
			else
				PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_on_bet.mp3")
			end
			self.playChipSound = false
			utils:delayInvoke("brnn.chipsound",0.3,function()
				self.playChipSound = true
			end)
		end
	end
end

--丢一堆筹码
function C:throwManyChips( seatId, area, chips, callback )
	if chips == 0 then
		return
	end
	self.flyChipsCallback = callback
	local chipsNumberArr = self:getChipsNumberArr(chips,seatId==8)
	for k,v in pairs(chipsNumberArr) do
		if v > 0 then
			for i=1,v do
				self:throwOneChip(seatId,area,k,true)
			end
		end
	end
	if self.playChipSound then
		if seatId == 8 then
			PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_bet.mp3")
		else
			PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_on_bet.mp3")
		end
		self.playChipSound = false
		utils:removeTimer("brnn.chipsound")
		utils:delayInvoke("brnn.chipsound",0.3,function()
			self.playChipSound = true
		end)
	end
end

--根据下注筹码获取数量{1=x,2=x,3=x,4=x,5=x}
function C:getChipsNumberArr( chips,more )
	local nums = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}
	if chips == 0 then
		return nums
	end
	for i=5,1,-1 do
		local num = math.floor(chips/self.CHIP_CONFIGS[i])
		if num > 0 then
			nums[i] = num
		end
		chips = chips%self.CHIP_CONFIGS[i]
		if chips <= 0 then
			break
		end
	end
	if more and nums[2] > 1 and nums[1]<5 then
		nums[2] = nums[2]-1
		nums[1] = nums[1]+10
	end
	if nums[5] > 5 then
		nums[5] = 5
	end
	return nums
end

function C:createChip( chipLevel )
	local chipNode = nil
	if chipLevel == 1 then
		chipNode = self.chip1:clone()
	elseif chipLevel == 2 then
		chipNode = self.chip2:clone()
	elseif chipLevel == 3 then
		chipNode = self.chip3:clone()
	elseif chipLevel == 4 then
		chipNode = self.chip4:clone()
	elseif chipLevel == 5 then
		chipNode = self.chip5:clone()
	end
	if chipNode then
		local rotation = math.random(-70, 70)
		chipNode:setRotation(rotation)
		self.chipsPool:addChild(chipNode)
	end
	return chipNode
end

function C:getRandomPos(area)
	local x = math.random( self.CHIP_POS_MIN_X, self.CHIP_POS_MAX_X ) + self.AREA_POS[area].x
	local y = math.random( self.CHIP_POS_MIN_Y, self.CHIP_POS_MAX_Y ) + self.AREA_POS[area].y
	return cc.p(x,y)
end

function C:chipAction( chipNode, fromPos, toPos )
	chipNode:setPosition(fromPos)
	chipNode:setVisible(true)
	chipNode:setScale(0.4)
	local distance = cc.pGetLength(cc.pSub(fromPos,toPos)) --cc.pGetDistance(fromPos, toPos)
	local speed = 2000
	local time = distance / speed
	local time2 =  math.min(0.10,time)
	local seq = cc.ScaleTo:create(time2,0.6)
	local move = cc.MoveTo:create(time,toPos)
	local scale = cc.ScaleTo:create(0.05, 0.5)
	local seq2 = transition.sequence({move,scale})
	local spawn = transition.spawn({seq,seq2})
	transition.execute(chipNode, spawn)
	if self.flyChipsCallback then
		self.flyChipsCallback()
	end
end

function C:recoverChips( area, seatIds, callback )
	self.flyChips = {}
	if #self.areaChips[area] == 0 or #seatIds == 0 then
		if callback then
	 		callback()
	 	end
		return
	end
	-- -- sound
	-- local node1 = display.newNode()
	-- node1:addTo(self.node)

	-- local callfunNode1 = CCCallFunc:create(function (  )
	-- 	--PLAY_SOUND(CHIP_WIN_SOUND)
	-- end)
	-- local delayNode1 = CCDelayTime:create(0.25)

	-- local seqNode1 = transition.sequence({callfunNode1,delayNode1})
	-- local repNode1 = CCRepeatForever:create(seqNode1)

	-- node1:runAction(repNode1)

	-- local node2 = display.newNode()
	-- node2:addTo(self.node)

	-- local callfunNode2 = CCCallFunc:create(function (  )
	-- 	--PLAY_SOUND(CHIP_WIN_SOUND)
	-- end)
	-- local delayNode2 = CCDelayTime:create(0.4)

	-- local seqNode2 = transition.sequence({callfunNode2,delayNode2})
	-- local repNode2 = CCRepeatForever:create(seqNode2)

	-- node2:runAction(repNode2)

	-- chips
	local chips = self.areaChips[area]
	
	local gapNum = math.floor(#chips / #seatIds)
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
	for i = 1, #seatIds do
		for m = curIndex, nextIndex, -1 do

			local chip = chips[m]
			chip:stopAllActions()
			local chipX = chip:getPositionX()
			local chipY = chip:getPositionY()

			local endPos = self.PLAYER_POS[seatIds[i]]
			local time = cc.pGetDistance(cc.p(chipX, chipY), endPos) / speed

			local movePart1 = cc.EaseIn:create(cc.MoveBy:create(0.2, cc.p((chipX - endPos.x) / 15, (chipY - endPos.y) / 10)), 0.4)
			local movePart2 = cc.EaseOut:create(cc.MoveTo:create(time, cc.p(endPos.x, endPos.y)), 0.8)
			local delay = cc.DelayTime:create(delayGap * (curIndex - m))
			local callFun = cc.CallFunc:create(function ()
				chip:setVisible(false)
				if curNum == #chips then
					if callback then
	 					callback()
	 				end
				end
	 			curNum = curNum - 1
	 			if curNum == 0 then
	 				-- node1:removeFromParent(true)
	 				-- node2:removeFromParent(true)
	 			end
			end)
			local seq = transition.sequence({delay,movePart1,movePart2,callFun})
			chip:runAction(seq)
		end

		curIndex = nextIndex - 1 > 1 and nextIndex - 1 or 1
		nextIndex = curIndex - gapNum + 1 > 1 and curIndex - gapNum + 1 or 1

		if i == #seatIds - 1 then
			nextIndex = 1
		end
	end
end

function C:flyLuckyStar(area,isAnim)
	if area < 1 or area > 4 then
		return
	end
	local startPos = self.PLAYER_POS[1]
	local endPos = self.STAR_POS[area]
	local luckyStar = display.newSprite(GAME_BRNN_ANIMATION_RES.."particle/luckyStar.png")
	luckyStar:addTo(self.chipsPool)
	luckyStar:setPosition(startPos)
    luckyStar:setVisible(true)
	if isAnim then
		local speed = 700
		local time = cc.pGetDistance(startPos, endPos) / speed

		local p1 = cc.p(startPos.x,startPos.y)
		local p2 = cc.p(startPos.x + (endPos.x - startPos.x) * 0.5,startPos.y + (endPos.y - startPos.y) * 0.6 + 100)

    	local bezierConfig = {p1,p2,endPos}

		local easeOut = cc.EaseOut:create(cc.BezierTo:create(time,bezierConfig),0.8)
		luckyStar:runAction(easeOut)
		-- par
		local par = CCParticleSystemQuad:create(GAME_BRNN_ANIMATION_RES.."particle/luckyStar.plist")
		par:setPosition(startPos)
		par:addTo(self.chipsPool,5)

		local parEaseOut = cc.EaseOut:create(cc.BezierTo:create(time,bezierConfig),0.8)
		local parCallFun = cc.CallFunc:create(function()
			par:removeFromParent(true)
		end)

		par:runAction(transition.sequence({parEaseOut,parCallFun}))
	else
		luckyStar:setPosition(endPos)
	end
end

return C