local C = class("AnnounceUngainedLayer",BaseLayer)
AnnounceUngainedLayer = C

C.RESOURCE_FILENAME = "base/AnnounceUngainedLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	moneyLabel = {path="box_img.coin_img.label"},
	confirmBtn = {path="box_img.confirm_btn",events={{event="click",method="onClickConfirmBtn"}}},
}

C.callback = nil

function C:ctor( info, callback )
	C.super.ctor(self)
	self.callback = callback
	local money = info.money
	self.moneyLabel:setString(utils:moneyString(money))
end

function C:onClickConfirmBtn( event )
	if self.callback then
		self.callback()
	end
	self:hide()
end

return AnnounceUngainedLayer