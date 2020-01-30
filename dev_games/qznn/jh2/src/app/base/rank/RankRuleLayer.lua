local C = class("RankRuleLayer",BaseLayer)
RankRuleLayer = C

C.RESOURCE_FILENAME = "base/RankRuleLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	scrollview = {path="box_img.scrollview"},
}

function C:onCreate()
	C.super.onCreate(self)
	self.scrollview:setScrollBarWidth(5)
	self.scrollview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
end

return RankRuleLayer