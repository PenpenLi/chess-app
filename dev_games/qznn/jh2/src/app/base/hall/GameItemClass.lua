local C = class("GameItemClass")
GameItemClass = C

C.node = nil
C.updateImg = nil
C.progressImg = nil
C.progressBar = nil
C.itemBtn = nil
C.callback = nil
C.gameId = nil

function C:ctor( node, callback )
	self.node = node
	self.updateImg = self.node:getChildByName("update_img")
	self.progressImg = self.node:getChildByName("progress_img")
	self.progressLabel = self.progressImg:getChildByName("progress_label")
	self.progressLabel:setLocalZOrder(20)
	self.itemBtn = self.node:getChildByName("item_btn")
	self.callback = callback
	self.itemBtn:onTouch(function( event )
		self:onTouchItemBtn(event)
	end)
	self.node:setVisible(true)
	self.updateImg:setVisible(false)
	self.progressImg:setVisible(false)
end

function C:setGameId( gameId )
	self.gameId = gameId
	local info = self:getGameInfo(self.gameId)
	if info == nil then
		return
	end
	local img =display.newSprite(info.path)
	local pos = cc.p(self.node:getContentSize().width/2,self.node:getContentSize().height/2)
	img:setPosition(pos)
	self.node:addChild(img,-1)
	local boxSprite = display.newSprite(BASE_IMAGES_RES.."main_layer/update_cd.png")
	self.progressTimer = cc.ProgressTimer:create(boxSprite)
	self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	self.progressTimer:setReverseDirection(false)
	self.progressTimer:setAnchorPoint(cc.p(0.5,0.5))
	self.progressTimer:setMidpoint(cc.p(0.5,0.5))
	self.progressTimer:setPosition(cc.p(self.progressImg:getContentSize().width/2,self.progressImg:getContentSize().height/2))
	self.progressImg:addChild(self.progressTimer,10)
end

function C:getGameInfo( gameId )
	if gameId == GAMEID_ZJH then
		return {path="base/images/main_layer/dt_game_zjh.png"}
	elseif gameId == GAMEID_QZNN then
		return {path="base/images/main_layer/dt_game_qznn.png"}
	elseif gameId == GAMEID_LHD then
		return {path="base/images/main_layer/dt_game_lhd.png"}
	elseif gameId == GAMEID_HHDZ then
		return {path="base/images/main_layer/dt_game_hhdz.png"}
	elseif gameId == GAMEID_FISH  then
		return {path="base/images/main_layer/dt_game_jsby.png"}
	elseif gameId == GAMEID_MAJIANG then
		return {path="base/images/main_layer/dt_game_ermj.png"}
	elseif gameId == GAMEID_DDZ then
		return {path="base/images/main_layer/dt_game_ddz.png"}
	elseif gameId == GAMEID_BRNN then
		return {path="base/images/main_layer/dt_game_brnn.png"}
	elseif gameId == GAMEID_CPDDZ then
		return {path="base/images/main_layer/dt_game_cpddz.png"}
	elseif gameId == GAMEID_FRUIT then
		return {path="base/images/main_layer/dt_game_fruit.png"}
	elseif gameId == GAMEID_HB then
		return {path="base/images/main_layer/dt_game_hb.png"}
	elseif gameId == GAMEID_BRQZNN then
		return {path="base/images/main_layer/dt_game_brqznn.png"}
	elseif gameId == GAMEID_JSMJ then
		return {path="base/images/main_layer/dt_game_jsmj.png"}
	elseif gameId == GAMEID_HB then
		return {path="base/images/main_layer/dt_game_hb.png"}
	elseif gameId == GAMEID_PDK then
		return {path="base/images/main_layer/dt_game_pdk.png"}
	elseif gameId == GAMEID_JSYS then
		return {path="base/images/main_layer/dt_game_jsys.png"}
	elseif gameId == GAMEID_HCCC then
		return {path="base/images/main_layer/dt_game_hccc.png"}
	else
		return nil
	end
end

function C:onTouchItemBtn( event )
	if event.name == "began" then
		self.node:setScale(1.05)
	elseif event.name == "moved" then
	elseif event.name == "ended" then
		PLAY_SOUND_CLICK()
		self.node:setScale(1)
		if self.callback then
			self.callback(self.gameId)
		end
	elseif event.name == "cancelled" then
		self.node:setScale(1)
	end
end

function C:showWaitting()
	local strAnimName = BASE_ANIMATION_RES.."skeleton/waitting/shang"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    local pos = cc.p(self.node:getContentSize().width/2,self.node:getContentSize().height/2)
    skeletonNode:setPosition(pos)
    skeletonNode:setTag(10000)
    skeletonNode:setAnimation(0,"animation",true)
	self.node:addChild( skeletonNode )
end

function C:hideWaitting()
	local skeletonNode = self.node:getChildByTag(10000)
	if skeletonNode then
		skeletonNode:removeFromParent(true)
	end
end

function C:showGameProgress(percent)
	self.progressImg:setVisible(true)
	self.progressTimer:setPercentage(percent)
	if percent>0 then
		self.progressLabel:setString(math.ceil(percent).."%")
	else
		self.progressLabel:setString("等待中")
	end
end

function C:hideGameProgress()
	self.progressImg:setVisible(false)
end

return GameItemClass