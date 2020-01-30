--[[    author:Joseph
    time:2019-12-23 19:00:16
]]
local C = class("BjlTrendMap", BaseLayer)

C.RESOURCE_FILENAME = "games/bjl/prefab/BjlLdLayer.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
    backBtn = { path = "count_lbs.back_btn", events = { { event = "click", method = "onClickBackBtn" } } },
    banker_count_label = { path = "count_lbs.banker_count" },
    player_count_label = { path = "count_lbs.player_count" },
    tie_count_label = { path = "count_lbs.tie_count" },
    banker_pair_count_label = { path = "count_lbs.banker_pair_count" },
    player_pair_count_label = { path = "count_lbs.player_pair_count" },
    all_count_label = { path = "count_lbs.all_count" },
    DOT_PAPA = { path = "dots" },
    MAP_ZPL = { path = "maps.map_ZPL.qd" },
    MAP_DL = { path = "maps.map_DL.qd" },
    MAP_DYL = { path = "maps.map_DYL.qd" },
    MAP_XYL = { path = "maps.map_XYL.qd" },
    MAP_YYL = { path = "maps.map_YYL.qd" },
    ZPL_Z = { path = "dots.ZPL_Z" },
    ZPL_X = { path = "dots.ZPL_X" },
    ZPL_H = { path = "dots.ZPL_H" },
    DL_Z = { path = "dots.DL_Z" },
    DL_X = { path = "dots.DL_X" },
    DYL_Z = { path = "dots.DYL_Z" },
    DYL_X = { path = "dots.DYL_X" },
    XYL_Z = { path = "dots.XYL_Z" },
    XYL_X = { path = "dots.XYL_X" },
    YYL_Z = { path = "dots.YYL_Z" },
    YYL_X = { path = "dots.YYL_X" },
    WZ_1 = { path = "wenlu.w1z" },
    WZ_2 = { path = "wenlu.w2z" },
    WZ_3 = { path = "wenlu.w3z" },
    WX_1 = { path = "wenlu.w1x" },
    WX_2 = { path = "wenlu.w2x" },
    WX_3 = { path = "wenlu.w3x" },
    XH_1 = { path = "xian_hong.zxh" },
    XH_2 = { path = "xian_hong.hh" },
    XH_3 = { path = "xian_hong.dh" },
    XH_4 = { path = "xian_hong.zxl" },
    XH_5 = { path = "xian_hong.hl" },
    XH_6 = { path = "xian_hong.dl" },
}
--
local ROAD_START = {
    cc.p(15, 165), --ZPL
    cc.p(12, 138), --DL
    cc.p(6.5, 83), --DYL
    cc.p(6.5, 83), --XYL
    cc.p(6.5, 83) --YYL
}

local DOT_SIZE = {
    30.5,
    24.9,
    14.2,
    14.2,
    14.2
}
local COLUMN_LIMIT = {
    18,
    39,
    21,
    21,
    21
}

local COUNT = {
    ["banker"] = 0,
    ["player"] = 0,
    ["tie"] = 0,
    ["banker_pair"] = 0,
    ["player_pair"] = 0,
    ["all"] = 0
}

function C:onCreate()
    C.super.onCreate(self)
    self.yPos = self.resourceNode:getPositionY()
end

function C:show()
    C.super.show(self)

    self.resourceNode:setPositionY(self.yPos)
    self.maskLayer:setVisible(true)
    if self.maskLayer then
        self.maskLayer:setOpacity(0)
        self.maskLayer:runAction(cc.FadeTo:create(0.35, 153))
    end
end

function C:hide()
    C.super.hide(self)
end

function C:onClickBackBtn()
    self:hide()
end
--[[    @desc: set ZPL and show count data
    author:Joey
    time:2019-12-25 10:52:35
    --@data: original Net Data on results history
    @return: nil
]]
function C:setZpl(data)
    COUNT = {
        ["banker"] = 0,
        ["player"] = 0,
        ["tie"] = 0,
        ["banker_pair"] = 0,
        ["player_pair"] = 0,
        ["all"] = 0,
        col = 0
    }
    self.ZPL_index = 0;
    if data and #data > 0 then
        for data_index = 1, #data do
            self:addDotZPL(data_index, data)
        end
    end
    return COUNT;
end

function C:insertZPLdot(s)
    self:addDotZPL(1 + self.ZPL_index, nil, s)
    return COUNT;
end

function C:addDotZPL(data_index, data, unit)
    local switch = {
        [1] = function()
            COUNT["banker"] = COUNT["banker"] + 1
            return self.ZPL_Z:clone()
        end,
        [2] = function()
            COUNT["player"] = COUNT["player"] + 1
            return self.ZPL_X:clone()
        end,
        [3] = function()
            COUNT["tie"] = COUNT["tie"] + 1
            return self.ZPL_H:clone()
        end
    }
    local swFun = {
        [0] = function(dot)
            dot:getChildByName("zp"):setVisible(false)
            dot:getChildByName("xp"):setVisible(false)
        end,
        [1] = function(dot)
            dot:getChildByName("zp"):setVisible(true)
            dot:getChildByName("xp"):setVisible(false)
            COUNT["banker_pair"] = COUNT["banker_pair"] + 1
        end,
        [2] = function(dot)
            dot:getChildByName("zp"):setVisible(false)
            dot:getChildByName("xp"):setVisible(true)
            COUNT["player_pair"] = COUNT["player_pair"] + 1
        end,
        [3] = function(dot)
            dot:getChildByName("zp"):setVisible(true)
            dot:getChildByName("xp"):setVisible(true)
            COUNT["banker_pair"] = COUNT["banker_pair"] + 1
            COUNT["player_pair"] = COUNT["player_pair"] + 1
        end
    }

    if data then
        local i = data_index - 1
        local dot = switch[data[data_index].resultpos]()
        dot:setPosition(math.floor(i / 6) * DOT_SIZE[1], -(i % 6) * DOT_SIZE[1])
        swFun[data[data_index].resultpair](dot)
        COUNT.all = COUNT.all + 1
        self.MAP_ZPL:addChild(dot)
        COUNT.col = math.floor(i / 6)
    elseif unit then
        local i = data_index - 1
        local dot = switch[unit.resultpos]()
        dot:setPosition(math.floor(i / 6) * DOT_SIZE[1], -(i % 6) * DOT_SIZE[1])
        swFun[unit.resultpair](dot)
        COUNT.all = COUNT.all + 1
        self.MAP_ZPL:addChild(dot)
        COUNT.col = math.floor(i / 6)
    end
    self.ZPL_index = data_index

    self.banker_count_label:setString(COUNT.banker)
    self.player_count_label:setString(COUNT.player)
    self.tie_count_label:setString(COUNT.tie)
    self.banker_pair_count_label:setString(COUNT.banker_pair)
    self.player_pair_count_label:setString(COUNT.player_pair)
    self.all_count_label:setString(COUNT.all)

    local overOffset = COUNT.col - COLUMN_LIMIT[1] + 1
    if overOffset > 0 then
        self.MAP_ZPL:setPositionX(ROAD_START[1].x - overOffset * DOT_SIZE[1])
    else
        self.MAP_ZPL:setPositionX(ROAD_START[1].x)
    end
end
--[[    @desc: set dalu
    author:Joey
    time:2019-12-25 12:01:44
    --@data: original Net Data
    @return: nil
]]
function C:setDl(data)
    self.lastDL = {
        result = nil,
        tieCount = 0,
        limit = 5,
        col_count = 0
    }
    self.indexDotofDL = {
        x = -1,
        y = 0
    }
    self.dotMatrixDL = {}
    if not data then return; end
    for k, v in pairs(data) do
        self:addDLdot(v.resultpos)
    end
end

function C:insertDLdot(s)
    self:addDLdot(s.resultpos)
end

function C:addDLdot(result)
    local switch = {
        [1] = function()
            return self.DL_Z:clone()
        end,
        [2] = function()
            return self.DL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastDL.result then
            self.indexDotofDL.y = self.indexDotofDL.y + 1
        else
            self.indexDotofDL.y = 0
            self.indexDotofDL.x = self.indexDotofDL.x + 1
            self.lastDL.limit = 5
        end

        local col = self.indexDotofDL.x
        local row = self.indexDotofDL.y
        if self.lastDL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixDL[col * 6 + l] then
                    self.lastDL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastDL.limit then
            col = col + row - self.lastDL.limit
            row = self.lastDL.limit
        end

        dot:setPosition(col * DOT_SIZE[2], -row * DOT_SIZE[2])
        self.MAP_DL:addChild(dot)
        self.dotMatrixDL[col * 6 + row] = true

        self.lastDL.result = result
        if 0 ~= self.lastDL.tieCount then
            dot:getChildByName("lb"):setVisible(true)
            dot:getChildByName("lb"):setString(self.lastDL.tieCount)
            self.lastDL.tieCount = 0
        end

        self.lastDL.col_count = (col > self.lastDL.col_count) and col or self.lastDL.col_count
        local overOffset = self.lastDL.col_count - COLUMN_LIMIT[2] + 1
        if overOffset > 0 then
            self.MAP_DL:setPositionX(ROAD_START[2].x - overOffset * DOT_SIZE[2])
        else
            self.MAP_DL:setPositionX(ROAD_START[2].x)
        end
    else
        self.lastDL.tieCount = self.lastDL.tieCount + 1
    end
end
--[[    @desc: 下三路
    author:Joey
    time:2019-12-26 10:32:44
    --@data: 网络报文
    @return: 无返回
]]
function C:setXsl(data)
    ---无和局队列只记录形状 --lastR保存庄闲结果
    self.DataWithoutTie = {}
    self.lastR = nil

    local noTieData = self.DataWithoutTie

    if not data then return; end
    for k, v in pairs(data) do
        local vR = v.resultpos
        if vR ~= 3 then
            if self.lastR == vR then
                noTieData[#noTieData] = noTieData[#noTieData] + 1
            else
                noTieData[#noTieData + 1] = 1
            end
            self.lastR = vR
        end
    end
    self:setDYL(noTieData)
    self:setXYL(noTieData)
    self:setYYL(noTieData)
    return noTieData;
end
--更新无和局队列数据
function C:addDotForXsl(s)
    local noTieData = self.DataWithoutTie
    local vR = s.resultpos
    if vR ~= 3 then
        if self.lastR == vR then
            noTieData[#noTieData] = noTieData[#noTieData] + 1
        else
            noTieData[#noTieData + 1] = 1
        end
        self.lastR = vR
    end
    return noTieData;
end
--问路
function C:setAskLane()
    local askLaneArr = {}
    for i = 1, 3 do
        if self.DataWithoutTie[#self.DataWithoutTie - i] then
        if 1 == self.lastR then
                if 1 == (1 + self.DataWithoutTie[#self.DataWithoutTie]) - self.DataWithoutTie[#self.DataWithoutTie - i] then
                    askLaneArr[i] = -1
                else
                    askLaneArr[i] = 1
                end
            else
                if self.DataWithoutTie[#self.DataWithoutTie] == self.DataWithoutTie[#self.DataWithoutTie - i] then
                    askLaneArr[i] = 1
                else
                    askLaneArr[i] = -1
                end
            end
            self["WZ_" .. i]:setPositionY(askLaneArr[i] * 19)
            self["WX_" .. i]:setPositionY(-askLaneArr[i] * 19)
        end
    end
    return askLaneArr;
end


--[[    @desc: 大眼路
    author:Joey
    time:2019-12-26 15:38:43
    --@dld: 处理过的无“和”局形状数列
    @return:
]]
function C:setDYL(dld)
    local dylData = {}
    if dld and #dld > 0 then
        for k = 1, #dld do
            if nil ~= dld[k - 1] then
                for i = 1, dld[k] do
                    if i == 1 then
                        if dld[k - 1] and dld[k - 2] then
                            if dld[k - 1] == dld[k - 2] then
                                table.insert(dylData, 1)
                            else
                                table.insert(dylData, 2)
                            end
                        end
                    else
                        if 1 == i - dld[k - 1] then
                            table.insert(dylData, 2)
                        else
                            table.insert(dylData, 1)
                        end
                    end
                end
            end
        end
    end

    self.lastDYL = {
        result = nil,
        limit = 5,
        col_count = 0
    }
    self.indexDotofDYL = {
        x = -1,
        y = 0
    }
    self.dotMatrixDYL = {}

    if not dylData then return; end
    for k, v in pairs(dylData) do
        self:addDYLdot(v)
    end
end

function C:insertDYLdot(s)
    local noTieData = self.DataWithoutTie
    self.MAP_DYL:removeAllChildren();
    self:setDYL(noTieData)
end

function C:addDYLdot(result)
    local switch = {
        [1] = function()
            return self.DYL_Z:clone()
        end,
        [2] = function()
            return self.DYL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastDYL.result then
            self.indexDotofDYL.y = self.indexDotofDYL.y + 1
        else
            self.indexDotofDYL.y = 0
            self.indexDotofDYL.x = self.indexDotofDYL.x + 1
            self.lastDYL.limit = 5
        end

        local col = self.indexDotofDYL.x
        local row = self.indexDotofDYL.y
        if self.lastDYL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixDYL[col * 6 + l] then
                    self.lastDYL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastDYL.limit then
            col = col + row - self.lastDYL.limit
            row = self.lastDYL.limit
        end

        dot:setPosition(col * DOT_SIZE[3], -row * DOT_SIZE[3])
        self.MAP_DYL:addChild(dot)
        self.dotMatrixDYL[col * 6 + row] = true
        self.lastDYL.result = result

        self.lastDYL.col_count = (col > self.lastDYL.col_count) and col or self.lastDYL.col_count
        local overOffset = self.lastDYL.col_count - COLUMN_LIMIT[3] + 1
        if overOffset > 0 then
            self.MAP_DYL:setPositionX(ROAD_START[3].x - overOffset * DOT_SIZE[3])
        else
            self.MAP_DYL:setPositionX(ROAD_START[3].x)
        end
    end
end
--[[    @desc: 小眼路
    author:Joey
    time:2019-12-26 17:41:07
    --@dld: 处理过的无“和”局数列
    @return:
]]
function C:setXYL(dld)
    local xylData = {}
    if dld and #dld > 0 then
        for k = 1, #dld do
            if nil ~= dld[k - 2] then
                for i = 1, dld[k] do
                    if i == 1 then
                        if dld[k - 2] and dld[k - 3] then
                            if dld[k - 2] == dld[k - 3] then
                                table.insert(xylData, 1)
                            else
                                table.insert(xylData, 2)
                            end
                        end
                    else
                        if 1 == i - dld[k - 2] then
                            table.insert(xylData, 2)
                        else
                            table.insert(xylData, 1)
                        end
                    end
                end
            end
        end
    end

    self.lastXYL = {
        result = nil,
        limit = 5,
        col_count = 0
    }
    self.indexDotofXYL = {
        x = -1,
        y = 0
    }
    self.dotMatrixXYL = {}

    if not xylData then return; end
    for k, v in pairs(xylData) do
        self:addXYLdot(v)
    end
end

function C:insertXYLdot(s)
    local noTieData = self.DataWithoutTie
    self.MAP_XYL:removeAllChildren();
    self:setXYL(noTieData)
end

function C:addXYLdot(result)
    local switch = {
        [1] = function()
            return self.XYL_Z:clone()
        end,
        [2] = function()
            return self.XYL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastXYL.result then
            self.indexDotofXYL.y = self.indexDotofXYL.y + 1
        else
            self.indexDotofXYL.y = 0
            self.indexDotofXYL.x = self.indexDotofXYL.x + 1
            self.lastXYL.limit = 5
        end

        local col = self.indexDotofXYL.x
        local row = self.indexDotofXYL.y
        if self.lastXYL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixXYL[col * 6 + l] then
                    self.lastXYL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastXYL.limit then
            col = col + row - self.lastXYL.limit
            row = self.lastXYL.limit
        end

        dot:setPosition(col * DOT_SIZE[4], -row * DOT_SIZE[4])
        self.MAP_XYL:addChild(dot)
        self.dotMatrixXYL[col * 6 + row] = true
        self.lastXYL.result = result

        self.lastXYL.col_count = (col > self.lastXYL.col_count) and col or self.lastXYL.col_count
        local overOffset = self.lastXYL.col_count - COLUMN_LIMIT[4] + 1
        if overOffset > 0 then
            self.MAP_XYL:setPositionX(ROAD_START[4].x - overOffset * DOT_SIZE[4])
        else
            self.MAP_XYL:setPositionX(ROAD_START[4].x)
        end
    end
end

--[[    @desc: gadzadLO
    author:Joey
    time:2019-12-26 18:04:42
    --@dld: 处理过的无“和”局数列
    @return:
]]
function C:setYYL(dld)
    local yylData = {}
    if dld and #dld > 0 then
        for k = 1, #dld do
            if nil ~= dld[k - 3] then
                for i = 1, dld[k] do
                    if i == 1 then
                        if dld[k - 3] and dld[k - 4] then
                            if dld[k - 3] == dld[k - 4] then
                                table.insert(yylData, 1)
                            else
                                table.insert(yylData, 2)
                            end
                        end
                    else
                        if 1 == i - dld[k - 3] then
                            table.insert(yylData, 2)
                        else
                            table.insert(yylData, 1)
                        end
                    end
                end
            end
        end
    end
    self.lastYYL = {
        result = nil,
        limit = 5,
        col_count = 0
    }
    self.indexDotofYYL = {
        x = -1,
        y = 0
    }
    self.dotMatrixYYL = {}

    if not yylData then return end
    for k, v in pairs(yylData) do
        self:addYYLdot(v)
    end
end

function C:insertYYLdot(s)
    local noTieData = self.DataWithoutTie
    self.MAP_YYL:removeAllChildren();
    self:setYYL(noTieData)
end

function C:addYYLdot(result)
    local switch = {
        [1] = function()
            return self.YYL_Z:clone()
        end,
        [2] = function()
            return self.YYL_X:clone()
        end,
        [3] = function()
            return nil
        end
    }

    local dot = switch[result]()
    if dot then
        if result == self.lastYYL.result then
            self.indexDotofYYL.y = self.indexDotofYYL.y + 1
        else
            self.indexDotofYYL.y = 0
            self.indexDotofYYL.x = self.indexDotofYYL.x + 1
            self.lastYYL.limit = 5
        end

        local col = self.indexDotofYYL.x
        local row = self.indexDotofYYL.y
        if self.lastYYL.limit == 5 then
            for l = row, 5 do
                if self.dotMatrixYYL[col * 6 + l] then
                    self.lastYYL.limit = l - 1
                    break
                end
            end
        end
        if row > self.lastYYL.limit then
            col = col + row - self.lastYYL.limit
            row = self.lastYYL.limit
        end

        dot:setPosition(col * DOT_SIZE[5], -row * DOT_SIZE[5])
        self.MAP_YYL:addChild(dot)
        self.dotMatrixYYL[col * 6 + row] = true
        self.lastYYL.result = result

        self.lastYYL.col_count = (col > self.lastYYL.col_count) and col or self.lastYYL.col_count
        local overOffset = self.lastYYL.col_count - COLUMN_LIMIT[5] + 1
        if overOffset > 0 then
            self.MAP_YYL:setPositionX(ROAD_START[5].x - overOffset * DOT_SIZE[5])
        else
            self.MAP_YYL:setPositionX(ROAD_START[5].x)
        end
    end
end
--设置限红
function C:setBetLimit(t)
    for i = 1, 6 do
        if self["XH_" .. i] then
            self["XH_" .. i]:setString(tonumber(t[i]) / MONEY_SCALE)
        end
    end
end

return C