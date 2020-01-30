QznnTimerClassTypeGameStart = 1  --游戏即将开始
QznnTimerClassTypeQiangZhuang = 2  --请抢庄
QznnTimerClassTypeQiangZhuang2 = 3  --抢庄中
QznnTimerClassTypeQiangZhuang3 = 4  --等待其他玩家抢庄
QznnTimerClassTypeXiaZhu = 5  --请投注
QznnTimerClassTypeXiaZhu2 = 6  --等待其他玩家投注
QznnTimerClassTypeXiaZhu3 = 7  --投注中
QznnTimerClassTypeTanpai = 8  --请摊牌
QznnTimerClassTypeTanpai2 = 9  --摊牌中
QznnTimerClassTypeTanpai3 = 10  --等待其他玩家摊牌

local C = class("QznnTimerClass",ViewBaseClass)

C.BINDING = {
    timerNode={path="timer"},
    timerImg1={path="timer.time1_img"},
    timerImg2={path="timer.time2_img"},
    tipNode={path="tip"},
    tipdi_img={path="tip.di_img"},
    timerLabel={path="tip.time_label"},
    decLabel={path="tip.dec_label"},
}

C.timeType=1
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
        --游戏即将开始 3
        self.timerNode:setVisible(true)
        self.tipNode:setVisible(false)
        self.timeType=1
    elseif ctype == QznnTimerClassTypeQiangZhuang then
        --请抢庄
        self.timerNode:setVisible(true)
        self.tipNode:setVisible(false)
        self.timeType=1
    elseif ctype == QznnTimerClassTypeQiangZhuang2 then
        --抢庄中 3
        self.timerNode:setVisible(false)
        self.tipNode:setVisible(true)
        self.decLabel:setString("抢庄阶段:")
        self.tipdi_img:setContentSize(cc.size(166,36))
        self.timerLabel:setPositionX(50)
        self.timeType=2
    elseif ctype == QznnTimerClassTypeXiaZhu then
        --请投注
        self.timerNode:setVisible(true)
        self.tipNode:setVisible(false)
        self.timeType=1
    elseif ctype == QznnTimerClassTypeXiaZhu2 then
        --等待其他玩家投注
        self.timerNode:setVisible(false)
        self.tipNode:setVisible(true)
        self.decLabel:setString("请等待其他玩家下注:")
        self.tipdi_img:setContentSize(cc.size(280,41))
        self.timerLabel:setPositionX(112)
        self.timeType=2
    elseif ctype == QznnTimerClassTypeXiaZhu3 then
        --投注中 5
        self.timerNode:setVisible(false)
        self.tipNode:setVisible(true)
        self.decLabel:setString("下注阶段:")
        self.tipdi_img:setContentSize(cc.size(166,36))
        self.timerLabel:setPositionX(50)
        self.timeType=2
    elseif ctype == QznnTimerClassTypeTanpai then
        --请摊牌
        self.timerNode:setVisible(true)
        self.tipNode:setVisible(false)
        self.timeType=1
    elseif ctype == QznnTimerClassTypeTanpai2 then
        --摊牌中  7
        self.timerNode:setVisible(false)
        self.tipNode:setVisible(true)
        self.decLabel:setString("拼十阶段:")
        self.tipdi_img:setContentSize(cc.size(166,36))
        self.timerLabel:setPositionX(50)
        self.timeType=2
    end
    if self.timerLabel == nil then
        if self.callback then
            self.callback(true,0)
            self.callback = nil
        end
        return
    end
    self.node:setVisible(true)
    self:showCountDown(string.format("%d",self.timecount))
    local playtimer = function()
        self.timecount = self.timecount - 1
        self:showCountDown(string.format("%d",self.timecount))
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

function C:showCountDown(time)
    time=tonumber(time)
    if self.timeType==1 then
        local t1=time%10
        local t2=(time-t1)/10
        self.timerImg1:loadTexture(GAME_QZNN_IMAGES_RES.."timer/timer_"..t2..".png")
        self.timerImg2:loadTexture(GAME_QZNN_IMAGES_RES.."timer/timer_"..t1..".png")
    else
        self.timerLabel:setString(time)
    end
end

function C:onChangeState(state)
    self.timeType=2
    self.tipdi_img:setContentSize(cc.size(280,41))
    self.timerLabel:setPositionX(112)
    self.timerLabel:setString(string.format("%d",self.timecount))
    self.timerNode:setVisible(false)
    self.tipNode:setVisible(true)
    if state==QznnTimerClassTypeQiangZhuang3 then
        self.decLabel:setString("请等待其他玩家抢庄:")
    elseif state==QznnTimerClassTypeXiaZhu2 then
        self.decLabel:setString("请等待其他玩家下注:")
    elseif state==QznnTimerClassTypeTanpai3 then
        self.decLabel:setString("有人正在苦思冥想中:")
    end
end

function C:hide()
    utils:removeTimer("qznn.QznnTimerClass")
    if self.callback then
        self.callback(true,0)
    end
    self.timecount = 0
    self.callback = nil
    self.node:setVisible(false)
end

return C