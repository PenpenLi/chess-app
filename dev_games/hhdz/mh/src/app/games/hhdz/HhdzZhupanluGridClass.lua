local C = class("HhdzZhupanluGridClass",ViewBaseClass)

C.BINDING = {
	listview1 = {path="listview_1"},
	listview2 = {path="listview_2"},
	redDot = {path="red_dot"},
	blackDot = {path="black_dot"},
	gridview = {path="gridview"},
}

C.isShowed = false
C.index = 0

function C:onCreate()
	C.super.onCreate(self)

	self.redDot:setPosition(16,16)
	self.redDot:setVisible(false)
	self.blackDot:setPosition(16,16)
	self.blackDot:setVisible(false)

	local initListview = function( listview )
		local item = ccui.Layout:create()
		item:setContentSize(cc.size(32,32))
		listview:setItemModel(item)
		for i=1,6 do
			listview:pushBackDefaultItem()
		end
		listview:setScrollBarEnabled(false)
		listview:setVisible(false)
	end
	initListview(self.listview1)
	initListview(self.listview2)
	self.listview1:setVisible(false)
	self.listview2:setVisible(false)
	self.gridview:setScrollBarEnabled(false)
	self:refreshHistory()
end

function C:show()
	self.isShowed = true
	self.gridview:jumpToRight()
end

function C:hide()
	self.isShowed = false
end

function C:refreshHistory( dataArr )
	local doRefresh = function( gridview )
		gridview:removeAllItems()
		for i=1,10 do
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
	self.index = 0
	if dataArr then
		for i,v in ipairs(dataArr) do
			self:addHistory(v,false)
		end
	end
end

function C:addHistory( data, blink )
	self.index = self.index+1
	self:insertHistory(self.index,data,blink)
	if blink then
		self.gridview:jumpToRight()
	end
end

function C:addForecastData( data, callback )
	local index = self.index+1
	self:insertHistory(index,data,true,callback)
	self.gridview:jumpToRight()
end

function C:insertHistory( index, data, blink, callback )
	local dot = nil
	if data == 2 then
		dot = self.blackDot:clone()
	else
		dot = self.redDot:clone()
	end

	local pos = self:getGridviewDotPos(index)

	if #self.gridview:getItems() < pos.x+1 then
		local list = nil
		local index = #self.gridview:getItems()+1
		if index%2 == 0 then
			list = self.listview2:clone()
		else
			list = self.listview1:clone()
		end
		list:setVisible(true)
		self.gridview:pushBackCustomItem(list)
	end

	local listview = self.gridview:getItem(pos.x)
	local item = listview:getItem(pos.y)
	if item then
		item:addChild(dot)
		dot:setVisible(true)
		if self.isShowed and blink then
			self:playBlinkAni(dot,callback)
		end
	end
end

--x:0~n y:0~5
function C:getGridviewDotPos( index )
	local x = 0
	local y = 0
	if index > 0 then
		x = math.ceil(index/6)-1
		y = (index-1)%6
	end
	return cc.p(x,y)
end

function C:playBlinkAni( dot, callback )
	dot:stopAllActions()
	local array = {}
	array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeOut:create(0.2)
    array[#array+1] =  cc.DelayTime:create(0.2)
    array[#array+1] =  cc.FadeIn:create(0.2)
    local array2 = {}
    array2[#array2+1] = cc.Repeat:create(cc.Sequence:create(array),3)
    if callback then
    	array2[#array2+1] =  cc.DelayTime:create(0.2)
    	array2[#array2+1] = cc.CallFunc:create(function()
    		callback()
    	end)
    	array2[#array2+1] =  cc.RemoveSelf:create()
    end
    dot:runAction(cc.Sequence:create(array2))
end

return C