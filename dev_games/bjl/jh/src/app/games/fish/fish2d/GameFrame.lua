--region GameFrame.lua
--Date 2018-03-27
--记录游戏中的数据、运算

local GameFrame = class("GameFrame")


GameFrame.GAME_PLAYER    =   4           --最大游戏人数

GameFrame.INVALID_CHAIR  =  0xFFFF       --无效的椅子号

function GameFrame:ctor()
    self.m_isGamePause = false

--    self.m_users = {}           --玩家信息
    self.m_myChairId = -1        --我自己的座位号
    self.m_myUserId = 0

    self.m_isFingerPressed = false --记录触屏已按下
    self.m_autoShoot = false    --自动射击
 	self.m_autoLock = false 	--自动锁定


    self.m_openAddSpeed = false  --开启加速模式
    self.m_openDouble = false    --开启双倍模式
    self.mAutoSpeedMultiple = 1  --加速的速率

    self.m_fishIndex = 0

    self._bFishInView = false
 	self.m_InViewFishs = {}       --记录在屏幕中的鱼m_InViewFishs[fishID] = FisModel

    self.m_InViewBullets = {}    --在屏幕中的子弹

    self.m_curSceneId = -1   --当前场景ID
    self._exchangeSceneing = false --正在切换场景

    self.m_SingleGameTotalGold = 0     --捕鱼总收获分数
    self.m_FishDealCountManager = {}   -- m_FishDealCountManager[fishtype] = count

    self.m_waitList = {}      --等待鱼列表
 	self.m_fishList = {}      --鱼列表
 	self.m_fishKingList = {}  --记录鱼王
 	self.m_fishCreateList = {} --创建鱼

 	self.m_fishArray = {}	--场景中鱼

    self.m_enterTime = 0	--进入时间 

    self.m_meNetType = 0    --我的网类型

    self.s_gameConfig = {}  --服务器下发的配置，对应场景数据 CMD_S_StatusFree

    self.m_BigFishStartType = 0  --服务器下发的需要显示在小地图的大鱼类型
    self.m_DisplayBloodFishStartType = 10 --服务器下发的需要同步HP的大鱼类型
end

function GameFrame:getCannonLevelByMriple(muriple)
    for i = 1, self.s_gameConfig.mulriple_count_ do
        if muriple == self.s_gameConfig.cannon_mulriple_[i] then
            return i
        end
    end
    return 0
end

function GameFrame:getCannonMaxLevel()
    return self.s_gameConfig.mulriple_count_
end

function GameFrame:getCannonMripleByLevel(cannonLevel)
    if cannonLevel > 0 and cannonLevel <= self.s_gameConfig.mulriple_count_  then
        return self.s_gameConfig.cannon_mulriple_[cannonLevel]
    end
    return self.s_gameConfig.cannon_mulriple_[1]
end

function GameFrame:getFishMultiple(fishType)
    if self.s_gameConfig.FishMultiple == nil then
        return 0
    end
    local mult = self.s_gameConfig.FishMultiple[fishType+1]
    if mult == nil then
        print("GameFrame:getFishMultiple fishType: ",fishType)
    end
    return mult
end

function GameFrame:getBulletConfig(cannonLevel)
    if cannonLevel > 0 and cannonLevel <= self.s_gameConfig.mulriple_count_  then
        return self.s_gameConfig.bullet_config_[cannonLevel]
    end
    return self.s_gameConfig.bullet_config_[1]
end

function GameFrame:getBulletSpeed(cannonLevel)
    if cannonLevel > 0 and cannonLevel <= self.s_gameConfig.mulriple_count_  then
        return self.s_gameConfig.bullet_config_[cannonLevel].speed
    end
    return self.s_gameConfig.bullet_config_[1].speed
end

function GameFrame:getCannonTypeByLevel(cannonLevel)
    local cannontype = 0
    if cannonLevel <= 3 then
        cannontype = 0
    elseif cannonLevel < 7 and cannonLevel > 3 then
        cannontype = 1
    else
        cannontype = 2
    end
    return cannontype
end

local fish2dbaseMultiple = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
local fishkingbaseMultiple = { 1, 2, 3, 5, 10, 50, 100 }

function GameFrame:getCannonBaseMultiple(level)
    level = level and level or 1
    local baseMult = 1
    local baseMultiple = nil
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        baseMultiple = fish2dbaseMultiple
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        baseMultiple = fishkingbaseMultiple
    else
        return 1
    end
    baseMult = baseMultiple[level]
    return baseMult ~= nil and baseMult or 1
end

function GameFrame:getRoomMultiple()
    local multi = self.s_gameConfig.room_multiple
    return  (multi ~= nil) and multi or 0
end

function GameFrame:selectMaxFish()
    local fishkey = 0

    return fishkey
end

--计算原点到目标点的夹角弧度
function GameFrame:calcRotate(srcPos,targetPos)
    local disqrt = (targetPos.x-srcPos.x) * (targetPos.x-srcPos.x) + (targetPos.y-srcPos.y) * (targetPos.y-srcPos.y)
    local dis = math.sqrt(disqrt)
    local sin_value = (targetPos.x - srcPos.x) / dis
    local angle = math.acos(sin_value)
    if targetPos.y > srcPos.y then
        angle = 2 * math.pi - angle
    end
    angle = angle + math.pi/2
    return angle
end


return GameFrame
--endregion
