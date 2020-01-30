local C = class("BrnnJackpotLayer",BaseLayer)

C.RESOURCE_FILENAME = "games/brnn/JackpotLayer.csb"
C.RESOURCE_BINDING = {
	template = {path="template"},
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	moneyLabel = {path="box_img.money_label"},
	listview = {path="box_img.listview"}, 
}

C.TYPE_CONFIGS = {
	[7] = "brnn_jiangchi_tape_hulu.png",
	[6] = "brnn_jiangchi_tape_shunzi.png",
	[10] = "brnn_jiangchi_tape_ths.png",
	[5] = "brnn_jiangchi_tape_tonghua.png",
	[8] = "brnn_jiangchi_tape_whn.png",
	[11] = "brnn_jiangchi_tape_wxn.png",
	[9] = "brnn_jiangchi_tape_zdn.png",
}
C.TYPE_SIZE = {
	[7] = cc.size(61,35),
	[6] = cc.size(61,35),
	[10] = cc.size(86,35),
	[5] = cc.size(60,35),
	[8] = cc.size(89,35),
	[11] = cc.size(89,35),
	[9] = cc.size(89,35),
}

function C:destroy()
	self.listview:removeAllItems()
end

function C:onCreate()
	C.super.onCreate(self)
	self.template:setVisible(false)
	self.listview:removeAllItems()
	self.listview:setTopPadding(5)
	self.listview:setBottomPadding(5)
	self.listview:setScrollBarWidth(5)
	self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
end

function C:show()
	C.super.show(self)
	self.listview:jumpToTop()
end

function C:setJackpotMoney( money )
	local moneyStr = utils:moneyString(money,3)
	self.moneyLabel:setString(moneyStr)
end

function C:reloadRewardPlayerList( dataArr )
	if dataArr == nil then
		return
	end
	table.sort( dataArr, function( a,b )
		return a.time > b.time
	end )
	self.listview:removeAllItems()
	for i,v in ipairs(dataArr) do
		local item = self:createItem(v)
		self.listview:pushBackCustomItem(item)
	end
	self:removeMore()
	self.listview:jumpToTop()
end

function C:addRewardPlayer( info )
	if info == nil then
		return
	end
	local item = self:createItem(info)
	self.listview:insertCustomItem(item,0)
	self:removeMore()
end

function C:removeMore()
	local count = #self.listview:getItems()
	if count > 100 then
		for i=100,count-1 do
			self.listview:removeLastItem()
		end
	end
end

function C:createItem( info )
	local item = self.template:clone()
	item:setVisible(true)
	--TODO:屏蔽vip
	item:getChildByName("vip_img"):setVisible(false)
	local head = GET_HEADID_RES(info["headid"])
	item:getChildByName("head_img"):loadTexture(head)
	local name = "ID:"..tostring(info["playerid"])
	item:getChildByName("name_label"):setString(name)
	local money = utils:moneyString(info["winmoney"],3)
	item:getChildByName("money_label"):setString(money)
	local isMe = info["playerid"] == dataManager.playerId
	item:getChildByName("me_img"):setVisible(isMe)
	local time = os.date("%Y-%m-%d %H:%M:%S",info["time"])
	item:getChildByName("time_label"):setString(time)
	local ctype = info["emtype"]
	local typeRes = GAME_BRNN_IMAGES_RES..self.TYPE_CONFIGS[ctype]
	local size = self.TYPE_SIZE[ctype]
	if typeRes then
		item:getChildByName("type_img"):loadTexture(typeRes)
		item:getChildByName("type_img"):setContentSize(size)
	else
		item:getChildByName("type_img"):setVisible(false)
	end
	return item
end

return C