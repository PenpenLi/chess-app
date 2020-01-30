local PlayerClass = import(".ZjhHistoryPlayerClass")
local ReportLayer = import(".ZjhReportLayer")
local C = class("ZjhHistoryClass",BaseLayer)

C.RESOURCE_FILENAME = "games/zjh/HistoryLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	playerPanel = {path="box_img.player_panel"},
}

C.playerClassArr = nil
C.historyInfo = nil
C.callback = nil

function C:ctor(callback)
	for i=1,5 do
		local key = string.format("player"..i)
		local path = string.format("box_img.player_panel.player_"..i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickPlayer"}}}
	end
	self.callback = callback
	C.super.ctor(self)
end

function C:onCreate()
	C.super.onCreate(self)
	self.playerClassArr = {}
	for i=1,5 do
		local key = string.format("player"..i)
		local player = self[key]
		player:setTag(i)
		local playerClass = PlayerClass.new(player)
		table.insert(self.playerClassArr,playerClass)
	end
end

function C:reloadInfo( info )
	self.historyInfo = info
	local count = #self.historyInfo["players"]
	local width = 167*(count-1)+160
	self.playerPanel:setContentSize(cc.size(width,316))
	for i=1,5 do
		local playerClass = self.playerClassArr[i]
		local playerInfo = self.historyInfo["players"][i]
		if playerInfo then
			playerClass:reloadInfo(playerInfo)
			local posX = 80+(i-1)*167
			local posY = 158
			playerClass.node:setPositionX(posX)
			playerClass:setVisible(true)
		else
			playerClass:setVisible(false)
		end
	end
end

function C:onClickPlayer( event )
	local index = event.target:getTag()
	local playerClass = self.playerClassArr[index]
	if playerClass.reportFlags then
		toastLayer:show("您已举报过该玩家！")
	else
		local playerInfo = self.historyInfo["players"][index]
		playerInfo["index"] = index
		if playerInfo["playerid"] == dataManager.playerId then
			toastLayer:show("不能举报自己哦")
			return
		end
		local layer = ReportLayer.new(playerInfo,function( info )
			self:reportPlayer(info)
		end)
		layer:show()
	end
end

function C:reportPlayer( info )
	dump(info)
	local historyId = self.historyInfo["paiju_bs"]
	local ids = tostring(info["playerid"])
	if self.callback then
		self.callback(historyId,ids)
	end
	local index = info["index"]
	local playerClass = self.playerClassArr[index]
	playerClass:setReportFlags(true)
	toastLayer:show("提交成功，相关人员将核实处理，感谢您的配合！")
end

return C