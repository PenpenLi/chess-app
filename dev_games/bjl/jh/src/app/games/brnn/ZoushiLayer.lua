local C = class("BrnnZoushiLayer",BaseLayer)

C.RESOURCE_FILENAME = "games/brnn/ZoushiLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},

	listWinDot = {path="box_img.top_panel.win_dot"},
	listLoseDot = {path="box_img.top_panel.lose_dot"},

	qinglongBar = {path="box_img.top_panel.qinglong.bar_img.bar"},
	qinglongBarLabel = {path="box_img.top_panel.qinglong.bar_img.label"},
	qinglongListview = {path="box_img.top_panel.qinglong.listview"},

	baihuBar = {path="box_img.top_panel.baihu.bar_img.bar"},
	baihuBarLabel = {path="box_img.top_panel.baihu.bar_img.label"},
	baihuListview = {path="box_img.top_panel.baihu.listview"},

	zhuqueBar = {path="box_img.top_panel.zhuque.bar_img.bar"},
	zhuqueBarLabel = {path="box_img.top_panel.zhuque.bar_img.label"},
	zhuqueListview = {path="box_img.top_panel.zhuque.listview"},

	xuanwuBar = {path="box_img.top_panel.xuanwu.bar_img.bar"},
	xuanwuBarLabel = {path="box_img.top_panel.xuanwu.bar_img.label"},
	xuanwuListview = {path="box_img.top_panel.xuanwu.listview"},

	gridWinDot = {path="box_img.center_panel.win_dot"},
	gridLoseDot = {path="box_img.center_panel.lose_dot"},
	girdListview = {path="box_img.center_panel.listview"},

	qinglongGridview = {path="box_img.center_panel.qinglong_grid"},
	baihuGridview = {path="box_img.center_panel.baihu_grid"},
	zhuqueGridview = {path="box_img.center_panel.zhuque_grid"},
	xuanwuGridview = {path="box_img.center_panel.xuanwu_grid"},

	turnLabel = {path="box_img.bottom_panel.turn_label"},
	qinglongLabel = {path="box_img.bottom_panel.qinglong_label"},
	baihuLabel = {path="box_img.bottom_panel.baihu_label"},
	zhuqueLabel = {path="box_img.bottom_panel.zhuque_label"},
	xuanwuLabel = {path="box_img.bottom_panel.xuanwu_label"},

	nextWin = {path="box_img.bottom_panel.next_win",events={{event="click",method="onClickNextWin"}}},
	nextLose = {path="box_img.bottom_panel.next_lose",events={{event="click",method="onClickNextLose"}}},
}

C.isShowed = false
C.turnCount = 0
C.qinglongCount = 0
C.baihuCount = 0
C.zhuqueCount = 0
C.xuanwuCount = 0
C.historyDataArr = nil
--{x=0,y=0,result=0}
C.qinglongGridviewDotInfoArr = nil
C.baihuGridviewDotInfoArr = nil
C.zhuqueGridviewDotInfoArr = nil
C.xuanwuGridviewDotInfoArr = nil
--是否点击预测
C.isAddForecast = false

function C:destroy()
	self.qinglongGridview:removeAllItems()
	self.baihuGridview:removeAllItems()
	self.zhuqueGridview:removeAllItems()
	self.xuanwuGridview:removeAllItems()
	self.qinglongGridviewDotInfoArr = nil
	self.baihuGridviewDotInfoArr = nil
	self.zhuqueGridviewDotInfoArr = nil
	self.xuanwuGridviewDotInfoArr = nil
end

function C:onCreate()
	C.super.onCreate(self)
	self.listWinDot:setVisible(false)
	self.listLoseDot:setVisible(false)

	self.gridWinDot:setVisible(false)
	self.gridLoseDot:setVisible(false)
	-- self.girdListview:setVisible(false)
	self.girdListview:setScrollBarEnabled(false)

	local item = ccui.Layout:create()
	item:setContentSize(cc.size(16,16))
	self.girdListview:setItemModel(item)
	for i=1,6 do
		self.girdListview:pushBackDefaultItem()
	end

	self.qinglongListview:setScrollBarEnabled(false)
	self.baihuListview:setScrollBarEnabled(false)
	self.zhuqueListview:setScrollBarEnabled(false)
	self.xuanwuListview:setScrollBarEnabled(false)

	self.qinglongGridview:setScrollBarEnabled(false)
	self.baihuGridview:setScrollBarEnabled(false)
	self.zhuqueGridview:setScrollBarEnabled(false)
	self.xuanwuGridview:setScrollBarEnabled(false)

	self.qinglongGridview:setItemModel(self.girdListview)
	self.baihuGridview:setItemModel(self.girdListview)
	self.zhuqueGridview:setItemModel(self.girdListview)
	self.xuanwuGridview:setItemModel(self.girdListview)

	self.historyDataArr = {}
	self.qinglongGridviewDotInfoArr = {}
	self.baihuGridviewDotInfoArr = {}
	self.zhuqueGridviewDotInfoArr = {}
	self.xuanwuGridviewDotInfoArr = {}
	
	self:refreshPercent()
	self:refreshTurnCount()
end

function C:show()
	C.super.show(self)
	self.isShowed = true
	self.qinglongGridview:jumpToRight()
	self.baihuGridview:jumpToRight()
	self.zhuqueGridview:jumpToRight()
	self.xuanwuGridview:jumpToRight()
end

function C:hide()
	C.super.hide(self)
	self.isShowed = false
end

function C:refreshHistory( dataArr )
	self.historyDataArr = {}
	if dataArr then
		self.historyDataArr = dataArr
	end
	self:refreshPercent()
	self:refreshListData()
	self:refreshGridData()
	self:refreshTurnCount()
end

function C:addHistory( data )
	table.insert(self.historyDataArr,data)
	self:refreshPercent()
	self:addListData(data)
	self:addGridData(data)
	self:addTurnCount(data)
end

function C:getRecentHistory( count )
	local dataArr = {}
	if #self.historyDataArr <= count then
		dataArr = self.historyDataArr
	else
		local index = #self.historyDataArr-count+1
		for i=index,#self.historyDataArr do
			table.insert(dataArr,self.historyDataArr[i])
		end
	end
	return dataArr
end

function C:refreshGridData()
	local doRefresh = function( gridview )
		gridview:removeAllItems()
		for i=1,22 do
			gridview:pushBackDefaultItem()
		end
	end

	doRefresh(self.qinglongGridview)
	doRefresh(self.baihuGridview)
	doRefresh(self.zhuqueGridview)
	doRefresh(self.xuanwuGridview)

	self.qinglongGridviewDotInfoArr = {}
	self.baihuGridviewDotInfoArr = {}
	self.zhuqueGridviewDotInfoArr = {}
	self.xuanwuGridviewDotInfoArr = {}

	for i,v in ipairs(self.historyDataArr) do
		self:insertGridviewDot(self.qinglongGridview,1,v[1],false)
		self:insertGridviewDot(self.baihuGridview,2,v[2],false)
		self:insertGridviewDot(self.zhuqueGridview,3,v[3],false)
		self:insertGridviewDot(self.xuanwuGridview,4,v[4],false)
	end

	self.qinglongGridview:jumpToRight()
	self.baihuGridview:jumpToRight()
	self.zhuqueGridview:jumpToRight()
	self.xuanwuGridview:jumpToRight()
end

function C:addGridData( data )
	self:insertGridviewDot(self.qinglongGridview,1,data[1],true)
	self:insertGridviewDot(self.baihuGridview,2,data[2],true)
	self:insertGridviewDot(self.zhuqueGridview,3,data[3],true)
	self:insertGridviewDot(self.xuanwuGridview,4,data[4],true)
	self.qinglongGridview:jumpToRight()
	self.baihuGridview:jumpToRight()
	self.zhuqueGridview:jumpToRight()
	self.xuanwuGridview:jumpToRight()
end

function C:addForecastData( result )
	if self.isAddForecast then
		return
	end
	self.isAddForecast = true
	utils:delayInvoke("brnn.forecast",2.6,function()
		self.isAddForecast = false
	end)
	self:insertGridviewDot(self.qinglongGridview,1,result,true,true)
	self:insertGridviewDot(self.baihuGridview,2,result,true,true)
	self:insertGridviewDot(self.zhuqueGridview,3,result,true,true)
	self:insertGridviewDot(self.xuanwuGridview,4,result,true,true)
	self.qinglongGridview:jumpToRight()
	self.baihuGridview:jumpToRight()
	self.zhuqueGridview:jumpToRight()
	self.xuanwuGridview:jumpToRight()
end

function C:insertGridviewDot( gridview, area, result, blink, isForecast )
	if area < 1 or area > 4 then
		return
	end
	local dot = nil
	if result == 0 then
		dot = self.gridWinDot:clone()
	else
		dot = self.gridLoseDot:clone()
	end

	local pos = self:getGridviewDotPos(gridview,area,result,isForecast)

	if #gridview:getItems() < pos.x+2 then
		gridview:pushBackDefaultItem()
	end

	local listview = gridview:getItem(pos.x)
	local item = listview:getItem(pos.y)
	if item then
		item:removeAllChildren(true)
		dot:setPosition(item:getContentSize().width/2,item:getContentSize().height/2)
		item:addChild(dot)
		--设置格子被持有了
		if isForecast then
			item.beHold = false
		else
			item.beHold = true
		end
		dot:setVisible(true)
		if self.isShowed and blink then
			self:playBlinkAni(dot,isForecast)
		end
	end
end

--x:0~n y:0~5
function C:getGridviewDotPos( gridview, area, result, isForecast )
	local infoArr = nil
	if area == 1 then
		infoArr = self.qinglongGridviewDotInfoArr
	elseif area == 2 then
		infoArr = self.baihuGridviewDotInfoArr
	elseif area == 3 then
		infoArr = self.zhuqueGridviewDotInfoArr
	elseif area == 4 then
		infoArr = self.xuanwuGridviewDotInfoArr
	end

	local x = 0
	local y = 0
	local info = {}
	local count = #infoArr
	if count > 0 then
		local lastInfo = infoArr[count]
		if lastInfo.result == result then
			--与上局结果一样,往下或往右
			if lastInfo.y <= 4 then
				if self:isEmptyGrid(gridview,lastInfo.x,lastInfo.y+1) then
					--下一格空
					x = lastInfo.x
					y = lastInfo.y+1
				else
					--往右取格子
					x = lastInfo.x+1
					y = lastInfo.y
				end
			else
				--已经是最下面一格，往右取格子
				x = lastInfo.x+1
				y = lastInfo.y
			end
		else
			--与上局结果不一样，y=0，查找x
			y = 0
			for i=count,1,-1 do
				local tempInfo = infoArr[i]
				--找到连续的第一个点，得到x，当前往右移一列
				if tempInfo.y == 0 then
					x = tempInfo.x+1
					break
				end
			end
		end
	end
	info.x = x
	info.y = y
	info.result = result
	if not isForecast then
		table.insert(infoArr,info)
	end
	return info
end

--判断某个格子是否空
function C:isEmptyGrid( gridview, x, y )
	local listview = gridview:getItem(x)
	if listview then
		local item = listview:getItem(y)
		if item then
			if item.beHold then
				return false
			end
		end
	end
	return true
end

function C:refreshListData()
	local dataArr = self:getRecentHistory(20)
	self.qinglongListview:removeAllItems()
	self.baihuListview:removeAllItems()
	self.zhuqueListview:removeAllItems()
	self.xuanwuListview:removeAllItems()
	local pushDot = function( listview, result )
		local item = nil
		if result == 0 then
			item = self.listWinDot:clone()
		else
			item = self.listLoseDot:clone()
		end
		item:setVisible(true)
		listview:pushBackCustomItem(item)
	end
	for i,v in ipairs(dataArr) do
		pushDot(self.qinglongListview,v[1])
		pushDot(self.baihuListview,v[2])
		pushDot(self.zhuqueListview,v[3])
		pushDot(self.xuanwuListview,v[4])
	end
end

function C:addListData( data )
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
	popDot(self.qinglongListview)
	popDot(self.baihuListview)
	popDot(self.zhuqueListview)
	popDot(self.xuanwuListview)
	--插入最新一局数据
	local pushDot = function( listview, result )
		local item = nil
		if result == 0 then
			item = self.listWinDot:clone()
		else
			item = self.listLoseDot:clone()
		end
		item:setVisible(true)
		listview:pushBackCustomItem(item)
		if self.isShowed then
			self:playBlinkAni(item)
		end
	end
	pushDot(self.qinglongListview,data[1])
	pushDot(self.baihuListview,data[2])
	pushDot(self.zhuqueListview,data[3])
	pushDot(self.xuanwuListview,data[4])
end

function C:playBlinkAni( dot, isForecast )
	dot:stopAllActions()
	local array = {}
	array[#array+1] = cc.DelayTime:create(0.2)
    array[#array+1] = cc.FadeOut:create(0.2)
    array[#array+1] = cc.DelayTime:create(0.2)
    array[#array+1] = cc.FadeIn:create(0.2)
    local array2 = {}
    array2[#array2+1] = cc.Repeat:create(cc.Sequence:create(array),3)
    if isForecast then
    	array2[#array2+1] = cc.DelayTime:create(0.2)
    	array2[#array2+1] = cc.RemoveSelf:create()
    end
    dot:runAction(cc.Sequence:create(array2))
end

function C:refreshPercent()
	local dataArr = self:getRecentHistory(20)
	local totalCount = #dataArr
	if totalCount == 0 then
		totalCount = 1
	end
	local qinglongCount = 0
	local baihuCount = 0
	local zhuqueCount = 0
	local xuanwuCount = 0
	for i,v in ipairs(dataArr) do
		if v[1] == 0 then
			qinglongCount = qinglongCount+1
		end
		if v[2] == 0 then
			baihuCount = baihuCount+1
		end
		if v[3] == 0 then
			zhuqueCount = zhuqueCount+1
		end
		if v[4] == 0 then
			xuanwuCount = xuanwuCount+1
		end
	end
	self:setAreaPercent(1,qinglongCount/totalCount)
	self:setAreaPercent(2,baihuCount/totalCount)
	self:setAreaPercent(3,zhuqueCount/totalCount)
	self:setAreaPercent(4,xuanwuCount/totalCount)
end

function C:refreshTurnCount()
	self.turnCount = #self.historyDataArr
	self.qinglongCount = 0
	self.baihuCount = 0
	self.zhuqueCount = 0
	self.xuanwuCount = 0
	for i,v in ipairs(self.historyDataArr) do
		if v[1] == 0 then
			self.qinglongCount = self.qinglongCount+1
		end
		if v[2] == 0 then
			self.baihuCount = self.baihuCount+1
		end
		if v[3] == 0 then
			self.zhuqueCount = self.zhuqueCount+1
		end
		if v[4] == 0 then
			self.xuanwuCount = self.xuanwuCount+1
		end
	end
	self:setAreaTurnCount(0,self.turnCount)
	self:setAreaTurnCount(1,self.qinglongCount)
	self:setAreaTurnCount(2,self.baihuCount)
	self:setAreaTurnCount(3,self.zhuqueCount)
	self:setAreaTurnCount(4,self.xuanwuCount)
end

function C:addTurnCount( data )
	self.turnCount = self.turnCount+1
	if data[1] == 0 then
		self.qinglongCount = self.qinglongCount+1
	end
	if data[2] == 0 then
		self.baihuCount = self.baihuCount+1
	end
	if data[3] == 0 then
		self.zhuqueCount = self.zhuqueCount+1
	end
	if data[4] == 0 then
		self.xuanwuCount = self.xuanwuCount+1
	end
	self:setAreaTurnCount(0,self.turnCount)
	self:setAreaTurnCount(1,self.qinglongCount)
	self:setAreaTurnCount(2,self.baihuCount)
	self:setAreaTurnCount(3,self.zhuqueCount)
	self:setAreaTurnCount(4,self.xuanwuCount)
end

--area: 1=青龙 2=白虎 3=朱雀 4=玄武  percent:0~1
function C:setAreaPercent( area, percent )
	percent = math.floor(percent*100)
	local barRes = GAME_BRNN_IMAGES_RES.."jznn_history_prog_gray.png"
	if percent >= 50 then
		barRes = GAME_BRNN_IMAGES_RES.."jznn_history_prog_red.png"
	end
	if area == 1 then
		self.qinglongBarLabel:setString(string.format("%d%%",percent))
		self.qinglongBar:setPercent(percent)
		self.qinglongBar:loadTexture(barRes)
	elseif area == 2 then
		self.baihuBarLabel:setString(string.format("%d%%",percent))
		self.baihuBar:setPercent(percent)
		self.baihuBar:loadTexture(barRes)
	elseif area == 3 then
		self.zhuqueBarLabel:setString(string.format("%d%%",percent))
		self.zhuqueBar:setPercent(percent)
		self.zhuqueBar:loadTexture(barRes)
	elseif area == 4 then
		self.xuanwuBarLabel:setString(string.format("%d%%",percent))
		self.xuanwuBar:setPercent(percent)
		self.xuanwuBar:loadTexture(barRes)
	end
end

--area: 0=局数 1=青龙胜数 2=白虎胜数 3=朱雀胜数 4=玄武胜数
function C:setAreaTurnCount( area, count )
	count = tostring(count)
	if area == 0 then
		self.turnLabel:setString("局数 "..count)
	elseif area == 1 then
		self.qinglongLabel:setString("青龙 "..count)
	elseif area == 2 then
		self.baihuLabel:setString("白虎 "..count)
	elseif area == 3 then
		self.zhuqueLabel:setString("朱雀 "..count)
	elseif area == 4 then
		self.xuanwuLabel:setString("玄武 "..count)
	end
end

function C:onClickNextWin( event )
	self:addForecastData(0)
end

function C:onClickNextLose( event )
	self:addForecastData(1)
end

return C