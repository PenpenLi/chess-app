local C = class("SmsLoginLayer",BaseLayer)
SmsLoginLayer = C

C.RESOURCE_FILENAME = "base/SmsLoginLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	accountBg = {path="box_img.account_panel.bg_img"},
	codeBg = {path="box_img.code_panel.bg_img"},
	codeBtn = {path="box_img.code_panel.btn",events={{event="click",method="onClickCodeBtn"}}},
	codeLabel = {path="box_img.code_panel.btn.label"},
	loginBtn = {path="box_img.login_btn",events={{event="click",method="onClickLoginBtn"}}},
	pswLoginBtn = {path="box_img.psw_login_btn",events={{event="click",method="onClickPswLoginBtn"}}},
}

C.accountEditBox = nil
C.codeEditBox = nil

function C:onCreate()
	C.super.onCreate(self)
	self.accountEditBox = self:createEditBox("请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.accountBg:addChild(self.accountEditBox)
	self.codeEditBox = self:createEditBox("输入验证码",cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.codeEditBox:setContentSize(cc.size(178,40))
    local label = self.codeEditBox:getChildByTag(10000)
    label:setContentSize(cc.size(178,40))
    label:setPosition(cc.p(89,30))
    self.codeBg:addChild(self.codeEditBox)
	self.codeBtn:setEnabled(true)
	self.codeLabel:setVisible(false)
end

function C:createEditBox( placeholder, inputMode )
	local bg = cc.Scale9Sprite:create("base/images/account_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(348,40),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(8,33))
	editBox:setFontSize(22)
	editBox:setFontColor(INPUT_COLOR)
	editBox:setInputMode(inputMode)
	local label = ccui.Text:create()
	label:setFontSize(22)
	label:setString(placeholder)
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(348,40))
	label:setPosition(cc.p(174,30))
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

function C:startTimer()
    self:stopTimer()
    self.codeBtn:setEnabled(false)
    self.codeLabel:setVisible(true)
    self.codeLabel:setString("30")
    local count = 30
    utils:createTimer("hall.LOGIN_GET_MSG_CODE",1,function()
        count = count - 1
        self.codeLabel:setString(tostring(count))
        if count <= 0 then
            self:stopTimer()
        end
    end)
end
function C:stopTimer()
    utils:removeTimer("hall.LOGIN_GET_MSG_CODE")
    self.codeBtn:setEnabled(true)
    self.codeLabel:setVisible(false)
end

--获取短信验证码
function C:onClickCodeBtn( event )
    local phone = self.accountEditBox:getText()
    if phone == nil or phone == "" then
        toastLayer:show("请输入手机号码")
        return
    end
    if string.match(phone,"[1][3,4,5,7,8,9]%d%d%d%d%d%d%d%d%d") ~= phone then
        toastLayer:show("请输入正确的手机号码")
        return
    end
    --获取短信验证码
    self:startTimer()
    local ctype = CONST_VERIFY_CODE_LOGIN or 2
    eventManager:publish("RequestPhoneVerifyCode",phone,ctype)
end

--点击登录
function C:onClickLoginBtn( event )
	local account = self.accountEditBox:getText()
	if account == nil or account == "" then
		toastLayer:show("请输入手机号！")
		return
	end
	local code = self.codeEditBox:getText()
	if code == nil or code == "" then
		toastLayer:show("请输入验证码！")
		return
	end
	--验证码登录
	loadingLayer:show("正在登录...",120)
	eventManager:publish("SmsLogin",account,code)
end

--密码登录
function C:onClickPswLoginBtn( event )
	self:hide()
	utils:delayInvoke("smslogin.pwd",0.3,function()
		LoginLayer.new():show()
	end)
end

return SmsLoginLayer