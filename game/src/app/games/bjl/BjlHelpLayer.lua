--[[    author:Joseph
    time:2020-01-06 18:50:01
]]
local C = class("BjlHelpLayer", BaseLayer)

C.RESOURCE_FILENAME = "games/bjl/prefab/BjlHelpLayer.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
    backBtn = { path = "close_btn", events = { { event = "click", method = "onClickBackBtn" } } },
    -- template = { path = "Panel_1" },
    -- list = { path = "listview" },
}

function C:onCreate()
    C.super.onCreate(self)
    self.yPos = self.resourceNode:getPositionY()
end

function C:show()
    C.super.show(self)

    self.resourceNode:setPositionY(self.yPos)
    self.maskLayer:setVisible(true)
    if self.maskLayer then
        self.maskLayer:setOpacity(0)
        self.maskLayer:runAction(cc.FadeTo:create(0.35, 153))
    end
end

function C:hide()
    C.super.hide(self)
end

function C:onClickBackBtn()
    self:hide()
end


return C