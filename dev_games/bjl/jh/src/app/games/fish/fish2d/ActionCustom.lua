--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
--local SimpleTools = require "app.views.games.fish2d.SimpleTools"
--local simpleTools = SimpleTools.new()
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')

--local _target = nil

--local move_points_ = nil

--function setTarget(target)
--    _target = target
--end

--function setmove_points_(move_points)
--    move_points_ = move_points
--end

-----------------------------------
local function xPoint(x,y)
    return cc.p(x,y)
end

--local function toCCP(pt)
--    return Fish2dTools.toCCP(pt.x,pt.y)
--end

local function toCCP(x,y)
    return Fish2dTools.toCCP(x,y)
end

local function toNetPoint(pt)
    return Fish2dTools.toNetPoint(pt.x,pt.y)
end

local function CalculateRotateAngle(pntBegin,pntNext)
    local dRotateAngle = math.atan2(math.abs(pntBegin.x - pntNext.x),math.abs(pntBegin.y - pntNext.y))

    --如果下一点的横坐标大于前一点(在第一和第四象限)
    if pntNext.x >= pntBegin.x then
        if pntNext.y >= pntBegin.y then
            --不做任何处理
            dRotateAngle = Fish2dTools.M_PI - dRotateAngle
        else
            dRotateAngle = dRotateAngle
        end
    else
        --第二象限
        if pntNext.y >= pntBegin.y then
            dRotateAngle = Fish2dTools.M_PI + dRotateAngle
        else
           dRotateAngle = 2 * Fish2dTools.M_PI - dRotateAngle
        end
    end

    dRotateAngle =  Fish2dTools.toCCRotation(dRotateAngle)    --dRotateAngle * 180 / Fish2dTools.M_PI
    return dRotateAngle
end

----------------------------------

local Move_Point = class("Move_Point")

function Move_Point:ctor(position,angle)
    self.angle_ = angle
    self.position_ = position
end

function Move_Point:getPostion()
    return self.position_
end

-------------------------------
local LuaActionInterval = class("LuaActionInterval")

function LuaActionInterval:ctor()
    self._target = nil
    self._duration = 0
    self._tag = 0

    self._firstTick = false
    self._elapsed = 0

    self.m_ptCurrent = cc.p(0,0)
    self.m_ptLast = cc.p(0,0)

    self.bird_speed_ = 0
end

function LuaActionInterval:initWithDuration(d)
    self._duration = d 
    return true
end

function LuaActionInterval:setDuration(d)
    self._duration = d 
end

function LuaActionInterval:step(dt)

end

function LuaActionInterval:isDone()
    return self._elapsed >= self._duration
end

function LuaActionInterval:startWithTarget(target)
   self._target = target
end

function LuaActionInterval:setSpeed(speed)
   self.bird_speed_ = speed
end

function LuaActionInterval:setTag(tag)
    self._tag = tag
end

function LuaActionInterval:getTag()
    return self._tag
end

-------------------------------

local Action_Base_Bird_Move = class("Action_Base_Bird_Move",LuaActionInterval)

function Action_Base_Bird_Move:ctor()
   self._elapsed = 0
   self._duration = 0
end

function Action_Base_Bird_Move:BirdMoveTo(elapsed)
    return cc.p(0,0)
end

--------------------------------

local Action_Move_Point = class("Action_Move_Point", Action_Base_Bird_Move)

function Action_Move_Point:ctor(d,speed,points,offset,isFlipY,scaleRate)
    self._elapsed = 0
    self._duration = 0
    self._target = nil
    self.move_points_ = {}
    self.bird_speed_ = speed
    self:initData(d,points,offset,isFlipY,scaleRate)
end

--function Action_Move_Point:create(d,points,offse,isFlipY)
--    local act = Action_Move_Point.new()
--    if act ~= nil and act:init(d,points,offse,isFlipY) then
--        act:autorelease()
--        return act
--    end
--    act = nil
--    return 0
--end

function Action_Move_Point:initData(d,points,offset,isFlipY,scaleRate)
    local move_point = nil
    for i = 1,#points do
        move_point = points[i]

        if offset.x ~= 0 or offset.y ~= 0 then
            move_point.position_.x = move_point.position_.x + offset.x
            move_point.position_.y = move_point.position_.y + offset.y
        end
        if isFlipY then
            move_point.position_.y = Fish2dTools.kRevolutionHeight*scaleRate - move_point.position_.y
            local angle = move_point.angle_
            if angle > 360 then
                angle = angle - 360
            elseif angle < -360 then
                angle = angle + 360
            end

            if angle >= 180 and angle <= 360 then
                angle = 180 - angle + 360
            else
                angle = 180 - angle
            end

            move_point.angle_ = angle
        end

        table.insert(self.move_points_,move_point)
    end

    self:setDuration(d * #self.move_points_)

    return true
end

local BIRD_ITEM_SPECIAL_SMALL_PURSE = 9
local BIRD_ITEM_SPECIAL_MIDDLE_PURSE = 10
local BIRD_ITEM_SPECIAL_BIG_PURSE = 11
local BIRD_ITEM_SPECIAL_GOLDX2 = 6
local BIRD_ITEM_SPECIAL_LUCKY = 5
local BIRD_TYPE_18 = 18
local BIRD_TYPE_INGOT = 42

--todo
local function isDntgSpecialBird(birdType)
   return Fish2dTools.isSpecialBird(birdType)
end
--todo
local function isDntgReverseAtGoStraightBird(start_p,end_p)
    return Fish2dTools.isReverseAtGoStraightBird(start_p,end_p)
end

--todo
local function isDntgNeedGoStraightBird(birdType)
    return Fish2dTools.isNeedGoStraightBird(birdType)
end

--todo
local function isDntgSpecialRoundBird(birdType)
    return Fish2dTools.isSpecialRoundBird(birdType)
end

function Action_Move_Point:step(time)
    self._elapsed =  self._elapsed + time*self.bird_speed_
    local timeRatio = self._elapsed/self._duration

    local fDiff
    local fIndex = timeRatio * #self.move_points_ + 1
    local index = math.floor(fIndex)
    if index < 1 then
        index = 1
    end

    fDiff = fIndex - index

    if index >= #self.move_points_ then
        index = #self.move_points_ - 1
    end

    local move_point = {position_=nil,angle_=nil}

    if index < #self.move_points_ then
        local move_point1 = self.move_points_[index]
        local move_point2 = self.move_points_[index + 1]
        if not move_point1 then
            print("move_point1 is nil index: ",index)
        end
        local pMul1 = cc.pMul(move_point1.position_,1 - fDiff)
        local pMul2 = cc.pMul(move_point2.position_,fDiff)
        move_point.position_ = cc.pAdd(pMul1,pMul2)
        move_point.angle_ = move_point1.angle_*(1 - fDiff) + move_point2.angle_*fDiff

        if math.abs(move_point1.angle_ - move_point2.angle_) > 180 then
            move_point.angle_ = move_point1.angle_
        end
    else
        move_point = self.move_points_[index]
    end

    local bird = self._target.mFishModel
    local spr_shadow = bird.shadow_
    local spr_effect = bird.effect_

    local angle = 360 - move_point.angle_

    if bird.item_ ~= -1 and not isDntgSpecialBird(bird.type_) then 
        if bird.item_ == BIRD_ITEM_SPECIAL_SMALL_PURSE or bird.item_ == BIRD_ITEM_SPECIAL_SMALL_PURSE
        or bird.item_ == BIRD_ITEM_SPECIAL_SMALL_PURSE or bird.item_ == BIRD_ITEM_SPECIAL_SMALL_PURSE or 
        bird.item_ == BIRD_ITEM_SPECIAL_SMALL_PURSE then
            angle = 0;
        end
    end

    local dragon_value = isDntgReverseAtGoStraightBird(cc.p(self._target:getPositionX(),self._target:getPositionY()),cc.p(move_point.position_.x,move_point.position_.y))
    local newpos = toCCP(move_point.position_.x,move_point.position_.y)
    self._target:setPosition(newpos.x,newpos.y)

    if bird.type_ == BIRD_TYPE_18 then 
       -- local pos = self._target:getPosition()
    end

    if not isDntgNeedGoStraightBird(bird.type_)  then
        self._target:setRotation(angle)
    else
        self._target:setRotation(180)
        self._target:setFlippedX(dragon_value)
    end

    if spr_shadow ~= nil then
        spr_shadow:setPosition(toCCP(move_point.position_.x + 20,move_point.position_.y + 20))
        if not isDntgNeedGoStraightBird(bird.type_) then
            spr_shadow:setRotation(self._target:getRotation())
        else
            spr_shadow:setRotation(180)
            spr_shadow:setFlippedX(dragon_value)
        end
    end

    if spr_effect ~= nil then
        if bird.type_ == BIRD_TYPE_INGOT then
            local bird_size = spr_shadow:getSize()
            local bird_pos = cc.p(self._target:getPositionX(),self._target:getPositionY())
            angle = self._target:getRotation()
            local big_angle = false
            if angle > 180 or angle < - 180 then
                big_angle = true
            end

            if angle >180 then
                angle = angle - 180
            elseif angle < -180 then
                angle = angle + 180
            end
            angle = -angle
            local dregress = angle * 0.01745329252 --PI / 180

            local effect_pos = nil
            if big_angle ~= nil then
                effect_pos = {x = bird_pos.x - 30 * math.cos(dregress), y = bird_pos.y - 30 * math.sin(dregress) }
            else
                effect_pos = {x = bird_pos.x + 30 * math.cos(dregress), y = bird_pos.y + 30 * math.sin(dregress) }
            end
            spr_effect:setPosition(effect_pos)

            spr_effect:setRotation(self._target:getRotation() + 90)
        elseif  not isDntgSpecialRoundBird(bird.type_) then 
            spr_effect:setPosition(self._target:getPosition())
            spr_effect:setRotation(spr_effect:getRotation() + 1)
        else
            spr_effect:setRotation(angle)
            spr_effect:setPosition(self._target:getPositionX(),self._target:getPositionY())

            local nodes = spr_effect:getChildren()
            for i = 1, #nodes do 
                local node = nodes[i]
                node:setRotation(node:getRotation() + 1)
            end
        end
    end

    if self._target ~= nil then
        if self._elapsed >= self._duration then
            self._target:setVisible(false)
        else
            self._target:setVisible(true)
        end
    end

end

function Action_Move_Point:BirdMoveTo(elapsed)
    local time = math.min(1, (self._elapsed + elapsed) / self._duration)
    if time < 0 then 
        time = 1
    end
    local fDiff  --可能产生的偏移
    local fIndex = time * #self.move_points_
    local index = fIndex

    fDiff = fIndex - index

    if index >= #self.move_points_ then
        index = #self.move_points_ - 1
    end

    local move_point
    
    if index < #self.move_points_ - 1 then 
        local move_point1 = self.move_points_[index]
        local move_point2 = self.move_points_[index + 1]

        move_point.position_ = move_point1.position_*(1 - fDiff) + move_point2.position_*fDiff
    else
        move_point = self.move_points_[index]
    end

    local pos = move_point.getPostion()
    local target_pos = toCCP(pos.x,pos.y)

    return move_point.getPostion()
end


--------------------------------
local Action_Bird_Move = class("Action_Bird_Move",Action_Base_Bird_Move)

function Action_Bird_Move:ctor()
    self._elapsed = 0
    self._duration = 0
    self.m_ptLast = cc.p(0,0)
    self.m_ptCurrent = cc.p(0,0)
end

function Action_Bird_Move:move_angle()
    local temp_value = 0
    temp_value = CalculateRotateAngle(self.m_ptCurrent,self.m_ptLast)

    self._target:setRotation(temp_value)

    local bird = self._target.mFishModel
    local spr_shadow = bird.shadow_
    local spr_effect = bird.effect_
    if spr_shadow then
        spr_shadow:setRotation(self._target:getRotation())
    end

    if spr_effect then
        spr_effect:setRotation(self._target:getRotation())
    end

    local targetpos = cc.p(self._target:getPositionX(),self._target:getPositionY())
    local dragon_value = isDntgReverseAtGoStraightBird(targetpos,toCCP(self.m_ptLast.x,self.m_ptLast.y))

    if not isDntgNeedGoStraightBird(bird.type_) then
        self._target:setRotation(temp_value)
    else
        self._target:setRotation(180)
        self._target:setFlippedX(not dragon_value)
    end

    if spr_shadow ~= nil then
        if not isDntgNeedGoStraightBird(bird.type_) then
            spr_shadow:setRotation(self._target:getRotation())
        else
            spr_shadow:setRotation(180)
            spr_shadow:setFlippedX(not dragon_value)
        end
    end
end
---------鱼的圆圈移动----------------------
local Action_Bird_Round_Move = class("Action_Bird_Round_Move",Action_Bird_Move)

function Action_Bird_Round_Move:ctor(center,radius,rotate_duration,start_angle,rotate_angle,move_duration,bird_speed,is_centre_bird)
    self._elapsed = 0
    self._duration = 0
    self.center_ = nil
    self.radius_ = nil
    self.rotate_duration_ = nil
    self.start_angle_ = nil
    self.rotate_angle_ = nil
    self.move_duration_ = nil
    self.delta_ = cc.p(0,0)
    self.bird_speed_ = nil
    self.stage_ = nil
    self.angle_ = nil
    self._target = nil
    self.is_centre_bird_ = nil
    self.m_ptLast = cc.p(0,0)
    self.m_ptCurrent = cc.p(0,0)

    self:init(center,radius,rotate_duration,start_angle,rotate_angle,move_duration,bird_speed,is_centre_bird)
end

--function Action_Bird_Round_Move:create(center,radius,rotate_duration,start_angle,rotate_angle,move_duration,bird_speed,is_centre_bird)
--    local act = Action_Bird_Round_Move.new()
--    if act ~= nil and act:init(center,radius,rotate_duration,start_angle,rotate_angle,move_duration,bird_speed,is_centre_bird) then
--        act:autorelease()
--        return act
--    end

--    act = nil
--    return 0
--end

function Action_Bird_Round_Move:init(center,radius,rotate_duration,start_angle,rotate_angle,move_duration,bird_speed,is_centre_bird)
    self.center_ = center
    self.radius_ = radius
    self.rotate_duration_ = rotate_duration
    self.start_angle_ = start_angle
    self.rotate_angle_ = rotate_angle
    self.move_duration_ = move_duration
    self.bird_speed_ = bird_speed
    self.stage_ = 0
    self.angle_ = Fish2dTools.M_PI_2 + start_angle
    self._duration = rotate_duration + move_duration
    self.rotate_angle_ = rotate_angle
    self.is_centre_bird_ = is_centre_bird

    return true
end

function Action_Bird_Round_Move:step(time)
    self._elapsed =  self._elapsed + time 
    local timeRatio = self._elapsed/self._duration
    if not self._target then
        return
    end
    if self.stage_ == 0 and timeRatio * self._duration >= self.rotate_angle_ then
        --散开
        self.stage_ = 1
        self.delta_.x = math.cos(self.angle_)
        self.delta_.y = math.sin(self.angle_)
    end

    if self.stage_ == 0 then
        local angle = self.start_angle_ + self.rotate_angle_ * timeRatio
        local pt = {}
        pt.x = self.center_.x + self.radius_ * math.cos(angle)
        pt.y = self.center_.y + self.radius_ * math.sin(angle)
        self._target:setPosition(toCCP(pt.x,pt.y))

        --阴影特效
        local bird = self._target.mFishModel
        local spr_shadow = bird.shadow_
        local spr_effect = bird.effect_
        if spr_shadow ~= nil then
            spr_shadow:setPosition(toCCP(pt.x + 20, pt.y + 20))
        end
        if spr_effect ~= nil then
            spr_effect:setPosition(self._target:getPosition())
            spr_effect:setRotation(spr_effect:getRotation() + 1)
        end

        --角度
        self.m_ptCurrent = pt
        if self.is_centre_bird_ ~= nil then
            self._target:setRotation(Fish2dTools.toCCRotation(angle))
            if spr_shadow ~= nil then
                spr_shadow:setRotation(self._target:getRotation())             
            end
            if spr_effect ~= nil then 
                spr_effect:setPosition(self._target:getPosition())
                spr_effect:setRotation(spr_effect:getRotation() + 1)
            end
        else
            self:move_angle()
            self.m_ptLast = pt
        end
    else
        --散开
        local pt = toNetPoint(cc.p(self._target:getPositionX(),self._target:getPositionY()))
        pt.x = pt.x + self.bird_speed_ * (timeRatio / 4) * self.delta_.x
        pt.y = pt.y + self.bird_speed_ * (timeRatio / 4) * self.delta_.y
        self._target:setPosition(toCCP(pt.x,pt.y))

        local bird = self._target.mFishModel
        local spr_shadow = bird.shadow_
        local spr_effect = bird.effect_
        if spr_shadow then
            spr_shadow:setPosition(toCCP(pt.x + 20, pt.y + 20))
        end
        if spr_effect then
            spr_effect:setPosition(self._target:getPosition())
            spr_effect:setRotation(spr_effect:getRotation() + 1)
        end

        self.m_ptCurrent = pt
        self:move_angle()
        self.m_ptLast = pt
    end
end

function Action_Bird_Round_Move:BirdMoveTo(elapsed)
    --到达的时候的时间
    local time = math.min(1,(self._elapsed + elapsed) / _duration)
    if self.stage_ == 0 then
        --位置
        local angle = self.start_angle_ + self.rotate_angle_ * time
        local pt = nil
        pt.x = self.center_.x + self.radius_ * math.cos(angle)
        pt.y = self.center_.y + self.radius_ * math.sin(angle)

        return pt
    else
        local pt = nil
        if self._target ~= nil then
            pt = toNetPoint(self._target:getPosition())
        else
           pt = xPoint(0,0) 
        end

        pt.x = pt.x + self.bird_speed_ * (time / 4) * self.delta_.x
        pt.y = pt.y + self.bird_speed_ * (time / 4) * self.delta_.y

        return pt
    end
end

-------------------------------
local Action_Bird_Move_Linear = class("Action_Bird_Move_Linear",Action_Bird_Move)

function Action_Bird_Move_Linear:ctor(bird_speed,start,endP)
    self._elapsed = 0
    self._duration = 0
    self.start_ = nil
    self.end_ = nil
    self.delta_ = nil
    self.bird_speed_ = nil
    self.m_ptCurrent = cc.p(0,0)
    self.m_ptLast = cc.p(0,0)
    self.m_setAngleCount = 0
    self:initData(bird_speed,start,endP)
end

function Action_Bird_Move_Linear:initData(bird_speed,start,endP)
    self.start_ = cc.p(start.x,start.y)
    self.end_ = cc.p(endP.x,endP.y)
    self.bird_speed_ = bird_speed
    self.delta_ = cc.pSub(endP,start)
    local length = math.sqrt(self.delta_.x * self.delta_.x + self.delta_.y * self.delta_.y)
    self._duration = length / self.bird_speed_
    self._target = nil
    return true
end

function Action_Bird_Move_Linear:step(time)
    self._elapsed =  self._elapsed + time 
    local timeRatio = self._elapsed/self._duration
    if not self._target then
        print("Action_Bird_Move_Linear:step self._target is nil!")
        return
    end
    --位置
    local pt = cc.p(self.start_.x + self.delta_.x * timeRatio, self.start_.y + self.delta_.y * timeRatio)
    self._target:setPosition(toCCP(pt.x,pt.y))

    --阴影特效
    local bird = self._target.mFishModel
    local spr_shadow = bird.shadow_
    local spr_effect = bird.effect_
    if spr_shadow ~= nil then
        spr_shadow:setPosition(toCCP(pt.x + 20, pt.y + 20))
    end

    if spr_effect then
        local angle = CalculateRotateAngle(self.m_ptCurrent,self.m_ptLast)
        --这里是有问题的!!!
        if bird.type_ == BIRD_TYPE_INGOT then
            local bird_size = spr_shadow:getSize()
            local bird_pos = self._target:getPosition()
            local angle = self._target:getRotation()
            local big_angle = false
            if angle > 180 or angle < - 180 then
                big_angle = true
            end

            if angle >180 then
                angle = angle - 180
            elseif angle < -180 then
                angle = angle + 180
            end
            angle = -angle
            local dregress = angle * 0.01745329252 --PI / 180

            local effect_pos = nil
            if big_angle ~= nil then
                effect_pos = cc.p(bird_pos.x - 30 * math.cos(dregress), bird_pos.y - 30 * math.sin(dregress))
            else
                effect_pos = cc.p(bird_pos.x + 30 * math.cos(dregress), bird_pos.y + 30 * math.sin(dregress))
            end
            spr_effect:setPosition(effect_pos)
            spr_effect:setRotation(self._target:getRotation() + 90)
        elseif not isDntgSpecialRoundBird(bird.type_) then
            spr_effect:setPosition(self._target:getPosition())
            spr_effect:setRotation(spr_effect:getRotation() + 1)
        else
            spr_effect:setRotation(angle)
            local now_p_1 = self._target:getPosition()

            spr_effect:setPosition(now_p_1)
            local nodes = spr_effect:getChildren()
            for i = 0, i < #nodes do
                local node = nodes[i]
                node:setRotation(node:getRotation() + 1)
            end
        end
    end

    --角度
    self.m_ptCurrent = pt

    if self.m_setAngleCount == nil or self.m_setAngleCount <= 2 then
        if self.m_setAngleCount == nil then self.m_setAngleCount = 0 end
        self.m_setAngleCount = self.m_setAngleCount + 1

        self:move_angle()
    end
    self.m_ptLast = pt

end

function Action_Bird_Move_Linear:BirdMoveTo(elapsed)
    --这个时间是有可能下一帧的时间大于了持续总时间.所以比较一下
    local time = math.min(1,(self._elapsed + elapsed) / _duration)
    return xPoint(self.start_.x + self.delta_.x * time, self.start_.y + self.delta_.y * time)
end
-------------------------------
local Action_Bird_Move_Pause_Linear = class("Action_Bird_Move_Pause_Linear",Action_Bird_Move)

function Action_Bird_Move_Pause_Linear:ctor(bird_speed,pause_time,start,pause,endP,start_angle)
    self._elapsed = 0
    self._duration = 0
    self.start_ = nil
    self.end_ = nil
    self.pause_ = nil   --暂停点
    self.front_delta_ = nil
    self.back_delta_ = nil
    self.bird_speed_ = nil
    self.pause_time_ = nil  --暂停时间
    self.front_time_ = nil  --暂停之前的动作时间
    self.back_time_ = nil   --暂停之后的动作时间
    self.start_angle_ = nil --开始点等于暂停点时使用此角度
    self.m_ptCurrent = cc.p(0,0)
    self.m_ptLast = cc.p(0,0)
    self.m_setAngleCount = 0
    self:initData(bird_speed,pause_time,start,pause,endP,start_angle)
end

--function Action_Bird_Move_Pause_Linear:create(bird_speed,start,endP)
--    local act = Action_Bird_Move.new()
--    if act ~= nil and act:init(bird_speed,start,endP) then
--        act:autorelease()

--        return act
--    end
--    act = nil

--    return 0
--end

function Action_Bird_Move_Pause_Linear:initData(bird_speed,pause_time,start,pause,endP,start_angle)
    self.start_ = cc.p(start.x,start.y)
    self.pause_ = cc.p(pause.x,pause.y)   --暂停点
    self.end_ = cc.p(endP.x,endP.y)
    self.bird_speed_ = bird_speed
    self.pause_time_ = pause_time
    self.start_angle_ = start_angle

    self.front_delta_ = cc.pSub(self.pause_,self.start_)
    local length = math.sqrt(self.front_delta_.x * self.front_delta_.x + self.front_delta_.y * self.front_delta_.y)
    self.front_time_ = length / bird_speed
    self.back_delta_ = cc.pSub(self.end_,self.pause_)
    length = math.sqrt(self.back_delta_.x * self.back_delta_.x + self.back_delta_.y * self.back_delta_.y)
    self.back_time_ = length / bird_speed
    self._duration = self.front_time_ + self.pause_time_ + self.back_time_

    return true
end

function Action_Bird_Move_Pause_Linear:step(time)
    self._elapsed =  self._elapsed + time 
    local timeRatio = self._elapsed/self._duration

    --位置
    local pt = cc.p(self._target:getPositionX(),self._target:getPositionY())
    if self._elapsed <= self.front_time_ then
        timeRatio = self._elapsed / self.front_time_
        pt.x = self.start_.x + self.front_delta_.x * timeRatio
        pt.y = self.start_.y + self.front_delta_.y * timeRatio
        self._target:setPosition(toCCP(pt.x,pt.y))

        --角度
        self.m_ptCurrent = pt
        if self.m_setAngleCount == nil or self.m_setAngleCount <= 2 then
            if self.m_setAngleCount == nil then self.m_setAngleCount = 0 end
            self.m_setAngleCount = self.m_setAngleCount + 1

            self:move_angle()
        end
        self.m_ptLast = pt

    elseif self._elapsed > self.front_time_ + self.pause_time_ then
        timeRatio = (self._elapsed - (self.front_time_ + self.pause_time_)) / self.back_time_
        pt.x = self.pause_.x + self.back_delta_.x * timeRatio
        pt.y = self.pause_.y + self.back_delta_.y * timeRatio
        self._target:setPosition(toCCP(pt.x,pt.y))

        --角度
        self.m_ptCurrent = pt
        if self.m_setAngleCount == nil or self.m_setAngleCount <= 2 then
            if self.m_setAngleCount == nil then self.m_setAngleCount = 0 end
            self.m_setAngleCount = self.m_setAngleCount + 1

            self:move_angle()
        end
        self.m_ptLast = pt

    elseif self.start_ == self.pause_ then
        pt = self.pause_
        self._target:setPosition(toCCP(pt.x,pt.y))
        self._target:setRotation((self.start_angle_ - Fish2dTools.M_PI_2) * 180 / Fish2dTools.M_PI)
    end
end

function Action_Bird_Move_Pause_Linear:BirdMoveTo(elapsed)
    local time = 0
    if (self._elapsed + elapsed) <= self.front_time_ then
        time = math.min(1,(self._elapsed + elapsed) / self._duration)
        return cc.p(self.start_.x + self.front_delta_.x * time, self.start_.y + self.front_delta_.y * time)
    elseif (self._elapsed + elapsed) > self.front_time_ + self.pause_time_ then
        time = math.min(1,((self._elapsed + elapsed) - (self.front_time_ + self.pause_time_)) / self.back_time_)
        return cc.p(self.pause_.x,self.pause_.y)
    end

    return cc.p(self.pause_.x, self.pause_.y)
end

-------------------------------
local Shake = class("Shake",LuaActionInterval)

function Shake:ctor(duration,strength_x,strength_y)
    self._target = nil
    self._elapsed = 0
    self._initial_x = 0
    self._initial_y = 0
    self._strength_x = 0   
    self._strength_y = 0
    if strength_y == nil then
        strength_y = strength_x       
    end
    self:initData(duration,strength_x,strength_y)
end

function Shake:initData(duration,strength_x,strength_y)
    self._duration = duration
    self._strength_x = strength_x
    self._strength_y = strength_y
end

function Shake:fgRangeRand(min,max)
--    local mytime = os.time()
--    mytime = string.reverse(mytime)
--    math.randomseed(mytime)	
--    local rnd = math.random()

--    return rnd * (max - min) + min
    return math.random(min,max)
end

function Shake:step(time)
    if self:isDone() then
        return
    end
    self._elapsed =  self._elapsed + time 
    local randx = self:fgRangeRand(-self._strength_x,self._strength_x)
    local randy = self:fgRangeRand(-self._strength_y,self._strength_y)

    self._target:setPosition(self._initial_x + randx,self._initial_y + randy)
end


function Shake:startShakeWithTarget(target)
    self._target = target
    self._initial_x = target:getPositionX()
    self._initial_y = target:getPositionY()
end

function Shake:stop(target)
   self._target:setPosition(self._initial_x,self._initial_y)
   --self.super:stop()
end

-------------------------------
local BirdDeathAction = class("BirdDeathAction",LuaActionInterval)

function BirdDeathAction:ctor(d)
    self._target = nil
    self._elapsed = 0
    self.mOldRotate = nil
    self.mNumber = 0
    self.mSignDregress = 45   --单个角度
    self.isRun = {}  --是否允许了
    for i = 0, 7  do
        self.isRun[i] = false
    end
    self:initData(d)
end



function BirdDeathAction:initData(d)
    self._duration = d

    return true
end


function BirdDeathAction:step(time)
    if not self._target then
        return
    end
    if self:isDone() then
        return
    end
    --现在已经走过的时间
    self._elapsed =  self._elapsed + time 
    local timeRatio = self._elapsed/self._duration

    local now_time = timeRatio * self._duration
    local rotate_ = self._target:getRotationSkewX()
    if now_time == 0 then
        self.mOldRotate = rotate_
        rotate_ = ((rotate_ / 90) + 1) * 90
        self.mSignDregress = -mSignDregress
    end

    if now_time > 0.08 * self.mNumber then 
        rotate_ = rotate_ + self.mSignDregress
        local isFilpped = self._target:setFlippedX(not isFilpped)
        if self.mNumber > 7 and self.mNumber < 13 then
            if rotate_ > 180 then
                rotate_ = rotate_ - 180 - self.mSignDregress
            else
                 rotate_ = rotate_ + 180 - self.mSignDregress
            end
        elseif rotate_ > 360 then
            rotate_ = rotate_ - 180
            self.mSignDregress = -self.mSignDregress 
        elseif rotate_ < 0 then
            rotate_ = rotate_ + 180
            self.mSignDregress = -self.mSignDregress 
        end

        self.mNumber = self.mNumber + 1
    end

    if timeRatio == 1 then 
        rotate_ = self.mOldRotate
        self._target:setFlippedX(false)
    end

    self._target:setRotation(rotate_)

end


------------返回---------------

local ActionCustomta = {
    move_Point = Move_Point,
    action_Move_Point = Action_Move_Point,
    action_Bird_Move = Action_Bird_Move,
    action_Bird_Round_Move = Action_Bird_Round_Move,
    action_Bird_Move_Linear = Action_Bird_Move_Linear,
    action_Bird_Move_Pause_Linear = Action_Bird_Move_Pause_Linear,
    shake = Shake,
    birdDeathAction = BirdDeathAction,

}

return ActionCustomta