local C = class("BrnnBankerListLayer",BaseLayer)

C.RESOURCE_FILENAME = "games/brnn/BankerListLayer.csb"
C.RESOURCE_BINDING = {
	template = {path="template"},
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	listview = {path="box_img.listview"},
	needLabel = {path="box_img.need_label"},
	downBtn = {path="box_img.down_btn",events={{event="click",method="onClickDownBtn"}}},
	upBtn = {path="box_img.up_btn",events={{event="click",method="onClickUpBtn"}}},
}

C.downCallback = nil
C.upCallback = nil
C.isShowed = false

function C:destroy()
	self.listview:removeAllItems()
	self.downCallback = nil
	self.upCallback = nil
end

function C:onCreate()
	C.super.onCreate(self)
	self.template:setVisible(false)
	self.downBtn:setVisible(false)
	self.needLabel:setString("")
	self.listview:removeAllItems()
	self.listview:setTopPadding(5)
	self.listview:setBottomPadding(5)
	self.listview:setScrollBarWidth(5)
	self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
end

function C:show( bankerList, inBankerList, needMoney )
	C.super.show(self)
	self.isShowed = true
	local text = string.format("%0.0f",needMoney/MONEY_SCALE)
	self.needLabel:setString(text)
	self:reload(bankerList,inBankerList)
end

function C:hide()
	C.super.hide(self)
	self.isShowed = false
end

function C:onClickUpBtn( event )
	if self.upCallback then
		self.upCallback()
	end
	-- self:hide()
end

function C:onClickDownBtn( event )
	if self.downCallback then
		self.downCallback()
	end
	self:hide()
end

function C:reload( dataArr, inBankerList )
	if self.isShowed == false then
		return
	end
	if inBankerList then
		self.upBtn:setVisible(false)
		self.downBtn:setVisible(true)
	else
		self.upBtn:setVisible(true)
		self.downBtn:setVisible(false)
	end
	self.listview:removeAllItems()
	if dataArr then
		for i,v in ipairs(dataArr) do
			local item = self:createItem(i,v)
			self.listview:pushBackCustomItem(item)
		end
	end
	self.listview:jumpToTop()
end

function C:createItem( index,info )
	local item = self.template:clone()
	item:setVisible(true)
	local headId = info["headid"]
	local headUrl = info["wxheadurl"]
	local headImg = item:getChildByName("head_img")
	SET_HEAD_IMG(headImg,headId,headUrl)
	local name = info["name"]
	if name == nil or name == "" then
		name = tostring(info["playerid"])
	end
	item:getChildByName("name_label"):setString(name)
	local money = utils:moneyString(info["coin"],3)
	item:getChildByName("blance_label"):setString(money)
	local isMe = info["playerid"] == dataManager.playerId
	item:getChildByName("me_img"):setVisible(isMe)
	item:getChildByName("sort_label"):setString(tostring(index))
	return item
end

return C