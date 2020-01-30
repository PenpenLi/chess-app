package.loaded["app.common.sound"] = nil
package.loaded["app.common.BaseLayer"] = nil
package.loaded["app.common.DialogLayer"] = nil
package.loaded["app.common.GameModelBase"] = nil
package.loaded["app.common.GameCoreBase"] = nil
package.loaded["app.common.GameSceneBase"] = nil
package.loaded["app.common.LoadingLayer"] = nil
package.loaded["app.common.SettingsLayer"] = nil
package.loaded["app.common.ToastLayer"] = nil
package.loaded["app.common.WebLayer"] = nil
package.loaded["app.common.RuleLayer"] = nil
package.loaded["app.common.ViewBaseClass"] = nil
package.loaded["app.common.RolledAnnounceLayer"] = nil

require("app.common.sound")
require("app.common.BaseLayer")
require("app.common.DialogLayer")
require("app.common.GameModelBase")
require("app.common.GameCoreBase")
require("app.common.GameSceneBase")
require("app.common.LoadingLayer")
require("app.common.SettingsLayer")
require("app.common.ToastLayer")
require("app.common.WebLayer")
require("app.common.RuleLayer")
require("app.common.ViewBaseClass")
require("app.common.RolledAnnounceLayer")

if loadingLayer then
	loadingLayer:release()
end
loadingLayer = LoadingLayer.new()
loadingLayer:retain()

if toastLayer then
	toastLayer:release()
end
toastLayer = ToastLayer.new()
toastLayer:retain()

if settingsLayer then
	settingsLayer:release()
end
settingsLayer = SettingsLayer.new()
settingsLayer:retain()

if webLayer then
	webLayer:release()
end
webLayer = WebLayer.new()
webLayer:retain()

if ruleLayer then
	ruleLayer:release()
end
ruleLayer = RuleLayer.new()
ruleLayer:retain()

if rolledAnnounceLayer then
	rolledAnnounceLayer:release()
end
rolledAnnounceLayer = RolledAnnounceLayer.new()
rolledAnnounceLayer:retain()

function GET_HEADID_RES( headId )
	if headId < 1 then
		headId = 1
	elseif headId > COMMON_HEAD_MAX then
		headId = COMMON_HEAD_MAX
	end
	return string.format(COMMON_HEAD_RES.."head_%02d.png",tonumber(headId))
end

function GET_FRAMEID_RES( frameId )
	return string.format(COMMON_FRAME_RES.."frame_%02d.png",tonumber(frameId))
end

function SHOW_GAME_RULE( gameId,level )
	ruleLayer:show(gameId,level)
end

function SHOW_SETTINGS()
	settingsLayer:show()
end

function SET_ROLL_ANNOUNCE_PARENT_POSY(parent,posY )
	rolledAnnounceLayer:setAnnounceParentAndPosY(parent,posY)
end

function SHOW_ROLL_ANNOUNCE( info )
	if SCENE_NAME == "Hall" or SCENE_NAME == "Game" then
		rolledAnnounceLayer:show(info)
	end
end

function HIDE_ROLL_ANNOUNCE()
	rolledAnnounceLayer:hide(true)
end