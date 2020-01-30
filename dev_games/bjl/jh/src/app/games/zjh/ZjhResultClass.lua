local C = class("ZjhResultClass",ViewBaseClass)

C.BINDING = {
	winPanel = {path="you_win"},
	losePanel = {path="you_lose"},
}

function C:ctor( node )
    for i=1,5 do
        local key = string.format("node%d",i)
        local path = string.format("node_%d",i)
        self.BINDING[key] = {path=path}
    end
	C.super.ctor(self,node)
end

function C:onCreate()
    for i=1,5 do
        local key = string.format("node%d",i)
        local node = self[key]
        node:getChildByName("win_img"):setVisible(false)
        node:getChildByName("lose_img"):setVisible(false)
    end
    self.losePanel:setVisible(false)
    self.winPanel:setVisible(false)
end

function C:showWinCoin( seatId, coinString )
    if seatId < 1 or seatId > 5 then
        return
    end
	local key = string.format("node%d",seatId)
	local node = self[key]
	local bg = node:getChildByName("win_img")
	self:showCoinChange( bg, coinString )
end

function C:showLoseCoin( seatId, coinString )
    if seatId < 1 or seatId > 5 then
        return
    end
    local key = string.format("node%d",seatId)
	local node = self[key]
	local bg = node:getChildByName("lose_img")
	self:showCoinChange( bg, coinString )
end

function C:showCoinChange( bg, str )
	self.node:setVisible(true)
	bg:setVisible(true)
	local label = bg:getChildByName("label")
	label:setString(str)
	local scale = 124/label:getContentSize().width
    scale = math.min(scale,1)
    label:setScale(scale)
	bg:setPosition(cc.p(50,50))
	bg:setOpacity(0)
	local array = {}
	array[1] = cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(50, 100)))
	array[2] = cc.DelayTime:create(2)
	array[3] = cc.FadeOut:create(0.5)
	array[4] = cc.CallFunc:create(function()
		bg:setVisible(false)
	end)
	bg:runAction(cc.Sequence:create(array))
end

function C:playWinnerAnimation( seatId )
	local key = string.format("node%d",seatId)
	local node = self[key]
	local frame = cc.ParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/frame.plist")
    frame:setAutoRemoveOnFinish(true)
    frame:setAnchorPoint(cc.p(0.5, 0.5))
    frame:setPosition(cc.p(50,50))
    node:addChild(frame,-1)

    local star = cc.ParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/star.plist")
    star:setAutoRemoveOnFinish(true)
    star:setAnchorPoint(cc.p(0.5, 0.5))
    star:setPosition(cc.p(50,50))
    node:addChild(star,-1)
end

function C:showYouWin( callback )
    --播放赢音效
    PLAY_SOUND(GAME_ZJH_SOUND_RES.."game_win.mp3")
	self.node:setVisible(true)
	self:playResultAnimation(self.winPanel,callback)
end

function C:showYouLose( callback )
    --播放输音效
    PLAY_SOUND(GAME_ZJH_SOUND_RES.."game_over.mp3")
	self.node:setVisible(true)
	self:playResultAnimation(self.losePanel,callback)
end

function C:playResultAnimation( node, callback )
	node:setVisible(true)
	node:setScale(0)
	local array = {}
	array[1] = cc.EaseBackOut:create(cc.ScaleTo:create(0.4,1))
	array[2] = cc.DelayTime:create(0.5)
	array[3] = cc.EaseBackIn:create(cc.ScaleTo:create(0.4,0))
	array[4] = cc.DelayTime:create(0.2)
	array[5] = cc.CallFunc:create(function()
		node:setVisible(false)
		if callback then
			callback()
		end
	end)
	node:runAction(cc.Sequence:create(array))
end

return C