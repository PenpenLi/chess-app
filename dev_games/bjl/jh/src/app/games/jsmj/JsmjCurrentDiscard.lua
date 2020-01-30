--[[--
    界面: 上方玩家(对家)打出的牌(放大的那张牌)
]]
local C = class("JsmjCurrentDiscard", cc.Node)
local JsmjDefine = import(".JsmjDefine")

--构造函数
function C:ctor(parent)
    self.dimens_ = parent.dimens_
    self.theme_ = parent.theme_
    self.tile_ = nil
    self.with_ = math.modf(self.dimens_:getDimens(109))
    self.height_ = math.modf(self.dimens_:getDimens(138))
    self.tileWidth_ = math.modf(self.dimens_:getDimens(89))
    self.tileHeight_ = math.modf(self.dimens_:getDimens(130))
    self.tileLeft_ = 0
    self.tileTop_ = 0
    self.top_ = 0
    self.left_ = 0
end

--设置显示的牌，并刷新显示
function C:setTile(tile)
    self.tile_ = tile
    self:refresh()
end

--设置显示位置
function C:setPos(pos)
    self.pos_ = pos

    local nTop = 0
    local nLeft = 0

    if self.pos_ == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        nTop = self.dimens_.height / 2 + (self.dimens_.height / 2 - self.height_ * 2) / 2
        nLeft = (self.dimens_.width - self.with_) / 2
    elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
        nTop = self.dimens_:getDimens(640)
        nLeft = (self.dimens_.width - self.with_) / 2 + self.dimens_:getDimens(3)
    elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_LEFT then
        nTop = self.dimens_:getDimens(550)
        nLeft = self.dimens_:getDimens(190)
    elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_RIGHT then
        nTop = self.dimens_:getDimens(550)
        nLeft = self.dimens_.right - self.dimens_:getDimens(299)
    end
    -- 校正坐标
    self.top_ = nTop
    self.left_ = nLeft
    self.tileLeft_ = self.left_ + (self.with_ - self.tileWidth_) / 2 - math.modf(self.dimens_:getDimens(0.18))
    self.tileTop_ = self.top_ - (self.height_ - self.tileHeight_) / 2 - math.modf(self.dimens_:getDimens(3)) - self.tileHeight_
end

--刷新显示
function C:refresh()
    self:removeAllChildren()
    if self.tile_ then
        self.tile_.mode_ = 1 --fixme:lyt define
        
        local t = self.tile_:getTileImage(self.dimens_.scale_)
        t:setPosition(display.width/2, self.tileTop_)
        t:setAnchorPoint(cc.p(0.5, 0.5))
        local img = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "discard/mahjong_discard_tile_bg.png")
        if img then
            img:setScale(self.dimens_.scale_)
            img:setPosition(display.width/2, self.tileTop_)
            img:setAnchorPoint(cc.p(0.5, 0.5))
            img:setLocalZOrder(0)
            self:addChild(img)
        end
        self:addChild(t)
    end
end

return C