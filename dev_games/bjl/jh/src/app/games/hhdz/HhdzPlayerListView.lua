local C = class("HhdzPlayerListView",BaseLayer)

C.RESOURCE_FILENAME = GAME_HHDZ_PREFAB_RES.."PlayerListLayer.csb"

C.RESOURCE_BINDING = 
{
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},

	templateItem = {path="template"},

    listview = {path="box_img.listview"}, 
    item1 = {path="box_img.listview.item_1"},
    item2 = {path="box_img.listview.item_2"},
    item3 = {path="box_img.listview.item_3"},
    item4 = {path="box_img.listview.item_4"},
    item5 = {path="box_img.listview.item_5"},
    item6 = {path="box_img.listview.item_6"},
    item7 = {path="box_img.listview.item_7"},
    item8 = {path="box_img.listview.item_8"},
    item9 = {path="box_img.listview.item_9"}
}

C.items = nil

function C:onCreate()
	C.super.onCreate(self)
    self.items = {}
	self.listview:setTopPadding(5)
	self.listview:setBottomPadding(5)
	self.listview:setScrollBarWidth(5)
	self.listview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
    for i=1,9 do
        self.items[i] = self["item"..tostring(i)]
    end
end

function C:show()
    -- self:removeAll()
    self.listview:jumpToTop()
    C.super.show(self)
end

function C:removeAll()
    for k,v in pairs(self.items) do
        v:setVisible(false)
    end
end

function C:setInfos(playerlist)
    self:removeAll()
    for i=1,#playerlist do
        if i > #self.items then
            local item = self.templateItem:clone()
            table.insert(self.items,item)
            self.listview:pushBackCustomItem(item)
        end
        self:setItemInfo(self.items[i],i,playerlist[i])
        self.items[i]:setVisible(true)
    end
    
end

function C:hide()
	C.super.hide(self)
end

function C:setItemInfo(item,rank,info)
    local headImg = item:getChildByName("head_img")
    local nameLabel = item:getChildByName("name_label")
    local creditLabel = item:getChildByName("blance_label")
    local betLabel = item:getChildByName("bet_label")
    local winLabel = item:getChildByName("win_label")
    local headRes = GET_HEADID_RES(info.headid)
    headImg:loadTexture(headRes)
    nameLabel:setString("ID:"..tostring(info.playerid))
    creditLabel:setString(utils:moneyString(info.money,2))
    betLabel:setString(utils:moneyString(info.bet20,2).."元")
    winLabel:setString(tostring(info.winnum).."局")
    if rank > 9 then
        local rankLabel = item:getChildByName("rank_img"):getChildByName("label")
        rankLabel:setString(tostring(rank-1))
    end
end

return C