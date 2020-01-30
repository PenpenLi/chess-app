--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local hallCore = require("app.base.hall.HallCore")

local C = class("SanGongRoomScene",SceneBase)
SanGongRoomScene = C
C.qznnHelpLayer = nil
-- 资源名
C.RESOURCE_FILENAME = "base/SanGongRoom.csb"

C.RESOURCE_BINDING = {
    right_bg = {path="right_bg"},
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
    bg_top = {path="bg_top"},
    img_head = {path="top_panel.img_head"},

    huaAni = {path="huaAni"},
    girlAni = {path="girlAni"},
    item_ani_0 = {path="right_panel.gameItem_0.item_ani"},
    item_ani_1 = {path="right_panel.gameItem_1.item_ani"},
    item_ani_2 = {path="right_panel.gameItem_2.item_ani"},
    item_ani_3 = {path="right_panel.gameItem_3.item_ani"},
    item_ani_4 = {path="right_panel.gameItem_4.item_ani"},
    item_ani_5 = {path="right_panel.gameItem_5.item_ani"},

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
C.gameId = GAMEID_SANGONG


function C:initialize()
    --适配宽度代码 1136为设计分辨率宽度
	self.hairOffsetX = GET_PHONE_HAIRE_WIDTH()
	self.resourceNode:setPositionX(self.offsetX)
    self.right_bg:setPositionX(self.right_bg:getPositionX() + self.offsetX)
    self.btn_back:setPositionX(self.btn_back:getPositionX() + self.offsetX)
    self.btn_help:setPositionX(self.btn_help:getPositionX() + self.offsetX)
    self.btn_record:setPositionX(self.btn_record:getPositionX() + self.offsetX)

    self.bg_top:setScaleX(display.width/1136)
    self.top_panel:setPositionX(self.top_panel:getPositionX() - self.offsetX)
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

    self.huaAni:setScaleX(0.88)
    self.huaAni:setScaleY(0.88)
    self.girlAni:setScaleX(0.7)
    self.girlAni:setScaleY(0.7)
    self.item_ani_0:setScaleX(0.8)
    self.item_ani_0:setScaleY(0.8)
    self.item_ani_1:setScaleX(0.8)
    self.item_ani_1:setScaleY(0.8)
    self.item_ani_2:setScaleX(0.8)
    self.item_ani_2:setScaleY(0.8)
    self.item_ani_3:setScaleX(0.8)
    self.item_ani_3:setScaleY(0.8)
    self.item_ani_4:setScaleX(0.8)
    self.item_ani_4:setScaleY(0.8)
    self.item_ani_5:setScaleX(0.8)
    self.item_ani_5:setScaleY(0.8)

    if(self.items[1] ~= nil) then
        self.label_0:setString(self.items[1].name/MONEY_SCALE)       --体验房底注
        self.label_1:setString(self.items[1].money/MONEY_SCALE)       --体验房准入
    end
    if(self.items[2] ~= nil) then
        self.label_2:setString(self.items[2].name/MONEY_SCALE)       --初级房底注
        self.label_3:setString(self.items[2].money/MONEY_SCALE)       --初级房准入
    end
    if(self.items[3] ~= nil) then
        self.label_4:setString(self.items[3].name/MONEY_SCALE)       --中级房底注
        self.label_5:setString(self.items[3].money/MONEY_SCALE)       --中级房准入
    end
    if(self.items[4] ~= nil) then
        self.label_6:setString(self.items[4].name/MONEY_SCALE)       --高级房底注
        self.label_7:setString(self.items[4].money/MONEY_SCALE)       --高级房准入
    end
    if(self.items[5] ~= nil) then
        self.label_8:setString(self.items[5].name/MONEY_SCALE)       --至尊房底注
        self.label_9:setString(self.items[5].money/MONEY_SCALE)       --至尊房准入
    end
    if(self.items[6] ~= nil) then
        self.label_10:setString(self.items[6].name/MONEY_SCALE)       --王者房底注
        self.label_11:setString(self.items[6].money/MONEY_SCALE)       --王者房准入
    end
    
    self.txt_id:setString("ID:" .. dataManager.userInfo.playerid)
    self.txt_id:setFontSize(24)
    self.label_money:setString(dataManager.userInfo.money/MONEY_SCALE)
end

--进入场景
function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--播放背景音乐
	PLAY_MUSIC(BASE_SOUND_RES.."bg_room_qznn.mp3")
end

--三公女孩动画
function C:loadQZNNGirlAnimation()
	local strAnimName ="base/animation/skeleton/sangong/SG_effect_hallgirl_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.girlAni:addChild( skeletonNode )

    local strAnimName2 ="base/animation/skeleton/sangong/SG_effect_hall_ske"
    local skeletonNode2 = sp.SkeletonAnimation:create(strAnimName2 .. ".json", strAnimName2 .. ".atlas", 1)
    skeletonNode2:setAnimation(0,"newAnimation1",true)
	self.huaAni:addChild( skeletonNode2 )
end

--三公00
function C:loadQZNN01Animation()
	local strAnimName ="base/animation/skeleton/sangong/sg_effect_hall1_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_0:addChild( skeletonNode )
end

--三公01
function C:loadQZNN02Animation()
	local strAnimName ="base/animation/skeleton/sangong/sg_effect_hall2_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_1:addChild( skeletonNode )
end

--三公02
function C:loadQZNN03Animation()
	local strAnimName ="base/animation/skeleton/sangong/sg_effect_hall3_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_2:addChild( skeletonNode )
end

--三公03
function C:loadQZNN04Animation()
	local strAnimName ="base/animation/skeleton/sangong/sg_effect_hall4_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_3:addChild( skeletonNode )
end

--三公04
function C:loadQZNN05Animation()
	local strAnimName ="base/animation/skeleton/sangong/sg_effect_hall5_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_4:addChild( skeletonNode )
end

--三公05
function C:loadQZNN06Animation()
	local strAnimName ="base/animation/skeleton/sangong/sg_effect_hall6_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_5:addChild( skeletonNode )
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
	if(self.items[1] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[1])
    end
end

--点击进入初级房
function C:OnGameItem_1( event )
	if(self.items[2] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[2])
    end
end

--点击进入中级房
function C:OnGameItem_2( event )
	if(self.items[3] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[3])
    end
end

--点击进入高级房
function C:OnGameItem_3( event )
	if(self.items[4] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[4])
    end
end

--点击进入至尊房
function C:OnGameItem_4( event )
	if(self.items[5] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[5])
    end
end

--点击进入王者房
function C:OnGameItem_5( event )
    if(self.items[6] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[6])
    end
end

return SanGongRoomScene