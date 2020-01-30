local C = class("ProxyLayer",BaseLayer)
ProxyLayer = C

C.RESOURCE_FILENAME = "base/ProxyLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	nameLabel = {path="box_img.name_img.label"},
	wxLabel = {path="box_img.wx_img.label"},
	openBtn = {path="box_img.btn",events={{event="click",method="onClickOpenBtn"}}},
}

C.proxyInfo = nil

function C:ctor( info )
	self.proxyInfo = info
	C.super.ctor(self)
end

function C:onCreate()
	C.super.onCreate(self)
	self.nameLabel:setString(self.proxyInfo.AgentName)
	self.wxLabel:setString(self.proxyInfo.WeiXin)
end

function C:onClickOpenBtn( event )
	local text = self.wxLabel:getString() or ""
	utils:setCopy(text)
	toastLayer:show("复制成功，即将打开微信...")
	utils:delayInvoke("hall.proxy",3,function()
		platform.openApp("wx")
		self:hide()
	end)
end

return ProxyLayer