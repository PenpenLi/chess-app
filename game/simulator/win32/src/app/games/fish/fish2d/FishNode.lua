-- region FishNode.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- 鱼的Node

local FishNode = class("FishNode", cc.Sprite);
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')
local scheduler = cc.Director:getInstance():getScheduler()

function FishNode:ctor(viewParent, ftype)
    --    print("---FishNode:ctor ftype: ",ftype)
    self.parent = viewParent
    if self.parent then
        self._dataModel = self.parent._dataModel
    end
    self.mFishModel = nil
    self.mFishMove = nil
    self.mIsPause = false
    self.mType = 0
    self.mLock = { false, false, false, false }
    self.mLock[0] = false
    self.mBirdSize = cc.size(0, 0)

    self.mFishList = { }
    self.mFishNum = 0

    self.m_isShadow = false
    self.m_schedule = nil

    self.m_minmapFish = nil
    self.m_isUnActive = false

    self.m_hp = 100
    self.m_isInitHp = false
    self.m_isEnteredScene = false
    self.m_synSetServerHp = false

    self.Text_Info = nil

    self:initFish(ftype)
end

function FishNode:reset()
    self.mFishModel = nil
    self.mFishMove = nil
    self.mIsPause = false
    self.mLock = { false, false, false, false }
    self.mLock[0] = false
    -- self.mBirdSize = cc.size(0, 0)

    if self.mFishList then
        for i = 1, #self.mFishList do
            self.mFishList[i]:removeFromParent()
        end
    end
    self.mFishList = { }
    self.mFishNum = 0
    self.pause_time = false
    if self.m_schedule ~= nil then
        self:unScheduleFish()
    end

    if self.m_isShadow then
        self:setColor(cc.c3b(255, 255, 255))
        self:setOpacity(255)
        -- self:runAction(cc.FadeTo:create(0.1, 255))
        self.m_isShadow = false
    end

    self:autoCallBack()

    self.m_isUnActive = false
    self.m_minmapFish = nil
    self.m_hp = 100
    self.m_isInitHp = false
    self.m_isEnteredScene = false
    self.m_synSetServerHp = false

end

function FishNode:initFish(ftype)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        if ftype == -1 then
            self:init()
        elseif ftype <= 19 then
            self:initWithSpriteFrameName("img_toumingdian_1.png")
        else
            self:initWithSpriteFrameName("Bird20_01.png")
        end
    else
        self:init()
    end


    self.mType = ftype

end

function FishNode:getType()
    return self.mType
end

function FishNode:setHitRed(time)
    local hitTag = 10011
    self:stopActionByTag(hitTag)

    self:setColor(cc.c3b(255, 0, 0))
    local action = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create( function(self)
        self:setColor(cc.c3b(255, 255, 255))
    end ),
    nil)
    action:setTag(hitTag)

    self:runAction(action)
end

function FishNode:born(isShadow)
    self:stopAllActions()
    local animate = Fish2dTools.createFishAnimate(self.mType)
    if not animate then
        return
    end
    self:runAction(cc.RepeatForever:create(animate))


    local firams = animate:getAnimation():getFrames()
    local rect = firams[1]:getSpriteFrame():getRect()
    self.mBirdSize = cc.size(rect.width, rect.height)

    self.m_isShadow = isShadow
    local opacity = 0
    if isShadow then
        self:setColor(cc.c3b(0, 0, 0))
        opacity = 100
    else
        self:setColor(cc.c3b(255, 255, 255))
        opacity = 255
    end

    self:setOpacity(0)
    local fadeAction = cc.FadeTo:create(0.5, opacity)
    fadeAction:setTag(101)
    self:runAction(fadeAction)
end

function FishNode:setUnActive(isUnActive)
    self.m_isUnActive = isUnActive
    if self.m_isShadow then
        return
    end
    self:stopActionByTag(101)
    if isUnActive then
        self:runAction(cc.FadeTo:create(0.5, 50))
    else
        self:runAction(cc.FadeTo:create(0.5, 255))
    end
end

function FishNode:isUnActive()
    return self.m_isUnActive
end

function FishNode:death()
    self:stopAllActions()
    self:setTag(-1)
    --    if self.mFishMove then
    --        self.mFishMove:release()
    --    end
    self.mFishMove = nil

    local animate = Fish2dTools.createFishDeadAnimate(self.mType)
    if animate then
        animate:setDuration(animate:getDuration() / 5)
        self:runAction(cc.RepeatForever:create(animate))
    end
end

function FishNode:setRed()
    self:stopAllActions()
    local animate = Fish2dTools.createFishAnimate(self.mType)
    self:runAction(cc.RepeatForever:create(animate))

    self:setColor(cc.c3b(255, 0, 0))

    self:setOpacity(0)
    self:runAction(cc.FadeOut:create(1, 255))
end

function FishNode:setLock(isLock, chair_id)
    self.mLock[chair_id] = isLock
    if isLock then
        --   self:scheduleUpdate()
    else
        --  self:unscheduleUpdate()
    end
end

function FishNode:getLock(chair_id)
    return self.mLock[chair_id]
end

function FishNode:getScenePostion()
    return cc.p(self:getPositionX() + self.parent:getPositionX(), self:getPositionY() + self.parent:getPositionY())
end

function FishNode:isOutWindow()
    if not self:isVisible() then
        return true
    end

    local fishpos = self:getScenePostion()
    local isContact = true
    if fishpos.x < 0 or fishpos.x > Fish2dTools.kRevolutionWidth then
        isContact = false
    elseif fishpos.y < 0 or fishpos.y > Fish2dTools.kRevolutionHeight then
        isContact = false
    end
    return not isContact
end

function FishNode:autoCallBack()

    -- TODO

end

function FishNode:getSize()
    local tsize = cc.size(self.mBirdSize.width * 0.75, self.mBirdSize.height * 0.75)
    return tsize
end

function FishNode:pauseFish(isPase)
    self.mIsPause = isPase
end

function FishNode:autoScale()
    self:setFishScale(1)
end

function FishNode:setFishScale(scaleVaue)
    self:setScale(scaleVaue)
end

function FishNode:setFishNum(num)
    self.mFishNum = num
end

function FishNode:getFishNum()
    return self.mFishNum
end

function FishNode:hillAndDestory()
    local func_bird_hide = function()
        self.mFishModel.live_ = 0
        -- print("hillAndDestory self.mFishModel.live_ = 0, id: ",self.mFishModel.id_)
        if self.mFishModel.shadow_ then
            self.mFishModel.shadow_:setVisible(false)
        end
        if self.mFishModel.effect_ then
            self.mFishModel.effect_:setVisible(false)
        end
        self:setVisible(false)
    end
    local func_bird_end = function()
        self:autoCallBack()
        if self.mFishModel.effect_ then
            self.mFishModel.effect_:stopAllActions()
            self.mFishModel.effect_:removeAllChildrenWithCleanup(true)
            self.mFishModel.effect_ = nil
        end
        --
        self:unScheduleFish()
        if self.parent then
            self.parent:fishDead(self.mFishModel, true)
            self.parent.parent:destoryFish(self.mFishModel)
        end

        -- 移除鱼节点
        -- self:removeFromParent()
    end
    local act = cc.Sequence:create(
    cc.CallFunc:create(func_bird_hide),
    cc.DelayTime:create(0.25),
    cc.CallFunc:create(func_bird_end),
    nil
    )
    self:runAction(act)
end

function FishNode:schedulerUpdate()
    local runAllTime = 0
    local function updateFish(dt)
        if not self.mFishModel then
            return
        end
        if self.mIsPause then
            return
        end
        runAllTime = runAllTime + dt
        if runAllTime < self.mFishModel.path_delay_ then
            return
        end

        if not self.mFishMove then
            return
        end
        if not self.mFishMove:isDone() and self:getParent() then
            -- dt = dt * self.mFishModel.speed_
            self.mFishMove:step(dt)

            if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
                if self.m_isInitHp == false then
                    self:initHp()
                end
                if self.mFishModel.type_ >= self._dataModel.m_DisplayBloodFishStartType then
                    -- 大鱼从屏幕中出去时同步HP
                    self:SynSetServerHp()
                end
                -- 小地图的鱼同步
                if self.m_minmapFish ~= nil then
                    self.m_minmapFish:setPosition(self:getPositionX() * Fish2dTools.MINMAP_RATE_X, self:getPositionY() * Fish2dTools.MINMAP_RATE_Y)
                    self.m_minmapFish:setRotation(self:getRotation())
                    self.m_minmapFish:setFlippedX(self:isFlippedX())
                end
                if self.m_hpNode ~= nil then
                    self.m_hpNode:setPosition(self:getPositionX() + 20, self:getPositionY() -20)
                    self.m_hpNode:setRotation(self:getRotation() + 90)
                end
            end

        else
--            print("-- ", (self), self.mFishModel.node_)
            self:unScheduleFish()
            self:hillAndDestory()
        end

    end
    -- 定时器
    if nil == self.m_schedule then
        self.m_schedule = scheduler:scheduleScriptFunc(updateFish, 0, false)
    end
end

function FishNode:unScheduleFish()
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
    end
end

-------------------------------- HP 相关 --------------------------------
function FishNode:initHp()
    if self.m_isInitHp == true then
        return
    end
    self.m_isInitHp = true
    if Fish2dTools.mGame_Type ~= Fish2dTools.GAME_TYPE_FISHKING then
        return
    end
    if self._dataModel == nil then
        return
    end
    local beginX = self:getPositionX()
    local beginY = self:getPositionY()
    local mychair = self._dataModel.m_myChairId
    -- 从不同方向来的鱼的初始HP不一样，从我所在的象限出生的鱼HP才是满的
    local isFullHp = false
    if mychair == 0 then
        if beginX < Fish2dTools.kRevolutionWidth and beginY > Fish2dTools.kRevolutionHeight then
            isFullHp = true
        end
    elseif mychair == 1 then
        if beginX > Fish2dTools.kRevolutionWidth and beginY > Fish2dTools.kRevolutionHeight then
            isFullHp = true
        end
    elseif mychair == 2 then
        if beginX > Fish2dTools.kRevolutionWidth and beginY < Fish2dTools.kRevolutionHeight then
            isFullHp = true
        end
    elseif mychair == 3 then
        if beginX < Fish2dTools.kRevolutionWidth and beginY < Fish2dTools.kRevolutionHeight then
            isFullHp = true
        end
    end

    if isFullHp then
        self.m_hp = 100
    else
        self.m_hp = math.random(50, 101)
    end

end

-- 向服务器设置HP，刚出屏幕时
function FishNode:SynSetServerHp()
    if Fish2dTools.mGame_Type ~= Fish2dTools.GAME_TYPE_FISHKING then
        return
    end
    if not self:isVisible() then
        return
    end
    local isOut = self:isOutWindow()
    --    print("FishNode:SynSetServerHp isOut, m_isEnteredScene, m_synSetServerHp, ", isOut,self.m_isEnteredScene,self.m_synSetServerHp)
    if self.m_isEnteredScene == false then
        if not isOut then
            self.m_isEnteredScene = true
            self.m_synSetServerHp = false
        end
        return
    end
    if self.m_synSetServerHp == true then
        return
    end
    if isOut then
        self.m_synSetServerHp = true
        self.m_isEnteredScene = false
--        print(" App.conn:notify('SynSetServerHp')")
        -- 通知外部
        eventManager:publish("SynSetServerHp", self.mFishModel.id_, self.m_hp)
--        App.conn:notify('SynSetServerHp', self.mFishModel.id_, self.m_hp)
    end
end

function FishNode:getHp()
    return self.m_hp
end

function FishNode:showHp(hpvalue)
    if Fish2dTools.mGame_Type ~= Fish2dTools.GAME_TYPE_FISHKING then
        return
    end

    local hpValueImg = self.m_hpValueImg
    if self.m_hpNode == nil then
        self.m_hpNode = cc.Node:create()
        local hpbg = cc.Sprite:create(Fish2dTools.mGameResPre .. "/res/hpbg.png")
        hpbg:setAnchorPoint(cc.p(0, 0.5))
        self.m_hpNode:addChild(hpbg, 1)
        self.m_hpValueImg = cc.Sprite:create(Fish2dTools.mGameResPre .. "/res/hpvalue.png")
        self.m_hpValueImg:setAnchorPoint(cc.p(0, 0.5))
        self.m_hpNode:addChild(self.m_hpValueImg, 2)
        self.parent:addChild(self.m_hpNode, self:getLocalZOrder() + 1)
        hpValueImg = self.m_hpValueImg
    end
    hpvalue =(hpvalue > 0) and hpvalue or 0
    hpvalue =(hpvalue < 100) and hpvalue or 100
    self.m_hp = hpvalue
    if hpValueImg then
        hpValueImg:setScaleX(self.m_hp / 100.0)
    end
end

function FishNode:removeHp()
    self.m_hp = 0
    if self.m_hpNode ~= nil then
        self.m_hpNode:removeFromParent(true)
        self.m_hpNode = nil
    end
    self.m_hpValueImg = nil
end

function FishNode:hitCutHp(bulletLevel)
    if Fish2dTools.mGame_Type ~= Fish2dTools.GAME_TYPE_FISHKING then
        return
    end
    local rvalue = math.random(0, 20)
    local cutvalue = 1
    local itemv = 1
    if self.mFishModel.type_ < 5 then
        itemv = 5
    elseif self.mFishModel.type_ < 10 then
        itemv = 3
    elseif self.mFishModel.type_ < 19 then
        itemv = 2
    end
    if bulletLevel > 1 then
        itemv = itemv * bulletLevel * 1.4
    end
    if self.m_hp <= 20 then
        if rvalue <= 10 then
            cutvalue = itemv
        else
            cutvalue =(rvalue - 10) / 2
        end
    else
        if rvalue <= 5 then
            cutvalue = itemv
        elseif rvalue <= 15 then
            cutvalue = itemv * 2
        else
            cutvalue = rvalue - 10
        end
    end

    if self.m_hp <= cutvalue then
        cutvalue = 0
    end
    local newHp = self.m_hp - cutvalue
    if newHp < 3 then
        newHp = 3
    end
    self:showHp(newHp)
end

function FishNode:showInfo()
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        return
    end
--    if self.m_isShadow then
--        self.Text_Info:setVisible(false)
--        return
--    end
--    self.Text_Info = self:getChildByTag(10010)
--    if self.Text_Info == nil then
--        self.Text_Info = cc.Label:create()
--        self.Text_Info:setTag(10010)
--        self:addChild(self.Text_Info, 10)
--        self.Text_Info:setTextColor(cc.RED)
--    end
--    self.Text_Info:setVisible(true)
--    local info = string.format("%d,%d", self.mFishModel.path_type_,self.mFishModel.path_id_)
--    self.Text_Info:setString(info)
end
-----------------------------------------------------------------

-- 特殊的鱼
local SpecialFishNode = class("SpecialFishNode", FishNode);

function SpecialFishNode:born(isShadow)
    self:stopAllActions()
    if self.mFishList then
        for i = 1, #self.mFishList do
            self.mFishList[i]:removeFromParent()
        end
    end
    self.mFishList = { }

    for i = 0, self.mFishNum - 1 do
        local tfish = cc.Sprite:create()
        table.insert(self.mFishList, tfish)

        local animate = Fish2dTools.createFishAnimate(self.mType)
        if animate then
            tfish:runAction(cc.RepeatForever:create(animate))
        end

        local anchor_pos = self:getAnchorPointInPoints()
        local fish_pos = cc.pAdd(anchor_pos, self:getFishPostion(i))
        tfish:setPosition(fish_pos.x, fish_pos.y)
        self:addChild(tfish)

        local opacity = 0
        if isShadow then
            tfish:setColor(cc.c3b(0, 0, 0))
            opacity = 100
        else
            tfish:setColor(cc.c3b(255, 255, 255))
            opacity = 255
        end

        tfish:setOpacity(0)
        tfish:runAction(cc.FadeTo:create(1, opacity))
    end

end

function SpecialFishNode:getFishPostion(fish_rank)
    local now_p = cc.p(0, 0)
    local angle = 0
    local radian = 0
    local length = 95
    if self.mFishNum == 1 then
        return now_p
    elseif self.mFishNum == 2 then
        angle = 180 * fish_rank
        length = 80
    elseif self.mFishNum == 3 then
        angle = 120 * fish_rank
        length = 85
    elseif self.mFishNum == 4 then
        angle = 90 * fish_rank
    elseif self.mFishNum == 5 and fish_rank ~= 4 then
        angle = 90 * fish_rank
    elseif self.mFishNum == 5 and fish_rank == 4 then
        return now_p
    end

    radian = math.rad(angle)
    now_p.x = length * math.cos(radian)
    now_p.y = length * math.sin(radian)
    return now_p
end

function SpecialFishNode:setEffect(father, animate)
    for i = 0, self.mFishNum - 1 do
        local effect_fish = cc.Sprite:create()
        local fish_pos = self:getFishPostion(i)
        local father_pos = father:getAnchorPointInPoints()
        local end_p = cc.pAdd(fish_pos, father_pos)
        effect_fish:setPosition(end_p)
        father:addChild(effect_fish, 0)

        local new_animate = animate:clone()
        effect_fish:runAction(cc.RepeatForever:create(new_animate))
    end
end

function SpecialFishNode:setHitRed(time)
    local hitTag = 10011

    for i, v in pairs(self.mFishList) do
        local childNode = self.mFishList[i]
        childNode:stopActionByTag(hitTag)
        childNode:setColor(cc.c3b(255, 0, 0))
        local action = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create( function(args)
            childNode:setColor(cc.c3b(255, 255, 255))
        end ), nil)

        action:setTag(hitTag)
        childNode:runAction(action)
    end

end

function SpecialFishNode:death()
    self:setTag(-1)
    self:stopAllActions()
    --    if self.mFishMove then
    --        self.mFishMove:release()
    --    end
    self.mFishMove = nil

    if self.mFishList then
        for i = 1, #self.mFishList do
            self.mFishList[i]:removeFromParent()
        end
    end
    self.mFishList = { }

    for i = 0, self.mFishNum - 1 do
        local tfish = cc.Sprite:create()
        table.insert(self.mFishList, tfish)
        local animate = Fish2dTools.createFishDeadAnimate(self.mType)
        animate:setDuration(animate:getDuration() / 2)

        tfish:runAction(cc.RepeatForever:create(animate))

        local father_pos = self:getAnchorPointInPoints()
        local fish_pos = cc.pAdd(father_pos, self:getFishPostion(i))
        tfish:setPosition(fish_pos)
        self:addChild(tfish)
    end

end

----------------------------------------------------------------- 

return { fishNode = FishNode, specialFishNode = SpecialFishNode }
-- endregion
