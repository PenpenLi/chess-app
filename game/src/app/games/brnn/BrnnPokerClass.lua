local C = class("BrnnPokerClass",ViewBaseClass)

C.BINDING = {
    frontground = {path="frontground"},
    numberImg = {path="frontground.number"},
    smallColorImg = {path="frontground.small_color"},
    bigColorImg = {path="frontground.big_color"},
    background = {path="background"},
}

function C:setPokerData( pcolor, pvalue )
    local numberStr = ""
    local smallColorStr = ""
    local colorStr = ""
    local colorSize = cc.size(78,82)

    if pcolor == 6 then   --黑桃 6
        smallColorStr = "card_spade_s.png"
        colorStr = "card_spade.png"
        numberStr = "b"
        colorSize = cc.size(78,82)
    elseif pcolor == 3 then --方块 3
        smallColorStr = "card_diamond_s.png"
        colorStr = "card_diamond.png"
        numberStr = "r"
        colorSize = cc.size(80,80)
    elseif pcolor == 4 then    --梅花 4
        smallColorStr = "card_club_s.png"
        colorStr = "card_club.png"
        numberStr = "b"
        colorSize = cc.size(76,80)
    elseif pcolor == 5 then   --红桃 5
        smallColorStr = "card_heart_s.png"
        colorStr = "card_heart.png"
        numberStr = "r"
        colorSize = cc.size(80,72)
    end

    numberStr = numberStr..tostring(pvalue)..".png"

    self.numberImg:loadTexture(numberStr,1)
    self.smallColorImg:loadTexture(smallColorStr,1)
    self.bigColorImg:loadTexture(colorStr,1)
    self.bigColorImg:setContentSize(colorSize)
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