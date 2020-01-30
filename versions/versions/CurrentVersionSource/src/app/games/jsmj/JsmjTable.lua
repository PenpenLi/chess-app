--[[--
        界面: play界面麻将桌view，所有牌张显示都加该view
        生命周期: 同playview
  ]]
local C = class("JsmjTable", cc.Node)
local JsmjDefine = import("app.games.jsmj.JsmjDefine")
local JsmjTileImage = require("app.games.jsmj.JsmjTileImage")

--构造函数
function C:ctor(parent)
    self.parentView_ = parent
    self.background = nil
    self.tablesize_ = nil
    self.otherTileImgs_ = {}
    self.otherHandImgs_ = {}
    self.discardTileImgs_ = {}
    self.openWallTileImgs_ = {}

    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(display.width, display.height)
    self:setPosition(display.width/2, display.height/2)

    local tableWidth = 778 -- 桌子的实际图片的尺寸
    local tableHeight = 549
    self.tablesize_ = CCSize(tableWidth * 2, tableHeight)

    self.area_data = {} --每个区域的缩放等数据
    --手牌 左
    self:addArea(124, 209, 500, 542, 195, 1, 1, 32)
    --手牌 右
    self:addArea(self.tablesize_.width - 227, self.tablesize_.width - 142,
        self.tablesize_.width - 550, self.tablesize_.width - 508, 191, 1, 1, 32)

    --牌池 下
    self:addArea(496, self.tablesize_.width - 496, 663, self.tablesize_.width - 663, 160, 1, 10, 52)
    --牌池 右
    self:addArea(self.tablesize_.width - 506, self.tablesize_.width - 343,
        self.tablesize_.width - 727, self.tablesize_.width - 639, 220, 1, 2, 33.5)
    --牌池 上
    self:addArea(499, self.tablesize_.width - 499, 654,
        self.tablesize_.width - 654, 383, 0.7, 10, 52 * 0.75)
    --牌池 左
    self:addArea(506, 343, 727, 639, 220, 1, 2, 33.5)
end

function C:addOtherTileImg(pos, img)
    if img and pos then
        if self.otherTileImgs_[pos] == nil then
            self.otherTileImgs_[pos] = {}
        end
        self:addChild(img)
        table.insert(self.otherTileImgs_[pos], img)
    end
end

function C:addOtherHandImg(pos, img, handIndex)
    if img and pos then
        if self.otherHandImgs_[pos] == nil then
            self.otherHandImgs_[pos] = {}
        end
        if self.otherHandImgs_[pos][handIndex] == nil then
            self.otherHandImgs_[pos][handIndex] = {}
        end
        self:addChild(img)
        table.insert(self.otherHandImgs_[pos][handIndex], img)
    end
end

function C:getOtherHandImg(pos)
    return self.otherHandImgs_[pos]
end

function C:addDiscardTileImg(pos, img)
    if img and pos then
        if self.discardTileImgs_[pos] == nil then
            self.discardTileImgs_[pos] = {}
        end
        self:addChild(img)
        table.insert(self.discardTileImgs_[pos], img)
    end
end

function C:getDiscardTileImg(pos)
    return self.discardTileImgs_[pos]
end

function C:addOpenWallImg(pos, img)
    if img and pos then
        if self.openWallTileImgs_[pos] == nil then
            self.openWallTileImgs_[pos] = {}
        end
        self:addChild(img)
        table.insert(self.openWallTileImgs_[pos], img)
    end
end

function C:getOpenWallTileImg(pos)
    return self.openWallTileImgs_[pos]
end

function C:removeAllOtherTileImg(pos)
    printInfo(TAG, "removeAllOtherTileImg in", pos)
    if pos then
        if self.otherTileImgs_[pos] then
            for _, img in pairs(self.otherTileImgs_[pos]) do
                if img then
                    self:removeChild(img)
                end
            end
            self.otherTileImgs_[pos] = {}
        end
    end
end

function C:removeOtherLastTileImg(pos)
    printInfo("removeOtherLastTileImg in", pos)
    if pos then
        if self.otherTileImgs_[pos] then
            local drawImgIndex = #self.otherTileImgs_[pos]
            if pos == JsmjDefine.MahjongPos.POSITION_RIGHT then
                drawImgIndex = 1
            end
            local img = self.otherTileImgs_[pos][drawImgIndex]
            if img then
                self:removeChild(img)
                table.remove(self.otherTileImgs_[pos], drawImgIndex)
            end
        end
    end
end

function C:removeAllOtherHandImg(pos)
    printInfo( "removeAllOtherHandImg in", pos)
    if pos then
        if self.otherHandImgs_[pos] then
            for _, imgs in pairs(self.otherHandImgs_[pos]) do
                for _, img in pairs(imgs) do
                    if img then
                        self:removeChild(img)
                    end
                end
            end
            self.otherHandImgs_[pos] = {}
        end
    end
end

function C:removeAllDiscardTileImg(pos)
    printInfo("removeAllDiscardTileImg in", pos)
    if pos then
        if self.discardTileImgs_[pos] then
            for _, img in pairs(self.discardTileImgs_[pos]) do
                if img then
                    self:removeChild(img)
                end
            end
            self.discardTileImgs_[pos] = {}
        end
    end
end

function C:removeAllOpenWallTileImg(pos)
    printInfo("removeAllOpenWallTileImg in", pos)
    if pos then
        if self.openWallTileImgs_[pos] then
            for _, img in pairs(self.openWallTileImgs_[pos]) do
                if img then
                    img:removeFromParent()
                end
            end
            self.openWallTileImgs_[pos] = {}
        end
    end
end

--[[--
        获取玩家牌张显示信息
        @param pos: 玩家位置
        @param z: 显示优先级
        @return info: 坐标及缩放信息
  ]]
function C:getPlayerMahjongInfo(pos, z)
    print(" getPlayerMahjongInfo pos=",pos,",z=",z)
    local info = nil
    local area = nil
    if pos == JsmjDefine.MahjongPos.POSITION_RIGHT or pos == JsmjDefine.MahjongPos.POSITION_LEFT then
        if pos == JsmjDefine.MahjongPos.POSITION_LEFT then
            area = self.area_data[1]
        else
            area = self.area_data[2]
        end
        info = self:getInfo(self:getInterval(z, area) + area.y, area, 1)
    elseif pos == JsmjDefine.MahjongPos.POSITION_TOP then
        local topX = 682 --可调整对家手牌的位置
        info = {
            x = topX - z,
            y = 480,
            z = self:getLocalZOrder(),
            scale = 1,
        }
    else
        print("getPlayerMahjongInfo error,pos:", pos)
    end
    return info
end

--[[--
        根据坐标 获得显示优先级
        @param y: y坐标
        @param x: x坐标
        @return z: 显示优先级
  ]]
function C:getZ(y, x)
    local z = math.floor(836 - y / self.tablesize_.height * 836)
    if x ~= nil then
        local width = self.tablesize_.width / 2
        if x > width then
            x = width - (x - width)
        end
        x = x / width
        z = z + x * 45
    end
    return z
end

--[[--
        根据开始X, 结束X, Y坐标 获取Y坐标
        @param begin_x: 开始x坐标
        @param end_x: 结束x坐标
        @param y: y坐标
        @return y: y坐标
  ]]
function C:getY(begin_x, end_x, y)
    return y / self.tablesize_.height * (end_x - begin_x) + begin_x
end

--[[--
        获取所有变换信息
        @param _y: y坐标
        @param _area: 显示区域
        @param index: 牌张索引
        @return table: 坐标及缩放信息
  ]]
function C:getInfo(_y, _area, index)
    --目的地坐标
    local ret = nil
    local goal_begin = self:getY(_area.begin_x, _area.end_x, _y)
    local goal_end = self:getY(_area.begin_x + _area.begin_width,
        _area.end_x + _area.end_width, _y)
    --比例为1的坐标
    local first_begin = self:getY(_area.begin_x, _area.end_x, _area.y)
    local first_end = self:getY(_area.begin_x + _area.begin_width,
        _area.end_x + _area.end_width, _area.y)

    local width = (goal_end - goal_begin) / (_area.area * 2)
    width = width + width * (index - 1) * 2
    ret = {
        x = width + goal_begin,
        y = _y,
        z = self:getZ(_y, width + goal_begin),
        scale = (goal_end - goal_begin) / (first_end - first_begin) * _area.scale,
    }
    --_debugInfo(" getInfo _area=", _area, ",index=", index, ",ret=", vardump(ret))
    return ret
end

--[[--
        获取玩家牌张显示信息
        @param discardPos: 牌池位置区域
        @param discardIndex: 牌张索引
        @return table: 坐标及缩放信息
  ]]
function C:getDiscardTileInfo(discardPos, discardIndex)
    local maxCount = 20
    local index = discardIndex
    local mahjong = nil
    if index > maxCount then
        index = index - maxCount
    end
    local info = nil
    if discardPos == JsmjDefine.MahjongPos.POSITION_DISCARD_BOTTOM then
        local area = self.area_data[3]
        local mahjongpos = ((index - 1) % 10 + 1)
        local temp = 3 - (math.floor((index - 1) / 10) + 1)
        local y = self:getInterval((temp - 1) * area.interval, area)
        info = self:getInfo(y + area.y, area, mahjongpos)
        if info then
            info.tileIndex = mahjongpos
            if discardIndex > maxCount then
                info.y = info.y + 20 * info.scale
            end
        end
        info.x = info.x-200
    elseif discardPos == JsmjDefine.MahjongPos.POSITION_DISCARD_RIGHT then
        local area = self.area_data[4]
        local mahjongpos = (math.floor((index - 1) / 10) + 1)
        local temp = (math.floor((index - 1) % 10) + 1)
        local y = self:getInterval((temp - 1) * area.interval, area)
        info = self:getInfo(y + area.y, area, mahjongpos)
        if info then
            info.tileIndex = 3 - mahjongpos
            if discardIndex > maxCount then
                info.y = info.y + 27 * info.scale
                info.x = info.x + 2
            end
        end
    elseif discardPos == JsmjDefine.MahjongPos.POSITION_DISCARD_TOP then
        local area = self.area_data[5]
        local mahjongpos = 11 - ((index - 1) % 10 + 1)
        local temp = (math.floor((index - 1) / 10) + 1)
        local y = self:getInterval((temp - 1) * area.interval, area)
        info = self:getInfo(y + area.y, area, mahjongpos)
        if info then
            info.tileIndex = mahjongpos
            if discardIndex > maxCount then
                info.y = info.y + 23 * 0.75 * info.scale
            end
        end
        info.x = info.x-200
    elseif discardPos == JsmjDefine.MahjongPos.POSITION_DISCARD_LEFT then
        local area = self.area_data[6]
        local mahjongpos = (math.floor((index - 1) / 10) + 1)
        local temp = 11 - (math.floor((index - 1) % 10) + 1)
        local y = self:getInterval((temp - 1) * area.interval, area)
        info = self:getInfo(y + area.y, area, mahjongpos)
        if info then
            info.tileIndex = 3 - mahjongpos
            if discardIndex > maxCount then
                info.y = info.y + 27 * info.scale
                info.x = info.x - 2
            end
        end
    else
        print("getDiscardTileInfo error,discardPos:", discardPos)
    end
    return info
end

--[[--
        添加一个区域
        @param _begin_x1: 起始坐标
        @param _begin_x2: 起始坐标
        @param _end_x1: 结束坐标
        @param _end_x2: 结束坐标
        @param _y: y坐标
        @param scale: 缩放大小
        @param area: 区域参数
        @param _interval: 间隔
  ]]
function C:addArea(_begin_x1, _begin_x2, _end_x1, _end_x2, _y, scale, area, _interval)
    local area = {
        begin_x = _begin_x1,
        begin_width = _begin_x2 - _begin_x1,
        end_x = _end_x1,
        end_width = _end_x2 - _end_x1,
        y = _y, --放大比例为1的时候Y的位置
        scale = scale,
        z = 0,
        area = area,
        interval = _interval
    }

    self:initScaleZ(area)

    self.area_data[#self.area_data + 1] = area
end

--[[--
        往后每个像素的基础缩放比例
        @param _area: 区域
        @return none
  ]]
function C:initScaleZ(_area)
    local _y = _area.y + 1

    --目的地坐标
    local goal_begin = self:getY(_area.begin_x, _area.end_x, _y)
    local goal_end = self:getY(_area.begin_x + _area.begin_width, _area.end_x + _area.end_width, _y)
    --比例为1的坐标
    local first_begin = self:getY(_area.begin_x, _area.end_x, _area.y)
    local first_end = self:getY(_area.begin_x + _area.begin_width, _area.end_x + _area.end_width, _area.y)
    _area.z = (goal_end - goal_begin) / (first_end - first_begin)
end

--[[--
        获得一个麻将的后一个的间隔
        @param _interval: 没有透视时，距离起点正常的间隔（Y轴方向）
        @param _area: 区域参数（_area.z每个像素基本缩放比例）
        @return -interval:间隔
  ]]
function C:getInterval(_interval, _area)
    local scale = _area.z
    local last_interval = 1
    local temp = math.floor(math.abs(_interval))
    local interval = (math.pow(scale, temp + 1) - scale) / (scale - 1)
    if _interval > 0 then
        return interval
    end
    return -interval
end

--退出函数
function C:onExit()
    self.otherTileImgs_ = {}
    self.otherHandImgs_ = {}
    self.discardTileImgs_ = {}
    self.openWallTileImgs_ = {}
end


return C