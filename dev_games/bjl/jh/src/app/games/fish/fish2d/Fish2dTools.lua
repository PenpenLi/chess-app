-- region Fish2dTools.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

Fish2dTools = { }

-- 2d捕鱼
Fish2dTools.GAME_TYPE_FISH2D = 1
-- 捕鱼王
Fish2dTools.GAME_TYPE_FISHKING = 2

Fish2dTools.mGame_Type = 1

Fish2dTools.mGameResPre_C2d = "fish"
Fish2dTools.mGameResPre_CKing = "FishkingGameScene"

Fish2dTools.mGameResPre = Fish2dTools.mGameResPre_C2d

-- 每个玩家允许的最多子弹
Fish2dTools.BULLETCOUNT_MAX = 40

Fish2dTools.M_PI_2 = 1.5707963267948
Fish2dTools.M_PI = 3.141592653589793

Fish2dTools.kRevolutionWidth = 1334
Fish2dTools.kRevolutionHeight = 750

Fish2dTools.mWorldScaleRate = 1

Fish2dTools.BIRD_FRAME_SPEED = 0.26
Fish2dTools.BIRD_MOVE_NORMAL = 1
Fish2dTools.BIRD_MOVE_RUN_AWAY = 40

Fish2dTools.MINMAP_RATE_X = 0.1274
Fish2dTools.MINMAP_RATE_Y = 0.1267
-- 鱼类型
Fish2dTools.BIRD_TYPE_0 = 0
Fish2dTools.BIRD_TYPE_1 = 1
Fish2dTools.BIRD_TYPE_2 = 2
Fish2dTools.BIRD_TYPE_3 = 3
Fish2dTools.BIRD_TYPE_4 = 4
Fish2dTools.BIRD_TYPE_5 = 5
Fish2dTools.BIRD_TYPE_6 = 6
Fish2dTools.BIRD_TYPE_7 = 7
Fish2dTools.BIRD_TYPE_8 = 8
Fish2dTools.BIRD_TYPE_9 = 9
Fish2dTools.BIRD_TYPE_10 = 10
Fish2dTools.BIRD_TYPE_11 = 11
Fish2dTools.BIRD_TYPE_12 = 12
Fish2dTools.BIRD_TYPE_13 = 13
Fish2dTools.BIRD_TYPE_14 = 14
Fish2dTools.BIRD_TYPE_15 = 15
Fish2dTools.BIRD_TYPE_16 = 16
Fish2dTools.BIRD_TYPE_17 = 17
Fish2dTools.BIRD_TYPE_18 = 18
Fish2dTools.BIRD_TYPE_19 = 19
Fish2dTools.BIRD_TYPE_20 = 20
Fish2dTools.BIRD_TYPE_21 = 21
Fish2dTools.BIRD_TYPE_22 = 22
Fish2dTools.BIRD_TYPE_23 = 23
Fish2dTools.BIRD_TYPE_24 = 24
Fish2dTools.BIRD_TYPE_25 = 25
Fish2dTools.BIRD_TYPE_26 = 26
Fish2dTools.BIRD_TYPE_27 = 27
Fish2dTools.BIRD_TYPE_28 = 28
Fish2dTools.BIRD_TYPE_29 = 29

Fish2dTools.BIRD_TYPE_NULL = -1
Fish2dTools.MAX_BIRD_TYPE = 30

Fish2dTools.BIRD_PAUSE = Fish2dTools.BIRD_TYPE_18	-- 定屏炸弹
Fish2dTools.BOMB_SMALL = Fish2dTools.MAX_BIRD_TYPE	-- 小型炸弹
Fish2dTools.BOMB_LARGE = Fish2dTools.MAX_BIRD_TYPE	-- 大型炸弹
Fish2dTools.BOMB_ULTIMATELY = Fish2dTools.MAX_BIRD_TYPE	-- 全屏炸弹
Fish2dTools.BOSS_FISH = Fish2dTools.BIRD_TYPE_29	-- BOSS

-- 特殊鱼
Fish2dTools.BIRD_TYPE_CHAIN = 40		-- 闪电鱼
Fish2dTools.BIRD_TYPE_RED = 41		-- 红鱼
Fish2dTools.BIRD_TYPE_INGOT = 42		-- 元宝鱼
-- 一箭多雕
Fish2dTools.BIRD_TYPE_ONE = 50
Fish2dTools.BIRD_TYPE_TWO = 51
Fish2dTools.BIRD_TYPE_THREE = 52
Fish2dTools.BIRD_TYPE_FOUR = 53
Fish2dTools.BIRD_TYPE_FIVE = 54

-- 鱼效果类型
Fish2dTools.BIRD_ITEM_ZORDER_0 = 200
Fish2dTools.BIRD_ITEM_ZORDER_1 = 201
Fish2dTools.BIRD_ITEM_BOMB_EX_0 = 202
Fish2dTools.BIRD_ITEM_BOMB_EX_1 = 203

-- 子弹类型
Fish2dTools.BULLET_PENETRATE = 0x01		-- 穿透
Fish2dTools.BULLET_DOUBLE = 0X02		-- 双炮
Fish2dTools.BULLET_Fury = 0x04		-- 狂暴

function Fish2dTools.toCCP(x, y)
    return cc.p(x, Fish2dTools.kRevolutionHeight * Fish2dTools.mWorldScaleRate - y)
end

function Fish2dTools.toNetPoint(x, y)
    return cc.p(x, Fish2dTools.kRevolutionHeight * Fish2dTools.mWorldScaleRate - y)
end

function Fish2dTools.toCCPNoScale(x, y)
    return cc.p(x, Fish2dTools.kRevolutionHeight - y)
end

function Fish2dTools.toNetPointNoScale(x, y)
    return cc.p(x, Fish2dTools.kRevolutionHeight - y)
end

function Fish2dTools.toNetRotation(angle)
    return math.rad(angle)
end

function Fish2dTools.toCCRotation(rotation)
    return math.deg(rotation)
end

-- 计算原点到目标点的夹角弧度
function Fish2dTools.calcRotate(srcPos, targetPos)
    local disqrt =(targetPos.x - srcPos.x) *(targetPos.x - srcPos.x) +(targetPos.y - srcPos.y) *(targetPos.y - srcPos.y)
    local dis = math.sqrt(disqrt)
    local sin_value =(targetPos.x - srcPos.x) / dis
    local angle = math.acos(sin_value)
    if targetPos.y > srcPos.y then
        angle = 2 * math.pi - angle
    end
    angle = angle + math.pi / 2
    return angle
end

function Fish2dTools.isFishNeedNarrowing(birdType)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return false
    end
    if birdType == Fish2dTools.BIRD_TYPE_18 or
        birdType == Fish2dTools.BIRD_TYPE_19 or
        birdType == Fish2dTools.BIRD_TYPE_27
    then
        return true
    end
    return false
end

function Fish2dTools.isSpecialBird(birdType)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return false
    end
    if birdType == Fish2dTools.BIRD_TYPE_CHAIN or
        birdType == Fish2dTools.BIRD_TYPE_RED or
        birdType == Fish2dTools.BIRD_TYPE_ONE or
        birdType == Fish2dTools.BIRD_TYPE_TWO or
        birdType == Fish2dTools.BIRD_TYPE_THREE or
        birdType == Fish2dTools.BIRD_TYPE_FOUR or
        birdType == Fish2dTools.BIRD_TYPE_FIVE or
        birdType == Fish2dTools.BIRD_TYPE_INGOT
    then
        return true
    end
    return false
end

function Fish2dTools.isSpecialRoundBird(birdType)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return false
    end
    if
        birdType == Fish2dTools.BIRD_TYPE_ONE or
        birdType == Fish2dTools.BIRD_TYPE_TWO or
        birdType == Fish2dTools.BIRD_TYPE_THREE or
        birdType == Fish2dTools.BIRD_TYPE_FOUR or
        birdType == Fish2dTools.BIRD_TYPE_FIVE
    then
        return true
    end
    return false
end
function Fish2dTools.isNeedGoStraightBird(birdType)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return false
    end
    if
        birdType == Fish2dTools.BIRD_TYPE_24 or
        birdType == Fish2dTools.BIRD_TYPE_25 or
        birdType == Fish2dTools.BIRD_TYPE_26 or
        birdType == Fish2dTools.BIRD_TYPE_27 or
        birdType == Fish2dTools.BIRD_TYPE_28
    then
        return true
    end
    return false
end


function Fish2dTools.isReverseAtGoStraightBird(start_p, end_p)
    local result_p = cc.pSub(end_p, start_p)
    if result_p.x >= 0 then
        return false
    elseif result_p.x < 0 then
        return true
    end
    return true
end

----------------------------------------------------------------------------------


function Fish2dTools.createAnimate(name, time)
    local animation = cc.AnimationCache:getInstance():getAnimation(name)
    if not animation then
        return nil
    end
    local animate = cc.Animate:create(animation)
    if time > 0 then
        animate:setDuration(time)
    end
    return animate
end

function Fish2dTools.animationWithFrame(frameName, beginNun, endNum, delay)
    local frame = nil
    local animation = cc.Animation:create()
    for index = beginNun, endNum do
        local name = string.format("%s%d.png", frameName, index)
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
        animation:addSpriteFrame(frame)
    end
    animation:setDelayPerUnit(delay)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(1)

    local animate = cc.Animate:create(animation)
    return animate
end

function Fish2dTools.createFishAnimate(ftype)
    local name = nil
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        name = string.format("bird%d_move", ftype)
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        name = string.format("fish%d_move", ftype)
    end

    return Fish2dTools.createAnimate(name, 0)
end

function Fish2dTools.createFishDeadAnimate(ftype)
    local name = nil
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        if ftype > 27 then
            name = string.format("bird%d_dead", ftype)
        else
            name = string.format("bird%d_move", ftype)
        end
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        name = string.format("fish%d_move", ftype)
    end
    return Fish2dTools.createAnimate(name, 0)
end

function Fish2dTools.particle_play(viewParent, pt, particleName, delay, scale)
    local particleSystem = cc.ParticleSystemQuad:create(particleName)
    if particleSystem then
        particleSystem:setPosition(pt.x, pt.y)
        viewParent:addChild(particleSystem)
        local act = cc.Sequence:create(
        cc.DelayTime:create(particleSystem:getLife() + delay),
        cc.RemoveSelf:create(),
        nil)
        particleSystem:runAction(act)
        particleSystem:setScale(scale)
    end
end

----------------------------------------------------------------
local static_local_index_ = 0

function Fish2dTools:getNewIndex()
    static_local_index_ = static_local_index_ + 1
    if static_local_index_ > 1000000 then
        static_local_index_ = 1
    end
    return static_local_index_
end

function xSize(x, y)
    return cc.p(x, y)
end

local BIRD_SIZES = {
    xSize(15,48),xSize(18,40),xSize(36,58),xSize(42,72),-- 4
    xSize(33,93),xSize(54,78),xSize(37,86),xSize(52,97),-- 8
    xSize(56,112),xSize(52,120),xSize(71,101),xSize(48,112),-- 12
    xSize(112,105),xSize(45,157),xSize(69,209),xSize(60,100),-- 16
    xSize(100,180),xSize(140,250),xSize(200,180),xSize(180,210),-- 20
    xSize(250,120),xSize(100,500),xSize(200,200),xSize(70,480),-- 24
    xSize(180,160),xSize(180,230),xSize(280,240),xSize(250,440),-- 28
    xSize(230,195),xSize(270,400),-- 30
};

local SPECIAL_BIRD_SIZES = {
    xSize(90,90),xSize(225,90),xSize(150,150),xSize(165,150),xSize(165,165)
};

function Fish2dTools.get_fish_size(fish_type)
    return BIRD_SIZES[fish_type + 1]
end

function Fish2dTools.get_special_fish_size(fish_type)
    return SPECIAL_BIRD_SIZES[fish_type + 1]
end

function Fish2dTools.compute_collision(bird_x, bird_y, bird_width, bird_height, bird_rotation,
        bullet_x, bullet_y, bullet_radius)

    local sint, cost
    local w, h, rx, ry, r

    cost = math.cos(bird_rotation)
    sint = math.sin(bird_rotation)

    w = bird_width
    h = bird_height
    r = bullet_radius
    rx =(bullet_x - bird_x) * cost +(bullet_y - bird_y) * sint
    ry = -(bullet_x - bird_x) * sint +(bullet_y - bird_y) * cost

    local dx = math.min(rx, w * 0.5)
    dx = math.max(dx, - w * 0.5)

    local dy = math.min(ry, h * 0.5)
    dy = math.max(dy, - h * 0.5)

    return(rx - dx) *(rx - dx) +(ry - dy) *(ry - dy) <= r * r;
end

return Fish2dTools

-- endregion
