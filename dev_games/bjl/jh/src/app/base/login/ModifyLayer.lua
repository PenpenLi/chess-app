local C = class("ModifyLayer",BaseLayer)
ModifyLayer = C

C.RESOURCE_FILENAME = "base/ModifyLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
    passwordBg = {path="box_img.password_panel_1.bg_img"},
	passwordBg2 = {path="box_img.password_panel_2.bg_img"},
	passwordBg3 = {path="box_img.password_panel_3.bg_img"},
	resetBtn = {path="box_img.reset_btn",events={{event="click",method="onClickResetBtn"}}},
}

function C:onCreate( event )
	C.super.onCreate(self)

    self.passwordEditBox = self:createEditBox()
    self.passwordBg:addChild(self.passwordEditBox)

    self.passwordEditBox2 = self:createEditBox()
    self.passwordBg2:addChild(self.passwordEditBox2)

    self.passwordEditBox3 = self:createEditBox()
    self.passwordBg3:addChild(self.passwordEditBox3)
end

function C:createEditBox()
    local bg = cc.Scale9Sprite:create("base/images/account_popup/scale9sprite.png")
    local editBox = ccui.EditBox:create(cc.size(390,56),bg,bg,bg)
    editBox:setAnchorPoint(cc.p(0,0.5))
    editBox:setPosition(cc.p(11,37))
    editBox:setFontSize(22)
    editBox:setFontColor(cc.c3b(255,255,255))
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editBox:setMaxLength(12)
    local label = ccui.Text:create()
    label:setFontSize(22)
    label:setString("5-12位英文/数字/点/减号/下划线")
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
    --修改密码回调
    self.onModifySuccessHandler = handler(self,self.onResetSuccess)
    eventManager:on("ChangePasswordSuccess", self.onModifySuccessHandler)
end

function C:hide()
    eventManager:off("ChangePasswordSuccess", self.onModifySuccessHandler)
    C.super.hide(self)
end

--点击修改密码
function C:onClickResetBtn( event )
    local p1 = self.passwordEditBox:getText()
    local p2 = self.passwordEditBox2:getText()
    local p3 = self.passwordEditBox3:getText()

    if p1 == nil or p1 == "" then
        toastLayer:show("请输入旧密码")
        return
    end

    if p2 == nil or p2 == "" then
        toastLayer:show("请输入新密码")
        return
    end

    if p3 == nil or p3 == "" then
        toastLayer:show("请确认新密码")
        return
    end

    if p2 ~= p3 then
        toastLayer:show("两次输入的密码不一致")
        return
    end

    if #p1 < 6 or #p2 < 6 then
        toastLayer:show("密码长度不能小于6位")
        return
    end
    --修改密码
    eventManager:publish("ChangePassword",p1,p2)
end

function C:onResetSuccess()
    eventManager:off("ChangePasswordSuccess", self.onModifySuccessHandler)
    self:hide()
end

return ModifyLayer