local C = class("GameSceneBase",SceneBase)
GameSceneBase = C

C.model = nil
C.logic = nil
C.define = nil
--子游戏场景需要显示电量信息，需要赋值
--电量进度
C.__batteryBar = nil
--是否充电标识
C.__batteryLighting = nil
--充值
C.rechargeLayer = nil

local BETTERY_NODE_CSB = "common/BatteryNode.csb"

--加载资源
function C:loadResource()
	-- body
end

--卸载资源
function C:unloadResource()
	-- body
end

--初始化页面
function C:initialize()
    --body
end

function C:onEnter()
    C.super.onEnter(self)
    self:loadResource()
    self:initialize()
    self.core:start()
    local posY = 540
    if self.model.roomInfo.gameid == GAMEID_FISH then
    	posY = 680
    elseif self.model.roomInfo.gameid == GAMEID_FRUIT then
    	posY = 700
    end
    SET_ROLL_ANNOUNCE_PARENT_POSY(self,posY)
end

function C:onExit()
	if self.model.timerName then
		utils:removeTimer(self.model.timerName)
	end
	if self.rechargeLayer then
		self.rechargeLayer:release()
		self.rechargeLayer = nil
	end
	HIDE_ROLL_ANNOUNCE()
	self:unloadResource()
	self.logic = nil
	self.define = nil
	self.model = nil
	C.super.onExit(self)
end

--服务器其座位号转本地座位号
function C:getLocalSeatId( seatId )
	local localSeatId = seatId - self.model.mySeatId
	if localSeatId < 0 then
		localSeatId = localSeatId + self.model.PLAYER_MAX
	end
	return localSeatId+1
end

--绑定电池节点
function C:bindBatteryNode( node )
	if node then
		local batteryNode = cc.CSLoader:createNode(BETTERY_NODE_CSB)
		node:addChild(batteryNode)
		self.__batteryBar = batteryNode:getChildByName("battery_img"):getChildByName("bar")
		self.__batteryLighting = batteryNode:getChildByName("battery_img"):getChildByName("lighting")
	end
end

--更新电池状态
function C:updateBattery()
	local isCharging = utils:isBatteryCharging()
	if self.__batteryBar and tolua.type(self.__batteryBar) == "ccui.LoadingBar" then
		local percent = utils:getBatteryPercent()
		self.__batteryBar:setPercent(percent)
		if percent < 20 then
			self.__batteryBar:loadTexture(COMMON_IMAGES_RES.."battery_dead.png")
		else
			if isCharging then
				self.__batteryBar:loadTexture(COMMON_IMAGES_RES.."battery_charging.png")
			else
				self.__batteryBar:loadTexture(COMMON_IMAGES_RES.."battery_bar.png")
			end
		end
	end
	if self.__batteryLighting and self.__batteryLighting["setVisible"] then
		self.__batteryLighting:setVisible(isCharging)
	end
end

--显示游戏规则
function C:showRule()
	local gameId = self.model.roomInfo.gameid
	if gameId == GAMEID_BRNN then
		local level = 1
		if self.model.roomInfo.orderid == 90 then
			level = 2
		end
		SHOW_GAME_RULE(gameId,level)
	else
    	SHOW_GAME_RULE(gameId)
    end
end

--显示设置弹窗
function C:showSettings()
    SHOW_SETTINGS()
end

--玩家点击返回退出游戏
function C:touchBack(tip)
    if self.model.isGaming then
    	DialogLayer.new():show(tip or "您已参与游戏，不能退出！")
        -- DialogLayer.new():show(tip or "退出后将由系统代打且不能进入其他游戏,您确定要退出吗？",function( isOk )
        --     if isOk then
        --         self.core:quitGame()
        --     end
        -- end)
    else
        self.core:quitGame()
    end
end

function C:touchRecharge()
	self.core:requestRechargeConfig()
end

function C:showRechargeLayer( info )
	if self.rechargeLayer == nil then
		self.rechargeLayer = RechargeLayer.new()
		self.rechargeLayer:retain()
	end
	self.rechargeLayer:show(info)
end

return GameSceneBase