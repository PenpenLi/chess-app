local C = class("WebLayer",BaseLayer)
WebLayer = C

C.RESOURCE_FILENAME = "common/WebLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="hide"}}},
	panel = {path="panel"},
}

--是否使用显示隐藏动画
C.USE_ACTION = false
--是否使用模态
C.USE_MODAL = false
--webview
C.webView = nil
C.offsetX = (display.width-1136)/2
C.hairOffsetX = 0

function C:onCreate()
    C.super.onCreate(self)
    self.panel:setContentSize({width=display.width,height=display.height})
    self.panel:setPositionX(-self.offsetX)
	if device.platform == "ios" or device.platform == "android" then
		local width = self.panel:getContentSize().width
		local height = self.panel:getContentSize().height
        self.webView = ccexp.WebView:create()
        self.webView:setPosition(cc.p(width/2, (height-70)/2))
        self.webView:setContentSize(width, height-70)
        
        self.webView:setScalesPageToFit(true)
        self.webView:setOnShouldStartLoading(function(sender, url)
            printInfo("====onWebViewShouldStartLoading, url is ", url)
            return true
        end)
        self.webView:setOnDidFinishLoading(function(sender, url)
            printInfo("===onWebViewDidFinishLoading, url is ", url)
        end)
        self.webView:setOnDidFailLoading(function(sender, url)
            printInfo("===onWebViewDidFinishLoading, url is ", url)
        end)
        self.webView:addTo(self.panel)
    end
end

function C:show( url, cleanCached )
	if device.platform == "ios" or device.platform == "android" then
		C.super.show(self)
		cleanCached = cleanCached or false
		self.webView:loadURL( url, cleanCached )
    else
        utils:openUrl()
	end
end

return WebLayer