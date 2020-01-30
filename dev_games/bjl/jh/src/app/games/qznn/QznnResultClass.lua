local C = class("QznnResultClass",ViewBaseClass)

C.BINDING = {
    losePanel = {path="lose_panel"},
    winPanel = {path="win_panel"},
}
C.playerNodeArr = nil
C.scheduler = nil
C.goldscheduleId1 = nil
C.goldscheduleId2 = nil

function C:ctor( node )
    for i=1,5 do
        local key = string.format("player%d",i)
        local path = {path=string.format("player_%d",i)}
        self.BINDING[key] = path
    end
	C.super.ctor(self,node)
end

function C:removeTimer()
    self:stopPlayFLyGoldSound()
end

function C:onCreate()
    self.playerNodeArr = {}
    for i=1,5 do
        local key = string.format("player%d",i)
        local node = self[key]
        self.playerNodeArr[i] = node
        node:getChildByName("win_img"):setVisible(false)
        node:getChildByName("lose_img"):setVisible(false)
    end
    self.losePanel:setVisible(false)
    self.winPanel:setVisible(false)
end

function C:setVisible( flags )
	self.node:setVisible(flags)
end

function C:showWinCoin( seatId, coinString )
    if seatId < 1 or seatId > 5 then
        return
    end
    
    local playerNode = self.playerNodeArr[seatId]
    local bg = playerNode:getChildByName("win_img")
    --判断一下如果是上边的两个位置，则y坐标小一点
    if seatId == 4 or seatId == 3 then
        self:showCoinChange( bg, coinString ,95)
    else
        self:showCoinChange(bg, coinString, 115)
    end
end

function C:showLoseCoin( seatId, coinString )
    if seatId < 1 or seatId > 5 then
        return
    end
    local playerNode = self.playerNodeArr[seatId]
    local bg = playerNode:getChildByName("lose_img")
    if seatId == 4 or seatId == 3 then
        self:showCoinChange( bg, coinString ,95)
    else
        self:showCoinChange(bg, coinString, 115)
    end
end

function C:showCoinChange( bg, str, PosY )
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
	--array[1] = cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(50, 100)))
    array[1] = cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(50, PosY)))
	array[2] = cc.DelayTime:create(2)
	array[3] = cc.FadeOut:create(0.5)
	array[4] = cc.CallFunc:create(function()
		bg:setVisible(false)
	end)
	bg:runAction(cc.Sequence:create(array))
end

function C:playWinnerAnimation( seatId )
	local playerNode = self.playerNodeArr[seatId]
	local frame = cc.ParticleSystemQuad:create(GAME_QZNN_ANIMATION_RES.."particle/frame.plist")
    frame:setAutoRemoveOnFinish(true)
    frame:setAnchorPoint(cc.p(0.5, 0.5))
    frame:setPosition(cc.p(50,50))
    playerNode:addChild(frame,-1)

    local star = cc.ParticleSystemQuad:create(GAME_QZNN_ANIMATION_RES.."particle/star.plist")
    star:setAutoRemoveOnFinish(true)
    star:setAnchorPoint(cc.p(0.5, 0.5))
    star:setPosition(cc.p(50,50))
    playerNode:addChild(star,-1)
end

function C:showYouWin( callback )
    --播放赢音效
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."game_win.mp3")
	self.node:setVisible(true)
	self:playResultAnimation(self.winPanel,callback)
end

function C:showYouLose( callback )
    --播放输音效
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."game_over.mp3")
	self.node:setVisible(true)
	self:playResultAnimation(self.losePanel,callback)
end

function C:playResultAnimation( node, callback )
	node:setVisible(true)
	node:setScale(0)
	local array = {}
	array[1] = cc.EaseBackOut:create(cc.ScaleTo:create(0.5,1))
	array[2] = cc.DelayTime:create(0.5)
	array[3] = cc.EaseBackIn:create(cc.ScaleTo:create(0.5,0))
	array[4] = cc.DelayTime:create(0.5)
	array[5] = cc.CallFunc:create(function()
		node:setVisible(false)
		if callback then
			callback()
		end
	end)
	node:runAction(cc.Sequence:create(array))
end

function C:playFlyCoinAnimation( banker, losers, winners, callback )
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
    self:flyBankerWin( banker, losers, winners, callback )
end

function C:getPositionBySeatId( seatId )
	local playerNode = self.playerNodeArr[seatId]
	return cc.p( playerNode:getPositionX(), playerNode:getPositionY() )
end

function C:flyBankerWin( banker, losers, winners, callback )
    if banker == nil or banker == -1 then return end
    local goldNum = 50

    local batch = display.newLayer()
    batch:setContentSize(cc.size(self.node:getContentSize().width,self.node:getContentSize().height))
    batch:setAnchorPoint(cc.p(0,0))
    batch:setLocalZOrder(100)
    self.node:addChild(batch)

    local maxGoldNum = 0
    local curGoldNum = 0
    local isOnlyFirst = false

    if #losers > 0 then
        self:playFLyGoldSound()

        if #winners == 0 then
            isOnlyFirst = true
        end

        for i,v in ipairs(losers) do
            local num = goldNum
            for m = 1,num do
                local startPos = self:getPositionBySeatId(v)
                local endPos = self:getPositionBySeatId(banker)

                local delayWin = 0.01 * (m - 1)
                local timerName = string.format("qznn.flywin%d_%d",m,i)
                utils:delayInvoke(timerName,delayWin,function()
                    local callbackGold = function()
                        curGoldNum = curGoldNum + 1

                        if curGoldNum == 1 then
                            self:flyGoldPar({banker})
                        elseif curGoldNum <= maxGoldNum - 35 then
                            local gold = batch:getChildByTag(curGoldNum)
                            if gold then
                                local arr = {}
                                arr[1] = CCDelayTime:create(0.02 * (maxGoldNum - 15) / 2)
                                arr[2] = CCCallFunc:create(function ()
                                    gold:setVisible(false)
                                end)
                                gold:runAction(cc.Sequence:create(arr))
                            end
                        elseif curGoldNum == maxGoldNum then
                            self:stopPlayFLyGoldSound()

                            for i = 1,curGoldNum do
                                local gold = batch:getChildByTag(i)
                                local fadeOut = CCFadeOut:create(0.2)
                                gold:runAction(fadeOut)
                            end

                            local delay = CCDelayTime:create(0.4)
                            local callfun = CCCallFunc:create(function (  )
                                batch:removeFromParent(true)
                                if not isOnlyFirst then
                                    self:flyBankerLose( banker, winners, callback )
                                end
                            end)

                            batch:runAction(cc.Sequence:create({delay,callfun}))
                        end
                    end

                    maxGoldNum = maxGoldNum + 1
                
                    self:flyGold(batch,startPos,endPos,callbackGold,maxGoldNum)
                end)
            end
        end
    else
        batch:removeFromParent(true)
        self:flyBankerLose( banker, winners, callback )
    end
end

function C:flyBankerLose( banker, winners, callback )
    local goldNum = 50
    local batch = display.newLayer()
    batch:setContentSize(cc.size(self.node:getContentSize().width,self.node:getContentSize().height))
    batch:setAnchorPoint(cc.p(0,0))
    batch:setLocalZOrder(100)
    self.node:addChild(batch)

    local maxGoldNum = 0
    local curGoldNum = 0

    if #winners > 0 then
        self:playFLyGoldSound()
        for i,v in ipairs(winners) do
            local winnerGoldNum = 0
            local num = goldNum
            for m = 1,num do
                local startPos = self:getPositionBySeatId(banker)
                local endPos = self:getPositionBySeatId(v)

                local delayLose = 0.01 * (m - 1)
                local timerName = string.format("qznn.flylose%d_%d",m,i)
                utils:delayInvoke(timerName,delayLose,function()
                    local callbackGold = function (  )
                        winnerGoldNum = winnerGoldNum + 1
                        curGoldNum = curGoldNum + 1

                        if winnerGoldNum == 1 then
                            self:flyGoldPar({v})
                        end
                        
                        if curGoldNum == maxGoldNum then
                            self:stopPlayFLyGoldSound()

                            for i = 1,curGoldNum do
                                local gold = batch:getChildByTag(i)
                                local fadeOut = CCFadeOut:create(0.2)
                                gold:runAction(fadeOut)
                            end

                            local delay = CCDelayTime:create(0.4)
                            local callfun = CCCallFunc:create(function (  )
                                batch:removeFromParent(true)
                            end)
                            batch:runAction(cc.Sequence:create({delay,callfun}))
                        end
                    end

                    maxGoldNum = maxGoldNum + 1

                    self:flyGold(batch,startPos,endPos,callbackGold,maxGoldNum)
                end)
            end
        end
    else
        batch:removeFromParent(true)
    end
end

function C:flyGold( parent, startPos, endPos, callback, tag )
    local gold = display.newSprite(GAME_QZNN_IMAGES_RES.."fly_gold.png")
    gold:setScale(0.7)
    gold:setTag(tag)
    gold:setLocalZOrder(100)
    parent:addChild(gold)

    local width = 100 / 4

    local gapX = math.random(-width, width)
    local gapY = math.random(-width, width)

    local startX = gapX + startPos.x
    local startY = gapY + startPos.y

    local x = gapX * 1.1 + endPos.x
    local y = gapY * 1.1 + endPos.y

    gold:setPosition(cc.p(startX,startY))

    local realEndPos = cc.p(x, y)
    
    local speed = 920
    local time = cc.pGetDistance(startPos, realEndPos) / speed

    local endX = endPos.x + 50
    local endY = endPos.y + 120

    local p1 = cc.p(startX,startY)
    local p2 = cc.p(startX + (endX - startX) * 0.5,startY + (endY - startY) * 0.6 + 100)
    
    local easeOut = cc.EaseOut:create(cc.BezierTo:create(time,{p1,p2,realEndPos}),0.8)
    local callfun = cc.CallFunc:create(function (  )
        if callback then
            callback()
        end
    end)
    gold:runAction(cc.Sequence:create({easeOut,callfun}))
end

function C:playFLyGoldSound()
    self:stopPlayFLyGoldSound()
    utils:createTimer("qznn.QznnFlyGoldTimer",0.2,function()
        --播放飞金币音效
        PLAY_SOUND(GAME_QZNN_SOUND_RES.."fly_gold.mp3")
    end)

    utils:createTimer("qznn.QznnFlyGoldTimer2",0.35,function()
        --播放飞金币音效
        PLAY_SOUND(GAME_QZNN_SOUND_RES.."fly_gold.mp3")
    end)
end

function C:stopPlayFLyGoldSound()
    utils:removeTimer("qznn.QznnFlyGoldTimer")
    utils:removeTimer("qznn.QznnFlyGoldTimer2")
end

function C:flyGoldPar( seats )
    for i,v in ipairs(seats) do
        self:playWinnerAnimation(v)
    end
end

return C