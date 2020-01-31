-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local FishLayer = class("FishLayer", cc.Layer)
local FishNode = require("app.games.fish.fish2d.FishNode")
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')
local ActionCustom = require('app.games.fish.fish2d.ActionCustom')
local ObjectPool = require('app.games.fish.fish2d.ObjectPool')


function FishLayer:ctor(viewParent)
    self.parent = viewParent
    self._dataModel = self.parent._dataModel

    self.dinged_ = false
    self.m_WorldScaleRate = 1

    self.batch_node1_ = cc.Node:create()
    self:addChild(self.batch_node1_)
    self.batch_node2_ = cc.Node:create()
    self:addChild(self.batch_node2_)

    -- 初始化鱼的路径数据
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        init_paths("games/fish/path/path_c2d")
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        init_paths("games/fish/path/path_king")
    end

end

function FishLayer:setWorldScaleRate(rate)
    rate =(rate > 0) and rate or 1
    self.m_WorldScaleRate = rate
end

function FishLayer:getWorldScaleRate()
    return self.m_WorldScaleRate
end

function FishLayer:setWorldOriginPos(chairid)
    print("====> FishLayer:setWorldOriginPos: ", self.m_WorldScaleRate, chairid)
    if self.m_WorldScaleRate <= 1 then
        self:setPosition(0, 0)
    elseif self.m_WorldScaleRate == 2 then
        if chairid == 0 then
            self:setPosition(0, - Fish2dTools.kRevolutionHeight)
        elseif chairid == 1 then
            self:setPosition(- Fish2dTools.kRevolutionWidth, - Fish2dTools.kRevolutionHeight)
        elseif chairid == 2 then
            self:setPosition(- Fish2dTools.kRevolutionWidth, 0)
        elseif chairid == 3 then
            self:setPosition(0, 0)
        end
    end
end

function FishLayer:createFish(type_, isSpecialBird_)
    local m_fishPool = self.parent.m_fishPool
    local node = nil
    if isSpecialBird_ then
        if m_fishPool.specialfish == nil then
            m_fishPool.specialfish = { }
        end
        if m_fishPool.specialfish[type_] == nil then
            m_fishPool.specialfish[type_] = ObjectPool:create( function()
                local fishnode = FishNode.specialFishNode:create(self, type_)
                return fishnode
            end , "specialfish_" .. type_)
        end

        node = m_fishPool.specialfish[type_]:createObject()

    else

        if m_fishPool.fish == nil then
            m_fishPool.fish = { }
        end
        if m_fishPool.fish[type_] == nil then
            m_fishPool.fish[type_] = ObjectPool:create( function()
                local fishnode = FishNode.fishNode:create(self, type_)
                return fishnode
            end , "fish_" .. type_)
        end

        node = m_fishPool.fish[type_]:createObject()
    end
    node:reset()

    return node
end

function FishLayer:sendFish(fishModel, isScene, moveAction)
    -- print("---FishLayer:sendFish---")
    -- 鱼节点
    local node = nil
    -- 鱼影子节点
    local shadow = nil

    local isSpecialBird = Fish2dTools.isSpecialBird(fishModel.type_)
    local isSpecialRoundBird = Fish2dTools.isSpecialRoundBird(fishModel.type_)
    -- 创建节点
    if not isSpecialBird then
        node = self:createFish(fishModel.type_, false)
        if not isScene then
            shadow = self:createFish(fishModel.type_, false)
        end
    elseif isSpecialRoundBird then
        -- 是圆盘鱼,用特殊类去创建它
        node = self:createFish(fishModel.item_, true)
        node:setFishNum(fishModel.type_ - Fish2dTools.BIRD_TYPE_ONE + 1)
--        shadow = self:createFish(fishModel.item_, true)
--        shadow:setFishNum(fishModel.type_ - Fish2dTools.BIRD_TYPE_ONE + 1)
    elseif isSpecialBird then
        node = self:createFish(fishModel.item_, false)
        if not isScene then
            shadow = self:createFish(fishModel.item_, false)
        end
    end

    node:born(false)
    node:autoScale()

    if shadow then
        shadow:born(true)
        shadow:autoScale()
    end

    self:setFishAnchor(fishModel.type_, node, shadow)

    if isScene then
        node:setPosition(Fish2dTools.toCCP(fishModel.position_.x, fishModel.position_.y))
    else
        if Fish2dTools.isFishNeedNarrowing(fishModel.type_) then
            node:setFishScale(0.8)
            if shadow then
                shadow:setFishScale(0.8)
            end
        end

        local srcpos = Fish2dTools.toCCP(-3000, -3000)
        node:setPosition(srcpos.x, srcpos.y)
        if shadow then
            shadow:setPosition(srcpos.x, srcpos.y)
        end
    end

    local sEffect = string.format("BirdEffect%d", fishModel.type_)
    local effect_animate = Fish2dTools.createAnimate(sEffect, 0)
    local effect = nil
    if effect_animate then
        if isSpecialRoundBird then
            effect = cc.Sprite:createWithSpriteFrameName("img_toumingdian_1.png")
            node:setEffect(effect, effect_animate)
            effect:setPosition(Fish2dTools.toCCP(-3000, -3000))
        else
            effect = cc.Sprite:create()
            effect:setDisplayFrameWithAnimationName(sEffect, 0)
            effect:runAction(cc.RepeatForever:create(effect_animate))
            effect:setPosition(Fish2dTools.toCCP(-3000, -3000))
        end

        effect:setOpacity(0)
        effect:runAction(cc.FadeIn:create(1))
        effect:setScale(1.0)

        -- 先判断特殊情况
        if fishModel.type_ == Fish2dTools.BIRD_TYPE_CHAIN or fishModel.type_ == Fish2dTools.BIRD_TYPE_INGOT then
            -- 闪电鱼,闪电鱼都是小鱼
            self.batch_node1_:addChild(effect, 2)
        elseif fishModel.type_ == Fish2dTools.BIRD_TYPE_RED or isSpecialRoundBird then
            -- 红鱼效果在下面
            self.batch_node1_:addChild(effect, 0)
        elseif fishModel.type_ <= 16 then
            self.batch_node1_:addChild(effect, 0)
        end

    end

    -- 添加顺序是先特效,在影子在鱼
    if shadow then
        if isSpecialBird then
            self.batch_node1_:addChild(shadow, 0)
        elseif fishModel.type_ <= 19 then
            self.batch_node1_:addChild(shadow, 0)
        else
            self.batch_node2_:addChild(shadow, 0)
        end
    end

    -- 小鱼,或者闪电鱼,红鱼
    local reccount = 1
    if fishModel.item_ == Fish2dTools.BIRD_ITEM_ZORDER_0 then
        reccount = self:getChildrenCount()
    end
    if fishModel.type_ <= 19 or isSpecialBird then
        if isSpecialBird then
            effect:setLocalZOrder(reccount)
        end
        self.batch_node1_:addChild(node, reccount)
    else
        self.batch_node2_:addChild(node, reccount)
    end

    if not isScene then
        -- 调整光圈大小,使之能完全包裹鱼
        if fishModel.type_ == Fish2dTools.BIRD_TYPE_CHAIN or fishModel.type_ == Fish2dTools.BIRD_TYPE_INGOT then
            local fish_size = node:getSize()
            local effect_size = effect:getContentSize()

            local scale_effect = cc.p(fish_size.width / effect_size.width, fish_size.height / effect_size.width)
            if scale_effect.x < scale_effect.y then
                scale_effect.x = scale_effect.y
            else
                scale_effect.y = scale_effect.x
            end
            if scale_effect.x < 0.2 then
                scale_effect.x = 0.2
                scale_effect.y = 0.2
            end
            if fishModel.type_ == Fish2dTools.BIRD_TYPE_CHAIN then
                effect:setScale(scale_effect.x)
            elseif fishModel.type_ == Fish2dTools.BIRD_TYPE_INGOT then
                if scale_effect.x > 0.6 then
                    effect:setScale(0.75)
                else
                    effect:setScale(0.45)
                end
            end
        end
    end

    node.mFishModel = fishModel
    node.mFishModel.shadow_ = shadow
    node.mFishModel.node_ = node
    node.mFishModel.effect_ = effect

    if node.mFishModel.type_ == Fish2dTools.BIRD_TYPE_RED then
        node.mFishModel.node_:setRed()
    end

    -- 创建动作
    local action = nil
    if isScene then
        action = moveAction
    else
        local scaleRate = self.m_WorldScaleRate
        local keystep = 1
        -- if scaleRate == 2 then keystep = 3 end
        local src_move_points = get_paths(fishModel.path_id_, fishModel.path_type_)
        local move_points = { }
        for i = 1, #src_move_points do
            -- 不用取全部点，取关键点，保证路径更平滑
            --if i % keystep == 0 then
                local item = { position_ = { x = src_move_points[i].x * scaleRate, y = src_move_points[i].y * scaleRate }, angle_ = src_move_points[i].z }
                table.insert(move_points, item)
            --end
        end

        --以下通过插值路径两端 解决大鱼未出屏幕消失问题
        if #move_points > 1 and move_points[#move_points].position_.y > Fish2dTools.kRevolutionHeight then
            local a = move_points[#move_points - 1]
            local b = move_points[#move_points]
            for i = 2, 20 do
                local item = {position_ = cc.pLerp(a.position_, b.position_, i), angle_ = a.angle_}
                table.insert(move_points, item)
            end
        end
        if #move_points > 1 and move_points[1].position_.y > Fish2dTools.kRevolutionHeight then
            local a = move_points[2]
            local b = move_points[1]
            for i = 2, 10 do
                local item = {position_ = cc.pLerp(a.position_, b.position_, i), angle_ = b.angle_}
                table.insert(move_points, 1, item)
            end
        end
        src_move_points = nil
        local isFlipY = false
        if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
            if self._dataModel.m_myChairId <= 1 then
                isFlipY = true
            end
        end
        action = ActionCustom.action_Move_Point:create(Fish2dTools.BIRD_FRAME_SPEED * scaleRate * keystep, fishModel.speed_, move_points, fishModel.path_offset_, isFlipY, scaleRate)
        move_points = nil
    end
    node:showInfo()

    action:startWithTarget(node)
    node.mFishMove = action

    node:schedulerUpdate()

    --    if not isScene then
    --        if self.dinged_ then
    --            node:pauseSchedulerAndActions()
    --        end

    --    end

end

function FishLayer:getNewFishNode(fishModel)
    local isSpecialBird = Fish2dTools.isSpecialBird(fishModel.type_)
    local isSpecialRoundBird = Fish2dTools.isSpecialRoundBird(fishModel.type_)
    -- 创建节点
    local node = nil
    if not isSpecialBird then
        node = self:createFish(fishModel.type_, false)
    elseif isSpecialRoundBird then
        -- 是圆盘鱼,用特殊类去创建它
        node = self:createFish(fishModel.item_, true)
        node:setFishNum(fishModel.type_ - Fish2dTools.BIRD_TYPE_ONE + 1)
    elseif isSpecialBird then
        node = self:createFish(fishModel.item_, false)
    end
    if node then
        node:born(false)
        self:setFishAnchor(fishModel.type_, node, nil)
        node:setPosition(-1000, -1000)
    end

    return node
end

function FishLayer:setFishAnchor(fishType, node, shadow)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        if (fishType == Fish2dTools.BIRD_TYPE_20) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.25))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.25))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_22) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.4))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.4))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_25) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.6))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.6))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_27) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.6))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.6))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_16) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.25))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.25))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_17) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.25))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.25))
            end
        end
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        if (fishType == Fish2dTools.BIRD_TYPE_20 or fishType == Fish2dTools.BIRD_TYPE_19 or fishType == Fish2dTools.BIRD_TYPE_18) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.4))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.4))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_16) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.45))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.45))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_14) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.4))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.4))
            end
        elseif (fishType == Fish2dTools.BIRD_TYPE_17) then
            if node then
                node:setAnchorPoint(cc.p(0.5, 0.25))
            end
            if shadow then
                shadow:setAnchorPoint(cc.p(0.5, 0.25))
            end
        end
    end

end

function FishLayer:fishDead(fishModel, isCleanup)
    local node = fishModel.node_

    local actionDurTime = 1.2
    local frameTime = 0.02
    local fishType = node:getType()
    if not isCleanup then
        -- 创建死亡动画
        local isSpecialBird = Fish2dTools.isSpecialBird(fishModel.type_)
        local isSpecialRoundBird = Fish2dTools.isSpecialRoundBird(fishModel.type_)

        local spt
        if not isSpecialBird then
            spt = self:createFish(fishType, false)
            spt:death()
            self.batch_node1_:addChild(spt, 10)
        elseif isSpecialRoundBird then
            -- 是圆盘鱼,用特殊类去创建它
            spt = self:createFish(fishType, true)
            spt:setFishNum(fishModel.type_ - Fish2dTools.BIRD_TYPE_ONE + 1)
            spt:death()
            self.batch_node1_:addChild(spt, 10)
        elseif isSpecialBird then
            spt = self:createFish(fishType, false)
            spt:death()
            self.batch_node1_:addChild(spt, 10)
        end

        spt:autoCallBack()
        spt:setRotation(node:getRotation())
        spt:setPosition(node:getPositionX(), node:getPositionY())

        -- 抖动特效
        local shakeCustom = ActionCustom.shake:create(actionDurTime, 5, 5)
        shakeCustom:startShakeWithTarget(spt)
        local shakeOne = cc.Sequence:create(cc.DelayTime:create(frameTime), cc.CallFunc:create( function()
            if shakeCustom then
                shakeCustom:step(frameTime)
            end
        end ), nil)
        local shakeAction = cc.Sequence:create(cc.Repeat:create(shakeOne, actionDurTime / frameTime), cc.CallFunc:create( function()
            shakeCustom = nil
            shakeOne = nil
        end ), nil)
        spt:runAction(shakeAction)

        local act = cc.Sequence:create(
        cc.DelayTime:create(1.2),
        cc.CallFunc:create( function()
            if spt.recycleToPool ~= nil then
                spt.recycleToPool()
            else
                spt.removeFromParent(true)
            end
        end ),
        nil
        )
        spt:runAction(act)

        if Fish2dTools:isSpecialRoundBird(fishModel.type_) then
            spt:setScale(1.25)
        end

        if not Fish2dTools.isSpecialBird(fishModel.type_) then
            if fishModel.type_ >= 16 and fishModel.type_ < 26 then

                local fishRotate = ActionCustom.birdDeathAction:create(actionDurTime)
                fishRotate:startWithTarget(spt)
                local fishRotateOne = cc.Sequence:create(cc.DelayTime:create(frameTime), cc.CallFunc:create( function()
                    if fishRotate then
                        fishRotate:step(frameTime)
                    end
                end ), nil)
                local fishRotateAction = cc.Sequence:create(cc.Repeat:create(fishRotateOne, actionDurTime / frameTime), cc.CallFunc:create( function()
                    fishRotate = nil
                    fishRotateOne = nil
                end ), nil)

                spt:runAction(fishRotateAction)
                spt:setScale(1.25)

            end
        end

        if Fish2dTools.isFishNeedNarrowing(fishModel.type_) then
            spt:setScale(0.7)
        end
        -- 检测红鱼
        if fishModel.type_ == Fish2dTools.BIRD_TYPE_RED then
            spt:setColor(cc.RED)
        end

    end
    --

    -- 删除特效
    local effect = fishModel.effect_
    if effect then
        -- effect:runAction(ActionCustom.shake:create(1.6, 5, 5))
        if not isCleanup then
            local shakeCustom2 = ActionCustom.shake:create(actionDurTime, 5, 5)
            shakeCustom2:startShakeWithTarget(effect)
            local shakeOne2 = cc.Sequence:create(cc.DelayTime:create(frameTime), cc.CallFunc:create( function()
                if shakeCustom2 then
                    shakeCustom2:step(frameTime)
                end
            end ), nil)
            local shakeAction2 = cc.Sequence:create(cc.Repeat:create(shakeOne2, actionDurTime / frameTime), cc.CallFunc:create( function()
                shakeCustom2 = nil
                shakeOne2 = nil
            end ), nil)
            effect:runAction(shakeAction2)


            local act = cc.Sequence:create(
            cc.DelayTime:create(actionDurTime + 0.02),
            cc.RemoveSelf:create(),
            nil
            )
            effect:runAction(act)
        else
            effect:removeFromParent(true)
        end

        fishModel.effect_ = nil
    end

    fishModel.live_ = 0
    -- print("fishDead fishModel.live_ = 0, id: ", fishModel.id_)

    fishModel.node_:unScheduleFish()

    if fishModel.node_.m_minmapFish ~= nil then
        fishModel.node_.m_minmapFish:removeFromParent()
        fishModel.node_.m_minmapFish = nil
    end

    fishModel.node_:removeHp()

    if fishModel.node_.recycleToPool ~= nil then
        fishModel.node_:recycleToPool()
    else
        fishModel.node_:removeFromParent(true)
    end
--    print("D: ", fishModel.node_)
    fishModel.node_ = nil

    if fishModel.shadow_ then
        fishModel.shadow_:unScheduleFish()
        if fishModel.shadow_.recycleToPool ~= nil then
            fishModel.shadow_:recycleToPool()
        else
            fishModel.shadow_:removeFromParent(true)
        end
        fishModel.shadow_ = nil
    end


end

function FishLayer:setDingFish(isDing)
    self.dinged_ = isDing

    local thefishModel = nil
    for fishkey in pairs(self._dataModel.m_InViewFishs) do
        thefishModel = self._dataModel.m_InViewFishs[fishkey]
        if thefishModel and thefishModel.live_ > 0 and thefishModel.node_ then
            thefishModel.node_:pauseFish(self.dinged_)
        end
    end
end


return FishLayer

-- endregion
