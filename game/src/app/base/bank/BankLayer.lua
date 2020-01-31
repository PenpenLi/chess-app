local C = class("BankLayer",BaseLayer)
BankLayer = C

C.RESOURCE_FILENAME = "base/BankLayer.csb"
C.RESOURCE_BINDING = {
	--关闭按钮
	closeBtn = {path="box_img.close_btn",events={{event="click",method="OnBack"}}},
	--存入tab按钮
	cunruTabBtn = {path="box_img.cunru_tab_btn",events={{event="click",method="onClickCunruTabBtn"}}},
	--取出tab按钮
	quchuTabBtn = {path="box_img.quchu_tab_btn",events={{event="click",method="onClickQuchuTabBtn"}}},
	--当前余额文本
	blanceLabel = {path="box_img.info_img.blance_label"},
	--当前保险箱余额文本
	bankLabel = {path="box_img.info_img.bank_label"},
	--余额文本右边箭头图标
	--arrowUpImg = {path="box_img.info_img.arrow_up_img"},
	--保险箱余额文本右边箭头图标
	--arrowDownImg = {path="box_img.info_img.arrow_down_img"},
	--输入框node
	inputNode = {path="box_img.input_node"},
	--存入输入框背景
	inputCunruImg = {path="box_img.input_node.cunru_img"},
	--取出输入框背景
	inputQuchuImg = {path="box_img.input_node.quchu_img"},
	--清除输入框
	inputClearBtn = {path="box_img.input_node.clear_btn",events={{event="click",method="onClickInputClearBtn"}}},
	--拖选金额滑块
	slider = {path="box_img.progress_node.slider",events={{event="event",method="onEventSlider"}}},
	--最大按钮
	maxBtn = {path="box_img.progress_node.max_btn",events={{event="click",method="onClickMaxBtn"}}},
	--百分比提示背景
	tipsImg = {path="box_img.progress_node.tips_img"},
	--百分比提示文本
	tipsLabel = {path="box_img.progress_node.tips_img.label"},
	--存入确定按钮
	cunruBtn = {path="box_img.cunru_btn",events={{event="click",method="onClickCunruBtn"}}},
	--取出确定按钮
	quchuBtn = {path="box_img.quchu_btn",events={{event="click",method="onClickQuchuBtn"}}},

    --存入按钮选中
    cunru_tab_s = {path="box_img.cunru_tab_s"},
    --取出按钮选中
    quchu_tab_s = {path="box_img.quchu_tab_s"},
}

--当前余额，未除以金币百分比
C.blanceCoin = 0
--保险箱余额
C.bankCoin = 0
--打开界面 2为取出
C.showIndex = 0

--创建初始化layer的时候调用
function C:onCreate()
	C.super.onCreate(self)
	self.cunruTabBtn:setEnabled(false)
	self.quchuTabBtn:setEnabled(true)
	--self.arrowUpImg:setVisible(false)
	--self.arrowDownImg:setVisible(false)
	self.blanceLabel:setString("")
	self.bankLabel:setString("")
	self.inputCunruImg:setVisible(true)
	self.inputQuchuImg:setVisible(false)
	self.inputEditBox = self:createEditBox(handler(self,self["onEditHandler"]))
	self.inputNode:addChild(self.inputEditBox)
	self.slider:setPercent(0)
	self.tipsImg:setVisible(false)
	self.tipsImg:setPosition(cc.p(0,18))
	self.tipsLabel:setString("0%")
end

function C:createEditBox(handler)
	local bg = cc.Scale9Sprite:create("base/images/service_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(326,48),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(-138,-18))
	editBox:setFontSize(26)
	editBox:setFontColor(cc.c3b(255,255,255))
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	editBox:setMaxLength(9)
	local label = ccui.Text:create()
	label:setFontSize(24)
	label:setString("输入或拖选存取金额")
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(340,48))
	label:setPosition(cc.p(170,23))
	editBox:addChild(label)
	editBox:onEditHandler(handler)
	return editBox
end

function C:onExit()
	eventManager:off("SaveMoneyResult",self.onCunruResultHandler)
    eventManager:off("GetMoneyResult",self.onQuchuResultHandler)
    eventManager:off("Money",self.onMoneyChangeHandler)
    eventManager:off("BankMoney",self.onBankMoneyChangeHandler)
    C.super.onExit(self)
end

--每次显示都会调用
function C:show(index)
	C.super.show(self)
	self.onCunruResultHandler = handler(self,self.onCunruResult)
	self.onQuchuResultHandler = handler(self,self.onQuchuResult)
	self.onMoneyChangeHandler = handler(self,self.onMoneyChange)
	self.onBankMoneyChangeHandler = handler(self,self.onBankMoneyChange)
    eventManager:on("SaveMoneyResult",self.onCunruResultHandler)
    eventManager:on("GetMoneyResult",self.onQuchuResultHandler)
    eventManager:on("Money",self.onMoneyChangeHandler)
    eventManager:on("BankMoney",self.onBankMoneyChangeHandler)
	self.blanceCoin = tonumber(dataManager.userInfo["money"])
	self.bankCoin = tonumber(dataManager.userInfo["walletmoney"])
	--显示默认选择存入tab
	if index == 2 then
		self:onClickQuchuTabBtn()
	else
		self:onClickCunruTabBtn()
	end
    self.showIndex = index
end

function C:OnBack( event )
    self:release()
    if self.showIndex == 2 then
        self:hide()
    else
	require("app.init")
	HallCore.new():run()
    end
end

--点击存入tab
function C:onClickCunruTabBtn( event )
    self.cunru_tab_s:setVisible(true)
    self.quchu_tab_s:setVisible(false)
	local blanceStr = utils:moneyString(self.blanceCoin,3)
	local bankStr = utils:moneyString(self.bankCoin,3)
	self.blanceLabel:setString(blanceStr)
	self.bankLabel:setString(bankStr)
	self.inputEditBox:setText("")
	self.inputEditBox:getChildByTag(10000):setVisible(true)
	self.inputCunruImg:setVisible(true)
	self.cunruBtn:setVisible(true)
	self.cunruTabBtn:setEnabled(false)
	self.inputQuchuImg:setVisible(false)
	self.quchuBtn:setVisible(false)
	self.quchuTabBtn:setEnabled(true)
	self.slider:setPercent(0)
	self.tipsImg:setPosition(cc.p(0,18))
	self.tipsLabel:setString("0%") 
--	self.arrowUpImg:loadTexture("base/images/bank_popup/bk_flag_less.png")
--	self.arrowDownImg:loadTexture("base/images/bank_popup/bk_flag_more.png")
end

--点击取出tab
function C:onClickQuchuTabBtn( event )
    self.cunru_tab_s:setVisible(false)
    self.quchu_tab_s:setVisible(true)
	local blanceStr = utils:moneyString(self.blanceCoin,3)
	local bankStr = utils:moneyString(self.bankCoin,3)
	self.blanceLabel:setString(blanceStr)
	self.bankLabel:setString(bankStr)
	self.inputEditBox:setText("")
	self.inputEditBox:getChildByTag(10000):setVisible(true)
	self.inputCunruImg:setVisible(false)
	self.cunruBtn:setVisible(false)
	self.cunruTabBtn:setEnabled(true)
	self.inputQuchuImg:setVisible(true)
	self.quchuBtn:setVisible(true)
	self.quchuTabBtn:setEnabled(false)
	self.slider:setPercent(0)
	self.tipsImg:setPosition(cc.p(0,18))
	self.tipsLabel:setString("0%")
--	self.arrowUpImg:loadTexture("base/images/bank_popup/bk_flag_more.png")
--	self.arrowDownImg:loadTexture("base/images/bank_popup/bk_flag_less.png")
end

--滑块变化
function C:sliderChanged( percent )
	local money = 0
	if self.cunruBtn:isVisible() then
		money = math.floor(self.blanceCoin * (percent/100) / MONEY_SCALE) * MONEY_SCALE
	else
		money = math.floor(self.bankCoin * (percent/100) / MONEY_SCALE) * MONEY_SCALE
	end
	local moneyStr = utils:moneyString(money,0)
	self.inputEditBox:setText(moneyStr)
	self.inputEditBox:getChildByTag(10000):setVisible(false)
	self:setMoneyAndPercent(money,percent)
end

--输入框变化
function C:inputChanged( money )
	money = money*MONEY_SCALE
	local percent = 0
	if self.cunruBtn:isVisible() then
		if money > self.blanceCoin then
			money = self.blanceCoin
			self.inputEditBox:setText(utils:moneyString(money,0))
		end
		percent = money/self.blanceCoin*100
	elseif self.quchuBtn:isVisible() then
		if money > self.bankCoin then
			money = self.bankCoin
			self.inputEditBox:setText(utils:moneyString(money,0))
		end
		percent = money/self.bankCoin*100
	end
	self.slider:setPercent(percent)
	self:setMoneyAndPercent(money,percent)
end

--设置金币和滑块百分比
function C:setMoneyAndPercent( money, percent )
	local x = self.slider:getContentSize().width * percent / 100
	self.tipsImg:setPosition(cc.p(x,self.tipsImg:getPositionY()))
	self.tipsLabel:setString(string.format("%0.0f%%",percent))
	local blanceStr = ""
	local bankStr = ""
	if self.cunruBtn:isVisible() then
		blanceStr = utils:moneyString(self.blanceCoin-money,3)
		bankStr = utils:moneyString(self.bankCoin+money,3)
	else
		blanceStr = utils:moneyString(self.blanceCoin+money,3)
		bankStr = utils:moneyString(self.bankCoin-money,3)
	end
	self.blanceLabel:setString(blanceStr)
	self.bankLabel:setString(bankStr)
	--播放动画
	self:playAni()
end

--播放金币变化动画
function C:playAni()
	self.tipsImg:stopAllActions()
	self.tipsImg:setVisible(true)
	self.tipsImg:setOpacity(255)
	self.tipsImg:runAction(transition.sequence({
		cc.FadeOut:create(1),
	}))
--	self.arrowUpImg:stopAllActions()
--	self.arrowDownImg:stopAllActions()
--	self.arrowUpImg:setVisible(true)
--	self.arrowDownImg:setVisible(true)
--	self.arrowUpImg:setOpacity(255)
--	self.arrowDownImg:setOpacity(255)
--	self.arrowUpImg:runAction(transition.sequence({
--		cc.FadeOut:create(1),
--	}))
--	self.arrowDownImg:runAction(transition.sequence({
--		cc.FadeOut:create(1),
--	}))
end

--输入框事件回调
function C:onEditHandler( event )
	if event.name == "began" then
		local l = event.target:getChildByTag(10000)
		l:setVisible(false)
	elseif event.name == "ended" then
		if event.target:getText() == nil or event.target:getText() == "" then
			local l = event.target:getChildByTag(10000)
			l:setVisible(true)
		end
	elseif event.name == "changed" then
		local str = self.inputEditBox:getText()
		if str == nil or str == "" then
			self:inputChanged(0)
			return
		end
		local money = tonumber(str)
		if money == nil then
			money = 0
		end
		money = math.floor(money)
		self.inputEditBox:setText(tostring(money))
		self:inputChanged(money)
	end
end

--滑块变化事件回调
function C:onEventSlider( event )
	local percent = self.slider:getPercent()
	self:sliderChanged(percent)
end

--点击清除输入框
function C:onClickInputClearBtn( event )
	self.inputEditBox:setText("")
	self.inputEditBox:getChildByTag(10000):setVisible(true)
	self:inputChanged(0)
end

--点击最大按钮
function C:onClickMaxBtn( event )
	self.slider:setPercent(100)
	self:sliderChanged(100)
	self.inputEditBox:getChildByTag(10000):setVisible(false)
end

--点击存入按钮，请求协议
function C:onClickCunruBtn( event )
	--实际面值金币（未乘以 MONEY_SCALE）
	local money = self:checkInputMoney()
	if money <= 0 then
		return
	end
	--发送协议，显示loading
	loadingLayer:show("正在处理...")
    eventManager:publish("SaveMoney",money)
end

function C:onCunruResult(result,msg)
    loadingLayer:hide()
    if result then
		toastLayer:show("操作成功！")
		self.blanceCoin = tonumber(dataManager.userInfo["money"])
		self.bankCoin = tonumber(dataManager.userInfo["walletmoney"])
		self.inputEditBox:setText("")
		self.inputEditBox:getChildByTag(10000):setVisible(true)
		self:inputChanged(0)
	else
		toastLayer:show("操作失败！")
	end
end

--点击取出按钮，请求协议
function C:onClickQuchuBtn( event )
	--实际面值金币（未乘以 MONEY_SCALE）
	local money = self:checkInputMoney()
	if money <= 0 then
		return
	end
	--发送协议，显示loading
	loadingLayer:show("正在处理...")
    eventManager:publish("GetMoney",money)
end

function C:onQuchuResult(result,msg)
    loadingLayer:hide()
    if result then
		toastLayer:show("操作成功！")
		self.blanceCoin = tonumber(dataManager.userInfo["money"])
		self.bankCoin = tonumber(dataManager.userInfo["walletmoney"])
		self.inputEditBox:setText("")
		self.inputEditBox:getChildByTag(10000):setVisible(true)
		self:inputChanged(0)
	else
		toastLayer:show("操作失败！")
	end
end

--检查并返回金额，返回0为无效金币
function C:checkInputMoney()
	local str = self.inputEditBox:getText()
	local money = tonumber(str)
	if money == nil or money == 0 then
		toastLayer:show("请输入有效存取金额！")
		return 0
	end
	return money
end

function C:onMoneyChange(money)
    self.blanceCoin = tonumber(money)
    blanceStr = utils:moneyString(self.blanceCoin,3)
    self.blanceLabel:setString(blanceStr)
end

function C:onBankMoneyChange(money)
    self.bankCoin = tonumber(money)
    bankStr = utils:moneyString(self.bankCoin,3)
    self.bankLabel:setString(bankStr)
end

return BankLayer