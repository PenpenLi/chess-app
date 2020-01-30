
local C = class("JsmjSettlementView",ViewBaseClass)
local scheduler = cc.Director:getInstance():getScheduler()

C.BINDING = 
{
    winBgImg = {path="win_img"},
    loseBgImg = {path="lose_img"},
    winLabel = {path="Label_win"},
    loseLabel = {path="Label_lose"},
    continueBtn = {path="Button_again",events={{event="click",method="continue"}}},
    exitBtn = {path="Button_exit",events={{event="click",method="exit"}}},

    winHeadImg = {path="head_Win.head_img"},
    winFrameImg = {path="head_Win.frame_img"},

    loseHeadImg = {path="head_Lose.head_img"},
    loseFrameImg = {path="head_Lose.frame_img"},

    countDownLabel = {path="Text_timer"},
}

C.info = nil

function C:ctor(parent, node)
    C.super.ctor(self,node)
    self.parView_ = parent
end

function C:onCreate()
end

--显示玩家
function C:show(info)
    --self.parView_.core:c2sSendGameOver()
    self.info = info
    self.winBgImg:setVisible(true)
    self.loseBgImg:setVisible(false)

    if info.winSeat == 0 then   --流局
        self.winBgImg:loadTexture(GAME_JSMJ_IMAGES_RES .. "jiesuan/liuju_bg.png")
        info.winSeat = info.mySeat
    else
        if info.winSeat == info.mySeat then --胜利
            self.winBgImg:loadTexture(GAME_JSMJ_IMAGES_RES .. "jiesuan/shengli_bg.png")
        else --失败
            self.winBgImg:loadTexture(GAME_JSMJ_IMAGES_RES .. "jiesuan/shibai_bg.png")
        end
    end
    
    for i=1,self.parView_.model.playerCount do
        local playerinfo = nil
        for k,v in pairs(info.players) do
            if i == v.seat then
                playerinfo = v
            end
        end
        local headId = playerinfo.headid
	    local headUrl = playerinfo.wxheadurl
        if i == info.winSeat then
            SET_HEAD_IMG(self.winHeadImg,headId,headUrl)
            if info.lScore == nil or info.lScore[i] == nil then
                self.winLabel:setString(0)
            else
                self.winLabel:setString("+" .. utils:moneyString(info.lScore[i],2))
            end
        else
            SET_HEAD_IMG(self.loseHeadImg,headId,headUrl)
            if info.lScore == nil or info.lScore[i] == nil then
                self.loseLabel:setString(0)
            else
                self.loseLabel:setString(utils:moneyString(info.lScore[i],2))
            end
        end
    end

    self:countDown(10,handler(self,self.exit))

    self.node:setVisible(true)
end

--隐藏
function C:hide()
    self.node:setVisible(false)
    self:removeClockHandler();
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
    self.countDownLabel:setString(tostring(leftTime) .. "s")
    self.countDownHandler = scheduler:scheduleScriptFunc(function()
        leftTime = leftTime - 1;
		if leftTime <= 0 then
			if callback then
				callback()
			end
		else 
			self.countDownLabel:setString(tostring(leftTime) .. "s")
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
