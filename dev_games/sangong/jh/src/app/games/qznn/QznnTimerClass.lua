QznnTimerClassTypeGameStart = 1  --游戏即将开始
QznnTimerClassTypeQiangZhuang = 2  --请抢庄
QznnTimerClassTypeQiangZhuang2 = 3  --抢庄中
QznnTimerClassTypeXiaZhu = 4  --请投注
QznnTimerClassTypeXiaZhu2 = 5  --等待其他玩家投注
QznnTimerClassTypeXiaZhu3 = 6  --投注中
QznnTimerClassTypeTanpai = 7  --请摊牌
QznnTimerClassTypeTanpai2 = 8  --摊牌中

local C = class("QznnTimerClass",ViewBaseClass)

C.BINDING = {
    startTimer = {path="start_timer"},
    qiangTimer = {path="qiang_timer"},
    qiangTimer2 = {path="qiang_timer2"},
    betTimer = {path="bet_timer"},
    betTimer2 = {path="bet_timer2"},
    betTimer3 = {path="bet_timer3"},
    tanpaiTimer = {path="tan_timer"},
    tanpaiTimer2 = {path="tan_timer2"},
}

C.timerLabel = nil
C.timecount = 0
C.callback = nil

function C:onCreate()
    self:hide()
end

function C:setVisible( visible )
    self.node:setVisible(visible)
end

function C:show( time, ctype, callback )
    self:hide()
    self.timecount = time
    self.callback = callback
    if ctype == QznnTimerClassTypeGameStart then
        self.timerLabel = self.startTimer:getChildByName("label")
        self.startTimer:setVisible(true)
    elseif ctype == QznnTimerClassTypeQiangZhuang then
        self.timerLabel = self.qiangTimer:getChildByName("label")
        self.qiangTimer:setVisible(true)
    elseif ctype == QznnTimerClassTypeQiangZhuang2 then
        self.timerLabel = self.qiangTimer2:getChildByName("label")
        self.qiangTimer2:setVisible(true)
    elseif ctype == QznnTimerClassTypeXiaZhu then
        self.timerLabel = self.betTimer:getChildByName("label")
        self.betTimer:setVisible(true)
    elseif ctype == QznnTimerClassTypeXiaZhu2 then
        self.timerLabel = self.betTimer2:getChildByName("label")
        self.betTimer2:setVisible(true)
    elseif ctype == QznnTimerClassTypeXiaZhu3 then
        self.timerLabel = self.betTimer3:getChildByName("label")
        self.betTimer3:setVisible(true)
    elseif ctype == QznnTimerClassTypeTanpai then
        self.timerLabel = self.tanpaiTimer:getChildByName("label")
        self.tanpaiTimer:setVisible(true)
    elseif ctype == QznnTimerClassTypeTanpai2 then
        self.timerLabel = self.tanpaiTimer2:getChildByName("label")
        self.tanpaiTimer2:setVisible(true)
    end
    if self.timerLabel == nil then
        if self.callback then
            self.callback(true,0)
            self.callback = nil
        end
        return
    end
    self.node:setVisible(true)
    self.timerLabel:setString(string.format("%d",self.timecount))
    local playtimer = function()
        self.timecount = self.timecount - 1
        self.timerLabel:setString(string.format("%d",self.timecount))
        if self.timecount <= 0 then
            if self.callback then
                self.callback(true,0)
                self.callback = nil
            end
            self:hide()
        else
            if self.callback then
                self:callback(false,self.timecount)
            end
        end
    end
    utils:createTimer("qznn.QznnTimerClass",1,playtimer)
end

function C:hide()
    utils:removeTimer("qznn.QznnTimerClass")
    if self.callback then
        self.callback(true,0)
    end
    self.startTimer:setVisible(false)
    self.qiangTimer:setVisible(false)
    self.qiangTimer2:setVisible(false)
    self.betTimer:setVisible(false)
    self.betTimer2:setVisible(false)
    self.betTimer3:setVisible(false)
    self.tanpaiTimer:setVisible(false)
    self.tanpaiTimer2:setVisible(false)
    self.timerLabel = nil
    self.timecount = 0
    self.callback = nil
    self.node:setVisible(false)
end

return C