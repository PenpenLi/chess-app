local Slot = require('app.common.Slot')
local device = require('cocos.framework.device')

local ROW_NUM = 3
local ICON_NUM = 22

local _super = require("app.games.fruit.SlotBase")
local FruitScene = class("FruitScene", _super)

-- 资源名
FruitScene.RESOURCE_FILENAME = "games/fruit/SlotsFruitGameScene.json"
-- 资源绑定
FruitScene.RESOURCE_BINDING = {
	--top panel
--	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
}
FruitScene.argT = {
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
    startCommand = FRUIT.CMD.SUB_C_PULL,
    startProtoName = "GamePull",
    SUB_C_ROUND_OVER = FRUIT.CMD.SUB_C_GAME_OVER,
--    SUB_C_EXIT_GAME = 3,
    createLines = {file = GAME_FRUIT_IMAGES_RES.."lines/xian_%d.png", pos = cc.p(670, 385)},
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
                bg =    GAME_FISH_SOUND_RES.."bgm.mp3",
                stop1 = GAME_FISH_SOUND_RES.."stop1.wav",
                stop2 = GAME_FISH_SOUND_RES.."stop2.wav",
                stop3 = GAME_FISH_SOUND_RES.."stop3.wav",
                stop4 = GAME_FISH_SOUND_RES.."stop4.wav",
                stop5 = GAME_FISH_SOUND_RES.."stop5.wav",
                acc1 = GAME_FISH_SOUND_RES.."expected.wav",
                acc2 = GAME_FISH_SOUND_RES.."expected.wav",
                acc3 = GAME_FISH_SOUND_RES.."expected.wav",
                acc4 = GAME_FISH_SOUND_RES.."expected.wav",
                acc5 = GAME_FISH_SOUND_RES.."expected.wav",
                }
}

function FruitScene:ctor( core )
	FruitScene.super.ctor(self,core)
end

--加载资源
function FruitScene:loadResource()
	FruitScene.super.loadResource(self)
end

--卸载资源
function FruitScene:unloadResource()
    cc.AnimationCache:destroyInstance()
    display.removeUnusedSpriteFrames()
	FruitScene.super.unloadResource(self)
end

function FruitScene:initialize()
	FruitScene.super.initialize(self)

    local effct = cc.FileUtils:getInstance():getValueVectorFromFile("games/fruit/effect.plist")
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

--    dump(self.m_arrIconPos)
end

--进入场景
function FruitScene:onEnter()
	FruitScene.super.onEnter(self)
    self:viewDidLoad()
	PLAY_MUSIC(GAME_FISH_SOUND_RES..string.format("bgm%d.mp3", math.random(1, 4)))
end

--退出场景
function FruitScene:onExit()
	STOP_MUSIC()
    self:finalize()
	FruitScene.super.onExit(self)
end


function FruitScene:viewDidLoad()
    local name = ccui.Text:create("", "", 22)
    local money = ccui.Text:create("", "", 22)
    name:setPosition(cc.p(280, 708))
    money:setPosition(cc.p(1080, 708))
    name:setTextColor(cc.c3b(255, 222, 5))
    money:setTextColor(cc.c3b(255, 222, 5))
    local pBG = self:seekChild("img_main_bg")
    pBG:addChild(name, 0, "Label_MyName")
    pBG:addChild(money, 0, "Label_MyMoney")

    _super.viewDidLoad(self)

	self.m_pAutoRunEffet = utils.GetAmt("sgj_zidong");
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
		if (self.m_nTimesLeftGame and self.m_nTimesLeftGame > 0) then
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
		PLAY_SOUND_CLICK()
		self.m_bAutoRunning = false
	end)
	pAuto:addChild(self.m_pAutoRunEffet)

	self.m_pOver:addClickEventListener(function()
		PLAY_SOUND_CLICK()
		if (self.m_bRunning and not self.m_bStopping and not self.m_bAutoRunning) then
			self:Stop()
		end
	end)
	self.m_pMultipleBtnInc:addClickEventListener(function()
		self.m_nCurMultiple = math.min(self.m_nMaxMultiple, self.m_nCurMultiple + self.m_nMaxMultiple / 5);
		self.m_pBetSingle:setString(utils:moneyString(self.m_nCurMultiple * self.m_llSingleBet));
	    self.m_pBetTotal:setString(utils:moneyString(self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	end)
	self.m_pMultipleBtnDec:addClickEventListener(function()
		self.m_nCurMultiple = math.max(1, self.m_nCurMultiple - self.m_nMaxMultiple / 5);
		self.m_pBetSingle:setString(utils:moneyString(self.m_nCurMultiple * self.m_llSingleBet));
	    self.m_pBetTotal:setString(utils:moneyString(self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	end)
	self.m_pMaxBet:addClickEventListener(function()
		self.m_nCurMultiple = self.m_nMaxMultiple
		self.m_pBetSingle:setString(utils:moneyString(self.m_nCurMultiple * self.m_llSingleBet));
	    self.m_pBetTotal:setString(utils:moneyString(self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	end)

	local pAmt = utils.GetAmt("sgj_sgxml");
	pAmt:setPosition(cc.p(20 + 454, 340));
	self.m_pLittleGame:addChild(pAmt, -1);

	self.m_pWinFree = utils.GetAmt("sgj_mianfei", false);
	self.m_pWinFree:setPosition(250, 280);
	self.m_pWinFree:setVisible(false);
	self.m_pWinLG:addChild(self.m_pWinFree);

	self.m_pWinGame = utils.GetAmt("sgj_mianfei_xiaomali", false);
	self.m_pWinGame:setPosition(250, 280);
	self.m_pWinGame:setVisible(false);
	self.m_pWinLG:addChild(self.m_pWinGame);

    self.m_arrWinTips = {}
	self.m_arrWinTips[1] = self:seekChildByName("Image_Tips1");
	self.m_arrWinTips[2] = self:seekChildByName("Image_Tips2");

	pAmt = utils.GetAmt("zhongjiang_tongyong");
	pAmt:setPosition(510, 260);
	self.m_pLGWin:addChild(pAmt, -1);

	pAmt = utils.GetAmt("sgj_jmpaomad");
	pAmt:setPosition(cc.p(321, 659));
	self.m_pBG:addChild(pAmt);
	pAmt = utils.GetAmt("sgj_jmpaomad");
	pAmt:setPosition(cc.p(1010, 659));
	pAmt:setScaleX(-1);
	self.m_pBG:addChild(pAmt);

	self.m_pCoinBoxAmt = utils.GetAmt("hylj_zhongjiangfankui");
	self.m_pCoinBoxAmt:setPosition(cc.pAdd(cc.p(self.m_pIcome:getPosition()), cc.p(0, 0)));
	self.m_pCoinBoxAmt:setVisible(false);
	self.m_pIcome:getParent():addChild(self.m_pCoinBoxAmt);

    local quit = ccui.Button:create("common/images/btn_back.png", "common/images/btn_back.png")
    self.m_pBG:addChild(quit)
    quit:setPosition(cc.p(40, 710))
    quit:addClickEventListener(function() 
        self.core:quitGame()
    end)

    self:MakeLongPushButton(self.m_pStart, function() self:ReqStart() end, function() self:ReqStart() self.m_bAutoRunning = true end, GAME_FRUIT_ANIMATION_RES.."scene/sgj_juli_lizi.plist")

    self.m_help = require("app.common.HelpUI"):create(2, GAME_FRUIT_IMAGES_RES.."help", cc.p(-530, 0), cc.p(530, 0), cc.p(555 + 30, 275 + 28))
    self:addChild(self.m_help)
    self.m_help:setVisible(false)
end




-------------------------------------------------主线----------------------------------------------------
function FruitScene:FreeGameScene(pData)
dump(pData)
	self.m_llSingleBet = pData.MinBet / self.argT.lines
	self.m_nMaxMultiple = pData.MaxBet / pData.MinBet
	self.m_nCurMultiple = self.m_nMaxMultiple
	self.m_nTimesLeft4Free = pData.nLeftNum

--    if App.gameData[MsgCenter.gameKindID].m_bAutoRunning or App.gameData[MsgCenter.gameKindID].m_nCurMultiple ~= 1 then
--        self.m_nCurMultiple = App.gameData[MsgCenter.gameKindID].m_nCurMultiple or self.m_nCurMultiple
--        self.m_bAutoRunning = App.gameData[MsgCenter.gameKindID].m_bAutoRunning
--    end

	self.m_pBetSingle:setString(utils:moneyString(self.m_nCurMultiple * self.m_llSingleBet))
	self.m_pBetTotal:setString(utils:moneyString(self.m_llSingleBet * self.m_nCurMultiple * self.argT.lines))
	self.m_pLeftGame:setString(string.format("%d", pData.nSmallMaryNum));
	self.m_pFreeTimes:setString(string.format("%d", self.m_nTimesLeft4Free));

	if (pData.nSmallMaryNum > 0) then
		self:_start_inner_game();
	else
        self:CheckAutoStart()
    end
end

function FruitScene:ReqStart()
	if (not self.m_bRunning) then
		if (self:CheckMoney4Run()) then
			local data = { lBetScore = self.m_nCurMultiple * self.m_llSingleBet * self.argT.lines}
	        self.core:sendGameMsg(self.argT.startCommand, data)
--			MsgCenter:SendDataToServerG(200, self.argT.startCommand, data, self.argT.startProtoName)
			self.m_pStart:setEnabled(false)
			self.m_pStart:waitAndCall(1.5, function()
				self.m_pStart:setEnabled(true)
			end)
		end
	end
end

-- N个拉霸的游戏协议都不一样，这里对拉动后的返回协议做适配统一成一种格式
function FruitScene:AdaptGameInfo()
    self.m_GameData.line = self.m_GameData.Line
    self.m_GameData.winScore = self.m_GameData.Score
    self.m_GameData.m_TableLight = self.m_GameData.TableLight
    self.m_GameData.winScore = self.m_GameData.Score
    self.m_GameData.userScore = self.m_GameData.lCurrentScore
    self.m_GameData.FreePullTime = self.m_GameData.nFreeRoundLeft
    dump(self.m_GameData)
    local tmp = {{}, {}, {}, {}, {}}
    for k, v in pairs(self.m_GameData.m_Table) do
        tmp[k % 5 + 1][1 + math.floor(k / 5)] = v
    end
    local tmp2 = {{}, {}, {}, {}, {}}
    for k, v in pairs(self.m_GameData.m_TableLight) do
        tmp2[k % 5 + 1][1 + math.floor(k / 5)] = v
    end
----    self.m_GameData.m_Table = tmp
    self.m_GameData.m_Table = tmp
    self.m_GameData.m_TableLight = tmp2
    self.m_GameData.littleGameWin = self.m_GameData.nMarryNum
end

function FruitScene:CalcRunningInfo()
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

        if self.m_GameData.bSpeedUp[col] ~= 0 then
            accNum = accNum + 1
            self.m_GameData.runInfo[col].accMoment = self.m_GameData.runInfo[col - 1].dur
            self.m_GameData.runInfo[col].accEff = "sgj_jiasu"
        end
	end

    dump(self.m_GameData)
end

function FruitScene:startRun(data)
    _super.startRun(self, data)
end

function FruitScene:AfterMakeResult(fResultLast, llWinNum)
    return fResultLast
end

function FruitScene:Update()
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
function FruitScene:_show_win_panel(llWin, nLv)
	local arrEff = {"sgj_zhongjiangjs_diban", "sgj_zhongjiangjs_big", "sgj_zhongjiangjs_super", "sgj_zhongjiangjs_mega"};
	local pAmt = utils.GetAmt(arrEff[1], false);
	pAmt:setPosition(667, 367);
	pAmt:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		local pMoney = ccui.TextBMFont:create("0", GAME_FRUIT_FONT_RES.."num3.fnt");
		pMoney:setPositionY(27);
		pAmt:addChild(pMoney, 99);
		pAmt:getAnimation():playWithIndex(0);
        utils.numberGO(pMoney, 0, llWin, 2, function(a, over)
			pMoney:setString(utils:moneyString(a, 0));
	        self.m_pIcome:setString(utils:moneyString(a, 0));
			if (over) then
--				self:PlayIconEffect(self.m_pMyIcon, llWin, nLv);
            end
		end);
		if (nLv > 0) then
			local light = cc.Sprite:create(GAME_FRUIT_ANIMATION_RES.."result/sgj_jisuan_00.png");
			local light2 = cc.Sprite:create(GAME_FRUIT_ANIMATION_RES.."result/sgj_jisuan_01.png");
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
		local pAmt2 = utils.GetAmt(arrEff[math.min(4, nLv + 1)]);
		pAmt2:setPosition(7, 120);
		pAmt:addChild(pAmt2);
		pAmt:setPositionY(267);
	end
	PLAY_SOUND(GAME_FRUIT_SOUND_RES..string.format("win1.wav%d", 1 + math.min(2, nLv + 1)));
end

function FruitScene:PlayIconEffect(pIcon, llScore, nLv)
	local pAmt1 = utils.GetAmt("sgj_zhongjiangtoux");
	pIcon:getParent():addChild(pAmt1);
	pAmt1:setPosition(cc.pFromSize(cc.sizeSub(cc.sizeMul(pIcon:getContentSize(), 0.5), cc.size(50, 68))));
	pAmt1:runAction(cc.Sequence:create(cc.CallFunc:create(function()
		if (nLv > 0) then
			local pWinNum = cc.Sprite:create(string.format(GAME_FRUIT_ANIMATION_RES.."player/win%d.png", nLv));
			pWinNum:setPosition(cc.sizeSub(cc.sizeMul(pIcon:getContentSize(), 0.5), cc.size(50, 62)));
			pWinNum:runAction(cc.Sequence:create(cc.MoveBy:create(2.5, cc.p(0, 80)), cc.RemoveSelf:create()));
			pWinNum:setScale(nLv == 2 and 0.8 or 0.9);
			pIcon:getParent():addChild(pWinNum);
		
			local lizi_bj = cc.ParticleSystemQuad:create(GAME_FRUIT_ANIMATION_RES.."player/sgj_txzj_lizi.plist");
			lizi_bj:setPosition(pIcon:getPosition());
			pIcon:getParent():addChild(lizi_bj);
		end
	end), cc.DelayTime:create(2), cc.RemoveSelf:create()));
end

function FruitScene:_start_inner_game()
	PLAY_MUSIC(GAME_FISH_SOUND_RES.."bonus_bgm.mp3");
	self:_show_little_game_ui(true, 2);
	self.m_pLittleGame:setScale(0);
	self.m_pLittleGame:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
		cc.CallFunc:create(function()
	    self.core:sendGameMsg(FRUIT.CMD.SUB_C_MARRY)
--		MsgCenter:SendDataToServerG(200, 3);
--		self.m_pPlayers:ActiveMe(false);
	end)));
	self.m_pLGWinNumCur:setString("0");
	self.m_pWinLGTimes:stopAllActions();
end

function FruitScene:_run_target(from, target)
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
	vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() PLAY_SOUND(GAME_FRUIT_SOUND_RES.."sgj_start.wav"); end));
	for i = 0, nStartSteps - 1 do
        local index = (from + nStepCounter) % ICON_NUM
		vtrActions[#vtrActions + 1] = (cc.DelayTime:create(arrStartTimeSlots[i + 1]));
		vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() self:_run_step(index, false, i / 100); end));
        nStepCounter = nStepCounter + 1
	end
    local loop = true
	while (loop) do
		vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() PLAY_SOUND(GAME_FRUIT_SOUND_RES.."sgj_loop.wav"); end));
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

	vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() STOP_ALL_SOUND();  PLAY_SOUND(GAME_FRUIT_SOUND_RES.."sgj_end.wav"); end));
	for i = 0, nEndSteps - 1 do
        local index = (from + nStepCounter) % ICON_NUM
		vtrActions[#vtrActions + 1] = (cc.DelayTime:create(arrEndTimeSlots[i + 1]));
		vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() self:_run_step(index, i == nEndSteps - 1, (nEndSteps - i - 1) / 100); end));
        nStepCounter = nStepCounter + 1
	end
	vtrActions[#vtrActions + 1] = (cc.CallFunc:create(function() PLAY_SOUND(GAME_FRUIT_SOUND_RES.."sgj_endEx.wav"); end));
	self:runAction(cc.Sequence:create(vtrActions));
end

local function BesideOf(base, step)
	base = (base + step) % ICON_NUM;
	if (base < 0) then
		base = base + ICON_NUM;
	end
	return base;
end

function FruitScene:_run_step(index, over, speed)
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
		PLAY_SOUND(GAME_FRUIT_SOUND_RES.."coinRoll.wav");
        self.m_MyMoney:setString(utils:moneyString(self.m_LGameData.UserScore, 2))
		self.m_pLGWinNum:setString(utils:moneyString(self.m_LGameData.TotalWin));
		utils.numberGO(self.m_pLGWinNumCur, tonumber(self.m_pLGWinNumCur:getString()), self.m_LGameData.TotalWin, 1, function(a, over)
			self.m_pLGWinNumCur:setString(utils:moneyString(a, 0));
		end);
		local nTimes = self.m_nTimesLeftGame;
		self.m_pLGWinNumCur:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
			if (self.m_nTimesLeftGame > 0) then
--				MsgCenter:SendDataToServerG(200, 3);
	            self.core:sendGameMsg(FRUIT.CMD.SUB_C_MARRY)
--				self.m_pPlayers:ActiveMe(false);
			else
				self:_show_little_game_ui(true, 3);
			end
		end), cc.DelayTime:create(5), cc.CallFunc:create(function()
			if (nTimes == 0) then
				self.m_bRunning = false;
				self:_show_little_game_ui(false);
				self:CheckAutoStart();
	            PLAY_MUSIC(GAME_FISH_SOUND_RES.."bgm.mp3");
			end
		end)));
--		self.m_pPlayers:ActiveMe(true);
	end
end

function FruitScene:_show_little_game_ui(bShow, type, type2)
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
function FruitScene:startLGame(data)
	self.m_LGameData = data
	local nIndex = arrIndex2Fruit[self.m_LGameData.Fruit][math.random(1, #arrIndex2Fruit[self.m_LGameData.Fruit])];
	self:_run_target(self.m_nCurLGameIconIndex or 0, nIndex);
	self.m_nCurLGameIconIndex = nIndex;
	self.m_nTimesLeftGame = self.m_LGameData.nMarryLeft;

	self.m_pLeftGame:setString(string.format("%d", self.m_LGameData.nMarryLeft));
	self.m_pLGRunTimes:setString(string.format("%d", self.m_LGameData.nMarryNum));
end

-------------------------------------------------事件----------------------------------------------------
function FruitScene:StartGame()
    self.m_MyMoney:setString(utils:moneyString(self.m_GameData.userScore, 2))
	self:runAction(cc.Sequence:create(cc.DelayTime:create(llWinNum and 4 or 0), cc.CallFunc:create(function()
		self.m_nTimesLeftGame = self.m_GameData.nMarryNum;
		self.m_pWinLGTimes:setString(string.format("%d", self.m_GameData.nMarryNum));
		self.m_pWinLGTimes:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
			self:_show_little_game_ui(true, 1);
		end), cc.DelayTime:create(15), cc.CallFunc:create(function()
			self:_start_inner_game();
		end)));
	end)));
end

function FruitScene:OnNewFreeTimes(fResultLast)
	PLAY_MUSIC(GAME_FISH_SOUND_RES.."bgmFire.mp3")
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		self.m_pWinLGTimes:setString(string.format("%d", self.m_GameData.FreePullTime));
		self:_show_little_game_ui(true, 1, 1);
	end), cc.DelayTime:create(3), cc.CallFunc:create(function()
		self:_show_little_game_ui(false);
	end)));
	fResultLast = math.max(5, fResultLast);
	return fResultLast;
end

--function FruitScene:OnFreeTimesOver()
--end

function FruitScene:GetWinType(llScore)
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

function FruitScene:LittleWin(llWinNum, nWinLv)
	self:_show_win_panel(llWinNum, nWinLv);
    return 3
end

function FruitScene:BigWin(llWinNum, nWinLv)
	self:_show_win_panel(llWinNum, nWinLv);
	return 3
end

function FruitScene:onSystemMessage(msg)
    if self.mMessageLayer then
        self.mMessageLayer:InsertSystemString(msg.szString)
    end
end







return FruitScene

--endregion
