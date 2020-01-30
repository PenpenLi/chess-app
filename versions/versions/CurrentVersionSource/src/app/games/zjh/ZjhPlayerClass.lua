local PokerClass = import(".ZjhPokerClass")
local C = class("ZjhPlayerClass",ViewBaseClass)

C.BINDING = {
	headPanel = {path="head_panel"},
    headImg = {path="head_panel.head_img"},
	nameLabel = {path="head_panel.name_label"},
	blanceLabel = {path="head_panel.blance_label"},
    cityLabel = {path="head_panel.city_label"},
	timerNode = {path="head_panel.timer_node"},
	speakImg = {path="speak_img"},
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
    self:lightHead()
	self:setStatus(0)
	self:setSpeak(0)
	self:hideChips()
	self:hideTimer()
	self:hidePoker()
	self.pokerDataArr = nil
	self.pokerType = nil
end

function C:show( info )
	if info == nil then
		return
    end
    dump(info,"显示玩家信息")
	self.playerInfo = info
	self:setVisible(true)
	--头像
    local headId = info["headid"]
    local headUrl = info["wxheadurl"]
    SET_HEAD_IMG(self.headImg,headId,headUrl)
    
    --昵称
    local nickname = info["nickname"]
    if nickname == nil or nickname == "" then
        nickname = tostring(info["playerid"])
    end
    nickname = utils:nameStandardString(nickname,20,104)
    self.nameLabel:setString(nickname)
    --位置
    if self.cityLabel then
        local city = info["city"] or "未知"
        city = string.gsub(city,"省","")
        city = string.gsub(city,"市","")
        self.cityLabel:setString(city)
    end
    --余额
    if self.blanceLabel then
        local blance = info["money"]
        self.blanceLabel:setString(utils:moneyString(blance))
    end
end

function C:setBlance( money )
	self.playerInfo["money"] = money
    if self.blanceLabel then
	   local str = utils:moneyString(money)
	   self.blanceLabel:setString(str)
    end
end

function C:grayHead()
    self.headPanel:setColor(cc.c3b(100, 100, 100))
end

function C:lightHead()
    self.headPanel:setColor(cc.c3b(255, 255, 255))
end

-- function C:sendPokerAni( delay, callback) 
--     local sendAni = function()
--         self.pokerPanel:setVisible(true)
--         --播放发牌音效
--         PLAY_SOUND(GAME_ZJH_SOUND_RES.."sendcards.mp3")
--         local beginPos = self.pokerPanel:convertToNodeSpace( cc.p(display.cx,display.cy) )
--         for i=1,3 do
--             local pokerClass = self.pokerClassArr[i]
--             pokerClass:setVisible(true)
--             pokerClass.node:setPosition(beginPos)
--             pokerClass.node:setOpacity(0)
--             local endPos = self.pokerPosArr[i]
--             local time = 0.12
--             local interval = 0.03
--             local moveAni = cc.MoveTo:create(time,endPos)
--             local fadeAni = cc.FadeIn:create(time)
--             local array = {}
--             array[#array+1] = cc.DelayTime:create(interval * (i-1))
--             array[#array+1] = transition.spawn({moveAni,fadeAni})
--             if i==3 and callback then
--                 array[#array+1] = cc.CallFunc:create(callback)
--             end
--             pokerClass.node:runAction( cc.Sequence:create(array) )
--         end
--     end
--     local array = {}
--     array[1] = cc.DelayTime:create(delay)
--     array[2] = cc.CallFunc:create(function()
--         sendAni()
--     end)
--     self.node:runAction(cc.Sequence:create(array))
-- end

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
        pokerClass.node:setOpacity(255)
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
    self:showPokerType(self.pokerType,animated)
	if self.hadTurnPoker then
        return
    end
    self.hadTurnPoker = true
    local isMe = self.node:getTag()==1
    for i=1,3 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:frontgroundPoker(isMe)
    end
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
        pokerClass.node:setOpacity(255)
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
    local isBig = true
    
    if ctype == ZJH.POKER_TYPE.SANPAI or ctype == ZJH.POKER_TYPE.SANPAI_A or ctype == ZJH.POKER_TYPE.TESHU then
    	text = "散牌"
        name = "shan"
        isBig = false
    elseif ctype == ZJH.POKER_TYPE.DUIZI then
    	text = "对子"
    	name = "pairs"
    elseif ctype == ZJH.POKER_TYPE.SHUNZI then
    	text = "顺子"
    	name = "straight"
    elseif ctype == ZJH.POKER_TYPE.JINHUA then
    	text = "金花"
    	name = "gold_flower"
    elseif ctype == ZJH.POKER_TYPE.SHUNJIN then
    	text = "顺金"
    	name = "straight_gold"
    elseif ctype == ZJH.POKER_TYPE.BAOZI then
    	text = "豹子"
    	name = "panther"
    end

    if self.typeLabel then
    	self.typeImg:setVisible(true)
    	self.typeLabel:setString(text)
    end

    if name == "" then
    	return
    end

    if self.node:getTag() == 1 then
        name = name.."_zz.png"
    else
        name = name..".png"
    end
    self.pokerTypeImg:stopAllActions()
    self.pokerTypeImg:loadTexture(GAME_ZJH_IMAGES_RES..name)
    self.pokerTypeImg:setOpacity(255)
    self.pokerTypeNode:setVisible(true)
    if animated then
        local array = {}
        if isBig then
            PLAY_SOUND(GAME_ZJH_SOUND_RES.."special_bg.mp3")
            local particle = cc.ParticleSystemQuad:create(GAME_ZJH_ANIMATION_RES.."particle/star01.plist")
            particle:setScale(0.6)
            particle:setAutoRemoveOnFinish(true)
            local x = self.pokerTypeImg:getContentSize().width/2
            local y = self.pokerTypeImg:getContentSize().height/2
            particle:setPosition(cc.p(x,y))
            particle:setAnchorPoint(cc.p(0.5, 0.5))
            self.pokerTypeImg:addChild(particle)
            array[#array+1] = cc.DelayTime:create(1.7)
        else
            array[#array+1] = cc.DelayTime:create(1.2)
        end
        array[#array+1] = cc.FadeOut:create(0.5)
        self.pokerTypeImg:runAction(cc.Sequence:create(array))
    end

    if animated == false then
        self:movePokerType()
    end
end

function C:movePokerType()
    if self.pokerTypeNode:isVisible() == false or self.pokerTypeNode:getPositionY() ~= 0 then
        return
    end
    local y = 18
    if self.node:getTag() == 1 then
        y = 30
    end
    local beginPos = cc.p(self.pokerTypeNode:getPositionX(),0)
    local endPos = cc.p(self.pokerTypeNode:getPositionX(),y)
    self.pokerTypeNode:stopAllActions()
    self.pokerTypeNode:setPosition(endPos)
    -- self.pokerTypeNode:setPosition(beginPos)
    -- self.pokerTypeNode:runAction(cc.MoveTo:create(0.3,endPos))
end

function C:hidePokerType()
	self.pokerTypeNode:setVisible(false)
    self.pokerTypeNode:setPositionY(0)
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
        -- self:setSpeak(0)
        self:grayHead()
        self:grayPoker()
	elseif status == 3 then
		self.statusImg:loadTexture(GAME_ZJH_IMAGES_RES.."img_ts_qipai.png")
        -- self:setSpeak(0)
        self:grayHead()
        self:grayPoker()
	end
	self.statusImg:setVisible(true)
    self:movePokerType()
end

--0:隐藏 1:跟注  2:加注  3:看牌  4:比牌  5:孤注一掷 6:蒙跟 7:离开
function C:setSpeak( status )
	if status == 0 then
		self.speakImg:setVisible(false)
        if self.cityLabel then
            self.cityLabel:setVisible(true)
        end
        if self.nameLabel then
            self.nameLabel:setVisible(true)
        end
		return
	end

    if self.cityLabel and self.node:getTag() ~= 1 then
        self.cityLabel:setVisible(false)
    end
    if self.nameLabel and self.node:getTag() == 1 then
        self.nameLabel:setVisible(false)
    end

    local resname = ""
	if status == 1 then
        resname = GAME_ZJH_IMAGES_RES.."tips_genzhu.png"
	elseif status == 2 then
		resname = GAME_ZJH_IMAGES_RES.."tips_jiazhu.png"
	elseif status == 3 then
		resname = GAME_ZJH_IMAGES_RES.."tips_kanpai.png"
	elseif status == 4 then
		resname = GAME_ZJH_IMAGES_RES.."tips_bipai.png"
	elseif status == 5 then
		resname = GAME_ZJH_IMAGES_RES.."tips_gzyz.png"
    elseif status == 6 then
        resname = GAME_ZJH_IMAGES_RES.."tips_menggen.png"
    elseif status == 7 then
        resname = GAME_ZJH_IMAGES_RES.."tips_likai.png"
	end
    if resname ~= "" then
        self.speakImg:setTexture(resname)
        self.speakImg:setVisible(true)
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
    progressTimer:setScale(0.85)
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
    local width = 42
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
        if countdown <= 5 then
            PLAY_SOUND(GAME_ZJH_SOUND_RES.."warning.mp3")
        end
        countdown = countdown - 1
        if countdown < 0 then
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