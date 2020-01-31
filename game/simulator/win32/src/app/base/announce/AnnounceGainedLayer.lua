local C = class("AnnounceGainedLayer",BaseLayer)
AnnounceGainedLayer = C

C.RESOURCE_FILENAME = "base/AnnounceGainedLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	titleLabel = {path="box_img.title_label"},
	gainedImg = {path="box_img.gained_img"},
	moneyLabel = {path="box_img.coin_img.label"},
	fromImg = {path="box_img.from_img"},
	fromLabel = {path="box_img.from_img.label"}
}

function C:ctor( info )
	C.super.ctor(self)
	local title = info.title
	local money = info.money
	local from = "发件人："..tostring(info.from)
	self.titleLabel:setString(title)
	self.moneyLabel:setString(utils:moneyString(money))
	self.fromLabel:setString(from)
	local width = self.fromLabel:getContentSize().width + 60
	self.fromImg:setContentSize(cc.size(width,self.fromImg:getContentSize().height))
end

return AnnounceGainedLayer