--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

local C = class("DDZRoomCore",CoreBase)
DDZRoomCore = C

C.MODULE_PATH = "app.base.gameroom.ddz"
C.SCENE_CONFIG = {scenename = "DDZRoomScene", filename = "DDZRoomScene"}

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	self.scene:initialize()
end

---回到大厅
function C:showZJHRoomLayer()
	require("app.init")
	HallCore.new():run()
end

return DDZRoomCore
