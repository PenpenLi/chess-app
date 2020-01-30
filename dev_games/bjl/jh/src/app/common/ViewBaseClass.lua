local C = class("ViewBaseClass")
ViewBaseClass = C

C.node = nil
C.BINDING = nil

function C:ctor( node )
	self.node = node
	local binding = rawget(self.class, "BINDING")
	if self.node and binding then
		self:createBinding(self.node,binding)
	end
	if self.onCreate then 
		self:onCreate() 
	end
end

function C:onCreate()
end

function C:setVisible( flags )
    if self.node then
        self.node:setVisible(flags)
    end
end

function C:isVisible()
    if self.node then
        return self.node:isVisible()
    else
        return false
    end
end

function C:createBinding( node,binding )
	if node == nil or binding == nil then
		return
	end
    for nodeName, nodeBinding in pairs(binding) do
        local node =  self:findNestedChildByName(node, nodeBinding.path)
        if node then
            self[nodeName] = node
            for _, event in ipairs(nodeBinding.events or {}) do
                if event.event == "click" and node["onClick"] ~= nil then
                    node:onClick(handler(self, self[event.method]))
                end
                if event.event == "touch" and node["onTouch"] ~= nil then
                    node:onTouch(handler(self, self[event.method]))
                end
                if event.event == "event" and node["onEvent"] ~= nil then
                    node:onEvent(handler(self, self[event.method]))
                end
                if event.event == "scroll" and node["onScroll"] ~= nil then
                    node:onScroll(handler(self, self[event.method]))
                end
            end
        end
    end
end

function C:findNestedChildByName( node, name )
    local array = utils:stringSplit(name,".")
    if #array == 0 then
        return nil
    end
    if #array == 1 then
        return node:getChildByName(array[1])
    end
    local parent = node
    local count = #array
    for i=1,count do
        if parent == nil then
            return nil
        end
        parent = parent:getChildByName(array[i])
        if parent == nil then
            return nil
        end
        if i == count - 1 then
            return parent:getChildByName(array[count])
        end
    end
end

return ViewBaseClass