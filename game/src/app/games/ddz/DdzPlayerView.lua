local PokerClass = import(".DdzPokerView")
local C = class("DdzPlayerView",ViewBaseClass)
local scheduler = cc.Director:getInstance():getScheduler()
local Card = require("app.games.ddz.DdzPokerView")

local SEAT_MID = 1
local SEAT_LEFT = 3
local SEAT_RIGHT = 2

local VIEW_POSX = 10 + (IS_IPHONEX and 100 or 0)
local VIEW_POSY = 50;

local CENTER = cc.p(display.cx,display.cy)

local ALERT_SOUND = GAME_DDZ_SOUND_RES.."s_alert.mp3"
local COUNT_DOWN_SOUND = GAME_DDZ_SOUND_RES.."s_countdown.mp3"

local SPRING_SOUND = GAME_DDZ_SOUND_RES.."s_spring"
local BOMB_SOUND = GAME_DDZ_SOUND_RES.."s_bomb.mp3"
local AIRPLANE_SOUND = GAME_DDZ_SOUND_RES.."s_plane.mp3"
local ROCKET_SOUND = GAME_DDZ_SOUND_RES.."s_rocket.mp3"
local DOUBLE_STRAIGHT_SOUND = GAME_DDZ_SOUND_RES.."s_doublestraight.mp3"
local STRAIGHT_SOUND = GAME_DDZ_SOUND_RES.."s_straight.mp3"

local SPRING_CSB = GAME_DDZ_PREFAB_RES.."Spring.csb"
local BOMB_CSB = GAME_DDZ_PREFAB_RES.."Bomb.csb"
local PLANE_CSB = GAME_DDZ_PREFAB_RES.."Airplane.csb"
local ROCKET_FARMER_CSB = GAME_DDZ_PREFAB_RES.."RocketFarmer.csb"
local ROCKET_LORD_CSB = GAME_DDZ_PREFAB_RES.."RocketLord.csb"
local DOUBLE_STRAIGHT_CSB = GAME_DDZ_PREFAB_RES.."DoubleStraight.csb"
local STRAIGHT_CSB = GAME_DDZ_PREFAB_RES.."Straight.csb"
local STRAIGHT_REVERSE_CSB = GAME_DDZ_PREFAB_RES.."StraightReverse.csb"
local THREE_ONE_CSB = GAME_DDZ_PREFAB_RES.."3and1.csb"
local THREE_ONE_REVERSE_CSB = GAME_DDZ_PREFAB_RES.."3and1Reverse.csb"
local THREE_TWO_CSB = GAME_DDZ_PREFAB_RES.."3and2.csb"
local THREE_TWO_REVERSE_CSB = GAME_DDZ_PREFAB_RES.."3and2Reverse.csb"
local FOUR_ONE_CSB = GAME_DDZ_PREFAB_RES.."4and1.csb"
local FOUR_ONE_REVERSE_CSB = GAME_DDZ_PREFAB_RES.."4and1Reverse.csb"
local FOUR_TWO_CSB = GAME_DDZ_PREFAB_RES.."4and2.csb"
local FOUR_TWO_REVERSE_CSB = GAME_DDZ_PREFAB_RES.."4and2Reverse.csb"

local PLAYER_INFO_CSB = GAME_DDZ_PREFAB_RES.."PlayerInfo.csb"

C.BINDING = 
{
    headImg = {path="head_con.head_img"},
    frameImg = {path="head_con.frame_img"},
    dizhuImg = {path="head_con.dizhu_img"},
    creditLabel = {path="head_con.info_node.credit_label"},
    nameLabel = {path="head_con.info_node.name_label"},
    chupaiNode = {path="chupai_node"},
    buyaoImg = {path="buyao_img"},
    effectNode = {path="effect_node"},
    jiaofenNode = {path="jiaofen_node"},
    fen0Img = {path="jiaofen_node.0fen_img"},
    fen1Img = {path="jiaofen_node.1fen_img"},
    fen2Img = {path="jiaofen_node.2fen_img"},
    fen3Img = {path="jiaofen_node.3fen_img"},
    jiabeiNode = {path="jiabei_node"},
    bujiabeiImg = {path="jiabei_node.bujiabei_img"},
    jiabeiImg = {path="jiabei_node.jiabei_img"},
    tuoguanNode = {path="tuoguan_node"},
    tuoguanEyeImg = {path="tuoguan_node.eye_img"},
    clockNode = {path="clock_node"},
    clockLabel = {path="clock_node.clock_label"},
    clockTickImg = {path="clock_node.tick_img"},
    clockLeftImg = {path="clock_node.left_img"},
    clockRightImg = {path="clock_node.right_img"},
    clockLightImg = {path="clock_node.light_img"},
}

C.seat = 0
C.logic = nil
C.cancelTuoguanCallback = nil
C.jiaofens = nil
C.clockPos = nil
C.dizhuPos = nil
C.countDownHandler = nil

C.currentDetailInfoZorder = 0
C.playerInfo = nil
C.isLord = false
C.voice = "male/"
C.globalEffectNode = nil

function C:ctor(node,seat,logic,globalEffectNode)
    self.seat = seat
    self.logic = logic
    self.globalEffectNode = globalEffectNode

    if self.seat ~= 1 then
        self.BINDING.cityLabel = {path="head_con.info_node.city_label"}
        self.BINDING.headBtn = {path="head_con.head_btn",events={{event="click",method="showDetailInfo"}}}
        self.BINDING.alertImg = {path="alert_img"}
        self.BINDING.alertSp = {path="alert_img.light_sp"}
        self.BINDING.pokerRemainNode = {path="poker_remain_bg_img"}
        self.BINDING.pokerRemainLabel = {path="poker_remain_bg_img.poker_remain_label"}
    
    else
        self.BINDING.cancelTuoguanBtn = {path="tuoguan_node.cancel_btn",events={{event="click",method="cancelTuoguan"}}}
    end

    C.super.ctor(self,node)
end

function C:onCreate()

    self.jiaofens = {}
    self.jiaofens[1] = self.fen0Img
    self.jiaofens[2] = self.fen1Img
    self.jiaofens[3] = self.fen2Img
    self.jiaofens[4] = self.fen3Img

    self.clockPos = {}
    self.clockPos.root = cc.p(self.clockNode:getPosition())
    self.clockPos.left = cc.p(self.clockLeftImg:getPosition())
    self.clockPos.right = cc.p(self.clockRightImg:getPosition())
    self.clockPos.tick = cc.p(self.clockTickImg:getPosition())
    
    self.dizhuPos = cc.p(self.dizhuImg:getPosition())

    if self.seat ~= SEAT_MID then
        local blendFunc = {};
        blendFunc.src = GL_DST_ALPHA
        blendFunc.dst = GL_ONE
        self.alertSp:setBlendFunc(blendFunc); 
    end

    self:clean()
end

--显示玩家
function C:show(info)
    print("show:"..tostring(info.playerid))
    self.playerInfo = info
    self.voice = info.headid % 2 == 1 and "female/" or "male/"
    local headId = self.playerInfo["headid"]
    local headUrl = self.playerInfo["wxheadurl"]
    SET_HEAD_IMG(self.headImg,headId,headUrl)
    local name = self.playerInfo["nickname"]
    if name == nil or name == "" then
        name = tostring(self.playerInfo["playerid"])
    end
    self.nameLabel:setString(name)
    self.creditLabel:setString(utils:moneyString(self.playerInfo["money"]))
    if self.seat ~= SEAT_MID then
        local city = self.playerInfo["city"]
        if city == nil or city == "" then
            city = "未知"
        end
        self.cityLabel:setString(tostring(city))
    end
    self.node:setVisible(true)
    self.isLord = false
end

--隐藏玩家
function C:hide()
    self.node:setVisible(false)
end

--清理显示
function C:clean()
    self:hideClock()
    self:hideTuoGuan()
    self:hideAlert()
    self:hideRemainCards()
    self:hideDiZhu()
    self:hideJiaoFen()
    self:hideCards()
    self:hideJiaBei()
    self:hideBuYao()
    self:removeClockHandler()
end

--设置金币
function C:setMoney(money)
    if self.playerInfo then
        self.playerInfo["money"] = money
    end
    local moneyStr = utils:moneyString(money)
    self.creditLabel:setString(moneyStr)
end

--显示详细信息
function C:showDetailInfo()
    if self.seat == SEAT_MID then return end
    if self.playerInfo == nil then return end

    --点击关闭
    local cover = ccui.Layout:create()
    cover:setTouchEnabled(true)
    cover:setContentSize(cc.size(display.width, display.height))
    cover:setAnchorPoint(cc.p(0, 0))
    cover:setPosition(0,0)
    cover:addTo(self.globalEffectNode)

    local panel = cc.CSLoader:createNode(PLAYER_INFO_CSB)
    panel:addTo(self.globalEffectNode)

    cover:onClick(function()
        cover:removeFromParent(true)
        panel:removeFromParent(true)
    end)
    
    --绑定数据
    local root = panel:getChildByName("pop_info_panel")
    local headImg = root:getChildByName("head_img")
    local frameImg = root:getChildByName("frame_img")
    local vipImg = root:getChildByName("vip_img")
    local vipLabel = vipImg:getChildByName("label")
    local idLabel = root:getChildByName("id_label")
    local nameLabel = root:getChildByName("name_label")
    local cityLabel = root:getChildByName("city_label")
    local creditLabel = root:getChildByName("credit_fnt")
    local nameLabel = root:getChildByName("name_label")
    --头像
    local headId = self.playerInfo["headid"]
    local headUrl = self.playerInfo["wxheadurl"]
    SET_HEAD_IMG(headImg,headId,headUrl)
    --头像框
    --vip
    vipImg:setVisible(false)
    --id
    idLabel:setString(tostring(self.playerInfo["playerid"]))
    --name
    local name = self.playerInfo["nickname"]
    if name == nil or name == "" then
        name = tostring(self.playerInfo["playerid"])
    end
    nameLabel:setString(name)
    --city
    local city = self.playerInfo["city"] or "未知"
    cityLabel:setString(city)
    --money
    local money = self.playerInfo["money"]
    creditLabel:setString(utils:moneyString(money,3))

    local pos = cc.p(self.globalEffectNode:getPosition())
    local myNodePos = cc.p(self.node:getPosition())
    local myNodeWorldPos = self.node:getParent():convertToWorldSpace(myNodePos)
    local _localPos = self.globalEffectNode:convertToNodeSpace(myNodeWorldPos)
    local localPos = cc.p(_localPos.x + 250, _localPos.y - 4)
    if self.seat == SEAT_RIGHT then
        localPos = cc.p(_localPos.x - 250, _localPos.y - 4)
    end
    panel:setPosition(localPos)
    
    panel:setScale(0.1);
	local seq = transition.sequence({
			CCScaleTo:create(0.1, 1.1),
			CCScaleTo:create(0.1, 1),
			CCDelayTime:create(3),
			CCFadeOut:create(0.1),
			CCCallFunc:create(function ( ... )
                cover:removeFromParent(true)
				panel:removeFromParent(true);
			end)
		})
    panel:runAction(seq)
end

--显示托管
function C:showTuoGuan()
    if self.tuoguanNode:isVisible() then
        return
    end
    self.tuoguanNode:setVisible(true)
    self:animateTuoguanEye()
end

--隐藏托管
function C:hideTuoGuan()
    self.tuoguanNode:setVisible(false)
    self.tuoguanEyeImg:stopAllActions()
end

--播放托管机器人眼睛动画
function C:animateTuoguanEye()
    local t = 0.15;
    local seq = transition.sequence({
	    CCScaleTo:create(t, 1, 0.2),
	    CCScaleTo:create(t, 1, 1),
	    CCScaleTo:create(t, 1, 0.2),
	    CCScaleTo:create(t, 1, 1),
	    CCDelayTime:create(1);
    })
    self.tuoguanEyeImg:runAction(CCRepeatForever:create(seq))
end

--显示闹钟
function C:showClock(time,callback,pos)
    self:stopClockAnim()
    self:removeClockHandler();
    self.clockLabel:setString(tostring(time))
	local start = true;
    local leftTime = time;

    self.clockNode:setVisible(true)
	self.countDownHandler = scheduler:scheduleScriptFunc(function()
        leftTime = leftTime - 1;
		if leftTime <= 0 then
			if callback then
				callback()
			end
            self.clockNode:setVisible(false)
            self:removeClockHandler();
		else 
			self.clockLabel:setString(tostring(leftTime));
			if leftTime < 6 then 
				if time > 1 then 
					--TODO 播放音效
                    PLAY_SOUND(COUNT_DOWN_SOUND)
				end 
				if start then
					start = false;
					self:startClockAnim();
				end 
			end
		end 
	end, 1,false);

    if pos then
        local nodePos = self.node:convertToNodeSpace(pos)
        self.clockNode:setPosition(nodePos)
    end
end

--开始闹钟动画
function C:startClockAnim()

    local t = 1;
    self.clockLightImg:setVisible(true)
    self.clockLightImg:setScale(0.5);
	local spawn = transition.spawn({
			CCScaleTo:create(t, 1.25),
			transition.sequence({
					CCDelayTime:create(0.8),
					CCFadeOut:create(0.2),
				}),
		})
	local scale = transition.sequence({
			spawn,
			CCCallFunc:create(function ()
				self.clockLightImg:setScale(0.5);
				self.clockLightImg:setOpacity(255);
			end)
		})
	self.clockLightImg:runAction(CCRepeatForever:create(scale));

	local jump = transition.sequence({
			CCMoveBy:create(t/2, cc.p(0, 20)),
			CCMoveBy:create(t/2, cc.p(0, -20)),
		})
	self.clockNode:runAction(CCRepeatForever:create(jump)); 

	local jumpL = transition.sequence({
		CCMoveBy:create(t/2, cc.p(-10, 10)),
		CCMoveBy:create(t/2, cc.p(10, -10)),
	})
	self.clockLeftImg:runAction(CCRepeatForever:create(jumpL)); 

	local jumpR = transition.sequence({
		CCMoveBy:create(t/2, cc.p(10, 10)),
		CCMoveBy:create(t/2, cc.p(-10, -10)),
	})
	self.clockRightImg:runAction(CCRepeatForever:create(jumpR)); 

	local shake = transition.sequence({
			CCRotateTo:create(t/10, 20),
			CCRotateTo:create(t/10, -20),
		})
	self.clockTickImg:runAction(CCRepeatForever:create(shake)); 
end

--停止闹钟动画
function C:stopClockAnim()
    transition.stopTarget(self.clockNode)
    transition.stopTarget(self.clockLightImg)
    transition.stopTarget(self.clockLeftImg)
    transition.stopTarget(self.clockRightImg)
    transition.stopTarget(self.clockTickImg)
    self.clockLightImg:setVisible(false)
    self.clockNode:setPosition(self.clockPos.root)
    self.clockLeftImg:setPosition(self.clockPos.left)
    self.clockRightImg:setPosition(self.clockPos.right)
    self.clockTickImg:setPosition(self.clockPos.tick)
    self.clockTickImg:setRotation(0)
end

--隐藏闹钟
function C:hideClock()
    self.clockNode:setVisible(false)
    self.clockTickImg:stopAllActions()
    self:removeClockHandler()
end

--移除闹钟回调
function C:removeClockHandler()
	if self.countDownHandler then 
		scheduler:unscheduleScriptEntry(self.countDownHandler)
		self.countDownHandler = nil;
	end
end

--显示报警
function C:showAlert()
    if self.seat == SEAT_MID then return end
    self.alertImg:setVisible(true)
    PLAY_SOUND(ALERT_SOUND)
    utils:playFramesAnimation(self.alertSp,"alert",0,9,0.1,-1)
end

--隐藏报警
function C:hideAlert()
    if self.seat == SEAT_MID then return end
    self.alertImg:setVisible(false)
    transition.stopTarget(self.alertSp)
end

--取消托管
function C:cancelTuoguan()
    if self.cancelTuoguanCallback then
        self.cancelTuoguanCallback()
    end

end

--显示剩余牌数
function C:showRemainCards(num)
    if self.seat == SEAT_MID then return end
    if num <= 2  and num > 0 then
        if not self.alertImg:isVisible() then 
            self:showAlert()
        end
        local sound = GAME_DDZ_SOUND_RES..self.voice.."left"..num.."_"..math.random(1,2)..".mp3"
        PLAY_SOUND(sound)
    end
    self.pokerRemainNode:setVisible(true)
    self.pokerRemainLabel:setString(num)
end

--隐藏剩余牌数
function C:hideRemainCards()
    if self.seat == SEAT_MID then return end
    self.pokerRemainNode:setVisible(false)
end

--显示叫分
function C:showJiaoFen(fen,silent)
    self.jiaofenNode:setVisible(true)
    if not silent then
        local sound = "rate_"..fen
        PLAY_SOUND(GAME_DDZ_SOUND_RES..self.voice..sound..".mp3")
    end
    fen = fen + 1
    for i=1,4 do
        self.jiaofens[i]:setVisible(i==fen)
    end
end

--隐藏叫分
function C:hideJiaoFen()
    self.jiaofenNode:setVisible(false)
end

--显示加倍
function C:showJiaBei(jiabei,silent)
    self.jiabeiNode:setVisible(true)
    self.bujiabeiImg:setVisible(not jiabei)
    self.jiabeiImg:setVisible(jiabei)
    
    if not silent then
        if jiabei then
            PLAY_SOUND(GAME_DDZ_SOUND_RES..self.voice.."double.mp3")
        else
            PLAY_SOUND(GAME_DDZ_SOUND_RES..self.voice.."no_double.mp3")
        end
    end
end

function C:hideJiaBei()
    self.jiabeiNode:setVisible(false)
end

--显示地主
function C:showDiZhu(anim)
    self.dizhuImg:stopAllActions()
    self.dizhuImg:setVisible(true)
    if anim then
        local pos = self.dizhuImg:getParent():convertToNodeSpace(cc.p(display.cx,display.cy + 80))
        self.dizhuImg:setPosition(pos)
        self.dizhuImg:setScale(1.2);
	    local seq = transition.sequence({
				    CCEaseIn:create(CCScaleTo:create(0.1, 2), 0.1),
				    CCDelayTime:create(0.3),
				    CCEaseOut:create(CCScaleTo:create(0.3, 1), 0.2),
				    CCDelayTime:create(0.3),
				    CCEaseOut:create(CCMoveTo:create(0.3, self.dizhuPos), 0.2),
	        })
        self.dizhuImg:runAction(seq);
    else
        self.dizhuImg:setPosition(self.dizhuPos)
    end
end

--隐藏地主
function C:hideDiZhu()
    self.dizhuImg:setVisible(false)
end

--出牌
function C:showCards(cards,anim,showAll)
    PLAY_SOUND(GAME_DDZ_SOUND_RES.."s_playcard.mp3")
    self.chupaiNode:removeAllChildren(true);
    local gap = 34;
	local maxLine = 8;
	local count = 0;
	local lX = 160 + (IS_IPHONEX and 90 or 0);
	local rX = 160 + (IS_IPHONEX and 90 or 0);
	cards = self.logic:sortCards(cards);
    count = #cards;
    for i, v in pairs(cards) do
        local card = Card.new({
		    id = v,
		    isLord = self.isLord,
		    lastCard = i == 1,
		    playing = true,
	    })
        local x = gap * (count - i);
        local y = 0;
        card:addTo(self.chupaiNode, count - i);
        if count > maxLine then
	        local oX = 0;
	        if self.seat == SEAT_MID then 
	        elseif self.seat == SEAT_LEFT then
		        oX = gap/2
		        if ((count - i) / (maxLine - 1)) > 1 then 
			        x = gap * (count - maxLine - i);
			        y = -70;
		        end  
	        elseif self.seat == SEAT_RIGHT then
		        oX = gap/2 - 36;
		        if ((count - i) / (maxLine - 1)) > 1 then 
		            x = gap * (maxLine - i);
			        y = -70;
		        end  
	        end 	
	        x = x + oX;
        end 
        card:setScale(0.6);
        card:setPosition(cc.p(x, y));
        card:setTouchEnabled(false);

        if count > 1 and anim then
            local mx = self.seat == SEAT_RIGHT and count*gap or 0;
            local delay = self.seat == SEAT_RIGHT and 0.05*i or 0.05*(count - i);
            if self.seat == SEAT_RIGHT and count > maxLine then 
	            mx = maxLine*gap;
	        end 
            card:setPosition(cc.p(mx, y)); 
            local t = 0.1 + delay;
            local move = CCEaseIn:create(CCMoveTo:create(t, cc.p(x, y)), t);
            card:runAction(move);
        end 
    end 

    if self.seat == SEAT_MID then
		self.chupaiNode:align(display.CENTER_BOTTOM, -(count - 1) * gap * 0.5, showAll and (display.cy - 55) or (display.cy - 15))
	elseif self.seat == SEAT_RIGHT then
        self.chupaiNode:align(display.RIGHT_CENTER, -10-math.min(count,maxLine)*gap, 55)
        self.effectNode:align(display.RIGHT_CENTER, -10-math.min(count,maxLine)*gap * 0.5, 55)
	elseif self.seat == SEAT_LEFT then
		self.chupaiNode:align(display.LEFT_CENTER, 150, 55)
        self.effectNode:align(display.LEFT_CENTER, 150 + math.min(count,maxLine)*gap * 0.5, 55)
	end 
    self.chupaiNode:setVisible(true)
    if not showAll then
        self:playCardEffect(cards)
    end
end 

--隐藏出牌
function C:hideCards()
    self.chupaiNode:setVisible(false)
end

function C:playCardEffect(cards)
    self.logic:resetPlayCards(self.logic:protoToCards(cards))
    local count = self.logic:getPlayCardsCount()
    local sound = nil
    if count < 1 then
        return
    elseif count == 1 then
        if self.logic:isBigKing() then 
            --大王
			sound = "redjoker"
		elseif self.logic:isSmallKing() then 
            --小王
			sound = "blackjoker"
		else
            --单张
			sound = "single"..tostring(self.logic:getPlayCardsSingleKey())
            
		end 
    elseif count == 2 then
        if self.logic:isDoubleKing() then
            --火箭 
            sound = "rocket";
            self:playRocketAni()
        else
            --对子
            sound = "pair"..tostring(self.logic:getPlayCardsSingleKey())
        end 
    elseif count == 3 then
        --三顺
    	sound = "triple";
    elseif count == 4 then
    	if self.logic:isBomb() then 
            --炸弹
    		sound = "bomb";
            self:playBombAni()
    	elseif self.logic:isTripleWithSingle() then
            --三带一
    		sound = "3and1";
            self:play3And1Ani()
    	end 
    elseif count == 5 then
    	if self.logic:isTripleWithDouble() then
            --三带二
    		sound = "3and2";
            self:play3And2Ani()
    	end 
    else
        local isBomb, wings = self.logic:isBombWithWings();
    	if isBomb then 
            --四带二
    		sound = "4and"..wings;
            self:play4And1Ani()
    	elseif self.logic:isDoubleStraight() then 
            --双顺
    		sound = "doubelstraight";
            self:playDoubleStraightAni()
    	elseif self.logic:isTripleStraight() or self.logic:isTripleStraightWithWings() then 
            --飞机
    		sound = self.logic:isTripleStraight() and "plane" or "planewings";
            self:playAirplaneAni()
    	end 
    end

    if count >= 5 and self.logic:isSingleStraight() then 
        --顺子
        sound = "straight";
        self:playStraightAni()
    end

    PLAY_SOUND(GAME_DDZ_SOUND_RES..tostring(self.voice)..sound..".mp3")
end

--显示不要
function C:showBuYao(silent)
    self.buyaoImg:setVisible(true)
    if not silent then
        local sound = "pass_"..math.random(0,1)
        printInfo(sound)
        PLAY_SOUND(GAME_DDZ_SOUND_RES..self.voice..sound..".mp3")
    end
end

--隐藏不要
function C:hideBuYao()
    self.buyaoImg:setVisible(false)
end

--region 动画特效

--通用接口
function C:playEffect(anim,sound,soundDeley,parent,pos,worldSpace,isScale)
    if self.effectAnims == nil then
        self.effectAnims = {}
    end
    if self.effectAnimActions == nil then
        self.effectAnimActions = {}
    end

    local ani = self.effectAnims[anim]
    local act = self.effectAnimActions[anim]

    if ani == nil or act == nil then
        ani = cc.CSLoader:createNode(anim)
        act = cc.CSLoader:createTimeline(anim)
        ani:runAction(act)
        self.effectAnims[anim] = ani
        self.effectAnimActions[anim] = act
    end

    if not parent then
        parent = self.node        
    end

    if ani:getParent() ~= parent then
        ani:addTo(parent)
    end

    if pos then
        local p = pos
        if worldSpace then
            p = parent:convertToNodeSpace(pos)
        end
        ani:setPosition(p)
    else
        ani:setPosition(cc.p(0,0))
    end
        
    if isScale then
        if self.seat ~= SEAT_MID then
            ani:setScale(0.6)
        end
    end

    act:gotoFrameAndPlay(0,false)
    if sound then
        self:playSound(sound,soundDeley)
    end
end

function C:playSpringAni()
    self:playEffect(SPRING_CSB,SPRING_SOUND,0,self.globalEffectNode,CENTER,true)
end

--播放炸弹特效
function C:playBombAni()
    local strAnimName = GAME_DDZ_ANIMATION_RES.."sanim/boom/bomb"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:addTo(self.globalEffectNode,99)
    local p = self.globalEffectNode:convertToNodeSpace(CENTER)
	skeletonNode:setPosition(p)
    skeletonNode:setAnimation(0,"animation",false)
    skeletonNode:runAction(transition.sequence({
        CCDelayTime:create(2),
        CCCallFunc:create(function() 
            skeletonNode:stopAllActions()
            skeletonNode:setVisible(false)
            skeletonNode:removeFromParent(true)
        end)
    }))
    self:playSound(BOMB_SOUND,0.667)
end

--播放飞机特效
function C:playAirplaneAni()
    self:playEffect(PLANE_CSB,AIRPLANE_SOUND,0,self.globalEffectNode,CENTER,true)
end

--播放火箭特效
function C:playRocketAni()
    local strAnimName = GAME_DDZ_ANIMATION_RES.."sanim/rock/rocket"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:addTo(self.globalEffectNode,99)
    local p = self.globalEffectNode:convertToNodeSpace(CENTER)
	skeletonNode:setPosition(p)
    skeletonNode:setAnimation(0,"animation",false)
    skeletonNode:runAction(transition.sequence({
        CCDelayTime:create(2),
        CCCallFunc:create(function() 
            skeletonNode:stopAllActions()
            skeletonNode:setVisible(false)
            skeletonNode:removeFromParent(true)
        end)
    }))
    self:playSound(ROCKET_SOUND,0)
    self:playSound(BOMB_SOUND,1)
end

--播放连对特效
function C:playDoubleStraightAni()
    self:playEffect(DOUBLE_STRAIGHT_CSB,DOUBLE_STRAIGHT_SOUND,0,self.effectNode,nil,false,true)
end

--播放顺子特效
function C:playStraightAni()
    if self.seat == SEAT_RIGHT then
        self:playEffect(STRAIGHT_REVERSE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,true)
    else
        self:playEffect(STRAIGHT_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,true)
    end
end

--播放三带一特效
function C:play3And1Ani(rev)
    if self.seat == SEAT_RIGHT then
        self:playEffect(THREE_ONE_REVERSE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    else
        self:playEffect(THREE_ONE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    end
end

--播放三带二特效
function C:play3And2Ani(rev)
    if self.seat == SEAT_RIGHT then
        self:playEffect(THREE_TWO_REVERSE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    else
        self:playEffect(THREE_TWO_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    end
end

--播放四带一特效
function C:play4And1Ani(rev)
    if self.seat == SEAT_RIGHT then
        self:playEffect(FOUR_ONE_REVERSE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    else
        self:playEffect(FOUR_ONE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    end
end

--播放四带二特效
function C:play4And2Ani(rev)
    if self.seat == SEAT_RIGHT then
        self:playEffect(FOUR_TWO_REVERSE_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    else
        self:playEffect(FOUR_TWO_CSB,STRAIGHT_SOUND,0,self.effectNode,nil,false,false)
    end
end


function C:playSound(sound,delay)
    local seq = transition.sequence({
			CCDelayTime:create(delay),
			CCCallFunc:create(function ( ... )
				PLAY_SOUND(sound)
			end)
		})
    self.node:runAction(seq)
end

--endregion

return C
