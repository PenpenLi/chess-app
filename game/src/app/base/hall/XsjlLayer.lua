local C = class("XsjlLayer",BaseLayer)
XsjlLayer = C

C.RESOURCE_FILENAME = "base/XsjlLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="OnBack"}}},
	confirmBtn = {path="confirm_btn",events={{event="click",method="OnBack"}}}
}

function C:OnBack( event )
	require("app.init")
	HallCore.new():run()
end

return XsjlLayer