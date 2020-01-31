local C = class("JsmjPlayerDetailClass",ViewBaseClass)
local PLAYER_INFO_CSB = "games/jsmj/UserNode.csb"

C.posArr = {cc.p(168,200),cc.p(865,400),cc.p(575,524 ),cc.p(440,524),cc.p(271,400)}

function C:show( info, seatId )
	if info == nil then
		return
	end
 
	if seatId < 1 or seatId > 5 then
		return
	end

    local offsetX = (display.width-1136)/2

    --点击关闭
    local cover = ccui.Layout:create()
    --cover:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    cover:setTouchEnabled(true)
    cover:setContentSize(cc.size(display.width, display.height))
    --cover:setBackGroundColor(cc.c3b(125, 125, 125))
    cover:setAnchorPoint(cc.p(0, 0))
    cover:setPosition(0-offsetX, 0)
    cover:addTo(self.node:getParent():getParent())

    local panel = cc.CSLoader:createNode(PLAYER_INFO_CSB)
    panel:setPosition(0, 0)
    panel:addTo(self.node)

    cover:onClick(function()
        cover:removeFromParent(true)
        panel:removeFromParent(true)
    end)
    
    --绑定数据
    local root = panel:getChildByName("box_img")
    local idLabel = root:getChildByName("Text_id")
    local cityLabel = root:getChildByName("Text_area")
    local creditLabel = root:getChildByName("Text_coin")

    local city = info["city"] or "未知"
    cityLabel:setString(city)
    if info["nickname"] and string.len(info["nickname"]) > 0 then
        idLabel:setString(info["nickname"])
    else
        idLabel:setString(info["playerid"])
    end
    local money = info["money"]
    creditLabel:setString(utils:moneyString(money,3))

    panel:setScale(0.1)
	local seq = transition.sequence({
			CCScaleTo:create(0.1, 1.1),
			CCScaleTo:create(0.1, 1),
			CCDelayTime:create(3),
			CCFadeOut:create(0.1),
			CCCallFunc:create(function ()
                cover:removeFromParent(true)
				panel:removeFromParent(true);
			end)
		})
    panel:runAction(seq)
end

return C