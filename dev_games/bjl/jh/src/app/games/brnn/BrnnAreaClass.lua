local PokerClass = import(".BrnnPokerClass")
local C = class("BrnnAreaClass",ViewBaseClass)

C.BINDING = {
	totalChipsLabel = {path="total_chips_label"},
	myChipsLabel = {path="my_chips_label"},
	pokerPanel = {path="poker_panel"},
	pokerType = {path="poker_panel.poker_type"},
	beiLabel = {path="poker_panel.bei_label"},
	firePanel = {path="fire_panel"},
	dotListview = {path="dot_listview"},
}

C.pokerClassArr = nil
C.pokerPosArr = nil
C.pokerDataArr = nil
C.typeName = ""
C.typeBei = 0
C.winDot = nil
C.loseDot = nil
C.area = 0

function C:destroy()
	self.pokerClassArr = nil
	self.pokerPosArr = nil
	self.pokerDataArr = nil
	self.winDot = nil
	self.loseDot = nil
end

function C:ctor( node, area, winDot, loseDot )
	for i=1,5 do
		local key = string.format("poker%d",i)
		local path = string.format("poker_panel.poker_%d",i)
		self.BINDING[key] = {path=path}
	end
	self.area = area
	self.winDot = winDot
	self.loseDot = loseDot
	C.super.ctor(self,node)
end

function C:onCreate()
	C.super.onCreate(self)
	self.pokerClassArr = {}
	self.pokerPosArr = {}
	for i=1,5 do
		local key = string.format("poker%d",i)
		local poker = self[key]
		self.pokerClassArr[i] = PokerClass.new(poker)
		self.pokerPosArr[i] = cc.p(poker:getPosition())
	end
	self.dotListview:setScrollBarEnabled(false)
	self.dotListview:removeAllItems()
	self:clean()
end

function C:refreshHistory( historyDataArr )
	self.dotListview:removeAllItems()
	local dataArr = self:getRecentHistory(historyDataArr,10)
	for i,v in ipairs(dataArr) do
		local item = nil
		if v[self.area] == 0 then
			item = self.winDot:clone()
		else
			item = self.loseDot:clone()
		end
		item:setVisible(true)
		self.dotListview:pushBackCustomItem(item)
	end
end

function C:getRecentHistory( historyDataArr, count )
	local dataArr = {}
	if #historyDataArr <= count then
		dataArr = historyDataArr
	else
		local index = #historyDataArr-count+1
		for i=index,#historyDataArr do
			table.insert(dataArr,historyDataArr[i])
		end
	end
	return dataArr
end

function C:addHistory( data )
	--超过10，移除前面的数据
	local popDot = function( listview )
		local count = #listview:getItems()
		if count >= 10 then
			local num = count-9
			for i=1,num do
				listview:removeItem(0)
			end
		end
	end
	popDot(self.dotListview)
	--插入最新一局数据
	local pushDot = function( listview, result )
		local item = nil
		if result == 0 then
			item = self.winDot:clone()
		else
			item = self.loseDot:clone()
		end
		item:setVisible(true)
		listview:pushBackCustomItem(item)
		self:playBlinkAni(item)
	end
	pushDot(self.dotListview,data[self.area])
end

function C:playBlinkAni( dot )
	local array = {}
	array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeOut:create(0.2)
    array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeIn:create(0.2)
    dot:runAction(cc.Repeat:create(cc.Sequence:create(array),3))
end

function C:clean()
	self:setTotalChips(0)
	self:setMyChips(0)
	self:hidePoker()
end

function C:setTotalChips( chips )
	if chips == 0 then
		self.totalChipsLabel:setString("")
	else
		local str = utils:moneyString(chips)
		self.totalChipsLabel:setString(str)
	end
end

function C:setMyChips( chips,change )
	if chips == 0 then
		self.myChipsLabel:setString("")
	else
		local str = utils:moneyString(chips,0)
		self.myChipsLabel:setString(str)
	end
end

function C:setResultChips( chips )
	if chips == nil then
		return
	end
	local str2 = ""
	if chips > 0 then
		str2 = "+"..utils:moneyString(chips,3)
	else
		str2 = utils:moneyString(chips,3)
	end
	str2 = tostring(self.myChipsLabel:getString()).."a"..str2
	self.myChipsLabel:setString(str2)
end

function C:showFireAni()
	self:hideFireAni()
	self.firePanel:setVisible(true)
	local strAnimName = GAME_BRNN_ANIMATION_RES.."skeleton/fire/skeleton"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setPosition(cc.p(193,124))
    skeletonNode:setScaleX(0.88)
    skeletonNode:setAnimation(0,"animation",true)
    self.firePanel:addChild( skeletonNode )
end

function C:hideFireAni()
	self.firePanel:removeAllChildren(true)
	self.firePanel:setVisible(false)
end

function C:sendPokerAni()
	--播放发牌音效
    PLAY_SOUND(GAME_BRNN_SOUND_RES.."public_fapai.mp3")
	local fromPos = self.pokerPanel:convertToNodeSpace(cc.p(display.cx,display.cy+20))
	local array = {}
	for i=1,5 do
		local toPos = self.pokerPosArr[i]
		local time = 0.25
		local pokerClass = self.pokerClassArr[i]
		pokerClass.node:setPosition(fromPos)
		array[#array+1] = cc.DelayTime:create((i-1)*0.02)
		if i==5 then
			array[#array+1] = cc.CallFunc:create(function()
				pokerClass:setVisible(true)
				--easing = "OUT",
				transition.moveTo(pokerClass.node,{time=time,x=toPos.x,y=toPos.y,onComplete=function()
					self:openTwoPokers()
				end})
			end)
		else
			array[#array+1] = cc.CallFunc:create(function()
				pokerClass:setVisible(true)
				transition.moveTo(pokerClass.node,{time=time,x=toPos.x,y=toPos.y})
			end)
		end
		
	end
	self.pokerPanel:runAction(cc.Sequence:create(array))
end

function C:sendPokerImm()
	for i=1,5 do
		self.pokerClassArr[i].node:setPosition(self.pokerPosArr[i])
		self.pokerClassArr[i]:setVisible(true)
	end
	if #self.pokerDataArr >= 2 then
		self:openTwoPokers()
	end
end

function C:setPokerData( dataArr, typeName, typeBei )
	if dataArr == nil then
		return
	end
	if self.pokerDataArr and #self.pokerDataArr == 2 then
		local data1 = self.pokerDataArr[1]
		local data2 = self.pokerDataArr[2]
		local tempDataArr = {}
		table.insert(tempDataArr,data1)
		table.insert(tempDataArr,data2)
		for i,v in ipairs(dataArr) do
			local isData1 = v.color == data1.color and v.number == data1.number
			local isData2 = v.color == data2.color and v.number == data2.number
			if isData1 == false and isData2 == false then
			   table.insert(tempDataArr,v)
			end
		end
		self.pokerDataArr = tempDataArr
	else
		self.pokerDataArr = utils:copyTable(dataArr)
	end
	self.typeName = typeName or ""
	self.typeBei = typeBei or 0
	for i,v in ipairs(self.pokerDataArr) do
		self.pokerClassArr[i]:setPokerData(v.color,v.number)
	end
end

function C:openTwoPokers()
	if self.pokerDataArr == nil or #self.pokerDataArr < 2 then
		return
	end
	self:openPoker(1)
	self:openPoker(2)
	local p1 = self.pokerDataArr[1].number
	local p2 = self.pokerDataArr[2].number
	if p1 > 10 then
		p1 = 10
	end
	if p2 > 10 then
		p2 = 10
	end
	if (p1+p2)%10 == 0 then
		self:showFireAni()
	else
		self:hideFireAni()
	end
end

function C:openThreePokers()
	for i=3,5 do
		self:openPoker(i)
	end
	self:showPokerType()
	self:hideFireAni()
end

function C:openAllPokers()
	for i=1,5 do
		self:openPoker(i)
	end
	self:showPokerType()
	self:hideFireAni()
end

function C:openPoker(index)
	self.pokerClassArr[index].node:setPosition(self.pokerPosArr[index])
	self.pokerClassArr[index]:setVisible(true)
	self.pokerClassArr[index]:frontgroundPoker(false)
end

function C:hidePoker()
	for i=1,5 do
		local pokerClass = self.pokerClassArr[i]
		pokerClass:backgroundPoker(false)
		pokerClass:setVisible(false)
	end
	self.pokerDataArr = nil
	self:hidePokerType()
end

function C:showPokerType()
	if self.typeName == "" then
		return
	end
	self.pokerType:setVisible(true)
	local armature = ccs.Armature:create(self.typeName)
	armature:setScale(0.6)
	local pos = cc.p(0,0)
	if self.typeName == "wuhuaniu" or self.typeName == "zhadanniu" or self.typeName == "tonghuashun" or self.typeName == "wuxiaoniu" then
		pos = cc.p(-15,0)
	end
	armature:setPosition(pos)
	self.pokerType:addChild(armature)
	armature:getAnimation():play("CardTypeAni")
	if self.typeBei > 0 then
		local array = {}
		array[#array+1] = cc.DelayTime:create(0.4)
		array[#array+1] = cc.CallFunc:create(function()
			self.beiLabel:setVisible(true)
			self.beiLabel:setString("X"..tostring(self.typeBei))
		end)
		self.beiLabel:runAction(cc.Sequence:create(array))
	end
end

function C:hidePokerType()
	self.pokerType:setVisible(false)
	self.pokerType:removeAllChildren(true)
	self.beiLabel:setVisible(false)
	self.beiLabel:stopAllActions()
	self.typeName = ""
	self.typeBei = 0
end

return C