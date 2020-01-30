local C = class("HhdzPlayerListView",BaseLayer)

C.RESOURCE_FILENAME = GAME_HHDZ_PREFAB_RES.."PlayerListLayer.csb"

C.RESOURCE_BINDING = 
{
	template = {path="template"},
    closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
    listview = {path="box_img.listview"},
}

function C:onCreate()
	C.super.onCreate(self)
	self.template:setVisible(false)
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
    item = self.template:clone()
    --屏蔽vip
    item:getChildByName("vip_img"):setVisible(false)
    item:setVisible(true)
    local headId = info["headid"]
    local headUrl = info["wxheadurl"]
    local headImg = item:getChildByName("head_img")
    SET_HEAD_IMG(headImg,headId,headUrl)
    item:getChildByName("rank_label"):setString("No."..index)
    local name = info["nickname"]
    if name == nil or name == "" then
        name = tostring(info["playerid"])
    end
    item:getChildByName("name_label"):setString(name)
    local money = utils:moneyString(info["money"])
    item:getChildByName("blance_label"):setString(money)
    local bet = "下注:"..utils:moneyString(info["bet20"])
    item:getChildByName("bet_label"):setString(bet)
    local win = "获胜:"..tostring(info["winnum"])
    item:getChildByName("win_label"):setString(win)
    return item
end

return C