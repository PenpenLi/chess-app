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
	self.progressBar = self.progressImg:getChildByName("progress_bar")
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
	elseif gameId == GAMEID_BRQZNN then
		return {path="base/images/main_layer/dt_game_jcby.png"}
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

return GameItemClass