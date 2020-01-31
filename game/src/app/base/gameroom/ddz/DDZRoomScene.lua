--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local hallCore = require("app.base.hall.HallCore")

local C = class("DDZRoomScene",SceneBase)
DDZRoomScene = C
C.qznnHelpLayer = nil
-- 资源名
C.RESOURCE_FILENAME = "base/DDZRoom.csb"

C.RESOURCE_BINDING = {
	--返回按钮
	btn_back = {path="node_back.btn_back",events={{event="click",method="OnBack"}}},
    node_back = {path="node_back"},
    --帮助按钮
	btn_help = {path="btn_help",events={{event="click",method="OnHelp"}}},
    --记录按钮
	btn_record = {path="btn_record",events={{event="click",method="OnRecord"}}},
	--体验房
	btn_gameItem_0 = {path="right_panel.gameItem_0.Button",events={{event="click",method="OnGameItem_0"}}},
    --初级房
	btn_gameItem_1 = {path="right_panel.gameItem_1.Button",events={{event="click",method="OnGameItem_1"}}},
    --中级房
	btn_gameItem_2 = {path="right_panel.gameItem_2.Button",events={{event="click",method="OnGameItem_2"}}},
    --高级房
	btn_gameItem_3 = {path="right_panel.gameItem_3.Button",events={{event="click",method="OnGameItem_3"}}},

    img_girl = {path="img_girl"},
    right_panel = {path="right_panel"},

    --顶部UI节点
    top_panel = {path="top_panel"},
    img_head = {path="top_panel.img_head"},
    node_imgHead = {path="top_panel.node_imgHead"},

    label_0 = {path="right_panel.gameItem_0.node_label.label0_bg.label_0"},
    label_1 = {path="right_panel.gameItem_0.node_label.label1_bg.label_0"},
    label_2 = {path="right_panel.gameItem_1.node_label.label0_bg.label_0"},
    label_3 = {path="right_panel.gameItem_1.node_label.label1_bg.label_0"},
    label_4 = {path="right_panel.gameItem_2.node_label.label0_bg.label_0"},
    label_5 = {path="right_panel.gameItem_2.node_label.label1_bg.label_0"},
    label_6 = {path="right_panel.gameItem_3.node_label.label0_bg.label_0"},
    label_7 = {path="right_panel.gameItem_3.node_label.label1_bg.label_0"},

    txt_id = {path="top_panel.txt_id"},
    label_money = {path="node_account.label_0"},
}

C.offsetX = (display.width-1136)/2

C.items = {}
C.gameId = GAMEID_DDZ


function C:initialize()
    --适配宽度代码 1136为设计分辨率宽度
	self.hairOffsetX = GET_PHONE_HAIRE_WIDTH()
	self.resourceNode:setPositionX(self.offsetX)
    self.node_back:setPositionX(self.node_back:getPositionX() + self.offsetX)
    self.btn_help:setPositionX(self.btn_help:getPositionX() + self.offsetX)
    self.btn_record:setPositionX(self.btn_record:getPositionX() + self.offsetX)
    self.right_panel:setPositionX(self.right_panel:getPositionX() + self.offsetX)

    self.top_panel:setPositionX(self.top_panel:getPositionX() - self.offsetX)
    self.img_girl:setPositionX(self.img_girl:getPositionX() - self.offsetX)
    --self.img_head:setVisible(false)
    self.btn_help:setVisible(false)
    self.btn_record:setVisible(false)

    SET_HEAD_IMG(self.img_head,dataManager.userInfo.headid,dataManager.userInfo.wxheadurl)
    
    --print("-------gameId-------" .. self.gameId)

	for k,v in pairs(dataManager.gamelist) do
		if v.gameid == self.gameId then
			local contain = false
			--过滤重复房间号
			for t,r in pairs(self.items) do
				if r.orderid == v.orderid then
					contain = true
				end
			end
			if not contain then
				table.insert(self.items,v)
			end
		end
	end

    table.sort(self.items,function(a,b)
        return a.orderid > b.orderid
    end)

    self:loadHeadBGAnimation()

    self.label_0:setString("准入" .. 100/MONEY_SCALE)       --体验房准入
    self.label_1:setString("底分" .. 1/MONEY_SCALE)       --体验房底分
    self.label_2:setString("准入" .. 1000/MONEY_SCALE)       --初级房准入
    self.label_3:setString("底分" .. 10/MONEY_SCALE)       --初级房底分
    self.label_4:setString("准入" .. 2000/MONEY_SCALE)       --中级房准入
    self.label_5:setString("底分" .. 20/MONEY_SCALE)       --中级房底分
    self.label_6:setString("准入" .. 18000/MONEY_SCALE)       --高级房准入
    self.label_7:setString("底分" .. 200/MONEY_SCALE)       --高级房底分

    self.txt_id:setString("ID:" .. dataManager.userInfo.playerid)
    self.txt_id:setFontSize(26)
    self.label_money:setString(dataManager.userInfo.money/MONEY_SCALE)
end

--进入场景
function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--播放背景音乐
	PLAY_MUSIC(BASE_SOUND_RES.."bg_room_ddz.mp3")
end

--斗地主头像背景动画
function C:loadHeadBGAnimation()
	local strAnimName ="base/animation/skeleton/head_bg/effect_frame5_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.node_imgHead:addChild( skeletonNode )

    self.node_imgHead:setScaleX(0.75)
    self.node_imgHead:setScaleY(0.75)
end

--点击返回大厅
function C:OnBack( event )
	require("app.init")
	HallCore.new():run()
end

--帮助
function C:OnHelp( event )
	--print("--------------OnHelp  is  called!!!--------------")
--    if self.qznnHelpLayer == nil then
--		self.qznnHelpLayer = QZNNHelpLayer.new()
--		self.qznnHelpLayer:retain()
--	end
--	self.qznnHelpLayer:show()
end

--记录
function C:OnRecord( event )
	print("--------------OnRecord  is  called!!!--------------")
end

--点击进入体验房
function C:OnGameItem_0( event )
	--print("--------------OnGameItem_0  is  called!!!--------------")
    hallCore:enterGameRoom(self.items[1])
end

--点击进入初级房
function C:OnGameItem_1( event )
	--print("--------------OnGameItem_1  is  called!!!--------------")
    hallCore:enterGameRoom(self.items[2])
end

--点击进入中级房
function C:OnGameItem_2( event )
--	if(self.items[3] == nil) then
--        toastLayer:show("房间暂未开放！！",3)
--    else
--        hallCore:enterGameRoom(self.items[3])
--    end
end

--点击进入高级房
function C:OnGameItem_3( event )
--	if(self.items[4] == nil) then
--        toastLayer:show("房间暂未开放！！",3)
--    else
--        hallCore:enterGameRoom(self.items[4])
--    end
end

return DDZRoomScene