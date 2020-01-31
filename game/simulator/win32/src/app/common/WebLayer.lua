local C = class("WebLayer",BaseLayer)
WebLayer = C

C.RESOURCE_FILENAME = "common/WebLayer.csb"
C.RESOURCE_BINDING = {
    top = {path="top"},
    titleLabel = {path="top.title_label"},
	closeBtn = {path="top.close_btn",events={{event="click",method="hide"}}},
	container = {path="container"},
}

--是否使用显示隐藏动画
C.USE_ACTION = false
--是否使用模态
C.USE_MODAL = false
--webview
C.webview = nil
C.widthOfWebview = display.width

function C:onCreate()
    C.super.onCreate(self)
    if device.platform == "android" or GET_PHONE_HAIRE_WIDTH() > 0 then
        self.widthOfWebview = display.width-180
    end
    local topSize = cc.size(self.widthOfWebview,self.top:getContentSize().height)
    self.top:setContentSize(topSize)
    self.titleLabel:setPositionX(self.widthOfWebview/2)
    self.closeBtn:setPositionX(self.widthOfWebview)

    local containerSize = cc.size(display.width,self.container:getContentSize().height)
    self.container:setContentSize(containerSize)

	if device.platform == "ios" or device.platform == "android" then
		local width = self.container:getContentSize().width
		local height = self.container:getContentSize().height-60
        self.webview = ccexp.WebView:create()
        self.webview:setPosition(cc.p(width/2,height/2))
        self.webview:setContentSize(self.widthOfWebview,height)
        self.webview:setScalesPageToFit(true)
        self.webview:setOnShouldStartLoading(function(sender, url)
            self.titleLabel:setVisible(true)
            return true
        end)
        self.webview:setOnDidFinishLoading(function(sender, url)
            self.titleLabel:setVisible(false)
            self.webview:setVisible(true)
        end)
        self.webview:setOnDidFailLoading(function(sender, url)
            self.titleLabel:setVisible(false)
        end)
        self.webview:addTo(self.container)
    end
end

function C:show( url, cleanCached )
	if device.platform == "ios" or device.platform == "android" then
		C.super.show(self)
        self:setLocalZOrder(10000)
		cleanCached = cleanCached or false
		self.webview:loadURL( url, cleanCached )
    else
        utils:openUrl(url)
	end
end

function C:onEnter()
    C.super.onEnter(self)
    if self.webview then
        local width = self.container:getContentSize().width
        local height = self.container:getContentSize().height-60
        self.webview:setPosition(cc.p(width/2,height/2))
        self.webview:setContentSize(self.widthOfWebview,height)
    end
end

function C:onExit()
    if self.webview then
        self.webview:stopLoading()
        self.webview:setVisible(false)
    end
    C.super.onExit(self)
end

return WebLayer