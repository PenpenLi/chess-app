local LhdScene = class("LhdScene",GameSceneBase)
local lhUIZoushi = import(".LhdZoushi")

local tipsBG = GAME_LHD_IMAGES_RES.."game/tishitiao_bg.png";
--csb资源路径
LhdScene.RESOURCE_FILENAME = "games/lhd/LhdScene.csb"

LhdScene.RESOURCE_BINDING = 
{
    
}

LhdScene.SELECT_CONFIG = {}

function LhdScene:ctor(core)
    print("龙虎斗构造=====================");
    LhdScene.super.ctor(self,core);
end

function LhdScene:initialize()
	LhdScene.super.initialize(self);
    self:initUI();
    self:initDeviceInfo();
    self:initSelfInfo();
    self:initPlayerList();
    self:initBankerList();
    self:initUserInfoView();
    self:initHistory();
    --self:playWaitAct();
end

--进入场景
function LhdScene:onEnterTransitionFinish()
	LhdScene.super.onEnterTransitionFinish(self);
    print("龙虎斗onEnter===============");
	PLAY_MUSIC(GAME_LHD_SOUND_RES.."bg.mp3");
	
end

--加载资源
function LhdScene:loadResource()
    LhdScene.super.loadResource(self);
    display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."card.plist",GAME_LHD_IMAGES_RES.."card.png");
	display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."game.plist",GAME_LHD_IMAGES_RES.."game.png");
	display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."banker.plist",GAME_LHD_IMAGES_RES.."banker.png");
    display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."history.plist",GAME_LHD_IMAGES_RES.."history.png");
    display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."playerList.plist",GAME_LHD_IMAGES_RES.."playerList.png");
    display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."userinfo.plist",GAME_LHD_IMAGES_RES.."userinfo.png");
    display.loadSpriteFrames(GAME_LHD_IMAGES_RES.."common.plist",GAME_LHD_IMAGES_RES.."common.png");
end

--释放资源
function LhdScene:unloadResource()
    display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."card.plist",GAME_LHD_IMAGES_RES.."card.png");
	display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."game.plist",GAME_LHD_IMAGES_RES.."game.png");
	display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."banker.plist",GAME_LHD_IMAGES_RES.."banker.png");
    display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."history.plist",GAME_LHD_IMAGES_RES.."history.png");
    display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."playerList.plist",GAME_LHD_IMAGES_RES.."playerList.png");
    display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."userinfo.plist",GAME_LHD_IMAGES_RES.."userinfo.png");
    display.removeSpriteFrames(GAME_LHD_IMAGES_RES.."common.plist",GAME_LHD_IMAGES_RES.."common.png");
    LhdScene.super.unloadResource(self);
end

function LhdScene:onExitTransitionStart()
    print("退出游戏场景----------------------------");
    local scheduler = cc.Director:getInstance():getScheduler();
    if self.betScheduler then
        scheduler:unscheduleScriptEntry(self.betScheduler);
        self.betScheduler = nil;
    end
    if self.deviceInfoSch then
        scheduler:unscheduleScriptEntry(self.deviceInfoSch);
        self.deviceInfoSch = nil;
    end
    if self.userBetMsgSch then
        scheduler:unscheduleScriptEntry(self.userBetMsgSch);
        self.userBetMsgSch = nil;
    end
    lhUIZoushi:clear();
    STOP_MUSIC();
	if self.updateScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateScheduler)
	end
    LhdScene.super.onExitTransitionStart(self);
end

--初始化UI
function LhdScene:initUI()
    --self.resultUI = {};
    self.Chips = {}
    self.Pokers = {}
    self.MyInfo = {};
    self.Players = {};
    self.ChipBtn = {};
    self.chipPos = {};
    self.TouchBet = {};
    self.resultTb = {};
    self.compareTb = {};
    self.BankerInfo = {};
    self.userWinChip = {};
    self.userInfo = {};
    self.historyListTb = {};
    self.userBetMsgTemp = {};
    self.selectScore = nil;
    self.bankerState = 0;     -- 0 没上庄，1 在上庄列表，2 已上庄
    self.selectChipIndex = nil;
    self.isStartBet = nil;      --是否开始下注
    self.isSelectChip = nil;    --是否手动选择筹码
    self.starArea = nil;        --神算子下注区域
    self.gameState = 0;         --当前游戏状态
    self.allUsers = {};
	self.flyingBets = {};
    self.lhdLocalPlayerList = {};

    --主要节点 
    self.img_bg = self:seekChild("Image_bg");
    self.img_bg:setPosition(cc.p(display.width/2, display.height/2));
    self.topNode = self:seekChild("topNode");
    self.centerNode = self:seekChild("centerNode");
    self.bottomNode = self:seekChild("bottomNode");
    self.playerNode = self.centerNode:getChildByName("playerNode");
    self.cardNode = self:seekChild("cardNode");
    self.rootNode = self:seekChild("rootNode");
    self.touchBetNode = self.centerNode:getChildByName("TouchBetNode");
    self.deviceNode = self.topNode:getChildByName("Image_device");
    self.deviceNode:setPosition(cc.p(display.width / 2, self.deviceNode:getPositionY()));

    self.chipsNode = self:seekChild("chipNode");
    self.helpNode = self:seekChild("helpNode");
    local helpScrollView = self.helpNode:getChildByName("help_BG"):getChildByName("ScrollView_1");
    helpScrollView:setScrollBarEnabled(false);
    self.menuBtn = self:seekChild("btn_setting");
    self.menuBtn:setPosition(cc.p(display.width / 2 - 50, self.menuBtn:getPositionY()));
    self.betTime = self:seekChild("img_clock"):hide();
    self.betTime.fnt_time = self.betTime:getChildByName("fnt_time");
    self.exitBtn = self:seekChild("btn_exit");
    self.exitBtn:setPosition(cc.p(-display.width / 2 + 50, self.exitBtn:getPositionY()));
    -- self.exitBtn1 = self:seekChild("btn_exit1");
    -- self.exitBtn1:setPosition(cc.p(-display.width / 2 + 50, self.exitBtn1:getPositionY()));
    --比牌
    self.cardCompareNode = self:seekChild("cardCompareNode"):hide();
    self.cardCompareNode:setPositionY(312)
    --开始下注和结束下注
    self.startBet = self.rootNode:getChildByName("startBet");
    self.startBet:setPosition(cc.p(-display.width / 2, display.height / 2));
    self.startBet.startPos = cc.p(self.startBet:getPosition());
    self.stopBet = self.rootNode:getChildByName("stopBet");
    self.stopBet:setPosition(cc.p(-display.width / 2, display.height / 2));
    self.stopBet.startPos = cc.p(self.stopBet:getPosition());

    --在线玩家列表
    self.img_BtnBet = self.bottomNode:getChildByName("img_btnBet");
    self.btnOnline = self.img_BtnBet:getChildByName("btn_online");
    --商城
    self.btnShop = self.img_BtnBet:getChildByName("btn_shop");
    self.btnShop:addClickEventListener(function()
        self:touchRecharge();
    end);
    --牌
    for i = 1, 2 do
        self.compareTb[i] = self.cardCompareNode:getChildByName("img_win_area_"..i);
        self.compareTb[i].card = self.compareTb[i]:getChildByName("card");
        self.compareTb[i].winnerIcon = self.cardCompareNode:getChildByName("img_winner_"..i):hide();
        self.Pokers[i] = self.cardNode:getChildByName("card_"..i):hide();
        self.Pokers[i].startPos = cc.p(self.Pokers[i]:getPosition());
        local movePos=self.cardNode:getChildByName("movePos_"..i)
        self.Pokers[i].moveToPos = cc.p(movePos:getPositionX(),-21);
    end
    self.compareTb[3] = {};
    self.compareTb[3].winnerIcon = self.cardCompareNode:getChildByName("img_winner_3"):hide();

    --庄家信息
    self.btnBanker = self:seekChild("btn_applyBanker");
    self.btnBanker:addClickEventListener(function()
        if self.bankerState == 0 or self.bankerState == 1 then
            self:onClickUpBanker();
        else
            local text = "您正在请求下庄，本局完成后，\n   您将不再坐庄，确认吗？"
            self:messageBox(text, function()
                self.core:offBanker();
            end);
        end
    end);

    self.BankerListNode = self:seekChild("BankerListNode");
    self.applyBankerTips = self:seekChild("applyBankerTips");
    self.applyBankerTips.nickName = self.applyBankerTips:getChildByName("text_ApplyBankerName");

    self.BankerInfo = self.topNode:getChildByName("Image_banker");
    self.sysBanker = self.topNode:getChildByName("Image_sysBanker");
    self.sysBanker.fnt_LoseScore = self.sysBanker:getChildByName("fnt_loseScore");
    self.sysBanker.fnt_WinScore = self.sysBanker:getChildByName("fnt_winScore");
    self.sysBanker.fnt_LoseScore.startPos = cc.p(self.sysBanker.fnt_LoseScore:getPosition());
    self.sysBanker.fnt_WinScore.startPos = cc.p(self.sysBanker.fnt_WinScore:getPosition());

    self.BankerInfo.head = self.BankerInfo:getChildByName("img_head");
    self.BankerInfo.nickName = self.BankerInfo:getChildByName("Text_userName");
    self.BankerInfo.score = self.BankerInfo:getChildByName("img_scoreBG"):getChildByName("Text_BankerScore");
    self.BankerInfo.bankerCount = self.BankerInfo:getChildByName("Text_bankerCount");
    self.BankerInfo.fnt_WinScore = self.BankerInfo:getChildByName("fnt_winScore");
    self.BankerInfo.fnt_WinScore:setLocalZOrder(20)
    self.BankerInfo.fnt_LoseScore = self.BankerInfo:getChildByName("fnt_loseScore");
    self.BankerInfo.fnt_LoseScore:setLocalZOrder(20)
    self.BankerInfo.fnt_WinScore.startPos = cc.p(self.BankerInfo.fnt_WinScore:getPosition());
    self.BankerInfo.fnt_LoseScore.startPos = cc.p(self.BankerInfo.fnt_LoseScore:getPosition());

    --自己的信息
    self.MyInfo = self:seekChild("myInfo");
    self.MyInfo.head = self.MyInfo:getChildByName("img_head");
    self.MyInfo.score = self.MyInfo:getChildByName("img_score_BG"):getChildByName("Text_score");
    self.MyInfo.nickname = self.MyInfo:getChildByName("Text_nickName");
    --self.MyInfo.img_bet = self.MyInfoNode:getChildByName("bet_img"):hide();
    --self.MyInfo.bet_label = self.MyInfo.img_bet:getChildByName("label");
    self.MyInfo.fnt_LoseScore = self.MyInfo:getChildByName("fnt_loseScore"):hide();
    self.MyInfo.fnt_LoseScore:setLocalZOrder(20)
    self.MyInfo.fnt_WinScore = self.MyInfo:getChildByName("fnt_winScore"):hide();
    self.MyInfo.fnt_WinScore:setLocalZOrder(20)
    self.MyInfo.fnt_LoseScore.startPos = cc.p(self.MyInfo.fnt_LoseScore:getPosition());
    self.MyInfo.fnt_WinScore.startPos = cc.p(self.MyInfo.fnt_WinScore:getPosition());
    self.MyInfo.head:addClickEventListener(function()
        local user = self:getUserInfo(self.MyInfo.playerid);
        if user and not user.isOpenUserInfo then
            user.isOpenUserInfo = true;
            self:setUserInfo(user);
            self:openUserInfo();
        end
    end);

    --其他玩家
    for i = 1, 6 do
        self.Players[i] = self.playerNode:getChildByName("player_"..i);
        self.Players[i].img_Null = self.Players[i]:getChildByName("img_Null");
        self.Players[i].userInfo = self.Players[i]:getChildByName("userinfo"):hide();
        self.Players[i].head = self.Players[i].userInfo:getChildByName("img_hede");
        self.Players[i].score = self.Players[i].userInfo:getChildByName("Text_Score");
        self.Players[i].nickName = self.Players[i].userInfo:getChildByName("img_nickBg"):getChildByName("Text_nickName");
        self.Players[i].fnt_LoseScore = self.Players[i]:getChildByName("fnt_loseScore"):hide();
        self.Players[i].fnt_LoseScore:setLocalZOrder(20)
        self.Players[i].fnt_WinScore = self.Players[i]:getChildByName("fnt_winScore"):hide();
        self.Players[i].fnt_WinScore:setLocalZOrder(20)
        self.Players[i].fnt_LoseScore.startPos = cc.p(self.Players[i].fnt_LoseScore:getPosition());
        self.Players[i].fnt_WinScore.startPos = cc.p(self.Players[i].fnt_WinScore:getPosition());
        self.Players[i].chairid = i;
        self.Players[i].startPos = cc.p(self.Players[i]:getPosition());
    end

    --筹码选择
    self.btnChipNode = self:seekChild("btnChipNode");
    for i = 1, 5 do
        self.ChipBtn[i] = self.btnChipNode:getChildByName("btn_select_"..i);
        self.ChipBtn[i].img_select = self.ChipBtn[i]:getChildByName("img_select"):hide();
        self.ChipBtn[i].startPos = cc.p(self.ChipBtn[i]:getPosition());
        self.ChipBtn[i]:addClickEventListener(function(sender)
            self:onClickSelectChip(sender, i);
        end);
    end
    for i = 1, 3 do
        self.chipPos[i] = self.chipsNode:getChildByName("chipPos_"..i);
        --点击下注
        self.TouchBet[i] = self.touchBetNode:getChildByName("touch_"..i):show();
        self.TouchBet[i].star = self.TouchBet[i]:getChildByName("img_star"):hide();
        self.TouchBet[i].chipPos = self.TouchBet[i]:getChildByName("chipPos");
        self.TouchBet[i].total_label = self.TouchBet[i]:getChildByName("Text_allBet"):setString(0);
        self.TouchBet[i].self_label = self.TouchBet[i]:getChildByName("Text_myBet"):setString(0);
        self.TouchBet[i]:addTouchEventListener(function(node, event_type)
			if event_type == cc.EventCode.BEGAN then
				if self.BankerInfo.playerid ~= self.MyInfo.playerid then
					if self.isStartBet then
						self:onClickBet(sender, i);
					end
				else
					LhdShowTips:show("您当前是庄家，无法下注", nil, tipsBG);
				end
			end
        end);
    end

    --在线玩家列表按钮
    self.btnOnline:addClickEventListener(function()
        self:onClickOnline();
    end);

    --菜单
    self.menuBtn:addClickEventListener(function()
        self:onClickMenuCallback();
    end);
    --退出
    self.exitBtn:addClickEventListener(function()
        self:onClickExitBtn();
    end);
    --帮助
    local helpBtn = self:seekChild("btn_help");
    helpBtn:setPosition(cc.p(display.width / 2 - 130, helpBtn:getPositionY()));
    helpBtn:addClickEventListener(function()
        self:onClickOpenHelp();
    end);
    local closeHelpBtn = self.helpNode:getChildByName("help_BG"):getChildByName("btn_close");
    closeHelpBtn:addClickEventListener(function()
        self:onClickCloseHelp();
    end);
end

--初始化自己的头像信息
function LhdScene:initSelfInfo()
    self.MyInfo.money = self.model.myInfo.money;
    SET_HEAD_IMG(self.MyInfo.head, self.model.myInfo.headid, self.model.myInfo.wxheadurl);
    self.MyInfo.nickname:setString(utils:nameStandardString(tostring(self.model.myInfo.nickname), 22, 165));
    self.MyInfo.score:setString(utils:moneyString(self.model.myInfo.money));
    self.MyInfo.playerid = self.model.myInfo.playerid;
end

--初始化设备信息
function LhdScene:initDeviceInfo()
    self.deviceWifi = self.deviceNode:getChildByName("wifi");
    self.device4G = self.deviceNode:getChildByName("4G");
    self.deviceBattery = self.deviceNode:getChildByName("Image_battery"):getChildByName("batteryBar");
    self.deviceTime = self.deviceNode:getChildByName("Text_Time");
    self.devicePing = self.deviceNode:getChildByName("Text_Ping");
    local scheduler = cc.Director:getInstance():getScheduler();
    if self.deviceInfoSch then
        scheduler:unscheduleScriptEntry(self.deviceInfoSch);
        self.deviceInfoSch = nil;
    end
    self.deviceInfoSch = scheduler:scheduleScriptFunc(function()
        local deviceNetWork = utils:getCurrentConnectType();
        if deviceNetWork == CONST_NET_TYPE_WIFI then
            self.deviceWifi:show();
            self.device4G:hide();
        elseif deviceNetWork == CONST_NET_TYPE_4G then
            self.device4G:show();
            self.deviceWifi:hide();
        end
        local batteryPercent = utils:getBatteryPercent();
        self.deviceBattery:setPercent(batteryPercent);
        local curTime = os.date("%H:%M", os.time());
        self.deviceTime:setString(curTime);
    end, 1, false);
end

--清除游戏数据
function LhdScene:cleanGameData()
    print("===================清除游戏数据==================");
    for i = 1, #self.compareTb do
        if self.compareTb[i].card then
            local pk = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."card/poker_0"..i..".png");
            self.compareTb[i].card:setSpriteFrame(pk:getSpriteFrame());
        end
        if self.compareTb[i].winnerIcon then
            self.compareTb[i].winnerIcon:hide();
        end
    end
    self.MyInfo.fnt_LoseScore:hide();
    self.MyInfo.fnt_LoseScore:setPosition(cc.p(self.MyInfo.fnt_LoseScore.startPos));
    self.MyInfo.fnt_WinScore:hide();
    self.MyInfo.fnt_WinScore:setPosition(cc.p(self.MyInfo.fnt_WinScore.startPos));
    self.BankerInfo.fnt_LoseScore:hide();
    self.BankerInfo.fnt_LoseScore:setPosition(cc.p(self.BankerInfo.fnt_LoseScore.startPos));
    self.BankerInfo.fnt_WinScore:hide();
    self.BankerInfo.fnt_WinScore:setPosition(cc.p(self.BankerInfo.fnt_WinScore.startPos));
    self.sysBanker.fnt_LoseScore:hide();
    self.sysBanker.fnt_LoseScore:setPosition(cc.p(self.sysBanker.fnt_LoseScore.startPos));
    self.sysBanker.fnt_WinScore:hide();
    self.sysBanker.fnt_WinScore:setPosition(cc.p(self.sysBanker.fnt_WinScore.startPos));
    for key, var in ipairs(self.Players) do
        if var then
            var.fnt_LoseScore:hide();
            var.fnt_WinScore:hide();
            var.fnt_LoseScore:setPosition(cc.p(var.fnt_LoseScore.startPos));
            var.fnt_WinScore:setPosition(cc.p(var.fnt_WinScore.startPos));
        end
    end
    for key, var in ipairs(self.TouchBet) do
        if var then
            var.total_label:setString(0);
            var.self_label:setString(0);
            var.star:hide();
        end
    end
    self.starArea = nil;
    self.userBetMsgTemp = {};
    self.cardCompareNode:setVisible(false);
    for i = 1, 5 do
        collectgarbage("collect");
    end
end

------------------------------------------------------------按钮回调------------------------------------------------------------
--打开帮助
function LhdScene:onClickOpenHelp()
    local helpBG = self.helpNode:getChildByName("help_BG");
    self:popUpEffect(helpBG, self.helpNode, true);
end

--关闭帮助
function LhdScene:onClickCloseHelp()
    local helpBG = self.helpNode:getChildByName("help_BG");
    self:popUpEffect(helpBG, self.helpNode, false);
end

--打开菜单
function LhdScene:onClickMenuCallback()
    self:showSettings();
end

--点击返回
function LhdScene:onClickExitBtn( event )
	local text = "您当前已下注，不能退出游戏！"
	if self.MyInfo.playerid == self.BankerInfo.playerid then
		text = "您正在坐庄，不能退出游戏！"
	    self:messageBox(text);
        return;
	end
    print("手动退出游戏：", self.MyInfo.isBankerList);
    if self.MyInfo.isBankerList then
        text = "您正在申请上庄，是否确认离开房间？";
        self:messageBox(text, function()
            self.core:quitGame();
        end);
        return;
    end
    if self.MyInfo.isBet then
	    self:messageBox(text);
        return;
    end
    self.core:quitGame();
end

--在线玩家列表
function LhdScene:onClickOnline()
    self:onClickOpenPlayerList();
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
        self.core:requestAllPlayerList();
    end)));
end

--历史记录
function LhdScene:onClickHistory()
    self:openHistory();
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
        self.core:requestHistory();
    end)));
end

--选择下注筹码
function LhdScene:onClickSelectChip(sender, index)
    print("点击选择筹码：", sender, "选择的筹码为：", self.SELECT_CONFIG[index]);
    self.isSelectChip = true;
    self.selectScore = self.SELECT_CONFIG[index];
    print("修改选择筹码数值444444：", self.selectScore);
    for key, var in ipairs(self.ChipBtn) do
        if var == sender then
            local startPos = var.startPos;
            local curPos = cc.p(var:getPosition());
            if startPos.y == curPos.y then
                var:setPosition(cc.p(var:getPositionX(), var:getPositionY() + 15));
            end
            var.img_select:show();
            self.selectChipIndex = key;
        else
            var:setPosition(cc.p(var.startPos));
            var.img_select:hide();
        end
    end
end

--点击下注区域
function LhdScene:onClickBet(sender, area)
    print("点击下注：", area, self.selectScore, self.model.myInfo.money);
	PLAY_SOUND(GAME_LHD_SOUND_RES.."click.mp3",false);
    if self.selectScore then
        local myMoney = self.MyInfo.money;
        if myMoney < self.model.betNeed then
            LhdShowTips:show("剩余金币不足"..utils:moneyString(self.model.betNeed).."元，无法下注", nil, tipsBG);
            return;
        end
        if myMoney >= self.selectScore then
            self.core:sendBet(area, self.selectScore);
            --yg：下注预先表现
            self.MyInfo.money = self.MyInfo.money - self.selectScore;
            local areaBet = (tonumber(self.TouchBet[area].self_label:getString()) or 0)+(self.selectScore/MONEY_SCALE)
            self.TouchBet[area].self_label:setString(areaBet);        --我在这个区域下的总注
            self.MyInfo.score:setString(utils:moneyString(self.MyInfo.money));
            self:deskChipMove(self.selectScore, self.MyInfo.head, area, function()
            end);
            self:autoSelectChip();
        end
    else
        if #self.SELECT_CONFIG <= 0 then
            LhdShowTips:show("获取服务器配置失败", nil, tipsBG);
            return;
        end
        LhdShowTips:show("请选择下注金币", nil, tipsBG);
    end
	PLAY_SOUND(GAME_LHD_SOUND_RES.."click.mp3",false);
end

--上庄按钮
function LhdScene:onClickUpBanker()
    self.core:requestBankerList();
    self:popUpEffect(self.bankerView, self.BankerListNode, true);
end

--------------------------------------------------工具方法-----------------------------------
--自动选择下注筹码
function LhdScene:autoSelectChip()
    local myMoney = self.MyInfo.money;
    print("自动选择下注筹码：", self.selectChipIndex, self.selectChipIndex);
    if not self.selectChipIndex then
        self.ChipBtn[1]:setEnabled(true);
        self.ChipBtn[1]:setBright(true);
        local chipBtnStartPos = self.ChipBtn[1].startPos;
        self.ChipBtn[1]:setPosition(cc.p(chipBtnStartPos.x, chipBtnStartPos.y + 15));
        self.ChipBtn[1].img_select:show();
        self.selectScore = self.SELECT_CONFIG[1];
        print("修改选择筹码数值333333：", self.selectScore);
        for i = 1, #self.SELECT_CONFIG do
            if myMoney >= self.SELECT_CONFIG[i] then
                self.ChipBtn[i]:setEnabled(true);
                self.ChipBtn[i]:setBright(true);
            else
                self.ChipBtn[i]:setEnabled(false);
                self.ChipBtn[i]:setBright(false);
                self.ChipBtn[i]:setPosition(cc.p(self.ChipBtn[i].startPos));
                self.ChipBtn[i].img_select:setVisible(false);
            end
        end
        print("第一次进入自动选择筹码：", self.selectScore);
        return;
    end
    self.selectScore = self.SELECT_CONFIG[self.selectChipIndex];
    print("修改选择筹码数值111111：", self.selectScore);
    if not self.isSelectChip or myMoney < self.selectScore then
        for i = 1, #self.SELECT_CONFIG do
            if myMoney >= self.SELECT_CONFIG[i] then
                self.ChipBtn[i]:setEnabled(true);
                self.ChipBtn[i]:setBright(true);
                self.selectChipIndex = i;
            else
                self.ChipBtn[i]:setEnabled(false);
                self.ChipBtn[i]:setBright(false);
                self.ChipBtn[i]:setPosition(cc.p(self.ChipBtn[i].startPos));
                self.ChipBtn[i].img_select:setVisible(false);
            end
        end
    end
    self.selectScore = self.SELECT_CONFIG[self.selectChipIndex];
    print("修改选择筹码数值2222222：", self.selectScore);
    if myMoney >= self.selectScore then
        for i = 1, #self.SELECT_CONFIG do
            if myMoney >= self.SELECT_CONFIG[i] then
                self.ChipBtn[i]:setEnabled(true);
                self.ChipBtn[i]:setBright(true);
            else
                self.ChipBtn[i]:setEnabled(false);
                self.ChipBtn[i]:setBright(false);
                self.ChipBtn[i]:setPosition(cc.p(self.ChipBtn[i].startPos));
                self.ChipBtn[i].img_select:setVisible(false);
            end
        end
        local chipBtnStartPos = self.ChipBtn[self.selectChipIndex].startPos;
        self.ChipBtn[self.selectChipIndex]:setPosition(cc.p(chipBtnStartPos.x, chipBtnStartPos.y + 15));
        self.ChipBtn[self.selectChipIndex].img_select:show();
    end
end

--通用弹出效果
function LhdScene:popUpEffect(node, parent, isOpen)
    if isOpen then
        node:setScale(0.1);
        local scale = cc.ScaleTo:create(0.3, 1.0);
        node:runAction(cc.Sequence:create(cc.EaseBackOut:create(scale)));
        parent:setVisible(true);
        node:setVisible(true);
    else
        local scale = cc.ScaleTo:create(0.3, 0.1);
        node:runAction(cc.Sequence:create(cc.EaseBackIn:create(scale), cc.CallFunc:create(function()
            if parent then
                parent:setVisible(false);
            else
                node:setVisible(false);
            end
        end)));
    end
end

--得到一张牌
function LhdScene:getPokerByCode(code, color)
    if code <= 0 or color <= 0 then
        return;
    end
    local cd = string.format("%02d", code);
    local sp = cc.Sprite:create(GAME_LHD_IMAGES_RES.."card/poker_"..color..cd..".png");
    if not sp then
        sp = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."card/poker_"..color..cd..".png");
    end
    return sp;
end

--翻牌动画
function LhdScene:pokerAction(poker, time, code, color, endfunc)
    local scale = poker:getScale();
	poker:runAction(cc.Sequence:create(cc.ScaleTo:create(time / 2, 0, scale, scale), cc.CallFunc:create(function()
        code = code or 0;
        local pk = self:getPokerByCode(code, color);
        if pk then
            local sp = poker;
            if not poker.setTexture then
                sp = poker:getVirtualRenderer():getSprite();
            end
            sp:setSpriteFrame(pk:getSpriteFrame());
		    poker:runAction(cc.Sequence:create(cc.ScaleTo:create(time / 2, scale, scale, scale), 
            cc.CallFunc:create(function () if endfunc then endfunc() end end)));
        end
	end)))
end

--获取一个用户的信息
function LhdScene:getUserInfo(playerid)
    return self.allUsers[playerid];
end

--设置选择筹码按钮启用禁用
function LhdScene:setChipBtnEnabled(isEnabled, isSelect)
    for key, var in ipairs(self.ChipBtn) do
        if var then
            var:setPosition(cc.p(var.startPos));
            var:setEnabled(isEnabled);
            var:setBright(isEnabled);
            if isSelect and key == self.selectChipIndex then
                var:setPosition(cc.p(var:getPositionX(), var:getPositionY() + 15));
            end
        end
    end
end

--------------------------------------------------动画效果----------------------------------
--开始游戏动画
function LhdScene:playStartAct()
    self:hideWaitAct();
    PLAY_SOUND(GAME_LHD_SOUND_RES.."alert.mp3");
    local spineNode = sp.SkeletonAnimation:create(GAME_LHD_ANIMATION_RES.."vs/vs.json", GAME_LHD_ANIMATION_RES.."vs/vs.atlas");
    local size = self.img_bg:getContentSize();
    spineNode:setPosition(cc.p(size.width / 2, size.height / 2+10));
    spineNode:setAnimation(0, "animation", false);
    self.rootNode:addChild(spineNode);
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.167), cc.CallFunc:create(function()
        spineNode:removeFromParent();
        spineNode = nil;
    end)));
end

--ASCII表中，3，4，5，6分别代表红桃，方块，梅花，黑桃。2代表无花色。0为错误牌
--大小对应为A 2 3 4 5 6 7 8 9 10 J Q K  小王 大王 听用牌 = 1 2 3 4 5 6 7 8 9 10 11 12 13  15 16 。 0为错误牌
--发牌动画
function LhdScene:sendCard()
    local delayTime = 0.2;
    local bgSize = self.img_bg:getContentSize();
    for key, var in ipairs(self.Pokers) do
        if var then
            var:setScale(0.1);
            var:setPosition(cc.p(0,0));--bgSize.width / 2, bgSize.height / 2));
            var:show();
            PLAY_SOUND(GAME_LHD_SOUND_RES.."sendcard.mp3");
            local spawn = cc.Spawn:create(cc.ScaleTo:create(0.15, 0.66), cc.MoveTo:create(0.15, cc.p(var.startPos)))
            var:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), spawn));
            delayTime = delayTime + 0.15;
        end
    end
end

--开始下注倒计时
function LhdScene:betTimeOut()
    local scheduler = cc.Director:getInstance():getScheduler();
    if self.betScheduler then
        scheduler:unscheduleScriptEntry(self.betScheduler);
        self.betScheduler = nil;
    end
    local timeOut = self.model.BET_TIME;
    self.betTime.fnt_time:setString(timeOut);
    self.betTime:show();
    self.betScheduler = scheduler:scheduleScriptFunc(function()
        --yg:调整读秒显示问题
        timeOut = timeOut - 1;
        self.betTime.fnt_time:setString(timeOut);
        if 0 < timeOut and timeOut <= 3 then
            PLAY_SOUND(GAME_LHD_SOUND_RES.."countdown.mp3");
        end
        --yg:提前一秒不能再下注，因为丢筹码预先表现了，放在最后一秒下注导致最后数据不一致
        if timeOut < 1 then
            self.isStartBet = false
        end
        if timeOut < 0 then
            self.betTime:hide();
            if self.betScheduler then
                scheduler:unscheduleScriptEntry(self.betScheduler);
                self.betScheduler = nil;
            end
        end
    end, 1, false);
end

--下注抖动
function LhdScene:userBetHeadMove(player)
    if not player.isMove then
        player.isMove = true;
        local movePos = 20;
        if player.chairid == 1 or player.chairid == 4 or player.chairid == 6  then
            movePos = -20;
        end
        local moveTo1 = cc.MoveTo:create(0.05,cc.p(player:getPositionX() + movePos, player:getPositionY()));
        local moveTo2 = cc.MoveTo:create(0.05, cc.p(player.startPos));
        local callFun = cc.CallFunc:create(function()
            player.isMove = false;
        end);
        player:runAction(cc.Sequence:create(moveTo1, moveTo2, callFun));
    end
end

--筹码飞动
function LhdScene:chipMove(score, player, area, call)
    self.Chips[area] = checktable(self.Chips[area]);
    --print("筹码飞动：", utils:moneyString(score));
    local chip = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."game/mortgage_fei_"..utils:moneyString(score)..".png");
    local nodePos = cc.p(self.chipsNode:convertToNodeSpace(player:convertToWorldSpace(player:getAnchorPointInPoints())));
    chip:setPosition(cc.p(nodePos.x, nodePos.y));
    local rotation = math.random(-50, 50);
    chip:setRotation(rotation);
    local chipPosNode = self.chipPos[area];
    local offsetX = chipPosNode:getPositionX();
    local offsetY = chipPosNode:getPositionY();
    local moveToPos = cc.p( math.random(offsetX - 70, offsetX + 70), math.random(offsetY - 55,offsetY + 55));
    --dump(moveToPos, "移动到的位置：");
    local myLabel = ccui.TextBMFont:create()
    myLabel:setFntFile(GAME_LHD_FONT_RES.."chip.fnt")
	myLabel:setString(utils:moneyString(score))
	myLabel:setPosition(28,29)
    myLabel:setScale(0.5)
	chip:addChild(myLabel)

    self.chipsNode:addChild(chip);

	local distance = cc.pGetLength(cc.pSub(nodePos,moveToPos))--nodePos.getDistance(moveToPos)
	local time = distance/2000
    local showSize = 1
    local moveSize = 1.2
    local putTime = 0.05
	chip:setScale(0.8)
    local seq =cc.Sequence:create(
    cc.MoveTo:create(time,moveToPos),
    cc.ScaleTo:create(putTime,showSize),
    cc.CallFunc:create(function()
        if call then
            call();
        end
    end)
    )
    local time1 =  math.min(0.10,time)  --allTime
    local seq1 = cc.Spawn:create(
    cc.RotateTo:create(time1,math.random(-50,50)+360*4),cc.ScaleTo:create(time1,moveSize)   
    )

    local action = cc.Spawn:create(seq1,seq) 
    local tag = 100 
    chip:stopActionByTag(tag)
    action:setTag(tag)
    chip:runAction(action);
	print(score)
	if score <= 5000 then
		if not self.isPlayingBet1Sound then
			self.isPlayingBet1Sound = true
			PLAY_SOUND(GAME_LHD_SOUND_RES.."bet2.mp3",false);
			utils:delayInvoke(GAME_LHD_SOUND_RES.."bet2.mp3",0.2,function ()
				self.isPlayingBet1Sound = false
			end)
		end
	else
		if not self.isPlayingBetSound then
			self.isPlayingBetSound = true
			PLAY_SOUND(GAME_LHD_SOUND_RES.."bet.mp3",false);
			utils:delayInvoke(GAME_LHD_SOUND_RES.."bet.mp3",0.2,function ()
				self.isPlayingBetSound = false
			end)
		end
	end

    chip.score = score;
    if #self.Chips[area] > 150 then
        local len = #self.Chips[area]  - 150;
        for key, var in pairs(self.Chips[area]) do
            if #self.Chips[area] < 150 then
                break;
            end
            if not tolua.isnull(var) then       --not tolua.isnull
                var:removeFromParent();
                var = nil;
            end
            table.remove(self.Chips[area], key);
        end
    end
    table.insert(self.Chips[area], chip);
end

function LhdScene:updateChip()
	local length = #self.flyingBets
    if length>0 then 
        local v = table.remove(self.flyingBets ,1)
		self:chipMove(v.score, v.player, v.area, v.callback)
    end 
end

--筹码飞动
function LhdScene:deskChipMove(score, player, area, call)
    self.Chips[area] = checktable(self.Chips[area]);
    --print("筹码飞动：", utils:moneyString(score));
    local chip = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."game/mortgage_fei_"..utils:moneyString(score)..".png");
    local nodePos = cc.p(self.chipsNode:convertToNodeSpace(player:convertToWorldSpace(player:getAnchorPointInPoints())));
    chip:setPosition(cc.p(nodePos.x, nodePos.y));
    local rotation = math.random(-50, 50);
    chip:setRotation(rotation);
    local chipPosNode = self.chipPos[area];
    local offsetX = chipPosNode:getPositionX();
    local offsetY = chipPosNode:getPositionY();
    local moveToPos = cc.p( math.random(offsetX - 70, offsetX + 70), math.random(offsetY - 55,offsetY + 55));
    --dump(moveToPos, "移动到的位置：");
    local myLabel = ccui.TextBMFont:create()
    myLabel:setFntFile(GAME_LHD_FONT_RES.."chip.fnt")
	myLabel:setString(utils:moneyString(score))
	myLabel:setPosition(28,29)
    myLabel:setScale(0.5)
	chip:addChild(myLabel)
    self.chipsNode:addChild(chip);

--	local movetime = math.random(50, 100) / 400.0
--    local moveTo = cc.MoveTo:create(movetime, cc.p(moveToPos));
--	local rotateAngle = math.random(20, 180)
--	local rotate_action = cc.RotateBy:create(0.3, rotateAngle)
--    local act = cc.Sequence:create(cc.EaseSineInOut:create(moveTo), cc.CallFunc:create(function()
--        if call then
--            call();
--        end
--    end));
--    chip:runAction(act);

	local distance = cc.pGetLength(cc.pSub(nodePos,moveToPos))--nodePos.getDistance(moveToPos)
	local time = distance/2000
    local showSize = 1
    local moveSize = 1.2
    local putTime = 0.05
	chip:setScale(0.8)
    local seq =cc.Sequence:create(
    cc.MoveTo:create(time,moveToPos),
    cc.ScaleTo:create(putTime,showSize),
    cc.CallFunc:create(function()
        if call then
            call();
        end
    end)
    )
    local time1 =  math.min(0.10,time)  --allTime
    local seq1 = cc.Spawn:create(
    cc.RotateTo:create(time1,math.random(-50,50)+360*4),cc.ScaleTo:create(time1,moveSize)   
    )

    local action = cc.Spawn:create(seq1,seq) 
    local tag = 100 
    chip:stopActionByTag(tag)
    action:setTag(tag)
    chip:runAction(action);

    chip.score = score;
    table.insert(self.Chips[area], chip);
    if score <= 5000 then
		if not self.isPlayingBet1Sound then
			self.isPlayingBet1Sound = true
			PLAY_SOUND(GAME_LHD_SOUND_RES.."bet2.mp3",false);
			utils:delayInvoke(GAME_LHD_SOUND_RES.."bet2.mp3",0.2,function ()
				self.isPlayingBet1Sound = false
			end)
		end
	else
		if not self.isPlayingBetSound then
			self.isPlayingBetSound = true
			PLAY_SOUND(GAME_LHD_SOUND_RES.."bet.mp3",false);
			utils:delayInvoke(GAME_LHD_SOUND_RES.."bet.mp3",0.2,function ()
				self.isPlayingBetSound = false
			end)
		end
	end
end

--拆分为筹码分数
function LhdScene:splitChipScore(score, selectChipTb)
    local publicScore = selectChipTb and selectChipTb or self.SELECT_CONFIG;
    local chipScore = score;
    local tempCount = nil;
    local userScore = {};
    for i = 1, 5 do
        tempCount = math.ceil(chipScore / publicScore[#publicScore + 1 - i]);
        chipScore = publicScore[#publicScore + 1 - i];
        for j = 1, tempCount do
            table.insert(userScore, chipScore);
        end
        chipScore = score % publicScore[#publicScore + 1 - i];
    end
    return userScore;
end

--拆分为筹码分数
function LhdScene:splitUserBetChipScore(score, count)
    local publicScore = self.SELECT_CONFIG;
    local chipScore = score;
    local tempCount = nil;
    local userScore = {};
    for i = 1, 5 do
        tempCount = math.floor(chipScore / publicScore[i]);
        chipScore = publicScore[i];
        --print("拆分筹码分数：", tempCount, i);
        if tonumber(tempCount) > count then
            tempCount = math.floor(count / i);
        end
        --print("拆分筹码循环：", tempCount, i);
        for j = 1, tempCount do
            table.insert(userScore, chipScore);
        end
        chipScore = score - (#userScore * 100);
    end
    return userScore;
end

--查找筹码
function LhdScene:findChip(playerid, score, areaIndex)
    if not areaIndex then
        return;
    end
    self.userWinChip[playerid] = checktable(self.userWinChip[playerid]);
    self.userWinChip[playerid][areaIndex] = checktable(self.userWinChip[playerid][areaIndex]);
    local chipScore = self:splitChipScore(score);
    --dump(chipScore, "玩家赢的筹码分数拆分：");
    for k, v in pairs(chipScore) do
        if self.Chips[areaIndex] then
            for key, var in pairs(self.Chips[areaIndex]) do
                if var.score == v then
                    if #chipScore >= #self.userWinChip[playerid][areaIndex] then
                        table.insert(self.userWinChip[playerid][areaIndex], var);
                        table.remove(self.Chips[areaIndex], key);
                        var = nil;
                    end
                end
            end
        end
    end
    if #self.userWinChip[playerid][areaIndex] <= 0 then
        for i = 1, #chipScore do
            local sp = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."game/mortgage_fei_"..utils:moneyString(chipScore[i])..".png");
            local chipPosNode = self.chipPos[areaIndex];
            local offsetX = chipPosNode:getPositionX();
            local offsetY = chipPosNode:getPositionY();
            local moveToPos = cc.p( math.random(offsetX - 70, offsetX + 70), math.random(offsetY - 55,offsetY + 55));
            sp:setPosition(moveToPos);
            local myLabel = ccui.TextBMFont:create()
            myLabel:setFntFile(GAME_LHD_FONT_RES.."chip.fnt")
	        myLabel:setString(utils:moneyString(chipScore[i]))
	        myLabel:setPosition(28,29)
            myLabel:setScale(0.5)
	        sp:addChild(myLabel)
            self.chipsNode:addChild(sp);
            table.insert(self.userWinChip[playerid][areaIndex], sp);
        end
    end
end

local allTime = 0;
--筹码飞回胜利的一方
function LhdScene:chipMoveToWinUser(chipTab, AreaIndex, pos, delay)
    if not chipTab or not chipTab[AreaIndex] then
        return;
    end
    if #chipTab[AreaIndex] > 0 then
        for key, var in pairs(chipTab[AreaIndex]) do
            if not tolua.isnull(var) then
                var:setLocalZOrder(9999);
                --local startPos=var:convertToWorldSpace(var:getAnchorPointInPoints())
                local startPos=cc.p(var:getPosition())
                --var:setPosition(startPos);
                --cc.EaseExponentialOut:create    EaseSineOut
                local delayGap = 0.015
                local speed = 1700
                local time = cc.pGetDistance(startPos, pos) / speed
                local mvPos = cc.p(0,0)
                if startPos.x > pos.x then 
                    mvPos.x = 20 
                else 
                    mvPos.x = -20
                end 
            
                if startPos.y > pos.y then 
                    mvPos.y = 20 
                else 
                    mvPos.y = -20
                end 
                local len = #chipTab[AreaIndex];
                
                local delay_time=delayGap * key
                if delay_time>0.6 and key~=len then
                    delay_time=math.random(10,50)/100
                elseif delay_time>0.6 and key==len then
                    delay_time=0.6
                end
                var:runAction(cc.Sequence:create(
                    CCDelayTime:create(delay_time),
                    cc.MoveBy:create(0.2, mvPos),
                    cc.MoveTo:create(time, cc.p(pos)),
                    cc.CallFunc:create(function()          
                        var:setVisible(false)        
                    end),
                    CCDelayTime:create(1.2),
                    cc.CallFunc:create(function()          
                        if key == len then
                            for k, v in ipairs(chipTab[AreaIndex]) do
                                if v then
                                    v:removeFromParent();
                                    v = nil;
                                end
                            end
                            chipTab[AreaIndex] = {};
                        end         
                    end)
                ));
            end
            if delay < 0.8 then
                delay = delay + 0.1;
                allTime = delay;
            end
        end
    end
end

--筹码飞回玩家列表
function LhdScene:chipMoveToPlayerList()
    --dump(self.Chips, "飞动到玩家列表：");
    local pos = cc.p(self.chipsNode:convertToNodeSpace(self.btnOnline:convertToWorldSpace(self.btnOnline:getAnchorPointInPoints())));
    for i = 1, 3 do
        self:chipMoveToWinUser(self.Chips, i, pos, 0.3);
    end
end

--回收筹码
function LhdScene:chipToUser(playerid, nChange, resultPos, player)
    if nChange > 0 then
        --print("\n\n{\n  在桌子上赢了的玩家userID为：", player.playerid, playerid, nChange);
        self:findChip(playerid, nChange, resultPos);
        local pos = cc.p(self.chipsNode:convertToNodeSpace(player.head:convertToWorldSpace(player.head:getAnchorPointInPoints())));
        --dump(pos, "  玩家筹码移动到的位置：");
        --dump(self.userWinChip[playerid], "  赢的玩家的筹码：");
        --print("\n}\n\n");
        self:chipMoveToWinUser(self.userWinChip[playerid], resultPos, pos, 0.3);
    end
end

--结算显示输赢
function LhdScene:resultWinCard(area, endFunc)
    print("播放哪个区域赢：", area);
    PLAY_SOUND(GAME_LHD_SOUND_RES.."win_"..area..".mp3");
    for i = 1, #self.compareTb do
        if i == area then
            self.compareTb[area].winnerIcon:setScale(5);
            self.compareTb[area].winnerIcon:show();
        else
            self.compareTb[i].winnerIcon:hide();
        end
    end
    local scaleTo = cc.ScaleTo:create(0.3, 1);
    self.compareTb[area].winnerIcon:runAction(cc.Sequence:create(scaleTo, cc.DelayTime:create(0.6), cc.CallFunc:create(function()
        if endFunc then
            endFunc();
        end
    end)));
end

--数字飞动
function LhdScene:flyNumber(node)
    --node:setScale(0.3);
    local scaleTo = cc.ScaleTo:create(0.4, 1.0);
    local moveTo = cc.MoveTo:create(0.4, cc.p(node:getPositionX(), node:getPositionY() + 40));
    local spawn = cc.Spawn:create(scaleTo, moveTo);
    local delay = cc.DelayTime:create(2.0);
    local call = cc.CallFunc:create(function()
        node:hide();
    end);
    local act = cc.Sequence:create(spawn, delay, call);
    node:runAction(act);
end

--结算数字飘动
function LhdScene:resultFlyNumber(player, playerid, nChange, playercoin)
    print("\n{\n数字飞动：在桌子上赢了的玩家userID为：", player.playerid, playerid, nChange);
    if player.playerid == playerid then
        print("数字飞动：", utils:moneyString(nChange), "\n}\n");
        if nChange > 0 then
            player.fnt_WinScore:setString("+"..utils:moneyString(nChange, 2));
            player.fnt_WinScore:show();
            self:flyNumber(player.fnt_WinScore);
        elseif nChange < 0 then
            player.fnt_LoseScore:setString(utils:moneyString(nChange, 2));
            player.fnt_LoseScore:show();
            self:flyNumber(player.fnt_LoseScore);
        end
        player.score:setString(utils:moneyString(playercoin));
    end
end

--结算特效
function LhdScene:resultAct(player)
    --print("播放胜利动画：", player);
    --local spineNode = sp.SkeletonAnimation:create("games/lhd/animation/win/defen.json", "games/lhd/animation/win/defen.atlas");
    local spineNode = sp.SkeletonAnimation:create(GAME_LHD_ANIMATION_RES.."yjgx/skeleton.json", GAME_LHD_ANIMATION_RES.."yjgx/yjgx.atlas");
    local pos = nil;
    if player.userInfo then
        pos = cc.p(player.userInfo:getPositionX(),player.userInfo:getPositionY()+8);
        print("pos = cc.p(player.userInfo:getPosition())=======", pos.x, pos.y);
    else
        pos = cc.p(player.head:getPositionX(),player.head:getPositionY()+8);
        print("pos = cc.p(player:getPosition())***********", pos.x, pos.y);
    end
    --dump(pos, "赢的玩家位置 ：");
    spineNode:setPosition(pos);
    --spineNode:setTimeScale(0.7);
    spineNode:setScale(0.85)
    spineNode:setAnimation(0, "animation", false);
    player:addChild(spineNode,18);
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
        spineNode:hide();
        spineNode:removeFromParent();
        spineNode = nil;
    end)));
end

--庄家数字飘动
function LhdScene:bankerResultFly(playerid, nChange, isAdd)
    local bankerFntNode = nil
    if playerid > 0 then
        bankerFntNode = isAdd and self.BankerInfo.fnt_WinScore or self.BankerInfo.fnt_LoseScore;
    else
        bankerFntNode = isAdd and self.sysBanker.fnt_WinScore or self.sysBanker.fnt_LoseScore;
    end
    bankerFntNode:show();
    print("庄家输赢：", bankerFntNode:isVisible(), utils:moneyString(nChange));
    local winMoney = (isAdd and "+" or "")..utils:moneyString(nChange, 2);
    print("字符串连接：", winMoney);
    bankerFntNode:setString(winMoney);
    self:flyNumber(bankerFntNode);
end

--结算飘字
function LhdScene:flyResultNumber(result)
    if not result.other then
        return ;
    end
    for i = 1, #result.other do
        if result.other[i].playerid == self.model.myInfo.playerid then
            self:chipToUser(result.other[i].playerid, result.other[i].nChange, result.resultPos, self.MyInfo);
            self.MyInfo.money = result.other[i].playercoin;
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.9), cc.CallFunc:create(function()
                if result.other[i].nChange > 0 then
                    self:resultAct(self.MyInfo);
                end
                self:resultFlyNumber(self.MyInfo, self.MyInfo.playerid, result.other[i].nChange, result.other[i].playercoin);
            end)));
        else
            for key, var in ipairs(self.Players) do
                if result.other[i].playerid == var.playerid then
                    self:chipToUser(result.other[i].playerid, result.other[i].nChange, result.resultPos, var);
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.9), cc.CallFunc:create(function()
                        if result.other[i].nChange > 0 then
                            self:resultAct(var);
                        end
                        self:resultFlyNumber(var, var.playerid, result.other[i].nChange, result.other[i].playercoin);
                    end)));
                end
            end
        end
    end
    --庄家
    if result.zhuang.nChange > 0 then
        --dump(self.userWinChip[result.zhuang.playerid], "庄家赢的筹码：");
        --print("庄家ID 为：", result.zhuang.playerid);
        local bankerNode = nil;
        if result.zhuang.playerid <= 0 then
            bankerNode = self.sysBanker;
        else
            bankerNode = self.BankerInfo;
        end
        for i = 1, 3 do
            self:findChip(result.zhuang.playerid, result.zhuang.nChange, i);
            local pos = cc.p(self.chipsNode:convertToNodeSpace(bankerNode:convertToWorldSpace(bankerNode:getAnchorPointInPoints())));
            self:chipMoveToWinUser(self.userWinChip[result.zhuang.playerid], i, pos, 0.3);
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.9), cc.CallFunc:create(function()
            if result.zhuang.playerid > 0 then
                self:resultAct(self.BankerInfo);
            end
            self:bankerResultFly(result.zhuang.playerid, result.zhuang.nChange, "+");
        end)));
    elseif result.zhuang.nChange < 0 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.9), cc.CallFunc:create(function()
            self:bankerResultFly(result.zhuang.playerid, result.zhuang.nChange);
        end)));
    end
    self.BankerInfo.score:setString(utils:moneyString(result.zhuang.playercoin));
    if result.zhuang.playerid == self.MyInfo.playerid then
        self.MyInfo.score:setString(utils:moneyString(result.zhuang.playercoin));
    end
    self:chipMoveToPlayerList();
    PLAY_SOUND(GAME_LHD_SOUND_RES.."win_bet.mp3");
end

--庄家更换动画
function LhdScene:userToBankerAct(nick)
    print("庄家切换动画=======================");
    self.applyBankerTips:setVisible(true);
    self.applyBankerTips.nickName:setString(utils:nameStandardString(tostring(nick), 31, 255));
    self.applyBankerTips:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
        self.applyBankerTips:setVisible(false);
    end)));
end

--------------------------------------------------消息回调----------------------------------
--保存玩家数据
function LhdScene:onSaveUserInfo(msg)
    for i = 1, #msg do
        self.allUsers[msg[i].playerid] = msg[i];
    end
    --请求玩家列表
    self.core:requestAllPlayerList();
end

--更新玩家数据
function LhdScene:onUpdateUserData(msg)
    for i = 1, #msg do
        local var = self.allUsers[msg[i].playerid];
        if var then
            var.money = msg[i].coin and msg[i].coin or msg[i].playercoin;
            var.headid = msg[i].headid and msg[i].headid or var.headid;
            var.nickname = msg[i].name and msg[i].name or var.nickname;
            if var.isOpenUserInfo then
                self:setUserInfo(var);
            end
        end
    end
end

--玩家进入
function LhdScene:onUserEnter(msg)
    local user = self:getUserInfo(msg.palyerid);
    if not user then
        self.allUsers[msg.playerid] = msg;
     end
end

--玩家离开
function LhdScene:onUserLeave(msg)
    local user = self.allUsers[msg.playerid];
    if user then
        table.remove(self.allUsers, msg.playerid);
        user = nil;
    end
end

--显示玩家信息
function LhdScene:onUpdateDeskUserInfo(msg)
    for key, var in ipairs(self.Players) do
        if var and msg[key] and msg[key].playerid > 0 then
            var.img_Null:hide();
            var.userInfo:show();
            local userinfo = self:getUserInfo(msg[key].playerid);
            SET_HEAD_IMG(var.head, msg[key].headid, userinfo and userinfo.wxheadurl or "");
            var.nickName:setString(utils:nameStandardString(tostring(msg[key].name), 13, 65));
            var.score:setString(utils:moneyString(msg[key].coin));
            var.playerid = msg[key].playerid;
            var.head:addClickEventListener(function()
                local user = self:getUserInfo(msg[key].playerid);
                if user and not user.isOpenUserInfo then
                    user.isOpenUserInfo = true;
                    self:setUserInfo(user);
                    self:openUserInfo();
                end
            end);
        else
            var.userInfo:hide();
            var.img_Null:show();
            var.playerid = nil;
        end
    end
end

--休息时间
function LhdScene:onSleep()
    local delayTime = 2.8;
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function()
        print("休息时间：", self.isChangeBanker, delayTime);
        if self.isChangeBanker then
            self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
                self:sendCard();
                self:hideWaitAct();
            end)));
            self.isChangeBanker = nil;
        else
            print("没有切换庄家发牌==================================");
            self:sendCard();
            self:hideWaitAct();
        end
    end)));
end

--开始下注
function LhdScene:onStartBet(msg)
    --self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
        self.startBet:setVisible(true);
        self:betTimeOut();
        --self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
        self:playStartAct();
        --end)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(function()
            self.isStartBet = true;
            PLAY_SOUND(GAME_LHD_SOUND_RES.."start.mp3");
            local size = self.img_bg:getContentSize();
            local moveTo1 = cc.MoveTo:create(0.3, cc.p(size.width / 2, size.height / 2));
            local moveTo2 = cc.MoveTo:create(0.3, cc.p(size.width + size.width / 2, size.height / 2));
            local delay = cc.DelayTime:create(0.5);
            self.startBet:runAction(cc.Sequence:create(cc.EaseExponentialOut:create(moveTo1), delay, cc.EaseExponentialIn:create(moveTo2), cc.CallFunc:create(function()
                self.startBet:setVisible(false);
                self.startBet:setPosition(cc.p(self.startBet.startPos));
            end)));
        end)));
    --end)));
end

--开始亮牌（停止下注）
function LhdScene:onStopBet(msg)
    --self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        PLAY_SOUND(GAME_LHD_SOUND_RES.."alert.mp3");
        self.isStartBet = false;
        self.stopBet:setVisible(true);
        local size = self.img_bg:getContentSize();
        local moveTo1 = cc.MoveTo:create(0.3, cc.p(size.width / 2, size.height / 2));
        local moveTo2 = cc.MoveTo:create(0.3, cc.p(size.width + size.width / 2, size.height / 2));
        local delay = cc.DelayTime:create(0.5);
        PLAY_SOUND(GAME_LHD_SOUND_RES.."stop.mp3");
        self.stopBet:runAction(cc.Sequence:create(cc.EaseExponentialOut:create(moveTo1), delay, cc.EaseExponentialIn:create(moveTo2), cc.CallFunc:create(function()
            self.stopBet:setVisible(false);
            self.stopBet:setPosition(cc.p(self.stopBet.startPos));
        end)));
    --end)));
end

--玩家下注
function LhdScene:onOtherUserBet()
    for key, var in pairs(self.userBetMsgTemp) do
            if var then
                if var.odds > 10000 then
                    local userBet = self:splitUserBetChipScore(var.odds, 3);
                    for k, v in ipairs(userBet) do
                        --self:chipMove(v, self.btnOnline, var.direction);
						table.insert(self.flyingBets,{score = v, player = self.btnOnline,area = var.direction})
                    end
                else
					table.insert(self.flyingBets,{score = var.odds, player = self.btnOnline,area = var.direction,callback = function()
                        self:setUserBetAreaInfo(var);
                    end})
--                    self:chipMove(var.odds, self.btnOnline, var.direction, function()
--                        self:setUserBetAreaInfo(var);
--                    end);
                end
                table.remove(self.userBetMsgTemp, key);
            end
        end
end

--桌子上玩家下注消息处理
function LhdScene:onDeskUserBetMsg(msg)
    if not self.updateScheduler then
        self.updateScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateChip), 0, false)
    end
    self:onUpdateUserBetUserInfo(msg);
    local player = nil;
    local playerNode = nil;
    if msg.playerid == self.model.myInfo.playerid then
        player = self.MyInfo.head;
        self.MyInfo.isBet = true;
        self.MyInfo.money = msg.chouma;
    else
        for userindex = 1, #self.Players do
            --print("在桌子上的玩家userID：", self.Players[userindex].playerid, msg.playerid);
            if msg.playerid == self.Players[userindex].playerid then
                player = self.Players[userindex];
                playerNode = self.Players[userindex];
                self.Players[userindex].score:setString(utils:moneyString(msg.chouma));
            end
        end
        if playerNode then
            self:userBetHeadMove(playerNode);
        end
    end
    if player == nil then
        --player = self.btnOnline;
        self:onOtherUserBet();
		self:onlineUserBetHeadMove();
        table.insert(self.userBetMsgTemp, msg);
        return;
    end
    --yg:已经预先表现
    if msg.playerid == self.model.myInfo.playerid then
        self:setUserBetAreaInfo(msg);
    else
        self:deskChipMove(msg.odds, player.head or player, msg.direction, function()
            self:setUserBetAreaInfo(msg);
        end);
    end
    self:shenSZBet(msg.playerid, msg.direction);
end

function LhdScene:onlineUserBetHeadMove()
	if not self.movingOnlineUserHead then
        self.movingOnlineUserHead = true;
        local movePosX = -20;
		local movePosY = 20;
		local startPos = cc.p(self.btnOnline:getPosition())

        local moveTo1 = cc.MoveTo:create(0.05,cc.p(startPos.x + movePosX, startPos.y+movePosY));
        local moveTo2 = cc.MoveTo:create(0.05, startPos);
        local callFun = cc.CallFunc:create(function()
            self.movingOnlineUserHead = false;
        end);
        self.btnOnline:runAction(cc.Sequence:create(moveTo1, moveTo2, callFun));
    end
end


--设置下注区域筹码数据显示
function LhdScene:setUserBetAreaInfo(msg)
    local areaAll = msg.dirctionall / MONEY_SCALE;
    local curAreaAll = self.TouchBet[msg.direction].total_label:getString();
    if tonumber(areaAll) > tonumber(curAreaAll) then
        self.TouchBet[msg.direction].total_label:setString(msg.dirctionall / MONEY_SCALE);     --这个区域下的总注
    end
    if msg.playerid == self.model.myInfo.playerid then
        self.TouchBet[msg.direction].self_label:setString(msg.buyall / MONEY_SCALE);        --我在这个区域下的总注
        self.MyInfo.score:setString(utils:moneyString(msg.chouma));
        self.model.myInfo.money = msg.chouma;
        self:autoSelectChip();
    end
end

--玩家下注同步玩家数据
function LhdScene:onUpdateUserBetUserInfo(msg)
    local var = self.allUsers[msg.playerid];
    if var then
        var.money = msg.chouma;
        if var.isOpenUserInfo then
            self:setUserInfo(var);
        end
    end
end

--神算子下注显示星
function LhdScene:shenSZBet(playerid, area)
    if playerid == self.Players[1].playerid then
        if not self.starArea then
            self.TouchBet[area].star:show();
            self.starArea = area;
        end
    end
end

--亮牌消息
function LhdScene:onLookCard(msg)
    local scheduler = cc.Director:getInstance():getScheduler();
    if self.userBetMsgSch then
        scheduler:unscheduleScriptEntry(self.userBetMsgSch);
        self.userBetMsgSch = nil;
    end
    if self.updateScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateScheduler)
        self.updateScheduler = nil;
	end
    for i = 1, #self.compareTb do
        self.compareTb[i].winnerIcon:hide();
    end
    --self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
        local tempMsg = {};
        tempMsg[1] = msg.long;
        tempMsg[2] = msg.hu;
        if not msg.long or not msg.hu then
            return;
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
            for i = 1, 2 do
                local pos = cc.p(self.Pokers[i].moveToPos);
                local moveTo = cc.MoveTo:create(0.3, cc.p(pos));
                local scaleTo = cc.ScaleTo:create(0.3, 1.0);
                local spawn = cc.Spawn:create(moveTo, scaleTo);
                local delay = cc.DelayTime:create(0.2);
                PLAY_SOUND(GAME_LHD_SOUND_RES.."flipcard.mp3");
                self.Pokers[i]:runAction(cc.Sequence:create(spawn, delay, cc.CallFunc:create(function()
                    self.cardCompareNode:setVisible(true);
                    self.Pokers[i]:hide();
                end)));
            end
        end)));
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.8), cc.CallFunc:create(function()
            local delayTime = 0.1;
            for key, var in ipairs(self.compareTb) do
                if var.card then
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function()
                        self:pokerAction(var.card, 0.5, tempMsg[key].number, tempMsg[key].color, function()
                            print("播放每个区域的点数：", tempMsg[key].number);
                            PLAY_SOUND(GAME_LHD_SOUND_RES.."lhb_p_"..tempMsg[key].number..".mp3");
                        end);
                    end)));
                    delayTime = delayTime + 1;
                end
            end
        end), cc.DelayTime:create(2.5), cc.CallFunc:create(function()
            local resultPos = nil;
            if msg.long.number > msg.hu.number then
                resultPos = 1;
            elseif msg.long.number < msg.hu.number then
                resultPos = 2;
            else
                resultPos = 3;
            end
            self:resultWinCard(resultPos);
        end)));
    --end)));
end

--结算
function LhdScene:onGameResult(msg)
    self.cardCompareNode:setVisible(false);
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
        self:flyResultNumber(msg);
        --更新历史记录
        self:addHistoryItem(msg.resultPos);
        self:updateResultTrend(msg.resultPos);
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
            local data = {};
            data.win = msg.resultPos;
            data.Value = msg.win_value;
            table.remove(self.historyListTb, 1);
            table.insert(self.historyListTb, data);
            --dump(self.historyListTb, "结算后设置胜率：")
            --self:setAreaWinRate(self.historyListTb, #self.historyListTb);
            --self:setHistoryViewData(data);
            if self.BankerInfo.playerid ~= self.MyInfo.playerid then
                self:autoSelectChip();
            end
            if msg.other then
                self:onUpdateUserData(msg.other);
            end
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function()
                self.core:requestAllPlayerList();
                self.isGameEnd = true;
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
                    self:cleanGameData();
                end)));
            end)));
            self.MyInfo.isBet = false;
        end)));
    end)));
end

------------------------------------------------------------玩家列表------------------------------------
function LhdScene:initPlayerList()
    self.playerListNode = self:seekChild("playerListNode");
    self.PlayerListBG = self.playerListNode:getChildByName("img_playerListBG");
    self.playerListView = self.PlayerListBG:getChildByName("playerListView");
    --self.curServiceUserCount = self.PlayerListBG:getChildByName("Text_tips"):setVisible(false);
    self.playerListView:setScrollBarEnabled(false);
    local btn_closePlayerList = self.PlayerListBG:getChildByName("btn_close");
    btn_closePlayerList:addClickEventListener(function()
        self:popUpEffect(self.PlayerListBG, self.playerListNode, false);
        self.isOpenPlayerList = nil;
    end);
end

function LhdScene:onClickOpenPlayerList()
    --self.playerListNode:setVisible(true);
    self:popUpEffect(self.PlayerListBG, self.playerListNode, true);
    self.isOpenPlayerList = true;
end

--初始化玩家列表数据
function LhdScene:initPlayerListData(msg)
    local tempTb = msg;
    --保存前六个玩家显示到桌子上
    local deskPlayerList = {};
    for i = 1, 6 do
        table.insert(deskPlayerList, msg[i]);
    end
    --table.remove(tempTb, 1);
    --dump(tempTb, "排序后的玩家列表：");
    --dump(deskPlayerList, "显示在桌子上的玩家：");
    if self.isGameEnd and not self.isOpenPlayerList then
        self:onUpdateDeskUserInfo(deskPlayerList);
        self.isGameEnd = nil;
        return;
    end
    self:onUpdateDeskUserInfo(deskPlayerList);

    --self.curServiceUserCount:setString("注：当前在线"..msg.curNum.."人，只显示50名");
    self.playerListData = tempTb;
    local tempNewPlayer = {};
    local sortList = {};
    for i = 1, #self.playerListData do
        local userinfo = self.playerListData[i];
        sortList[i] = userinfo.playerid;
        userinfo.sort = i;
        self.lhdLocalPlayerList[userinfo.playerid] = userinfo;
        tempNewPlayer[userinfo.playerid] = userinfo;
    end
    for key, var in pairs(self.lhdLocalPlayerList) do
        if not tempNewPlayer[key] then
            table.remove(self.lhdLocalPlayerList, key);
        end
    end
    
    local tempPlayerList = self.playerListView:getItems();
    local ItemNode = self.PlayerListBG:getChildByName("Item"):hide();
    for i = 1, #sortList do
        local user = self.lhdLocalPlayerList[sortList[i]];
        local item = nil;
        if i <= #tempPlayerList then
            self:setPlayerListData(self.playerListView:getItem(i-1), user);
        else
            item = ItemNode:clone():setVisible(false);
            item.img_ranking = item:getChildByName("img_ranking"):setVisible(i <= 9);
            item.head = item:getChildByName("img_head");
            item.userScore = item:getChildByName("img_userScore"):getChildByName("fnt_userScore");
            item.ranking = item:getChildByName("text_ranking"):setVisible(false);--系统字体排名
            item.fnt_ranking = item:getChildByName("fnt_ranking"):setVisible(i > 9);
            item.nickName = item:getChildByName("text_nickname");
            item.betScore = item:getChildByName("text_allbet");
            item.winScore = item:getChildByName("text_winscore");
            item.text_count = item:getChildByName("text_count");
            item.playerid = sortList[i];
            if i <= 9 then 
                item.img_ranking:loadTexture(GAME_LHD_IMAGES_RES.."playerList/rich_"..(i - 1)..".png", 1);
                item.img_ranking:ignoreContentAdaptWithSize(true);
            else
                item.fnt_ranking:setString("No."..i - 1);
            end
            if i <= 2 then
                --item:loadTexture(GAME_LHD_IMAGES_RES.."playerList/rank_cell_l.png", 1);
                item:loadTexture(GAME_LHD_IMAGES_RES.."playerList/rank_cell_d.png", 1);
            end
            self:setPlayerListData(item, user);
            self.playerListView:pushBackCustomItem(item);
        end
    end

    local len = #tempPlayerList - #sortList;

    if len > 0 then
        for i = 1, len do
            self.playerListView:removeLastItem();
        end
    end
end

--设置玩家列表数据
function LhdScene:setPlayerListData(item, usermsg)
    local userinfo = self:getUserInfo(usermsg.playerid);
    SET_HEAD_IMG(item.head, usermsg.headid, userinfo and userinfo.wxheadurl or "");
    item.userScore:setString(utils:moneyString(usermsg.coin));
    item.nickName:setString(utils:nameStandardString(tostring(usermsg.name), 24, 180));
    item.betScore:setString(utils:moneyString(usermsg.bet).."元");
    item.winScore:setString(usermsg.winnum.."局");
    item.text_count:setString("近20局");
    item:show();
    item.head:addClickEventListener(function()
        local user = self:getUserInfo(usermsg.playerid);
        if user and not user.isOpenUserInfo then
            user.isOpenUserInfo = true;
            self:setUserInfo(user);
            self:openUserInfo();
        end
    end);
end

-------------------------------------------------------------庄家和上庄列表-------------------------------------------
function LhdScene:initBankerList()
    self.bankerView = self.BankerListNode:getChildByName("img_bankerBG");
    self.bankerListView = self.bankerView:getChildByName("bankerListView");
    self.bankerListView:setScrollBarEnabled(false);
    self.bankerListCount = self.bankerView:getChildByName("text_curPlayer");
    self.bankerNeed = self.bankerView:getChildByName("text_bankerNeed");
    local btn_close = self.bankerView:getChildByName("btn_close");
    btn_close:addClickEventListener(function()
        self:popUpEffect(self.bankerView, self.BankerListNode, false);
    end);
    self.btn_MyApplyBanker = self.bankerView:getChildByName("btn_applyBanker");
    self.btn_MyApplyBanker:addClickEventListener(function()
        if self.bankerState == 0 then
            print("我要上庄：", self.model.myInfo.money, self.model.bankerNeed);
            if not self.model.bankerNeed then
                LhdShowTips:show("获取服务器配置失败，请重新登录", nil, tipsBG);
                return;
            end
            if self.model.myInfo.money >= self.model.bankerNeed then
                self.core:applyOnBanker();
            else
                LhdShowTips:show(utils:moneyString(self.model.bankerNeed).."元余额才可上庄，请充值", nil, tipsBG);
                return;
            end
        else
            if self.bankerState == 2 then
                local text = "您正在请求下庄，本局完成后，\n   您将不再坐庄，确认吗？"
                self:messageBox(text, function()
                    self.core:offBanker();
                end);
            else
                self.core:cancelApplyOnBanker();
            end
        end
    end);
end

--显示当前庄家信息
function LhdScene:onUpdateBankerInfo(msg, isOffLine)
    --dump(msg, "显示庄家信息：");
    if msg.zhuangid == self.MyInfo.playerid then
        self.bankerState = 2;
    else
        self.bankerState = 0;
    end
    if msg.zhuangturn == 0 and msg.zhuangname ~= "系统" and self.BankerInfo.playerid ~= msg.zhuangid and not isOffLine then
        self.isChangeBanker = true;
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2.2), cc.CallFunc:create(function()
        if msg.zhuangname ~= "系统" then
            self.BankerInfo:setVisible(true);
            self.sysBanker:setVisible(false);
            self.BankerInfo.nickName:setString(utils:nameStandardString(tostring(msg.zhuangname), 16, 102));--(msg.zhuangname);
        else
            self.BankerInfo:setVisible(false);
            self.sysBanker:setVisible(true);
        end
        print("庄家轮换：", msg.zhuangturn, msg.zhuangname, self.BankerInfo.playerid, msg.zhuangid, isOffLine);
        if msg.zhuangturn == 0 and msg.zhuangname ~= "系统" and self.BankerInfo.playerid ~= msg.zhuangid then
            if not isOffLine then
                self:userToBankerAct(msg.zhuangname);
            end
        end
        if msg.zhuangid == self.MyInfo.playerid then
            self.btnBanker:loadTextureNormal(GAME_LHD_IMAGES_RES.."game/an_shang2.png", 1);
            self.MyInfo.isBankerList = nil;
            self:setChipBtnEnabled(false);
        else
            --上庄的玩家不是我自己，切换按钮
            self.btnBanker:loadTextureNormal(GAME_LHD_IMAGES_RES.."game/an_shang.png", 1);
            if not self.MyInfo.isBankerList then
                self.btn_MyApplyBanker:loadTextureNormal(GAME_LHD_IMAGES_RES.."banker/sheng_an2.png", 1);
            end
            self:autoSelectChip();
        end
        self.BankerInfo.playerid = msg.zhuangid;
        self.BankerInfo.score:setString(utils:moneyString(msg.chouma));
        if msg.zhuangid > 0 then
            local userinfo = self:getUserInfo(msg.zhuangid);
            SET_HEAD_IMG(self.BankerInfo.head, msg.zhuangheadid, userinfo and userinfo.wxheadurl or "");
        end
        local bankerCount = msg.zhuangturn + 1;
        self.BankerInfo.bankerCount:setString("当前第 "..bankerCount.." 局");
        --点击庄家头像
        self.BankerInfo.head:addClickEventListener(function()
            local user = self:getUserInfo(self.BankerInfo.playerid);
            if user and not user.isOpenUserInfo then
                user.isOpenUserInfo = true;
                self:setUserInfo(user);
                self:openUserInfo();
            end
        end);
    end)));
end

--更新庄家列表
function LhdScene:onUpdateBankerList(msg)
    self.bankerListView:removeAllChildren();
    local ItemNode = self.bankerView:getChildByName("Item");
    local isMyUpBanke = nil;
    --dump(msg, "上庄列表：");
    if msg.list then
        local tempNewBankerList = {};
        for i = 1, #msg.list do
            local userinfo = msg.list[i];
            userinfo.sort = i;
            tempNewBankerList[userinfo.playerid] = userinfo;
        end
        local str = "当前排队"..#msg.list.."人(只显示前10名)";
        local len = #msg.list > 10 and 10 or #msg.list;
        for i = 1, len do
            if i <= len then
                local Item = ItemNode:clone();
                Item.rank = Item:getChildByName("text_No");
                Item.head = Item:getChildByName("img_head");
                Item.nickName = Item:getChildByName("text_nickname");
                Item.score = Item:getChildByName("img_goldBG"):getChildByName("text_userScore");

                self:setBankerListUserData(Item, msg, i);
                self.bankerListView:pushBackCustomItem(Item);
            end
        end
        local myUserInfo = tempNewBankerList[self.MyInfo.playerid];
        if myUserInfo then
            self.btn_MyApplyBanker:loadTextureNormal(GAME_LHD_IMAGES_RES.."banker/sheng_an.png", 1);
            self.bankerState = 1;
            self.MyInfo.isBankerList = true;
            isMyUpBanke = true;
            str = "当前排队"..#msg.list.."人(您当前排第"..myUserInfo.sort.."名)";
        end

        if not isMyUpBanke then
            self.bankerState = 0;
        end
        self.bankerListCount:setString(str);
    else
        if self.BankerInfo.playerid == self.MyInfo.playerid then
            isMyUpBanke = true;
        end
        if self.bankerState == 1 then
            self.bankerState = 0;
        end
        self.bankerListCount:setString("当前排队0人(只显示前10名)");
    end
    print("上庄队列：", self.bankerState, isMyUpBanke, self.BankerInfo.playerid, self.MyInfo.playerid);
    if not isMyUpBanke and self.bankerState == 0 then
        self.btn_MyApplyBanker:loadTextureNormal(GAME_LHD_IMAGES_RES.."banker/sheng_an2.png", 1);
    end
end

--设置庄家列表用户数据
function LhdScene:setBankerListUserData(Item, msg, index)
    Item.rank:setString("No."..index);
    local userinfo = self:getUserInfo(msg.list[index].playerid);
    SET_HEAD_IMG(Item.head, msg.list[index].headid, userinfo and userinfo.wxheadurl or "");
    Item.nickName:setString(utils:nameStandardString(tostring(msg.list[index].nickname), 18, 143));
    Item.score:setString(utils:moneyString(msg.list[index].coin));
    Item:show();
    Item.head:addClickEventListener(function()
        local user = self:getUserInfo(msg.list[index].playerid);
        if user and not user.isOpenUserInfo then
            user.isOpenUserInfo = true;
            self:setUserInfo(user);
            self:openUserInfo();
        end
    end);
end

------------------------------------------------------------历史记录------------------------------------------------------
function LhdScene:initHistory()
    --历史记录
    self.historyNode = self.bottomNode:getChildByName("historyNode");
    self.historyList = self.historyNode:getChildByName("historyList");
    self.historyList:setScrollBarEnabled(false);
    self.btnHistory = self.historyNode:getChildByName("btn_history");
    self.btnHistory:addClickEventListener(function()
        self:onClickHistory()
    end);
    --走势界面
    self.winRate = {};
    self.winAreaLong = 1;
    self.winAreaHu = 2;
    self.winAreaHe = 3;
    self.winAreaCount = 0;
    self.lastRoundArea = 0;
    self.continuousWin = 1;

    self.trendNode = self:seekChild("TrendNode"):show();
    self.lhResultPanel = self.trendNode:getChildByName("lhResultPanel"):setVisible(false);
    self.trendView = self.lhResultPanel:getChildByName("Result");
    local zoushi_Close = self.trendView:getChildByName("zoushi_Close");
    zoushi_Close:addClickEventListener(function()
        self:closeHistory();
    end);
    lhUIZoushi:initzoushiUI(self);
    --[[
    self.trendNode = self:seekChild("TrendNode");
    self.trendView = self.trendNode:getChildByName("img_historyBG");
    local winRateNode = self.trendView:getChildByName("img_areaBG");
    for i = 1, 2 do
        self.winRate[i] = winRateNode:getChildByName("loadBar_area_"..i);
        self.winRate[i].text_winRate = self.winRate[i]:getChildByName("text_winRate");
    end
    self.longHuTrendListView = self.trendView:getChildByName("longHuTrendListView");
    self.cardTypeTrendListView = self.trendView:getChildByName("cardTypeTrendListView");
    self.longHuTrendListView:setScrollBarEnabled(false);
    self.cardTypeTrendListView:setScrollBarEnabled(false);
    local btn_closeTrend = self.trendView:getChildByName("btn_close");
    btn_closeTrend:addClickEventListener(function()
        self:closeHistory();
    end);
    --]]
end

--显示主界面历史记录
function LhdScene:onUpdateHistoryIcon(msg)
    self.historyList:removeAllChildren();
    --local ItemNode = self.historyNode:getChildByName("Item");
    for key, var in ipairs(msg) do
        --local Item = ItemNode:clone();
        --local img_res = GAME_LHD_IMAGES_RES.."game/record_"..var.win..".png";
        --Item:loadTexture(img_res, 1);
        --Item:setVisible(true);
        --self.historyList:pushBackCustomItem(Item);
        self:addHistoryItem(var.win);
    end
    --self.historyList:jumpToRight()
end

--结算更新历史记录
function LhdScene:addHistoryItem(winArea)
    local ItemNode = self.historyNode:getChildByName("Item");
    local Item = ItemNode:clone();
    local img_res = GAME_LHD_IMAGES_RES.."game/record_"..winArea..".png";
    Item:loadTexture(img_res, 1);
    Item:setVisible(true);
    self.historyList:pushBackCustomItem(Item);
    self.historyList:jumpToRight();
end

--打开走势图
function LhdScene:openHistory()
    --self.trendNode:setVisible(true);
    self:popUpEffect(self.trendView, self.lhResultPanel, true);
end

--关闭走势图
function LhdScene:closeHistory()
    self:popUpEffect(self.trendView, self.lhResultPanel, false);
end

--初始化走势图
function LhdScene:initTrendData(msg)
    ---self.cardTypeTrendListView:removeAllChildren();
    ---self.longHuTrendListView:removeAllChildren();
    
    self.lastRoundArea = 0;
    for i = 1, #msg.data do
        --self:setHistoryViewData(msg.data[i]);
        if #self.historyListTb <= 20 then
            table.insert(self.historyListTb, msg.data[i]);
        end
        if #self.historyListTb > 20 then
            table.remove(self.historyListTb, 1);
        end
    end
    --self:setAreaWinRate(self.historyListTb, #self.historyListTb);
end

--更新走势
function LhdScene:updateTrendData(msg)
    lhUIZoushi:initzoushi(msg);
end

--结算更新走势
function LhdScene:updateResultTrend(data)
    lhUIZoushi:updateData(data, 3)
end

--设置区域胜率（废弃）
function LhdScene:setAreaWinRate(data, historyCount)
    local LongWin = 0;
    local HuWin = 0;
    for i = 1, historyCount do
        if data[i].win == 1 then
            LongWin = LongWin + 1;
        elseif data[i].win == 2 then
            HuWin = HuWin + 1;
        end
    end
    local percentLong = math.floor(LongWin / historyCount * 100);
    local percentHu = math.floor(HuWin / historyCount * 100);
    print("历史记录胜率：", percentHu, percentLong, historyCount);
    local LongScale = 1.0;
    if percentLong <= 30 then
        LongScale = 0.7;
    end
    if percentLong < 20 then
        LongScale = 0.5;
    end
    self.winRate[1].text_winRate:setScale(LongScale);

    local HuScale = 1.0;
    if percentHu <= 30 then
        HuScale = 0.7
    end
    if percentHu < 20 then
        HuScale = 0.5
    end
        self.winRate[2].text_winRate:setScale(HuScale);
    local long_loadBarSize = self.winRate[1]:getContentSize();
    self.winRate[1].text_winRate:setString("龙近20局: "..percentLong.."%");
    self.winRate[1].text_winRate:setPositionX(long_loadBarSize.width / 2 * percentLong / 100);
    self.winRate[1]:setPercent(percentLong);

    local hu_loadBarSize = self.winRate[2]:getContentSize();
    self.winRate[2].text_winRate:setString("虎近20局: "..percentHu.."%");
    self.winRate[2].text_winRate:setPositionX(hu_loadBarSize.width - (hu_loadBarSize.width / 2 * (percentHu / 100)));
    self.winRate[2]:setPercent(percentHu);
end

--设置走势界面记录(废弃)
function LhdScene:setHistoryViewData(data)
    if #self.longHuTrendListView:getItems() > 20 then
        self.longHuTrendListView:removeItem(0);
    end
    if #self.cardTypeTrendListView:getItems() > 20 then
        self.cardTypeTrendListView:removeItem(0);
    end
    local winAreaIndex = data.win;
    local winValue = data.Value;
    if not winValue or not winAreaIndex then
        return ;
    end
    if winAreaIndex == self.lastRoundArea then
        self.continuousWin = self.continuousWin + 1;
    end
    local new_Point_Panel = nil;
    local new_Card_Point = nil;
    local winPoint = nil;
    local cardTypeItem = nil;
    local tempWinPointPanel = {};
    local tempCardTypePanel = {};
    
    if self.lastRoundArea and winAreaIndex == self.lastRoundArea and self.continuousWin <= 7 then
        new_Point_Panel = self.longHuTrendListView:getItems()[#self.longHuTrendListView:getItems()];
        new_Card_Point = self.cardTypeTrendListView:getItems()[#self.cardTypeTrendListView:getItems()];
        winPoint = new_Point_Panel:getChildByName("WinnerItem_"..self.continuousWin);
        cardTypeItem = new_Card_Point:getChildByName("CardTypeItem_"..self.continuousWin);
    else
        new_Point_Panel = self.trendView:getChildByName("LongHuItemPanel"):clone();
        new_Card_Point = self.trendView:getChildByName("CardTypeItemPanel"):clone();
        for i = 1, 6 do
            tempWinPointPanel[i] = new_Point_Panel:getChildByName("WinnerItem_"..i):setVisible(false);
            tempCardTypePanel[i] = new_Card_Point:getChildByName("CardTypeItem_"..i):setVisible(false);
        end
        winPoint = tempWinPointPanel[1];
        cardTypeItem = tempCardTypePanel[1];
        self.continuousWin = 1;
    end
	new_Point_Panel:setVisible(true);
    winPoint:setVisible(true);
    if self.winAreaLong == data.win then
        winPoint:loadTexture(GAME_LHD_IMAGES_RES.."history/zoushi_long.png", 1);
    elseif self.winAreaHu == data.win then
        winPoint:loadTexture(GAME_LHD_IMAGES_RES.."history/zoushi_hu.png", 1);
    elseif self.winAreaHe == data.win then
        winPoint:loadTexture(GAME_LHD_IMAGES_RES.."history/zoushi_he.png", 1);
    end
    new_Card_Point:setVisible(true);
    cardTypeItem:setVisible(true);
    if winValue >= 9 then
        cardTypeItem:loadTexture(GAME_LHD_IMAGES_RES.."history/zoushi_bg1.png", 1);
    else
        cardTypeItem:loadTexture(GAME_LHD_IMAGES_RES.."history/zoushi_bg2.png", 1);
        cardTypeItem:getChildByName("text_winP"):setColor(cc.c3b(98, 66, 35));
    end
    
    cardTypeItem:getChildByName("text_winP"):setString(self:cardPointToCardValue(winValue));
    if not self.lastRoundArea or self.continuousWin == 1 then
        self.longHuTrendListView:pushBackCustomItem(new_Point_Panel);
        self.cardTypeTrendListView:pushBackCustomItem(new_Card_Point);
        self.lastRoundArea = winAreaIndex;
    end
    local listViewSize = self.longHuTrendListView:getContentSize();
    self.longHuTrendListView:forceDoLayout();
    self.longHuTrendListView:jumpToPercentHorizontal(100);
    self.cardTypeTrendListView:forceDoLayout();
    self.cardTypeTrendListView:jumpToPercentHorizontal(100);
end

--转换牌值为牌面值
function LhdScene:cardPointToCardValue(value)
    if value > 10 then
        if value == 11 then
            return "J";
        elseif value == 12 then
            return "Q";
        elseif value == 13 then
            return "K";
        end
    else
        return value;
    end
end

-- 主界面走势UI
function LhdScene:updateZoushiUI(data)
    if data < 0 or data > 3 then return end
    local function getPrefab(data)
        local itemclone= self.zsPrefab:clone()
        local zs_itemclone = self:seekWidgetByNameRoot(itemclone,"zs_item")
        if	data > 0  then
            zs_itemclone:loadTexture("lh_img_small_zoushi_"..data..".png",1) 
        end 
        itemclone.Image_new = self:seekWidgetByNameRoot(itemclone ,"Image_new"):setVisible(true)
        return itemclone
    end 

    if self.m_zxlistView then 
        --更新主界面走勢
        if g_getListViewSize(self.m_zxlistView) >=20 then
            self.m_zxlistView:removeItem(0)
        end
        if self.m_zxlistView.curlist then
            self.m_zxlistView.curlist.Image_new:setVisible(false)
        end
        --local zxitem = getPrefab(data)
        --self.m_zxlistView.curlist = zxitem
        --g_insertItemInListView(self.m_zxlistView,zxitem)
    end
end

-------------------------------------------------------个人信息弹窗----------------------------------------------------
--个人信息界面
function LhdScene:initUserInfoView()
    self.userInfoNode = self:seekChild("userInfoNode");
    self.userInfo.UserInfoView = self.userInfoNode:getChildByName("img_UserInfoBG");
    self.userInfo.btn_close = self.userInfo.UserInfoView:getChildByName("btn_close");
    self.userInfo.head = self.userInfo.UserInfoView:getChildByName("head_Panel"):getChildByName("img_head");
    self.userInfo.nickName = self.userInfo.UserInfoView:getChildByName("text_nick"):getChildByName("text_nickName");
    self.userInfo.img_sex = self.userInfo.UserInfoView:getChildByName("text_nick"):getChildByName("img_sex");
    self.userInfo.userid = self.userInfo.UserInfoView:getChildByName("text_ID"):getChildByName("text_userID");
    self.userInfo.userScore = self.userInfo.UserInfoView:getChildByName("img_userScore"):getChildByName("text_userScore");
    self.userInfo.address = self.userInfo.UserInfoView:getChildByName("img_address"):getChildByName("text_address");
    self.userInfo.IP = self.userInfo.UserInfoView:getChildByName("img_address"):getChildByName("text_IP");
    --TODO:杨过修改,暂时隐藏掉IP
    --self.userInfo.IP:setVisible(false)
    self.userInfo.btn_close:addClickEventListener(function()
        local userid = self.userInfo.userid:getString();
        local user = self:getUserInfo(tonumber(userid));
        if user and user.isOpenUserInfo then
            user.isOpenUserInfo = false;
        end
        self:popUpEffect(self.userInfo.UserInfoView, self.userInfoNode, false);
    end);
end

--打开个人信息
function LhdScene:openUserInfo()
    self:popUpEffect(self.userInfo.UserInfoView, self.userInfoNode, true);
end

function LhdScene:setUserInfo(userinfo)
    dump(userinfo, "传入的个人信息：");
    self.userInfo.nickName:setString(utils:nameStandardString(tostring(userinfo.nickname), 26, 142));
    SET_HEAD_IMG(self.userInfo.head, userinfo.headid, userinfo.wxheadurl);
    self.userInfo.userScore:setString(utils:moneyString(userinfo.money));
    local city = userinfo.city;
    if city == "" then
        city = "未知";
    end
    if userinfo.sex >= 0 and userinfo.sex < 2 then
        self.userInfo.img_sex:loadTexture(GAME_LHD_IMAGES_RES .. "userinfo/sex_" .. userinfo.sex .. ".png", 1);
    end
    self.userInfo.address:setString(city);
    self.userInfo.userid:setString(userinfo.playerid);
    if userinfo.playerid == self.MyInfo.playerid then
        self.userInfo.IP:setString(userinfo.ip);
    else
        local ipStr = self:getFormatIp(userinfo.ip);
        self.userInfo.IP:setString(ipStr);
    end
end

--获取IP
function LhdScene:getFormatIp(ip)
    local tempIP = ip;
    local ipLen = string.len(tempIP);
    local curlen = 0;
    local temp = {};
    local isStar = false;
    for i = 1, ipLen do
        if string.sub(tempIP,i, i) == "." then
		    curlen = curlen + 1;
	    end
	    if curlen < 2 then
		    temp[i] = string.sub(tempIP, i, i);
	    else
		    if string.sub(tempIP,i, i) == "." then
			    temp[i] = string.sub(tempIP, i, i);
                isStar = false;
		    else
                if not isStar then
			        temp[i] = "*";
                    isStar = true;
                else
                    temp[i] = "";
                end
		    end
	    end
    end
    return table.concat(temp);
end

-----------------------------------------------------------弹出对话框-----------------------------------------------------------
function LhdScene:messageBox(text, call, isHideCloseBtn)
    local msgBoxNode = self:seekChild("msgBoxNode");
    local msgBoxView = msgBoxNode:getChildByName("img_TipsBG");
    self:popUpEffect(msgBoxView, msgBoxNode, true);
    local text_msg = msgBoxView:getChildByName("Text_1");
    text_msg:setString(text);
    local btn_OK = msgBoxView:getChildByName("btn_OK");
    btn_OK:addClickEventListener(function()
        if call then
            call();
        end
        self:popUpEffect(msgBoxView, msgBoxNode, false);
    end);
    if isHideCloseBtn then
        local btn_close = msgBoxView:getChildByName("btn_close"):hide();
    else
        local btn_close = msgBoxView:getChildByName("btn_close");
        btn_close:addClickEventListener(function()
            self:popUpEffect(msgBoxView, msgBoxNode, false);
        end);
    end
end

-----------------------------------------------------------断线重连-------------------------------------------------------------
function LhdScene:offLineToOnline(msg)
    self.cardCompareNode:hide();
    if not self.selectScore then
        self.selectScore = self.SELECT_CONFIG[1];
        print("修改选择筹码数值66666666：", self.selectScore);
    end
    self:setChipBtnEnabled(false);
    self:autoSelectChip();
    if self.model.bankerNeed then
        self.bankerNeed:setString("上庄条件："..utils:moneyString(self.model.bankerNeed));
    end
    if msg.state == LHD.LHD_GameState.LHD_GameState_BuyHorse then
        self.isStartBet = true;
        local chipsNum = 150000;
        local count = 15;
        if tonumber(msg.nextat) > 10 then
            count = 5
        elseif tonumber(msg.nextat) > 5 then
            count = 10;
        end
        if msg.TableBetInfo then
            self:restoreDeskAllInfo(msg.TableBetInfo, count);
        end
    end
    self:restoreDeskMyInfo(msg.betinfo);
end

--恢复桌子上自己的数据
function LhdScene:restoreDeskMyInfo(msg)
    local temp = {};
    temp[1] = msg.long;
    temp[2] = msg.hu;
    temp[3] = msg.he;
    local myMoney = self.MyInfo.money;
    for i = 1, #self.TouchBet do
        self.TouchBet[i].self_label:setString(utils:moneyString(temp[i], 0));
        if temp[i] > 0 then
            self.MyInfo.isBet = true;
        end
        myMoney = myMoney - temp[i];
    end
    self.MyInfo.money = myMoney;
    self.MyInfo.score:setString(utils:moneyString(myMoney));
end

--恢复桌子上的数据
function LhdScene:restoreDeskAllInfo(msg, count)
    local temp = {};
    temp[1] = msg.long;
    temp[2] = msg.hu;
    temp[3] = msg.he;
    for i = 1, #self.TouchBet do
        self.TouchBet[i].total_label:setString(utils:moneyString(temp[i], 0));
        if temp[i] > 0 then
            if i == 3 then
                count = 5;
            end
            self:createChips(temp[i], i, count);
        end
    end
end

--创建筹码
function LhdScene:createChips(score, area, count)
    self.Chips[area] = checktable(self.Chips[area]);
    local chipScore = self:splitUserBetChipScore(score, count);
    --dump(chipScore, "中途进入拆分筹码：");
    if not chipScore or #chipScore <= 0 then
        return;
    end
    for i = 1, #chipScore do
        local chip = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."game/mortgage_fei_"..utils:moneyString(chipScore[i])..".png");
        local rotation = math.random(-50, 50);
        chip:setRotation(rotation);
        local chipPosNode = self.chipPos[area];
        local offsetX = chipPosNode:getPositionX();
        local offsetY = chipPosNode:getPositionY();
        local moveToPos = cc.p( math.random(offsetX - 70, offsetX + 70), math.random(offsetY - 55,offsetY + 55));
        chip:setPosition(cc.p(moveToPos));
        local myLabel = ccui.TextBMFont:create()
        myLabel:setFntFile(GAME_LHD_FONT_RES.."chip.fnt")
	    myLabel:setString(utils:moneyString(chipScore[i]))
	    myLabel:setPosition(28,29)
        myLabel:setScale(0.5)
	    chip:addChild(myLabel)
        self.chipsNode:addChild(chip);
        table.insert(self.Chips[area], chip);
    end
end

--播放中途进入在结算阶段的等待动画
function LhdScene:playWaitAct()
    local parentNode = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), display.width, 120);
    parentNode:setAnchorPoint(cc.p(0, 0));
    --print("当前层的锚点为：", parentNode:getAnchorPoint().x,parentNode:getAnchorPoint().y);
    parentNode:setPosition(cc.p(0, display.height / 2 - 60));
    --print("当前层的位置为：", parentNode:getPositionX(), parentNode:getPositionY());
    parentNode:setName("waitNode");
    self:addChild(parentNode);
    local parentSize = parentNode:getContentSize();
    local sp = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."game/wait.png");
    sp:setPosition(cc.p(parentSize.width / 2 - 80, parentSize.height / 2 - 5));
    parentNode:addChild(sp);
    
    local spSize = sp:getContentSize();
    self.waittingTb = {};
    for i = 1, 3 do
        self.waittingTb[i] = cc.Sprite:createWithSpriteFrameName(GAME_LHD_IMAGES_RES.."game/wait_dot.png"):hide();
        self.waittingTb[i]:setPosition(cc.p(parentSize.width / 2 + 145 + (i * 35), parentSize.height / 2 - 15));
        parentNode:addChild(self.waittingTb[i]);
    end
    local temp = {};
    local delay = 0.7;
    for i = 1, 3 do
        local act = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
            self.waittingTb[i]:show();
        end));
        table.insert(temp, act);
        
        if i == 3 then
            local act1 = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
                for j = 1, 3 do
                    self.waittingTb[j]:hide()
                end
            end));
            table.insert(temp, act1);
        end
    end
    self.waitAct = cc.RepeatForever:create(cc.Sequence:create(temp));
    self:runAction(self.waitAct);
end

--隐藏动画
function LhdScene:hideWaitAct()
    local waitNode = self:getChildByName("waitNode");
    if waitNode then
        waitNode:hide();
        waitNode:removeFromParent();
        self:stopAction(self.waitAct);
    end
end

function LhdScene:updateMyScore(score)
    self.MyInfo.money = score;
    self.model.myInfo.money = score;
	self.MyInfo.score:setString(utils:moneyString(self.MyInfo.money));
    if self.gameState == LHD.LHD_GameState.LHD_GameState_BuyHorse then
        self:autoSelectChip();
    end
end

function LhdScene:updateOtherScore(playerid,score)
	for userindex = 1, #self.Players do
		if playerid == self.Players[userindex].playerid then
			self.Players[userindex].score:setString(utils:moneyString(score));
		end
	end
end

-- 充值成功更新玩家数据
function LhdScene:updateUserScore(msg)
    local var = self.allUsers[msg.playerid];
    if var then
        var.coin = msg.coin;
        var.money = msg.coin;
    end
end

return LhdScene