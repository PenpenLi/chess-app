--region SlotsFruit.lua  水果老虎机
--Author : WB
--Date   : 2018/4/13

local _super = require('app.views.games.SlotsBase')
local SlotsFruit = class("SlotsFruit", _super)
local App = require('mvc.App')
local MsgCenter = require('app.pack2cpp.MsgCenter')
local tools = require('app.helpers.tools')
local SoundManager = require('app.helpers.SoundMng')
local Slot = require('app.widgets.Slot')
local device = require('cocos.framework.device')
local MessageLayer = require("app.widgets.MessageLayer")

local ROW_NUM = 3
local ICON_NUM = 22

SlotsFruit.argT = {
    COL_NUM = 5,
    ROW_NUM = 12,
    SLOT_WIDTH = 160,
    ICON_SPACE = 160,
    slotsPos = cc.p(160 + 60, 150),
    slotsIntervalX = 188,
    lines = 9,
    runDur = 1.7,
    speed = 400,
--    speedUP = 800,
    iconScaleY = 1,
    startCommand = 1,
    startProtoName = "GamePull",
    SUB_C_ROUND_OVER = 2,
--    SUB_C_EXIT_GAME = 3,
    createLines = {file = "SlotsFruitGameScene/Studio/lines/xian_%d.png", pos = cc.p(670, 385)},
    m_mpID2Name = { [1] = "sgj_yingtao",
                    [2] = "sgj_caomei",
                    [3] = "sgj_juzi",
                    [4] = "sgj_ningmeng",
                    [5] = "sgj_putao", 
                    [6] = "sgj_xigua", 
                    [7] = "sgj_lingdang",
                    [8] = "sgj_shuangxin",
                    [9] = "sgj_7",
                    [10]= "sgj_wild",
                    [11]= "sgj_scatter",
                    [12]= "sgj_bonus",
                   },
    sounds = {  
                bg =    "SLOTFRUIT_BGMUSIC",
                stop1 = "SLOTFRUIT_STOP1",
                stop2 = "SLOTFRUIT_STOP2",
                stop3 = "SLOTFRUIT_STOP3",
                stop4 = "SLOTFRUIT_STOP4",
                stop5 = "SLOTFRUIT_STOP5",
                acc1 = "SLOTFRUIT_EXPECT",
                acc2 = "SLOTFRUIT_EXPECT",
                acc3 = "SLOTFRUIT_EXPECT",
                acc4 = "SLOTFRUIT_EXPECT",
                acc5 = "SLOTFRUIT_EXPECT",
                }
}

function SlotsFruit:initialize() -- luacheck: ignore self
    _super.initialize(self)

    self:AddEvents(
        App.conn:on("startLGame",function(data)
            self:startLGame(data)
        end),
		--系统跑马灯消息
        App.conn:on("onSystemMessage", function(...)
            self:onSystemMessage(...)
        end)        
    )

    local effct = cc.FileUtils:getInstance():getValueVectorFromFile("game/SlotsFruit/effect.plist")
    for k, v in pairs(effct) do
	    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(v)
    end
    
    self.m_arrIconPos = {}
	local vtrInflections = { 9, 12, 20 };
	local fStartX = -4;
	local fStartY = 442;
	local fStepX = 95.9;
	local fStepY = 116.5;
	local fStartR = math.pi * 2;
	for i = 0, ICON_NUM - 1 do
		if (#vtrInflections > 0 and vtrInflections[1] == i) then
			fStartR = fStartR - math.pi / 2;
			table.remove(vtrInflections, 1)
		end
		local x_ = (math.cos(fStartR));
		local y_ = (math.sin(fStartR));
        print(x_, y_, fStartR)
		self.m_arrIconPos[i] = cc.p(fStartX + fStepX * x_, fStartY + fStepY * y_);
        fStartX = fStartX + fStepX * x_;
        fStartY = fStartY + fStepY * y_;
	end

    dump(self.m_arrIconPos)
end

function SlotsFruit:finalize() -- luacheck: ignore self
	self.mMessageLayer:remove()
    _super.finalize(self)
end

function SlotsFruit:viewDidLoad()
    _super.viewDidLoad(self)

	self.m_pAutoRunEffet = tools.GetAmt("sgj_zidong");
	self.m_pAutoRunEffet:setPosition(cc.p(90 + 46, 57));

	self.m_pLittleGame = self:seekChildByName("Image_Game");
	self.m_pWinLG = self:seekChildByName("Image_Win");
	self.m_pLGWin = self:seekChildByName("Image_WinG");
	self.m_pLGWinNumCur = self:seekChildByName("BitmapLabel_LG_Win");
	self.m_pLeftGame = self:seekChildByName("BitmapLabel_LG_Left");
	self.m_pWinLGTimes = self:seekChildByName("BitmapLabel_Win_Times");
	self.m_pLGWinNum = self:seekChildByName("BitmapLabel_WinG");
	self.m_pLGRunTimes = self:seekChildByName("BitmapLabel_RunTimes");
	local pStartLG = self:seekChildByName("Button_StartG");
	local pBackToGame = self:seekChildByName("Button_Back");
	pStartLG:addClickEventListener(function()
		if (self.m_nTimesLeftGame > 0) then
		    self:_start_inner_game();
        end
	end);
	pBackToGame:addClickEventListener(function()
		self.m_bRunning = false;
		self:_show_little_game_ui(false);
		self:CheckAutoStart();
	end);

    self.m_arrRunningMarks = {}
	for i = 1, 4 do
		self.m_arrRunningMarks[i] = self:seekChildByName(string.format("Image_Sel%d", i));
		self.m_arrRunningMarks[i]:getVirtualRenderer():getSprite():setBlendFunc({src = GL_SRC_ALPHA, dst = 1});
	end

	self.m_pMultipleBtnInc = self:seekChildByName("Button_Multiple_Inc")
	self.m_pMultipleBtnDec = self:seekChildByName("Button_Multiple_Dec")
	self.m_pMaxBet = self:seekChildByName("Button_MaxBet")
	self.m_pOver = self:seekChildByName("Button_Over")

	self.m_pBetSingle = self:seekChildByName("BitmapLabel_BetThis")
	self.m_pIcome	= self:seekChildByName("BitmapLabel_Income")
	self.m_pBetTotal = self:seekChildByName("BitmapLabel_BetTotal")
	local pAuto = self:seekChildByName("Button_Auto")
	pAuto:addClickEventListener(function()
		SoundManager:playSound("SISTER_STOP_BTN")
		self.m_bAutoRunning = false
	end)
	pAuto:addChild(self.m_pAutoRunEffet)

	self.m_pOver:addClickEventListener(function()
		SoundManager:playSound("SISTER_STOP_BTN")
		if (self.m_bRunning and not self.m_bStopping and not self.m_bAutoRunning) then
			self:Stop()
		end
	end)
	self.m_pMultipleBtnInc:addClickEventListener(function()
		self.m_nCurMultiple = math.min(self.m_nMaxMultiple, self.m_nCurMultiple + self.m_nMaxMultiple / 5);
		self.m_pBetSingle:setString(string.format("%d", self.m_nCurMultiple * self.m_llSingleBet));
	    self.m_pBetTotal:setString(string.format("%d", self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	end)
	self.m_pMultipleBtnDec:addClickEventListener(function()
		self.m_nCurMultiple = math.max(1, self.m_nCurMultiple - self.m_nMaxMultiple / 5);
		self.m_pBetSingle:setString(string.format("%d", self.m_nCurMultiple * self.m_llSingleBet));
	    self.m_pBetTotal:setString(string.format("%d", self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	end)
	self.m_pMaxBet:addClickEventListener(function()
		self.m_nCurMultiple = self.m_nMaxMultiple
		self.m_pBetSingle:setString(string.format("%d", self.m_nCurMultiple * self.m_llSingleBet));
	    self.m_pBetTotal:setString(string.format("%d", self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	end)

	local pAmt = tools.GetAmt("sgj_sgxml");
	pAmt:setPosition(cc.p(20 + 454, 340));
	self.m_pLittleGame:addChild(pAmt, -1);

	self.m_pWinFree = tools.GetAmt("sgj_mianfei", false);
	self.m_pWinFree:setPosition(250, 280);
	self.m_pWinFree:setVisible(false);
	self.m_pWinLG:addChild(self.m_pWinFree);

	self.m_pWinGame = tools.GetAmt("sgj_mianfei_xiaomali", false);
	self.m_pWinGame:setPosition(250, 280);
	self.m_pWinGame:setVisible(false);
	self.m_pWinLG:addChild(self.m_pWinGame);

    self.m_arrWinTips = {}
	self.m_arrWinTips[1] = self:seekChildByName("Image_Tips1");
	self.m_arrWinTips[2] = self:seekChildByName("Image_Tips2");

	pAmt = tools.GetAmt("zhongjiang_tongyong");
	pAmt:setPosition(510, 260);
	self.m_pLGWin:addChild(pAmt, -1);

	pAmt = tools.GetAmt("sgj_jmpaomad");
	pAmt:setPosition(cc.p(321, 659));
	self.m_pBG:addChild(pAmt);
	pAmt = tools.GetAmt("sgj_jmpaomad");
	pAmt:setPosition(cc.p(1010, 659));
	pAmt:setScaleX(-1);
	self.m_pBG:addChild(pAmt);

	self.m_pCoinBoxAmt = tools.GetAmt("hylj_zhongjiangfankui");
	self.m_pCoinBoxAmt:setPosition(cc.pAdd(cc.p(self.m_pIcome:getPosition()), cc.p(0, 0)));
	self.m_pCoinBoxAmt:setVisible(false);
	self.m_pIcome:getParent():addChild(self.m_pCoinBoxAmt);

    local PlayerIconList = require("app.widgets.PlayerIconList")
	self.m_pPlayers = PlayerIconList:create({PlayerIconList.PIT_ADDRESS, PlayerIconList.PIT_NAME, PlayerIconList.PIT_MONEY, PlayerIconList.PIT_COIN}, 6, false, true, 1175, 266, 110);
	self.m_pPlayers:setPosition(cc.p(78.5, 290));
	self.m_pPlayers:OffsetCtrl(PlayerIconList.PIT_ADDRESS, cc.p(-50, 82));
	self.m_pPlayers:OffsetCtrl(PlayerIconList.PIT_NAME, cc.p(-50, -4));
	self.m_pPlayers:OffsetCtrl(PlayerIconList.PIT_MONEY, cc.p(-46, -14));
	self.m_pPlayers:OffsetCtrl(PlayerIconList.PIT_COIN, cc.p(-46, -34));
	self.m_pPlayers:SetIconScale(0.95);
	self.m_pMyIcon = self.m_pPlayers:GetMyIcon();
	self.m_pBG:addChild(self.m_pPlayers, 1);

	self.m_pPlayers:SetPlayerUpdateCallBack(function(chair, pIcon, dwScoreDelta)
        if chair == MsgCenter:GetMyChair() then return end
		local nWinLv = self:GetWinType(dwScoreDelta);
		self:PlayIconEffect(pIcon, dwScoreDelta, nWinLv);
	end);

    self:MakeLongPushButton(self.m_pStart, function() self:ReqStart() end, function() self:ReqStart() self.m_bAutoRunning = true end, "SlotsFruitGameScene/Amt/scene/sgj_juli_lizi.plist")

    self.m_help = require("app.widgets.HelpUI"):create(2, "SlotsFruitGameScene/Studio/help", cc.p(-530, 0), cc.p(530, 0), cc.p(555 + 30, 275 + 28))
    self:addChild(self.m_help)
    self.m_help:setVisible(false)

    --系统跑马灯消息
    self.mMessageLayer = MessageLayer:create(self, cc.p(0, 130))
end




-------------------------------------------------主线----------------------------------------------------
function SlotsFruit:FreeGameScene(pData)
	self.m_llSingleBet = pData.lMinBetScore / self.argT.lines
	self.m_nMaxMultiple = pData.lMaxBetScore / pData.lMinBetScore
	self.m_nCurMultiple = self.m_nMaxMultiple
	self.m_nTimesLeft4Free = pData.FreePullTime

    if App.gameData[MsgCenter.gameKindID].m_bAutoRunning or App.gameData[MsgCenter.gameKindID].m_nCurMultiple ~= 1 then
        self.m_nCurMultiple = App.gameData[MsgCenter.gameKindID].m_nCurMultiple or self.m_nCurMultiple
        self.m_bAutoRunning = App.gameData[MsgCenter.gameKindID].m_bAutoRunning
    end

	self.m_pBetSingle:setString(string.format("%d", self.m_nCurMultiple * self.m_llSingleBet))
	self.m_pBetTotal:setString(string.format("%d", self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	self.m_pLeftGame:setString(string.format("%d", pData.nSmallMaryNum));
	self.m_pFreeTimes:setString(string.format("%d", self.m_nTimesLeft4Free));

	if (pData.nSmallMaryNum > 0) then
		self:_start_inner_game();
	else
        self:CheckAutoStart()
    end
end

function SlotsFruit:ReqStart()
	if (not self.m_bRunning) then
		if (self:CheckMoney4Run()) then
			local data = { userBetMultiple = self.m_nCurMultiple * self.m_llSingleBet * self.argT.lines}
			self:SendStart(data)
			self.m_pStart:setEnabled(false)
			self.m_pStart:waitAndCall(1.5, function()
				self.m_pStart:setEnabled(true)
			end)
		end
	end
end

-- N个拉霸的游戏协议都不一样，这里对拉动后的返回协议做适配统一成一种格式
function SlotsFruit:AdaptGameInfo()
    self.m_GameData.m_Table = tools.TransposeTable(self.m_GameData.m_Table)
    self.m_GameData.m_TableLight = tools.TransposeTable(self.m_GameData.m_TableLight)
    self.m_GameData.littleGameWin = self.m_GameData.nMarryNum
end

function SlotsFruit:CalcRunningInfo()
    self.m_GameData.runInfo = {
        {dur = 0, accMoment = nil, speedUP = nil, accEff = nil, stopSound = nil},
        {dur = 0, accMoment = nil, speedUP = nil, accEff = nil, stopSound = nil},
        {dur = 0, accMoment = nil, speedUP = nil, accEff = nil, stopSound = nil},
        {dur = 0, accMoment = nil, speedUP = nil, accEff = nil, stopSound = nil},
        {dur = 0, accMoment = nil, speedUP = nil, accEff = nil, stopSound = nil}
    }

    local accNum = 0
	for col = 1, self.argT.COL_NUM do
        self.m_GameData.runInfo[col].dur = 2 + col * 0.3 + accNum * 2

        if self.m_GameData.bSpeedUp[col] then
            accNum = accNum + 1
            self.m_GameData.runInfo[col].accMoment = self.m_GameData.runInfo[col - 1].dur
            self.m_GameData.runInfo[col].accEff = "sgj_jiasu"
        end
	end

    dump(self.m_GameData)
end

function SlotsFruit:startRun(data)
    _super.startRun(self, data)
end

function SlotsFruit:AfterMakeResult(fResultLast, llWinNum)
    return fResultLast
end

function SlotsFruit:Update()
    _super.Update(self)

	self.m_pStart:setTouchEnabled(not self.m_bRunning and not self.m_bStopping)
	self.m_pOver:setVisible(self.m_bRunning and self.m_arrSlots[self.argT.COL_NUM]:GetAcc():IsMoving() and not self.m_bAutoRunning)
	self.m_pMultipleBtnInc:setTouchEnabled(not self.m_bRunning)
	self.m_pMultipleBtnDec:setTouchEnabled(not self.m_bRunning)
	self.m_pMaxBet:setTouchEnabled(not self.m_bRunning)
	self.m_pAutoRunEffet:getParent():setVisible(self.m_bAutoRunning)
	self.m_pFreeTimes:getParent():setVisible(self.m_nTimesLeft4Free > 0);
end




-------------------------------------------------工具函数----------------------------------------------------
function SlotsFruit:_show_win_panel(llWin, nLv)
	local arrEff = {"sgj_zhongjiangjs_diban", "sgj_zhongjiangjs_big", "sgj_zhongjiangjs_super", "sgj_zhongjiangjs_mega"};
	local pAmt = tools.GetAmt(arrEff[1], false);
	pAmt:setPosition(667, 367);
	pAmt:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		local pMoney = ccui.TextBMFont:create("0", "SlotsFruitGameScene/Studio/font/num3.fnt");
		pMoney:setPositionY(27);
		pAmt:addChild(pMoney, 99);
		pAmt:getAnimation():playWithIndex(0);
        tools.numberGO(pMoney, 0, llWin, 2, function(a, over)
			pMoney:setString(string.format("%d", a));
	        self.m_pIcome:setString(string.format("%d", a));
			if (over) then
				self:PlayIconEffect(self.m_pMyIcon, llWin, nLv);
            end
		end);
		if (nLv > 0) then
			local light = cc.Sprite:create("SlotsFruitGameScene/Amt/result/sgj_jisuan_00.png");
			local light2 = cc.Sprite:create("SlotsFruitGameScene/Amt/result/sgj_jisuan_01.png");
			light:setScale(4);
			light2:setScale(4);
			light:setPositionY(150);
			light2:setPositionY(150);
			light:setBlendFunc({src = GL_SRC_ALPHA, dst = 1});
			light2:setBlendFunc({src = GL_SRC_ALPHA, dst = 1});
			light:runAction(cc.RepeatForever:create(cc.RotateBy:create(5, 360)));
			light2:runAction(cc.RepeatForever:create(cc.RotateBy:create(6, -360)));
			pAmt:addChild(light, -1);
			pAmt:addChild(light2, -1);
		end
	end), cc.DelayTime:create(3), cc.RemoveSelf:create(), cc.CallFunc:create(function()
		self.m_pEffectLayer:setOpacity(0);
	end)));
	self.m_pEffectLayer:addChild(pAmt);
	self.m_pEffectLayer:setOpacity(nLv > 0 and 255 or 0);
	self.m_pEffectLayer:setVisible(true);
	if (nLv > 0) then
		local pAmt2 = tools.GetAmt(arrEff[math.min(4, nLv + 1)]);
		pAmt2:setPosition(7, 120);
		pAmt:addChild(pAmt2);
		pAmt:setPositionY(267);
	end
	SoundManager:playSound(string.format("SLOTFRUIT_WINBG%d", 1 + math.min(2, nLv + 1)));
end

function SlotsFruit:PlayIconEffect(pIcon, llScore, nLv)
	local pAmt1 = tools.GetAmt("sgj_zhongjiangtoux");
	pIcon:getParent():addChild(pAmt1);
	pAmt1:setPosition(cc.pFromSize(cc.sizeSub(cc.sizeMul(pIcon:getContentSize(), 0.5), cc.size(50, 68))));
	pAmt1:runAction(cc.Sequence:create(cc.CallFunc:create(function()
		if (nLv > 0) then
			local pWinNum = cc.Sprite:create(string.format("SlotsFruitGameScene/Amt/player/win%d.png", nLv));
			pWinNum:setPosition(cc.sizeSub(cc.sizeMul(pIcon:getContentSize(), 0.5), cc.size(50, 62)));
			pWinNum:runAction(cc.Sequence:create(cc.MoveBy:create(2.5, cc.p(0, 80)), cc.RemoveSelf:create()));
			pWinNum:setScale(nLv == 2 and 0.8 or 0.9);
			pIcon:getParent():addChild(pWinNum);
		
			local lizi_bj = cc.ParticleSystemQuad:create("SlotsFruitGameScene/Amt/player/sgj_txzj_lizi.plist");
			lizi_bj:setPosition(pIcon:getPosition());
			pIcon:getParent():addChild(lizi_bj);
		end
	end), cc.DelayTime:create(2), cc.RemoveSelf:create()));
end

function SlotsFruit:_start_inner_game()
	SoundManager:playMusic("SLOTFRUIT_BONUSMUSIC");
	self:_show_little_game_ui(true, 2);
	self.m_pLittleGame:setScale(0);
	self.m_pLittleGame:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
		cc.CallFunc:create(function()
		MsgCenter:SendDataToServerG(200, 3);
		self.m_pPlayers:ActiveMe(false);
	end)));
	self.m_pLGWinNumCur:setString("0");
	self.m_pWinLGTimes:stopAllActions();
end

function SlotsFruit:_run_target(from, target)
	target = target + 4 * ICON_NUM;
	if (from > target % ICON_NUM) then
		target = target + ICON_NUM;
    end

	local arrStartTimeSlots = { 0, 0.3, 0.2, 0.2, 0.2, 0.15, 0.12, 0.1, 0.08, 0.06, 0.04, 0.03, 0.02, 0.02 };
	local arrEndTimeSlots = { 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1, 0.15, 0.2, 0.25, 0.4 };
	local fLoopTimeStep = 0.0155
	local nStartSteps = #(arrStartTimeSlots)
	local nEndSteps = #(arrEndTimeSlots)

	local nStepCounter = 0;
	local vtrActions = {}
	vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() SoundManager:playSound("SLOTFRUIT_RUN1"); end));
	for i = 0, nStartSteps - 1 do
        local index = (from + nStepCounter) % ICON_NUM
		vtrActions[#vtrActions + 1] = (cc.DelayTime:create(arrStartTimeSlots[i + 1]));
		vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() self:_run_step(index, false, i / 100); end));
        nStepCounter = nStepCounter + 1
	end
    local loop = true
	while (loop) do
		vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() SoundManager:playSound("SLOTFRUIT_RUN2"); end));
	    for i = 1, ICON_NUM do
            local index = (from + nStepCounter) % ICON_NUM
			vtrActions[#vtrActions + 1] = (cc.DelayTime:create(fLoopTimeStep));
			vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() self:_run_step(index, false, 1); end));
			if (from + nStepCounter == target - nEndSteps) then
                nStepCounter = nStepCounter + 1
				loop = false;
                break
			end
            nStepCounter = nStepCounter + 1
		end
	end

	vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() SoundManager:stopAllEffects();  SoundManager:playSound("SLOTFRUIT_RUN3"); end));
	for i = 0, nEndSteps - 1 do
        local index = (from + nStepCounter) % ICON_NUM
		vtrActions[#vtrActions + 1] = (cc.DelayTime:create(arrEndTimeSlots[i + 1]));
		vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() self:_run_step(index, i == nEndSteps - 1, (nEndSteps - i - 1) / 100); end));
        nStepCounter = nStepCounter + 1
	end
	vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() SoundManager:playSound("SLOTFRUIT_RUN4"); end));
	self:runAction(cc.Sequence:create(vtrActions));
end

local function BesideOf(base, step)
	base = (base + step) % ICON_NUM;
	if (base < 0) then
		base = base + ICON_NUM;
	end
	return base;
end

function SlotsFruit:_run_step(index, over, speed)
	self.m_arrRunningMarks[1]:setVisible(true);
	self.m_arrRunningMarks[1]:setPosition(self.m_arrIconPos[index]);

	self.m_arrRunningMarks[2]:setVisible(speed > 0.01);
	self.m_arrRunningMarks[2]:setOpacity(220);
	self.m_arrRunningMarks[2]:setPosition(self.m_arrIconPos[BesideOf(index, -1)]);

	self.m_arrRunningMarks[3]:setVisible(speed > 0.02);
	self.m_arrRunningMarks[3]:setOpacity(180);
	self.m_arrRunningMarks[3]:setPosition(self.m_arrIconPos[BesideOf(index, -2)]);

	self.m_arrRunningMarks[4]:setVisible(speed > 0.03);
	self.m_arrRunningMarks[4]:setOpacity(150);
	self.m_arrRunningMarks[4]:setPosition(self.m_arrIconPos[BesideOf(index, -3)]);

	if (over) then
		SoundManager:playSound("WHEEL_GETCOIN");
		self.m_pLGWinNum:setString(string.format("%d", self.m_LGameData.TotalWin));
		tools.numberGO(self.m_pLGWinNumCur, tonumber(self.m_pLGWinNumCur:getString()), self.m_LGameData.TotalWin, 1, function(a, over)
			self.m_pLGWinNumCur:setString(string.format("%d", a));
		end);
		local nTimes = self.m_nTimesLeftGame;
		self.m_pLGWinNumCur:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
			if (self.m_nTimesLeftGame > 0) then
				MsgCenter:SendDataToServerG(200, 3);
				self.m_pPlayers:ActiveMe(false);
			else
				self:_show_little_game_ui(true, 3);
			end
		end), cc.DelayTime:create(5), cc.CallFunc:create(function()
			if (nTimes == 0) then
				self.m_bRunning = false;
				self:_show_little_game_ui(false);
				self:CheckAutoStart();
	            SoundManager:playMusic("SLOTFRUIT_BGMUSIC");
			end
		end)));
		self.m_pPlayers:ActiveMe(true);
	end
end

function SlotsFruit:_show_little_game_ui(bShow, type, type2)
    type = type or 1

	local arrUI = { self.m_pWinLG, self.m_pLittleGame, self.m_pLGWin };
	for i = 1, 3 do
		arrUI[i]:setVisible(i == type);
	end
	if (bShow) then
		arrUI[type]:setScale(0);
		arrUI[type]:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)));
		self.m_pWinGame:setVisible(false);
		self.m_pWinFree:setVisible(false);
		local pEffBg = (type2 and self.m_pWinFree or self.m_pWinGame);
		pEffBg:setVisible(true);
		pEffBg:getAnimation():playWithIndex(0);

        type2 = type2 or 1
		self.m_arrWinTips[1]:setVisible(type2 == 1);
		self.m_arrWinTips[2]:setVisible(type2 == 2);
	end
	arrUI[1]:getParent():setVisible(bShow);
end

local arrIndex2Fruit = { { 0, 8, 11, 19 }, { 1, 7, 12, 18 }, { 6, 14 }, { 5, 17 }, {2, 13}, { 9, 21 }, { 4, 16 }, { 10, 20 }, { 3, 15 }, {}, {}, {} };
function SlotsFruit:startLGame(data)
	self.m_LGameData = data
	local nIndex = arrIndex2Fruit[self.m_LGameData.Fruit][math.random(1, #arrIndex2Fruit[self.m_LGameData.Fruit])];
	self:_run_target(self.m_nCurLGameIconIndex or 0, nIndex);
	self.m_nCurLGameIconIndex = nIndex;
	self.m_nTimesLeftGame = self.m_LGameData.nMarryLeft;

	self.m_pLeftGame:setString(string.format("%d", self.m_LGameData.nMarryLeft));
	self.m_pLGRunTimes:setString(string.format("%d", self.m_LGameData.nMarryNum));
end

-------------------------------------------------事件----------------------------------------------------
function SlotsFruit:StartGame()
	self.m_pPlayers:runAction(cc.Sequence:create(cc.DelayTime:create(llWinNum and 4 or 0), cc.CallFunc:create(function()
		self.m_nTimesLeftGame = self.m_GameData.nMarryNum;
		self.m_pWinLGTimes:setString(string.format("%d", self.m_GameData.nMarryNum));
		self.m_pWinLGTimes:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
			self:_show_little_game_ui(true, 1);
		end), cc.DelayTime:create(15), cc.CallFunc:create(function()
			self:_start_inner_game();
		end)));
	end)));
end

function SlotsFruit:OnNewFreeTimes(fResultLast)
	SoundManager:playMusic("SLOTFRUIT_FIREMUSIC");
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		self.m_pWinLGTimes:setString(string.format("%d", self.m_GameData.FreePullTime));
		self:_show_little_game_ui(true, 0, 1);
	end), cc.DelayTime:create(3), cc.CallFunc:create(function()
		self:_show_little_game_ui(false);
	end)));
	fResultLast = math.max(5, fResultLast);
	return fResultLast;
end

--function SlotsFruit:OnFreeTimesOver()
--end

function SlotsFruit:GetWinType(llScore)
	local nWinLv = llScore / (self.m_nCurMultiple * self.m_llSingleBet * self.argT.lines);
	if (nWinLv >= 20) then
		nWinLv = 3;
	elseif (nWinLv >= 10) then
		nWinLv = 2;
	elseif (nWinLv >= 5) then
		nWinLv = 1;
	else
		nWinLv = 0;
    end
	return nWinLv;
end

function SlotsFruit:LittleWin(llWinNum, nWinLv)
	self:_show_win_panel(llWinNum, nWinLv);
    return 3
end

function SlotsFruit:BigWin(llWinNum, nWinLv)
	self:_show_win_panel(llWinNum, nWinLv);
	return 3
end

function SlotsFruit:onSystemMessage(msg)
    if self.mMessageLayer then
        self.mMessageLayer:InsertSystemString(msg.szString)
    end
end







return SlotsFruit

--endregion
