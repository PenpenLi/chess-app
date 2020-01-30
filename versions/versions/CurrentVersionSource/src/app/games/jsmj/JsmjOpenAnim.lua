--[[--
        界面: play界面开牌动画
        生命周期: 开牌动画
  ]]
local C = class("JsmjOpenAnim", cc.Node)

local JsmjOpenTileWall = import(".JsmjOpenTileWall")
local JsmjDefine = import(".JsmjDefine")


local DEAL_STATE_ONE = 0 -- 4张组合发牌的个数
local DEAL_STATE_TWO = 8 -- 单个发的个数

local DISPATCH_COUNT = {4,4,1}

local FIGURE_POS_0 = 100

--[[--
        构造函数
        @param parent:上一级界面
        @param md:数据
  ]]
function C:ctor(parent)
    self.parentView_ = parent

    self.startIndex = 0

    self.onFigureAnimEndListener_ = nil
    self.onOpenDoorOverListener_ = nil
    self.onAddTilesListener_ = nil
    self.headNode_ = nil
    self.dealTileCount_ = 1
    self.figureAnimCount_ = 0
    self.isTopTile_ = true
    self.flyIndex_ = 0
    self.flyWallPos_ = 0
    self.currentIndex_ = -1
    -- 当前发牌的序号
    self.playerCount_ = 2
    -- fix me:lyt
    -- 是否是急速二人麻将
    self.isTP_ = true
    -- fix me:lyt

    self.tileWalls_ = { }
    self.currentNum_ = 0
    -- print(TAG, "ctor ,self.mahjongData_.gameId_:", self.mahjongData_.gameId_, ",self.isTP_:", self.isTP_)

    self:initView()
end

-- 初始化界面view
function C:initView()
    self:initTileWall()

    self:initChin()
end

--初始化牌墙
function C:initTileWall()
    -- if self.mahjongData_ then
    self.handNode_ = { }
    self.mopaiNode_ = { }
    for i = 1, self.playerCount_ do
        self.mopaiNode_[i] = self.parentView_.nodeMopai[i]
        self.handNode_[i] = self.parentView_.nodeHandCard[i]
    end
    self:initTileWallByPos(1)
    self:initTileWallByPos(2)
    -- end
end

--[[--
        初始化牌墙位置
        @param pos:玩家位置
  ]]
function C:initTileWallByPos(pos)
    self.tileWalls_[pos] = JsmjOpenTileWall.new(self.parentView_, pos, self.isTP_)
    self.tileWalls_[pos]:setAnchorPoint(cc.p(0.5,0.5))
    self.tileWalls_[pos]:setContentSize(display.width, display.height)
    self.tileWalls_[pos]:addTo(self)
    self.tileWalls_[pos].moveTileListener_ = handler(self, self.onMoveTileEnd)
end

-- 初始化玩家头像
function C:initChin()
    local nPlayerCount = self.playerCount_
    self.headNode_ = { }
    -- fixme:lyt player head
    for i = 1, nPlayerCount do
        self.headNode_[i] = self.parentView_.players[i]
        self.headNode_[i].headNode:setVisible(true)
        self.headNode_[i].scoreLabel:setVisible(false)
        self.headNode_[i].nameLabel:setVisible(false)
        self.headNode_[i].headNode:setPosition(self.headNode_[i].headStartPos)
    end
end

--[[--
        头像移动动画
        @param pos:玩家位置
  ]]
function C:figureAnim(pos)
    self.figureAnimCount_ = self.figureAnimCount_ + 1
    local isLast =(self.figureAnimCount_ == self.playerCount_)

    -- fixme:lyt player head
    local head = self.headNode_[pos].headNode
    -- local chin = self:getViewById(pos + FIGURE_POS_0)
    local function _removeSelf()
--        if chin then
--            chin:setVisible(false)
--        end
--        if isLast then
--            self:removeChins()
            if self.onFigureAnimEndListener_ then
                self.onFigureAnimEndListener_()
            end
--        end
    end

    if head then
        local array = { }
        array[1] = cc.MoveTo:create(0.15, self:getFigureDst(pos))
        array[2] = cc.CallFunc:create(_removeSelf)
        local action = cc.Sequence:create(array)
        --        local node = chin:getNode()
        if action then
            head:runAction(action)
        end
    end
end

--[[--
        头像移动最终坐标
        @param pos:玩家位置
        @return ccp:移动后坐标
  ]]
function C:getFigureDst(pos)
    local ccp = nil
    if pos == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        ccp = self.headNode_[1].headEndPos
    elseif pos == JsmjDefine.MahjongPos.POSITION_TOP then
        ccp = self.headNode_[2].headEndPos
    end
    return ccp
end


--牌张飞行结束
function C:runFlyToRemaindNum()
    print("runFlyToRemaindNum ")
    self:onAllAnimEnd()
end

function C:startDeal(bankerPos, beginSeat,offsetCount, cardData)
    self.curFromSeat_ = beginSeat --从哪个牌堆开始发牌
    self.offsetCount_ = offsetCount --从牌堆第几个牌开始发牌
    self.cardData_ = cardData --牌数据
    self.curToSeat_ = bankerPos --牌摸给谁

    DISPATCH_COUNT = {4,4,1}
    --DEAL_STATE_ONE = 4

    local maxTileNum = self.tileWalls_[self.curFromSeat_]:getMaxTileNum()
    self.curLeftNum_ = (maxTileNum-self.offsetCount_)*2--当前牌堆剩余多少牌
    self.dealCurCount_ = 1
    --self.dealTotalCount_ = math.ceil((#cardData[banker])/DEAL_STATE_ONE)

    self:dealTile()
end

-- 发牌动画
function C:dealTile()
    if self.dealCurCount_ <= #DISPATCH_COUNT then
        --获得当前摸几张牌
        --判断是否要从两个牌堆摸牌
        local tileWall = self.tileWalls_[self.curFromSeat_];
        local dst = self:getFinalCCP(self.curToSeat_)
        if DISPATCH_COUNT[self.dealCurCount_] > self.curLeftNum_ then
            --当前牌堆摸牌
            if DISPATCH_COUNT[self.dealCurCount_] == 1 then
                tileWall:moveTiles(self.offsetCount_, true, false, dst.x, dst.y)
            else
                tileWall:moveTiles(self.offsetCount_, false, false, dst.x, dst.y)
            end

            local LeftNum = DISPATCH_COUNT[self.dealCurCount_]-self.curLeftNum_
            self.curFromSeat_ = ((self.curFromSeat_)%self.playerCount_)+1
            tileWall = self.tileWalls_[self.curFromSeat_];
            self.offsetCount_ = 0
            self.curLeftNum_ = tileWall:getMaxTileNum();
            --下一牌堆摸牌
            if DISPATCH_COUNT[self.dealCurCount_] == 1 then
                tileWall:moveTiles(self.offsetCount_, true, true, dst.x, dst.y)
            else
                tileWall:moveTiles(self.offsetCount_, false, true, dst.x, dst.y)
            end

            self.offsetCount_ = self.offsetCount_+LeftNum/2
            self.curLeftNum_ = self.curLeftNum_ - LeftNum
            if self.curLeftNum_ <= 0 then
                self.curFromSeat_ = ((self.curFromSeat_)%self.playerCount_)+1
                tileWall = self.tileWalls_[self.curFromSeat_];
                self.offsetCount_ = 0
                self.curLeftNum_ = tileWall:getMaxTileNum();
            end
        else
            local oldLeftNum = self.curLeftNum_
            tileWall = self.tileWalls_[self.curFromSeat_];
            local moveCount = DISPATCH_COUNT[self.dealCurCount_]/2
         
            if DISPATCH_COUNT[self.dealCurCount_] == 1 then
                tileWall:moveTiles(self.offsetCount_, true, true, dst.x, dst.y)
            else
                tileWall:moveTiles(self.offsetCount_, false, false, dst.x, dst.y)
                self.offsetCount_ = self.offsetCount_ + 1

                tileWall:moveTiles(self.offsetCount_, false, true, dst.x, dst.y)
                self.offsetCount_ = self.offsetCount_ + 1
            end

            --self.offsetCount_ = self.offsetCount_ + DISPATCH_COUNT[self.dealCurCount_]/2
            self.curLeftNum_ = self.curLeftNum_ - DISPATCH_COUNT[self.dealCurCount_]
            if self.curLeftNum_ <= 0 then
                self.curFromSeat_ = ((self.curFromSeat_)%self.playerCount_)+1
                tileWall = self.tileWalls_[self.curFromSeat_];
                self.offsetCount_ = 0
                self.curLeftNum_ = tileWall:getMaxTileNum();
            end
        end

        --self.curToSeat_ = (self.curToSeat_%self.playerCount_)+1
        --self.dealCurCount_  = self.dealCurCount_ +1
    else
        self:runFlyToRemaindNum()
    end
end

-- 移动结束
function C:onMoveTileEnd()
    if self.onAddTilesListener_ then
        local num = DISPATCH_COUNT[self.dealCurCount_]
        self.onAddTilesListener_(self.curToSeat_, num)
    end
    self.dealCurCount_  = self.dealCurCount_ +1
    self.curToSeat_ = (self.curToSeat_%self.playerCount_)+1
    self:dealTile()
end


-- 开始头像移动动画
function C:startFigureAnim()
    self:figureAnim(1)
    self:figureAnim(2)
end

-- 动画结束处理
function C:onAllAnimEnd()
    self:removeTileWalls()
    if self.onOpenDoorOverListener_ then
        self.onOpenDoorOverListener_()
    end
end

--[[--
        获取最终坐标
        @param pos:方位
        @return ccp:坐标
  ]]
function C:getFinalCCP(pos)
    local ccp = nil
    if pos == JsmjDefine.MahjongPos.POSITION_BOTTOM then
        ccp = cc.p(self.mopaiNode_[1]:getPosition())
    elseif pos == JsmjDefine.MahjongPos.POSITION_TOP then
        ccp = cc.p(self.mopaiNode_[2]:getPosition())
    end
    return ccp
end

-- 退出函数
function C:onExit()
    self.tileWalls_ = nil
    self.mahjongData_ = nil
    self.figureAnimCount_ = 0
    self.dealTileCount_ = 1
    self.playerCount_ = 0
end

-- 移除牌墙
function C:removeTileWalls()
    if self.tileWalls_ then
        for _, wall in pairs(self.tileWalls_) do
            wall:removeAllTiles()
        end
    end
    self.tileWalls_ = nil
end

return C