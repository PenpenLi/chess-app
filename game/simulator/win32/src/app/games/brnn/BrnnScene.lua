local BankerClass = import(".BrnnBankerClass")
local AreaClass = import(".BrnnAreaClass")
local ChipsClass = import(".BrnnChipsClass")
local PlayerClass = import(".BrnnPlayerClass")
local PopupClass = import(".BrnnPopupClass")
local ResultClass = import(".BrnnResultClass")
local BankerListLayer = import(".BankerListLayer")
local JackpotLayer = import(".JackpotLayer")
local PlayerListLayer = import(".PlayerListLayer")
local ZoushiLayer = import(".ZoushiLayer")

local C = class("BrnnScene",GameSceneBase)
-- 资源名
C.RESOURCE_FILENAME = "games/brnn/BrnnScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
	--table
	zhuangTips = {path="zhuang_tips"},
	betTimer = {path="bet_timer"},
	--top panel
	topBg = {path="top_panel.bg_img"},
	--返回按钮
	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
	--充值按钮
	rechargeBtn = {path="top_panel.recharge_btn",events={{event="click",method="onClickRechargeBtn"}}},
	--帮助按钮
	helpBtn = {path="top_panel.help_btn",events={{event="click",method="onClickHelpBtn"}}},
	--设置按钮
	settingsBtn = {path="top_panel.settings_btn",events={{event="click",method="onClickSettingsBtn"}}},
	--电池节点
	batteryNode = {path="top_panel.battery_node"},
	--庄家节点
	bankerNode = {path="top_panel.banker_img"},
	--庄家玩家头像
	bankerPlayerHead = {path="top_panel.banker_img.player_head",events={{event="click",method="onClickBanker"}}},
	--上庄条件
	upBankerLabel = {path="top_panel.banker_img.right_panel.up_label"},
	--上庄按钮
	upBankerBtn = {path="top_panel.banker_img.right_panel.up_btn",events={{event="click",method="onClickUpBankerBtn"}}},
	--下庄按钮
	downBankerBtn = {path="top_panel.banker_img.right_panel.down_btn",events={{event="click",method="onClickDownBankerBtn"}}},
	--奖池节点
	jackpotNode = {path="top_panel.jiangchi_node"},
	jackpotLabel = {path="top_panel.jiangchi_node.label"},
	jackpotBtn = {path="top_panel.jiangchi_node.btn",events={{event="click",method="onClickJackpotBtn"}}},
	--bet area panel
	areaPanel = {path="area_panel"},
	loseDot = {path="area_panel.lose_dot"},
	winDot = {path="area_panel.win_dot"},
	qinglongArea = {path="area_panel.qinglong",events={{event="touch",method="onClickQinglong"}}},
	baihuArea = {path="area_panel.baihu",events={{event="touch",method="onClickBaihu"}}},
	zhuqueArea = {path="area_panel.zhuque",events={{event="touch",method="onClickZhuque"}}},
	xuanwuArea = {path="area_panel.xuanwu",events={{event="touch",method="onClickXuanwu"}}},
	--bottom panel
	myNode = {path="bottom_panel.me_info",events={{event="click",method="onClickSelf"}}},
	myBlanceLabel = {path="bottom_panel.me_info.info_img.blance_img.label"},
	myNameLabel = {path="bottom_panel.me_info.info_img.name_label"},
	myHead = {path="bottom_panel.me_info.head"},
	myHeadImg = {path="bottom_panel.me_info.head.head_img"},
	myFrameImg = {path="bottom_panel.me_info.head.frame_img"},
	myVipImg = {path="bottom_panel.me_info.head.vip_img"},
	myVipLabel = {path="bottom_panel.me_info.head.vip_img.label"},
	xuyaBtn = {path="bottom_panel.xuya_btn",events={{event="click",method="onClickXuyaBtn"}}},
	zoushiBtn = {path="bottom_panel.zoushi_btn",events={{event="click",method="onClickZoushiBtn"}}},
	onlineBtn = {path="bottom_panel.online_btn",events={{event="click",method="onClickOnlineBtn"}}},
	bottomTips = {path="bottom_panel.tips_img"},
	--chips panel
	chipsPanel = {path="chips_panel"},
	--result panel
	resultPanel = {path="result_panel"},
	--popup panel
	popupPanel = {path="popup_panel"},
	--等待下一局
	waittingImg = {path="wait_img"},
	--停止下注
	stopImg = {path="stop_img"},
}

C.bankerClass = nil
C.qinglongAreaClass = nil
C.baihuAreaClass = nil
C.zhuqueAreaClass = nil
C.xuanwuAreaClass = nil
C.chipsClass = nil
C.playerClassArr = nil
C.resultClass = nil
C.popupClass = nil
C.bankerListLayer = nil
C.jackpotLayer = nil
C.jackpotSkeletonNode = nil
C.playerListLayer = nil
C.zoushiLayer = nil
C.isSelfShaking = false
C.isOnlineShaking = false
C.lastJackpotMoney = 0

function C:ctor( core )
	--点击玩家头像,第一个玩家是神算子，第二个玩家是大富豪
	for i=1,6 do
		local key = string.format("player%d",i)
		local path = string.format("player_panel.player_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickPlayer"}}}
	end
	--点击下注按钮
	for i=1,5 do
		local key = string.format("betBtn%d",i)
		local path = string.format("bottom_panel.bet_btn_%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickBetBtn"}}}
	end
	C.super.ctor(self,core)
end

--加载资源
function C:loadResource()
	C.super.loadResource(self)
	self:loadPokerTypeRes()
	display.loadSpriteFrames(GAME_BRNN_IMAGES_RES.."brnn_cards.plist",GAME_BRNN_IMAGES_RES.."brnn_cards.png")
	display.loadSpriteFrames(GAME_BRNN_IMAGES_RES.."lzt_bg.plist",GAME_BRNN_IMAGES_RES.."lzt_bg.png")
end

--卸载资源
function C:unloadResource()
	self:unloadPokerTypeRes()
	display.removeSpriteFrames(GAME_BRNN_IMAGES_RES.."brnn_cards.plist",GAME_BRNN_IMAGES_RES.."brnn_cards.png")
	display.removeSpriteFrames(GAME_BRNN_IMAGES_RES.."lzt_bg.plist",GAME_BRNN_IMAGES_RES.."lzt_bg.png")
	C.super.unloadResource(self)
end

--加载牌型资源
function C:loadPokerTypeRes()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/hulu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/meiniu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuba.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuer.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niujiu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuliu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuniu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuqi.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niusan.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niusi.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuwu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuyi.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/shunzi.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/tonghua.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/tonghuashun.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/wuhuaniu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/wuxiaoniu.ExportJson")
	manager:addArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/zhadanniu.ExportJson")
end

--卸载牌型资源
function C:unloadPokerTypeRes()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/hulu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/meiniu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuba.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuer.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niujiu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuliu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuniu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuqi.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niusan.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niusi.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuwu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/niuyi.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/shunzi.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/tonghua.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/tonghuashun.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/wuhuaniu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/wuxiaoniu.ExportJson")
	manager:removeArmatureFileInfo(GAME_BRNN_ANIMATION_RES.."skeleton/type/zhadanniu.ExportJson")
end

function C:initialize()
	C.super.initialize(self)
	--适配宽屏
	self:adjustUI(self.topBg,{self.backBtn,self.batteryNode},{self.helpBtn,self.settingsBtn})
	--充值按钮
	self:playRechargeAni()
	--点击玩家头像
	self.playerClassArr = {} 
	for i=1,6 do
		local key = string.format("player%d",i)
		local player = self[key]
		player:setTag(i)
		local playerClass = PlayerClass.new(player)
		playerClass:setVisible(false)
		self.playerClassArr[i] = playerClass
	end
	--自己头像
	local headId = self.model.myInfo["headid"]
	local headUrl = self.model.myInfo["wxheadurl"]
	SET_HEAD_IMG(self.myHeadImg,headId,headUrl)
	local money = utils:moneyString(self.model.myInfo["money"])
	self.myBlanceLabel:setString(money)
	local name = self.model.myInfo["nickname"]
	if name == nil or name == "" then
		name = tostring(self.model.myInfo["playerid"])
	end
	self.myNameLabel:setString(name)
	self.myVipImg:setVisible(false)
	--筹码按钮按钮
	for i=1,5 do
		local key = string.format("betBtn%d",i)
		self[key]:setTag(i)
	end
	self:setXuyaBtnEnabled(false)
	self:setAllChipBtnSelected(false)
	self:setAllChipBtnEnabled(false)
	self.bottomTips:setVisible(false)
	--庄家
	self.upBankerLabel:setString("")
	self.bankerClass = BankerClass.new(self.bankerNode)
	-- self.bankerClass:setVisible(false)
	--奖池
	local strAnimName = GAME_BRNN_ANIMATION_RES.."skeleton/caijin/caijin"
    self.jackpotSkeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    self.jackpotSkeletonNode:setLocalZOrder(-1)
    self.jackpotNode:addChild( self.jackpotSkeletonNode )
    self:playJackpotSkeletonAnimation(1)
	self:setJackpotMoney(0)
	--下注倒计时
	self:hideBetTimer()
	--区域
	self.winDot:setVisible(false)
	self.loseDot:setVisible(false)
	self.qinglongAreaClass = AreaClass.new(self.qinglongArea,1,self.winDot,self.loseDot)
	self.baihuAreaClass = AreaClass.new(self.baihuArea,2,self.winDot,self.loseDot)
	self.zhuqueAreaClass = AreaClass.new(self.zhuqueArea,3,self.winDot,self.loseDot)
	self.xuanwuAreaClass = AreaClass.new(self.xuanwuArea,4,self.winDot,self.loseDot)
	self:setBetAreaEnabled(false)
	--筹码
	self.chipsClass = ChipsClass.new(self.chipsPanel)
	-- self.chipsClass:setVisible(false)
	--结算
	self.resultClass = ResultClass.new(self.resultPanel)
	-- self.resultClass:setVisible(false)
	--popup
	self.popupClass = PopupClass.new(self.popupPanel)
	--等待下一局
	self:hideWaitting()
	self.stopImg:setVisible(false)
	--绑定电池节点
	self:bindBatteryNode(self.batteryNode)
	self:updateBattery()
end

--进入场景
function C:onEnterTransitionFinish()
	C.super.onEnterTransitionFinish(self)
	PLAY_MUSIC(GAME_BRNN_SOUND_RES.."brnn_bgmusic.mp3")
end

--退出场景
function C:onExitTransitionStart()
	self:hideBetTimer()
	self:hideWaitting()
	self.bankerClass:destroy()
	self.bankerClass = nil
	self.qinglongAreaClass:destroy()
	self.qinglongAreaClass = nil
	self.baihuAreaClass:destroy()
	self.baihuAreaClass = nil
	self.zhuqueAreaClass:destroy()
	self.zhuqueAreaClass = nil
	self.xuanwuAreaClass:destroy()
	self.xuanwuAreaClass = nil
	self.chipsClass:destroy()
	self.chipsClass = nil
	for i,v in ipairs(self.playerClassArr) do
		v:destroy()
	end
	self.playerClassArr = nil
	self.resultClass = nil
	self.popupClass = nil
	if self.bankerListLayer then
		self.bankerListLayer:destroy()
		self.bankerListLayer:release()
		self.bankerListLayer = nil
	end
	if self.jackpotLayer then
		self.jackpotLayer:destroy()
		self.jackpotLayer:release()
		self.jackpotLayer = nil
	end
	if self.playerListLayer then
		self.playerListLayer:destroy()
		self.playerListLayer:release()
		self.playerListLayer = nil
	end
	if self.zoushiLayer then
		self.zoushiLayer:destroy()
		self.zoushiLayer:release()
		self.zoushiLayer = nil
	end
	STOP_MUSIC()
	self:restoreMusicVol()
	C.super.onExitTransitionStart(self)
end

--降低背景音乐音量
function C:reduceMusicVol()
	local percent = GET_MUSIC_VOLUME()
	if percent < 40 then
		return
	end
	percent = percent*0.5
	SET_MUSIC_VOLUME(percent,false)
end

--还原背景音乐音量
function C:restoreMusicVol()
	local percent = GET_MUSIC_VOLUME()
	SET_MUSIC_VOLUME(percent)
end

--充值动画
function C:playRechargeAni()
	if self.rechargeBtn then
		utils:createTimer("brnn.rechargea.ani",8,function()
			local array = {}
			array[#array+1] = cc.ScaleTo:create(0.2,1.2) --0.2秒由最小到最大
		    array[#array+1] = cc.ScaleTo:create(0.1,0.9) --0.1秒由最大到第二小
		    array[#array+1] = cc.ScaleTo:create(0.1,1.1) --0.1秒由第二小到第二大
		    array[#array+1] = cc.ScaleTo:create(0.1,1) --0.1秒由第二大到正常
			local action = transition.sequence(array)
			self.rechargeBtn:runAction(action)
		end)
	end
end

--点击返回
function C:onClickBackBtn( event )
	local text = "您当前已投注，不能退出游戏！"
	if self.model.isBanker then
		printInfo(">>>>>点击返回>>>>>11>>")
		text = "您正在坐庄，不能退出游戏！"
	end
	-- local text = "您当前已投注，退出游戏系统会自动帮您托管，不影响金币结算，确定退出游戏吗？"
	-- if self.model.isBanker then
	-- 	text = "您正在坐庄，确定退出游戏吗？"
	-- end
	self:touchBack(text)
end

--点击规则
function C:onClickHelpBtn( event )
	self:showRule()
end

--点击设置
function C:onClickSettingsBtn( event )
	self:showSettings()
end

--点击充值
function C:onClickRechargeBtn( event )
	self:touchRecharge()
end

--点击我要上庄
function C:onClickUpBankerBtn( event )
	if self.bankerListLayer == nil then
		self.bankerListLayer = BankerListLayer.new()
		self.bankerListLayer.upCallback = handler(self,self.onClickBankerListUpBtn)
		self.bankerListLayer.downCallback = handler(self,self.onClickBankerListDownBtn)
		self.bankerListLayer:retain()
	end
	self.bankerListLayer:show(self.model.bankerList,self.model.inBankerList,self.model.bankerNeed)
end

--刷新等待上庄列表
function C:refreshBankerList()
	local inBankerList = self.model.isBanker or self.model.inBankerList
	self.bankerListLayer:reload(self.model.bankerList,inBankerList)
end

--点击下庄(场景顶部下庄按钮，自己是庄)
function C:onClickDownBankerBtn( event )
	if self.model.bankerId == self.model.myInfo["playerid"] then
		self.core:applyOffBanker()
	end
end

--点击上庄列表我要上庄按钮(申请上庄)
function C:onClickBankerListUpBtn()
	self.core:applyOnBanker()
end

--点击上庄列表我要下庄按钮(取消申请下庄或者下庄)
function C:onClickBankerListDownBtn()
	if self.model.bankerId == self.model.myInfo["playerid"] then
		self.core:applyOffBanker()
	else
		self.core:cancelApplyOnBanker()
	end
end

--点击奖池
function C:onClickJackpotBtn( event )
	if self.jackpotLayer == nil then
		self.jackpotLayer = JackpotLayer.new()
		self.jackpotLayer:retain()
	end
	self.jackpotLayer:show()
end

function C:reloadRewardPlayerList( dataArr )
	if self.jackpotLayer == nil then
		self.jackpotLayer = JackpotLayer.new()
		self.jackpotLayer:retain()
	end
	self.jackpotLayer:reloadRewardPlayerList(dataArr)
end

function C:addRewardPlayer( info )
	if self.jackpotLayer == nil then
		self.jackpotLayer = JackpotLayer.new()
		self.jackpotLayer:retain()
	end
	self.jackpotLayer:addRewardPlayer(info)
end

--点击庄头像
function C:onClickBanker( event )
	if self.model.bankerInfo == nil then
		return
	end
	local info = {}
	info["playerid"] = self.model.bankerInfo["playerid"]
	info["headid"] = self.model.bankerInfo["headid"]
	info["nickname"] = self.model.bankerInfo["nickname"]
	info["money"] = self.model.bankerInfo["money"]
	info["city"] = self.model.bankerInfo["city"]
	info["wxheadurl"] = self.model.bankerInfo["wxheadurl"]
	self.popupClass:show(info,9)
end

--点击自己头像
function C:onClickSelf( event )
	--local info = {}
	--info["playerid"] = self.model.myInfo["playerid"]
	--info["headid"] = self.model.myInfo["headid"]
	--info["nickname"] = self.model.myInfo["nickname"]
	--info["money"] = self.model.myInfo["money"]
	--info["city"] = self.model.myInfo["city"]
	--info["wxheadurl"] = self.model.myInfo["wxheadurl"]
	--self.popupClass:show(info,7)
end

--点击其他玩家头像
function C:onClickPlayer( event )
	local seatId = event.target:getTag()
	local info = {}
	info["playerid"] = self.playerClassArr[seatId].info["playerid"]
	info["headid"] = self.playerClassArr[seatId].info["headid"]
	info["nickname"] = self.playerClassArr[seatId].info["name"]
	info["money"] = self.playerClassArr[seatId].info["coin"]
	info["city"] = self.playerClassArr[seatId].info["city"]
	info["wxheadurl"] = self.playerClassArr[seatId].info["wxheadurl"]
	self.popupClass:show(info,seatId)
end

--点击筹码按钮
function C:onClickBetBtn( event )
	local index = event.target:getTag()
	printInfo(">>>>>>>>>点击筹码按钮>>>>>>>>>"..index)
	self.model.currentChip = self.model.BET_CONFIGS[index]
	self.model.currentChipLevel = index
	self.model.lastSelectedChipLevel = index
	self:setAllChipBtnSelected(false)
	self:setChipBtnSelected(index,true)
end

--点击续押按钮
function C:onClickXuyaBtn( event )
	self.core:followHistoryBet()
	self:setXuyaBtnEnabled(false)
end

--点击走势按钮
function C:onClickZoushiBtn( event )
	if self.zoushiLayer == nil then
		self.zoushiLayer = ZoushiLayer.new()
		self.zoushiLayer:retain()
	end
	self.zoushiLayer:show()
end

function C:reloadHistory( dataArr )
	self.qinglongAreaClass:refreshHistory(dataArr)
	self.baihuAreaClass:refreshHistory(dataArr)
	self.zhuqueAreaClass:refreshHistory(dataArr)
	self.xuanwuAreaClass:refreshHistory(dataArr)
	if self.zoushiLayer == nil then
		self.zoushiLayer = ZoushiLayer.new()
		self.zoushiLayer:retain()
	end
	self.zoushiLayer:refreshHistory(dataArr)
end

function C:addHistory( data )
	if self.zoushiLayer == nil then
		self.zoushiLayer = ZoushiLayer.new()
		self.zoushiLayer:retain()
	end
	self.zoushiLayer:addHistory(data)
	self.qinglongAreaClass:addHistory(data)
	self.baihuAreaClass:addHistory(data)
	self.zhuqueAreaClass:addHistory(data)
	self.xuanwuAreaClass:addHistory(data)
end

--点击在线玩家
function C:onClickOnlineBtn( event )
	if self.playerListLayer == nil then
		self.playerListLayer = PlayerListLayer.new()
		self.playerListLayer.requestCallback = handler(self,self.requestPlayerList)
		self.playerListLayer:retain()
	end
	self.playerListLayer:show()
end

function C:requestPlayerList( page )
	self.core:requestAllPlayerList(page)
end

function C:responsePlayerList( info )
	if self.playerListLayer and self.playerListLayer.responseCallback then
		self.playerListLayer.responseCallback(info)
	end
end

--上庄需要金币
function C:setUpBankerNeedMoney( money )
	local text = "上庄需要"..utils:moneyString(money)
	self.upBankerLabel:setString(text)
end

--设置奖池奖金
function C:setJackpotMoney( money )
	self.lastJackpotMoney = money
	local str = utils:moneyString(money)
	self.jackpotLabel:setString(str)
	local scale = 96/self.jackpotLabel:getContentSize().width
	scale = math.min(scale,1)
	self.jackpotLabel:setScale(scale)
	if self.jackpotLayer == nil then
		self.jackpotLayer = JackpotLayer.new()
		self.jackpotLayer:retain()
	end
	self.jackpotLayer:setJackpotMoney(money)
end

--设置奖池动画 1=daiji | 2=shoudou
function C:playJackpotSkeletonAnimation( ctype )
	if ctype == 2 then
		self.jackpotSkeletonNode:setAnimation(0,"shoudou",false)
		utils:delayInvoke("brnn.jackpot",1.4,function()
			self.jackpotSkeletonNode:setAnimation(0,"daiji",true)
		end)
	else
		self.jackpotSkeletonNode:setAnimation(0,"daiji",true)
	end
end

--点击下注区域
function C:onClickQinglong(event)
	if event.name == "ended" then
		self:selfBetChip(1)
	end
end

function C:onClickBaihu(event)
	if event.name == "ended" then
		self:selfBetChip(2)
	end
end

function C:onClickZhuque(event)
	if event.name == "ended" then
		self:selfBetChip(3)
	end
end

function C:onClickXuanwu(event)
	if event.name == "ended" then
		self:selfBetChip(4)
	end
end

function C:selfBetChip( area )
	self:setXuyaBtnEnabled(false)
	self.model.lastHadBet = true
	self.model.isGaming = true
	self.core:sendBet(area,self.model.currentChip)
	self.model:addMyLastBet(area,self.model.currentChip)
	self.model:addPlayerBet(self.model.myInfo["playerid"],area,self.model.currentChip)
	local money = self.model.myInfo["money"] - self.model.currentChip
	if money < 0 then
		money = 0
	end
	self.model.myInfo["money"] = money
	local canbet = self.model.selfCanBetMoney - self.model.currentChip
	if canbet < 0 then
		canbet = 0
	end
	self.model.selfCanBetMoney = canbet
	self.myBlanceLabel:setString(utils:moneyString(money))
	self.chipsClass:throwOneChip(7,area,self.model.currentChipLevel)
	self:updateChipBtnStatus(self.model.currentChipLevel)
	-- self:updateMyBetChips()
	--丢星星
	if self.playerClassArr[1].info and self.playerClassArr[1].info["playerid"] == self.model.myInfo["playerid"] then
		local flags = self.model:getHadFlyLuckyStar(area)
		if flags == false then
			self.chipsClass:flyLuckyStar(area,true)
			self.model:setHadFlyLuckyStar(area)
		end
	end
	--甩头
	self:selfShakeHead()
end

--自己甩头
function C:selfShakeHead()
    if self.isSelfShaking == false then
        self.isSelfShaking = true
        local move1 = CCMoveTo:create(0.04,cc.p(70, 50))
        local move2 = CCMoveTo:create(0.04,cc.p(50,50))
        local delay = CCDelayTime:create(0.02)
        local callFun = CCCallFunc:create(function ()
            self.isSelfShaking = false
        end)
        self.myHead:runAction(transition.sequence({move1,move2,delay,callFun}))
    end
end

--在线玩家甩头
function C:onlineShakeHead()
    if self.isOnlineShaking == false then
        self.isOnlineShaking = true
        local posX = self.onlineBtn:getPositionX()
        local posY = self.onlineBtn:getPositionY()
        local move1 = CCMoveTo:create(0.04,cc.p(posX-20, posY+20))
        local move2 = CCMoveTo:create(0.04,cc.p(posX,posY))
        local delay = CCDelayTime:create(0.02)
        local callFun = CCCallFunc:create(function ()
            self.isOnlineShaking = false
        end)
        self.onlineBtn:runAction(transition.sequence({move1,move2,delay,callFun}))
    end
end

function C:updateMyBetChips()
	local money = self.model:getPlayerBetChips(self.model.myInfo["playerid"],1)
	self.qinglongAreaClass:setMyChips(money)
	money = self.model:getPlayerBetChips(self.model.myInfo["playerid"],2)
	self.baihuAreaClass:setMyChips(money)
	money = self.model:getPlayerBetChips(self.model.myInfo["playerid"],3)
	self.zhuqueAreaClass:setMyChips(money)
	money = self.model:getPlayerBetChips(self.model.myInfo["playerid"],4)
	self.xuanwuAreaClass:setMyChips(money)
end

function C:updateMyAreaBetChips( area, money, change )
	if area == 1 then
		self.qinglongAreaClass:setMyChips(money,change)
	elseif area == 2 then
		self.baihuAreaClass:setMyChips(money,change)
	elseif area == 3 then
		self.zhuqueAreaClass:setMyChips(money,change)
	elseif area == 4 then
		self.xuanwuAreaClass:setMyChips(money,change)
	end
end

--显示在桌玩家
function C:showTablePlayerList( infos )
	for i=1,6 do
		self.playerClassArr[i]:setVisible(false)
	end
	for i=1,6 do
		local info = infos[i]
		if info then
			self.playerClassArr[i]:show(info)
		end
	end
end

--更新玩家金币
function C:updatePlayerMoney( playerId, coin )
	if playerId == self.model.myInfo["playerid"] then
		local money = utils:moneyString(coin)
		self.myBlanceLabel:setString(money)
	end

	if playerId == self.model.bankerId then
		self.bankerClass:updateBlance(coin)
		if self.model.bankerInfo then
			self.model.bankerInfo["money"] = coin
		end
	end

	for i=1,6 do
		local playerClass = self.playerClassArr[i]
		if playerClass.info and playerClass.info["playerid"] == playerId then
			playerClass:updateBlance(coin)
			break
		end
	end
end

--显示金币不足50元不能下注
function C:showBetNeedTips()
	self.bottomTips:setVisible(true)
	self:setBetAreaEnabled(false)
	self:setAllChipBtnSelected(false)
	self:setAllChipBtnEnabled(false)
	self:setXuyaBtnEnabled(false)
end

function C:hideBetNeedTips()
	self.bottomTips:setVisible(false)
end

--设置是否可以下注
function C:setBetAreaEnabled( enabled )
	self.qinglongArea:setTouchEnabled(enabled)
	self.baihuArea:setTouchEnabled(enabled)
	self.zhuqueArea:setTouchEnabled(enabled)
	self.xuanwuArea:setTouchEnabled(enabled)
end

--更新按钮面值
function C:updateChipBtnText()
	for i=1,5 do
		local key = string.format("betBtn%d",i)
		local text = utils:moneyString(self.model.BET_CONFIGS[i])
		self[key]:getChildByName("label"):setString(text)
	end
	self.chipsClass:updateChipsText(self.model.BET_CONFIGS)
end

--更新最大可点击下注按钮
function C:updateChipBtnStatus( selectedIndex )
	local status = {false,false,false,false,false}
	local maxIndex = 0
	local money = self.model.selfCanBetMoney
	if money >= self.model.BET_CONFIGS[5] then
		status = {true,true,true,true,true}
		maxIndex = 5
	elseif money >= self.model.BET_CONFIGS[4] then
		status = {true,true,true,true,false}
		maxIndex = 4
	elseif money >= self.model.BET_CONFIGS[3] then
		status = {true,true,true,false,false}
		maxIndex = 3
	elseif money >= self.model.BET_CONFIGS[2] then
		status = {true,true,false,false,false}
		maxIndex = 2
	elseif money >= self.model.BET_CONFIGS[1] then
		status = {true,false,false,false,false}
		maxIndex = 1
	end
	for i=1,5 do
		self:setChipBtnEnabled(i,status[i])
	end

	if selectedIndex == nil or selectedIndex == 0 or selectedIndex > maxIndex then
		selectedIndex = maxIndex
	end
	if selectedIndex > 0 then
		self.bottomTips:setVisible(false)
		self:setAllChipBtnSelected(false)
		self:setChipBtnSelected(selectedIndex,true)
		self.model.currentChipLevel = selectedIndex
		self.model.currentChip = self.model.BET_CONFIGS[self.model.currentChipLevel]
	else
		self.model.currentChip = 0
		self.model.currentChipLevel = 0
		self:setAllChipBtnSelected(false)
		self:setBetAreaEnabled(false)
		self:setXuyaBtnEnabled(false)
	end
end

--设置续押按钮
function C:setXuyaBtnEnabled( enabled )
	self.xuyaBtn:setEnabled(enabled)
end

--下注按钮是否选中
function C:setAllChipBtnSelected( selected )
	for i=1,5 do
		self:setChipBtnSelected(i,selected)
	end
end

function C:setChipBtnSelected( index, selected )
	local key = string.format("betBtn%d",index)
	local chipBtn = self[key]
	chipBtn:getChildByName("selected"):setVisible(selected)
	if selected then
		chipBtn:setPositionY(64)
	else
		chipBtn:setPositionY(54)
	end
end

--筹码按钮是否可点击
function C:setAllChipBtnEnabled( enabled )
	for i=1,5 do
		self:setChipBtnEnabled(i,enabled)
	end
end

function C:setChipBtnEnabled( index, enabled )
	local key = string.format("betBtn%d",index)
	local chipBtn = self[key]
	if enabled then
		chipBtn:setOpacity(255)
	else
		chipBtn:setOpacity(102)
	end
	--chipBtn:setEnabled(enabled)
	chipBtn:setTouchEnabled(enabled)
end

--显示等待下一局
function C:showWaitting()
	self:playDotAni(self.waittingImg)
end

function C:hideWaitting()
	self.waittingImg:stopAllActions()
	self.waittingImg:setVisible(false)
end

--播放点动画
function C:playDotAni( node )
	node:stopAllActions()
	node:setVisible(true)
	local dot1 = node:getChildByName("dot_1")
	local dot2 = node:getChildByName("dot_2")
	local dot3 = node:getChildByName("dot_3")
	local array = {}
	local intervaltime = 0.5
	array[1] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
	array[2] = cc.DelayTime:create(intervaltime)
	array[3] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(false)
	end)
	array[4] = cc.DelayTime:create(intervaltime)
	array[5] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(true)
	end)
	array[6] = cc.DelayTime:create(intervaltime)
	array[7] = cc.CallFunc:create(function()
		dot1:setVisible(false)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
	array[8] = cc.DelayTime:create(intervaltime)
	local repeatAni = cc.RepeatForever:create(cc.Sequence:create(array))
    node:runAction(repeatAni)
end

--显示开始动画
function C:showStartAni()
	local strAnimName = GAME_BRNN_ANIMATION_RES.."skeleton/start/start2"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setPosition(cc.p(display.cx,display.cy))
    skeletonNode:setAnimation(0,"animation",false)
    self:addChild( skeletonNode )
    local array = {}
    array[1] = cc.DelayTime:create(1.2)
    array[2] = cc.CallFunc:create(function()
    	skeletonNode:removeFromParent(true)
    end)
    skeletonNode:runAction(cc.Sequence:create(array))
    PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_start.mp3")
    PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_show.mp3")
    self:reduceMusicVol()
end

--显示VS动画
function C:showVsAni()
	local strAnimName = GAME_BRNN_ANIMATION_RES.."skeleton/vs/skeleton"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setPosition(cc.p(display.cx,display.cy))
    skeletonNode:setAnimation(0,"animation",false)
    self:addChild( skeletonNode )
    utils:delayInvoke("brnn.vsani",1.2,function()
    	skeletonNode:removeFromParent(true)
    end)
    PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_dingdang.mp3")
end

--显示下注倒计时
function C:showBetTimer( time )
	self:hideBetTimer()
	if time < 1 then
		return
	end
	self.zhuangTips:setVisible(false)
	self.betTimer:setVisible(true)
	self.betTimer:getChildByName("label"):setString(string.format("%02d",time))
	utils:createTimer("brnn.BetTimer",1,function()
		local count = tonumber(self.betTimer:getChildByName("label"):getString()) or 0
		count = count - 1
		self.betTimer:getChildByName("label"):setString(string.format("%02d",count))
		if count <= 5 then
			PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_countdown.mp3")
		end
		if count < 0 then
			self:hideBetTimer()
		end
	end)
	self:reduceMusicVol()
end

function C:hideBetTimer()
	utils:removeTimer("brnn.BetTimer")
	self.betTimer:setVisible(false)
	self.zhuangTips:setVisible(true)
end

--显示停止下注动画
function C:showStopAni()
	-- local strAnimName = GAME_BRNN_ANIMATION_RES.."skeleton/end/skeleton"
    -- local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    -- skeletonNode:setPosition(cc.p(display.cx,display.cy))
    -- skeletonNode:setAnimation(0,"animation",false)
    -- self:addChild( skeletonNode )
    -- utils:delayInvoke("brnn.stopani",1.2,function()
    -- 	skeletonNode:removeFromParent(true)
    -- end)
    PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_stop.mp3")
	PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_show.mp3")
	self.stopImg:setVisible(true)
	local width = self.stopImg:getContentSize().width
	local posY = display.cy+40
	self.stopImg:setPosition(cc.p(-width/2,posY))
	local array = {}
	array[#array+1] = cc.EaseBackOut:create(cc.MoveTo:create(0.5, cc.p(568, posY)))
	array[#array+1] = cc.DelayTime:create(0.5)
	array[#array+1] = cc.EaseBackIn:create(cc.MoveTo:create(0.5, cc.p( 1136+width/2, posY)))
	array[#array+1] = cc.CallFunc:create(function()
		self.stopImg:setVisible(false)
	end)
	self.stopImg:runAction( cc.Sequence:create( array ) )
end

--发牌动画
function C:sendPokersAni( info )
	local array = {}
	local delay = 0.16
	array[1] = cc.CallFunc:create(function()
		self:sendBankerPokers(info["zhuang"],true)
	end)
	array[2] = cc.DelayTime:create(delay)
	array[3] = cc.CallFunc:create(function()
		self:sendAreaPokers(1,info["east"],true)
	end)
	array[4] = cc.DelayTime:create(delay)
	array[5] = cc.CallFunc:create(function()
		self:sendAreaPokers(2,info["south"],true)
	end)
	array[6] = cc.DelayTime:create(delay)
	array[7] = cc.CallFunc:create(function()
		self:sendAreaPokers(3,info["west"],true)
	end)
	array[8] = cc.DelayTime:create(delay)
	array[9] = cc.CallFunc:create(function()
		self:sendAreaPokers(4,info["north"],true)
	end)
	self.areaPanel:runAction(cc.Sequence:create(array))
end

--立即发牌
function C:sendPokersImm( info )
	self:sendBankerPokers(info["zhuang"],false)
	self:sendAreaPokers(1,info["east"],false)
	self:sendAreaPokers(2,info["south"],false)
	self:sendAreaPokers(3,info["west"],false)
	self:sendAreaPokers(4,info["north"],false)
end

--发庄家牌
function C:sendBankerPokers( pokers, animation )
	local temp = pokers
	if pokers["cards"] then
		temp = pokers["cards"]
	end
	self.bankerClass:setPokerData(temp)
	if animation then
		self.bankerClass:sendPokerAni()
	else
		self.bankerClass:sendPokerImm()
	end
end

--发其他区域的牌
function C:sendAreaPokers( area, pokers, animation )
	local areaClass = nil
	if area == 1 then
		areaClass = self.qinglongAreaClass
	elseif area == 2 then
		areaClass = self.baihuAreaClass
	elseif area == 3 then
		areaClass = self.zhuqueAreaClass
	elseif area == 4 then
		areaClass = self.xuanwuAreaClass
	end
	if areaClass == nil then
		return
	end
	local temp = pokers
	if pokers["cards"] then
		temp = pokers["cards"]
	end
	areaClass:setPokerData(temp)
	if animation then
		areaClass:sendPokerAni()
	else
		areaClass:sendPokerImm()
	end
end

function C:openPokers( info, lefttime )
	self.qinglongAreaClass:hideFireAni()
	self.baihuAreaClass:hideFireAni()
	self.zhuqueAreaClass:hideFireAni()
	self.xuanwuAreaClass:hideFireAni()
	local time = 7
	if lefttime then
		time = lefttime
	end
	local array = {}
	local delay = 1
	--庄
	if time <= 6 then
		delay = 0
	else
		delay = 1
	end
	array[#array+1] = cc.DelayTime:create(delay)
	array[#array+1] = cc.CallFunc:create(function()
		local pokers = info["zhuang"]["cards"]
		local ctype = info["zhuang"]["emtype"]
		local niun = info["zhuang"]["niun"]
		local typeName = self.logic:getPokerTypeArmatureName(ctype,niun)
		local key = self.logic:getTypeBeiKey(ctype)
		local typeBei = self.model.TYPE_BEI_CONFIGS[key] or 0
		self.bankerClass:setPokerData(pokers,typeName,typeBei)
		self.bankerClass:openThreePokers()
		if time > 6 then
			self:playTypeSound(typeName)
		end
	end)
	--青龙
	if time <= 5 then
		delay = 0
	else
		delay = 1
	end
	array[#array+1] = cc.DelayTime:create(delay)
	array[#array+1] = cc.CallFunc:create(function()
		local pokers = info["east"]["cards"]
		local ctype = info["east"]["emtype"]
		local niun = info["east"]["niun"]
		local typeName = self.logic:getPokerTypeArmatureName(ctype,niun)
		local key = self.logic:getTypeBeiKey(ctype)
		local typeBei = self.model.TYPE_BEI_CONFIGS[key] or 0
		self.qinglongAreaClass:setPokerData(pokers,typeName,typeBei)
		self.qinglongAreaClass:openThreePokers()
		--0表示庄输 1表示庄赢
		if info["east"]["win"] == 0 then
			self.resultClass:showVictory(1)
		end
		if time > 5 then
			self:playTypeSound(typeName)
		end
	end)
	--白虎
	if time <= 4 then
		delay = 0
	else
		delay = 1
	end
	array[#array+1] = cc.DelayTime:create(delay)
	array[#array+1] = cc.CallFunc:create(function()
		local pokers = info["south"]["cards"]
		local ctype = info["south"]["emtype"]
		local niun = info["south"]["niun"]
		local typeName = self.logic:getPokerTypeArmatureName(ctype,niun)
		local key = self.logic:getTypeBeiKey(ctype)
		local typeBei = self.model.TYPE_BEI_CONFIGS[key] or 0
		self.baihuAreaClass:setPokerData(pokers,typeName,typeBei)
		self.baihuAreaClass:openThreePokers()
		--0表示庄输 1表示庄赢
		if info["south"]["win"] == 0 then
			self.resultClass:showVictory(2)
		end
		if time > 4 then
			self:playTypeSound(typeName)
		end
	end)
	--朱雀
	if time <= 3 then
		delay = 0
	else
		delay = 1
	end
	array[#array+1] = cc.DelayTime:create(delay)
	array[#array+1] = cc.CallFunc:create(function()
		local pokers = info["west"]["cards"]
		local ctype = info["west"]["emtype"]
		local niun = info["west"]["niun"]
		local typeName = self.logic:getPokerTypeArmatureName(ctype,niun)
		local key = self.logic:getTypeBeiKey(ctype)
		local typeBei = self.model.TYPE_BEI_CONFIGS[key] or 0
		self.zhuqueAreaClass:setPokerData(pokers,typeName,typeBei)
		self.zhuqueAreaClass:openThreePokers()
		--0表示庄输 1表示庄赢
		if info["west"]["win"] == 0 then
			self.resultClass:showVictory(3)
		end
		if time > 3 then
			self:playTypeSound(typeName)
		end
	end)
	--玄武
	if time <= 2 then
		delay = 0
	else
		delay = 1
	end
	array[#array+1] = cc.DelayTime:create(delay)
	array[#array+1] = cc.CallFunc:create(function()
		local pokers = info["north"]["cards"]
		local ctype = info["north"]["emtype"]
		local niun = info["north"]["niun"]
		local typeName = self.logic:getPokerTypeArmatureName(ctype,niun)
		local key = self.logic:getTypeBeiKey(ctype)
		local typeBei = self.model.TYPE_BEI_CONFIGS[key] or 0
		self.xuanwuAreaClass:setPokerData(pokers,typeName,typeBei)
		self.xuanwuAreaClass:openThreePokers()
		--0表示庄输 1表示庄赢
		if info["north"]["win"] == 0 then
			self.resultClass:showVictory(4)
		end
		if time > 2 then
			self:playTypeSound(typeName)
		end
	end)
	self.areaPanel:runAction(cc.Sequence:create(array))
end

function C:playTypeSound( typeName )
	if typeName == "meiniu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull0.mp3")
	elseif typeName == "niuyi" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull1.mp3")
	elseif typeName == "niuer" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull2.mp3")
	elseif typeName == "niusan" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull3.mp3")
	elseif typeName == "niusi" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull4.mp3")
	elseif typeName == "niuwu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull5.mp3")
	elseif typeName == "niuliu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull6.mp3")
	elseif typeName == "niuqi" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull7.mp3")
	elseif typeName == "niuba" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull8.mp3")
	elseif typeName == "niujiu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull9.mp3")
	elseif typeName == "niuniu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_womanbull10.mp3")
	elseif typeName == "tonghua" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_tonghua.mp3")
	elseif typeName == "shunzi" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_woman_shunzi.mp3")
	elseif typeName == "hulu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_woman_hulu.mp3")
	elseif typeName == "wuhuaniu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_woman5flowerbull.mp3")
	elseif typeName == "zhadanniu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_woman4bomb.mp3")
	elseif typeName == "tonghuashun" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_woman_ths.mp3")
	elseif typeName == "wuxiaoniu" then
		PLAY_SOUND(GAME_BRNN_SOUND_RES.."woman/brnn_woman5littlebull.mp3")
	end
end

--结算
function C:doResult( info )
	self.areaPanel:stopAllActions()
	--更新电量
	self:updateBattery()
	--每个区域输赢
	self:doAreaResult(info)
	--走势
	if info["rec"] then
		self:addHistory(info["rec"])
	end
	--补金币
	self:doResultSupplementChips(info)
	local array = {}
	array[#array+1] = cc.DelayTime:create(1)
	array[#array+1] = cc.CallFunc:create(function()
		self:doResultRecoverChips(info,function()
			--奖池
			self:doResultJackpotInfo(info)
			--结算输赢
			self:doResultChangeMoney(info)
			--清除筹码
			self.model:clearBetPool()
			--恢复音量
			self:restoreMusicVol()
		end)
	end)
	self.resultClass.node:runAction(cc.Sequence:create(array))
end

--每个区域输赢
function C:doAreaResult( info )
	if info["other"] == nil then
		return
	end
	local win = nil
	for i,v in ipairs(info["other"]) do
		local seatId = self:getSeatIdByPlayerId(v["playerid"])
		if seatId == 7 then
			win = v["win"]
			break
		end
	end
	if win == nil or #win == 0 then
		return
	end
	dump(win,"doAreaResult")
	for k,v in pairs(win) do
		local area = tonumber(k)
		if area == 1 then
			self.qinglongAreaClass:setResultChips(v)
		elseif area == 2 then
			self.baihuAreaClass:setResultChips(v)
		elseif area == 3 then
			self.zhuqueAreaClass:setResultChips(v)
		elseif area == 4 then
			self.xuanwuAreaClass:setResultChips(v)
		end
	end
end

--奖池
function C:doResultJackpotInfo( info )
	local colorPool = info["ColorPool"]
	if colorPool == nil then
		return
	end
	--奖池晃动
	if #info["isZhuangBig"] == 4 then
		local shake = false
		for i=1,4 do
			local isBankerWin = info["isZhuangBig"][i] == 1
			if isBankerWin == false or (isBankerWin and self.model.bankerId ~= 0) then
				shake = true
				break
			end
		end
		if shake then
			self:playJackpotSkeletonAnimation(2)
		end
	end
	--更新奖池金额
	if colorPool["Value"] then
		self:setJackpotMoney(colorPool["Value"])
	end
	--添加头奖玩家
	if colorPool["Reward"] and info["bd"] then
		self:addRewardPlayer(info["bd"])
	end
	--中奖页面
	if colorPool["Reward"] then
		local emtype = 0
		local totalMoney = 0
		local myMoney = 0
		if colorPool["emtype"] then
			emtype = colorPool["emtype"]
		end
		if colorPool["PrevValue"] and colorPool["Value"] then
			totalMoney = math.abs(colorPool["Value"]-colorPool["PrevValue"])
		end
		if colorPool["Reward"]["list"] then
			for k,v in pairs(colorPool["Reward"]["list"]) do
				if v["playerid"] == self.model.myInfo["playerid"] then
					myMoney = v["value"]
					break
				end
			end
		end
		self:showReward( emtype, totalMoney, myMoney )
	end
end

--显示中奖页面
function C:showReward( emtype, totalMoney, myMoney )
	PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_baojiangchi.mp3")
	local rewardNode = display.newNode()
	-- skeleton
	local strAnimName = GAME_BRNN_ANIMATION_RES.."skeleton/reward/skeleton"
    local skeletonNode = sp.SkeletonAnimation:create(strAnimName .. ".json", strAnimName .. ".atlas", 1)
    skeletonNode:setPosition(568,display.cy+50)
    local width = skeletonNode:getContentSize().width
    local height = skeletonNode:getContentSize().height
    -- type
    local resname = self:getRewardEmtypeRes(emtype)
    if resname ~= "" then
    	local typeSprite = display.newSprite(resname)
    	typeSprite:setPosition(width/2,height/2+75)
    	skeletonNode:addChild(typeSprite)
    end
    -- total money
    local totalLabel = ccui.TextBMFont:create()
	totalLabel:setFntFile(GAME_BRNN_FONT_RES.."jiangchi_big_num.fnt")
	totalLabel:setString(utils:moneyString(totalMoney))
	totalLabel:setPosition(cc.p(width/2+15,height/2-50))
	skeletonNode:addChild(totalLabel)
	--my money
	if myMoney > 0 then
		local bgSprite = display.newSprite(GAME_BRNN_IMAGES_RES.."brnn_award_winning.png")
		bgSprite:setPosition(width/2,height/2-175)
		skeletonNode:addChild(bgSprite)
		local myLabel = ccui.TextBMFont:create()
		myLabel:setFntFile(COMMON_FONT_RES.."dt_jinbi_num.fnt")
		myLabel:setString(utils:moneyString(myMoney))
		myLabel:setPosition(width/2+140,height/2-178)
		skeletonNode:addChild(myLabel)
	end
    skeletonNode:setAnimation(0,"animation",false)
    rewardNode:addChild(skeletonNode)
    self.resultClass.node:addChild( rewardNode )
    local array = {}
    array[#array+1] = cc.DelayTime:create(3)
    array[#array+1] = cc.RemoveSelf:create()
    rewardNode:runAction(cc.Sequence:create(array))
end

function C:getRewardEmtypeRes( emtype )
	local resname = ""
	if emtype == BRNN.TYPE.TONGHUA then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_tonghua.png"
	elseif emtype == BRNN.TYPE.SHUNZI then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_shunzi.png"
	elseif emtype == BRNN.TYPE.HULU then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_hulu.png"
	elseif emtype == BRNN.TYPE.WUHUANIU then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_wuhuaniu.png"
	elseif emtype == BRNN.TYPE.ZHADAN then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_zhadan.png"
	elseif emtype == BRNN.TYPE.TONGHUASHUN then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_tonghuashun.png"
	elseif emtype == BRNN.TYPE.WUXIAONIU then
		resname = GAME_BRNN_IMAGES_RES.."brnn_award_tape_wuxiaoniu.png"
	end
	return resname
end

--补筹码
function C:doResultSupplementChips( info )
	if #info["isZhuangBig"] ~= 4 then
		return
	end
	local doAction = function( isBankerWin, area )
		if isBankerWin then
			--自己
			local money = self.model:getPlayerBetChips(self.model.myInfo["playerid"],area)
			if money > 0 then
				--补金币不用补实际筹码，表现而已,4个筹码
				if money > self.model:getMaxSupplementChips() then
					money = self.model:getMaxSupplementChips()
				end
				self.chipsClass:throwManyChips(7,area,money)
			end
			--在线
			money = self.model:getOnlinePlayerBetChips(area)
			if money > 0 then
				--补金币不用补实际筹码，表现而已,4个筹码
				if money > self.model:getMaxSupplementChips() then
					money = self.model:getMaxSupplementChips()
				end
				self.chipsClass:throwManyChips(8,area,money)
			end
			--在桌
			for seatId=1,6 do
				money = self:getTablePlayerBetChips(seatId,area)
				if money > 0 then
					--补金币不用补实际筹码，表现而已,4个筹码
					if money > self.model:getMaxSupplementChips() then
						money = self.model:getMaxSupplementChips()
					end
					self.chipsClass:throwManyChips(seatId,area,money)
				end
			end
		else
			local money = self.model:getAreaBetChips(area)
			if self.model.isBanker then
				self.chipsClass:throwManyChips(7,area,money)
			else
				self.chipsClass:throwManyChips(9,area,money)
			end
		end
	end
	for area=1,4 do
		local isBankerWin = info["isZhuangBig"][area] == 1
		doAction(isBankerWin,area)
	end
end

function C:isMySeatId( seatId )
	local flags = false
	if self.playerClassArr[seatId].info and self.playerClassArr[seatId].info["playerid"] == self.model.myInfo["playerid"] then
		flags = true
	end
	return flags
end

function C:isLuckyRichSame()
	local flags = false
	if self.playerClassArr[1].info and self.playerClassArr[2].info and self.playerClassArr[1].info["playerid"] == self.playerClassArr[2].info["playerid"] then
		flags = true
	end
	return flags
end

function C:getTablePlayerBetChips( seatId, area )
	if self:isMySeatId(seatId) then
		return 0
	end
	if seatId == 2 and self:isLuckyRichSame() then
		return 0
	end
	if self.playerClassArr[seatId].info then
		return self.model:getPlayerBetChips(self.playerClassArr[seatId].info["playerid"],area)
	else
		return 0
	end
end

function C:doResultRecoverChips	( info, callback )
	if #info["isZhuangBig"] ~= 4 then
		return
	end
	local flags = false
	for area=1,4 do
		local isBankerWin = info["isZhuangBig"][area] == 1
		if isBankerWin then
			local seatIds = {}
			if self.model.isBanker then
				table.insert(seatIds,7)
			else
				table.insert(seatIds,9)
			end
			if self.model.bankerId ~= 0 then
				--奖池
				table.insert(seatIds,10)
			end
			self.chipsClass:recoverChips(area,seatIds)
		else
			local seatIds = {}
			--奖池
			table.insert(seatIds,10)
			--自己
			local money = self.model:getPlayerBetChips(self.model.myInfo["playerid"],area)
			if money > 0 then
				table.insert(seatIds,7)
			end
			--在线
			money = self.model:getOnlinePlayerBetChips(area)
			if money > 0 then
				table.insert(seatIds,8)
			end
			--在桌
			for seatId=1,6 do
				money = self:getTablePlayerBetChips(seatId,area)
				if money > 0 then
					table.insert(seatIds,seatId)
				end
			end
			if flags == false then
				flags = true
				self.chipsClass:recoverChips(area,seatIds,callback)
			else
				self.chipsClass:recoverChips(area,seatIds)
			end
		end
	end
	if flags == false then
		if callback then
			callback()
		end
	end
	PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_win_bet.mp3")
end

function C:doResultChangeMoney( info )
	local moneyArr = {}
	if self.model.isBanker then
		moneyArr[7] = info["zhuang"]["nChange"]
	else
		moneyArr[9] = info["zhuang"]["nChange"]
	end
	if info["other"] then
		for i,v in ipairs(info["other"]) do
			local seatId = self:getSeatIdByPlayerId(v["playerid"])
			if moneyArr[seatId] then
				moneyArr[seatId] = moneyArr[seatId] + v["nChange"]
			else
				moneyArr[seatId] = v["nChange"]
			end
		end
	end
	self.resultClass:handleChangedMoney(moneyArr)
	if moneyArr[7] then
		if moneyArr[7] > 0 then
			PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_winner.mp3")
		else
			PLAY_SOUND(GAME_BRNN_SOUND_RES.."brnn_loser.mp3")
		end
	end
end

function C:getSeatIdByPlayerId( playerId )
	local seatId = 8
	for i=1,6 do
		if self.playerClassArr[i].info and self.playerClassArr[i].info["playerid"] == playerId then
			seatId = i
			break
		end
	end
	if playerId == self.model.myInfo["playerid"] then
		seatId = 7
	elseif playerId == self.model.bankerId then
		seatId = 9
	end
	return seatId
end

function C:flyLuckyStarIfNeeded()
	if self.playerClassArr[1].info then
		local money = self.model:getPlayerBetChips(self.playerClassArr[1].info["playerid"],1)
		local flags = self.model:getHadFlyLuckyStar(1)
		if money > 0  and flags == false then
			self.chipsClass:flyLuckyStar(1,false)
			self.model:setHadFlyLuckyStar(1)
		end
		money = self.model:getPlayerBetChips(self.playerClassArr[1].info["playerid"],2)
		flags = self.model:getHadFlyLuckyStar(2)
		if money > 0  and flags == false then
			self.chipsClass:flyLuckyStar(2,false)
			self.model:setHadFlyLuckyStar(2)
		end
		money = self.model:getPlayerBetChips(self.playerClassArr[1].info["playerid"],3)
		flags = self.model:getHadFlyLuckyStar(3)
		if money > 0  and flags == false then
			self.chipsClass:flyLuckyStar(3,false)
			self.model:setHadFlyLuckyStar(3)
		end
		money = self.model:getPlayerBetChips(self.playerClassArr[1].info["playerid"],4)
		flags = self.model:getHadFlyLuckyStar(4)
		if money > 0  and flags == false then
			self.chipsClass:flyLuckyStar(4,false)
			self.model:setHadFlyLuckyStar(4)
		end
	end
end

--断线重连创建筹码
function C:createAreaChips( area, money )
	self.chipsClass:createAreaChips(area,money)
end

--在桌子上的玩家丢金币
function C:tablePlayerThrowChips( playerId, area, chipLevel )
	local seatId = self:getSeatIdByPlayerId(playerId)
	if seatId < 1 or seatId > 6 then
		return
	end
	local flags = self.model:getHadFlyLuckyStar(area)
	if seatId == 1 and flags == false  then
		self.chipsClass:flyLuckyStar(area,true)
		self.model:setHadFlyLuckyStar(area)
	end
	self.chipsClass:throwOneChip( seatId, area, chipLevel )
	self.playerClassArr[seatId]:shakeHead()
end

--玩家续押
function C:followPlayerThrowChips( playerId, area, chips )
	local seatId = self:getSeatIdByPlayerId(playerId)
	local flags = self.model:getHadFlyLuckyStar(area)
	if seatId == 1 and flags == false  then
		self.chipsClass:flyLuckyStar(area,true)
		self.model:setHadFlyLuckyStar(area)
	end
	self.chipsClass:throwManyChips(seatId,area,chips)
	if 1 <= seatId and seatId <= 6 then
		self.playerClassArr[seatId]:shakeHead()
	elseif seatId == 7 then
		self:selfShakeHead()
	end
end

--在线玩家丢筹码
function C:onlinePlayerThrowChips( area,chips )
	self.chipsClass:throwManyChips(8,area,chips,function()
		self:onlineShakeHead()
	end)
end

--更新区域下注筹码
function C:updateAreaMoney( area, money )
	if area == 1 then
		self.qinglongAreaClass:setTotalChips(money)
	elseif area == 2 then
		self.baihuAreaClass:setTotalChips(money)
	elseif area == 3 then
		self.zhuqueAreaClass:setTotalChips(money)
	elseif area == 4 then
		self.xuanwuAreaClass:setTotalChips(money)
	end
end

--设置系统庄
function C:setBankerSystem()
	self.bankerClass:setBankerSystem()
	self.upBankerBtn:setVisible(true)
	self.downBankerBtn:setVisible(false)
	for i=1,5 do
		local key = string.format("betBtn%d",i)
		self[key]:setVisible(true)
	end
	self.xuyaBtn:setVisible(true)
end

--设置玩家庄
function C:setBankerPlayer( info )
	self.bankerClass:setBankerPlayer(info)
	if self.model.isBanker then
		self.upBankerBtn:setVisible(false)
		self.downBankerBtn:setVisible(true)
		for i=1,5 do
			local key = string.format("betBtn%d",i)
			self[key]:setVisible(false)
		end
		self.xuyaBtn:setVisible(false)
	else
		self.upBankerBtn:setVisible(true)
		self.downBankerBtn:setVisible(false)
		for i=1,5 do
			local key = string.format("betBtn%d",i)
			self[key]:setVisible(true)
		end
		self.xuyaBtn:setVisible(true)
	end
end

--清理桌子
function C:cleanDesktop()
	self.areaPanel:stopAllActions()
	self:hideWaitting()
	self.bankerClass:hidePoker()
	self.qinglongAreaClass:clean()
	self.baihuAreaClass:clean()
	self.zhuqueAreaClass:clean()
	self.xuanwuAreaClass:clean()
	self.chipsClass:clean()
	self.resultClass:clean()
end

return C