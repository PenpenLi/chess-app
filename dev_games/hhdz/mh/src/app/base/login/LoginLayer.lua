local C = class("LoginLayer",BaseLayer)
LoginLayer = C

C.RESOURCE_FILENAME = "base/LoginLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	accountBg = {path="box_img.account_panel.bg_img"},
	passwordBg = {path="box_img.password_panel.bg_img"},
	loginBtn = {path="box_img.login_btn",events={{event="click",method="onClickLoginBtn"}}},
	registerBtn = {path="box_img.register_btn",events={{event="click",method="onClickRegisterBtn"}}},
	resetBtn = {path="box_img.password_panel.reset_btn",events={{event="click",method="onClickResetBtn"}}},
}

C.accountEditBox = nil
C.passwordEditBox = nil

function C:onCreate()
	C.super.onCreate(self)
	if self.registerBtn then
		self.registerBtn:setVisible(false)
	end
	self.accountEditBox = self:createEditBox("请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.accountBg:addChild(self.accountEditBox)
	self.passwordEditBox = self:createEditBox("请输入密码",cc.EDITBOX_INPUT_MODE_EMAILADDR)--6-12位英文/数字/点/减号/下划线
	self.passwordEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	self.passwordEditBox:setContentSize(cc.size(225,40))
    local label = self.passwordEditBox:getChildByTag(10000)
    label:setContentSize(cc.size(225,40))
    label:setPosition(cc.p(10,19))
	self.passwordBg:addChild(self.passwordEditBox)
end

function C:createEditBox( placeholder, inputMode )
	local bg = cc.Scale9Sprite:create("base/images/account_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(330,40),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(6,35))
	editBox:setFontSize(22)
	editBox:setFontColor(INPUT_COLOR)
	editBox:setInputMode(inputMode)
	local label = ccui.Text:create()
	label:setFontSize(22)
	label:setString(placeholder)
	label:setAnchorPoint(cc.p(0,0.5))
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(330,40))
	label:setPosition(cc.p(10,19))
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

function C:onEnter()
	C.super.onEnter(self)
	self.onLoginRespHandler = handler(self,self.onLoginResp)
    eventManager:on("LoginResp", self.onLoginRespHandler)
end

function C:onExit()
	eventManager:off("LoginResp", self.onLoginRespHandler)
	C.super.onExit(self)
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

function C:onClickRegisterBtn( event )
	self:hide()
	utils:delayInvoke("login.register",0.3,function()
		RegisterLayer.new():show()
	end)
end

return LoginLayer