--[[--
    界面: play打骰子动画
]]

local C = class("JsmjDiceAnim", cc.Node)

local PIC_MODE_BIG = "big"
local PIC_MODE_SMALL = "small"
local MAX_TILE = 144

--[[--
    构造函数
]]
function C:ctor(parent, width, height)
    self.seat_ = -1
    self.width_ = width
    self.height_ = height
    self.routes_ = {}
    self.time_ = {}
    -- self:initRoute()
    math.randomseed(os.time())
    table.insert(self.time_, 0.1)
    table.insert(self.time_, 0.15)
    table.insert(self.time_, 0.35)
    table.insert(self.time_, 0.2)
    table.insert(self.time_, 0.4)
    table.insert(self.time_, 0.6)

    -- table.insert(self.time_,2)
    -- table.insert(self.time_,0.5)
    -- table.insert(self.time_,2)
    -- table.insert(self.time_,5)
end

--[[
    获取图片路径
]]
local function _getPic(self, mode, i)
    return GAME_JSMJ_IMAGES_RES .. "dice/mahjong_dice_" .. mode .. "_value" .. tostring(i) .. ".png"
end

--[[--
    获取图片路径
]]
local function _getRandomValue()
    math.random(1, 6)
    -- 第一次是一个固定值
    return math.random(1, 6)
end

--[[--
    获取随机数图片路径
]]
local function _getRandomPic(self)
    return _getPic(self, PIC_MODE_SMALL, _getRandomValue())
end

--[[--
    初始化骰子动画路线
]]
function C:initRoute()
    local width, height = self.width_, self.height_
    local diceWdithSmall, diceHeightSmall = 40, 40
    local route1 = {}
    -- 骰子1
    local route2 = {}
    -- 骰子2
    self.routes_ = {}
    table.insert(self.routes_, route1)
    table.insert(self.routes_, route2)
    if self.seat_ == 1 then --bottom
        table.insert(route1, cc.p(width / 2, 0))
        table.insert(route1, cc.p(0, height * 3 / 4))
        table.insert(route1, cc.p(width / 6, height))
        table.insert(route1, cc.p((width / 2 + diceWdithSmall), height / 2))

        table.insert(route2, cc.p(width / 2, 0))
        table.insert(route2, cc.p(width, height * 3 / 4))
        table.insert(route2, cc.p(width * 5 / 6, height))
        table.insert(route2, cc.p((width / 2 - diceHeightSmall), (height / 2 - diceHeightSmall)))
    elseif self.seat_ == 2 then --up
        table.insert(route1, cc.p(width / 2, height))
        table.insert(route1, cc.p(0, height / 4))
        table.insert(route1, cc.p(width / 6, 0))
        table.insert(route1, cc.p(width / 2 + diceWdithSmall, height / 2))

        table.insert(route2, cc.p(width / 2, height))
        table.insert(route2, cc.p(width, height / 4))
        table.insert(route2, cc.p(width * 5 / 6, 0))
        table.insert(route2, cc.p(width / 2 - diceHeightSmall, height / 2 - diceHeightSmall))
--    elseif self.pos_ == MahjongDef.POSITION_LEFT then
--        table.insert(route1, ccp(0, height / 2))
--        table.insert(route1, ccp(width * 3 / 4, height))
--        table.insert(route1, ccp(width, height * 5 / 6))
--        table.insert(route1, ccp(width / 2, (height / 2 - diceHeightSmall)))

--        table.insert(route2, ccp(0, height / 2))
--        table.insert(route2, ccp(width * 3 / 4, 0))
--        table.insert(route2, ccp(width, height / 6))
--        table.insert(route2, ccp((width / 2 - diceWdithSmall), height / 2))
--    elseif self.pos_ == MahjongDef.POSITION_RIGHT then
--        table.insert(route1, ccp(width, height / 2))
--        table.insert(route1, ccp(width / 4, height))
--        table.insert(route1, ccp(0, height * 5 / 6))
--        table.insert(route1, ccp(width / 2, height / 2 - diceHeightSmall))

--        table.insert(route2, ccp(width, height / 2))
--        table.insert(route2, ccp(width / 4, 0))
--        table.insert(route2, ccp(0, height / 6))
--        table.insert(route2, ccp(width / 2 - diceWdithSmall, height / 2))
    end
end

--[[--
    播放动画

    @param pos:动画位置
    @param value1:第一个骰子的最终值
    @param value2:第二个骰子的最终值

    @return none
]]
function C:start(seat, value1, value2)
    self.seat_ = seat
    self:initRoute()
    local img1, img2 = _getRandomPic(self), _getRandomPic(self)
    local sprite1 =display.newSprite( img1)
    local sprite2 =display.newSprite( img2)
    --local sprite1, sprite2 = CCSprite:create(img1), CCSprite:create(img2)
    if not sprite1 or not sprite2 then
        return
    end
    local array1 = {}
    local array2 = {}
    --local array1, array2 = CCArray:create(), CCArray:create()

    local function _removeSelf(spt)
        spt:removeFromParent()
    end

    local function _removeSelf2(spt)
        spt:removeFromParent()
        self:onDiceAnimEnd()
    end

    local function _changePic(spt)
        spt:setTexture(_getRandomPic(self))
    end

    local function _changeFinalPic1()
        sprite1:setTexture(_getPic(self, PIC_MODE_SMALL, value1))
    end

    local function _changeFinalPic2()
        sprite2:setTexture(_getPic(self, PIC_MODE_SMALL, value2))
    end

    array1[1] = CCMoveTo:create(self.time_[1], self.routes_[1][2])
    array1[2] = CCCallFuncN:create(_changePic)
    array1[3] = CCMoveTo:create(self.time_[2], self.routes_[1][3])
    array1[4] = CCCallFuncN:create(_changePic)
    array1[5] = CCMoveTo:create(self.time_[3], self.routes_[1][4])
    array1[6] = CCCallFuncN:create(_changeFinalPic1)
    array1[7] = CCJumpBy:create(self.time_[4], cc.p(2, 2), 2, math.random(2))
    -- array1:addObject(CCRotateTo:create(self.time_[5],math.random(-0,360)))
    array1[8] = CCMoveBy:create(self.time_[6], cc.p(0, 0))

    array2[1] = CCMoveTo:create(self.time_[1], self.routes_[2][2])
    array2[2] = CCCallFuncN:create(_changePic)
    array2[3] = CCMoveTo:create(self.time_[2], self.routes_[2][3])
    array2[4] = CCCallFuncN:create(_changePic)
    array2[5] = CCMoveTo:create(self.time_[3], self.routes_[2][4])
    array2[6] = CCCallFuncN:create(_changeFinalPic2)
    array2[7] = CCJumpBy:create(self.time_[4], cc.p(-2, -2), 2, math.random(2))
    -- array2:addObject(CCRotateTo:create(self.time_[5],math.random(-360,0)))
    array2[8] = CCMoveBy:create(self.time_[6], cc.p(0, 0))

    sprite1:setAnchorPoint(cc.p(0, 0))
    sprite1:setPosition(self.routes_[1][1])

    sprite2:setAnchorPoint(cc.p(0, 0))
    sprite2:setPosition(self.routes_[2][1])

    self:addChild(sprite1)
    self:addChild(sprite2)

    array1[9] = CCCallFuncN:create(_removeSelf)
    array2[9] = CCCallFuncN:create(_removeSelf2)

    local action1 = cc.Sequence:create(array1)
    local action2 = cc.Sequence:create(array2)

    sprite1:runAction(action1)
    sprite2:runAction(action2)
end

--退出函数
function C:onExit()
    self.routes_ = nil
    self.time_ = nil
    self.animEndListener_ = nil
end

--[[--
    设置动画结束监听
    @param func:动画结束执行方法
]]
function C:setOnAnimEndListener(func)
    self.animEndListener_ = func
end

--动画结束执行方法
function C:onDiceAnimEnd()
    self.animEndListener_()
end

return C