local PlayerClass = import(".DdzPlayerView")
local Card = import(".DdzPokerView")
local SettlementView = import(".DdzSettlementView")

local C = class("DdzScene", GameSceneBase)

local SELECTED_CARD_SOUND = GAME_DDZ_SOUND_RES.."s_selectcard.mp3"

local WAITING_CSB = GAME_DDZ_PREFAB_RES.."Waiting.csb"


-- 资源名
C.RESOURCE_FILENAME = "games/ddz/DdzScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
    --测试按钮
    testBtn1 = {path="TEST_BTN1",events={{event="click",method="onTest1"}}},
    testBtn2 = {path="TEST_BTN2",events={{event="click",method="onTest2"}}},
    topBg = {path="top.bg_img"},
	--返回按钮
	backBtn = {path="top.back_btn",events={{event="click",method="onBack"}}},
	--电池进度
	batteryNode = {path="top.battery_node"},
	----电池充电标识
	--batteryLighting = {path="top.battery_node.lighting_img"},
	--帮助按钮
	helpBtn = {path="top.help_btn",events={{event="click",method="onHelp"}}},
	--设置页面
	settingsBtn = {path="top.set_btn",events={{event="click",method="onSettings"}}},
    --托管按钮
	tuoguanBtn = {path="top.tuoguan_btn",events={{event="click",method="onTuoGuan"}}},
    --底分文本
	difenLabel = {path="top.difen_con.difen_label"},
    --记牌器
    jipaiqiNode = {path="top.jipaiqi_node"},
    --记牌器按钮
    jipaiqiBtn = {path="top.jipaiqi_node.jipaiqi_btn",events={{event="click",method="onJiPaiQi"}}},
    --记牌器牌数
    jipaiqiNumNode = {path="top.jipaiqi_node.jipaiqi_box"},
    --底牌节点
    blindView = {path="top.dipai_con.pokers_node"},
    
    --手牌节点
    myCardView = {path="player_1.poker_node"},

    --我的视图根节点
    myView = {path="myView"},

    --胜负结果根节点
    resultNode = {path="myView.result_node"},
    --地主失败
    lordLoseImg = {path="myView.result_node.dizhu_lose_img"},
    --地主胜利
    lordWinImg = {path="myView.result_node.dizhu_win_img"},
    --农民失败
    farmerLoseImg = {path="myView.result_node.nongmin_lose_img"},
    --农民胜利
    farmerWinImg = {path="myView.result_node.nongmin_win_img"},

    --倍数
    beishuNode = {path="bottom.beishu_img"},
    beishuLabel = {path="bottom.beishu_img.beishu_fnt"},

    --叫分
    jiaofenNode = {path="myView.jiaofen_node"},
    bujiaoBtn = {path="myView.jiaofen_node.bujiao_btn",events={{event="click",method="onBuJiao"}}},
    jiaofenClockNode = {path="myView.jiaofen_node.clock_node"},
    jiao1fenBtn = {path="myView.jiaofen_node.jiao1fen_btn",events={{event="click",method="onJiao1Fen"}}},
    jiao2fenBtn = {path="myView.jiaofen_node.jiao2fen_btn",events={{event="click",method="onJiao2Fen"}}},
    jiao3fenBtn = {path="myView.jiaofen_node.jiao3fen_btn",events={{event="click",method="onJiao3Fen"}}},

    --加倍
    jiabeiNode = {path="myView.jiabei_node"},
    jiabeiClockNode = {path="myView.jiabei_node.clock_node"},
    bujiabeiBtn = {path="myView.jiabei_node.bujiabei_btn",events={{event="click",method="onBuJiaBei"}}},
    jiabeiBtn = {path="myView.jiabei_node.jiabei_btn",events={{event="click",method="onJiaBei"}}},

    --出牌操作
    caozuoNode = {path="myView.caozuo_node"},
    caozuoClockNode = {path="myView.caozuo_node.clock_node"},
    buyaoBtn = {path="myView.caozuo_node.buyao_btn",events={{event="click",method="onBuYao"}}},
    tishiBtn = {path="myView.caozuo_node.tishi_btn",events={{event="click",method="onTiShi"}}},
    chupaiBtn = {path="myView.caozuo_node.chupai_btn",events={{event="click",method="onChuPai"}}},

    --要不起
    yaobuqiNode = {path="myView.yaobuqi_node"},
    yaobuqiClockNode = {path="myView.yaobuqi_node.clock_node"},
    yaobuqiBtn = {path="myView.yaobuqi_node.yaobuqi_btn",events={{event="click",method="onYaoBuQi"}}},
    yaobuqiMaskBtn = {path="myView.yaobuqi_node.mask",events={{event="click",method="onYaoBuQi"}}},

    --自动出牌
    zidongchupaiNode = {path="myView.zidongchupai_node"},
    quxiaozidongBtn = {path="myView.zidongchupai_node.quxiaozidong_btn",events={{event="click",method="onQuXiaoZiDong"}}},
    zidongchupaiBtn = {path="myView.zidongchupai_node.zidongchupai_btn",events={{event="click",method="onZiDongChuPai"}}},

    --全局特效节点
    effectNode = {path="effect_node"},

    --结算面板
    settlementNode = {path="result_con"},

    --触摸层节点
    pokerTouchNode = {path="player_1.poker_touch_node"},
}

C.jipaiNumbers = nil
C.jipaiNones = nil
C.players = nil
C.myCardViewRect = {}
C.settlementView = nil
C.resultImgBirthPoints = {}

function C:ctor(core)
    --记牌器
	for i=1,15 do
		local key = string.format("jipai%d",i)
		local path = string.format("top.jipaiqi_node.jipaiqi_box.green.label_%d",i)
		self.RESOURCE_BINDING[key] = {path=path}
	end
    for i=1,15 do
		local key = string.format("jipaiNone%d",i)
		local path = string.format("top.jipaiqi_node.jipaiqi_box.gray.label_%d",i)
		self.RESOURCE_BINDING[key] = {path=path}
	end
    --玩家
    for i=1,3 do
		local key = string.format("player%d",i)
		local path = string.format("player_%d",i)
		self.RESOURCE_BINDING[key] = {path=path}
	end
	C.super.ctor(self,core)
end

function C:initialize()
	C.super.initialize(self)
    --适配宽屏
    -- self:adjustUI(self.topBg,{self.backBtn,self.batteryNode},{self.helpBtn,self.settingsBtn,self.tuoguanBtn})
    self:adjustUI(
        self.topBg,
        {
            self.backBtn,
            self.batteryNode,

        },
        {
            self.helpBtn,
            self.settingsBtn,
            self.tuoguanBtn,
        }
    )


    self:adjustHeadUI(
        {
            self["player3"],
            self["player1"]:getChildByName("head_con"),
            self["beishuNode"],
        },
        {
            self["player2"],
        }
    )

    self.jipaiNumbers = {}
    self.jipaiNones = {}

	for i=1,15 do
		local numKey = string.format("jipai%d",i)
        local noneKey = string.format("jipaiNone%d",i)
		self.jipaiNumbers[i] = self[numKey]
        self.jipaiNones[i] = self[noneKey]
	end

    --绑定玩家
    self.players = {}
    for i=1,3 do
        local key = string.format("player%d",i)
        local p = self[key]
		local player = PlayerClass.new(p,i,self.logic,self.effectNode)
        player:hide()
		self.players[i] = player
        if i == 1 then
            player.cancelTuoguanCallback = handler(self,self.onCancelTuoguanBtn)
        end
    end

    --绑定电池节点
    --self:bindBatteryNode(self.batteryBar,self.batteryLighting)
    self:bindBatteryNode(self.batteryNode)
	self:updateBattery()

    --绑定结算面板
    self.settlementView = SettlementView.new(self.settlementNode)

    --选牌触摸层
    self.lastMoveX = 0;
	self.lastMoveY = 0;
    self.layer = display.newLayer();
	self.layer:setTouchEnabled(true);
	self.layer:registerScriptTouchHandler(function(event, x, y)
		return self:onSelectCard(event, x, y)
	end, false, 0, false)
    self.pokerTouchNode:addChild(self.layer)

    local pos = self.myCardView:convertToWorldSpace(cc.p(0,0))
    local box = self.myCardView:getBoundingBox()
    self.myCardViewRect = {x = pos.x, y = pos.y, width = box.width, height = box.height}

    self.resultImgBirthPoints = {}
    self:clean()
end

function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	--TODO:播放背景音乐
    PLAY_MUSIC(GAME_DDZ_SOUND_RES.."bg.mp3")
end

function C:onExitTransitionStart()
    self:clean()
	C.super.onExitTransitionStart(self)
end

--加载资源
function C:loadResource()
    C.super.loadResource(self)
    --加载plist图集
    display.loadSpriteFrames(GAME_DDZ_ANIMATION_RES.."alert.plist",GAME_DDZ_ANIMATION_RES.."alert.png")
    display.loadSpriteFrames(GAME_DDZ_IMAGES_RES.."ddz_cards.plist",GAME_DDZ_IMAGES_RES.."ddz_cards.png")
end

--卸载资源
function C:unloadResource()
    --移除图集
    display.removeSpriteFrames(GAME_DDZ_ANIMATION_RES.."alert.plist",GAME_DDZ_ANIMATION_RES.."alert.png")
    display.removeSpriteFrames(GAME_DDZ_IMAGES_RES.."ddz_cards.plist",GAME_DDZ_IMAGES_RES.."ddz_cards.png")
    
    C.super.unloadResource(self)
end

function C:clean()
	self:hideJiPaiQi()
    self:hideJiaoFenButtons()
    self:hideJiaBeiButtons()
    self:hideChuPaiButtons()
    self:hideAutoShowCardButtons()
    self:hideYaoBuQiButtons()
    self:hideBeiLv()
    self:hideBlindCards()
    self:cleanMyCards()
    self:hideResult()
    self:hideSettlement()

    for i=1,3 do
		self.players[i]:clean()
	end
end

function C:hideOtherPlayers()
    self.players[2]:hide()
    self.players[3]:hide()
end

function C:delayInvoke(time,callback)
    local act = transition.sequence({
		CCDelayTime:create(time),
		CCCallFunc:create(callback)
	})
    self:runAction(act)
end

--region UI Event

--测试
function C:onTest1()
    for i=1,3 do
        self:showPlayer(i,{headid = 5,playerid = "123456",money = 10000,nickname = "深圳"})
    end

    self.players[1]:playAirplaneAni()

    local colornumbers = 
    {   
    --连对，顺子
--        [1] = {color = 3,num = 3},
--        [2] = {color = 3,num = 4},
--        [3] = {color = 3,num = 5},
--        [4] = {color = 3,num = 6},
--        [5] = {color = 3,num = 7},

--        [6] = {color = 4,num = 3},
--        [7] = {color = 4,num = 4},
--        [8] = {color = 4,num = 5},
--        [9] = {color = 4,num = 6},
--        [10] = {color = 4,num = 7},

        --三带一
--        [1] = {color = 3,num = 3},
--        [2] = {color = 4,num = 3},
--        [3] = {color = 5,num = 3},
--        [4] = {color = 3,num = 6},

        --三带二
--        [1] = {color = 3,num = 3},
--        [2] = {color = 4,num = 3},
--        [3] = {color = 5,num = 3},
--        [4] = {color = 3,num = 6},
--        [5] = {color = 4,num = 6},

        --四带一对
--        [1] = {color = 3,num = 3},
--        [2] = {color = 4,num = 3},
--        [3] = {color = 5,num = 3},
--        [4] = {color = 6,num = 3},
--        [5] = {color = 3,num = 6},
--        [6] = {color = 4,num = 6},

        --四带二对
--        [1] = {color = 3,num = 3},
--        [2] = {color = 4,num = 3},
--        [3] = {color = 5,num = 3},
--        [4] = {color = 6,num = 3},
--        [5] = {color = 3,num = 6},
--        [6] = {color = 4,num = 6},
--        [7] = {color = 3,num = 7},
--        [8] = {color = 4,num = 7},

        --飞机
--        [1] = {color = 3,num = 3},
--        [2] = {color = 4,num = 3},
--        [3] = {color = 5,num = 3},
--        [4] = {color = 3,num = 4},
--        [5] = {color = 4,num = 4},
--        [6] = {color = 5,num = 4},
--        [7] = {color = 3,num = 7},
--        [8] = {color = 4,num = 7},

        --炸弹
--        [1] = {color = 3,num = 3},
--        [2] = {color = 4,num = 3},
--        [3] = {color = 5,num = 3},
--        [4] = {color = 6,num = 3},
        --火箭
        [1] = {color = 2,num = 15},
        [2] = {color = 2,num = 16},
    }
    local cards = {}
    for k,v in pairs(colornumbers) do
        table.insert(cards,self.logic:colorNumber2Id(v.color,v.num))
    end

    for i=1,3 do
        self:showCards(i,cards)
    end

    self:showYaoBuQiButtons()
end

function C:onTest2()

end

--点击返回按钮
function C:onBack(event)
    printInfo("点击了返回")
	self:touchBack()
end

--点击帮助按钮
function C:onHelp(event)
	self:showRule()
end

--点击设置按钮
function C:onSettings(event)
	self:showSettings()
end

--点击托管按钮
function C:onTuoGuan(event)
	self.core:tuoGuan()
end

--点击取消托管按钮
function C:onCancelTuoguanBtn()
    self.core:cancelTuoGuan()
end

--点击记牌器按钮
function C:onJiPaiQi(event)
    if self.jipaiqiAnimating and self.jipaiqiAnimating == true then
        return
    end
    self.jipaiqiAnimating = true

    if self.jipaiqiNumNode:isVisible() then
        transition.scaleTo(self.jipaiqiNumNode,{time = 0.12,scale = 0,onComplete = function()self.jipaiqiNumNode:setVisible(false) self.jipaiqiAnimating = false end})
	    transition.fadeTo(self.jipaiqiNumNode,{time = 0.12,opacity = 0})
    else
        self.jipaiqiNumNode:setVisible(true)
        self.jipaiqiNumNode:setScale(0)
	    self.jipaiqiNumNode:setOpacity(0)
	    transition.scaleTo(self.jipaiqiNumNode,{time = 0.2,easing = {"BACKOUT",2},scale = 1,onComplete = function() self.jipaiqiAnimating = false end})
	    transition.fadeTo(self.jipaiqiNumNode,{time = 0.2,opacity = 255})
    end
    
end

--不叫
function C:onBuJiao(event)
    self.core:buJiao()
end

--叫1分
function C:onJiao1Fen(event)
    self.core:jiaoFen(1)
end

--叫2分
function C:onJiao2Fen(event)
    self.core:jiaoFen(2)
end

--叫3分
function C:onJiao3Fen(event)
    self.core:jiaoFen(3)
end

--加倍
function C:onJiaBei(event)
    self.core:jiaBei()
end

--不加倍
function C:onBuJiaBei(event)
    self.core:buJiaBei()
end

--不要
function C:onBuYao(event)
    self.core:buYao()
end

--提示
function C:onTiShi(event)
    local cards = self.logic:getNextHint();
    if not cards then
        self:unselectAllCards()
    else
        self:unselectAllCards()
        self:showTipCards(self.logic:cardsToProto(cards))
    end
end

--出牌
function C:onChuPai(event)
    self:updateSelectedCards()
    self.core:chuPai()
end

--要不起
function C:onYaoBuQi(event)
    self.core:buYao()
end

--取消自动
function C:onQuXiaoZiDong(event)
    self.quxiaozidongBtn:setVisible(false)
    self.zidongchupaiBtn:setVisible(true)
    self.model.autoShowCard = false
end

--自动出牌
function C:onZiDongChuPai(event)
    self.quxiaozidongBtn:setVisible(true)
    self.zidongchupaiBtn:setVisible(false)
    self.model.autoShowCard = true
end

--endregion 

--region API

--显示记牌器（及其按钮）
function C:showJiPaiQi()
    self.jipaiqiNode:setVisible(true)
    self.jipaiqiNumNode:setVisible(false)
    self.jipaiqiAnimating = false
    self:onJiPaiQi()
end

--隐藏记牌器（及其按钮）
function C:hideJiPaiQi()
    self.jipaiqiNode:setVisible(false)
end

--隐藏记牌器数字面板
function C:hideJiPaiQiNumber()
    self.jipaiqiNumNode:setVisible(false)
end

--设置记牌器剩余牌数
function C:setJiPaiQiNumber(card,num)
    -- if num > 0 then
    --     self.jipaiNumbers[card]:setVisible(true)
    --     self.jipaiNumbers[card]:setString(num)
    --     self.jipaiNones[card]:setVisible(false)
    -- else
    --     self.jipaiNumbers[card]:setVisible(false)
    --     self.jipaiNones[card]:setString("0")
    --     self.jipaiNones[card]:setVisible(true)
    -- end
    self.jipaiNumbers[card]:setVisible(false)
    self.jipaiNones[card]:setString(num)
    if num==0 then
        self.jipaiNones[card]:setColor(cc.c3b(255,255,255))
    elseif num==4 then
        self.jipaiNones[card]:setColor(cc.c3b(255,0,0))      
    else
        self.jipaiNones[card]:setColor(cc.c3b(5,148,20))
    end
    self.jipaiNones[card]:setVisible(true)
end

--清零记牌器
function C:cleanJiPaiQi()
    for i=1,15 do
        self:setJiPaiQiNumber(i,0)
    end
end

--设置底分
function C:setDiFen(difen)
    print("DiFen============================="..tostring(difen))
    self.difenLabel:setString(tostring(difen))
end

--设置倍率
function C:setBeiLv(beilv)
    self.beishuNode:setVisible(true)
    self.beishuLabel:setString(tostring(beilv))
end

--隐藏倍率
function C:hideBeiLv()
    self.beishuNode:setVisible(false)
end

--显示叫分
function C:showJiaoFen(seat,fen)
    self.players[seat]:showJiaoFen(fen)
end

--隐藏叫分
function C:hideJiaoFen(seat)
    self.players[seat]:hideJiaoFen()
end

--隐藏所有叫分
function C:hideAllJiaoFen()
    for i = 1,3 do
        self.players[i]:hideJiaoFen()
    end
end

--显示加倍
function C:showJiaBei(seat,jiabei)
    self.players[seat]:showJiaBei(jiabei)
end

--隐藏加倍
function C:hideJiaBei(seat)
    self.players[seat]:hideJiaBei()
end

--隐藏所有加倍
function C:hideAllJiaBei()
    for i = 1,3 do
        self.players[i]:hideJiaBei()
    end
end

--显示匹配动画
function C:showWaiting()
    if self.waitingAni == nil or self.waitingAct == nil then
        self.waitingAni = cc.CSLoader:createNode(WAITING_CSB)
        self.waitingAct = cc.CSLoader:createTimeline(WAITING_CSB)
        self.waitingAni:runAction(self.waitingAct)
        self.waitingAni:addTo(self)
        self.waitingAni:setPosition(cc.p(display.cx,display.cy))
    end
    self.waitingAni:setVisible(true)
    self.waitingAct:gotoFrameAndPlay(0,true)
end

--隐藏匹配动画
function C:hideWaiting()
    if self.waitingAni then
        self.waitingAni:setVisible(false)
    end
    if self.waitingAct then
        self.waitingAct:stop()
    end
end

--显示玩家
function C:showPlayer(seat,info)
    print("showPlayer"..tostring(seat))
    self.players[seat]:show(info)
end

--隐藏玩家
function C:hidePlayer(seat)
    self.players[seat]:hide()
end

--设置金币
function C:setMoney(seat,money)
    self.players[seat]:setMoney(money)
end

--显示剩余牌数
function C:showRemainCardNumber(seat,num)
    self.players[seat]:showRemainCards(num)
end

--隐藏剩余牌数
function C:hideRemainCardNumber(seat)
    self.players[seat]:hideRemainCards()
end

--显示地主标志
function C:showDiZhu(seat,anim)
    self.players[seat]:showDiZhu(anim)
    self.players[seat].isLord = true
end

--隐藏地主标志
function C:hideDiZhu(seat)
    self.players[seat]:hideDiZhu()
end

--显示叫分按钮
function C:showJiaoFenButtons(fens,time,callback)
    self.jiaofenNode:setVisible(true)
    self.jiaofenClockNode:setVisible(true)
    self.jiao1fenBtn:setEnabled(false)
    self.jiao2fenBtn:setEnabled(false)
    self.jiao3fenBtn:setEnabled(false)

    for k,v in pairs(fens) do
        if v == 1 then
            self.jiao1fenBtn:setEnabled(true)
        end
        if v == 2 then
            self.jiao2fenBtn:setEnabled(true)
        end
        if v == 3 then
            self.jiao3fenBtn:setEnabled(true)
        end
    end
    local pos = self.jiaofenClockNode:convertToWorldSpace(cc.p(0,0))
    self.players[1]:showClock(time,callback,pos)
end

--隐藏叫分按钮
function C:hideJiaoFenButtons()
    self.jiaofenNode:setVisible(false)
    self.players[1]:hideClock()
end

--显示加倍按钮
function C:showJiaBeiButtons(time,callback)
    self.jiabeiNode:setVisible(true)
    local pos = self.jiabeiClockNode:convertToWorldSpace(cc.p(0,0))
    self.players[1]:showClock(time,callback,pos)
end

--隐藏加倍按钮
function C:hideJiaBeiButtons()
    self.jiabeiNode:setVisible(false)
    self.players[1]:hideClock()
end

--显示出牌按钮
function C:showChuPaiButtons(time,callback,first)
    self.caozuoNode:setVisible(true)
    self.buyaoBtn:setEnabled(not first)
    local pos = self.caozuoClockNode:convertToWorldSpace(cc.p(0,0))
    self.players[1]:showClock(time,callback,pos)
    self:updateSelectedCards()
end

--隐藏出牌按钮
function C:hideChuPaiButtons()
    self.caozuoNode:setVisible(false)
    self.players[1]:hideClock()
end

--显示自动出牌按钮
function C:showAutoShowCardButtons(auto)
    if not self.zidongchupaiNode:isVisible() then
        self.zidongchupaiBtn:setVisible(auto)
        self.quxiaozidongBtn:setVisible(not auto)
    end
    self.zidongchupaiNode:setVisible(true)
end

--隐藏自动出牌按钮
function C:hideAutoShowCardButtons()
    self.zidongchupaiNode:setVisible(false)
end

--显示要不起按钮
function C:showYaoBuQiButtons(time,callback)
    self.yaobuqiNode:setVisible(true)
    local pos = self.yaobuqiClockNode:convertToWorldSpace(cc.p(0,0))
    self.players[1]:showClock(time,callback,pos)
end

--隐藏要不起按钮
function C:hideYaoBuQiButtons()
    self.yaobuqiNode:setVisible(false)
end

--显示闹钟
function C:showClock(seat,time,callback,pos)
    self.players[seat]:showClock(time,callback,pos)
end

--隐藏闹钟
function C:hideClock(seat)
    self.players[seat]:hideClock()
end

--隐藏所有闹钟
function C:hideAllClocks()
    for k,v in pairs(self.players) do
        v:hideClock()
    end
end

--显示报警
function C:showAlert(seat)
    self.players[seat]:showAlert()
end

--隐藏报警
function C:hideAlert(seat)
    self.players[seat]:hideAlert()
end

--出牌
function C:showCards(seat,cards,anim,showAll)
    self.players[seat]:showCards(cards,anim,showAll)
end

--隐藏出牌
function C:hideCards(seat)
    self.players[seat]:hideCards()
end

--隐藏所有出牌
function C:hideAllCards()
    for i = 1,3 do
        self.players[i]:hideCards()
    end
end

--显示不要
function C:showBuYao(seat)
    self.players[seat]:showBuYao()
end

--隐藏不要
function C:hideBuYao(seat)
    self.players[seat]:hideBuYao()
end

--隐藏所有不要
function C:hideAllBuYao()
    for i = 1,3 do
        self.players[i]:hideBuYao()
    end
end

--显示托管
function C:showTuoGuan(seat)
    self.players[seat]:showTuoGuan()
end

--隐藏托管
function C:hideTuoGuan(seat)
    self.players[seat]:hideTuoGuan()
end

--显示胜负结果
function C:showResult(isLord,isWin,isSpring)
    if isWin then
        PLAY_SOUND(GAME_DDZ_SOUND_RES.."win.mp3")
    else
        PLAY_SOUND(GAME_DDZ_SOUND_RES.."lose.mp3")
    end
    self.resultNode:setVisible(true)
    self.lordWinImg:setVisible(false)
    self.lordLoseImg:setVisible(false)
    self.farmerWinImg:setVisible(false)
    self.farmerLoseImg:setVisible(false)
    local sp = nil

    local resetPos = function(img)
        local name = img:getName()
        if not self.resultImgBirthPoints[name] then
            local pos = cc.p(img:getPosition())
            self.resultImgBirthPoints[name] = pos
        else
            local pos = self.resultImgBirthPoints[name]
            img:setPosition(cc.p(pos.x,pos.y))
        end
    end
    resetPos(self.lordWinImg)
    resetPos(self.lordLoseImg)
    resetPos(self.farmerWinImg)
    resetPos(self.farmerLoseImg)


    if isLord then 
		if isWin then
			sp = self.lordWinImg
		else
			sp = self.lordLoseImg
		end 
	else 
		if isWin then
			sp = self.farmerWinImg
		else
			sp = self.farmerLoseImg
		end 
	end 

    sp:setVisible(true)
    local pos = self.resultImgBirthPoints[sp:getName()]


    sp:setPosition(cc.p(pos.x,pos.y + 50));

	if isWin then
	 	sp:setScale(0.1);
	else
		sp:setPosition(cc.p(pos.x,pos.y + 50)) 
	end

	local winAction = transition.sequence({
		CCScaleTo:create(0.2, 1.1),
		CCScaleTo:create(0.2, 1),
        CCDelayTime:create(1),
        CCCallFunc:create(function()
            if isSpring then
                self:playSpringAnim()
            end
        end),
		CCDelayTime:create(1.5),
		CCCallFunc:create(function ()
			sp:setVisible(false)
            self.resultNode:setVisible(false)
		end)
	})

	local loseAction = transition.sequence({
        CCMoveTo:create(0.2, cc.p(pos.x, pos.y -10)),
        CCMoveTo:create(0.1, cc.p(pos.x, pos.y)),
        CCDelayTime:create(1),
        CCCallFunc:create(function()
            if isSpring then
                self:playSpringAnim()
            end
        end),
		CCDelayTime:create(1),
		CCCallFunc:create(function ()
			sp:setVisible(false)
            self.resultNode:setVisible(false)
		end)
	})	
		
	sp:runAction(isWin and winAction or loseAction)

    return (isWin and 2.9 or 2.3) + (isSpring and 1.5 or 0)
end

--隐藏胜负结果
function C:hideResult()
    self.resultNode:setVisible(false)
    self.lordWinImg:setVisible(false)
    self.lordLoseImg:setVisible(false)
    self.farmerWinImg:setVisible(false)
    self.farmerLoseImg:setVisible(false)
end

--显示结算
function C:showSettlement(info)
    self.settlementView:show(info)
end

--隐藏结算
function C:hideSettlement()
    self.settlementView:hide()
end

function C:playSpringAnim()
    self.players[1]:playSpringAni()
end


--region 扑克牌

--创建底牌
function C:showBlindCards(cards)
    self.blindView:removeAllChildren(true);
    for i, v in pairs(cards) do 
		local w = 72;
		local x = -w*2 + w * i;
		local card = Card.new({
				id = v,
				bottom = true
			})
		card:setPosition(cc.p(x, 0));
		card:addTo(self.blindView);
	end
end
--隐藏底牌
function C:hideBlindCards()
    self.blindView:removeAllChildren(true);
end

--创建手牌
function C:createMyCards(cards,anim,blind)
    self.myCardView:removeAllChildren(true);
    if cards == nil then return end
    if #cards == 0 then return end
    cards = self.logic:sortCards(cards)
    local count = #cards;
	local scale = 1;
	local gap = count <= 17 and 54 or 50;
	gap = gap * scale;

	local cx = display.cx
	local setX = cx - (count - 1) / 2 * gap
    local setY = display.cy-185
    local localPos = self.myCardView:convertToNodeSpace(cc.p(setX,setY))
    local originX = localPos.x

	for i, k in ipairs(cards) do

		local isBlind = false;

		if #self.model.blindCards > 0 and blind then 
			for j, b in pairs(self.model.blindCards) do
				if k == b then
					isBlind = true;
					break; 
				end  
			end 
		end 


		local x = originX + (count - i) * gap
		
		local card = Card.new({
				delegate = self.core,
				id = k,
				showIdx = count - i,
				anim = anim and #self.model.blindCards < 1,
				isLord = self.model.isLord,
				lastCard = i == 1,
				isBlind = isBlind,
			})
		card:setPosition(cc.p(x, setY));
		card:addTo(self.myCardView, count - i);
		card:setTag(k);
		card:setScale(scale)
	end
    self.logic:setNewCards(self.logic:protoToCards(cards))

    --由于服务器会自动出最后一张牌，客户端暂时先关闭该功能
    if #cards == 1 then
        --self:showAutoShowCardButtons(true)
    end
end

--清除所有手牌
function C:cleanMyCards()
    self.myCardView:removeAllChildren(true);
end

--选牌回调
function C:onSelectCard(event, x, y)
	local pos = self.myCardView:convertToNodeSpace(cc.p(x, y));
	if event == "began" then
		if cc.rectContainsPoint(self.myCardViewRect,cc.p(x, y)) then
			self.lastMoveX = x;
	        self.lastMoveY = y;
	        self.touchCards = {}; 
	        self.touchCardIds = {};
	        self.index = 0;
	        self.startIndex = 0;
	        self.endIndex = 0;
			for i, id in pairs(self.model.myCards) do 
				local rect, card = self:getCardRect(id);
				if cc.rectContainsPoint(rect,pos) then
					self.index = id;
					self.startIndex = i;
					card:selected();
					self.touchCards[i] = card;
					self.touchCardIds[i] = id;
					PLAY_SOUND(SELECTED_CARD_SOUND)
					break;
				end 
			end 
			return true;
		else 
			return false;
		end
	elseif event == "moved" then
		if math.abs(x - self.lastMoveX) > 10 or math.abs(y - self.lastMoveY) > 10 then
			self.lastMoveX = x
            self.lastMoveY = y
			local outCard = true;

			for i, id in pairs(self.model.myCards) do 
				local rect, card = self:getCardRect(id);
				if self.startIndex ~= i then
					card:unSelected();
					self.touchCards[i] = nil;
					self.touchCardIds[i] = nil;  
				end 

				if cc.rectContainsPoint(rect,pos) then
					outCard = false;
					if self.startIndex == 0 then 
						self.startIndex = i;
					end 
					self.endIndex = i;
				end 
			end 

			if self.startIndex ~= self.endIndex then

			  	local increase = self.startIndex < self.endIndex and 1 or -1;
	            for i = self.startIndex, self.endIndex, increase do
	            	if self.model.myCards[i] then
		    		    if self.touchCards[i] == nil then
		    		    	local card = self.myCardView:getChildByTag(self.model.myCards[i]);
	    		    		card:selected();
		    		    	self.touchCards[i] = card;
							self.touchCardIds[i] = self.model.myCards[i];
		    		    end  
	            	end 
	            end  
			end 

			if outCard then --move out of cards reset index
				self.index = 0;
			end 
    	end 
    elseif event == "ended" then
    	for i ,card in pairs(self.touchCards) do
    		if card ~= nil then 
	    		card:unSelected();
				if card:isUp() then 
					card:downCard();
				else
					card:upCard(); 
				end  
    		end 
    	end 

    	self:showSelectedHintCards(self.touchCards)

        self:updateSelectedCards()

    	self.touchCards = {};
	end 
	self.toucheEvent = event;

	return true;
end 

function C:showSelectedHintCards(touchCards)
	-- 自己回合并且是在连选2张牌以上才生效
	if self.model.isMyTurn and #self.touchCards > 2 then
        utils:delayInvoke("ddz.selected.hint.cards",0.1,
            function() 
                local cards = self.logic:getSelectedHintCards(self.logic:protoToCards(self.model.selectedCards))
		        -- 有牌才会改变，如果是nil，就什么都不做
		        if cards then
		            self:showTipCards(self.logic:cardsToProto(cards))
		        end
		    end)
	end
end

function C:showTipCards(data)
	local keys = {};
	for i,id in pairs(data) do 
		table.insert(keys, id, id)
	end 

	local clone = function(t)
	    if not t then
	        assert(false, "error: want to clone nil table")
	    end
	    local res = {}
	    for k, v in pairs(t) do
	        res[k] = v
	    end
	    return res
	end

	local cards = clone(self.model.selectedCards)

	for i,id in pairs(cards) do
		local card = self.myCardView:getChildByTag(id);
		if card:isUp() and not keys[id] then
			card:downCard()
		end 
	end

	for i,id in pairs(data) do 
		local card = self.myCardView:getChildByTag(id);
		if not card:isUp() then
			card:upCard();
		end
	end  
    self:updateSelectedCards()
end

--取消选择所有手牌
function C:unselectAllCards()
	for i,id in pairs(self.model.myCards) do 
		local card = self.myCardView:getChildByTag(id);
		if card and card:isUp() then 
			card:downCard();
		end 

		if card and card:isSelected() then
			card:unSelected();
		end 
	end 
    self:updateSelectedCards()
end

--更新选择的牌
function C:updateSelectedCards()
    local cards = {}
    for k,v in pairs(self.model.myCards) do
	    local card = self.myCardView:getChildByTag(v)
        if card and card:isUp() then
	        table.insert(cards,card.id)
        end
    end 
    self.model.selectedCards = cards
    self.logic:resetPlayCards(self.logic:protoToCards(cards))
    self.chupaiBtn:setEnabled(self.logic:isValidCards())
end

--设置扑克牌可点击
function C:setAllCardsClickable(clickable)
    self.layer:setTouchEnabled(clickable)
end

function C:playMyCards(cards)
	if cards then 
		local t = 0.3;
		for k, v in pairs(cards) do
			for i, mv in pairs(self.model.myCards) do 
				if mv == v then 
					table.remove(self.model.myCards, i);
				end 
			end
			local card = self.myCardView:getChildByTag(v);
			if card then
				card:fadeOut(t); 
			end 
		end

        utils:delayInvoke("ddz.playmycards",t,
            function() 
                self:createMyCards(self.model.myCards,false,false);
		    end)
	end 
end 

function C:getCardRect(id)
	local w = #self.model.myCards <= 17 and 54 or 50;
	local h = 200;
	local card = self.myCardView:getChildByTag(id);
	local rect = card:getBoundingBox();
	rect.x = rect.x - w;
	rect.y = rect.y - h/2;
	rect.width = card:isLastCard() and w*2 or w;
	rect.height = h;
	return rect, card;
end 

function C:adjustHeadUI(leftItems,rightItems)
    local offsetX = (display.width-1136)/2
    local offset2 = GET_PHONE_HAIRE_WIDTH()
    offset2 = offset2 > 0 and (offset2 + 20) or 0
    if leftItems then
        for i,v in ipairs(leftItems) do
            v:setPositionX(v:getPositionX() - offsetX + offset2)
        end
    end
    if rightItems then
        for i,v in ipairs(rightItems) do
            v:setPositionX(v:getPositionX() + offsetX - offset2)
        end
    end
end

--endregion


--endregion

return C