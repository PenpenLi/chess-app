
local C = class("JsmjCurrentDiscard",ViewBaseClass)

C.BINDING = 
{
    imgValue = {path="Image_tile.Image_value"},
}

function C:ctor(parent, node)
    C.super.ctor(self,node)
    self.parView_ = parent
end

function C:onCreate()
end

--显示面板
function C:show(value)
    self.node:setVisible(true)
    self.imgValue:loadTexture(self.parView_:getAboveImg(value))
end

--隐藏
function C:hide()
    self.node:setVisible(false)
end

return C
