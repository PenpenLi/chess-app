local C = class("RolledAnnounceLayer",ViewBase)
RolledAnnounceLayer = C

C.RESOURCE_FILENAME = "common/RollingAnnounceNode.csb"
C.RESOURCE_BINDING = {
	box = {path="box"},
	container = {path="box.container"},
	listview = {path="box.container.listview"},
	textLabel = {path="box.text_label"},
	idLabel = {path="box.id_label"},
	gameLabel = {path="box.game_label"},
	moneyLabel = {path="box.money_label"},
	textImg={path="box.text_img"},
}

C.parentLayer = nil
C.posY = 540
C.isRolling = false

function C:onCreate()
	self.textLabel:setVisible(false)
	self.idLabel:setVisible(false)
	self.gameLabel:setVisible(false)
	self.moneyLabel:setVisible(false)
	self.textImg:setVisible(false)
	self.listview:removeAllItems()
	self.listview:setScrollBarEnabled(false)
end

function C:setAnnounceParentAndPosY( parent, posY )
	self.parentLayer = parent
	self.posY = posY
end

function C:show( info )
	if self.isRolling then
		return
	end

	if info["styleid"] ~= dataManager.styleId and info["styleid"] ~= 0 then
		return
	end

	if self.parentLayer == nil then
		return
	end
	dump(info,"show公告")
	local tempArr = {}
	if info["action"] == 1 then
		if info["text2"] then
			for k,v in pairs(info["text2"]) do
				if v["2"]=="blue" and string.find(v["1"],"金币")==nil then
					v["2"]="green"
					if string.find(v["1"],"恭喜") then
						v["1"]="horn_txt_gx"
					elseif string.find(v["1"],"在") then
						v["1"]="horn_txt_z"
					elseif string.find(v["1"],"一把赢得了") then
						v["1"]="horn_txt_win"
					elseif string.find(v["1"],"中拿到") then
						v["1"]="horn_txt_znd"
					end
				end
				tempArr[tonumber(k)] = v
			end
		end
	else
		if info["text"] then
			local v = {}
			v["1"] = info["text"]
			v["2"] = "blue"
			table.insert(tempArr,v)
		end
	end

	if #tempArr == 0 then
		return
	end
	self:setPosition(display.cx,self.posY)
	if self:getParent() ~= nil then
		self:removeFromParent(true)
	end
	self.parentLayer:addChild(self)
	self:setLocalZOrder(100)
	self.isRolling = true

	self.listview:removeAllItems()
	for k,v in pairs(tempArr) do
		local label = nil
		if v["2"] == "blue" and string.find(v["1"],"金币")==nil then
			label = self.textLabel:clone()
		elseif v["2"] == "white" then
			label = self.idLabel:clone()
		elseif v["2"] == "red" then
			label = self.gameLabel:clone()
		elseif v["2"] == "customize" then
			label = self.moneyLabel:clone()
			v["1"]=v["1"].."元"
		elseif v["2"] == "green" then
			label = self.textImg:clone()
		end
		if label then
			if v["2"] ~= "green"then
				label:setString(v["1"])
			else
				label:ignoreContentAdaptWithSize(true)
				label:loadTexture(COMMON_IMAGES_RES..v["1"]..".png")
			end
			label:setVisible(true)
			self.listview:pushBackCustomItem(label)
		end
	end
	-- local label = nil
	-- label = self.textLabel:clone()
	-- local str = ""
	-- for k,v in pairs(tempArr) do
	-- 	str=str..v["1"]	
	-- end
	-- str=self:trim(str)
	-- if label then
	-- 	label:setString(str)
	-- 	label:setVisible(true)
	-- 	self.listview:pushBackCustomItem(label)
	-- end
	dump(tempArr,"公告>>>>>>>>>>>")
	--local width = label:getContentSize().width--self.listview:getInnerContainerSize().width
	local width =self.listview:getInnerContainerSize().width
	local height = self.listview:getContentSize().height
	self.listview:setContentSize(width,height)
	self.listview:setPositionX(self.container:getContentSize().width)
	local time = (width+self.container:getContentSize().width)/90
	local array = {}
	array[#array+1] = cc.MoveTo:create(time,cc.p(-width+50,0))
	array[#array+1] = cc.CallFunc:create(function()
		self:hide(false)
	end)
	self.listview:runAction(cc.Sequence:create(array))
end

function C:hide(removeParent)
	self.isRolling = false
	if removeParent then
		self.parentLayer = nil
	end
	if not tolua.isnull(self) then
		self:removeFromParent(true)
	end
end

function C:trim(s) 
	--return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
	return (string.gsub(s, " ", ""))
end

return C