local C = class("HallManager");
HallManager = C

C.bindingAccount = nil
C.bindingPassword = nil
C.changingAccount = nil
C.changingPassword = nil
C.loginingAccount = nil
C.loginingPassword = nil
C.loginingRandom = nil
C.loginingWxcode = nil
C.loginingSmscode = nil
C.detectDisconnectTimes = 0
C.detectDisconnect = true
-- C.logining = false

function C:ctor()
    self:registerAll()
end

--注册协议
function C:registerAll()

    Register(MainProto.RegLogin,RegLogin.SC_REQUEST_GAMEVERSIONS_P,handler(self,self.s2cGameVersions))
    Register(MainProto.RegLogin,RegLogin.SC_LOGIN_P,handler(self,self.s2cLogin))
    Register(MainProto.RegLogin,RegLogin.SC_OHTER_LOGIN_P,handler(self,self.s2cOtherLogin))
    Register(MainProto.RegLogin,RegLogin.SC_LOGIN_OTHER_P,handler(self,self.s2cLoginOther))
    Register(MainProto.DBServer,DbServer.SC_SET_HEADID_P,handler(self,self.s2cChangeAvatar))
    Register(MainProto.BaseInfo,BaseInfo.DC_SET_SEX_P,handler(self,self.s2cChangeSex))
    Register(MainProto.RegLogin,RegLogin.SC_REQUEST_REG_PHONECODE_P,handler(self,self.s2cRequestPhoneVerifyCode))
    Register(MainProto.RegLogin,RegLogin.SC_PHONECODE_REG_P,handler(self,self.s2cBindPhone))
    Register(MainProto.BaseInfo,BaseInfo.SC_CHANGE_PSW_RESULT_P,handler(self,self.s2cChangePassword))
    Register(MainProto.FindPsw,FindPsw.SC_FINDPSW_SET_NEW_PSW_RESULT_P,handler(self,self.s2cFindPassword))
    Register(MainProto.RegLogin,RegLogin.SC_NORMAL_REG_P,handler(self,self.s2cRegister))
    Register(MainProto.DBServer,DbServer.SC_WEB_CHANGE_ATTRIB_P,handler(self,self.s2cAttributeChange))
    Register(MainProto.Money,Money.SC_SAVE_MONEY_RESULT_P,handler(self,self.s2cSaveMoney))
    Register(MainProto.Money,Money.SC_GET_MONEY_RESULT_P,handler(self,self.s2cGetMoney))
    Register(MainProto.Money,Money.SC_SET_MONEY_P,handler(self,self.s2cSetMoney))
    Register(MainProto.Money,Money.SC_SET_WALLETMONEY_P,handler(self,self.s2cSetBankMoney))
    Register(MainProto.Money,Money.DS_BIND_PICKUP_P,handler(self,self.s2cBindAlipay))
    Register(MainProto.Money,Money.DS_BIND_BANK_P,handler(self,self.s2cBindBank))
    Register(MainProto.Money,Money.DS_MONEY_CHANG_RMB_P,handler(self,self.s2cExchange))
    Register(MainProto.NoticeManager,NoticeManager.SC_NOTICE_P,handler(self,self.s2cNotice))
    Register(MainProto.RegLogin,RegLogin.DC_REQUEST_SYSTEM_STATUS_P,handler(self,self.s2cConfig))
    Register(MainProto.Rank,Rank.SC_RANK_DATA,handler(self,self.s2cRankData))
    Register(MainProto.Rank,Rank.SC_SELF_RANK_DATA_P,handler(self,self.s2cMyWinToday))

    Register(MainProto.MailManager,MailManager.SC_REQUEST_MAILLIST_P,handler(self,self.s2cRequestMailList))
    Register(MainProto.MailManager,MailManager.SC_REQUEST_MAIL_INFO_P,handler(self,self.s2cRequestMailDetail))
    Register(MainProto.MailManager,MailManager.SC_ADD_MAIL_P,handler(self,self.s2cAddMail))

    Register(MainProto.DBServer,DbServer.SC_CUSTSRV_REPLY_P,handler(self,self.s2cCustomServiceMsgList))
    Register(MainProto.Money,Money.DC_SEND_MSG_GUEST_SERVER_P,handler(self,self.s2cCustomServiceMsg))

    Register(MainProto.Game,Game.SC_GAME_PLAYER_NUM_P,handler(self,self.s2cGetPlayerCount))

    Register(MainProto.RegLogin,RegLogin.SC_HALL_SERVER_VERSION_P,handler(self,self.s2cHallVersions))

    Register(MainProto.Game,Game.SC_ADD_GAMELIST_P,handler(self,self.s2cAddGameRoom))
    Register(MainProto.Game,Game.SC_DEL_GAMELIST_P,handler(self,self.s2cDelGameRoom))
    Register(MainProto.Game,Game.SC_UPDATE_GAME_LIST_P,handler(self,self.s2cUpdateGameList))
    Register(MainProto.Game,Game.SC_GAME_CLOSE_P,handler(self,self.s2cCloseGame))
	
	Register(MainProto.Money,Money.SC_SET_GAME_MONEY_P,handler(self,self.s2cChangeMoney))

    eventManager:on("NullLogin",handler(self,self.nullLogin))
    eventManager:on("WechatLogin",handler(self,self.wechatLogin))
    eventManager:on("SmsLogin",handler(self,self.smsLogin))
    eventManager:on("QuickLogin",handler(self,self.quickLogin))
    eventManager:on("Login",handler(self,self.c2sLogin))
    eventManager:on("ChangeAvatar",handler(self,self.c2sChangeAvatar))
    eventManager:on("RequestPhoneVerifyCode",handler(self,self.c2sRequestPhoneVerifyCode))
    eventManager:on("BindPhone",handler(self,self.c2sBindPhone))
    eventManager:on("ChangePassword",handler(self,self.c2sChangePassword))
    eventManager:on("FindPassword",handler(self,self.c2sFindPassword))
    eventManager:on("SaveMoney",handler(self,self.c2sSaveMoney))
    eventManager:on("GetMoney",handler(self,self.c2sGetMoney))
    eventManager:on("BindAlipay",handler(self,self.c2sBindAlipay))
    eventManager:on("BindBank",handler(self,self.c2sBindBank))
    eventManager:on("Exchange",handler(self,self.c2sExchange))
    eventManager:on("Config",handler(self,self.requestConfig))
    eventManager:on("RankData",handler(self,self.c2sRankData))
    eventManager:on("RequestMailList",handler(self,self.c2sRequestMailList))
    eventManager:on("RequestMailDetail",handler(self,self.c2sRequestMailDetail))
    eventManager:on("SetMailRead",handler(self,self.c2sSetMailRead))
    eventManager:on("DeleteMail",handler(self,self.c2sDeleteMail))
    eventManager:on("Pay",handler(self,self.pay))
    eventManager:on("CustomServiceMsgList",handler(self,self.c2sCustomServiceMsgList))
    eventManager:on("CustomServiceMsg",handler(self,self.c2sCustomServiceMsg))
    eventManager:on("EnterHall",handler(self,self.EnterHall))
    eventManager:on("OnPause",handler(self,self.onPause))
    eventManager:on("OnResume",handler(self,self.onResume))
    eventManager:on("RequestAgentList",handler(self,self.requestAgentList))

    --全民代理
    --佣金信息
    eventManager:on("ReqGetBrokerageInfo",handler(self,self.c2sGetBrokerageInfo))
    Register(MainProto.QMAgent,QMAgent.SC_AGENT_PROMOTIONDATA,handler(self,self.s2cGetBrokerageInfo))
    --领取佣金
    eventManager:on("ReqGetBrokerageMoney",handler(self,self.c2sGetBrokerageMoney))
    Register(MainProto.QMAgent,QMAgent.SC_AGENT_GETMONEY,handler(self,self.s2cGetBrokerageMoney))
    --佣金明细
    eventManager:on("ReqGetBrokerageListInfo",handler(self,self.c2sGetBrokerageListInfo))
    Register(MainProto.QMAgent,QMAgent.SC_AGENT_MONEYDETAIL,handler(self,self.s2cGetBrokerageListInfo))
    --我的团队
    eventManager:on("ReqGetAgentTeamListInfo",handler(self,self.c2sGetAgentTeamListInfo))
    Register(MainProto.QMAgent,QMAgent.SC_AGENT_MYTEAM,handler(self,self.s2cGetAgentTeamListInfo))
    --请求刷新二维码链接
    eventManager:on("RefreshQrcodeUrl",handler(self,self.refreshQrcodeUrl))
end

function C:requestConfig()
    self.publishConfig = true
    self.c2sConfig()
end

--游戏暂停
function C:onPause()
    CloseHallServer()
end

--游戏恢复
function C:onResume()
    ReconnetHallServer()
end

--进入大厅回调
function C:EnterHall()
    SetHallServerConnectCallback(handler(self,self.connectCallback))
    utils:removeTimer("DetectNetwork")
    utils:createTimer("DetectNetwork",5, function()
        if self.detectDisconnectTimes >= 2 and self.detectDisconnect then
            self.detectDisconnect = false
            if SCENE_NAME == "Game" then
                ConnectHallServer(handler(self,self.connectCallback)) 
            else
                loadingLayer:hide()
                eventManager:publish("CloseNetworkDialog")
                DialogLayer.new(false):show("网络连接失败，请检查您的网络状态\n点击确定重新连接",
                function(ok)
                    ConnectHallServer(handler(self,self.connectCallback)) 
                    loadingLayer:show("连接中...",10000000)
                end,"CloseNetworkDialog")  
            end
        else
            self:c2sGetPlayerCount()
        end
    end)
end

function C:connectCallback(r)
    if not r then
        loadingLayer:hide()
        toastLayer:hide()
        if SCENE_NAME == "Game" then
            ConnectHallServer(handler(self,self.connectCallback)) 
        else
            printInfo("大厅服务器连接失败，请检查您的网络状态\n点击确定重新连接("..tostring(SCENE_NAME)..")")
            eventManager:publish("CloseNetworkDialog")
            DialogLayer.new(false):show("网络连接失败，请检查您的网络状态\n点击确定重新连接",
            function(ok)
                loadingLayer:show("连接中...",10000000)
                ConnectHallServer(handler(self,self.connectCallback)) 
            end,"CloseNetworkDialog")  
        end 
    else
        --关闭连接失败弹窗
        eventManager:publish("CloseNetworkDialog")
        print("连接成功")
        self.detectDisconnectTimes = 0
        self.detectDisconnect = true
        if self.loginingAccount then
            self:quickLogin()
        else
            local status = 1
            if dataManager.getLoginStatus then
                status = dataManager:getLoginStatus()
            end
            if status == 1 then
                self:quickLogin()
            else
                loadingLayer:hide()
            end
        end
    end
end

function C:EnterLogin()
    -- SetHallServerAutoReconnect(false)
    -- SetGameServerAutoReconnect(false)
    -- self.detectDisconnect = false
    if dataManager.setLoginStatus then
        dataManager:setLoginStatus(2)
    end
    ENTER_LOGIN()
end

--获取游戏版本
function C:c2sGameVersions()
    SendHallServer(MainProto.RegLogin, RegLogin.CS_REQUEST_GAMEVERSIONS_P, {siteid = dataManager.channel})
end

--获取游戏版本返回
function C:s2cGameVersions(s)
    dump(s)
    dataManager.gameRemoteVersions = s.data
    local updateGames = {}
    for k,v in pairs(s.data) do 
        local localVer = dataManager:getGameLocalVersion(v.gameid)
        local remoteVer = v.gamever
        if device.platform == "ios" then
            remoteVer = v.gameverios
        end
        if remoteVer > localVer then
            table.insert(updateGames,v.gameid)
        end
    end

    if #updateGames > 0 then
        eventManager:send("ShowGameUpdateFlags",updateGames)
    end
end

--获取大厅版本
function C:c2sHallVersions()
    SendHallServer(MainProto.RegLogin,RegLogin.CS_REQUEST_SERVER_VERSION_P,{siteid = dataManager.channel})
end

--获取大厅版本返回
function C:s2cHallVersions(s)
    local remoteVer = s[dataManager.channel]
    local localVer = dataManager:getLocalBaseVersion()

    if remoteVer > localVer then
        dataManager.remoteBaseVersion = remoteVer
        if not gameManager:isGaming() and SCENE_NAME ~= "Update" then
            print("不在游戏中，立即更新")
            gameManager:forceQuitRoom()
            CloseHallServer()
            ENTER_UPDATE()
        end
    end
end

--快速登陆
function C:quickLogin()
    printInfo("快速登陆")
    if self.loginingAccount then
        self:c2sLogin(self.loginingAccount,self.loginingPassword,self.loginingRandom,self.loginingWxcode,self.loginingSmscode)
    else
        local account = dataManager:getAccount()
        if account == "" then
            self:nullLogin()
        else
            local password = dataManager:getPassword()
            local random = dataManager:getRandomCer()
            self:c2sLogin(account,password,random)
        end
    end
end

--游客登陆
function C:nullLogin()
    self:c2sLogin("","","")
end

--微信登录
function C:wechatLogin( code )
    self:c2sLogin("","","",code)
end

--短信登录
function C:smsLogin( account,code )
    self:c2sLogin(account,"","","",code)
end

--发送登陆协议
function C:c2sLogin(account,password,random,wxcode,smscode)
    if not HallServerConnected then
        self.loginingAccount = account
        self.loginingPassword = password
        self.loginingRandom = random
        self.loginingWxcode = wxcode
        self.loginingSmscode = smscode
        ConnectHallServer(handler(self,self.connectCallback))
        return
    end

    local uuid = device:getUuid()
    local version = "1";
    local isVm = device:isVm()
    local promotionId = platform.getPromotionId() or 0 
    printInfo("promotionId:"..tostring(promotionId))
    local clipText = utils:getCopy()
    if promotionId == 0 and clipText then
        local flag = "&8#@"
        clipText = tostring(clipText)
        if string.sub(clipText,1,4) == flag and #clipText >= 5 then
            promotionId = tonumber( string.sub(clipText,5,#clipText)) or 0
        end
        printInfo("clipText:"..tostring(promotionId))
    end
    local info = 
    {
        ["accounttype"] = account== '' and CONST_LOGIN_TYPE_FAST or CONST_LOGIN_TYPE_NORMAL,
        ["hdtp"] = device.platform == "android" and CONST_HD_TYPE_ANDROID or CONST_HD_TYPE_APPLE,
        ["account"] = account,
        ["password"] = password,
        ["selectsavepsw"] = 1,
        ["random"] = random or "",
        ["usesavepsw"] = 1,
        ["hduc"] = uuid,
        ["hductp"] = device.platform == "android" and CONST_UC_TYPE_ANDROID_ID or CONST_UC_TYPE_ADID,
        ["version"] = version,
        ["checkcode"] = Md5.sumhexa(")(*&^" .. Md5.sumhexa("#~!" .. version .. "#" .. "#" .. uuid .. "!!!") .. "F^ad33"),
        ["localip"] = device:getLocalIp(),
        ["phoneCode"] = "",
        ["siteid"] = CHANNEL_ID,
        ["isvm"] = isVm,
        ["ccode"] = math.random(10000, 100000),
        ["uniquecode"] = uuid,
        ["promotionid"] = promotionId
    }
    --微信登录
    if wxcode and wxcode ~= "" then
        info["accounttype"] = CONST_LOGIN_TYPE_WECHAT or 5
        info["wxcode"] = wxcode
    end
    --短信登录
    if smscode and smscode ~= "" then
        info["accounttype"] = CONST_LOGIN_TYPE_SMS or 7
        info["smscode"] = smscode
    end
    -- self.logining = true
    dump(info,"发送登陆协议")
    SendHallServer(MainProto.RegLogin, RegLogin.CS_LOGIN_P, info)
    -- utils:createTimer("hallmanager.login",2,function()
    --     if self.logining then
    --         SendHallServer(MainProto.RegLogin, RegLogin.CS_LOGIN_P, info)
    --     else
    --         utils:removeTimer("hallmanager.login")
    --     end
    -- end)
end

--收到登陆返回
function C:s2cLogin(s)
    dump(s,"登陆返回")
    self.loginingAccount = nil
    self.loginingPassword = nil
    self.loginingRandom = nil
    self.loginingWxcode = nil
    self.loginingSmscode = nil
    -- self.logining = false
    loadingLayer:hide()
    if s["isusa"] and s["isusa"] == 1 then
        dataManager.isusa = true
    end
    local code = s["code"]
    --发布登录返回事件
    eventManager:publish("LoginResp",code)
    
    if code == CONST_LOGIN_RESULT_FORBID then
        DialogLayer.new():show("账号已被封",function( isOk )
            --跳转登陆界面
            self:EnterLogin()
            return
        end)
    elseif code == CONST_LOGIN_RESULT_NO_ACCOUNT then
        DialogLayer.new():show("账号不存在",function( isOk )
            --跳转登陆界面
            self:EnterLogin()
            return
        end)
    elseif code == CONST_LOGIN_RESULT_PSW_ERROR then
        DialogLayer.new():show("密码错误",function( isOk )
            --跳转登陆界面
            self:EnterLogin()
            return
        end)
    elseif code == CONST_LOGIN_RESULT_VERSION then
        DialogLayer.new():show("游戏版本不正确,请重新开启游戏后更新",function( isOk )
            CloseHallServer()
            ENTER_UPDATE()
            return
        end)
    elseif code ~= CONST_LOGIN_RESULT_SUCCESS  then
        local msg = s["msg"]
        DialogLayer.new():show(msg,function( isOk )
            --跳转登陆界面
            self:EnterLogin()
            return
        end)
    end

    dataManager.cer = s["cer"]
    dataManager.agentextips = s["agentextips"] or dataManager.agentextips
    dataManager.bankextips = s["bankextips"] or dataManager.bankextips
    dataManager.bindtips = s["bindtips"] or dataManager.bindtips
    dataManager.chargetips = s["chargetips"] or dataManager.chargetips
    dataManager.isbindaccount = s["isbindaccount"] or dataManager.isbindaccount
    dataManager.isgame = s["isgame"] or dataManager.isgame
    dataManager.ranktips = s["ranktips"] or dataManager.ranktips
    dataManager.regsendmoney = s["regsendmoney"] or dataManager.regsendmoney
    dataManager.serverip = s["serverip"] or dataManager.serverip
    dataManager.serverport = s["serverport"] or dataManager.serverport
    dataManager.gamelist = s["gamelist"] or dataManager.gamelist
    dataManager.sitegamelist = s["sitegamelist"] or dataManager.sitegamelist
    dataManager.state = s["state"] or dataManager.state
    dataManager.userInfo = s["Function"][6] or {}
    dataManager.userInfo.money = s["Function"][7]["money"]
    dataManager.userInfo.walletmoney = s["Function"][7]["walletmoney"]
    dataManager.loginTime = os.time() --保存登录成功时间
    --是否显示官网
    dataManager.officalwebdisplay = s["officalwebdisplay"] or dataManager.officalwebdisplay
    --是否显示二维码
    dataManager.showcode = s["IsShowCode"] or dataManager.showcode
    --是否显示全民推广
    dataManager.promotion = s["promotion"] or dataManager.promotion
    --平台ID
    dataManager.styleId = s["styleid"] or dataManager.styleId
    --官网地址
    dataManager.homeUrl = s["Url"] or dataManager.homeUrl

    --是否已经切换账号
    local isSwitched = dataManager.playerId ~= s["playerid"]

    dataManager.userInfo.playerid = s["playerid"]
    MONEY_SCALE = dataManager.userInfo.scale

    printInfo("保存账号密码")
    local account = s["loginparam"]["account"]
    local random = s["random"]
    dataManager:setAccount(account)
    dataManager:setRandomCer(random)
    dataManager:addAccount(account,nil,random)
    dataManager:setPlayerId(s["playerid"])
    
    dataManager.myWinToday = dataManager.userInfo.GameWinAmount
    dataManager.rankTodayGoldList = {}
    dataManager.rankTodayTimeList = {}
    dataManager.customServiceMsgList = {}
    dataManager.mails = {}

    --切换账号/距离上次刷新qrcodeUrl超过1个小时
    if isSwitched or os.time()-dataManager:getLastRefreshQrcodeUrlTime() > 60*60 then
        self:refreshQrcodeUrl()
    end

    if gameManager:isGaming() then
        loadingLayer:hide()
    else
        printInfo("======================SCENE_NAME:"..tostring(SCENE_NAME))
        if s.isgame and tonumber(s.isgame) == 1 then
            local ret = gameManager:reconnectGame(s.serverip,s.serverport)
            if not ret then
                if SCENE_NAME ~= "Hall" then
                    printInfo("进入大厅")
                    ENTER_HALL()
                end
            end
        elseif SCENE_NAME ~= "Hall" then
            printInfo("进入大厅")
            ENTER_HALL()
        end
    end
    --发布金币变化事件
    eventManager:publish("Money",dataManager.userInfo.money)
    self:c2sGameVersions()
    self:c2sHallVersions()
    self:c2sCustomServiceMsgList()
    self.publishConfig = false
    self:c2sConfig()
end

--别人在别处登陆，你被踢下线
function C:s2cOtherLogin(s)
    dump(s)
    local tip = "该账号已在别处登录，您已被迫下线，若非本人操作请尽快修改密码"
    if s["fenghao"] and s["fenghao"] == 1 then
        tip = "该账号已被封,你已被迫下线,如有疑问请与管理员联系"
    end
    -- SetHallServerAutoReconnect(false)
    -- SetGameServerAutoReconnect(false)
    -- self.detectDisconnect = false
    -- CloseHallServer()
    if dataManager.setLoginStatus then
        dataManager:setLoginStatus(2)
    end
    DialogLayer.new(false):show(tip,function( isOk )
        ENTER_LOGIN()
    end)
end

--你登陆把别人 挤下线
function C:s2cLoginOther(s)
    DialogLayer.new():show("该账号正在别处游戏，您已将其挤下线，若非本人操作请尽快修改密码。")
end

function C:c2sLogout()
    SendHallServer(MainProto.RegLogin,RegLogin.CS_LOGIN_OUT_P)
end

--服务器关闭，强制退出游戏
function C:s2cServerStop(s)
    DialogLayer.new():show(s["str"],function( isOk )
        utils:quitApp()
    end)
end

--刷新全民推广链接
function C:refreshQrcodeUrl()
    if dataManager.homeUrl == nil or dataManager.homeUrl == "" then
        return
    end
    local info = "{\"ch\":"..tostring(dataManager.playerId)..",\"pt\":"..tostring(dataManager.styleId)..",\"rand\":"..tostring(os.time()).."}"
    local base64String = utils:encodeBase64(info) or ""
    local homeUrl = tostring(dataManager.homeUrl)
    local len = string.len(homeUrl)
    local index = string.find(homeUrl,"/",len-1,len)
    if index == nil then
        homeUrl = homeUrl.."/"
    end
    local longUrl = homeUrl..utils:randomString(5,8)..".html?"..utils:randomString(3,5).."="..tostring(base64String).."&platform="..tostring(dataManager.styleId)
    local encodeUrl = string.urlencode(longUrl)
    self:createShortUrl(encodeUrl,function( shortUrl )
        print("=====================createShortUrl:"..tostring(shortUrl))
        if shortUrl then
            dataManager.qrcodeUrl = shortUrl
        else
            dataManager.qrcodeUrl = longUrl
        end
        eventManager:publish("RefreshQrcodeUrlResp")
        --保存本次qrcodeUrl并且清除上次qrcodeUrl生成的二维码图片
        dataManager:setLastQrcodeUrl(dataManager.qrcodeUrl)
    end)
end

function C:createShortUrl( longUrl,callback )
    self:createShortUrlBySina(longUrl,function( shortUrl )
        if shortUrl then
            if callback then
                callback(shortUrl)
            end
        else
            self:createShortUrlBySuo(longUrl,function( shortUrl )
                if callback then
                    callback(shortUrl)
                end
            end)
        end
    end)
end

--请求生成短链接(新浪接口)
function C:createShortUrlBySina( longUrl, callback )
    local url = "http://api.t.sina.com.cn/short_url/shorten.json?source=3271760578&url_long="..tostring(longUrl)
    utils:httpGet(url,function( response )
        local shortUrl = nil
        if response and type(response) == "string" then
            local tb = json.decode(response)
            if tb and tb[1] and tb[1].url_short then
                shortUrl = tb[1].url_short
            end
        end
        if callback then
            callback(shortUrl)
        end
    end)
end

--请求生成短链接(搜狗接口)
function C:createShortUrlBySuo( longUrl, callback )
    local url = "http://suo.im/api.php?url="..tostring(longUrl)
    utils:httpGet(url,function( response )
        local shortUrl = nil
        if response and type(response) == "string" then
            shortUrl = response
        end
        if callback then
            callback(shortUrl)
        end
    end)
end

--修改头像
function C:c2sChangeAvatar(id)
    printInfo(">>>>>>>修改头像>>>>>>>>"..id)
    SendHallServer(MainProto.BaseInfo, BaseInfo.CS_SET_HEADID_P, {id = id})
    local sex=(id+1)%2
    SendHallServer(MainProto.BaseInfo, BaseInfo.CD_SET_SEX_P, {sex = sex})
end

--修改头像返回
function C:s2cChangeAvatar(s)
    dump(s,"修改头像返回")
    local code = s["code"]
    if code == 0 then
        dataManager.userInfo.headid = s["id"]
    else
        toastLayer:show(s["msg"])
    end
end

--修改性別返回
function C:s2cChangeSex(s)
    dump(s,"修改性別返回")
    local sex=s["sex"]
    dataManager:setSex(sex)
end

--请求短信验证码
function C:c2sRequestPhoneVerifyCode(phone,type)
    SendHallServer(MainProto.RegLogin,RegLogin.CS_REQUEST_REG_PHONECODE_P,{phone = phone,type = type,siteid = dataManager.channel})
end

--请求短信验证码返回
function C:s2cRequestPhoneVerifyCode(s)
    toastLayer:show(s.msg)
end

--绑定手机号码
function C:c2sBindPhone(phone,code,password)
    local uuid = device:getUuid()
    local version = "0";
    local isVm = device:isVm()
    s = {}
    s["accounttype"] = CONST_LOGIN_TYPE_NORMAL;
    s["hdtp"] = device.platform == "android" and CONST_HD_TYPE_ANDROID or CONST_HD_TYPE_APPLE;
    s["password"] = password;
    s["phoneNumber"] = phone;
    s["phoneCode"] = code;
    s["hduc"] = uuid;
    s["version"] = version;
    s["checkcode"] = Md5.sumhexa("^&a"..Md5.sumhexa("#~!" ..version .."#".."#" ..uuid .."!!!") .."@*" ..phone);
    s["hductp"] = device.platform == "android" and CONST_UC_TYPE_ANDROID_ID or CONST_UC_TYPE_ADID;
    s["siteid"] = dataManager.channel;
    s["isvm"] = isVm;
    s["sex"] = 1;
    self.bindingAccount = phone
    self.bindingPassword = password
    SendHallServer(MainProto.RegLogin,RegLogin.CS_PHONECODE_REG_P,s)
end

--绑定手机号码返回
function C:s2cBindPhone(s)
    dump(s,"绑定手机号码返回")
    if s.code == 0 then
        dataManager.isbindaccount = 1
        dataManager:setAccount(self.bindingAccount)
        dataManager:setPassword(self.bindingPassword)
        dataManager:addAccount(self.bindingAccount,self.bindingPassword,nil)
        self.bindingAccount = nil
        self.bindingPassword = nil
        self:c2sLogout()
        self:quickLogin()
        loadingLayer:show("注册成功,自动登录中...")
        eventManager:publish("BindPhoneSuccess")
    else
        loadingLayer:hide()
        toastLayer:show(s.msg)
    end
end

--普通注册返回
function C:s2cRegister(s)
    printInfo(">>>>>>>>>>>>普通注册返回>>>>>>>>>>>")
    loadingLayer:hide()
    toastLayer:show(s.msg)
end

--属性变化通知（money）
function C:s2cAttributeChange(s)

    if s.money then
        dataManager.userInfo.money = s.money
        eventManager:publish("Money",s.money)
    end

    if s.charge then
        DialogLayer.new():show("你已成功充值" .. (s.charge / MONEY_SCALE) .. "金币！")
    end
end

--修改密码
function C:c2sChangePassword(old, new)
    self.changingPassword = new
    self.changingAccount = dataManager.account
    SendHallServer(MainProto.BaseInfo,BaseInfo.CS_CHANGE_PSW_P,{oldpsw=old,password = new})
end

--修改密码返回
function C:s2cChangePassword(s)
    if s.code == 0 then
        dataManager:setPassword(self.changingPassword)
        dataManager:addAccount(self.changingAccount,self.changingPassword,nil)
        eventManager:publish("ChangePasswordSuccess")
    end
    loadingLayer:hide()
    toastLayer:show(s.msg)
end

--找回密码
function C:c2sFindPassword(phone,code,password)
    local s = {}
    s["phoneNumber"] = phone;
    s["phoneCode"] = code;
    s["password"] = password;
    s["siteid"] = dataManager.channel;
    self.changingPassword = password
    self.changingAccount = phone
    SendHallServer(MainProto.FindPsw,FindPsw.CS_FINDPSW_SET_NEW_PSW_P,s)
end

--找回密码返回
function C:s2cFindPassword(s)
    if s.code == 0 then
        dataManager:setAccount(self.changingAccount)
        dataManager:setPassword(self.changingPassword)
        dataManager:addAccount(self.changingAccount,self.changingPassword,nil)
        eventManager:publish("FindPasswordSuccess")
        self:c2sLogout()
        self:quickLogin()
    end
    loadingLayer:hide()
    toastLayer:show(s.msg)
end

--存钱
function C:c2sSaveMoney(money)
    SendHallServer(MainProto.Money,Money.CS_SAVE_MONEY_P,{money = money * MONEY_SCALE})
end

--存钱返回
function C:s2cSaveMoney(s)
    eventManager:publish("SaveMoneyResult",s.code==0,s.msg)
end

--取钱
function C:c2sGetMoney(money)
    SendHallServer(MainProto.Money,Money.CS_GET_MONEY_P,{money = money * MONEY_SCALE,pwd = "888888"})
end

--取钱返回
function C:s2cGetMoney(s)
    eventManager:publish("GetMoneyResult",s.code==0,s.msg)
end

--金额变化
function C:s2cSetMoney(s)
    dataManager.userInfo.money = s.money
    eventManager:publish("Money",s.money)
end

--保险箱变化
function C:s2cSetBankMoney(s)
    dataManager.userInfo.walletmoney = s.walletmoney
    eventManager:publish("BankMoney",s.walletmoney)
end

--绑定支付宝
function C:c2sBindAlipay(account,name)
    SendHallServer(MainProto.Money,Money.CD_BIND_PICKUP_P,{zhifubao = account,name = name})
end

--绑定支付宝返回
function C:s2cBindAlipay(s)
    if s.code == 0 then
        if s.zhifubao then
            dataManager.userInfo.zhifubao = s.zhifubao
        end
        if s.realname then 
            dataManager.userInfo.realname = s.realname
        end
        eventManager:publish("BindAlipaySuccess",s.zhifubao,s.realname)
    end
    loadingLayer:hide()
    toastLayer:show(s.msg)
end

--绑定银行卡
function C:c2sBindBank(bankNum,name)
    SendHallServer(MainProto.Money,Money.CD_BIND_BANK_P,{BankName = 1,BankAccountInfo = "开心大赢家",BankAccountNum = bankNum,BankAccountName = name})
end

--绑定银行卡返回
function C:s2cBindBank(s)
    if s.code == 0 then
        if s.BankName then
            dataManager.userInfo.BankName = s.BankName
        end
        if s.BankAccountNum then
            dataManager.userInfo.BankAccountNum = s.BankAccountNum
        end
        if s.BankAccountName then 
            dataManager.userInfo.BankAccountName = s.BankAccountName
        end
        eventManager:publish("BindBankSuccess",s.BankAccountNum,s.BankAccountName)
    end
    loadingLayer:hide()
    toastLayer:show(s.msg)
end

--兑换
function C:c2sExchange(money,type)
    print("Exchane:"..tostring(money))
    SendHallServer(MainProto.Money,Money.CD_MONEY_CHANG_RMB_P,{money = money,type = type})
end

--兑换返回
function C:s2cExchange(s)
    toastLayer:show(s.msg)
    if s.code == 0 then
        dataManager.userInfo.money = s.money
        eventManager:publish("Money",s.money)
        eventManager:publish("ExchangeSuccess",s.money)
    end
    loadingLayer:hide()
end

--收到通知
function C:s2cNotice(s)
    SHOW_ROLL_ANNOUNCE(s)
end

--请求配置信息
function C:c2sConfig()
    SendHallServer(MainProto.RegLogin,RegLogin.CD_REQUEST_SYSTEM_STATUS_P,{siteid = dataManager.channel,userid = dataManager.playerId})
end

--请求配置信息返回
function C:s2cConfig(s)
    dump(s)
    dataManager.configs = s
    if self.publishConfig then
        self.publishConfig = nil
        eventManager:publish("ConfigResult",s)
    end
    eventManager:publish("s2cConfig")
end

--请求排行榜
function C:c2sRankData(type,from,to)

    if type == CONST_RANK_TODAY_MONEY then
        if (os.time()-dataManager.goldRankSyncInterval < dataManager.goldRankLastSyncTime) and dataManager.rankTodayGoldList.ranks and #dataManager.rankTodayGoldList.ranks > 0 then
            eventManager:publish("TodayGoldRankResult",dataManager.rankTodayGoldList.ranks)
            return
        end
    elseif type == CONST_RANK_TODAY_TIME then
        if (os.time()-dataManager.timeRankSyncInterval < dataManager.timeRankLastSyncTime) and dataManager.rankTodayTimeList.ranks and #dataManager.rankTodayTimeList.ranks > 0 then
            eventManager:publish("TodayTimeRankResult",dataManager.rankTodayTimeList.ranks)
            eventManager:publish("MyTimeTodayResult",dataManager.rankTodayTimeList.rankIndex)
            return
        end
    end

    local s = {}
    s.type = type;-- 1：在线时长；2：金币
    s.begin = from;
    s["end"] = to;
    SendHallServer(MainProto.Rank,Rank.CS_RANK_DATA,s)
end

--请求排行榜返回
function C:s2cRankData(s)
	dump(s)
    if s.type == CONST_RANK_TODAY_MONEY then
        dataManager.goldRankSyncInterval = s.syncInterval / 1000
        dataManager.goldRankLastSyncTime = s.lastSyncedTime
        local info = {}
        info.rankIndex = s.rankIndex
        info.ranks = {}
        if s.num > 0 then
        local strs = string.split(s.ranks,";");
            for i=1,#strs,1 do
                local str = strs[i]
                if strs ~= nil and #str > 0 then
                    local data = {}
                    local tmpData = string.split(str,",");
                    data.playerId = tmpData[1]
                    data.name = tmpData[2]
                    data.money = tmpData[3]
                    data.vip = tonumber(tmpData[4])
                    data.headId = tonumber(tmpData[5])
					data.wxheadurl = tmpData[6] or ""
                    table.insert(info.ranks,data);
                end
            end
        end
        dataManager.rankTodayGoldList = info
        eventManager:publish("TodayGoldRankResult",info.ranks)
        self:c2sMyWinToday()
    elseif s.type == CONST_RANK_TODAY_TIME then
        dataManager.timeRankSyncInterval = s.syncInterval / 1000
        dataManager.timeRankLastSyncTime = s.lastSyncedTime
        local info = {}
        info.rankIndex = s.rankIndex
        info.ranks = {}
        if s.num > 0 then
            local strs = string.split(s.ranks,";");
            for i=1,#strs,1 do
                local str = strs[i]
                if strs ~= nil and #str > 0 then
                    local data = {}
                    local tmpData = string.split(str,",");
                    data.playerId = tmpData[1]
                    data.name = tmpData[2]
                    data.time = tonumber(tmpData[3])
                    data.vip = tonumber(tmpData[4])
                    data.headId = tonumber(tmpData[5])
					data.wxheadurl = tmpData[6] or ""
                    table.insert(info.ranks,data);

                end
            end
        end
        dataManager.rankTodayTimeList = info
        eventManager:publish("TodayTimeRankResult",info.ranks)
        eventManager:publish("MyTimeTodayResult",info.rankIndex)
    end
end

--请求自己今天所赢金币
function C:c2sMyWinToday()
    SendHallServer(MainProto.Rank,Rank.CS_SELF_RANK_DATA_P)
end

--请求自己今天所赢金币返回
function C:s2cMyWinToday(s)
    if s.code == 0 then
        local playerId = s.UserId
        dataManager.myWinToday = tonumber(s.GameWinCount)
        local rank = (dataManager.rankTodayGoldList == nil) and 0 or dataManager.rankTodayGoldList.rankIndex
        eventManager:publish("MyWinTodayResult",rank,dataManager.myWinToday);
    end
end

--请求邮件列表
function C:c2sRequestMailList()
    SendHallServer(MainProto.MailManager,MailManager.CS_REQUEST_MAILLIST_P)
end

--请求邮件列表返回
function C:s2cRequestMailList(s)
    s.reconnect = nil
    dataManager.mails = s
    self:updateMailReadStatus()
    eventManager:publish("MailList",dataManager.mails)
end

--请求邮件详细内容
function C:c2sRequestMailDetail(id)
    SendHallServer(MainProto.MailManager,MailManager.CS_REQUEST_MAIL_INFO_P,{id = id})
end

--请求邮件详细内容
function C:s2cRequestMailDetail(s)
    dump(s,"请求邮件详细内容")
    local msg = nil
    for k,v in pairs(dataManager.mails) do
        if v.id == s.id then
            dataManager.mails[k].content = s.text
            msg = dataManager.mails[k]
            break
        end
    end
    if msg then
        eventManager:publish("MailDetail",msg)
    end
end

--新邮件
function C:s2cAddMail(s)
    table.insert(dataManager.mails,s)
    eventManager:publish("AddMail",s)
    self:updateMailReadStatus()
end

--设置邮件已读
function C:c2sSetMailRead(id)
    for k,v in pairs(dataManager.mails) do
        if v.id == id then
            dataManager.mails[k].readtype = CONST_MAIL_READY
            break
        end
    end
    self:updateMailReadStatus()
    SendHallServer(MainProto.MailManager,MailManager.CS_MAIL_SET_READ_P,{id = id})
end

--删除邮件
function C:c2sDeleteMail(id)
    for k,v in pairs(dataManager.mails) do
        if v.id == id then
            dataManager.mails[k] = nil
            break
        end
    end
    SendHallServer(MainProto.MailManager,MailManager.CS_DEL_MAIL_INFO_P,{id = id})
end

--检查邮件已读状态
function C:updateMailReadStatus()
    local hasUnread = false
    for k,v in pairs(dataManager.mails) do
        if v.readtype == CONST_MAIL_UNREADY then
            hasUnread = true
            break
        end
    end
    eventManager:publish("SetMailRedDot",hasUnread)
end

--请求代理列表
function C:requestAgentList()   
    local url = dataManager.agentUrl.."?userid="..tostring(dataManager.playerId)
    local xmlHttpReq = cc.XMLHttpRequest:new()
    xmlHttpReq.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
    xmlHttpReq.timeout = 5;
    xmlHttpReq:open("GET", url) -- 打开链接

    -- http响应回调
    local function onServerListResponse()

        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
            local tb = json.decode(xmlHttpReq.response)
            if tb == nil or type(tb) ~= "table" then
                return
            end
            --TODO
            eventManager:publish("AgentList",tb.data)
            xmlHttpReq:unregisterScriptHandler();
            xmlHttpReq = nil;
        end
    end

    -- 注册脚本回调方法
    xmlHttpReq:registerScriptHandler(onServerListResponse)
    xmlHttpReq:send() -- 发送请求
    
end

--支付
function C:pay(type, money)
    local min = 10
    local max = dataManager.configs.MaxMoney

    if type == CONST_PAY_TYPE_ALIPAY then
        min = dataManager.configs.MinAlipay
        max = dataManager.configs.MaxAlipay
    elseif type == CONST_PAY_TYPE_WX then
        min = dataManager.configs.MinWXPay
        max = dataManager.configs.MaxWXPay
    elseif type == CONST_PAY_TYPE_BANK then
        min = dataManager.configs.MinUnionPay
        max = dataManager.configs.MaxUnionPay
    elseif type == CONST_PAY_TYPE_QQ then
        min = dataManager.configs.MinQQPay
        max = dataManager.configs.MaxQQPay
    elseif type == CONST_PAY_TYPE_JD then
        min = dataManager.configs.MinJDPay
        max = dataManager.configs.MaxJDPay
    elseif type == CONST_PAY_TYPE_ALIPAY_QUOTA then
        min = dataManager.configs.Alipayisquotaminprice
        max = dataManager.configs.Alipayisquotamaxprice
    else
        DialogLayer.new():show("支付类型不正确",function( isOk ) end)
        return
    end

    if money < min then
        DialogLayer.new():show("充值金额不能小于"..min.."元",function( isOk ) end)
        return
    end

    if money > max then
        DialogLayer.new():show("充值金额不能大于"..max.."元",function( isOk ) end)
        return
    end

    local requestUrl = dataManager.payUrl .. "?suserid=" .. tostring(dataManager.playerId) .. "&samount="
                .. money .. "&spaytype=" .. type .. "&r=" .. os.time() .. "&ver=2.0"

    utils:httpGet(requestUrl,
    function(data)
        loadingLayer:hide()
        if data == nil then
            toastLayer:show("网络错误")
        else
            local msg = json.decode(data)
            local success = false
            if msg and msg.success == true then
                if msg["data"] and msg["data"]["payhead"] then
                    if msg["data"]["payhead"] == "H5" then
                        if msg["data"]["url"] then
                            utils:openUrl(msg["data"]["url"])
                            success = true
                            return
                        end
                    end
                end
            end
            if not success then
                toastLayer:show("请求支付接口失败")
            end
        end 
    end)
    loadingLayer:show("正在请求支付接口")
end

function C:c2sGetPlayerCount()
    self.detectDisconnectTimes = self.detectDisconnectTimes + 1
    SendHallServer(MainProto.Game,Game.CS_GAME_PLAYER_NUM_P)
end

function C:s2cGetPlayerCount(s)
    self.detectDisconnectTimes = 0
end

function C:c2sCustomServiceMsgList()
    SendHallServer(MainProto.DBServer,DbServer.CS_CUSTSRV_REPLY_P,{msgsize = 200})
end

function C:s2cCustomServiceMsgList(s)
    if s.IsAutoReply then
        local data = s.data[1]
        local msg = {time = data.fromtime,type = "from",content = data.fromcontent}
        table.insert(dataManager.customServiceMsgList,msg)
        EventManager:publish("CustomServiceMsgReply",msg)
        eventManager:publish("SetCustomServiceRedDot",true)
    else
        local msgList = {}
        table.insert(msgList,{time = os.date("%Y-%m-%d %H:%M:%S",0),type = "from",content = "您好，请详细描述您的问题（包括游戏ID，充值或提现时间、金额等）"})
        s.reconnect = nil
        local redDot = false
        local lastTime = dataManager:getLastReadMsgTime()
        for k,v in pairs(s) do
            if v.ToContent ~= nil and v.ToContent ~= "" then
                table.insert(msgList,{time = v.ToTime,type = "to",content = v.ToContent})
            end
            if v.FromContent ~= nil and v.FromContent ~= "" then
                table.insert(msgList,{time = v.FromTime,type = "from",content = v.FromContent})
                if not redDot and lastTime < utils:string2Time(v.FromTime) then
                    redDot = true
                end
            end
        end

        table.sort(msgList,function(a,b) return utils:string2Time(a.time) < utils:string2Time(b.time) end)

        eventManager:publish("SetCustomServiceRedDot",redDot)

        dataManager.customServiceMsgList = msgList
        EventManager:send("UpdateCustomServiceMsg",dataManager.customServiceMsgList)
    end
end

function C:c2sCustomServiceMsg(msg)
    SendHallServer(MainProto.Money,Money.CD_SEND_MSG_GUEST_SERVER_P,{msg = msg})
    table.insert(dataManager.customServiceMsgList,{time = os.date("%Y-%m-%d %H:%M:%S"),type = "to",content = msg})
    table.sort(dataManager.customServiceMsgList,function(a,b) return utils:string2Time(a.time) < utils:string2Time(b.time) end)
end

function C:s2cCustomServiceMsg(s)
    toastLayer:show("提交成功，客服小姐姐将在5分钟内处理您的问题，请注意查看回复")
end

--新增游戏房间
function C:s2cAddGameRoom(s)
    dataManager:addGameRoom(s)
    dump(dataManager.gamelist)
    eventManager:publish("UpdateGameList")
end

--关闭游戏房间
function C:s2cDelGameRoom(s)
	local roomInfo = dataManager:getRoomInfoByPort(s.port)
	local gameid = s.gameid
	local orderid = roomInfo.orderid
	dataManager:delGameRoom(s.gameid,s.port)
    gameManager:forceQuitRoom(gameid,orderid)
    eventManager:publish("UpdateGameList")
    if gameManager.currentGameId == s.gameid then
        toastLayer:show("房间已被关闭，请选择其他房间进行游戏！")
    end
end

--更新游戏（开关状态）
function C:s2cUpdateGameList(s)
    for k,v in pairs(s.game) do
        if k == gameManager.currentGameId and not v.isopen then
            gameManager:forceQuitRoom(k)
            break
        end
    end
end

--关服
function C:s2cCloseGame(s)
    gameManager:forceQuitRoom()
end

--关服
function C:s2cChangeMoney(s)
    if s.bchange and s.bchange == 1 and s.totalmoney then
        dataManager.userInfo.money = s.totalmoney
        eventManager:publish("Money",dataManager.userInfo.money)
    end
end

--全民代理
--请求佣金可提取金额
function C:c2sGetBrokerageInfo()
    SendHallServer(MainProto.QMAgent,QMAgent.CS_AGENT_PROMOTIONDATA)
end

function C:s2cGetBrokerageInfo(s)
    eventManager:publish("RespGetBrokerageInfo",s)
end

function C:c2sGetBrokerageMoney()
    SendHallServer(MainProto.QMAgent,QMAgent.CS_AGENT_GETMONEY)
end

function C:s2cGetBrokerageMoney(s)
    eventManager:publish("RespGetBrokerageMoney",s)
end

--佣金明细
function C:c2sGetBrokerageListInfo( page )
    SendHallServer(MainProto.QMAgent,QMAgent.CS_AGENT_MONEYDETAIL,{pageno=page})
end

function C:s2cGetBrokerageListInfo(s)
    eventManager:publish("RespGetBrokerageListInfo",s)
end

--我的团队
function C:c2sGetAgentTeamListInfo( page )
    SendHallServer(MainProto.QMAgent,QMAgent.CS_AGENT_MYTEAM,{pageno=page})
end

function C:s2cGetAgentTeamListInfo( s )
    eventManager:publish("RespGetAgentTeamListInfo",s)
end

hallManager = HallManager.new()

return HallManager