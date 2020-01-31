

local C = class("QZPJRoomCore",CoreBase)
QZPJRoomCore = C

C.MODULE_PATH = "app.base.gameroom.qzpj"
C.SCENE_CONFIG = {scenename = "QZPJRoomScene", filename = "QZPJRoomScene"}

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	self.scene:initialize()
end

return QZPJRoomCore
