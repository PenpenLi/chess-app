local C = class("BrnnResultClass",ViewBaseClass)

C.BINDING = {
	qinglongWin = {path="qinglong_win"},
	baihuWin = {path="baihu_win"},
	zhuqueWin = {path="zhuque_win"},
	xuanwuWin = {path="xuanwu_win"},
}

function C:ctor( node )
	for i=1,9 do
		local key = string.format("panel%d",i)
		local path = string.format("panel_%d",i)
		self.BINDING[key] = {path=path}
	end
	C.super.ctor(self,node)
end

function C:onCreate()
	C.super.onCreate(self)
	self.panelArr = {}
	for i=1,9 do
		local key = string.format("panel%d",i)
		self[key]:getChildByName("win_img"):setVisible(false)
		self[key]:getChildByName("lose_img"):setVisible(false)
	end
	self.qinglongWin:setVisible(false)
	self.baihuWin:setVisible(false)
	self.zhuqueWin:setVisible(false)
	self.xuanwuWin:setVisible(false)
end

function C:clean( )
	self.qinglongWin:setVisible(false)
	self.baihuWin:setVisible(false)
	self.zhuqueWin:setVisible(false)
	self.xuanwuWin:setVisible(false)
end

function C:handleChangedMoney( moneyArr )
	for k,v in pairs(moneyArr) do
		self:showChangedMoney(k,v)
	end
end

--1=神算子 2=富豪1 3=富豪2 4=富豪3 5=富豪4 6=富豪5 7=自己 8=在线玩家 9=庄家
function C:showChangedMoney( seatId, money )
	local key = string.format("panel%d",seatId)
	local panel = self[key]
	local node = nil
	local text = ""
	if money > 0 then
		node = panel:getChildByName("win_img")
		text = "+"..utils:moneyString(money,2).."元"
	else
		node = panel:getChildByName("lose_img")
		text = utils:moneyString(money,2).."元"
	end
	self:showChangedMoneyAni(node,text)
	if money > 0 and seatId ~= 8 then
		self:playWinnerAnimation(seatId)
	end
end

function C:showChangedMoneyAni( bg, str )
	bg:setVisible(true)
	local label = bg:getChildByName("label")
	label:setString(str)
	local width = label:getContentSize().width
	local scale = 124/width
	if scale > 1 then
		scale = 1
	end
	label:setScale(scale)
	local x = bg:getPositionX()
	bg:setPosition(cc.p(x,50))
	bg:setOpacity(0)
	local array = {}
	array[1] = cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(x, 90)))
	array[2] = cc.DelayTime:create(3)
	array[3] = cc.FadeOut:create(0.5)
	array[4] = cc.CallFunc:create(function()
		bg:setVisible(false)
	end)
	bg:runAction(cc.Sequence:create(array))
end

function C:playWinnerAnimation( seatId )
	local key = string.format("panel%d",seatId)
	local node = self[key]
	local frame = cc.ParticleSystemQuad:create(GAME_BRNN_ANIMATION_RES.."particle/frame.plist")
    frame:setAutoRemoveOnFinish(true)
    frame:setAnchorPoint(cc.p(0.5, 0.5))
    frame:setPosition(cc.p(50,50))
    node:addChild(frame)
    frame:setLocalZOrder(-1)

    local star = cc.ParticleSystemQuad:create(GAME_BRNN_ANIMATION_RES.."particle/star.plist")
    star:setAutoRemoveOnFinish(true)
    star:setAnchorPoint(cc.p(0.5, 0.5))
    star:setPosition(cc.p(50,50))
    node:addChild(star)
    star:setLocalZOrder(-1)
end

--area 1=青龙 2=白虎 3=朱雀 4=玄武
function C:showVictory( area )
	local win = nil
	if area == 1 then
		win = self.qinglongWin
	elseif area == 2 then
		win = self.baihuWin
	elseif area == 3 then
		win = self.zhuqueWin
	elseif area == 4 then
		win = self.xuanwuWin
	end
	if win == nil then
		return
	end
	win:setScale(2)
	local array = {}
	array[#array+1] = cc.DelayTime:create(0.3)
	array[#array+1] = cc.CallFunc:create(function()
		win:setVisible(true)
		transition.scaleTo(win,{time = 0.12,easing = {"BACKIN",2},scale = 1})
	end)
	win:runAction(cc.Sequence:create(array))
end

return C