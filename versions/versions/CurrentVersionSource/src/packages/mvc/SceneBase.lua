local C = class("SceneBase",ViewBase)
SceneBase = C

C.core = nil

function C:ctor( core )
	C.super.ctor(self)
	self.core = core
end

function C:showWithScene(transition, time, more)
	self:setVisible(true)
    local scene = display.newScene()
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function C:onEnter()
	print("================onEnter:"..tostring(self.class.__cname))
end

function C:onExit()
	print("================onExit:"..tostring(self.class.__cname))
end

function C:onEnterTransitionFinish()
	print("================onEnterTransitionFinish:"..tostring(self.class.__cname))
end

function C:onExitTransitionStart()
	if self.core and self.core.exit then
		self.core:exit()
	end
	self.resourceNode:removeAllChildren(true)
	self:removeAllChildren(true)
	self.core = nil
	self.RESOURCE_BINDING = nil
	display.removeUnusedSpriteFrames()
	collectgarbage("collect")
	print("================onExitTransitionStart:"..tostring(self.class.__cname))
end

function C:onCleanup()
	print("================onCleanup:")
end

return SceneBase