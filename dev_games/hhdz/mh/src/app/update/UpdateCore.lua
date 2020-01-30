require("app.init")
local C = class("UpdateCore",CoreBase)
UpdateCore = C

C.MODULE_PATH = "app.update"
C.SCENE_CONFIG = {scenename = "UpdateScene", filename = "UpdateScene"}
C.currentProgress = 0

local DOWNLOAD_SUCCESS = 1      --下载成功
local DECOMPRESS_SUCCESS = 2    --解压成功

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	--初始化场景
    SCENE_NAME = "Update"
    --创建download
    local fileUtil = cc.FileUtils:getInstance()
    if not fileUtil:isDirectoryExist(DOWNLOAD_PATH) then
        fileUtil:createDirectory(DOWNLOAD_PATH)
    end
    --创建download/res
    local downloadRes = DOWNLOAD_PATH.."res/"
    if not fileUtil:isDirectoryExist(downloadRes) then
        fileUtil:createDirectory(downloadRes)
    end
	self.scene:initialize()
    self:loadServerList()
    
    -- self.onResumeHandler = handler(self,self.needUpdateApp)
    -- eventManager:on("OnResume",self.onResumeHandler)
end

function C:exit()
    -- eventManager:off("OnResume",self.onResumeHandler)
    C.super.exit(self)
end

function C:loadServerList()
    self.scene:showTips(1);
    local function connectHallServerFinish(result)
        if result then
            --连接成功，开始登陆
            printInfo("=====连接成功")
            --主要是把大厅连接callback设置为HallManager里面方法处理
            eventManager:publish("EnterHall")
            local status = 0
            if dataManager.getLoginStatus then
                status = dataManager:getLoginStatus()
            end
            if status == 1 or (status == 0 and WECHAT_LOGIN_ENABLED == false ) then
                loadingLayer:show("正在登录...",120)
                --设置场景名字为登录中
                SCENE_NAME = "Logining"
                self.scene:showTips(4)
                eventManager:publish("QuickLogin")
            else
                loadingLayer:hide()
                ENTER_LOGIN()
            end
        else
            loadingLayer:hide()
            eventManager:publish("CloseNetworkDialog")
            local dialogLayer = DialogLayer.new(false)
            local text = "网络连接失败，请检查您的网络状态\n点击确定重启游戏"
            dialogLayer:show(text,function( isOk )
                self:loadServerList()
            end,"CloseNetworkDialog")
        end
    end

    local function getServerListFinish(result)
        if result then
            if dataManager.detectVm then
                if device:isVm() then
                    loadingLayer:hide()
                    utils:quitApp()
                end
            end

            if self:needUpdateApp() then
                return
            end

            if self:needUpdateBase() then
                self:startUpdateBase()
            else
                ConnectHallServer(connectHallServerFinish);
            end
        else
            loadingLayer:hide()
            eventManager:publish("CloseNetworkDialog")
            local dialogLayer = DialogLayer.new()
            local text = "网络连接失败，请检查您的网络状态\n点击确定重启游戏"
            dialogLayer:show(text,function( isOk )
                self:loadServerList()
            end,"CloseNetworkDialog")
        end
    end

    serverList:getServerList(getServerListFinish);
    loadingLayer:show("正在加载...",self.scene,100000)
end

--检查大厅是否需要更新
function C:needUpdateBase()
    if dataManager:getLocalBaseVersion() < dataManager.remoteBaseVersion then
        printInfo("本地版本："..dataManager:getLocalBaseVersion().." 服务器版本："..dataManager.remoteBaseVersion);
        return true;
    end
    return false;
end

--检查App是否需要更新
function C:needUpdateApp()
    local localAppVer = APP_VER or 1
    local remoteAppVer = dataManager.installver or 1
    local update = localAppVer < remoteAppVer and dataManager.installurl ~= nil and dataManager.installurl ~= "" and (device.platform == "ios" or device.platform == "android")
    if update then
        eventManager:publish("CloseUpdatekDialog")
        local text = "发现新版本，游戏体验更流畅\n请点击‘确定’按钮更新"
        if device.platform == "ios" then
            --注意中划线问题
            local index = string.find(dataManager.installurl,"itms%-services://")
            if index then
                text = "发现新版本,游戏体验更流畅\n点击‘确定’按钮，等待系统弹出安装提示后点击‘安装’，回到桌面查看安装状态，安装成功点击打开如果显示‘未受信任’，请按此操作手机【设置】->【通用】->【设备管理】找到游戏企业签名，点击信任之后即可打开游戏"
            else
                text = "发现新版本,游戏体验更流畅\n请点击‘确定’按钮前往官网下载"
            end
        end
        DialogLayer.new(false):show(text,function( isOk )
            self:updateApp()
        end,"CloseUpdatekDialog")
    end
    return update
end

function C:updateApp()
    local appVer = dataManager.installver or 1
    local appUrl = dataManager.installurl
    loadingLayer:show("正在更新...",self.scene,100000)
    self.scene:showTips(2);
    self.scene:setProgressBar(0)
    utils:updateApp(appVer,appUrl,function( resultString )
        local arr = utils:stringSplit(resultString,",")
        if #arr == 3 then
            local status = tonumber(arr[1])
            local msg = tostring(arr[2])
            local percent = tonumber(arr[3]) or 0
            if status == 1 or status == 3 then
                self.scene:setProgressBar(percent)
            else
                eventManager:publish("CloseUpdatekDialog")
                DialogLayer.new(false):show("更新失败，点击确定重试",function( isOk )
                    self:updateApp()
                end,"CloseUpdatekDialog")
            end
        else
            eventManager:publish("CloseUpdatekDialog")
            DialogLayer.new(false):show("更新失败，点击确定重试",function( isOk )
                self:updateApp()
            end,"CloseUpdatekDialog")
        end
    end)
end

function C:hallServerConnectCallback(success)
    if not success then
        loadingLayer:hide()
        toastLayer:hide()
        eventManager:publish("CloseNetworkDialog")
        DialogLayer.new():show("网络连接失败，请检查您的网络状态\n点击确定重新连接",function(ok) 
            ConnectHallServer(handler(self,self.hallServerConnectCallback)) 
        end,"CloseNetworkDialog") 
    else
        printInfo("连接成功，开始登陆")
        loadingLayer:show("正在登录...",self.scene,100000)
        self.scene:showTips(4)
        eventManager:publish("QuickLogin")
        eventManager:publish("EnterHall")
    end
end

--开始更新基础包
function C:startUpdateBase()
    printInfo("开始更新大厅...");
    loadingLayer:show("正在更新...",self.scene,100000)
    self.scene:showTips(2);
    self.scene:setProgressBar(0)
    local localVersion = dataManager:getLocalBaseVersion();
    local remoteVersion = dataManager.remoteBaseVersion;

    local url = dataManager.updateUrl.."/pt/v"..tostring(remoteVersion).."/v"..tostring(localVersion).."/";
    local basePackageUrl = url.."package.zip";
    local baseVersionUrl = url.."version";

    local assetsManager = cc.AssetsManager:new(basePackageUrl,baseVersionUrl,DOWNLOAD_PATH)
    assetsManager:retain()

    self.currentProgress = -1

    local function onError(errorCode)
        loadingLayer:hide()
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            dataManager:setLocalBaseVersion(remoteVersion)
            assetsManager:release()
            loadingLayer:hide()
            self:reload()
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            printInfo("网络错误，下载失败:"..basePackageUrl)
            loadingLayer:hide()
            local dialogLayer = DialogLayer.new()
            eventManager:publish("CloseNetworkDialog")
            local text = "网络连接失败，请检查您的网络状态\n点击确定重启游戏"
            dialogLayer:show(text,function( isOk )
                self:loadServerList()
            end,"CloseNetworkDialog")
        end
    end

    local function onProgress( percent )
        if self.currentProgress ~= percent then
            self.currentProgress = percent
            self.scene:setProgressBar(self.currentProgress)
        end
    end

    local function onSuccess(t)
        if t == DOWNLOAD_SUCCESS then
            --下载完成，开始解压
            self.scene:showTips(3)
        else
            --解压完成,重新加载
            dataManager:setLocalBaseVersion(remoteVersion)
            assetsManager:release()
            loadingLayer:hide()
            self:reload()
            return;
        end
    end

    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR) -- 注册错误回调
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS) -- 注册进度回调
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS) -- 注册更新成功回调
    assetsManager:setConnectionTimeout(3)
    assetsManager:checkUpdate() -- 自带检查版本和更新
end

function C:reload()
    package.loaded["app.init"] = nil
    require("app.init")
    self:loadServerList()
end

function C:enterLoginScene()
	require("app.init")
	LoginCore.new():run()
end

function C:enterHallScene()
	require("app.init")
	ENTER_HALL()
end

return UpdateCore