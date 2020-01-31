--[[    author:Joseph
    time：2019-12-31 13:13:44
]]
local C = class("BjlPlayersList", BaseLayer)

C.RESOURCE_FILENAME = "games/bjl/prefab/BjlPlayersList.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
    backBtn = { path = "bg.close_btn", events = { { event = "click", method = "onClickBackBtn" } } },
    template = { path = "Panel_1" },
    list = { path = "listview" },
}

function C:onCreate()
    C.super.onCreate(self)
    self.yPos = self.resourceNode:getPositionY()
end

function C:show()
    C.super.show(self)

    self.resourceNode:setPositionY(self.yPos)
    self.maskLayer:setVisible(true)
    if self.maskLayer then
        self.maskLayer:setOpacity(0)
        self.maskLayer:runAction(cc.FadeTo:create(0.35, 153))
    end
end

function C:hide()
    C.super.hide(self)
end

function C:onClickBackBtn()
    self:hide()
end

function C:setInfo(s)
    self.list:removeAllItems();
    for i, v in ipairs(s) do
        local item = self:createItem(v, i)
        self.list:pushBackCustomItem(item)
    end
end

function C:createItem(data, index)
    local litem = self.template:clone()
    litem:getChildByName("rank_num"):setString(tostring(index))
    litem:getChildByName("id_lb"):setString(tostring(data.playerid))
    litem:getChildByName("money_lb"):setString(utils:moneyString(data.money))
    litem:getChildByName("bet_lb"):setString(utils:moneyString(data.bet20))
    local headImg = litem:getChildByName("head_icon")
    SET_HEAD_IMG(headImg,data.headid,data.wxheadurl)
    if index < 4 then
        litem:getChildByName("rank_img"):loadTexture(GAME_BJL_IMAGES_RES .. "playersPanel/baccarat_players_rank" .. index .. ".png")
    end
    return litem
end

return C