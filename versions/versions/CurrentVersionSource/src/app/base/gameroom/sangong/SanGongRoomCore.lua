--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local C = class("SanGongRoomCore",CoreBase)
SanGongRoomCore = C

C.MODULE_PATH = "app.base.gameroom.sangong"
C.SCENE_CONFIG = {scenename = "SanGongRoomScene", filename = "SanGongRoomScene"}

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	self.scene:initialize()

    self.configsResultHandler = function(s) 
    	loadingLayer:hide() 
		self.rechargeLayer = RechargeLayer.new()
		self.rechargeLayer:retain()
        self.rechargeLayer:show(s,2) 
   	end
    eventManager:on("ConfigResult",self.configsResultHandler)
end

---回到大厅
function C:showZJHRoomLayer()
	require("app.init")
	HallCore.new():run()
end

function C:exit()
    eventManager:off("ConfigResult",self.configsResultHandler)
end

return SanGongRoomCore
