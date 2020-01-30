local Node = cc.Node

function Node:seekChildByName(name)
    local child = self:getChildByName(name)
    if child then return child end
    local chilren = self:getChildren()
    for k, v in pairs(chilren) do
        child = v:seekChildByName(name)
        if child then return child end
    end
end

function Node:waitAndCall(time, func)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(func)))
end
function Node:waitAndActions(time, ...)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(time), ...))
end