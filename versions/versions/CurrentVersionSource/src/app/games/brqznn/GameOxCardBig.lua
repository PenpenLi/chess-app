--搓牌用的一套牌
--牛牛卡牌
local GameOxCardBig =class('GameOxCardBig',cc.Node)
local GameConfig = import(".GameOxConfig")

--方块 梅花 红桃 黑桃
function GameOxCardBig:ctor(frontImg, color,value)
   -- color=2
    local cfg=GameConfig.new()
    self.back=cc.Node:create()
    self.back:setRotation(-90)
    frontImg:addChild(self.back,200)
    self.back:setPosition(cc.p(display.cx+350, display.cy-230))
    --self.back:setPosition(cc.p(100, 100))
    --self.back:getTexture():setAntiAliasTexParameters()
    --数字
    self.numbers={}
    for k,v in pairs(cfg.pokerCfg[value].numbers) do
        if k <= 2 then 
            local number=display.newSprite(GAME_BRQZNN_IMAGES_RES..'poker2/'..cfg.numberNames[color+1]..value..'.png')
            number:setPosition(v[1],v[2])
            number:setScale(v[3],v[4])
            number:setOpacity(0)
            self.back:addChild(number)
            table.insert(self.numbers,number)
        else
            local colorRes=cfg.colorNames[color+1]
            local hua=display.newSprite(GAME_BRQZNN_IMAGES_RES..'poker2/'..colorRes..'.png')
            hua:setPosition(v[1],v[2])
            hua:setScale(v[3],v[4])
            hua:setOpacity(0)
            self.back:addChild(hua)
            table.insert(self.numbers,hua)
        end             
    end
    --花色
     for k,v in pairs(cfg.pokerCfg[value].hua) do
        local colorRes=cfg.colorNames[color+1]
        if v[5]~=nil then
            colorRes=cfg.colorNamesA[color+1]..value
        end
        local hua=display.newSprite(GAME_BRQZNN_IMAGES_RES..'poker2/'..colorRes..'.png')
        hua:setPosition(v[1],v[2])
        hua:setScale(v[3],v[4])
        self.back:addChild(hua)
    end
    --self:setCascadeOpacityEnabled(true)
    --self:showNumber(true,callback)
    return self.numbers
end
--显示数字
function GameOxCardBig:showNumber(val,callback)
    if val==false then
        for k,v in pairs(self.numbers) do
            v:setVisible(false)
        end
    else
        for k,v in pairs(self.numbers) do
            v:setVisible(true)
            v:setOpacity(0)
            local arr = {}
            arr[1]=cc.DelayTime:create(0.3)
            arr[2]=cc.FadeIn:create(1.0)
            arr[3]=cc.DelayTime:create(1)
            arr[4]=cc.CallFunc:create(function()
                if callback and k==4 then
                    callback()
                end
            end)
            v:runAction(cc.Sequence:create(arr))
        end
    end
end
--打开卡牌
function GameOxCardBig:open(animation)
    if self.isOpen == false then
        if animation then
            self:flip()
        else
            self.back:setVisible(false)
            self.front:setVisible(true)
        end
        self.isOpen = true
    end
end

--翻转
function GameOxCardBig:flip()
    local interval=0.4
    local actionArray = {}   
    local op =cc.CallFunc:create(function()
        self.back:setVisible(false)
        self.front:setVisible(true)
    end)
    local _zoomOut = cc.OrbitCamera:create(interval/2, 1, 0, 0, 90, 0, 0)
    local _zoomIn = cc.OrbitCamera:create(interval/2, 1, 0, -90, 90, 0, 0)
    table.insert(actionArray, _zoomOut)
    table.insert(actionArray, op)
    table.insert(actionArray, _zoomIn)
    local seq = cc.Sequence:create(actionArray)
    self:runAction(seq)
end

function GameOxCardBig:collidePoint(tx,ty)
   local scale=self:getScaleX()
    local realW=scale*456
    local realH=scale*694
    local angle=self:getRotation()
    local radius=-3.1415926*angle/180
    local x,y=self:getPosition()
    local p2={x=x-realW*0.5,y=y}
    p2=self:getNewPos(p2,{x=x,y=y},radius)
    local p3={x=x+realW*0.5,y=y}
    p3=self:getNewPos(p3,{x=x,y=y},radius)
    local p4={x=x+realW*0.5,y=y+realH}
    p4=self:getNewPos(p4,{x=x,y=y},radius)
    local p1={x=x-realW*0.5,y=y+realH};
    p1=self:getNewPos(p1,{x=x,y=y},radius)
     if self:isPointInMatrix({x=tx,y=ty},p1,p2,p3,p4) then
        return true;
    end
    return false
end
-- 计算叉乘 |PP1| × |PP2| 
function  GameOxCardBig:getCross(p1, p2,p)   
    return (p1.x - p.x) * (p2.y - p.y) -(p2.x - p.x) * (p1.y - p.y);  
end
--点p是否在矩形内,利用叉乘的方向性
function GameOxCardBig:isPointInMatrix(p,p1,p2,p3,p4)   
    return self:getCross(p1,p2,p) * self:getCross(p3,p4,p) >= 0 and self:getCross(p2,p3,p) * self:getCross(p4,p1,p) >= 0
end 

--任意点(x,y)，绕一个坐标点(rx0,ry0)逆时针旋转a角度后的新的坐标设为(x0, y0)，有公式：
--x0= (x - rx0)*cos(a) - (y - ry0)*sin(a) + rx0 ;
--y0= (x - rx0)*sin(a) + (y - ry0)*cos(a) + ry0 ;
function GameOxCardBig:getNewPos(p, centerP, a)
    local x0 =(p.x - centerP.x) * math.cos(a) -(p.y - centerP.y) * math.sin(a) + centerP.x;
    local y0 =(p.x - centerP.x) * math.sin(a) +(p.y - centerP.y) * math.cos(a) + centerP.y;
    return { x = x0, y = y0 }
end

return GameOxCardBig

