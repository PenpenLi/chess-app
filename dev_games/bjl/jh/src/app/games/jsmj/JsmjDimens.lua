--[[--
    为适应多分辨率做的适配文件，主要计算用到的一些坐标参数和缩放比

    主要用到的相关参数：

    * scale_: 当前设计分辨率对实际分辨率的缩放比（按照高宽取最小的）
    * wScale_: 宽度缩放比
    * hScale_: 高度缩放比

]]
local JsmjDimens = class("JsmjDimens")

JsmjDimens.RESOLUTION_USER_DEFINE = "user" -- 用户自定义
JsmjDimens.RESOLUTION_480P = "480"
JsmjDimens.RESOLUTION_720P = "720"
JsmjDimens.RESOLUTION_1080P = "1080"

JsmjDimens.resolution_ = JsmjDimens.RESOLUTION_480P

---------------
-- 私有函数定义
---------------
local _initDataInSafeArea

--[[--
    横竖屏或者界面高宽变化了，重新初始化坐标参数
    @param w: 屏幕宽
    @param h: 屏幕高
    @param flag: True表示要切换成横屏，False表示要切换成竖屏
    @param resolution: 模式，不填的话按照分辨率选择
    @param offset: 自定义屏幕缩小尺寸
]]
function JsmjDimens:init(flag, resolution, offset)
    local w = 1136
    local h = 640

    if resolution then
        self.resolution_ = resolution
    else
        if (854 == w and 480 == h) or (480 == w and 854 == h) then
            self.resolution_ = JsmjDimens.RESOLUTION_480P
        elseif (1280 == w and 720 == h) or (720 == w and 1280 == h) then
            self.resolution_ = JsmjDimens.RESOLUTION_720P
        elseif (1920 == w and 1080 == h) or (1080 == w and 1920 == h) then
            self.resolution_ = JsmjDimens.RESOLUTION_1080P
        else
            self.resolution_ = JsmjDimens.RESOLUTION_USER_DEFINE
        end
    end

    -- 不需要拉伸到全屏宽或者全屏高的元素，使用 scale_
    -- 需要拉伸到全屏宽或者全屏高的元素，使用对应的缩放比，高是 hScale_，宽是 wScale_
    local size = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
--    if not size then
--        size = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
--    end

    if nil == flag then
        flag = true
    end

    self.flag_ = flag

    if flag then
        if size.width > size.height then
            self.wScale_ = size.width / w
            self.hScale_ = size.height / h
            self.setSize_ = {width = w, height = h}
        else
            self.wScale_ = size.width / h
            self.hScale_ = size.height / w
            self.setSize_ = {width = h, height = w}
        end
    else
        if size.width > size.height and device.platform ~= "windows" and device.platform ~= "mac" then
            self.wScale_ = size.height / w
            self.hScale_ = size.width / h
            self.setSize_ = {width = h, height = w}
        else
            self.wScale_ = size.width / w
            self.hScale_ = size.height / h
            self.setSize_ = {width = w, height = h}
        end
    end

    if self.wScale_ > self.hScale_ then
        self.scale_ = self.hScale_
    else
        self.scale_ = self.wScale_
    end

    self.sizeInPixels = {width = size.width, height = size.height}

    local winSize = size -- CCDirector:sharedDirector():getWinSize()

    self.size               = {width = winSize.width, height = winSize.height}
    self.width              = self.size.width
    self.height             = self.size.height
    self.cx                 = self.width / 2
    self.cy                 = self.height / 2
    self.c_left             = -self.width / 2
    self.c_right            = self.width / 2
    self.c_top              = self.height / 2
    self.c_bottom           = -self.height / 2
    self.left               = 0
    self.right              = self.width
    self.top                = self.height
    self.bottom             = 0
    self.widthInPixels      = self.sizeInPixels.width
    self.heightInPixels     = self.sizeInPixels.height

    -- 给出当前缩放比的情况下，设计分辨率在等比缩放后，在当前屏幕中的边界值
    local scaleWidth = self:getDimens(self.setSize_.width)
    local scaleHeight = self:getDimens(self.setSize_.height)
    self.matchLeft_ = (self.widthInPixels - scaleWidth) / 2
    self.matchRight_ = self.matchLeft_ + scaleWidth
    self.matchBottom_ = (self.heightInPixels - scaleHeight) / 2
    self.matchTop_ = self.matchBottom_ + scaleHeight

    -- 差距在 1 之间，就认为是同一个点
    if self.matchLeft_ < 1 then
        self.matchLeft_ = 0
    end

    if (self.widthInPixels - self.matchRight_) < 1 then
        self.matchRight_ = self.widthInPixels
    end

    if self.matchBottom_ < 1 then
        self.matchBottom_ = 0
    end

    if (self.heightInPixels - self.matchTop_) < 1 then
        self.matchTop_ = self.heightInPixels
    end

    -- HD 720P
    if w > h then
        w = 1280
        h = 720
    else
        w = 720
        h = 1280
    end

    if size.width > size.height then
        self.wScaleHD_ = size.width / w
        self.hScaleHD_ = size.height / h
    else
        self.wScaleHD_ = size.width / h
        self.hScaleHD_ = size.height / w
    end

    if (self.wScaleHD_ > self.hScaleHD_) then
        self.scaleHD_ = self.hScaleHD_
    else
        self.scaleHD_ = self.wScaleHD_
    end

    _initDataInSafeArea(self, w, h, offset)
end

--[[--

    根据当前缩放比计算缩放后的数值
    @param px: 标准分辨率上的数值
    @return 缩放后的数值
]]
function JsmjDimens:getDimens(px)
    return px * self.scale_
end

function JsmjDimens:getXDimens(px)
    return px * self.wScale_
end

function JsmjDimens:getYDimens(px)
    return px * self.hScale_
end

function JsmjDimens:getDimensHD(px)
    return px * self.scaleHD_
end

function JsmjDimens:getXDimensHD(px)
    return px * self.wScaleHD_
end

function JsmjDimens:getYDimensHD(px)
    return px * self.hScaleHD_
end

function JsmjDimens:getDimensSafe(px)
    return px * self.safeScale_
end

function JsmjDimens:getXDimensSafe(px)
    return px * self.wSafeScale_
end

function JsmjDimens:getYDimensSafe(px)
    return px * self.hSafeScale_
end

function JsmjDimens:convToSafeArea(x, y)
    local newX = x * self.wSafeRatio_ + self.widthOffset_
    local newY = y * self.hSafeRatio_ + self.heightOffset_
    return cc.p(newX, newY)
end

function JsmjDimens:convXToSafeArea(x)
    return x * self.wSafeRatio_ + self.widthOffset_
end

function JsmjDimens:convYToSafeArea(y)
    return y * self.hSafeRatio_ + self.heightOffset_
end

--[[--
    获取该参数的适配值
]]
function JsmjDimens:getDimensById(data)
    if not data or type(data) ~= "table" then
        printError(TAG, "getDimensById, data is nil or not table!!!")
        return 0
    end
    if data[self.resolution_] then
        return self:getDimens(data[self.resolution_])
    end

    return 0
end

--[[--
    获取该参数的原始值
]]
function JsmjDimens:getOriginalById(data)
    if not data or type(data) ~= "table" then
        printError(TAG, "getOriginalById, data is nil or not table!!!")
        return 0
    end
    if data[self.resolution_] then
        return data[self.resolution_]
    end

    return 0
end

--[[--
    获取该值动态适配后的值
    公共功能的传入的基准分辨率（HD）标准值可能高于游戏的基准适配分辨率
]]
function JsmjDimens:getDimensByDynAdapt(px)
    if JsmjDimens.RESOLUTION_720P == self.resolution_ then
        px = px * self.scale_
    else
        px = px * self.scale_ / 1.5
    end

    return px
end

--[[--
    获取该值wScale_动态适配后的值
    公共功能的传入的基准分辨率（HD）标准值可能高于游戏的基准适配分辨率
]]
function JsmjDimens:getXDimensByDynAdapt(px)
    if JsmjDimens.RESOLUTION_720P == self.resolution_ then
        px = px * self.wScale_
    else
        px = px * self.wScale_ / 1.5
    end

    return px
end

--[[--
    获取该值hScale_动态适配后的值
    公共功能的传入的基准分辨率（HD）标准值可能高于游戏的基准适配分辨率
]]
function JsmjDimens:getYDimensByDynAdapt(px)
    if JsmjDimens.RESOLUTION_720P == self.resolution_ then
        px = px * self.hScale_
    else
        px = px * self.hScale_ / 1.5
    end

    return px
end

---------------
-- 私有函数实现
---------------
--[[
    描述: 初始化安全区域内相应数据
    @param self
    @param w
    @param h
    @param customizeOffset 自定义屏幕缩小尺寸
]]
function _initDataInSafeArea(self, w, h, customizeOffset)
    --local statusBarHeight = JJInterface:getStatusBarHeight()
    --local navigationBarHeight = JJInterface:getNavigationBarHeight()
    local safeSize = {width = self.size.width, height = self.size.height}

    self.widthOffset_ = 0
    self.heightOffset_ = 0

    local offset = 0
    --if navigationBarHeight > 0 then
    --    offset = (navigationBarHeight > statusBarHeight) and navigationBarHeight or statusBarHeight
    --end

    if customizeOffset then
        offset = customizeOffset
    end

    if self.flag_ then
        self.widthOffset_ = offset
        safeSize.width = safeSize.width - self.widthOffset_ * 2
        if safeSize.width > safeSize.height then
            self.wSafeScale_ = safeSize.width / w
            self.hSafeScale_ = safeSize.height / h
        else
            self.wSafeScale_ = safeSize.width / h
            self.hSafeScale_ = safeSize.height / w
        end
    else
        self.heightOffset_ = offset
        safeSize.height = safeSize.height - self.heightOffset_ * 2
        if safeSize.width > safeSize.height and device.platform ~= "windows" and device.platform ~= "mac" then
            self.wSafeScale_ = safeSize.height / w
            self.hSafeScale_ = safeSize.width / h
        else
            self.wSafeScale_ = safeSize.width / w
            self.hSafeScale_ = safeSize.height / h
        end
    end

    if self.wSafeScale_ > self.hSafeScale_ then
        self.safeScale_ = self.hSafeScale_
    else
        self.safeScale_ = self.wSafeScale_
    end

    self.wSafeRatio_ = safeSize.width / self.width
    self.hSafeRatio_ = safeSize.height / self.height
    self.safeWidth_ = self.width - self.widthOffset_
    self.safeHeight_ = self.height - self.heightOffset_

    self.safeLeft_          = self.widthOffset_
    self.safeRight_         = self.width - self.widthOffset_
    self.safeTop_           = self.height - self.heightOffset_
    self.safeBottom_        = self.heightOffset_
end

return JsmjDimens
