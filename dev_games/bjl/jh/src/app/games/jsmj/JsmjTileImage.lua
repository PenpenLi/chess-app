--[[--
        界面: 牌张view
  ]]
local C = class("JsmjTileImage", cc.Node)
local JsmjDefine = import("app.games.jsmj.JsmjDefine")
local bit = require("bit")

local tilesResArr_normal = {
    {
        "mahjong_tile_big_wan_1", "mahjong_tile_big_wan_2", "mahjong_tile_big_wan_3",
        "mahjong_tile_big_wan_4", "mahjong_tile_big_wan_5", "mahjong_tile_big_wan_6",
        "mahjong_tile_big_wan_7", "mahjong_tile_big_wan_8", "mahjong_tile_big_wan_9"
    },
    { "mahjong_tile_big_zi_zhong", "mahjong_tile_big_zi_fa", "mahjong_tile_big_zi_baiban" }
}
-- 类型 tileValue
-- 区域  原始为1下 2右 3上 4左 ~~ 11下牌桌 12右牌桌 13上牌桌 14左牌桌
-- 区域中的位置 0无透视 >0有透视
-- 状态  0正常 1正面朝上 2正面朝下
--[[--
        构造函数
        @param tileId:牌张id
        @param area:显示区域
        @param pos:牌张的位置
        @param state:显示状态
  ]]
function C:ctor(tileId, area, pos, state, maxTileNum)
    --self.type = _tileId2Type(tileId)
    if tileId ~= nil and tileId ~= 0 then
        self.value_ = bit.band(tileId,0x00FF)
    else
        self.value_ = tileId
    end
--    print("（（（（（（（（（（ lyttest 22222 ））））））））））")
--    print(tileId, self.value_)
--    print(debug.traceback())
   
    --self.value_ = tileId
    self.area_ = area
    self.tilePos_ = pos
    self.state_ = state
    self.maxTileNumber_ = maxTileNum
    self.tileSize_ = nil

    self.front_ = nil
    -- 面图t
    self.rear_ = nil
    self.jiafan_ = nil
    -- 底图
--    if self.type == nil then
--        printError(JsmjTileImage, "ctor error,tileId:", tileId)
--        return
--    end
    self:setAnchorPoint(ccp(0.5, 0))
    self:createMahjong()
    self:setContentSize(self.tileSize_)
--    self:setCascadeOpacityEnabled(true)
--    self:setCascadeColorEnabled(true)
end

--[[--
        创建麻将牌显示
  ]]
function C:createMahjong()
    -- 下
    if self.area_ == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        self:createPlayerMahjong()
    -- 上
    elseif self.area_ == JsmjDefine.MahjongPos.POSITION_TOP then
        self:createUpMahjong()
        -- 右
--    elseif self.area_ == MahjongDef.POSITION_RIGHT then
--        self:createLeftMahjong()
--        -- 左
--    elseif self.area_ == MahjongDef.POSITION_LEFT then
--        self:createRightMahjong()
    elseif self.area_ == JsmjDefine.MahjongPos.POSITION_DISCARD_TOP then
        self:createDeskDownMahjong()
    elseif self.area_ == JsmjDefine.MahjongPos.POSITION_DISCARD_BOTTOM then
        self:createDeskDownMahjong()

--    elseif self.area_ == MahjongDef.POSITION_DISCARD_RIGHT then
--        self:createDeskRightMahjong()
--    elseif self.area_ == MahjongDef.POSITION_DISCARD_LEFT then
--        self:createDeskLeftMahjong()
    end
end

function C:getAboveImg()
    local name  = ""
    if self.value_ >= 0x31 and self.value_ <= 0x33 then
        name = tilesResArr_normal[2][self.value_-0x30] or ""
    else
        name = tilesResArr_normal[1][self.value_] or ""
    end
    local img = GAME_JSMJ_IMAGES_RES .. "tile/" .. name .. ".png"
    return img
end
--[[--
        创建玩家手牌
  ]]
function C:createPlayerMahjong()
    if self.state_ == JsmjDefine.MahjongPos.TILE_SHOW_STATE_STAND then --手牌
        self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/player.png"):addTo(self)
        self.front_ = display.newSprite(self:getAboveImg()):addTo(self)
        self.tileSize_ = self.rear_:getContentSize()
        self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
        self.front_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2 - 3))
    elseif self.state_ == JsmjDefine.MahjongPos.TILE_SHOW_STATE_FACE then --打出去的牌
        self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/player_up.png"):addTo(self)
        self.front_ = display.newSprite( self:getAboveImg()):addTo(self)
        self.tileSize_ = self.rear_:getContentSize()
        self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
        self.front_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2 + 18))
    else --拍堆里的牌
--        print("（（（（（（（（（（ lyttest 44444 ））））））））））")
--        print(debug.traceback())
        self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/player_down.png"):addTo(self)
        self.tileSize_ = self.rear_:getContentSize()
        self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
    end
end

--[[--
        获取牌张倾斜参数
        @param pos:牌张的位置
        @return skew,offset:倾斜参数
  ]]
function C:getUpMahjongSkew(pos)
    local skew = 0
    local offset = 0

    if pos == 1 then
        -- 从右边数，第１个 , 以下类推, offset 值越大,牌正面越向左移
        skew = 12
        offset = 4
    elseif pos == 2 then
        -- 从右边数，第2个 , 以下类推, offset 值越大,牌正面越向左移
        skew = 12
        offset = 4
    elseif pos == 3 then
        skew = 11
        offset = 3
    elseif pos == 4 then
        skew = 9
        offset = 3
    elseif pos == 5 then
        skew = 7
        offset = 2
    elseif pos == 6 then
        skew = 6
        offset = 1
    elseif pos == 7 then
        skew = 2
        offset = 0
    end
    return { skew, offset }
end

--[[--
        创建对家手牌
  ]]
function C:createUpMahjong()
    local jumpTile = 4 -- 跳过4张牌，用于实现对家牌张的方位显示
    --if self.maxTileNumber_ == MahjongDef.TILE_NUMBER_7 then
    --    jumpTile = 4
    --end
    --_debugInfo("createUpMahjong jumpTile=", jumpTile)
    if self.state_ == JsmjDefine.MahjongPos.TILE_SHOW_STATE_STAND then --手牌
        self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_player.png"):addTo(self)
        self.tileSize_ = self.rear_:getContentSize()
        self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
    elseif self.state_ == JsmjDefine.MahjongPos.TILE_SHOW_STATE_FACE then --打出去的牌

        local pos = self.tilePos_ + jumpTile
        local skew = 0
        local offset = 0
        if pos == 0 then
            pos = 7
        end
        --_debugInfo(" createUpMahjong face 1 pos=", pos)
        local jiafanPos = pos
        if pos > 7 then
            pos = 8 - (pos - 7)
            if self.tilePos_ >= 14 then
                pos = 1
            end

            self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up" .. pos .. ".png"):addTo(self)
            self.rear_:setScaleX(-1)
            -- mask
            self.mark = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_mask_" .. pos .. ".png"):addTo(self.rear_)
            self.mark:setAnchorPoint(cc.p(0, 0))
            self.mark:setVisible(false)

            -- 加番
            if jiafanPos < 15 then
                self.jiafan_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_jiafan_" .. jiafanPos .. ".png"):addTo(self.rear_)
                self.jiafan_:setAnchorPoint(cc.p(0, 0))
                self.jiafan_:setVisible(false)
            end
            --
            local temp = self:getUpMahjongSkew(pos)
            skew = temp[1]
            offset = temp[2] --> 调整此处，影响牌正面的显示
        else    
            self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up" .. pos .. ".png"):addTo(self)
            -- mask
            self.mark = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_mask_" .. pos .. ".png"):addTo(self.rear_)
            self.mark:setAnchorPoint(cc.p(0, 0))
            self.mark:setVisible(false)

            -- 加番
            self.jiafan_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_jiafan_" .. jiafanPos .. ".png"):addTo(self.rear_)
            self.jiafan_:setAnchorPoint(cc.p(0, 0))
            self.jiafan_:setVisible(false)
            --
            local temp = self:getUpMahjongSkew(pos)
            skew = -temp[1]
            offset = -temp[2]
        end
        self.front_ = display.newSprite( self:getAboveImg()):addTo(self)
        self.tileSize_ = self.rear_:getContentSize()
        self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
        self.front_:setPosition(cc.p(self.tileSize_.width / 2 + offset, self.tileSize_.height / 2 + 7))

        self.front_:setScale(0.28)
        self.front_:setScaleX(0.37)
        self.front_:setSkewX(skew)
    else --牌堆里的牌
        local pos = self.tilePos_ + jumpTile
        --_debugInfo(" createUpMahjong rear case 3 pos=", pos)
        if pos == 0 then pos = 7 end
        if pos > 7 then
            pos = 8 - (pos - 7)
            if self.tilePos_ >= 14 then
                pos = 1
            end

            self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_down" .. pos .. ".png"):addTo(self)
            self.rear_:setScaleX(-1)
        else
            self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/up_down" .. pos .. ".png"):addTo(self)
        end

        self.tileSize_ = self.rear_:getContentSize()
        self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
    end
end

--[[--
        获取桌面倾斜参数
        @param pos:玩家位置
        @return skew,offset:倾斜参数
  ]]
function C:getDeskDownSkew(pos)
    local skew = 0
    local offset = 0

    if pos == 1 then
        skew = 14
        offset = 7
    elseif pos == 2 then
        skew = 11
        offset = 5
    elseif pos == 3 then
        skew = 7
        offset = 4
    elseif pos == 4 then
        skew = 5
        offset = 2
    end

    return { skew, offset }
end

--[[--
        创建自家牌池中牌张
  ]]
function C:createDeskDownMahjong()
    local pos = self.tilePos_
    local skew = 0
    local offset = 0

    if pos > 5 then
        pos = 6 - (pos - 5)
        if self.tilePos_ >= 10 then pos = 1 end

        self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/down" .. pos .. ".png"):addTo(self)
        self.mark = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/down_mark_" .. pos .. ".png"):addTo(self.rear_)
        self.rear_:setScaleX(-1)
        local temp = self:getDeskDownSkew(pos)
        skew = -temp[1]
        offset = -temp[2]
    else
        self.rear_ = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/down" .. pos .. ".png"):addTo(self)
        self.mark = display.newSprite(GAME_JSMJ_IMAGES_RES .. "tilebg/down_mark_" .. pos .. ".png"):addTo(self.rear_)
        local temp = self:getDeskDownSkew(pos)
        skew = temp[1]
        offset = temp[2]
    end
    self.mark:setAnchorPoint(ccp(0, 0))
    self.mark:setVisible(false)
    self.front_ = display.newSprite(self:getAboveImg()):addTo(self)
    self.tileSize_ = self.rear_:getContentSize()
    self.rear_:setPosition(cc.p(self.tileSize_.width / 2, self.tileSize_.height / 2))
    self.front_:setPosition(cc.p(self.tileSize_.width / 2 + offset, self.tileSize_.height / 2 + 11))

    self.front_:setScale(0.49)
    self.front_:setScaleX(0.58)
    self.front_:setSkewX(skew)
end

--[[--
        显示加番
  ]]
function C:showJiaFan(flag)
    if self.jiafan_ then
        if flag == true then
            self.jiafan_:setVisible(true)
        else
            self.jiafan_:setVisible(false)
        end
    end
end

--[[--
        获取牌的大小
  ]]
function C:getTileSize()
    return self.tileSize_
end
return C