local PokerClass = import(".QznnPokerClass")
local C = class("QznnPlayerClass",ViewBaseClass)

C.cardtype=1    --牌图集有两种，1为整张牌，2为散件牌，需要重新组装的

C.BINDING = {
    headPanel = {path="head_panel"},
    headImg = {path="head_panel.head_img"},
    frameImg = {path="head_panel.frame_img"},
    vipLabel = {path="head_panel.vip_img.label"},
    blanceLabel = {path="head_panel.gold_img.label"},
    accountLabel = {path="head_panel.account_label"},
    locationLabel = {path="head_panel.location_img.label"},
    zhuangImg = {path="head_panel.zhuang_img"},
    tipsImg = {path="head_panel.tips_img"},
    niunPanel = {path="niun_panel"},
    niunBgImg = {path="niun_panel.bg_img"},
    niunNiuImg = {path="niun_panel.niu_img"},
    niuniuPanel = {path="niuniu_panel"},
    niuniuBgImg = {path="niuniu_panel.bg_img"},
    niuniuNiuImg = {path="niuniu_panel.niu_img"},
}

C.pokerClassArr = nil
C.pokerPosArr = nil
C.pokerScale = 1
C.openPokerPosArr = nil
C.openPokerScale = 1
C.isGaming = false
C.playerInfo = nil
C.pokerDataArr = nil
C.pokerType = -1
C.pokerNiun = -1
C.hadTurnPoker = false
C.calculateCallback = nil
C.selectedPokerIndexs = nil

function C:ctor( node )
    for i=1,5 do
        local key = string.format("poker%d",i)
        local path = string.format("poker_%d",i)
        self.BINDING[key] = {path=path}
    end
    C.super.ctor(self,node)
end

function C:onCreate()
    self.pokerClassArr = {}
    self.pokerPosArr = {}
    self.openPokerPosArr = {}
    for i=1,5 do
        local key = string.format("poker%d",i)
        local pokerNode = self[key]
        local pokerClass = PokerClass.new(pokerNode)
        self.pokerClassArr[i] = pokerClass
        self.pokerPosArr[i] = cc.p(pokerNode:getPosition())
        self.openPokerPosArr[i] = cc.p(pokerNode:getPosition())
    end
    if self.node:getTag() == 1 then
        self.pokerScale = 1
        self.openPokerScale = 0.65
        self.openPokerPosArr = { cc.p(443,200),cc.p(488,200),cc.p(533,200),cc.p(578,200),cc.p(623,200) }
    else
        self.pokerScale = 0.44
        self.openPokerScale = 0.44
    end
    self.zhuangImg:setLocalZOrder(3)
    self:clean()
end

function C:clean()
    self:hidePoker()
    self:hideType()
    self:hideZhuang()
    self:hideTips()
    self.pokerDataArr = nil
    self.pokerType = -1
    self.pokerNiun = -1
    self.hadTurnPoker = false
    self.selectedPokerIndexs = nil
end

function C:setVisible( flags )
    self.node:setVisible(flags)
    if flags == false then
        self:clean()
        self.isGaming = false
        self.playerInfo = nil
    end
end

function C:isVisible()
    return self.node:isVisible()
end

function C:setCalculateCallback( callback )
    self.calculateCallback = callback
    for i=1,5 do
        local poker = self.pokerClassArr[i]
        poker.node:onClick(function()
            self:onClickPoker(i)
        end)
    end
end

function C:onClickPoker( index )
    --播放点击牌音效
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."card_select.mp3")
    if self.pokerDataArr == nil or self.niunPanel:isVisible() or self.niuniuPanel:isVisible() then
        return
    end
    if self.selectedPokerIndexs == nil then
        self.selectedPokerIndexs = {}
    end
    local pos = -1
    for i,v in ipairs(self.selectedPokerIndexs) do
        if v == index then
            pos = i
            break
        end
    end
    if pos == -1 then
        if #self.selectedPokerIndexs >= 3 then
            return
        end
        table.insert(self.selectedPokerIndexs,index)
    else
        table.remove(self.selectedPokerIndexs,pos)
    end
    table.sort( self.selectedPokerIndexs )
    for i=1,5 do
        local poker = self.pokerClassArr[i]
        local p = self.pokerPosArr[i]
        poker.node:setPosition(p)
    end
    local nums = {0,0,0}
    for i,v in ipairs(self.selectedPokerIndexs) do
        local poker = self.pokerClassArr[v]
        local p = self.pokerPosArr[v]
        local x = p.x
        local y = p.y + 20
        poker.node:setPosition(cc.p(x,y))
        local num = self.pokerDataArr[v]["number"]
        if num > 10 then
            num = 10
        end
        nums[i] = num
    end
    if self.calculateCallback then
        self.calculateCallback(nums[1],nums[2],nums[3])
    end
end

function C:show( playerInfo )
    if playerInfo == nil then
        return
    end
    self.playerInfo = playerInfo
    self:setVisible(true)
    --头像
    local headid = self.playerInfo["headid"]
    local headRes = GET_HEADID_RES( headid )
    --头像框
    --local frameId = self.playerInfo.cbVip2
    --self.frameImg:loadTexture(GET_FRAMEID_RES(frameId))

    --ID
    local nickname = tostring(self.playerInfo["playerid"])
    self.accountLabel:setString(nickname)
    --位置
    local city = self.playerInfo["nickname"] or "未知"
    city = string.gsub(city,"省","")
    city = string.gsub(city,"市","")
    if self.locationLabel then
        self.locationLabel:setString(city)
    end
    --余额
    local blance = self.playerInfo["money"]
    self:setBlance(blance)
end

function C:showWaitting( flags )
    if flags then
        self.headPanel:setColor(cc.c3b(100, 100, 100))
    else
        self.headPanel:setColor(cc.c3b(255, 255, 255))
    end
end

function C:setBlance( blance )
    if self.playerInfo then
        self.playerInfo["money"] = blance
    end
    local coinStr = utils:moneyString(blance)
    self.blanceLabel:setString(coinStr)
end

function C:showQiangTips( beishu, animation )
    if self.tipsImg:isVisible() then
        return
    end
    self.tipsImg:setVisible(true)
    local resname = GAME_QZNN_IMAGES_RES.."grab_multi_"..beishu..".png"
    self.tipsImg:setTexture(resname)
    if animation then
        local endPos = cc.p(self.tipsImg:getPosition())
        local beginPos = cc.p(50,endPos.y)
        if self.node:getTag() == 1 then
            beginPos = cc.p(50,50)
        end
        self.tipsImg:setPosition(beginPos)
        self.tipsImg:setScale(0)
        self.tipsImg:runAction( cc.MoveTo:create(0.3,endPos))
        --self.tipsImg:runAction( cc.ScaleTo:create(0.3,0.7))
        self.tipsImg:runAction( cc.ScaleTo:create(0.3,1.0))
    end
end

function C:showBetTips( beishu, animation )
    if self.tipsImg:isVisible() then
        return
    end
    self.tipsImg:setVisible(true)
    local resname = GAME_QZNN_IMAGES_RES.."tag_"..beishu..".png"
    self.tipsImg:setTexture(resname)
    if animation then
        local endPos = cc.p(self.tipsImg:getPosition())
        local beginPos = cc.p(50,endPos.y)
        if self.node:getTag() == 1 then
            beginPos = cc.p(50,50)
        end
        self.tipsImg:setPosition(beginPos)
        self.tipsImg:setScale(0)
        self.tipsImg:runAction( cc.MoveTo:create(0.3,endPos))
        --self.tipsImg:runAction( cc.ScaleTo:create(0.3,0.7))
        self.tipsImg:runAction( cc.ScaleTo:create(0.3,1.0))
    end
end

function C:showBankerTips( beishu )
    self.tipsImg:setVisible(true)
    local resname = GAME_QZNN_IMAGES_RES.."grab_multi_"..beishu..".png"
    self.tipsImg:setTexture(resname)
end

function C:hideTips()
    self.tipsImg:setVisible(false)
end

function C:playBlinksAni( callback )
    --播放定庄音效
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."banker.mp3")
    self:showZhuang(true)
    --1
    local light1 = display.newSprite(GAME_QZNN_IMAGES_RES.."box_light1.png")
    light1:setPosition(cc.p(50,50))
    light1:setVisible(false)
    light1:setLocalZOrder(2)
    self.headPanel:addChild(light1)
    local repeatArr1 = {}
    repeatArr1[1] =  CCDelayTime:create(0.2)
    repeatArr1[2] =  CCHide:create()
    repeatArr1[3] =  CCDelayTime:create(0.2)
    repeatArr1[4] =  CCShow:create()
    local array1 = {}
    array1[1] = CCRepeat:create(cc.Sequence:create(repeatArr1),5)
    array1[2] = CCCallFunc:create(function()
        light1:removeFromParent(true)
    end)
    light1:runAction(cc.Sequence:create(array1))
    --2
    local light2 = display.newSprite(GAME_QZNN_IMAGES_RES.."box_light2.png")
    light2:setPosition(cc.p(50,50))
    light2:setLocalZOrder(2)
    light2:setVisible(false)
    self.headPanel:addChild(light2)
    local repeatArr2 = {}
    repeatArr2[1] =  CCDelayTime:create(0.2)
    repeatArr2[2] =  CCShow:create()
    repeatArr2[3] =  CCDelayTime:create(0.2)
    repeatArr2[4] =  CCHide:create()
    local array2 = {}
    array2[1] = CCRepeat:create(cc.Sequence:create(repeatArr2),5)
    array2[2] = CCCallFunc:create(function()
        light2:removeFromParent(true)
        if callback then
            callback()
        end
    end)
    light2:runAction(cc.Sequence:create(array2))
end

function C:showZhuang( animation )
    self.zhuangImg:setScale(1)
    self.zhuangImg:setVisible(true)
    if animation == true then
        self.zhuangImg:setScale(3)
        self.zhuangImg:setOpacity(0)
        local array = {}
        array[1] = cc.EaseIn:create(cc.Spawn:create({ cc.ScaleTo:create(0.5, 1, 1), cc.FadeIn:create(0.5) }), 0.5)
        self.zhuangImg:runAction( cc.Sequence:create(array) )
    end
end

function C:hideZhuang()
    self.zhuangImg:setVisible(false)
end

function C:sendPokerAni( delay, callback )
    local tag = self.node:getTag()
    local sendAni = function()
        --播放发牌音效
        PLAY_SOUND(GAME_QZNN_SOUND_RES.."sendcard.mp3")
        local beginPos = self.node:convertToNodeSpace( cc.p(display.cx,display.cy-30) )
        local endPos1 = self.pokerPosArr[1]
        local isSelf = self.node:getTag() == 1
        for i=1,5 do
            local pokerClass = self.pokerClassArr[i]
            pokerClass:setVisible(true)
            pokerClass.frontground:setVisible(false)
            pokerClass.node:setScale(0.44)
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
            array[3] = cc.DelayTime:create(0.02*(5-i))
            array[4] = cc.MoveTo:create(moveTime,endPos2)
            array[5] = cc.CallFunc:create(function()
                if i == 5 and callback then
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
        spawn = cc.Spawn:create({cc.ScaleTo:create(time,1),easeIn})
    else
        spawn = cc.Spawn:create({easeIn})
    end
    return spawn
end

function C:sendPoker()
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass.node:setScale( self.pokerScale )
        pokerClass.node:setPosition( self.pokerPosArr[i] )
        pokerClass.node:setVisible(true)
    end
end

function C:setPokerData( dataArr, ctype, niun )
    self.pokerDataArr = utils:copyTable(dataArr)
    self.pokerType = ctype
    self.pokerNiun = niun
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        local data = self.pokerDataArr[i]
        local pcolor = data["color"]
        local pvalue = data["number"]
	if self.cardtype==1 then
		--整张牌
                pokerClass:createOverAllCard(pcolor, pvalue)
 	elseif self.cardtype==2 then
		--散件牌
        	pokerClass:setPokerData( pcolor, pvalue )
	end
    end
end

function C:turnPoker()
    if self.hadTurnPoker then
        return
    end
    self.hadTurnPoker = true
    local animated = self.node:getTag()==1
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:frontgroundPoker(animated)
    end
end

function C:openPoker()
    if self.node:getTag() ~= 1 then
        self:turnPoker()
    end
    if self.node:getTag() == 1 then
        for i=1,5 do
            local pokerClass = self.pokerClassArr[i]
            pokerClass.node:setScale( self.openPokerScale )
            pokerClass.node:setPosition( self.openPokerPosArr[i] )
            pokerClass.node:setVisible(true)
        end
    end
    self:showType( self.pokerType, self.pokerNiun )
end

function C:hidePoker()
    local animated = self.node:getTag()==1
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:backgroundPoker(animated)
        pokerClass:setVisible(false)
    end
end

function C:showType( ntype,num )
    if ntype == -1 or num == -1 or self.niunPanel:isVisible() or self.niuniuPanel:isVisible() then
        return
    end
    --播放摊牌音效
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."show.mp3")
    local isNiuniu = false
    local niuName = ""
    local niuSp = nil
    --无牛
    if ntype == 0 then
        self.niunPanel:setVisible(true)
        self.niunBgImg:setTexture(GAME_QZNN_IMAGES_RES.."cow_bg_black.png")
        self.niunNiuImg:setTexture(GAME_QZNN_IMAGES_RES.."type/cow_0.png")

    --牛1-9
    elseif ntype == 1 or ntype == 2 then
        self.niunPanel:setVisible(true)
        self.niunBgImg:setTexture(GAME_QZNN_IMAGES_RES.."cow_bg_yellow.png")
        self.niunNiuImg:setTexture(GAME_QZNN_IMAGES_RES.."type/cow_"..num..".png")
        niuSp = self.niunNiuImg

    --牛牛
    elseif ntype == 3 then
        isNiuniu = true
        niuName = GAME_QZNN_IMAGES_RES.."type/cow_10.png"

    --5花牛
    elseif ntype == 4 then
        isNiuniu = true
        niuName = GAME_QZNN_IMAGES_RES.."type/cow_12.png"

    --炸弹牛
    elseif ntype == 5 then
        isNiuniu = true
        niuName = GAME_QZNN_IMAGES_RES.."type/cow_11.png"

    --五小牛
    elseif ntype == em_BZNN_HandPX_FiveCalf then
        isNiuniu = true
        niuName = GAME_QZNN_IMAGES_RES.."type/cow_13.png"
    end

    if isNiuniu then
        self.niuniuPanel:setVisible(true)
        --按照美术要求不要牛牛特效
        --local array = {}
        --local bg = self.niuniuBgImg
        --local x = bg:getContentSize().width/2
        --local y = bg:getContentSize().height/2
        --local lineSp = display.newSprite("#red_line1.png")
        --lineSp:setPosition(cc.p(x,y))
        --lineSp:setScaleX(0.18)
        --lineSp:setScaleY(0.7)
        --self.niuniuBgImg:addChild(lineSp)
        --for i=1,10 do
        --    local resPng = "red_line"..i..".png"
        --    local tmpsf = cc.SpriteFrameCache:getInstance():getSpriteFrame( resPng )
        --    array[i] = tmpsf
        --end
        --local aniSpeed = 0.1
        --local animation = CCAnimation:createWithSpriteFrames( array, aniSpeed )
        --local animate = CCAnimate:create( animation )
        --local arr = {}
        --arr[1] = CCRepeat:create( animate, 100)
        --lineSp:runAction(cc.Sequence:create(arr))
        self.niuniuNiuImg:setTexture(niuName)
        niuSp = self.niuniuNiuImg
    end

    if niuSp then
        niuSp:setScale(3.5)
        niuSp:setOpacity(0)
        local particle = cc.ParticleSystemQuad:create(GAME_QZNN_ANIMATION_RES.."particle/star01.plist")
        particle:setAutoRemoveOnFinish(true)
        local x = niuSp:getContentSize().width/2
        local y = niuSp:getContentSize().height/2
        particle:setPosition(cc.p(x,y))
        niuSp:addChild(particle)
        particle:setScale(0.5)

        local fadeIn = cc.FadeIn:create(0.2)
        local scale = cc.ScaleTo:create(0.2, 1)
        -- local callfun = cc.CallFunc:create(function()
        --     local particle = cc.ParticleSystemQuad:create(GAME_QZNN_ANIMATION_RES.."particle/star01.plist")
        --     particle:setAutoRemoveOnFinish(true)
        --     local x = niuSp:getContentSize().width/2
        --     local y = niuSp:getContentSize().height/2
        --     particle:setPosition(cc.p(x,y))
        --     niuSp:addChild(particle)
        --     particle:setScale(0.5)
        -- end)
        local x = 1
        niuSp:runAction(cc.Spawn:create({fadeIn,scale}))
    end
    --播放牌型音效
    self:playTypeSound( ntype, num)
end

function C:playTypeSound( ntype, num )
    local name = ""
    if ntype == 0 then
        name = "niu_0.mp3"
    elseif ntype == 1 or ntype == 2 then
        name = "niu_"..num..".mp3"
    elseif ntype == 3 then
        name = "niu_10.mp3"
    elseif ntype == 4 then
        name = "niu_12.mp3"
    elseif ntype == 5 then
        name = "niu_11.mp3"
    end

    if name == "" then
        return
    end
    PLAY_SOUND(GAME_QZNN_SOUND_RES..name)
end

function C:hideType()
    self.niunPanel:setVisible(false)
    self.niuniuPanel:setVisible(false)
    self.niuniuBgImg:removeAllChildren(true)
end

return C