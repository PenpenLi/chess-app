-- region FishGameSceneBase.lua
-- Date 2018-03-28
-- 此文件由[BabeLua]插件自动生成

local FishGameSceneBase = class("FishGameSceneBase", GameSceneBase)

local GaneFrame = require('app.games.fish.fish2d.GameFrame')
local CannonLayer = require('app.games.fish.fish2d.CannonLayer')
local FishNode = require('app.games.fish.fish2d.FishNode')
local FishLayer = require('app.games.fish.fish2d.FishLayer')
local FishModel = require('app.games.fish.fish2d.FishModel')
local Bullet = require('app.games.fish.fish2d.Bullet')
local ActionCustom = require('app.games.fish.fish2d.ActionCustom')

local ObjectPool = require('app.games.fish.fish2d.ObjectPool')
local Fish2dTools = require('app.games.fish.fish2d.Fish2dTools')
local CoTimer = require('app.games.fish.fish2d.CoTimer')
local scheduler = cc.Director:getInstance():getScheduler()

FishGameSceneBase.zIndex = {
    zIndex_sceneLayer = - 2,
    zIndex_fishLayer = - 1,
    zIndex_cannonLayer = 10,
    zIndex_bullet = 11,
    zIndex_net = 12,
    zIndex_gole = 13,
    zIndex_effect = 14,
    zIndex_ui = 15,
    zIndex_uiExitPanel = 16,
    zIndex_uiHelpPanel = 17
}

local WARNING_SHOW = 60000  -- 超时退出倒计时
local WARNING_EXIT = 30000  -- 超时提示倒计时

function FishGameSceneBase:initialize()
	FishGameSceneBase.super.initialize(self)
    self.gfishData = { cannonLevel = nil, autoLock = nil, autoShoot = nil, openAddSpeed = nil, openDouble = nil, canAutoLockFishType = nil }

    self.m_BulletCount = 0
    self.mCurrentMySendBulletCount = 0

    self._dataModel = GaneFrame:create()
    self._dataModel.m_isFingerPressed = false

    self.m_cannonLayer = nil
    self.m_netLayer = nil
    self.m_fishLayer = nil
    self.m_coinLayer = nil
    self.m_bulletLayer = nil

    self.GAME_PLAYER = self._dataModel.GAME_PLAYER

    -- 定义本文件一些常用的控制变量
    self.m_Var = {
        m_isAlertGoldLose = false,
        isAlertFireFailed = false,
        fireTimer = nil,
        warningTimer = nil,
        m_Image_ExitTip = nil,
        m_Text_ExitTipCountdown = nil,
        m_isFirstToLockBoss = false,
        scene_ = 0
    }
    self.m_Var.m_canAutoLockFishType = { }

--    if self.gfishData.canAutoLockFishType == nil then
--        self.gfishData.canAutoLockFishType = self.m_Var.m_canAutoLockFishType
--    end

    self.m_Var.fireTimer = CoTimer:create(0)
    self.m_Var.warningTimer = CoTimer:create(0)

    self.m_WaitCreateFish = { Send_Bird = { }, Send_Bird_Linear = { }, Send_Bird_Round = { }, Send_Bird_Pause_Linear = { } }

    -- 对象池定义
    self.m_netPool = { }
    self.m_netShadowPool = { }
    self.m_bulletPool = { }
    self.m_fishPool = { }
    self.m_coinPool = nil

    -- 正在执行换位置
    self.m_changingChair = false
    display.setAutoScale(CC_DESIGN_RESOLUTION2)

--    self:AddEvents(
--    -- 框架部分的用户状态通知
--    App.conn:on('SomeOneSitDown', function(...)
--        self:SomeOneSitDown(...)
--    end ),
--    App.conn:on('ISitDown', function(...)
--        self:ISitDown(...)
--    end ),
--    App.conn:on('SomebodyLeave', function(...)
--        self:SomebodyLeave(...)
--    end ),
--    App.conn:on('SomebodyOffline', function(...)
--        self:SomebodyOffline(...)
--    end ),
--    App.conn:on('UserScoreChanged', function(...)
--        self:UserScoreChanged(...)
--    end ),
--    -- 场景消息通知
--    App.conn:on('S_StatusFree', function(...)
--        self:S_StatusFree(...)
--    end ),
--    -- 游戏消息通知
--    App.conn:on('S_Change_Scene', function(...)
--        self:S_Change_Scene(...)
--    end ),
--    App.conn:on('S_Fire_Failed', function(...)
--        self:S_Fire_Failed(...)
--    end ),
--    App.conn:on('S_Catch_Bird', function(...)
--        self:S_Catch_Bird(...)
--    end ),
--    App.conn:on('S_Send_Bird', function(...)
--        self:S_Send_Bird(...)
--    end ),
--    App.conn:on('S_Send_Bird_Linear', function(...)
--        self:S_Send_Bird_Linear(...)
--    end ),
--    App.conn:on('S_Send_Bird_Round', function(...)
--        self:S_Send_Bird_Round(...)
--    end ),
--    App.conn:on('S_Send_Bird_Pause_Linear', function(...)
--        self:S_Send_Bird_Pause_Linear(...)
--    end ),
--    App.conn:on('S_Send_Bullet', function(...)
--        self:S_Send_Bullet(...)
--    end ),
--    App.conn:on('ChangeCannonLevel', function(...)
--        self:ChangeCannonLevel(...)
--    end ),
--    App.conn:on('ExitGame', function(card)
--        -- MsgCenter:LeaveSeat()
--        MsgCenter:CloseSocketG()
--        SoundMng:stopMusic()
--        -- SoundMng:stopVoice()
--        SoundMng:stopAllEffects()
--        App.switchNoAmt("HallController", "HallViews")
--    end ),

--    -- 按下了返回键
--    App.conn:on("key_back_released", function()
--        self:reqExitGame(true)
--    end )
--    )
--    App.HandleAppSwitchEvent(self)
end

function FishGameSceneBase:reqExitGame(isAlert)
    -- 子类实现
end

function FishGameSceneBase:finalize()
    -- luacheck: ignore self
    self:clearData()
--    SoundMng:stopAllSounds()
end

function FishGameSceneBase:clearData()
    self.m_BulletCount = 0

    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
    end

    for i = 0, self.GAME_PLAYER - 1 do
        local cannon = self.m_cannonLayer:getCannon(i)
        if cannon then
            cannon:cancelLockFish()
            cannon:unscheduleLock()
        end
    end

    -- 清理子弹
    if self.m_bulletLayer then
        local allBullet = self.m_bulletLayer:getChildren()
        for i, v in pairs(allBullet) do
            if allBullet[i] then
                allBullet[i]:onExit()
            end
        end
        self.m_bulletLayer:removeAllChildren(true)
    end
    -- 清理鱼
    for fishkey, v in pairs(self._dataModel.m_InViewFishs) do
        thefishModel = self._dataModel.m_InViewFishs[fishkey]
        if thefishModel and thefishModel.node_ then
            thefishModel.node_:unScheduleFish()
        end
        thefishModel = nil
    end
    self._dataModel.m_InViewFishs = { }
    self.m_fishLayer:removeAllChildren(true)

    self:clearObjPool(true)
end


function FishGameSceneBase:clearObjPool(isAllClear)
    local fishnum = isAllClear and 0 or 4
    local coinnum = isAllClear and 0 or 10

    -- 清理鱼的对象池
    if self.m_fishPool.fish ~= nil then
        for i = 0, 29 do
            if self.m_fishPool.fish[i] ~= nil then
                self.m_fishPool.fish[i]:clearObject(fishnum)
            end
        end
    end
    if self.m_fishPool.specialfish ~= nil then
        for i = 0, 29 do
            if self.m_fishPool.specialfish[i] ~= nil then
                self.m_fishPool.specialfish[i]:clearObject(fishnum)
            end
        end
    end
    if self.m_coinPool ~= nil then
        self.m_coinPool:clearObject(coinnum)
    end

    if isAllClear then
        for i = 0, 10 do
            if self.m_netPool[i] then
                self.m_netPool[i]:clearObject(0)
            end
            if self.m_netShadowPool[i] then
                self.m_netShadowPool[i]:clearObject(0)
            end
        end

        if self.m_bulletPool[1] then
            self.m_bulletPool[1]:clearObject(0)
        end
        if self.m_bulletPool[2] then
            self.m_bulletPool[2]:clearObject(0)
        end

        ----
        self.m_netPool = { }
        self.m_netShadowPool = { }
        self.m_bulletPool = { }
        self.m_fishPool = { }
        self.m_coinPool = nil

        -- 清除鱼的缓存

    end
end

function FishGameSceneBase:viewDidLoad()
    print("重入viewDidLoad")
    self:loadRes()

    --    for i = 0, self._dataModel.GAME_PLAYER - 1 do
    --        self._dataModel.m_users[i] = { info = nil, gameData = { offline = false, playing = false } }
    --    end

    local panelTable = self:seekChild("Panel_Table")
    panelTable:setAnchorPoint(cc.p(0.5, 0.5))

    -- 背景层
    self.m_sceneLayer = cc.Layer:create()
    self:addChild(self.m_sceneLayer, self.zIndex.zIndex_sceneLayer)

    -- 鱼层
    self.m_fishLayer = FishLayer:create(self)
    self.m_fishLayer:setAnchorPoint(cc.p(0, 0))
    self.m_fishLayer:setPosition(0, 0)
    self:addChild(self.m_fishLayer, self.zIndex.zIndex_fishLayer)

    -- 炮台角色
    self.m_cannonLayer = CannonLayer:create(self)
    self:addChild(self.m_cannonLayer, self.zIndex.zIndex_cannonLayer)

    -- 子弹层
    self.m_bulletLayer = cc.Layer:create()
    self:addChild(self.m_bulletLayer, self.zIndex.zIndex_bullet)

    -- 鱼网
    self.m_netLayer = cc.Layer:create()
    self:addChild(self.m_netLayer, self.zIndex.zIndex_net)

    -- 金币、特效
    self.m_coinLayer = cc.Layer:create()
    self:addChild(self.m_coinLayer, self.zIndex.zIndex_gole)

    -- UI
    self.resourceNode:setPosition(cc.p(0, 0))
    self.resourceNode:setLocalZOrder(self.zIndex.zIndex_ui)
    self.resourceNode:setVisible(true)

    self.m_schedule = nil
    if not self.m_schedule then
        self.m_schedule = scheduler:scheduleScriptFunc( function(deltaT)
            self:Update(deltaT)
        end , 0, false)
    end
end

function FishGameSceneBase:loadRes()
    --    SpriteHelper.cacheAnimations("game/fish2d")
end


-- 初始化UI、处理UI 按钮操作
function FishGameSceneBase:UIToolBar()
    print("---FishGameSceneBase:UIToolBar---")
    -- 由子类实现
end


function FishGameSceneBase:UIExitPanel()
    -- 由子类实现
end

-- 我的炮倍改变
function FishGameSceneBase:ChangeCannonLevel(level)
    self.gfishData.cannonLevel = level

end


-- dealtype：1 add  2:remove 3:find
function FishGameSceneBase:deal2dKeyData(keyDatas, key, dealtype)
    if keyDatas == nil then
        keyDatas = {}
    end
    
    if dealtype == 1 then
        keyDatas[key] = key
        if self.gfishData.canAutoLockFishType == nil then
            self.gfishData.canAutoLockFishType = {}
        end
        self.gfishData.canAutoLockFishType[key] = key
        return true
    end

    if dealtype == 2 then
        if keyDatas[key] ~= nil then
            keyDatas[key] = nil
            if self.gfishData.canAutoLockFishType ~= nil then
                self.gfishData.canAutoLockFishType[key] = nil
            end
            return true
        end
        return false
    end

    if dealtype == 3 then
        if keyDatas[key] ~= nil then
            return true
        end
        return false
    end

    return true
end

---------------------------自动、锁定相关  begin-------------------------

-- 自动锁定和子弹发炮的按钮处理 btnType:1自动锁定 2自动射击
function FishGameSceneBase:lockAutoCallback(btnType, isOpen)
    -- 由子类实现
end

function FishGameSceneBase:toSetAutoShoot(isShoot)
    self._dataModel.m_autoShoot = isShoot
    self.gfishData.autoShoot = isShoot
end

function FishGameSceneBase:toSetAutoLock(isLock)
    self._dataModel.m_autoLock = isLock
    self.gfishData.autoLock = isLock
    --
    local cannon = self.m_cannonLayer:getMyCannon()
    if not isLock then
        -- 清理我的锁鱼状态
        if cannon:isLockFish() then
            cannon:getLockFish():setLock(false, self._dataModel.m_myChairId)
            cannon:cancelLockFish()
        else
            cannon:clearLockEffect()
        end
    else
        -- 锁定开启后，在Update自动搜索
    end
end

-- 去寻找鱼并锁定
function FishGameSceneBase:toLockBigFish(theType)
    -- print("---FishGameSceneBase:toLockBigFish---theType: ",theType)
    local fishModel = nil
    local fishNode = nil
    -- 最大类型的鱼Model
    local maxTypeFish = nil

    if not self.m_cannonLayer then
        return
    end

    -- 遍历所有鱼	
    for i, v in pairs(self._dataModel.m_InViewFishs) do
        fishModel = self._dataModel.m_InViewFishs[i]
        if fishModel and fishModel.live_ > 0 then
            if (theType <= 0 and self:isAuotLockFish(fishModel.type_)) or(theType == fishModel.type_) then
                fishNode = fishModel.node_
                if fishNode and not fishNode:isOutWindow() and(not fishNode:isUnActive()) then
                    if maxTypeFish == nil then
                        maxTypeFish = fishModel
                    elseif fishModel.type_ > maxTypeFish.type_ then
                        maxTypeFish = fishModel
                    end
                end
            end
        end
    end
    -- print("maxTypeFish:",maxTypeFish)
    if maxTypeFish then
        maxTypeFish.node_:setLock(true, self._dataModel.m_myChairId)
        local cannon = self.m_cannonLayer:getMyCannon()
        if cannon:isLockFish() then
            -- 取消原锁定
            cannon:getLockFish():setLock(false, self._dataModel.m_myChairId)
        end
        -- 设置新的锁定
        cannon:setLockFish(maxTypeFish.node_)
    end

end

function FishGameSceneBase:isAuotLockFish(fishType)
    if fishType == Fish2dTools.BOSS_FISH then
        return true
    end

    local isHave = self:deal2dKeyData(self.m_Var.m_canAutoLockFishType, fishType, 3)

    return isHave
end


function FishGameSceneBase:Update(deltaT)
    -- 分帧生成鱼
    local fishNum = #self.m_WaitCreateFish.Send_Bird
    local fish_linearNum = #self.m_WaitCreateFish.Send_Bird_Linear
    local fish_roundNum = #self.m_WaitCreateFish.Send_Bird_Round
    local fish_pause_linearNum = #self.m_WaitCreateFish.Send_Bird_Pause_Linear

    local stepNum = 4
    local steproundNum = 10
    if fishNum > 0 then
        for i = 1, stepNum do
            if i <= fishNum then
                local data = table.remove(self.m_WaitCreateFish.Send_Bird, 1)
                self:net_send_fish(data)
            end
        end
    end
    if fish_linearNum > 0 then
        for i = 1, stepNum do
            if i <= fish_linearNum then
                local data = table.remove(self.m_WaitCreateFish.Send_Bird_Linear, 1)
                self:net_send_fish_linear(data)
            end
        end
    end
    if fish_roundNum > 0 then
        for i = 1, steproundNum do
            if i <= fish_roundNum then
                local data = table.remove(self.m_WaitCreateFish.Send_Bird_Round, 1)
                self:net_send_fish_round(data)
            end
        end
    end
    if fish_pause_linearNum > 0 then
        for i = 1, stepNum do
            if i <= fish_pause_linearNum then
                local data = table.remove(self.m_WaitCreateFish.Send_Bird_Pause_Linear, 1)
                self:net_send_fish_pause_linear(data)
            end
        end
    end

    -- 检查超时提示
    if self._dataModel.m_myChairId >= 0 then
        local warntime = self.m_Var.warningTimer:getElapsed()
        if warntime >= WARNING_SHOW then
            if self.m_Var.m_Image_ExitTip and self.m_Var.m_Image_ExitTip:isVisible() == false then
                self.m_Var.m_Image_ExitTip:setVisible(true)
            end
        end
        if warntime >= WARNING_SHOW then
            warntime =(WARNING_EXIT + WARNING_SHOW) - warntime
            warntime = warntime / 1000
            if warntime >= 0 and self.m_Var.m_Text_ExitTipCountdown then
                self.m_Var.m_Text_ExitTipCountdown:setString(string.format("%d", warntime))
            end
            if warntime < 0 then
                -- 超时了，自动退出
                if nil ~= self.m_schedule then
                    scheduler:unscheduleScriptEntry(self.m_schedule)
                    self.m_schedule = nil
                end
                self:timeOut()
            end
        end
    end
    --

end

function FishGameSceneBase:timeOut()
    -- 子类实现
--    MsgCenter:LeaveSeat(1)
    self.core:quitGame()
end

function FishGameSceneBase:getLockFishId(chairId)
    local cannon = self.m_cannonLayer:getCannon(chairId)
    if not cannon or not cannon:isLockFish() then
        return -1
    end
    local fishNode = cannon:getLockFish()
    if not fishNode.mFishModel then
        return -1
    end
    return fishNode.mFishModel.id_
end

function FishGameSceneBase:setFishLock(chairId, fishId)
    local cannon = self.m_cannonLayer:getCannon(chairId)
    if cannon == nil then
        return
    end
    if fishId == -1 then
        cannon:cancelLockFish()
        return
    end
    local fishModel = self._dataModel.m_InViewFishs[fishId]
    if not fishModel or fishModel.live_ <= 0 then
        cannon:cancelLockFish()
        return
    end

    cannon:setLockFish(fishModel.node_)
    fishModel.node_:setLock(true, chairId)
end

---------------------------自动、锁定相关  end-------------------------

---------------------------框架网络消息-------------------------

function FishGameSceneBase:UserScoreChanged(score)
    -- 刷新玩家分数



end

function FishGameSceneBase:SomeOneSitDown(user, chair)
    -- 某人进入牌桌坐下
    -- if self:UserInfo(chair) and self:UserInfo(chair).dwUserID == user then
    -- return
    -- end
    print("别人坐下:  ", user, chair)
    --    self._dataModel.m_users[chair].info = MsgCenter:GetUserInfo(user)
    --    self._dataModel.m_users[chair].gameData.offline = false

    local cannon = self.m_cannonLayer:getCannon(self._dataModel.m_myChairId)
    if cannon and cannon:isMe() then
        self:userEnter(chair)
    end
end

function FishGameSceneBase:ISitDown(user, chair)
    -- 我坐下并举手
    print("******>我坐下: ", user, chair)
    --    local userinfo = MsgCenter:GetUserInfo(user)
    --    self._dataModel.m_users[chair].info = userinfo
    --    self._dataModel.m_users[chair].gameData.offline = false
    --    dump(self._dataModel.m_users[chair].info)
    if self._dataModel.m_myChairId ~= -1 then
        self:userLeave(self._dataModel.m_myChairId)
    end
    self._dataModel.m_myChairId = chair
    self._dataModel.m_myUserId = user
    self.m_cannonLayer:setMyCharId(self._dataModel.m_myChairId)

    local panelTable = self:seekChild("Panel_Table")
    self.m_cannonLayer:loadUI(panelTable, self.model.mySeatId)
    -- self:userEnter(chair)
end

function FishGameSceneBase:switchCannonUI(firstSeatNo, secondSeatNo)
    print("-----FishGameSceneBase:switchCannonUI firstSeatNo: secondSeatNo: ", firstSeatNo, secondSeatNo)
    if firstSeatNo == secondSeatNo then
        return
    end
    local firstCannon = self.m_cannonLayer:getCannon(firstSeatNo)
    if not firstCannon then
        return
    end
    local secondCannon = self.m_cannonLayer:getCannon(secondSeatNo)
    firstCannon:switchUI(secondCannon)
end

function FishGameSceneBase:SomebodyLeave(user, chair)
    -- 某人离开牌桌
    print("有人离开: ", user, chair)
    self:userLeave(chair, true)
    if user == self.model.myPlayerId then
        self:ILeave(user, chair)
    end
end

function FishGameSceneBase:SomebodyOffline(user, chair)
    -- 某人掉线
    print("有人掉线: ", user, chair)
    -- local icon = self._dataModel.m_users[chair].ctrls.icon
    --    self._dataModel.m_users[chair].gameData.offline = true
    -- icon:getVirtualRenderer():setState(1);
end

function FishGameSceneBase:ILeave(user, chair)
    -- 我离开牌桌（未收到此消息）
    if user ~= self.model.myPlayerId then
        return
    end
    print(debug.traceback("我站起来: ", user, chair))
    self:userLeave(chair, true)
    self._dataModel.m_myChairId = -1
    self:clearData()

    local money = self.m_cannonLayer:getMyCannon():getGold()
    dataManager.userInfo.money = money
    eventManager:publish("Money",money)
end

function FishGameSceneBase:userEnter(chairId)
    local me =(self.model.mySeatId == chairId)
    if me then
        self._dataModel.m_myChairId = chairId
    end
    print("------FishGameSceneBase:userEnter chairId: isMe: ", chairId, me)
    local cannon = self.m_cannonLayer:getCannon(chairId)
    if cannon == nil then
        return
    end
    if me and cannon:isMe() then
        return
        -- 已经是我自己不需要处理
    end

    cannon:setIsMe(me)
    cannon:showCannon(true)

    if me then
        if (chairId == 0 or chairId == 1) and not self.switch then
            self.switch = true
            self:switchCannonUI(0, self.GAME_PLAYER - 1)
            self:switchCannonUI(1, self.GAME_PLAYER - 2)
        end

    else
        if self._dataModel.m_myChairId == 0 or self._dataModel.m_myChairId == 1 then
            cannon:setViewChairId(self.GAME_PLAYER - chairId - 1)
        else
            cannon:setViewChairId(chairId)
        end
    end

end

function FishGameSceneBase:userLeave(chairId, isSetNil)
    print("---FishGameSceneBase:userLeave---chairId: ", chairId)
    if isSetNil then
        --        self._dataModel.m_users[chairId].info = nil
        --        self._dataModel.m_users[chairId].gameData.playing = false
    end
--    if chairId ~= self._dataModel.m_myChairId then
--        return
--    end

    local cannon = self.m_cannonLayer:getCannon(chairId)
    if not cannon then
        return
    end

    cannon:showCannon(false)
--    cannon:setViewChairId(chairId)
    cannon:setLockFish(nil)
    cannon:setIsMe(false)
end

-------------------------场景消息---------------------------------

function FishGameSceneBase:S_StatusFree(data)
    dump(data, "---FishGameSceneBase:S_StatusFree---")
    --    struct CMD_S_StatusFree
    -- {
    -- 	uint8 scene_;										//场景
    -- 	uint32 cannon_mulriple_[MAX_CANNON_TYPE];			//大炮倍数
    -- 	uint32 mulriple_count_;								//倍数
    -- 	uint16 scene_special_time_;							//特殊鱼阵时间（未使用 禁止开炮）
    -- 	Role_Net_Object role_objects_[GAME_PLAYER];			//玩家信息
    -- 	Bullet_Config bullet_config_[BULLET_KIND_COUNT];	//子弹配置
    -- };

    self._dataModel.s_gameConfig = data

    self:set_scene(self._dataModel.s_gameConfig.scene_)

    if self._dataModel.s_gameConfig.scene_special_time_ > 5 and(not self.m_changingChair) then
        -- 提示鱼潮进行中
        self:showInFishBomlTips()
    end
    -- 还原换桌标识
    self.m_changingChair = false

    self.m_cannonLayer:setMyCharId(self._dataModel.m_myChairId)
    --  for i = 0, self._dataModel.GAME_PLAYER-1 do
    --      local cannon = self.m_cannonLayer:getCannon(i)
    --      if cannon and cannon.chair_id_ ~= cannon.view_chair_id_ then
    --          self:switchCannonUI(0, self.GAME_PLAYER-1)
    --          self:switchCannonUI(1, self.GAME_PLAYER-2)
    --          break
    --      end
    --  end

    for i = 0, self._dataModel.GAME_PLAYER - 1 do
        self:userLeave(i, false)
        -- 清理显示的座位顺序
    end

    self:userEnter(self._dataModel.m_myChairId)

    self._dataModel.m_isGamePause = false
    self.m_BulletCount = 0
    self._dataModel.mAutoSpeedMultiple = 1
    -- 播放此场景背景音效
    local sceneMusic = self._dataModel.s_gameConfig.scene_
    if sceneMusic == nil then
        sceneMusic = 0
    end
    if sceneMusic > 3 or sceneMusic < 0 then
        sceneMusic = 0
    end
    local mark = cc.Sprite:createWithSpriteFrameName("userLocation.png")
    self.m_cannonLayer:getCannon(self._dataModel.m_myChairId)._Player_Node:addChild(mark)
    mark:setPositionY(180)
    mark:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, -30)), cc.MoveBy:create(0.5, cc.p(0, 30))), 4), cc.RemoveSelf:create(true)))

    local bgsceneMusic = string.format("scene%d", sceneMusic)
	PLAY_MUSIC(GAME_FISH_SOUND_RES..string.format("bgm%d.mp3", sceneMusic + 1))
end

-------------------------游戏消息---------------------------------

function FishGameSceneBase:S_Change_Scene(data)
    --  struct CMD_S_Change_Scene
    -- {
    -- 	uint8 scene_;	///< 场景
    -- 	uint16 special_time;   //特殊鱼阵时间
    -- }
    self:chang_scene(data.scene_)

end

function FishGameSceneBase:S_Fire_Failed(data)
    --  struct CMD_S_Fire_Failed
    -- {
    -- 	uint16 chair_id_;
    -- 	int64  nowGlod_;
    -- }
    print("-------FishGameSceneBase:S_Fire_Failed: ", data.chair_id_, data.nowGlod_)
    if data.chair_id_ ~= self._dataModel.m_myChairId then
        return
    end
    local canon = self.m_cannonLayer:getMyCannon()
    canon:setGold(data.nowGlod_)
    if canon:canFire() then
        return
    end
    if self.m_Var.isAlertFireFailed == false then
        self.m_Var.isAlertFireFailed = true
        if self.m_Var.m_isAlertGoldLose then
            return
        end
--        App.showMsgBox(App.stringsDic.System_Tips_mb2, MsgBoxBtnType.NONEBUTTON)
        DialogLayer.new():show("金币不足，无法发射子弹！")
        if self._dataModel.m_autoLock then
            self:lockAutoCallback(1, self._dataModel.m_autoLock)
        end
    end

end

--
local BIRD_PLATE_OFFSET_Y = 210

function FishGameSceneBase:S_Catch_Bird(data)
    -- struct Catch_Bird
    -- {
    -- 	uint16  chair_id_;
    -- 	uint32	catch_gold_;	///< 抓住金币
    -- 	uint32	bird_id_;		///< 抓住鱼id
    -- 	uint64	now_money;;		//当前金币数
    -- 	bool	isDouble;		//是否暴击
    -- 	uint8   is_die;			//是否死亡	
    -- }
    local catch_gold_ = data.catch_gold_
    local chair_id_ = data.chair_id_
    local is_die =(data.is_die == 1)
    local isMe = chair_id_ == self._dataModel.m_myChairId
    local cannon = self.m_cannonLayer:getCannon(chair_id_)

    if cannon and catch_gold_ ~= 0 then
        cannon:addGold(catch_gold_)
        local fish_multiple = catch_gold_ / cannon:getCannonMuitle()
        cannon:showCoin(fish_multiple, catch_gold_)
    end

    local fishModel = self._dataModel.m_InViewFishs[data.bird_id_]
    if fishModel == nil or fishModel.live_ <= 0 then
        -- 没有找到此鱼
        return
    end

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        if not isMe and is_die then
            -- 捕鱼王别人打死鱼，清理
            fishModel.live_ = 0
            self.m_fishLayer:fishDead(fishModel, false)
            self:destoryFish(fishModel)
            return
        end
    end

    if cannon == nil then
        return
    end


    local fish_type = fishModel.type_
    local fishNode = fishModel.node_
    local fishPos = fishNode:getScenePostion()
    local cannonPos = cannon:getPaotaiPos()

    -- 飞金币效果
    if catch_gold_ ~= 0 then
        self:coin_move(chair_id_, fish_type, fishPos, cannonPos)
        self:coin_label(fishPos,(fish_type < 0 and 1 or 2), catch_gold_)
    end

    self:playSoundCatchFish(fish_type)

    local isShowBig_fish_flash = false
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        isShowBig_fish_flash =(fish_type >= Fish2dTools.BIRD_TYPE_16 and not Fish2dTools.isSpecialBird(fish_type))
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        isShowBig_fish_flash =(fish_type >= Fish2dTools.BIRD_TYPE_14)
    end
    if isShowBig_fish_flash then
        local pt = cannonPos
        local viewChair_id_ = cannon:getViewChairId()
        if (viewChair_id_ >= 2) then
            pt.y = pt.y + BIRD_PLATE_OFFSET_Y
        else
            pt.y = pt.y - BIRD_PLATE_OFFSET_Y
        end
        if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
            data.isDouble = true
        end
        self:big_fish_flash(chair_id_, pt, catch_gold_, data.isDouble);
    end

    if fish_type >= Fish2dTools.BIRD_TYPE_11 and fish_type < Fish2dTools.BIRD_TYPE_18 then
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level2/bing_lizi.plist", 2, 1)
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level2/bing_quan.plist", 2, 2.5)
    elseif ((fish_type >= Fish2dTools.BIRD_TYPE_19 and fish_type <= Fish2dTools.BIRD_TYPE_23)
        or(fish_type == Fish2dTools.BIRD_TYPE_29 and not is_die)) then
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level1/dajinbi.plist", 2, 1)
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level1/xiao1.plist", 2, 1)
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level1/xiao2.plist", 2, 3)
    elseif fish_type >= Fish2dTools.BIRD_TYPE_24 and fish_type < Fish2dTools.BIRD_TYPE_28 then
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level3/dabao_lizi.plist", 2, 1)
        Fish2dTools.particle_play(self.m_coinLayer, fishPos, Fish2dTools.mGameResPre .. "/flash/Particle/level3/dabao_quan.plist", 2, 3.5)
    end

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        if fish_type == Fish2dTools.BIRD_PAUSE then
            -- 定屏
            self:Ding_play()
        elseif (fish_type == Fish2dTools.BIRD_TYPE_28 or (fish_type == Fish2dTools.BIRD_TYPE_29 and is_die)) then
            -- 炸弹
            Fish2dTools.particle_play(self.m_coinLayer, cc.p(Fish2dTools.kRevolutionWidth / 2, Fish2dTools.kRevolutionHeight / 2), Fish2dTools.mGameResPre .. "/flash/Particle/level4/dajinbi.plist", 2, 1)
            Fish2dTools.particle_play(self.m_coinLayer, cc.p(Fish2dTools.kRevolutionWidth / 2, Fish2dTools.kRevolutionHeight / 2), Fish2dTools.mGameResPre .. "/flash/Particle/level4/lizi.plist", 2, 1)
            Fish2dTools.particle_play(self.m_coinLayer, cc.p(Fish2dTools.kRevolutionWidth / 2, Fish2dTools.kRevolutionHeight / 2), Fish2dTools.mGameResPre .. "/flash/Particle/level4/dabao_quan.plist", 3.5, 1)

            self.m_coinLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.35), cc.CallFunc:create( function()
                local thefishModel = nil
                local thefishNode = nil
                for fishkey,v in pairs(self._dataModel.m_InViewFishs) do
                    thefishModel = self._dataModel.m_InViewFishs[fishkey]
                    if thefishModel then
                        thefishNode = thefishModel.node_
                        if thefishNode and not thefishNode:isOutWindow() then
                            self:coin_move(chair_id_, thefishModel.type_, thefishNode:getScenePostion(), cannonPos)
                        end
                    end
                end
            end ), nil))
        end
    end


    -- 高分鱼震屏特效
    if (fish_type >= 16 or Fish2dTools.isSpecialBird(fish_type)) then
        self:stop_shake_screen()
        self:start_shake_screen(6)
    end

    if is_die and isMe then
        -- 统计捕获到的鱼和金币，用于结算显示
        self._dataModel.m_SingleGameTotalGold = self._dataModel.m_SingleGameTotalGold + catch_gold_
        if self._dataModel.m_FishDealCountManager[fish_type] then
            self._dataModel.m_FishDealCountManager[fish_type] = self._dataModel.m_FishDealCountManager[fish_type] + 1
        else
            self._dataModel.m_FishDealCountManager[fish_type] = 1
        end
    end
    if isMe and catch_gold_ > 0 then
        self.m_Var.m_isAlertGoldLose = false
        self.m_Var.isAlertFireFailed = false
    end

    -- 清除鱼
    if is_die then
        fishModel.live_ = 0
        self.m_fishLayer:fishDead(fishModel, false)
        self:destoryFish(fishModel)

        if (fish_type == Fish2dTools.BIRD_TYPE_28) then
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.35), cc.CallFunc:create( function()
                self:clearSceneFish()
            end ), nil)) 
        end
    end


end

function FishGameSceneBase:playSoundCatchFish(fish_type)
    if fish_type >= 14 or Fish2dTools.isSpecialBird(fish_type) then
        local sCatch_1 = GAME_FISH_SOUND_RES..string.format("bigFish_%d.mp3", math.random(0, 7))
        PLAY_SOUND(sCatch_1, false)
        PLAY_SOUND(GAME_FISH_SOUND_RES.."superarm.mp3", false)
    elseif fish_type >= 8 and fish_type < 14 then
        if (math.random(0, 3) == 1) then
            local sCatch_2 = GAME_FISH_SOUND_RES..string.format("smallFish_%d.mp3", math.random(0, 10))
            PLAY_SOUND(sCatch_2, false)
        end
        PLAY_SOUND(GAME_FISH_SOUND_RES.."catch.wav", false)
    else
        PLAY_SOUND(GAME_FISH_SOUND_RES.."catch.wav", false)
    end
end

-- local fishcount = 0;
-- 鱼的生成
function FishGameSceneBase:S_Send_Bird(data)
    --  struct CMD_S_Send_Bird
    -- {
    -- 	uint32		id_; ///< id
    -- 	uint8		type_;  ///< 类型
    -- 	uint8		item_; ///< 特效 如果是闪电鱼 红鱼 此项代表鱼类型
    -- 	uint16		path_id_;	///< 路径id
    -- 	uint8		path_type_; ///< 路径类型
    -- 	float		path_delay_; ///< 路径延长
    -- 	xPoint		path_offset_; ///< 路径偏移
    -- 	float		elapsed_; ///< 逝去时间
    -- 	float		speed_; ///< 速度

    -- 	uint32		time_; ///< 时间
    -- 	uint32		gold_; ///< 金币
    -- }
    --     if fishcount>100 then
    --      return
    --     end
    --     fishcount = fishcount+1
--    dump(data)
 
    if self.m_WaitCreateFish.Send_Bird == nil then
        self.m_WaitCreateFish.Send_Bird = { }
    end
    table.insert(self.m_WaitCreateFish.Send_Bird, data)

    --     self:net_send_fish(data)

end

function FishGameSceneBase:S_Send_Bird_Linear(data)
    --  struct CMD_S_Send_Bird_Linear
    -- {
    -- 	uint32 id_;	///< id
    -- 	uint8 type_; ///< 类型
    -- 	uint8 item_; ///< 特效
    -- 	float path_delay_; ///< 路径延迟
    -- 	float elapsed_; ///< 逝去的时间
    -- 	float speed_; ///< 速度

    -- 	xPoint start_; ///< 开始位置
    -- 	xPoint end_; ///< 结束位置

    -- 	uint32 time_; ///< 时间
    -- 	uint32 gold_; ///< 金币
    -- }
    --     if fishcount>0 then
    --      return
    --     end
    --     fishcount = fishcount+1
    if self.m_WaitCreateFish.Send_Bird_Linear == nil then
        self.m_WaitCreateFish.Send_Bird_Linear = { }
    end
    table.insert(self.m_WaitCreateFish.Send_Bird_Linear, data)
    --     self:net_send_fish_linear(data)

end

function FishGameSceneBase:S_Send_Bird_Round(data)
    --  struct CMD_S_Send_Bird_Round
    -- {
    -- 	uint32 id_; ///< id
    -- 	uint8 type_; ///< 鱼类型
    -- 	uint8 item_; ///< 鱼特效
    -- 	float path_delay_; ///< 路径延迟
    -- 	float elapsed_; ///< 时间延迟
    -- 	float speed_; ///< 速度

    -- 	xPoint center_; ///< 中心店
    -- 	float radius_; ///< 半径
    -- 	float rotate_duration_; ///< 旋转时间
    -- 	float start_angle_; ///< 开始角度
    -- 	float rotate_angle_; ///< 旋转角度
    -- 	float move_duration_; ///< 移动时间

    -- 	uint32 time_; ///< 时间
    -- 	uint32 gold_; ///< 金币
    -- }
    if self.m_WaitCreateFish.Send_Bird_Round == nil then
        self.m_WaitCreateFish.Send_Bird_Round = { }
    end
    table.insert(self.m_WaitCreateFish.Send_Bird_Round, data)
    --     self:net_send_fish_round(data)

end

function FishGameSceneBase:S_Send_Bird_Pause_Linear(data)
    --  struct CMD_S_Send_Bird_Pause_Linear
    -- {
    -- 	uint32 id_;
    -- 	uint8 type_;
    -- 	uint8 item_;
    -- 	float path_delay_;
    -- 	float elapsed_;
    -- 	float speed_;
    -- 	float start_angle_;

    -- 	xPoint start_;
    -- 	xPoint pause_;
    -- 	xPoint end_;
    -- 	float pause_time_;

    -- 	uint32 time_;
    -- 	uint32 gold_;
    -- }
    if self.m_WaitCreateFish.Send_Bird_Pause_Linear == nil then
        self.m_WaitCreateFish.Send_Bird_Pause_Linear = { }
    end
    table.insert(self.m_WaitCreateFish.Send_Bird_Pause_Linear, data)

    --     self:net_send_fish_pause_linear(data)
end

function FishGameSceneBase:S_Send_Bullet(data)
    --  struct CMD_S_Send_Bullet
    -- {
    -- 	float rotation_;		///< 角度
    -- 	uint16 chair_id_;		///< 椅子id
    -- 	uint32 bullet_mulriple;	//当前子弹赔率
    -- 	int lock_bird_id_;		///< 锁定的鱼
    -- 	int64 cur_gold_;		//当前鱼币
    -- 	uint8 bullet_type_;		//子弹类型
    -- };
    -- print("-------FishGameSceneBase:S_Send_Bullet: ", data.chair_id_, data.cur_gold_)
    self:netSendBullet(data, false)
end

-------------------------------------------------------------------

--------------------------------子弹相关处理 begin-----------------------------------
local isTimeUpCount = 0

-- 处理自己操作发射子弹
function FishGameSceneBase:toFire()
    -- print("---FishGameSceneBase:toFire---")
    if self._dataModel.m_isGamePause then
        print("Waining toFire: m_isGamePause = true")
        return
    end
    if self._dataModel.s_gameConfig == nil or self._dataModel.s_gameConfig.mulriple_count_ == nil or self._dataModel.s_gameConfig.mulriple_count_ <= 0 then
        print("Waining toFire: mulriple_count_ <= 0")
        return
    end
    if self.m_Var.fireTimer:isTimeUp() == false then
        -- 间隔时间太短
        isTimeUpCount = isTimeUpCount+1
        if isTimeUpCount > 50 then
             print(string.format("Wain toFire: isTimeUp: currentTime=%d, mStart=%d, mDelay=%d",self.m_Var.fireTimer.currentTime,self.m_Var.fireTimer.mStart,self.m_Var.fireTimer.mDelay))
             if self.m_Var.fireTimer.mStart < 0 then
                 self.m_Var.fireTimer.mStart = self.m_Var.fireTimer:getCurrentTime()
             end
        end
        return
    end
    isTimeUpCount = 0
    local myCannon = self.m_cannonLayer:getMyCannon()
    local cannonLevel = myCannon:getCannonLevel()
    if not myCannon:canFire() then
        if self.m_Var.m_isAlertGoldLose then
--            print("Waining toFire: myCannon:canFire() = false,m_isAlertGoldLose = true")
            return
        end
        self.m_Var.m_isAlertGoldLose = true

        self.m_Var.fireTimer:initData(1000)
        -- 提示金币不足
--        App.showMsgBox(App.stringsDic.System_Tips_mb2, MsgBoxBtnType.NONEBUTTON)
        DialogLayer.new():show("金币不足，无法发射子弹！")
        print("Waining toFire: myCannon:canFire() = false")
        if self._dataModel.m_autoLock then
            self:lockAutoCallback(1, self._dataModel.m_autoLock)
        end
        return
    end
    self.m_Var.m_isAlertGoldLose = false
    if self.m_BulletCount > Fish2dTools.BULLETCOUNT_MAX then
        print("Waining toFire: m_BulletCount, BULLETCOUNT_MAX: ", self.m_BulletCount, Fish2dTools.BULLETCOUNT_MAX)
        return
    end
    self.m_BulletCount = self.m_BulletCount + 1
    if myCannon:isOpenDoubleCannon() then
        -- 双炮再加一个
        self.m_BulletCount = self.m_BulletCount + 1
    end
    local bulletConfig = self._dataModel:getBulletConfig(cannonLevel)
    if not bulletConfig then
        print("---Error toFire bulletConfig is nil, cannonLevel:", cannonLevel)
        return
    end
    local fire_interval_ = bulletConfig.fire_interval
    self.m_Var.fireTimer:initData(fire_interval_ * self._dataModel.mAutoSpeedMultiple)

    self.m_Var.warningTimer:initData(0)
    if self.m_Var.m_Image_ExitTip and self.m_Var.m_Image_ExitTip:isVisible() then
        self.m_Var.m_Image_ExitTip:setVisible(false)
    end

    myCannon:fire(true)

    local bulletType = 0
    if myCannon:isOpenKuangbao() then
        bulletType = bulletType + Fish2dTools.BULLET_Fury
    end
    if myCannon:isOpenDoubleCannon() then
        bulletType = bulletType + Fish2dTools.BULLET_DOUBLE
    end
    local localfishid = -1
    if myCannon:isLockFish() then
        localfishid = myCannon:getLockFishId()
    end

    --    struct CMD_S_Send_Bullet
    -- {
    -- 	float rotation_;		///< 角度弧度值
    -- 	uint16 chair_id_;		///< 椅子id
    -- 	uint32 bullet_mulriple;	//当前子弹赔率
    -- 	int lock_bird_id_;		///< 锁定的鱼
    -- 	int64 cur_gold_;		//当前鱼币
    -- 	uint8 bullet_type_;		//子弹类型
    -- };
    local sendBulletData = { }
    sendBulletData.chair_id_ = self._dataModel.m_myChairId
    sendBulletData.rotation_ = myCannon:getBowRotation()
    sendBulletData.bullet_type_ = bulletType
    sendBulletData.bullet_mulriple = myCannon:getCannonMuitle()
    sendBulletData.lock_bird_id_ = localfishid
    sendBulletData.cur_gold_ = myCannon:getGold() - sendBulletData.bullet_mulriple
    if myCannon:isOpenDoubleCannon() then
        sendBulletData.cur_gold_ = sendBulletData.cur_gold_ - sendBulletData.bullet_mulriple
    end

    self:sendOpenFireToS(sendBulletData)

    self:netSendBullet(sendBulletData, true)

    -- 音效
    local sSnd = GAME_FISH_SOUND_RES.."fire0.wav"
    PLAY_SOUND(sSnd, false)
end

-- 向服务器发送开火协议
function FishGameSceneBase:sendOpenFireToS(sendBulletData)
    -- print("---FishGameSceneBase:sendOpenFireToS---")
    self.mCurrentMySendBulletCount = self.mCurrentMySendBulletCount + 1
    --    struct CMD_C_Fire
    -- {
    -- 	uint16 chair_id_;
    -- 	float rote_;				//< 开火, 角度
    -- 	uint32 bullet_mulriple_;	//< 子弹倍数
    -- 	int lock_bird_id_;			//锁定鱼id
    -- 	uint8 bullet_type_;		//< 子弹类型  穿透 双倍  狂暴
    -- };
    local cfireData = {
        chair_id_ = sendBulletData.chair_id_,
        rote_ = sendBulletData.rotation_,
        bullet_mulriple_ = sendBulletData.bullet_mulriple,
        lock_bird_id_ = sendBulletData.lock_bird_id_,
        bullet_type_ = sendBulletData.bullet_type_
    }

--    dump(cfireData)
	self.core:sendGameMsg(FISH.CMD.SUB_C_FIRE, cfireData)
--    MsgCenter:SendDataToServerG(constDef.MDM_GF_GAME, SUB_C_FIRE, cfireData, "CMD_C_Fire")
end

-- 向服务器发送碰撞到鱼协议
function FishGameSceneBase:sendCatchFishToS(bulletNode, fishModel)
    -- print("---FishGameSceneBase:sendCatchFishToS---bid, fid: ", bulletNode.mId, fishModel.id_)
    if bulletNode.mChairId ~= self._dataModel.m_myChairId then
        return
    end
    -- 捕到鱼(客户端告诉服务端)
    -- struct CMD_C_Catch_Fish
    -- {
    -- 	uint16 					chair_id;			//椅子ID
    -- 	uint32 					fish_id_;			//鱼ID
    -- 	uint8 					bullet_kind;		//子弹类型
    -- 	uint32					bullet_id;			//子弹ID
    -- };
    local cCatchFish = { bullet_multiple = self.m_cannonLayer:getMyCannon():getCannonMuitle(), chair_id = bulletNode.mChairId, fish_id_ = fishModel.id_, bullet_kind = bulletNode.bullet_type_, bullet_id = 0 }
	self.core:sendGameMsg(FISH.CMD.SUB_C_CATCH_FISH, cCatchFish)
--    MsgCenter:SendDataToServerG(constDef.MDM_GF_GAME, SUB_C_CATCH_FISH, cCatchFish, "CMD_C_Catch_Fish")
end

function FishGameSceneBase:netSendBullet(cmd_sendBullet, bMeLocalFire)
    -- print("---FishGameSceneBase:netSendBullet--- bMeLocalFire, bullet_type_: ", bMeLocalFire, cmd_sendBullet.bullet_type_)
    -- dump(cmd_sendBullet)
    --  struct CMD_S_Send_Bullet
    -- {
    -- 	float rotation_;		///< 角度
    -- 	uint16 chair_id_;		///< 椅子id
    -- 	uint32 bullet_mulriple;	//当前子弹赔率
    -- 	int lock_bird_id_;		///< 锁定的鱼
    -- 	int64 cur_gold_;		//当前鱼币
    -- 	uint8 bullet_type_;		//子弹类型
    -- };
    if not cmd_sendBullet or self.loading then  -- 忽略loading时的消息
        print("FishGameSceneBase:netSendBullet cmd_sendBullet is nil!")
        return
    end
    cmd_sendBullet.bullet_mulriple = cmd_sendBullet.bullet_mulriple or cmd_sendBullet.bullet_mulriple_
    if cmd_sendBullet.bullet_mulriple <= 0 or cmd_sendBullet.chair_id_ >= self.GAME_PLAYER then
        print("FishGameSceneBase:netSendBullet cmd_sendBullet.bullet_mulriple, cmd_sendBullet.chair_id_", cmd_sendBullet.bullet_mulriple, cmd_sendBullet.chair_id_)
        return
    end

    local cannon = self.m_cannonLayer:getCannon(cmd_sendBullet.chair_id_)
    if cannon == nil then
        if bMeLocalFire then
            print("FishGameSceneBase:netSendBullet cannon is nil! cmd_sendBullet.chair_id_: ",cmd_sendBullet.chair_id_)
        end
        return
    end

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        if cmd_sendBullet.chair_id_ ~= self._dataModel.m_myChairId then
            return
        end
    end
    
    local bulletLevel = self._dataModel:getCannonLevelByMriple(cmd_sendBullet.bullet_mulriple)

    -- 修正锁鱼标识
    if not bMeLocalFire and cmd_sendBullet.lock_bird_id_ ~= -1 and not cannon:isMe() then
        if not self._dataModel.m_InViewFishs[cmd_sendBullet.lock_bird_id_] then
            cmd_sendBullet.lock_bird_id_ = -1
        end
    end

    -- 有锁定鱼时修正子弹角度
    if cmd_sendBullet.lock_bird_id_ ~= -1 then
        local locakfishPos = cannon:getLockFishPos()
        if locakfishPos.x ~= 0 or locakfishPos.y ~= 0 then
            local paotaipos = cannon:getPaotaiPos()
            local bAngle = Fish2dTools.calcRotate(paotaipos, locakfishPos)
            cmd_sendBullet.rotation_ = bAngle
        end
    end
    -- 计算炮台角度
    local degree = Fish2dTools.toCCRotation(cmd_sendBullet.rotation_)
    -- 弧度转角度
    if cannon:isMe() then
        if degree > 360 then
            degree = degree - 360
        end
        if degree > 90 and degree <= 180 then
            degree = 90
        elseif degree > 180 and degree < 270 then
            degree = 270
        end
    end
    local cannonDegree = degree
    if cannon:getViewChairId() < 2 then
        if cmd_sendBullet.lock_bird_id_ == -1 then
            cannonDegree = 360 - degree
        else
            cannonDegree = degree - 180
        end
    end

    local isToParse = bMeLocalFire or not cannon:isMe()
    if not isToParse then
        return
    end
    
    self.m_cannonLayer:bulletSend(cmd_sendBullet.chair_id_, cmd_sendBullet.bullet_mulriple, math.rad(cannonDegree), cmd_sendBullet.cur_gold_, bMeLocalFire)

    cmd_sendBullet.bullet_type_ = cmd_sendBullet.bullet_type_ or cmd_sendBullet.bullet_kind
    local bullet_type = cmd_sendBullet.bullet_type_
    local isFuryBullt = bit.band(bullet_type, Fish2dTools.BULLET_Fury) > 0 and true or false
    local isDoubleBullt = bit.band(bullet_type, Fish2dTools.BULLET_DOUBLE) > 0 and true or false
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        isFuryBullt = false
        isDoubleBullt = false
    end
    -- print("isFuryBullt,isDoubleBullt:", isFuryBullt, isDoubleBullt)
    if isToParse then
        if not cannon:isMe() then
            cannon:openKuangbao(isFuryBullt)
            cannon:openDoubleCannon(isDoubleBullt)
        end
        cannon:setCannonLevel(bulletLevel)
    end

    -- 设置锁鱼
    if cmd_sendBullet.lock_bird_id_ ~= -1 then
        self:setFishLock(cmd_sendBullet.chair_id_, cmd_sendBullet.lock_bird_id_)
    else
        if not cannon:isMe() then
            self:setFishLock(cmd_sendBullet.chair_id_, -1)
        end
    end

    local bulletDegree = cannon:getSpriteCannonImgRotation()
    if cannon:getViewChairId() < 2 then
        bulletDegree = cannon:getPlayerNodeRotation() + cannon:getSpriteCannonImgRotation()
    end
    if bulletDegree > 360 then
        bulletDegree = bulletDegree - 360
    end
    local bulletrotation = Fish2dTools.toNetRotation(bulletDegree)
    --    print("netSendBullet cmd_sendBullet.rotation_,bulletrotation: ",cmd_sendBullet.rotation_,bulletrotation)
    cmd_sendBullet.rotation_ = bulletrotation
    local bulletCount = 1
    if isDoubleBullt then
        bulletCount = 2
    end
    local bulletStartPos = cc.p(0, 0)
    for i = 0, bulletCount - 1 do
        if i == 0 then
            bulletStartPos = cannon:getPaotaiPos()
        elseif i == 1 then
            bulletStartPos = cannon:getConnonDouble2WordPos()
        else
            return
        end
        if isToParse then
            -- 发射子弹
            self:sendBullet(cmd_sendBullet, bulletStartPos, bulletDegree, i)
        end

    end

end

function FishGameSceneBase:sendBullet(cmd_sendBullet, bulletPos, weaponDegree, doubleIndex)

    local offoLength = 90
    if doubleIndex == 1 then
        offoLength = 5
    end
    local bulletStartPos = cc.p(bulletPos.x, bulletPos.y)
    local bullet_radians = math.rad(90 - weaponDegree)
    bulletStartPos.x = bulletStartPos.x + offoLength * math.cos(bullet_radians)
    bulletStartPos.y = bulletStartPos.y + offoLength * math.sin(bullet_radians)

    --子弹生成在屏幕外
    if bulletStartPos.x <= 0 or bulletStartPos.x >= Fish2dTools.kRevolutionWidth or bulletStartPos.y <= 0 or bulletStartPos.y >= Fish2dTools.kRevolutionHeight then
        print("Waining sendBullet startPos is out!!!")
        if cmd_sendBullet.chair_id_ == self._dataModel.m_myChairId and self.m_BulletCount > 0 then
            self.m_BulletCount = self.m_BulletCount - 1
        end
        return
    end
    if bulletStartPos.y <= 0 or bulletStartPos.y >= Fish2dTools.kRevolutionHeight then
        return
    end

    local bulletLevel = self._dataModel:getCannonLevelByMriple(cmd_sendBullet.bullet_mulriple)

    if self.m_bulletPool[1] == nil then
        self.m_bulletPool[1] = ObjectPool:create( function()
            local bulletNode = Bullet:create(self, false)
            bulletNode.bullet_type_ = cmd_sendBullet.bullet_type_
            return bulletNode
        end , "bullet_1")
    end
    if self.m_bulletPool[2] == nil then
        self.m_bulletPool[2] = ObjectPool:create( function()
            local bulletShadowNode = Bullet:create(self, true)
            return bulletShadowNode
        end , "bullet_2")
    end

    -- 生成子弹对象
    local bulletNode = self.m_bulletPool[1]:createObject()
    bulletNode.bullet_type_ = cmd_sendBullet.bullet_type_
    bulletNode:resetData(cmd_sendBullet.chair_id_, bulletLevel)
    self.m_bulletLayer:addChild(bulletNode, 1)
    -- 生成子弹影子对象
    local bulletShadowNode = self.m_bulletPool[2]:createObject()
    bulletShadowNode:resetData(cmd_sendBullet.chair_id_, bulletLevel)
    self.m_bulletLayer:addChild(bulletShadowNode, 0)

    if doubleIndex == 1 then
        bulletNode:setOpacity(0)
        bulletShadowNode:setOpacity(0)
    end
    bulletNode:born(false)
    bulletShadowNode:born(true)
    -- 关联
    bulletNode:setShdowNode(bulletShadowNode)
    -- 关联
    bulletShadowNode:setBaseNode(bulletNode)
 
    bulletNode:setPosition(bulletStartPos.x, bulletStartPos.y)
    local angle = math.deg(cmd_sendBullet.rotation_ - Fish2dTools.M_PI_2)

    bulletNode:setBulletRotation(angle)
    bulletNode:setFishId(cmd_sendBullet.lock_bird_id_)


    bulletShadowNode:setPosition(bulletNode:getPositionX() + 15, bulletNode:getPositionY() -15)
    bulletShadowNode:setBulletRotation(bulletNode:getRotation())

    self:fire_process(bulletNode, bulletShadowNode, cmd_sendBullet, bulletStartPos, 0)

    -- 记录子弹对象
    -- table.insert(self._dataModel.m_InViewBullets, bulletNode)
end

-- 开启子弹移动
function FishGameSceneBase:fire_process(bulletNode, bulletShadowNode, cmd_sendBullet, bulletPos, trad)
    local playerAngle = cmd_sendBullet.rotation_

    local bulletLevel = self._dataModel:getCannonLevelByMriple(cmd_sendBullet.bullet_mulriple)
    local bulletSpeed = self._dataModel:getBulletSpeed(bulletLevel)

    bulletNode:setSpeed(bulletSpeed)
    bulletNode:setMoveRotation(playerAngle)
    bulletNode:onEnter()

    bulletShadowNode:setSpeed(bulletSpeed)
    bulletShadowNode:setMoveRotation(playerAngle)
    bulletShadowNode:onEnter()

    return playerAngle
end

function FishGameSceneBase:removeBullet(bulletNode)
    -- print("---FishGameSceneBase:removeBullet---id:",bulletNode.mId)
    if bulletNode.mChairId == self._dataModel.m_myChairId then
        self.m_BulletCount = self.m_BulletCount - 1
        if self.m_BulletCount < 0 then self.m_BulletCount = 0 end
    end

    bulletNode:onExit()
    if bulletNode.m_shadowNode then
        bulletNode.m_shadowNode:onExit()
        if bulletNode.m_shadowNode.recycleToPool ~= nil then
            bulletNode.m_shadowNode:recycleToPool()
        else
            bulletNode.m_shadowNode:removeFromParent(true)
        end
    end
    if bulletNode.recycleToPool ~= nil then
        bulletNode:recycleToPool()
    else
        bulletNode:removeFromParent(true)
    end
end

-- 显示鱼网
function FishGameSceneBase:openNet(chairId, netType, pos)
    -- 网
    if self.m_netPool[netType] == nil then
        self.m_netPool[netType] = ObjectPool:create( function()
            local netImgname = nil
            if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
                netImgname = string.format("jsby_yuwang_0%d", netType)
            elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
                netImgname = string.format("daao_byw_yw_0%d", netType)
            end
            local spt = ccs.Armature:create(netImgname)
            return spt
        end , "net_" .. netType)
    end

    local spt = self.m_netPool[netType]:createObject()
    spt:setPosition(pos)
    spt:getAnimation():play("Animation1", -1, 0)
    self.m_netLayer:addChild(spt, 1)
    local act = cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create( function()
        if spt.recycleToPool ~= nil then
            spt:recycleToPool()
        else
            spt:removeFromParent(true)
        end
    end ), nil)
    spt:runAction(act)
    -- 网的影子
    if self.m_netShadowPool[netType] == nil then
        self.m_netShadowPool[netType] = ObjectPool:create( function()
            if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
                netImgname = string.format("jsby_yuwang_0%d", netType)
            elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
                netImgname = string.format("daao_byw_yw_0%d", netType)
            end
            local spt = ccs.Armature:create(netImgname)
            return spt
        end , "netShadow_" .. netType)
    end
    local spt_shadow = self.m_netShadowPool[netType]:createObject()
    spt_shadow:setPosition(cc.p(pos.x + 30, pos.y - 30))
    spt_shadow:getAnimation():play("Animation1", -1, 0)
    spt_shadow:setColor(cc.c3b(0, 0, 0))
    spt_shadow:setScale(0.75)
    spt_shadow:runAction(cc.FadeTo:create(0.1, 100))
    self.m_netLayer:addChild(spt_shadow, 0)
    local act_shadow = cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create( function()
        if spt_shadow.recycleToPool ~= nil then
            spt_shadow:recycleToPool()
        else
            spt_shadow:removeFromParent(true)
        end
    end ), nil)
    spt_shadow:runAction(act_shadow)

end
----------------------------子弹相关处理 end-------------------------------------------------

----------------------------鱼相关处理 begin---------------------------------
function FishGameSceneBase:net_send_fish(cmd_send_fish)
    -- struct CMD_S_Send_Bird
    -- {
    -- 	uint32		id_; ///< id
    -- 	uint8		type_;  ///< 类型
    -- 	uint8		item_; ///< 特效 如果是闪电鱼 红鱼 此项代表鱼类型
    -- 	uint16		path_id_;	///< 路径id
    -- 	uint8		path_type_; ///< 路径类型
    -- 	float		path_delay_; ///< 路径延长
    -- 	xPoint		path_offset_; ///< 路径偏移
    -- 	float		elapsed_; ///< 逝去时间
    -- 	float		speed_; ///< 速度

    -- 	uint32		time_; ///< 时间
    -- 	uint32		gold_; ///< 金币
    -- }
    -- print("---FishGameSceneBase:net_send_fish---fishId, type: ", cmd_send_fish.id_, cmd_send_fish.type_)

    self:deleteInFishBomlTips()

    if self._dataModel.m_InViewFishs[cmd_send_fish.id_] then
        -- 此鱼已经存在了，先删除
        self:destoryFish(self._dataModel.m_InViewFishs[cmd_send_fish.id_])
        self._dataModel.m_InViewFishs[cmd_send_fish.id_] = nil
    end

    local fishModel = FishModel:create()
    fishModel.id_ = cmd_send_fish.id_
    fishModel.type_ = cmd_send_fish.type_
    fishModel.item_ = cmd_send_fish.item_

    fishModel.path_id_ = cmd_send_fish.path_id_
    fishModel.path_type_ = cmd_send_fish.path_type_
    fishModel.path_delay_ = cmd_send_fish.path_delay_
    fishModel.path_offset_ = cc.p(cmd_send_fish.path_offset_x, cmd_send_fish.path_offset_y)
    fishModel.speed_ = cmd_send_fish.speed_

    -- print("set : self._dataModel.m_InViewFishs[cmd_send_fish.id_] id: ",fishModel.id_)

    --    if fishModel.type_ > Fish2dTools.BIRD_TYPE_12 then
    --        table.insert(self._dataModel.m_canAutoLockList, cmd_send_fish.id_)
    --    end
    --
    self.m_fishLayer:sendFish(fishModel, nil, nil)

    self._dataModel.m_InViewFishs[cmd_send_fish.id_] = fishModel
    self:addFishCallBack(fishModel)
end

function FishGameSceneBase:net_send_fish_linear(cmd_send_fish)
    --  struct CMD_S_Send_Bird_Linear
    -- {
    -- 	uint32 id_;	///< id
    -- 	uint8 type_; ///< 类型
    -- 	uint8 item_; ///< 特效
    -- 	float path_delay_; ///< 路径延迟
    -- 	float elapsed_; ///< 逝去的时间
    -- 	float speed_; ///< 速度

    -- 	xPoint start_; ///< 开始位置
    -- 	xPoint end_; ///< 结束位置

    -- 	uint32 time_; ///< 时间
    -- 	uint32 gold_; ///< 金币
    -- }
    -- print("---FishGameSceneBase:net_send_fish_linear---fishId, type: ", cmd_send_fish.id_, cmd_send_fish.type_)

    self:deleteInFishBomlTips()

    if self._dataModel.m_InViewFishs[cmd_send_fish.id_] then
        -- 此鱼已经存在了，先删除
        self:destoryFish(self._dataModel.m_InViewFishs[cmd_send_fish.id_])
        self._dataModel.m_InViewFishs[cmd_send_fish.id_] = nil
    end
--    dump(cmd_send_fish)
    cmd_send_fish.start_ = cc.p(cmd_send_fish.start_x, cmd_send_fish.start_y)
    cmd_send_fish.end_ = cc.p(cmd_send_fish.end_x, cmd_send_fish.end_y)

    local worldScaleRate = self.m_fishLayer:getWorldScaleRate()
    cmd_send_fish.start_ = cc.pMul(cmd_send_fish.start_, worldScaleRate)
    cmd_send_fish.end_ = cc.pMul(cmd_send_fish.end_, worldScaleRate)

    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        if self._dataModel.m_myChairId <= 1 then
            cmd_send_fish.start_.y = Fish2dTools.kRevolutionHeight * worldScaleRate - cmd_send_fish.start_.y
            cmd_send_fish.end_.y = Fish2dTools.kRevolutionHeight * worldScaleRate - cmd_send_fish.end_.y
        end
    end


    local fishModel = FishModel:create()
    fishModel.id_ = cmd_send_fish.id_
    fishModel.type_ = cmd_send_fish.type_
    fishModel.item_ = cmd_send_fish.item_

    fishModel.position_ = cc.p(cmd_send_fish.start_.x, cmd_send_fish.start_.y)
    fishModel.path_delay_ = cmd_send_fish.path_delay_
    fishModel.elapsed_ = cmd_send_fish.elapsed_
    fishModel.speed_ = cmd_send_fish.speed_


    --    if fishModel.type_ > Fish2dTools.BIRD_TYPE_12 then
    --        table.insert(self._dataModel.m_canAutoLockList, cmd_send_fish.id_)
    --    end
    --
    local acion = ActionCustom.action_Bird_Move_Linear:create(fishModel.speed_, cmd_send_fish.start_, cmd_send_fish.end_)
    self.m_fishLayer:sendFish(fishModel, true, acion)

    self._dataModel.m_InViewFishs[cmd_send_fish.id_] = fishModel
    self:addFishCallBack(fishModel)
end

function FishGameSceneBase:net_send_fish_round(cmd_send_fish)
    -- struct CMD_S_Send_Bird_Round
    -- {
    -- 	uint32 id_; ///< id
    -- 	uint8 type_; ///< 鱼类型
    -- 	uint8 item_; ///< 鱼特效
    -- 	float path_delay_; ///< 路径延迟
    -- 	float elapsed_; ///< 时间延迟
    -- 	float speed_; ///< 速度

    -- 	xPoint center_; ///< 中心店
    -- 	float radius_; ///< 半径
    -- 	float rotate_duration_; ///< 旋转时间
    -- 	float start_angle_; ///< 开始角度
    -- 	float rotate_angle_; ///< 旋转角度
    -- 	float move_duration_; ///< 移动时间

    -- 	uint32 time_; ///< 时间
    -- 	uint32 gold_; ///< 金币
    -- };
    -- print("---FishGameSceneBase:net_send_fish_round---fishId, type: ", cmd_send_fish.id_, cmd_send_fish.type_)
    if self._dataModel.m_InViewFishs[cmd_send_fish.id_] then
        -- 此鱼已经存在了，先删除
        self:destoryFish(self._dataModel.m_InViewFishs[cmd_send_fish.id_])
        self._dataModel.m_InViewFishs[cmd_send_fish.id_] = nil
    end

    local worldScaleRate = self.m_fishLayer:getWorldScaleRate()
    cmd_send_fish.center_ = cc.p(cmd_send_fish.center_x, cmd_send_fish.center_y)
    cmd_send_fish.center_ = cc.pMul(cmd_send_fish.center_, worldScaleRate)
    cmd_send_fish.radius_ = cmd_send_fish.radius_ * worldScaleRate
    cmd_send_fish.rotate_duration_ = cmd_send_fish.rotate_duration_ * worldScaleRate
    cmd_send_fish.move_duration_ = cmd_send_fish.move_duration_ * worldScaleRate

    local fishModel = FishModel:create()
    fishModel.id_ = cmd_send_fish.id_
    fishModel.type_ = cmd_send_fish.type_
    fishModel.item_ = cmd_send_fish.item_

    fishModel.path_delay_ = cmd_send_fish.path_delay_
    fishModel.elapsed_ = cmd_send_fish.elapsed_
    fishModel.speed_ = cmd_send_fish.speed_


    --    if fishModel.type_ > Fish2dTools.BIRD_TYPE_12 then
    --        table.insert(self._dataModel.m_canAutoLockList, cmd_send_fish.id_)
    --    end
    --
    local acion = ActionCustom.action_Bird_Round_Move:create(cmd_send_fish.center_, cmd_send_fish.radius_, cmd_send_fish.rotate_duration_,
    cmd_send_fish.start_angle_, cmd_send_fish.rotate_angle_, cmd_send_fish.move_duration_, cmd_send_fish.speed_, cmd_send_fish.radius_ == 0 and true or false)
    self.m_fishLayer:sendFish(fishModel, true, acion)

    self._dataModel.m_InViewFishs[cmd_send_fish.id_] = fishModel
    self:addFishCallBack(fishModel)
end

function FishGameSceneBase:net_send_fish_pause_linear(cmd_send_fish)
    -- struct CMD_S_Send_Bird_Pause_Linear
    -- {
    -- 	uint32 id_;
    -- 	uint8 type_;
    -- 	uint8 item_;
    -- 	float path_delay_;
    -- 	float elapsed_;
    -- 	float speed_;
    -- 	float start_angle_;

    -- 	xPoint start_;
    -- 	xPoint pause_;
    -- 	xPoint end_;
    -- 	float pause_time_;

    -- 	uint32 time_;
    -- 	uint32 gold_;
    -- };
    -- print("---FishGameSceneBase:net_send_fish_pause_linear---fishId, type: ", cmd_send_fish.id_, cmd_send_fish.type_)
--    dump(cmd_send_fish)
    if self._dataModel.m_InViewFishs[cmd_send_fish.id_] then
        -- 此鱼已经存在了，先删除
        self:destoryFish(self._dataModel.m_InViewFishs[cmd_send_fish.id_])
        self._dataModel.m_InViewFishs[cmd_send_fish.id_] = nil
    end

    local worldScaleRate = self.m_fishLayer:getWorldScaleRate()
    cmd_send_fish.start_ = cc.p(cmd_send_fish.start_x, cmd_send_fish.start_y)
    cmd_send_fish.pause_ = cc.p(cmd_send_fish.pause_x, cmd_send_fish.pause_y)
    cmd_send_fish.end_ = cc.p(cmd_send_fish.end_x, cmd_send_fish.end_y)
    cmd_send_fish.start_ = cc.pMul(cmd_send_fish.start_, worldScaleRate)
    cmd_send_fish.pause_ = cc.pMul(cmd_send_fish.pause_, worldScaleRate)
    cmd_send_fish.end_ = cc.pMul(cmd_send_fish.end_, worldScaleRate)

    local fishModel = FishModel:create()
    fishModel.id_ = cmd_send_fish.id_
    fishModel.type_ = cmd_send_fish.type_
    fishModel.item_ = cmd_send_fish.item_

    fishModel.path_delay_ = cmd_send_fish.path_delay_
    fishModel.elapsed_ = cmd_send_fish.elapsed_
    fishModel.speed_ = cmd_send_fish.speed_


    --    if fishModel.type_ > Fish2dTools.BIRD_TYPE_12 then
    --        table.insert(self._dataModel.m_canAutoLockList, cmd_send_fish.id_)
    --    end
    --
    local acion = ActionCustom.action_Bird_Move_Pause_Linear:create(cmd_send_fish.speed_, cmd_send_fish.pause_time_, cmd_send_fish.start_,
    cmd_send_fish.pause_, cmd_send_fish.end_, cmd_send_fish.start_angle_)
    self.m_fishLayer:sendFish(fishModel, true, acion)

    self._dataModel.m_InViewFishs[cmd_send_fish.id_] = fishModel
    self:addFishCallBack(fishModel)
end

function FishGameSceneBase:addFishCallBack(fishModel)
    -- 子类实现
end

function FishGameSceneBase:collisionPosFish(touchPos)
    local isTouch = false
    local pt_touchPos = touchPos
    local fishList = self._dataModel.m_InViewFishs
    local fishModel = nil

    for fishkey in pairs(fishList) do
        fishModel = fishList[fishkey]
        -- 检测点是否和鱼碰撞
        if fishModel and fishModel.live_ > 0 and fishModel.node_ and(fishModel.node_:isUnActive() == false) then
            local fishNode = fishModel.node_
            local pt_fish = fishNode:getScenePostion()
            local sz_fish
            if Fish2dTools.isSpecialRoundBird(fishModel.type_) then
                local special_id = fishModel.type_ - Fish2dTools.BIRD_TYPE_ONE
                sz_fish = Fish2dTools.get_special_fish_size(special_id)
            elseif Fish2dTools.isSpecialBird(fishModel.type_) then
                sz_fish = Fish2dTools.get_fish_size(fishModel.item_)
            else
                sz_fish = Fish2dTools.get_fish_size(fishModel.type_)
            end
            local rotation_fish = Fish2dTools.toNetRotation(fishNode:getRotation())

            isTouch = Fish2dTools.compute_collision(pt_fish.x, pt_fish.y, sz_fish.x, sz_fish.y, rotation_fish, pt_touchPos.x, pt_touchPos.y, 1)
            if isTouch then
                break
            end
        end
    end

    if isTouch then
        return fishModel.node_
    end
    return nil
end

function FishGameSceneBase:destoryFish(fishModel)
    -- print("FishGameSceneBase:destoryFish fishModel.id_: ",fishModel.id_)
    if fishModel.id_ <= 0 then
        return
    end

    -- 清理对此鱼的锁定信息
    for i = 0, self.GAME_PLAYER - 1 do
        local cannon = self.m_cannonLayer:getCannon(i)
        if cannon and cannon:isLockFish() then
            if cannon:getLockFishId() == fishModel.id_ then
                cannon:cancelLockFish()
            end
        end
    end

    --
    --    if #self._dataModel.m_canAutoLockList > 0 and self._dataModel.m_canAutoLockList[fishModel.id_] then
    --        self._dataModel.m_canAutoLockList[fishModel.id_] = nil
    --    end
    fishModel.node_ = nil

    -- print("destoryFish self._dataModel.m_InViewFishs[fishModel.id_] = nil, id: ",fishModel.id_, self._dataModel.m_InViewFishs[fishModel.id_].id_)
    self._dataModel.m_InViewFishs[fishModel.id_] = nil
end

function FishGameSceneBase:clearSceneFish()
    print("---FishGameSceneBase:clearSceneFish---")
    for fishkey,v in pairs(self._dataModel.m_InViewFishs) do
        fishModel = self._dataModel.m_InViewFishs[fishkey]
        if fishModel then
            fishModel.live_ = 0
            -- print("clearSceneFish fishModel.live_ = 0, id: ", self.mFishModel.id_)
            self.m_fishLayer:fishDead(fishModel, true)
            self:destoryFish(fishModel)
        end
    end
    -- 清空
    self._dataModel.m_InViewFishs = { }
end
----------------------------鱼相关处理 end---------------------------------

----------------------------金币和特效相关处理 begin---------------------------------
-- 捕到鱼爆出金币并飞向炮台
function FishGameSceneBase:coin_move(chair_id, fish_type, pt_src, pt_dst)
    local coin_index = 1
    local count = 0
    if fish_type < 26 then
        count = fish_type % 10 + 1
    end
    local coinSize = 1.2

    local size = 50;
    local x_offset = - size *(count > 5 and 5 or count) / 2;
    local y_offset = - size *(count / 5 + 1) / 2;

    local ani_name = string.format("CoinMove%d", coin_index)

    if ((fish_type > Fish2dTools.BIRD_TYPE_14 and fish_type <= Fish2dTools.BIRD_TYPE_17) or(fish_type == Fish2dTools.BIRD_TYPE_26)) then
        -- 10倍-25倍
        coinSize = 1.2
    elseif (fish_type > Fish2dTools.BIRD_TYPE_17) then
        coinSize = 1.4
    end
    local srcVec2 = pt_src
    local dstVec2 = pt_dst
    local oppoX = count > 8 and 140 or 60;

    if self.m_coinPool == nil then
        self.m_coinPool = ObjectPool:create( function()
            local spt = cc.Sprite:create()
            return spt
        end , "coin")
    end

    for i = 0, count - 1 do
        local spt = self.m_coinPool:createObject()
        -- cc.Sprite:createWithSpriteFrameName("jinbi_cell-jinbi_1.png")
        spt:setScale(coinSize)
        self.m_coinLayer:addChild(spt)
        spt:runAction(cc.RepeatForever:create(Fish2dTools.createAnimate(ani_name, 0)));

        local goldPos = cc.p(srcVec2.x + math.random(- oppoX, oppoX), srcVec2.y + math.random(-20, 20))
        spt:setPosition(goldPos.x, goldPos.y);

        spt:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.MoveBy:create(0.4, cc.p(0, 190))),
        cc.EaseBounceOut:create(cc.MoveBy:create(1.1, cc.p(0, -120))),
        cc.DelayTime:create(0.1 + i * 0.04),
        cc.EaseSineIn:create(cc.JumpTo:create(0.9, dstVec2, 120, 1)),
        cc.CallFunc:create( function()
            if spt.recycleToPool ~= nil then
                spt:recycleToPool()
            else
                spt:removeFromParent(true)
            end
        end ),
        nil))
    end

end

function FishGameSceneBase:coin_label(pt_src, font_index, price)
    local label = cc.LabelAtlas:_create()
    label:initWithString(tostring(utils:moneyString(price)), "games/fish/bmfonts/bigAwardNum.png", 37, 62, string.byte("."))
    label:setPosition(pt_src.x, pt_src.y)
    self.m_coinLayer:addChild(label)

    local act = cc.Sequence:create(
    cc.DelayTime:create(0.2),
    cc.MoveTo:create(0.3, cc.p(pt_src.x, pt_src.y - 50)),
    cc.FadeOut:create(0.6),
    cc.RemoveSelf:create(),
    nil)

    label:runAction(act);
end

function FishGameSceneBase:big_fish_flash(chair_id, pt, price, isBaoji)
    local aniTag = 1111 + chair_id

    local label = cc.LabelAtlas:_create()
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        label:initWithString(tostring(utils:moneyString(price, 2)), "games/fish/bmfonts/bigAwardNum.png", 37, 62, string.byte("."))
        label:setPosition(cc.p(175, 75))
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        label:initWithString(tostring(utils:moneyString(price, 2)), "FishkingGameScene/flash/baoji/zj_numfont.png", 48, 63, string.byte("0"))
        label:setPosition(cc.p(175, 75 + 60))
    end
    local pt2 = cc.p(pt.x + 100, pt.y - 2)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setTag(aniTag)

    local act = cc.RepeatForever:create(cc.Sequence:create(
    cc.MoveTo:create(0.3, cc.p(pt2.x, pt2.y + 10)),
    cc.MoveTo:create(0.3, pt2),
    cc.MoveTo:create(0.3, cc.p(pt2.x, pt2.y - 10)),
    cc.MoveTo:create(0.3, pt2),
    nil))
    label:setScale(1.0)
    label:runAction(act)
--    local aa = label:clone()
--    self:addChild(aa)

    local bingoName = { }
    local renderName = ""
    if Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISH2D then
        bingoName = { "2D_jsby_baoji", "2D_buyu_jiangchi" }
        renderName = "caidai"
    elseif Fish2dTools.mGame_Type == Fish2dTools.GAME_TYPE_FISHKING then
        bingoName = { "daao_byw_jc_zj", "daao_byw_jc_zj" }
        renderName = "diban"
    end

    local armature = self.m_coinLayer:getChildByTag(aniTag)
    if armature == nil then
        local index = 2
        if (isBaoji == true) then
            index = 1
        end
        armature = ccs.Armature:create(bingoName[index])
        armature:setTag(aniTag)
        self.m_coinLayer:addChild(armature)

    else
        armature:stopAllActions()
        -- armature:getAnimation():stop()
        local caidai = armature:getChildByName(renderName)
        if caidai then
            local renderNode = caidai:getDisplayRenderNode()
            if renderNode then
                renderNode:removeChildByTag(aniTag)
            end
        end
    end

    armature:setVisible(true)
    local ptNew = cc.p(pt.x, pt.y)
    armature:setPosition(ptNew.x, ptNew.y)
    armature:getAnimation():playWithIndex(0)
    -- play("Animation1", -1, 1);
    armature:setScale(0.8)
    armature:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
    cc.CallFunc:create( function()
        local caidai = armature:getChildByName(renderName)
        if caidai then
            local renderNode = caidai:getDisplayRenderNode()
            if renderNode then
                renderNode:removeChildByTag(aniTag)
            end
        end
        armature:setVisible(false)
        armature:stopAllActions()
    end ), nil));
    --    self.m_Var.catchBingoArmature = armature

    local caidai = armature:getChildByName(renderName)
    if caidai then
        caidai:getDisplayRenderNode():addChild(label, 9999)
    end
    -- 音效
    PLAY_SOUND(GAME_FISH_SOUND_RES.."bingo.wav", false)

end

-- 播放定的特效
function FishGameSceneBase:Ding_play()
    local armature = ccs.Armature:create("bingdongxiaoguo")
    armature:setPosition(Fish2dTools.kRevolutionWidth / 2, Fish2dTools.kRevolutionHeight / 2)
    armature:getAnimation():play("Animation1")
    self.m_coinLayer:addChild(armature)
    self:fish_ding(true)
    armature:runAction(cc.Sequence:create(cc.DelayTime:create(5.0), cc.CallFunc:create( function()
        armature:removeFromParent()
        self:fish_ding(false)
    end ), nil))

end

-- 定的逻辑
function FishGameSceneBase:fish_ding(ding)
    if self.m_fishLayer then
        self.m_fishLayer:setDingFish(ding)
    end
end

-- 开始震屏
function FishGameSceneBase:start_shake_screen(shake_radius)

end

-- 停止震屏
function FishGameSceneBase:stop_shake_screen()

end

function FishGameSceneBase:showInFishBomlTips()
    if self.m_Var.m_inFishBoomSprite == nil then
        self.m_Var.m_inFishBoomSprite = cc.Sprite:create(string.format("%s/res/alert_yuchao.png", Fish2dTools.mGameResPre))
        if self.m_Var.m_inFishBoomSprite then
            self.m_Var.m_inFishBoomSprite:setPosition(Fish2dTools.kRevolutionWidth / 2, Fish2dTools.kRevolutionHeight - 100)
            self:addChild(self.m_Var.m_inFishBoomSprite, 1000)
            self.m_Var.m_inFishBoomSprite:setOpacity(0)
            self.m_Var.m_inFishBoomSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1), nil)))
        end
    end
end

function FishGameSceneBase:deleteInFishBomlTips()
    if self.m_Var.m_inFishBoomSprite ~= nil then
        self.m_Var.m_inFishBoomSprite:stopAllActions()
        self.m_Var.m_inFishBoomSprite:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create(), nil))
        self.m_Var.m_inFishBoomSprite = nil
    end
end

----------------------------金币和特效相关处理 end---------------------------------

----------------------------场景切换、BOSS相关处理 start---------------------------
function FishGameSceneBase:init_scene()
    -- 子类实现
end

function FishGameSceneBase:set_scene(scene)
    -- 子类实现
end

-- 切换场景
function FishGameSceneBase:chang_scene(scene)
    self:fish_speed_up(true)
    self:pauseBulletSend()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(7), cc.CallFunc:create( function()
        self:resumeBulletSend()
    end ), nil))
    ----------
    if scene >= 3 then
        scene = 0
    end
    self.m_Var.scene_ = scene
    self._dataModel.m_curSceneId = scene

    local spr_c_lizi_ = self.m_Var.spr_c_lizi_
    if spr_c_lizi_ then
        spr_c_lizi_:setPosition(Fish2dTools.kRevolutionWidth + 266 - 50, spr_c_lizi_:getPositionY())
        spr_c_lizi_:resetSystem()
        spr_c_lizi_:setVisible(true)
    end
    local actlizi = cc.Sequence:create(
    cc.DelayTime:create(1),
    cc.MoveTo:create(8, cc.p(-256 - 50, spr_c_lizi_:getPositionY())),
    cc.CallFunc:create( function()
        self:set_scene(self.m_Var.scene_)
    end ),
    nil)
    spr_c_lizi_:runAction(actlizi)

    local spr_cloud_ = self.m_Var.spr_cloud_
    spr_cloud_:setPosition(Fish2dTools.kRevolutionWidth + 266, spr_cloud_:getPositionY())
    spr_cloud_:setVisible(true)
    -- spr_cloud_:resumeSchedulerAndActions()

    -- change end
    local act = cc.Sequence:create(
    cc.DelayTime:create(1),
    cc.MoveTo:create(8, cc.p(-256, spr_cloud_:getPositionY())),
    cc.CallFunc:create( function()
        self:set_scene(self.m_Var.scene_)
    end ),
    nil)

    spr_cloud_:runAction(act)

    -- 切换场景不能有音效
--    SoundMng:stopAllSounds()
    PLAY_MUSIC(GAME_FISH_SOUND_RES.."WaveEnter.mp3", false)
    --
    local spr_background2_ = self.m_Var.spr_background2_

    spr_background2_:setVisible(true)
    spr_background2_:setPositionX(spr_cloud_:getPositionX() -140)
    local act2 = cc.Sequence:create(
    cc.DelayTime:create(1),
    cc.MoveTo:create(6.5, cc.p(0, spr_background2_:getPositionY())),
    nil)

    spr_background2_:runAction(act2)

end



function FishGameSceneBase:playBossEnterEffect()
    m_isFirstToLockBoss = true;
    --
end

function FishGameSceneBase:playSceneBgMusic()
    local sSound = string.format("scene%d", self.m_Var.scene_)
    SET_MUSIC_VOLUME(50);
	PLAY_MUSIC(GAME_FISH_SOUND_RES..string.format("bgm%d.mp3", self.m_Var.scene_ + 1))
end

-- 鱼加速游动
function FishGameSceneBase:fish_speed_up(speed_up)
    for fishkey, v in pairs(self._dataModel.m_InViewFishs) do
        local thefishModel = self._dataModel.m_InViewFishs[fishkey]
        if thefishModel and thefishModel.live_ > 0 then
            thefishModel.speed_ = speed_up and Fish2dTools.BIRD_MOVE_RUN_AWAY or Fish2dTools.BIRD_MOVE_NORMAL
            if thefishModel.node_ and thefishModel.node_:isVisible() then
                thefishModel.node_.mFishMove:setSpeed(thefishModel.speed_)
            end
        end
    end
end

-- 暂时发射子弹
function FishGameSceneBase:pauseBulletSend()
    self.m_BulletCount = self.m_BulletCount + Fish2dTools.BULLETCOUNT_MAX
end

-- 恢复发射子弹
function FishGameSceneBase:resumeBulletSend()
    self.m_BulletCount = self.m_BulletCount - Fish2dTools.BULLETCOUNT_MAX
    if self.m_BulletCount < 0 then
        self.m_BulletCount = 0
    end
end

----------------------------场景切换、BOSS相关处理 end-----------------------------

return FishGameSceneBase
-- endregion
