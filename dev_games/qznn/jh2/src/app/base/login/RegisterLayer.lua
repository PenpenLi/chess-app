local C = class("RegisterLayer",BaseLayer)
RegisterLayer = C

C.RESOURCE_FILENAME = "base/RegisterLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	accountBg = {path="box_img.account_panel.bg_img"},
	codeBg = {path="box_img.code_panel.bg_img"},
	codeBtn = {path="box_img.code_panel.btn",events={{event="click",method="onClickCodeBtn"}}},
	codeLabel = {path="box_img.code_panel.btn.label"},
	passwordBg = {path="box_img.password_panel.bg_img"},
	passwordBg2 = {path="box_img.password_panel2.bg_img"},
	registerBtn = {path="box_img.register_btn",events={{event="click",method="onClickRegisterBtn"}}},
}

function C:onCreate( event )
	C.super.onCreate(self)

    self.accountEditBox = self:createEditBox("请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.accountBg:addChild(self.accountEditBox)

    self.codeEditBox = self:createEditBox("输入验证码",cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.codeEditBox:setContentSize(cc.size(216,56))
    local label = self.codeEditBox:getChildByTag(10000)
    label:setContentSize(cc.size(200,66))
    label:setPosition(cc.p(90,28))
    self.codeBg:addChild(self.codeEditBox)
	self.codeBtn:setEnabled(true)
	self.codeLabel:setVisible(false)

    self.passwordEditBox = self:createEditBox("6-12位英文/数字/点/减号/下划线",cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.passwordEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.passwordEditBox:setMaxLength(12)
    self.passwordBg:addChild(self.passwordEditBox)

    self.passwordEditBox2 = self:createEditBox("6-12位英文/数字/点/减号/下划线",cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.passwordEditBox2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.passwordEditBox2:setMaxLength(12)
    self.passwordBg2:addChild(self.passwordEditBox2)
end

function C:createEditBox( placeholder, inputMode )
    local bg = cc.Scale9Sprite:create("base/images/account_popup/scale9sprite.png")
    local editBox = ccui.EditBox:create(cc.size(390,56),bg,bg,bg)
    editBox:setAnchorPoint(cc.p(0,0.5))
    editBox:setPosition(cc.p(11,37))
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
    self.onRegisterSuccessHandler = handler(self,self.onRegisterSuccess)
    eventManager:on("BindPhoneSuccess", self.onRegisterSuccessHandler)
end

function C:onExit()
    self:stopTimer()
    eventManager:off("BindPhoneSuccess", self.onRegisterSuccessHandler)
    C.super.onExit(self)
end

function C:startTimer()
    self:stopTimer()
    self.codeBtn:setEnabled(false)
    self.codeLabel:setVisible(true)
    self.codeLabel:setString("30")
    local count = 30
    utils:createTimer("hall.REGISTER_GET_MSG_CODE",1,function()
        count = count - 1
        self.codeLabel:setString(tostring(count))
        if count <= 0 then
            self:stopTimer()
        end
    end)
end
function C:stopTimer()
    utils:removeTimer("hall.REGISTER_GET_MSG_CODE")
    self.codeBtn:setEnabled(true)
    self.codeLabel:setVisible(false)
end

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
    self:startTimer()
    eventManager:publish("RequestPhoneVerifyCode",phone,CONST_VERIFY_CODE_CHANGE_PWD)
end

function C:onClickRegisterBtn( event )
    local phone = self.accountEditBox:getText()
    local code = self.codeEditBox:getText()
    local p1 = self.passwordEditBox:getText()
    local p2 = self.passwordEditBox2:getText()

    if phone == nil or phone == "" then
        toastLayer:show("请输入手机号码")
        return
    end
    if string.match(phone,"[1][3,4,5,7,8,9]%d%d%d%d%d%d%d%d%d") ~= phone then
        toastLayer:show("请输入正确的手机号码")
        return
    end

    if p1 ~= p2 then
        toastLayer:show("两次输入的密码不一致")
        return
    end

    if p1 == nil or p1 == "" then
        toastLayer:show("请输入密码")
        return
    end

    if #p1 < 6 then
        toastLayer:show("密码长度不能小于6位")
        return
    end

    if code == nil or code == "" then
        toastLayer:show("请输入验证码")
        return
    end
    loadingLayer:show("正在注册...")
    eventManager:publish("BindPhone",phone,code,p1)
end

function C:onRegisterSuccess()
    -- loadingLayer:hide()
    self:hide()
    if dataManager.regsendmoney > 0 then
        local text = "注册正式账号成功，系统赠送您"..utils:moneyString(dataManager.regsendmoney).."金币"
        DialogLayer.new():show(text,function( isOk )
            utils:delayInvoke("hall.register.success",0.5,function()
                local particle = cc.ParticleSystemQuad:create("base/animation/particle/gold.plist")
                particle:setAutoRemoveOnFinish(true)
                particle:setPosition(display.cx,display.bottom+100)
                local currentScene = display.getRunningScene()
                if currentScene then
                    currentScene:addChild(particle)
                end               
            end)      
        end)      
        --self:hide()
     end
end

return RegisterLayer