local C = class("ZhifubaoLayer",BaseLayer)
ZhifubaoLayer = C

C.RESOURCE_FILENAME = "base/ZhifubaoLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	bindTitleImg = {path="box_img.bind_title_img"},
	updateTitleImg = {path="box_img.update_title_img"},
	accountImg = {path="box_img.account_img"},
	nameImg = {path="box_img.name_img"},
	bindBtn = {path="box_img.bind_btn",events={{event="click",method="onClickBindBtn"}}},
	updateBtn = {path="box_img.update_btn",events={{event="click",method="onClickUpdateBtn"}}},
}

--绑定或者修改成功才调
C.callback = nil

function C:onCreate()
	C.super.onCreate(self)

	self.accountEditBox = self:createEditBox("邮箱/手机号",cc.EDITBOX_INPUT_MODE_EMAILADDR)
	self.accountImg:addChild(self.accountEditBox)

	self.nameEditBox = self:createEditBox("支付宝实名制姓名",cc.EDITBOX_INPUT_MODE_ANY)
	self.nameImg:addChild(self.nameEditBox)
end

function C:createEditBox( placeholder, inputMode )
	local bg = cc.Scale9Sprite:create("base/images/account_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(480,50),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(0,25))
	editBox:setFontSize(26)
	editBox:setFontColor(cc.c3b(255,255,255))
	editBox:setInputMode(inputMode)
	editBox:setMaxLength(128)
	local label = ccui.Text:create()
	label:setFontSize(26)
	label:setString(placeholder)
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(350,66))
	label:setPosition(cc.p(175,25))
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
	--是否已绑定支付宝
	local hadBinding = false
	if dataManager.userInfo["zhifubao"] ~= nil and dataManager.userInfo["zhifubao"] ~= "" then
		hadBinding = true
	end
	self.updateTitleImg:setVisible(hadBinding)
	self.updateBtn:setVisible(hadBinding)
	self.bindTitleImg:setVisible(hadBinding==false)
	self.bindBtn:setVisible(hadBinding==false)
	self.onBindSuccessHandler = handler(self,self.onBindSuccess)
    eventManager:on("BindAlipaySuccess",self.onBindSuccessHandler)
end

function C:onExit()
	eventManager:off("BindAlipaySuccess",self.onBindSuccessHandler)
	C.super.onExit(self)
end

function C:onClickBindBtn( event )
	local account, name = self:checkInput()
	if account and name then
		loadingLayer:show("正在处理...")
		eventManager:publish("BindAlipay",account,name)
	end
end

function C:onClickUpdateBtn( event )
	local account, name = self:checkInput()
	if account and name then
		loadingLayer:show("正在处理...")
		eventManager:publish("BindAlipay",account,name)
	end
end

function C:checkInput()
	local account = self.accountEditBox:getText()
	if account == nil or account == "" then
		toastLayer:show("请输入支付宝账号")
		return nil, nil
	end
	local name = self.nameEditBox:getText()
	if name == nil or name == "" then
		toastLayer:show("请输入实名制姓名")
		return nil, nil
	end
	return account, name
end

function C:onBindSuccess(account,name)
	loadingLayer:hide()
    if self.callback then
		self.callback()
	end
    self:hide()
end

return ZhifubaoLayer