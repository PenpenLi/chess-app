-- region Bullet.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Bullet = class("Bullet", cc.Sprite)
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')
local scheduler = cc.Director:getInstance():getScheduler()

function Bullet:ctor(viewParent, isShadow)
    -- Fish2dGameScene
    self.parent = viewParent
    self._dataModel = self.parent._dataModel

    self.mId = 0

    -- 子弹等级1-10
    self.mBulletLevel = 1
    self.mImgIndex = 0

    self.mRotation = 0
    self.mBulletSpeed = 0
    self.mMove_dx = 0
    self.mMove_dy = 0

    self.m_schedule = nil

    self.m_shadowNode = nil
    -- 正常子弹关联的影子节点
    self.m_baseNode = nil
    -- 影子节点关联的正常子弹
    self.m_IsShadow = isShadow
end

-- 重置子弹数据，便于对象复用
function Bullet:resetData(chairId, bulletLevel)
    self.mChairId = chairId
    -- 锁定追踪的鱼
    self.mFishId = self.parent:getLockFishId(self.mChairId)

    self.mId = 0
    if not isShadow then
        self.mId = Fish2dTools:getNewIndex()
    end

    -- 子弹等级1-10
    self.mBulletLevel = bulletLevel

    local imgPreName = ""
    local imgIndex = 1
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        if bulletLevel <= 3 then
            imgIndex = 1
        elseif bulletLevel < 7 and bulletLevel >= 4 then
            imgIndex = 2
        else
            imgIndex = 3
        end
        imgPreName = "c2d_bullet_"
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        imgIndex = bulletLevel
        imgPreName = "cking_bullet_"
    end

    if self.mImgIndex ~= imgIndex then
        self.mImgIndex = imgIndex
        local imgname = string.format("%s0%d.png", imgPreName, self.mImgIndex)
        self:setSpriteFrame(imgname)
    end

    self.mRotation = 0
    self.mBulletSpeed = 0
    self.mMove_dx = 0
    self.mMove_dy = 0
    self.isToSetRotation = true
    if self.m_schedule ~= nil then
        self:unSchedule()
    end

    self.m_shadowNode = nil
    -- 正常子弹关联的影子节点
    self.m_baseNode = nil
    -- 影子节点关联的正常子弹
end

-- 设置关联的影子节点
function Bullet:setShdowNode(shadowNode)
    self.m_shadowNode = shadowNode
end

function Bullet:setBaseNode(baseNode)
    self.m_baseNode = baseNode
end

function Bullet:setMoveRotation(rotation)
    self.mRotation = rotation

    self.mMove_dx = math.cos(self.mRotation - Fish2dTools.M_PI_2)
    self.mMove_dy = math.sin(self.mRotation - Fish2dTools.M_PI_2)

    self.isToSetRotation = true
    -- print("---Bullet:setMoveRotation---self.mBulletSpeed, angle, self.mRotation, self.mMove_dx,self.mMove_dy: ",self.mBulletSpeed,angle, self.mRotation,self.mMove_dx,self.mMove_dy )
end

function Bullet:setSpeed(bulletSpeed)
    self.mBulletSpeed = bulletSpeed
end

function Bullet:born(isShadow)
    local opacity = 255
    self.m_IsShadow = isShadow
    if isShadow then
        self:setColor(cc.c3b(0, 0, 0))
        opacity = 100
    else
        self:setColor(cc.c3b(255, 255, 255))
        opacity = 255
    end
    self:runAction(cc.FadeTo:create(0.05, opacity))
end

function Bullet:onEnter()
    self:schedulerUpdate()
end


function Bullet:onExit()
    -- self:removeAllComponents()
    self:unSchedule()
end

function Bullet:schedulerUpdate()
    -- print("---Bullet:schedulerUpdate---")
    local function updateBullet(dt)
        if self.m_IsShadow then
            -- 影子子弹移动
            if self.m_baseNode then
                self:setBulletRotation(self.m_baseNode:getRotation())
                self:setPositionX(self.m_baseNode:getPositionX() + 15)
                self:setPositionY(self.m_baseNode:getPositionY() -15)
            end
            return
        end
        -- 更新锁定鱼id
        if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
            self.mFishId = self.parent:getLockFishId(self.mChairId)
        end

        if self.mFishId ~= -1 then
            local fishModel = self._dataModel.m_InViewFishs[self.mFishId]
            if not self:checkCanCollision(fishModel) then
                self.mFishId = -1
            end
        end
        --
        if self.mFishId == -1 then
            self:normalUpdate(dt)
        else
            self:followFish(dt)
        end
        -- 检测碰撞
        self:collisionToFish()
    end

    if not self.m_schedule then
        self.m_schedule = scheduler:scheduleScriptFunc(updateBullet, 0, false)
    end
end


-- 正常发射
function Bullet:normalUpdate(dt)
    local pos = Fish2dTools.toNetPointNoScale(self:getPositionX(), self:getPositionY())
    local addx = self.mMove_dx * self.mBulletSpeed * dt
    local addy = self.mMove_dy * self.mBulletSpeed * dt
    pos.x = pos.x + addx
    pos.y = pos.y + addy
    -- print("1 pos addx,addy, x, y: ",addx,addy,pos.x,pos.y)

    if pos.x < 0 then
        pos.x = - pos.x
        self.mMove_dx = - self.mMove_dx
        self.mRotation = - self.mRotation
        self:setFishId(-1)
        self.isToSetRotation = true
    elseif pos.x > Fish2dTools.kRevolutionWidth then
        pos.x = Fish2dTools.kRevolutionWidth -(pos.x - Fish2dTools.kRevolutionWidth)
        self.mMove_dx = - self.mMove_dx
        self.mRotation = - self.mRotation
        self:setFishId(-1)
        self.isToSetRotation = true
    end

    if pos.y < 0 then
        pos.y = - pos.y
        self.mMove_dy = - self.mMove_dy
        self.mRotation = Fish2dTools.M_PI - self.mRotation
        self:setFishId(-1)
        self.isToSetRotation = true
    elseif pos.y > Fish2dTools.kRevolutionHeight then
        pos.y = Fish2dTools.kRevolutionHeight -(pos.y - Fish2dTools.kRevolutionHeight)
        self.mMove_dy = - self.mMove_dy
        self.mRotation = Fish2dTools.M_PI - self.mRotation
        self:setFishId(-1)
        self.isToSetRotation = true
    end
    -- print("2 pos x, y: ",pos.x,pos.y)
    local newpos = Fish2dTools.toCCPNoScale(pos.x, pos.y)
    self:setPosition(newpos.x, newpos.y)

    if self.isToSetRotation then
        local angle = math.deg(self.mRotation - Fish2dTools.M_PI_2)
        self:setBulletRotation(angle)
        self.isToSetRotation = false
    end

end

-- 锁定鱼
function Bullet:followFish(dt)
    if self.mFishId < 0 then
        return
    end
    local fishModel = self._dataModel.m_InViewFishs[self.mFishId]
    if not fishModel or not fishModel.node_ then
        self.mFishId = -1
        return
    end
    local fishNode = fishModel.node_
    if fishNode:isOutWindow() then
        self.mFishId = -1
        return
    end
    local bulletPos = cc.p(self:getPositionX(), self:getPositionY())
    local fishPos = fishNode:getScenePostion()
    local bulletAngle = Fish2dTools.calcRotate(bulletPos, fishPos)
    -- math.atan2(fishNode:getPositionY() - self:getPositionY(), fishNode:getPositionX() - self:getPositionX()) + Fish2dTools.M_PI_2;
    self:setMoveRotation(bulletAngle)
    if self.m_shadowNode then
        self.m_shadowNode:setMoveRotation(bulletAngle)
        -- 影子随着改变
    end
    --
    self:normalUpdate(dt)
end

-- 子弹和鱼的碰撞检测
function Bullet:collisionToFish()
    if self.m_IsShadow then
        return false
    end

    local fishList = self._dataModel.m_InViewFishs

    local collision = false
    local bulletPos = cc.p(self:getPositionX(), self:getPositionY())
    local bullet_radius = 10
    local lockfishId = self.mFishId

    if lockfishId >= 0 then
        -- 有锁鱼标识
        if not fishList[lockfishId] then
            self:setFishId(-1)
            -- 锁定的鱼已不存在
            return false
        else
            -- 检测锁定鱼是否碰撞
            collision = self:collisionToOneFish(bulletPos, bullet_radius, fishList[lockfishId].node_)
            if collision then
                return true
            end

            return false
        end

    end

    local fishModel = nil
    for fishkey, v in pairs(fishList) do
        fishModel = fishList[fishkey]
        if fishModel and fishModel.live_ <= 0 then
            -- print("---fishModel.live_ <= 0, ",fishModel.id_,fishModel.node_)
        end
        -- 检测鱼是否碰撞
        if fishModel and fishModel.live_ > 0 and fishModel.node_ then
            collision = self:collisionToOneFish(bulletPos, bullet_radius, fishModel.node_)
        end
        if collision == true then
            break
        end
    end

    return collision
end

-- 子弹和鱼的倍数不匹配
function Bullet:checkCanCollision(fishModel)
    if fishModel == nil then
        return false
    end
    if self.parent.isCanCollision then
        -- 子弹和鱼的倍数不匹配
        if self.parent:isCanCollision(self.mBulletLevel, fishModel.type_) == false then
            return false
        end
    end
    return true
end

-- 检测并处理子弹和指定鱼碰撞
function Bullet:collisionToOneFish(bulletPos, bullet_radius, fishNode)
    local fishModel = fishNode.mFishModel
    -- print("collisionToOneFish fishNode: ",fishNode)
    -- if not fishNode.getPositionY then
    -- dump(fishNode)
    -- dump(fishModel)
    -- end
    if not fishNode:isVisible() then
        return false
    end

    local pt_fish = fishNode:getScenePostion()
    if math.abs(pt_fish.x - bulletPos.x) > 100 or math.abs(pt_fish.y - bulletPos.y) > 100 then
        return false
    end

    if fishNode:isOutWindow() then
        return false
    end

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        -- 子弹和鱼的倍数不匹配
        if not self:checkCanCollision(fishModel) then
            return false
        end
    end


    local sz_fish
    if Fish2dTools.isSpecialRoundBird(fishModel.type_) then
        local special_id = fishModel.type_ - Fish2dTools.BIRD_TYPE_ONE
        sz_fish = Fish2dTools.get_special_fish_size(special_id)
    elseif Fish2dTools.isSpecialBird(fishModel.type_) then
        sz_fish = Fish2dTools.get_fish_size(fishModel.item_)
    else
        sz_fish = Fish2dTools.get_fish_size(fishModel.type_)
    end
    local rotation_fish = Fish2dTools.toNetRotation(fishNode:getRotationSkewX())
    -- dump(pt_fish)
    -- print("Fish2dTools.compute_collision: ", pt_fish.x, pt_fish.y, sz_fish.x, sz_fish.y, rotation_fish, bulletPos.x, bulletPos.y, bullet_radius)
    if Fish2dTools.compute_collision(pt_fish.x, pt_fish.y, sz_fish.x, sz_fish.y, rotation_fish, bulletPos.x, bulletPos.y, bullet_radius) then
        -- 有碰撞
        -- 不是红鱼设置捕中状态
        if fishModel.type_ ~= Fish2dTools.BIRD_TYPE_RED then
            fishNode:setHitRed(0.4)
        end
        fishNode:hitCutHp(self.mBulletLevel)
        -- 自己碰撞了才发送协议
        if self.mChairId == self._dataModel.m_myChairId then
            self.parent:sendCatchFishToS(self, fishModel)
        end
        self:openNet()

        return true
    end
    return false
end

-- 打开鱼网效果
function Bullet:openNet()
    -- print("---Bullet:openNet---")
    if self.m_IsShadow then
        return false
    end
    self:setVisible(false)

    self.parent:openNet(self.mChairId, self.mImgIndex, cc.p(self:getPositionX(), self:getPositionY()))

    self.parent:removeBullet(self)

end

function Bullet:unSchedule()
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
    end
end

function Bullet:setFishId(fishId)
    self.mFishId = fishId
    if self.m_shadowNode then
        self.m_shadowNode.mFishId = fishId
    end
end

function Bullet:getFishId()
    return self.mFishId
end

function Bullet:getActMove()
    return self.mActMove
end

function Bullet:getActShadowMove()
    return self.mActShadowMove
end

function Bullet:setBulletRotation(rotation)
    self:setRotation(rotation)
end

return Bullet
-- endregion
