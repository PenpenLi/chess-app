local C = class("YinhangkaLayer",BaseLayer)
YinhangkaLayer = C

-- C.RESOURCE_FILENAME = "base/YinhangkaLayer.csb"
C.RESOURCE_FILENAME = "base/YhkLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	bindTitleImg = {path="box_img.bind_title_img"},
	updateTitleImg = {path="box_img.update_title_img"},
	nameImg = {path="box_img.name_img"},
	accountImg = {path="box_img.account_img"},
	--bankTextField = {path="box_img.bank_img.textfield"},
	--bankSelectBtn = {path="box_img.bank_img.btn",events={{event="click",method="onClickBankSelectBtn"}}},
	--branchTextField = {path="box_img.branch_img.textfield"},
	bindBtn = {path="box_img.bind_btn",events={{event="click",method="onClickBindBtn"}}},
	updateBtn = {path="box_img.update_btn",events={{event="click",method="onClickUpdateBtn"}}},
	--listviewImg = {path="box_img.listview_img"},
	--listview = {path="box_img.listview_img.listview",events={{event="event",method="onEventListview"}}},
	--template = {path="template"},
}

-- C.BANK_LIST = { [1] = { ["id"] = 1, ["name"] = "中国银行" },
--                 [2] = { ["id"] = 2, ["name"] = "中国工商银行" },
--                 [3] = { ["id"] = 3, ["name"] = "中国建设银行" },
--                 [4] = { ["id"] = 4, ["name"] = "中国农业银行" },
--                 [5] = { ["id"] = 5, ["name"] = "招商银行" },
--                 [6] = { ["id"] = 6, ["name"] = "中信银行" },
--                 [7] = { ["id"] = 7, ["name"] = "交通银行" },
--                 [8] = { ["id"] = 8, ["name"] = "民生银行" },
--                 [9] = { ["id"] = 9, ["name"] = "华夏银行" },
--                 [10] = { ["id"] = 10, ["name"] = "广东发展银行" },
--                 [11] = { ["id"] = 11, ["name"] = "恒丰银行" },
--                 [12] = { ["id"] = 12, ["name"] = "兴业银行" },
--                 [13] = { ["id"] = 13, ["name"] = "光大银行" },
--                 [14] = { ["id"] = 14, ["name"] = "浦发银行" },
--                 [15] = { ["id"] = 15, ["name"] = "中国邮政储蓄银行" },
--                 [16] = { ["id"] = 16, ["name"] = "深圳发展银行" },
--                 [17] = { ["id"] = 17, ["name"] = "浙商银行" },
--                 [18] = { ["id"] = 18, ["name"] = "其它银行" } }
-- C.selectedIndex = 0

--绑定或者更改成功后回调
C.callback = nil

function C:onCreate()
	C.super.onCreate(self)
	self.bindTitleImg:setVisible(false)
	self.updateTitleImg:setVisible(false)

	self.nameEditBox = self:createEditBox("请输入持卡人姓名",cc.EDITBOX_INPUT_MODE_ANY)
	self.nameImg:addChild(self.nameEditBox)

	self.accountEditBox = self:createEditBox("请输入银行卡账号",cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.accountImg:addChild(self.accountEditBox)
	-- self.bankTextField:setPlaceHolderColor(PLACE_HOLDER_COLOR)
	-- self.branchTextField:setPlaceHolderColor(PLACE_HOLDER_COLOR)
	self.bindBtn:setVisible(false)
	self.updateBtn:setVisible(false)
	-- self.listview:removeAllItems()
	-- self.listviewImg:setVisible(false)
	-- self.template:setVisible(false)
	-- for i=1,#self.BANK_LIST do
	-- 	local bank = self.BANK_LIST[i]
	-- 	local item = self.template:clone()
	-- 	item:setVisible(true)
	-- 	item:setString(bank["name"])
	-- 	self.listview:pushBackCustomItem(item)
	-- end
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
	local hadBinding = false
	if dataManager.userInfo["BankAccountNum"] ~= nil and dataManager.userInfo["BankAccountNum"] ~= "" then
		hadBinding = true
	end
	self.updateTitleImg:setVisible(hadBinding)
	self.updateBtn:setVisible(hadBinding)
	self.bindTitleImg:setVisible(hadBinding==false)
	self.bindBtn:setVisible(hadBinding==false)
	self.onBindSuccessHandler = handler(self,self.onBindSuccess)
    eventManager:on("BindBankSuccess",self.onBindSuccessHandler)
end

function C:onExit()
	eventManager:off("BindBankSuccess",self.onBindSuccessHandler)
	C.super.onExit(self)
end

-- function C:onClickBankSelectBtn( event )
-- 	if self.listviewImg:isVisible() then
-- 		self.listviewImg:setVisible(false)
-- 		self.bankSelectBtn:setRotation(0)
-- 	else
-- 		self.listviewImg:setVisible(true)
-- 		self.bankSelectBtn:setRotation(180)
-- 	end
-- end

-- function C:onEventListview( event )
-- 	printInfo("=====onEventListview:==="..tostring(event.name))
-- 	if event.name == "ON_SELECTED_ITEM_END" then
-- 		self.selectedIndex = self.listview:getCurSelectedIndex()+1
-- 		printInfo("=======onEventListview:"..tostring(self.selectedIndex))
-- 		local text = self.BANK_LIST[self.selectedIndex]["name"]
-- 		self.bankTextField:setString(text)
-- 		self.listviewImg:setVisible(false)
-- 	end
-- end

function C:onClickBindBtn( event )
	local account, name = self:checkInput()
	if account and name then
		--绑定银行卡
		eventManager:publish("BindBank",account,name)
	end
end

function C:onClickUpdateBtn( event )
	local account, name = self:checkInput()
	if account and name then
		--更换银行卡
		eventManager:publish("BindBank",account,name)
	end
end

function C:checkInput()
	local name = self.nameEditBox:getText()
	if name == nil or name == "" then
		toastLayer:show("请输入持卡人姓名")
		return nil, nil
	end
	local account = self.accountEditBox:getText()
	if account == nil or account == "" then
		toastLayer:show("请输入银行卡账号")
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

return YinhangkaLayer