local device = require('cocos.framework.device')
local HBScene = class("HBScene", GameSceneBase)

local STATUS_NIL = 100
local STATUS_PLAY = 101
local STATUS_JIESUAN = 102

print = release_print

-- 资源名
HBScene.RESOURCE_FILENAME = "games/hb/HBScene.csb"
-- 资源绑定
HBScene.RESOURCE_BINDING = {
	--top panel
--	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
}

function HBScene:ctor( core )
	HBScene.super.ctor(self,core)
    self.reduncantPlayer = {}
    setmetatable(self.reduncantPlayer, {__mode = "v"})
end

--加载资源
function HBScene:loadResource()
	HBScene.super.loadResource(self)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GAME_HB_ANIMATION_RES.."Bomb.plist")

    local animation = cc.Animation:create()
    for index = 1, 5 do
        local name = string.format("zhadan_texiao0%d.png", index)
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
        animation:addSpriteFrame(frame)
    end
    animation:setDelayPerUnit(0.15)
--    animation:setRestoreOriginalFrame(true)
--    animation:setLoops(1)

    self.explosion = cc.Animate:create(animation)
    self.explosion:retain()
end

--卸载资源
function HBScene:unloadResource()
    self.explosion:release()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GAME_HB_ANIMATION_RES.."Bomb.plist")
	HBScene.super.unloadResource(self)
end

function HBScene:initialize()
	HBScene.super.initialize(self)
    self:setScale(display.height / 720)
end

--进入场景
function HBScene:onEnterTransitionFinish()
	HBScene.super.onEnterTransitionFinish(self)
    self:viewDidLoad()
    PLAY_MUSIC(GAME_HB_SOUND_RES.."bg.mp3", true);
end

--退出场景
function HBScene:onExitTransitionStart()
    self.m_pTextMyMoney:setString(utils:moneyString(dataManager.userInfo.money, 1))
	STOP_MUSIC()
    self.m_pCD:unscheduleUpdate()
	HBScene.super.onExitTransitionStart(self)
end


function HBScene:viewDidLoad()
	self.pDlgNewBomb= self:seekChildByName("Dlg_New_Bomb");
	local pDlgPlayers = self:seekChildByName("Dlg_Players");
--	local pDlgRule= self:seekChildByName("Dlg_Rule");
	self.pDlgNewBomb:setLocalZOrder(3)
	pDlgPlayers:setLocalZOrder(3)

	self.m_pCD = self:seekChildByName("Text_CD");
    self.m_pCD:getParent():setLocalZOrder(2)
    self.m_pCD:getParent():setVisible(false)

	self.m_pTextPackMoney = self:seekChildByName("Text_Pack_Money");
	self.m_pTextPackNum = self:seekChildByName("Text_Pack_Num");
	self.m_pTextPackCode = self:seekChildByName("Text_Pack_Code");
	self.m_pIconBanker = self:seekChildByName("head_icon_banker");
	self.m_pTextBankerName = self:seekChildByName("Text_Name_banker");
	self.m_pTextBankerWin = self:seekChildByName("BitmapFontLabel_BankerWin");
	self.m_pIconMe = self:seekChildByName("head_icon");
	self.m_pRedPack = self:seekChildByName("red_pack");
	self.m_pRedPack.cover = self.m_pRedPack:seekChildByName("Image_Cover");
	self.m_pRedPack.open = self.m_pRedPack:seekChildByName("Image_Open");
	self.m_pRedPack.light = self.m_pRedPack:seekChildByName("Image_Light");
	self.m_pRedPack.get = self.m_pRedPack:seekChildByName("BitmapFontLabel_IGet");
	self.m_pTextPrompt = self:seekChildByName("Text_Prompt");
	self.m_pTextMyMoney = self:seekChildByName("Text_My_Money");
	self.m_pTextMyName = self:seekChildByName("Text_My_Name");
	self.m_pTextMyWin = self:seekChildByName("BitmapFontLabel_MyWin");
	self.m_pTextMyName:setString(dataManager.userInfo.nickname);
	self.m_pTextMyMoney:setString(utils:moneyString(dataManager.userInfo.money, 1));
	self.m_pTextMyWin:setString("");
 	SET_HEAD_IMG(self.m_pIconMe, dataManager.userInfo.headid, dataManager.userInfo.wxheadurl)
    self.m_pIconMe:setContentSize(cc.size(76, 76))
    self.m_pIconBanker:setContentSize(cc.size(76, 76))
    self.m_pRedPack.open:setVisible(false)
    self.m_pRedPack.get:setString("")
	self.m_pRedPack.light:setBlendFunc({src = GL_SRC_ALPHA, dst = 1});
    self.m_pRedPack.light:runAction(cc.RepeatForever:create(cc.RotateBy:create(5, 360)))
    self.m_pTextPrompt:getParent():setCascadeOpacityEnabled(true)
    self.m_pTextPrompt:getParent():setVisible(false)
    self.m_pTextPrompt:getParent():setLocalZOrder(5)
    self.m_pTextMyMoney:enableOutline(cc.c4b(100, 100, 100, 255), 1)
    self.m_pTextPackMoney:enableOutline(cc.c4b(100, 100, 100, 255), 1)
    self.m_pTextPackNum:enableOutline(cc.c4b(100, 100, 100, 255), 1)
    self.m_pTextPackCode:enableOutline(cc.c4b(100, 100, 100, 255), 1)

	local pQuit = self:seekChildByName("Button_Quit");
	local pNewBomb = self:seekChildByName("Button_NewBomb");
	local pRule = self:seekChildByName("Button_Rule");
	local pSetting = self:seekChildByName("Button_Setting");
	local pPlayers = self:seekChildByName("Button_Players");
--	local pCloseR = pDlgRule:seekChildByName("Button_Close");
	local pCloseNB = self.pDlgNewBomb:seekChildByName("Button_Close");
	local pCloseP = pDlgPlayers:seekChildByName("Button_Close");

    local popOut = function(node)
        node:setVisible(true)
        node:getChildren()[1]:setScale(0)
        node:getChildren()[1]:waitAndActions(0, cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)))
	    PLAY_SOUND(GAME_HB_SOUND_RES.. "dianji1.mp3");
    end
    local popIn = function(node)
        node:getChildren()[1]:waitAndActions(0, cc.EaseBackIn:create(cc.ScaleTo:create(0.3, 0)), cc.CallFunc:create(function ()
            node:setVisible(false)
        end))
	    PLAY_SOUND(GAME_HB_SOUND_RES.. "guanbi.mp3");
    end
	pQuit:addClickEventListener(function()      
    if self.m_pBtnBombOK.me then
        self.core:sendGameMsg(HB.CMD.CANCAL_BANK)
    end
    if self.banker == dataManager.userInfo.playerid then
        return self:showPrompt("请稍等几秒，您还在做庄呢")
    end
    if self.isbomb == true then
        return self:showPrompt("请先取消埋雷")
    end
    self.core:quitGame() end);
	pSetting:addClickEventListener(function()   self:showSettings() end); 

	pRule:addClickEventListener(function()      self:showRule() end);
	pNewBomb:addClickEventListener(function()   popOut(self.pDlgNewBomb) end);
    pPlayers:addClickEventListener(function()   popOut(pDlgPlayers) end);

--    pCloseR:addClickEventListener(function()    popIn(pDlgRule) end);        pDlgRule:setVisible(false)
    pCloseNB:addClickEventListener(function()   popIn(self.pDlgNewBomb) end);self.pDlgNewBomb:setVisible(false)
    pCloseP:addClickEventListener(function()    popIn(pDlgPlayers) end);     pDlgPlayers:setVisible(false)
    self.m_pRedPack:setLocalZOrder(2)    
    self.m_pRedPack:setTouchEnabled(true)    
    self.m_pRedPack:addTouchEventListener(function(node, event_type_)
		if event_type_ == cc.EventCode.BEGAN then
            self.m_pRedPack:stopActionByTag(999)
            local action = cc.Sequence:create(cc.ScaleTo:create(0.2, 0.95), cc.ScaleTo:create(0.1, 1))
            action:setTag(999)
            self.m_pRedPack:runAction(action)
	        PLAY_SOUND(GAME_HB_SOUND_RES.. "dianji1.wav");
		elseif event_type_ == cc.EventCode.ENDED then
            if self.m_pCD:getParent():isVisible() and not self.m_pCD.send then
                self.core:sendGameMsg(HB.CMD.ROD_RED)
                self.m_pCD.send = true
            end
		elseif event_type_ == cc.EventCode.CANCELED then
            self.m_pRedPack:setScale(1)
		end
    end);

    self.m_arrPlayers = {}
	for i = 1, 10 do
		self.m_arrPlayers[i] = self:seekChildByName(string.format("item_bg%d", i));
		self.m_arrPlayers[i].icon = self.m_arrPlayers[i]:seekChildByName("head_icon");
		self.m_arrPlayers[i].name = self.m_arrPlayers[i]:seekChildByName("Text_Name");
		self.m_arrPlayers[i].get = self.m_arrPlayers[i]:seekChildByName("Text_Get");
		self.m_arrPlayers[i].win = self.m_arrPlayers[i]:seekChildByName("BitmapFontLabel_Win");
		self.m_arrPlayers[i].get:setTextColor(cc.c3b(255, 217, 60))
--		self.m_arrPlayers[i]:setVisible(false)

        local icon2 = self.m_pIconMe:clone()
        icon2:setPosition(cc.p(self.m_arrPlayers[i].icon:getPosition()))
		self.m_arrPlayers[i].icon:getParent():addChild(icon2)
		self.m_arrPlayers[i].icon:removeFromParent()
		self.m_arrPlayers[i].icon = icon2
--		self.m_arrPlayers[i]:getVirtualRenderer():getSprite():setBlendFunc({src = GL_SRC_ALPHA, dst = 1});
	end
	self.m_pExtraItem = self:seekChildByName("item_extra");
	self.m_pExtraItem.txt = self.m_pExtraItem:seekChildByName("Text_Tips");
    self.m_pExtraItem:setVisible(false)

    -- 玩家列表 pDlgPlayers
	self.m_pTextPlayerNum = self:seekChildByName("Text_Player_Num");
    self.m_pTextPlayerNum:setString(0)
	self.m_pListPlayers = pDlgPlayers:seekChildByName("ListView_Players");
    self.m_pListPlayers:setScrollBarEnabled(false)
    self.m_pItemPlayerT = pDlgPlayers:seekChildByName("item_Player_T");
    self.m_pItemPlayerT:setVisible(false)
    self.m_pItemPlayerT.Clone = function(node, playerid, score)
        local item = node:clone()
	    item.icon = item:seekChildByName("head_icon");
	    item.name = item:seekChildByName("Text_Name");
	    item.money = item:seekChildByName("Text_Money");
	    item.rank = item:seekChildByName("Text_Rank");
		item.icon:setContentSize(cc.size(66, 66))
        item:setVisible(true)

        local player = self.model:getPlayer(playerid)
        if player then
 	        SET_HEAD_IMG(item.icon, player.headid, player.wxheadurl)
 	        item.name:setString(utils:nameStandardString(player.nickname, item.name:getFontSize(), node.width))
 	        item.money:setString(utils:moneyString(score or player.money, 0))
 	        item.rank:setString(node.NO)
        end

        return item;
    end

    -- 埋雷界面 pDlgNewBomb
	self.m_pTextSetMoney = self.pDlgNewBomb:seekChildByName("Text_SetMoney");
	self.m_pSlider = self.pDlgNewBomb:seekChildByName("Slider");
	self.m_pBombCode = self.pDlgNewBomb:seekChildByName("Text_Bomb_Code");
	self.m_pMultipleMax = self.pDlgNewBomb:seekChildByName("Text_MultipleR");
    self.m_pMoneyOption = {}
	for i = 1, 4 do
		self.m_pMoneyOption[i] = self:seekChildByName(string.format("Button_Option%d", i));
		self.m_pMoneyOption[i]:addClickEventListener(function()
            self.m_pTextSetMoney:setString(self.m_pMoneyOption[i]:getTitleText())
            self.m_pTextSetMoney.value = tonumber(self.m_pMoneyOption[i]:getTitleText()) * 100
        end);
	end
    self.m_pBtnNumberOK = self.pDlgNewBomb:seekChildByName("Button_Number_OK");
    self.m_arrKeyBoard = {sel = nil}
	for i = 0, 9 do
		self.m_arrKeyBoard[i] = self:seekChildByName(string.format("Button_Num%d", i));
		self.m_arrKeyBoard[i]:addClickEventListener(function()
            self.m_pBombCode:setString(i)
            if self.m_arrKeyBoard.sel then self.m_arrKeyBoard.sel:setEnabled(true) end
            self.m_arrKeyBoard[i]:setEnabled(false)
            self.m_arrKeyBoard.sel = self.m_arrKeyBoard[i]
        end);
	end
	self.m_pSlider:addEventListener(function(n, t)
        if t == 0 then
            local nRange = self.gameConfig.redMaxR - self.gameConfig.redMin
            local value = math.ceil(self.gameConfig.redMin + self.m_pSlider:getPercent() / 100 * nRange)
            value = math.floor(value / 1000) * 1000
            self.m_pTextSetMoney:setString(utils:moneyString(value, 0))
            self.m_pTextSetMoney.value = value
        end
    end);
    self.m_pBombCode:addClickEventListener(function(t)
        self.m_pBombCode:getParent():setVisible(false)
        self.m_pBtnNumberOK:setVisible(true)
    end)
    self.m_pBtnNumberOK:addClickEventListener(function(t)
        self.m_pBombCode:getParent():setVisible(true)
        self.m_pBtnNumberOK:setVisible(false)
    end)

    self.m_pBtnBombOK = self.pDlgNewBomb:seekChildByName("Button_OK");
    self.m_pListCandidates = self.pDlgNewBomb:seekChildByName("ListView_Candidates");
    self.m_pListCandidates:setScrollBarEnabled(false)
	self.m_pBtnBombOK:addClickEventListener(function()
        local code = tonumber(self.m_pBombCode:getString())
        local coin = self.m_pTextSetMoney.value
        local data = {lScore = coin, bankThunder = code}
        if self.m_pBtnBombOK.me then
            self.core:sendGameMsg(HB.CMD.CANCAL_BANK)
        else
            self.core:sendGameMsg(HB.CMD.APPLY_BANK, data)
        end
	    PLAY_SOUND(GAME_HB_SOUND_RES.. "dianji1.mp3");
    end);

    self.m_pItemPlayerT2 = self.pDlgNewBomb:seekChildByName("Image_Item_T2");
    self.m_pItemPlayerT2:setVisible(false)
    self.m_pItemPlayerT2.Clone = self.m_pItemPlayerT.Clone
    self:clear()

    local leftNode = self:seekChildByName("Node_left");
    local rightNode = self:seekChildByName("Node_right");
    
    self:setPositionX((display.width -  self:getScale() * 1280) / 2)
    leftNode:setPositionX(self:convertToNodeSpace(cc.p(0, 0)).x)
    rightNode:setPositionX(self:convertToNodeSpace(cc.p(display.width, 0)).x)
    SET_ROLL_ANNOUNCE_PARENT_POSY(self.resourceNode, 490 )    

	self:scheduleUpdateWithPriorityLua(function (deltaT)
		self:Update(deltaT)
    end, 1)
end


function HBScene:Update(dt)
    if self.gameConfig then
        local maxMulti = self.gameConfig.redMax / self.gameConfig.redMin
        local realMulti = math.floor(dataManager.userInfo.money / self.gameConfig.redMin)
        self.gameConfig.redMaxR = math.min(realMulti, maxMulti) * self.gameConfig.redMin
        self.m_pMultipleMax:setString(string.format("%d倍", math.min(realMulti, maxMulti)))
    end
    self.m_pTextPlayerNum:setString(self.model:getPlayerNum())
    rolledAnnounceLayer:setPositionX(self.m_pTextPrompt:getParent():getPositionX())
	rolledAnnounceLayer:setLocalZOrder(2)
end

function HBScene:FreeGameScene(data)
dump(data, "场景"..data.gameStatus)
    self.gameConfig = data.gameConfig
    self:clear()
    if data.gameStatus >= STATUS_PLAY then
        self:newRound({bankThunder = data.bankThunder, coin = data.bankMoney, left = data.leftTime, bank_playid = data.bank_playid})
    end

    local step = (data.gameConfig.redMax - data.gameConfig.redMin) / 3
	for i = 1, 4 do
		self.m_pMoneyOption[i]:setTitleText(utils:moneyString(data.gameConfig.Buttons[i]))
		self.m_pMoneyOption[i]:getTitleLabel():setPositionY(36)
	end
    local maxMulti = self.gameConfig.redMax / self.gameConfig.redMin
    local realMulti = math.floor(dataManager.userInfo.money / self.gameConfig.redMin)
    self.gameConfig.redMaxR = math.min(realMulti, maxMulti) * self.gameConfig.redMin

--    self.gameConfig.redNum = 7
    local numSide = math.ceil(self.gameConfig.redNum / 2)
    if numSide ~= 5 and not self.adjusted then
        self.adjusted = true

        local Y = self.m_arrPlayers[1]:getParent():getPositionY()
        local size = self.m_arrPlayers[1]:getParent():getContentSize()
        local offY = self.m_arrPlayers[1]:getPositionY() - self.m_arrPlayers[2]:getPositionY()
        local decNum = 5 - numSide
        local lp = self.m_arrPlayers[1]:getParent()
        local rp = self.m_arrPlayers[6]:getParent()
        lp:setContentSize(cc.size(size.width, size.height - decNum * offY))
        rp:setContentSize(cc.size(size.width, size.height - decNum * offY))
        lp:setPositionY(Y + decNum * offY / 2)
        rp:setPositionY(Y + decNum * offY / 2)
        local curCount = 1
	    for i = 1, 10 do
		    self.m_arrPlayers[i]:setPositionY(self.m_arrPlayers[i]:getPositionY() - decNum * offY);
            local sideIndex = (i <= 5 and i or i - 5)
            if sideIndex <= numSide then
		        self.m_arrPlayers[curCount] = self.m_arrPlayers[i]
                curCount = curCount + 1
            end
	    end
        if math.floor(self.gameConfig.redBl) ~= self.gameConfig.redBl then
            self.m_pExtraItem.txt:setString(string.format("%d包%.1f倍", self.gameConfig.redNum, self.gameConfig.redBl))
        else
            self.m_pExtraItem.txt:setString(string.format("%d包%d倍", self.gameConfig.redNum, self.gameConfig.redBl))
        end
        
        self.m_pExtraItem:setVisible(true)
    end
    self.m_arrPlayers.curNum = 0
    self.m_pListCandidates:removeAllItems()
    for i, v in ipairs(data.jiesuan or {}) do
        v.status = 1
        v.playerid = v.playerid or v.playid
        self:playerRob(v)
    end
    if data.gameStatus == STATUS_JIESUAN then
        self:result()
    end

    for k, v in ipairs(data.applyBanks or {}) do
        v.playerid = v.playerid
        v.status = 1
        self:newBomb(v)
    end
    self.m_pTextSetMoney:setString(utils:moneyString(data.gameConfig.redMin))
    self.m_pTextSetMoney.value = data.gameConfig.redMin
    self.m_pSlider:setPercent(0)
end

function HBScene:clear()
	for i = 1, 10 do
		self.m_arrPlayers[i]:setVisible(false)
		self.m_arrPlayers[i]:setTexture(GAME_HB_IMAGES_RES.."main/item_bg1.png")
        if self.m_arrPlayers[i].bomb then
            self.m_arrPlayers[i].bomb:removeFromParent()
            self.m_arrPlayers[i].bomb = nil
        end
    end
    self.m_pTextPackMoney:setString("")
    self.m_pTextPackNum:setString("")
    self.m_pTextPackCode:setString("")
    self.m_pTextBankerWin:setString("")
    self.m_pRedPack.cover:setVisible(true)
    self.m_pRedPack.open:setVisible(false)
    self.m_pRedPack.get:setString("")
    self.m_pTextMyWin:setString("")
    self:setBanker(0)
end

function HBScene:newRound(data)
dump(data, "新一轮")
    self:clear()
    self.m_pCD.send = false
    self.m_pCD:getParent():setVisible(true)
    data.leftTime = data.left or self.gameConfig.rodRedTime / 1000
    utils.numberGO(self.m_pCD, data.leftTime, 0, data.leftTime, function(l, over)
        if math.ceil(l) ~= self.m_pCD.value then
            PLAY_SOUND(GAME_HB_SOUND_RES.."countdown.mp3");
        end
        self.m_pCD:getParent():setVisible(not over)
        self.m_pCD:setString(string.format("倒计时%d秒", math.ceil(l)))
        self.m_pCD.value = math.ceil(l)
    end)
	for i = 1, 10 do
		self.m_arrPlayers[i]:setVisible(false)
    end
    self.m_arrPlayers.curNum = 0
    self.gameData = {leftRed = data.leftRed or self.gameConfig.redNum}
     
    self.m_pTextPackMoney:setString(utils:moneyString(data.coin))
    self.m_pTextPackNum:setString(self.gameConfig.redNum)
    self.m_pTextPackCode:setString(data.bankThunder)
    local myWin = dataManager.userInfo.money - self.m_pTextMyMoney:getString() * MONEY_SCALE
    if math.abs(myWin) >= 1 then
	    self.m_pTextMyWin:setFntFile(GAME_HB_FONT_RES.. (myWin > 0 and "number_win.fnt" or "number_lose.fnt"))
        self.m_pTextMyWin:setString((myWin >= 0 and "+" or "") .. utils:moneyString(myWin, 1));
	    self.m_pTextMyMoney:setString(utils:moneyString(dataManager.userInfo.money, 1));
    end
    if data.bank_playid then
        self:setBanker(data.bank_playid)
    end

    local find = false
    if not data.applyBanks then
        local offset = self.m_pListCandidates:getInnerContainerPosition()
        local items = self.m_pListCandidates:getItems()
        for i = #items, 1, -1 do
            if items[i].id == data.bank_playid then find = true end
            if find then
                self.m_pListCandidates:removeItem(i - 1)
            end
        end
        self.m_pListCandidates:setInnerContainerPosition(cc.p(offset.x, offset.y + 85))
        self.m_pListCandidates:doLayout()
        items = self.m_pListCandidates:getItems()
        for i, v in ipairs(items) do
            v.rank:setString(i)
        end
   end
end

function HBScene:newBomb(data)
dump(data, "埋雷")
    if data.status == 1 then
        self.m_pItemPlayerT2.NO = #self.m_pListCandidates:getItems() + 1
        self.m_pItemPlayerT2.width = 130
        local item = self.m_pItemPlayerT2.Clone(self.m_pItemPlayerT2, data.playid, data.lScore)
        item.id = data.playid
        local offset = self.m_pListCandidates:getInnerContainerPosition()
        self.m_pListCandidates:pushBackCustomItem(item)
        self.m_pListCandidates:setInnerContainerPosition(cc.p(offset.x, offset.y - 85))
        self.m_pListCandidates:doLayout()

        self.m_pBtnBombOK:setTouchEnabled(false)
        self.m_pBtnBombOK:waitAndCall(1, function() 
            self.m_pBtnBombOK:setTouchEnabled(true)
        end)
        if data.playid == dataManager.userInfo.playerid then
            self.isbomb = true
	        self.m_pTextMyMoney:setString(utils:moneyString(dataManager.userInfo.money, 1));
            self.m_pBtnBombOK.me = true
            self.m_pBtnBombOK:loadTextures(GAME_HB_IMAGES_RES.."newboomb/btn_boomb2.png", "", "")
            if self.pDlgNewBomb:isVisible() then
                self.pDlgNewBomb:setVisible(false)
                self:showPrompt("埋雷成功")
            end
        end
    end
end

function HBScene:cancalBomb(data)
    dump(data, "取消埋雷")
    
    local items = self.m_pListCandidates:getItems()
    local index = -1
    for i, v in ipairs(items) do
        if index == -1 and v.id == data.playid then
            index = i - 1
        else
            v.rank:setString((index == -1 or i <= index) and i or (i - 1))
        end
    end
    self.m_pListCandidates:removeItem(index)

    if data.playid == dataManager.userInfo.playerid then
        self.isbomb = false
        self.m_pTextMyMoney:setString(utils:moneyString(dataManager.userInfo.money, 1));
        self.m_pBtnBombOK.me = false
        self.m_pBtnBombOK:loadTextures(GAME_HB_IMAGES_RES.."newboomb/btn_boomb.png", "", "")
        self.pDlgNewBomb:setVisible(false)
        self:showPrompt("取消埋雷成功")
    end
end

function HBScene:changeStatge(data)
dump(data, "切换场景"..data.status)
    if data.status == STATUS_NIL then
        self:clear()        
    elseif data.status == STATUS_PLAY then
        self:newRound(data)
    elseif data.status == STATUS_JIESUAN then
        self:result()
    end
end

function HBScene:failed(data)
dump(data)
    self:showPrompt(data.msg)
end

function HBScene:playerRob(data)
--dump(data, "抢红包")
    if data.status ~= 1 then
        self:showPrompt(data.msg)
        return
    end
    local player = self.model:getPlayer(data.playerid)
    self.gameData.leftRed = self.gameData.leftRed - 1
    self.m_arrPlayers.curNum = self.m_arrPlayers.curNum + 1
    self.m_arrPlayers[self.m_arrPlayers.curNum]:setVisible(true)
	self.m_arrPlayers[self.m_arrPlayers.curNum].get:setString("");
	self.m_arrPlayers[self.m_arrPlayers.curNum].win:setString("");
    self.m_arrPlayers[self.m_arrPlayers.curNum].data = data
    self.m_pTextPackNum:setString(self.gameData.leftRed)
 	SET_HEAD_IMG(self.m_arrPlayers[self.m_arrPlayers.curNum].icon, player.headid, player.wxheadurl)
    local name = self.m_arrPlayers[self.m_arrPlayers.curNum].name
	name:setString(utils:nameStandardString(player.nickname, name:getFontSize(), 130));

    if data.realMoney < 0 then
        local bomb = cc.Sprite:create(GAME_HB_IMAGES_RES.."main/boomb.png")
        bomb:setPosition(cc.p(228, 90))
        self.m_arrPlayers[self.m_arrPlayers.curNum]:addChild(bomb)
        self.m_arrPlayers[self.m_arrPlayers.curNum].bomb = (bomb)
		self.m_arrPlayers[self.m_arrPlayers.curNum]:setTexture(GAME_HB_IMAGES_RES.."main/item_bg2.png")
    end

    if data.playerid == dataManager.userInfo.playerid then
	    self.m_arrPlayers[self.m_arrPlayers.curNum].get:setString(utils:moneyString(data.redMoney, 1));
        self.m_pRedPack:stopAllActions()
        self.m_pRedPack:waitAndActions(0, cc.ScaleTo:create(0.2, 1.1), cc.CallFunc:create(function() 
            self.m_pRedPack.cover:setVisible(false)
            self.m_pRedPack.open:setVisible(true)
            self.m_pRedPack.get:setString("+"..utils:moneyString(data.redMoney, 1))
	        PLAY_SOUND(GAME_HB_SOUND_RES.. (data.realMoney < 0 and "boom.wav" or "gongxi.mp3"));
        end), cc.ScaleTo:create(0.15, 1))


        if data.realMoney < 0 then
            local spt = cc.Sprite:create()
            spt:setPosition(cc.p(150, 200))
            self.m_pRedPack:addChild(spt)
            spt:waitAndActions(0, self.explosion, cc.RemoveSelf:create())
        end
    end
end

function HBScene:handleLeftRed(data)
dump(data, "返回庄家")
end

function HBScene:bankerWin(data)
dump(data, "庄家输赢")
    if data.money > 0 then
        self.m_pTextBankerWin:setString("+"..utils:moneyString(data.money))
    end
end

function HBScene:result()
print("结算")
    self.m_pCD:getParent():setVisible(false)
    self.m_pCD:unscheduleUpdate()

	for i = 1, self.m_arrPlayers.curNum do
        local get = utils:moneyString(self.m_arrPlayers[i].data.redMoney, 1)
        local win = utils:moneyString(self.m_arrPlayers[i].data.realMoney, 1)
        if self.m_arrPlayers[i].data.realMoney > 0 then
            win = "+"..win
		    self.m_arrPlayers[i].win:setFntFile(GAME_HB_FONT_RES.."number_win.fnt")
        else
		    self.m_arrPlayers[i].win:setFntFile(GAME_HB_FONT_RES.."number_lose.fnt")
        end
		self.m_arrPlayers[i].get:setString(get)
		self.m_arrPlayers[i].win:setString(win)
    end

    
    local myWin = dataManager.userInfo.money - self.m_pTextMyMoney:getString() * MONEY_SCALE
    if math.abs(myWin) >= 1 then
	    self.m_pTextMyWin:setFntFile(GAME_HB_FONT_RES.. (myWin > 0 and "number_win.fnt" or "number_lose.fnt"))
        self.m_pTextMyWin:setString((myWin >= 0 and "+" or "") .. utils:moneyString(myWin, 1));
	    self.m_pTextMyMoney:setString(utils:moneyString(dataManager.userInfo.money, 1));
    end
end

function HBScene:setBanker(id)
    if id == dataManager.userInfo.playerid then
        self.m_pBtnBombOK.me = false
        self.m_pBtnBombOK:loadTextures(GAME_HB_IMAGES_RES.."newboomb/btn_boomb.png", "", "")
    end
    self.m_pTextBankerName:setString("")
    self.m_pIconBanker:setVisible(id ~= 0)
    self.banker = id
    if self.banker == dataManager.userInfo.playerid then
        self.isbomb = false
    end
    if id == 0 then
        return
    end
    local banker = self.model:getPlayer(id)
 	SET_HEAD_IMG(self.m_pIconBanker, banker.headid, banker.wxheadurl)
    self.m_pTextBankerName:setString(utils:nameStandardString(banker.nickname, self.m_pTextBankerName:getFontSize(), 130))
end

function HBScene:clearPlayers()
    self.reduncantPlayer = {}
    self.m_pListPlayers:removeAllItems()
end

function HBScene:updatePlayers(info, go)
    local items = self.m_pListPlayers:getItems()
    if go then
        local index = -1
        self.reduncantPlayer[info.playerid] = nil
        for k, v in ipairs(items) do
            if index == -1 and v.id == info.playerid then
                index = k - 1
            else
                v.rank:setString((index == -1 or index >= k) and k or (k - 1))
            end
        end
        self.m_pListPlayers:removeItem(index)
        if #items <= 100 then
            local k, v = next(self.reduncantPlayer, nil)
            if v then
--                print("插入之前拒之门外的 ", k)
                self.reduncantPlayer[k] = nil
                return self:updatePlayers({playerid = k})
            end
        end
    else
        if #items >= 100 then
            self.reduncantPlayer[info.playerid] = 1
--            dump(self.reduncantPlayer)
            return
        end
        self.m_pItemPlayerT.NO = #items + 1
        self.m_pItemPlayerT.width = 200
        local item = self.m_pItemPlayerT.Clone(self.m_pItemPlayerT, info.playerid)
        item.id = info.playerid
        self.m_pListPlayers:pushBackCustomItem(item)
    end
end

function HBScene:showPrompt(text)
    self.m_pTextPrompt:stopAllActions()
    self.m_pTextPrompt:setString(text)
    self.m_pTextPrompt:getParent():setVisible(true)
    self.m_pTextPrompt:getParent():setOpacity(255)
    self.m_pTextPrompt:getParent():waitAndActions(3, cc.FadeOut:create(1), cc.Hide:create())
end




return HBScene

--endregion
