local GameItemClass = import(".GameItemClass")
local RoomItemClass = import(".RoomItemClass")
local C = class("HallScene",SceneBase)

C.RESOURCE_FILENAME = "base/HallScene.csb"
C.RESOURCE_BINDING = {
	--top panel
	headNode = {path="top_panel.head_node"},
	topImg = {path="top_panel.top_img"},
	headImg = {path="top_panel.head_node.head_img"},
	frameImg = {path="top_panel.head_node.frame_img"},
	headBtn = {path="top_panel.head_node.head_btn",events={{event="click",method="onClickHeadBtn"}}},
	nameImg = {path="top_panel.head_node.name_img"},
	idLabel = {path="top_panel.head_node.name_img.label"},
	blanceNode = {path="top_panel.blance_node"},
	blanceLabel = {path="top_panel.blance_node.blance_label"},
	rechargeBtn = {path="top_panel.blance_node.recharge_btn",events={{event="click",method="onClickRechargeBtn"}}},
	rechargeBtn2 = {path="top_panel.blance_node.recharge_btn2",events={{event="click",method="onClickRechargeBtn"}}},
	announceBtn = {path="top_panel.announce_btn",events={{event="click",method="onClickAnnounceBtn"}}},
	announceRedDot = {path="top_panel.announce_btn.dot_img"},
	serviceBtn = {path="top_panel.service_btn",events={{event="click",method="onClickServiceBtn"}}},
	serviceRedDot = {path="top_panel.service_btn.dot_img"},
	--bottom panel
	bottomPanel = {path="bottom_panel"},
	bottomImg = {path="bottom_panel.bottom_img"},
	rankBtn = {path="bottom_panel.rank_panel.rank_btn",events={{event="click",method="onClickRankBtn"}}},
	bankBtn = {path="bottom_panel.bank_panel.bank_btn",events={{event="click",method="onClickBankBtn"}}},
	exchangeBtn = {path="bottom_panel.exchange_panel.exchange_btn",events={{event="click",method="onClickExchangeBtn"}}},
	exchangeRotateImg = {path="bottom_panel.exchange_panel.exchange_img2"},
	moneyPanel = {path="bottom_panel.money_panel"},
	moneyBtn = {path="bottom_panel.money_panel.money_btn",events={{event="click",method="onClickMoneyBtn"}}},
	moneySkeletonNode = {path="bottom_panel.money_panel.skeleton_node"},
	proxyPanel = {path="bottom_panel.proxy_panel"},
	proxyBtn = {path="bottom_panel.proxy_panel.proxy_btn",events={{event="click",method="onClickProxyBtn"}}},
	rechargePanel = {path="bottom_panel.recharge_panel"},
	rechargeBtn3 = {path="bottom_panel.recharge_panel.recharge_btn",events={{event="touch",method="onTouchRechargeBtn"}}},
	rechargeSkeletonNode = {path="bottom_panel.recharge_panel.skeleton_node"},
	--center panel
	centerPanel = {path="center_panel"},
	centerScrollview = {path="center_panel.scrollview",events={{event="event",method="onEventCenterScrollView"}}},
	leftPanel = {path="center_panel.scrollview.left_panel"},
	pageview = {path="center_panel.scrollview.left_panel.pageview",events={{event="event",method="onEventPageView"}}},
	pageDot1 = {path="center_panel.scrollview.left_panel.dot_1"},
	pageDot2 = {path="center_panel.scrollview.left_panel.dot_2"},
	rightPanel = {path="center_panel.scrollview.right_panel"},
	gameItem = {path="item"},
	pageItem = {path="page_1"},
	pageItem2 = {path="page_2"},
	arrowLeftBtn = {path="center_panel.arrow_left_btn",events={{event="click",method="onClickArrowLeftBtn"}}},
	arrowRightBtn = {path="center_panel.arrow_right_btn",events={{event="click",method="onClickArrowRightBtn"}}},
	--room panel
	roomPanel = {path="room_panel"},
	roomTitleNode = {path="room_panel.top_panel.title_node"},
	roomHelpBtn = {path="room_panel.top_panel.title_node.help_btn",events={{event="click",method="onClickRoomHelpBtn"}}},
	roomTitleImg = {path="room_panel.top_panel.title_node.title_img"},
	roomCloseBtn = {path="room_panel.top_panel.close_btn",events={{event="click",method="onClickRoomCloseBtn"}}},
	roomListPanel = {path="room_panel.list_panel"}
}

C.gameItemClassArr = nil
C.gameId = nil
C.offsetX = (display.width-1136)/2
C.hairOffsetX = 0

function C:onEnter()
	C.super.onEnter(self)
	PLAY_BACKGROUND_MUSIC()
	SET_ROLL_ANNOUNCE_PARENT_POSY(self,540) 
end

function C:onExit()
	self:stopPageTimer()
	STOP_BACKGROUND_MUSIC()
	HIDE_ROLL_ANNOUNCE()
	self.gameItemClassArr = nil
	self:unloadResource()
	eventManager:off("s2cConfig",self.onConfigInfoHandler)
	C.super.onExit(self)
end

--加载资源
function C:loadResource()
	-- body
end

--卸载资源
function C:unloadResource()
	audio.unloadSound(BASE_SOUND_RES.."bg.mp3")
end

function C:initialize()
    --适配
    self:adjustUI()
	--top panel
	self.announceRedDot:setVisible(false)
	self.serviceRedDot:setVisible(false)
	--center panel
	self.gameItem:setVisible(false)
	self.pageItem:setVisible(false)
	self.pageItem2:setVisible(false)
	self.arrowLeftBtn:setVisible(false)
	self.arrowRightBtn:setVisible(false)
	self:updatePageview()
	self:loadPaySkelentonAnimation()
	--room panel
	self.roomPanel:setVisible(false)
	self:onConfigInfo()
	self.onConfigInfoHandler = handler(self,self.onConfigInfo)
    eventManager:on("s2cConfig",self.onConfigInfoHandler)
end

function C:adjustUI()
	--适配宽度代码 1136为设计分辨率宽度
	self.hairOffsetX = GET_PHONE_HAIRE_WIDTH()
	self.resourceNode:setPositionX(self.offsetX)
	self.topImg:setContentSize(cc.size(display.width,self.topImg:getContentSize().height))
	self.headNode:setPositionX(self.headNode:getPositionX()-self.offsetX)
	self.blanceNode:setPositionX(self.blanceNode:getPositionX()-self.offsetX)
	self.announceBtn:setPositionX(self.announceBtn:getPositionX()+self.offsetX)
	self.serviceBtn:setPositionX(self.serviceBtn:getPositionX()+self.offsetX)
	self.bottomPanel:setContentSize(cc.size(display.width,self.bottomPanel:getContentSize().height))
	--self.bottomImg:setContentSize(cc.size(display.width,self.bottomImg:getContentSize().height))
	self.rechargePanel:setPositionX(display.width)
	self.centerPanel:setContentSize(cc.size(display.width,self.centerPanel:getContentSize().height))
	self.centerScrollview:setContentSize(cc.size(display.width,self.centerScrollview:getContentSize().height))
	self.leftPanel:setPositionX(self.hairOffsetX)
	self.rightPanel:setPositionX(self.hairOffsetX+323)
	self.arrowLeftBtn:setPositionX(10+self.hairOffsetX)
	self.arrowRightBtn:setPositionX(display.width)
	self.roomPanel:setContentSize(cc.size(display.width,self.roomPanel:getContentSize().height))
	--self.roomTitleNode:setPositionX(self.roomTitleNode:getPositionX()-self.offsetX)
	self.roomListPanel:setContentSize(cc.size(display.width,self.roomListPanel:getContentSize().height))
end

function C:onEventCenterScrollView( event )
	if self.roomPanel:isVisible() then
		return
	end
	local layer = self.centerScrollview:getInnerContainer()
	local offsetX = layer:getPositionX()
	if offsetX >= 0 then
		self:hideLeftArrow()
		if not self.arrowRightBtn:isVisible() then
			self:showRightArrow()
		end
	elseif offsetX <= self.centerScrollview:getContentSize().width-self.centerScrollview:getInnerContainerSize().width then
		self:hideRightArrow()
		if not self.arrowLeftBtn:isVisible() then
			self:showLeftArrow()
		end
	end
end

function C:showArrowIfNeeded()
	local layer = self.centerScrollview:getInnerContainer()
	local offsetX = layer:getPositionX()
	if offsetX <= -100 then
		self:showLeftArrow()
	end
	if offsetX > self.centerScrollview:getContentSize().width-self.centerScrollview:getInnerContainerSize().width then
		self:showRightArrow()
	end
end

function C:showLeftArrow()
	if self.gameItemClassArr == nil then
		return
	end
	local count = #self.gameItemClassArr
	if count < 9 then
		return
	end
	self:hideLeftArrow()
	self.arrowLeftBtn:setVisible(true)
	local moveLeft1 = cc.EaseOut:create(cc.MoveTo:create(0.5, cc.p(self.hairOffsetX, 302)), 0.5)
	local moveLeft2 = cc.EaseIn:create(cc.MoveTo:create(0.5, cc.p(self.hairOffsetX+10, 302)), 0.5)
	local leftAction = transition.sequence({
			moveLeft1,
			moveLeft2,
			moveLeft1,
			moveLeft2,
			moveLeft1,
			moveLeft2,
			cc.DelayTime:create(8)
		})
	self.arrowLeftBtn:runAction(cc.RepeatForever:create(leftAction))
end

function C:hideLeftArrow()
	self.arrowLeftBtn:stopAllActions()
	self.arrowLeftBtn:setVisible(false)
	self.arrowLeftBtn:setPosition(self.hairOffsetX+10,302)
end

function C:showRightArrow()
	if self.gameItemClassArr == nil then
		return
	end
	-- local count = #self.gameItemClassArr
	-- if count < 9 then
	-- 	return
	-- end
	self:hideRightArrow()
	self.arrowRightBtn:setVisible(true)
	local moveRight1 = cc.EaseOut:create(cc.MoveTo:create(0.5, cc.p(display.width, 302)), 0.5)
	local moveRight2 = cc.EaseIn:create(cc.MoveTo:create(0.5, cc.p(display.width-10, 302)), 0.5)
	local rightAction = transition.sequence({
			moveRight1,
			moveRight2,
			moveRight1,
			moveRight2,
			moveRight1,
			moveRight2,
			cc.DelayTime:create(8)
		})
	self.arrowRightBtn:runAction(cc.RepeatForever:create(rightAction))
end

function C:hideRightArrow()
	self.arrowRightBtn:stopAllActions()
	self.arrowRightBtn:setVisible(false)
	self.arrowRightBtn:setPosition(display.width-10,302)
end

--配置信息返回
function C:onConfigInfo()
	local items = self.pageview:getItems()
	--是否显示官网地址
	local showHomeUrl = true
	if tonumber(dataManager.officalwebdisplay) ~= 1 then
		showHomeUrl = false
	end
	--是否显示二维码
	local showQrcode = true
	if dataManager.configs and dataManager.configs.IsShowCode and tonumber(dataManager.configs.IsShowCode) ~= 1 then
		showQrcode = false
	end
	for i,v in ipairs(items) do
		if v:getTag() == 2 then
			v:getChildByName("label"):setVisible(showHomeUrl)
		end
		if v:getTag() == 1 then
			v:getChildByName("qrcode"):setVisible(showQrcode)
			local resname = BASE_IMAGES_RES.."main_layer/official_url_logo2.png"
			if showQrcode then
				resname = BASE_IMAGES_RES.."main_layer/copy_qrcode.png"
			end
			v:getChildByName("img"):loadTexture(resname)
		end
	end

	--获取配置的官网地址/生成官网二维码
	if dataManager.configs == nil or dataManager.configs.Url == nil or dataManager.configs.Url == "" then
		return
	end
	--官网地址
	local text = dataManager.configs.Url
	if #text > 22 then
		text = string.gsub(text,"http://","")
		text = string.gsub(text,"https://","")
	end
	text = string.lower(text)
	--二维码
	local isFileExist = false
	local fileName = Md5.sumhexa(tostring(text))..".png"
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        isFileExist = true
    else
        local storagePath = DOWNLOAD_PATH.."res/"..fileName
        local result = utils:createQRCode(text,256,storagePath)
        if result then
            isFileExist = true
        end
    end
	
	for i,v in ipairs(items) do
		if v:getTag() == 2 then
			v:getChildByName("label"):setString(text)
			local width = v:getChildByName("label"):getContentSize().width
			local scale = 290/width
			if scale > 1 then
				scale = 1
			end
			v:getChildByName("label"):setScale(scale)
		end
		if v:getTag() == 1 and isFileExist then
			v:getChildByName("qrcode"):loadTexture(fileName)
		end
	end
end

function C:copyHomeUrl()
	if dataManager.configs == nil or dataManager.configs.Url == nil or dataManager.configs.Url == "" then
		return
	end
	utils:setCopy(tostring(dataManager.configs.Url))
	toastLayer:show("官网地址已复制成功，欢迎推荐给您的好友")
end

function C:loadPaySkelentonAnimation()
	local strAnimName = "base/animation/skeleton/recharge/chongzhi"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setAnimation(0,"animation",true)
	self.rechargeSkeletonNode:addChild( skeletonNode )
end

function C:addPage( pIdx )
	local newPage = nil
	if pIdx == 1 then
		newPage = self.pageItem:clone()
	else
		newPage = self.pageItem2:clone()
		local btn = newPage:getChildByName("btn")
		btn:onClick(function( event )
            self:copyHomeUrl()
		end)
	end
	newPage:onTouch(function( event )
		self:onTouchPageview(event)
	end)
	newPage:setVisible(true)
	newPage:setTag(pIdx)
	self.pageview:addPage(newPage)
end

function C:updatePageview()
	self.pageview:removeAllPages()
	self:addPage(2,0)
	self:addPage(1,1)
	self:addPage(2,2)
	self:addPage(1,3)
	self:addPage(2,4)
	self:addPage(1,5)
	self:addPage(2,6)
	self.pageview:setCurrentPageIndex(3)
	self.pageDot1:loadTexture("base/images/main_layer/dot1.png")
	self.pageDot2:loadTexture("base/images/main_layer/dot2.png")
	self:startPageTimer()
end

function C:startPageTimer()
	self:stopPageTimer()
	utils:createTimer("hall.pagetimer",10,function()
		local index = self.pageview:getCurrentPageIndex() + 1
		if index > 6 then
			index = 3
		end
		self.pageview:scrollToPage(index,0.5)
		if index%2 == 0 then
			self.pageDot1:loadTexture("base/images/main_layer/dot2.png")
			self.pageDot2:loadTexture("base/images/main_layer/dot1.png")
		else
			self.pageDot1:loadTexture("base/images/main_layer/dot1.png")
			self.pageDot2:loadTexture("base/images/main_layer/dot2.png")
		end
	end)
end

function C:stopPageTimer()
	utils:removeTimer("hall.pagetimer")
end

function C:onTouchPageview( event )
	if event.name == "began" then
		self:stopPageTimer()
	elseif event.name == "cancelled" then
		if 0 == self.pageview:getCurrentPageIndex() then
			self.pageview:scrollToPage(2,0)
		elseif 6 == self.pageview:getCurrentPageIndex() then
			self.pageview:scrollToPage(4,0)
		end
		self:startPageTimer()
	elseif event.name == "ended" then
		if event.target:getTag()==2 then
			PLAY_SOUND_CLICK()
            self:copyHomeUrl()
		end
		self:startPageTimer()
	end
end

function C:onEventPageView( event )
	if event.name == "TURNING" then
		if 1 == self.pageview:getCurrentPageIndex() then
			self.pageview:scrollToPage(3,0)
		elseif 5 == self.pageview:getCurrentPageIndex() then
			self.pageview:scrollToPage(3,0)
		end
		if self.pageview:getCurrentPageIndex()%2 == 0 then
			self.pageDot1:loadTexture("base/images/main_layer/dot2.png")
			self.pageDot2:loadTexture("base/images/main_layer/dot1.png")
		else
			self.pageDot1:loadTexture("base/images/main_layer/dot1.png")
			self.pageDot2:loadTexture("base/images/main_layer/dot2.png")
		end
	end
end

function C:showGameItems( items )
	self:hideLeftArrow()
	self:hideRightArrow()
	self.centerScrollview:setScrollBarEnabled(false)
	--self.centerScrollview:setBounceEnabled(false)
	self.centerScrollview:setTouchTotalTimeThreshold(0.2)
	self.rightPanel:removeAllChildren()
	self.gameItemClassArr = {}
	local count = #items
	for i=1,count do
		local node = self.gameItem:clone()
		local gameItemClass = GameItemClass.new(node,function( gameId )
			self:onClickGameItem(gameId)
		end)
		local gameId = items[i]
		gameItemClass:setGameId(gameId)
		local pos = self:getGameItemPosition(i)
		gameItemClass.node:setPosition(pos)
		self.rightPanel:addChild(gameItemClass.node)
		local isOpen = self:isGameOpening(gameId)
		if isOpen == false then
			gameItemClass:showWaitting()
		end
		-- gameItemClass.updateImg:setVisible(true)
		-- gameItemClass.progressImg:setVisible(true)
		table.insert(self.gameItemClassArr,gameItemClass)
	end
	local cols = math.ceil(count/2)
	local width = cols*210
	if width < display.width-343-self.hairOffsetX then
		width = display.width-343-self.hairOffsetX
	end
	width = width+20
	local height = self.rightPanel:getContentSize().height
	self.rightPanel:setContentSize(cc.size(width,height))
	width = width+self.rightPanel:getPositionX()
	self.centerScrollview:setInnerContainerSize(cc.size(width,height))
	if width > display.width-343 then
		self:showRightArrow()
	end
end

--判断游戏是否开发
function C:isGameOpening( gameId )
	local isOpen = false
	for k,v in pairs(dataManager.gamelist) do
		if v.gameid == gameId then
			isOpen = true
			break
		end
	end
	return isOpen
end

--获取游戏位置
-- 01  03  05  07  09  11  13  15  17
-- 02  04  06  08  10  12  14  16  18
function C:getGameItemPosition( index )
	local upY = 310
	local downY = 105
	local x = 105
	local y = upY
	if index%2 == 0 then
		y = downY
	end
	local cols = math.ceil(index/2)
	x = x+(cols-1)*210
	return cc.p(x,y)
end

--点击游戏
function C:onClickGameItem( gameId )
	self.core:didSelectedGame( gameId, true )
end

--显示更新标识
function C:showGameUpdateFlag( gameId )
	for k,v in pairs(self.gameItemClassArr) do
		if v.gameId == gameId then
			v.updateImg:setVisible(true)
			return
		end
	end
end

--隐藏更新标识
function C:hideGameUpdateFlag( gameId )
	for k,v in pairs(self.gameItemClassArr) do
		if v.gameId == gameId then
			v.updateImg:setVisible(false)
			return
		end
	end
end

--设置更新进度 0-100
function C:showGameProgress( gameId, percent )
	for k,v in pairs(self.gameItemClassArr) do
		if v.gameId == gameId then
			v.progressImg:setVisible(true)
			v.progressBar:setPercent(percent)
			return
		end
	end
end

--隐藏游戏进度条
function C:hideGameProgress( gameId )
	for k,v in pairs(self.gameItemClassArr) do
		if v.gameId == gameId then
			v.progressImg:setVisible(false)
			v.progressBar:setPercent(0)
			return
		end
	end
end

--显示房间列表
function C:showRoomLayer( gameId, items, animation )
	self.gameId = gameId
	self:createRoom( gameId, items )
	if animation == true then
		self:hallOutAni()
		self:roomInAni()
	else
		self:hideHall()
		self:showRoom()
	end
end

--创建房间列表
function C:createRoom( gameId, items )
	local titleName = nil
	if gameId == GAMEID_ZJH then
		titleName = "base/images/room_layer/zjh_title.png"
	elseif gameId == GAMEID_QZNN then
		titleName = "base/images/room_layer/qznn_title.png"
	elseif gameId == GAMEID_DDZ then
		titleName = "base/images/room_layer/ddz_title.png"
	elseif gameId == GAMEID_BRNN then
		titleName = "base/images/room_layer/brnn_title.png"
	elseif gameId == GAMEID_CPDDZ then
		titleName = "base/images/room_layer/cpddz_title.png"
	elseif gameId == GAMEID_FISH then
		titleName = "base/images/room_layer/jsby_title.png"
	elseif gameId == GAMEID_FRUIT then
		titleName = "base/images/room_layer/fruit_title.png"
	elseif gameId == GAMEID_HB then
		titleName = "base/images/room_layer/hb_title.png"
	elseif gameId == GAMEID_BRQZNN then
		titleName = "base/images/room_layer/brqznn_title.png"
	elseif gameId == GAMEID_JSMJ then
		titleName = "base/images/room_layer/jsmj_title.png"
	elseif gameId == GAMEID_HB then
		titleName = "base/images/room_layer/hb_title.png"
	end
	if titleName then
		self.roomTitleImg:setTexture(titleName)
	end
	self.roomListPanel:removeAllChildren(true)
	local count = #items
	local padding = (self.roomListPanel:getContentSize().width-count*254)/(count+1)
	local x = padding + 254/2
	local y = -40
	for i=1,count do
		local roomInfo = items[i]
		local roomItemClass = RoomItemClass.new(i,roomInfo,function( roomInfo )
			self:onClickRoomItem(roomInfo)
		end)
		roomItemClass.node:setPosition(cc.p(x,y))
		self.roomListPanel:addChild(roomItemClass.node)
		x = x + padding + 254
	end
end

--大厅退出动画
function C:hallOutAni()
	self:hideLeftArrow()
	self:hideRightArrow()
	self.headNode:setPosition(75-self.offsetX,50)
	self.headNode:setVisible(true)
	self.headNode:runAction(transition.sequence({
		cc.MoveTo:create(0.2,cc.p(75-self.offsetX,150)),
		cc.CallFunc:create(function()
			self.announceBtn:setVisible(false)
		end)
	}))
	--top panel
	self.announceBtn:setPosition(992+self.offsetX,38)
	self.announceBtn:setVisible(true)
	self.announceBtn:runAction(transition.sequence({
		cc.MoveTo:create(0.2,cc.p(992+self.offsetX,150)),
		cc.CallFunc:create(function()
			self.announceBtn:setVisible(false)
		end)
	}))
	self.serviceBtn:setPosition(1076+self.offsetX,38)
	self.serviceBtn:setVisible(true)
	self.serviceBtn:runAction(transition.sequence({
		cc.MoveTo:create(0.2,cc.p(1076+self.offsetX,150)),
		cc.CallFunc:create(function()
			self.serviceBtn:setVisible(false)
		end)
	}))
	--left panel
	self.leftPanel:setPosition(self.hairOffsetX,0)
	self.leftPanel:setVisible(true)
	self.leftPanel:runAction(transition.sequence({
		cc.MoveTo:create(0.2,cc.p(-323,0)),
		cc.CallFunc:create(function()
			self.leftPanel:setVisible(false)
		end)
	}))
	--right panel
	self.rightPanel:setPosition(323+self.hairOffsetX,0)
	self.rightPanel:setVisible(true)
	self.rightPanel:runAction(transition.sequence({
		cc.MoveTo:create(0.25,cc.p(display.width,0)),
		cc.CallFunc:create(function()
			self.rightPanel:setVisible(false)
		end)
	}))
	--bottom panel
	self.bottomPanel:setPosition(568,0)
	self.bottomPanel:setVisible(true)
	self.bottomPanel:runAction(transition.sequence({
		cc.MoveTo:create(0.2,cc.p(568,-95)),
		cc.CallFunc:create(function()
			self.bottomPanel:setVisible(false)
		end)
	}))
end

function C:hallInAni()
	self.gameId = nil
	self:showArrowIfNeeded()
	self.headNode:setPosition(75-self.offsetX,150)
	self.headNode:setVisible(true)
	self.headNode:runAction( cc.MoveTo:create(0.25,cc.p(75-self.offsetX,50)) )
	--top panel
	self.announceBtn:setPosition(992+self.offsetX,150)
	self.announceBtn:setVisible(true)
	self.announceBtn:runAction( cc.MoveTo:create(0.25,cc.p(992+self.offsetX,38)) )
	self.serviceBtn:setPosition(1076+self.offsetX,150)
	self.serviceBtn:setVisible(true)
	self.serviceBtn:runAction( cc.MoveTo:create(0.25,cc.p(1076+self.offsetX,38)) )
	--left panel
	self.leftPanel:setPosition(-323,0)
	self.leftPanel:setVisible(true)
	self.leftPanel:runAction( cc.MoveTo:create(0.25,cc.p(self.hairOffsetX,0)) )
	--right panel
	self.rightPanel:setPosition(display.width,0)
	self.rightPanel:setVisible(true)
	self.rightPanel:runAction( cc.MoveTo:create(0.25,cc.p(323+self.hairOffsetX,0)) )
	--bottom panel
	self.bottomPanel:setPosition(568,-95)
	self.bottomPanel:setVisible(true)
	self.bottomPanel:runAction( cc.MoveTo:create(0.25,cc.p(568,0)) )
end

function C:roomInAni()
	self.roomPanel:setVisible(true)
	self.roomTitleNode:setPosition(264,140)
	self.roomTitleNode:runAction( cc.MoveTo:create(0.25, cc.p(264,50)) )
	self.roomCloseBtn:setPosition(44,140)
	self.roomCloseBtn:runAction( cc.MoveTo:create(0.25, cc.p(44,50)) )
	self.roomListPanel:setPosition(display.width,290)
	self.roomListPanel:runAction( transition.sequence({
		cc.DelayTime:create(0.1),
		cc.MoveTo:create(0.25,cc.p(0,290))
	}))
end

function C:showHall()
	self.gameId = nil
	self:showArrowIfNeeded()
	self.announceBtn:setPosition(992+self.offsetX,38)
	self.announceBtn:setVisible(true)
	self.serviceBtn:setPosition(1076+self.offsetX,38)
	self.serviceBtn:setVisible(true)
	self.leftPanel:setPosition(self.hairOffsetX,0)
	self.leftPanel:setVisible(true)
	self.rightPanel:setPosition(self.hairOffsetX+323,0)
	self.rightPanel:setVisible(true)
	self.bottomPanel:setPosition(568,0)
	self.bottomPanel:setVisible(true)
end

function C:hideHall()
	self.headNode:setVisible(false)
	self.announceBtn:setVisible(false)
	self.serviceBtn:setVisible(false)
	self.leftPanel:setVisible(false)
	self.rightPanel:setVisible(false)
	self:hideLeftArrow()
	self:hideRightArrow()
	self.bottomPanel:setVisible(false)
end

function C:showRoom()
	self.roomPanel:setVisible(true)
	self.roomListPanel:setPosition(0,290)
end

function C:hideRoom()
	self.roomPanel:setVisible(false)
end

--点击游戏房间
function C:onClickRoomItem( roomInfo )
	self.core:enterGameRoom(roomInfo)
end

--[[events]]
--点击头像
function C:onClickHeadBtn( event )
	self.core:showPersonalLayer()
	-- self:testSaveImage()
end

--TODO:测试保存图片/获取图片
function C:testSaveImage()
	--二维码
	local isFileExist = false
	local text = "http://www.jianghuyule16.com"--..tostring(os.time())
	local fileName = Md5.sumhexa(tostring(text))..".png"
	local storagePath = DOWNLOAD_PATH.."res/"..fileName
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        isFileExist = true
    else
        local result = utils:createQRCode(text,256,storagePath)
        if result then
            isFileExist = true
        end
    end
    if isFileExist then
    	utils:saveImage(storagePath,function( success )
    		if success == true or tonumber(success) == 1 then
    			toastLayer:show("保存成功")
    		else
    			toastLayer:show("保存失败，请检查相册权限是否开启",3)
    		end
    	end)
    end
end
function C:testGetImage(ctype)
	local fileName = tostring(os.time()).."temp_image.png"--"temp_image.png"--
	local filePath = DOWNLOAD_PATH.."res/"..fileName
	if cc.FileUtils:getInstance():isFileExist(fileName) then
		self.headImg:loadTexture(fileName)
	end
	utils:getImage(ctype,filePath,200,function( success )
		if success == true or tonumber(success) == 1 then
			self.headImg:loadTexture(fileName)
		else
			if ctype == 1 then
				toastLayer:show("获取失败，请检查相册权限是否开启",3)
			else
				toastLayer:show("获取失败，请检查相机权限是否开启",3)
			end
		end
	end)
end

--点击充值
function C:onClickRechargeBtn( event )
	self.core:showRechargeLayer()
end

function C:onTouchRechargeBtn( event )
	if event.name == "began" then
        self.rechargeSkeletonNode:setScale(1.1)
    elseif event.name == "moved" then
    elseif event.name == "ended" then
        PLAY_SOUND_CLICK()
        self.rechargeSkeletonNode:setScale(1)
        self.core:showRechargeLayer()
    elseif event.name == "cancelled" then
        self.rechargeSkeletonNode:setScale(1)
    end
end

--点击公告
function C:onClickAnnounceBtn( event )
	self.core:showAnnounceLayer()
	-- self:testGetImage(1)
end

--点击客服
function C:onClickServiceBtn( event )
	self.core:showServiceLayer()
	-- self:testGetImage(2)
end

--点击排行榜
function C:onClickRankBtn( event )
	self.core:showRankLayer()
end

--点击保险箱
function C:onClickBankBtn( event )
	self.core:showBankLayer()
end

--点击兑换
function C:onClickExchangeBtn( event )
	self.core:showExchangeLayer()
end

--点击注册送金
function C:onClickMoneyBtn( event )
	self.core:showZcsjLayer()
end

--点击全民代理
function C:onClickProxyBtn( event )
	self.core:showQmdlLayer()
end

--点击箭头左按钮
function C:onClickArrowLeftBtn( event )
	self.centerScrollview:scrollToLeft(0.2,false)
	self:hideLeftArrow()
end

--点击箭头右按钮
function C:onClickArrowRightBtn( event )
	self.centerScrollview:scrollToRight(0.2,false)
	self:hideRightArrow()
end

--点击房间列表关闭按钮
function C:onClickRoomCloseBtn( event )
	self:hideRoom()
	self:hallInAni()
end

--点击房间列表帮助按钮
function C:onClickRoomHelpBtn( event )
	if self.gameId then
		SHOW_GAME_RULE(self.gameId,1)
	end
end

--[[scene api]]
--设置头像
function C:setHeadId( headId, headUrl )
    SET_HEAD_IMG(self.headImg,headId,headUrl)
end

--设置头像框
function C:setFrameId( frameId )
	local name = GET_FRAMEID_RES(frameId)
	self.frameImg:loadTexture(name)
end

--设置账号ID
function C:setAccount( account )
	self.idLabel:setString(tostring(account))
	-- local width = self.idLabel:getContentSize().width+25
	-- if width < 143 then
	-- 	width = 143
	-- end
	-- self.nameImg:setContentSize(cc.size(width,self.nameImg:getContentSize().height))
	-- local posX = self.headNode:getPositionX()+38+width+40
	-- self.blanceNode:setPositionX(posX)
end

--设置金币
function C:setBlance( blance )
	local string = utils:moneyString(blance,2)
	self.blanceLabel:setString(string)
	-- local width = self.blanceLabel:getContentSize().width
	-- if width < 140 then
	-- 	width = 140
	-- end
	-- width = width+100
	-- self.rechargeBtn2:setContentSize(cc.size(width,63))
	-- self.rechargeBtn:setPositionX(self.rechargeBtn2:getPositionX()+width-4)
end

--是否显示注册送金
function C:showZcsjTabBtn( showed )
	self.moneyPanel:setVisible(showed)
end

--是否显示全民代理
function C:showProxyTabBtn( showed )
	self.proxyPanel:setVisible(showed)
end

--公告小红点
function C:setAnnounceRedDot(visible)
    self.announceRedDot:setVisible(visible)
end

--客服小红点
function C:setServiceRedDot(visible)
    self.serviceRedDot:setVisible(visible)
end

return C
