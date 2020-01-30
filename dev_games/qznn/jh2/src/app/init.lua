package.loaded["app.config"] = nil
package.loaded["app.channel"] = nil
package.loaded["app.define"] = nil
package.loaded["app.proto.Constant"] = nil
package.loaded["app.proto.Protocals"] = nil
package.loaded["app.utils.init"] = nil
package.loaded["app.network.NetConnect"] = nil
package.loaded["app.network.ServerList"] = nil
package.loaded["app.manager.DataManager"] = nil
package.loaded["app.manager.EventManager"] = nil
package.loaded["app.manager.HallManager"] = nil
package.loaded["app.manager.GameManager"] = nil
package.loaded["packages.mvc.init"] = nil
package.loaded["app.common.init"] = nil
package.loaded["app.base.init"] = nil

local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
customEventDispatch:removeAllEventListeners()
customEventDispatch:addEventListenerWithFixedPriority(cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",function () eventManager:publish("OnPause") end), 1)
customEventDispatch:addEventListenerWithFixedPriority(cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",function () eventManager:publish("OnResume") end), 1)

--!!!注意:禁止随意调整加载顺序
require("app.config")
require("app.channel")
require("app.define")
require("app.version")
require("app.proto.Constant")
require("app.proto.Protocals")
require("app.utils.init")
require("app.network.NetConnect")
require("app.network.ServerList")
require("app.manager.DataManager")
require("app.manager.EventManager")
require("app.manager.HallManager")
require("app.manager.GameManager")
require("packages.mvc.init")
require("app.common.init")
require("app.base.init")

function ENTER_UPDATE()
	--清除所有定时器
    if utils and utils.removeAllTimers then
		utils:removeAllTimers()
	end
	UpdateCore.new():run()
    SCENE_NAME = "Update"
end