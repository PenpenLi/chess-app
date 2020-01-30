module("platform",package.seeall)
luaj = require("cocos.cocos2d.luaj")

JAVA_CLASS_NAME = "org/cocos2dx/lua/LuaJavaBridge"

-----------方法签名------------
-- I                    整数
-- F                    浮点数
-- Z                    布尔值
-- Ljava/lang/String;   字符串
-- V                    Void空
-------------------------------
--注册网络监听 handler(status) 0:无网络 1:WiFi 2:蜂窝网
function registerNetworkHandler( handler )
    -- body
end

--注销网络监听
function unregisterNetworkHandler( handler )
    -- body
end

--注销所有网络监听
function unregisterAllNetworkHandler()
    -- body
end

--TODO:注册OpenUrl处理
function registerOpenUrlHandler( handler )
    local args = { handler }
    local sigs = "(I)V"
    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "RegisterOpenUrlHandler", args, sigs)
    if not ok then
        printInfo("====call java RegisterOpenUrlHandler failed!")
    else
        printInfo("====call java RegisterOpenUrlHandler success!")
    end
end

--是否是模拟器
function isSiumlator()
	local args = { nil }
    local sigs = "()Z"
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/lua/LuaJavaBridge"
    local ok,ret = luaj.callStaticMethod(className, "isVm", args, sigs)
    if not ok then
    	printInfo("====call java isSiumlator failed!")
    	return false
    else
    	printInfo("====call java isSiumlator success!")
    	return ret
    end
end

--获取设备UUID
function getUUID()
	local args = { nil }
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "GetUuid", args, sigs)
    if not ok then
    	printInfo("====call java getUUID failed!")
    	return ""
    else
    	printInfo("====call java getUUID success!")
    	return ret
    end
    
end

--设置粘贴板内容
function setClipboardText( text )
	local args = { text }
    local sigs = "(Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "SetCopy", args, sigs)
    if not ok then
        printInfo("====call java SetCopy failed!")
    else
        printInfo("====call java SetCopy success!")
    end
end

--获取粘贴板内容
function getClipboardText()
	local args = { nil }
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "GetCopy", args, sigs)
    if not ok then
    	printInfo("====call java getClipboardText failed!")
        return ""
    else
    	printInfo("====call java getClipboardText success!")
        return ret
    end
end

--浏览器打开URL
function openUrl( url )
	local args = { url }
    local sigs = "(Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "OpenUrl", args, sigs)
    if not ok then
        printInfo("====call java openUrl failed!")
    else
        printInfo("====call java openUrl success!")
    end
end

--是否已安装微信客户端
function isInstallWechat()
	local args = { nil }
    local sigs = "()Z"
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "IsInstallWechat", args, sigs)
    if not ok then
    	printInfo("====call java isInstallWechat failed!")
        return false
    else
    	printInfo("====call java isInstallWechat success!")
        return ret
    end
end

--获取设备类型
function getDeviceType()
	local args = { nil }
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "GetAndroidDeviceType", args, sigs)
    if not ok then
    	printInfo("====call java getDeviceType failed!")
        return ""
    else
    	printInfo("====call java getDeviceType success!")
        return ret
    end
end

--获取当前网络状态
function getCurrentNetworkType()
	local args = { nil }
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "GetCurrentConnectType", args, sigs)
    if not ok then
    	printInfo("====call java getCurrentNetworkType failed!")
        return CONST_NET_TYPE_UNKNOWN
    else
    	printInfo("====call java getCurrentNetworkType success!")
        return ret
    end
end

--当前网络是否连接
function isNetworkAvailable()
	local args = { nil }
    local sigs = "()Z"    
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "IsNetworkAvailable", args, sigs)
    if not ok then
    	printInfo("====call java isNetworkAvailable failed!")
        return true
    else
    	printInfo("====call java isNetworkAvailable success!")
        return ret
    end
end

--打开应用（qq,wx,zfb）
function openApp( appName )
	local args = { nil }
    local sigs = "(Ljava/lang/String;Ljava/lang/String;)V"
    if appName == "qq" then
        args = { "com.tencent.mobileqq","com.tencent.mobileqq.activity.SplashActivity" }
    elseif appName == "wx" then
        args = { "com.tencent.mm","com.tencent.mm.ui.LauncherUI" }
    elseif appName == "zfb" then
        args = { "com.eg.android.AlipayGphone","com.eg.android.AlipayGphone.AlipayLogin" }
    else
        args = { "com.tencent.mm","com.tencent.mm.ui.LauncherUI" }
    end

    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "OpenApp", args, sigs)
    if not ok then
    	printInfo("====call java openApp failed!")
    else
    	printInfo("====call java openApp success!")
    end
end

--获取电量百分比 0-100
function getBatteryLevel()
    local args = { nil }
    local sigs = "()I"
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/lua/LuaJavaBridge"
    local ok,ret = luaj.callStaticMethod(className, "GetBatteryPercent", args, sigs)
    if not ok then
    	return 100
    else
    	return ret
    end
end

--获取电池状态 0:未知 1:未充电 2:充电中（小于100%） 3:充电中（已满100%）
function getBatteryState()
    local args = { nil }
    local sigs = "()I"
    local luaj = require "cocos.cocos2d.luaj"
    local className = "org/cocos2dx/lua/LuaJavaBridge"
    local ok,ret = luaj.callStaticMethod(className, "GetBatteryStatus", args, sigs)
    if not ok then
    	return 1
    else
        if ret > 2 then
            ret = 1
        end
    	return ret
    end
end

--获取推广渠道号
function getPromotionId()
	local args = { nil }
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "GetPromotionId", args, sigs)
    if not ok then
        return 0
    else
        return tonumber(ret) or 0
    end
end

--生成二维码
function createQRCode( url,width,filePath )
    local methodName = "CreateQRCode"
    local args = {url,width,filePath}
    local sig = "(Ljava/lang/String;ILjava/lang/String;)Z"
    local ok, ret = luaj.callStaticMethod(JAVA_CLASS_NAME, methodName, args, sig)
    if ok and ret then
        printInfo("====call java CreateQRCode success!")
        return true
    else
        printInfo("====call java CreateQRCode failed!")
        return false
    end
end

--注册微信AppId
function registerWechatAppId( appId )
    local args = { appId }
    local sigs = "(Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "RegisterWechatAppId", args, sigs)
    if not ok then
        printInfo("====call java RegisterWechatAppId failed!")
    else
        printInfo("====call java RegisterWechatAppId success!")
    end
end

--发起微信登录
function sendWechatLogin( handler )
    local args = {handler}
    local sig = "(I)V"
    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "SendWechatLoginReq", args, sig)
    if not ok then
        printInfo("====call java SendWechatLoginReq failed!")
    else
        printInfo("====call java SendWechatLoginReq success!")
    end
end

--微信分享
--type:1=文字，2=图片，3=音乐，4=视频，5=网页，6=小程序
--scene:0=聊天界面，1=朋友圈，2=收藏，3=指定联系人
--info:参数信息
function shareToWechat( ctype, scene, info )
    if not ctype or not scene or not info then
        return
    end
    info.type = ctype
    info.scene = scene
    local jsonString = json.encode(info)
    printInfo("===================shareToWechat============:"..tostring(jsonString))
    local args = { jsonString }
    local sigs = "(Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod(JAVA_CLASS_NAME, "ShareToWechat", args, sigs)
    if not ok then
        printInfo("====call java ShareToWechat failed!")
    else
        printInfo("====call java ShareToWechat success!")
    end
end

--发起定位
function startLocation( handler )
    if not handler then
        return
    end
    local args = {handler}
    local sig = "(I)V"
    local ok, ret = luaj.callStaticMethod(JAVA_CLASS_NAME, "StartLocation", args, sig)
    if not ok then
        printInfo("====call java StartLocation failed!")
    else
        printInfo("====call java StartLocation success!")
    end
end

--保存图片到相册
function saveImage( handler,filePath )
    if not handler or not filePath then
        return
    end
    local methodName = "SaveImage"
    local args = {handler,filePath}
    local sig = "(ILjava/lang/String;)V"
    local ok, ret = luaj.callStaticMethod(JAVA_CLASS_NAME, methodName, args, sig)
    if not ok then
        printInfo("====call java SaveImage failed!")
    else
        printInfo("====call java SaveImage success!")
    end
end

--从相册或者相机获取图片 ctype: 1=相册 2=相机
function getImage( handler,ctype,filePath,size )
    if not handler or not filePath then
        return
    end
    local methodName = "GetImage"
    local args = {handler,ctype,filePath,size}
    local sig = "(IILjava/lang/String;I)V"
    local ok, ret = luaj.callStaticMethod(JAVA_CLASS_NAME, methodName, args, sig)
    if not ok then
        printInfo("====call java GetImage failed!")
    else
        printInfo("====call java GetImage success!")
    end
end

--更新APP handler(status,msg,percent)
function updateApp( appVer,appUrl,handler )
    if not appVer or not appUrl or not handler then
        return
    end
    local methodName = "UpdateApp"
    local args = {appVer,appUrl,handler}
    local sig = "(ILjava/lang/String;I)V"
    local ok, ret = luaj.callStaticMethod(JAVA_CLASS_NAME, methodName, args, sig)
    if not ok then
        printInfo("====call java UpdateApp failed!")
    else
        printInfo("====call java UpdateApp success!")
    end
end





































