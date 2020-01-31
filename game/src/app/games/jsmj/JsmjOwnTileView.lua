--[[--
        界面: play界面自己手牌
        生命周期: 同playview
  ]]
local C = class("JsmjOwnTileView", cc.Node)
local JsmjDefine = import(".JsmjDefine")
local JsmjTile = import(".JsmjTile")

local STATE_NONE = 0 -- 无状态
local STATE_WAIT_DEAL = 1 -- 等待开始发牌
local STATE_DEAL_ANIM = 2 -- 发牌动画状态：增加牌 - [四张翻转牌],主要是
local STATE_SORT_ANIM = 3 -- 排序动画状态
local STATE_PLAY = 4 -- 普通状态
local STATE_MOVE = 5 -- 移动选中的牌

local MAX_DEAL_CARD_NUM = 14 -- 发牌阶段玩家拥有的最大牌数
local STATE_OPENDOOR_STEP_1 = 0 -- 发牌动画的第1步
local STATE_OPENDOOR_STEP_2 = 1

local TILE_CLICK_STATE_DISABLE = -1
local TILE_CLICK_STATE_HUN = 100

local TOUCH_STATE_NONE = 0
local TOUCH_STATE_DOWN = 1
local TOUCH_STATE_LONG = 2
local TOUCH_STATE_SELECT = 3
local TOUCH_STATE_MOVE = 4
local TOUCH_STATE_DOUBLE = 5 -- 双击
local TOUCH_STATE_DISPLAY_TING = 6 -- 显示当前听了什么牌
local TOUCH_STATE_DISPLAY_HUN = 7 -- 弹出混牌说明

local CLICK_DELAY = 0.06 -- down 和up事件时间间隔 单位：秒

local TILE_FAN_NUM = 5 -- 番数展示
local ADD_ID_HUN = 5000 -- 混牌阴影id增量（为了与tile的id_有区别）
local ADD_ID_ANIM = 6000 -- 动画
local ADD_ID_EFFECT = 10000 -- 放大tile
local IMG_TING_MASK_ID = 10 -- ting 牌的mask
local IMG_AWARD_MASK_ID = 100 -- 设置奖花的蒙灰所在的层
local IMG_AWARD_ITEM_ID = 10 -- 每个蒙灰所在的层

C.TYPE_DEAL_END = 1 -- 发牌动画结束的监听
C.TYPE_PLAY_UPPER = 2 -- 打牌过程中选中那张牌的回调
C.TYPE_TILE_MOVE = 3 -- 监听滑动出牌的状态
C.TYPE_PLAY_PRESS = 4 -- 牌过程中点中那张牌的回调

C.TYPE_PRESS_TING = 5
C.TYPE_PRESS_HUN = 6

C.TYPE_DISCARD_TILE = 7
C.TYPE_PRESS_PRE_TING = 8

C.colorCount_ = nil -- 保存万筒条开牌时数量，用于排序
C.isDrawTile_ = true -- 是否抓完牌，控制显示
C.canDiscardFlag_ = false -- 是否可以出牌
C.anGang_ = nil -- 保持暗杠被提起过的牌
C.flowerid_ = nil -- 保存花牌id，用于播放补花动画

--[[--
        构造函数
        @param parent:上一级界面
  ]]
function C:ctor(parent)
    -- C.super.ctor(self)
    self.parentView = parent
    -- self.theme_ = parent.theme_
    self.mahjongData_ = self.parentView.model
    self.openDoorStepState_ = STATE_OPENDOOR_STEP_1
    -- 发牌动画步骤

    self.tiles_ = { }
    -- 自己的手牌

    self.moveTile_ = nil
    -- 当前移动的牌
    self.nCanTingTiles_ = { }
    -- 可听牌列表

    self.drawTile_ = nil
    -- 抓到的牌

    self.haveHunTilesflag_ = false
    -- 收到混牌消息的标志

    self.nOwnTileTouchState_ = 0

    self.nLastTileRight_ = 0
    -- 手牌最后一张手牌的右坐标，便于显示OperaterBtn

    self.mIsShowWinTiles_ = false
    self.bDiscardActionFlag_ = false
    -- 是否是自己出牌的请求
    self.mBackTileRects_ = { }
    -- 显示牌的背面(即推倒后的牌)，二人胡牌，玩家胡牌后；或者听牌后

    self.mHuTile_ = nil
    -- 胡牌的牌
    self.mIsTwoWin_ = false

    self.mIsCalled_ = false
    -- 是否已经听牌

    self.tileMargin = 0
    self.bottomOffset = math.modf(21)
    -- self.bottom = math.modf(self.dimens_:getDimens(32))
    self.bottom_ = math.modf(35)
    -- 距离底部的距离

    self.padding_ = math.modf(15)
    self.matchId_ = parent.matchId_
    self.listen_ = nil
    self.ownstate_ = STATE_WAIT_DEAL
    self.lastDownY = 0
    self.touchState = 0

    self.resultPadding_ = 90
    -- 结算时，　牌放倒的偏移
    self.paddingCenter_ = 0
    -- 居中处理时，此处可以用50(可以实现5张与4张都居中)

    local layer = ccui.Layout:create()
    layer:setTag(ADD_ID_ANIM)
    layer:setVisible(false)
    self:addChild(layer)

    self.isShowTiles_ = false
    -- 是否显示开牌动画

    self.selfInfo_ = nil

    self.nTilePressEffectWidth_ = 106
    self.nTilePressEffectHeight_ = 153
    -- 吃碰杠几组牌
    self.bOpendoorEnd_ = false
    -- 开牌完毕
    self.isBanker_ = false
    -- 标记自己庄家第一次出牌动作
    self.tingRefresh_ = false
    -- 标记是否更新查听内容
    self.beganTouchSign_ = false
    -- 标记点击事件开始与结束
    self.fanShowCount_ = 0
    -- 显示加番牌的张数[场景版迭代]
    self.isTileMoveAnim_ = false
    -- 牌移动的状态
    self.fallState_ = false
    -- 放倒状态
    self.dealHadShowNum_ = 0
    -- 发牌阶段，已经亮牌的数量
    self.totalShow_ = 0
end

function C:setTouchEnabled(enable)
	self.canTouch = enable;
end

-- 移除所有牌张
function C:delAllTiles()
    self:removeAllChildren()
    self.tiles_ = { }
    self.drawTile_ = nil
    self.resultView_ = nil
end

-- 重置手牌数据
function C:playViewReset()
    self.isShowTiles_ = false
    self.haveHunTilesflag_ = false
    self.isHunRec_ = false
    self.selfInfo_ = nil
    -- 吃碰杠几组牌
    self.bOpendoorEnd_ = false
    -- 开牌完毕
    self:removeAllChildren()
    --    self:removeAllView()
    self.tiles_ = { }
    self.drawTile_ = nil
    self.isBanker_ = false
    self.anGang_ = nil
    self.tingRefresh_ = false
    self.resultView_ = nil
    self.mIsCalled_ = false
    self.nCanTingTiles_ = { }
    self.totalShow_ = 0
    self:setTouchEnabled(true)
    self:setDiscardTileFlag(false)
    self.beganTouchSign_ = false
    -- 标记点击事件开始与结束
    self.tingSignColor_ = nil
    self.tingSignValue_ = nil
    self.fanShowCount_ = 0
    self:setTileMoveingFlag(false)
    self:setFallState(false)
    -- 以下用于自动适配手牌张数
    self.bigTileWidth_ = 80
    self.bigTileHeight_ = 116
    local maxDealCardNum = 5
    self.tileAllWidth_ = maxDealCardNum * self.bigTileWidth_ +(maxDealCardNum - 1) * self.tileMargin
    self.margin_ = math.modf((display.width - self.tileAllWidth_ - self.padding_) / 2)
    local offsetX = (display.width-1136)/2
    self.handStartX_ = display.width/2 + self.bigTileWidth_*2 - offsetX + 15
    -- 手牌的起始位置
    self:setHadShowNum(0)
end

--[[--
        删除单个牌张
        @param tile:删除牌
        @param notAnim:是否需要播放抓牌动画
  ]]
function C:delTile(tile, notAnim)
    if tile then
        if self.mahjongData_ then
            self.mahjongData_:setDrawAnimFlag(false)
        end
        self.nCanTingTiles_ = { }

        local fanTile = nil
        -- 加番牌
        local removeFlag = false
        -- 是否移除
--        if self.mahjongData_ and self.mahjongData_:getAddFanTileId() > 0 then
--            fanTile = Tile.new(self.mahjongData_:getAddFanTileId())
--        end

        if self.isDrawCall_ then
            self.isDrawCall_ = false
            self:removeAllChildren()
            self:addTileViews()
            local drawTile = self:getDrawTile()
            if drawTile then
                self:setTileInHand(drawTile.id_)
            end
            removeFlag = true
        end
        --local tileNum = self.mahjongData_:getMaxTileNumber()
        local tileNum = 4

        for index, tileTmp in ipairs(self.tiles_) do
            if tileTmp.id_ == tile.id_ then
                self.moveDiscardIdx_ =((tileNum + 1) - #self.tiles_) + index
                if self:getChildByTag(tileTmp.id_) then
                    self:getChildByTag(tileTmp.id_):removeFromParent()
                end
                if self:getChildByTag(tileTmp.id_ + ADD_ID_EFFECT) then
                    self:getChildByTag(tileTmp.id_ + ADD_ID_EFFECT):removeFromParent()
                end
                table.remove(self.tiles_, index)

--                if fanTile and fanTile.color_ == tile.color_ and fanTile.value_ == tile.value_ then
--                    removeFlag = true
--                end
                break
            end
        end

        self.drawTile_ = nil
        if #self.tiles_ % 3 ~= 1 then
            -- 打完牌如果少牌或者多牌，则刷新一下数据
--            local data = GameDataContainer:getGameData(self.matchId_)
--            if data and #data.tiles_ % 3 == 1 then
--                self:startGetTiles(data.tiles_, true)
--            end
        end

--        if removeFlag then
--            self:refreshSign()
--        end
        self:refreshTiles(notAnim)
    end
end

--[[--
        手牌中是否存在某一张牌
        @param tile:检查牌张
        @return tile:找到牌张
  ]]
function C:findByTile(tile)
    local ret = false
    for index, tileTmp in pairs(self.tiles_) do
        if tileTmp.id_ == tile.id_ then
            ret = self.tiles_[index]
        end
    end
    return ret
end

--[[--
        刷新手牌显示
        @param notAnim:是否需要抓牌动画
  ]]
function C:refreshTiles(notAnim)
    -- 每次删除牌时都需要重新排序index
    self:addTileViews()
    self:soreTiles()

    self:drawTiles(notAnim)
end

--[[--
        发牌动画时，逐步显示牌张
        @param num:显示数量

  ]]
function C:showDealTiles(num)
    num = self.totalShow_ + num
    self.totalShow_ = num
    local maxTileNum = #self.mahjongData_.myCards
    local lastTileNum = maxTileNum
--    if self.mahjongData_.mySeat == self.mahjongData_.bankerSeat then
--        -- 如果是庄家，则以最后一张为准
--        lastTileNum = maxTileNum + 1 --最后一张牌
--    end

    if num and not self.isShowTiles_ then
        local began, last = 0, 0
        if num == 4 then --前4张
            self:drawBottomTilesAnim(#self.tiles_)
            self:setHadShowNum(num)

            began = num
            last = num - 3
        else
            if num > lastTileNum then
                began = lastTileNum -- 对于７张牌，如果分２次发，每次发4张，就会多一张，此处增加这种方式的支持
            else
                began = num
            end
            last = self:getHadShowNum()+1
            self:setHadShowNum(num)
        end
        local layer = self:getChildByTag(ADD_ID_ANIM)
        if layer then
            layer:setVisible(true)
            for i = began, last, -1 do
                if layer:getChildByTag(i) then
                    layer:getChildByTag(i):setVisible(true)
                end
            end
            self:delayInvoke(0.15, handler(self, function()
                for i = began, last, -1 do
                    if layer:getChildByTag(i) then
                        layer:getChildByTag(i):setVisible(false)
                    end
                    if self.tiles_[i] then
                        local view = self:getChildByTag(self.tiles_[i].id_)
                        if view then
                            view:setVisible(true)
                        end
                    end
                end
            end))
        end

        -- 最后一张牌
        if num >= lastTileNum then
            self.isShowTiles_ = true
            self.openDoorStepState_ = STATE_OPENDOOR_STEP_1
            if self.scheduleHandler_ then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleHandler_)
                self.scheduleHandler_ = nil
            end
            self.parentView:refreshBanker()
            self.scheduleHandler_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.bottomTilesAnim), 0.3, false)
        end
    end
end

function C:delayInvoke(time,callback)
    local act = transition.sequence({
		CCDelayTime:create(time),
		CCCallFunc:create(callback)
	})
    self:runAction(act)
end


--[[--
        停止计时器
  ]]
function C:stopSchedule()
    if self.scheduleHandler_ then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleHandler_)
        self.scheduleHandler_ = nil
    end
    if self.drawHandler_ then
        self:unschedule(self.drawHandler_)
        self.drawHandler_ = nil
    end
    self.isHunRec_ = false
end

--[[--
        退出函数
  ]]
function C:onExit()
    self:removeAllView()

    self.tiles_ = nil
    -- 自己的手牌
    self.moveTile_ = nil
    -- 当前移动的牌
    self.nCanTingTiles_ = nil
    -- 可听牌列表
    self.drawTile_ = nil
    -- 抓到的牌
    self.mBackTileRects_ = nil
    -- 显示牌的背面(即推倒后的牌)，二人胡牌，玩家胡牌后；或者听牌后
    self.mHuTile_ = nil
    -- 胡牌的牌

    self.listen_ = nil
    self.mahjongData_ = nil
    self.selfInfo_ = nil

    self.anGang_ = nil

    self.resultView_ = nil
    self.nCanTingTiles_ = {}

    self:stopSchedule()
end

--[[--
        播放发牌动画
        @param count:显示牌张数
  ]]
function C:drawBottomTilesAnim(count)
    local layer = self:getChildByTag(ADD_ID_ANIM)
    if not layer then
        local layer = ccui.Layout:create()
        layer:setTag(ADD_ID_ANIM)
        layer:setVisible(false)
        layer:addTo(self)
    end
    layer = self:getChildByTag(ADD_ID_ANIM)
    layer:removeAllChildren() -- 清除里面的图片(此处用于重新创建)
    if layer then

        -- 发牌动画的位置
        local x = self.handStartX_ 

        if count % 3 ~= 2 then
            x = x- self.padding_ - self.bigTileWidth_ - self.tileMargin + self.paddingCenter_
        end

        for i = count, 1, -1 do
            local tileView = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "tilebg/player_down.png" )
            tileView:setScale(1)
            tileView:setVisible(false)
            tileView:setAnchorPoint(cc.p(0, 0))
            layer:addChild(tileView, i * 2 - 1, i)
            tileView:setPosition(cc.p(x, self.bottom_))
            x = x - self.bigTileWidth_ - self.tileMargin
            if (count % 3 == 2 or self:getDrawTile() ~= nil) and i == count then
                -- 5张牌走此流程
                x = x - self.padding_
            end
        end
    end
end

--理牌动画
function C:bottomTilesAnim()
    local layer = self:getChildByTag(ADD_ID_ANIM)
    if layer and self.openDoorStepState_ <= STATE_OPENDOOR_STEP_2 then
        if self.openDoorStepState_ == STATE_OPENDOOR_STEP_1 then
            for i = 1, #self.tiles_, 1 do
                layer:setVisible(true)
                local view = layer:getChildByTag(i)
                if view then
                    self:getChildByTag(self.tiles_[i].id_):setVisible(false) --关闭牌张显示
                    view:setVisible(true) -->展示牌的背面
                end
            end
        elseif self.openDoorStepState_ == STATE_OPENDOOR_STEP_2 then
            layer:removeAllChildren()
            layer:setVisible(false)
            self:setOwnState(STATE_PLAY)
            self:addTileViews()
            self:drawTiles()
            --self:refreshTiles()
            self:setTouchEnabled(true)
            self:setOpenDoorEndFlag(true)

            self.parentView.core:c2sSendCardEnd()--向服务器发送开牌动画完成
        end
        self.openDoorStepState_ = self.openDoorStepState_ + 1
    else
        self:stopSchedule()
        self:setTouchEnabled(true)
        self:setOpenDoorEndFlag(true)
    end
end

--播放流光动画是，没门牌数目是否达标（>9）
--function C:isColorReach()
--    local ret = false
--    if self.colorCount_ and self.colorCount_[0] and self.colorCount_[0] > 9 then
--        ret = true
--    end
--    if not ret and self.colorCount_ and self.colorCount_[1] and self.colorCount_[1] > 9 then
--        ret = true
--    end
--    if not ret and self.colorCount_ and self.colorCount_[2] and self.colorCount_[2] > 9 then
--        ret = true
--    end
--    return ret
--end

--手牌排序
function C:sortTiles()
    table.sort(self.tiles_, function(a, b)
        if a.value_ == b.value_ then
            return a.id_ < b.id_
        else
            return a.value_ < b.value_
        end
    end)
end

--添加手牌图片到layer
function C:addTileViews()
    local x = self.handStartX_
    local count = #self.tiles_
    if count % 3 ~= 2 and not self:getDrawTile() then
        x = x - self.padding_ - self.bigTileWidth_ - self.tileMargin + self.paddingCenter_
    end
    --if self.nGroup_ > 0 then
    --    x = x - (self.dimens_:getDimens(18) + (self.nGroup_ - 1) * self.dimens_:getDimens(25))
    --end

    for i = count, 1, -1 do
        local tile = self.tiles_[i]
        local tileView = self:getChildByTag(tile.id_)

        if not tileView then
            tileView = tile:getTileImage(1, nil, self.bigTileWidth_, self.bigTileHeight_)
            tileView:setTouchEnabled(true)
            tileView:setAnchorPoint(cc.p(0, 0))
            tileView:addClickEventListener(handler(self, self.onClick))
            tileView:setVisible(false)

            tileView:setPosition(cc.p(x, self.bottom_))
            tile.tileX_ = x
            tile.tileY_ = self.bottom_
            x = x - self.bigTileWidth_ - self.tileMargin
            if (count % 3 == 2 or self:getDrawTile() ~= nil) and i == count then
                -- 5张牌走此流程
                x = x - self.padding_
            end
            tileView:setTag(tile.id_)
            self:addChild(tileView, i * 2 - 1)
        else
            tileView:setVisible(true)
        end
    end

    for i = count, 1, -1 do
        local tile = self.tiles_[i]
        if tile ~= nil then
            local tileView = self:getChildByTag(tile.id_)
            if count % 3 == 2 and self.mahjongData_.huFan < 1 and self.mahjongData_.tingInfo then
                -- 5张牌走此流程
                for n=1,#self.mahjongData_.tingInfo do
                    if  tile.value_ == self.mahjongData_.tingInfo[n].OutCardData then
                        tile:setTingSign(tileView, true)
                    end
                end
--                if not self.mIsCalled_ and self.mahjongData_ and not self.mahjongData_:isCanHu()
--                        and self:getTileCanTingFlag(tile)
--                        and (self.tingSignColor_ ~= tile.color_ or self.tingSignValue_ ~= tile.value_) then
--                    local compareTile = self.tiles_[count]
--                    if self:getDrawTile() then
--                        compareTile = self:getDrawTile()
--                    end
--                    if compareTile then
--                        if compareTile.id_ == tile.id_ or (compareTile.color_ ~= tile.color_
--                                or compareTile.value_ ~= tile.value_) then
--                            self.tingSignColor_ = tile.color_
--                            self.tingSignValue_ = tile.value_
--                            tile:setTingSign(tileView, true)
--                        end
--                    else
--                        self.tingSignColor_ = tile.color_
--                        self.tingSignValue_ = tile.value_
--                        tile:setTingSign(tileView, true)
--                    end
--                end
            else
                tile:setTingSign(tileView, false)
            end
        end
    end
    self.tingSignColor_ = nil
    self.tingSignValue_ = nil
end

--[[--
        显示手牌，并设置坐标
        @param notAnim:是否播放抓牌动画
  ]]
function C:drawTiles(notAnim)
    if not (self:getOwnState() >= STATE_SORT_ANIM) then
        return
    end
    local layer = self:getChildByTag(ADD_ID_ANIM)
    if layer then
        layer:setVisible(false)
    end
    if self.tiles_ then
        local count = #self.tiles_
        self.startX = self.handStartX_ + 0

        --if self.nGroup_ > 0 then
        --    self.startX = self.startX - (self.dimens_:getDimens(18) + (self.nGroup_ - 1) * self.dimens_:getDimens(25))
        --end

        -- 此处很坑
        if count % 3 ~= 2 and not self:getDrawTile() then
            -- 4张牌的时候
            self.startX = self.startX - self.padding_ - self.bigTileWidth_ - self.tileMargin + self.paddingCenter_
        end

        local x = self.startX

        --self.parentView:askHoldMsgForBit(self.parentView.HOLD_BIT_DRAW_TILE)
        for i = count, 1, -1 do
            self:drawSingleTile(x, self.tiles_[i], i, notAnim, (i == count))
            x = x - self.bigTileWidth_ - self.tileMargin
            if (count % 3 == 2 or self:getDrawTile() ~= nil) and i == count then
                -- 5张牌走此流程
                x = x - self.padding_
            end
        end
    end
end

--[[--
        添加单张牌显示
        @param x:x坐标
        @param tile:牌张
        @param i:牌张序列
        @param notAnim:是否播放抓牌动画
        @param isLast:是否是最后一张牌
  ]]
function C:drawSingleTile(x, tile, i, notAnim, isLast)
--    print("（（（（（（（（（（ lyttest 88888 ））））））））））")
--    print(tile.id_)
--    print(debug.traceback())
    local tileView = self:getChildByTag(tile.id_)
    if tileView then
        tileView:setVisible(true)
        local bottom = self.bottom_
        tile.upper_ = false

        local drawtile = self:getDrawTile()

        if self:getOpenDoorEndFlag() == true and not notAnim then
            if tile:getIsInHand() == false and drawtile == nil and i ~= #self.tiles_ then
                self:setTileMoveingFlag(true)
                local array = { }
                array[1] = CCMoveTo:create(0.1, cc.p(tile.tileX_, tile.tileY_ + self.bigTileHeight_)) -- 将牌先抬起
                array[2] = CCMoveTo:create(0.2, cc.p(x, bottom + self.bigTileHeight_)) --横向移动
                array[3] = CCMoveTo:create(0.2, cc.p(x, self.bottom_)) -- 落到底下
                array[4] = CCCallFunc:create(function()
                    self:draweff(tileView, tile, x, bottom)
                    tile:setIsInHand(true)
                    self:setTileMoveingFlag(false)
                end)
                tileView:runAction(CCSequence:create(array))
            elseif drawtile ~= nil and tile:getIsInHand() ~= true and drawtile.id_ == tile.id_ then
                if self.isBanker_ or (self.mahjongData_ and self.mahjongData_:getDrawAnimFlag()) then
                    --print(" drawSingleTile case 2")
                    tileView:setPosition(x, self.bottom_)
                    self:draweff(tileView, tile, x, self.bottom_, isLast)

                    self:setDiscardTileFlag(true)
                else
                    --print(" drawSingleTile case 3")
                    if self.mahjongData_ then
                        self.mahjongData_:setDrawAnimFlag(true)
                    end
                    tileView:setPosition(x, bottom + 40)
                    local array = { }
                    table.insert(array, CCMoveTo:create(0.15, ccp(x, self.bottom_)))
                    if self:isTingForDelay() then
                        table.insert(array,CCDelayTime:create(0.3))
                    else
                        table.insert(array,CCDelayTime:create(0.1))
                    end
                    table.insert(array,CCCallFunc:create(function()
                        --SoundManager:playEffect(MahjongDef.GAME_SFX.SOUND_TYPE_MAHJONG_SELECT)
                        self:draweff(tileView, tile, x, self.bottom_, isLast)
                        -- 抓的是花牌的话，则不允许出牌
                        if self.flowerid_ == nil then
                            self:setDiscardTileFlag(true)
                        end
                    end))
                    tileView:runAction(CCSequence:create(array))
                end
            else
                tile:setIsInHand(true)
                --print(" drawSingleTile case 4")

                if math.abs(tile.tileX_ - x) > self.bigTileWidth_ * 2 then
                    --print(" drawSingleTile case 4-1")
                    local array = { }
                    table.insert(array,CCMoveTo:create(0.1, cc.p(tile.tileX_, tile.tileY_ + self.bigTileHeight_)))
                    table.insert(array,CCMoveTo:create(0.2, cc.p(x, bottom + self.bigTileHeight_))) --横向移动
                    table.insert(array,CCMoveTo:create(0.2, cc.p(x, self.bottom_))) -- 落到底下
                    table.insert(array,CCCallFunc:create(function()
                        self:draweff(tileView, tile, x, self.bottom_, isLast)
                        if #self.tiles_ % 3 == 2 and i == #self.tiles_ then
                            --print(" drawSingleTile case 42")
                            tile:setIsInHand(false)
                        end
                    end))
                    tileView:runAction(CCSequence:create(array))
                else
                    --print(" drawSingleTile case 4-2")
                    local moveto = CCMoveTo:create(0.2, cc.p(x, self.bottom_))
                    tileView:runAction(CCSequence:create(moveto, CCCallFuncN:create(function()
                        self:draweff(tileView, tile, x, self.bottom_, isLast)
                        if #self.tiles_ % 3 == 2 and i == #self.tiles_ then
                            --print(" drawSingleTile case 42")
                            tile:setIsInHand(false)
                        end
                    end)))
                end
            end
        else
            tile:setIsInHand(true)
            --print(" drawSingleTile case 5")
            tileView:setPosition(x, self.bottom_)
            self:draweff(tileView, tile, x, self.bottom_, isLast)
        end
    end
end

--[[--
        添加牌放大view
        @param tileView:牌张view
        @param tile:牌张
        @param x:x坐标
        @param bottom:y坐标
        @param isLast:是否是最后一张牌
  ]]
function C:draweff(tileView, tile, x, bottom, isLast)
    tile.tileX_ = x
    tile.tileY_ = bottom
    tileView:setPosition(x, bottom)
    self:drawEffect(tile)
end

--[[--
        添加牌放大view
        @param tile:牌张
  ]]
function C:drawEffect(tile)
    local effectView = self:getChildByTag(tile.id_ + ADD_ID_EFFECT)
    local left = tile.tileX_ - (self.nTilePressEffectWidth_ - self.bigTileWidth_) / 2
    local top = tile.tileY_ + self.bigTileHeight_ + self.bottomOffset

    if not effectView then
        local tileTop = (self.nTilePressEffectHeight_ - self.bigTileHeight_) / 2 + 2.5
        local tileLeft = (self.nTilePressEffectWidth_ - self.bigTileWidth_) / 2 - 1

        local touchLayer = ccui.Layout:create()
        touchLayer:setContentSize(cc.size(self.nTilePressEffectWidth_,self.nTilePressEffectHeight_))
        touchLayer:setTag(tile.id_ + ADD_ID_EFFECT)
        touchLayer:setPosition(left, top)
        touchLayer:setVisible(false)
        self:addChild(touchLayer)

        local tileSelView = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .."play/mahjong_tile_press_effect.png")
        tileSelView:setAnchorPoint(cc.p(0, 0))
        tileSelView:setScale(1)
        tileSelView:setPosition(0, 0)
        touchLayer:addChild(tileSelView)

        local tileView = tile:getTileImage(1)
        tileView:setAnchorPoint(cc.p(0, 0))
        tileView:setPosition(tileLeft, tileTop)
        touchLayer:addChild(tileView)
    else
        effectView:setPosition(left, top)
    end
end

--听牌时蒙灰不能打的牌张
function C:drawCallTile()
    local count = #self.tiles_
    for i = count, 1, -1 do
        local tile = self.tiles_[i]
        local tileView = self:getChildByTag(tile.id_)
        local tileSelView = nil

        if tileView then
            --if self:getShowWinTiles() and not self:getTileCanTingFlag(tile) then
            if not self:getTileCanTingFlag(tile) then
                tileSelView = tileView:getChildByTag(IMG_TING_MASK_ID)
                if tileSelView then
                    -- 已经有了，不显示
                    print(" drawCallTile use old mask")
                else
                    print(" drawCallTile create mask tile.id_=", tile.id_)
                    tileSelView = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .."tile/mahjong_tile_undisable.png")
                    tileSelView:setAnchorPoint(cc.p(0, 0))
                    tileSelView:setScale(1)
                    tileSelView:setTag(IMG_TING_MASK_ID)
                    tileSelView:setPosition(0,0)
                    tileView:addChild(tileSelView, 500)
                end
                tileSelView:setVisible(true)
            end
        end
    end
    self.isDrawCall_ = true
end

--取消听牌时的蒙灰
function C:undoDrawCallTile()
    local count = #self.tiles_
    for i = count, 1, -1 do
        local tile = self.tiles_[i]
        local tileView = self:getChildByTag(tile.id_)
        local tileSelView = nil

        if tileView then
            tileSelView = tileView:getChildByTag(IMG_TING_MASK_ID)
            if tileSelView then
                tileSelView:setVisible(false)
            end
        end
    end
    self.isDrawCall_ = false
end

--听牌结束取消蒙灰显示
function C:cancelCall()
    self:removeAllChildren()
    self.isDrawCall_ = false
    -- 避免取消听后，最后一张牌会重新播一次抓牌动画
    self:setBankerFlag(true)
    self.fanShowCount_ = 0
    self:addTileViews()
    self:drawTiles()
end

--[[--
        添加结算时，胡的牌张
        @param tile:牌
  ]]
function C:addResultTile(tile)
    if tile ~= nil then
        if not self:findByTile(tile) then
            table.insert(self.tiles_, tile)
        else
            if self:getChildByTag(tile.id_) then
                self:getChildByTag(tile.id_):removeFromParent()
            end
        end
    end
end

--[[--
        添加结算时，手牌显示
        @param lastTile:手牌最后一张牌
        @param needReMargin:  true  : 位置需要重新调整
  ]]
function C:drawLastResultTile(lastTile, needReMargin, paoPos)
    local tile
    if lastTile then
        tile = lastTile
    else
        local count = #self.tiles_
        if count % 3 == 2 then
            -- 5张牌走此流程
            tile = self.tiles_[count]
        end
    end
    if tile and not self.resultView_ then
        local x = self.handStartX_
        if needReMargin then
            x = x - self.resultPadding_ + 63 + self.padding_
        end

        self.resultView_ = ccui.Layout:create()
        self.resultView_:setAnchorPoint(CCPoint(0, 0))
        self.resultView_:setPosition(x, self.bottom_)
        self.resultView_:setContentSize(63, 102)
        self:addChild(self.resultView_)

        local lastTileView = tile:getSmallTileImage(1)
        lastTileView:setPosition(0, 0)
        lastTileView:setTag(IMG_AWARD_MASK_ID)
        self.resultView_:addChild(lastTileView)

--        if lastTileView then
--            local resultTileMask = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .."tile/mahjong_tile_undisable.png")
--            resultTileMask:setAnchorPoint(cc.p(0, 0))
--            resultTileMask:setScale(0.8)
--            resultTileMask:setTag(IMG_AWARD_ITEM_ID)
--            resultTileMask.tile = tile --记录牌值
--            resultTileMask:setVisible(false)
--            lastTileView:addChild(resultTileMask)
--        end

        -- 添加胡牌箭头
--        if self.mahjongData_ then
--            local info = self.mahjongData_:getPlayerInfoBySeat(self.mahjongData_:getSelfSeat())
--            if info then
                --local paoPos = self.mahjongData_:getPositionBySeat(self.mahjongData_:getnPaoSeat())
                local rotate = 90
                local arrowImage = GAME_JSMJ_IMAGES_RES .."play/mahjong_play_handview_arrow.png"
                if paoPos == -1 then
                    arrowImage = GAME_JSMJ_IMAGES_RES .."play/mahjong_play_handview_zimo.png"
                    rotate = 0
                elseif paoPos == JsmjDefine.MahjongPos.POSITION_TOP then
                    rotate = -90
                elseif paoPos == JsmjDefine.MahjongPos.POSITION_LEFT then
                    rotate = 180
                elseif paoPos == JsmjDefine.MahjongPos.POSITION_RIGHT then
                    rotate = 0
                end
                local arrowImg = ccui.ImageView:create(arrowImage)
                arrowImg:setRotation(rotate)
                arrowImg:setAnchorPoint(cc.p(0.5, 0.5))
                arrowImg:setScale(1)
                arrowImg:setPosition(35, 23)
                self.resultView_:addChild(arrowImg)
            --end
--        end
    end
end

--[[--
        结算时，设置手牌坐标
        @param isShow:是否有推牌
        @param winFlag:是否推牌后，播放移动动画
  ]]
function C:setLastPoint(isShow, winFlag)
    local x = self.startX
    if isShow then
       -- local width = math.modf(63)
        x = self.handStartX_ - self.resultPadding_
    else
        x = self.handStartX_
        --if self.nGroup_ > 0 then
        --    x = x - (self.dimens_:getDimens(18) + (self.nGroup_ - 1) * self.dimens_:getDimens(25))
        --end
    end

    if self.resultView_ then
        --if winFlag and self.nGroup_ < 3 then
            local array = { }
            array[1] = CCMoveTo:create(0.2, cc.p(x, self.bottom_))
            self.resultView_:runAction(CCSequence:create(array))
        --else
        --    self.resultView_:setPositionX(x)
        --end
    end
end

--[[--
        添加结算手牌
        @param winFlag:是否推牌后，播放移动动画
        @param lastTile:最后一张牌
  ]]
function C:drawResultTile(winFlag, lastTile, paoPos)
    local width = math.modf(63)
    local count = #self.tiles_
    local x = self.handStartX_ 
--    if count % 3 ~= 2 then
--        x = x- self.padding_ - self.bigTileWidth_ - self.tileMargin + self.paddingCenter_
--    end
    x = x - self.resultPadding_
--    display.width - self.margin_ - 3.5 * width - self.padding_ + self.resultPadding_
    --if self.nGroup_ > 0 then
    --    x = x + (self.nGroup_ - 1) * self.dimens_:getDimens(20)
    --end
    self.drawTile_ = lastTile
    if not winFlag then
        self:soreTiles(true)
    end
    
    local layer = self:getChildByTag(ADD_ID_ANIM)
    if not layer then
        local layer = ccui.Layout:create()
        layer:setTag(ADD_ID_ANIM)
        self:addChild(layer)
    end
    layer = self:getChildByTag(ADD_ID_ANIM)
    layer:setVisible(true)

--    local fanTile
--    if self.mahjongData_ and self.mahjongData_:getAddFanTileId() > 0 then
--        fanTile = JsmjTile.new(self.mahjongData_:getAddFanTileId())
--    end
--    local signcount = 0
--    local handViewSignCount = 0
--    if self.parentView then
--        signcount = self.parentView.showFanLastCount_
--        handViewSignCount = self.parentView:getHandViewSignCount()
--    end
--    signcount = signcount - handViewSignCount
--    self.fanShowCount_ = 0

    for i = count, 1, -1 do
        local tile = self.tiles_[i]
        local tileView = self:getChildByTag(tile.id_)
        if tileView then
            tileView:setVisible(false)
            self:setPressView(tile, false)
        end

        local resultView
        if count % 3 == 2 then
            -- 5张牌走此流程
            if i == count then
                if not winFlag then
                    resultView = tile:getSmallTileImage(1)
                    local x1 = x + math.modf(72)
                    resultView:setPosition(x1, self.bottom_)
                    resultView:setTag(IMG_AWARD_MASK_ID + i)
                    layer:addChild(resultView)
                end
            else
                resultView = tile:getSmallTileImage(1)
                local x1 = x
                resultView:setPosition(x1, self.bottom_)
                resultView:setTag(IMG_AWARD_MASK_ID + i)
                layer:addChild(resultView)
                x = x - width
            end
        else
            resultView = tile:getSmallTileImage(1)
            resultView:setPosition(x, self.bottom_)
            resultView:setTag(IMG_AWARD_MASK_ID + i)
            layer:addChild(resultView)
            x = x - width
        end
--        if resultView then
--            local resultTileMask = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "tile/mahjong_tile_undisable.png")
--            resultTileMask:setAnchorPoint(cc.p(0, 0))
--            resultTileMask:setScale(0.8)
--            resultTileMask:setTag(IMG_AWARD_ITEM_ID)
--            resultTileMask:setVisible(false)
--            resultTileMask.tile = tile --记录牌值
--            resultView:addChild(resultTileMask)
--        end
    end

    if lastTile then
        self:drawLastResultTile(lastTile, true, paoPos)
    end
--    self:setLastPoint(true, winFlag)
end

--重置手牌状态
function C:resetTilesState()
    if self.tiles_ == nil then return end
    for i, tile in ipairs(self.tiles_) do
        if tile.upper_ then
            tile.upper_ = false
            local tileView = self:getChildByTag(tile.id_)
            if tileView then
                tileView:setPositionY(self.bottom_)
            end
        end
    end
    self:cleanSelect()
end

--[[--
        获取牌张位置
        @param id:牌张id
        @return index:牌张位置
  ]]
function C:getIndex(id)
    local index = -1
    for k, v in pairs(self.tiles_) do
        if id == v.id_ then
            index = k
            break
        end
    end
    return index
end

--[[--
        牌张点击事件处理
        @param target:点击view
  ]]
function C:onClick(target)
    if not self.canTouch then
        return
    end
    if target then
        local index = self:getIndex(target:getTag())
        local tile = self.tiles_[index]
        if tile then
--            if self:getShowWinTiles() then
--                local isTingTile = self:getTileCanTingFlag(tile)
--                if isTingTile then
--                    if tile.upper_ then
--                        if not self:OwnTailsetUpper(index, false) then
--                            tile.tileY_ = self.bottom_
--                        end
--                    else
--                        self:remargin()
--                        if self:OwnTailsetUpper(index, true) then
--                            tile.tileY_ = self.bottom_ + self.bottomOffset
--                        end
--                    end
--                    target:setPositionY(tile.tileY_)
--                end
--            else
                if self.mahjongData_:isMyTurn() and self.mahjongData_.huFan < 1 then
                    self:sendStateChange({ id = C.TYPE_DISCARD_TILE, tile = tile, index = index })
                end
--            end
        end
    end
end

--[[--
        牌张点击事件处理
        @param event:点击事件
        @param x:触摸x坐标
        @param y:触摸y坐标
        @return bRet:是否继续处理下一步事件
  ]]
--function C:onTouch(event, x, y)
--    if not self.canTouch then
--        return false
--    end
--    local bRet = false
--    local touchTileIndex = self:findInTouch(x, y)

--    if event == "began" then
--        self.beganTouchSign_ = true
--        -- 标记点击事件开始与结束
--        self.downIndex = touchTileIndex
--        self.moveIndex = touchTileIndex
--        self.isMoved = false
--        if self.downIndex == TILE_CLICK_STATE_HUN then
--            print("touchbegin case 1")
--            self.touchState = TOUCH_STATE_DOWN
--            self.nOwnTileTouchState_ = TOUCH_STATE_DISPLAY_HUN
--            self:sendStateChange({ id = C.TYPE_PRESS_HUN, isShow = true })
--        elseif self.downIndex ~= TILE_CLICK_STATE_DISABLE then
--            print("touchbegin case 2")
--            self.touchState = TOUCH_STATE_DOWN
--            if self.mahjongData_ then
--                if self.selfInfo_ == nil then
--                    self.selfInfo_ = self.mahjongData_:getPlayerInfoBySeat(self.mahjongData_:getSelfSeat())
--                end
--                if self.selfInfo_ and self.selfInfo_:getnCallType() > 0 then
--                    if self.mahjongData_:getGangAfterTing() == true and self.tiles_
--                            and #self.tiles_ == self.downIndex then
--                        print("touchbegin case 21")
--                        self:sendStateChange({ id = C.TYPE_PRESS_TING, isShow = false })
--                        self.nOwnTileTouchState_ = TOUCH_STATE_DOWN
--                        self.isShowTing = false
--                        self:OwnTailSetPress(self.downIndex, true)
--                    else
--                        print("touchbegin case 22")
--                        self.nOwnTileTouchState_ = TOUCH_STATE_DISPLAY_TING
--                        self.isShowTing = true
--                        self:sendStateChange({ id = C.TYPE_PRESS_TING, isShow = true })
--                    end
--                else
--                    print("touchbegin case 23")
--                    self.nOwnTileTouchState_ = TOUCH_STATE_DOWN
--                    self.isShowTing = false

--                    self:OwnTailSetPress(self.downIndex, true)
--                end
--                self.beganTime_ = JJTimeUtil:getCurrentServerTime()
--            end
--        end
--    elseif event == "ended" then
--        self.beganTouchSign_ = false
--        self.upIndex = touchTileIndex
--        if self.touchState == TOUCH_STATE_DOWN then
--            -- 单击
--            print("ended case 1")
--            self.touchState = TOUCH_STATE_NONE
--            if self.nOwnTileTouchState_ > TOUCH_STATE_NONE then
--                if self.nOwnTileTouchState_ == TOUCH_STATE_DOWN then
--                    print("ended case 2")
--                    local gap = (JJTimeUtil:getCurrentServerTime() - self.beganTime_) / 1000
--                    if gap > 0 and gap < CLICK_DELAY then
--                        self:delayInvoke((CLICK_DELAY - gap),handler(self, self.touchEventEnd))
--                        bRet = true
--                    else
--                        self.downIndex = TILE_CLICK_STATE_DISABLE
--                        self:cleanSelect()
--                        self.nOwnTileTouchState_ = TOUCH_STATE_NONE
--                    end
--                elseif self.nOwnTileTouchState_ == TOUCH_STATE_DISPLAY_TING then
--                    print("ended case 3")
--                    self:sendStateChange({ id = C.TYPE_PRESS_TING, isShow = false })
--                    self.downIndex = TILE_CLICK_STATE_DISABLE
--                    self:cleanSelect()
--                    self.nOwnTileTouchState_ = TOUCH_STATE_NONE
--                    bRet = true
--                elseif self.nOwnTileTouchState_ == TOUCH_STATE_DISPLAY_HUN then
--                    print("ended case 4")
--                    self:sendStateChange({ id = C.TYPE_PRESS_HUN, isShow = false })
--                    bRet = true
--                    self.downIndex = TILE_CLICK_STATE_DISABLE
--                    self:cleanSelect()
--                    self.nOwnTileTouchState_ = TOUCH_STATE_NONE
--                end
--                if self.isMoved then
--                    bRet = true
--                end
--            end
--        end
--    elseif event == "moved" then
--        if self.isDrawCall_ and touchTileIndex ~= self.downIndex then
--            if self.tiles_[self.downIndex] and self:getChildByTag(self.tiles_[self.downIndex].id_) then
--                self:getChildByTag(self.tiles_[self.downIndex].id_):setPositionY(self.bottom_)
--            end
--        else
--            if self.moveIndex ~= touchTileIndex and touchTileIndex ~= -1 then
--                self.isMoved = true
--                if self.moveIndex == TILE_CLICK_STATE_HUN then
--                    self:sendStateChange({ id = C.TYPE_PRESS_HUN, isShow = false })
--                elseif self.moveIndex ~= TILE_CLICK_STATE_DISABLE then
--                    if self.nOwnTileTouchState_ == TOUCH_STATE_DISPLAY_TING then
--                    else
--                        self:setPressView(self.tiles_[self.moveIndex], false)
--                    end
--                end
--                self.moveIndex = touchTileIndex

--                if self.moveIndex == TILE_CLICK_STATE_HUN then
--                    if self.nOwnTileTouchState_ == TOUCH_STATE_DISPLAY_TING then
--                        self:sendStateChange({ id = C.TYPE_PRESS_TING, isShow = false })
--                    end
--                    self.nOwnTileTouchState_ = TOUCH_STATE_DISPLAY_HUN
--                    self:sendStateChange({ id = C.TYPE_PRESS_HUN, isShow = true })
--                elseif self.moveIndex ~= TILE_CLICK_STATE_DISABLE then

--                    if self.nOwnTileTouchState_ == TOUCH_STATE_DISPLAY_TING then
--                    elseif self.nOwnTileTouchState_ == TOUCH_STATE_DOWN then
--                        self:OwnTailSetPress(self.moveIndex, true)
--                    elseif self.nOwnTileTouchState_ == TOUCH_STATE_DISPLAY_HUN then
--                        if self.isShowTing then
--                            self.nOwnTileTouchState_ = TOUCH_STATE_DISPLAY_TING
--                            self:sendStateChange({ id = C.TYPE_PRESS_TING, isShow = true })
--                        else
--                            if self.selfInfo_ and self.selfInfo_:getnCallType() > 0 then
--                                self.isShowTing = true
--                                self:sendStateChange({ id = C.TYPE_PRESS_TING, isShow = true })
--                            else
--                                self:OwnTailSetPress(self.moveIndex, true)
--                            end
--                        end
--                    end
--                end
--            end
--        end
--    elseif event == "cancelled" then
--    end
--    return bRet
--end

--触摸结束后事件处理
function C:touchEventEnd()
    if self.nOwnTileTouchState_ == TOUCH_STATE_DOWN then
        if self.upIndex ~= TILE_CLICK_STATE_DISABLE and self.upIndex ~= TILE_CLICK_STATE_HUN then
            if self.tiles_ and self.tiles_[self.upIndex] then
                self:OwnTailSetPress(self.upIndex, false)
                self:onClick(self:getChildByTag(self.tiles_[self.upIndex].id_))
            end
        end
        self.downIndex = TILE_CLICK_STATE_DISABLE
    end
    self:cleanSelect()
    self.nOwnTileTouchState_ = TOUCH_STATE_NONE
end

--[[--
        寻找触摸去区域view
        @param x:触摸x坐标
        @param y:触摸y坐标
        @return index:第几张牌
  ]]
function C:findInTouch(x, y)

    local index = TILE_CLICK_STATE_DISABLE
    local ry = y
    -- 牌张是否已经被抬起，即牌张对应位置区域已变化
    local isUpped = self.nOwnTileTouchState_ == TOUCH_STATE_DOWN and self.touchState == TOUCH_STATE_DOWN
    if y < self.bottom_ * 2 and not isUpped then
        -- 只有未抬起时需要减去边缘，防止点击下边缘部分不触发onInterceptTouchEvent中的"ended"事件
        ry = ry - 1.1 * self.bottomOffset
    end

    for i, tile in ipairs(self.tiles_) do
        local isTingTile = self:getTileCanTingFlag(tile)
        --local isHun = tile:isHun()
        local tileView = self:getChildByTag(tile.id_)
        if tileView and tileView:isTouchInside(x, ry) then
            if self:getShowWinTiles() and not isTingTile then
                index = TILE_CLICK_STATE_DISABLE
            else
                index = i
            end
            break
        end
    end
    return index
end

--[[--
        添加抓到的牌张
        @param tile:牌
        @param isDraw:是否播放抓牌动画
  ]]
function C:setDrawTile(tile, isDraw)
    self.drawTile_ = tile
    --local data = GameDataContainer:getGameData(self.matchId_)
    -- nil表示此时没有刚抓的牌
    if tile ~= nil then
        -- mahjongpublic
        if self.flowerid_ then
            for index, tileTmp in ipairs(self.tiles_) do
                if tileTmp.id_ == self.flowerid_ then
                    if self:getChildByTag(tileTmp.id_) then
                        self:getChildByTag(tileTmp.id_):removeFromParent()
                    end
                    if self:getChildByTag(tileTmp.id_ + ADD_ID_EFFECT) then
                        self:getChildByTag(tileTmp.id_ + ADD_ID_EFFECT):removeFromParent()
                    end
                    table.remove(self.tiles_, index)
                    break
                end
            end
        end
        --
        if isDraw then
            self:addDrawTile(tile) -->正常抓牌在此处
        else
            self:addTile(tile)
        end
        -- 检查手牌是否正常，不正常则刷新手牌
        local maxTileNum = self.mahjongData_:getMaxTileNumber()

        if #self.tiles_ % 3 ~= 2 or #self.tiles_ > (maxTileNum + 1) then

            if self.mahjongData_.myOutCard and self.mahjongData_:getTiles() then
                self:delAllTiles()
                local tiles = self.mahjongData_:getTiles()
                for k, v in ipairs(tiles) do
                    if v ~= nil then
                        local tile = JsmjTile.new(v.id_)
                        tile:setIsInHand(true)
                        table.insert(self.tiles_, tile)
                    end
                end
                self.drawTile_ = JsmjTile.new(self.mahjongData_.myOutCard)
                table.insert(self.tiles_, JsmjTile.new(self.mahjongData_.myOutCard))
                self:setDiscardTileFlag(true)
                self:refreshTiles(false)
            end
        end
    end
end

--获取抓到的牌张
function C:getDrawTile()
    return self.drawTile_
end

--手牌中是否存在该张牌
function C:setTileInHand(tileId)
    if tileId and tileId > -1 then
        for i = 1, #self.tiles_ do
            local tile = self.tiles_[i]
            if tile and tile.id_ == tileId then
                tile:setIsInHand(false)
                break
            end
        end
    end
end

--显示手牌
function C:showDrawTile()
    if self.isDrawTile_ then
        self.isDrawTile_ = false
        self:addTileViews()
        self:drawTiles()
    end
end

-- 添加一张手牌
function C:addTile(tile)
    if tile ~= nil then
        for k, v in pairs(self.tiles_) do
            print("addTile tile k= ", k, ",color=", v.color_, ",value=", v.value_, ", id=", v.id_)
        end
        if not self:findByTile(tile) then
            table.insert(self.tiles_, tile)
            self:remargin()
            self:addTileViews()
            self:drawTiles(false)
        end
    end
end

--添加手牌到view
function C:addDrawTile(tile)
    if tile ~= nil then
        if not self:findByTile(tile) then
            self.isDrawTile_ = true
            table.insert(self.tiles_, tile)
        end
    end
end

--[[--
        对手牌进行排序
        @param isResult:是否已经结束
  ]]
function C:soreTiles(isResult)
    if self.tiles_ and (self:getOwnState() >= STATE_SORT_ANIM or isResult) then
        local count = #self.tiles_
        if count < 2 then return end
        self:sortTiles()
        local drawTile = nil
--        local hunTiles = {}
        for i = 1, #self.tiles_ do
            local oTile = self.tiles_[i]
            if self.drawTile_ ~= nil and oTile.id_ == self.drawTile_.id_ then
                drawTile = oTile
            else
--                if self:isHun(oTile) == true then
--                    table.insert(hunTiles, oTile)
--                end
            end
        end

        for k, v in ipairs(self.tiles_) do
            if drawTile ~= nil and v.id_ == drawTile.id_ then
                table.remove(self.tiles_, k)
                break
            end
        end
--        for i = 1, #hunTiles do
--            for k, v in ipairs(self.tiles_) do
--                if v.id_ == hunTiles[i].id_ then
--                    table.remove(self.tiles_, k)
--                    break
--                end
--            end
--        end

--        for i = #hunTiles, 1, -1 do
--            table.insert(self.tiles_, 1, hunTiles[i])
--        end

        if drawTile ~= nil then
            table.insert(self.tiles_, drawTile)
        end
    end
end

--重置抬起牌张
function C:cleanUpper()
    for i = 1, #self.tiles_ do
        self:OwnTailsetUpper(i, false)
    end
end

--[[--
        抬起，按下牌张事件处理
        @param index:牌张位置
        @param isupper:是否抬起
  ]]
function C:OwnTailsetUpper(index, isupper)
    local tile = self.tiles_[index]
    local flag = false
    if tile ~= nil then
        --if self.bDiscardActionFlag_ and isupper then
        if isupper then
            tile.upper_ = true
            tile.tileY_ = self.bottom_ + self.bottomOffset
            --self:sendStateChange({ id = self.TYPE_PLAY_UPPER, tile = tile })
        else
            tile.upper_ = false
            tile.tileY_ = self.bottom_
            --self:sendStateChange({ id = self.TYPE_PLAY_UPPER })
        end
        flag = tile.upper_
    end
    local taget = self:getChildByTag(tile.id_)
    taget:setPositionY(tile.tileY_)
    return flag
end

--[[--
        触摸手牌时事件处理
        @param index:牌张位置
        @param ispress:是否触摸
  ]]
function C:OwnTailSetPress(index, ispress)
    local tile = self.tiles_[index]
    local count = #self.tiles_
    if tile ~= nil then
        -- 关闭这张牌的番数显示
        local tileView = self:getChildByTag(tile.id_)
        if tileView then
            local tileFanLabel = tileView:getChildByTag(TILE_FAN_NUM)
            if tileFanLabel then
                if ispress then
                    tileFanLabel:setVisible(false)
                else
                    tileFanLabel:setVisible(true)
                end
            end
        end

        if self.mahjongData_:getSelfTakeOutTile() == nil and not self.mahjongData_:isSelfGanging() then
            print(" OwnTailSetPress case 1 ")
            if ispress then
                print(" OwnTailSetPress case 13 ")
                self:setPressView(tile, true)
                self:sendStateChange({ id = self.TYPE_PLAY_PRESS, tile = tile })
            else
                self:setPressView(tile, false)
                print(" OwnTailSetPress case 14 ")
                self:sendStateChange({ id = self.TYPE_PLAY_PRESS })
            end
        end
    end
end

--[[--
        触摸手牌时事，显示放大view
        @param tile:触摸牌张
        @param flag:是否触摸
  ]]
function C:setPressView(tile, flag)
    if tile then
        if flag then
            if self:getChildByTag(tile.id_) then
                self:getChildByTag(tile.id_):setPositionY(self.bottom_ + self.bottomOffset)
            end
            if not self:getShowWinTiles() and self:getChildByTag(tile.id_ + ADD_ID_EFFECT) then
                self:getChildByTag(tile.id_ + ADD_ID_EFFECT):setVisible(true)
            end
        else
            if not self:getShowWinTiles() and self:getChildByTag(tile.id_) then
                self:getChildByTag(tile.id_):setPositionY(self.bottom_)
            end
            if self:getChildByTag(tile.id_ + ADD_ID_EFFECT) then
                self:getChildByTag(tile.id_ + ADD_ID_EFFECT):setVisible(false)
            end
        end
    end
end

--[[--
        获取玩家手牌
        @param tiles:手牌数据
        @param isBack:是否重绘
        @param firstTile:抓的牌
  ]]
function C:startGetTiles(tiles, isBack, firstTile)
    if tiles ~= nil then
        self.mahjongData_:removeAllTiles()
        self:delAllTiles()
        self:setVisible(true)
        for k, v in ipairs(tiles) do
            if v ~= nil then
                local tile = JsmjTile.new(v)
                if isBack then
                    -- 断线回来，则
                    tile:setIsInHand(true)
                end
                self.mahjongData_:addTile(tile)
                table.insert(self.tiles_, tile)
            end
        end
        if firstTile and not self:findByTile(firstTile) then
--            _debugInfo(" first tile id=", firstTile.id_)
            table.insert(self.tiles_, JsmjTile.new(firstTile.id_))
        end
--        self:setGroupCount()
        -- 更新吃碰杠了几手牌
        self:addTileViews()
        self.colorCount_ = nil
    end
end

--绘制手牌
function C:displayCard()
    --_debugInfo(" displayCard ")
    self:remargin()
    self:setOwnState(STATE_PLAY)
    self:setOpenDoorEndFlag(true)
    -- 断线回来
    self:refreshTiles(true)
end


--[[--
        获得选中的牌，以供点击出牌按钮等时适用
        @return tile:选择的牌
  ]]
function C:getDiscardTile()
    if self.tiles_ ~= nil then
        for k, v in ipairs(self.tiles_) do
            if v ~= nil and v.upper_ then
                return self.tiles_[k]
            end
        end
    end
    return nil
end

--[[--
        设置听牌时选择标记
        @param bTingFlag:听牌标记
  ]]
function C:getMoveTileIndex()
    local nIndex = -1
    for k, v in ipairs(self.tiles_) do
        if v ~= nil and v.upper_ then
            return k
        end
    end
    return nIndex
end

function C:setMoveTile(owntile)
    self.moveTile_ = owntile
end

--[[--
        设置听牌时选择标记
        @param bTingFlag:听牌标记
  ]]
function C:setShowWinTiles(bTingFlag)
    self.mIsShowWinTiles_ = bTingFlag
end

function C:getShowWinTiles()
    return self.mIsShowWinTiles_
end

--保存可以听牌的列表
function C:refreshCanTingTiles()
    self.nCanTingTiles_ = {}
    if self.mahjongData_.tingInfo == nil then
        return
    end
    for n=1,#self.mahjongData_.tingInfo do
        table.insert(self.nCanTingTiles_, JsmjTile.new(self.mahjongData_.tingInfo[n].OutCardData))
    end
end

--保存可以听牌的列表
function C:setCanTingTiles()
    self:refreshCanTingTiles()
    self:drawCallTile()
end

--[[--
        判断是否可以听牌
        @param owntile:选择牌
        @return flag:是否可听标记
  ]]
function C:getTileCanTingFlag(owntile)
    for k, v in pairs(self.nCanTingTiles_) do
        if v.value_ == owntile.value_ then
            return true
        end
    end
    return false
end

-- 重新设置每张牌的位置
function C:remargin()
    for k, tile in pairs(self.tiles_) do
        local tileView = self:getChildByTag(tile.id_)
        if tileView then
            tile.upper_ = false
            tile.tileY_ = self.bottom_
            tileView:setPositionY(self.bottom_)
        end
    end
end

--重置手牌抬起状态
function C:cleanSelect()
    for i = 1, #self.tiles_ do
        self:OwnTailSetPress(i, false)
    end
end

--[[--
        听牌时判断是否显示听牌标记
        @return isShow:是否允许显示听标记
  ]]
function C:isShowTingSign()
    local isShow = true
    local ownTileCount = 0
    local tempId = -1
    for k, t in pairs(self.tiles_) do
        if t then
            if bit.rshift(tempId, 4) ~= bit.rshift(t.id_, 4) then
                ownTileCount = ownTileCount + 1
            end
            tempId = t.id_
        end
    end
    if self.nCanTingTiles_ and ownTileCount == #self.nCanTingTiles_ then
        isShow = false
    end
    return isShow
end

-- 听牌时需要处理的动作
function C:tingSignSelect()

    self:refreshCanTingTiles()
    -- 标记更新查听内容
    self.tingRefresh_ = true

    local count = #self.tiles_
    for i = count, 1, -1 do
        local tile = self.tiles_[i]
        if tile ~= nil then
            local tileView = self:getChildByTag(tile.id_)
            if not self:getShowWinTiles() and tileView then
                tileView:setPositionY(self.bottom_)
            end
            if self:getChildByTag(tile.id_ + ADD_ID_EFFECT) then
                self:getChildByTag(tile.id_ + ADD_ID_EFFECT):setVisible(false)
            end
            if not self.mIsCalled_ and #self.tiles_ % 3 == 2 and self.mahjongData_.huFan < 1 and self:getTileCanTingFlag(tile)
                    and (self.tingSignColor_ ~= tile.color_ or self.tingSignValue_ ~= tile.value_) then
                local compareTile = self.tiles_[#self.tiles_]
                if self.drawTile_ then
                    compareTile = self.drawTile_
                end
                if compareTile then
                    if compareTile.id_ == tile.id_ or (compareTile.color_ ~= tile.color_
                            or compareTile.value_ ~= tile.value_) then
                        self.tingSignColor_ = tile.color_
                        self.tingSignValue_ = tile.value_
                        tile:setTingSign(tileView, true)
                    end
                else
                    self.tingSignColor_ = tile.color_
                    self.tingSignValue_ = tile.value_
                    tile:setTingSign(tileView, true)
                end
            else
                tile:setTingSign(tileView, false)
            end
        end
    end
    self.tingSignColor_ = nil
    self.tingSignValue_ = nil
end

--[[--
        设置是否多人胡牌
        @param isTwoWin:是否多人胡牌
  ]]
function C:setTwoWin(isTwoWin)
    self.mIsTwoWin_ = isTwoWin
    self:setTouchEnabled(not isTwoWin)
end

--[[--
        设置监听
        @param listen:监听函数
  ]]
function C:setOwnTileViewListen(listen)
    self.listen_ = listen
end

--发送事件
function C:sendStateChange(event)
    if self.listen_ then
        self.listen_(event)
    end
end

--设置手牌view为打牌状态
function C:setViewPlayState()
    self:setOwnState(STATE_PLAY)
end

function C:startDeal(tick, list)
    self:setOwnState(STATE_WAIT_DEAL)
    self:setTouchEnabled(false)
end

--[[--
        获取吃碰杠时，相关手牌数据
        @param tileIds:吃碰杠牌列表
        @param id:吃碰杠的牌
        @return productTiles:吃碰杠牌数据
  ]]
function C:getProduct(tileIds, id)
    local productTiles = {}
    for k, v in pairs(tileIds) do
        if v and v ~= id then
            for kk, vv in pairs(self.tiles_) do
                if v == vv.id_ then
                    local t = JsmjTile.new(v)
                    t.mode_ = MahjongDef.MODE_BIG
                    t.tileX_ = vv.tileX_
                    t.tileY_ = vv.tileY_
                    table.insert(productTiles, t)
                    break
                end
            end
        end
    end
    return productTiles
end

--[[--
        获取最后一张坐标
        @return ccp:坐标
  ]]
function C:getLastShowLocation()
    local x = self.handStartX_
    --if self.nGroup_ > 0 then
    --    x = x - (self.dimens_:getDimens(18) + (self.nGroup_ - 1) * self.dimens_:getDimens(25))
    --end
    return ccp(x, self.bottom_)
end

--[[--
        是否可以出牌
        @return canFlag:可出牌标记
  ]]
function C:canDiscardTile()
    local ret = false
    if self.canDiscardFlag_ and #self.tiles_ % 3 == 2 then
        ret = true
    end
    return ret
end

--[[--
        设置是否可以出牌
        @param flag:可出牌标记
  ]]
function C:setDiscardTileFlag(flag)
    self.canDiscardFlag_ = flag
end

--[[--
        设置是否是庄家
        @param flag:是否是庄家标记
  ]]
function C:setBankerFlag(flag)
    self.isBanker_ = flag
end

--[[--
    播放手牌流光动画
    yanlz：二麻9期自测优化：[4．去掉发牌后流光效果]
    @param isRepeat:是否是第二次播放
]]
function C:playChampionAnim(isRepeat)

    local count = #self.tiles_
    if count > 0 then
        local touchWidth = self.bigTileWidth_ * count
        if count % 3 == 2 then
            -- 5张牌走此流程
            touchWidth = touchWidth + self.padding_
        end
        local animLayer = ccui.Layout:create()
        animLayer:setAnchorPoint(cc.p(0, 0))
        animLayer:setPosition(self.tiles_[1].tileX_, 40)
        animLayer:setViewSize(touchWidth, 103)
        self:addChild(animLayer, 101, ADD_ID_ANIM + 2)
        animLayer:setEnableScissor(true)

        local championBg = CCSprite:create(GAME_JSMJ_IMAGES_RES .. "tile/tile_champion_table_bg.png")
        animLayer:getNode():addChild(championBg)
        championBg:setAnchorPoint(cc.p(0, 0))
        championBg:setPosition(cc.p(0, 0))
        championBg:setScale(1)
        local array =  { }
        array[1] = CCMoveTo:create(1, cc.p(touchWidth, 0))

        local function CallFucnCallback()
            animLayer:getNode():removeChild(championBg)
            self:removeChild(animLayer)

            if not isRepeat then
                self:playChampionAnim(true) --yanlz：二麻9期：去掉发牌后流光效果
            end
        end

        array[2] = CCCallFuncN:create(CallFucnCallback)
        local action = CCSequence:create(array)
        championBg:runAction(action)
    end
end

--[[--
        加番牌时需要处理的动作
        @param count:加番牌个数
        @param id:加番牌id
        @param isPlaySound:是否播放声音
]]
function C:jiaFanSignSelect(count, id, isPlaySound)
    self.fanShowCount_ = 0
    local handViewSignCount = 0
    if self.parentView then
        handViewSignCount = self.parentView:getHandViewSignCount()
    end
    count = count - handViewSignCount
    local time = 0
    -- 有多张加番牌时也只播一次音效
    local playOnce = false
    if self.mahjongData_ and self.mahjongData_:getAddFanTileId() > 0 then
        local fanTile = JsmjTile.new(self.mahjongData_:getAddFanTileId())
        for i = 1, #self.tiles_ do
            local tile = self.tiles_[i]
            if tile ~= nil then
                if fanTile.color_ == tile.color_ and fanTile.value_ == tile.value_ and count > self.fanShowCount_ then
                    if isPlaySound then
                        self.fanShowCount_ = self.fanShowCount_ + 1
                        -- time = time + 0.2
                        time = 0.2
                        -- 开局后，手中加番牌角标一起出现
                        playOnce = true
                        self:i(handler(self, function()
                            if tile and self:getChildByTag(tile.id_) then
                                tile:setJiaFanSign(self:getChildByTag(tile.id_), true)
                            end
                        end), time)
                    else
                        self.fanShowCount_ = self.fanShowCount_ + 1
                        tile:setJiaFanSign(self:getChildByTag(tile.id_), true)
                    end
                else
                    if tile and self:getChildByTag(tile.id_) then
                        tile:setJiaFanSign(self:getChildByTag(tile.id_), false)
                    end
                end
            end
        end
    end

    if isPlaySound and playOnce then
        SoundManager:playEffect(MahjongDef.GAME_SFX.SOUND_TYPE_MAHJONG_APPEAR_JIAFAN)
    end
end

--[[--
        托管前出牌
]]
function C:DiscardTileBeforeTrust()
    print(" DiscardTileBeforeTrust ")
    if self.tiles_ and self.tiles_[#self.tiles_] then
        self:onClick(self:getChildByTag(self.tiles_[#self.tiles_].id_))
    end
end

--[[--
        听牌后出牌延迟
]]
function C:isTingForDelay()
--    if self.mahjongData_ and self.mahjongData_:getSelfSeat() then
--        local me = self.mahjongData_:getPlayerInfoBySeat(self.mahjongData_:getSelfSeat())
--        if me and me:getnCallType() and me:getnCallType() > 0 then
--            return true
--        end
--    end
    return false
end

--[[--
    设置开门结束标志
]]
function C:setOpenDoorEndFlag(flag)
    self.bOpendoorEnd_ = flag
end

function C:getOpenDoorEndFlag()
    return self.bOpendoorEnd_
end

--[[ 标识牌正在移动
     @param flag: true or false 是否在移动中
 ]]
function C:setTileMoveingFlag(flag)
    self.isTileMoveAnim_ = flag
end

function C:getTileMoveingFlag()
    print("getTileMoveAnim() flag= ", self.isTileMoveAnim_)
    return self.isTileMoveAnim_
end

--[[ 标识牌已经放倒
     @param flag: true or false 是否在移动中
 ]]
function C:setFallState(status)
    print("setFallState status=", status)
    self.fallState_ = status
end

function C:getFallState()
    print("getFallState self.fallState_=", self.fallState_)
    return self.fallState_
end

--[[--
        检查是否重奖花
        @param tile: 牌张
  ]]
function C:checkIsHitFlower(tile)
    local ret = false
    local awardTiles = self.mahjongData_:getAwardFlowerAllTiles() -- 所有的奖花
    local hitTiles = self.mahjongData_:getAwardFlowerHitTiles()
    if hitTiles and #hitTiles > 0 then
        if self.mahjongData_:getWinSeat() == self.mahjongData_:getSelfSeat() then
            -- 如果自己赢了
            if tile then
                for i, hitTiles in pairs(hitTiles) do
                    if hitTiles.color_ == tile.color_ and hitTiles.value_ == tile.value_ then
                        ret = true
                    end
                end
            end
        end
    end
    return ret
end

--打开或关闭所有牌的蒙板
function C:drawTileFrontMask(show)
    local count = #self.tiles_
    local layer = self:getChildByTag(ADD_ID_ANIM)
    if layer then
        -- 最大5张牌
        for i = 1, 5 do
            local resultView = layer:getChildByTag(IMG_AWARD_MASK_ID + i)
            if resultView then
                local imgMask = resultView:getChildByTag(IMG_AWARD_ITEM_ID)
                if imgMask then
                    local tile = imgMask.tile
                    if show then
                        imgMask:setVisible(true) --否则打开
                    else
                        imgMask:setVisible(show)
                    end
                end
            end
        end
        if self.resultView_ then
            -- 计算最后一张牌
            local lastTileView = self.resultView_:getChildByTag(IMG_AWARD_MASK_ID)
            if lastTileView then
                local imgMask = lastTileView:getChildByTag(IMG_AWARD_ITEM_ID)
                if imgMask then
                    local tile = imgMask.tile
                    if show then
                        imgMask:setVisible(true) --否则打开
                    else
                        imgMask:setVisible(show)
                    end
                end
            end
        end
    end
end

--[[--
        重奖花的牌关闭蒙板
        @param show: 关闭或打开
  ]]
function C:drawFlowerHitTile(tile)
    if not tile then
        return
    end
    local count = #self.tiles_
    local layer = self:getChildByTag(ADD_ID_ANIM)
    if layer then
        -- 最大5张牌
        for i = 1, 5 do
            local resultView = layer:getChildByTag(IMG_AWARD_MASK_ID + i)
            if resultView then
                local imgMask = resultView:getChildByTag(IMG_AWARD_ITEM_ID)
                if imgMask then
                    local tileOwn = imgMask.tile
                    print(" OKOOK 1 mask = true id=", tile.id_)
                    if tileOwn.value_ == tile.value_ then
                        imgMask:setVisible(false) -- 关闭蒙板
                    end
                end
            end
        end
        if self.resultView_ then
            -- 计算最后一张牌
            local lastTileView = self.resultView_:getChildByTag(IMG_AWARD_MASK_ID)
            if lastTileView then
                local imgMask = lastTileView:getChildByTag(IMG_AWARD_ITEM_ID)
                if imgMask then
                    local tileOwn = imgMask.tile

                    if tileOwn.value_ == tile.value_ then
                        imgMask:setVisible(false) -- 关闭蒙板
                    end
                end
            end
        end
    end
end

--[[ 原来的标志位增加接口
 　　@param flag: true or false
     @return none
]]
function C:setOwnState(state)
    print(" setOwnState state=", state)
    self.ownstate_ = state
end

function C:getOwnState()
    print(" getOwnState state=", self.ownstate_)
    return self.ownstate_
end

--[[ 用于记录发牌阶段已经亮牌的张数
     @param num: 已经亮牌的张数
     @return none
-- ]]
function C:setHadShowNum(num)
    print(" setHadShowNum num=", num)
    self.dealHadShowNum_ = num
end

function C:getHadShowNum()
    return self.dealHadShowNum_
end

return C