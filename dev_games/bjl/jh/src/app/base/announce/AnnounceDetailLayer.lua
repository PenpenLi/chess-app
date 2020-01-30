local C = class("AnnounceDetailLayer",BaseLayer)
AnnounceDetailLayer = C

C.RESOURCE_FILENAME = "base/AnnounceDetailLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	titleLabel = {path="box_img.title_label"},
	scrollview = {path="box_img.scrollview"},
	fromImg = {path="box_img.from_img"},
	fromLabel = {path="box_img.from_img.label"}
}

function C:ctor( info )
	C.super.ctor(self)
	local title = info.title
	local content = info.content
	local from = "发件人："..tostring(info.from)
	self.titleLabel:setString(title)
	local label = cc.LabelTTF:create()
	label:setFontSize(26)
	label:setColor(cc.c3b(0,0,0))
	label:setAnchorPoint(cc.p(0,1))
	label:setDimensions(cc.size(self.scrollview:getContentSize().width,0))
	label:setString(content)
	self.scrollview:addChild(label)
	local height = label:getContentSize().height
	if height < 230 then
		height = 230
		self.scrollview:setBounceEnabled(false)
	else
		self.scrollview:setBounceEnabled(true)
	end
	label:setPositionY(height)
	self.scrollview:setScrollBarEnabled(false)
	self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getContentSize().width,height))
	self.fromLabel:setString(from)
	local width = self.fromLabel:getContentSize().width + 60
	self.fromImg:setContentSize(cc.size(width,self.fromImg:getContentSize().height))
end

return AnnounceDetailLayer