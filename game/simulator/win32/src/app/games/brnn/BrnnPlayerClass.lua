local C = class("BrnnPlayerClass",ViewBaseClass)

C.BINDING = {
	head = {path="head"},
	flagsImg = {path="head.flags_img"},
	headImg = {path="head.head_img"},
	frameImg = {path="head.frame_img"},
	vipImg = {path="head.vip_img"},
	vipLabel = {path="head.vip_img.label"},
	blanceLabel = {path="blance_img.label"},
	nameLabel = {path="name_label"},
}

C.info = nil
C.isShaking = false
C.headPos = cc.p(50,50)

function C:destroy()
	self.info = nil
end

function C:onCreate()
	C.super.onCreate(self)
	self.headPos = cc.p(self.head:getPosition())
end

function C:setVisible( flags )
	C.super.setVisible(self,flags)
	if flags == false then
		self.info = nil
	end
end

function C:show(info)
	self:setVisible(true)
	self.info = info
	local headId = info["headid"]
	local headUrl = info["wxheadurl"]
	SET_HEAD_IMG(self.headImg,headId,headUrl)
	self.vipImg:setVisible(false)
	local name = self.info["name"]
	if name == nil or name == "" then
		name = tostring(self.info["playerid"])
	end
	self.nameLabel:setString(name)
	if self.blanceLabel then
		local money = utils:moneyString(self.info["coin"])
		self.blanceLabel:setString(money)
	end
end

function C:updateBlance( coin )
	if self.info then
		self.info["coin"] = coin
	end
	if self.blanceLabel then
		local money = utils:moneyString(coin)
		self.blanceLabel:setString(money)
	end
end

--甩头
function C:shakeHead()
    if self.isShaking == false then
        self.isShaking = true
        local moveGap = 20
        local tag = self.node:getTag()
        if tag == 1 or tag == 5 or tag == 6  then
            moveGap = -20
        end
        local move1 = CCMoveTo:create(0.04,cc.p(self.headPos.x + moveGap, self.headPos.y))
        local move2 = CCMoveTo:create(0.04,self.headPos)
        local delay = CCDelayTime:create(0.02)
        local callFun = CCCallFunc:create(function ()
            self.isShaking = false
        end)
        self.head:runAction(transition.sequence({move1,move2,delay,callFun}))
    end
end

return C