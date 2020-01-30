local C = class("QZPJHelpLayer", BaseLayer)
QZPJHelpLayer = C

C.RESOURCE_FILENAME = "base/QZPJHelp.csb"
C.RESOURCE_BINDING = {
    btn_close = { path = "btn_close", events = { { event = "click", method = "OnClose" } } },
    btn_1 = { path = "d_1.btn_1", events = { { event = "click", method = "OC_" } } },
    btn_2 = { path = "d_1.btn_2", events = { { event = "click", method = "OC_" } } },
    btn_3 = { path = "d_1.btn_3", events = { { event = "click", method = "OC_" } } },
    btn_4 = { path = "d_1.btn_4", events = { { event = "click", method = "OC_" } } },
    btn_5 = { path = "d_1.btn_5", events = { { event = "click", method = "OC_" } } },
    S_1 = { path = "d_2.ScrollView_1" },
    S_2 = { path = "d_2.ScrollView_2" },
    S_3 = { path = "d_2.ScrollView_3" },
    S_4 = { path = "d_2.ScrollView_4" },
    S_5 = { path = "d_2.ScrollView_5" },
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
    self:pressBtn(1)
end

function C:hide()
    C.super.hide(self)
end

function C:OnClose(event)
    self:hide()
end

function C:OC_(event)
    self:pressBtn(string.sub(event.target:getName(), 5))
end

function C:pressBtn(index)
    for i = 1, 5 do
        self["btn_" .. i]:setEnabled(true);
        self["S_" .. i]:setVisible(false);
    end
    self["btn_" .. index]:setEnabled(false);
    self["S_" .. index]:setVisible(true);

end

return QZPJHelpLayer