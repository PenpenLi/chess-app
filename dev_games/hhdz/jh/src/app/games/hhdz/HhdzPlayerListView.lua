local C = class("HhdzPlayerListView",BaseLayer)

C.RESOURCE_FILENAME = GAME_HHDZ_PREFAB_RES.."PlayerListLayer.csb"

C.RESOURCE_BINDING = 
{
	template1 = {path="template_1"},
    template2 = {path="template_2"},
    template3 = {path="template_3"}, 
    closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
    listview = {path="box_img.listview"},
}

function C:onCreate()
	C.super.onCreate(self)
	self.template1:setVisible(false)
    self.template2:setVisible(false)
    self.template3:setVisible(false)
    self.listview:removeAllItems()
    self.listview:setTopPadding(5)
    self.listview:setBottomPadding(5)
    self.listview:setScrollBarWidth(5)
    self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
end

function C:show()
    C.super.show(self)
    self.listview:jumpToTop()
end

function C:hide()
    C.super.hide(self)
end

function C:setInfos(playerlist)
    self.listview:removeAllItems()
    for i=1,#playerlist do
        local item = self:createItem(i,playerlist[i])
        self.listview:pushBackCustomItem(item)
    end
    self.listview:jumpToTop()
end

function C:createItem( index,info )
    local item = nil
    if index == 1 then
         item = self.template1:clone()
         item:getChildByName("rank_img"):loadTexture(GAME_HHDZ_IMAGES_RES.."star.png")
    elseif index == 2 then
        item = self.template1:clone()
        item:getChildByName("rank_img"):loadTexture(GAME_HHDZ_IMAGES_RES.."rich_1.png")
    elseif index <= 9 then
        item = self.template2:clone()
        item:getChildByName("rank_img"):loadTexture(GAME_HHDZ_IMAGES_RES.."rich_"..tostring(index-1)..".png")
    else
        item = self.template3:clone()
        item:getChildByName("rank_img"):getChildByName("label"):setString(tostring(index-1))
    end
    --TODO:屏蔽vip
    item:getChildByName("vip_img"):setVisible(false)
    item:setVisible(true)
    local headId = info["headid"]
    local headUrl = info["wxheadurl"]
    local headImg = item:getChildByName("head_img")
    SET_HEAD_IMG(headImg,headId,headUrl)
    local name = info["nickname"]
    if name == nil or name == "" then
        name = tostring(info["playerid"])
    end
    item:getChildByName("name_label"):setString(name)
    local money = utils:moneyString(info["money"],3)
    item:getChildByName("blance_label"):setString(money)
    local bet = utils:moneyString(info["bet20"],3)
    item:getChildByName("bet_label"):setString(bet)
    local win = tostring(info["winnum"]).."局"
    item:getChildByName("win_label"):setString(win)
    return item
end

return C