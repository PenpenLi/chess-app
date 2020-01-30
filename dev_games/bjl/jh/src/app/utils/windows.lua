module("platform",package.seeall)

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

--注册OpenUrl处理
function registerOpenUrlHandler( handler )
end

--是否是模拟器
function isSiumlator()
	return false
end

--获取设备UUID
function getUUID()
	return GetWinUuid()
end

--设置粘贴板内容
function setClipboardText( text )
	SetWinCopy(text)
end

--获取粘贴板内容
function getClipboardText()
	return GetWinCopy()
end

--浏览器打开URL
function openUrl( url )
	OpenWinUrl(url)
end

--是否已安装微信客户端
function isInstallWechat()
	return false
end

--获取设备类型
function getDeviceType()
	return "windows"
end

--获取当前网络状态
function getCurrentNetworkType()
	return CONST_NET_TYPE_WIFI
end

--当前网络是否连接
function isNetworkAvailable()
	return true
end

--打开应用（qq,wx,zfb）
function openApp( appName )
	-- body
end

--获取电量百分比 0-100
function getBatteryLevel()
    return 20
end

--获取电池状态 0:未知 1:未充电 2:充电中（小于100%） 3:充电中（已满100%）
function getBatteryState()
    return 0
end

--获取推广渠道号
function getPromotionId()
	return 0
end

--生成二维码
function createQRCode( url,width,filePath )
    return false
end

--TODO:注册微信AppId
function registerWechatAppId( appId )
    -- body
end

--发起微信登录
function sendWechatLogin( handler )
end

--微信分享
--type:1=文字，2=图片，3=音乐，4=视频，5=网页，6=小程序
--scene:0=聊天界面，1=朋友圈，2=收藏，3=指定联系人
--info:参数信息
function shareToWechat( ctype, scene, info )
end

--TODO:发起定位
function startLocation( handler )
    -- body
end























