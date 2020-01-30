local C = class("LoginCore",CoreBase)
LoginCore = C

C.MODULE_PATH = "app.base.login"
C.SCENE_CONFIG = {scenename = "LoginScene", filename = "LoginScene"}

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	self.scene:initialize()
end

return LoginCore
