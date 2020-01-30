package.loaded["app.base.announce.AnnounceDetailLayer"] = nil
package.loaded["app.base.announce.AnnounceGainedLayer"] = nil
package.loaded["app.base.announce.AnnounceLayer"] = nil
package.loaded["app.base.announce.AnnounceUngainedLayer"] = nil
package.loaded["app.base.bank.BankLayer"] = nil
package.loaded["app.base.exchange.ExchangeLayer"] = nil
package.loaded["app.base.exchange.YinhangkaLayer"] = nil
package.loaded["app.base.exchange.ZhifubaoLayer"] = nil
package.loaded["app.base.hall.GameItemClass"] = nil
package.loaded["app.base.hall.HallCore"] = nil
package.loaded["app.base.hall.HallScene"] = nil
package.loaded["app.base.hall.QmdlLayer"] = nil
package.loaded["app.base.hall.QmdlHelpLayer"] = nil
package.loaded["app.base.hall.QmdlPopupLayer"] = nil
package.loaded["app.base.hall.RoomItemClass"] = nil
package.loaded["app.base.hall.XsjlLayer"] = nil
package.loaded["app.base.hall.ZcsjLayer"] = nil
package.loaded["app.base.huodong.HuodongLayer"] = nil
package.loaded["app.base.login.LoginCore"] = nil
package.loaded["app.base.login.LoginLayer"] = nil
package.loaded["app.base.login.SmsLoginLayer"] = nil
package.loaded["app.base.login.LoginScene"] = nil
package.loaded["app.base.login.ModifyLayer"] = nil
package.loaded["app.base.login.RegisterLayer"] = nil
package.loaded["app.base.login.ResetLayer"] = nil
package.loaded["app.base.login.SwitchLayer"] = nil
package.loaded["app.base.personal.HeadLayer"] = nil
package.loaded["app.base.personal.PersonalLayer"] = nil
package.loaded["app.base.rank.RankLayer"] = nil
package.loaded["app.base.rank.RankRuleLayer"] = nil
package.loaded["app.base.recharge.ProxyLayer"] = nil
package.loaded["app.base.recharge.RechargeLayer"] = nil
package.loaded["app.base.service.ServiceLayer"] = nil

require("app.base.announce.AnnounceDetailLayer")
require("app.base.announce.AnnounceGainedLayer")
require("app.base.announce.AnnounceLayer")
require("app.base.announce.AnnounceUngainedLayer")
require("app.base.bank.BankLayer")
require("app.base.exchange.ExchangeLayer")
require("app.base.exchange.YinhangkaLayer")
require("app.base.exchange.ZhifubaoLayer")
require("app.base.hall.GameItemClass")
require("app.base.hall.HallCore")
require("app.base.hall.HallScene")
require("app.base.hall.QmdlLayer")
require("app.base.hall.QmdlHelpLayer")
require("app.base.hall.QmdlPopupLayer")
require("app.base.hall.RoomItemClass")
require("app.base.hall.XsjlLayer")
require("app.base.hall.ZcsjLayer")
require("app.base.huodong.HuodongLayer")
require("app.base.login.LoginCore")
require("app.base.login.LoginLayer")
require("app.base.login.SmsLoginLayer")
require("app.base.login.LoginScene")
require("app.base.login.ModifyLayer")
require("app.base.login.RegisterLayer")
require("app.base.login.ResetLayer")
require("app.base.login.SwitchLayer")
require("app.base.personal.HeadLayer")
require("app.base.personal.PersonalLayer")
require("app.base.rank.RankLayer")
require("app.base.rank.RankRuleLayer")
require("app.base.recharge.ProxyLayer")
require("app.base.recharge.RechargeLayer")
require("app.base.service.ServiceLayer")

function ENTER_HALL()
    if SCENE_NAME == "Hall" then
        return
    end
	HallCore.new():run()
    SCENE_NAME = "Hall"
    eventManager:publish("ExitGame")
    if dataManager.setLoginStatus then
        dataManager:setLoginStatus(1)
    end
end

function ENTER_HALL_ROOM( gameId )
    if SCENE_NAME == "Hall" then
        return
    end
	HallCore.new(gameId):run()
    SCENE_NAME = "Hall"
    eventManager:publish("ExitGame")
    if dataManager.setLoginStatus then
        dataManager:setLoginStatus(1)
    end
end

function ENTER_LOGIN()
    if SCENE_NAME == "Login" then
        return
    end
	LoginCore.new():run()
    SCENE_NAME = "Login"
    eventManager:publish("ExitGame")
    if dataManager.setLoginStatus then
        dataManager:setLoginStatus(2)
    end
end

function ENTER_GAME(gameId,roomInfo)
	local game = require(GAMECORE_CONFIGS[gameId]).new(roomInfo)
    if game then
        SCENE_NAME = "Game"
        game:run()
        game.gameId = gameId
        print(GAMECORE_CONFIGS[gameId].." require success")
    else
        print(GAMECORE_CONFIGS[gameId].." is invalid")
    end
    return game
end

--获取手机刘海高度，调整大厅或者游戏里面被刘海挡住的UI
function GET_PHONE_HAIRE_WIDTH()
    local width = 0
    local scale = math.floor(display.height/display.width*10)
    if device.platform == "ios" and scale < 5 then
        width = 40
    end
    return width
end

--是否支持捕鱼水果机
function SUPPORT_FISH_FRUIT()
    local flags = true
    if device.platform == "ios" and (CHANNEL_ID == 2 or CHANNEL_ID == 7 or CHANNEL_ID == 17) then
        flags = false
    end
    return flags
end

--是否支持微信登录/分享
function SUPPORT_WECHAT()
    local flags = true
    if device.platform == "ios" and (CHANNEL_ID == 2 or CHANNEL_ID == 7 or CHANNEL_ID == 17) then
        flags = false
    end
    return flags
end

--是否支持定位
function SUPPORT_LOCATION()
    local flags = true
    if device.platform == "ios" and (CHANNEL_ID == 2 or CHANNEL_ID == 7 or CHANNEL_ID == 17) then
        flags = false
    end
    return flags
end

function SUPPORT_CAMERA()
    local flags = true
    if device.platform == "ios" and (CHANNEL_ID == 2 or CHANNEL_ID == 7 or CHANNEL_ID == 17 or CHANNEL_ID == 15 or CHANNEL_ID == 18) then
        flags = false
    end
    return flags
end