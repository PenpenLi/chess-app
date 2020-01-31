local C = class("ZjhPokerClass",ViewBaseClass)

C.BINDING = {
    frontground = {path="frontground"},
    background = {path="background"},
}

function C:setPokerData( pcolor, pvalue )
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
    else
        --所有异常以1输出
        numberStr="1.png"
    end
    if pcolor == 6 then   --黑桃 6
        colorStr = "lord_card_spade_"
    elseif pcolor == 3 then --方块 3
        colorStr = "lord_card_diamond_"
    elseif pcolor == 4 then    --梅花 4
        colorStr = "lord_card_club_"
    elseif pcolor == 5 then   --红桃 5
        colorStr = "lord_card_heart_"
    else
        --所有异常以6输出
        numberStr="lord_card_spade_"
    end
    if colorStr ~= "" and numberStr ~= "" then
        resname = colorStr..numberStr
    end
    self.frontground:loadTexture(resname,1)
end

function C:backgroundPoker( animation )
    self.background:loadTexture("lord_card_bg.png",1)
    if animation == true then
        self.frontground:stopAllActions()
        self.background:stopAllActions()
        local duration = 0
        local backCamera = cc.OrbitCamera:create( duration, 1, 0, -270, -90, 0, 0 )
        local backSeq = cc.Sequence:create( cc.DelayTime:create( duration ), cc.Show:create(), backCamera )
        self.background:runAction( backSeq )
        local frontCamera = cc.OrbitCamera:create( duration, 1, 0, 0, -90, 0, 0 )
        local frontSeq = cc.Sequence:create( frontCamera, cc.Hide:create(), cc.DelayTime:create( duration ) )
        self.frontground:runAction( frontSeq )
    else
        self.frontground:setVisible(false)
        self.background:setVisible(true)
    end
end

function C:frontgroundPoker( animation )
    if animation == true then
        self.frontground:stopAllActions()
        self.background:stopAllActions()
        local duration = 0.1
        --//第一个参数是旋转的时间，第二个参数是起始半径，第三个参数半径差，第四个参数是起始Z角，第五个参数是旋转Z角差，第六个参数是起始X角，最后一个参数旋转X角差
        local backCamera = cc.OrbitCamera:create( duration, 1, 0, 0, 90, 0, 0 )
        local backSeq = cc.Sequence:create( cc.Show:create(), backCamera, cc.Hide:create() )
        self.background:runAction( backSeq )
        local frontCamera = cc.OrbitCamera:create( duration, 1, 0, 270, 90, 0, 0 )
        local frontSeq = cc.Sequence:create( cc.DelayTime:create( duration ), cc.Show:create(), frontCamera )
        self.frontground:runAction( frontSeq )
    else
        self.frontground:setVisible(true)
        self.background:setVisible(false)
    end
end

function C:graygroundPoker()
    self.background:loadTexture("lord_card_s_bg.png",1)
end

return C