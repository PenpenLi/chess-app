local C = class("HhdzXiasanluGridClass",ViewBaseClass)

C.BINDING = {
	listview1 = {path="listview_1"},
	listview2 = {path="listview_2"},
	redDot = {path="red_dot"},
	blackDot = {path="black_dot"},
	gridview = {path="gridview"},
}

C.isShowed = false
C.luInfoArr = nil

function C:onCreate()
	C.super.onCreate(self)
	self.redDot:setPosition(4,4)
	self.redDot:setVisible(false)
	self.blackDot:setPosition(4,4)
	self.blackDot:setVisible(false)

	local initListview = function( listview )
		local item = ccui.Layout:create()
		item:setContentSize(cc.size(8,8))
		listview:setItemModel(item)
		for i=1,6 do
			listview:pushBackDefaultItem()
		end
		listview:setVisible(false)
		listview:setScrollBarEnabled(false)
	end

	initListview(self.listview1)
	initListview(self.listview2)
	self.listview1:setVisible(false)
	self.listview2:setVisible(false)
	self.historyDataArr = {}
	self.luInfoArr = {}
	self.gridview:setScrollBarEnabled(false)
end

function C:show()
	self.isShowed = true
	self.gridview:jumpToRight()
end

function C:hide()
	self.isShowed = false
end

function C:refreshHistory( dataArr, blink )
	if dataArr then
		self:refreshGridData(dataArr,blink)
	end
end

function C:refreshGridData( dataArr, blink)
	local doRefresh = function( gridview )
		gridview:removeAllItems()
		for i=1, 32 do
			local list = nil
			if i%2 == 0 then
				list = self.listview2:clone()
			else
				list = self.listview1:clone()
			end
			list:setVisible(true)
			gridview:pushBackCustomItem(list)
		end
	end
	doRefresh(self.gridview)
	self.luInfoArr = {}
	for i,v in ipairs(dataArr) do
		if i == #dataArr then
			self:insertGridviewDot(v,blink,true)
		else
			self:insertGridviewDot(v,false,true)
		end
	end
	self.gridview:jumpToRight()
end

function C:addForecastData( data )
	self:insertGridviewDot(data,true,false)
	self.gridview:jumpToRight()
end

function C:insertGridviewDot( result, blink, hold )
	local dot = nil
	if result == 2 then
		dot = self.blackDot:clone()
	else
		dot = self.redDot:clone()
	end
	local info = self:getGridviewDotInfo(result)
	if hold then
		table.insert(self.luInfoArr,info)
	end
	if #self.gridview:getItems() < info.col then
		local list1 = self.listview1:clone()
		list1:setVisible(true)
		self.gridview:pushBackCustomItem(list1)
		local list2 = self.listview2:clone()
		list2:setVisible(true)
		self.gridview:pushBackCustomItem(list2)
	end
	local listview = self.gridview:getItem(info.col-1)
	local item = listview:getItem(info.row-1)
	if item then
		item:removeAllChildren(true)
		item:addChild(dot)
		--设置格子被持有了
		item.beHold = hold
		dot:setVisible(true)
		if self.isShowed and blink then
			if hold == false then
				self:playBlinkAni(dot,true)
			else
				self:playBlinkAni(dot,false)
			end
		end
	end
end

--info:{row=x,col=x,result=x,logicRow=x,logicCol=x}
--row:1~6 col:1~n   logicRow:1~n logicCol:1~n
function C:getGridviewDotInfo( result )
	local row = 1
	local col = 1
	local logicRow = 1
	local logicCol = 1
	local info = {}
	local count = #self.luInfoArr
	if count > 0 then
		local lastInfo = self.luInfoArr[count]
		if lastInfo.result == result then
			--与上局结果一样,往下或往右
			logicCol = lastInfo.logicCol
			logicRow = lastInfo.logicRow+1
			if lastInfo.row <= 5 then
				if self:isEmptyGrid(lastInfo.col,lastInfo.row+1) then
					--下一格空
					col = lastInfo.col
					row = lastInfo.row+1
				else
					--往右取格子
					col = lastInfo.col+1
					row = lastInfo.row
				end
			else
				--已经是最下面一格，往右取格子
				col = lastInfo.col+1
				row = lastInfo.row
			end
		else
			--与上局结果不一样，y=0，查找x
			row = 1
			col = lastInfo.logicCol+1
			logicCol = col
		end
	end
	info.row = row
	info.col = col
	info.logicRow = logicRow
	info.logicCol = logicCol
	info.result = result
	return info
end

--判断某个格子是否空
function C:isEmptyGrid( col, row )
	local listview = self.gridview:getItem(col-1)
	if listview then
		local item = listview:getItem(row-1)
		if item then
			if item.beHold then
				return false
			end
		end
	end
	return true
end

function C:playBlinkAni( dot, remove )
	dot:stopAllActions()
	local array = {}
	array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeOut:create(0.2)
    array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeIn:create(0.2)
    local array2 = {}
    array2[#array2+1] = cc.Repeat:create(cc.Sequence:create(array),3)
    if remove then
    	array2[#array2+1] =  cc.DelayTime:create(0.2)
    	array2[#array2+1] =  cc.RemoveSelf:create()
    end
    dot:runAction(cc.Sequence:create(array2))
end

return C