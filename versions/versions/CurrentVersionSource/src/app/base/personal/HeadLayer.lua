local C = class("HeadLayer",BaseLayer)
HeadLayer = C

C.RESOURCE_FILENAME = "base/HeadLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
    headImg = {path="head_img"},
}

C.didSelectedHead = nil
C.headId = 0

function C:ctor()
	for i=1,COMMON_HEAD_MAX do
		local key = string.format("headBtn%d",i)
		local path = string.format("box_img.scrollview.head_btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="touch",method="onTouchHeadBtn"}}}
	end
	C.super.ctor(self)
    self.headId = dataManager.userInfo.headid
end

function C:onCreate()
	C.super.onCreate(self)
	for i=1,COMMON_HEAD_MAX do
		self:setHeadBtnEnabled(i,true)
	end
	--头像ID
	self.headId = dataManager.userInfo.headid
	self:selectedHead(self.headId)
    self.headImg:loadTexture(string.format("common/head/head_%02d.png",self.headId))
end

function C:onTouchHeadBtn( event )
	if event.name == "began" then
		event.target:setScale(1.1)
	elseif event.name == "moved" then
		--
	elseif event.name == "ended" then
		PLAY_SOUND_CLICK()
		event.target:setScale(1)
		local tag = event.target:getTag()
		self:selectedHead( tag )
		if self.didSelectedHead then
			self.didSelectedHead(tag)
		end
	    eventManager:publish("ChangeAvatar",tag)
	elseif event.name == "cancelled" then
		event.target:setScale(1)
	end
end

function C:selectedHead( headId )
	if headId < 1 then
		headId = 1
	elseif headId > COMMON_HEAD_MAX then
		headId = COMMON_HEAD_MAX
	end

    self:setHeadBtnEnabled(self.headId,true)
	self.headId = headId
	self:setHeadBtnEnabled(self.headId,false)    
    self.headImg:loadTexture(string.format("common/head/head_%02d.png",self.headId))
end

function C:setHeadBtnEnabled( index, enabled )
	local headBtn = self[string.format("headBtn%d",index)]
	if headBtn then
		headBtn:setEnabled(enabled)
		local img = headBtn:getChildByName("selected_img")
		img:setVisible( not enabled )
	end
end

return HeadLayer