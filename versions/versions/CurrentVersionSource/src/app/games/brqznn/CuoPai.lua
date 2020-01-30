local C = class("CuoPai")

function C:ctor( node )
	self.node = node
    
    self:initUI()
    --自动翻开模式
    self.isAutoOpen=false
    self.flipInterval=0
    self.dis=-1000
    self.isAutoClose=false
    self.needClose=false

    self:initEvents()
end

function C:initUI()
    self.back=display.newSprite("common/images/card_back.png")
    self.front=display.newSprite("common/images/card_bg.png")
    self.poker=PageFlip:create(self.back,self.front)
    self.poker:setCascadeOpacityEnabled(true)
    self.poker:setRotation(90)
    self.node:addChild(self.poker)

    self.poker:setPosition(640,340)
    self.poker:calculateHorizontalVertexPoints(-250)
end

function C:initEvents()
	local function onTouchBegan(touch, event) 
		return self:onTouchBegan(touch, event)
	end
	local function onTouchMoved(touch, event)  
		self:onTouchMoved(touch, event)
	end

	local function onTouchEnded(touch, event) 
		self:onTouchEnded(touch, event)
	end
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher =  self.node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.node)

   --游戏主循环
    local scheduler = cc.Director:getInstance():getScheduler()  
	self.schedulerID = scheduler:scheduleScriptFunc(function()
			self:update()
		end,0.016,false) 
end

function C:update()
	if self.isAutoOpen then
        self.dis=self.dis-12
        self.poker:calculateHorizontalVertexPoints(self.dis,-320+(self.dis+480)*2)
        if self.dis<-718 then
            self.dis=-718
            self.isAutoOpen=false
            cc.Director:getInstance():setDepthTest(false)
        end
    end
    if self.isAutoClose then       
        self.dis=self.dis+8
        self.poker:calculateHorizontalVertexPoints(self.dis)
        if self.dis>-250 then
            self.dis=-250
            self.isAutoClose=false
        end
    end
end

function C:onTouchBegan(touch, event)
    if self.needClose then
        return false
    end
    local point = touch:getLocation()
    point = self.node:convertToNodeSpace(point)
    self.oldPoint = point
    return true
end

function C:onTouchMoved(touch, event)
    if self.isAutoOpen then return end;
    local point = touch:getLocation()
    point = self.node:convertToNodeSpace(point)
    local dis=point.y-self.oldPoint.y
    dis=-250-dis
    if dis<-480 then
        dis=-480
    elseif dis>-250 then
        dis=-250;
    end

    if dis<=-480 then
        self.isAutoOpen=true
    end
    self.dis=dis

    printInfo(">>>>>>>>>>>>>>>>>>>>>"..dis)
    self.poker:calculateHorizontalVertexPoints(dis)
end

function C:onTouchEnded(touch, event)
    local point = touch:getLocation()
    point = self.node:convertToNodeSpace(point)
    if self.dis > -400 then
        self.isAutoClose = true
    end
end

return C