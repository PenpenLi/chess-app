local PokerClass = import(".BRQznnPokerClass")
local CuoSingle = import(".CuoSingle")
local RubCardLayer =  import(".RubCardLayer")
local GameOxCardBig =  import(".GameOxCardBig")
local GameConfig = import(".GameOxConfig")
local C = class("BRQznnCuoClass",ViewBaseClass)

C.BINDING = {
    poker5Node={path="poker5"},
    closeBtn={path="close_btn",events={{event="click",method="onClickCloseBtn"}}},
    color1={path="color1"},
    color2={path="color2"},
}

C.pokerClassArr = nil
C.pokerDataArr =nil
C.poker5Pos=nil
C.callback=nil

C.colorPos={
    [1]=cc.p(422,122),
    [2]=cc.p(716,403)
}

C.numberPos={
    [1]=cc.p(366,122),
    [2]=cc.p(774,403)
}

C.numberNames={'hongse','heise','hongse','heise'}
C.colorNames={'dafangjiao','dameihua','dahongtao','daheitao'}

function C:ctor( node )
    for i=1,4 do
        local key = string.format("poker%d",i)
        local path = {path=string.format("poker_%d",i)}
        self.BINDING[key] = path
    end
    C.super.ctor(self,node)
end

function C:onCreate()
    self.pokerClassArr = {}
    for i=1,4 do
        local key = string.format("poker%d",i)
        local pokerNode = self[key]
        local pokerClass = PokerClass.new(pokerNode)
        self.pokerClassArr[i] = pokerClass
    end
    
end

function C:setVisible( flags )
    self.node:setVisible(flags)
end

function C:isVisible()
    return self.node:isVisible()
end

--设置牌信息
function C:setPokerData( dataArr, ctype, niun )
    if self.pokerDataArr then
        --要排序,前面四张已经给了，只取最后一张即可
        for i = 1, #dataArr do
            local pcolor1 = dataArr[i]["color"]
            local pvalue1 = dataArr[i]["number"]
            local exist = false
            for k = 1, #self.pokerDataArr do
                local pcolor2 = self.pokerDataArr[k]["color"]
                local pvalue2 = self.pokerDataArr[k]["number"]
                if pcolor1==pcolor2 and pvalue1==pvalue2 then
                    self.pokerDataArr[k]["up"]=dataArr[i]["up"]
                    exist=true
                end
            end
            if not exist then
                local info = utils:copyTable(dataArr[i])
                table.insert(self.pokerDataArr,info)
            end
        end
    else
        self.pokerDataArr = utils:copyTable(dataArr)
    end
    if ctype~=nil then
        self.pokerType = ctype
    end
    if niun~=nil then
        self.pokerNiun = niun
    end
    for i=1,4 do
        local pokerClass = self.pokerClassArr[i]
        local data = self.pokerDataArr[i]
        local pcolor = data["color"]
        local pvalue = data["number"]
        local up = data["up"]
        pokerClass:setPokerData( pcolor, pvalue,up )
    end
end

--翻牌
function C:turnPoker()
    for i=1,4 do
        local pokerClass = self.pokerClassArr[i]
        pokerClass:frontgroundPoker(false)
    end
end

--显示
function C:show(callback)
    self.callback=callback
    self:turnPoker()
    self:setVisible(true)
    self.rubCardLayer=nil
    self.color1:setOpacity(0)
    self.color2:setOpacity(0)
	--搓牌
	local endCallBack = function()
		self:cuoPaiFinish()
    end
    local color = self.pokerDataArr[5]["color"]-3
    local number = self.pokerDataArr[5]["number"]
    local strBack = GAME_BRQZNN_IMAGES_RES..'poker2/'.."paibei_1.png"
    local strFront = GAME_BRQZNN_IMAGES_RES..'poker2/'.."card"..color.."_"..number..".png"
    self.rubCardLayer = RubCardLayer:create(strBack,strFront , display.cx, display.cy-62, endCallBack)
    self.poker5Node:addChild(self.rubCardLayer, 100)
end

--搓牌完成
function C:cuoPaiFinish()
    self:createNum(self.poker5Node,self.pokerDataArr[5].color-3,self.pokerDataArr[5].number)
    self:showNumber()
end

function C:createNum(frontImg, color,value)
     --数字
     self.color1:loadTexture(GAME_BRQZNN_IMAGES_RES..'poker2/cardColor'..color.."_"..value..'.png')
     self.color2:loadTexture(GAME_BRQZNN_IMAGES_RES..'poker2/cardColor'..color.."_"..value..'.png')
 end

--显示数字
function C:showNumber(val)
    local array = {}
    array[1]=cc.DelayTime:create(0.1)
    array[2]=cc.CallFunc:create(function()
        self.color1:runAction(cc.FadeIn:create(0.3))
        self.color2:runAction(cc.FadeIn:create(0.3))
     end)
    array[3]=cc.DelayTime:create(0.65)
    array[4]=cc.CallFunc:create(function()
                if self.callback then
                    self.callback()
                end
                self:clean()
             end)
    self.node:runAction(cc.Sequence:create(array))
end

--隐藏
function C:clean()
    if self.rubCardLayer then
        self.rubCardLayer:removeFromParent()
    end
    self.rubCardLayer=nil
    self.poker5Node:removeAllChildren()
    self.callback=nil
    self.pokerDataArr=nil
    self.node:stopAllActions()
    self.color1:stopAllActions()
    self.color2:stopAllActions()
    self.color1:setOpacity(0)
    self.color2:setOpacity(0)
    self:setVisible(false)
end

--关闭
function C:onClickCloseBtn(event)
    if self.callback then
        self.callback()
    end
end

return C