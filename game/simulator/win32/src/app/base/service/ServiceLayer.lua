local C = class("ServiceLayer",BaseLayer)
ServiceLayer = C

C.RESOURCE_FILENAME = "base/ServiceLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	contactTabBtn = {path="box_img.contact_tab_btn",events={{event="click",method="onClickContactTabBtn"}}},
	commonTabBtn = {path="box_img.common_tab_btn",events={{event="click",method="onClickCommonTabBtn"}}},
	contactPanel = {path="box_img.contact_panel"},
	commonPanel = {path="box_img.common_panel"},
	onlinePanel = {path="box_img.online_panel"},
	--listview = {path="box_img.contact_panel.listview"},
	--inputBg = {path="box_img.contact_panel.bottom_img.input_img"},
	--sendBtn = {path="box_img.contact_panel.bottom_img.send_btn",events={{event="click",method="onClickSendBtn"}}},
	templateLeft = {path="left_item"},
	templateRight = {path="right_item"},
}
C.webview = nil

function C:onCreate()
	C.super.onCreate(self)
	--self.inputEditBox = self:createEditBox()
	--self.inputBg:addChild(self.inputEditBox)
	self.templateLeft:setVisible(false)
	self.templateRight:setVisible(false)
	local headImg = self.templateRight:getChildByName("head_panel"):getChildByName("head_img")
	local headId = dataManager.userInfo.headid
	local headUrl = dataManager.userInfo.wxheadurl
	SET_HEAD_IMG(headImg,headId,headUrl)
	--self.listview:setScrollBarWidth(5)
	--self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
	--self.listview:setTopPadding(10)
	--self.listview:setBottomPadding(10)
	self.commonPanel:setScrollBarWidth(5)
	self.commonPanel:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
end

function C:createEditBox()
	local bg = cc.Scale9Sprite:create("base/images/service_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(426,50),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(15,38))
	editBox:setFontSize(24)
	editBox:setFontColor(cc.c3b(255,255,255))
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	editBox:setMaxLength(140)
	local label = ccui.Text:create()
	label:setFontSize(24)
	label:setString("输入您想咨询的问题")
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(410,50))
	label:setPosition(cc.p(205,25))
	editBox:addChild(label)
	editBox:onEditHandler(handler(self,self["onEditHandler"]))
	return editBox
end

function C:onEditHandler( event )
	if event.name == "began" then
		local l = event.target:getChildByTag(10000)
		l:setVisible(false)
	elseif event.name == "ended" then
		if event.target:getText() == nil or event.target:getText() == "" then
			local l = event.target:getChildByTag(10000)
			l:setVisible(true)
		end
	end
end

function C:show()
	C.super.show(self)
	self:showTabIndex(2,true)
	--self:loadMessage()

    self.receiveNewRespHandler = handler(self,self.receiveNewResp)
    eventManager:on("CustomServiceMsgReply",self.receiveNewRespHandler)

    --self.refreshListviewHandler = handler(self,self.refreshListview)
    --eventManager:on("UpdateCustomServiceMsg",self.refreshListviewHandler)

    dataManager:setLastReadMsgTime(os.time())
    eventManager:publish("SetCustomServiceRedDot",false)
end

function C:hide()
	C.super.hide(self)
	if self.webview then
		self.webview:setVisible(false)
	end
end

function C:onExit()
    eventManager:off("CustomServiceMsgReply",self.receiveNewRespHandler)
    --eventManager:off("UpdateCustomServiceMsg",self.refreshListviewHandler)
    dataManager:setLastReadMsgTime(os.time())
    utils:removeTimer("hall.webview")
    if self.webview then
		self.webview:setVisible(false)
	end
	C.super.onExit(self)
end

--加载数据
function C:loadMessage()
	local items = dataManager.customServiceMsgList
	if #items == 0 then
        eventManager:publish("CustomServiceMsgList")
	else
		utils:delayInvoke("hall.service",0.5,function()
			self:refreshListview(items)
		end)
	end
end

--收到新回复消息
function C:receiveNewResp( item )
	local item = self:createFromItem(item.content)
	self.listview:pushBackCustomItem(item)
	self.listview:jumpToBottom()
end

--刷新列表
function C:refreshListview(items)
	self.listview:removeAllItems()
	for i,v in ipairs(items) do
		if v.type == "to" then
			local item = self:createToItem(v.content)
			self.listview:pushBackCustomItem(item)
		elseif v.type == "from" then
			local item = self:createFromItem(v.content)
			self.listview:pushBackCustomItem(item)
		end
	end
	self.listview:jumpToBottom()
end

function C:onClickContactTabBtn( event )
	self:showTabIndex(1)
end

function C:onClickCommonTabBtn( event )
	self:showTabIndex(2)
end

function C:showTabIndex( index,fromShow )
	local flags = (index==1 and ONLINE_SERVICE_ENABLED == false)
	self.contactPanel:setVisible(flags)
	flags = (index==1 and ONLINE_SERVICE_ENABLED == true)
    if index==1 then
        self.onlinePanel:setVisible(true)
	else
       self.onlinePanel:setVisible(false)
	end
	--self.onlinePanel:setVisible(flags)
	self.contactTabBtn:setEnabled(index~=1)
	self.commonPanel:setVisible(index==2)
	self.commonTabBtn:setEnabled(index~=2)
	if self.onlinePanel:isVisible() then
		self:showWebView(true)
	else
		if self.webview then
			self.webview:setVisible(false)
		end
	end
end

function C:showWebView(fromShow)
--	local doAction = function()
--		if self.webview then
--			self.webview:setVisible(true)
--		elseif self.webview == nil and (device.platform == "ios" or device.platform == "android")  then
--			local width = self.onlinePanel:getContentSize().width
--			local height = self.onlinePanel:getContentSize().height
--	        self.webview = ccexp.WebView:create()
--	        self.webview:setPosition(cc.p(width/2,height/2))
--	        self.webview:setContentSize(width-4, height-4)
--	        self.webview:setScalesPageToFit(true)
--	        self.webview:setOnShouldStartLoading(function(sender, url)
--	            return true
--	        end)
--	        self.webview:setOnDidFinishLoading(function(sender, url)
--	        end)
--	        self.webview:setOnDidFailLoading(function(sender, url)
--	        end)
--	        self.webview:addTo(self.onlinePanel)
--	        --客服URL
--	        local url = "https://chat-new.mqimg.com/widget/standalone.html?eid=158206"  --tostring(DEFAULT_SERVICE_URL).."&info="..string.urlencode("userId=0".."&name=用户ID:"..tostring(dataManager.playerId)..",平台:"..tostring(dataManager.styleId)..",渠道:"..tostring(CHANNEL_ID).."&memo=0")
--	        self.webview:loadURL(url,true)
--		end
--	end
--	if fromShow then
--		utils:delayInvoke("hall.webview",0.3,function()
--			doAction()
--		end)
--	else
--		doAction()
--	end
    utils:openUrl("https://chat-new.mqimg.com/widget/standalone.html?eid=158206")
end

--点击发送按钮
function C:onClickSendBtn( event )
	local text = self.inputEditBox:getText()
	if text == nil or text == "" then
		toastLayer:show("请输入内容")
		return
	end
	printInfo("====text:"..#text)
	if #text < 12 then
		toastLayer:show("输入内容过少")
		return
	end
	local item = self:createToItem(text)
	self.listview:pushBackCustomItem(item)
	self.listview:jumpToBottom()
	self.inputEditBox:setText("")
	self.inputEditBox:getChildByTag(10000):setVisible(true)
	--发送出去
    eventManager:publish("CustomServiceMsg",text)
end

function C:createFromItem( text )
	local item = self.templateLeft:clone()
	item:setVisible(true)
	local head = item:getChildByName("head_panel")
	local bg = item:getChildByName("content_img")

	local label = cc.LabelTTF:create()
	label:setFontSize(26)
	label:setColor(cc.c3b(0,0,0))
	label:setAnchorPoint(cc.p(0,0.5))
	label:setDimensions(cc.size(420,0))
	label:setString(text)
	bg:addChild(label)
	label:setDimensions(cc.size(0,26))
	local width = label:getContentSize().width
	if width > 420 then
		label:setDimensions(cc.size(420,0))
	end
	width = label:getContentSize().width
	local height = label:getContentSize().height
	
	local bgWidth = width + 30
	local bgHeight = height + 34

	if bgWidth < 40 then
		bgWidth = 40
	end
	if bgHeight < 60 then
		bgHeight = 60
	end

	local itemWidth = item:getContentSize().width
	local itemHeight = bgHeight+20

	bg:setContentSize(cc.size(bgWidth,bgHeight))
	label:setPosition(cc.p(18,bgHeight/2))
	item:setContentSize(cc.size(itemWidth,itemHeight))
	head:setPositionY(itemHeight-10)
	return item
end

function C:createToItem( text )
	local item = self.templateRight:clone()
	item:setVisible(true)
	local head = item:getChildByName("head_panel")
	local bg = item:getChildByName("content_img")

	local label = cc.LabelTTF:create()
	label:setFontSize(26)
	label:setColor(cc.c3b(0,0,0))
	label:setAnchorPoint(cc.p(1,0.5))
	label:setString(text)
	bg:addChild(label)
	label:setDimensions(cc.size(0,26))
	local width = label:getContentSize().width
	if width > 420 then
		label:setDimensions(cc.size(420,0))
	end
	width = label:getContentSize().width
	local height = label:getContentSize().height
	
	local bgWidth = width + 30
	local bgHeight = height + 34

	if bgWidth < 40 then
		bgWidth = 40
	end
	if bgHeight < 60 then
		bgHeight = 60
	end

	local itemWidth = item:getContentSize().width
	local itemHeight = bgHeight+20

	bg:setContentSize(cc.size(bgWidth,bgHeight))
	label:setPosition(cc.p(bgWidth-18,bgHeight/2))
	item:setContentSize(cc.size(itemWidth,itemHeight))
	head:setPositionY(itemHeight-10)
	return item
end

return ServiceLayer