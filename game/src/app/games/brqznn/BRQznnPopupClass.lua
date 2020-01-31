local C = class("BRQznnPopupClass",ViewBaseClass)
local PLAYER_INFO_CSB = "games/brqznn/PlayerInfo.csb"
C.posArr = {cc.p(168,200),cc.p(900,210),cc.p(900,345 ),cc.p(910,510),
cc.p(568,530),cc.p(294,510),cc.p(230,345),cc.p(230,210)}

function C:show( info, seatId )
	if info == nil then
		return
	end
 
	if seatId < 1 or seatId > 8 then
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
    -- local vipImg = root:getChildByName("vip_img")
    -- local vipLabel = vipImg:getChildByName("label")
    --local idLabel = root:getChildByName("id_label")
    local nameLabel = root:getChildByName("name_label")
    local cityLabel = root:getChildByName("city_label")
    local creditLabel = root:getChildByName("credit_fnt")
    --头像
    local headId = info["headid"]
    local headUrl = info["wxheadurl"]
    SET_HEAD_IMG(headImg,headId,headUrl)
    --头像框
    --vip
    --vipImg:setVisible(false)
    --id
    --idLabel:setString(tostring(info["playerid"]))
    --name
    dump(info,"玩家信息")
    local name = info["nickname"]
    if name == nil or name == "" then
        name = tostring(info["playerid"])
        nameLabel:setString(name)
    elseif tonumber(name) then
        nameLabel:setString(name)
    else
        nameLabel:setString(self:utf8sub(name,1,7))
    end
    --city
    local city = info["city"] or "中国"
    cityLabel:setString(city)
    --money
    local money = info["money"]
    creditLabel:setString(utils:moneyString(money,3))

    local pos = self.posArr[seatId]
    panel:setPosition(pos)

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

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
function C:chsize(char)
	if not char then
		print("not char")
		return 0
	elseif char > 240 then
		return 4
	elseif char > 225 then
		return 3
	elseif char > 192 then
		return 2
	else
		return 1
	end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function C:utf8len(str)
	local len = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + self:chsize(char)
		len = len +1
	end
	return len
end

-- 截取utf8 字符串
-- str:			要截取的字符串
-- startChar:	开始字符下标,从1开始
-- numChars:	要截取的字符长度
function C:utf8sub(str, startChar, numChars)
	local startIndex = 1
	while startChar > 1 do
		local char = string.byte(str, startIndex)
		startIndex = startIndex + self:chsize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex
	while numChars > 0 and currentIndex <= string.len(str) do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + self:chsize(char)
		numChars = numChars -1
    end
	return string.sub(str,startIndex,currentIndex - 1)
end

return C