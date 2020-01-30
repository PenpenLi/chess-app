local C = class("QznnPokerClass",ViewBaseClass)

C.BINDING = {
    frontground = {path="frontground"},
    numberImg = {path="frontground.number"},
    smallColorImg = {path="frontground.small_color"},
    bigColorImg = {path="frontground.big_color"},
    background = {path="background"},
}

function C:setVisible( visible )
    self.node:setVisible(visible)
end

function C:setPokerData( pcolor, pvalue )
    local numberStr = ""
    local smallColorStr = ""
    local colorStr = ""
    local colorSize = cc.size(78,82)

    if pcolor == 6 then   --黑桃 6
        smallColorStr = "shape_spade_s.png"
        colorStr = "shape_spade.png"
        numberStr = "num_black_"
        colorSize = cc.size(78,82)
    elseif pcolor == 3 then --方块 3
        smallColorStr = "shape_diamond_s.png"
        colorStr = "shape_diamond.png"
        numberStr = "num_red_"
        colorSize = cc.size(80,80)
    elseif pcolor == 4 then    --梅花 4
        smallColorStr = "shape_club_s.png"
        colorStr = "shape_club.png"
        numberStr = "num_black_"
        colorSize = cc.size(76,80)
    elseif pcolor == 5 then   --红桃 5
        smallColorStr = "shape_heart_s.png"
        colorStr = "shape_heart.png"
        numberStr = "num_red_"
        colorSize = cc.size(80,72)
    end

    numberStr = numberStr..tostring(pvalue)..".png"

    self.numberImg:loadTexture(numberStr,1)
    self.smallColorImg:loadTexture(smallColorStr,1)
    self.bigColorImg:loadTexture(colorStr,1)
    self.bigColorImg:setContentSize(colorSize)
end

function C:createOverAllCard( pcolor, pvalue )
    local pokerNumStr = ""
    local colorTypeStr = ""
    if pcolor == 6 then   --黑桃
        colorTypeStr = "3_"
    elseif pcolor == 3 then --方块 3
        colorTypeStr = "0_"
    elseif pcolor == 4 then    --梅花
        colorTypeStr = "1_"
    elseif pcolor == 5 then   --红桃
        colorTypeStr = "2_"
    end
    pokerNumStr = "card"..colorTypeStr..tostring(pvalue)..".png"
    --printInfo(pokerNumStr)
    self.frontground:loadTexture(pokerNumStr, 1)
    self.numberImg:setVisible(false)
    self.smallColorImg:setVisible(false)
    self.bigColorImg:setVisible(false)

    self.frontground:setVisible(true)
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