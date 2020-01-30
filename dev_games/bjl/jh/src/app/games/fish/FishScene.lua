local _super = require('app.games.fish.FishGameSceneBase')
local Fish2dGameScene = class("Fish2dGameScene", _super)
local GaneFrame = require('app.games.fish.fish2d.GameFrame')
local CannonLayer = require('app.games.fish.fish2d.CannonLayer')
local Cannon = require('app.games.fish.fish2d.Cannon')
local FishNode = require('app.games.fish.fish2d.FishNode')
local FishLayer = require('app.games.fish.fish2d.FishLayer')
local FishModel = require('app.games.fish.fish2d.FishModel')
local Bullet = require('app.games.fish.fish2d.Bullet')
local ActionCustom = require('app.games.fish.fish2d.ActionCustom')

local ObjectPool = require('app.games.fish.fish2d.ObjectPool')
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')
local CoTimer = require('app.games.fish.fish2d.CoTimer')


local Fish2dGameScene = class("FishScene",require("app.games.fish.FishGameSceneBase"))

-- 资源名
Fish2dGameScene.RESOURCE_FILENAME = "games/fish/Fish2dGameScene.csb"
-- 资源绑定
Fish2dGameScene.RESOURCE_BINDING = {
	--top panel
--	backBtn = {path="top_panel.back_btn",events={{event="click",method="onClickBackBtn"}}},
}

function Fish2dGameScene:ctor( core )
	Fish2dGameScene.super.ctor(self,core)
end

local function cachAnimation(info)
	local cache = cc.SpriteFrameCache:getInstance();
	local name = info.name;
	local format = info.format;
	local delay = info.delay;
	local frames = info.frames;
	local count = frames == nil and 0 or #frames;
	assert(count ~= 0);

	local animFrames = {};

	for k = 1, count do
		local sFrame = frames[k];
		local frame = -1;
        frame = tonumber(string.match(sFrame, "(%d+),"))
		local str = string.format(format, frame);
		local sptFrame = cache:getSpriteFrameByName(str);
		--CCLOG("photo name is ==%s", str);
		assert(sptFrame ~= nil, str);

		if sptFrame then
			--AnimationFrame* aniFrame = AnimationFrame::create(sptFrame, frameDelay, ValueMapNull);
            table.insert(animFrames, sptFrame)
			--aniFrame:release();
		end
	end

	local animation = cc.Animation:createWithSpriteFrames(animFrames, delay / 3 * 2);
	--bool haveReBack = animation:getRestoreOriginalFrame();
	cc.AnimationCache:getInstance():addAnimation(animation, name);
	--animation:release();
end

--加载资源
function Fish2dGameScene:loadResource()
	Fish2dGameScene.super.loadResource(self)
--	display.loadSpriteFrames(GAME_BRNN_IMAGES_RES.."brnn_cards.plist",GAME_BRNN_IMAGES_RES.."brnn_cards.png")
--	display.loadSpriteFrames(GAME_BRNN_IMAGES_RES.."jiangchi.plist",GAME_BRNN_IMAGES_RES.."jiangchi.png")
--	display.loadSpriteFrames(GAME_BRNN_IMAGES_RES.."lzt_bg.plist",GAME_BRNN_IMAGES_RES.."lzt_bg.png")
    LockMsg()
    LockMsg2()
    local res = cc.FileUtils:getInstance():getValueVectorFromFile("games/fish/config/resources.plist")
--    for i, v in ipairs(res) do
--        cc.SpriteFrameCache:getInstance():addSpriteFrames(v)
--    end
    local amt = cc.FileUtils:getInstance():getValueVectorFromFile("games/fish/config/effect.plist")
--    for i, v in ipairs(amt) do
--		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(v)
--    end

    local aa = cc.FileUtils:getInstance():getValueVectorFromFile("games/fish/config/coin_animations.plist")
    local bb = cc.FileUtils:getInstance():getValueVectorFromFile("games/fish/config/other_animations.plist")
    local cb = cc.FileUtils:getInstance():getValueVectorFromFile("games/fish/config/bird_animations.plist")
    for k, v in pairs(bb) do
        table.insert(aa, v)
    end
    for k, v in pairs(cb) do
        table.insert(aa, v)
    end

    local resIndex = 1
    local amtIndex = 1

    local bg = display.newSprite("games/fish/loading/loadingBG.png")
    bg:setPosition({x = CC_DESIGN_RESOLUTION2.width / 2, y = CC_DESIGN_RESOLUTION2.height / 2});
    local spineNode = sp.SkeletonAnimation:createWithJsonFile("games/fish/loading/skeleton.json", "games/fish/loading/skeleton.atlas");
    spineNode:setPosition(bg:getAnchorPointInPoints());
    spineNode:setAnimation(0, "animation", true);
    bg:addChild(spineNode);
    bg:setScale(1.1);
    self:addChild(bg, 99);

    local barBG = display.newSprite("update/images/progress_bg.png")
    local bar = ccui.LoadingBar:create("update/images/progress_bar.png")
    bar:setPosition(cc.p(362, 22));
    barBG:setPosition(bg:getAnchorPointInPoints());
    barBG:setPositionY(100);
    barBG:addChild(bar)
    bg:addChild(barBG);

    local totalNum = #res + #amt
    local update = function(dt)
        if resIndex <= #res then
            cc.SpriteFrameCache:getInstance():addSpriteFrames(res[resIndex])
            resIndex = resIndex + 1
            bar:setPercent(math.floor(100 * resIndex / totalNum))
            return
        end
        if amtIndex <= #amt then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(amt[amtIndex])
            amtIndex = amtIndex + 1
            bar:setPercent(math.floor(100 * (resIndex + amtIndex) / totalNum))
            return
        end
        for k, v in pairs(aa) do
            cachAnimation(v)
        end
        UnlockMsg()
        UnlockMsg2()
        utils.scheduler:unscheduleScriptEntry(self.m_schedule)
        self:viewDidLoad()
        self.loading = true
        bg:waitAndActions(0.2, cc.CallFunc:create(function() 
            self.loading = false
        end), cc.RemoveSelf:create())
    end

    if not self.m_schedule then
        self.m_schedule = utils.scheduler:scheduleScriptFunc(update, 0, false)
    end

end

--卸载资源
function Fish2dGameScene:unloadResource()
--	display.removeSpriteFrames(GAME_BRNN_IMAGES_RES.."brnn_cards.plist",GAME_BRNN_IMAGES_RES.."brnn_cards.png")
--	display.removeSpriteFrames(GAME_BRNN_IMAGES_RES.."jiangchi.plist",GAME_BRNN_IMAGES_RES.."jiangchi.png")
--	display.removeSpriteFrames(GAME_BRNN_IMAGES_RES.."lzt_bg.plist",GAME_BRNN_IMAGES_RES.."lzt_bg.png")
    cc.AnimationCache:destroyInstance()
    display.removeUnusedSpriteFrames()
	Fish2dGameScene.super.unloadResource(self)
end

function Fish2dGameScene:initialize()
	Fish2dGameScene.super.initialize(self)
end

--进入场景
function Fish2dGameScene:onEnter()
	Fish2dGameScene.super.onEnter(self)
	PLAY_MUSIC(GAME_FISH_SOUND_RES..string.format("bgm%d.mp3", math.random(1, 4)))
end

--退出场景
function Fish2dGameScene:onExit()
	STOP_MUSIC()
    self:finalize()
	Fish2dGameScene.super.onExit(self)
end


--更新玩家金币
function Fish2dGameScene:updatePlayerMoney( playerId, coin )
end



-- 通知我的炮台开启狂暴加速模式
function Fish2dGameScene:OpenCannonKuangbao(open)
    self.gfishData.openAddSpeed = open
end
-- 通知我的炮台开启双倍模式
function Fish2dGameScene:OpenCannonDouble(open)
    self.gfishData.openDouble = open
end

function Fish2dGameScene:reqExitGame(isAlert)
    -- 退出游戏，返回到大厅
    self.gfishData = {}
    if isAlert then
        self:UIExitPanel()
    else
        self.core:quitGame()
    end
end

function Fish2dGameScene:finalize()
    -- luacheck: ignore self
    _super.finalize(self)
end

function Fish2dGameScene:clearData()
    _super.clearData(self)
end


function Fish2dGameScene:viewDidLoad()
    print("重入viewDidLoad")

    Fish2dTools.MAX_BIRD_TYPE = 30
    Fish2dTools.mGameResPre = Fish2dTools.mGameResPre_C2d
    Fish2dTools.mGame_Type = Fish2dTools.GAME_TYPE_FISH2D
    Fish2dTools.mWorldScaleRate = 1
    Fish2dTools.BULLETCOUNT_MAX = 40

    _super.viewDidLoad(self)

    self:UIToolBar()

    self:init_scene()

end

-- 初始化UI、处理UI 按钮操作
function Fish2dGameScene:UIToolBar() 
    print("---Fish2dGameScene:UIToolBar---")
    local Panel_SetLockFish = self:seekChild("Panel_SetLockFish")
    local Image_ExitTip = self:seekChild("Image_ExitTip")
    local Panel_Help = self:seekChild("Panel_Help")
    local Panel_ToolBar = self:seekChild("Panel_ToolBar")
    local Node_Contain = self:seekChild("Node_Contain")
    local Image_LockTip = self:seekChild("Image_LockTip")

    Panel_SetLockFish:setVisible(false)
    Image_ExitTip:setVisible(false)
    Panel_Help:setVisible(false)
    Panel_ToolBar:setVisible(true)
    Node_Contain:setVisible(false)
    Image_LockTip:setVisible(false)

    self.m_Var.m_Image_ExitTip = Image_ExitTip
    self.m_Var.m_Text_ExitTipCountdown = Image_ExitTip:getChildByName("AtlasLabel_Time")

    -- 自动锁定按钮
    self.plockButton = Panel_ToolBar:getChildByName("Button_suo")
    self.plockButton:setVisible(true)
    self.plockButton:addClickEventListener( function()
        local isOpen = self._dataModel.m_autoLock
        self:lockAutoCallback(1, isOpen)
    end )
    -- 自动射击按钮
    self.autoFireButton = Panel_ToolBar:getChildByName("Button_Auto")
    self.autoFireButton:setVisible(true)
    self.autoFireButton:addClickEventListener( function()
        local isOpen = self._dataModel.m_autoShoot
        self:lockAutoCallback(2, isOpen)
    end )

    -- 左侧操作按钮
    local buttonParent = Panel_ToolBar:getChildByName("ButtonLayer")
    
     -- IphoneX 刘海屏特殊处理
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        local director = cc.Director:getInstance()
        local glview = director:getOpenGLView()
        local frameSize = glview:getFrameSize()
        if frameSize.width == 2436 and frameSize.height == 1125 then
            buttonParent:setPositionX(buttonParent:getPositionX() + 40)
        end
    end

    local m_buttonOpen = buttonParent:getChildByName("Button_Open")
    m_buttonOpen:setBright(true)
    local m_nodeContain = buttonParent:getChildByName("Node_Contain")
    m_nodeContain:setVisible(false)
    local showOperationCallBack = function()
        local animationTime = 0.2;
        if m_buttonOpen:isBright() then
            m_buttonOpen:setBright(false)
            m_nodeContain:setVisible(true)
            m_nodeContain:setScale(0.01)
            m_nodeContain:runAction(cc.Sequence:create(cc.ScaleTo:create(animationTime, 1.0), nil))
        else
            m_buttonOpen:setBright(true)
            m_nodeContain:setVisible(true)
            m_nodeContain:runAction(cc.Sequence:create(cc.ScaleTo:create(animationTime, 0.01), cc.Hide:create(), nil))
        end
    end
    m_buttonOpen:addClickEventListener(showOperationCallBack)

    -- 退出按钮，显示结算界面
    local pCloseItem = m_nodeContain:getChildByName("Button_Exit")
    pCloseItem:setPressedActionEnabled(true)
    pCloseItem:addClickEventListener( function()
        self:UIExitPanel()
    end )
    -- 音乐开关
    local voiceItem = m_nodeContain:getChildByName("Button_Music")
    voiceItem:setPressedActionEnabled(true)
    voiceItem:setBright(GET_MUSIC_VOLUME() > 0)
    voiceItem:addClickEventListener( function()
        local isOpen = voiceItem:isBright()
        if isOpen then
            voiceItem:setBright(false)
--            SoundMng:setMusicEnabled(false, nil)
--            SoundMng:setEffectEnabled(false)
            self.musicV = GET_MUSIC_VOLUME()
            self.soundV = GET_SOUND_VOLUME()
            SET_MUSIC_VOLUME(0)
            SET_SOUND_VOLUME(0)
        else
            voiceItem:setBright(true)
--            SoundMng:setMusicEnabled(true, nil)
--            SoundMng:setEffectEnabled(true)
            SET_MUSIC_VOLUME(self.musicV)
            SET_SOUND_VOLUME(self.soundV)
        end
    end )
    -- 特效开关
    local effectItem = m_nodeContain:getChildByName("Button_Tiexiao")
    effectItem:setPressedActionEnabled(true)
    effectItem:addClickEventListener( function()
        effectItem:setBright(not effectItem:isBright())
    end )

    -- 设置锁鱼开关
    if self.gfishData ~= nil then
        if self.gfishData.canAutoLockFishType ~= nil then
            self.m_Var.m_canAutoLockFishType = self.gfishData.canAutoLockFishType
        end
    end
    self:UIInitSetLockFish()
    local setItem = m_nodeContain:getChildByName("Button_set")
    setItem:setPressedActionEnabled(true)
    setItem:addClickEventListener( function()
        local Panel_SetLockFish = self:seekChild("Panel_SetLockFish")
        if Panel_SetLockFish then
            Panel_SetLockFish:setVisible(true)
        end
    end )

    -- 帮助界面
    local helpItem = m_nodeContain:getChildByName("Button_help")
    helpItem:setPressedActionEnabled(true)
    helpItem:addClickEventListener( function()
        Panel_Help:setVisible(true)
    end )
    local helpClose = Panel_Help:getChildByName("Button_Close")
    helpClose:setPressedActionEnabled(true)
    helpClose:addClickEventListener( function()
        Panel_Help:setVisible(false)
    end )

end


function Fish2dGameScene:UIExitPanel()
    if self.m_Var.mBalancePanel == nil then
        local mBalancePanel = cc.CSLoader:createNode("games/fish/SettlementUi.csb")
        self.m_Var.mBalancePanel = mBalancePanel

        mBalancePanel:setAnchorPoint(cc.p(0.5, 0.5))
        mBalancePanel:setPosition(Fish2dTools.kRevolutionWidth / 2, Fish2dTools.kRevolutionHeight / 2)
        self:addChild(mBalancePanel, self.zIndex.zIndex_uiExitPanel)

        local Image_SettlementBG = SEEK_CHILD(mBalancePanel, "Image_SettlementBG")

        local Button_Close = SEEK_CHILD(Image_SettlementBG, "Button_Close")
        local Button_Cancle = SEEK_CHILD(Image_SettlementBG, "Button_Cancle")
        local Button_True = SEEK_CHILD(Image_SettlementBG, "Button_True")
        Button_Close:setPressedActionEnabled(true)
        Button_Cancle:setPressedActionEnabled(true)
        Button_True:setPressedActionEnabled(true)
        Button_Close:addClickEventListener( function()
            self.m_Var.mBalancePanel:setVisible(false)
        end )
        Button_Cancle:addClickEventListener( function()
            self.m_Var.mBalancePanel:setVisible(false)
        end )
        Button_True:addClickEventListener( function()
            -- 退出游戏，返回到大厅
            self:reqExitGame(false)
        end )

        mBalancePanel:setVisible(false);
    end

    local mBalancePanel = self.m_Var.mBalancePanel
    local Image_SettlementBG = SEEK_CHILD(mBalancePanel, "Image_SettlementBG")

    local lab_timeout = SEEK_CHILD(Image_SettlementBG, "AtlasLabel_Time")
    local lab_bird_add_Money = SEEK_CHILD(Image_SettlementBG, "AtlasLabel_FishMoney")
    local lab_total_money = SEEK_CHILD(Image_SettlementBG, "AtlasLabel_UserMoney")

    lab_bird_add_Money:setString(utils:moneyString(self._dataModel.m_SingleGameTotalGold, 2))
    lab_total_money:setString(utils:moneyString(self.m_cannonLayer:getMyCannon():getGold(), 2))
    lab_timeout:setString("20")
    -- 20秒后自动关闭？
    lab_timeout:setVisible(false)

    -- 显示详情捕鱼条数
    -- dump(self._dataModel.m_FishDealCountManager)
    for fishtype = 0, Fish2dTools.MAX_BIRD_TYPE - 1 do
        local name = string.format("AtlasLabel_Fish%d", fishtype)
        local text = Image_SettlementBG:getChildByName(name)
        if text then
            local num = self._dataModel.m_FishDealCountManager[fishtype]
            if num then
                text:setString(string.format("%d", num))
            else
                text:setString("0")
            end
        end
    end

    mBalancePanel:setVisible(true)
end

-- 设置锁鱼界面
function Fish2dGameScene:UIInitSetLockFish()
    local Panel_SetLockFish = self:seekChild("Panel_SetLockFish")
    local closeBtn = Panel_SetLockFish:getChildByName("setclose")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:addClickEventListener( function()
        Panel_SetLockFish:setVisible(false)
    end )

    self.set_use_all = Panel_SetLockFish:getChildByName("set_use_all")
    self.set_use_all:setEnabled(false)
    self.set_use_all:addClickEventListener( function()
        self:setLockPanelAllFish(true)
        self.set_use_select:setEnabled(true)
        self.set_use_all:setEnabled(false)
    end )

    self.set_use_select = Panel_SetLockFish:getChildByName("set_use_select")
    self.set_use_select:addClickEventListener( function()
        self:setLockPanelAllFish(false)
        self.set_use_select:setEnabled(false)
        self.set_use_all:setEnabled(true)
        -- 选择指定的鱼
        local fishItemNode = Panel_SetLockFish:getChildByName("fishItemNode")
        for i = 14, 18 do
            local itemname = string.format("fishitem%d", i)
            local fishItem = fishItemNode:getChildByName(itemname)
            fishItem:setTag(i)
            if fishItem then
                fishItem:getChildren()[1]:setVisible(true)

                local fishType = fishItem:getTag() + 12 - 1
                self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 1)
            end
        end

    end )

    local fishItemNode = Panel_SetLockFish:getChildByName("fishItemNode")
    local fishItemAllChildNode = fishItemNode:getChildren()
    for i = 1, fishItemNode:getChildrenCount() do
        local fishItem = fishItemAllChildNode[i]
        if fishItem then
            fishItem:setTag(i)
            fishItem:addClickEventListener( function()
                local fishType = fishItem:getTag() + 12 - 1

                local selectNode = fishItem:getChildren()[1]
                selectNode:setVisible(not selectNode:isVisible())
                if selectNode:isVisible() then
                    self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 1);
                else
                    self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 2);
                end
            end )
            local fishType = fishItem:getTag() + 12 - 1
            local isHave = self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 3)
            fishItem:getChildren()[1]:setVisible(isHave)
        end
    end
    
    -- 初始化为全选
    if self.gfishData.canAutoLockFishType == nil then
        self:setLockPanelAllFish(true)
    end

end

function Fish2dGameScene:setLockPanelAllFish(isLock)
    local Panel_SetLockFish = self:seekChild("Panel_SetLockFish")
    local fishItemNode = Panel_SetLockFish:getChildByName("fishItemNode")
    if fishItemNode == nil then
        return
    end

    local fishItemAllChild = fishItemNode:getChildren()
    for i = 1, fishItemNode:getChildrenCount() do
        local item = fishItemAllChild[i]
        if item then
            item:setTag(i)
            item:getChildren()[1]:setVisible(isLock)

            local fishType = item:getTag() + 12 - 1
            if isLock then
                self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 1)
            else
                self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 2)
            end
        end
    end
end

function Fish2dGameScene:ChangeCannonLevel(level)
    _super.ChangeCannonLevel(self, level)
end
---------------------------自动、锁定相关  begin-------------------------

local m_lastSelectTime_Lock = 0
local m_lastSelectTime_Fire = 0

-- 自动锁定和子弹发炮的按钮处理 btnType:1自动锁定 2自动射击
function Fish2dGameScene:lockAutoCallback(btnType, isOpen)
    local Panel_ToolBar = self:seekChild("Panel_ToolBar")
    local plockButton = Panel_ToolBar:getChildByName("Button_suo")
    function setLockBigEffect(isOpen)
        if not plockButton or not plockButton:isVisible() then
            return
        end

        self.autoLockArma = plockButton:getChildByName("autoLockArma")
        if not isOpen then
            if self.autoLockArma then
                -- autoLockArma:getAnimation():pause()
                self.autoLockArma:setVisible(false)
            end
        else
            if self.autoLockArma then
                self.autoLockArma:setVisible(true)
                self.autoLockArma:getAnimation():play("Animation1", -1, 1)
            else
                self.autoLockArma = ccs.Armature:create("jsby_suodingzhong_00")
                self.autoLockArma:setName("autoLockArma")
                self.autoLockArma:setPosition(cc.p(-11, -11))
                self.autoLockArma:setVisible(true)
                self.autoLockArma:setAnchorPoint(cc.p(0, 0))
                plockButton:addChild(self.autoLockArma, 1)
                self.autoLockArma:getAnimation():play("Animation1", -1, 1)
            end
        end
    end

    local autoFireButton = Panel_ToolBar:getChildByName("Button_Auto")
    function setAutoFireEffect(isOpen)

        if not autoFireButton or not autoFireButton:isVisible() then
            return
        end
        self.autoArma = autoFireButton:getChildByName("autoArma")

        if not isOpen then
            if self.autoArma then
                -- autoArma:getAnimation():pause()
                self.autoArma:setVisible(false)
            end
        else
            if self.autoArma then
                self.autoArma:setVisible(true)
                self.autoArma:getAnimation():play("Animation1", -1, 1)
            else
                self.autoArma = ccs.Armature:create("jsby_zidongzhong_00")
                self.autoArma:setName("autoArma")
                self.autoArma:setPosition(cc.p(-11, -11))
                self.autoArma:setVisible(true)
                self.autoArma:setAnchorPoint(cc.p(0, 0))
                autoFireButton:addChild(self.autoArma, 1)
                self.autoArma:getAnimation():play("Animation1", -1, 1)
            end
        end
    end

    if btnType == 1 then
        -- 自动锁定按钮
        if isOpen then
            self:toSetAutoLock(false)
            setLockBigEffect(false)
            if m_lastSelectTime_Lock > m_lastSelectTime_Fire then
                setAutoFireEffect(false)
                self:toSetAutoShoot(false)
                m_lastSelectTime_Fire = 0
            end
            m_lastSelectTime_Lock = 0
        else
            setAutoFireEffect(true)
            setLockBigEffect(true)
            self:toSetAutoLock(true)
            self:toSetAutoShoot(true)
            local tv_usec = self.m_Var.fireTimer:getCurrentTime()
            m_lastSelectTime_Lock = tv_usec
            if m_lastSelectTime_Fire <= 10 then
                m_lastSelectTime_Fire = tv_usec - 30
            end
        end
    else
        -- 自动射击按钮
        if isOpen then
            self:toSetAutoShoot(false)
            setAutoFireEffect(false)
            m_lastSelectTime_Fire = 0
            self:toSetAutoLock(false)
            setLockBigEffect(false)
            m_lastSelectTime_Lock = 0
        else
            self:toSetAutoShoot(true)
            setAutoFireEffect(true)
            local tv_usec = self.m_Var.fireTimer:getCurrentTime()
            m_lastSelectTime_Fire = tv_usec
        end
    end

end


function Fish2dGameScene:Update(deltaT)
    _super.Update(self, deltaT)

    -- 自动射击或一直按下屏幕
    if self._dataModel.m_autoShoot or self._dataModel.m_isFingerPressed then
        self:toFire()
    end

    -- 锁定搜索
    if self._dataModel.m_autoLock then
        local cannon = self.m_cannonLayer:getMyCannon()
        if not cannon:isLockFish() then
            -- 自动去寻找鱼锁定
            if self.m_Var.m_isFirstToLockBoss then
                -- 锁定BOSS
                self:toLockBigFish(Fish2dTools.BOSS_FISH)
                if cannon:isLockFish() then
                    self.m_Var.m_isFirstToLockBoss = false
                end
            else
                -- 锁定鱼
                self:toLockBigFish(-1)
            end
        end
    end
end

function Fish2dGameScene:timeOut()
    self:reqExitGame(false)
end

---------------------------自动、锁定相关  end-------------------------

---------------------------框架网络消息-------------------------

function Fish2dGameScene:UserScoreChanged(score)
    -- 刷新玩家分数

end

function Fish2dGameScene:SomeOneSitDown(user, chair)
    -- 某人进入牌桌坐下
    -- if self:UserInfo(chair) and self:UserInfo(chair).dwUserID == user then
    -- return
    -- end
    _super.SomeOneSitDown(self, user, chair)
end

function Fish2dGameScene:ISitDown(user, chair)
    -- 我坐下并举手
    _super.ISitDown(self, user, chair)
end


function Fish2dGameScene:SomebodyLeave(user, chair)
    -- 某人离开牌桌
    _super.SomebodyLeave(self, user, chair)
end


function Fish2dGameScene:ILeave(user, chair)
    -- 我离开牌桌（未收到此消息）
    -- print(debug.traceback("我站起来: ", user, chair))
    _super.ILeave(self, user, chair)

end

function Fish2dGameScene:userEnter(chairId)
    _super.userEnter(self, chairId)

    local cannon = self.m_cannonLayer:getCannon(chairId)
    local tUesr = self.model:getPlayer(chairId)
    if cannon and tUesr then
        cannon:setGold(tUesr.money)
        cannon:setCannonLevel(tUesr.level)
    end

end

function Fish2dGameScene:userLeave(chairId, isSetNil)
    _super.userLeave(self, chairId, isSetNil)
end

-------------------------场景消息---------------------------------

function Fish2dGameScene:S_StatusFree(data)
    print("---Fish2dGameScene:S_StatusFree---")
    --    struct CMD_S_StatusFree
    -- {
    -- 	uint8 scene_;										//场景
    -- 	uint32 cannon_mulriple_[MAX_CANNON_TYPE];			//大炮倍数
    -- 	uint32 mulriple_count_;								//倍数
    -- 	uint16 scene_special_time_;							//特殊鱼阵时间（未使用 禁止开炮）
    -- 	Role_Net_Object role_objects_[GAME_PLAYER];			//玩家信息
    -- 	Bullet_Config bullet_config_[BULLET_KIND_COUNT];	//子弹配置
    -- };
    _super.S_StatusFree(self, data)

    Fish2dTools.mWorldScaleRate = 1
    self.m_fishLayer:setWorldScaleRate(1)
    self.m_fishLayer:setWorldOriginPos(self._dataModel.m_myChairId)

    local myCannon = self.m_cannonLayer:getMyCannon()
    -- 读取断线重连的数据
    local isSetMeCannonLevel = false
    local isSetOpenKuangbao = false
    local isSetOpenDoubleCannon = false
    if self.gfishData ~= nil then
        if self.gfishData.cannonLevel ~= nil then
            myCannon:setCannonLevel(self.gfishData.cannonLevel, true)
            isSetMeCannonLevel = true
        else
            myCannon:setCannonLevel(1)
        end
        if self.gfishData.openAddSpeed ~= nil then
            myCannon:openKuangbao(self.gfishData.openAddSpeed)
            isSetOpenKuangbao = true
        end
        if self.gfishData.openDouble ~= nil then
            myCannon:openDoubleCannon(self.gfishData.openDouble)
            isSetOpenDoubleCannon = true
        end

        if self.gfishData.autoLock == true then
            self:lockAutoCallback(1, false)
        end
        if self.gfishData.autoShoot == true then
            self:lockAutoCallback(2, false)
        end
        if self.gfishData.canAutoLockFishType ~= nil then
            self.m_Var.m_canAutoLockFishType = self.gfishData.canAutoLockFishType
        end
    end

    for i = 1, self._dataModel.GAME_PLAYER do
        -- 这里数组从1开始
        local roleobj = self._dataModel.s_gameConfig.role_objects_[i]
        local chairId = roleobj.chair_id_
        if chairId ~= self._dataModel.INVALID_CHAIR then
            if chairId ~= self._dataModel.m_myChairId then
                self:userEnter(chairId)
            end
            local cannon = self.m_cannonLayer:getCannon(chairId)
            cannon:setGold(roleobj.catch_gold_)
            if not (cannon:isMe() and isSetMeCannonLevel) then
                if roleobj.cannon_mulriple_ <= 0 then
                    roleobj.cannon_type_ = 1
                else
                    roleobj.cannon_type_ = self._dataModel:getCannonLevelByMriple(roleobj.cannon_mulriple_)
                end
                cannon:setCannonLevel(roleobj.cannon_type_, true)
            end
            
        end
    end

    
    if myCannon then
        if not isSetOpenKuangbao then
            myCannon:openKuangbao(myCannon._isOpenKuangbao)
        end
        if not isSetOpenDoubleCannon then
            myCannon:openDoubleCannon(myCannon._isOpenDouble)
        end
    end

end


-------------------------游戏消息---------------------------------

function Fish2dGameScene:S_Change_Scene(data)
    --  struct CMD_S_Change_Scene
    -- {
    -- 	uint8 scene_;	///< 场景
    -- 	uint16 special_time;   //特殊鱼阵时间
    -- }
    self:chang_scene(data.scene_)

end

function Fish2dGameScene:S_Fire_Failed(data)
    --  struct CMD_S_Fire_Failed
    -- {
    -- 	uint16 chair_id_;
    -- 	int64  nowGlod_;
    -- }
    print("-------Fish2dGameScene:S_Fire_Failed: ", data.chair_id_, data.nowGlod_)
    _super.S_Fire_Failed(self, data)
end

function Fish2dGameScene:S_Catch_Bird(data)
    -- struct Catch_Bird
    -- {
    -- 	uint16  chair_id_;
    -- 	uint32	catch_gold_;	///< 抓住金币
    -- 	uint32	bird_id_;		///< 抓住鱼id
    -- 	uint64	now_money;;		//当前金币数
    -- 	bool	isDouble;		//是否暴击
    -- 	uint8   is_die;			//是否死亡	
    -- }
    -- print("-------------------Fish2dGameScene:S_Catch_Bird: ", data.now_money, data.is_die)
    _super.S_Catch_Bird(self, data)
end

function Fish2dGameScene:playSoundCatchFish(fish_type)
    _super.playSoundCatchFish(self, fish_type)
end


----------------------------场景切换、BOSS相关处理 start---------------------------
function Fish2dGameScene:init_scene()
    local winSize = cc.size(Fish2dTools.kRevolutionWidth, Fish2dTools.kRevolutionHeight)
    local cx = winSize.width / 2
    local cy = winSize.height / 2

    local spr_background_ = cc.Sprite:createWithSpriteFrameName("bg1.jpg")
    spr_background_:setAnchorPoint(cc.p(0, 0))
    self.m_sceneLayer:addChild(spr_background_)
    self.m_Var.spr_background_ = spr_background_

    local spr_background2_ = cc.Sprite:createWithSpriteFrameName("bg1.jpg")
    spr_background2_:setAnchorPoint(cc.p(0, 0))
    spr_background2_:setVisible(false)
    self.m_sceneLayer:addChild(spr_background2_)
    self.m_Var.spr_background2_ = spr_background2_

    local spr_c_lizi_ = cc.ParticleSystemQuad:create("games/fish/flash/scene/huantu_paopao.plist")
    spr_c_lizi_:setPosition(cc.p(winSize.width, cy))
    spr_c_lizi_:setVisible(false)
    self.m_sceneLayer:addChild(spr_c_lizi_)
    self.m_Var.spr_c_lizi_ = spr_c_lizi_

    local spr_cloud_ = cc.Sprite:createWithSpriteFrameName("Cloud0.png")
    local animate = Fish2dTools.createAnimate("Cloud", 0)
    spr_cloud_:runAction(cc.RepeatForever:create(animate))
    spr_cloud_:setPosition(cc.p(winSize.width, cy))
    spr_cloud_:setVisible(false)
    self.m_sceneLayer:addChild(spr_cloud_, spr_c_lizi_:getLocalZOrder() + 1)
    local scale = 750 / spr_cloud_:getContentSize().height
    spr_cloud_:setScale(scale)
    self.m_Var.spr_cloud_ = spr_cloud_


    local opacity = 220

    local spr_water_wave_ = cc.Sprite:createWithSpriteFrameName("waterAni_0.png")
    spr_water_wave_:setPosition(cc.p(cx, cy))
    local action_1 = Fish2dTools.animationWithFrame("waterAni_", 0, 7, 0.2)
    spr_water_wave_:setAnchorPoint(cc.p(0.5, 0.5))
    spr_water_wave_:setScale(1.31, 1.46)
    spr_water_wave_:runAction(cc.RepeatForever:create(action_1))
    -- spr_water_wave_:setBlendFunc(cc.BlendFunc::ADDITIVE);
    spr_water_wave_:setOpacity(opacity)
    self.m_sceneLayer:addChild(spr_water_wave_, 100)

end

function Fish2dGameScene:set_scene(scene)
    if scene >= 3 then
        scene = 0
    end
    self.m_Var.scene_ = scene
    self._dataModel.m_curSceneId = scene
     local bgindex = scene + 1
    if bgindex < 1 or bgindex > 3 then
        bgindex = 1
    end
    local sceneback = string.format("bg%d.jpg", bgindex)
    self.m_Var.spr_background_:setSpriteFrame(sceneback)
    if self.m_Var.spr_c_lizi_ then
        self.m_Var.spr_c_lizi_:setPosition(Fish2dTools.kRevolutionWidth + 300, self.m_Var.spr_c_lizi_:getPositionY())
        self.m_Var.spr_c_lizi_:setVisible(false)
        self.m_Var.spr_c_lizi_:stopAllActions()
    end
    self.m_Var.spr_cloud_:setPosition(Fish2dTools.kRevolutionWidth + 300, self.m_Var.spr_cloud_:getPositionY())
    self.m_Var.spr_cloud_:setVisible(false)
    -- self.m_Var.spr_cloud_:pauseSchedulerAndActions()
    -- change end
    self.m_Var.spr_background2_:stopAllActions()
    self.m_Var.spr_background2_:setVisible(false)

end

-- 切换场景
function Fish2dGameScene:chang_scene(scene)
    _super.chang_scene(self,scene)

    local spr_background2_ = self.m_Var.spr_background2_
    local bgindex = scene + 1
    if bgindex < 1 or bgindex > 3 then
        bgindex = 1
    end
    local sceneback = string.format("bg%d.jpg", bgindex)
    spr_background2_:setSpriteFrame(sceneback)

    m_isFirstToLockBoss = false;

    self:runAction(cc.Sequence:create(cc.DelayTime:create(7.5),
    cc.CallFunc:create( function()
        self:clearObjPool(false)
        --
        if self.m_Var.scene_ % 2 == 0 then
            self:playBossEnterEffect()
        else
            self:playSceneBgMusic()
        end
    end
    ), nil))

end


function Fish2dGameScene:playBossEnterEffect()
    m_isFirstToLockBoss = true;

    local dibanHeight = 750
    local downFontPosY = 65
    local topFontPosY = 65
    local dibanDealyTime = 0.1
    local midDealyTime = 0.2
    local sceneSize = cc.p(Fish2dTools.kRevolutionWidth, Fish2dTools.kRevolutionHeight)

    local bossEnterDiban = self:getChildByName("bossEnterDiban")
    if bossEnterDiban == nil then
        bossEnterDiban = ccs.Armature:create("boos_laixi_01")
        bossEnterDiban:setName("bossEnterDiban");
        bossEnterDiban:setPosition(sceneSize.x / 2, - dibanHeight / 2)
        self:addChild(bossEnterDiban, self.zIndex.zIndex_effect)
    end
    local bossEnterDibanUp = self:getChildByName("bossEnterDibanUp")
    if bossEnterDibanUp == nil then
        bossEnterDibanUp = ccs.Armature:create("boos_laixi_01")
        bossEnterDibanUp:setName("bossEnterDibanUp")
        bossEnterDibanUp:setPosition(sceneSize.x / 2, sceneSize.y + dibanHeight / 2)
        bossEnterDibanUp:setScale(-1)
        self:addChild(bossEnterDibanUp, self.zIndex.zIndex_effect)
    end
    if bossEnterDiban then
        bossEnterDiban:stopAllActions()
        bossEnterDiban:setVisible(true)
        -- bossEnterDiban:getAnimation():stop()
        bossEnterDiban:getAnimation():play("Animation1", -1, 1)
    end
    if bossEnterDibanUp then
        bossEnterDibanUp:stopAllActions()
        bossEnterDibanUp:setVisible(true)
        -- bossEnterDibanUp:getAnimation():stop()
        bossEnterDibanUp:getAnimation():play("Animation1", -1, 1)
    end

    local bossEnterMidFont = self:getChildByName("bossEnterMidFont")
    if bossEnterMidFont == nil then
        bossEnterMidFont = ccs.Armature:create("boos_laixi_00")
        bossEnterMidFont:setName("bossEnterMidFont")
        bossEnterMidFont:setPosition(sceneSize.x + 500, sceneSize.y / 2 - 15)
        self:addChild(bossEnterMidFont, self.zIndex.zIndex_effect)
    end
    if bossEnterMidFont then
        bossEnterMidFont:stopAllActions()
        bossEnterMidFont:setVisible(true)
        -- bossEnterMidFont:getAnimation():stop()
        bossEnterMidFont:getAnimation():play("Animation1", -1, 1)

        local inAction = cc.EaseSineIn:create(cc.MoveTo:create(0.3, cc.p(sceneSize.x / 2 + 100, sceneSize.y / 2)))
        local delayAction = cc.MoveTo:create(1.9, cc.p(sceneSize.x / 2 - 100, sceneSize.y / 2))
        local outAction = cc.EaseSineOut:create(cc.MoveTo:create(0.3, cc.p(-500, sceneSize.y / 2)))

        bossEnterMidFont:runAction(cc.Sequence:create(inAction, delayAction, outAction, cc.RemoveSelf:create(), nil))
    end

    if bossEnterDiban then
        bossEnterDiban:runAction(cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.1), cc.Show:create(),
        cc.MoveTo:create(0.2, cc.p(sceneSize.x / 2, dibanHeight / 2)), cc.DelayTime:create(2.0),
        cc.MoveTo:create(0.2, cc.p(sceneSize.x / 2, - dibanHeight / 2)), cc.RemoveSelf:create(), nil))
    end
    if bossEnterDibanUp then
        bossEnterDibanUp:runAction(cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.1), cc.Show:create(),
        cc.MoveTo:create(0.2, cc.p(sceneSize.x / 2, sceneSize.y - dibanHeight / 2)), cc.DelayTime:create(2.0),
        cc.MoveTo:create(0.2, cc.p(sceneSize.x / 2, sceneSize.y + dibanHeight / 2)), cc.RemoveSelf:create(), nil))
    end

    self:runAction(cc.Sequence:create(
    cc.DelayTime:create(0.1),
    cc.CallFunc:create( function()
--        SoundMng:stopAllSounds()
        PLAY_SOUND(GAME_FISH_SOUND_RES.."boss_enter.wav", false)
    end ),
    cc.DelayTime:create(1.5),
    cc.CallFunc:create( function()
--        SoundMng:setMusicVolume(50);
        PLAY_MUSIC(GAME_FISH_SOUND_RES.."c2d_boss_bg.mp3", true);
    end ),
    cc.DelayTime:create(36),
    cc.CallFunc:create( function()
        m_isFirstToLockBoss = false;
        self:playSceneBgMusic()
    end ),
    nil))

end






return Fish2dGameScene