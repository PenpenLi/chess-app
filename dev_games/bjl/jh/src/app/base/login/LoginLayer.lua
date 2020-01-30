local C = class("LoginLayer",BaseLayer)
LoginLayer = C

C.RESOURCE_FILENAME = "base/LoginLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	accountBg = {path="box_img.account_panel.bg_img"},
	passwordBg = {path="box_img.password_panel.bg_img"},
	loginBtn = {path="box_img.login_btn",events={{event="click",method="onClickLoginBtn"}}},
	resetBtn = {path="box_img.reset_btn",events={{event="click",method="onClickResetBtn"}}},
}

C.accountEditBox = nil
C.passwordEditBox = nil

function C:onCreate()
	C.super.onCreate(self)
	self.accountEditBox = self:createEditBox("请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.accountBg:addChild(self.accountEditBox)
	self.passwordEditBox = self:createEditBox("6-12位英文/数字/点/减号/下划线",cc.EDITBOX_INPUT_MODE_EMAILADDR)
	self.passwordEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	self.passwordBg:addChild(self.passwordEditBox)
end

function C:createEditBox( placeholder, inputMode )
	local bg = cc.Scale9Sprite:create("base/images/account_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(352,58),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(11,38))
	editBox:setFontSize(22)
	editBox:setFontColor(cc.c3b(255,255,255))
	editBox:setInputMode(inputMode)
	local label = ccui.Text:create()
	label:setFontSize(22)
	label:setString(placeholder)
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(340,66))
	label:setPosition(cc.p(170,28))
	editBox:addChild(label)
	editBox:onEditHandler(function( event )
		if event.name == "began" then
			local l = event.target:getChildByTag(10000)
			l:setVisible(false)
		elseif event.name == "ended" then
			if event.target:getText() == nil or event.target:getText() == "" then
				local l = event.target:getChildByTag(10000)
				l:setVisible(true)
			end
		end
	end)
	return editBox
end

function C:show()
    C.super.show(self)
    self.onLoginRespHandler = handler(self,self.onLoginResp)
    eventManager:on("LoginResp", self.onLoginRespHandler)
end

function C:hide()
    eventManager:off("LoginResp", self.onLoginRespHandler)
    C.super.hide(self)
end

function C:onHide()
    eventManager:off("LoginResp", self.onLoginRespHandler)
    C.super.onHide(self)
end

function C:onLoginResp(code)
    loadingLayer:hide()
    if code == 0 then
    	self:onHide()
    end
end

function C:onClickLoginBtn( event )
	local account = self.accountEditBox:getText()
	if account == nil or account == "" then
		toastLayer:show("请输入手机号！")
		return
	end
	local password = self.passwordEditBox:getText()
	if password == nil or password == "" then
		toastLayer:show("请输入密码！")
		return
	end
	if #password < 6 then
        toastLayer:show("密码长度不能小于6位")
        return
    end

	loadingLayer:show("正在登录...",120)
	eventManager:publish("Login",account,password,"")
end

function C:onClickResetBtn( event )
	self:hide()
	utils:delayInvoke("login.reset",0.3,function()
		ResetLayer.new():show()
	end)
end

return LoginLayer