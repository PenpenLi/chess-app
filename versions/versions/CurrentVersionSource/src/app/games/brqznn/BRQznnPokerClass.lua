local C = class("BRQznnPokerClass",ViewBaseClass)

C.BINDING = {
    frontground = {path="frontground"},
    background = {path="background"},
}

C.up=nil

function C:setVisible( visible )
    if visible==false then
        self.up=0
    end
    self.node:setVisible(visible)
end

--up为1代表可提
function C:setPokerData( pcolor, pvalue,up )
    self.up=up
    -- local numberStr = ""
    -- local smallColorStr = ""
    -- local colorStr = ""
    -- local colorSize = cc.size(78,82)

    -- if pcolor == 6 then   --黑桃 6
    --     smallColorStr = "shape_spade_s.png"
    --     colorStr = "shape_spade.png"
    --     numberStr = "num_black_"
    --     colorSize = cc.size(78,82)
    -- elseif pcolor == 3 then --方块 3
    --     smallColorStr = "shape_diamond_s.png"
    --     colorStr = "shape_diamond.png"
    --     numberStr = "num_red_"
    --     colorSize = cc.size(80,80)
    -- elseif pcolor == 4 then    --梅花 4
    --     smallColorStr = "shape_club_s.png"
    --     colorStr = "shape_club.png"
    --     numberStr = "num_black_"
    --     colorSize = cc.size(76,80)
    -- elseif pcolor == 5 then   --红桃 5
    --     smallColorStr = "shape_heart_s.png"
    --     colorStr = "shape_heart.png"
    --     numberStr = "num_red_"
    --     colorSize = cc.size(80,72)
    -- end

    -- numberStr = numberStr..tostring(pvalue)..".png"

    -- self.numberImg:loadTexture(numberStr,1)
    -- self.smallColorImg:loadTexture(smallColorStr,1)
    -- self.bigColorImg:loadTexture(colorStr,1)
    -- self.bigColorImg:setContentSize(colorSize)
    local colorStr =GAME_BRQZNN_IMAGES_RES.. "paixiao/card"..(pcolor-3).."_"..pvalue..".png"
    self.frontground:loadTexture(colorStr)
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
        self.background:runAction(cc.OrbitCamera:create( 0, 1, 0, -270, -90, 0, 0 ))
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
        self.frontground:runAction(cc.OrbitCamera:create( 0, 1, 0, 270, 90, 0, 0 ))
        self.background:setVisible(false)
    end
end

return C