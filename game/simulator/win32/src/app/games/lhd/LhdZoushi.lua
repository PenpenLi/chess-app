local lhUIZoushi = { }
local daplu_h = 6
local daplu_w = 12
local luMax = 40
local xiaoplu_length = 20
local ui = nil
local blinkTag = 302
local isyuce = true 
local m_long = 1;
local m_hu = 2;
local m_he = 3;

function lhUIZoushi:initzoushiUI(parent)
    ui = parent
    self:initUI()
end

function lhUIZoushi:initzoushi(Recorddata)

    local len = Recorddata.longwinnum + Recorddata.huwinnum + Recorddata.hewinnum;

    local d = { }
    for i = 1, len do
        if Recorddata[i] then
            table.insert(d, Recorddata[i].win)
        end
    end

    Recorddata.record = d

    self:initdata(Recorddata.record)
end 

-- 添加一个点击监听
function lhUIZoushi:addTouchEventListener(btn,func,ignoreAction,isUShake,ignorePlaying)
    local bp = nil 
    local isShake = true
    local function buttonFunc (sender,eventType) 
        if eventType == ccui.TouchEventType.began then
            if not ignorePlaying then 
                --audio.playSound("games/lhd/res/music/click.mp3")
            end 
            if not ignoreAction then   
                UIBase:btnRunAmplifyAction(sender) 
            end 
            if isUShake then 
                bp = cc.p(sender:getTouchBeganPosition()) 
                isShake = true 
            end
        elseif eventType == ccui.TouchEventType.moved then 
            if not ignoreAction then 
                UIBase:btnRunAmplifyAction(sender) 
            end 
            if isUShake then 
                local np = cc.p(sender:getTouchMovePosition())
                isShake = self:isShake(bp,np)
            end 
            --sender:setScale(1)
        elseif eventType == ccui.TouchEventType.canceled then
            if not ignoreAction then 
                UIBase:btnRunReduceAction(sender) 
            end 
        elseif eventType == ccui.TouchEventType.ended then 
            if not ignoreAction then  
                UIBase:btnRunReduceAction(sender) 
            end 
        end

        if isUShake then 
            if not isShake then 
                return 
            end 
        end 

        if func then 
            func(sender,eventType)
        end 

    end    
    
    btn:setTouchEnabled(true)   
    btn:addTouchEventListener(buttonFunc)
    return btn 
end 

function lhUIZoushi:initUI()
    local rootNode = ui.lhResultPanel
    print("初始化路单。。。。。。")
    self.Image_Title = ui.trendView:getChildByName("Image_Title")
    self.Label_Long = self.Image_Title:getChildByName("Label_Long")
    self.Label_Hu = self.Image_Title:getChildByName("Label_Hu")
    self.ProgressBar_Long = ui.trendView:getChildByName("ProgressBar_long")
    self.ProgressBar_Hu = ui.trendView:getChildByName("ProgressBar_hu")
    self.win_hu = ui.trendView:getChildByName("Image_11"):getChildByName("huNode"):getChildByName("Label_win_hu")
    self.win_long = ui.trendView:getChildByName("Image_11"):getChildByName("longNode"):getChildByName("Label_win_long")
    self.win_he = ui.trendView:getChildByName("Image_11"):getChildByName("heNode"):getChildByName("Label_win_he")
    self.win_zong = ui.trendView:getChildByName("Image_11"):getChildByName("AllNode"):getChildByName("Label_win_zong")
    local Pailuda = ui.trendView:getChildByName("Pailuda");
    local yuce_long = Pailuda:getChildByName("yuce_long")
    local yuce_hu = Pailuda:getChildByName("yuce_hu")
    self:addTouchEventListener(yuce_long, handler(self, self.nextLong), true);
    self:addTouchEventListener(yuce_hu, handler(self, self.nextHu), true);
    --yuce_long:addTouchEventListener(handler(self, self.nextLong))
    --yuce_long:addTouchEventListener(handler(self, self.nextHu))

    self.zhuzailu = { }
    self.xiaopailu = { }
    self.dalu = { }
    self.dayanlu = { }
    self.xiaolu = { }
    self.zhanglanglu = { }

    self.dayanlu.yuce_red = yuce_long:getChildByName("yuce_rd")
    self.dayanlu.yuce_black = yuce_hu:getChildByName("yuce_bd")
    self.xiaolu.yuce_red = yuce_long:getChildByName("yuce_rx")
    self.xiaolu.yuce_black = yuce_hu:getChildByName("yuce_bx")
    self.zhanglanglu.yuce_red = yuce_long:getChildByName("yuce_rz")
    self.zhanglanglu.yuce_black = yuce_hu:getChildByName("yuce_bz")

    local dapailuNode = Pailuda:getChildByName("ScrollView_15"):getChildByName("PailuZong");
    for i = 1, daplu_w do
        local node = dapailuNode:getChildByName("dapailu_" .. i)
        for j = 1, daplu_h do
            local dapl = node:getChildByName("Image_" .. j)
            -- cclogError({"看这里!!!!!!!!!!!!",i,j,node,dapl})
            dapl:setVisible(false)
            table.insert(self.zhuzailu, dapl)
        end
    end

    local PailuxiaoNode = ui.trendView:getChildByName("Pailuxiao");
    for i = 1, xiaoplu_length do
        local xiaopl = PailuxiaoNode:getChildByName("xiaopailu_" .. i):setVisible(false)
        xiaopl.zs_item = xiaopl:getChildByName("zs_item")
        -- xiaopl.Image_new =  ui:seekWidgetByNameRoot(xiaopl,"Image_new"):setVisible(false)
        table.insert(self.xiaopailu, xiaopl)
    end

    -- 大路
    daluNode = Pailuda:getChildByName("ScrollView_16"):getChildByName("dalu");
    for i = 1, luMax do
        local node = daluNode:getChildByName("dalu_" .. i)
        local daluWdata = { }
        for j = 1, 6 do
            local dl = node:getChildByName("Image_" .. j):setVisible(false)
            dl.text = dl:getChildByName("BitmapLabel_11")
            dl.text.numValue = 0
            dl.data = -1
            table.insert(daluWdata, dl)
        end
        table.insert(self.dalu, daluWdata)
    end

    self.zhupaluGundong = Pailuda:getChildByName("ScrollView_15"):setScrollBarEnabled(false);
    self.daluGundong = Pailuda:getChildByName("ScrollView_16"):setScrollBarEnabled(false);
    self.dayanluGundong = Pailuda:getChildByName("ScrollView_17"):setScrollBarEnabled(false);
    self.xiaoluGundong = Pailuda:getChildByName("ScrollView_18"):setScrollBarEnabled(false);
    self.zhanglangluGundong = Pailuda:getChildByName("ScrollView_19"):setScrollBarEnabled(false);
    -- 大眼路
    local dayanluNode = self.dayanluGundong:getChildByName("dayanlu");
    for i = 1, luMax do
        local node = dayanluNode:getChildByName("dayanlu_" .. i)
        local dayanluWdata = { }
        for j = 1, 6 do
            local dl = node:getChildByName("Image_" .. j):setVisible(false)
            dl.data = -1
            table.insert(dayanluWdata, dl)
        end
        table.insert(self.dayanlu, dayanluWdata)
    end
    -- 小路
    local xiaoluNode = self.xiaoluGundong:getChildByName("xiaolu");
    for i = 1, luMax do
        local node = xiaoluNode:getChildByName("xiaolu_" .. i)
        local dayanluWdata = { }
        for j = 1, 6 do
            local dl = node:getChildByName("Image_" .. j):setVisible(false)
            dl.data = -1
            table.insert(dayanluWdata, dl)
        end
        table.insert(self.xiaolu, dayanluWdata)
    end
    -- 蟑螂路
    local zllNode = self.zhanglangluGundong:getChildByName("zhanglanglu");
    for i = 1, luMax do
        local node = zllNode:getChildByName("zhanglanglu_" .. i)
        local dayanluWdata = { }
        for j = 1, 6 do
            local dl = node:getChildByName("Image_" .. j):setVisible(false)
            dl.data = -1
            table.insert(dayanluWdata, dl)
        end
        table.insert(self.zhanglanglu, dayanluWdata)
    end
    ui.lhResultPanel.state = 0
    -- 状态初始值
    self.historicalData = { }
    self.showData = { }
end

local delayTag = 308
-- 更新函数  外部调用
function lhUIZoushi:updateData(data, time)
    print("结果结算..........", data, time)

    time = - time or 0
    if time > 10 then
        return
    elseif time <= 10 and time >= 4 then
        time = 0
    else
        time = 0
    end
    local delay = cc.DelayTime:create(time)
    local callback = cc.CallFunc:create( function()
        self:addData(data)
        self:show()
        self:loadYucePic_new()
        self:newzhuzailuBlink()
        self:newallOtherluBlink()
        -- 更新主界面走势
        --ui:updateZoushiUI(data)
        dataLoading = false
    end )
    local action = cc.Sequence:create(delay, callback)
    action:setTag(delayTag)
    self.win_zong:stopActionByTag(delayTag)
    self.win_zong:runAction(action)
end

function lhUIZoushi:addData(newdata)
    if ui.lhResultPanel.state == 0 then
        print("未初始化 缓存数据")
        ui.lhResultPanel.cache = newdata
        return
    end
    if #self.historicalData >= 70 then
        table.remove(self.historicalData, 1)
    end
    table.insert(self.historicalData, newdata)
    self:zhuzailuAddData(newdata)
    self:daluAddData(newdata)
end

function lhUIZoushi:getData()
    if self.historicalData then
        return self.historicalData
    else
        return false
    end
end

function lhUIZoushi:testludan(num, showtype)
    for i = 1, num do
        table.insert(self.historicalData, showtype)
    end
end

function lhUIZoushi:initdata(data)

    self.historicalData = { }
    self.showData = { }
    -- 各路显示所参照的数据
    self.historicalData = data

    print("初始化走势长度前。。。。。。", #self.historicalData)
    -- 测试 路单
    --[[
    self.historicalData = {}
    self:testludan(9,2)
    self:testludan(2,3)
    self:testludan(9,2)
    self:testludan(2,3)
    table.insert(self.historicalData,1)
    table.insert(self.historicalData,3)
    table.insert(self.historicalData,1)
    self:testludan(2,2)
    self:testludan(2,3)
    self:testludan(6,2)
    table.insert(self.historicalData,3)
    self:testludan(9,2)
    self:testludan(6,3)
    self:testludan(5,2)
    self:testludan(8,3)
    self:testludan(4,2)
    self:testludan(1,3)
    self:testludan(1,2)
   --]]
    -- 测试 路单
    while #self.historicalData > 70 do
        table.remove(self.historicalData, 1)
    end
    print("初始化走势长度。。。。后。。", #self.historicalData)
    self:zhuzailuInitData()
    self:daluInitData()

    self:show()
    self:loadYucePic_new()
    ui.lhResultPanel.state = 1
    -- 已经初始化
    if ui.lhResultPanel.cache then
        print("初始化 拿缓存")
        self:addData(ui.hhResultPanel.cache)
        ui.lhResultPanel.cache = { }
    end

    -- 更新主面板的走势
    --for i, v in ipairs(self.historicalData) do
    --    ui:updateZoushiUI(v)
    --end
end

-- 显示
function lhUIZoushi:show()
    self:zhuzailuShow()
    self:xiaopailuShow()
    self:daluShow()
    -- self:loaddaluPic()
    self:allOtherluInitData()
    -- 大路完毕后运行
    self:allOtherluShow()

    self:setProgressBar()
end

-- 最新闪烁
function lhUIZoushi:newzhuzailuBlink()
    local action = cc.Blink:create(2, 2)
    action:setTag(blinkTag)
    self.zhuzailu[self.zhuzailu.curPos]:stopActionByTag(blinkTag)
    self.zhuzailu[self.zhuzailu.curPos]:runAction(action)
end

-- 最新otherlu闪烁
function lhUIZoushi:newotherluBlink(viewlist)
    if viewlist.numW and #viewlist.uidata > 0 then
        local action = cc.Blink:create(2, 2)
        action:setTag(blinkTag)
        viewlist[viewlist.numW][viewlist.numH]:stopActionByTag(blinkTag)
        viewlist[viewlist.numW][viewlist.numH]:runAction(action)
    end
end

-- 最新allotherlu闪烁
function lhUIZoushi:newallOtherluBlink()
    self:newotherluBlink(self.dalu)
    self:newotherluBlink(self.dayanlu)
    self:newotherluBlink(self.xiaolu)
    self:newotherluBlink(self.zhanglanglu)
end
--- ====  zhuzai  ====
-- zhuzai init 数据
function lhUIZoushi:zhuzailuInitData()
    self.zhuzailu.uidata = { }
    for i, v in ipairs(self.historicalData) do
        table.insert(self.zhuzailu.uidata, v)
    end

    while #self.zhuzailu.uidata > 70 do
        table.remove(self.zhuzailu.uidata, 1)
    end

end
-- zhuzai add 数据
function lhUIZoushi:zhuzailuAddData(data)
    table.insert(self.zhuzailu.uidata, data)
    if #self.zhuzailu.uidata > 70 then
        table.remove(self.zhuzailu.uidata, 1)
    end
end

-- zhuzai路   移动范围 390起步 50递增4次到590止  0开始 8.35% 递增
function lhUIZoushi:zhuzailuShow()
    self.zhuzailu.curPos = 0
    for i = 1, daplu_h * daplu_w do
        if self.zhuzailu.uidata then
            if self.zhuzailu.uidata[i] ~= nil then
                if self.zhuzailu.uidata[i] == m_he then
                    self.zhuzailu[i]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_dot_item_he.png", 1)
                elseif self.zhuzailu.uidata[i] == m_long then
                    self.zhuzailu[i]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_dot_item_long.png", 1)
                elseif self.zhuzailu.uidata[i] == m_hu then
                    self.zhuzailu[i]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_dot_item_hu.png", 1)
                end
                self.zhuzailu[i]:setVisible(true)
                self.zhuzailu.curPos = i
            else
                self.zhuzailu[i]:setVisible(false)
            end
        end
    end
    --print("lhUIZoushi:zhuzailuShow()  ：   ", self.zhuzailu.curPos);
    local moveDis = math.floor(self.zhuzailu.curPos / 6)
    if moveDis >= 11 then
        self.zhupaluGundong:setInnerContainerSize(cc.size(530, 270))
    elseif moveDis > 7 then
        -- self.zhupaluGundong:scrollToPercentHorizontal((moveDis-7)*8.35,1,true)
        self.zhupaluGundong:setInnerContainerSize(cc.size(354 + 43 *(moveDis - 6), 270))
    else
        self.zhupaluGundong:setInnerContainerSize(cc.size(354, 270))
    end
    self.zhupaluGundong:scrollToPercentHorizontal(100, 1, true)
end
-- 小牌路
function lhUIZoushi:xiaopailuShow()
    local len = #self.historicalData
    for i = 1, 20 do
        if self.historicalData[len + i - 20] ~= nil then
            if self.historicalData[len + i - 20] == m_he then
                self.xiaopailu[i].zs_item:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_dot_item_he.png", 1)
            elseif self.historicalData[len + i - 20] == m_long then
                self.xiaopailu[i].zs_item:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_dot_item_long.png", 1)
            elseif self.historicalData[len + i - 20] == m_hu then
                self.xiaopailu[i].zs_item:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_dot_item_hu.png", 1)
            end
            self.xiaopailu[i]:setVisible(true)
            --[[ self.xiaopailu[i].Image_new:setVisible(false)
            if  i == 20 then
                self.xiaopailu[i].Image_new:setVisible(true)
            end]]
        else
            self.xiaopailu[i]:setVisible(false)
            --[[if  self.xiaopailu[i-1] then
                self.xiaopailu[i-1].Image_new:setVisible(true)
            end]]
        end
    end
end

-- 创建下路数据模型
function lhUIZoushi:initShowData()
    self.showData = { }
    local numW = 1
    --  31
    local numH = 1
    --  6
    self.showData.numW = numW
    self.showData.numH = numH
    self.showData[numW] = { }
    self.showData[numW][numH] = { }
    self.showData[numW][numH].numValue = 0
    for i, data in ipairs(self.dalu.uidata) do
        -- print("大路 数据   值  为。。。........数据模型....。",i,data)

        while true do
            if data == m_he then
                -- 为  he
                self.showData[numW][numH].numValue = self.showData[numW][numH].numValue + 1
                break
            end
            if numH == 1 and not self.showData[numW][numH].data then
                -- 初始原点
                self.showData[numW][numH].data = data
                -- print("大路    初始值  为。。",numW,numH,self.showData[numW][numH].data)

                break
            end
            if self.showData[numW][numH].data == data then
                numH = numH + 1
            else
                numW = numW + 1
                numH = 1
                self.showData[numW] = { }
            end

            self.showData[numW][numH] = { }
            self.showData[numW][numH].numValue = 0

            self.showData[numW][numH].data = data
            -- print("大路    值  为。。",numW,numH,self.showData[numW][numH].data)
            self.showData.numW = numW
            self.showData.numH = numH
            break
        end

    end
end

--- ====  大路 显示 ====
-- 大路 init 数据
function lhUIZoushi:daluInitData()
    self.dalu.uidata = { }
    for i, v in ipairs(self.historicalData) do
        table.insert(self.dalu.uidata, v)
    end

    while #self.dalu.uidata > 70 do
        table.remove(self.dalu.uidata, 1)
    end
    self:initShowData()
end
-- da add 数据
function lhUIZoushi:daluAddData(data)
    table.insert(self.dalu.uidata, data)
    if #self.dalu.uidata > 70 then
        table.remove(self.dalu.uidata, 1)
    end
    self:initShowData()
end

-- 移动对应的大路数据一列
function lhUIZoushi:moveDaluData(notdisplay)
    local tempdata = self.dalu.uidata

    local value = self.dalu[1][1].data
    -- print("牌路 第一列删除。、、、、、",#tempdata,value,tempdata[1])
    local i = 1
    while true do
        if not tempdata[i] then
            self.dalu.uidata = { }
            self.dalu.numW = 1
            self.dalu.numH = 1
            break
        end
        if tempdata[i] == value then
            -- print("sh 杀出 删除值为。。。", tempdata[i] ,#self.dalu.uidata)
            table.remove(tempdata, 1)
        elseif tempdata[i] == 1 then
            table.remove(tempdata, 1)
        else
            break
        end

    end
    if not tempdata then
        return
    end
    -- print("牌路 第一列删除。、、、、、  后",#tempdata ,value)
    self:daluShow(notdisplay)
end
-- 刷新对应的大路数据
function lhUIZoushi:daluShow(notdisplay)

    for i = 1, luMax do
        for j = 1, 6 do
            self.dalu[i][j].data = -1
            self.dalu[i][j].text.numValue = 0
        end
    end
    if not self.dalu.uidata then
        return
    end
    local numW = 1
    --  31
    local numH = 1
    --  6
    local tempW = 0
    local startPos = 1
    -- 初始原点
    self.dalu.numW = numW
    self.dalu.numH = numH
    for i, data in ipairs(self.dalu.uidata) do
        -- print("大路 数据   值  为。。。............。",data,i)
        while true do
            if data == m_he then
                -- wei  he
                --print("和赢===============================", self.dalu[self.dalu.numW][self.dalu.numH].text.numValue, self.dalu[self.dalu.numW][self.dalu.numH].text.numValue + 1);
                self.dalu[self.dalu.numW][self.dalu.numH].text.numValue = self.dalu[self.dalu.numW][self.dalu.numH].text.numValue + 1
                startPos = startPos + 1
                --self.dalu[numW][numH].data = data;
                break
            end
            if i == startPos then
                -- 初始原点
                self.dalu[numW][numH].data = data
                break
            end
            if self.dalu[numW][numH].data == data then
                if self.dalu[numW][numH + 1] == nil or self.dalu[numW][numH + 1].data ~= -1 then
                    -- 到顶
                    -- print("到顶。。。。。。",numW,numH,data)
                    local movedis = 1
                    movedis = numW + movedis
                    -- if numH == 1 then
                    --     self:moveDaluData(notdisplay)
                    --     return
                    -- end
                    while true do
                        if self.dalu[movedis][numH].data == -1 then
                            self.dalu[movedis][numH].data = data
                            self.dalu.numW = movedis
                            self.dalu.numH = numH
                            -- print("到顶 找到。。。 ",numW,movedis,numH,data)
                            break
                        else
                            movedis = movedis + 1
                            if movedis > luMax - 1 then
                                self:moveDaluData(notdisplay)
                                return
                                -- self.daluViewList[index][movedis][numH].data = data.cbWinOrLose
                                -- break
                            end
                        end
                    end
                    break
                else
                    numH = numH + 1
                end
            else
                numW = 1
                while self.dalu[numW][1].data ~= -1 do
                    numW = numW + 1
                    if numW > luMax - 1 then
                        -- 越界
                        self:moveDaluData(notdisplay)
                        return
                        -- break
                    end
                end
                numH = 1
            end
            self.dalu[numW][numH].data = data
            self.dalu.numW = numW
            self.dalu.numH = numH
            break
        end
    end
    if not notdisplay then
        self:updateDalu()
    end
    print("lhUIZoushi:daluShow(notdisplay)    :   ", self.dalu.numW);
    if self.dalu.numW >= 39 then
        self.daluGundong:setInnerContainerSize(cc.size(881, 140))
    elseif self.dalu.numW > 24 then
        -- self.daluGundong:scrollToPercentHorizontal((self.dalu.numW-24)*6.25,1,true)
        self.daluGundong:setInnerContainerSize(cc.size(529 + 22 *(self.dalu.numW - 23), 140))
    else
        self.daluGundong:setInnerContainerSize(cc.size(529, 140))
    end
    self.daluGundong:scrollToPercentHorizontal(100, 1, true)
end

-- 更新大路 
function lhUIZoushi:updateDalu()
    for i = 1, luMax do
        for j = 1, 6 do
            -- print("大路 数据 值为",i ,j ,self.dalu[i][j].data)

            self.dalu[i][j]:setVisible(true)
            self.dalu[i][j].text:setVisible(false)
            --print("显示赢的图标***********************************", self.dalu[i][j].text.numValue);
            if self.dalu[i][j].text.numValue > 0 then
                -- he
                --print("显示和赢图标===============================");
                self.dalu[i][j]:loadTexture(GAME_LHD_IMAGES_RES.."history/jilu_he1.png", 1)
                self.dalu[i][j].text:setVisible(true)
                self.dalu[i][j].text:setString(self.dalu[i][j].text.numValue)
            end
            if self.dalu[i][j].data == m_long then
                self.dalu[i][j]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_4.png", 1)
            elseif self.dalu[i][j].data == m_hu then
                self.dalu[i][j]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_4.png", 1)
            else
                self.dalu[i][j]:setVisible(false)
            end
        end
    end
end

--- ====  大眼路 xiao zlang 显示 ====

function lhUIZoushi:allOtherluInitData()
    self:otherluInitData(self.dayanlu, 1)
    self:otherluInitData(self.xiaolu, 2)
    self:otherluInitData(self.zhanglanglu, 3)
end
-- init 数据
function lhUIZoushi:otherluInitData(viewlist, offset)

    viewlist.uidata = { }
    viewlist.startPos_w = 1 + offset
    -- 起始大路列数
    viewlist.startPos_h = 2
    -- 起始大路行数
    -- print(offset,"其他路  起始  参照点 。。。计算前。",viewlist.startPos_w,viewlist.startPos_h)
    -- print("大路  2  2  值、、",self.dalu[viewlist.startPos_w][viewlist.startPos_h].data)
    if self.showData[viewlist.startPos_w] then
        if not self.showData[viewlist.startPos_w][viewlist.startPos_h] then
            viewlist.startPos_w = viewlist.startPos_w + 1
            viewlist.startPos_h = 1
        end
    else
        -- viewlist.numW = 1
        -- viewlist.numH = 1
    end
    -- print(offset,"其他路  起始  参照点 。。。。",viewlist.startPos_w,viewlist.startPos_h)
end

-- 显示所有其他路
function lhUIZoushi:allOtherluShow(notdisplay)

    self:RefDaluLen()
    self:otherluShow_new(self.dayanlu, 1, notdisplay)
    self:otherluShow_new(self.xiaolu, 2, notdisplay)
    self:otherluShow_new(self.zhanglanglu, 3, notdisplay)
end

-- 移动对应的大眼路数据一列
function lhUIZoushi:moveOtherluData(viewlist, offset, notdisplay)
    local tempdata = viewlist.uidata
    -- print("牌路 第一列删除。、、、、、",#tempdata)
    local value = viewlist[1][1].data
    while true do
        local i = 1
        if not tempdata[i] then
            viewlist.uidata = { }
            break
        end
        if tempdata[i] == value then
            -- print("sh 杀出 删除值为。。。", tempdata[i].cbWinOrLose ,#self.daluViewList[index].uidata)
            table.remove(tempdata, 1)
        else
            break
        end

    end
    if not tempdata then
        return
    end
    self:loadOtherlu(viewlist, offset, notdisplay)
end

-- 获得对应的路数据
function lhUIZoushi:otherluShow_new(viewlist, offset, notdisplay)
    -- 黑1  红2
    viewlist.uidata = { }
    local i = viewlist.startPos_w
    local j = viewlist.startPos_h
    while self.showData[i] do

        while self.showData[i][j] do
            if j == 1 then
                -- 等于1 的时候
                -- print("第一行、、、、、、",j,self.dalu[i-1].len,self.dalu[i-1].len)
                if self.showData[i - 1].len == self.showData[i - offset - 1].len then
                    -- 齐

                    -- print("齐。。。。   红",tempW)
                    table.insert(viewlist.uidata, 1)
                elseif self.showData[i - 1].len ~= self.showData[i - offset - 1].len then
                    -- 不
                    -- print("不 ，，齐。。。。  黑",tempW)
                    table.insert(viewlist.uidata, 2)
                end
            else
                -- 一行以上的时候
                -- print("第后面  记行、、、、、、",j)
                if self.showData[i - offset][j] then
                    -- 有粒
                    -- print("有 ，，粒。。。。   红",tempW)
                    table.insert(viewlist.uidata, 1)
                else
                    -- 无粒
                    if not self.showData[i - offset][j - 1] and j >= 3 then
                        -- print("无 ，，粒。。。。 红",tempW)
                        table.insert(viewlist.uidata, 1)
                    else
                        -- print("无 ，，粒。。。。   黑",tempW)
                        table.insert(viewlist.uidata, 2)
                    end
                end
            end
            j = j + 1
        end
        i = i + 1
        j = 1
    end
    -- print("显示的  小路 为。。。。。",offset)

    if not notdisplay then
        -- self:loadOtherlu_new(viewlist,offset,notdisplay)
        self:loadOtherlu(viewlist, offset, notdisplay)
    end

end

-- 移动对应的大眼路数据一列
function lhUIZoushi:moveOtherluData(viewlist, offset, notdisplay)
    local tempdata = viewlist.uidata
    -- print("牌路 第一列删除。、、、、、",#tempdata)
    local value = viewlist[1][1].data
    while true do
        local i = 1
        if not tempdata[i] then
            viewlist.uidata = { }
            break
        end
        if tempdata[i] == value then
            -- print("sh 杀出 删除值为。。。", tempdata[i].cbWinOrLose ,#self.daluViewList[index].uidata)
            table.remove(tempdata, 1)
        else
            break
        end

    end
    if not tempdata then
        return
    end
    self:loadOtherlu(viewlist, offset, notdisplay)
end

-- 刷新对应的大眼路数据
function lhUIZoushi:loadOtherlu(viewlist, offset, notdisplay)
    -- 黑1  红2

    for i = 1, luMax do
        for j = 1, 6 do
            viewlist[i][j].data = -1
        end
    end
    local numW = 1
    --  31
    local numH = 1
    --  6

    local tempW = 0
    local startPos = 1
    -- 初始原点
    for i, data in ipairs(viewlist.uidata) do
        -- print("qt 路 数据   值  为。。。。",data,i,offset)
        while true do
            if i == startPos then
                -- 初始原点
                viewlist[numW][numH].data = data
                viewlist.numW = numW
                viewlist.numH = numH
                break
            end

            if viewlist[numW][numH].data == data then
                if viewlist[numW][numH + 1] == nil or viewlist[numW][numH + 1].data ~= -1 then
                    -- 越界
                    local movedis = 1
                    movedis = numW + movedis
                    -- if numH == 1 then
                    --     self:moveOtherluData(viewlist,offset)
                    --     return
                    -- end
                    while true do
                        if viewlist[movedis][numH].data == -1 then
                            viewlist[movedis][numH].data = data
                            viewlist.numW = movedis
                            viewlist.numH = numH
                            -- print("越界 找到。。。 ",numW,movedis,numH)
                            break
                        else
                            movedis = movedis + 1
                            if movedis > luMax - 1 then
                                movedis = luMax - 1
                                self:moveOtherluData(viewlist, offset)
                                return
                                -- self.daluViewList[index][movedis][numH].data = data.cbWinOrLose
                                -- break
                            end
                        end
                    end
                    break
                else
                    numH = numH + 1
                end
            else
                numW = 1

                while viewlist[numW][1].data ~= -1 do
                    numW = numW + 1
                    if numW > luMax - 1 then
                        -- 越界
                        numW = luMax - 1
                        self:moveOtherluData(viewlist, offset)
                        return
                        -- break
                    end
                end
                numH = 1
            end
            viewlist[numW][numH].data = data
            viewlist.numW = numW
            viewlist.numH = numH
            break
        end
    end
    if not notdisplay then
        self:updateOtherlu(viewlist, offset)
    end
    local movelist = { }
    if offset == 1 then
        movelist = self.dayanluGundong
    elseif offset == 2 then
        movelist = self.xiaoluGundong
    elseif offset == 3 then
        movelist = self.zhanglangluGundong
    end
    if viewlist.numW then
        local num = math.floor(viewlist.numW / 2)
        if num >= 19 then
            movelist:setInnerContainerSize(cc.size(440, movelist:getContentSize().height))
        elseif num > 11 then
            -- self.dayanluGundong:scrollToPercentHorizontal  ((viewlist.numW-24)*12.4,1,true)
            movelist:setInnerContainerSize(cc.size(265 + 22 *(num - 11), movelist:getContentSize().height))
        else
            movelist:setInnerContainerSize(cc.size(265, movelist:getContentSize().height))
        end
        movelist:scrollToPercentHorizontal(100, 1, true)
    end

end

-- 更新大眼路
function lhUIZoushi:updateOtherlu(viewlist, offset)
    for i = 1, luMax do
        for j = 1, 6 do
            --print("大路 数据 值为",i ,j ,viewlist[i][j].data)
            if viewlist[i][j].data == m_long then
                viewlist[i][j]:setVisible(true)
                viewlist[i][j]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_bz_" .. offset .. ".png", 1)
            elseif viewlist[i][j].data == m_hu then
                viewlist[i][j]:setVisible(true)
                viewlist[i][j]:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_rz_" .. offset .. ".png", 1)
            else
                viewlist[i][j]:setVisible(false)
            end
        end
    end
end

-- 刷新取得大路列数的有值长度
function lhUIZoushi:RefDaluLen()
    local i = 1
    local j = 1
    while true do
        self.showData[i].len = 0
        while true do
            if self.showData[i][j] then
                self.showData[i].len = j

                j = j + 1
            else
                break
            end
        end
        -- print("c長度    jisuan計算，，，，",i ,self.showData[i].len)
        i = i + 1
        j = 1
        if not self.showData[i] then
            return
        end
    end
    -- print("c長度    jisuan計算....",i,self.dalu[i].len)

end


-- 下局hong
function lhUIZoushi:nextLong()
    self:nextState(true)
end

-- 下局hei
function lhUIZoushi:nextHu()
    self:nextState(false)
end
local moveDis = 0
-- 47.5 每格
-- 下局预测
function lhUIZoushi:nextState(isWin)
    -- if not isyuce or  dataLoading  or not self.dalu.uidata then return
    -- end
    if not isyuce or not self.dalu.uidata then return end
    -- print("预测。。。。。",isWin)
    isyuce = false
    local newdata = { }
    if isWin then
        newdata = m_long
    else
        newdata = m_hu
    end
    self:zhuzailuAddData(newdata)
    self:daluAddData(newdata)
    --
    self:zhuzailuShow()

    -- self:loaddaluPic()

    self:daluShow()
    self:allOtherluInitData()
    self:allOtherluShow()
    self:newzhuzailuBlink()
    self:newallOtherluBlink()

    self:zhuzailuInitData()
    self:daluInitData()

    local delay = cc.DelayTime:create(2.2)
    local callback = cc.CallFunc:create( function()
        isyuce = true
        self:show()
    end )
    local action = cc.Sequence:create(delay, callback)
    action:setTag(131011)
    self.Image_Title:stopActionByTag(131011)
    self.Image_Title:runAction(action)
end

function lhUIZoushi:loadYucePic_new()
    local a = #self.dayanlu.uidata
    local b = #self.xiaolu.uidata
    local c = #self.zhanglanglu.uidata
    -- print("预测 准备。。。。前",a,self.dayanlu.uidata[a],self.xiaolu.uidata[b],self.zhanglanglu.uidata[c])
    local newdata = { }
    newdata = 2
    -- hu
    self:daluAddData(newdata)
    self:allOtherluInitData()
    self:allOtherluShow(true)
    a = #self.dayanlu.uidata
    b = #self.xiaolu.uidata
    c = #self.zhanglanglu.uidata
    -- print("预测 准备。。。。后",a,#self.dayanlu.uidata,self.dayanlu.uidata[a],self.xiaolu.uidata[b],self.zhanglanglu.uidata[c])
    if self.dayanlu.uidata[a] == m_hu then
        self.dayanlu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_1.png", 1)
        self.dayanlu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_1.png", 1)
    elseif self.dayanlu.uidata[a] == m_long then
        self.dayanlu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_1.png", 1)
        self.dayanlu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_1.png", 1)
    else
        self.dayanlu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
        self.dayanlu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    if self.xiaolu.uidata[b] == m_hu then
        self.xiaolu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_2.png", 1)
        self.xiaolu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_2.png", 1)
    elseif self.xiaolu.uidata[b] == m_long then
        self.xiaolu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_2.png", 1)
        self.xiaolu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_2.png", 1)
    else
        self.xiaolu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
        self.xiaolu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    if self.zhanglanglu.uidata[c] == m_hu then
        self.zhanglanglu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_3.png", 1)
        self.zhanglanglu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_3.png", 1)
    elseif self.zhanglanglu.uidata[c] == m_long then
        self.zhanglanglu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_3.png", 1)
        self.zhanglanglu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_3.png", 1)
    else
        self.zhanglanglu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
        self.zhanglanglu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    self:daluInitData()
end
-- 预测图标更新
function lhUIZoushi:loadYucePic()
    local newdata = { }
    newdata = 3
    -- hu
    self:daluAddData(newdata)
    -- self:loaddaluPic(true)
    self:daluShow(true)
    self:allOtherluInitData()
    self:allOtherluShow(true)
    if self.dayanlu.numW then
        local dayanluValue = self.dayanlu[self.dayanlu.numW][self.dayanlu.numH].data
        if dayanluValue == m_hu then
            self.dayanlu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_1.png", 1)
        elseif dayanluValue == m_long then
            self.dayanlu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_1.png", 1)
        end
    else
        self.dayanlu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    if self.xiaolu.numW then
        if self.xiaolu[self.xiaolu.numW][self.xiaolu.numH].data == m_hu then
            self.xiaolu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_2.png", 1)
        elseif self.xiaolu[self.xiaolu.numW][self.xiaolu.numH].data == m_long then
            self.xiaolu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_2.png", 1)
        end
    else
        self.xiaolu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    if self.zhanglanglu.numW then
        if self.zhanglanglu[self.zhanglanglu.numW][self.zhanglanglu.numH].data == m_hu then
            self.zhanglanglu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_3.png", 1)
        elseif self.zhanglanglu[self.zhanglanglu.numW][self.zhanglanglu.numH].data == m_long then
            self.zhanglanglu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_3.png", 1)
        end
    else
        self.zhanglanglu.yuce_black:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    self:daluInitData()
    newdata = 2
    -- long
    self:daluAddData(newdata)
    -- self:loaddaluPic(true)
    self:daluShow(true)
    self:allOtherluInitData()
    self:allOtherluShow(true)
    if self.dayanlu.numW then
        if self.dayanlu[self.dayanlu.numW][self.dayanlu.numH].data == m_hu then
            self.dayanlu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_1.png", 1)
        elseif self.dayanlu[self.dayanlu.numW][self.dayanlu.numH].data == m_long then
            self.dayanlu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_1.png", 1)
        end
    else
        self.dayanlu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    if self.xiaolu.numW then
        if self.xiaolu[self.xiaolu.numW][self.xiaolu.numH].data == m_hu then
            self.xiaolu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_2.png", 1)
        elseif self.xiaolu[self.xiaolu.numW][self.xiaolu.numH].data == m_long then
            self.xiaolu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_2.png", 1)
        end
    else
        self.xiaolu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    if self.zhanglanglu.numW then
        if self.zhanglanglu[self.zhanglanglu.numW][self.zhanglanglu.numH].data == m_hu then
            self.zhanglanglu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_hu_3.png", 1)
        elseif self.zhanglanglu[self.zhanglanglu.numW][self.zhanglanglu.numH].data == m_long then
            self.zhanglanglu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_img_long_3.png", 1)
        end
    else
        self.zhanglanglu.yuce_red:loadTexture(GAME_LHD_IMAGES_RES.."history/lh_bg_tm.png", 1)
    end
    self:daluInitData()

end

-- 取得20局long胜率
function lhUIZoushi:getlongPercent()
    local len = #self.historicalData
    local longwin = 0
    local huwin = 0
    local hewin = 0
    for i = 0, 19 do
        if self.historicalData[len - i] then
            if self.historicalData[len - i] == m_long then
                longwin = longwin + 1
            elseif self.historicalData[len - i] == m_hu then
                huwin = huwin + 1
            elseif self.historicalData[len - i] == m_he then
                hewin = hewin + 1
            end
        end
    end


    if len > 20 then
        return math.floor(longwin *(100 /(20 - hewin)))
    else
        return math.floor(longwin *(100 /(len - hewin)))
    end

end

-- 显示输赢
function lhUIZoushi:showWinOrloseResult()
    local len = #self.historicalData
    local longwin = 0
    local huwin = 0
    local hewin = 0
    for i = 1, len do
        if self.historicalData[i] then
            if self.historicalData[i] == m_long then
                longwin = longwin + 1
            elseif self.historicalData[i] == m_hu then
                huwin = huwin + 1
            elseif self.historicalData[i] == m_he then
                hewin = hewin + 1
            end
        end
    end
    self.win_long:setString(longwin)
    self.win_hu:setString(huwin)
    self.win_he:setString(hewin)
    self.win_zong:setString(longwin + huwin + hewin)
end

-- 设置显示条 和 局数 
function lhUIZoushi:setProgressBar()

    local longPercent = self:getlongPercent()
    print(longPercent)
    self.Label_Long:setString(longPercent .. "%")
    -- self.ProgressBar_Long:setPercent(longPercent)
    self.ProgressBar_Long:setPercent(50)
    self.Label_Hu:setString((100 - longPercent) .. "%")
    -- self.ProgressBar_Hu:setPercent(100-longPercent)
    self.ProgressBar_Hu:setPercent(50)
    -- self.Image_Title:setPositionX(longPercent*7.98+120)
    --self.Image_Title:setPositionX(50 * 7.98 + 120)
    self:showWinOrloseResult()
end
function lhUIZoushi:clear()
    self.historicalData = { }
    self.xiaopailu = { }
    self.zhuzailu = { }
    self.dalu = { }
    self.dayanlu = { }
    self.xiaolu = { }
    self.zhanglanglu = { }
    self.showData = { }
end
return lhUIZoushi
