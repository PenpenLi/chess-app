-- region CannonLayer.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local CannonLayer = class("CannonLayer", cc.Layer)
local Cannon = require('app.games.fish.fish2d.Cannon')
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')

function CannonLayer:ctor(viewParent)
    print("---------CannonLayer:ctor--------")
    self.parent = viewParent
    self._dataModel = self.parent._dataModel

    self.rootNode = nil
    self.m_cannonList = { }

    for i = 0, self._dataModel.GAME_PLAYER - 1 do
        self.m_cannonList[i] = Cannon:create(self, i)
        self.m_cannonList[i]:showCannon(false)
        self:addChild(self.m_cannonList[i])
    end

    self.m_myChairID = 0

    -- 是否一直按下屏幕
    self._dataModel.m_isFingerPressed = false
    -- 触摸事件
    local function onTouchBegan(touch, event)
        if nil == self.onTouchBegan then
            return false
        end
        return self:onTouchBegan(touch, event)
    end

    local function onTouchMoved(touch, event)
        if nil ~= self.onTouchMoved then
            self:onTouchMoved(touch, event)
        end
    end

    local function onTouchEnded(touch, event)
        if nil ~= self.onTouchEnded then
            self:onTouchEnded(touch, event)
        end
    end

    local function onTouchCancelled(touch, event)
        if nil ~= self.onTouchCancelled then
            self:onTouchCancelled(touch, event)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function CannonLayer:loadUI(uiRoot, myChair)
    print("CannonLayer:loadUI myChair: ", myChair)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        for i = 0, self._dataModel.GAME_PLAYER - 1 do
            self:getCannon(i):loadUI(uiRoot)
        end
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        self.m_cannonList[myChair]:loadUI(uiRoot)
    end
end

function CannonLayer:setMyCharId(chairId)
    self.m_myChairID = chairId
end

function CannonLayer:getCannon(chairId)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        if self.m_myChairID ~= chairId then
            return nil
        end
    end
    return self.m_cannonList[chairId]
end

function CannonLayer:getMyCannon()
    return self:getCannon(self.m_myChairID)
end

function CannonLayer:setGold(chairId, gold)
    self:getCannon(chairId):setGold(gold)
end

function CannonLayer:addGold(chairId, gold)
    local cannon = self:getCannon(chairId)
    cannon:setGold(cannon.gold_ + gold)
end

-- 发炮时设置金币数、炮台方向、炮口动画、炮倍数
function CannonLayer:bulletSend(chairId, cannonMulriple, rotation, curGold, bMeLocalFire)
    local cannon = self:getCannon(chairId)
    if not cannon then
        return
    end
    local isMe = chairId == self.m_myChairID
    if not isMe then
        cannon:setGold(curGold)
    elseif not bMeLocalFire then
        if cannon.currentSendBulletCount_ > 10 then
            cannon:setGold(curGold)
            cannon.currentSendBulletCount_ = 0
        end
    else
        cannon:setGold(curGold)
    end

    cannon:setBowRotation(rotation)

    if bMeLocalFire or not isMe then
        cannon:setCannonMuitle(cannonMulriple)
        local level = self._dataModel:getCannonLevelByMriple(cannonMulriple)
        cannon:setCannonLevel(level, false)

        cannon:fire(bMeLocalFire)
    end

end

function CannonLayer:onTouchBegan(touch, unused_event)
    local touchpos = touch:getLocation()
    -- print("---CannonLayer:onTouchBegan---touch: ", touchpos.x, touchpos.y)
    local Cannon = self:getMyCannon()
    if not Cannon then
        print("CannonLayer:onTouchBegan myCannon is nil")
        return false
    end

    local paotaiPos = Cannon:getPaotaiPos()
    local rotation = self._dataModel:calcRotate(paotaiPos, touchpos)
    local isLock = self._dataModel.m_autoLock

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        if Cannon:getCannonLevel() >= 6 then
            -- 使用鱼雷时，只能点击鱼攻击
            if not Cannon:isLockFish() then
                local touchedFish = self.parent:collisionPosFish(touchpos)
                print("CannonLayer:onTouchBegan touchedFish： ", touchedFish)
                if touchedFish then
                    Cannon:setBowRotation(rotation)
                    -- 锁定切换为点中的鱼
                    Cannon:setLockFish(touchedFish)
                    touchedFish:setLock(true, self.m_myChairID)
                    self.parent:toFire()
                end
            else
                self.parent:toFire()
            end

            return true
        else
            if self._dataModel.m_autoShoot then
                isLock = true  --只能模式下可以手动选择目标
            end
        end
    end

    if isLock then
        -- 检查当前是否有点中鱼
        local touchedFish = self.parent:collisionPosFish(touchpos)

        if touchedFish then
            Cannon:setBowRotation(rotation)
            -- 锁定切换为点中的鱼
            Cannon:setLockFish(touchedFish)
            touchedFish:setLock(true, self.m_myChairID)
        else
            if not Cannon:isLockFish() then
                Cannon:setBowRotation(rotation)
            end
        end

        self.parent:toFire()
    else
        Cannon:setBowRotation(rotation)
        self._dataModel.m_isFingerPressed = true

        self.parent:toFire()
    end

    return true
end

function CannonLayer:onTouchMoved(touch, unused_event)
    local isLock = self._dataModel.m_autoLock
    if isLock then
        return
    end
    local touchpos = touch:getLocation()
    -- print("---CannonLayer:onTouchMoved---touch: ", touchpos.x, touchpos.y)
    local Cannon = self:getMyCannon()
    if not Cannon then
        return
    end
    local paotaiPos = Cannon:getPaotaiPos()
    local rotation = self._dataModel:calcRotate(paotaiPos, touchpos)
    Cannon:setBowRotation(rotation)
end

function CannonLayer:onTouchEnded(touch, unused_event)
    local touchpos = touch:getLocation()
    -- print("---CannonLayer:onTouchEnded---touch: ", touchpos.x, touchpos.y)

    self._dataModel.m_isFingerPressed = false
end

function CannonLayer:onTouchCancelled(touch, unused_event)
    local touchpos = touch:getLocation()
    -- print("---CannonLayer:onTouchCancelled---touch: ", touchpos.x, touchpos.y)

    self._dataModel.m_isFingerPressed = false
end

return CannonLayer
-- endregion
