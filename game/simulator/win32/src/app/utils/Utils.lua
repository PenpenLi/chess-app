local C = class("Utils")
Utils = C

C.timers = {}
C.scheduler = cc.Director:getInstance():getScheduler()
C.randomChars = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
                 "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                 "1","2","3","4","5","6","7","8","9","0"}

--获取金币字符串 count:0无小数 1一位小数 2两位小数 3直接tostring(有几位小数就是几位) ,如果不传count,会加亿/万单位处理
function C:moneyString( money, count )
    money = tonumber(money) or 0
    money = money/MONEY_SCALE
    if count == 0 then
        return string.format("%0.0f",money)--tostring(money)
    elseif count == 1 then
        return string.format("%0.1f",money)
    elseif count == 2 then
        return string.format("%0.2f",money)
    elseif count == 3 then
        return tostring(money)
    else
        if money > 100000000 then
            return string.format("%0.2f亿",money/100000000)
        elseif money > 10000 then
            return string.format("%0.2f万",money/10000)
        else
            if money == math.floor(money) then
                return string.format("%0.0f",money)
            elseif money*10 == math.floor(money*10) then
                return string.format("%0.1f",money)
            else
                return string.format("%0.2f",money)
            end
        end
    end
end

--获取随机字符串
function C:randomString( min,max )
    math.randomseed(os.clock()*10000)
    local length = math.random(min,max)
    local string = ""
    for i=1,length do
        local index = math.random(1,#self.randomChars)
        string = string..self.randomChars[index]
    end
    return string
end

function C:encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str
 
    while #str > 0 do
        local bytes_num = 0
        local buf = 0
 
        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end
 
        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end
 
        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end
 
    return s64
end
 
function C:decodeBase64(str64)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local temp={}
    for i=1,64 do
        temp[string.sub(b64chars,i,i)] = i
    end
    temp['=']=0
    local str=""
    for i=1,#str64,4 do
        if i>#str64 then
            break
        end
        local data = 0
        local str_count=0
        for j=0,3 do
            local str1=string.sub(str64,i+j,i+j)
            if not temp[str1] then
                return
            end
            if temp[str1] < 1 then
                data = data * 64
            else
                data = data * 64 + temp[str1]-1
                str_count = str_count + 1
            end
        end
        for j=16,0,-8 do
            if str_count > 0 then
                str=str..string.char(math.floor(data/math.pow(2,j)))
                data=math.mod(data,math.pow(2,j))
                str_count = str_count - 1
            end
        end
    end
 
    local last = tonumber(string.byte(str, string.len(str), string.len(str)))
    if last == 0 then
        str = string.sub(str, 1, string.len(str) - 1)
    end
    return str
end

--分割字符串
function C:stringSplit( theString, theSeparator )
	theString = tostring(theString)
    theSeparator = tostring(theSeparator)

    if theSeparator == '' then
        return theString
    end

    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(theString, theSeparator, pos, true)
    end do
        table.insert(arr, string.sub(theString, pos, st - 1))
        pos = sp + 1
    end

    table.insert(arr, string.sub(theString, pos))
    return arr
end

--将秒转为时间字符串（00:00:00）
function C:timeString( time )
    time = tonumber(time);
    local timeStr = "";
    local hour = 0;
    local minus = 0;
    local seconds = 0;
    if time > 3600 then
        hour = math.floor(time / 3600);
        local hourYu = time % 3600;
        minus = math.floor(hourYu / 60);
        minus = tonumber(string.format("%d", minus));
        local minusYu = hourYu % 60;
        seconds = minusYu;
    else
        if time >= 60 then
            minus = math.floor(time / 60);

            local minusYu = time % 60;
            seconds = minusYu;
        else
            seconds = time;
        end
    end
    return string.format("%02d:%02d:%02d",hour,minus,seconds)
end

function C:string2Time(str)
    local Y = string.sub(str , 1, 4)
    local M = string.sub(str , 6, 7)
    local D = string.sub(str , 9, 10)
    local H = string.sub(str , 12, 13)
    local m = string.sub(str , 15, 16)
    local s = string.sub(str , 18, 19)
    return os.time({year=Y, month=M, day=D, hour=H,min=m,sec=s})
end

--定时器
function C:createTimer( name, interval, callback)
    self:removeTimer(name)
    local entry = self.scheduler:scheduleScriptFunc(callback, interval, false)
    self.timers[tostring(entry)] = name
    return entry
end

function C:removeTimer( name )
    for k,v in pairs(self.timers) do
        local index = string.find(v,name)
        if index then
            self:removeTimerByEntry(tonumber(k))
        end
    end
end

function C:removeTimerByEntry( entry )
    self.scheduler:unscheduleScriptEntry(entry)
    self.timers[tostring(entry)] = nil
end

function C:removeAllTimers()
    for k,v in pairs(self.timers) do
        self.scheduler:unscheduleScriptEntry(tonumber(k))
    end
    self.timers = {}
end

function C:delayInvoke(name, delay, callback)
    local doAction = function()
        self:removeTimer(name)
        if callback then
            callback()
        end
    end
    self:createTimer(name, delay, doAction)
end

function C:quitApp()
    cc.Director:getInstance():endToLua()
end

--http获取json
function C:httpGet(url,callback)
    local xmlHttpReq = cc.XMLHttpRequest:new()
    xmlHttpReq.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型cc.XMLHTTPREQUEST_RESPONSE_JSON--
    xmlHttpReq.timeout = 20;
    xmlHttpReq:open("GET", url) -- 打开链接

    -- http响应回调
    local function onResponse()

        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
            callback(xmlHttpReq.response)
        else
            callback(nil)
        end

        xmlHttpReq:unregisterScriptHandler();
        xmlHttpReq = nil;
    end

    -- 注册脚本回调方法
    xmlHttpReq:registerScriptHandler(onResponse)
    xmlHttpReq:send() -- 发送请求
end

--设置剪切板内容
function C:setCopy(content)
    platform.setClipboardText(content)
end

--获取剪切板内容
function C:getCopy()
    return platform.getClipboardText()
end

--浏览器打开链接
function C:openUrl(url)
    platform.openUrl(url)
end

--是否已经安装微信
function C:isInstallWechat()
    return platform.isInstallWechat()
end

--获取安卓设备
function C:getAndroidDeviceType()
    return platform.getDeviceType()
end

--获取当前网络类型（wifi/4G）
function C:getCurrentConnectType()
    return platform.getCurrentNetworkType()
end

--当前网络是否可用
function C:isNetworkAvailable()
    return platform.isNetworkAvailable()
end

--打开应用（qq,wx,zfb）
function C:openApp(appName)
    platform.openApp(appName)
end

--ios支付
function C:iosBuy(productid,price,playerid,itemName)
    if device.platform == "ios" then
        platform.iosBuy(productid,price,playerid,itemName)
    end
end

--是否正在充电
function C:isBatteryCharging()
    local isCharging = false
    local state = platform.getBatteryState()
    if state == 2 or state == 3 then
        isCharging = true
    end
    return isCharging
end

--电量百分比 0-100
function C:getBatteryPercent()
    return platform.getBatteryLevel()
end

function C:playFramesAnimation(sprite,aniName,startFrame,endFrame,speed,loops,callback)
    local array = {}
    for i=startFrame,endFrame do
        local resPng = aniName..i..".png"
        local tmpsf = cc.SpriteFrameCache:getInstance():getSpriteFrame( resPng )
        array[i] = tmpsf
    end
    local animation = CCAnimation:createWithSpriteFrames(array, speed)
    local animate = CCAnimate:create(animation)
    if callback then
        animate = cc.Sequence:create({animate,CCCallFunc:create(callback)})
    end
    sprite:setVisible(true)
    if loops < 0 then
        sprite:runAction(cc.RepeatForever:create(animate))
    else
        sprite:runAction(cc.Repeat:create( animate, loops))
    end
end

function C:createFrameAnim(params)
    local path = params.path;
    local image = params.image;
    local endFrame = params.endFrame;
    local interval = params.interval or 0.1;
    local start = params.start or 1;
    local remove = true;
    if params.remove ~= nil then 
        remove = params.remove;
    end 
    params.removeSelf = remove
    display.loadSpriteFrames(path..".plist", path..".png");
    local frames = display.newFrames(image.."%d.png", start, endFrame);
    local sprite = display.newSprite(frames[start]);
    local animation = display.newAnimation(frames, interval);
    if params.once then 
        sprite:playAnimationOnce(animation,params)
    else
        sprite:playAnimationForever(animation)
    end
    return sprite;
end

function C:newTTFLabel(params)
    assert(type(params) == "table","[framework.display] newTTFLabel() invalid params")

    local text       = tostring(params.text)
    local font       = params.font or display.DEFAULT_TTF_FONT
    local size       = params.size or display.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    local textAlign  = params.align or kCCTextAlignmentLeft
    local textValign = params.valign or kCCVerticalTextAlignmentCenter 
    local x, y       = params.x, params.y
    local dimensions = params.dimensions or cc.size(0, 0)

    local label = CCLabelTTF:create(text, font, size, dimensions, textAlign, textValign)

    if label then
        label:setColor(color)
        if x and y then label:setPosition(x, y) end
    end

    return label
end

function C:copyTable( tb )
    local table = {}
    for k, v in pairs(tb or {}) do
        if type(v) ~= "table" then
            table[k] = v
        else
            table[k] = self:copyTable(v)
        end
    end
    return table
end

function C:createQRCode( url,width,filePath )
    return platform.createQRCode(url,width,filePath)
end

--TODO：注册OpenUrl
function C:registerOpenUrlHandler( handler )
    platform.registerOpenUrlHandler(handler)
end

--注册微信AppId
function C:registerWechatAppId( appId )
    platform.registerWechatAppId(appId)
end

--微信登录
function C:sendWechatLogin( callback )
    platform.sendWechatLogin(callback)
end

--type:1=文字，2=图片，3=音乐，4=视频，5=网页，6=小程序
--scene:0=聊天界面，1=朋友圈，2=收藏，3=指定联系人
--info:参数信息
function C:shareToWechat( ctype, scene, info )
    platform.shareToWechat(ctype,scene,info)
end

--发起定位
function C:startLocation( handler )
    platform.startLocation(handler)
end

--保存图片到相册 handler(success) success：字符串"0"或者"1"
function C:saveImage( filePath, handler )
    platform.saveImage(handler,filePath)
end

--从相册或者相机获取图片 handler(success) success：字符串"0"或者"1"
function C:getImage( type,filePath,size,handler )
    platform.getImage(handler,type,filePath,size)
end

--更新APP handler(resultString) resultString=status,msg,percent
--status: 1=更新中，2=更新失败，3=更新成功
function C:updateApp( appVer,appUrl,handler )
    platform.updateApp(appVer,appUrl,handler)
end

function C.GetAmt(pName, play, index, file)
--    print("tools.GetAmt", pName)
    if pName == nil then
    print(debug.traceback("GetAmt", 3))
    end
    if file then
	    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(file)
    end

	local armature = ccs.Armature:create(pName)
	if play == nil or play then
		armature:getAnimation():playWithIndex(index or 0);
	end
    
	return armature;
end

-- 数字匀速变化action，能在给定时间内从A速匀变化到B
function C.numberGO(node, a, b, duration, callback)
    callback = callback or function()end
    a = math.floor(a)
    b = math.floor(b)
    duration = (duration == 0 and 0.0001 or duration)
    local length =(b - a)
    local handler = { timeAcc = 0 }
    node:scheduleUpdateWithPriorityLua( function(deltaT)
        handler.timeAcc = handler.timeAcc + deltaT
        if handler.timeAcc >= duration then
            node:unscheduleUpdate()
        end
        local now = a +(math.min(handler.timeAcc, duration) / duration) * length
        if node.setString then node:setString(math.floor(now)) end
        local terminate = callback(now, handler.timeAcc >= duration)
        if terminate then
            node:unscheduleUpdate()
        end
    end , 1)
    callback(a)
end

function C.TransposeTable(t) --将二维表转置
    local tt = {}
    for row, rowT in ipairs(t) do
        for col, v in ipairs(rowT) do
            tt[col] = tt[col] or {}
            tt[col][row] = v
        end
    end
    return tt
end

--将数组t打乱，可以指定打乱的前len个单位
function C.shuffleTable(t, len)
    if type(t)~="table" then
        return
    end
    len = len or #t
    local tab = {}
    local index = 1
    for i = 1, len do
        local n = math.random(1, len - i + 1)
        if t[n] ~= nil then
            tab[index] = t[n]
            table.remove(t, n)
            index = index + 1
        end
    end
    for i, v in ipairs(t) do
        table.insert(tab, v)
    end
    for i, v in ipairs(tab) do
        t[i] = v
    end
    return tab
end

function C:getString(msg,start,length)
    local eof = 0
    for k = start,string.len(msg) do
        local g = C:truncateUTF8String(msg,start,k)
        if C:utfstrlen(g) == length then
            return g,k
        end
        eof = k
    end
    return msg, eof
end

function C:utfstrlen(str)
    if str == nil then return 0 end
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};

    local function func() 
        while left ~= 0 do
            local tmp=string.byte(str,-left);
            local i=#arr;
            while arr[i] do
                if tmp and tmp>=arr[i] then left=left-i;break;end
                i=i-1;
            end
            cnt=cnt+1;
        end    
    end

    local __TRACEBACK_ = function(msg)  
                            dump(msg)
                         end

    xpcall(func, __TRACEBACK_)
    return cnt;
end


function C:truncateUTF8String(s,start,n)
    local dropping = string.byte(s, n+1)
    if dropping ~= nil then
        if dropping >= 128 and dropping < 192 then
            return C:truncateUTF8String(s, start,n-1)
        end
    end
    return string.sub(s, start, n)

end

function C:nameStandardString(nameString, fontSize, width)
    -- 文字，字体大小，需要适配的像素宽度
    if not width then return nameString end
    local curLength = C:utfstrlen(nameString)
    local oldString = nameString
    -- print("nameStandardString")

    local test = ccui.Text:create(nameString, "", fontSize)
    while test:getContentSize().width > width do
        -- print(curLength)
        curLength = curLength - 1
        nameString = C:getString(nameString, 0, curLength)
        test:setString(nameString)
    end

    if #oldString ~= #nameString then
--        nameString = nameString .. ".."
        test:setString(nameString)
        if test:getContentSize().width > width then
--            nameString = C:getString(nameString, 0, curLength - 1) .. ".."
        end
    end
    return nameString
end

--清除所有定时器
if utils and utils.removeAllTimers then
    utils:removeAllTimers()
end

utils = Utils.new()

return C