local C = class("ExchangeLayer",BaseLayer)
ExchangeLayer = C

C.RESOURCE_FILENAME = "base/ExchangeLayer.csb"
C.RESOURCE_BINDING = {
	--关闭按钮
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	--银行卡tab按钮
	yhkTabBtn = {path="box_img.yhk_tab_btn",events={{event="click",method="onClickYhkTabBtn"}}},
	--支付宝tab按钮
	zfbTabBtn = {path="box_img.zfb_tab_btn",events={{event="click",method="onClickZfbTabBtn"}}},

	--银行卡面板
	yhkPanel = {path="box_img.yhk_panel"},
	--余额
	yhkBlanceLabel = {path="box_img.yhk_panel.top_img.coin_label"},
	--兑换记录按钮
	yhkRecordBtn = {path="box_img.yhk_panel.top_img.record_btn",events={{event="click",method="onClickYhkRecordBtn"}}},
	--兑换说明
	yhkDescLabel = {path="box_img.yhk_panel.top_img.desc_label"},
	--
	yhkCenterImg = {path="box_img.yhk_panel.center_img"},
	--清空输入框按钮
	yhkClearBtn = {path="box_img.yhk_panel.center_img.clear_btn",events={{event="click",method="onClickYhkClearBtn"}}},
	--滑块
	yhkSlider = {path="box_img.yhk_panel.center_img.progress_node.slider",events={{event="event",method="onEventYhkSlider"}}},
	--最大按钮
	yhkMaxBtn = {path="box_img.yhk_panel.center_img.progress_node.max_btn",events={{event="click",method="onClickYhkMaxBtn"}}},
	--滑块百分比背景
	yhkTipsImg = {path="box_img.yhk_panel.center_img.progress_node.tips_img"},
	--滑块百分比文本
	yhkTipsLabel = {path="box_img.yhk_panel.center_img.progress_node.tips_img.label"},
	--银行卡账号文本
	yhkAccountLabel = {path="box_img.yhk_panel.bottom_img.label"},
	--绑定银行卡
	yhkBindBtn = {path="box_img.yhk_panel.bottom_img.bind_btn",events={{event="click",method="onClickYhkBindBtn"}}},
	--更换银行卡
	yhkUpdateBtn = {path="box_img.yhk_panel.bottom_img.update_btn",events={{event="click",method="onClickYhkUpdateBtn"}}},
	--银行卡兑换按钮
	yhkExchangeBtn = {path="box_img.yhk_panel.exchange_btn",events={{event="click",method="onClickYhkExchangeBtn"}}},

	--支付宝面板
	zfbPanel = {path="box_img.zfb_panel"},
	--余额
	zfbBlanceLabel = {path="box_img.zfb_panel.top_img.coin_label"},
	--兑换记录按钮
	zfbRecordBtn = {path="box_img.zfb_panel.top_img.record_btn",events={{event="click",method="onClickZfbRecordBtn"}}},
	--兑换说明
	zfbDescLabel = {path="box_img.zfb_panel.top_img.desc_label"},
	--兑换输入框
	zfbCenterImg = {path="box_img.zfb_panel.center_img"},
	--清空输入框
	zfbClearBtn = {path="box_img.zfb_panel.center_img.clear_btn",events={{event="click",method="onClickZfbClearBtn"}}},
	--滑块
	zfbSlider = {path="box_img.zfb_panel.center_img.progress_node.slider",events={{event="event",method="onEventZfbSlider"}}},
	--最大
	zfbMaxBtn = {path="box_img.zfb_panel.center_img.progress_node.max_btn",events={{event="click",method="onClickZfbMaxBtn"}}},
	--滑块百分比背景
	zfbTipsImg = {path="box_img.zfb_panel.center_img.progress_node.tips_img"},
	--滑块百分比文本
	zfbTipsLabel = {path="box_img.zfb_panel.center_img.progress_node.tips_img.label"},
	--账号文本
	zfbAccountLabel = {path="box_img.zfb_panel.bottom_img.label"},
	--绑定支付宝按钮
	zfbBindBtn = {path="box_img.zfb_panel.bottom_img.bind_btn",events={{event="click",method="onClickZfbBindBtn"}}},
	--更换支付宝按钮
	zfbUpdateBtn = {path="box_img.zfb_panel.bottom_img.update_btn",events={{event="click",method="onClickZfbUpdateBtn"}}},
	--支付宝兑换按钮
	zfbExchangeBtn = {path="box_img.zfb_panel.exchange_btn",events={{event="click",method="onClickZfbExchangeBtn"}}},
}

--当前余额金币
C.blanceCoin = 0

function C:onCreate()
	C.super.onCreate(self)

	self.yhkBlanceLabel:setString("")
	self.yhkEditBox = self:createEditBox(handler(self,self["onYhkEditHandler"]))
	self.yhkCenterImg:addChild(self.yhkEditBox)
	self.yhkDescLabel:setString(dataManager.bankextips)
	self.yhkTipsImg:setVisible(false)

	self.zfbBlanceLabel:setString("")
	self.zfbEditBox = self:createEditBox(handler(self,self["onZfbEditHandler"]))
	self.zfbCenterImg:addChild(self.zfbEditBox)
	self.zfbDescLabel:setString(dataManager.agentextips)
	self.zfbTipsImg:setVisible(false)
end

function C:createEditBox(handler)
	local bg = cc.Scale9Sprite:create("base/images/service_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(380,40),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(164,108))
	editBox:setFontSize(26)
	editBox:setFontColor(INPUT_COLOR)
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	editBox:setMaxLength(9)
	local label = ccui.Text:create()
	label:setFontSize(24)
	label:setString("输入或拖选兑换金额")
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setAnchorPoint(cc.p(0,0.5))
	label:setTag(10000)
	label:setContentSize(cc.size(240,40))
	label:setPosition(cc.p(10,19))
	editBox:addChild(label)
	editBox:onEditHandler(handler)
	return editBox
end

function C:show()
	C.super.show(self)
	self.blanceCoin = tonumber(dataManager.userInfo["money"])
	self:onClickYhkTabBtn()

    self.onExchangeSuccessHandler = handler(self,self.onExchangeSuccess)
    eventManager:on("ExchangeSuccess",self.onExchangeSuccessHandler)
    self.onMoneyChangeHandler = handler(self,self.onMoneyChange)
    eventManager:on("Money",self.onMoneyChangeHandler)
end

--点击银行卡tab
function C:onClickYhkTabBtn( event )
	self.yhkTabBtn:setEnabled(false)
	self.zfbTabBtn:setEnabled(true)
	self.yhkPanel:setVisible(true)
	self.zfbPanel:setVisible(false)

	local blanceStr = utils:moneyString(self.blanceCoin,2)
	self.yhkBlanceLabel:setString(blanceStr)

	self.yhkEditBox:setText("")
	self.yhkEditBox:getChildByTag(10000):setVisible(true)
	self.yhkSlider:setPercent(0)
	self.yhkTipsImg:setPosition(cc.p(-15,16))
	self.yhkTipsLabel:setString("0%")

	--是否已绑定银行卡
	if dataManager.userInfo["BankAccountNum"] ~= nil and dataManager.userInfo["BankAccountNum"] ~= "" then
		self.yhkAccountLabel:setString(dataManager.userInfo["BankAccountNum"])
		self.yhkAccountLabel:setTextColor(cc.c4b(26,26,26,255))
		self.yhkBindBtn:setVisible(false)
		self.yhkUpdateBtn:setVisible(true)
	else
		self.yhkAccountLabel:setString("未绑定银行卡账号")
		self.yhkAccountLabel:setTextColor(cc.c4b(77,77,77,255))
		self.yhkBindBtn:setVisible(true)
		self.yhkUpdateBtn:setVisible(false)
	end
end

--点击支付宝tab
function C:onClickZfbTabBtn( event )
	self.yhkTabBtn:setEnabled(true)
	self.zfbTabBtn:setEnabled(false)
	self.yhkPanel:setVisible(false)
	self.zfbPanel:setVisible(true)

	local blanceStr = utils:moneyString(self.blanceCoin,2)
	self.zfbBlanceLabel:setString(blanceStr)

	self.zfbEditBox:setText("")
	self.zfbEditBox:getChildByTag(10000):setVisible(true)
	self.zfbSlider:setPercent(0)
	self.zfbTipsImg:setPosition(cc.p(-15,16))
	self.zfbTipsLabel:setString("0%")

	--是否已绑定支付宝
	if dataManager.userInfo["zhifubao"] ~= nil and dataManager.userInfo["zhifubao"] ~= "" then
		self.zfbAccountLabel:setString(dataManager.userInfo["zhifubao"])
		self.zfbAccountLabel:setTextColor(cc.c4b(26,26,26,255))
		self.zfbBindBtn:setVisible(false)
		self.zfbUpdateBtn:setVisible(true)
	else
		self.zfbAccountLabel:setString("未绑定支付宝账号")
		self.zfbAccountLabel:setTextColor(cc.c4b(77,77,77,255))
		self.zfbBindBtn:setVisible(true)
		self.zfbUpdateBtn:setVisible(false)
	end
end

--点击支付宝兑换记录，弹web
function C:onClickZfbRecordBtn( event )
	--用户ID&密码
	local userId = dataManager:getPlayerId()
	local password = dataManager:getRandomCer()
    print("password:"..tostring(password))
	--serverlist 里面的publicurl
	local publicurl = dataManager.exchangeLogUrl
	--zfbpath 
	local zfbpath = DEFAULT_ALIPAY_EXCHANGELOG
	local url = string.format(publicurl..zfbpath,userId,password)
    print(url)
	webLayer:show(url)
end

--点击银行卡兑换记录，弹web
function C:onClickYhkRecordBtn( event )
	--用户ID&密码
	local userId = dataManager:getPlayerId()
	local password = dataManager:getRandomCer()
	--serverlist 里面的publicurl
	local publicurl = dataManager.exchangeLogUrl
	--银行卡路径 
	local zfbpath = DEFAULT_BANK_EXCHANGELOG
	local url = string.format(publicurl..zfbpath,userId,password)
    print(url)
	webLayer:show(url,true)
end

--银行卡
--滑块变化
function C:yhkSliderChanged( percent )
	local money = math.floor((self.blanceCoin-10*MONEY_SCALE) * (percent/100) / MONEY_SCALE) * MONEY_SCALE
	if money < 0 then
		money = 0
	end
	local moneyStr = utils:moneyString(money,0)
	self.yhkEditBox:setText(moneyStr)
	self.yhkEditBox:getChildByTag(10000):setVisible(false)
	self:yhkSetMoneyAndPercent(money,percent)
end

--输入框变化
function C:yhkInputChanged( money )
	money = money*MONEY_SCALE
	if money > self.blanceCoin then
		money = self.blanceCoin
		self.yhkEditBox:setText(utils:moneyString(money,0))
	end
	local percent = money/(self.blanceCoin-10*MONEY_SCALE)*100
	self.yhkSlider:setPercent(percent)
	self:yhkSetMoneyAndPercent(money,percent)
end

--设置金币和滑块百分比
function C:yhkSetMoneyAndPercent( money, percent )
	local x = self.yhkSlider:getContentSize().width * percent / 100
	self.yhkTipsImg:setPosition(cc.p(x-15,self.yhkTipsImg:getPositionY()))
	self.yhkTipsLabel:setString(string.format("%0.0f%%",percent))
	local blanceStr = utils:moneyString(self.blanceCoin-money,2)
	self.yhkBlanceLabel:setString(blanceStr)
	--播放动画
	self:yhkPlayAni()
end

--播放金币变化动画
function C:yhkPlayAni()
	self.yhkTipsImg:stopAllActions()
	self.yhkTipsImg:setVisible(true)
	self.yhkTipsImg:setOpacity(255)
	self.yhkTipsImg:runAction(transition.sequence({
		cc.FadeOut:create(1),
	}))
end

--输入框
function C:onYhkEditHandler( event )
	if event.name == "began" then
		local l = event.target:getChildByTag(10000)
		l:setVisible(false)
	elseif event.name == "ended" then
		if event.target:getText() == nil or event.target:getText() == "" then
			local l = event.target:getChildByTag(10000)
			l:setVisible(true)
		end
	elseif event.name == "changed" then
		local str = self.yhkEditBox:getText()
		if str == nil or str == "" then
			self:yhkInputChanged(0)
			return
		end
		local money = tonumber(str)
		if money == nil then
			money = 0
		end
		money = math.floor(money)
		if 0 < money and money*MONEY_SCALE > self.blanceCoin-10*MONEY_SCALE then
			money = (self.blanceCoin-10*MONEY_SCALE)/MONEY_SCALE
			toastLayer:show("达到最大可兑换金额，对话后账号上至少保留10元")
		end
		if money < 0 then
			money = 0
		end
		self.yhkEditBox:setText(tostring(money))
		self:yhkInputChanged(money)
	end
end

function C:onClickYhkClearBtn( event )
	self.yhkEditBox:setText("")
	self.yhkEditBox:getChildByTag(10000):setVisible(true)
	self:yhkInputChanged(0)
end

function C:onEventYhkSlider( event )
	local percent = self.yhkSlider:getPercent()
	self:yhkSliderChanged(percent)
end

function C:onClickYhkMaxBtn( event )
	self.yhkSlider:setPercent(100)
	self:yhkSliderChanged(100)
end

function C:onClickYhkBindBtn( event )
	local layer = YinhangkaLayer.new()
	layer.callback = function()
		self.yhkAccountLabel:setString(dataManager.userInfo["BankAccountNum"])
		self.yhkBindBtn:setVisible(false)
		self.yhkUpdateBtn:setVisible(true)
	end
	layer:show()
end

function C:onClickYhkUpdateBtn( event )
	local layer = YinhangkaLayer.new()
	layer.callback = function()
		self.yhkAccountLabel:setString(dataManager.userInfo["BankAccountNum"])
		self.yhkBindBtn:setVisible(false)
		self.yhkUpdateBtn:setVisible(true)
	end
	layer:show()
end

--点击银行卡兑换
function C:onClickYhkExchangeBtn( event )
	local money = tonumber(self.yhkEditBox:getText())
	if money == nil or money == 0 then
		toastLayer:show("请输入有效金额")
		return
	end
	if dataManager.userInfo["BankAccountNum"] == nil or dataManager.userInfo["BankAccountNum"] == "" then
		toastLayer:show("请先绑定银行卡")
		return
	end
	if money < 100 then
		toastLayer:show("兑换最小额度100元，至少保留10元")
		return
	end
	eventManager:publish("Exchange",money,CONST_EXCHANGE_BANK)
end

--支付宝
--滑块变化
function C:zfbSliderChanged( percent )
	local money = math.floor((self.blanceCoin-10*MONEY_SCALE) * (percent/100) / MONEY_SCALE) * MONEY_SCALE
	if money < 0 then
		money = 0
	end
	local moneyStr = utils:moneyString(money,0)
	self.zfbEditBox:setText(moneyStr)
	self.zfbEditBox:getChildByTag(10000):setVisible(false)
	self:zfbSetMoneyAndPercent(money,percent)
end

--输入框变化
function C:zfbInputChanged( money )
	money = money*MONEY_SCALE
	if money > self.blanceCoin then
		money = self.blanceCoin
		self.zfbEditBox:setText(utils:moneyString(money,0))
	end
	local percent = money/(self.blanceCoin-10*MONEY_SCALE)*100
	self.zfbSlider:setPercent(percent)
	self:zfbSetMoneyAndPercent(money,percent)
end

--设置金币和滑块百分比
function C:zfbSetMoneyAndPercent( money, percent )
	local x = self.zfbSlider:getContentSize().width * percent / 100
	self.zfbTipsImg:setPosition(cc.p(x-15,self.zfbTipsImg:getPositionY()))
	self.zfbTipsLabel:setString(string.format("%0.0f%%",percent))
	local blanceStr = utils:moneyString(self.blanceCoin-money,2)
	self.zfbBlanceLabel:setString(blanceStr)
	--播放动画
	self:zfbPlayAni()
end

--播放金币变化动画
function C:zfbPlayAni()
	self.zfbTipsImg:stopAllActions()
	self.zfbTipsImg:setVisible(true)
	self.zfbTipsImg:setOpacity(255)
	self.zfbTipsImg:runAction(transition.sequence({
		cc.FadeOut:create(1),
	}))
end

--输入框
function C:onZfbEditHandler( event )
	if event.name == "began" then
		local l = event.target:getChildByTag(10000)
		l:setVisible(false)
	elseif event.name == "ended" then
		if event.target:getText() == nil or event.target:getText() == "" then
			local l = event.target:getChildByTag(10000)
			l:setVisible(true)
		end
	elseif event.name == "changed" then
		local str = self.zfbEditBox:getText()
		if str == nil or str == "" then
			self:zfbInputChanged(0)
			return
		end
		local money = tonumber(str)
		if money == nil then
			money = 0
		end
		money = math.floor(money)
		if 0 < money and money*MONEY_SCALE > self.blanceCoin-10*MONEY_SCALE then
			money = (self.blanceCoin-10*MONEY_SCALE)/MONEY_SCALE
			toastLayer:show("达到最大可兑换金额，对话后账号上至少保留10元")
		end
		if money < 0 then
			money = 0
		end
		self.zfbEditBox:setText(tostring(money))
		self:zfbInputChanged(money)
	end
end

function C:onClickZfbClearBtn( event )
	self.zfbEditBox:setText("")
	self.zfbEditBox:getChildByTag(10000):setVisible(true)
	self:zfbInputChanged(0)
end

function C:onEventZfbSlider( event )
	local percent = self.zfbSlider:getPercent()
	self:zfbSliderChanged(percent)
end

function C:onClickZfbMaxBtn( event )
	self.zfbSlider:setPercent(100)
	self:zfbSliderChanged(100)
end

function C:onClickZfbBindBtn( event )
	local layer = ZhifubaoLayer.new()
	layer.callback = function()
		self.zfbAccountLabel:setString(dataManager.userInfo["zhifubao"])
		self.zfbBindBtn:setVisible(false)
		self.zfbUpdateBtn:setVisible(true)
	end
	layer:show()
end

function C:onClickZfbUpdateBtn( event )
	local layer = ZhifubaoLayer.new()
	layer.callback = function()
		self.zfbAccountLabel:setString(dataManager.userInfo["zhifubao"])
		self.zfbBindBtn:setVisible(false)
		self.zfbUpdateBtn:setVisible(true)
	end
	layer:show()
end

--点击支付宝兑换
function C:onClickZfbExchangeBtn( event )
	local money = tonumber(self.zfbEditBox:getText())
	if money == nil or money <= 0 then
		toastLayer:show("请输入有效金额")
		return
	end
	if dataManager.userInfo["zhifubao"] == nil or dataManager.userInfo["zhifubao"] == "" then
		toastLayer:show("请先绑定支付宝账号")
		return
    end
	if money < 100 then
		toastLayer:show("兑换最小额度100元，至少保留10元")
		return
	end
	loadingLayer:show("正在兑换...")
	eventManager:publish("Exchange",money,CONST_EXCHANGE_ALIPAY)
end

function C:onMoneyChange(money)
    self.blanceCoin = money
    local blanceStr = utils:moneyString(money,2)
	self.zfbBlanceLabel:setString(blanceStr)
	self.yhkBlanceLabel:setString(blanceStr)
end

function C:onExchangeSuccess(money)
    loadingLayer:hide()
    self:onClickYhkClearBtn()
    self:onClickZfbClearBtn()
end

function C:onExit()
    eventManager:off("ExchangeSuccess",self.onExchangeSuccessHandler)
    eventManager:off("Money",self.onMoneyChangeHandler)
    self.super.onExit(self)
end

return ExchangeLayer