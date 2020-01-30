local PokerClass = import(".BRQznnPokerClass")
local Model = import(".BRQznnModel")
local C = class("BRQznnPlayerClass",ViewBaseClass)

C.BINDING = {
    headPanel = {path="head_panel"},
    infoImg={path="head_panel.info_img"},
    headImg = {path="head_panel.head_img"},
    frameImg = {path="head_panel.frame_img"},
    blanceLabel = {path="head_panel.label"},
    accountLabel = {path="head_panel.account_label"},
    zhuangImg = {path="head_panel.zhuang_img"},
    zhuangTipImg = {path="head_panel.zhuangtips_img"},
    zhuangchooseImg = {path="head_panel.zhuangchoose_img"},
    tipsImg = {path="head_panel.tips_img"},
    niuniuPanel = {path="niun_panel"},
    niuniuNiuImg = {path="niun_panel.niu_img"},
    betImg={path="head_panel.bet_img"},
    betLabel={path="head_panel.bet_img.label"},
    flyGold={path="head_panel.bet_gold"},
    ready_bg={path="head_panel.ready_bg"},
    ready={path="head_panel.ready_bg.ready"},
    winImg={path="win_img"},
    winLabel={path="win_img.label"},
    loseImg={path="lose_img"},
    loseLabel={path="lose_img.label"},
}

C.pokerClassArr = nil
C.pokerPosArr = nil
C.pokerScale = 1
C.openPokerPosArr = nil
C.openPokerNiuPosArr = nil
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
    self.openPokerPosArr={}
    self.openPokerNiuPosArr={}
    for i=1,5 do
        local key = string.format("poker%d",i)
        local pokerNode = self[key]
        local pokerClass = PokerClass.new(pokerNode)
        self.pokerClassArr[i] = pokerClass
        self.pokerPosArr[i] = cc.p(pokerNode:getPosition())
        self.openPokerPosArr[i] = cc.p(pokerNode:getPosition())
    end
    if self.node:getTag() == 1 then
        self.pokerScale = 0.55
        self.openPokerScale = 0.55
        self.openPokerPosArr = { cc.p(488,50),cc.p(528,50),cc.p(568,50),cc.p(608,50),cc.p(648,50) }
        for i = 1, 5 do
            local x = self.openPokerPosArr[i].x
            local y = self.openPokerPosArr[i].y
            if i>3 then
                x=x+15
            end
            self.openPokerNiuPosArr[i]=cc.p(x,y)
        end
    elseif self.node:getTag()<=4 then
        for i = 1, 5 do
            local x = self.openPokerPosArr[i].x
            local y = self.openPokerPosArr[i].y
            if i<=3 then
                x=x-15
            end
            self.openPokerNiuPosArr[i]=cc.p(x,y)
        end
    else
        for i = 1, 5 do
            local x = self.openPokerPosArr[i].x
            local y = self.openPokerPosArr[i].y
            if i>3 then
                x=x+15
            end
            self.openPokerNiuPosArr[i]=cc.p(x,y)
        end
    end
    self.zhuangImg:setLocalZOrder(3)
    self.niuniuPanel:setLocalZOrder(10)
    self.niuniuNiuImg:setLocalZOrder(5)
    self.headPanel:setLocalZOrder(100)
    self.zhuangchooseImg:setGlobalZOrder(1000)
    self.winImg:setLocalZOrder(200)
    self.loseImg:setLocalZOrder(200)

    local scale = 1
    local str = "ying_da"
    if self.node:getTag() ~= 1 then
        scale=0.8
        str = "ying_xiao"
    end
    local strAnimName = GAME_BRQZNN_ANIMATION_RES.. "spine/zhuang"
    self.skeletonNode1= sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.headPanel:addChild( self.skeletonNode1 )
    self.skeletonNode1:setPosition(cc.p(self.infoImg:getPosition()))
    self.skeletonNode1:setScale(scale)

    local strAnimName = GAME_BRQZNN_ANIMATION_RES.. "spine/zhuangjia"
    self.skeletonNode2 = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.headPanel:addChild( self.skeletonNode2 )
    self.skeletonNode2:setPosition(cc.p(self.zhuangImg:getPosition()))
    self.skeletonNode2:setScale(scale*0.7)

    local strAnimName = GAME_BRQZNN_ANIMATION_RES.. "spine/youniou"
    self.skeletonType = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.niuniuPanel:addChild( self.skeletonType,10)
    self.skeletonType:setPosition(cc.p(self.niuniuNiuImg:getPosition()))
    self.skeletonType:setScale(scale)

    local strAnimName = GAME_BRQZNN_ANIMATION_RES.. "spine/"..str
    self.skeletonWin = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.headPanel:addChild( self.skeletonWin,150)
    self.skeletonWin:setPosition(cc.p(self.infoImg:getPositionX(),self.infoImg:getPositionY()))
    self.winLabel:setLocalZOrder(10)

    local strAnimName = GAME_BRQZNN_ANIMATION_RES.. "spine/cuo"
    self.skeletonCuo = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.headPanel:addChild( self.skeletonCuo )
    self.skeletonCuo:setPosition(cc.p(self.headImg:getPosition()))
    self.skeletonCuo:setScale(scale)

    self.winImg:setScale(0.8)
    self.loseImg:setScale(0.8)

    self:clean()
end

function C:clean()
    self:hidePoker()
    self:hideType()
    self:hideZhuang()
    self:hideTips()
    self:hideBetTip()
    self:hideBankerTips()
    self:showReady(false)
    self:hideResult()
    self.zhuangchooseImg:setVisible(false)
    self.skeletonNode1:setVisible(false)
    self.skeletonNode2:setVisible(false)
    self.skeletonType:setVisible(false)
    self.skeletonWin:setVisible(false)
    self.skeletonCuo:setVisible(false)
    self.zhuangImg:setVisible(false)
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
    self.headImg:loadTexture(headRes)
    --ID
    local nickname = tostring(self.playerInfo["playerid"])
    self.accountLabel:setString(nickname)
    --位置
    local city = self.playerInfo["nickname"] or "未知"
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

--显示抢庄提示
function C:showQiangTips( beishu,ani )
    printInfo(">>>>>>>>>>>>显示抢庄提示>>>>>>>>>>>"..beishu)
    if ani then
        self.tipsImg:setVisible(true)
        local resname = Model.imagePath.."qiang"..beishu..".png"
        self.tipsImg:setTexture(resname)
        if beishu==0 then
            PLAY_SOUND(Model.soundPath.."buqiang_0.mp3")
        else
            PLAY_SOUND(Model.soundPath.."qiangzhuang_0.mp3")
        end
    else
        self:showBankerTips(beishu)
    end
end
--隐藏抢庄提示
function C:hideTips()
    self.tipsImg:setVisible(false)
end
--显示庄家倍数
function C:showBankerTips( beishu )
    self:hideTips()
    self.zhuangTipImg:setVisible(true)
    local resname = Model.imagePath.."beishu_"..beishu..".png"
    printInfo(">>>>>>>>>显示庄家倍数>>>>>>"..resname)
    self.zhuangTipImg:setTexture(resname)
end
--隐藏庄家倍数
function C:hideBankerTips()
    self.zhuangTipImg:setVisible(false)
end

--显示下注提示
function C:showBetTips( beishu, animation )
    printInfo(">>>>>>>>>>>>显示下注提示>>>>>>>>>>>"..beishu)
    self:hideTips()
    self.betLabel:setString(beishu)
    if animation then
        PLAY_SOUND(Model.soundPath.."coin_big.mp3")
        local endPos = cc.p(self.flyGold:getPosition())
        local beginPos = cc.p(self.headImg:getPosition())

        local count,num = self:getGoldCount(beishu)
        for i = 1, count do       
            local gold = self.flyGold:clone()
            gold:setVisible(true)
            gold:setPosition(beginPos)
            self.headPanel:addChild(gold)
            local array = {}
            array[1]=cc.DelayTime:create(i*0.027)
            array[2]=cc.MoveTo:create(0.4,endPos)
            array[3]=cc.CallFunc:create(function()
                gold:removeFromParent()
                if i==num then
                    self.betImg:setVisible(true)
                    self.flyGold:setVisible(true)
                end
            end)
            gold:runAction(cc.Sequence:create(array) )
        end
    else
        self.betImg:setVisible(true)
        self.flyGold:setVisible(true)
    end
end

--隐藏下注提示
function C:hideBetTip()
    self.betImg:setVisible(false)
    self.flyGold:setVisible(false)
end

--获取飞金币个数
function C:getGoldCount(beishu)
    local index = 0
    for i = 1, #Model.betConfig do
        if beishu==Model.betConfig[i] then
            index=i
            break
        end
    end
    local count = 0
    local num = 0
    if index==1 then
        count=1
        num=1
    elseif index==2 then
        count=2
        num=2
    elseif index==3 then
        count=4
        num=2
    elseif index==4 then
        count=8
        num=4
    end
    return count,num
end

--选庄动画
function C:playChoiceZhuangAni()
    self.zhuangchooseImg:stopAllActions()
    local array = {}
    array[1] =  CCDelayTime:create(1/60*3)
    array[2]=CCCallFunc:create(function()
        self.zhuangchooseImg:setVisible(true)
    end)
    array[3] =  CCDelayTime:create(1/60*3)
    array[4]=CCCallFunc:create(function()
        self.zhuangchooseImg:setVisible(false)
    end)
    self.zhuangchooseImg:runAction(cc.Sequence:create(array))
end

function C:getBlinkPos()
    return self.infoImg:getPosition()
end

--定庄动画
function C:playBlinksAni( callback )
    --播放定庄音效
    PLAY_SOUND(Model.soundPath.."banker.mp3")
    --self:showZhuang(true)
    local path = ""
    if self.node:getTag() == 1 then
        path="qjk_da.png"
    else
        path="qjk_xiao.png"
    end
    printInfo(">>>>>>>>>>定庄动画>>>>>>>>>1>>>")

    self.skeletonNode1:setVisible(true)
    self.skeletonNode1:setAnimation(0,"animation",false)

    local array = {}
    array[1] =  CCDelayTime:create(0.3)
    array[2]=CCCallFunc:create(function()
        self.skeletonNode2:setVisible(true)
        self.skeletonNode2:setAnimation(0,"animation",false)
        self.skeletonNode2:setTimeScale(1.2)
    end)
    array[3]=CCDelayTime:create(1)
    array[4]=CCCallFunc:create(function()
        if callback then
            callback()
        end
    end)
    self.headPanel:runAction(cc.Sequence:create(array))
end

function C:showZhuang( animation )
    local scale = 1
    if self.node:getTag()~=1 then
        scale=0.7
    end
    self.zhuangImg:setScale(scale)
    self.zhuangImg:setVisible(true)
    if animation == true then
        self.zhuangImg:setScale(3*scale)
        self.zhuangImg:runAction( cc.ScaleTo:create(0.3, scale, scale) )
    end
end

function C:hideZhuang()
    self.zhuangImg:setVisible(false)
end

--先发四张牌
function C:sendFourPokerAni( delay, callback )
    local sendAni = function()
        --PLAY_SOUND(Model.soundPath.."sendcard.mp3")
        local beginPos = self.node:convertToNodeSpace( cc.p(display.cx,display.cy) )
        local moveTime = 1/60*12
        for i = 1, 4 do
            local pokerClass = self.pokerClassArr[i]       
            pokerClass.node:setPosition(beginPos)
            local endPos = self.pokerPosArr[i]
            local arr = {}
            arr[1]=cc.DelayTime:create((i-1)*1/60*4)
            arr[2]=cc.CallFunc:create(function()
                pokerClass:setVisible(true)
            end)
            arr[3]=cc.MoveTo:create(moveTime,endPos)
            arr[4]=cc.CallFunc:create(function()
                if i==4 then
                    if callback then
                        callback()
                    end
                end
            end)
            pokerClass.node:runAction(cc.Sequence:create(arr))
        end
    end
    local array = {}
    array[1] = cc.DelayTime:create(delay)
    array[2] = cc.CallFunc:create(function()
        sendAni()
    end)
    self.node:runAction(cc.Sequence:create(array))
end

--发最后一张牌
function C:sendLastPoker(delay,callback)
    local sendAni = function()
        --PLAY_SOUND(Model.soundPath.."sendcard.mp3")
        local beginPos = self.node:convertToNodeSpace( cc.p(display.cx,display.cy) )
        local moveTime = 1/60*10
        local pokerClass = self.pokerClassArr[5]
        pokerClass:setVisible(true)
        pokerClass.node:setPosition(beginPos)
        local endPos = self.pokerPosArr[5]
        local arr = {}
        arr[1]=cc.MoveTo:create(moveTime,endPos)
        arr[2]=cc.CallFunc:create(function()
            if callback then
                callback()
            end
        end)
        pokerClass.node:runAction(cc.Sequence:create(arr))
    end
    local array = {}
    array[1] = cc.DelayTime:create(delay)
    array[2] = cc.CallFunc:create(function()
        sendAni()
    end)
    self.node:runAction(cc.Sequence:create(array))
end

--直接显示4张牌或者5张牌
function C:sendFourPoker(count)
    for i=1,count do
        local pokerClass = self.pokerClassArr[i]
        --pokerClass.node:setScale( self.pokerScale )
        pokerClass.node:setPosition( self.pokerPosArr[i] )
        pokerClass.node:setVisible(true)
    end
end

--设置牌信息
function C:setPokerData( dataArr, ctype, niun )
    if self.pokerDataArr then
        --要排序,前面四张已经给了，只取最后一张即可
        for i = 1, #dataArr do
            local pcolor1 = dataArr[i]["color"]
            local pvalue1 = dataArr[i]["number"]
            local exist = false
            for k = 1, #self.pokerDataArr do
                local pcolor2 = self.pokerDataArr[k]["color"]
                local pvalue2 = self.pokerDataArr[k]["number"]
                if pcolor1==pcolor2 and pvalue1==pvalue2 then
                    self.pokerDataArr[k]["up"]=dataArr[i]["up"]
                    exist=true
                end
            end
            if not exist then
                local info = utils:copyTable(dataArr[i])
                table.insert(self.pokerDataArr,info)
            end
        end
    else
        self.pokerDataArr = utils:copyTable(dataArr)
    end
    if ctype~=nil then
        self.pokerType = ctype
    end
    if niun~=nil then
        self.pokerNiun = niun
    end
    for i=1,#self.pokerDataArr do
        local pokerClass = self.pokerClassArr[i]
        local data = self.pokerDataArr[i]
        local pcolor = data["color"]
        local pvalue = data["number"]
        local up = data["up"]
        pokerClass:setPokerData( pcolor, pvalue, up )
    end
end

--设置牌信息,最后一张
function C:setLastPokerData(dataArr, ctype, niun)
    self.pokerDataArr = utils:copyTable(dataArr)
    self.pokerType = ctype
    self.pokerNiun = niun
    local pokerClass = self.pokerClassArr[5]
    local data = self.pokerDataArr[1]
    local pcolor = data["color"]
    local pvalue = data["number"]
    local up = data["up"]
    pokerClass:setPokerData( pcolor, pvalue,up )
end

--先翻四张牌
function C:turnFourPoker()
    for i=1,4 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:frontgroundPoker(true)
    end
end

--翻最后一张牌
function C:turnLastPoker()
    local pokerClass = self.pokerClassArr[5]
    pokerClass:frontgroundPoker(true)
    -- if self.node:getTag()==1 then
    --     local array = {}
    --     array[1] = cc.DelayTime:create(0.2)
    --     array[2] = cc.CallFunc:create(function()
    --         --self:showType( self.pokerType, self.pokerNiun )
    --     end)
    --     self.node:runAction(cc.Sequence:create(array))
    -- end
end

--翻牌
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

--显示搓牌中
function C:showCuoPaiTip()
    self.skeletonCuo:setVisible(true)
    self.skeletonCuo:setAnimation(0,"animation",true)
    if self.node:getTag() == 1 then
        for i=1,5 do
            local pokerClass = self.pokerClassArr[i]
            local x,y = self.pokerPosArr[i].x,self.pokerPosArr[i].y
            pokerClass.node:setPosition(cc.p(x,y-150))
        end
    end
end

--显示搓牌完成
function C:showPlayerCuoPaiFinish()
    self.skeletonCuo:setVisible(false)
    self.skeletonCuo:setAnimation(0,"animation",false)
    if self.node:getTag() == 1 then
        local pokerClass = self.pokerClassArr[5]
        pokerClass:frontgroundPoker(false)
        for i=1,5 do
            local pokerClass = self.pokerClassArr[i]
            pokerClass.node:runAction(cc.MoveTo:create(0.5,self.pokerPosArr[i]))
        end
    end
end

--显示准备中
function C:showReady(flag,ani)
    self.ready_bg:setVisible(flag)
    self.ready:setScale(1)
    if flag and ani then
        self.ready:setScale(3)
        self.ready:setOpacity(0)
        local array = {}
        array[1] = cc.EaseIn:create(cc.Spawn:create({ cc.ScaleTo:create(0.5, 1, 1), cc.FadeIn:create(0.1) }), 0.5)
        self.ready:runAction( cc.Sequence:create(array) )
    end
end

--亮牌
function C:openPoker()
    printInfo(">>>>>>>>>亮牌>>>>>>>>>>>"..self.node:getTag())
    self.skeletonCuo:setVisible(false)
    self.skeletonCuo:setAnimation(0,"animation",false)
    if self.node:getTag() == 1 then
        local pokerClass = self.pokerClassArr[5]
        pokerClass:frontgroundPoker(false)
    end
    local pos = nil
    if self.pokerType==0 then
        pos=self.openPokerPosArr
    else
        pos=self.openPokerNiuPosArr
    end
    local temp1 = {}
    local temp2 = {}
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        if pokerClass.up==1 then
            table.insert(temp1,pokerClass)
        else
            table.insert(temp2,pokerClass)
        end
    end
    for i = 1, #temp1 do
        if self.node:getTag() ~= 1 then
            temp1[i]:frontgroundPoker(false)
        end
        temp1[i].node:setPosition(pos[i])
        temp1[i].node:setVisible(true)
        temp1[i].node:setLocalZOrder(i)
    end
    for i = 1, #temp2 do
        if self.node:getTag() ~= 1 then
            temp2[i]:frontgroundPoker(false)
        end
        temp2[i].node:setPosition(pos[#temp1+i])
        temp2[i].node:setVisible(true)
        temp2[i].node:setLocalZOrder(#temp1+i)
    end
    
    self:showType( self.pokerType, self.pokerNiun )
end

function C:hidePoker()
    --local animated = self.node:getTag()==1
    for i=1,5 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:backgroundPoker(false)
        pokerClass:setVisible(false)
        pokerClass.node:setLocalZOrder(i)
    end
end

function C:showType( ntype,num )
    if ntype == -1 or num == -1 then
        return
    end
    --播放摊牌音效
    PLAY_SOUND(Model.soundPath.."show.mp3")
    local niuName = ""
    self.niuniuPanel:setVisible(true)
    --无牛
    if ntype == 0 then
        niuName = Model.imagePath.."type/niu_0.png"       
    --牛1-9
    elseif ntype == 1 or ntype == 2 then
        niuName = Model.imagePath.."type/niu_"..num..".png"
        self:showTypeEffect()
    --牛牛
    elseif ntype == 3 then
        niuName = Model.imagePath.."type/niu_10.png"
        self:showTypeEffect()
    --5花牛
    elseif ntype == 4 then
        niuName = Model.imagePath.."type/niu_12.png"
        self:showTypeEffect()
    --炸弹牛
    elseif ntype == 5 then
        niuName = Model.imagePath.."type/niu_15.png"
        self:showTypeEffect()
    end

    self.niuniuNiuImg:setTexture(niuName)
    self.niuniuNiuImg:setScale(0)
    local scale = 1
    if self.node:getTag() ~= 1 then
        scale=0.75
    end
    self.niuniuNiuImg:runAction(cc.ScaleTo:create(1/60*15,scale,scale))

    --播放牌型音效
    self:playTypeSound( ntype, num)
end

--显示牌型特效
function C:showTypeEffect()
    local array = {}
    array[1] = cc.DelayTime:create(1/60*10)
    array[2] = cc.CallFunc:create(function()
        self.skeletonType:setVisible(true)
        self.skeletonType:setAnimation(0,"animation",true)
    end)
    self.node:runAction(cc.Sequence:create(array))
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
    PLAY_SOUND(Model.soundPath..name)
end

--显示赢
function C:showWin(money)
    self.winImg:setVisible(true)
    self.loseImg:setVisible(false)
    self.winLabel:setString("+"..money)
    self.skeletonWin:setVisible(true)
    self.skeletonWin:setAnimation(0,"animation",true)
    if self.node:getTag() == 1 then
        PLAY_SOUND(Model.soundPath.."win.mp3")
    end
end
--显示输
function C:showLose(money)
    self.winImg:setVisible(false)
    self.loseImg:setVisible(true)
    self.loseLabel:setString(money)
    if self.node:getTag() == 1 then
        PLAY_SOUND(Model.soundPath.."lose.mp3")
    end
end

--隐藏输赢
function C:hideResult()
    self.winImg:setVisible(false)
    self.loseImg:setVisible(false)
end

function C:hideType()
    self.niuniuPanel:setVisible(false)
end

return C