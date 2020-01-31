local C = class("PersonalLayer",BaseLayer)
PersonalLayer = C

C.RESOURCE_FILENAME = "base/PersonalLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	--头像
	headImg = {path="box_img.head_img"},
	frameImg = {path="box_img.frame_img"},
	--vip
	vipImg = {path="box_img.vip_img"},
	vipLabel = {path="box_img.vip_img.label"},
	--更换头像
	changeBtn = {path="box_img.change_btn",events={{event="click",method="onClickChangeBtn"}}},
	--账号ID
	accountLabel = {path="box_img.account_img.label"},
	accountBtn = {path="box_img.account_img.btn",events={{event="click",method="onClickCopyBtn"}}},
	--昵称
	nicknameLabel = {path="box_img.nickname_img.label"},
	nicknameBtn = {path="box_img.nickname_img.btn",events={{event="click",method="onClickNicknameBtn"}}},
	--手机号
	phoneLabel = {path="box_img.phone_img.label"},
	phoneLabel1 = {path="box_img.phone_img.label_1"},
	bindBtn = {path="box_img.phone_img.btn",events={{event="click",method="onClickRegisterBtn"}}},
	resetBtn = {path="box_img.phone_img.reset_btn",events={{event="click",method="onClickResetBtn"}}},
	--切换账号/注册/设置
	switchBtn = {path="box_img.switch_btn",events={{event="click",method="onClickSwitchBtn"}}},
	registerBtn = {path="box_img.register_btn",events={{event="click",method="onClickRegisterBtn"}}},
	settingsBtn = {path="box_img.settings_btn",events={{event="click",method="onClickSettingsBtn"}}}
}

C.didSelectedHead = nil

function C:onCreate()
	C.super.onCreate(self)
end

function C:show()
    C.super.show(self)
    --头像
    local headId = dataManager.userInfo.headid
    local headUrl = dataManager.userInfo.wxheadurl
    SET_HEAD_IMG(self.headImg,headId,headUrl)
    if headUrl and headUrl ~= "" then
		self.changeBtn:setVisible(false)
	elseif WECHAT_LOGIN_ENABLED then
		self.changeBtn:setVisible(false)
    else
    	self.changeBtn:setVisible(true)
    end
    --头像框
    -- local frameRes = string.format("common/frame/frame_%02d.png",dataManager.vipLevel2)
    -- self.frameImg:loadTexture(frameRes)
    --vip等级
    --屏蔽VIP显示
    self.vipImg:setVisible(false)
    -- self.vipLabel:setString(tostring(dataManager.vipLevel2))
    --账号ID
    self.accountLabel:setString(tostring(dataManager.playerId))
    --昵称
    local nickname = dataManager.userInfo.nickname or tostring(dataManager.playerId)
    self.nicknameLabel:setString(nickname)
    if nickname == tostring(dataManager.playerId) then
    	self.nicknameBtn:setVisible(true)
    else
    	self.nicknameBtn:setVisible(false)
    end
    --屏蔽修改昵称
    self.nicknameBtn:setVisible(false)
	--手机号
    
    --是否游客
	local isGuest = dataManager.isbindaccount == 0
	if isGuest then
		self.phoneLabel1:setString("未绑定手机号")
		self.phoneLabel:setVisible(false)
		self.phoneLabel1:setVisible(true)
		self.bindBtn:setVisible(true)
		self.resetBtn:setVisible(false)
		self.registerBtn:setVisible(true)
		self.registerBtn:setPosition(cc.p(405,75))
		self.switchBtn:setPosition(cc.p(146,75))
		self.settingsBtn:setPosition(cc.p(663,75))
	else
		self.phoneLabel:setString(tostring(dataManager.account))
		self.phoneLabel:setVisible(true)
		self.phoneLabel1:setVisible(false)
		self.bindBtn:setVisible(false)
		self.resetBtn:setVisible(true)
		self.registerBtn:setVisible(false)
		self.switchBtn:setPosition(cc.p(252,75))
		self.settingsBtn:setPosition(cc.p(570,75))
	end
	--屏蔽修改密码
	self.resetBtn:setVisible(false)
end

--点击更换头像
function C:onClickChangeBtn( event )
	local headLayer = HeadLayer.new()
	headLayer.didSelectedHead = function ( headId )
		if self.didSelectedHead then
			self.didSelectedHead(headId)
		end
		self.headImg:loadTexture(string.format("common/head/head_%02d.png",headId))
	end
	headLayer:show()
end

--点击复制ID
function C:onClickCopyBtn( event )
	utils:setCopy(tostring(self.accountLabel:getString()))
	toastLayer:show("已复制ID:"..tostring(self.accountLabel:getString()))
end

--修改昵称
function C:onClickNicknameBtn( event )
	-- body
end

--点击修改密码
function C:onClickResetBtn( event )
	-- ModifyLayer.new():show()
end

--点击切换账号
function C:onClickSwitchBtn( event )
	local dialogLayer = DialogLayer.new()
	--是否游客账号
	local isGuest = dataManager.isbindaccount == 0
	local text = "您确定切换账号吗？"
	if isGuest then
		text = "您当前的账号为游客账号,若退出可能无法再找回,为了保护您的账号安全,建议您绑定账号"
	end
	dialogLayer:show(text,function( isOk )
		if isOk then
			self:onHide()
			ENTER_LOGIN()
		end
	end)
end

--点击注册正式账号 -- 立即绑定
function C:onClickRegisterBtn( event )
	self:onHide()
	RegisterLayer.new():show()
end

--点击设置
function C:onClickSettingsBtn( event )
	settingsLayer:show()
end

return PersonalLayer