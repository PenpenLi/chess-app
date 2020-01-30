local PokerClass = import(".ZjhPokerClass")
local C = class("ZjhPlayerClass",ViewBaseClass)

C.BINDING = {
	headPanel = {path="head_panel"},
	headImg = {path="head_panel.head_img"},
	frameImg = {path="head_panel.frame_img"},
    vipImg = {path="head_panel.vip_img"},
    vipLabel = {path="head_panel.vip_img.label"},
	accountLabel = {path="head_panel.info_img.account_label"},
	blanceLabel = {path="head_panel.info_img.gold_img.label"},
    cityImg = {path="head_panel.info_img.city_img"},
    cityLabel = {path="head_panel.info_img.city_img.label"},
	timerNode = {path="head_panel.timer_node"},
	speakImg = {path="speak_img"},
	waittingImg = {path="waitting_img"},
	pokerPanel = {path="poker_panel"},
	statusImg = {path="poker_panel.status_img"},
	chipsImg = {path="chips_img"},
	chipsLabel = {path="chips_img.label"},
	pokerTypeNode = {path="poker_panel.type_node"},
	pokerTypeImg = {path="poker_panel.type_node.img"},
	--玩家自己，下注筹码数量右边得牌型文本
	typeImg = {path="type_img"},
	typeLabel = {path="type_img.label"},
}
C.pokerClassArr = nil
C.pokerPosArr = nil
C.pokerScale = nil
C.playerInfo = nil
C.hadTurnPoker = false
C.pokerDataArr = nil
C.pokerType = nil
C.isLeft = true

function C:ctor( node )
	for i=1,3 do
		local key = string.format("poker%d",i)
		local path = string.format("poker_panel.poker_%d",i)
		self.BINDING[key] = {path=path}
	end
	C.super.ctor(self,node)
end

function C:onCreate()
	C.super.onCreate(self)
	self.pokerClassArr = {}
	self.pokerPosArr = {}
	for i=1,3 do
		local key = string.format("poker%d",i)
		local panel = self[key]
		local poker = PokerClass.new(panel)
		self.pokerClassArr[i] = poker
		self.pokerPosArr[i] = cc.p(panel:getPosition())
		if self.pokerScale == nil then
			self.pokerScale = panel:getScale()
		end
	end
    self.vipImg:setVisible(false)
	self:clean()
end

function C:setVisible( flags )
	C.super.setVisible(self,flags)
	if flags == false then
		self.playerInfo = nil
		self:clean()
	end
end

function C:clean()
	self:setStatus(0)
	self:setSpeak(0)
	self:hideChips()
	self:hideTimer()
	self:hideWaitting()
	self:hidePoker()
	self.pokerDataArr = nil
	self.pokerType = nil
end

function C:show( info )
	if info == nil then
		return
	end
    dump(info,"playerInfo")
	self.playerInfo = info
	self:setVisible(true)
	--头像
    local headId = info["headid"]
    local headRes = GET_HEADID_RES( headId )
    self.headImg:loadTexture(headRes)
    --头像框
    -- local frameId = self.playerInfo.cbVipLevel2 or 0
    -- self.frameImg:loadTexture(GET_FRAMEID_RES(frameId))
    --vip
    -- self.vipLabel:setString(tostring(self.playerInfo.cbVipLevel2))
    --ID
    local nickname = info["nickname"] or tostring(info["playerid"])
    self.accountLabel:setString(nickname)
    --位置
    local city = info["city"] or info["nickname"]
    city = string.gsub(city,"省","")
    city = string.gsub(city,"市","")
    if self.cityLabel then
        self.cityLabel:setString(city)
        local x = 76-(self.cityLabel:getContentSize().width+20)/2+9
        self.cityImg:setPositionX(x)
    end
    --余额
    local blance = info["money"]
    self.blanceLabel:setString(utils:moneyString(blance))
end

function C:grayHead()
    self.headPanel:setColor(cc.c3b(100, 100, 100))
end

function C:lightHead()
    self.headPanel:setColor(cc.c3b(255, 255, 255))
end

function C:showWaitting()
	self.waittingImg:setVisible(true)
	self:grayHead()
end

function C:hideWaitting()
	self.waittingImg:setVisible(false)
	self:lightHead()
end

function C:setBlance( money )
	self.playerInfo["money"] = money
	local str = utils:moneyString(money)
	self.blanceLabel:setString(str)
end

function C:sendPokerAni( delay, callback) 
    local sendAni = function()
    	self.pokerPanel:setVisible(true)
        --播放发牌音效
        PLAY_SOUND(GAME_ZJH_SOUND_RES.."sendcards.mp3")
        local beginPos = self.pokerPanel:convertToNodeSpace( cc.p(display.cx,display.cy) )
        local endPos1 = self.pokerPosArr[1]
        local isSelf = self.node:getTag() == 1
        for i=1,3 do
            local pokerClass = self.pokerClassArr[i]
            pokerClass:setVisible(true)
            pokerClass.node:setScale(0.42)
            pokerClass.node:setPosition(beginPos)
            local endPos2 = self.pokerPosArr[i]
            local distanceX = math.abs(endPos2.x-endPos1.x)
            local moveTime = distanceX/900
            if isSelf then
                moveTime = distanceX/1600
            end
            local array = {}
            array[1] = cc.DelayTime:create(0.02 * (i-1))
            array[2] = self:createSendCardActionPart1( beginPos, endPos1, isSelf )
            array[3] = cc.DelayTime:create(0.02*(3-i))
            array[4] = cc.MoveTo:create(moveTime,endPos2)
            array[5] = cc.CallFunc:create(function()
                if i == 3 and callback then
                    callback()
                end
            end)
            pokerClass.node:runAction( cc.Sequence:create(array) )
        end
    end
    local array = {}
    array[1] = cc.DelayTime:create(delay)
    array[2] = cc.CallFunc:create(function()
        sendAni()
    end)
    self.node:runAction(cc.Sequence:create(array))
end

function C:createSendCardActionPart1( startPos, endPos, isSelf )
    local gapX = 20
    local gapY = 260

    local p1 = cc.p(0,0)
    local p2 = cc.p(0,0)

    if startPos.x <= endPos.x then
        p1.x = startPos.x + gapX
        p2.x = math.max(endPos.x - gapX * 2,p1.x + 10)
    else
        p1.x = startPos.x - gapX
        p2.x = math.min(endPos.x + gapX * 2,p1.x - 10)
    end

    if startPos.y <= endPos.y then
        p1.y = startPos.y + gapY
        p2.y = math.max(endPos.y + gapY / 2,p1.y + 10) 
    else
        p1.y = startPos.y + gapY
        p2.y = endPos.y + gapY / 2
    end

    local speed = 600
    local time = cc.pGetDistance(startPos, endPos) / speed
 
    local easeIn = cc.EaseIn:create(cc.BezierTo:create(time,{p1,p2,endPos}),1.5)

    local spawn = nil

    if isSelf then
        spawn = cc.Spawn:create({cc.ScaleTo:create(time,self.pokerScale),easeIn})
    else
        spawn = cc.Spawn:create({easeIn})
    end
    return spawn
end

function C:sendPokerImm()
	self.pokerPanel:setVisible(true)
    for i=1,3 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass.node:setScale( self.pokerScale )
        pokerClass.node:setPosition( self.pokerPosArr[i] )
        pokerClass.node:setVisible(true)
    end
end

function C:setPokerData( dataArr, ctype )
	self.pokerDataArr = utils:copyTable(dataArr)
	self.pokerType = ctype
	for i=1,3 do
        local pokerClass = self.pokerClassArr[i]
        local data = self.pokerDataArr[i]
        local pcolor = data["color"]
        local pvalue = data["number"]
        pokerClass:setPokerData( pcolor, pvalue )
    end
end

function C:openPoker(animated)
	if self.hadTurnPoker then
        return
    end
    self.hadTurnPoker = true
    self:setStatus(0)
    local isMe = self.node:getTag()==1
    for i=1,3 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:frontgroundPoker(isMe)
    end
    self:showPokerType(self.pokerType,animated)
end

function C:hidePoker()
	self.hadTurnPoker = false
	self.statusImg:setVisible(false)
	self:hidePokerType()
    self.pokerPanel:setVisible(false)
	local animated = self.node:getTag()==1
	for i=1,3 do
		local pokerClass = self.pokerClassArr[i]
		pokerClass:backgroundPoker(animated)
        pokerClass:setVisible(false)
	end
end

function C:grayPoker()
    for i=1,3 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:graygroundPoker()
    end
end

function C:showPokerType( ctype, animated )
    local name = ""
    local text = ""
    
    if ctype == ZJH.POKER_TYPE.SANPAI or ctype == ZJH.POKER_TYPE.SANPAI_A or ctype == ZJH.POKER_TYPE.TESHU then
    	text = "散牌"
    elseif ctype == ZJH.POKER_TYPE.DUIZI then
    	text = "对子"
    	name = "pairs.png"
    elseif ctype == ZJH.POKER_TYPE.SHUNZI then
    	text = "顺子"
    	name = "straight.png"
    elseif ctype == ZJH.POKER_TYPE.JINHUA then
    	text = "金花"
    	name = "gold_flower.png"
    elseif ctype == ZJH.POKER_TYPE.SHUNJIN then
    	text = "顺金"
    	name = "straight_gold.png"
    elseif ctype == ZJH.POKER_TYPE.BAOZI then
    	text = "豹子"
    	name = "panther.png"
    end

    if self.typeLabel then
    	self.typeImg:setVisible(true)
    	self.typeLabel:setString(text)
    end

    if name == "" then
    	return
    end

    self.pokerTypeImg:loadTexture(GAME_ZJH_IMAGES_RES..name)

    if animated then
        self.pokerTypeNode:setVisible(true)
    	self.pokerTypeImg:setOpacity(0)
    	local delay = cc.DelayTime:create(0.2)
		local fadenIn = cc.FadeIn:create(0.3)
		local callfun = cc.CallFunc:create(function()
			--播放好牌音效
    		PLAY_SOUND(GAME_ZJH_SOUND_RES.."special_bg.mp3")
			local particle = cc.ParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/star01.plist")
            particle:setScale(0.6)
            particle:setAutoRemoveOnFinish(true)
            local x = self.pokerTypeImg:getContentSize().width/2
            local y = self.pokerTypeImg:getContentSize().height/2
            particle:setPosition(cc.p(x,y))
	    	particle:setAnchorPoint(cc.p(0.5, 0.5))
            self.pokerTypeImg:addChild(particle)
		end)
		local seq = cc.Sequence:create({delay,callfun})
		local spawn = cc.Spawn:create({seq,fadenIn})
		self.pokerTypeImg:runAction(spawn)
    else
    	self.pokerTypeImg:setOpacity(255)
    	self.pokerTypeNode:setVisible(true)
    end
end

function C:hidePokerType()
	self.pokerTypeNode:setVisible(false)
	if self.typeImg then
		self.typeImg:setVisible(false)
	end
end

function C:setChips( chips )
	local str = utils:moneyString(chips)
	self.chipsLabel:setString(str)
	self.chipsImg:setVisible(true)
end

function C:hideChips()
	self.chipsLabel:setString("")
	self.chipsImg:setVisible(false)
end

--0:隐藏 1:看牌 2:淘汰 3:弃牌
function C:setStatus(status)
	if status == 0 then
		self.statusImg:setVisible(false)
		return
	end
	if status == 1 then
        if self.node:getTag() == 1 then
            return
        end
		self.statusImg:loadTexture(GAME_ZJH_IMAGES_RES.."img_ts_yikanpai.png")
	elseif status == 2 then
		self.statusImg:loadTexture(GAME_ZJH_IMAGES_RES.."img_ts_bipaishu.png")
        self:grayHead()
        self:grayPoker()
	elseif status == 3 then
		self.statusImg:loadTexture(GAME_ZJH_IMAGES_RES.."img_ts_qipai.png")
        self:grayHead()
        self:setSpeak(0)
        self:grayPoker()
	end
	self.statusImg:setVisible(true)
end

--0:隐藏 1:跟注  2:加注  3:看牌  4:比牌  5:全押
function C:setSpeak( status )
	if status == 0 then
		self.speakImg:setVisible(false)
		return
	end
    local resname = ""
	if status == 1 then
        resname = GAME_ZJH_IMAGES_RES.."img_gz_l.png"
        if self.isLeft == false then
            resname = GAME_ZJH_IMAGES_RES.."img_gz_r.png"
        end
	elseif status == 2 then
		resname = GAME_ZJH_IMAGES_RES.."img_jz_l.png"
        if self.isLeft == false then
            resname = GAME_ZJH_IMAGES_RES.."img_jz_r.png"
        end
        self.speakImg:loadTexture(resname)
	elseif status == 3 then
		resname = GAME_ZJH_IMAGES_RES.."img_kp_l.png"
        if self.isLeft == false then
            resname = GAME_ZJH_IMAGES_RES.."img_kp_r.png"
        end
        self.speakImg:loadTexture(resname)
	elseif status == 4 then
		resname = GAME_ZJH_IMAGES_RES.."img_bp_l.png"
        if self.isLeft == false then
            resname = GAME_ZJH_IMAGES_RES.."img_bp_r.png"
        end
        self.speakImg:loadTexture(resname)
	elseif status == 5 then
		resname = GAME_ZJH_IMAGES_RES.."img_qy_l.png"
        if self.isLeft == false then
            resname = GAME_ZJH_IMAGES_RES.."img_qy_r.png"
        end
	end
    if resname ~= "" then
        -- self.speakImg:loadTexture(resname)
        -- self.speakImg:setVisible(true)
        self:showSpeakAni(resname)
    end
end

function C:showSpeakAni( resname )
    local sprite = display.newSprite(resname)
    local x = 10
    local ap = cc.p(1,0.5)
    if self.isLeft then
        x = 90
        ap = cc.p(0,0.5)
    end
    sprite:setAnchorPoint(ap)
    sprite:setPosition(cc.p(x,70))
    self.node:addChild(sprite)
    local time = 1.2
    local moveArray = {}
    moveArray[#moveArray+1] = cc.MoveTo:create(time,cc.p(x,130))
    moveArray[#moveArray+1] = cc.CallFunc:create(function()
        sprite:removeFromParent(true)
    end)
    local fadeArray = {}
    fadeArray[#fadeArray+1] = cc.DelayTime:create(time/2)
    fadeArray[#fadeArray+1] = cc.FadeOut:create(time/2)

    sprite:runAction(cc.Sequence:create(moveArray))
    sprite:runAction(cc.Sequence:create(fadeArray))
end

function C:showTimer( time, callback )
    self:hideTimer()
	self.timerNode:setVisible( true )
    local countdown = math.floor(time)
    if countdown > 15 then
        countdown = 15
    elseif countdown < 1 then
        countdown = 1
    end

    local greenColor = cc.c3b(119,255,0)
    local yellowColor = cc.c3b(255,237,0)
    local redColor = cc.c3b(255,0,26)

    local greenLight = GAME_ZJH_ANIMATION_RES.."particle/light_green.plist"
    local yellowLight = GAME_ZJH_ANIMATION_RES.."particle/light_yellow.plist"
    local redLight = GAME_ZJH_ANIMATION_RES.."particle/light_red.plist"

    --倒计时框
    local boxSprite = display.newSprite(GAME_ZJH_IMAGES_RES.."timer_box.png")
    local progressTimer = cc.ProgressTimer:create(boxSprite)
    self.timerNode:addChild(progressTimer)
    progressTimer:setScale(0.96)
    progressTimer:setPosition(cc.p(0,0))
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    progressTimer:setReverseDirection(true)
    progressTimer:setAnchorPoint(cc.p(0.5,0.5))
    progressTimer:setMidpoint(cc.p(0.5,0.5))
    local percentage = countdown/15*100
    progressTimer:setPercentage(percentage)
    if countdown >=9 then
        progressTimer:setColor(greenColor)
    elseif countdown >= 5 then
        progressTimer:setColor(yellowColor)
    else
        progressTimer:setColor(redColor)
    end
    --动画
    local array = {}
    array[1] = cc.ProgressTo:create(countdown,0)
    array[2] = cc.CallFunc:create(function ()
        self:hideTimer()
        if callback then
            callback()
        end
    end)
    
    --倒计时光点
    local lightNode = display.newNode()
    lightNode:setLocalZOrder(100)
    self.timerNode:addChild(lightNode)
    local lightDot = nil
    if countdown >=9 then
        lightDot = cc.ParticleSystemQuad:create(greenLight)
    elseif countdown >= 5 then
        lightDot = cc.ParticleSystemQuad:create(yellowLight)
    else
        lightDot = cc.ParticleSystemQuad:create(redLight)
    end
    lightDot:setAnchorPoint(cc.p(0.5, 0.5))
    lightDot:setPosition(cc.p(0,0))
    lightNode:addChild(lightDot)
    --动画
    local array2 = {}
    local time_1_8 = 1875 --15000/8
    local taketime = (15-countdown)*1000
    local width = 46
    if taketime < time_1_8 then
        local x = width*(taketime/time_1_8)
        local pos = cc.p(x,width)
        lightNode:setPosition(pos)
        local remaintime = (time_1_8-taketime)
        array2[1] = cc.MoveTo:create(remaintime/1000,cc.p(width,width))
        array2[2] = cc.MoveTo:create((time_1_8*2)/1000,cc.p(width,-width))
        array2[3] = cc.MoveTo:create((time_1_8*2)/1000,cc.p(-width,-width))
        array2[4] = cc.MoveTo:create((time_1_8*2)/1000,cc.p(-width,width))
        array2[5] = cc.MoveTo:create(time_1_8/1000,cc.p(0,width))
    elseif taketime < 3*time_1_8 then
        local y = width-((taketime-time_1_8)/(time_1_8*2))*(width*2)
        local pos = cc.p(width,y)
        lightNode:setPosition(pos)
        local remaintime = (time_1_8*3-taketime)
        array2[1] = cc.MoveTo:create(remaintime/1000,cc.p(width,-width))
        array2[2] = cc.MoveTo:create((time_1_8*2)/1000,cc.p(-width,-width))
        array2[3] = cc.MoveTo:create((time_1_8*2)/1000,cc.p(-width,width))
        array2[4] = cc.MoveTo:create(time_1_8/1000,cc.p(0,width))
    elseif taketime < 5*time_1_8 then
        local x = width-((taketime-time_1_8*3)/(time_1_8*2))*(width*2)
        local pos = cc.p(x,-width)
        lightNode:setPosition(pos)
        local remaintime = (time_1_8*5-taketime)
        array2[1] = cc.MoveTo:create(remaintime/1000,cc.p(-width,-width))
        array2[2] = cc.MoveTo:create((time_1_8*2)/1000,cc.p(-width,width))
        array2[3] = cc.MoveTo:create(time_1_8/1000,cc.p(0,width))
    elseif taketime < 7*time_1_8 then
        local y = -width+((taketime-time_1_8*5)/(time_1_8*2))*(width*2)
        local pos = cc.p(-width,y)
        lightNode:setPosition(pos)
        local remaintime = (time_1_8*7-taketime)
        array2[1] = cc.MoveTo:create(remaintime/1000,cc.p(-width,width))
        array2[2] = cc.MoveTo:create(time_1_8/1000,cc.p(0,width))
    else
        local x = -width+((taketime-time_1_8*7)/time_1_8)*width
        local pos = cc.p(x,width)
        lightNode:setPosition(pos)
        local remaintime = (time_1_8*8-taketime)
        array2[1] = cc.MoveTo:create(remaintime/1000,cc.p(0,width))
    end

    --播放动画
    progressTimer:runAction(cc.Sequence:create(array))
    lightNode:runAction(cc.Sequence:create(array2))

    --倒计时定时器
    local timerName = "zjh.player_timer_"..tostring(self.node:getTag())
    utils:createTimer(timerName,1,function()
        if countdown == 9 then
            progressTimer:setColor(yellowColor)
            lightNode:removeAllChildren(true)
            local dot = cc.ParticleSystemQuad:create(yellowLight)
            dot:setAnchorPoint(cc.p(0.5, 0.5))
            dot:setPosition(cc.p(0,0))
            lightNode:addChild(dot)
        elseif countdown == 5 then
            progressTimer:setColor(redColor)
            lightNode:removeAllChildren(true)
            local dot = cc.ParticleSystemQuad:create(redLight)
            dot:setAnchorPoint(cc.p(0.5, 0.5))
            dot:setPosition(cc.p(0,0))
            lightNode:addChild(dot)
        end
        countdown = countdown - 1
        if countdown and countdown < 0 then
            self:hideTimer()
        end
    end)
end

function C:hideTimer()
	local timerName = "zjh.player_timer_"..tostring(self.node:getTag())
    utils:removeTimer(timerName)
    self.timerNode:removeAllChildren(true)
    self.timerNode:setVisible(false)
end

return C