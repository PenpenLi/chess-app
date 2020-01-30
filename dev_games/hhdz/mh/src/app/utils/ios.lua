module("platform",package.seeall)
luaoc = require("cocos.cocos2d.luaoc")

OC_CLASS_NAME = "LuaObjectCBridge"

--注册网络监听 handler(status) 0:无网络 1:WiFi 2:蜂窝网
function registerNetworkHandler( handler )
    if not handler then
        return
    end
    local ocMethodName = "registerNetworkHandler"
    local args = { handler = handler }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc registerNetworkHandler failed")
    else 
        printInfo("==== call oc registerNetworkHandler success")
    end
end

--注销网络监听
function unregisterNetworkHandler( handler )
    if not handler then
        return
    end
    local ocMethodName = "unregisterNetworkHandler"
    local args = { handler = handler }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc unregisterNetworkHandler failed")
    else 
        printInfo("==== call oc unregisterNetworkHandler success")
    end
end

--注销所有网络监听
function unregisterAllNetworkHandler()
    local ocMethodName = "unregisterAllNetworkHandler"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
        printInfo("==== call oc unregisterAllNetworkHandler failed")
    else 
        printInfo("==== call oc unregisterAllNetworkHandler success")
    end
end

--注册OpenUrl处理
function registerOpenUrlHandler( handler )
    if not handler then
        return
    end
    local ocMethodName = "registerOpenUrlHandler"
    local args = { handler = handler }
    local ok = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc registerOpenUrlHandler failed")
    else 
        printInfo("==== call oc registerOpenUrlHandler success")
    end
end

--是否是模拟器
function isSiumlator()
	return false
end

--获取设备UUID
function getUUID()
	local ocMethodName = "getUUID"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
        printInfo("==== call oc getUUID failed")
        return ""
    else
    	printInfo("==== call oc getUUID success")
        return ret
    end
end

--设置粘贴板内容
function setClipboardText( text )
	local ocMethodName = "setClipboardText"
    local args = {
        content = text
    }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
    	printInfo("==== call oc setClipboardText failed")
    else 
    	printInfo("==== call oc setClipboardText success")
    end
end

--获取粘贴板内容
function getClipboardText()
    local ocMethodName = "getClipboardText"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
        printInfo("==== call oc getClipboardText failed")
        return ""
    else
    	printInfo("==== call oc getClipboardText success")
        return ret
    end
end

--浏览器打开URL
function openUrl( url )
	local ocMethodName = "openUrl"
    local args = {
        url = url
    }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
    	printInfo("==== call oc openUrl failed")
    else 
    	printInfo("==== call oc openUrl success")
    end
end

--是否已安装微信客户端
function isInstallWechat()
	local ocMethodName = "isInstallWechat"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
    	printInfo("==== call oc isInstallWechat failed")
    	return false
    else 
    	printInfo("==== call oc isInstallWechat success")
    	return ret
    end
end

--获取设备类型
function getDeviceType()
	local ocMethodName = "getDeviceType"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
    	printInfo("==== call oc getDeviceType failed")
    	return "iOS"
    else 
    	printInfo("==== call oc getDeviceType success")
    	return ret
    end
end

--获取当前网络状态 0:无网络 1:WiFi 2:蜂窝网络(3G/4G)
function getCurrentNetworkType()
	local ocMethodName = "getCurrentNetworkType"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
    	printInfo("==== call oc getCurrentNetworkType failed")
    	return CONST_NET_TYPE_UNKNOWN
    else 
    	printInfo("==== call oc getCurrentNetworkType success")
    	return ret
    end
end

--当前网络是否连接
function isNetworkAvailable()
	local ocMethodName = "isNetworkAvailable"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
    	printInfo("==== call oc isNetworkAvailable failed")
    	return false
    else 
    	printInfo("==== call oc isNetworkAvailable success")
    	return ret
    end
end

--打开应用（qq,wx,zfb）
function openApp( appName )
	local ocMethodName = "openWX"
	if appName == "qq" then
		ocMethodName = "openQQ"
	elseif appName == "zfb" then
		ocMethodName = "openZFB"
	end
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
    	printInfo("==== call oc openApp failed")
    else 
    	printInfo("==== call oc openApp success")
    end
end

--获取电量百分比 0-100
function getBatteryLevel()
    local ocMethodName = "getBatteryLevel"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
        printInfo("==== call oc getBatteryLevel failed")
        return 0
    else 
        printInfo("==== call oc getBatteryLevel success")
        return ret
    end
end

--获取电池状态 0:未知 1:未充电 2:充电中（小于100%） 3:充电中（已满100%）
function getBatteryState()
    local ocMethodName = "getBatteryState"
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName)
    if not ok then
        printInfo("==== call oc getBatteryState failed")
        return 0
    else 
        printInfo("==== call oc getBatteryState success")
        return ret
    end
end

--苹果内购
function iosBuy(productid,price,playerid,itemName)
    local iosPayUrl = string.gsub(dataManager.payUrl, "/heepay", "")
    iosPayUrl = iosPayUrl.."/ApplepayOld"
    SetIOSPayInfo(iosPayUrl,0,"ApplepayOld")
    local args = { arg1 = tostring(productid), arg2 = price, arg3 = tostring(playerid), arg4 = itemName, arg5 = DEFAULT_IOS_PAY_URL .. "?userid=" .. tostring(playerid) .. "&amount=" .. price }
    local ok, ret = luaoc.callStaticMethod(OC_CLASS_NAME, "IOSBuy", args)
    if not ok then
        printInfo("Call LuaObjectCBridge:IOSBuy fail!")
    else
        printInfo("The ret is:", ret)
        return ret
    end
end

--内购回调
function CompletIOSBuy(itemStr)
    toastLayer:show("购买["..itemStr.."]成功")
end

--获取推广渠道号
function getPromotionId()
	return 0
end

--生成二维码
function createQRCode( url,width,filePath )
    if url == nil or width == nil or filePath == nil then
        return false
    end
    local args = { url=url, width=width, filePath=filePath }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, "createQRCode", args)
    if ok and ret then
        printInfo("==== call oc createQRCode success")
        return true
    else 
        printInfo("==== call oc createQRCode failed")
        return false
    end
end

--注册微信AppId
function registerWechatAppId( appId )
    if not appId then
        return
    end
    local ocMethodName = "registerWechatAppId"
    local args = { appId = appId }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc registerWechatAppId failed")
    else 
        printInfo("==== call oc registerWechatAppId success")
    end
end

--发起微信登录
function sendWechatLogin( handler )
    if not handler then
        return
    end
    local ocMethodName = "sendWechatLoginReq"
    local args = { handler = handler }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc sendWechatLoginReq failed")
    else 
        printInfo("==== call oc sendWechatLoginReq success")
    end
end

--type:1=文字，2=图片，3=音乐，4=视频，5=网页，6=小程序
--scene:0=聊天界面，1=朋友圈，2=收藏，3=指定联系人
--info:参数信息
function shareToWechat( ctype, scene, info )
    if not ctype or not scene or not info then
        return
    end
    local ocMethodName = "shareToWechat"
    info.type = ctype
    info.scene = scene
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, info)
    if not ok then
        printInfo("==== call oc shareToWechat failed")
    else 
        printInfo("==== call oc shareToWechat success")
    end
end

--发起定位
function startLocation( handler )
    if not handler then
        return
    end
    local ocMethodName = "startLocation"
    local args = { handler = handler }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc startLocation failed")
    else 
        printInfo("==== call oc startLocation success")
    end
end

--保存图片到相册
function saveImage( handler,filePath )
    if not handler or not filePath then
        return
    end
    local ocMethodName = "saveImage"
    local args = { handler = handler,filePath=filePath }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc saveImage failed")
    else 
        printInfo("==== call oc saveImage success")
    end
end

--从相册或者相机获取图片 ctype: 1=相册 2=相机
function getImage( handler,ctype,filePath,size )
    if not handler or not filePath then
        return
    end
    local ocMethodName = "getImage"
    local args = { handler = handler,type=ctype,filePath=filePath,size=size }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
        printInfo("==== call oc getImage failed")
    else 
        printInfo("==== call oc getImage success")
    end
end

--更新APP handler(resultString) resultString=status,msg,percent
--status: 1=更新中，2=更新失败，3=更新成功
function updateApp( appVer,appUrl,handler )
    if not appUrl or not handler then
        return
    end
    handler("3,finished,100")
    openUrl(appUrl)
end

