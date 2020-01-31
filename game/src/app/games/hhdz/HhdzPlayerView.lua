local C = class("HhdzPlayerView",ViewBaseClass)
local scheduler = cc.Director:getInstance():getScheduler()

local CENTER = cc.p(display.cx,display.cy)

local PLAYER_INFO_CSB = GAME_HHDZ_PREFAB_RES.."PlayerInfo.csb"
local ON_BET_SOUND = GAME_HHDZ_SOUND_RES.."on_bet.mp3"

C.BINDING = 
{
    headNode = {path="head_con"},
    headImg = {path="head_con.head_img"},
    frameImg = {path="head_con.frame_img"},
    vipImg = {path="head_con.vip_img"},
    vipLabel = {path="head_con.vip_img.label"},
    headBtn = {path="head_con.head_btn",events={{event="click",method="showDetailInfo"}}},
    nameLabel = {path="info_node.name_label"},
    winFramePar = {path="head_con.win_effect_par"},
    winStarPar = {path="head_con.win_effect_par.star_par"},
    resultNode = {path="result_con"},
    winImg = {path="result_con.win_img"},
    winLabel = {path="result_con.win_img.label"},
    loseImg = {path="result_con.lose_img"},
    loseLabel = {path="result_con.lose_img.label"},
}

C.seat = 0
C.resultPos = nil
C.headPos = nil

function C:ctor(node,seat,globalEffectNode)
    self.seat = seat
    self.globalEffectNode = globalEffectNode
    if self.seat == 0 or self.seat == 1 or self.seat == 6 then
        self.BINDING.creditLabel = {path="info_node.credit_label"}
    end
    C.super.ctor(self,node)
end

function C:onCreate()
    self.resultPos = cc.p(self.resultNode:getPosition())
    self.headPos = cc.p(self.headNode:getPosition())
    self:clean()
end

--显示玩家
function C:show(info)
    self.playerInfo = info
    local headId = self.playerInfo["headid"]
    local headUrl = self.playerInfo["wxheadurl"]
    SET_HEAD_IMG(self.headImg,headId,headUrl)
    local name = self.playerInfo["nickname"]
    if name == nil or name == "" then
        name = tostring(self.playerInfo["playerid"])
    end
    self.nameLabel:setString(name)
    self.vipImg:setVisible(false)
    self.vipLabel:setVisible(false)
    --self.vipLabel:setString(self.playerInfo["vipLevel2"])
    if self.seat == 0 or self.seat == 1 or self.seat == 6 then
        self.creditLabel:setString(utils:moneyString(self.playerInfo["money"]))
    end
    -- self.frameImg:loadTexture(GET_FRAMEID_RES(self.playerInfo["vipLevel2"]))
    self.node:setVisible(true)
end

--隐藏玩家
function C:hide()
    self.node:setVisible(false)
end

--清理显示
function C:clean()
    self.winFramePar:setVisible(false)
    self.resultNode:setVisible(false)
end

--设置金币
function C:setMoney(money)
    if self.playerInfo then
        self.playerInfo["money"] = money
    end
    if self.creditLabel then
        local moneyStr = utils:moneyString(self.playerInfo["money"])
        self.creditLabel:setString(moneyStr)
    end
end

--甩头
function C:shakeHead(playSound)

    if not self.isAction then
        self.isAction = true

        if self.headNode then
            local moveGap = 0

            if self.seat <= 3 or self.seat == 0 then
                moveGap = 20
            else
                moveGap = -20
            end

            if playSound then
                PLAY_SOUND(ON_BET_SOUND)
            end
            
            local move1 = CCMoveTo:create(0.04,cc.p(self.headPos.x + moveGap, self.headPos.y))
            local move2 = CCMoveTo:create(0.04,self.headPos)
            local delay = CCDelayTime:create(0.02)
            local callFun = CCCallFunc:create(function ()
                self.isAction = false
            end)

            self.headNode:runAction(transition.sequence({move1,move2,delay,callFun}))
        end
    end
end

--显示详细信息
function C:showDetailInfo()
    if self.playerInfo == nil then return end
    if self.seat == 0 then return end

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

    local offsetX = display.width-1136
    local localPos = cc.p(273-offsetX,50)
    if self.seat > 3 then
        localPos = cc.p(-168-offsetX,50)
    end

    local worldPos = self.node:convertToWorldSpace(localPos)
    local localPos = self.globalEffectNode:convertToWorldSpace(worldPos)
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


function C:playResultEffect(money)
    if money > 0 then
        self.winFramePar:setVisible(true)
        self.winFramePar:start()
        self.winStarPar:start()
        self.winImg:setVisible(true)
        self.winLabel:setString("+"..utils:moneyString(money,2).."元")
        self.loseImg:setVisible(false)
    else
        self.winFramePar:setVisible(false)
        self.winFramePar:stop()
        self.winStarPar:stop()
        self.winFramePar:resetSystem()
        self.winStarPar:resetSystem()
        self.loseImg:setVisible(true)
        self.loseLabel:setString(utils:moneyString(money,2).."元")
        self.winImg:setVisible(false)
    end

    self.resultNode:setOpacity(0)
    self.resultNode:setVisible(true)
    self.resultNode:setPosition(self.resultPos)
    local move = CCMoveTo:create(0.3, cc.p(self.resultPos.x, self.resultPos.y + 30))
    local fadeIn = CCFadeIn:create(0.3)
    local delay = CCDelayTime:create(2)
    local fadeOut = CCFadeOut:create(0.5)
    local callFun = CCCallFunc:create(function ()
	    self.resultNode:setVisible(false)
	end)
    local spawn = transition.spawn({move,fadeIn})
    local seq = transition.sequence({spawn,delay,fadeOut,callFun})
    self.resultNode:runAction(seq)
end


return C
