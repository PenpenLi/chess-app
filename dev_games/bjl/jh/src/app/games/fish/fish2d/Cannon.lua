-- region Cannon.lua
-- Date 2018-03-28
-- 此文件由[BabeLua]插件自动生成
local Cannon = class("Cannon", cc.Node)
local Bullet = require('app.games.fish.fish2d.Bullet')
local FishNode = require('app.games.fish.fish2d.FishNode')
local CoinsNodeX = require('app.games.fish.fish2d.CoinsNode')
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')
--local SoundMng = require('app.helpers.SoundMng')
local scheduler = cc.Director:getInstance():getScheduler()

function Cannon:ctor(viewParent, chair_id)
    print("---Cannon:ctor---chair_id: ", chair_id)
    self:setName("Cannon" .. chair_id)
    self.chair_id_ = chair_id
    self.view_chair_id_ = chair_id
    self.gold_ = 0

    self.level_ = -1
    self.cannon_mulriple_ = 0
    self.cannon_speed_ = 0

    self.parent = viewParent
    self._dataModel = self.parent._dataModel

    self.currentSendBulletCount_ = 0

    self._Player_Node = nil
    self._Sprite_Cannon = nil
    self._CoinsShowNode = nil
    self._Button_Double_Tag1 = nil
    self._Button_Double_Tag2 = nil
    self._Button_Kuangbao_Tag1 = nil
    self._Button_Kuangbao_Tag2 = nil
    self._isOpenKuangbao = false
    self._isOpenDouble = false

    self._isMe = false

    self.rotation_ = 0

    -- 当前锁定的鱼Node
    self._mLockFish = nil
    self._mLockFishId = 0
    self._mLockFishType = 0
    self._mLockFishTypeSpecial = 0
    self._mLockFishAnimate = nil
    self._mLockFishEffect = nil
    self.mLockLineLayout = nil

    self._Sprite_Cannon_2_WorldPostion = cc.p(0, 0)
end

function Cannon:loadUI(uiRoot)
    local uiName = "Image_Battery" .. self.chair_id_
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        uiName = "Image_Battery"
    end
    self._Player_Node = uiRoot:getChildByName(uiName)

    self._Image_Battery = self._Player_Node:getChildByName("Image_Battery")
    self._Image_BatteryBig = self._Player_Node:getChildByName("Image_BatteryBig")
    if self._Image_BatteryBig then
        self._Image_BatteryBig:setVisible(false)
    end

    self._AtlasLabel_CannonNum = self._Player_Node:getChildByName("AtlasLabel_CannonNum")
    self._AtlasLabel_CannonNum:setLocalZOrder(6)

    self._AtlasLabel_Money = self._Player_Node:getChildByName("AtlasLabel_Money")
    self._Image_Money_Bg = self._Player_Node:getChildByName("Image_Money_bg")

    self._Text_Name = self._Player_Node:getChildByName("Text_Name")

    self._Sprite_Cannon = self._Player_Node:getChildByName("Sprite_Cannon")
    self._Sprite_Cannon_img = self._Sprite_Cannon:getChildByName("Sprite_Cannon_img")
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        self._Sprite_Cannon_img:setAnchorPoint(cc.p(0.5, 0.2))
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        self._Sprite_Cannon_img:setAnchorPoint(cc.p(0.5, 0.35))
    end
    self._Sprite_Cannon_img:ignoreAnchorPointForPosition(false)
    self._Cannon_Head = self._Sprite_Cannon_img:getChildByName("Cannon_Head")

    self._Icon_lock = self._Player_Node:getChildByName("Icon_Lock")
    self._Image_Lock = self._Icon_lock:getChildByName("Image_Lock")
    if self._Image_Lock then
        self._Icon_lock:setVisible(false)
    end
    -- 加炮倍数
    self._Button_Add = self._Player_Node:getChildByName("Button_Add")
    if self._Button_Add then
        self._Button_Add:setPressedActionEnabled(true)
        self._Button_Add:addClickEventListener( function()
            print("_Button_Add:addClickEventListener self:isMe(): ", self:isMe(), self.chair_id_)
            if self:isMe() then
                self:addCannonCallback()
            end
        end )
        self._Button_Add:setVisible(false)
    end
    -- 减炮倍数
    self._Button_Cut = self._Player_Node:getChildByName("Button_Cut")
    if self._Button_Cut then
        self._Button_Cut:setPressedActionEnabled(true)
        self._Button_Cut:addClickEventListener( function()
            if self:isMe() then
                self:cutCannonCallback()
            end
        end )
        self._Button_Cut:setVisible(false)
    end
    if Fish2dTools.mGame_Type ~= Fish2dTools.GAME_TYPE_FISHKING then
        -- 狂暴加速操作
        self._Button_Kuangbao = self._Player_Node:getChildByName("Button_Kuangbao")
        if self._Button_Kuangbao then
            self._Button_Kuangbao:addClickEventListener( function()
                if self:isMe() then
                    self._Button_Kuangbao_Tag1:setVisible(not self._Button_Kuangbao_Tag1:isVisible())
                    self._Button_Kuangbao_Tag2:setVisible(not self._Button_Kuangbao_Tag1:isVisible())
                    self:openKuangbao(self:isOpenKuangbao())
                end
            end )
            self._Button_Kuangbao:setVisible(true)

            self._Button_Kuangbao_Tag1 = self._Button_Kuangbao:getChildByName("Tag_select_1")
            self._Button_Kuangbao_Tag2 = self._Button_Kuangbao:getChildByName("Tag_select_2")
            self._Button_Kuangbao_Tag1:setVisible(false)
            self._Button_Kuangbao_Tag2:setVisible(true)
            self._Button_Kuangbao_Tag1:setLocalZOrder(5)
            self._Button_Kuangbao_Tag2:setLocalZOrder(5)

            self:initSpriteEffect(Fish2dTools.BULLET_Fury, self._Button_Kuangbao)
        end

        -- 狂暴双倍操作
        self._Button_Double = self._Player_Node:getChildByName("Button_Double")
        if self._Button_Double then
            self._Button_Double:addClickEventListener( function()
                if self:isMe() then
                    self._Button_Double_Tag1:setVisible(not self._Button_Double_Tag1:isVisible())
                    self._Button_Double_Tag2:setVisible(not self._Button_Double_Tag1:isVisible())
                    self:openDoubleCannon(self:isOpenDoubleCannon())
                end
            end )
            self._Button_Double:setVisible(true)

            self._Button_Double_Tag1 = self._Button_Double:getChildByName("Tag_select_1")
            self._Button_Double_Tag2 = self._Button_Double:getChildByName("Tag_select_2")
            self._Button_Double_Tag1:setVisible(false)
            self._Button_Double_Tag2:setVisible(true)
            self._Button_Double_Tag1:setLocalZOrder(5)
            self._Button_Double_Tag2:setLocalZOrder(5)

            self:initSpriteEffect(Fish2dTools.BULLET_DOUBLE, self._Button_Double)

            local localpos = cc.pAdd(self._Button_Double:getAnchorPointInPoints(), cc.p(35, -12))
            self._Sprite_Cannon_2_WorldPostion = self._Button_Double:convertToWorldSpace(localpos)
            if self:getParent() then
                self._Sprite_Cannon_2_WorldPostion = self:getParent():convertToNodeSpace(self._Sprite_Cannon_2_WorldPostion)
            end
        end

        -- 重叠金币效果
        self._CoinsShowNode = self._Player_Node:getChildByName("CoinsShow")
        self.mCoinsShow = CoinsNodeX:create()
        self.mCoinsShow:setPosition(0, 0)
        self._CoinsShowNode:addChild(self.mCoinsShow)

    end

    -- 锁定鱼效果
    self.mLockLineLayout = cc.Sprite:create()
    self.mLockLineLayout:setVisible(false)
    self:addChild(self.mLockLineLayout, 0XFFFF)
    for i = 0, 15 - 1 do
        local lockLine = cc.Sprite:createWithSpriteFrameName("lockBublle.png")
        lockLine:setTag(i)
        lockLine:setScale(0.8)
        lockLine:setOpacity(200)
        lockLine:setVisible(false)
        self.mLockLineLayout:addChild(lockLine)
    end

    self._mLockFishAnimate = FishNode.fishNode:create(nil, -1)
    self._mLockFishEffect = cc.Sprite:create()
    self._mLockFishEffect:setVisible(false)
    self._mLockFishAnimate:setPosition(self._Image_Lock:getPosition())
    self._mLockFishEffect:setPosition(self._Image_Lock:getPosition())
    self._Icon_lock:addChild(self._mLockFishAnimate, 1);
    self._Icon_lock:addChild(self._mLockFishEffect, 0);

    self.mLockIcon = cc.Sprite:createWithSpriteFrameName("lockCenter.png")
    self:addChild(self.mLockIcon, 10000)
    self.mLockIcon:setVisible(false)

    self.m_schedule = nil

    self:showCannon(false)
end

function Cannon:showAddCut(isShow)
    if not self:isMe() then
        return
    end
    if self._Button_Add then
        self._Button_Add:setVisible(isShow)
    end
    if self._Button_Cut then
        self._Button_Cut:setVisible(isShow)
    end
end

function Cannon:scheduleLock()
    function updateLock(dt)
        if not self._Player_Node:isVisible() then
            return
        end
        if self:isLockFish() then
            if not self._mLockFish.mFishModel or self._mLockFish.mFishModel.live_ <= 0 then
                self:cancelLockFish()
                return
            end
            if self:getLockFish():isOutWindow() then
                self:cancelLockFish()
                return
            end
            -- 有锁定鱼
            local lockfishPos = self:getLockFishPos()
            self.mLockLineLayout:setVisible(true)
            self:correctLockLine(lockfishPos)

            self._Icon_lock:setVisible(true)

            local tpos = self:convertToNodeSpace(lockfishPos)
            self.mLockIcon:setPosition(tpos)
            self.mLockIcon:setVisible(true)
            if self:isMe() then
                self:openCircularLockIcon()
            end
        else
            -- 没有锁定鱼
            self._Icon_lock:setVisible(false)
            self.mLockIcon:setVisible(false)
            self.mLockLineLayout:setVisible(false)
        end
    end

    if not self.m_schedule then
        self.m_schedule = scheduler:scheduleScriptFunc(updateLock, 0, false)
    end
end

function Cannon:correctLockLine(fishPos)
    local paotaiPos = self:getPaotaiPos()
    local now_p = cc.pSub(paotaiPos, fishPos)
    local angle = cc.pToAngleSelf(now_p)
    local distance = cc.pGetDistance(paotaiPos, fishPos)

    local tAllLockLine = self.mLockLineLayout:getChildren()
    local tAllLockLineCount = self.mLockLineLayout:getChildrenCount()
    -- 球个数
    local qCount = distance / 50
    if (qCount < 2) then qCount = 2 end
    if (qCount > tAllLockLineCount) then qCount = tAllLockLineCount end

    local average = distance / qCount;
    local stepx = average * math.cos(angle)
    local stepy = average * math.sin(angle)

    local posx = paotaiPos.x
    local posy = paotaiPos.y

    posx = posx - stepx
    posy = posy - stepy

    for i = 1, tAllLockLineCount do
        if tAllLockLine[i] then
            tAllLockLine[i]:setVisible(false)
        end
    end

    -- 第一个不显示
    tAllLockLine[1]:setVisible(false)
    for i = 2, qCount do
        local tLockLine = tAllLockLine[i]
        posx = posx - stepx
        posy = posy - stepy

        tLockLine:setVisible(true);
        local tLockLinePos = cc.p(posx, posy)
        tLockLine:setPosition(self.mLockLineLayout:convertToNodeSpace(tLockLinePos))
    end

    -- local paotaiPos2 = cc.p(paotaiPos.x,paotaiPos.y)
    -- local lockPos = cc.p(fishPos.x,fishPos.y)
    local value_1 = Fish2dTools.calcRotate(paotaiPos, fishPos)
    if self:getViewChairId() <= 1 then
        value_1 = value_1 - Fish2dTools.M_PI
    end
    self:setBowRotation(value_1)

end

function Cannon:openCircularLockIcon()
    self._Image_Lock:setVisible(true)

    if (self._mLockFish.mFishModel and self._mLockFish.mFishModel.type_ == Fish2dTools.BIRD_TYPE_INGOT) then
        -- 设置角度
        self._mLockFishEffect:setRotation(self._mLockFish:getRotation() + 90)
        -- 设置位置
        local bird_pos = self._mLockFishAnimate:getPosition()
        local angle = self._mLockFish:getRotation()
        local big_angle =(angle > 180 or angle < -180) and true or false
        angle =(angle > 180 and angle - 180 or angle < -180) and angle + 180 or angle
        angle = - angle
        local dregress = Fish2dTools.toNetRotation(angle)

        local effect_pos;
        if big_angle then
            effect_pos = cc.p(bird_pos.x - 30 * math.cos(dregress), bird_pos.y - 30 * math.sin(dregress))
        else
            effect_pos = cc.p(bird_pos.x + 30 * math.cos(dregress), bird_pos.y + 30 * math.sin(dregress))
        end

        self._mLockFishEffect:setPosition(effect_pos.x, effect_pos.y)
    else
        self._mLockFishEffect:setRotation(self._mLockFish:getRotation())
    end
end

function Cannon:unscheduleLock()
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
    end
end
-- 显示此玩家和炮台
function Cannon:showCannon(bshow)
    print("-----Cannon:show bshow:", bshow, self.chair_id_)
    if self._Player_Node == nil then
        return
    end

    self._Player_Node:setVisible(bshow)
    self:setVisible(bshow)

    if bshow then
        self:scheduleLock()
    else
        self:unscheduleLock()
    end

end


function Cannon:switchUIPosition(pFirstNode, pSecondNode)
    -- print("Cannon:switchUIPosition pFirstNode, pSecondNode: ", pFirstNode:getName(),pSecondNode:getName())
    if pFirstNode and pSecondNode then
        local firstpos = cc.p(pFirstNode:getPositionX(), pFirstNode:getPositionY())
        local secondpos = cc.p(pSecondNode:getPositionX(), pSecondNode:getPositionY())
        -- print("Cannon:switchUIPosition firstpos, secondpos: ", firstpos.x,firstpos.y,secondpos.x,secondpos.y)
        pSecondNode:setPosition(firstpos.x, firstpos.y)
        pFirstNode:setPosition(secondpos.x, secondpos.y)
    end
end

function Cannon:switchUIRotation(pFirstNode, pSecondNode)
    -- print("Cannon:switchUIRotation pFirstNode, pSecondNode: ", pFirstNode:getName(),pSecondNode:getName())
    if pFirstNode and pSecondNode then
        local temp = pSecondNode:getRotation()
        pSecondNode:setRotation(pFirstNode:getRotation())
        pFirstNode:setRotation(temp)
    end
end

function Cannon:switchUIScale(pFirstNode, pSecondNode)
    -- print("Cannon:switchUIScale pFirstNode, pSecondNode: ", pFirstNode:getName(),pSecondNode:getName())
    if pFirstNode and pSecondNode then
        local tempx = pSecondNode:getScaleX()
        local tempy = pSecondNode:getScaleY()
        pSecondNode:setScaleX(pFirstNode:getScaleX())
        pSecondNode:setScaleY(pFirstNode:getScaleY())
        pFirstNode:setScaleX(tempx)
        pFirstNode:setScaleY(tempy)
    end
end

function Cannon:switchUI(otherCannon)
    if not otherCannon then
        return
    end
    -- print("---Cannon:switchUI---otherCannon.view_chair_id_, self.view_chair_id_: ", otherCannon.view_chair_id_, self.view_chair_id_)
    local otherViewSeat = otherCannon.view_chair_id_
    otherCannon.view_chair_id_ = self.view_chair_id_
    self.view_chair_id_ = otherViewSeat

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return
    end

    self:switchUIPosition(self._Player_Node, otherCannon._Player_Node)
    self:switchUIRotation(self._Player_Node, otherCannon._Player_Node)
    self:switchUIScale(self._Player_Node, otherCannon._Player_Node)
    -- 炮台
    self:switchUIPosition(self._Image_Battery, otherCannon._Image_Battery)
    self:switchUIRotation(self._Image_Battery, otherCannon._Image_Battery)
    self:switchUIScale(self._Image_Battery, otherCannon._Image_Battery)
    -- 金钱文字
    self:switchUIPosition(self._AtlasLabel_Money, otherCannon._AtlasLabel_Money)
    self:switchUIRotation(self._AtlasLabel_Money, otherCannon._AtlasLabel_Money)
    self:switchUIPosition(self._Image_Money_Bg, otherCannon._Image_Money_Bg)
    self:switchUIRotation(self._Image_Money_Bg, otherCannon._Image_Money_Bg)
    self:switchUIScale(self._Image_Money_Bg, otherCannon._Image_Money_Bg)

    self:switchUIPosition(self._CoinsShowNode, otherCannon._CoinsShowNode)
    self:switchUIRotation(self._CoinsShowNode, otherCannon._CoinsShowNode)
    self:switchUIScale(self._CoinsShowNode, otherCannon._CoinsShowNode)
    -- 炮管数量
    self:switchUIRotation(self._AtlasLabel_CannonNum, otherCannon._AtlasLabel_CannonNum)
    self:switchUIPosition(self._AtlasLabel_CannonNum, otherCannon._AtlasLabel_CannonNum)
    -- 炮管
    self:switchUIPosition(self._Sprite_Cannon, otherCannon._Sprite_Cannon)
    self:switchUIRotation(self._Sprite_Cannon, otherCannon._Sprite_Cannon)
    self:switchUIScale(self._Sprite_Cannon, otherCannon._Sprite_Cannon)

    self:switchUIPosition(self._Sprite_Cannon_img, otherCannon._Sprite_Cannon_img)
    self:switchUIRotation(self._Sprite_Cannon_img, otherCannon._Sprite_Cannon_img)
    -- 锁定标记
    self:switchUIPosition(self._Icon_lock, otherCannon._Icon_lock)
    self:switchUIRotation(self._Icon_lock, otherCannon._Icon_lock)
    -- 按钮位置
    self:switchUIPosition(self._Button_Add, otherCannon._Button_Add)
    self:switchUIPosition(self._Button_Cut, otherCannon._Button_Cut)

    self:switchUIPosition(self._Button_Kuangbao, otherCannon._Button_Kuangbao)
    self:switchUIRotation(self._Button_Kuangbao, otherCannon._Button_Kuangbao)
    self:switchUIScale(self._Button_Kuangbao, otherCannon._Button_Kuangbao)
    self:switchUIPosition(self._Button_Double, otherCannon._Button_Double)
    self:switchUIRotation(self._Button_Double, otherCannon._Button_Double)
    self:switchUIScale(self._Button_Double, otherCannon._Button_Double)
    local localpos = cc.pAdd(self._Button_Double:getAnchorPointInPoints(), cc.p(35, -12))
    self._Sprite_Cannon_2_WorldPostion = self._Button_Double:convertToWorldSpace(localpos)
    if self:getParent() then
        self._Sprite_Cannon_2_WorldPostion = self:getParent():convertToNodeSpace(self._Sprite_Cannon_2_WorldPostion)
    end
    local local2pos = cc.pAdd(otherCannon._Button_Double:getAnchorPointInPoints(), cc.p(35, -12))
    otherCannon._Sprite_Cannon_2_WorldPostion = otherCannon._Button_Double:convertToWorldSpace(localpos)
    if otherCannon:getParent() then
        otherCannon._Sprite_Cannon_2_WorldPostion = otherCannon:getParent():convertToNodeSpace(otherCannon._Sprite_Cannon_2_WorldPostion)
    end

    -- print("---Cannon:switchUI Over---otherCannon.view_chair_id_, self.view_chair_id_: ", otherCannon.view_chair_id_, self.view_chair_id_)
end


function Cannon:onExit()

end

-- 设置炮的倍数
function Cannon:setCannonMuitle(multiple)
    --    print("Cannon:setCannonMuitle multiple: ", multiple)
    if self.cannon_mulriple_ == multiple then
        return
    end
    self.cannon_mulriple_ = multiple
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        self._AtlasLabel_CannonNum:setString(utils:moneyString(multiple))
        self._AtlasLabel_CannonNum:setVisible(true)
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        --local cannon_basemulriple = self:getCannonBaseMultiple(self.level_)
        --self._AtlasLabel_CannonNum:setString(cannon_basemulriple)

        self._AtlasLabel_CannonNum:setVisible(false)
    end

end

function Cannon:getCannonMuitle()
    return self.cannon_mulriple_
end


-- 设置炮的等级
function Cannon:setCannonLevel(level, isSetMuitle, isMust)
    -- print("---Cannon:setCannonLeve---level: ", level, isSetMuitle, self:getName())
    isSetMuitle = (isSetMuitle == nil) and true or isSetMuitle
    isMust = (isMust == nill) and false or isMust
    if not isMust and self.level_ == level then
        return false
    end

    self.level_ = level

    if not self._Sprite_Cannon_img then
        return true
    end
    self._Sprite_Cannon_img:setPosition(cc.p(0, 0))

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        -- 设置炮台样式
        if level < 6 then
            if self._Image_BatteryBig then
                self._Image_BatteryBig:setVisible(false)
            end
            self._Image_Battery:setVisible(true)
            if self:isMe() then
                self._Button_Add:setVisible(true)
                self._Button_Cut:setVisible(true)
            end
        else
            -- 鱼雷
            if self._Image_BatteryBig then
                self._Image_BatteryBig:setVisible(true)
                self._Image_Battery:setVisible(false)
            end
            if self:isMe() then
                self._Button_Add:setVisible(false)
                self._Button_Cut:setVisible(false)
            end
        end
    end

    local paoImage = nil
    local paoeff1 = nil
    local paoeff1_1 = nil

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        self._Sprite_Cannon_img:removeChildByName("paoeff1")
        self._Sprite_Cannon_img:removeChildByName("paoeff1_1")
        local index = self._dataModel:getCannonTypeByLevel(self.level_)
        if index == 0 then
            paoImage = "c2d_pao_01.png"
            paoeff1 = string.format("%s/flash/pao/01/jsby_paoguang_01.png", Fish2dTools.mGameResPre)
            paoeff1_1 = string.format("%s/flash/pao/01/paohuo1.png", Fish2dTools.mGameResPre)
        elseif index == 1 then
            paoImage = "c2d_pao_02.png"
            paoeff1 = string.format("%s/flash/pao/02/jsby_paoguang_02.png", Fish2dTools.mGameResPre)
            paoeff1_1 = string.format("%s/flash/pao/02/paohuo2.png", Fish2dTools.mGameResPre)
        else
            paoImage = "c2d_pao_03.png"
            paoeff1 = string.format("%s/flash/pao/03/jsby_paoguang_03.png", Fish2dTools.mGameResPre)
            paoeff1_1 = string.format("%s/flash/pao/03/paohuo3.png", Fish2dTools.mGameResPre)
        end
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        local index = self.level_
        paoImage = string.format("cking_pao_0%d.png", index)
    end
    self._Sprite_Cannon_img:setSpriteFrame(paoImage)


    if paoeff1 then
        local pao1Arma = cc.Sprite:create(paoeff1)
        pao1Arma:setName("paoeff1")
        pao1Arma:setPosition(cc.pAdd(self._Sprite_Cannon_img:getAnchorPointInPoints(), cc.p(0, 35)))
        -- pao1Arma:setBlendFunc(gl.ALPHA, gl.ONE)
        self._Sprite_Cannon_img:addChild(pao1Arma, 1)
        pao1Arma:setVisible(false)
    end
    if paoeff1_1 then
        local pao1_1Arma = cc.Sprite:create(paoeff1_1)
        pao1_1Arma:setName("paoeff1_1")
        pao1_1Arma:setPosition(cc.pAdd(self._Sprite_Cannon_img:getAnchorPointInPoints(), cc.p(0, 110)))
        -- pao1_1Arma:setBlendFunc(gl.ALPHA, gl.ONE)
        self._Sprite_Cannon_img:addChild(pao1_1Arma, 1)
        pao1_1Arma:setVisible(false)
    end
    -- 计算子弹速度
    self.cannon_speed_ = self._dataModel:getBulletSpeed(self.level_)


    -- 通知外部
    if self:isMe() then
        eventManager:publish('ChangeCannonLevel', self.level_)
    end

    if isSetMuitle then
        self:setCannonMuitle(self._dataModel:getCannonMripleByLevel(self.level_))
    end

    return true
end

function Cannon:getCannonLevel()
    return self.level_
end

-- 增加炮倍数
function Cannon:addCannonCallback()
    -- print("---Cannon:addCannonCallback---")
    if self:isMe() then
        PLAY_SOUND(GAME_FISH_SOUND_RES.."cannon_add.mp3", false)
    end
    local level = self.level_ + 1
    local maxLevel = self._dataModel:getCannonMaxLevel()
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        maxLevel = maxLevel - 2
        if level > maxLevel then
            level = maxLevel
        end
    end
    if level > maxLevel then
        level = 1
    end
    local isChange = self:setCannonLevel(level)
    local mulriple = self._dataModel:getCannonMripleByLevel(self.level_)
    self:setCannonMuitle(mulriple)
    if isChange then
        self:playChangeCannonEffect()
    end
end

-- 减少炮倍数
function Cannon:cutCannonCallback()
    -- print("---Cannon:cutCannonCallback---")
    if self:isMe() then
        PLAY_SOUND(GAME_FISH_SOUND_RES.."cannon_add.mp3", false)
    end
    local level = self.level_ - 1
    if level <= 0 then
        local maxLevel = self._dataModel:getCannonMaxLevel()
        if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
            maxLevel = maxLevel - 2
            level = 1
        else
            level = maxLevel
        end
    end
    local isChange = self:setCannonLevel(level)
    local mulriple = self._dataModel:getCannonMripleByLevel(self.level_)
    self:setCannonMuitle(mulriple)
    if isChange then
        self:playChangeCannonEffect()
    end
end

function Cannon:playChangeCannonEffect()
    if not self:isMe() then
        return
    end
    --    local change_lizhi = cc.Node:create()
    --    change_lizhi:setPosition(self._Sprite_Cannon:getPosition())
    local lizhiPos = cc.p(self._Sprite_Cannon:getPositionX(), self._Sprite_Cannon:getPositionY())
    local lizhiParent = self._Player_Node
    Fish2dTools.particle_play(lizhiParent, lizhiPos, Fish2dTools.mGameResPre .. "/flash/paoshouji/paoshouji_01.plist", 1, 0.9)
    Fish2dTools.particle_play(lizhiParent, lizhiPos, Fish2dTools.mGameResPre .. "/flash/paoshouji/paoshouji_02.plist", 1, 0.9)

end

-- 开启加速狂暴模式
function Cannon:openKuangbao(isOpen)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return
    end
    self._Button_Kuangbao_Tag1:setVisible(isOpen)
    self._Button_Kuangbao_Tag2:setVisible(not isOpen)
    if self:isMe() then
        if isOpen then
            self._dataModel.mAutoSpeedMultiple = 0.7
        else
            self._dataModel.mAutoSpeedMultiple = 1
        end
    end
    if self._isOpenKuangbao == isOpen then
        return
    end
    self._isOpenKuangbao = isOpen
    -- 通知外部
    if self:isMe() then
        eventManager:publish('OpenCannonKuangbao', self._isOpenKuangbao)
    end
    self:playSpriteOpenEffect(Fish2dTools.BULLET_Fury, isOpen, self._Button_Kuangbao)

end

-- 开启双炮模式
function Cannon:openDoubleCannon(isOpen)
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return
    end
    self._Button_Double_Tag1:setVisible(isOpen)
    self._Button_Double_Tag2:setVisible(not isOpen)

    if self._isOpenDouble == isOpen then
        return;
    end
    self._isOpenDouble = isOpen
    -- 通知外部
    if self:isMe() then
        eventManager:publish('OpenCannonDouble', self._isOpenDouble)
    end
    self:playSpriteOpenEffect(Fish2dTools.BULLET_DOUBLE, isOpen, self._Button_Double)
end

-- 是否已打开狂暴模式
function Cannon:isOpenKuangbao()
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return false
    end
    if self._Button_Kuangbao and self._Button_Kuangbao_Tag1 then
        return self._Button_Kuangbao_Tag1:isVisible()
    end
    return false
end

-- 是否已打开双炮模式
function Cannon:isOpenDoubleCannon()
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        return false
    end
    if self._Button_Double_Tag1 then
        return self._Button_Double_Tag1:isVisible()
    end
    return false
end

function Cannon:initSpriteEffect(stype, baseNode)
    local armaName = ""
    if (stype == Fish2dTools.BULLET_DOUBLE) then
        armaName = "buyu_renwu_3"
    elseif (stype == Fish2dTools.BULLET_Fury) then
        armaName = "buyu_renwu_1"
    else
        return
    end

    local spriteInitArma = baseNode:getChildByName("spriteInitArma")
    if spriteInitArma and spriteInitArma:getAnimation() then
--        spriteInitArma:getAnimation():stop()
        spriteInitArma:getAnimation():play("Animation1", -1, 1)
    else
        spriteInitArma = ccs.Armature:create(armaName)
        spriteInitArma:setName("spriteInitArma")
        spriteInitArma:setVisible(true)
        -- spriteInitArma->setAnchorPoint(Vec2(0.5f,0.5f));
        baseNode:addChild(spriteInitArma, 2)
        --
        spriteInitArma:getAnimation():play("Animation1", -1, 1)

        if (stype == Fish2dTools.BULLET_Fury) then
            spriteInitArma:setPosition(30, 23)
        elseif (stype == Fish2dTools.BULLET_DOUBLE) then
            spriteInitArma:setPosition(30, 20)
        end
    end
end

function Cannon:playSpriteOpenEffect(stype, isOpen, baseNode)
    local tagAni1 = 10
    local tagAni2 = 11
    local tagAni3 = 12
    local tagLizi1 = 15
    local tagLizi2 = 16
    local tagLizi3 = 17
    local ani1 = baseNode:getChildByTag(tagAni1)
    local ani2 = baseNode:getChildByTag(tagAni2)
    local ani3 = baseNode:getChildByTag(tagAni3)

    local lizi1 = baseNode:getChildByTag(tagLizi1)
    local lizi2 = baseNode:getChildByTag(tagLizi2)
    local lizi3 = baseNode:getChildByTag(tagLizi3)

    if not isOpen then
        if ani1 then
            ani1:removeFromParent()
        end
        if ani2 then
            ani2:removeFromParent()
        end
        if ani3 then
            ani3:removeFromParent()
        end
        if lizi1 then
            lizi1:removeFromParent()
        end
        if lizi2 then
            lizi2:removeFromParent()
        end
        if lizi3 then
            lizi3:removeFromParent()
        end

        if (stype == Fish2dTools.BULLET_Fury) then
            -- 加速
            self._Cannon_Head:removeChildByName("longwang_effect")
        end
        -- 返回
        return
    end

    if ani1 then
        ani1:setVisible(true)
        ani1:getAnimation():play("Animation1", -1, 1)
    else
        local oppoPos = cc.p(0, 0)
        if (stype == Fish2dTools.BULLET_Fury) then
            -- 狂暴加速
            ani1 = ccs.Armature:create("2d_fkby_renwu_longwang")
            oppoPos = cc.p(-32.28, 52.86 - 5 - 13)
        elseif (stype == Fish2dTools.BULLET_DOUBLE) then
            -- 双炮
            ani1 = ccs.Armature:create("fkby_renwu_wukong00")
            oppoPos = cc.p(25.00 + 15, 46.54)
        end
        if ani1 then
            ani1:setTag(tagAni1)
            ani1:setPosition(oppoPos.x, oppoPos.y)
            ani1:setVisible(true)
            -- ani1->setAnchorPoint(Vec2::ZERO)
            baseNode:addChild(ani1, 3)
            -- -
            ani1:getAnimation():play("Animation1", -1, 1)
        end
    end

    if ani2 then
        ani2:setVersion(true)
        ani2:getAnimation():play("Animation1", -1, 1)
    else
        local oppoPos = cc.p(0, 0)
        if (stype == Fish2dTools.BULLET_Fury) then
            -- 狂暴加速

        elseif (stype == Fish2dTools.BULLET_DOUBLE) then
            -- 双炮
            ani2 = ccs.Armature:create("fkby_renwu_wukong01")
            oppoPos = cc.p(30, 49)
        end
        if ani2 then
            ani2:setTag(tagAni2)
            ani2:setPosition(oppoPos.x, oppoPos.y)
            ani2:setVisible(true)
            -- ani2->setAnchorPoint(Vec2::ZERO);
            if (stype == Fish2dTools.BULLET_Fury) then
                ani2:setAnchorPoint(cc.p(0.5, 0.5))
                self._Cannon_Head:addChild(ani2, 3)
                -- 龙王牛魔王的这个特效加在炮口上
            elseif (stype == Fish2dTools.BULLET_DOUBLE) then
                baseNode:addChild(ani2, 1)
            end
            -- -
            ani2:getAnimation():play("Animation1", -1, 1)
        end
    end

    if ani3 then
        ani3:setVersion(true)
        ani3:getAnimation():play("Animation1", -1, 1)
    else
        local oppoPos = cc.p(0, 0)
        if (stype == Fish2dTools.BULLET_DOUBLE) then
            -- 双炮
            ani3 = ccs.Armature:create("fkby_renwu_wukong02")
            oppoPos = cc.p(65.10, 28.89)
        end
        if ani3 then
            ani3:setTag(tagAni3)
            ani3:setPosition(oppoPos.x, oppoPos.y)
            ani3:setVisible(true)
            -- ani3->setAnchorPoint(Vec2::ZERO);
            baseNode:addChild(ani3, 3)
            -- -
            ani3:getAnimation():play("Animation1", -1, 1)
        end
    end


    if lizi1 then
        lizi1:setVisible(true)
    else
        local oppoPos = cc.p(0, 0)
        if (stype == Fish2dTools.BULLET_Fury) then
            -- 加速
            lizi1 = cc.ParticleSystemQuad:create(string.format("%s/flash/longwang/longwang.plist", Fish2dTools.mGameResPre))
            oppoPos = cc.p(29.58, 35.00 - 13);
        elseif (stype == Fish2dTools.BULLET_DOUBLE) then
            -- //双炮
            lizi1 = cc.ParticleSystemQuad:create(string.format("%s/flash/sunwukong/wukong.plist", Fish2dTools.mGameResPre))
            oppoPos = cc.p(63.08, 27.87)
        end
        if lizi1 then
            lizi1:setTag(tagLizi1)
            lizi1:setPosition(oppoPos.x, oppoPos.y)
            baseNode:addChild(lizi1, 3)
        end
    end
    if lizi2 then
        lizi2:setVisible(true)
    else
        local oppoPos = cc.p(0, 0)
        if (stype == Fish2dTools.BULLET_Fury) then
            -- 加速
            lizi2 = cc.ParticleSystemQuad:create(string.format("%s/flash/longwang/longwang2.plist", Fish2dTools.mGameResPre))
            oppoPos = cc.p(31.32, 20.00)
        end
        if lizi2 then
            lizi2:setTag(tagLizi2)
            lizi2:setPosition(oppoPos.x, oppoPos.y)
            baseNode:addChild(lizi2, 3)
        end
    end
    if lizi3 then
        lizi3:setVisible(true)
    else
        local oppoPos = cc.p(0, 0)
        if (stype == Fish2dTools.BULLET_Fury) then
            -- 加速
            lizi3 = cc.ParticleSystemQuad:create(string.format("%s/flash/longwang/longwang.plist", Fish2dTools.mGameResPre))
            oppoPos = cc.p(29.58 - 150, 35.00 + 20 - 13 - 33)
        end
        if lizi3 then
            lizi3:setTag(tagLizi3)
            lizi3:setPosition(oppoPos.x, oppoPos.y)
            baseNode:addChild(lizi3, 3)
        end
    end

end

function Cannon:getPaotaiPos()
    if not self._Sprite_Cannon then
        return cc.p(0, 0)
    end
    local tPos = self._Sprite_Cannon:convertToWorldSpace(self._Sprite_Cannon:getAnchorPointInPoints())
    tPos = self:getParent():convertToNodeSpace(tPos)
    return tPos
end

function Cannon:setIsMe(isMe)
    self._isMe = isMe
    self._Button_Add:setVisible(isMe)
    self._Button_Cut:setVisible(isMe)
end

function Cannon:isMe()
    return self._isMe
end

function Cannon:setViewChairId(view_chair_id)
    self.view_chair_id_ = view_chair_id
end

function Cannon:getViewChairId()
    return self.view_chair_id_
end

function Cannon:getChairId()
    return self.chair_id_
end

function Cannon:setName(name)
    if self._Text_Name and name then
        self._Text_Name:setString(name)
    end
end

function Cannon:setGold(gold)
    if gold == nil then
        return
    end
    self.gold_ = gold
    self._AtlasLabel_Money:setString(utils:moneyString(gold, 2))

end

function Cannon:addGold(gold)
    self:setGold(self.gold_ + gold)
end

-- 显示叠金币效果
function Cannon:showCoin(count, score)
    if self.mCoinsShow == nil then
        return
    end
    if self:getViewChairId() == 0 or self:getViewChairId() == 2 then
        self.mCoinsShow:show_coin_animtion(count, score, true)
    else
        self.mCoinsShow:show_coin_animtion(count, score, false)
    end
end

function Cannon:getGold()
    return self.gold_
end

-- 判断能否发炮
function Cannon:canFire()
    if self:isOpenDoubleCannon() then
        return self.cannon_mulriple_ * 2 <= self.gold_
    end
    return self.cannon_mulriple_ <= self.gold_
end

-- 处理发炮动画
function Cannon:fire(isSelf)
    local backtime = 0.12;
    local backscale = 1.05;
    local gotime = 0.15;
    local goscale = 1.0;
    local offoLength = 15;

    if self._Sprite_Cannon_img then
        self._Sprite_Cannon_img:stopAllActions()
        self._Sprite_Cannon_img:setPosition(cc.p(0, 0))
        local radians = Fish2dTools.toNetRotation(90 - self._Sprite_Cannon_img:getRotationSkewX())
        local offoPos = cc.p(math.cos(radians) * offoLength, math.sin(radians) * offoLength)
        local backPostion = cc.p(- offoPos.x, - offoPos.y)

        local goPostion = cc.p(0, 0)
        local spawn1 = cc.Spawn:create( { cc.MoveTo:create(backtime, backPostion), cc.ScaleTo:create(backtime, backscale) })
        local spawn2 = cc.Spawn:create( { cc.MoveTo:create(gotime, goPostion), cc.ScaleTo:create(gotime, goscale) })
        local runAni = cc.Sequence:create(spawn1, spawn2, nil)
        self._Sprite_Cannon_img:runAction(runAni)
    end

    local pao1Arma = self._Sprite_Cannon_img:getChildByName("paoeff1")
    if pao1Arma then
        pao1Arma:stopAllActions()
        pao1Arma:setVisible(true)
        pao1Arma:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), cc.FadeOut:create(0.05), cc.Hide:create(), nil))
    end
    local pao1_1Arma = self._Sprite_Cannon_img:getChildByName("paoeff1_1")
    if pao1_1Arma then
        pao1_1Arma:stopAllActions()
        pao1_1Arma:setVisible(true)
        pao1_1Arma:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), cc.FadeOut:create(0.05), cc.Hide:create(), nil))
    end


end

local lockFishEffectTag = 11022
local lockFishAniTag = 11023

function Cannon:setLockFish(fish)
    if self._mLockFish == nil and fish == nil then

        return
    end

    self._mLockFish = fish
    if self._mLockFish then
        self._mLockFishId = self._mLockFish.mFishModel.id_
    else
        self._mLockFishId = 0
    end
    -- 处理效果
    if self._mLockFish == nil then
        if self._mLockFishAnimate and self._mLockFishEffect then
            self._mLockFishAnimate:stopAllActions()
            self._mLockFishEffect:stopAllActions();
            self._mLockFishType = -1
            self._mLockFishTypeSpecial = -1
            self._mLockFishAnimate:setScale(1);
            self._mLockFishEffect:setScale(1);
            self._mLockFishAnimate:setColor(cc.c3b(255, 255, 255))
            self._mLockFishEffect:setVisible(false);
            self._mLockFishEffect:setLocalZOrder(0);
            self._mLockFishEffect:setPosition(self._Image_Lock:getPosition())
            self._mLockFishAnimate:setRotation(0)
            ----
            self._mLockFishAnimate:removeFromParent()
            self._mLockFishAnimate = nil;
            self._mLockFishEffect:removeFromParent()
            self._mLockFishEffect = nil
        end
        if self.mLockLineLayout then
            self.mLockLineLayout:setVisible(false)
        end
        self._Icon_lock:removeChildByTag(lockFishAniTag)
        self._Icon_lock:removeChildByTag(lockFishEffectTag)
        self._Icon_lock:setVisible(false)
        self.mLockIcon:setVisible(false)
        return
    end
    local fish_type = self._mLockFish:getType()
    local fish_type_special = self._mLockFish.mFishModel.type_
    local lockfish_type = self._mLockFish.mFishModel.type_

    -- 锁定的鱼存在, 锁定的鱼的类型不等于保存的鱼的类型. 创建的鱼的类型不等于创建的鱼的类型
    if fish_type ~= self._mLockFishType or fish_type_special ~= self._mLockFishTypeSpecial then

        if self._mLockFishAnimate then
            self._mLockFishAnimate:stopAllActions()

            self._mLockFishAnimate:setColor(cc.c3b(255, 255, 255))
            -- 移除该动画
            self._mLockFishAnimate:removeFromParent()
            self._mLockFishAnimate = nil;
        end
        if self._mLockFishEffect then
            -- 移除特效下所有节点
            self._mLockFishEffect:stopAllActions()
            self._mLockFishEffect:removeFromParent()
            self._mLockFishEffect = nil
        end

        self._mLockFishEffect = cc.Sprite:create()
        self._mLockFishEffect:setPosition(self._Image_Lock:getPositionX(), self._Image_Lock:getPositionY())
        self._mLockFishEffect:setTag(lockFishEffectTag)
        self._Icon_lock:addChild(self._mLockFishEffect, 0)
        -- 锁定鱼
        self._mLockFishType = self._mLockFish:getType()
        self._mLockFishTypeSpecial = self._mLockFish.mFishModel.type_
        -- 若为红鱼和闪电鱼.则改为特效获取

        if (Fish2dTools.isSpecialBird(lockfish_type)) then
            -- 特殊鱼用特殊类去创建
            if (Fish2dTools.isSpecialRoundBird(lockfish_type)) then
                self._mLockFishAnimate = FishNode.specialFishNode:create(nil, self._mLockFish.mFishModel.item_)
                self._mLockFishAnimate:setFishNum(lockfish_type - Fish2dTools.BIRD_TYPE_ONE + 1)
            else
                self._mLockFishAnimate = FishNode.fishNode:create(nil, self._mLockFish.mFishModel.item_)
            end
        else
            self._mLockFishAnimate = FishNode.fishNode:create(nil, lockfish_type)
        end

        self._mLockFishAnimate:born(false)
        -- 设置红鱼必须在后面.
        if (lockfish_type == Fish2dTools.BIRD_TYPE_RED) then
            self._mLockFishAnimate:setColor(cc.c3b(255, 0, 0))
        end
        self._mLockFishAnimate:setPosition(self._Image_Lock:getPosition())
        self._mLockFishAnimate:setTag(lockFishAniTag)
        self._Icon_lock:addChild(self._mLockFishAnimate)
        local sEffect = string.format("BirdEffect%d", lockfish_type)
        -- 特效
        local effect_animate = Fish2dTools.createAnimate(sEffect, 0)
        if effect_animate then
            -- 特效不为空才添加
            self._mLockFishEffect:setVisible(true)
            -- 使用特殊鱼类中的方法确定位置
            if (Fish2dTools.isSpecialRoundBird(lockfish_type)) then
                self._mLockFishAnimate:setEffect(self._mLockFishEffect, effect_animate)
            else
                self._mLockFishEffect:runAction(cc.CCRepeatForever:create(effect_animate))
            end
            if (self._mLockFishTypeSpecial == Fish2dTools.BIRD_TYPE_CHAIN or self._mLockFishTypeSpecial == Fish2dTools.BIRD_TYPE_INGOT) then
                -- < 是闪电鱼,在上面
                self._mLockFishEffect:setLocalZOrder(2)
            end
        else
            self._mLockFishEffect:setVisible(false)
            self._mLockFishEffect:setLocalZOrder(0)
        end

        -- 计算缩放!!
        local scale_rate = cc.p(1, 1)
        if (lockfish_type == Fish2dTools.BIRD_TYPE_INGOT) then
            scale_rate.x = 0.4
            scale_rate.y = 0.4
        elseif (lockfish_type > 14) then
            scale_rate.x = 0.4
            scale_rate.y = 0.4
        elseif (not Fish2dTools.isSpecialRoundBird(lockfish_type)) then
            local bgSize = self._Image_Lock:getContentSize()
            local birdSize = self._mLockFish:getSize()

            -- < 框的宽度,除以鱼的宽度
            scale_rate = cc.p(bgSize.width / birdSize.width, bgSize.height / birdSize.height)
            -- < 先取最小值
            if (scale_rate.x > scale_rate.y) then
                scale_rate.x = scale_rate.y
            else
                scale_rate.y = scale_rate.x
            end
            -- < 在检查是否大于1,///< 在检查是否等于0
            if (scale_rate.x > 0.75 or scale_rate.x <= 0.0) then
                scale_rate.x = 0.75
                scale_rate.y = 0.75
            end
        else
            if (lockfish_type == Fish2dTools.BIRD_TYPE_ONE) then
                scale_rate.x = 0.5
                scale_rate.y = 0.5
            elseif (lockfish_type == Fish2dTools.BIRD_TYPE_TWO) then
                scale_rate.x = 0.4
                scale_rate.y = 0.4
            elseif (lockfish_type == Fish2dTools.BIRD_TYPE_THREE) then
                scale_rate.x = 0.35
                scale_rate.y = 0.35
            elseif (lockfish_type == Fish2dTools.BIRD_TYPE_FOUR) then
                scale_rate.x = 0.3
                scale_rate.y = 0.3
            elseif (lockfish_type == Fish2dTools.BIRD_TYPE_FIVE) then
                scale_rate.x = 0.3
                scale_rate.y = 0.3
            end
        end

        self._mLockFishAnimate:setScale(scale_rate.x)

        if lockfish_type ~= Fish2dTools.BOSS_FISH then
            if self:getViewChairId() >= 2 then
                self._mLockFishAnimate:setScaleY(- scale_rate.x)
            end
        else
            if self:getViewChairId() >= 2 then
                self._mLockFishAnimate:setRotation(-90)
            else
                self._mLockFishAnimate:setRotation(90)
            end
        end

        self._mLockFishEffect:setScale(scale_rate.x)

        -- < 计算位置
        local bird_pos = cc.p(self._mLockFishAnimate:getPositionX(), self._mLockFishAnimate:getPositionY())
        local angle = self._mLockFishAnimate:getRotation()
        local big_angle =(angle > 180 or angle < -180) and true or false
        angle =(angle > 180 and angle - 180 or angle < -180) and angle + 180 or angle
        angle = - angle
        local dregress = Fish2dTools.toNetRotation(angle)

        local effect_pos;
        if big_angle then
            effect_pos = cc.p(bird_pos.x - 30 * math.cos(dregress), bird_pos.y - 30 * math.sin(dregress))
        else
            effect_pos = cc.p(bird_pos.x + 30 * math.cos(dregress), bird_pos.y + 30 * math.sin(dregress))
        end

        if (lockfish_type == Fish2dTools.BIRD_TYPE_INGOT) then
            self._mLockFishEffect:setPosition(effect_pos)
        else
            self._mLockFishEffect:setPosition(self._Image_Lock:getPositionX(), self._Image_Lock:getPositionY())
        end

    end

end

function Cannon:clearLockEffect()
    if self._mLockFishAnimate and self._mLockFishEffect then
        self._mLockFishAnimate:stopAllActions()
        self._mLockFishEffect:stopAllActions();
        self._mLockFishType = -1
        self._mLockFishTypeSpecial = -1
        self._mLockFishAnimate:setScale(1);
        self._mLockFishEffect:setScale(1);
        self._mLockFishAnimate:setColor(cc.c3b(255, 255, 255))
        self._mLockFishEffect:setVisible(false);
        self._mLockFishEffect:setLocalZOrder(0);
        self._mLockFishEffect:setPosition(self._Image_Lock:getPosition())
        self._mLockFishAnimate:setRotation(0)
        ----
        self._mLockFishAnimate:removeFromParent()
        self._mLockFishAnimate = nil;
        self._mLockFishEffect:removeFromParent()
        self._mLockFishEffect = nil
    end
    if self.mLockLineLayout then
        self.mLockLineLayout:setVisible(false)
    end
    self._Icon_lock:removeChildByTag(lockFishAniTag)
    self._Icon_lock:removeChildByTag(lockFishEffectTag)
    self._Icon_lock:setVisible(false)
    self.mLockIcon:setVisible(false)
end

function Cannon:getLockFishPos()
    if self._mLockFish then
        local tfishpos = self._mLockFish:convertToWorldSpace(self._mLockFish:getAnchorPointInPoints())
        tfishpos = self:getParent():convertToNodeSpace(tfishpos)
        return tfishpos
    end
    return cc.p(0, 0)
end

function Cannon:isLockFish()
    return not (self._mLockFish == nil)
end

function Cannon:cancelLockFish()
    self:setLockFish(nil)
    self._mLockFishId = 0
end

function Cannon:getLockFish()
    return self._mLockFish
end

function Cannon:getLockFishId()
    return self._mLockFishId
end

-- 设置炮口的旋转角度
function Cannon:setBowRotation(rotation)
    -- print("---Cannon:setBowRotation---rotation:",rotation)
    self.rotation_ = rotation

    local angle = math.deg(self.rotation_)
    -- 弧度转为角度
    if self._Sprite_Cannon_img then
        self._Sprite_Cannon_img:setRotation(angle)
    end
end

-- 获取炮口的角度
function Cannon:getBowRotation()
    return self.rotation_
end

function Cannon:getSpriteCannonImgRotation()
    return self._Sprite_Cannon_img:getRotation()
end

function Cannon:getPlayerNodeRotation()
    return self._Player_Node:getRotation()
end

function Cannon:getConnonDouble2WordPos()
    return self._Sprite_Cannon_2_WorldPostion
end

return Cannon
-- endregion