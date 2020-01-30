local C = class("RuleLayer",BaseLayer)
RuleLayer = C

C.RESOURCE_FILENAME = "common/RuleLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	scrollview = {path="box_img.scrollview"},
	contentImg = {path="box_img.scrollview.content_img"},
}

function C:onCreate()
	C.super.onCreate(self)
	self.scrollview:setScrollBarEnabled(false)
end

--level:百人牛牛游戏用到1：5低分场 2：高分场
function C:show( gameId, level )
	local name = ""
	if gameId == GAMEID_DDZ or gameId == GAMEID_CPDDZ then
		name = "rules_ddz.png"
	elseif gameId == GAMEID_ZJH then
		name = "rules_zjh.png"
	elseif gameId == GAMEID_QZNN then
		name = "rules_qznn.png"
	elseif gameId == GAMEID_HHDZ then
		name = "rules_hhdz.png"
	elseif gameId == GAMEID_FRUIT then
		name = "rules_hhdz.png"
	elseif gameId == GAMEID_HB then
		name = "rules_hb.png"
	elseif gameId == GAMEID_BRNN then
		if level == 1 then
			name = "rules_brnn_5.png"
		elseif level == 2 then
			name = "rules_brnn_10.png"
		end
	end
	if name == "" then
		return
	end
	self.contentImg:setTexture(COMMON_IMAGES_RES..name)
	local height = self.contentImg:getContentSize().height
	if height < 458 then
		height = 458
		self.scrollview:setBounceEnabled(false)
	else
		self.scrollview:setBounceEnabled(true)
	end
	self.contentImg:setPositionY(height)
	self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getContentSize().width,height))
	C.super.show(self)
end

return RuleLayer