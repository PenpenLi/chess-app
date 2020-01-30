local C = class("HhdzZoushiLayer",BaseLayer)

local ZhupanluGridClass = import(".HhdzZhupanluGridClass")
local DaluGridClass = import(".HhdzDaluGridClass")
local XiasanluGridClass = import(".HhdzXiasanluGridClass")
local Helper = import(".HhdzHelper")

local function shakeNodeScale(node,func,tag,nOpacity)
    if not node then
        return func and func()
    end
    node:setScale(0.6)

    local t = {0.11,0.105,0.101,0.0905}
    local l = {1.20,0.80,1.10,0.90}

    for i=2,10 do
        t[i] =  0.09 - 0.008*i
        if i%2 == 0 then
            l[i] = math.min(0.94 + i*0.012,1)
        else
            l[i] = math.max(1.06 - i*0.012,1)
        end
    end
    local n = 0
    local function getScFunc()
        n = n + 1
        return cc.ScaleTo:create(t[n],l[n])
    end

    local seq = cc.Sequence:create(
            getScFunc(),
            getScFunc(),
            getScFunc(),
            getScFunc(),
            getScFunc(),
            getScFunc(),
            getScFunc(),
            getScFunc(),
            getScFunc(),
            cc.ScaleTo:create(0.01,1)
    )
    tag = tag or 99
    seq:setTag(tag)

    node:stopActionByTag(tag)
    node:runAction(seq)
end

C.RESOURCE_FILENAME = "games/hhdz/prefab/TrendLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hideSelf"}}},

	recentThumbImg = {path="box_img.recent_panel.percent_panel.thumb_img"},
	recentBlackImg = {path="box_img.recent_panel.percent_panel.black_img"},
	recentRedImg = {path="box_img.recent_panel.percent_panel.red_img"},
	recentBlackLabel = {path="box_img.recent_panel.percent_panel.black_label"},
	recentRedLabel = {path="box_img.recent_panel.percent_panel.red_label"},
	recentRedDot = {path="box_img.recent_panel.red_dot"},
	recentBlackDot = {path="box_img.recent_panel.black_dot"},
	recentListview = {path="box_img.recent_panel.listview"},

	zplPanel = {path="box_img.pailu_panel.zpl_panel"},
	dlPanel = {path="box_img.pailu_panel.dl_panel"},
	dyzlPanel = {path="box_img.pailu_panel.dyzl_panel"},
	xlPanel = {path="box_img.pailu_panel.xl_panel"},
	yylPanel = {path="box_img.pailu_panel.yyl_panel"},

	nextBlackPanel = {path="box_img.pailu_panel.next_panel.black_panel",events={{event="click",method="onClickNextBlack"}}},
	nextRedPanel = {path="box_img.pailu_panel.next_panel.red_panel",events={{event="click",method="onClickNextRed"}}},
	nextBlackCircleImg = {path="box_img.pailu_panel.next_panel.black_panel.circle_img"},
	nextBlackBallImg = {path="box_img.pailu_panel.next_panel.black_panel.ball_img"},
	nextBlackLineImg = {path="box_img.pailu_panel.next_panel.black_panel.line_img"},
	nextRedCircleImg = {path="box_img.pailu_panel.next_panel.red_panel.circle_img"},
	nextRedBallImg = {path="box_img.pailu_panel.next_panel.red_panel.ball_img"},
	nextRedLineImg = {path="box_img.pailu_panel.next_panel.red_panel.line_img"},

	redLabel = {path="box_img.pailu_panel.red_label"},
	blackLabel = {path="box_img.pailu_panel.black_label"},
	roundLabel = {path="box_img.pailu_panel.round_label"},

	typePanel = {path="box_img.type_panel"},
	typeImg = {path="box_img.type_img"},
}

C.TYPE_POS_Y = {
	[1] = 43,
	[2] = 7,
}
C.TYPE_POS_X = {
	[1] = 10,
	[2] = 92.44,
	[3] = 174.89,
	[4] = 257.33,
	[5] = 339.78,
	[6] = 422.22,
	[7] = 504.67,
	[8] = 587.11,
	[9] = 669.56,
	[10] = 752,
}

C.zplGridClass = nil
C.dlGridClass = nil
C.dyzlGridClass = nil
C.xlGridClass = nil
C.yylGridClass = nil

C.historyDataArr = nil
C.cachedHistoryDataArr = nil
C.historyTypeArr = nil
C.cachedHistoryTypeArr = nil
C.historyTypeNodeArr = nil
--是否点击预测
C.isAddForecast = false
C.dyzlForecastBlackResult = 0
C.xlForecastBlackResult = 0
C.yylForecastBlackResult = 0
C.dyzlForecastRedResult = 0
C.xlForecastRedResult = 0
C.yylForecastRedResult = 0

function C:clean()
	self.historyDataArr = {}
	self.cachedHistoryDataArr = {}
	self.historyTypeArr = {}
	self.cachedHistoryTypeArr = {}
	self.historyTypeNodeArr = {}
	self.zplGridClass:refreshHistory()
	self.dlGridClass:refreshHistory()
	self.typePanel:removeAllChildren()
	self:refreshRoundData()
	self:setHistoryPercent(0.5)
end

function C:onCreate()
	C.super.onCreate(self)

	self.recentBlackDot:setVisible(false)
	self.recentRedDot:setVisible(false)
	self.recentListview:setScrollBarEnabled(false)

	self.zplGridClass = ZhupanluGridClass.new(self.zplPanel)
	self.dlGridClass = DaluGridClass.new(self.dlPanel)
	self.dyzlGridClass = XiasanluGridClass.new(self.dyzlPanel)
	self.xlGridClass = XiasanluGridClass.new(self.xlPanel)
	self.yylGridClass = XiasanluGridClass.new(self.yylPanel)

	self.typeImg:setVisible(false)
	self.historyDataArr = {}
	self.cachedHistoryDataArr = {}
	self.historyTypeArr = {}
	self.cachedHistoryTypeArr = {}
	self.historyTypeNodeArr = {}
	self:refreshRoundData()
	self:setHistoryPercent(0.5)
	self.yPos = self.resourceNode:getPositionY()
	self.USE_ACTION = false
end

function C:show()

		C.super.show(self)
		self.isShowed = true
		self.zplGridClass:show()
		self.dlGridClass:show()
		self.dyzlGridClass:show()
		self.xlGridClass:show()
		self.yylGridClass:show()

		self.resourceNode:setPositionY(self.yPos)
		self.maskLayer:setVisible(true)
		if self.maskLayer then
			self.maskLayer:setOpacity(0)
			self.maskLayer:runAction(cc.FadeTo:create(0.35, 153))
		end
		shakeNodeScale(self.resourceNode)
end

function C:hide()
	C.super.hide(self)
	self.isShowed = false
	self.zplGridClass:hide()
	self.dlGridClass:hide()
	self.dyzlGridClass:hide()
	self.xlGridClass:hide()
	self.yylGridClass:hide()
	utils:removeTimer("hhdz.zoushitu")
end


function C:hideSelf()
	-- self.resourceNode:setPositionY(self.yPos + 10000)
	-- self.resourceNode:setScale(0)
	-- self.maskLayer:setVisible(false)
	self:hide()
end

function C:handleCachedHistory()
	local count = #self.cachedHistoryDataArr
	if count >= 20 then
		--如果大于等于20局，直接全部刷新
		for i=1,count do
			table.insert(self.historyDataArr,self.cachedHistoryDataArr[i])
			table.insert(self.historyTypeArr,self.cachedHistoryTypeArr[i])
		end
		local dataArr = self:getRecentHistoryData(70)
		local typeArr = self:getRecentHistoryType(20)
		self:refreshHistory(dataArr,typeArr)
	else
		--如果小于20局，添加方式刷新
		for i,v in ipairs(self.cachedHistoryDataArr) do
			table.insert(self.historyDataArr,v)
			self.zplGridClass:addHistory(v,false)
			self.dlGridClass:addHsitory(v,false)
			self:addListData(v,false)
		end
		for i,v in ipairs(self.cachedHistoryTypeArr) do
			table.insert(self.historyTypeArr,v)
			self:addTypeData(ctype)
		end
		self:refreshXslHistory(self.dlGridClass.daluInfoArr,false)
		self:refreshPercent()
		self:refreshNextData()
		self:refreshRoundData()
	end
	self.cachedHistoryDataArr = {}
	self.cachedHistoryTypeArr = {}
end

function C:refreshHistory( dataArr, typeArr )
	--if self.isShowed then
		self.historyDataArr = {}
		self.historyTypeArr = {}
		if dataArr then
			self.historyDataArr = self:getArrayLastItems(dataArr,70)
		end
		if typeArr then
			self.historyTypeArr = self:getArrayLastItems(typeArr,20)
		end
		--近20局走势
		self:refreshPercent()
		self:refreshListData()
		self:refreshTypeData()
		--刷新走势图
		self.zplGridClass:refreshHistory(self.historyDataArr)
		self.dlGridClass:refreshHistory(self.historyDataArr)
		self:refreshXslHistory(self.dlGridClass.daluInfoArr,false)
		--刷新下局走势
		self:refreshNextData()
		--刷新局数
		self:refreshRoundData()
	--else
	--	if dataArr then
	--		self.cachedHistoryDataArr = self:getArrayLastItems(dataArr,70)
	--	end
	--	if typeArr then
	--		self.cachedHistoryTypeArr = self:getArrayLastItems(typeArr,20)
	--	end
	--end
end

--刷新下三路
function C:refreshXslHistory(daluInfoArr,blink)
	local daluInfoArr = utils:copyTable(daluInfoArr)
	local dyzlResultArr = Helper.calculateDYZL(daluInfoArr)
	self.dyzlGridClass:refreshHistory(dyzlResultArr,blink)
	local xlResultArr = Helper.calculateXL(daluInfoArr)
	self.xlGridClass:refreshHistory(xlResultArr,blink)
	local yylResultArr = Helper.calculateYYL(daluInfoArr)
	self.yylGridClass:refreshHistory(yylResultArr,blink)
end

function C:addHistory( data, ctype )
	-- if self.isShowed then
		table.insert(self.historyDataArr,data)
		table.insert(self.historyTypeArr,ctype)
		self.zplGridClass:addHistory(data,true)
		self.dlGridClass:addHsitory(data,true)
		self:refreshXslHistory(self.dlGridClass.daluInfoArr,true)
		self:refreshPercent()
		self:addListData(data,true)
		self:addTypeData(ctype,true)
		self:refreshNextData()
		self:refreshRoundData()
	--else
	--	table.insert(self.cachedHistoryDataArr,data)
	--	table.insert(self.cachedHistoryTypeArr,ctype)
	--end
end

function C:getRecentHistoryData( count )
	local dataArr = self:getArrayLastItems(self.historyDataArr,count)
	return dataArr
end

function C:getRecentHistoryType( count )
	local dataArr = self:getArrayLastItems(self.historyTypeArr,count)
	return dataArr
end

function C:getArrayLastItems( array, count )
	local dataArr = {}
	if #array <= count then
		dataArr = utils:copyTable(array)
	else
		local index = #array-count+1
		for i=index,#array do
			table.insert(dataArr,array[i])
		end
	end
	return dataArr
end

function C:refreshPercent()
	local dataArr = self:getRecentHistoryData(20)
	local totalCount = #dataArr
	if totalCount == 0 then
		totalCount = 1
	end
	local blackCount = 0
	for i,v in ipairs(dataArr) do
		if v == 2 then
			blackCount = blackCount+1
		end
	end
	local blackPercent = blackCount/totalCount
	self:setHistoryPercent(blackPercent)
end

function C:setHistoryPercent( blackPercent )
	local percent = math.floor(blackPercent*100)
	self.recentBlackLabel:setString(string.format("%d%%",percent))
	self.recentRedLabel:setString(string.format("%d%%",100-percent))
	local thumbPosX = 135+326*blackPercent
	self.recentThumbImg:setPositionX(thumbPosX)
	self.recentBlackImg:setContentSize(thumbPosX+5,42)
	self.recentRedImg:setContentSize(601-thumbPosX,42) -- 828-227
	self.recentBlackLabel:setPositionX(thumbPosX-10)
	self.recentRedLabel:setPositionX(thumbPosX+237)
end

function C:refreshListData()
	local dataArr = self:getRecentHistoryData(20)
	self.recentListview:removeAllItems()
	local pushDot = function( listview, result )
		local item = nil
		if result == 2 then
			item = self.recentBlackDot:clone()
		else
			item = self.recentRedDot:clone()
		end
		item:setVisible(true)
		listview:pushBackCustomItem(item)
	end
	for i,v in ipairs(dataArr) do
		pushDot(self.recentListview,v)
	end
end

function C:addListData( data, blink )
	--超过20，移除前面的数据
	local popDot = function( listview )
		local count = #listview:getItems()
		if count >= 20 then
			local num = count-19
			for i=1,num do
				listview:removeItem(0)
			end
		end
	end
	popDot(self.recentListview)
	--插入最新一局数据
	local pushDot = function( listview, result )
		local item = nil
		if result == 2 then
			item = self.recentBlackDot:clone()
		else
			item = self.recentRedDot:clone()
		end
		item:setVisible(true)
		listview:pushBackCustomItem(item)
		if self.isShowed and blink then
			self:playBlinkAni(item)
		end
	end
	pushDot(self.recentListview,data)
end

function C:playBlinkAni( dot )
	local array = {}
	array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeOut:create(0.2)
    array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeIn:create(0.2)
    dot:runAction(cc.Repeat:create(cc.Sequence:create(array),3))
end

function C:refreshTypeData()
	self.typePanel:removeAllChildren(true)
	self.historyTypeNodeArr = {}
	local typeArr = self:getRecentHistoryType(20)
	for i,v in ipairs(typeArr) do
		local resname = self:getTypeRes(v)
		local index = math.floor((i+1)/2)
		if index > 10 then
			index = 10
		end
		local x = self.TYPE_POS_X[index]
		local y = self.TYPE_POS_Y[1]
		if i%2 == 0 then
			y = self.TYPE_POS_Y[2]
		end
		local item = self.typeImg:clone()
		item:loadTexture(resname,1)
		item:setPosition(x,y)
		if i==#typeArr then
			item:getChildByName("new_img"):setVisible(true)
		else
			item:getChildByName("new_img"):setVisible(false)
		end
		item:setVisible(true)
		table.insert(self.historyTypeNodeArr,item)
		self.typePanel:addChild(item)
	end
end

-- Invalid         = 0,                 -- 无效
-- Single 			= 1,                -- 散牌
-- Pair9A 			= 2,                 -- 9-A对子
-- Straight 		= 3,                 -- 顺子
-- Flush 			= 4,                 -- 同花
-- StraightFlush 	= 5,                 -- 同花顺
-- ThreeKind 		= 6,                 -- 豹子
-- Pair            = 8,                 -- 对子
function C:getTypeRes( ctype )
	local resname = "single_d.png"
	if ctype == 1 then
		resname = "single_d.png"
	elseif ctype == 2 then
		resname = "double_l.png"
	elseif ctype == 3 then
		resname = "straight_l.png"
	elseif ctype == 4 then
		resname = "flower_l.png"
	elseif ctype == 5 then
		resname = "straight_flower_l.png"
	elseif ctype == 6 then
		resname = "bomb_l.png"
	elseif ctype == 8 then
		-- resname = "double_d.png"
		resname = "double_l.png"
	end
	return resname
end

function C:addTypeData( ctype, blink )
	local lastNode = nil
	if #self.historyTypeNodeArr >= 20 then
		lastNode = table.remove(self.historyTypeNodeArr,1)
	end
	if lastNode then
		lastNode:removeFromParent(true)
	end
	local item = self.typeImg:clone()
	local resname = self:getTypeRes(ctype)
	item:loadTexture(resname,1)
	item:setVisible(true)
	table.insert(self.historyTypeNodeArr,item)
	self.typePanel:addChild(item)
	for i,v in ipairs(self.historyTypeNodeArr) do
		local index = math.floor((i+1)/2)
		local x = self.TYPE_POS_X[index]
		local y = self.TYPE_POS_Y[1]
		if i%2 == 0 then
			y = self.TYPE_POS_Y[2]
		end
		v:setPosition(x,y)
		if i==#self.historyTypeNodeArr then
			v:getChildByName("new_img"):setVisible(true)
		else
			v:getChildByName("new_img"):setVisible(false)
		end
	end
	if self.isShowed and blink then
		self:playBlinkAni(item)
	end
end

function C:refreshNextData()
	--获取下局黑预测
	local dataArr = self.dlGridClass:getForecastInfoArr(2)
	self.dyzlForecastBlackResult,self.xlForecastBlackResult,self.yylForecastBlackResult = Helper.getNextXslData(dataArr)
	if self.dyzlForecastBlackResult == 1 then
		self.nextBlackCircleImg:loadTexture("corner_circle_red.png",1)
	else
		self.nextBlackCircleImg:loadTexture("corner_circle_blue.png",1)
	end
	if self.xlForecastBlackResult == 1 then
		self.nextBlackBallImg:loadTexture("corner_ball_red.png",1)
	else
		self.nextBlackBallImg:loadTexture("corner_ball_blue.png",1)
	end
	if self.yylForecastBlackResult == 1 then
		self.nextBlackLineImg:loadTexture("corner_line_red.png",1)
	else
		self.nextBlackLineImg:loadTexture("corner_line_blue.png",1)
	end
	--获取下局红预测
	local dataArr = self.dlGridClass:getForecastInfoArr(1)
	self.dyzlForecastRedResult,self.xlForecastRedResult,self.yylForecastRedResult = Helper.getNextXslData(dataArr)
	if self.dyzlForecastRedResult == 1 then
		self.nextRedCircleImg:loadTexture("corner_circle_red.png",1)
	else
		self.nextRedCircleImg:loadTexture("corner_circle_blue.png",1)
	end
	if self.xlForecastRedResult == 1 then
		self.nextRedBallImg:loadTexture("corner_ball_red.png",1)
	else
		self.nextRedBallImg:loadTexture("corner_ball_blue.png",1)
	end
	if self.yylForecastRedResult == 1 then
		self.nextRedLineImg:loadTexture("corner_line_red.png",1)
	else
		self.nextRedLineImg:loadTexture("corner_line_blue.png",1)
	end
end

function C:onClickNextBlack( event )
	if self.isAddForecast then
		return
	end
	self.isAddForecast = true
	self.zplGridClass:addForecastData(2,function()
		self.isAddForecast = false
	end)
	self.dlGridClass:addForecastData(2)
	self.dyzlGridClass:addForecastData(self.dyzlForecastBlackResult)
	self.xlGridClass:addForecastData(self.xlForecastBlackResult)
	self.yylGridClass:addForecastData(self.yylForecastBlackResult)
end

function C:onClickNextRed( event )
	if self.isAddForecast then
		return
	end
	self.isAddForecast = true
	self.zplGridClass:addForecastData(1,function()
		self.isAddForecast = false
	end)
	self.dlGridClass:addForecastData(1)
	self.dyzlGridClass:addForecastData(self.dyzlForecastRedResult)
	self.xlGridClass:addForecastData(self.xlForecastRedResult)
	self.yylGridClass:addForecastData(self.yylForecastRedResult)
end

function C:refreshRoundData()
	local redCount = 0
	local blackCount = 0
	local totalCount = #self.historyDataArr
	for i,v in ipairs(self.historyDataArr) do
		if v == 2 then
			blackCount = blackCount+1
		else
			redCount = redCount+1
		end
	end
	self.redLabel:setString(string.format("红 %d",redCount))
	self.blackLabel:setString(string.format("黑 %d",blackCount))
	self.roundLabel:setString(string.format("局数 %d",totalCount))
end

return C