--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local hallCore = require("app.base.hall.HallCore")

local C = class("HBRoomScene",SceneBase)
HBRoomScene = C
C.jsmjHelpLayer = nil
-- 资源名
C.RESOURCE_FILENAME = "base/HBRoom.csb"

C.RESOURCE_BINDING = {
	--返回按钮
	btn_back = {path="node_back.btn_back",events={{event="click",method="OnBack"}}},
    node_back = {path="node_back"},
    --帮助按钮
	btn_help = {path="node_help.btn_help",events={{event="click",method="OnHelp"}}},
    node_help = {path="node_help"},
    --记录按钮
	btn_record = {path="node_record.btn_record",events={{event="click",method="OnRecord"}}},
    node_record = {path="node_record"},
	--体验房
	btn_gameItem_0 = {path="right_panel.gameItem_0.Button",events={{event="click",method="OnGameItem_0"}}},
    --初级房
	btn_gameItem_1 = {path="right_panel.gameItem_1.Button",events={{event="click",method="OnGameItem_1"}}},
    --中级房
	btn_gameItem_2 = {path="right_panel.gameItem_2.Button",events={{event="click",method="OnGameItem_2"}}},
    --高级房
	btn_gameItem_3 = {path="right_panel.gameItem_3.Button",events={{event="click",method="OnGameItem_3"}}},
    --node_gameItem_3 = {path="right_panel.gameItem_3"},
  

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

    label_0 = {path="right_panel.gameItem_0.node_label.label_0"},
    label_1 = {path="right_panel.gameItem_1.node_label.label_0"},
    label_2 = {path="right_panel.gameItem_2.node_label.label_0"},
    label_3 = {path="right_panel.gameItem_3.node_label.label_0"},

    txt_id = {path="top_panel.txt_id"},
    label_money = {path="top_panel.label_0"},
}

C.offsetX = (display.width-1136)/2

C.items = {}
C.gameId = GAMEID_HB


function C:initialize()
    --适配宽度代码 1136为设计分辨率宽度
	self.hairOffsetX = GET_PHONE_HAIRE_WIDTH()
	self.resourceNode:setPositionX(self.offsetX)
    self.node_back:setPositionX(self.node_back:getPositionX() + self.offsetX)
    self.node_help:setPositionX(self.node_help:getPositionX() + self.offsetX)
    self.node_record:setPositionX(self.node_record:getPositionX() + self.offsetX)


    self.top_panel:setPositionX(self.top_panel:getPositionX() - self.offsetX)
    --self.img_head:setVisible(false)
    --self.btn_help:setVisible(false)
    --self.btn_record:setVisible(false)
    --self.node_gameItem_3:setVisible(false)

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
    self:loadHeadBGAnimation()

    self.girlAni:setScaleX(1.3)
    self.girlAni:setScaleY(1.3)
    self.item_ani_0:setScaleX(0.88)
    self.item_ani_0:setScaleY(0.88)
    self.item_ani_1:setScaleX(0.88)
    self.item_ani_1:setScaleY(0.88)
    self.item_ani_2:setScaleX(0.88)
    self.item_ani_2:setScaleY(0.88)
    self.item_ani_3:setScaleX(0.88)
    self.item_ani_3:setScaleY(0.88)

    self.label_0:setString("红包限额50-250")       --体验房底注、准入
    self.label_1:setString("红包限额50-250")       --初级房底注、准入
    self.label_2:setString("红包限额50-250")       --中级房底注、准入
    self.label_3:setString("红包限额50-250")       --高级房底注、准入

    self.txt_id:setString("ID:" .. dataManager.userInfo.playerid)
    self.txt_id:setFontSize(26)
    self.label_money:setString(dataManager.userInfo.money/MONEY_SCALE)
end

--进入场景
function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--播放背景音乐
	PLAY_MUSIC(BASE_SOUND_RES.."bg_room_ermj.mp3")
end

--红包扫雷女孩动画
function C:loadQZNNGirlAnimation()
	local strAnimName ="base/animation/skeleton/hb/xlch_effect_hall_girl_skea"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.girlAni:addChild( skeletonNode )
end

--红包扫雷00
function C:loadQZNN01Animation()
	local strAnimName ="base/animation/skeleton/hb/br_hall_effect1_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_0:addChild( skeletonNode )
end

--红包扫雷01
function C:loadQZNN02Animation()
	local strAnimName ="base/animation/skeleton/hb/br_hall_effect2_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_1:addChild( skeletonNode )
end

--红包扫雷02
function C:loadQZNN03Animation()
	local strAnimName ="base/animation/skeleton/hb/br_hall_effect3_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_2:addChild( skeletonNode )
end

--红包扫雷03
function C:loadQZNN04Animation()
	local strAnimName ="base/animation/skeleton/hb/br_hall_effect4_ske"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"newAnimation",true)
	self.item_ani_3:addChild( skeletonNode )
end


--红包扫雷头像背景动画
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
	--print("--------------OnGameItem_2  is  called!!!--------------")
    hallCore:enterGameRoom(self.items[3])
end

--点击进入高级房
function C:OnGameItem_3( event )
	--print("--------------OnGameItem_3  is  called!!!--------------")
    if(self.items[4] == nil) then
        toastLayer:show("房间暂未开放！！",3)
    else
        hallCore:enterGameRoom(self.items[4])
    end
end

return HBRoomScene