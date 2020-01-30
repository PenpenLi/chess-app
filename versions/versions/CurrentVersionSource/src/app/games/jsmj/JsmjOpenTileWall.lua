--[[--
        界面: 发牌动画牌墙
        生命周期: 动画开始到结束
        成员函数:

        * _getAngangImg: 获取牌背图片
        必要重载:
            * 无
  ]]
local C = class("JsmjOpenTileWall", cc.Node)
local JsmjDefine = import(".JsmjDefine")

local TOP_BEGINE_X1 = 404
local TOP_BEGINE_Y1 = 474
local BOTTOM_BEGINE_X1 = 351
local BOTTOM_BEGINE_Y1 = 194

--[[
      获取牌背图片资源路径
      @param pos 位置
      @param index 牌张索引

      @return anGangImg 图片资源
]]
function _getAngangImg(pos, index)
    local rotate = 0
    local img = "openanim/open_tile_left.png"
    if pos == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        img = "openanim/open_tile_bottom.png"
    elseif pos == JsmjDefine.MahjongPos.POSITION_TOP then
        img = "openanim/open_tile_bottom.png"
    end
    local anGangImg = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. img)
    anGangImg:setAnchorPoint(cc.p(0, 0))
    anGangImg:setRotation(rotate)
    return anGangImg
end

--[[--
        构造函数

        @param parent:上一级界面
        @param pos:玩家座位
        @param isTp:区分是否是极速麻将

        @return none
  ]]
function C:ctor(parent, pos, isTP)
    self.parentView_ = parent
    self.locations_ = {}
    self.flyToRemaindNumTimes_ = {}
    self.pos_ = pos
    self.currentNum_ = 0
    self.maxTileNum_ = 14
    self.isTP_ = isTP
    self.moveTileListener_ = nil

    BOTTOM_BEGINE_X1 = self.parentView_.nodeCardBegin1:getPositionX()
    BOTTOM_BEGINE_Y1 = self.parentView_.nodeCardBegin1:getPositionY()
    TOP_BEGINE_X1 = self.parentView_.nodeCardBegin2:getPositionX()
    TOP_BEGINE_Y1 = self.parentView_.nodeCardBegin2:getPositionY()

    self:initPosition()
    self:drawTiles()
end

--[[--
        初始化界面坐标
  ]]
function C:initPosition()
    if self.pos_ == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        self.maxTileNum_ = 14 --据新需求调整牌墙
        self.currentNum_ = self.maxTileNum_*2
        self:initBottom()
    elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
        self.maxTileNum_ = 14 --据新需求调整牌墙
        self.currentNum_ = self.maxTileNum_*2
        self:initTop()
    end
end

--创建牌墙
function C:drawTiles()
    for i = 1, self.maxTileNum_ * 2 do
        self:drawTile(i)
    end
end

--[[--
        播放所有牌张飞行动画
        @param index:牌张位置
        @param isSingle:是否单张
        @param isSencond:是否是下一墩牌
        @param left:最后移动到的x坐标
        @param top:最后移动到的y坐标
  ]]
function C:moveTiles(index, isSingle, isSencond, left, top)
    printInfo("moveTiles in,index:", index, ",isSingle:", isSingle)
    if isSingle then
        self:moveTile(index, left, top, true)
    else
        for i = 0, 1 do
            local tileViewId = index + self.maxTileNum_ * (1 - i)
            self:moveTile(tileViewId, left, top, (isSencond and i == 1))
        end
    end
end

--[[--
        播放单张牌飞行动画
        @param index:牌张位置
        @param left:最后移动到的x坐标
        @param top:最后移动到的y坐标
        @param isEnd:是否结束
  ]]
function C:moveTile(index, left, top, isEnd)
    print("moveTile in,index:", index, ",left:", left, ",top:", top)
    local tileImgs
    if self.parentView_ then
        tileImgs = self.parentView_:getOpenWallTileImg(self.pos_)
    end
    if tileImgs then
        local tileView = tileImgs[index]
        local function _animEnd()
            if tileView then
                --print("~~~~~~".. tileView:getPositionX() .. " " ..tileView:getPositionY())
                tileView:setVisible(false)
            end
            if isEnd and self.moveTileListener_ then
                self.moveTileListener_()
            end
        end

        if tileView then
            local array = {}
            array[1] = CCMoveTo:create(0.2, cc.p(left, top))--fixme:lyt test time
            array[2] = CCCallFuncN:create(_animEnd)
            local action = CCSequence:create(array)
            --local node = tileView:getNode()
            --if action and node then
                tileView:setLocalZOrder(720)
                tileView:runAction(action)
            --end
        end
    end
end

--[[--
        添加牌墙
        @param location:坐标参数
  ]]
function C:drawTile(location)
   -- print("drawTile in,location:", location)
    if self.locations_ then
        local posInfo = self.locations_[location]
        local tileImg = _getAngangImg(self.pos_, location)
        if tileImg and posInfo then
            tileImg:setPosition(cc.p(posInfo.x, posInfo.y))
            tileImg:setScale(posInfo.scale)
            tileImg:setLocalZOrder(posInfo.z)
            if self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
                tileImg:setScaleY(0.66)
            end
            self.parentView_:addOpenWallImg(self.pos_, tileImg)
        end
    end
end

--初始化自家方向坐标
function C:initBottom()
    local tileWidth, tileHeight, tileThick, tileFace, tileFaceWidth = 47, 33, 9, 36, 32
    for j = 1, 2 do
        local left, top = BOTTOM_BEGINE_X1, BOTTOM_BEGINE_Y1 + (j - 1) * tileThick
        local right = BOTTOM_BEGINE_X1 + tileFaceWidth
        for i = 1, self.maxTileNum_ do
            local z = 720 - (2 - j) * self.maxTileNum_ - i
            table.insert(self.locations_, { x = left, y = top, z = z, scale = 1 })
            top = math.floor(top)
            left = left + tileFaceWidth
        end
    end
end

-- 初始化对家坐标
function C:initTop()
    local tileWidth, tileHeight, tileThick, tileFace, tileFaceWidth = 47, 33, 9, 36, 32
    local scale = 0.78
    tileFaceWidth = tileFaceWidth * scale
    for j = 1, 2 do
        local left, top = TOP_BEGINE_X1, TOP_BEGINE_Y1 + (j - 1) * tileThick * scale
        for i = 1, self.maxTileNum_ do
            local z = 720 - (2 - j) * self.maxTileNum_ - i
            table.insert(self.locations_, { x = left, y = top, z = z, scale = scale })
            top = math.floor(top)
            left = math.floor(left + tileFaceWidth)
        end
    end
end

--获取最大牌张
function C:getMaxTileNum()
    return self.maxTileNum_
end

--退出函数
function C:onExit()
    self.locations_ = nil
end

--动画结束，移除所有view
function C:removeAllTiles()
    if self.parentView_ then
        self.parentView_:removeAllOpenWallTileImg(self.pos_)
    end
end

return C