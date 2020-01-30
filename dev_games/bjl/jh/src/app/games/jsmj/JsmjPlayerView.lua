
local C = class("JsmjPlayerView",ViewBaseClass)
local scheduler = cc.Director:getInstance():getScheduler()
local PopupClass = import(".JsmjPlayerDetailClass")

local DiceAnim = import(".JsmjDiceAnim")

local SEAT_MID = 1
local SEAT_LEFT = 3
local SEAT_RIGHT = 2

local VIEW_POSX = 10 + (IS_IPHONEX and 100 or 0)
local VIEW_POSY = 50;

local CENTER = cc.p(display.cx,display.cy)

C.BINDING = 
{
    headImg = {path="head_con.head_img"},
    frameImg = {path="head_con.frame_img"},

    scoreLabel = {path="head_con.score_label"},
    nameLabel = {path="head_con.name_label"},
    headBtn = {path="head_con.head_btn",events={{event="click",method="showDetailInfo"}}},

    winLabel = {path="Label_win"},
    loseLabel = {path="Label_lose"},
    nodeEffect = {path="Node_effect"},

    headNode = {path="head_con"},
    headStart = {path="head_start"},
}

C.seat = 0
C.logic = nil
C.countDownHandler = nil

C.currentDetailInfoZorder = 0
C.playerInfo = nil
C.voice = "male/"
C.globalEffectNode = nil

C.popupClass = nil

function C:ctor(node,seat,logic,globalEffectNode, bottomNode)
    self.seat = seat
    self.logic = logic
    self.globalEffectNode = globalEffectNode
    self.bottomNode = bottomNode

    --[[***
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
    ***]]

    self.popupClass = PopupClass.new(self.popupPanel)
    C.super.ctor(self,node)

    if self.seat == SEAT_MID then
        self.scoreLabel =  bottomNode:getChildByName("Text_score")
        self.nameLabel =  bottomNode:getChildByName("Text_name")
    end

    self.headStartPos = cc.p(self.headStart:getPosition())
    self.headEndPos = cc.p(self.headNode:getPosition())
end

function C:onCreate()

    --[[***
    if self.seat ~= SEAT_MID then
        local blendFunc = {};
        blendFunc.src = GL_DST_ALPHA
        blendFunc.dst = GL_ONE
        self.alertSp:setBlendFunc(blendFunc); 
    end
    ***]]

    self:clean()
end

--显示玩家
function C:show(info)
    print("show:"..info.playerid)
    self.playerInfo = info
    self.voice = info.headid % 2 == 1 and "female/" or "male/"
    local headRes = GET_HEADID_RES(self.playerInfo["headid"])
    self.headImg:loadTexture(headRes)
    self.nameLabel:setString(self.playerInfo["playerid"])
    self.scoreLabel:setString(utils:moneyString(self.playerInfo["money"]))

    --[[***
    if self.seat ~= SEAT_MID then
        self.cityLabel:setString(self.playerInfo["nickname"])
    end
    ***]]

    self.node:setVisible(true)
end

--隐藏玩家
function C:hide()
    self.node:setVisible(false)
end

--清理显示
function C:clean()
    --self:hideCards()
    self:hideResult()
    --self:removeClockHandler()
end

function C:showResult(score)
    if score >= 0 then
        self.winLabel:setVisible(true)
        self.loseLabel:setVisible(false)
        self.winLabel:setString("+" .. utils:moneyString(score,2))
    else
        self.winLabel:setVisible(false)
        self.loseLabel:setVisible(true)
        self.loseLabel:setString(utils:moneyString(score,2))
    end
end

function C:hideResult()
    self.winLabel:setVisible(false)
    self.loseLabel:setVisible(false)
end

--设置金币
function C:setMoney(money)
    if self.playerInfo then
        self.playerInfo["money"] = money
    end
    local moneyStr = utils:moneyString(money)
    self.scoreLabel:setString(moneyStr)
end

--显示详细信息
function C:showDetailInfo()
    --*** if self.seat == SEAT_MID then return end
    if self.playerInfo == nil then return end

	self.popupClass:show(self.playerInfo,self.seat)
end

--[[--
        开始掷骰子
        @param diceAck:投骰子消息 MAHJONG_CASTDICE_ACK
        @return none
  ]]
function C:castDice(diceValue)
    --self:askHoldMsgForBit(self.HOLD_BIT_CAST_DICE)
    --self:showRulerPrompt(false)
    if diceValue then
        --local pos = self.nodeEffect
        local vaule1, vaule2 = diceValue[1], diceValue[2]
        if self.diceAnim_ == nil then
            --local width, height = self.dimens_:getDimens(400), self.dimens_:getDimens(400)
            self.diceAnim_ = DiceAnim.new(self, 200, 200)
            self.diceAnim_:setPosition(-100, 0)
            self.diceAnim_:setAnchorPoint(cc.p(0, 0))
            --self.diceAnim_:setViewSize(400, 400)
            --self.diceAnim_:setScale(1)
            --self.diceAnim_:setOnAnimEndListener(function() self:askCleanHoldMsgForBit(self.HOLD_BIT_CAST_DICE) end)
            self.nodeEffect:addChild(self.diceAnim_)
        end
        self.diceAnim_:start(self.seat, vaule1, vaule2)
    end
end

--[[--
        移除回收骰子动画相关
        @param none
        @return none
  ]]
function C:recycleDiceView()
    local layer = self:getViewById(LAYER_ID_ANIM)
    if self.diceAnim_ and layer then
        self.diceAnim_:setVisible(false)
        layer:removeView(self.diceAnim_)
    end
    self.diceAnim_ = nil
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

return C
