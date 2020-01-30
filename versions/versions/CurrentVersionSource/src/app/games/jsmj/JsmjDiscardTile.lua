--[[--
    界面: play界面牌池,玩家和对家出过的牌张
]]
local C = class("JsmjDiscardTile", cc.Node)
local JsmjDefine = import(".JsmjDefine")
local JsmjTile = import(".JsmjTile")
local JsmjTileImage = import(".JsmjTileImage")

local nFirstLineNum_ = 9 -- 第一行显示多少张
local nSecondLineNum_ = 9 -- 第二行显示多少张
local nThirdLineNum_ = 9 -- 第三行显示多少张

local MAX_TILE_NUM = nFirstLineNum_ + nSecondLineNum_ + nThirdLineNum_ --

--[[--
    构造函数
    @param parent
    @param pos:玩家座位
    @param isTp:区分是否是极速麻将
]]
function C:ctor(parent, pos, isTp)
    self.parentView_ = parent
    self.nPos_ = pos
    self.discardPos_ = nil
    self.picMode_ = 1 --fixme:lyt define
    self.selectedTile_ = nil
    -- 当前选中的牌：需要根据这张牌来设置相邻牌的显示颜色 Tile
    self.doubleTiles_ = nil
    -- 导致加倍的牌列表 List<Tile>
    self.tiles_ = nil
    -- List<Tile>

    self.doubleMarkWidth_ = 15
    self.doubleMarkMarginTop = -2
    self.doubleMarkMarginRight = 2
    self.tileThick_ = 5
    self.localtions_ = {}
    self.isTp_ = isTp
    self.callTileId_ = 0
    self.callMarkRotation_ = 0
    self:initPosition()
end

--初始化界面view坐标
function C:initPosition()
    if self.nPos_ == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        self.discardPos_ = JsmjDefine.MahjongPos.POSITION_DISCARD_BOTTOM
    elseif self.nPos_ == JsmjDefine.MahjongPos.POSITION_TOP then
        self.discardPos_ = JsmjDefine.MahjongPos.POSITION_DISCARD_TOP
    elseif self.nPos_ == JsmjDefine.MahjongPos.POSITION_LEFT then
        self.callMarkRotation_ = 90
        self.discardPos_ = JsmjDefine.MahjongPos.POSITION_DISCARD_LEFT
    elseif self.nPos_ == JsmjDefine.MahjongPos.POSITION_RIGHT then
        self.callMarkRotation_ = -90
        self.discardPos_ = JsmjDefine.MahjongPos.POSITION_DISCARD_RIGHT
    end
    if self.parentView_ then
        for i = 1, MAX_TILE_NUM do
            local showInfo = self.parentView_:getDiscardTileShowInfo(self.discardPos_, i)
            if showInfo then
                table.insert(self.localtions_, showInfo)
            end
        end
    end
end

--[[--
    标记牌池中与选中牌张相同的牌
    @param t:点中牌张
]]
function C:setSelectedTile(t)
    self.selectedTile_ = t
    if self.tiles_ then
        for k, t in pairs(self.tiles_) do
            if self.selectedTile_ and t.color_ == self.selectedTile_.color_
                    and t.value_ == self.selectedTile_.value_ then
                self:setMarkVisible(k, true)
            else
                self:setMarkVisible(k, false)
            end
        end
    end
end

--[[--
    牌张标记显隐
    @param tileIndex:牌张位置
    @param flag:是否标记
]]
function C:setMarkVisible(tileIndex, flag)
    local handImgs
    if self.parentView_ then
        handImgs = self.parentView_:getDiscardTileImg(self.nPos_)
    end
    if handImgs then
        local tileView = handImgs[tileIndex]
        if tileView then
            if flag then
                tileView:setColor(ccc3(168, 249, 160))
            else
                tileView:setColor(display.COLOR_WHITE)
            end
        end
    end
end

--[[--
    设置牌池显示牌张
    @param tiles:显示牌张集合
]]
function C:setTiles(tiles)
    self.tiles_ = tiles
    -- if self.tiles_==nil then
    --     self.tiles_={}
    -- end
    -- table.insert(self.tiles_,tiles)
end

--[[--
    设置牌池加倍牌张
    @param tileIndex:加倍牌张集合
]]
function C:setDoubleTiles(tiles)
    self.doubleTiles_ = tiles
end

--[[--
    添加具体牌张到view显示
    @param tile:显示牌张
    @param state:显示状态
    @param location:位置索引
]]
function C:drawTile(tile, state, location, drawFlag, finalLocation, isHand, arrowDirection)
    local tileState = state
    if tileState == nil then
        tileState = 1 --fixme:lyt face
    end
    local tileId = nil
    if tile then
        tileId = tile.id_
    end
    if self.localtions_ and self.parentView_ then
        local showInfo = self.localtions_[location]
        if showInfo then
            --添加保护，避免两张一样的牌同时出现在牌池中
            if self.parentView_ then
                local handImgs = self.parentView_:getDiscardTileImg(self.nPos_)
                if handImgs then
                    local lastImg = handImgs[#handImgs]
                    if lastImg and lastImg.getImgTileId then
                        if lastImg:getImgTileId() == tileId then
                            return
                        end
                    end
                end
            end
            local img = JsmjTileImage.new(tileId,self.discardPos_, showInfo.tileIndex, tileState, 5)
            if img and showInfo and showInfo.scale and showInfo.z and showInfo.x and showInfo.y then
                self.parentView_:addDiscardTileImg(self.nPos_, img)
                img:setScale(showInfo.scale)
                img:setLocalZOrder(showInfo.z)
                img:setPosition(showInfo.x, showInfo.y)

                -- 画听牌标志
                self:addCallMark(img, tileId)
            end
        else
        end
    end
end

--重置函数
function C:reset()
    self.tiles_ = nil
    self.doubleTiles_ = nil
    self.callTileId_ = nil
    self.selectedTile_ = nil
    self:removeTiles()
end

--退出函数
function C:onExit()
    self.tiles_ = nil
    self.doubleTiles_ = nil
    self.localtions_ = nil
    self.callTileId_ = nil
    self.discardPos_ = nil
end

--刷新界面，重绘牌池界面
function C:refresh()
    self:removeTiles()
    if self.tiles_ then
        local tileNum = #self.tiles_
        for i = 1, tileNum do
            local t = self.tiles_[i]
            self:drawTile(t, nil, i)
        end
    end
end

--获取下一张牌的显示坐标
function C:getNextPoint()
    local showInfo = nil
    if self.localtions_ then
        --dump(self.tiles_,"tiles_")
        if self.tiles_ then
            local tileNum = #self.tiles_
            printInfo(">>>>>>>>>获取下一张牌的显示坐标>>>>>>>>>"..tileNum)
            showInfo = self.localtions_[tileNum]
        else
            showInfo = self.localtions_[1]
        end
    end
    return showInfo
end

--[[--
    设置听牌时的位置
    @param tileId: 听牌时打出牌张id
]]
function C:setCallTileId(tileId)
    self.callTileId_ = tileId
end

--[[--
    设置听牌标记
    @param img: 听牌view
    @param tileId: 听牌时打出牌张id
]]
function C:addCallMark(img, tileId)
    if not img or not tileId or not self.callTileId_ then
        return
    end
    if self.callTileId_ == tileId then
        local callMarkImg = display.newSprite(GAME_JSMJ_IMAGES_RES .. "play/mahjong_play_call_tile_mark.png")
        if callMarkImg and img.size.width and img.size.height then
            callMarkImg:setAnchorPoint(cc.p(0.5, 0.5))
            if self.nPos_ == MahjongDef.POSITION_BOTTOM then
                local left = img.size.width / 2
                local top = 3 * img.size.height / 8
                local scale = 1.2
                callMarkImg:setPosition(cc.p(left, top))
                callMarkImg:setScale(scale)
            else
                local left = img.size.width / 2
                local top = 5 * img.size.height / 12
                local scale = 1.2
                callMarkImg:setPosition(cc.p(left, top))
                callMarkImg:setScale(scale)
            end
            img:addChild(callMarkImg)
        end
    end
end

--移除所有牌张显示
function C:removeTiles()
    if self.parentView_ then
        self.parentView_:removeAllDiscardTileImg(self.nPos_)
    end
end

return C