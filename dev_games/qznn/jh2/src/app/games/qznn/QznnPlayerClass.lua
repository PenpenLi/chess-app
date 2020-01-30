local PokerClass = import(".QznnPokerClass")
local C = class("QznnPlayerClass",ViewBaseClass)

C.BINDING = {
    headPanel = {path="head_panel"},
    headImg = {path="head_panel.head_img"},
    frameImg = {path="head_panel.frame_img"},
    vipLabel = {path="head_panel.vip_img.label"},
    blanceLabel = {path="head_panel.gold_img.label"},
    accountLabel = {path="head_panel.account_label"},
    locationLabel = {path="head_panel.city_label"},
    zhuangNode = {path="head_panel.zhuang_node"},
    zhuangImg = {path="head_panel.zhuang_img"},
    zhuangchooseImg = {path="head_panel.zhuangchoose_img"},
    betLabel = {path="head_panel.bet_label"},
    typePanel = {path="type_panel"},
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
C.hadOpenPoker = false
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
        pokerClass.frontground:setPosition(cc.p(pokerNode:getContentSize().width/2,pokerNode:getContentSize().height/2))
        pokerClass.background:setPosition(cc.p(pokerNode:getContentSize().width/2,pokerNode:getContentSize().height/2))
        self.pokerClassArr[i] = pokerClass
        self.pokerPosArr[i] = cc.p(pokerNode:getPosition())
        self.openPokerPosArr[i] = cc.p(pokerNode:getPosition())
    end
    if self.node:getTag() == 1 then
        self.pokerScale = 1
        self.openPokerScale = 0.65
        self.openPokerPosArr = { cc.p(473,166),cc.p(503,166),cc.p(533,166),cc.p(563,166),cc.p(593,166) }
    else
        self.pokerScale = 0.65
        self.openPokerScale = 0.65
    end
    self.zhuangImg:setLocalZOrder(3)
    local strAnimName =""
    if self.node:getTag() == 1 then
        strAnimName= GAME_QZNN_ANIMATION_RES.."skeleton/dingzhuang/zhuang1"
    else
        strAnimName= GAME_QZNN_ANIMATION_RES.."skeleton/dingzhuang/zhuang2"
    end
    self.zhuangAni = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.zhuangAni:setPosition(cc.p(50,50))
    self.zhuangAni:setVisible(false)
    self.headPanel:addChild( self.zhuangAni )

    local strAnimName1 =GAME_QZNN_ANIMATION_RES.."skeleton/qiang/qiang"
    self.qiangAni = sp.SkeletonAnimation:create(strAnimName1 .. ".json", strAnimName1 .. ".atlas", 1)
    self.qiangAni:setPosition(cc.p(self.zhuangImg:getPosition()))
    self.qiangAni:setVisible(false)
    self.headPanel:addChild( self.qiangAni )

    self.betLabel:setScale(1)
    self.zhuangchooseImg:setGlobalZOrder(1000)
    self.typePanel:setLocalZOrder(20)
    self.headPanel:setLocalZOrder(30)
    self:clean()
end

function C:clean()
    self:hidePoker()
    self:hideType()
    self:hideZhuang()
    self:hideBetTips()
    self:hideBankerTips()
    self.pokerDataArr = nil
    self.pokerType = -1
    self.pokerNiun = -1
    self.hadTurnPoker = false
    self.hadOpenPoker = false
    self.selectedPokerIndexs = nil
    self.zhuangchooseImg:setVisible(false)
    self.zhuangAni:setVisible(false)
    self.zhuangImg:setVisible(false)
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
        poker.node:onTouch(function(event)
            if self.hadTurnPoker and event.name == "ended" then
                self:onClickPoker(i)
            end
        end)
    end
end

function C:onClickPoker( index )
    --播放点击牌音效
    if self.pokerDataArr == nil or self.typePanel:isVisible() then
        return
    end
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."audio_btn_click.mp3")
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
    dump(playerInfo,"show>>>playerInfo")
    self.playerInfo = playerInfo
    self:setVisible(true)
    --头像
    local headId = self.playerInfo["headid"]
    local headUrl = self.playerInfo["wxheadurl"]
    SET_HEAD_IMG(self.headImg,headId,headUrl)
    --头像框
    --local frameId = self.playerInfo.cbVip2
    --self.frameImg:loadTexture(GET_FRAMEID_RES(frameId))

    --ID
    local nickname = self.playerInfo["nickname"]
    if nickname == nil or nickname == "" then
        nickname = tostring(self.playerInfo["playerid"])
    end
    self.accountLabel:setString(utils:nameStandardString(tostring(nickname), 20, 142))
    --位置
    local city = self.playerInfo["city"] or "未知"
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
    if self.qiangAni:isVisible() then
        return
    end
    -- self.zhuangImg:setVisible(true)
    -- local resname = GAME_QZNN_IMAGES_RES.."grab_multi_"..beishu..".png"
    -- self.zhuangImg:setTexture(resname)
    printInfo(">>>>>>>>>>>>showQiangTips>>>>>>>>"..self.node:getTag())
    local aniName=""
    if beishu==0 then
        aniName="buqiang"
    else
        aniName="qiang_"..beishu
    end
    if not animation then
        aniName=aniName.."b"
    end
    self.qiangAni:setVisible(true)
    self.qiangAni:setTimeScale(1.2)
    self.qiangAni:setAnimation(0,aniName,false)
    if animation then
        if self.node:getTag()==1 then
            self.qiangAni:setPosition(cc.p(500,190))
        elseif self.node:getTag()==2 or self.node:getTag()==3 then
            self.qiangAni:setPosition(cc.p(-108,-16))
        elseif self.node:getTag()==4 or self.node:getTag()==5 then
            self.qiangAni:setPosition(cc.p(210,-16))
        end
    else
        if self.node:getTag()==1 then
            self.qiangAni:setPosition(cc.p(50,132))
        elseif self.node:getTag()==2 or self.node:getTag()==3 then
            self.qiangAni:setPosition(cc.p(-108,102))
        elseif self.node:getTag()==4 or self.node:getTag()==5 then
            self.qiangAni:setPosition(cc.p(210,102))
        end
    end
end

function C:showBetTips( beishu, animation )
    if self.betLabel:isVisible() then
        return
    end
    self.betLabel:setVisible(true)
    self.betLabel:setString("下注"..beishu.."倍")
end

function C:hideBetTips()
    self.betLabel:setVisible(false)
end

function C:showBankerTips( beishu )
    printInfo(">>>>>>>>>>>>showBankerTips>>>>>>>>"..self.node:getTag())
    local aniName=""
    if beishu==0 then
        aniName="buqiangb"
    else
        aniName="qiang_"..beishu.."b"
    end
    self.qiangAni:setVisible(true)
    self.qiangAni:setAnimation(0,aniName,false)
    if self.node:getTag()==1 then
        self.qiangAni:setPosition(cc.p(50,132))
    elseif self.node:getTag()==2 or self.node:getTag()==3 then
        self.qiangAni:setPosition(cc.p(-108,102))
    elseif self.node:getTag()==4 or self.node:getTag()==5 then
        self.qiangAni:setPosition(cc.p(210,102))
    end
end

function C:hideBankerTips()
    self.qiangAni:setVisible(false)
end

--选庄动画
function C:playChoiceZhuangAni()
    self.zhuangchooseImg:stopAllActions()
    local array = {}
    array[1] =  CCDelayTime:create(1/60*6)
    array[2]=CCCallFunc:create(function()
        --PLAY_SOUND(GAME_QZNN_SOUND_RES.."select.mp3")
        self.zhuangchooseImg:setVisible(true)
    end)
    array[3] =  CCDelayTime:create(1/60*6)
    array[4]=CCCallFunc:create(function()
        self.zhuangchooseImg:setVisible(false)
    end)
    self.zhuangchooseImg:runAction(cc.Sequence:create(array))
end

--播放定庄
function C:playBlinksAni( callback )
    --播放定庄音效
    PLAY_SOUND(GAME_QZNN_SOUND_RES.."boss.mp3")
    self:showZhuang(true)
    local array2 = {}
    array2[1] = CCDelayTime:create(0.1)
    array2[2] = CCCallFunc:create(function()
        if callback then
            callback()
        end
    end)
    self.headPanel:runAction(cc.Sequence:create(array2))
end

function C:showZhuang( animation )
    self.zhuangAni:setVisible(true)
    if animation then
        self.zhuangAni:setAnimation(0,"animation",false)
    else
        self.zhuangAni:setAnimation(0,"animation2",false)
    end
end

function C:hideZhuang()
    self.zhuangAni:setVisible(false)
end

function C:sendPokerAni( delay, callback )
    if self.pokerClassArr[1].node:isVisible() then
        if callback then
            callback()
        end
        return
    end
    local tag = self.node:getTag()
    local sendAni = function()
        --播放发牌音效
        --PLAY_SOUND(GAME_QZNN_SOUND_RES.."sendcard.mp3")
        local beginPos = self.node:convertToNodeSpace( cc.p(display.cx,display.cy-30) )
        for i=1,5 do
            local pokerClass = self.pokerClassArr[i]
            pokerClass:setVisible(true)
            pokerClass.frontground:setVisible(false)
            pokerClass.node:setPosition(beginPos)
            pokerClass.node:setOpacity(0)
            pokerClass.node:setScale( self.pokerScale )
            local endPos = self.pokerPosArr[i]
            local time = 0.16
            local interval = 0.04
            local moveAni = cc.MoveTo:create(time,endPos)
            local fadeAni = cc.FadeIn:create(time)
            local array = {}
            array[#array+1] = cc.DelayTime:create(interval * (i-1))
            array[#array+1] = transition.spawn({moveAni,fadeAni})
            if i==5 and callback then
                array[#array+1] = cc.CallFunc:create(callback)
            end
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

-- function C:sendPokerAni( delay, callback )
--     if self.pokerClassArr[1].node:isVisible() then
--         if callback then
--             callback()
--         end
--         return
--     end
--     local tag = self.node:getTag()
--     local sendAni = function()
--         --播放发牌音效
--         PLAY_SOUND(GAME_QZNN_SOUND_RES.."sendcard.mp3")
--         local beginPos = self.node:convertToNodeSpace( cc.p(display.cx,display.cy-30) )
--         local endPos1 = self.pokerPosArr[1]
--         local isSelf = self.node:getTag() == 1
--         for i=1,5 do    
--             local pokerClass = self.pokerClassArr[i]
--             pokerClass:setVisible(true)
--             pokerClass.frontground:setVisible(false)
--             pokerClass.node:setScale(0.65)
--             pokerClass.node:setPosition(beginPos)
--             local endPos2 = self.pokerPosArr[i]
--             local distanceX = math.abs(endPos2.x-endPos1.x)
--             local moveTime = distanceX/900
--             if isSelf then
--                 moveTime = distanceX/1600
--             end
--             local array = {}
--             array[1] = cc.DelayTime:create(0.034 * (i-1))
--             array[2] = self:createSendCardActionPart1( beginPos, endPos1, isSelf )
--             array[3] = cc.DelayTime:create(0.035*(5-i))
--             array[4] = cc.MoveTo:create(moveTime,endPos2)
--             array[5] = cc.CallFunc:create(function()
--                 if i == 5 and callback then
--                     callback()
--                 end
--             end)
--             pokerClass.node:stopAllActions()
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

    local speed = 1200
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
    --从大到小进行了牌型
    table.sort(dataArr,function(a,b)
        if a.number~=b.number then
            return a.number > b.number
        else
            return a.color > b.color
        end
    end)
    self.pokerDataArr = utils:copyTable(dataArr)
    self.pokerType = ctype
    self.pokerNiun = niun
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        local data = self.pokerDataArr[i]
        local pcolor = data["color"]
        local pvalue = data["number"]
        local up = data["up"]
	    pokerClass:setPokerData( pcolor, pvalue, up )
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
    self.hadOpenPoker=true
    if self.node:getTag() ~= 1 then
        self:turnPoker()
    end
    -- local pos=self.openPokerPosArr
    -- local temp1 = {}
    -- local temp2 = {}
    -- for i=1,5 do
    --     local pokerClass = self.pokerClassArr[i]
    --     pokerClass.node:setScale( self.openPokerScale )
    --     pokerClass.node:stopAllActions()
    --     if pokerClass.up==1 then
    --         table.insert(temp1,pokerClass)
    --     else
    --         table.insert(temp2,pokerClass)
    --     end
    -- end
    -- for i = 1, #temp1 do
    --     temp1[i].node:setPosition(pos[i])
    --     temp1[i].node:setVisible(true)
    --     temp1[i].node:setLocalZOrder(i)
    -- end
    -- for i = 1, #temp2 do
    --     temp2[i].node:setPosition(pos[#temp1+i])
    --     temp2[i].node:setVisible(true)
    --     temp2[i].node:setLocalZOrder(#temp1+i)
    -- end
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
        pokerClass.node:setLocalZOrder(i)
    end
end

function C:showType( ntype,num )
    if ntype == -1 or num == -1 or self.typePanel:isVisible() then
        return
    end
    --播放摊牌音效
    if self.node:getTag()==1 then
        PLAY_SOUND(GAME_QZNN_SOUND_RES.."show.mp3")
    end
    --TODO:播放牌型spine
    local strAnimName =GAME_QZNN_ANIMATION_RES.."skeleton/cardtype/paixing"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    local name=""
    if ntype == 0 then
        name = "pai_s1"
    elseif ntype == 1 or ntype == 2 then
        name = "pai_"..num
    elseif ntype == 3 then
        name = "pai_10"
    elseif ntype == 4 then
        name = "pai_12"
    elseif ntype == 5 then
        name = "pai_13"
    end
    skeletonNode:setAnimation(0,name,false)
    self.typePanel:addChild( skeletonNode,20 )
    self.typePanel:setVisible(true)

    --播放牌型音效
    self:playTypeSound( ntype, num)
end

function C:playTypeSound( ntype, num )
    local name = ""
    local sex=self.playerInfo.sex
    if sex<0 then
        sex=0
    elseif sex>1 then
        sex=1
    end
    if ntype == 0 then
        name = sex.."_niu_0.mp3"
    elseif ntype == 1 or ntype == 2 then
        name = sex.."_niu_"..num..".mp3"
    elseif ntype == 3 then
        name = sex.."_niu_10.mp3"
    elseif ntype == 4 then
        name = sex.."_niu_12.mp3"
    elseif ntype == 5 then
        name = sex.."_niu_11.mp3"
    end
    if name == "" then
        return
    end
    PLAY_SOUND(GAME_QZNN_SOUND_RES..name)
end

function C:hideType()
    self.typePanel:setVisible(false)
    self.typePanel:removeAllChildren(true)
end

return C