local C = class("SanGongPokerClass",ViewBaseClass)

C.BINDING = {
    frontground = {path="frontground"},
    background = {path="background"},
}

function C:setVisible( visible )
    self.node:setVisible(visible)
end

function C:setPokerData( pcolor, pvalue )
    local resname = "bg_front.png"
    local colorStr = ""
    local numberStr = ""

    if 1 <= pvalue and pvalue <=13 then
        numberStr = tostring(pvalue)..".png"
    end

    if pcolor == 6 then   --黑桃
        colorStr = "card3_"
    elseif pcolor == 3 then --方块 3
        colorStr = "card0_"
    elseif pcolor == 4 then    --梅花
        colorStr = "card1_"
    elseif pcolor == 5 then   --红桃
        colorStr = "card2_"
    end

    if colorStr ~= "" and numberStr ~= "" then
        resname = colorStr..numberStr
    end

    self.frontground:loadTexture(resname,1)
end

function C:backgroundPoker( animation )
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

return C