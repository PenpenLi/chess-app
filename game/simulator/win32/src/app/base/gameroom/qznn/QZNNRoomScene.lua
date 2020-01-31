--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local hallCore = require("app.base.hall.HallCore")

local C = class("QZNNRoomScene",SceneBase)
QZNNRoomScene = C
C.qznnHelpLayer = nil
-- 资源名
C.RESOURCE_FILENAME = "base/QZNNRoom.csb"

C.RESOURCE_BINDING = {
	--返回按钮
	btn_back = {path="btn_back",events={{event="click",method="OnBack"}}},
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
    --至尊房
	btn_gameItem_4 = {path="right_panel.gameItem_4.Button",events={{event="click",method="OnGameItem_4"}}},
    --王者房
	btn_gameItem_5 = {path="right_panel.gameItem_5.Button",events={{event="click",method="OnGameItem_5"}}},
  

    --顶部UI节点
    top_panel = {path="top_panel"},
    bg_top = {path="top_panel.bg_top"},
    img_head = {path="top_panel.img_head"},
    node_imgHead = {path="top_panel.node_imgHead"},

    girlAni = {path="girlAni"},
    item_ani_0 = {path="right_panel.gameItem_0.item_ani"},
    item_ani_1 = {path="right_panel.gameItem_1.item_ani"},
    item_ani_2 = {path="right_panel.gameItem_2.item_ani"},
    item_ani_3 = {path="right_panel.gameItem_3.item_ani"},
    item_ani_4 = {path="right_panel.gameItem_4.item_ani"},
    item_ani_5 = {path="right_panel.gameItem_5.item_ani"},
    node_bg_left = {path="node_bg_left"},
    node_bg_right = {path="node_bg_right"},

    label_0 = {path="right_panel.gameItem_0.node_label.label_0"},
    label_1 = {path="right_panel.gameItem_0.node_label.label_1"},
    label_2 = {path="right_panel.gameItem_1.node_label.label_0"},
    label_3 = {path="right_panel.gameItem_1.node_label.label_1"},
    label_4 = {path="right_panel.gameItem_2.node_label.label_0"},
    label_5 = {path="right_panel.gameItem_2.node_label.label_1"},
    label_6 = {path="right_panel.gameItem_3.node_label.label_0"},
    label_7 = {path="right_panel.gameItem_3.node_label.label_1"},
    label_8 = {path="right_panel.gameItem_4.node_label.label_0"},
    label_9 = {path="right_panel.gameItem_4.node_label.label_1"},
    label_10 = {path="right_panel.gameItem_5.node_label.label_0"},
    label_11 = {path="right_panel.gameItem_5.node_label.label_1"},

    txt_id = {path="top_panel.txt_id"},
    label_money = {path="top_panel.label_0"},
}

C.offsetX = (display.width-1136)/2

C.items = {}
C.gameId = GAMEID_QZNN


function C:initialize()
    --适配宽度代码 1136为设计分辨率宽度
	self.hairOffsetX = GET_PHONE_HAIRE_WIDTH()
	self.resourceNode:setPositionX(self.offsetX)
    self.btn_back:setPositionX(self.btn_back:getPositionX() + self.offsetX)
    self.btn_help:setPositionX(self.btn_help:getPositionX() + self.offsetX)
    self.btn_record:setPositionX(self.btn_record:getPositionX() + self.offsetX)


    self.top_panel:setPositionX(self.top_panel:getPositionX() - self.offsetX)
    --self.img_head:setVisible(false)
    --self.btn_help:setVisible(false)
    --self.btn_record:setVisible(false)
    --self.gameItem_5:setVisible(false)

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

    self:loadQZNNGirlAnimation()
    self:loadQZNN01Animation()
    self:loadQZNN02Animation()
    self:loadQZNN03Animation()
    self:loadQZNN04Animation()
    self:loadQZNN05Animation()
    self:loadQZNN06Animation()
    self:loadHeadBGAnimation()
    self:loadRoomBG_LeftAnimation()
    self:loadRoomBG_RightAnimation()

    self.girlAni:setScaleX(0.88)
    self.girlAni:setScaleY(0.88)
    self.item_ani_0:setScaleX(0.88)
    self.item_ani_0:setScaleY(0.88)
    self.item_ani_1:setScaleX(0.88)
    self.item_ani_1:setScaleY(0.88)
    self.item_ani_2:setScaleX(0.88)
    self.item_ani_2:setScaleY(0.88)
    self.item_ani_3:setScaleX(0.88)
    self.item_ani_3:setScaleY(0.88)
    self.item_ani_4:setScaleX(0.88)
    self.item_ani_4:setScaleY(0.88)
    self.item_ani_5:setScaleX(0.88)
    self.item_ani_5:setScaleY(0.88)

    self.label_0:setString("底注" .. "2")       --体验房底注
    self.label_1:setString("准入" .. "200")       --体验房准入
    self.label_2:setString("底注" .. "10")       --初级房底注
    self.label_3:setString("准入" .. "500")       --初级房准入
    self.label_4:setString("底注" .. "50")       --中级房底注
    self.label_5:setString("准入" .. "2500")       --中级房准入
    self.label_6:setString("底注" .. "100")       --高级房底注
    self.label_7:setString("准入" .. "5000")       --高级房准入
    self.label_8:setString("底注" .. "200")       --至尊房底注
    self.label_9:setString("准入" .. "10000")       --至尊房准入
    self.label_10:setString("底注" .. "300")       --王者房底注
    self.label_11:setString("准入" .. "18000")       --王者房准入

    self.txt_id:setString("ID:" .. dataManager.userInfo.playerid)
    self.txt_id:setFontSize(26)
    self.label_money:setString(dataManager.userInfo.money/MONEY_SCALE)
end

--进入场景
function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--播放背景音乐
	PLAY_MUSIC(BASE_SOUND_RES.."bg_room_qznn.mp3")
end

--抢庄牛牛女孩动画
function C:loadQZNNGirlAnimation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_girl_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.girlAni:addChild( skeletonNode )
end

--抢庄牛牛00
function C:loadQZNN01Animation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_1_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_0:addChild( skeletonNode )
end

--抢庄牛牛01
function C:loadQZNN02Animation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_2_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_1:addChild( skeletonNode )
end

--抢庄牛牛02
function C:loadQZNN03Animation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_3_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_2:addChild( skeletonNode )
end

--抢庄牛牛03
function C:loadQZNN04Animation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_4_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_3:addChild( skeletonNode )
end

--抢庄牛牛04
function C:loadQZNN05Animation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_5_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_4:addChild( skeletonNode )
end

--抢庄牛牛05
function C:loadQZNN06Animation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_6_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_5:addChild( skeletonNode )
end

--牛牛头像背景动画
function C:loadHeadBGAnimation()
	local strAnimName ="base/animation/skeleton/head_bg/effect_frame5_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.node_imgHead:addChild( skeletonNode )

    self.node_imgHead:setScaleX(0.75)
    self.node_imgHead:setScaleY(0.75)
end

--房间射灯动画右
function C:loadRoomBG_RightAnimation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_light_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"qznn_hall_effect_light1",true)
	self.node_bg_right:addChild( skeletonNode )

    self.node_bg_right:setScaleX(0.88)
    self.node_bg_right:setScaleY(0.88)
end

--房间射灯动画左
function C:loadRoomBG_LeftAnimation()
	local strAnimName ="base/animation/skeleton/qznn/qznn_hall_effect_light_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"qznn_hall_effect_light2",true)
	self.node_bg_left:addChild( skeletonNode )

    self.node_bg_left:setScaleX(0.88)
    self.node_bg_left:setScaleY(0.88)
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
	--print("--------------OnGameItem_2  is  called!!!--------------")
    hallCore:enterGameRoom(self.items[3])
end

--点击进入高级房
function C:OnGameItem_3( event )
	--print("--------------OnGameItem_3  is  called!!!--------------")
    hallCore:enterGameRoom(self.items[4])
end

--点击进入至尊房
function C:OnGameItem_4( event )
	--print("--------------OnGameItem_4  is  called!!!--------------")
    hallCore:enterGameRoom(self.items[5])
end

--点击进入王者房
function C:OnGameItem_5( event )
	--print("--------------OnGameItem_5  is  called!!!--------------")
    if(self.items[6] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[6])
    end
end

return QZNNRoomScene