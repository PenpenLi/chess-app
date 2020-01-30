local C = class("ZjhCompareClass",ViewBaseClass)

C.BINDING = {
	maskPanel = {path="mask_panel"},
	cancelBtn = {path="cancel_btn"},
	pkBtn2 = {path="pk_btn_2"},
	pkBtn3 = {path="pk_btn_3"},
	pkBtn4 = {path="pk_btn_4"},
	pkBtn5 = {path="pk_btn_5"},
}

C.playerPosArr = {cc.p(391,147),cc.p(986,285),cc.p(986,470),cc.p(150,470),cc.p(150,285)}

function C:onCreate()
	C.super.onCreate(self)
	self.maskPanel:setVisible(false)
	self.maskPanel:setContentSize(cc.size(display.width,display.height))
	self.cancelBtn:setVisible(false)
	self.pkBtn2:setVisible(false)
	self.pkBtn3:setVisible(false)
	self.pkBtn4:setVisible(false)
	self.pkBtn5:setVisible(false)
end

function C:setVisible( flags )
	C.super.setVisible(self,flags)
	if flags == false then
		self.maskPanel:setVisible(false)
		self.cancelBtn:setVisible(false)
		for i=2,5 do
			local key = string.format("pkBtn%d",i)
			local pkBtn = self[key]
			local box = pkBtn:getChildByName("box_img")
			box:stopAllActions()
			pkBtn:setVisible(false)
		end
	end
end

function C:showPK( localSeatIds )
	dump(localSeatIds,"showPK")
	self:setVisible(true)
	self.maskPanel:setVisible(true)
	self.cancelBtn:setVisible(true)
	for i,v in ipairs(localSeatIds) do
		self:playPKAni(v)
	end
end

function C:playPKAni( localSeatId )
	local key = string.format("pkBtn%d",localSeatId)
	local pkBtn = self[key]
	local box = pkBtn:getChildByName("box_img")
	pkBtn:setVisible(true)
	local arr = {}
	arr[1] = cc.ScaleTo:create(0.2,0.9)
	arr[2] = cc.ScaleTo:create(0.4,1.1)
	arr[3] = cc.ScaleTo:create(0.2,1)
	box:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
end

function C:playCompareAni( winner, loser, callback )
	self:setVisible(true)

	local startPos = self.playerPosArr[winner]
	local endPos = self.playerPosArr[loser]

	local parent = display.newNode()
	parent:addTo(self.node)

	local node = display.newNode()
	node:setPosition(startPos.x,startPos.y)
	node:addTo(parent,100)

	-- fly
	local speed = 1200
	local moveFly = CCMoveTo:create(math.min(cc.pGetDistance(startPos, endPos) / speed,0.65),endPos)
	local callfunFly = CCCallFunc:create(function (  )
		local particle = CCParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/attack_fly.plist")
    	particle:setAutoRemoveOnFinish(true)
    	particle:setPosition(0,0)
    	particle:addTo(node)
    	particle:setScale(0.5)
	end)

	local spawnFly = transition.spawn({moveFly,callfunFly})

	-- attack
	local callfunAttack1 = CCCallFunc:create(function ()
		PLAY_SOUND(GAME_ZJH_SOUND_RES.."cmp_boom.mp3")
		if callback then
			callback()
		end
		local strAnimName = GAME_ZJH_ANIMATION_RES.."skeleton/bipai_boom/attack_skeleton"
	    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
	    skeletonNode:setPosition(endPos.x + 10,endPos.y + 35)
	    skeletonNode:setAnimation(0,"attack_ani",false)
	    skeletonNode:addTo(parent,99)
	end)

	local delayAttack = CCDelayTime:create(0.16)

	local callfunAttack2 = CCCallFunc:create(function ()
		local particle = CCParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/attack_bomb.plist")
    	particle:setAutoRemoveOnFinish(true)
    	particle:setPosition(endPos.x,endPos.y)
    	particle:addTo(parent,98)
    	particle:setScale(0.5)
	end)

	local seqAttack = transition.sequence({callfunAttack1,delayAttack,callfunAttack2})

	local delayRemove = CCDelayTime:create(0.7)
	-- remove
	local removeCallfun = CCCallFunc:create(function ()
		parent:removeFromParent(true)
		self:setVisible(false)
	end)

	local seq = transition.sequence({spawnFly,seqAttack,delayRemove,removeCallfun})
	node:runAction(seq)
end

return C