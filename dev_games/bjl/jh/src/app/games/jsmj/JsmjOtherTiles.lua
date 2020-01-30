--[[--
        界面: play界面其它玩家手牌

        生命周期: 开牌到牌局结束

        成员函数:

        * _getArrowInfo: 获取指向信息
        * _getBuInfo: 获取补杠标记信息

        必要重载:
            * 无
  ]]
local C = class("JsmjOtherTiles", cc.Node)
local JsmjDefine = import(".JsmjDefine")
local Tile = import(".JsmjTile")
local JsmjTileImage = import(".JsmjTileImage")

C.MARK_TYPE_SAME = 1
C.MARK_TYPE_NEAR = 2
MAX_TILE = 5
local _getArrowInfo = nil
local _getBuInfo = nil

--[[--
        构造函数
        @param parentView:上一级界面
        @param pos:玩家座位
  ]]
function C:ctor(parentView, pos)
    --C.super.ctor(self)
    self.pView_ = parentView
    self.dimens_ = parentView.dimens_
    self.theme_ = parentView.theme_
    self.pos_ = pos
    self.mahjongData_ = self.pView_.model
    --_debugInfo(" --------cror-------- ")
    self.num_ = 0
    -- 总共需要画多少张
    self.currentNum_ = 0
    -- 当前需要画多少张
    self.isAnim_ = false
    -- 是否在播放发牌动画中
    self.localtions_ = {}
    -- 显示背面牌时
    self.handLocations_ = { {}, {}, {}, {}, {} }
    self.playerTiles_ = {}
    self.picMode_ = 0
    self.drawPlayerTile_ = nil
    -- 抓到的牌
    self.huTile_ = nil
    -- 胡的牌,二人胡牌模式时，第一个人胡牌时显示
    self.isCalled_ = false
    -- 是否已经听牌
    self.isWin_ = false
    -- 是否已经胡牌
    -- self.maxFan_ = 0 --胡牌总番数
    self.handNum_ = 0
    -- 吃碰杠了多少
    self.selectedTile_ = nil
    -- 当前选中的牌：需要根据这张牌来设置相邻牌的显示颜色 Tile
    self.moveAnimFlag_ = false
    -- 标记是否有移牌动画

    self.isAnGang_ = false
    self.touchLayer_ = nil

    --self:initTouchLayer()
    -- 加番
    self.fanInHandCount_ = 0
    -- 坎牌的加番个数
    self.fanInTilesCount_ = 0
    -- 手牌的加番个数
    self.initFlag_ = false -- 是否已经初始化完毕
end

--初始化界面数据
function C:init()
    MAX_TILE = self.mahjongData_:getMaxTileNumber() + 1 --设置可配
    self.localtions_ = {}
    if self.pView_ then
        local tileHeight = 32
        local interval = { 0.2, 0.4, 0.6, 0.9 }
        local drawLocaiton = MAX_TILE
        local drawOffset = 0.2
        if self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
            tileHeight = 34  --此处可以据牌张大小进行调整,可以调整牌间距
            interval = { 0.4, 0.7, 1.0, 1.4 }
            drawOffset = 0.4
        elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_LEFT then
            interval = { 0.2, 0.4, 0.6, 0.8 }
            drawLocaiton = 1
            drawOffset = -0.3
        end
        for j = 1, MAX_TILE do
            local i = j
            if i == drawLocaiton then
                i = i + drawOffset
            end
            local zCoords = i * tileHeight
            local showInfo = self.pView_:getOtherTileShowInfo(self.pos_, zCoords)
            if showInfo then
                table.insert(self.handLocations_[1], showInfo) -->目前对家只用第一组参数s
            end
            zCoords = (i - interval[1]) * tileHeight
            showInfo = self.pView_:getOtherTileShowInfo(self.pos_, zCoords)
            if showInfo then
                table.insert(self.handLocations_[2], showInfo)
            end
            zCoords = (i - interval[2]) * tileHeight
            showInfo = self.pView_:getOtherTileShowInfo(self.pos_, zCoords)
            if showInfo then
                table.insert(self.handLocations_[3], showInfo)
            end
            zCoords = (i - interval[3]) * tileHeight
            showInfo = self.pView_:getOtherTileShowInfo(self.pos_, zCoords)
            if showInfo then
                table.insert(self.handLocations_[4], showInfo)
            end
            zCoords = (i - interval[4]) * tileHeight
            showInfo = self.pView_:getOtherTileShowInfo(self.pos_, zCoords)
            if showInfo then
                table.insert(self.handLocations_[5], showInfo)
            end
        end
        self.localtions_ = self.handLocations_[1] -->目前对家只用第一组参数
    end
    self.initFlag_ = true
end

--设置手牌数目
function C:setTileNum(num)
    --_debugInfo("setTileNum num=", num)
    if num and num > 0 then
        if num > MAX_TILE then
            num = MAX_TILE
        end
        self.num_ = num
        self.currentNum_ = self.num_
    end
end

-- 设置吃碰杠数目
function C:setHandNum(num)
    --_debugInfo("setHandNum num=", num)
    if num and num >= 0 and num <= 5 then
        self.handNum_ = num
    end
end

--是否已经听牌
function C:isCalled()
    return self.isCalled_
end

--[[--
        设置是否听牌
        @param isCalled:是否听牌
  ]]
function C:setCalled(isCalled)
    self.isCalled_ = isCalled
end

--是否胡牌
function C:isWin()
    return self.isWin_
end

--[[--
        设置是否胡牌
        @param isWin:是否胡牌
  ]]
function C:setWin(isWin)
    --_debugInfo("setWin isWin=", isWin)
    self.isWin_ = isWin
end

function C:setAnGang(flag)
    self.isAnGang_ = flag
end

--[[--
        吃碰杠时刷新
        @param handNum:吃碰杠数
        @param tiles:吃碰杠的牌id
        @param tileNum:手牌数
  ]]
function C:refreshOtherforCpg(handNum, tiles, tileNum)
    if handNum then
        self:setHandNum(handNum)
    end
    if tiles then
        self:delNeeddelTileIds(tiles)
    end
    if tileNum then
        self:setTileNum(tileNum)
    end
    self.moveAnimFlag_ = true
    self:refresh()
    self.isAnGang_ = false
    self.moveAnimFlag_ = false
end

--[[--
        听牌时刷新
        @param playerTiles:玩家手牌id
        @param isCall:听牌标记
  ]]
function C:refreshOtherforCall(playerTiles, isCall)
    -- 同时清除抓牌
    self.drawPlayerTile_ = nil
    self:setCalled(isCall)
    if playerTiles then
        self:setPlayerTilesOnly(playerTiles)
    end
    self:refresh()
end

--[[--
        胡牌时刷新
        @param params:详细参数
  ]]
function C:refreshOtherforWin(params)
    if params then
        self.paoPos_ = params.paoPos_
        if params.paoTile_ then
            --[[self.huTile_ = params.paoTile_
            self:setWin(true)
            -- 胡牌时时清除抓牌
            self.drawPlayerTile_ = nil]]
            self:setHuTile(params.paoTile_)
            self:setPlayerDrawTile(nil)
        else
            self:setWin(false)
        end
    end
end

--[[--
        开牌时刷新
        @param tileNum:牌张数量
        @param isAnim:是否需要播放抓牌动画
        @param drawTile:抓到的牌
  ]]
function C:refreshOtherforStartDeal(tileNum, isAnim, drawTile)
    --_debugInfo("refreshOtherforStartDeal tileNum=", tileNum)
    self.isAnim_ = isAnim
    self.drawPlayerTile_ = drawTile
    if tileNum then
        self:setTileNum(tileNum)
    end
    self:refresh()
end

--[[--
        抓到的牌
        @param tile:牌张id
        @param isDelay:是否需要增加延迟
        @param isJustSet:是否只是设置抓的牌
  ]]
function C:setPlayerDrawTile(tile, isDelay, isJustSet)
    --_debugInfo(" setPlayerDrawTile tileid=", tile)
    self.drawPlayerTile_ = tile
    if not isJustSet then
        if isDelay == true then
            self:addDrawTile()
        else
            self:refresh()
        end
    end
end

--添加牌
function C:addTile()

    self:refresh()
    self.drawHandler_ = nil
    self.isDrawFlower_ = false
    --self.pView_:askCleanHoldMsgForBit(self.pView_.HOLD_BIT_OTHER_DRAW)
end

--添加牌，并播抓牌动画
function C:addDrawTile()
    --self.pView_:askHoldMsgForBit(self.pView_.HOLD_BIT_OTHER_DRAW)
    self.drawHandler_ = self:delayInvoke(0.1, handler(self, self.addTile))
end

function C:delayInvoke(time,callback)
    local act = transition.sequence({
		CCDelayTime:create(time),
		CCCallFunc:create(callback)
	})
    self:runAction(act)
end

--[[--
        设置玩家手牌id
        @param tiles:手牌id
  ]]
function C:setPlayerTilesOnly(tiles)
    self.playerTiles_ = {}
    if tiles and #tiles > 0 then
        for _, v in pairs(tiles) do
            if v then
                table.insert(self.playerTiles_, v)
            end
        end
    end
    -- 整体排序
    self:sorePlayerTiles()
end

--停止schedule
function C:stopSchedule()
    if self.drawHandler_ then
        self:unschedule(self.drawHandler_)
        self.drawHandler_ = nil
    end
end

--[[--
       吃、碰、杠之后，将这些牌从m_Tiles中去除 List<Integer> tileids
        @param tiles:吃碰杠的牌id
  ]]
function C:delNeeddelTileIds(tiles)
    if tiles then
        for _, tileId in pairs(tiles) do
            for k, tile in pairs(self.playerTiles_) do
                if tileId and tileId == tile.id_ then
                    table.remove(self.playerTiles_, k)
                    break
                end
            end
        end
    end
end

--[[--
        设置胡牌
        @param huTile:胡牌的
  ]]
function C:setHuTile(huTile)
    self.huTile_ = huTile
    if self.huTile_ then
        self:setWin(true)
    end
end

--[[--
        刷新手牌显示
        @param winFlag:是否是胡牌时刷新
  ]]
function C:refresh(winFlag)
   -- self:calcShowJiafanInTilesCount()
    self:drawOthersTiles(winFlag)
end

--[[--
        刷新手牌显示
        @param winFlag:是否是胡牌时刷新
  ]]
function C:drawOthersTiles(winFlag)
   -- _debugInfo(" drawOthersTiles winFlag=", winFlag, ",initFlag=", self.initFlag_)
    if not self.initFlag_ then
        --_debugInfo(" call init")
        self:init()
    end
    if self.pView_ then
        self.pView_:removeAllOtherTileImg(self.pos_)
    end
    if self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
        self:drawTopTiles(winFlag)
    end
end

--[[--
        播放抓牌动画
        @param img:动画图片
        @param x:动画最终x坐标
        @param y:动画最终y坐标
  ]]
function C:playDrawAnim(img, x, y)
    --_debugInfo(" playDrawAnim  ")
    if img and x and y then
        img:setPosition(x, y + 15)
        local array = { }
        array[1] = CCCallFunc:create(function() self.pView_:askHoldMsgForBit(self.pView_.HOLD_BIT_OTHER_DRAW) end)
        array[2] = CCMoveTo:create(0.15, ccp(x, y))
        array[3] = CCCallFunc:create(function()
            --self.pView_:askCleanHoldMsgForBit(self.pView_.HOLD_BIT_OTHER_DRAW)
        end)
        img:runAction(CCSequence:create(array))
    end
end

--[[--
        刷新上家手牌显示
        @param winFlag:是否是胡牌时刷新
  ]]
function C:drawTopTiles(winFlag)
   -- _debugInfo(" drawTopTiles winFlag=", winFlag, ",self.currentNum_=",
   --     self.currentNum_, ",self.isAnim_=", self.isAnim_)
    local startIndex = MAX_TILE - self.currentNum_
    if self:isShowAllTiles() then
        local count = #self.playerTiles_
        for i = startIndex, MAX_TILE - 1 do
            local drawTileIndex = i - startIndex + 1
            local t = self.playerTiles_[drawTileIndex]
            if i < MAX_TILE then
                if t and t.id_ > 0 then
                    self:drawShowTile(t, i, i + 1)
                end
            end
        end
        if not winFlag then
            local node = nil
            if self.drawPlayerTile_ then
                if self.drawPlayerTile_.id_ > 0 then
                    -- 避免二麻亮出一万
                    node = self:drawShowTile(self.drawPlayerTile_, MAX_TILE)
                elseif self.playerTiles_[count] and self.playerTiles_[count].id_ > 0 then
                    node = self:drawShowTile(self.playerTiles_[count], MAX_TILE)
                else
                    self:drawBackTile(MAX_TILE)
                end
            elseif count > self.num_ then
                if self.playerTiles_[count] and self.playerTiles_[count].id_ > 0 then
                    node = self:drawShowTile(self.playerTiles_[count], MAX_TILE)
                end
            end
            if self.isWin_ then
                self:showHuArrow(node, self.paoPos_)
            end
        end
        -- 听牌后
    elseif self:isCalled() or self:isWin() then
        --_debugInfo(" drawTopTiles  case 2")
        for i = startIndex, MAX_TILE - 1 do
            self:drawBackTile(i)
        end
        if self.drawPlayerTile_ then
            self:drawBackTile(MAX_TILE)
        end
    elseif self.isAnim_ then
        for i = 1, self.currentNum_ do
            self:drawTile(i)
        end
    else
        for i = startIndex, MAX_TILE - 1 do
            self:drawTile(i, nil, i + 1)
        end
        if self.drawPlayerTile_ then
            if self.isAnGang_ == false then
                self:drawTile(MAX_TILE, true)
            end
        end
    end
end

--是否亮牌
function C:isShowAllTiles()
    if self.playerTiles_ then
        if #self.playerTiles_ > 1 then
            return true
        elseif #self.playerTiles_ == 1 then
            if self.playerTiles_[1] and self.huTile_ and self.playerTiles_[1].id_ == self.huTile_.id_ then
                return false
            else
                return true
            end
        end
    end
    return false
end

--[[--
        显示亮着的牌(正面)
        @param tile: 麻将信息
        @param location: 当前牌张处于手牌中的位置号[1-14]
        @param finalLocation:  当前牌张最终(有坎牌要移动手牌)处于手牌中的位置号[1-14]
    ]]
function C:drawShowTile(t, location, finalLocation)
    --_debugInfo("drawShowTile t.color_= ", t.color_, ",value=", t.value_, ",location=", location)
    return self:drawTile(location, nil, finalLocation, JsmjDefine.MahjongPos.TILE_SHOW_STATE_FACE, t)
end

--[[--
        显示扣着的牌(背面)
        @param location: 当前牌张处于手牌中的位置号[1-14]
        @param finalLocation: 当前牌张最终(有坎牌要移动手牌)处于手牌中的位置号[1-14]
]]
function C:drawBackTile(location, finalLocation)
    self:drawTile(location, nil, finalLocation, JsmjDefine.MahjongPos.TILE_SHOW_STATE_BACK, nil)
end

--[[--
        正常的手牌(画单张牌)
        @param location: 当前牌张处于手牌中的位置号[1-14]
        @param drawFlag: 是否有抓牌动画(只有花抓的牌且不是花牌的情况下)
        @param finalLocation: 当前牌张最终(有坎牌要移动手牌)处于手牌中的位置号[1-14]
        @param state: 麻将的状态(背面站立(默认)/正面/背面)
        @param tile: 麻将信息
]]
function C:drawTile(location, drawFlag, finalLocation, state, tile)
    local tileState = state
    if tileState == nil then
        tileState = JsmjDefine.MahjongPos.TILE_SHOW_STATE_STAND
    end
    local tileId = nil
    if tile then
        tileId = tile.id_
    end
    if self.localtions_ and self.pView_ then
        local showInfo = self.localtions_[location]
        local maxTileNum = self.mahjongData_:getMaxTileNumber()
        local img = JsmjTileImage.new(tileId, self.pos_, location, tileState, 5)
        if img and showInfo and showInfo.scale and showInfo.z and showInfo.x and showInfo.y then
            if drawFlag == true and not self.isDrawFlower_ then
                self.pView_:addOtherTileImg(self.pos_, img)
                img:setScale(showInfo.scale)
                img:setLocalZOrder(showInfo.z)
                self:playDrawAnim(img, showInfo.x, showInfo.y)
            else
                if self.moveAnimFlag_ and finalLocation and (self.drawPlayerTile_ or self.currentNum_ % 3 == 2)
                        and self.isAnGang_ == false then
                    --_debugInfo(" drawTile case 2")
                    local finalShowInfo = self.localtions_[finalLocation]
                    if finalShowInfo and finalShowInfo.x and finalShowInfo.y then
                        img:setPosition(showInfo.x, showInfo.y)
                        self.pView_:addOtherTileImg(self.pos_, img)
                        img:setScale(finalShowInfo.scale)
                        img:setLocalZOrder(finalShowInfo.z)
                        img:setPosition(finalShowInfo.x, finalShowInfo.y)
                        -- 直接设置位置
                        local array = CCArray:create()
                        array:addObject(CCMoveTo:create(0.4, ccp(finalShowInfo.x, finalShowInfo.y)))
                        img:runAction(CCSequence:create(array))
                    else
                    end
                else
                    --_debugInfo(" drawTile case 3")
                    self.pView_:addOtherTileImg(self.pos_, img)
                    img:setScale(showInfo.scale)
                    img:setLocalZOrder(showInfo.z)
                    img:setPosition(showInfo.x, showInfo.y)
                    --_debugInfo("drawTile ok  location=",location,",z=",showInfo.z)
                end
            end

            -- 加番
--            if state == MahjongDef.TILE_SHOW_STATE_FACE and self:needShowJiafanInTiles(tileId) then
--                img:showJiaFan(true)
--            end
            --
            return img
        else
        end
    end
end

--[[--
        设置玩家手牌，并显示
        @param tiles:手牌
        @param winFlag:用于是否需要画最后一张牌，区分胡牌移动动画执行标记,true 不画，false 画
  ]]
function C:setPlayerTiles(tiles, winFlag)
    self.playerTiles_ = {}
    if tiles and #tiles > 0 then
        for _, v in pairs(tiles) do
            if v then
                table.insert(self.playerTiles_, v)
            end
        end
    end
    -- 整体排序
    self:sorePlayerTiles()
    self:refresh(winFlag)
end

--手牌排序
function C:sorePlayerTiles()
    --if self.playerTiles_ then
        -- MahjongUtil:sortTiles(self.playerTiles_)
        -- 对家手牌摊开后，排列方式和本家相同
        --MahjongUtil:sortTilesReserve(self.playerTiles_)
    --end
    -- 对家的混不用特殊排序
    -- if self.pos_ ~= MahjongDef.POSITION_TOP then
    local hunTiles = {}
    local hunTileIndex = {}
    local huTileIndex = -1
--    for k, tile in pairs(self.playerTiles_) do
--        if self.huTile_ and self.huTile_.id_ == tile.id_ then
--            -- huTileIndex = k
--        else
--            if self.mahjongData_:isHun(tile) then
--                tile.isHun_ = true
--                table.insert(hunTiles, tile)
--                table.insert(hunTileIndex, k)
--            end
--        end
--    end
    for k, index in pairs(hunTileIndex) do
        table.remove(self.playerTiles_, index)
    end

    for k, tile in pairs(self.playerTiles_) do
        if self.huTile_ and self.huTile_.id_ == tile.id_ then
            huTileIndex = k
        end
    end
    -- 先移除胡牌
    table.remove(self.playerTiles_, huTileIndex)
    -- 对家混牌放在最右侧
    if self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
        for i = #hunTiles, 1, -1 do
            table.insert(self.playerTiles_, hunTiles[i])
        end
    else
        for i = #hunTiles, 1, -1 do
            table.insert(self.playerTiles_, 1, hunTiles[i])
        end
    end

    table.insert(self.playerTiles_, self.huTile_)
    -- end
end

--退出函数
function C:onExit()
    self.localtions_ = nil
    self.playerTiles_ = nil
    self.drawPlayerTile_ = nil
    self.huTile_ = nil
    self.isCalled_ = false
    self.isWin_ = false
    -- self.maxFan_ = 0
    self.currentNum_ = 0
    self.num_ = 0
    self.isAnim_ = false

    self.touchLayer_ = nil
    -- 加番
    self.fanInHandCount_ = 0
    -- 坎牌的加番个数
    self.fanInTilesCount_ = 0
    -- 手牌的加番个数
    --
    --self:stopSchedule()
end

--重置数据
function C:reset()
    self.num_ = 0
    -- 总共需要画多少张
    self.currentNum_ = 0
    -- 当前需要画多少张
    self.isAnim_ = false
    -- 是否在播放发牌动画中
    self.localtions_ = self.handLocations_[1]
    self.playerTiles_ = {}
    -- Collections.synchronizedList(new ArrayList<Tile>())
    self.drawPlayerTile_ = nil
    -- 抓到的牌
    self.huTile_ = nil
    -- 胡的牌,二人胡牌模式时，第一个人胡牌时显示
    self.isCalled_ = false
    -- 是否已经听牌
    self.isWin_ = false
    -- self.maxFan_ = 0
    self.handNum_ = 0
    -- 吃碰杠了多少
    self.selectedTile_ = nil
    self.moveAnimFlag_ = false
    -- 加番
    self.fanInHandCount_ = 0
    -- 坎牌的加番个数
    self.fanInTilesCount_ = 0
    -- 手牌的加番个数

    if self.pView_ then
        self.pView_:removeAllOtherTileImg(self.pos_)
        self.pView_:removeAllOtherHandImg(self.pos_)
    end
    --self:setTingViewEnableTouch(false)
end

--[[--
        获取最后一张牌坐标
        @param pos:玩家座位
        @return ccp:最后一张牌坐标
  ]]
function C:getLastShowLocation(pos)
    local showInfo = nil
    if pos == JsmjDefine.MahjongPos.POSITION_LEFT then
        showInfo = self.localtions_[1]
    elseif pos == JsmjDefine.MahjongPos.POSITION_RIGHT then
        showInfo = self.localtions_[MAX_TILE]
    elseif pos == JsmjDefine.MahjongPos.POSITION_TOP then
        showInfo = self.localtions_[MAX_TILE]
    end
    if showInfo and showInfo.x and showInfo.y then
        return ccp(showInfo.x, showInfo.y)
    else
    end
end

--移除抓的牌
function C:removeDrawTile()
    if self.pView_ then
        self.pView_:removeOtherLastTileImg(self.pos_)
    end
end

--[[--
        添加最后一张牌显示
        @param pos:玩家座位
        @param paoPos:点炮座位
  ]]
function C:drawLastResultTile(pos, paoPos)
    local location = 1
    if pos == JsmjDefine.MahjongPos.POSITION_TOP then
        location = MAX_TILE
    end
    if self.huTile_ and self.huTile_.id_ > 0 then
        if paoPos == self.pos_ or paoPos == JsmjDefine.MahjongPos.POSITION_UNKNOW then
            -- self:removeDrawTile()
        end
        self:showHuArrow(self:drawShowTile(self.huTile_, location), paoPos)
    end
end

--[[--
        显示方位标记
        @param node:添加显示layer
        @param tilePos:牌张方位
  ]]
function C:showArrowImg(node, tilePos)
    local arrowImg = display.newSprite(GAME_JSMJ_IMAGES_RES .. "play/mahjong_play_handview_arrow.png")
    if arrowImg and node then
        local tileSize = node:getTileSize()
        if tileSize and tileSize.width and tileSize.height then
            node:addChild(arrowImg)
            local rotate, skewX, shewY, left, top, scaleX, scaleY = _getArrowInfo(self.pos_, tilePos, tileSize.width,
                tileSize.height)
            arrowImg:setPosition(left, top)
            arrowImg:setScaleX(scaleX)
            arrowImg:setScaleY(scaleY)
            arrowImg:setSkewX(skewX)
            arrowImg:setSkewY(shewY)
            arrowImg:setRotation(rotate)
        end
    end
end

--[[--
        显示胡牌标记
        @param node:添加显示layer
        @param tilePos:牌张方位
  ]]
function C:showHuArrow(node, tilePos)
    if tilePos ~= self.pos_ and tilePos ~= JsmjDefine.MahjongPos.POSITION_UNKNOW then
        self:showArrowImg(node, tilePos)
    else
        local arrowImg = display.newSprite(GAME_JSMJ_IMAGES_RES .. "play/mahjong_play_handview_zimo.png")
        if arrowImg and node then
            local tileSize = node:getTileSize()
            if tileSize and tileSize.width and tileSize.height then
                node:addChild(arrowImg)
                local rotate, skewX, shewY, left, top, scaleX, scaleY = 0, 0, 0, 0, 0, 1, 1
                if self.pos_ == JsmjDefine.MahjongPos.POSITION_LEFT then
                    rotate = 90
                    left, top = tileSize.width / 5, tileSize.height * 3 / 4
                    skewX, shewY = 0, -38
                elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_TOP then
                    left, top = tileSize.width / 2, tileSize.height * 3 / 10
                    scaleX = 0.8
                    scaleY = 0.8
                elseif self.pos_ == JsmjDefine.MahjongPos.POSITION_RIGHT then
                    rotate = -90
                    left, top = tileSize.width * 4 / 5, tileSize.height * 2 / 3
                    skewX, shewY = 0, 0
                end
                arrowImg:setPosition(left, top)
                arrowImg:setScaleX(scaleX)
                arrowImg:setScaleY(scaleY)
                arrowImg:setSkewX(skewX)
                arrowImg:setSkewY(shewY)
                arrowImg:setRotation(rotate)
            end
        end
    end
end

--[[
      获取指向标记信息
      @param selfPos 自己位置
      @param tilePos 吃碰杠那张牌玩家的位置
      @param width 牌张宽度
      @param height 牌张高度
      @return rotate, skewX, shewY, left, top, scaleX, scaleY:显示参数
]]
function _getArrowInfo(selfPos, tilePos, width, height)
    local rotate, skewX, shewY, left, top, scaleX, scaleY = 0, 0, 0, 0, 0, 1, 1
    if selfPos == MahjongDef.POSITION_LEFT then
        left, top = width * 1 / 4, height * 3 / 4
        if tilePos == MahjongDef.POSITION_RIGHT then
            skewX, shewY = 20, 0
        elseif tilePos == MahjongDef.POSITION_TOP then
            skewX, shewY = 10, -30
            rotate = -90
            scaleX = 0.8
        elseif tilePos == MahjongDef.POSITION_BOTTOM then
            skewX, shewY = 10, -20
            rotate = 90
            scaleX = 0.8
        end
    elseif selfPos == MahjongDef.POSITION_RIGHT then
        left, top = width * 3 / 4, height * 3 / 4
        if tilePos == MahjongDef.POSITION_LEFT then
            rotate = 180
            skewX, shewY = -20, 0
        elseif tilePos == MahjongDef.POSITION_TOP then
            skewX, shewY = 10, 10
            rotate = -116
            scaleX = 0.8
        elseif tilePos == MahjongDef.POSITION_BOTTOM then
            rotate = 78
            skewX, shewY = 10, 10
            scaleX = 0.8
        end
    elseif selfPos == MahjongDef.POSITION_TOP then
        left, top = width / 2, height * 2 / 10
        scaleX = 0.8
        scaleY = 0.8
        if tilePos == MahjongDef.POSITION_RIGHT then
            skewX, shewY = 0, 0
        elseif tilePos == MahjongDef.POSITION_LEFT then
            rotate = 180
        elseif tilePos == MahjongDef.POSITION_BOTTOM then
            rotate = 90
        end
    end
    return rotate, skewX, shewY, left, top, scaleX, scaleY
end

--[[--
        设置被选中的牌张
        @param t:被点击牌张
  ]]
function C:setSelectedTile(t)
    self.selectedTile_ = t
    local handImgs
    if self.pView_ then
        handImgs = self.pView_:getOtherHandImg(self.pos_)
    end
    if handImgs then
        for k, images in pairs(handImgs) do
            for j, image in pairs(images) do
                local v = image.type
                local color = math.floor(v / 16)
                local value = v % 16 - 1
                if self.selectedTile_ and color == self.selectedTile_.color_
                        and value == self.selectedTile_.value_ then
                    self:setMarkVisible(k, j, true)
                else
                    self:setMarkVisible(k, j, false)
                end
            end
        end
    end
end

--[[--
        标记选中牌张相同牌
        @param handIndex:吃碰杠牌位置
        @param tileIndex:牌张位置
        @param flag:是否标记
  ]]
function C:setMarkVisible(handIndex, tileIndex, flag)
    local handImgs
    if self.pView_ then
        handImgs = self.pView_:getOtherHandImg(self.pos_)
    end
    if handImgs then
        local tileView = handImgs[handIndex][tileIndex]
        -- if tileView and tileView.mark then
        if tileView then
            if flag then
                tileView:setColor(MahjongDef.MARK_COLOR_SAME)
            else
                tileView:setColor(display.COLOR_WHITE)
            end
        end
    end
end

function C:setOtherTileViewListen(listen)
    self.listen_ = listen
end

function C:onInterceptTouchEvent(event, x, y)
    local bRet = false
    if self.touchLayer_ and self.touchLayer_:isTouchInside(x, y) then
        if not self.touchLayer_:isTouchEnable() then
            return false
        end

        if event == "began" then
            if not self.isShowTingView_ and self.listen_ then
                self.isShowTingView_ = true
                self.listen_:onOtherTileViewListen(true)
            end
        elseif event == "ended" then
            if self.isShowTingView_ and self.listen_ then
                self.isShowTingView_ = false
                self.listen_:onOtherTileViewListen(false)
            end
        elseif event == "moved" then

        elseif event == "cancelled" then
        end
    else
        if self.isShowTingView_ and self.listen_ then
            self.isShowTingView_ = false
            self.listen_:onOtherTileViewListen(false)
        end
    end

    return bRet
end

--[[--
        是否需要显示坎牌加番牌
        @param tileId:牌张id
  ]]
function C:needShowJiafanInHand(tileId)
    local show = false
    if self.mahjongData_ then
        -- fantile
        local fanTile = Tile.new(self.mahjongData_:getAddFanTileId())

        -- tileid
        if not tileId or type(tileId) ~= "number" then
            return false
        end
        -- 限制张数
        local limit = self.mahjongData_:getAddFanTileNum()
        if not limit or type(limit) ~= "number" then
            return false
        end

        local tile = Tile.new(tileId)
        if fanTile and tile and fanTile.color_ == tile.color_ and fanTile.value_ == tile.value_ then
            if self.fanInHandCount_ < limit then
                self.fanInHandCount_ = self.fanInHandCount_ + 1
                show = true
            end
        end
    end
    return show
end


--[[--
        是否需要显示加番牌
        @param tileId:牌张id
  ]]
function C:needShowJiafanInTiles(tileId)
    local show = false
    if self.mahjongData_ then
        -- fantile
        local fanTile = Tile.new(self.mahjongData_:getAddFanTileId())

        -- tileid
        if not tileId or type(tileId) ~= "number" then
            return false
        end

        local tile = Tile.new(tileId)
        if fanTile and tile and fanTile.color_ == tile.color_ and fanTile.value_ == tile.value_ then
            if self.fanInTilesCount_ > 0 then
                self.fanInTilesCount_ = self.fanInTilesCount_ - 1
                show = true
            end
        end
    end
    return show
end

--获取坎牌中的加番牌个数
function C:getJiafanCountInHand()
    local count = 0
    if self.mahjongData_ then
        -- fantile
        local fanTile = Tile.new(self.mahjongData_:getAddFanTileId())

        if fanTile then
            local top = self.mahjongData_:getMahjongPlayerInfoByPos(MahjongDef.POSITION_TOP)
            if top and top:getHands() and #top:getHands() > 0 then
                local hands = top:getHands()
                for i = 1, #hands do
                    if hands[i] and hands[i].tiles_ and #hands[i].tiles_ > 0 then
                        local tiles = hands[i].tiles_
                        for j = 1, #tiles do
                            local t = tiles[j]
                            if t and t.color_ == fanTile.color_ and t.value_ == fanTile.value_ then
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return count
end

--获取手中加番牌个数
function C:getJiafanCountInTile()
    local count = 0
    if self.mahjongData_ then
        -- fantile
        local fanTile = Tile.new(self.mahjongData_:getAddFanTileId())

        if fanTile and self.playerTiles_ and #self.playerTiles_ > 0 then
            local tiles = self.playerTiles_
            for i = 1, #tiles do
                if tiles[i] and tiles[i].color_ and tiles[i].value_ then
                    local tileView = tiles[i]
                    if tileView and tileView.color_ == fanTile.color_ and tileView.value_ == fanTile.value_ then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

return C
