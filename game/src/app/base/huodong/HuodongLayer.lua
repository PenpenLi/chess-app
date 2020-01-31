local C = class("HuodongLayer",BaseLayer)
HuodongLayer = C
C.RESOURCE_FILENAME = "base/HuodongLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="OnBack"}}},
	--列表
	listview = {path="box_img.listview"},
	emptyLabel = {path="box_img.empty_label"},
	--item模板
	item = {path="item"},
}

--活动任务-游戏图标[缺少的让美术出图]
local ICON_CONFIGS = {
	[0] = "huodong_popup/icon_game_comm.png",
	[GAMEID_BRNN] = "huodong_popup/icon_game_brnn.png",
	[GAMEID_HHDZ] = "huodong_popup/icon_game_hhdz.png",
	[GAMEID_CPDDZ] = "huodong_popup/icon_game_cpddz.png",
	[GAMEID_DDZ] = "huodong_popup/icon_game_ddz.png",
	[GAMEID_ZJH] = "huodong_popup/icon_game_zjh.png",
	[GAMEID_QZNN] = "huodong_popup/icon_game_qznn.png",
	[GAMEID_BJL] = "huodong_popup/icon_game_bjl.png",
	[GAMEID_BRQZNN] = "huodong_popup/icon_game_brqznn.png",
	[GAMEID_FRUIT] = "huodong_popup/icon_game_fruit.png",
	[GAMEID_HCCC] = "huodong_popup/icon_game_hccc.png",
	[GAMEID_FISH] = "huodong_popup/icon_game_jsby.png",
	[GAMEID_JSMJ] = "huodong_popup/icon_game_jsmj.png",
	[GAMEID_SANGONG] = "huodong_popup/icon_game_jsys.png",
	[GAMEID_LHD] = "huodong_popup/icon_game_lhd.png",
	[GAMEID_QZPJ] = "huodong_popup/icon_game_qzpj.png",
	[GAMEID_HB] = "huodong_popup/icon_game_hb.png",
}

local GAME_SORT = {
	[0] = 0,
	[GAMEID_HB] = 1,
	[GAMEID_LHD] = 2,
	[GAMEID_BRQZNN] = 3,
	[GAMEID_CPDDZ] = 4,
	[GAMEID_ZJH] = 5,
	[GAMEID_QZNN] = 6,
	[GAMEID_FISH] = 7,
	[GAMEID_BRNN] = 8,
	[GAMEID_HHDZ] = 9,
	[GAMEID_JSMJ] = 10,
	[GAMEID_DDZ] = 12,
	[GAMEID_BJL] = 13,
	[GAMEID_FRUIT] = 14,
	[GAMEID_HCCC] = 15,
	[GAMEID_SANGONG] = 16,
	[GAMEID_QZPJ] =17,
}

C.taskList = nil

function C:onCreate()
	C.super.onCreate(self)
	self.listview:setTopPadding(5)
	self.listview:setScrollBarEnabled(false)
	self.listview:removeAllItems()
	self.item:setVisible(false)
end

function C:show()
	C.super.show(self)
	self.updateItemDataHandler = handler(self,self.updateItemData)
	self.onGetTaskRewardResponseHandler = handler(self,self.onGetTaskRewardResponse)
	eventManager:on("UpdateTaskInfo",self.updateItemDataHandler)
	eventManager:on("GetTaskRewardResponse",self.onGetTaskRewardResponseHandler)
	self:updateTaskList(true)
	--请求更新活动列表
	eventManager:publish("UpdateTaskInfoRequest")
end

function C:onExit()
	eventManager:off("UpdateTaskInfo",self.updateItemDataHandler)
	eventManager:off("GetTaskRewardResponse",self.onGetTaskRewardResponseHandler)
	C.super.onExit(self)
end

function C:OnBack( event )
	require("app.init")
	HallCore.new():run()
end

--[[
	info.Id --任务ID
	info.taskname --任务名称[比如:斗地主0.1元底分]
	info.tasktype --任务类型 liushui/changci
	info.gameid --游戏ID
	info.orderid --游戏房间ID
	info.completeVal --总进度
	info.nowVal --当前进度(当前进度会大于总进度，比如百变斗地主5局，当前完成了15局，玩家可以领多次的)
	info.completeAmout --任务奖励金币（单位分）
]]
function C:updateTaskList(isJumpToTop)
	self.taskList = dataManager:getRenwuList()
	table.sort(self.taskList,function( a,b )
		if a.nowVal>=a.completeVal or b.nowVal>=b.completeVal then
			return a.nowVal/a.completeVal>b.nowVal/b.completeVal
		end
		if a.gameid == b.gameid then
			--gameid一样
			local atype = 1
			local btype = 1
			if a.tasktype == "liushui" then
				atype = 2
			end
			if b.tasktype == "liushui" then
				btype = 2
			end
			if atype == btype then
				--类型一样,根据房间orderid降序排(底分低的排在前面)
				return a.orderid > b.orderid
			else
				--类型不一样，流水优先
				return atype > btype
			end
		else
			--gameid不一样,根据对应得sortid升序排
			local asortid = GAME_SORT[a.gameid] or 100
			local bsortid = GAME_SORT[b.gameid] or 100
			return asortid < bsortid
		end
	end)
	-- self.taskList = self:testData()
	-- table.sort(self.taskList,function( a,b )
	-- 	local atype = 1
	-- 	local btype = 1
	-- 	if a.tasktype == "liushui" then
	-- 		atype = 2
	-- 	end
	-- 	if b.tasktype == "liushui" then
	-- 		btype = 2
	-- 	end
	-- 	if atype == btype then
	-- 		--任务类型一样
	-- 		if a.gameid == 0 or b.gameid == 0 then
	-- 			--有全局任务类型
	-- 			if a.gameid == b.gameid then
	-- 				--全局任务或者同一个游戏任务
	-- 				if a.nowVal ~= 0 and b.nowVal ~= 0 then
	-- 					--都有任务进度，按接近完成程度排序
	-- 					return (a.completeVal-a.nowVal) < (b.completeVal-b.nowVal)
	-- 				else
	-- 					--有任务进度排在前面
	-- 					return a.nowVal > b.nowVal
	-- 				end
	-- 			else
	-- 				--全局任务排在前面
	-- 				return a.gameid < b.gameid
	-- 			end
	-- 		else
	-- 			--没有全局任务类型,不需要对游戏类型排序
	-- 			if a.nowVal ~= 0 and b.nowVal ~= 0 then
	-- 				--都有任务进度，按接近完成程度排序
	-- 				return (a.completeVal-a.nowVal) < (b.completeVal-b.nowVal)
	-- 			else
	-- 				--有任务进度排在前面
	-- 				return a.nowVal > b.nowVal
	-- 			end
	-- 		end
	-- 	else
	-- 		--任务类型不一样,流水活动排前面,忽略任务完成程度
	-- 		return atype > btype
	-- 	end
	-- end)
	self.listview:removeAllItems()
	for index,info in ipairs(self.taskList) do
		local item = self:createItem(index,info)
		self.listview:pushBackCustomItem(item)
	end
	if isJumpToTop then
		self.listview:jumpToTop()
	end
	if self.taskList and #self.taskList > 0 then
		self.emptyLabel:setVisible(false)
	else
		self.emptyLabel:setVisible(true)
	end
end

--TODO:活动任务-测试数据
function C:testData()
	local list = {}
	table.insert(list,{Id=1,taskname="斗地主0.1元底分",gameid=GAMEID_DDZ,orderid=80,completeVal=5,nowVal=2,completeAmout=800})
	table.insert(list,{Id=2,taskname="抢庄牌九0.2元底分",gameid=GAMEID_QZPJ,orderid=110,completeVal=10,nowVal=5,completeAmout=1000})
	table.insert(list,{Id=3,taskname="龙虎斗",gameid=GAMEID_LHD,orderid=90,completeVal=20,nowVal=22,completeAmout=2000,finish=1})
	table.insert(list,{Id=1,taskname="金鲨银鲨0.1元底分",gameid=GAMEID_SANGONG,orderid=80,completeVal=5,nowVal=2,completeAmout=800})
	table.insert(list,{Id=2,taskname="极速捕鱼0.2元底分",gameid=GAMEID_FISH,orderid=110,completeVal=10,nowVal=5,completeAmout=1000})
	table.insert(list,{Id=3,taskname="豪车猜猜0.1元底分",gameid=GAMEID_HCCC,orderid=90,completeVal=20,nowVal=22,completeAmout=2000})
	table.insert(list,{Id=1,taskname="二人麻将0.1元底分",gameid=GAMEID_JSMJ,orderid=80,completeVal=5,nowVal=2,completeAmout=800})
	table.insert(list,{Id=2,taskname="扫雷红包0.2元底分",gameid=GAMEID_HB,orderid=110,completeVal=10,nowVal=5,completeAmout=1000})
	table.insert(list,{Id=3,taskname="水果机0.2元底分",gameid=GAMEID_FRUIT,orderid=90,completeVal=20,nowVal=22,completeAmout=2000})
	table.insert(list,{Id=1,taskname="明牌抢庄牛牛0.1元底分",gameid=GAMEID_BRQZNN,orderid=80,completeVal=5,nowVal=2,completeAmout=800})
	table.insert(list,{Id=2,taskname="百家乐",gameid=GAMEID_BJL,orderid=110,completeVal=10,nowVal=5,completeAmout=1000})
	table.insert(list,{Id=3,taskname="抢庄牛牛0.2元底分",gameid=GAMEID_QZNN,orderid=90,completeVal=20,nowVal=22,completeAmout=2000})
	table.insert(list,{Id=1,taskname="炸金花0.1元底分",gameid=GAMEID_ZJH,orderid=80,completeVal=5,nowVal=2,completeAmout=800})
	table.insert(list,{Id=2,taskname="百变斗地主0.2元底分",gameid=GAMEID_CPDDZ,orderid=110,completeVal=10,nowVal=5,completeAmout=1000})
	table.insert(list,{Id=3,taskname="红黑大战",gameid=GAMEID_HHDZ,orderid=90,completeVal=20,nowVal=22,completeAmout=2000})
	table.insert(list,{Id=3,taskname="百人牛牛高倍场",gameid=GAMEID_BRNN,orderid=90,completeVal=20,nowVal=22,completeAmout=2000})
	table.insert(list,{Id=3,taskname="极速捕鱼0.1元",gameid=GAMEID_FISH,orderid=90,completeVal=20,nowVal=22,completeAmout=2000})
	return list
end

function C:createItem( index, info)
	local item = self.item:clone()
	item:setVisible(true)
	--游戏图标
	local iconBtn = item:getChildByName("icon_btn")
	local iconPath = ICON_CONFIGS[info.gameid]
	if iconPath then
		iconBtn:setVisible(true)
		iconBtn:loadTextureNormal(BASE_IMAGES_RES..iconPath)

        iconBtn:setScaleX(0.7)
        iconBtn:setScaleY(0.7)
	else
		iconBtn:setVisible(false)
	end

	--名称
	local nameLabel = item:getChildByName("name_label")
	local taskname = info.taskname or ""
	nameLabel:setString(taskname)

	--完成进度
	local progressBar = item:getChildByName("progress_img"):getChildByName("bar")
	local progressLabel = item:getChildByName("progress_img"):getChildByName("label")
	local total = tonumber(info.completeVal) or 1
	local progress = tonumber(info.nowVal) or 0
	--一次次领取
	if progress > total then
		progress = total
	end
	local percent = math.floor(progress/total*100)
	--主要是为了显示有进度，要不然完成任务数量过打，完成了几个，看不到进度条
	if 0 < progress and percent < 8 then
		percent = 8

	end
    -- progress = string.gsub(tostring(progress), "(%.%d-)0+$", "%1")
    -- total = string.gsub(tostring(total), "(%.%d-)0+$", "%1")
	progressBar:setPercent(percent)
	progressLabel:setString(string.format("%d/%d",math.floor(progress),total))

	--奖励金币
	local moneyLabel = item:getChildByName("reward_img"):getChildByName("label")
	moneyLabel:setString(utils:moneyString(info.completeAmout,3))

	--开始按钮
	local beginBtn = item:getChildByName("begin_btn")
	beginBtn:setTag(index)
	beginBtn:onClick(handler(self,self.onClickBeginBtn))
	local gotBtn = item:getChildByName("got_btn")
	gotBtn:setTag(index)
	gotBtn:onClick(handler(self,self.onClickGotBtn))

	--是否已完成
	local finish = info.nowVal >= info.completeVal
	if finish then
		beginBtn:setVisible(false)
		gotBtn:setVisible(true)
	else
		beginBtn:setVisible(true)
		gotBtn:setVisible(false)
        dump(info)
        if info.tasktype == "liushui" and info.gameid == 0 then
	        beginBtn:setVisible(false)
        end
	end
	return item
end

function C:onClickBeginBtn( event )
	local index = event.target:getTag()
	local info = self.taskList[index]
	if info then
		--在这里目前不需要判断炸金花是否需要定位了，如果需要后面再加判断
		gameManager:enterGame(info.gameid,info.orderid,nil,function(code,msg)
			if code == 0 then
				--self:onHide()
			elseif code == 3 then
				toastLayer:show("金币不足，请提取保险箱金币！")
			elseif code == 4 then
				toastLayer:show("金币不足，请充值金币！")
			end
		end)
	end
end

--活动任务-发送领取奖励协议
function C:onClickGotBtn( event )
	local index = event.target:getTag()
	local info = self.taskList[index]
	if info then
		dump(info,"onClickGotBtn")
		local msg = {}
		msg.id = info.id
        dump(msg)
		eventManager:publish("GetTaskRewardRequest",msg)
	end
end

--活动任务-收到更新列表
function C:updateItemData(itemListInfo)
	self:updateTaskList(false)
end

--活动任务-领取奖励返回结果
function C:onGetTaskRewardResponse(info)
	--以服务器字段为准
	if info.amout > 0 then
		toastLayer:show("领取成功!")
		if info.nowAmout then
			eventManager:publish("Money",info.nowAmout)
			dataManager.userInfo.money=info.nowAmout
		end
		local taskId = info.taskid
		local taskInfo = dataManager:getRenwuInfoByTaskId(taskId)
		if taskInfo then
			taskInfo.nowVal = info.nowVal or 0
			dataManager:updateRenwu(taskInfo)
			--更新任务列表
			self:updateTaskList(false)
		end
	else
		toastLayer:show("领取失败！")
	end
end

return HuodongLayer