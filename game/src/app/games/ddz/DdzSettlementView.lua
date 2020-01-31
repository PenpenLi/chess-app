local PokerClass = import(".DdzPokerView")
local C = class("DdzPlayerView",ViewBaseClass)
local scheduler = cc.Director:getInstance():getScheduler()

local VIEW_POSX = 10 + (IS_IPHONEX and 100 or 0)
local VIEW_POSY = 50;

local ALERT_SOUND = GAME_DDZ_SOUND_RES.."s_alert.mp3"
local COUNT_DOWN_SOUND = GAME_DDZ_SOUND_RES.."s_countdown.mp3"

C.BINDING = 
{
    lordLoseImg = {path="role_node.dizhu_lose_img"},
    lordWinImg = {path="role_node.dizhu_win_img"},
    farmerLoseImg = {path="role_node.nongmin_lose_img"},
    farmerWinImg = {path="role_node.nongmin_win_img"},

    winEffect = {path="effect_node.win"},
    loseEffect = {path="effect_node.lose"},
    winBgImg = {path="settlement_node.win_img"},
    winImg = {path="settlement_node.win_img.text_img"},
    loseBgImg = {path="settlement_node.lose_img"},
    loseImg = {path="settlement_node.lose_img.text_img"},

    continueBtn = {path="settlement_node.continue_btn",events={{event="click",method="continue"}}},
    exitBtn = {path="settlement_node.leave_btn",events={{event="click",method="exit"}}},
    detailBtn = {path="row1_node.details_btn",events={{event="click",method="showDetail"}}},

    countDownLabel = {path="settlement_node.continue_btn.continue_num"},

    row1lordImg = {path="row1_node.dizhu_img"},
    row1NameLabel = {path="row1_node.name_label"},
    row1DifenLabel = {path="row1_node.difen_label"},
    row1BeishuLabel = {path="row1_node.beishu_label"},
    row1JinbiLabel = {path="row1_node.jinbi_label"},

    row2lordImg = {path="row2_node.dizhu_img"},
    row2NameLabel = {path="row2_node.name_label"},
    row2DifenLabel = {path="row2_node.difen_label"},
    row2BeishuLabel = {path="row2_node.beishu_label"},
    row2JinbiLabel = {path="row2_node.jinbi_label"},

    row3lordImg = {path="row3_node.dizhu_img"},
    row3NameLabel = {path="row3_node.name_label"},
    row3DifenLabel = {path="row3_node.difen_label"},
    row3BeishuLabel = {path="row3_node.beishu_label"},
    row3JinbiLabel = {path="row3_node.jinbi_label"},

    detailFarmerNode = {path="nongmin_details_node"},
    detailFarmerQiangdizhuLabel = {path="nongmin_details_node.qiangdizhu_label"},
    detailFarmerZhadanLabel = {path="nongmin_details_node.zhadan_label"},
    detailFarmerGonggongbeishuLabel = {path="nongmin_details_node.gonggong_beishu_label"},
    detailFarmerNongminjiabeiLabel = {path="nongmin_details_node.nongmin_jiabei_label"},
    detailFarmerZongbeishuLabel = {path="nongmin_details_node.zongbeishu_label"},
    detailFarmerNameLabel = {path="nongmin_details_node.name_label"},

    detailLordNode = {path="dizhu_details_node"},
    detailLordQiangdizhuLabel = {path="dizhu_details_node.qiangdizhu_label"},
    detailLordZhadanLabel = {path="dizhu_details_node.zhadan_label"},
    detailLordChuntianLabel = {path="dizhu_details_node.chuntian_label"},
    detailLordZongbeishuLabel = {path="dizhu_details_node.zongbeishu_label"},
    detailLordNameLabel = {path="dizhu_details_node.name_label"},
}

C.info = nil
C.rows = nil
C.detailNode = nil

function C:ctor(node)
    C.super.ctor(self,node)
end

function C:onCreate()
    self.rows = {}
    for i=1,3 do
        self.rows[i] = {}
        self.rows[i].lordImg = self[string.format("row%dlordImg",i)]
        self.rows[i].nameLabel = self[string.format("row%dNameLabel",i)]
        self.rows[i].difenLabel = self[string.format("row%dDifenLabel",i)]
        self.rows[i].beishuLabel = self[string.format("row%dBeishuLabel",i)]
        self.rows[i].jinbiLabel = self[string.format("row%dJinbiLabel",i)]
    end
end

--显示玩家
function C:show(info)
    self.info = info
    self.lordLoseImg:setVisible(false)
    self.lordWinImg:setVisible(false)
    self.farmerLoseImg:setVisible(false)
    self.farmerWinImg:setVisible(false)

    self.winEffect:setVisible(false)
    self.winBgImg:setVisible(false)
    self.winImg:setVisible(false)

    self.loseEffect:setVisible(false)
    self.loseBgImg:setVisible(false)
    self.loseImg:setVisible(false)

    if info.win then
        if info.isLord then
            self.lordWinImg:setVisible(true)
        else
            self.farmerWinImg:setVisible(true)
        end

        self.winEffect:setVisible(true)
        self.winBgImg:setVisible(true)
        self.winImg:setVisible(true)

    else
        if info.isLord then
            self.lordLoseImg:setVisible(true)
        else
            self.farmerLoseImg:setVisible(true)
        end

        self.loseEffect:setVisible(true)
        self.loseBgImg:setVisible(true)
        self.loseImg:setVisible(true)
    end

    self:countDown(10,handler(self,self.exit))

    for i=1,3 do
        self.rows[i].lordImg:setVisible(info.rows[i].dizhu)
        self.rows[i].nameLabel:setString(info.rows[i].name)
        self.rows[i].difenLabel:setString(info.rows[i].difen)
        self.rows[i].beishuLabel:setString(info.rows[i].beishu)
        self.rows[i].jinbiLabel:setString(utils:moneyString(info.rows[i].win,1))
    end

    self.detailLordNode:setVisible(false)
    self.detailFarmerNode:setVisible(false)

    if info.isLord then
        self.detailNode = self.detailLordNode
        self.detailLordQiangdizhuLabel:setString("×"..info.detail.jiaofen)
        self.detailLordZhadanLabel:setString("×"..info.detail.zhadan)
        self.detailLordChuntianLabel:setString("×"..info.detail.chuntian)
        self.detailLordZongbeishuLabel:setString("×"..info.detail.totalAdd)
        self.detailLordNameLabel:setString(info.detail.name)
    else
        self.detailNode = self.detailFarmerNode
        self.detailFarmerQiangdizhuLabel:setString("×"..info.detail.jiaofen)
        self.detailFarmerZhadanLabel:setString("×"..info.detail.zhadan)
        self.detailFarmerGonggongbeishuLabel:setString("×"..info.detail.commonAdd)
        self.detailFarmerNongminjiabeiLabel:setString("×"..info.detail.farmerAdd)
        self.detailFarmerZongbeishuLabel:setString("×"..info.detail.totalAdd)
        self.detailFarmerNameLabel:setString(info.detail.name)
    end

    self.node:setVisible(true)
end

--隐藏
function C:hide()
    self.node:setVisible(false)
    self:removeClockHandler();
end

function C:showDetail(event)
    if self.detailAnimating and self.detailAnimating == true then
        return
    end

    self.detailAnimating = true

    if self.detailNode:isVisible() then
        transition.scaleTo(self.detailNode,{time = 0.12,scale = 0,onComplete = function()self.detailNode:setVisible(false) self.detailAnimating = false end})
	    transition.fadeTo(self.detailNode,{time = 0.12,opacity = 0})
    else
        self.detailNode:setVisible(true)
	    transition.scaleTo(self.detailNode,{time = 0.2,easing = {"BACKOUT",2},scale = 1,onComplete = function() self.detailAnimating = false end})
	    transition.fadeTo(self.detailNode,{time = 0.2,opacity = 255})
    end
end

function C:continue(event)
    self:removeClockHandler()
    self.info.continueHandler()
end

function C:exit(event)
    self:removeClockHandler()
    self.info.exitHandler()
end

function C:countDown(time,callback)
    self:removeClockHandler();
    local leftTime = time;
    self.countDownLabel:setString(tostring(leftTime))
    self.countDownHandler = scheduler:scheduleScriptFunc(function()
        leftTime = leftTime - 1;
		if leftTime <= 0 then
			if callback then
				callback()
			end
		else 
			self.countDownLabel:setString(tostring(leftTime))
		end 
	end, 1,false)
end

function C:removeClockHandler()
	if self.countDownHandler then 
		scheduler:unscheduleScriptEntry(self.countDownHandler)
		self.countDownHandler = nil
	end
end

return C
