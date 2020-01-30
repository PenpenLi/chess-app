local C = class("RankLayer",BaseLayer)
RankLayer = C

C.RESOURCE_FILENAME = "base/RankLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	todayWinTabBtn = {path="box_img.today_win_tab_btn",events={{event="click",method="onClickTodayWinTabBtn"}}},
	todayTimeTabBtn = {path="box_img.today_time_tab_btn",events={{event="click",method="onClickTodayTimeTabBtn"}}},
	weekWinTabBtn = {path="box_img.week_win_tab_btn",events={{event="click",method="onClickWeekWinTabBtn"}}},
	rewardTabBtn = {path="box_img.reward_tab_btn",events={{event="click",method="onClickRewardTabBtn"}}},
	ruleBtn = {path="box_img.rule_tab_btn",events={{event="click",method="onClickRuleTabBtn"}}},

	todayWinPanel = {path="box_img.today_win_panel"},
	todayWinListview = {path="box_img.today_win_panel.listview"},
	todayWinEmptyLabel = {path="box_img.today_win_panel.empty_label"},
	todayWinMineImg = {path="box_img.today_win_panel.mine_img"},

	todayTimePanel = {path="box_img.today_time_panel"},
	todayTimeListview = {path="box_img.today_time_panel.listview"},
	todayTimeEmptyLabel = {path="box_img.today_time_panel.empty_label"},
	todayTimeMineImg = {path="box_img.today_time_panel.mine_img"},

	weekWinPanel = {path="box_img.week_win_panel"},
	weekWinListview = {path="box_img.week_win_panel.listview"},
	weekWinEmptyLabel = {path="box_img.week_win_panel.empty_label"},
	weekWinMineImg = {path="box_img.week_win_panel.mine_img"},

	rewardPanel = {path="box_img.reward_panel"},
	rewardListview = {path="box_img.reward_panel.listview"},
	rewardEmptyLabel = {path="box_img.reward_panel.empty_label"},
	rewardMineImg = {path="box_img.reward_panel.mine_img"},

	templateItem1 = {path="rank_item_1"},
	templateItem2 = {path="rank_item_2"},
	templateItem3 = {path="rank_item_3"},
	templateItem4 = {path="rank_item_4"},
}

function C:onCreate()
	C.super.onCreate(self)
	self.templateItem1:setVisible(false)
	self.templateItem2:setVisible(false)
	self.templateItem3:setVisible(false)
	self.templateItem4:setVisible(false)

	self.todayWinListview:removeAllItems()
	self.todayTimeListview:removeAllItems()
	self.weekWinListview:removeAllItems()
	self.rewardListview:removeAllItems()

	self.todayWinListview:setScrollBarWidth(5)
	self.todayTimeListview:setScrollBarWidth(5)
	self.weekWinListview:setScrollBarWidth(5)
	self.rewardListview:setScrollBarWidth(5)

	self.todayWinListview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
	self.todayTimeListview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
	self.weekWinListview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))
	self.rewardListview:setScrollBarPositionFromCornerForVertical(cc.p(5,5))

	self.todayWinEmptyLabel:setVisible(false)
	self.todayTimeEmptyLabel:setVisible(false)
	self.weekWinEmptyLabel:setVisible(false)
	self.rewardEmptyLabel:setVisible(false)

	--设置ID
	self:setMineIdLable(self.todayWinMineImg)
	self:setMineIdLable(self.todayTimeMineImg)
	self:setMineIdLable(self.weekWinMineImg)
	self:setMineIdLable(self.rewardMineImg)

	--设置头像
	self:setMineHeadId(self.todayWinMineImg)
	self:setMineHeadId(self.todayTimeMineImg)
	self:setMineHeadId(self.weekWinMineImg)
	self:setMineHeadId(self.rewardMineImg)

	--设置信息
	self:setMineInfo(self.todayWinMineImg,"0.00",-1)
	self:setMineInfo(self.todayTimeMineImg,"00:00:00",-1)
	self:setMineInfo(self.weekWinMineImg,"0.00",-1)
	self:setMineInfo(self.rewardMineImg,"0.00",-1)

	--先注释本周赢金币/上周获奖名单功能
	self.weekWinTabBtn:setVisible(false)
	self.rewardTabBtn:setVisible(false)
end

function C:show()
	C.super.show(self)
	self:showTabPanel(1)

	utils:delayInvoke("hall.rank",0.3,function()
		self:loadTodayWinInfo()
		self:loadTodayTimeInfo()
		self:loadWeekWinInfo()
		self:loadRewardInfo()

	    self:loadMyTodayWinInfo()
		self:loadMyTodayTimeInfo(0)
		self:loadMyWeekWinInfo()
		self:loadMyRewardInfo()
	end)
	
    self.onLoadTodayWinInfoHander = handler(self, self.onLoadTodayWinInfo)
    eventManager:on("TodayGoldRankResult",self.onLoadTodayWinInfoHander)

    self.onLoadMyTodayWinInfoHander = handler(self, self.onLoadMyTodayWinInfo)
    eventManager:on("MyWinTodayResult",self.onLoadMyTodayWinInfoHander)

    self.onLoadTodayTimeInfoHander = handler(self, self.onLoadTodayTimeInfo)
    eventManager:on("TodayTimeRankResult",self.onLoadTodayTimeInfoHander)

    self.loadMyTodayTimeInfoHander = handler(self, self.loadMyTodayTimeInfo)
    eventManager:on("MyTimeTodayResult",self.loadMyTodayTimeInfoHander)
end

function C:hide()
    eventManager:off("TodayGoldRankResult",self.onLoadTodayWinInfoHander)
    eventManager:off("MyWinTodayResult",self.onLoadMyTodayWinInfoHander)
    eventManager:off("TodayTimeRankResult",self.onLoadTodayTimeInfoHander)
    eventManager:off("MyTimeTodayResult",self.loadMyTodayTimeInfoHander)
	C.super.hide(self)
end

function C:onClickTodayWinTabBtn( event )
	self:showTabPanel(1)
	self.todayWinListview:jumpToTop()
end

function C:onClickTodayTimeTabBtn( event )
	self:showTabPanel(2)
	self.todayTimeListview:jumpToTop()
end

function C:onClickWeekWinTabBtn( event )
	self:showTabPanel(3)
	self.weekWinListview:jumpToTop()
end

function C:onClickRewardTabBtn( event )
	self:showTabPanel(4)
	self.rewardListview:jumpToTop()
end

function C:onClickRuleTabBtn( event )
	RankRuleLayer.new():show()
end

function C:showTabPanel( index )
	self.todayWinPanel:setVisible(index==1)
	self.todayWinTabBtn:setEnabled(index~=1)
	self.todayTimePanel:setVisible(index==2)
	self.todayTimeTabBtn:setEnabled(index~=2)
	self.weekWinPanel:setVisible(index==3)
	self.weekWinTabBtn:setEnabled(index~=3)
	self.rewardPanel:setVisible(index==4)
	self.rewardTabBtn:setEnabled(index~=4)
end

function C:setMineIdLable( mineImg )
	local idLabel = mineImg:getChildByName("id_label")
	idLabel:setString(tostring(dataManager.playerId))
end

function C:setMineHeadId( mineImg )
	local headImg = mineImg:getChildByName("head_img")
	local name = GET_HEADID_RES(dataManager.userInfo.headid)
	headImg:loadTexture(name)
end

function C:setMineInfo( mineImg, text, myRank )
	local textLabel = mineImg:getChildByName("box_img"):getChildByName("label")
	textLabel:setString(text)
	for i=1,5 do
		local rank = i-1
		local rankImg = mineImg:getChildByName(string.format("rank_%d_img",rank))
		if rank == myRank then
			rankImg:setVisible(true)
		else
			rankImg:setVisible(false)
		end
		if 4 <= myRank and rank == 4 then
			rankImg:setVisible(true)
			local label = rankImg:getChildByName("label")
			label:setString(tostring(myRank))
		end
	end
end

--请求今日赢金币
function C:loadTodayWinInfo()
	eventManager:publish("RankData",CONST_RANK_TODAY_MONEY,1,100);
end
--数据返回
function C:onLoadTodayWinInfo(list)
	local items = self.todayWinListview:getItems()
	if #list == 0 and #items == 0 then
		self.todayWinEmptyLabel:setVisible(true)
		return
	end
	self.todayWinEmptyLabel:setVisible(false)
	self:refreshTodayWinList(list)

end

--刷新列表
function C:refreshTodayWinList( list )
	if list == nil or #list == 0 then
		return
	end

	--我的今日赢金币
	local myGold = utils:moneyString(tonumber(dataManager.myWinToday),2)
	local myRank = 0

	self.todayWinListview:removeAllItems()
	for i,v in ipairs(list) do
		local item = nil
		if i == 1 then
			item = self.templateItem1:clone()
		elseif i == 2 then
			item = self.templateItem2:clone()
		elseif i == 3 then
			item = self.templateItem3:clone()
		else
			item = self.templateItem4:clone()
		end
		item:setVisible(true)
		--item:getChildByName("box_img"):getChildByName("img"):loadTexture("base/images/rank_popup/rank_icon_gold.png")
		item:getChildByName("box_img"):loadTexture("base/images/rank_popup/rank_icon_gold.png")
		item:getChildByName("box_img"):getChildByName("time_label"):setVisible(false)
		item:getChildByName("box_img"):getChildByName("coin_label"):setVisible(true)
		local headId = tonumber(v.headId) or 1
		local id = tostring(v.playerId) or ""
		local gold = tonumber(v.money) or 0
		item:getChildByName("head_img"):loadTexture(GET_HEADID_RES(headId))
		item:getChildByName("id_label"):setString(id)
		item:getChildByName("box_img"):getChildByName("coin_label"):setString(utils:moneyString(gold,2))
		if i >= 4 then
			item:getChildByName("rank_img"):getChildByName("label"):setString(tostring(i))
		end
		self.todayWinListview:pushBackCustomItem(item)
		if id == tostring(dataManager.playerId) then
			myGold = utils:moneyString(gold,2)
			myRank = i
		end
	end
	--刷新我的今日赢金币
	self:setMineInfo(self.todayWinMineImg,myGold,myRank)
end

--请求今日在线时长
function C:loadTodayTimeInfo()
	eventManager:publish("RankData",CONST_RANK_TODAY_TIME,1,100);
end
--数据返回
function C:onLoadTodayTimeInfo(list)
	local items = self.todayWinListview:getItems()
	if #list == 0 and #items == 0 then
		self.todayTimeEmptyLabel:setVisible(true)
		return
	end
	self.todayTimeEmptyLabel:setVisible(false)
	self:refreshTodayTimeList(list)
end
--刷新列表
function C:refreshTodayTimeList( list )
	if list == nil or #list == 0 then
		return
	end

	dump(list,"refreshTodayTimeList")

	--我的在线时长
	local myOnlineTime = utils:timeString(dataManager:getOnlineTime())
	local myRank = 0

	self.todayTimeListview:removeAllItems()
	for i,v in ipairs(list) do
		local item = nil
		if i == 1 then
			item = self.templateItem1:clone()
		elseif i == 2 then
			item = self.templateItem2:clone()
		elseif i == 3 then
			item = self.templateItem3:clone()
		else
			item = self.templateItem4:clone()
		end
		item:setVisible(true)
		--item:getChildByName("box_img"):getChildByName("img"):loadTexture("base/images/rank_popup/rank_icon_time.png")
		item:getChildByName("box_img"):loadTexture("base/images/rank_popup/rank_icon_time.png")
		item:getChildByName("box_img"):getChildByName("time_label"):setVisible(true)
		item:getChildByName("box_img"):getChildByName("coin_label"):setVisible(false)
		local headId = tonumber(v.headId) or 1
		local id = tostring(v.playerId) or ""
		local time = tonumber(v.time) or 0
		item:getChildByName("head_img"):loadTexture(GET_HEADID_RES(headId))
		item:getChildByName("id_label"):setString(id)
		item:getChildByName("box_img"):getChildByName("time_label"):setString(utils:timeString(time))
		if i >= 4 then
			item:getChildByName("rank_img"):getChildByName("label"):setString(tostring(i))
		end
		self.todayTimeListview:pushBackCustomItem(item)
		if id == tostring(dataManager.playerId) then
			myOnlineTime = time
			myRank = i
		end
	end
	--刷新我的在线时长
	self:setMineInfo(self.todayTimeMineImg,myOnlineTime,myRank)
end

--请求本周赢金币
function C:loadWeekWinInfo()
	--TODO:测试
	self:onLoadWeekWinInfo()
end
--数据返回
function C:onLoadWeekWinInfo()
	--TODO:测试
	local ranks = "1008590,,5224050,0,11;1018124,,4733650,0,1;1011259,,3943450,0,12;1007511,,3929200,0,4;1016558,,3793350,0,10;1016811,,3603650,0,3;1012164,,3575250,0,15;1011038,,3538500,0,15;1016610,,3402405,0,3;1008195,,3069400,0,10;1006350,,3066100,0,14"
	local tempArr = utils:stringSplit(ranks,";")
	local list = {}
	for i,v in ipairs(tempArr) do
		local item = utils:stringSplit(v,",")
		table.insert(list,item)
	end
	local items = self.todayWinListview:getItems()
	if #list == 0 and #items == 0 then
		self.weekWinEmptyLabel:setVisible(true)
		return
	end
	self.weekWinEmptyLabel:setVisible(false)
	self:refreshWeekWinList(list)
end
--刷新列表
function C:refreshWeekWinList( list )
	if list == nil or #list == 0 then
		return
	end
	--TODO:我的本周赢金币
	local myGold = utils:moneyString(tonumber(dataManager.myWinToday),2)
	local myRank = 0

	self.weekWinListview:removeAllItems()
	for i,v in ipairs(list) do
		local item = nil
		if i == 1 then
			item = self.templateItem1:clone()
		elseif i == 2 then
			item = self.templateItem2:clone()
		elseif i == 3 then
			item = self.templateItem3:clone()
		else
			item = self.templateItem4:clone()
		end
		item:setVisible(true)
		--item:getChildByName("box_img"):getChildByName("img"):loadTexture("base/images/rank_popup/rank_icon_gold.png")
		item:getChildByName("box_img"):loadTexture("base/images/rank_popup/rank_icon_gold.png")
		item:getChildByName("box_img"):getChildByName("time_label"):setVisible(false)
		item:getChildByName("box_img"):getChildByName("coin_label"):setVisible(true)
		local headId = tonumber(v[5]) or 1
		local id = tostring(v[1]) or ""
		local gold = tonumber(v[3]) or 0
		item:getChildByName("head_img"):loadTexture(GET_HEADID_RES(headId))
		item:getChildByName("id_label"):setString(id)
		item:getChildByName("box_img"):getChildByName("coin_label"):setString(utils:moneyString(gold,2))
		if i >= 4 then
			item:getChildByName("rank_img"):getChildByName("label"):setString(tostring(i))
		end
		self.weekWinListview:pushBackCustomItem(item)
		if id == tostring(dataManager.playerId) then
			myGold = utils:moneyString(gold,2)
			myRank = i
		end
	end
	--刷新我的本周赢金币
	self:setMineInfo(self.weekWinMineImg,myGold,myRank)
end

--请求上周获奖名单
function C:loadRewardInfo()
	--TODO:测试
	self:onLoadRewardInfo()
end
--数据返回
function C:onLoadRewardInfo()
	--TODO:测试
	local ranks = "1008590,,5224050,0,11;1010936,,4733650,0,1;1018124,,3943450,0,12;1007511,,3929200,0,4;1016558,,3793350,0,10;1016811,,3603650,0,3;1012164,,3575250,0,15;1011038,,3538500,0,15;1016610,,3402405,0,3;1008195,,3069400,0,10;1006350,,3066100,0,14"
	local tempArr = utils:stringSplit(ranks,";")
	local list = {}
	for i,v in ipairs(tempArr) do
		local item = utils:stringSplit(v,",")
		table.insert(list,item)
	end
	local items = self.todayWinListview:getItems()
	if #list == 0 and #items == 0 then
		self.rewardEmptyLabel:setVisible(true)
		return
	end
	self.rewardEmptyLabel:setVisible(false)
	self:refreshRewardList(list)
end
--刷新列表
function C:refreshRewardList( list )
	if list == nil or #list == 0 then
		return
	end
	--TODO:我的上周获奖金币
	local myGold = utils:moneyString(tonumber(dataManager.myWinToday),2)
	local myRank = 0

	self.rewardListview:removeAllItems()
	for i,v in ipairs(list) do
		local item = nil
		if i == 1 then
			item = self.templateItem1:clone()
		elseif i == 2 then
			item = self.templateItem2:clone()
		elseif i == 3 then
			item = self.templateItem3:clone()
		else
			item = self.templateItem4:clone()
		end
		item:setVisible(true)
		--item:getChildByName("box_img"):getChildByName("img"):loadTexture("base/images/rank_popup/rank_icon_bonus.png")
		item:getChildByName("box_img"):loadTexture("base/images/rank_popup/rank_icon_bonus.png")
		item:getChildByName("box_img"):getChildByName("time_label"):setVisible(false)
		item:getChildByName("box_img"):getChildByName("coin_label"):setVisible(true)
		local headId = tonumber(v[5]) or 1
		local id = tostring(v[1]) or ""
		local gold = tonumber(v[3]) or 0
		item:getChildByName("head_img"):loadTexture(GET_HEADID_RES(headId))
		item:getChildByName("id_label"):setString(id)
		item:getChildByName("box_img"):getChildByName("coin_label"):setString(utils:moneyString(gold,2))
		if i >= 4 then
			item:getChildByName("rank_img"):getChildByName("label"):setString(tostring(i))
		end
		self.rewardListview:pushBackCustomItem(item)
		if id == tostring(dataManager.playerId) then
			myGold = utils:moneyString(gold,2)
			myRank = i
		end
	end
	--刷新我的上周获奖金币
	self:setMineInfo(self.rewardMineImg,myGold,myRank)
end

--请求我的今日赢金币
function C:loadMyTodayWinInfo()
    local myGold = dataManager.myWinToday
	local myRank = 0
	self:onLoadMyTodayWinInfo(myRank,myGold)
end

--数据返回
function C:onLoadMyTodayWinInfo(rank,gold)
	gold = utils:moneyString(tonumber(gold),2)
	self:setMineInfo(self.todayWinMineImg,gold,rank)
end

--我的今日在线时长
function C:loadMyTodayTimeInfo(rank)
	local time = utils:timeString(dataManager:getOnlineTime())
	self:setMineInfo(self.todayTimeMineImg,time,rank)
end

--请求我的本周赢金币
function C:loadMyWeekWinInfo()
	--TODO:测试
	-- self:onLoadMyWeekWinInfo()
end

--数据返回
function C:onLoadMyWeekWinInfo()
	--TODO:
	local gold = "912385.98"
	local rank = 2
	self:setMineInfo(self.weekWinMineImg,gold,rank)
end

--请求我的上周获奖名单
function C:loadMyRewardInfo()
	--TODO:测试
	-- self:onLoadMyRewardInfo()
end
--数据返回
function C:onLoadMyRewardInfo()
	--TODO:
	local gold = "15658.94"
	local rank = 3
	self:setMineInfo(self.rewardMineImg,gold,rank)
end

return RankLayer