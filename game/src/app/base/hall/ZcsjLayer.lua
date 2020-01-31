local C = class("ZcsjLayer",BaseLayer)
ZcsjLayer = C

C.RESOURCE_FILENAME = "base/ZcsjLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="OnBack"}}},
	registerBtn = {path="register_btn",events={{event="click",method="onClickRegisterBtn"}}},
    img = {path="img"},
    img_ani = {path="img_ani"},
    font_num = {path="font_num"},
}

function C:onClickRegisterBtn( event )
	RegisterLayer.new():show()
	self:hide()
end

function C:onCreate()
	C.super.onCreate(self)
    self.img:setVisible(false)

    self:loadSongJinAnimation()
end

--×¢²áËÍ½ð¶¯»­
function C:loadSongJinAnimation()
	local strAnimName ="base/animation/skeleton/songjin/huodongjuesedaiji"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"animation",true)
	self.img_ani:addChild( skeletonNode )

    self.img_ani:setScaleX(0.75)
    self.img_ani:setScaleY(0.75)
end

function C:OnBack( event )
	require("app.init")
	HallCore.new():run()
end

return ZcsjLayer