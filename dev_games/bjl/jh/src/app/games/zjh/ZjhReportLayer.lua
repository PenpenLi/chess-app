local C = class("ZjhReportLayer",BaseLayer)

C.RESOURCE_FILENAME = "games/zjh/ReportLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	playerLabel = {path="box_img.player_label"},
	reportBtn = {path="box_img.report_btn",events={{event="click",method="onClickReportBtn"}}},
}
C.info = nil
C.callback = nil

function C:ctor( info,callback )
	self.info = info
	self.callback = callback
	C.super.ctor(self)
end

function C:onCreate()
	C.super.onCreate(self)
	local text = "被举报人："..tostring(self.info["playerid"]).."  "..tostring(self.info["nickname"])
	self.playerLabel:setString(text)
end

function C:onClickReportBtn( event )
	if self.callback then
		self.callback(self.info)
	end
	self:hide()
end

return C