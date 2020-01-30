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
    nameLabel = {path="head_con.name_label"},
    resultNode = {path="result_con"},
    winImg = {path="result_con.win_img"},
    winLabel = {path="result_con.win_img.label"},
    loseImg = {path="result_con.lose_img"},
    loseLabel = {path="result_con.lose_img.label"},
    head_none={path="head_none"},
}

C.seat = 0
C.resultPos = nil
C.headPos = nil

function C:ctor(node,seat,globalEffectNode)
    self.seat = seat
    self.globalEffectNode = globalEffectNode
    --if self.seat == 0 or self.seat == 1 or self.seat == 6 then
        self.BINDING.creditLabel = {path="head_con.credit_label"}
    --end
    C.super.ctor(self,node)
end

function C:onCreate()
    self.resultPos = cc.p(self.resultNode:getPosition())
    self.headPos = cc.p(self.headNode:getPosition())
    local strAnimName= GAME_HHDZ_ANIMATION_RES.."defen/defen"
    self.winEffect = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.winEffect:setAnimation(0,"animation",false)
	self.headImg:addChild( self.winEffect )
    self:clean()
end

--隐藏玩家
function C:hide()
    self.headNode:setVisible(false)
    if self.head_none then
        self.head_none:setVisible(true)
    end
end

--清理显示
function C:clean()
    self.resultNode:setVisible(false)
    self.winEffect:setVisible(false)
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
    --if self.seat == 0 or self.seat == 1 or self.seat == 6 then
        self.creditLabel:setString(utils:moneyString(self.playerInfo["money"]))
    --end
    -- self.frameImg:loadTexture(GET_FRAMEID_RES(self.playerInfo["vipLevel2"]))
    self.headNode:setVisible(true)
    if self.head_none then
        self.head_none:setVisible(false)
    end
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
    local ipLabel = root:getChildByName("ip_label")
    local sexImg=root:getChildByName("sex_img")
    local closeBtn=root:getChildByName("close_btn")
    closeBtn:onClick(function()
        cover:removeFromParent(true)
        panel:removeFromParent(true)
    end)
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
        name = self.playerInfo["playerid"]
    end
    name = utils:nameStandardString(name, 26, 142)
    nameLabel:setString(name)
    --city
    local city = self.playerInfo["city"] or "未知"
    cityLabel:setString(city)
    --money
    local money = self.playerInfo["money"]
    creditLabel:setString(utils:moneyString(money,3))
    --sex
    if self.playerInfo.sex and self.playerInfo.sex >= 0 and self.playerInfo.sex < 2 then
        sexImg:loadTexture(GAME_HHDZ_IMAGES_RES .. "chuangkou/sex_" .. self.playerInfo.sex .. ".png", 1);
    end
    if self.playerInfo.playerid == dataManager.playerId then
        ipLabel:setString(self.playerInfo.ip);
    else
        local ipStr = self:getFormatIp(self.playerInfo.ip);
        ipLabel:setString(ipStr);
    end

     local offsetX = display.width-1136
    -- local localPos = cc.p(273-offsetX,50)
    -- if self.seat > 3 then
    --     localPos = cc.p(-168-offsetX,50)
    -- end
    local localPos=cc.p(display.cx-offsetX/2,display.cy)

    --local worldPos = self.node:convertToWorldSpace(localPos)
    --local localPos = self.globalEffectNode:convertToWorldSpace(worldPos)
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

--获取IP
function C:getFormatIp(ip)
    printInfo(">>>>>>>>>>获取IP>>>>>>>>>"..ip)
    local tempIP = ip;
    local ipLen = string.len(tempIP);
    local curlen = 0;
    local temp = {};
    local isStar = false;
    for i = 1, ipLen do
        if string.sub(tempIP,i, i) == "." then
		    curlen = curlen + 1;
	    end
	    if curlen < 2 then
		    temp[i] = string.sub(tempIP, i, i);
	    else
		    if string.sub(tempIP,i, i) == "." then
			    temp[i] = string.sub(tempIP, i, i);
                isStar = false;
		    else
                if not isStar then
			        temp[i] = "*";
                    isStar = true;
                else
                    temp[i] = "";
                end
		    end
	    end
    end
    return table.concat(temp);
end

function C:playResultEffect(money)
    if money > 0 then
        self.winEffect:setAnimation(0,"animation",false)
        self.winImg:setVisible(true)
        self.winLabel:setString("+"..utils:moneyString(money,2).."元")
        self.loseImg:setVisible(false)
    else
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
