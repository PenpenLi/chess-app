local PokerClass = import(".BrnnPokerClass")
local C = class("BrnnBankerClass",ViewBaseClass)

C.BINDING = {
	systemHead = {path="system_head"},
	playerHead = {path="player_head"},
	playerHeadImg = {path="player_head.head_img"},
	playerFrameImg = {path="player_head.frame_img"},
	moneyLabel = {path="money_img.label"},
	nameLabel = {path="name_img.label"},
	pokerPanel = {path="poker_panel"},
	pokerType = {path="poker_panel.poker_type"},
	beiLabel = {path="poker_panel.bei_label"},
	pokerTypeArmature = {path="poker_panel.poker_type.armature_node"},
}

C.pokerClassArr = nil
C.pokerPosArr = nil
C.pokerDataArr = nil
C.typeName = ""
C.typeBei = 0

function C:destroy()
	self.pokerClassArr = nil
	self.pokerPosArr = nil
	self.pokerDataArr = nil
end

function C:ctor( node )
	for i=1,5 do
		local key = string.format("poker%d",i)
		local path = string.format("poker_panel.poker_%d",i)
		self.BINDING[key] = {path=path}
	end
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
		poker:setVisible(false)
	end
	self:setBankerSystem()
end

function C:updateBlance( money )
	local str = utils:moneyString(money)
	self.moneyLabel:setString(str)
end

function C:setBankerSystem()
	self.systemHead:setVisible(true)
	self.moneyLabel:setString("1000000")
	self.nameLabel:setString("系统庄")
	self.playerHead:setVisible(false)
end

function C:setBankerPlayer( info )
	self.playerHead:setVisible(true)
	local headRes = GET_HEADID_RES(info["headid"])
	self.playerHeadImg:loadTexture(headRes)
	local money = utils:moneyString(info["money"])
	self.moneyLabel:setString(money)
	local name = "ID:"..tostring(info["playerid"])
	self.nameLabel:setString(name)
	self.systemHead:setVisible(false)
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
		if i== 5 then
			array[#array+1] = cc.CallFunc:create(function()
				pokerClass:setVisible(true)
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
	self:openPoker(1)
	self:openPoker(2)
end

function C:openThreePokers()
	for i=3,5 do
		self:openPoker(i)
	end
	self:showPokerType()
end

function C:openAllPokers()
	for i=1,5 do
		self:openPoker(i)
	end
	self:showPokerType()
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