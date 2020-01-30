local C = class("RechargeLayer",BaseLayer)
RechargeLayer = C

C.RESOURCE_FILENAME = "base/RechargeLayer.csb"
C.RESOURCE_BINDING = {
	--关闭按钮
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},

	--tab滚动
	tabScrollview = {path="box_img.tab_scrollview"},
	--vip充值tab
	vipTabBtn = {path="box_img.tab_scrollview.vip_tab_btn",events={{event="click",method="onClickVipTabBtn"}}},
	--支付宝充值tab
	zfbTabBtn = {path="box_img.tab_scrollview.zfb_tab_btn",events={{event="click",method="onClickZfbTabBtn"}}},
	--微信充值tab
	wxTabBtn = {path="box_img.tab_scrollview.wx_tab_btn",events={{event="click",method="onClickWxTabBtn"}}},
	--银行卡充值tab
	unionTabBtn = {path="box_img.tab_scrollview.union_tab_btn",events={{event="click",method="onClickUnionTabBtn"}}},
	--支付宝定额充值tab
	zfbdTabBtn = {path="box_img.tab_scrollview.zfbd_tab_btn",events={{event="click",method="onClickZfbdTabBtn"}}},
	--QQ充值tab
	qqTabBtn = {path="box_img.tab_scrollview.qq_tab_btn",events={{event="click",method="onClickQqTabBtn"}}},
	--京东充值tab
	jdTabBtn = {path="box_img.tab_scrollview.jd_tab_btn",events={{event="click",method="onClickJdTabBtn"}}},

	--vip面板
	vipPanel = {path="box_img.vip_panel"},
	--支付宝面板
	zfbPanel = {path="box_img.zfb_panel"},
	--微信面板
	wxPanel = {path="box_img.wx_panel"},
	--银行卡面板
	unionPanel = {path="box_img.union_panel"},
	--支付宝定额面板
	zfbdPanel = {path="box_img.zfbd_panel"},
	--QQ面板
	qqPanel = {path="box_img.qq_panel"},
	--京东面板
	jdPanel = {path="box_img.jd_panel"},

	--vip面板loading文本
	vipLoadingLabel = {path="box_img.vip_panel.loading_label"},
	--vip面板无代理文本
	vipEmptyLabel = {path="box_img.vip_panel.empty_label"},
	--vip面板账号ID文本
	vipAccountLabel = {path="box_img.vip_panel.bottom_panel.account_img.label"},
	--vip面板复制ID按钮
	vipCopyBtn = {path="box_img.vip_panel.bottom_panel.copy_btn",events={{event="click",method="onClickVipCopyBtn"}}},

	--支付宝面板输入框
	zfbCenterImg = {path="box_img.zfb_panel.center_img"},
	--支付宝输入框清除按钮
	zfbClearBtn = {path="box_img.zfb_panel.center_img.clear_btn",events={{event="click",method="onClickZfbClearBtn"}}},
	--支付宝面板确定按钮
	zfbConfirmBtn = {path="box_img.zfb_panel.confirm_btn",events={{event="click",method="onClickZfbConfirmBtn"}}},

	--微信输入框
	wxCenterImg = {path="box_img.wx_panel.center_img"},
	--微信输入框清除按钮
	wxClearBtn = {path="box_img.wx_panel.center_img.clear_btn",events={{event="click",method="onClickWxClearBtn"}}},
	--微信确定按钮
	wxConfirmBtn = {path="box_img.wx_panel.confirm_btn",events={{event="click",method="onClickWxConfirmBtn"}}},

	--银行卡输入框
	unionCenterImg = {path="box_img.union_panel.center_img"},
	--银行卡输入框清除按钮
	unionClearBtn = {path="box_img.union_panel.center_img.clear_btn",events={{event="click",method="onClickUnionClearBtn"}}},
	--银行卡确定按钮
	unionConfirmBtn = {path="box_img.union_panel.confirm_btn",events={{event="click",method="onClickUnionConfirmBtn"}}},

	--QQ输入框
	qqCenterImg = {path="box_img.qq_panel.center_img"},
	--QQ输入框清除按钮
	qqClearBtn = {path="box_img.qq_panel.center_img.clear_btn",events={{event="click",method="onClickQqClearBtn"}}},
	--QQ确定按钮
	qqConfirmBtn = {path="box_img.qq_panel.confirm_btn",events={{event="click",method="onClickQqConfirmBtn"}}},

	--京东输入框
	jdCenterImg = {path="box_img.jd_panel.center_img"},
	--京东输入框清除按钮
	jdClearBtn = {path="box_img.jd_panel.center_img.clear_btn",events={{event="click",method="onClickJdClearBtn"}}},
	--京东确定按
	jdConfirmBtn = {path="box_img.jd_panel.confirm_btn",events={{event="click",method="onClickJdConfirmBtn"}}},

	--支付宝定额动画箭头
	zfbdArrowImg = {path="box_img.zfbd_panel.center_img.arrow_img"},
	--支付宝定额选择金额文本
	zfbdLabel = {path="box_img.zfbd_panel.center_img.label"},
	--支付宝确定按
	zfbdConfirmBtn = {path="box_img.zfbd_panel.confirm_btn",events={{event="click",method="onClickZfbdConfirmBtn"}}},
}

C.configsInfo = nil
C.vipInfoArr = nil
C.zfbMoneyArr = nil
C.wxMoneyArr = nil
C.unionMoneyArr = nil
C.zfbdMoneyArr = nil
C.qqMoneyArr = nil
C.jdMoneyArr = nil
C.zfbdArrowPos = nil

--创建充值页面，设置绑定面板按钮
function C:ctor()
	--vip item btns
	for i=1,6 do
		local key = string.format("vipItemBtn%d",i)
		local path = string.format("box_img.vip_panel.center_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickVipItemBtn"}}}
	end
	--zfb item btns
	for i=1,8 do
		local key = string.format("zfbItemBtn%d",i)
		local path = string.format("box_img.zfb_panel.center_img.btns_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickZfbItemBtn"}}}
	end
	--wx item btns
	for i=1,8 do
		local key = string.format("wxItemBtn%d",i)
		local path = string.format("box_img.wx_panel.center_img.btns_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickWxItemBtn"}}}
	end
	--union item btns
	for i=1,8 do
		local key = string.format("unionItemBtn%d",i)
		local path = string.format("box_img.union_panel.center_img.btns_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickUnionItemBtn"}}}
	end
	--zfbd item btns
	for i=1,12 do
		local key = string.format("zfbdItemBtn%d",i)
		local path = string.format("box_img.zfbd_panel.center_img.btns_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickZfbdItemBtn"}}}
	end
	--qq item btns
	for i=1,8 do
		local key = string.format("qqItemBtn%d",i)
		local path = string.format("box_img.qq_panel.center_img.btns_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickQqItemBtn"}}}
	end
	--jd item btns
	for i=1,8 do
		local key = string.format("jdItemBtn%d",i)
		local path = string.format("box_img.jd_panel.center_img.btns_panel.btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickJdItemBtn"}}}
	end
	C.super.ctor(self)
end

--初始化充值页面
function C:onCreate()
	C.super.onCreate(self)
	self.tabScrollview:setScrollBarEnabled(false)
	self:hideVipLoading()

	self.zfbInputEditBox = self:createEditBox()
	self.zfbCenterImg:addChild(self.zfbInputEditBox)

	self.wxInputEditBox = self:createEditBox()
	self.wxCenterImg:addChild(self.wxInputEditBox)

	self.unionInputEditBox = self:createEditBox()
	self.unionCenterImg:addChild(self.unionInputEditBox)

	self.zfbdLabel:setString("0元")

	self.qqInputEditBox = self:createEditBox()
	self.qqCenterImg:addChild(self.qqInputEditBox)

	self.jdInputEditBox = self:createEditBox()
	self.jdCenterImg:addChild(self.jdInputEditBox)

	self.zfbdArrowPos = cc.p(self.zfbdArrowImg:getPosition())
end

function C:createEditBox(handler)
	local bg = cc.Scale9Sprite:create("base/images/service_popup/scale9sprite.png")
	local editBox = ccui.EditBox:create(cc.size(364,40),bg,bg,bg)
	editBox:setAnchorPoint(cc.p(0,0.5))
	editBox:setPosition(cc.p(161,235))
	editBox:setFontSize(26)
	editBox:setFontColor(cc.c3b(255,255,255))
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	editBox:setMaxLength(9)
	local label = ccui.Text:create()
	label:setFontSize(24)
	label:setString("请输入充值金额")
	label:setTextColor(PLACE_HOLDER_COLOR)
	label:setTag(10000)
	label:setContentSize(cc.size(350,40))
	label:setPosition(cc.p(175,18))
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
			if event.target:getText() then
				local number = tonumber(event.target:getText())
				if number then
					event.target:setText(tonumber(number))
				end
			end
		end
	end)
	return editBox
end

--显示充值页面
function C:show(info)
	if not info then
		return
	end
	dump(info,"recharge")
	C.super.show(self)
	self.configsInfo = info
	self:sortTabBtns()
	self:initVipPanel()
	self:initZfbPanel()
	self:initWxPanel()
	self:initUnionPanel()
	self:initZfbdPanel()
	self:initQqPanel()
	self:initJdPanel()
    self.onVipInfoHandler = handler(self,self.onVipInfo)
    eventManager:on("AgentList",self.onVipInfoHandler)
end

--隐藏充值面板
function C:hide()
	self:hideVipLoading()
	self:stopArrowAni()

    eventManager:off("AgentList",self.onVipInfoHandler)

	C.super.hide(self)
end

--对tab按钮排序
function C:sortTabBtns()
	self.vipTabBtn:setVisible(false)
	self.zfbTabBtn:setVisible(false)
	self.wxTabBtn:setVisible(false)
	self.unionTabBtn:setVisible(false)
	self.zfbdTabBtn:setVisible(false)
	self.qqTabBtn:setVisible(false)
	self.jdTabBtn:setVisible(false)

	local vipPos = tonumber(self.configsInfo["Agentsort"])
	local zfbPos = tonumber(self.configsInfo["Alipay"])
	local wxPos = tonumber(self.configsInfo["WXPay"])
	local unionPos = tonumber(self.configsInfo["UnionPay"])
	local zfbdPos = tonumber(self.configsInfo["Alipayisquotasort"])
	local qqPos = tonumber(self.configsInfo["QQPay"])
	local jdPos = tonumber(self.configsInfo["JDPay"])

	local tempArr = {}
	if vipPos > 0 then
		table.insert(tempArr,{ key=0, value=vipPos })
	end
	if zfbPos > 0 then
		table.insert(tempArr,{ key=22, value=zfbPos })
	end
	if wxPos > 0 then
		table.insert(tempArr,{ key=30, value=wxPos })
	end
	if unionPos > 0 then
		table.insert(tempArr,{ key=31, value=unionPos })
	end
	if zfbdPos > 0 then
		table.insert(tempArr,{ key=36, value=zfbdPos })
	end
	if qqPos > 0 then
		table.insert(tempArr,{ key=32, value=qqPos })
	end
	if jdPos > 0 then
		table.insert(tempArr,{ key=33, value=jdPos })
	end
	table.sort(tempArr,function( a,b )
		return a.value < b.value
	end)

	local count = #tempArr
	local padding = 95
	local height = padding*count + 5
	if height < self.tabScrollview:getContentSize().height then
		height = self.tabScrollview:getContentSize().height
		self.tabScrollview:setBounceEnabled(false)
	else 
		self.tabScrollview:setBounceEnabled(true)
	end
	self.tabScrollview:setInnerContainerSize(cc.size(self.tabScrollview:getContentSize().width,height))

	local posY = height-100

	for i=1,count do
		local item = tempArr[i]
		if item.key == 0 then
			self.vipTabBtn:setVisible(true)
			self.vipTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickVipTabBtn()
			end
		elseif item.key == 22 then
			self.zfbTabBtn:setVisible(true)
			self.zfbTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickZfbTabBtn()
			end
		elseif item.key == 30 then
			self.wxTabBtn:setVisible(true)
			self.wxTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickWxTabBtn()
			end
		elseif item.key == 31 then
			self.unionTabBtn:setVisible(true)
			self.unionTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickUnionTabBtn()
			end
		elseif item.key == 36 then
			self.zfbdTabBtn:setVisible(true)
			self.zfbdTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickZfbdTabBtn()
			end
		elseif item.key == 32 then
			self.qqTabBtn:setVisible(true)
			self.qqTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickQqTabBtn()
			end
		elseif item.key == 33 then
			self.jdTabBtn:setVisible(true)
			self.jdTabBtn:setPositionY(posY)
			if i == 1 then
				self:onClickJdTabBtn()
			end
		end
		posY = posY-padding
	end
end

--选择vip
function C:onClickVipTabBtn( event )
	self:showTabPanel(1)
end

--选择支付宝
function C:onClickZfbTabBtn( event )
	self:showTabPanel(2)
end

--选择微信
function C:onClickWxTabBtn( event )
	self:showTabPanel(3)
end

--选择银行卡
function C:onClickUnionTabBtn( event )
	self:showTabPanel(4)
end

--选择支付宝定额
function C:onClickZfbdTabBtn( event )
	self:showTabPanel(5)
end

--选择QQ
function C:onClickQqTabBtn( event )
	self:showTabPanel(6)
end

--选择京东
function C:onClickJdTabBtn( event )
	self:showTabPanel(7)
end

--显示选择的面板
function C:showTabPanel( index )
	--vip
	self.vipPanel:setVisible(index==1)
	self.vipTabBtn:setEnabled(index~=1)
	if self.vipPanel:isVisible() then
		self:loadVipInfo()
	end

	--支付宝
	self.zfbPanel:setVisible(index==2)
	self.zfbTabBtn:setEnabled(index~=2)
	self.zfbInputEditBox:setText("")
	self.zfbInputEditBox:getChildByTag(10000):setVisible(true)

	--微信
	self.wxPanel:setVisible(index==3)
	self.wxTabBtn:setEnabled(index~=3)
	self.wxInputEditBox:setText("")
	self.wxInputEditBox:getChildByTag(10000):setVisible(true)

	--银行卡
	self.unionPanel:setVisible(index==4)
	self.unionTabBtn:setEnabled(index~=4)
	self.unionInputEditBox:setText("")
	self.unionInputEditBox:getChildByTag(10000):setVisible(true)

	--支付宝定额
	self.zfbdPanel:setVisible(index==5)
	self.zfbdTabBtn:setEnabled(index~=5)
	self.zfbdLabel:setString("0元")
	if self.zfbdPanel:isVisible() then
		self:playArrowAni()
	else
		self:stopArrowAni()
	end

	--QQ
	self.qqPanel:setVisible(index==6)
	self.qqTabBtn:setEnabled(index~=6)
	self.qqInputEditBox:setText("")
	self.qqInputEditBox:getChildByTag(10000):setVisible(true)

	--京东
	self.jdPanel:setVisible(index==7)
	self.jdTabBtn:setEnabled(index~=7)
	self.jdInputEditBox:setText("")
	self.jdInputEditBox:getChildByTag(10000):setVisible(true)
end

--vip充值
function C:initVipPanel()
	self.vipAccountLabel:setString(tostring(dataManager.playerId))
	self:loadVipInfo()
end

--刷新代理列表
function C:refreshVipPanel()
	self.vipEmptyLabel:setVisible(false)
	for i=1,6 do
		local key = string.format("vipItemBtn%d",i)
		self[key]:setVisible(false)
	end
	local count = math.min(#self.vipInfoArr,8)
	for i=1,count do
		local info = self.vipInfoArr[i]
		local key = string.format("vipItemBtn%d",i)
		local btn = self[key]
		local nameLabel = btn:getChildByName("name_label")
		local wxLabel = btn:getChildByName("wx_label")
		btn:setTag(i)
		btn:setVisible(true)
		nameLabel:setString(info.AgentName)
		wxLabel:setString(info.WeiXin)
	end
end

--请求代理列表
function C:loadVipInfo()
	self.vipEmptyLabel:setVisible(false)
	if self.vipInfoArr == nil or #self.vipInfoArr == 0 then
		for i=1,6 do
			local key = string.format("vipItemBtn%d",i)
			self[key]:setVisible(false)
		end
		self:showVipLoading()
	end
    eventManager:publish("RequestAgentList")
end

--代理列表返回
function C:onVipInfo(list)
	self:hideVipLoading()
	self.vipInfoArr = list
	if self.vipInfoArr == nil or #self.vipInfoArr == 0 then
		self.vipEmptyLabel:setVisible(true)
	else
		self:refreshVipPanel()
	end
end

function C:showVipLoading()
	self.vipLoadingLabel:stopAllActions()
	self.vipLoadingLabel:setVisible(true)
	self.vipLoadingLabel:setString("正在获取代理列表，请稍后...")
	local array = {}
	array[1] = cc.DelayTime:create(0.5)
    array[2] = cc.CallFunc:create(function()
		self.vipLoadingLabel:setString("正在获取代理列表，请稍后")
	end)
    array[3] = cc.DelayTime:create(0.25)
    array[4] = cc.CallFunc:create(function()
		self.vipLoadingLabel:setString("正在获取代理列表，请稍后.")
	end)
    array[5] = cc.DelayTime:create(0.5)
    array[6] = cc.CallFunc:create(function()
		self.vipLoadingLabel:setString("正在获取代理列表，请稍后..")
	end)
	array[7] = cc.DelayTime:create(0.5)
    array[8] = cc.CallFunc:create(function()
		self.vipLoadingLabel:setString("正在获取代理列表，请稍后...")
	end)
    self.vipLoadingLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
end

function C:hideVipLoading()
	self.vipLoadingLabel:stopAllActions()
	self.vipLoadingLabel:setVisible(false)
end

--复制ID
function C:onClickVipCopyBtn( event )
	local text = self.vipAccountLabel:getString() or tostring(dataManager.playerId)
	utils:setCopy(text)
	toastLayer:show("已复制ID:"..text.."，发送给代理即可充值")
end

function C:onClickVipItemBtn( event )
	local info = self.vipInfoArr[event.target:getTag()]
	ProxyLayer.new(info):show()
end

--支付宝充值
function C:initZfbPanel()
	for i=1,8 do
		local key = string.format("zfbItemBtn%d",i)
		self[key]:setVisible(false)
	end
	local minMoney = tonumber(self.configsInfo["MinAlipay"]) or 0
	self.zfbInputEditBox:getChildByTag(10000):setString(string.format("请输入充值金额,最低%d元",minMoney))

	local tempArr = utils:stringSplit(self.configsInfo["AliPaySection"],"|")
	self.zfbMoneyArr = {}
	for i,v in ipairs(tempArr) do
		local money = tonumber(v)
		table.insert(self.zfbMoneyArr,money)
	end
	table.sort(self.zfbMoneyArr)
	local count = math.min(#self.zfbMoneyArr,8)
	for i=1,count do
		local money = tonumber(self.zfbMoneyArr[i]) or 0
		local key = string.format("zfbItemBtn%d",i)
		local btn = self[key]
		local label = btn:getChildByName("label")
		btn:setTag(i)
		btn:setVisible(true)
		label:setString(string.format("%d元",money))
	end
end

function C:onClickZfbClearBtn( event )
	self.zfbInputEditBox:setText("")
	self.zfbInputEditBox:getChildByTag(10000):setVisible(true)
end

function C:onClickZfbItemBtn( event )
	local index = event.target:getTag()
	local money = tonumber(self.zfbMoneyArr[index]) or 0
	self.zfbInputEditBox:setText(string.format("%d",money))
	self.zfbInputEditBox:getChildByTag(10000):setVisible(false)
end

--支付宝充值点击确认按钮
function C:onClickZfbConfirmBtn( event )
	local str = string.gsub(self.zfbInputEditBox:getText(),"元","")
	local money = tonumber(str)
	if money == nil or money <= 0 then
		toastLayer:show("请输入有效充值金额")
		return
	end

	local minMoney = tonumber(self.configsInfo["MinAlipay"]) or 0
	if money < minMoney then
		local text = string.format("单笔最小充值%d元,请调整充值金额",minMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.zfbInputEditBox:setText(tostring(minMoney))
			end
		end)
		return
	end

	local maxMoney = tonumber(self.configsInfo["MaxAlipay"]) or 0
	if money > maxMoney then
		local text = string.format("单笔最大充值%d元,请调整充值金额",maxMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.zfbInputEditBox:setText(tostring(maxMoney))
			end
		end)
		return
	end
    eventManager:send("Pay",CONST_PAY_TYPE_ALIPAY,money)
end

--微信充值
function C:initWxPanel()
	for i=1,8 do
		local key = string.format("wxItemBtn%d",i)
		self[key]:setVisible(false)
	end
	local minMoney = tonumber(self.configsInfo["MinWXPay"]) or 0
	self.wxInputEditBox:getChildByTag(10000):setString(string.format("请输入充值金额,最低%d元",minMoney))

	local tempArr = utils:stringSplit(self.configsInfo["WXPaySection"],"|")
	self.wxMoneyArr = {}
	for i,v in ipairs(tempArr) do
		local money = tonumber(v)
		table.insert(self.wxMoneyArr,money)
	end
	table.sort(self.wxMoneyArr)
	local count = math.min(#self.wxMoneyArr,8)
	for i=1,count do
		local money = tonumber(self.wxMoneyArr[i]) or 0
		local key = string.format("wxItemBtn%d",i)
		local btn = self[key]
		local label = btn:getChildByName("label")
		btn:setTag(i)
		btn:setVisible(true)
		label:setString(string.format("%d元",money))
	end
end

function C:onClickWxClearBtn( event )
	self.wxInputEditBox:setText("")
	self.wxInputEditBox:getChildByTag(10000):setVisible(true)
end

function C:onClickWxItemBtn( event )
	local index = event.target:getTag()
	local money = tonumber(self.wxMoneyArr[index]) or 0
	self.wxInputEditBox:setText(string.format("%d",money))
	self.wxInputEditBox:getChildByTag(10000):setVisible(false)
end

--微信充值点击确认按钮
function C:onClickWxConfirmBtn( event )
	local str = string.gsub(self.wxInputEditBox:getText(),"元","")
	local money = tonumber(str)
	if money == nil or money <= 0 then
		toastLayer:show("请输入有效充值金额")
		return
	end

	local minMoney = tonumber(self.configsInfo["MinWXPay"]) or 0
	if money < minMoney then
		local text = string.format("单笔最小充值%d元,请调整充值金额",minMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.wxInputEditBox:setText(tostring(minMoney))
			end
		end)
		return
	end

	local maxMoney = tonumber(self.configsInfo["MaxWXPay"]) or 0
	if money > maxMoney then
		local text = string.format("单笔最大充值%d元,请调整充值金额",maxMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.wxInputEditBox:setText(tostring(maxMoney))
			end
		end)
		return
	end

	--调用接口
    eventManager:send("Pay",CONST_PAY_TYPE_WX,money)
end

--银行卡充值
function C:initUnionPanel()
	for i=1,8 do
		local key = string.format("unionItemBtn%d",i)
		self[key]:setVisible(false)
	end
	local minMoney = tonumber(self.configsInfo["MinUnionPay"]) or 0
	self.unionInputEditBox:getChildByTag(10000):setString(string.format("请输入充值金额,最低%d元",minMoney))

	local tempArr = utils:stringSplit(self.configsInfo["UnionPaySection"],"|")
	self.unionMoneyArr = {}
	for i,v in ipairs(tempArr) do
		local money = tonumber(v)
		table.insert(self.unionMoneyArr,money)
	end
	table.sort(self.unionMoneyArr)
	local count = math.min(#self.unionMoneyArr,8)
	for i=1,count do
		local money = tonumber(self.unionMoneyArr[i]) or 0
		local key = string.format("unionItemBtn%d",i)
		local btn = self[key]
		local label = btn:getChildByName("label")
		btn:setTag(i)
		btn:setVisible(true)
		label:setString(string.format("%d元",money))
	end
end

function C:onClickUnionClearBtn( event )
	self.unionInputEditBox:setText("")
	self.unionInputEditBox:getChildByTag(10000):setVisible(true)
end

function C:onClickUnionItemBtn( event )
	local index = event.target:getTag()
	local money = tonumber(self.unionMoneyArr[index]) or 0
	self.unionInputEditBox:setText(string.format("%d",money))
	self.unionInputEditBox:getChildByTag(10000):setVisible(false)
end

--银行卡充值点击确定按钮
function C:onClickUnionConfirmBtn( event )
	local str = string.gsub(self.unionInputEditBox:getText(),"元","")
	local money = tonumber(str)
	if money == nil or money <= 0 then
		toastLayer:show("请输入有效充值金额")
		return
	end

	local minMoney = tonumber(self.configsInfo["MinUnionPay"]) or 0
	if money < minMoney then
		local text = string.format("单笔最小充值%d元,请调整充值金额",minMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.unionInputEditBox:setText(tostring(minMoney))
			end
		end)
		return
	end

	local maxMoney = tonumber(self.configsInfo["MaxUnionPay"]) or 0
	if money > maxMoney then
		local text = string.format("单笔最大充值%d元,请调整充值金额",maxMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.unionInputEditBox:setText(tostring(maxMoney))
			end
		end)
		return
	end
	--调用接口
    eventManager:send("Pay",CONST_PAY_TYPE_BANK,money)
end

--支付宝定额充值
--初始化支付宝定额面板
function C:initZfbdPanel()
	for i=1,12 do
		local key = string.format("zfbdItemBtn%d",i)
		self[key]:setVisible(false)
	end

	local tempArr = utils:stringSplit(self.configsInfo["Alipayisquotasection"],"|")
	self.zfbdMoneyArr = {}
	for i,v in ipairs(tempArr) do
		local money = tonumber(v)
		table.insert(self.zfbdMoneyArr,money)
	end
	table.sort(self.zfbdMoneyArr)
	local count = math.min(#self.zfbdMoneyArr,12)
	for i=1,count do
		local money = tonumber(self.zfbdMoneyArr[i]) or 0
		local key = string.format("zfbdItemBtn%d",i)
		local btn = self[key]
		local label = btn:getChildByName("label")
		btn:setTag(i)
		btn:setVisible(true)
		label:setString(string.format("%d元",money))
	end
end

--播放手指动画
function C:playArrowAni()
	self:stopArrowAni()
	local posX = self.zfbdArrowPos.x
    local posY = self.zfbdArrowPos.y
    local array = {}
    array[1] = cc.MoveTo:create(0.3,cc.p(posX,posY+10))
    array[2] = cc.MoveTo:create(0.3,cc.p(posX,posY))
    self.zfbdArrowImg:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
end

function C:stopArrowAni()
	self.zfbdArrowImg:stopAllActions()
	self.zfbdArrowImg:setPosition(self.zfbdArrowPos)
end

--选择金额
function C:onClickZfbdItemBtn( event )
	local index = event.target:getTag()
	local money = tonumber(self.zfbdMoneyArr[index]) or 0
	self.zfbdLabel:setString(string.format("%d元",money))
end

--支付宝定额支付点击确定
function C:onClickZfbdConfirmBtn( event )
	local str = string.gsub(self.zfbdLabel:getString(),"元","")
	local money = tonumber(str)
	if money == nil or money <= 0 then
		toastLayer:show("请选择充值金额")
		return
	end

	--调用接口
    eventManager:send("Pay",CONST_PAY_TYPE_ALIPAY_QUOTA,money)
end

--QQ充值
function C:initQqPanel()
	for i=1,8 do
		local key = string.format("qqItemBtn%d",i)
		self[key]:setVisible(false)
	end
	local minMoney = tonumber(self.configsInfo["MinQQPay"]) or 0
	self.qqInputEditBox:getChildByTag(10000):setString(string.format("请输入充值金额,最低%d元",minMoney))

	local tempArr = utils:stringSplit(self.configsInfo["QQPaySection"],"|")
	self.qqMoneyArr = {}
	for i,v in ipairs(tempArr) do
		local money = tonumber(v)
		table.insert(self.qqMoneyArr,money)
	end
	table.sort(self.qqMoneyArr)
	local count = math.min(#self.qqMoneyArr,8)
	for i=1,count do
		local money = tonumber(self.qqMoneyArr[i]) or 0
		local key = string.format("qqItemBtn%d",i)
		local btn = self[key]
		local label = btn:getChildByName("label")
		btn:setTag(i)
		btn:setVisible(true)
		label:setString(string.format("%d元",money))
	end
end

function C:onClickQqClearBtn( event )
	self.qqInputEditBox:setText("")
	self.qqInputEditBox:getChildByTag(10000):setVisible(true)
end

function C:onClickQqItemBtn( event )
	local index = event.target:getTag()
	local money = tonumber(self.qqMoneyArr[index]) or 0
	self.qqInputEditBox:setText(string.format("%d",money))
	self.qqInputEditBox:getChildByTag(10000):setVisible(false)
end

--QQ充值点击确定按钮
function C:onClickQqConfirmBtn( event )
	local str = string.gsub(self.qqInputEditBox:getText(),"元","")
	local money = tonumber(str)
	if money == nil or money <= 0 then
		toastLayer:show("请输入有效充值金额")
		return
	end

	local minMoney = tonumber(self.configsInfo["MinQQPay"]) or 0
	if money < minMoney then
		local text = string.format("单笔最小充值%d元,请调整充值金额",minMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.qqInputEditBox:setText(tostring(minMoney))
			end
		end)
		return
	end

	local maxMoney = tonumber(self.configsInfo["MaxQQPay"]) or 0
	if money > maxMoney then
		local text = string.format("单笔最大充值%d元,请调整充值金额",maxMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.qqInputEditBox:setText(tostring(maxMoney))
			end
		end)
		return
	end

	--调用接口
    eventManager:send("Pay",CONST_PAY_TYPE_QQ,money)
end

--京东充值
function C:initJdPanel()
	for i=1,8 do
		local key = string.format("jdItemBtn%d",i)
		self[key]:setVisible(false)
	end
	local minMoney = tonumber(self.configsInfo["MinJDPay"]) or 0
	self.jdInputEditBox:getChildByTag(10000):setString(string.format("请输入充值金额,最低%d元",minMoney))

	local tempArr = utils:stringSplit(self.configsInfo["JDPaySection"],"|")
	self.jdMoneyArr = {}
	for i,v in ipairs(tempArr) do
		local money = tonumber(v)
		table.insert(self.jdMoneyArr,money)
	end
	table.sort(self.jdMoneyArr)
	local count = math.min(#self.jdMoneyArr,8)
	for i=1,count do
		local money = tonumber(self.jdMoneyArr[i]) or 0
		local key = string.format("jdItemBtn%d",i)
		local btn = self[key]
		local label = btn:getChildByName("label")
		btn:setTag(i)
		btn:setVisible(true)
		label:setString(string.format("%d元",money))
	end
end

function C:onClickJdClearBtn( event )
	self.jdInputEditBox:setText("")
	self.jdInputEditBox:getChildByTag(10000):setVisible(true)
end

function C:onClickJdItemBtn( event )
	local index = event.target:getTag()
	local money = tonumber(self.jdMoneyArr[index]) or 0
	self.jdInputEditBox:setText(string.format("%d",money))
	self.jdInputEditBox:getChildByTag(10000):setVisible(false)
end

--京东充值点击确定按钮
function C:onClickJdConfirmBtn( event )
	local str = string.gsub(self.jdInputEditBox:getText(),"元","")
	local money = tonumber(str)
	if money == nil or money <= 0 then
		toastLayer:show("请输入有效充值金额")
		return
	end

	local minMoney = tonumber(self.configsInfo["MinJDPay"]) or 0
	if money < minMoney then
		local text = string.format("单笔最小充值%d元,请调整充值金额",minMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.jdInputEditBox:setText(tostring(minMoney))
			end
		end)
		return
	end

	local maxMoney = tonumber(self.configsInfo["MaxJDPay"]) or 0
	if money > maxMoney then
		local text = string.format("单笔最大充值%d元,请调整充值金额",maxMoney)
		DialogLayer.new():show(text,function( isOk )
			if isOk then
				self.jdInputEditBox:setText(tostring(maxMoney))
			end
		end)
		return
	end

	--调用接口
    eventManager:send("Pay",CONST_PAY_TYPE_JD,money)
end

return RechargeLayer