local C = class("BrnnPopupClass",ViewBaseClass)

C.BINDING = {
	popupImg = {path="popup_img"},
	headImg = {path="popup_img.head_img"},
	frameImg = {path="popup_img.frame_img"},
	accountLabel = {path="popup_img.account_label"},
	cityLabel = {path="popup_img.city_label"},
	goldLabel = {path="popup_img.gold_label"},
}

local PLAYER_INFO_CSB = "games/brnn/PlayerInfo.csb"

C.PLAYER_POS = {
	[1] = cc.p(836,486),
	[2] = cc.p(300,486),
	[3] = cc.p(300,296),
	[4] = cc.p(300,176),
	[5] = cc.p(836,296),
	[6] = cc.p(836,176),
	[7] = cc.p(300,100),
	[8] = cc.p(836,100),
	[9] = cc.p(434,430),
}

function C:show( info, seatId )
	if info == nil then
		return
	end
	if seatId < 0 or seatId > 9 then
		return
	end

	--点击关闭
    local cover = ccui.Layout:create()
    cover:setTouchEnabled(true)
    cover:setContentSize(cc.size(display.width, display.height))
    cover:setAnchorPoint(cc.p(0, 0))
    cover:setPosition(0,0)
    cover:addTo(self.node)

    local panel = cc.CSLoader:createNode(PLAYER_INFO_CSB)
    panel:addTo(self.node)

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
    local headId = info["headid"]
    local headUrl = info["wxheadurl"]
    SET_HEAD_IMG(headImg,headId,headUrl)
    --头像框
    --vip
    vipImg:setVisible(false)
    --id
    idLabel:setString(tostring(info["playerid"]))
    --name
    local name = info["nickname"]
    if name == nil or name == "" then
        name = tostring(info["playerid"])
    end
    nameLabel:setString(name)
    --city
    local city = info["city"] or "未知"
    cityLabel:setString(city)
    --money
    local money = info["money"]
    creditLabel:setString(utils:moneyString(money,3))

    local pos = self.PLAYER_POS[seatId]
    panel:setPosition(pos)

    panel:setScale(0.1);
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