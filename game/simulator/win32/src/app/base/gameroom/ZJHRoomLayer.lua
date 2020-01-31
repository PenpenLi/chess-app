--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local C = class("ZJHRoomLayer",SceneBase)
ZJHRoomLayer = C
-- 资源名
C.RESOURCE_FILENAME = "base/ZhaJinHuaRoom.csb"

C.RESOURCE_BINDING = {
	--返回按钮
	btn_back = {path="btn_back",events={{event="click",method="OnBack"}}},
	--返回按钮
	btn_gameItem_0 = {path="right_panel.gameItem_0",events={{event="click",method="OnGameItem_0"}}},
    --返回按钮
	btn_gameItem_1 = {path="right_panel.gameItem_1",events={{event="click",method="OnGameItem_1"}}},
    --返回按钮
	btn_gameItem_2 = {path="right_panel.gameItem_2",events={{event="click",method="OnGameItem_2"}}},
    --返回按钮
	btn_gameItem_3 = {path="right_panel.gameItem_3",events={{event="click",method="OnGameItem_3"}}},

}

--创建初始化layer的时候调用
function C:onCreate()
	C.super.onCreate(self)
--	self.cunruTabBtn:setEnabled(false)
--	self.quchuTabBtn:setEnabled(true)
--	self.arrowUpImg:setVisible(false)
--	self.arrowDownImg:setVisible(false)
--	self.blanceLabel:setString("")
--	self.bankLabel:setString("")
--	self.inputCunruImg:setVisible(true)
--	self.inputQuchuImg:setVisible(false)
--	self.inputEditBox = self:createEditBox(handler(self,self["onEditHandler"]))
--	self.inputNode:addChild(self.inputEditBox)
--	self.slider:setPercent(0)
--	self.tipsImg:setVisible(false)
--	self.tipsImg:setPosition(cc.p(0,18))
--	self.tipsLabel:setString("0%")
end

--点击存入tab
function C:OnBack( event )
	print("--------------OnBack  is  called!!!--------------")
end

--点击存入tab
function C:OnGameItem_0( event )
	print("--------------OnGameItem_0  is  called!!!--------------")
end

--点击存入tab
function C:OnGameItem_1( event )
	print("--------------OnGameItem_1  is  called!!!--------------")
end

--点击存入tab
function C:OnGameItem_2( event )
	print("--------------OnGameItem_2  is  called!!!--------------")
end

--点击存入tab
function C:OnGameItem_3( event )
	print("--------------OnGameItem_3  is  called!!!--------------")
end

return ZJHRoomLayer