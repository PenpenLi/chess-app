local C = class("ZjhHistoryPlayerClass",ViewBaseClass)

C.BINDING = {
	headImg = {path="head_img"},
	reportImg = {path="report_img"},
	winImg = {path="win_img"},
	loseImg = {path="lose_img"},
	idLabel = {path="id_label"},
	poker1 = {path="poker_1"},
	poker2 = {path="poker_2"},
	poker3 = {path="poker_3"},
	typeImg = {path="type_img"},
	winLabel = {path="win_label"},
	loseLabel = {path="lose_label"}
}

C.info = nil
C.reportFlags = false

function C:reloadInfo( info )
	self.info = info
	self:setReportFlags(false)
	--头像
	local headId = self.info["headid"]
	local headUrl = self.info["wxheadurl"]
	SET_HEAD_IMG(self.headImg,headId,headUrl)
	--输赢
	local money = self.info["coinchange"]
	if money > 0 then
		self.winLabel:setString("+"..utils:moneyString(money,3).."元")
		self.winImg:setVisible(true)
		self.winLabel:setVisible(true)
		self.loseImg:setVisible(false)
		self.loseLabel:setVisible(false)
	else
		self.loseLabel:setString(utils:moneyString(money,3).."元")
		self.winImg:setVisible(false)
		self.winLabel:setVisible(false)
		self.loseImg:setVisible(true)
		self.loseLabel:setVisible(true)
	end
	--id
	local playerId = self.info["playerid"]
	self.idLabel:setString(tostring(playerId))
	--poker
	self:setPokerData(self.poker1,self.info["cards"][1].color,self.info["cards"][1].number)
	self:setPokerData(self.poker2,self.info["cards"][2].color,self.info["cards"][2].number)
	self:setPokerData(self.poker3,self.info["cards"][3].color,self.info["cards"][3].number)
	local pokerColor = cc.c3b(191, 191, 191)
	if money > 0 then
		pokerColor = cc.c3b(255, 255, 255)
	end
	self.poker1:setColor(pokerColor)
	self.poker2:setColor(pokerColor)
	self.poker3:setColor(pokerColor)
	--ctype
	local name = ""
	local ctype = self.info["ctype"]
	if ctype == ZJH.POKER_TYPE.SANPAI or ctype == ZJH.POKER_TYPE.SANPAI_A or ctype == ZJH.POKER_TYPE.TESHU then
        name = "shan.png"
    elseif ctype == ZJH.POKER_TYPE.DUIZI then
    	name = "pairs.png"
    elseif ctype == ZJH.POKER_TYPE.SHUNZI then
    	name = "straight.png"
    elseif ctype == ZJH.POKER_TYPE.JINHUA then
    	name = "gold_flower.png"
    elseif ctype == ZJH.POKER_TYPE.SHUNJIN then
    	name = "straight_gold.png"
    elseif ctype == ZJH.POKER_TYPE.BAOZI then
    	name = "panther.png"
    end
    if name ~= "" then
    	self.typeImg:loadTexture(GAME_ZJH_IMAGES_RES..name)
    end
end

function C:setPokerData( poker, pcolor, pvalue )
    if pvalue == 14 then
        pvalue = 1
    end

    local resname = "lord_card_bg.png"
    local colorStr = ""
    local numberStr = ""
    if 1 <= pvalue and pvalue <=10 then
        numberStr = tostring(pvalue)..".png"
    elseif pvalue == 11 then
        numberStr = "j.png"
    elseif pvalue == 12 then
        numberStr = "q.png"
    elseif pvalue == 13 then
        numberStr = "k.png"
    end
    if pcolor == 6 then   --黑桃 6
        colorStr = "lord_card_spade_"
    elseif pcolor == 3 then --方块 3
        colorStr = "lord_card_diamond_"
    elseif pcolor == 4 then    --梅花 4
        colorStr = "lord_card_club_"
    elseif pcolor == 5 then   --红桃 5
        colorStr = "lord_card_heart_"
    end
    if colorStr ~= "" and numberStr ~= "" then
        resname = colorStr..numberStr
    end
    poker:loadTexture(resname,1)
end

function C:setReportFlags( flags )
	self.reportFlags = flags
	self.reportImg:setVisible(flags)
end

return C