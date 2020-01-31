--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion

local C = class("DDZHelpLayer",BaseLayer)
DDZHelpLayer = C

C.RESOURCE_FILENAME = "base/DDZHelp.csb"
C.RESOURCE_BINDING = {
	btn_close = {path="node_all.btn_close",events={{event="click",method="OnClose"}}},
    img_pxbg_0 = {path="node_all.top_panel.img_pxbg_0"},     --牌型
    img_pxbg_1 = {path="node_all.top_panel.img_pxbg_1"},     --玩法
    img_pxbg_2 = {path="node_all.top_panel.img_pxbg_2"},     --赔率
    img_pxbg_3 = {path="node_all.top_panel.img_pxbg_3"},     --关于我们
    btn_px_0 = {path="node_all.top_panel.btn_px_0_0",events={{event="click",method="OnContent0"}}},       --牌型
    btn_px_1 = {path="node_all.top_panel.btn_px_1_0",events={{event="click",method="OnContent1"}}},       --玩法
    btn_px_2 = {path="node_all.top_panel.btn_px_2_0",events={{event="click",method="OnContent2"}}},       --赔率
    btn_px_3 = {path="node_all.top_panel.btn_px_3_0",events={{event="click",method="OnContent3"}}},       --关于我们
    obj_content0 = {path="node_all.center_panel.ScrollView_0"},      --牌型
    obj_content1 = {path="node_all.center_panel.ScrollView_1"},      --玩法
    obj_content2 = {path="node_all.center_panel.img_0"},     --赔率
    obj_content3 = {path="node_all.center_panel.img_1"},     --关于我们
}

function C:onCreate()
	C.super.onCreate(self)
    self.img_pxbg_0:setVisible(true)
    self.img_pxbg_1:setVisible(false)
    self.img_pxbg_2:setVisible(false)
    self.img_pxbg_3:setVisible(false)

    self.obj_content0:setVisible(true)
    self.obj_content1:setVisible(false)
    self.obj_content2:setVisible(false)
    self.obj_content3:setVisible(false)
end

function C:OnClose( event )
	self:hide()
end

function C:OnContent0( event )
	self.img_pxbg_0:setVisible(true)
    self.img_pxbg_1:setVisible(false)
    self.img_pxbg_2:setVisible(false)
    self.img_pxbg_3:setVisible(false)

    self.obj_content0:setVisible(true)
    self.obj_content1:setVisible(false)
    self.obj_content2:setVisible(false)
    self.obj_content3:setVisible(false)
end

function C:OnContent1( event )
	self.img_pxbg_0:setVisible(false)
    self.img_pxbg_1:setVisible(true)
    self.img_pxbg_2:setVisible(false)
    self.img_pxbg_3:setVisible(false)

    self.obj_content0:setVisible(false)
    self.obj_content1:setVisible(true)
    self.obj_content2:setVisible(false)
    self.obj_content3:setVisible(false)
end

function C:OnContent2( event )
	self.img_pxbg_0:setVisible(false)
    self.img_pxbg_1:setVisible(false)
    self.img_pxbg_2:setVisible(true)
    self.img_pxbg_3:setVisible(false)

    self.obj_content0:setVisible(false)
    self.obj_content1:setVisible(false)
    self.obj_content2:setVisible(true)
    self.obj_content3:setVisible(false)
end

function C:OnContent3( event )
	self.img_pxbg_0:setVisible(false)
    self.img_pxbg_1:setVisible(false)
    self.img_pxbg_2:setVisible(false)
    self.img_pxbg_3:setVisible(true)

    self.obj_content0:setVisible(false)
    self.obj_content1:setVisible(false)
    self.obj_content2:setVisible(false)
    self.obj_content3:setVisible(true)
end

return DDZHelpLayer