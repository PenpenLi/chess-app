local C = class("AnnounceLayer",BaseLayer)
AnnounceLayer = C

C.RESOURCE_FILENAME = "base/AnnounceLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="OnBack"}}},
	emptyPanel = {path="box_img.empty_panel"},
	listview = {path="box_img.listview"},
	messageItem = {path="item_1"},
	moneyItem = {path="item_2"}
}

C.announceArr = nil
C.onMsgDetail = nil

function C:onCreate()
	C.super.onCreate(self)
	self.messageItem:setVisible(false)
	self.moneyItem:setVisible(false)
	self.listview:setScrollBarWidth(5)
	self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
	self.listview:removeAllItems()
end

function C:show()
	C.super.show(self)
	--获取缓存邮件列表
    self:loadAnnounces()

    self.onLoadAnnouncesHandler = handler(self,self.onLoadAnnounces)
    eventManager:on("MailList",self.onLoadAnnouncesHandler)
    self.onMessageDetailHandler = handler(self,self.onMessageDetail)
    eventManager:on("MailDetail",self.onMessageDetailHandler)
    self.onAddMessageHandler = handler(self,self.onAddMessage)
    eventManager:on("AddMail",self.onAddMessageHandler)

    if self.announceArr == nil or #self.announceArr == 0 then
        eventManager:publish("RequestMailList")
    end
end

function C:onExit()
    eventManager:off("MailList",self.onLoadAnnouncesHandler)
    eventManager:off("MailDetail",self.onMessageDetailHandler)
    eventManager:off("AddMail",self.onAddMessageHandler)
	C.super.onExit(self)
end

function C:OnBack( event )
	require("app.init")
	HallCore.new():run()
end

--请求邮件列表数据
function C:loadAnnounces()
	self:onLoadAnnounces(dataManager.mails)
end

function C:onLoadAnnounces(array)
	self.announceArr = array
	table.sort( self.announceArr, function ( a,b )
		if a.readtype == b.readtype then
			return a.id > b.id
		else
			return a.readtype < b.readtype
		end
	end )
	self:refreshListview(self.announceArr)
end

function C:onMessageDetail(detail)
    if self.onMsgDetail then
        self.onMsgDetail(detail)
    end
    loadingLayer:hide()
end

function C:onAddMessage()
    self:onLoadAnnounces(self.announceArr)
end

function C:refreshListview( announceArr )
	self.listview:removeAllItems()
	if announceArr == nil or #announceArr == 0 then
		self.emptyPanel:setVisible(true)
		self.listview:setVisible(false)
		return
	end
	self.emptyPanel:setVisible(false)
	self.listview:setVisible(true)
	--添加邮件
	for i=1,#announceArr do
		local item = announceArr[i]
		if item.mailtype == 3 then
			local node = self:createMoneyItem(i,item)
			self.listview:pushBackCustomItem(node)
		else
			local node = self:createMessageItem(i,item)
			self.listview:pushBackCustomItem(node)
		end
	end
end

--创建消息邮件item
function C:createMessageItem( index, info )
	local item = self.messageItem:clone()
	item:setTag(index)
	item:getChildByName("btn"):setTag(index)
	item:setVisible(true)
	item:getChildByName("title_label"):setString(info.title)
	item:getChildByName("time_label"):setString(info.time)
	item:getChildByName("from_img"):getChildByName("label"):setString("发件人:"..tostring(info.from))
	if info.readtype == CONST_MAIL_UNREADY then
		item:getChildByName("btn"):setVisible(true)
		item:getChildByName("read_img"):setVisible(false)
	else
		item:getChildByName("btn"):setVisible(false)
		item:getChildByName("read_img"):setVisible(true)
	end
	item:getChildByName("btn"):onClick(handler(self,self["onSelectedMessageItem"]))
	item:onTouch(handler(self,self["onSelectedMessageItem"]))
	return item
end

--创建金币邮件item
function C:createMoneyItem( index, info )
	local item = self.moneyItem:clone()
	item:setTag(index)
	item:getChildByName("btn"):setTag(index)
	item:setVisible(true)
	item:getChildByName("title_label"):setString(info.title)
	item:getChildByName("time_label"):setString(info.time)
	item:getChildByName("coin_label"):setString(utils:moneyString(info.money))
	item:getChildByName("from_img"):getChildByName("label"):setString("发件人:"..tostring(info.from))
	if info.readtype == CONST_MAIL_UNREADY then
		item:getChildByName("btn"):setVisible(true)
		item:getChildByName("gained_img"):setVisible(false)
	else
		item:getChildByName("btn"):setVisible(false)
		item:getChildByName("gained_img"):setVisible(true)
	end
	item:getChildByName("btn"):onClick(handler(self,self["onSelectedMoneyItem"]))
	item:onTouch(handler(self,self["onSelectedMoneyItem"]))
	return item
end

--点击查看消息邮件详情
function C:onSelectedMessageItem( event )
	if event.name ~= "ended" then
		return
	end
	local index = event.target:getTag()
	local item = self.listview:getItem(index-1)
	item:getChildByName("btn"):setVisible(false)
	item:getChildByName("read_img"):setVisible(true)
	local info = self.announceArr[index]
    if info.content then
	    AnnounceDetailLayer.new(info):show()
        self.onMsgDetail = nil
    else
        local function msgDetail(s)
            if s.id == info.id then
                self.onMsgDetail = nil
                AnnounceDetailLayer.new(s):show()
                if info.readtype == CONST_MAIL_UNREADY then
                    eventManager:publish("SetMailRead",info.id)
                end
            end
        end
        self.onMsgDetail = msgDetail
        eventManager:publish("RequestMailDetail",info.id)
        loadingLayer:show("正在读取...")
    end
end

--点击查看金币邮件详情
function C:onSelectedMoneyItem( event )
	if event.name ~= "ended" then
		return
	end
	local index = event.target:getTag()
	local info = self.announceArr[index]
	if info.readtype == CONST_MAIL_UNREADY then
		AnnounceUngainedLayer.new(info,function()
			local info = self.announceArr[index]
			info.readtype = CONST_MAIL_READY
			local item = self.listview:getItem(index-1)
			item:getChildByName("btn"):setVisible(false)
			item:getChildByName("gained_img"):setVisible(true)
			--播放金币粒子动画
			self:playGoldAni()
		end):show()
	else
		AnnounceGainedLayer.new(info):show()
	end
end

function C:playGoldAni()
	local particle = cc.ParticleSystemQuad:create("base/animation/particle/gold.plist")
    particle:setAutoRemoveOnFinish(true)
    particle:setPosition(display.cx,display.bottom+100)
    self:addChild(particle)
end

return AnnounceLayer