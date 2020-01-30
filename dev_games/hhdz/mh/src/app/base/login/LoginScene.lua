local C = class("LoginScene",SceneBase)

C.RESOURCE_FILENAME = "base/LoginScene.csb"
C.RESOURCE_BINDING = {
	versionLabel = {path="version_label"},
	serviceBtn = {path="service_btn",events={{event="click",method="onClickServiceBtn"}}},
	wxLoginBtn = {path="wx_btn",events={{event="click",method="onClickWxBtn"}}},
	ykLoginBtn = {path="yk_btn",events={{event="click",method="onClickYkBtn"}}},
	sjLoginBtn = {path="sj_btn",events={{event="click",method="onClickSjBtn"}}},
}

C.serviceLayer = nil

function C:initialize()
	-- SwitchLayer.new():show(self)
	--适配宽度代码 1136为设计分辨率宽度
	local offsetX = (display.width-1136)/2
	self.resourceNode:setPositionX(offsetX) 
	local text = "版本信息"..tostring(CHANNEL_ID).."."..tostring(dataManager:getLocalBaseVersion()).."."..tostring(dataManager.remoteBaseVersion)
	self.versionLabel:setString(text)
	local btns = {}
	if GUEST_LOGIN_ENABLED then
		table.insert(btns,self.ykLoginBtn)
		self.ykLoginBtn:setVisible(true)
	else
		self.ykLoginBtn:setVisible(false)
	end
	if WECHAT_LOGIN_ENABLED then
		table.insert(btns,self.wxLoginBtn)
		self.wxLoginBtn:setVisible(true)
	else
		self.wxLoginBtn:setVisible(false)
	end
	table.insert(btns,self.sjLoginBtn)
	local padding = 11
	local width = 289
	local posX = (1136-(padding+width)*(#btns-1))/2
	for i,v in ipairs(btns) do
		v:setPositionX(posX)
		posX = posX+padding+width
	end
	self:logoAni()
end

function C:logoAni()
	local strAnimName = "base/animation/skeleton/logo/logo"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"animation",true)
	self.resourceNode:addChild( skeletonNode )
	skeletonNode:setPosition(cc.p(568,360))
end

function C:onClickServiceBtn( event )
	self:showServiceLayer()
end

--显示客服
function C:showServiceLayer()
	-- if self.serviceLayer == nil then
	-- 	self.serviceLayer = ServiceLayer.new()
	-- 	self.serviceLayer:retain()
	-- end
	-- self.serviceLayer:show()
	local url = DEFAULT_SERVICE_URL.."&info="..string.urlencode("userId=0".."&name=用户ID:"..""..",平台:".."2"..",渠道:".."2500".."&memo=0")
	WebLayer.new():show(url,true)
end

--游客登录
function C:onClickYkBtn( event )
   	loadingLayer:show("正在登录...",120)
    eventManager:send("NullLogin")
end

--微信登录
function C:onClickWxBtn( event )
	local callback = function( code )
		if code and code ~= "" then
			loadingLayer:show("正在登录...",120)
			eventManager:publish("WechatLogin",code)
			--label会变黑
			--经过调查发现是SDK的回调函数在线程中处理的，将刷新放在游戏下一帧，问题就可以解决。
			--  utils:delayInvoke("LoginScene.webchat",0.2,function()
				
			-- end)
	    end
	end
	utils:sendWechatLogin(callback)
end

--手机登录
function C:onClickSjBtn( event )
	-- SmsLoginLayer.new():show()
	LoginLayer.new():show()
end

return C