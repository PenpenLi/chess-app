
local C = class("JsmjTile")
local bit = require("bit")

local TILE_BG_ID = 999
local TILE_ID = 1000
local TINGSIGN_ID = 1001
local JIAFANSIGN_ID = 1002

local tilesResArr_normal = {
    {
        "mahjong_tile_big_wan_1", "mahjong_tile_big_wan_2", "mahjong_tile_big_wan_3",
        "mahjong_tile_big_wan_4", "mahjong_tile_big_wan_5", "mahjong_tile_big_wan_6",
        "mahjong_tile_big_wan_7", "mahjong_tile_big_wan_8", "mahjong_tile_big_wan_9"
    },
    { "mahjong_tile_big_zi_zhong", "mahjong_tile_big_zi_fa", "mahjong_tile_big_zi_baiban" }
}

local tilesResArr_small = {
    {
        "mahjong_tile_small_wan_1", "mahjong_tile_small_wan_2", "mahjong_tile_small_wan_3",
        "mahjong_tile_small_wan_4", "mahjong_tile_small_wan_5", "mahjong_tile_small_wan_6",
        "mahjong_tile_small_wan_7", "mahjong_tile_small_wan_8", "mahjong_tile_small_wan_9"
    },
    { "mahjong_tile_small_zi_zhong", "mahjong_tile_small_zi_fa", "mahjong_tile_small_zi_baiban" }
}

--[[--
        构造函数
        @param id:牌张id
        @param value:牌张各花色下值，如果value有值，id则表示花色
  ]]
function C:ctor(id)
    self.id_ = id
    --self.value_ = value
    --self.value_ = bit.band(id,0x00FF)
    if id ~= nil and id ~= 0 then
        self.value_ = bit.band(id,0x00FF)
    else
        self.value_ = id
    end
--    print("（（（（（（（（（（ lyttest 111111 ））））））））））")
--    print(self.id_, self.value_)
--    print(debug.traceback())

    self.index_ = 0
    -- 加番标记
    self.bgMode_ = 0

    self.upper_ = false
    self.selected_ = false

    self.tileX_ = 0
    self.tileY_ = 0

    self.isInHand_ = false

    -- 牌的宽度
    self.tileWidth_ = 80
    -- 牌的高度
    self.tileHeight_ = 116
    self.canTouch = true
end

--[[--
        获取牌面图片
        @return img:图片路径
  ]]
function C:getAboveImg()
    local name  = ""
    if self.value_ >= 0x31 and self.value_ <= 0x33 then
        name = tilesResArr_normal[2][self.value_-0x30] or ""
    else
        name = tilesResArr_normal[1][self.value_] or ""
    end
    local img = GAME_JSMJ_IMAGES_RES .. "tile/" .. name .. ".png"
--    print("（（（（（（（（（（ lyttest 66666 ））））））））））")
--    print(self.value_, img)
--    print(debug.traceback())
    return img
end

--[[--
        获取牌张图片

        @param scale:缩放大小
        @param ccpoint:坐标
        @param tingSignX:听标记x坐标
        @param tingSignY:听标记y坐标

        @return view:牌张图片
  ]]
  function C:getTileImage(scale, ccpoint, tingSignX, tingSignY, bgOpacity, opacity)
    local view = ccui.Layout:create()
    local bgImg = GAME_JSMJ_IMAGES_RES .. "tile/tile_bg.png"
    local bgScale = scale
    local tileScale = scale
    local tileImg
    local tingSignImg_, jiaFanImg_
    local name

    local img = self:getAboveImg()
    local tileImg = display.newSprite(img)
    --tileImg:setTouchEnabled(false)
    tileImg:setTag(TILE_ID)
    if ccpoint then
        tileImg:setAnchorPoint(ccpoint)
    else
        tileImg:setAnchorPoint(cc.p(0, 0))
    end

    bgImg = GAME_JSMJ_IMAGES_RES .. "tile/tile_bg.png"
    tileImg:setAnchorPoint(cc.p(-0.01, -0.06))
    if tingSignX and tingSignY and tileScale then
        tingSignImg_ = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "tile/mahjong_ting_sign.png" )
        tingSignImg_:setTag(TINGSIGN_ID)
        tingSignImg_:setScale(bgScale)
        tingSignImg_:setAnchorPoint(cc.p(1, 1.8))
        tingSignImg_:setVisible(false)
        tingSignImg_:setPosition(tingSignX, tingSignY)
    end

    if tileScale then
        tileImg:setScale(tileScale)
    end
    if opacity then
        tileImg:setOpacity(opacity)
    end

    local bg = ccui.ImageView:create(bgImg)
    bg:setTag(TILE_BG_ID)
    if ccpoint then
        bg:setAnchorPoint(ccpoint)
    else
        bg:setAnchorPoint(cc.p(0, 0))
    end
    if bgScale then
        bg:setScale(bgScale)
    end
    if bgOpacity then
        bg:setOpacity(bgOpacity)
    end
    --view:setClippingEnabled (true)
    --view:setBackGroundColor(cc.c3b(100, 0,0),cc.c3b(100, 0,0))
    view:setContentSize(cc.size(bg:getContentSize().width, bg:getContentSize().height))
    bg:setPosition(cc.p(0,0))
    tileImg:setPosition(cc.p(0,0))
    view:addChild(bg)
    view:addChild(tileImg)
    if tingSignX and tingSignY and tingSignImg_ then
        view:addChild(tingSignImg_)
    end

    return view
end

--[[--
        是否显示听标记
        @param view:牌张view
        @param isShow:是否显示
  ]]
function C:setTingSign(view, isShow)
    self.isSign_ = isShow
    if view and view.getChildByTag and view:getChildByTag(TINGSIGN_ID) then
        view:getChildByTag(TINGSIGN_ID):setVisible(isShow)
    end
end

-- mode 0默认，1相同，2相邻
function C:changeBg(view, mode)
    if type(mode) == "number" and self.bgMode_ ~= mode and view and view.getViewById
            and view:getChildByTag(TILE_BG_ID) then
        self.bgMode_ = mode
--        if self.mode_ == MahjongDef.MODE_SMALL_BOTTOM or self.mode_ == MahjongDef.MODE_SMALL_TOP then
--            if mode == 1 then
--                view:getChildByTag(TILE_BG_ID):setImage(GAME_JSMJ_IMAGES_RES .. "tile/tile_font_bg_same.png")
--            elseif mode == 2 then
--                view:getChildByTag(TILE_BG_ID):setImage(GAME_JSMJ_IMAGES_RES .. "tile/tile_font_bg_near.png")
--            else
--                view:getChildByTag(TILE_BG_ID):setImage(GAME_JSMJ_IMAGES_RES .. "tile/tile_font_bg.png")
--            end
--        end
    end
end

--[[--
        获取小牌张图片
        @param scale:缩放大小
        @return view:牌张图片
  ]]
function C:getSmallTileImage(scale)
    local view = ccui.Layout:create()
    local bgScale = scale
    local tileScale = scale * 0.76
    local bgImg = "tile/tile_font_bg.png"
    local name = tilesResArr_normal[self.color_ + 1] and tilesResArr_normal[self.color_ + 1][self.value_ + 1] or ""
    local img = "tile/" .. name .. ".png"
    local tileImg = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. img)
    tileImg:setScale(tileScale)
    tileImg:setAnchorPoint(cc.p(-0.03, -0.28))

    local jiaFanImg_ = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "/tile/mahjong_jiafan_sign.png")
    jiaFanImg_:setTag(JIAFANSIGN_ID)
    jiaFanImg_:setScale(scale * 0.6)
    jiaFanImg_:setAnchorPoint(cc.p(0, -2.7))
    jiaFanImg_:setVisible(false)

    local bg = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. bgImg)
    bg:setAnchorPoint(cc.p(0, 0))
    bg:setScale(bgScale)
    view:addChild(bg)
    view:addChild(tileImg)
    view:addChild(jiaFanImg_)

    return view
end

--[[--
        获取大牌张图片
        @param ccp:坐标
        @return view:牌张图片
  ]]
function C:getBigTile(ccp)
    local view = ccui.Layout:create()
    local bgImg = GAME_JSMJ_IMAGES_RES .. "tile/tile_bg.png"
    local name = tilesResArr_normal[self.color_ + 1]
            and tilesResArr_normal[self.color_ + 1][self.value_ + 1] or ""
    local img = GAME_JSMJ_IMAGES_RES .. "tile/" .. name .. ".png"
    local tileImg = display.newSprite(img)
    tileImg:setAnchorPoint(cc.p(0.5, -0.1))
    local bg = ccui.ImageView:create(bgImg)
    bg:setAnchorPoint(cc.p(0.5, 0))
    view:addChild(bg)
    view:addChild(tileImg)

    return view
end

--[[--
        比较牌张大小
        @param other:牌张
        @return none
  ]]
function C:compareTo(other)
    local ret = self.id_ - other.id_
    ret = ((ret > 0) and true) or false
    return ret
end

--[[--
        比较牌张
        @param other:牌
        @return ret:是否是相同
  ]]
function C:equals(other)
    local ret = (self == other)
    if not ret then
        ret = ((self.color_ == other.color_) and (self.value_ == other.value_))
    end
    return ret
end

--[[--
        打印函数
  ]]
function C:toString()

    local t = {}
    table.insert(t, "    Tile[id=0x")
    table.insert(t, bit.tohex(self.id_))
    table.insert(t, ",color_:")
    table.insert(t, tostring(self.color_))
    table.insert(t, ",value_:")
    table.insert(t, tostring(self.value_))
    table.insert(t, ",index_:")
    table.insert(t, tostring(self.index_))
    local str = ""
    if self.color_ <= MahjongDef.TILE_COLOR_BING then
        if self.color_ == MahjongDef.TILE_COLOR_WAN then
            str = "Wan"
        elseif self.color_ == MahjongDef.TILE_COLOR_TIAO then
            str = "Tiao"
        elseif self.color_ == MahjongDef.TILE_COLOR_BING then
            str = "Bing"
        end
    elseif self.color_ == MahjongDef.TILE_COLOR_WIND then --3
        if self.value_ == 0 then
            str = "DongF"
        elseif self.value_ == 1 then
            str = "NanF"
        elseif self.value_ == 2 then
            str = "XiF"
        elseif self.value_ == 3 then
            str = "BeiF"
        end
    elseif self.color_ == MahjongDef.TILE_COLOR_JIAN then --4
        if self.value_ == 0 then
            str = "Zhong"
        elseif self.value_ == 1 then
            str = "Fa"
        elseif self.value_ == 2 then
            str = "Bai"
        end
    elseif self.color_ == MahjongDef.TILE_COLOR_FLOWER then
        if self.value_ == 0 then
            str = "Mei"
        elseif self.value_ == 1 then
            str = "Lan"
        elseif self.value_ == 2 then
            str = "Zhu"
        elseif self.value_ == 3 then
            str = "Ju"
        end
    elseif self.color_ == MahjongDef.TILE_COLOR_SEASON then

        if self.value_ == 0 then
            str = "Chun"
        elseif self.value_ == 1 then
            str = "Xia"
        elseif self.value_ == 2 then
            str = "Qiu"
        elseif self.value_ == 3 then
            str = "Dong"
        end
    else
        str = "Erro Color：" .. tostring(self.color_)
    end

    if self.color_ < MahjongDef.TILE_COLOR_WIND then
        table.insert(t, "]\"")
        table.insert(t, tostring(self.value_ + 1))
        table.insert(t, "\"")
    else
        table.insert(t, "]")
    end
    table.insert(t, str)
    table.insert(t, "]")
    return table.concat(t)
end

--[[--
        获取奖花牌张图片

        @param scale:缩放大小
        @param ccpoint:坐标
        @param tingSignX:听标记x坐标
        @param tingSignY:听标记y坐标

        @return view:牌张图片
  ]]
function C:getAwardFlowerTileImage(scale, ccpoint, tingSignX, tingSignY, bgOpacity, opacity)
    local view = ccui.Layout:create()
    local bgImg = GAME_JSMJ_IMAGES_RES .. "tile/tile_bg.png"
    local bgScale = scale
    local tileScale = scale
    local tileImg
    local tingSignImg_, jiaFanImg_
    local name = nil

    local img = self:getAboveImg()
--    name = tilesResArr_normal[self.color_ + 1] and tilesResArr_normal[self.color_ + 1][self.value_ + 1] or ""
--    local img = GAME_JSMJ_IMAGES_RES .. "tile/" .. name .. ".png"

    local tileImg = ccui.ImageView:create(img)
    tileImg:setTag(TILE_ID)

    --if self.mode_ == MahjongDef.MODE_BIG then
        bgImg = GAME_JSMJ_IMAGES_RES .. "tile/tile_bg.png"
        --tileImg:setAnchorPoint(CCPoint(-0.01, -0.06))
        tileImg:setPosition(self.tileWidth_ / 2, self.tileHeight_ / 2)
    --end

    local bg = ccui.ImageView:create(bgImg)
    bg:setTag(TILE_BG_ID)
    bg:setPosition(self.tileWidth_ / 2, self.tileHeight_ / 2)

    view:addChild(bg)
    view:addChild(tileImg)

    return view
end

--[[--
    设置手牌是否在手中
    @param inhand: 是否在手中  true or false
    @return none
]]
function C:setIsInHand(inhand)
    self.isInHand_ = inhand
end

function C:getIsInHand()
    return self.isInHand_
end

--function Tile:setTouchEnabled(enable)
--	self.canTouch = enable;
--end

return C