local C = class("LhdToastLayer",BaseLayer)
LhdToastLayer = C

--是否使用显示隐藏动画
C.USE_ACTION = false
--是否使用模态
C.USE_MODAL = false

C.RESOURCE_FILENAME = "common/ToastLayer.csb"
C.RESOURCE_BINDING = {
	container = {path="container"},
	template = {path="template"}
}

C.index = 0

function C:onCreate()
	C.super.onCreate(self)
	self.template:setVisible(false)
end

function C:show( text, time, bgFile)
	if text == nil or text == "" then
		return
	end
	if self.index == 0 or self:getParent() == nil then
		self.container:removeAllChildren(true)
		C.super.show(self)
	end
	self:setLocalZOrder(999)
	self:addItem(text,time, bgFile)
end

function C:addItem( text, time, bgFile)
	local items = self.container:getChildren()
	table.sort( items, function( a, b )
		return a:getTag() > b:getTag()
	end )
	for i=1,#items do
		local item = items[i]
		item:runAction(cc.MoveTo:create(0.2,cc.p(568,320+i*80)))
	end
	self.index = self.index + 1
	local item = self.template:clone()
    local img = nil;
    local size = nil;
    if bgFile then
        item:loadTexture(bgFile, 1);
        img = ccui.ImageView:create(bgFile, 1);
        item:addChild(img);
        size = img:getContentSize();
        img:removeFromParent();
        img = nil;
    end
	local label = item:getChildByName("label")
    label:setFontName(GAME_LHD_FONT_RES.."FZY4JW.TTF");
	label:setString(text)
    label:setColor(cc.c3b(20, 124, 158));
	local width = label:getContentSize().width + 80
	local height = size.height and size.height or item:getContentSize().height
	item:setContentSize(cc.size(width,height))
    label:setPositionY(height / 2);
	item:setPosition(cc.p(568,320))
	item:setTag(self.index)
	item:setVisible(true)
	self.container:addChild(item)
	time = time or 2
	item:runAction(transition.sequence({
		cc.DelayTime:create(time),
		cc.FadeOut:create(0.5),
		cc.CallFunc:create(function()
			item:removeFromParent(true)
			local children = self.container:getChildren()
			if #children == 0 then
				self:hide()
			end
		end)
	}))
end

function C:hide()
	self.index = 0
	C.super.hide(self)
end

function C:onExit()
	self.index = 0
end

return LhdToastLayer