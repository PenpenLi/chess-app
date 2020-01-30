
local C = class("JsmjRuleClass",BaseLayer)
JsmjRuleClass = C

C.RESOURCE_FILENAME = "games/jsmj/Rule.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="Panel_close",events={{event="click",method="hide"}}}
}

function C:onCreate()
	C.super.onCreate(self)
end

return JsmjRuleClass