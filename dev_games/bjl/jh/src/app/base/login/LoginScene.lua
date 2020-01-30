local C = class("LoginScene",SceneBase)

C.RESOURCE_FILENAME = "base/LoginScene.csb"
C.RESOURCE_BINDING = {
	versionLabel = {path="version_label"},
	wxLoginBtn = {path="wx_btn",events={{event="click",method="onClickWxBtn"}}},
	ykLoginBtn = {path="yk_btn",events={{event="click",method="onClickYkBtn"}}},
	sjLoginBtn = {path="sj_btn",events={{event="click",method="onClickSjBtn"}}},
}

function C:initialize()
	-- SwitchLayer.new():show(self)
	local text = "版本信息"..tostring(CHANNEL_ID).."."..tostring(dataManager:getLocalBaseVersion()).."."..tostring(dataManager.remoteBaseVersion)
	self.versionLabel:setString(text)
	if WECHAT_LOGIN_ENABLED and WECHAT_APPID and WECHAT_APPID ~= "" and (device.platform == "ios" or device.platform == "android") then
        self.wxLoginBtn:setVisible(true)
    	self.ykLoginBtn:setVisible(false)
    else
    	self.wxLoginBtn:setVisible(false)
    	self.ykLoginBtn:setVisible(true)
    end
    self.versionLabel:runAction(cc.CallFunc:create(function ()
        display.setAutoScale(CC_DESIGN_RESOLUTION)
    end))   
end

--游客登录
function C:onClickYkBtn( event )
   	loadingLayer:show("正在登录...",120)
    eventManager:send("NullLogin")
end

--微信登录
function C:onClickWxBtn( event )
	local callback = function( code )
		printInfo("===========wechat login:"..tostring(code))
		if code and code ~= "" then
			loadingLayer:show("正在登录...",120)
	    	eventManager:publish("WechatLogin",code)
	    end
	end
	utils:sendWechatLogin(callback)
end

--手机登录
function C:onClickSjBtn( event )
	SmsLoginLayer.new():show()
end

return C