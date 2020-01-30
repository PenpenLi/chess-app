local C = class("BrnnPlayerListLayer",BaseLayer)

C.RESOURCE_FILENAME = "games/brnn/PlayerListLayer.csb"
C.RESOURCE_BINDING = {
	template1 = {path="template_1"},
	template2 = {path="template_2"},
	template3 = {path="template_3"}, 
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	listview = {path="box_img.listview"}, 
}

C.requestCallback = nil
C.responseCallback = nil
C.currentPage = 0
C.totalPages = 0
C.lastRequestTime = 0

function C:destroy()
	self.listview:removeAllItems()
	self.requestCallback = nil
	self.responseCallback = nil
end

function C:onCreate()
	C.super.onCreate(self)
	self.template1:setVisible(false)
	self.template2:setVisible(false)
	self.template3:setVisible(false)
	self.listview:removeAllItems()
	self.listview:setTopPadding(5)
	self.listview:setBottomPadding(5)
	self.listview:setScrollBarWidth(5)
	self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
	self.responseCallback = handler(self,self.responsePlayerList)
end

function C:show()
	C.super.show(self)
	local nowTime = os.time()
	if nowTime-self.lastRequestTime >= 30 then
		self:requestPlayerList(1)
	else
		self.listview:jumpToTop()
	end
end

function C:requestPlayerList(page)
	if self.requestCallback then
		self.requestCallback(page)
	end
end

function C:responsePlayerList( info )
	if info == nil then
		return
	end
	self.lastRequestTime = os.time()
	self.totalPages = info["pages"] or 0
	self.currentPage = info["page"] or 0
	if info["data"] then
		if self.currentPage == 1 then
			self:reloadPlayerList(info["data"])
		else
			self:addPlayerList(info["data"])
		end
	end
	local count = #self.listview:getItems()
	if self.currentPage < self.totalPages and count < 101 then
		self:requestPlayerList(self.currentPage+1)
	end
end

function C:reloadPlayerList( dataArr )
	self.listview:removeAllItems()
	self:addPlayerList(dataArr)
	self.listview:jumpToTop()
end

function C:addPlayerList( dataArr )
	local count = #self.listview:getItems()
	for i,v in ipairs(dataArr) do
		local index = count+i
		local item = self:createItem(index,v)
		self.listview:pushBackCustomItem(item)
	end
end

function C:createItem( index,info )
	local item = nil
	if index == 1 then
		 item = self.template1:clone()
		 item:getChildByName("rank_img"):loadTexture(GAME_BRNN_IMAGES_RES.."star.png")
	elseif index == 2 then
		item = self.template1:clone()
		item:getChildByName("rank_img"):loadTexture(GAME_BRNN_IMAGES_RES.."rich_1.png")
	elseif index <= 9 then
		item = self.template2:clone()
		item:getChildByName("rank_img"):loadTexture(GAME_BRNN_IMAGES_RES.."rich_"..tostring(index-1)..".png")
	else
		item = self.template3:clone()
		item:getChildByName("rank_img"):getChildByName("label"):setString(tostring(index-1))
	end
	--TODO:屏蔽vip
	item:getChildByName("vip_img"):setVisible(false)
	item:setVisible(true)
	local head = GET_HEADID_RES(info["headid"])
	item:getChildByName("head_img"):loadTexture(head)
	local name = "ID:"..tostring(info["playerid"])
	item:getChildByName("name_label"):setString(name)
	local money = utils:moneyString(info["coin"],3)
	item:getChildByName("blance_label"):setString(money)
	local bet = utils:moneyString(info["allbet"],3)
	item:getChildByName("bet_label"):setString(bet)
	local win = tostring(info["wins"]).."局"
	item:getChildByName("win_label"):setString(win)
	return item
end

return C