-- region SlotsBase.lua
-- Date 2018-03-28
-- 此文件由[BabeLua]插件自动生成

local SlotsBase = class("SlotsBase", GameSceneBase)
local Slot = require('app.common.Slot')

function SlotsBase.SetImageTextureWithOther(pIcon, pIconOther)
--	pIcon:setContentSize(pIconOther:getContentSize())
--	pIcon:getVirtualRenderer():getSprite():setContentSize(pIconOther:getContentSize())
--	pIcon:getVirtualRenderer():getSprite():setTexture(pIconOther:getVirtualRenderer():getSprite():getTexture())
    local f, t = pIconOther:getRenderFile()
	pIcon:loadTexture(f, t)
end

function SlotsBase:initialize()
	SlotsBase.super.initialize(self)

--    self:AddEvents(
--        App.conn:on("FreeGameScene",function(data)
--            self:FreeGameScene(data)
--        end),
--        App.conn:on("GameStart",function(data)
--            self:startRun(data)
--        end)
--    )

    self.m_llSingleBet = 1
    self.m_nMaxMultiple = 5
    self.m_nCurMultiple = 1
    self.m_llWinFreeTurn = 0
    self.m_nTimesLeft4Free = 0
	self.m_bRunning = false
	self.m_bStopping = false
    self.m_bAutoRunning = false
    self.m_GameData = {userScore = dataManager.userInfo.money}

    display.setAutoScale(CC_DESIGN_RESOLUTION2)
end


function SlotsBase:finalize()
    -- luacheck: ignore self
    STOP_ALL_SOUND()
end

function SlotsBase:loadRes()
    --    SpriteHelper.cacheAnimations("game/fish2d")
end

function SlotsBase:viewDidLoad()
    if self.argT.sounds.bg then
        print(self.argT.sounds.bg)
        PLAY_MUSIC(self.argT.sounds.bg)
    end
    self.m_pBG = self:seekChild("img_main_bg")
--	self.m_pMenu = require("app.widgets.GameExitMenu"):create(self, self.argT.SUB_C_EXIT_GAME);
--	self.m_pMenu:SetBackMusic(self.argT.sounds.bg);
--    self.m_pMenu:CanICloseGameAndWhy(function(exit)
--        return true
--    end)

    -- 将所有的图标和模糊图标存起来，用来克隆给指定位置显示。 这两个数组的内容不会在游戏中改变。
    self.m_arrIcon_T = {}
    self.m_arrIcon_Tb = {}
	for i = 1, self.argT.ROW_NUM do
		self.m_arrIcon_T[i] = self:seekChildByName(string.format("Icon_%d", i - 1))
		self.m_arrIcon_Tb[i] = self:seekChildByName(string.format("Icon_%db", i - 1))
	end
    if #self.m_arrIcon_Tb == 0 then
        self.m_arrIcon_Tb = self.m_arrIcon_T
    end
	self.m_arrIcon_T[1]:getParent():setVisible(false);

    -- 创建以列为单位的滚动机。create最后的回调参数是滚动结束要干的事。
    self.m_arrSlots = {}
	for i = 1, self.argT.COL_NUM do
        local itemNum = self.argT.ITEM_COL or 3
        local endEffects = self.argT.END_EFFECTS
        if endEffects == nil then
            endEffects = true
        end
		self.m_arrSlots[i] = Slot:create(self.argT.ROW_NUM, cc.size(self.argT.SLOT_WIDTH, self.argT.ICON_SPACE * self.argT.ROW_NUM), function()
			self.m_arrSlots[i]:runAction(cc.Sequence:create(
				cc.CallFunc:create(function()
--                if i == self.argT.COL_NUM and endEffects then
--                    SoundMng:stopAllEffects();
--                end
                PLAY_SOUND(self.m_GameData.runInfo[i].stopSound or self.argT.sounds["stop"..i])
--				self.m_arrSlots[i]:setPositionY(self.m_arrSlots[i]:getPositionY() - 5)
                local ppIconSet = self:GetShowingFrame(i)
                for row = 1, self.argT.ROW_NUM do
                    if row <= itemNum then
 				        self.SetImageTextureWithOther(ppIconSet[i][row], self.m_arrIcon_T[self.m_arrIcons[i][row]:getTag()])
				        ppIconSet[i][row]:setOpacity(255)
				        ppIconSet[i][row]:setScaleY(1)
                    else
				        ppIconSet[i][4]:setOpacity(0)
                    end
                end
                
                local frames = self.m_arrSlots[i]:GetFrames()
	            frames = (frames[1]:getPositionY() == 0 and frames[1] or frames[2])
                frames:runAction(cc.Sequence:create(
				    cc.MoveBy:create(0.08, cc.p(0, 0 - (self.argT.easeEnd or 30))),
				    cc.MoveTo:create(0.1, cc.p(frames:getPositionX(), 0))
                ))
			end),
				cc.DelayTime:create(0.28),
				cc.CallFunc:create(function()
                self:SlotsStopped(i)
			end)))
		end, itemNum)

		self.m_arrSlots[i]:SetCurItem(math.random() % self.argT.ROW_NUM)
		self.m_arrSlots[i]:setPosition(cc.p(self.argT.slotsPos.x + (i - 1) * self.argT.slotsIntervalX, self.argT.slotsPos.y))
		self.m_pBG:addChild(self.m_arrSlots[i])

		local frames = self.m_arrSlots[i]:GetFrames()

        -- 为每个滚动列存一列图标，这些图标在滚动列上位置不变，只是通过克隆m_arrIcon_T中的内容来改变外形。
        self.m_arrIcons = self.m_arrIcons or {}
        self.m_arrIcons2 = self.m_arrIcons2 or {}
		for j = 1, self.argT.ROW_NUM do
            self.m_arrIcons[i] = self.m_arrIcons[i] or {}
            self.m_arrIcons2[i] = self.m_arrIcons2[i] or {}
			self.m_arrIcons[i][j] = self.m_arrIcon_T[j]:clone()
			self.m_arrIcons2[i][j] = self.m_arrIcon_T[j]:clone()
			self.m_arrIcons[i][j]:setTag(j)
			self.m_arrIcons2[i][j]:setTag(j)
			self.m_arrIcons[i][j]:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_arrIcons2[i][j]:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_arrIcons[i][j]:setPosition(cc.p(self.argT.SLOT_WIDTH / 2, (j - 1) * self.argT.ICON_SPACE + self.argT.ICON_SPACE / 2))
			self.m_arrIcons2[i][j]:setPosition(cc.p(self.argT.SLOT_WIDTH / 2, (j - 1) * self.argT.ICON_SPACE + self.argT.ICON_SPACE / 2))
			frames[1]:addChild(self.m_arrIcons[i][j])
			frames[2]:addChild(self.m_arrIcons2[i][j])
		end

        -- 一些游戏滚动起来后会有列特效。
        if self.argT.runEff then
            self.m_arrRunningBG = self.m_arrRunningBG or {}
            self.m_arrRunningEff = self.m_arrRunningEff or {}
		    self.m_arrRunningBG[i] = self:seekChildByName(string.format("Image_RunBG%d", i - 1))
		    self.m_arrRunningEff[i] = self:seekChildByName(string.format("Image_RunEff%d", i - 1))
		    self.m_arrRunningEff[i]:getVirtualRenderer():getSprite():setBlendFunc({src = GL_SRC_ALPHA, dst = 1})
		    self.m_arrRunningBG[i]:setOpacity(0)
		    self.m_arrRunningEff[i]:setOpacity(0)
        end
    end

    -- 一些游戏会显示中了哪些线。
	for i = 1, self.argT.lines do
        self.m_arrLines = self.m_arrLines or {}
        if self.argT.createLines then
		    self.m_arrLines[i] = ccui.ImageView:create(string.format(self.argT.createLines.file, i))
		    self.m_arrLines[i]:setPosition(self.argT.createLines.pos);
            self.m_pBG:addChild(self.m_arrLines[i], 2)
        else
		    self.m_arrLines[i] = self:seekChildByName(string.format("Image_Line%d", i))
        end
        self.m_arrLines[i].y = self.m_arrLines[i]:getPositionY()
		self.m_arrLines[i]:setPositionY(10000)
        self.m_arrLines[i]:waitAndCall(0, function ()            
		    self.m_arrLines[i]:getVirtualRenderer():getSprite():setBlendFunc({src = GL_SRC_ALPHA, dst = 1})
		    self.m_arrLines[i]:setPositionY(self.m_arrLines[i].y)
		    self.m_arrLines[i]:setVisible(false)
        end)
    end
   
    -- 启动按钮。
	self.m_pStart = self:seekChildByName("Button_Start")
	self.m_pStart:addClickEventListener(function()
		self:ReqStart()
	end)

    -- 用来放置所有中奖效果的层。
	self.m_pEffectLayer = self:seekChildByName("Panel_EffectLayer")
	self.m_pEffectLayer:setTouchEnabled(false)
	self.m_pEffectLayer:setOpacity(0)

    -- 还剩多少次免费。
	self.m_pFreeTimes = self:seekChildByName("BitmapLabel_FreeTimes")
	if self.m_pFreeTimes then self.m_pFreeTimes:getParent():setVisible(false) end

    -- 我在名字和钱。
    self.m_MyName = self:seekChildByName("Label_MyName")
    self.m_MyMoney = self:seekChildByName("Label_MyMoney")
    if self.m_MyName then self.m_MyName:setString(dataManager.userInfo.nickname) end
    if self.m_MyMoney then self.m_MyMoney:setString(utils:moneyString(dataManager.userInfo.money, 2)) end
	
    -- 帮助按钮。
    self.btHelp = self:seekChildByName("btn_help")
    self.btHelp:setPosition(cc.pSub(cc.p(self.btHelp:getPosition()), cc.p(10, 12)))
    self.btHelp:loadTextures("gameCommonUI/GameCom/btn_bangzhu.png", "")
    self.btHelp:addClickEventListener(function()
        self.m_help:setVisible(true)
    end)

	self.Schedule = self:scheduleUpdateWithPriorityLua(function (deltaT)
		self:Update(deltaT)
	end, 1)

--    local kind = MsgCenter.gameKindID
--    App.gameData[kind] = App.gameData[kind] or {}
--    self.m_nCurMultiple = App.gameData[kind].m_nCurMultiple or self.m_nCurMultiple
--    self.m_bAutoRunning = App.gameData[kind].m_bAutoRunning

--    MsgCenter:SendGameOption()
end




-------------------------------------------------骨干----------------------------------------------------
function SlotsBase:FreeGameScene(data)
end

-- 请求启动，条件判断。
function SlotsBase:ReqStart()
	if (not self.m_bRunning) then
		if (self:CheckMoney4Run()) then
			local data = { lBetScore = self.argT.lines * self.m_nCurMultiple * self.m_llSingleBet }
	        self.core:sendGameMsg(self.argT.startCommand, data)
--			MsgCenter:SendDataToServerG(200, self.argT.startCommand, data, self.argT.startProtoName)
			self.m_pStart:setEnabled(false)
			self.m_pStart:waitAndCall(1.5, function()
				self.m_pStart:setEnabled(true)
			end)
		end
	end
end

-- 强制停止滚动。
function SlotsBase:Stop()
	local nStopNum = -1;
	for j = 1, self.argT.COL_NUM do
		self.m_arrSlots[j]:GetAcc():setTag(j);
		if (self.m_arrSlots[j]:GetAcc():IsMoving()) then
			if (nStopNum == -1) then
				nStopNum = j
            end
			self:LayOutIconByResult(j, self.m_GameData.m_Table[j][1], self.m_GameData.m_Table[j][2], self.m_GameData.m_Table[j][3]);
			self.m_arrSlots[j]:stopAllActions();
			self.m_arrSlots[j].m_pAcc:Stop();
--			self.m_arrSlots[j].m_pAcc:SetCurAngularVelo(600);
			self.m_arrSlots[j].m_pAcc:Start(-1, 0, 0, (j - nStopNum) * 0.2);
            if self.m_arrSlots[j].eff then
                self.m_arrSlots[j].eff:removeFromParent()
                self.m_arrSlots[j].eff = nil
            end
            if self.m_arrRunningBG then
			    self.m_arrRunningBG[j]:waitAndActions((j - nStopNum) * 0.2 - 0.5, cc.FadeOut:create(0.5))
			    self.m_arrRunningEff[j]:waitAndActions((j - nStopNum) * 0.2 - 0.5, cc.FadeOut:create(0.5))
            end
		end
	end
	self.m_bStopping = (nStopNum ~= -1)
--    SoundMng:stopAllEffects();
end

-- 将前三行换成期望的图标，滚动每次都停在前三行。
function SlotsBase:LayOutIconByResult(slot, icon_1, icon_2, icon_3)
	print(string.format("slot: %d, icon: %d %d %d", slot,  icon_1, icon_2, icon_3))
	self.SetImageTextureWithOther(self.m_arrIcons[slot][1], self.m_arrIcon_Tb[icon_1]);
	self.SetImageTextureWithOther(self.m_arrIcons[slot][2], self.m_arrIcon_Tb[icon_2]);
	self.SetImageTextureWithOther(self.m_arrIcons[slot][3], self.m_arrIcon_Tb[icon_3]);
	self.SetImageTextureWithOther(self.m_arrIcons2[slot][1], self.m_arrIcon_Tb[icon_1]);
	self.SetImageTextureWithOther(self.m_arrIcons2[slot][2], self.m_arrIcon_Tb[icon_2]);
	self.SetImageTextureWithOther(self.m_arrIcons2[slot][3], self.m_arrIcon_Tb[icon_3]);

	self.m_arrIcons[slot][1]:setTag(icon_1);
	self.m_arrIcons[slot][2]:setTag(icon_2);
	self.m_arrIcons[slot][3]:setTag(icon_3);
	self.m_arrIcons2[slot][1]:setTag(icon_1);
	self.m_arrIcons2[slot][2]:setTag(icon_2);
	self.m_arrIcons2[slot][3]:setTag(icon_3);
end

function SlotsBase:OnHLIcon(icon, col, row)
end

-- 滚动完毕后哪些图标中奖并需要播放特效闪烁等，哪些线需要显示。
function SlotsBase:HLIconByResult()
    for col, colT in ipairs(self.m_GameData.m_TableLight) do
	    for row, cell in ipairs(colT) do
            if cell == 1 then
                local ppIconSet = self:GetShowingFrame(col)
                local effects = self.argT.m_mpID2Name[ppIconSet[col][row]:getTag()]
                if effects then
                    if type(effects) ~= "table" then effects = {effects} end
		            ppIconSet[col][row].eff = {}
                    for i, v in ipairs(effects) do
		                local pAmt = utils.GetAmt(v)
		                local size = cc.size(ppIconSet[col][row]:getContentSize().width / 2, ppIconSet[col][row]:getContentSize().height / 2)
		                ppIconSet[col][row]:addChild(pAmt)
		                pAmt:setPosition(cc.pFromSize(size))
		                table.insert(ppIconSet[col][row].eff, pAmt)
                    end
		            ppIconSet[col][row]:setOpacity(0)
                end
                self:OnHLIcon(ppIconSet[col][row], col, row)
            end
        end
	end
    local bAtLeastOneLine = false
    if self.m_arrLines and self.m_GameData.line then
        if type(self.m_GameData.line) == "number" then
            if self.m_GameData.line ~= 0 then
    	        self.m_arrLines[self.m_GameData.line]:setVisible(true);
                bAtLeastOneLine = true
            end
        else
            for i, v in ipairs(self.m_GameData.line) do
    	        self.m_arrLines[i]:setVisible(v ~= 0);
                bAtLeastOneLine = bAtLeastOneLine or (v ~= 0)
            end
        end
    end
	if (self.argT.sounds.line and bAtLeastOneLine) then
		PLAY_SOUND(self.argT.sounds.line);
	end
	return false;
end

-- N个拉霸的游戏协议都不一样，这里对拉动后的返回协议做适配统一成一种格式
function SlotsBase:AdaptGameInfo()
    -- 下面是核心内容，实际内容是这个的超集
--    self.m_GameData = { m_Table = {},           -- 所有格子里的图标
--                        m_TableLight = {},      -- 哪些图标亮起来（中奖）
--                        line = {3, 4},          -- 中了那些线    （一些游戏可能没有）
--                        winScore = 10000,       -- 中了多少分
--                        userScore = 11111,      -- 本盘完了后玩家身上多少钱
--                        FreePullTime = 5,       -- 还剩几次免费 
--                        littleGameWin = 3333    -- 小游戏赢了多少（一些游戏可能没有）
--                       }
end

function SlotsBase:CalcRunningInfo()
    -- 这是输出格式
--    self.m_GameData.runInfo[1] = {  dur = 2, 
--                                    accMoment = 1,
--                                    soundTime = 0,
--                                    speedUP = true, 
--                                    accEff = "", 
--                                    accSound = "", 
--                                    stopSound = ""
--                                  }
end

-- 启动滚动，一并按上面函数的结果完成滚动特殊效果，比如模糊、加速、播放特殊音效等，还会扣除滚动需要的钱。
function SlotsBase:startRun(data)
    lastMoney = self.m_GameData.userScore
	self.m_GameData = data
    self:AdaptGameInfo()
    self:CalcRunningInfo()
	self:ClearAllEffects()

	for col, colT in ipairs(self.m_arrIcons) do
		for row, icon in ipairs(colT) do
			self.m_arrIcons[col][row]:stopAllActions()
			self.m_arrIcons2[col][row]:stopAllActions()
			self.m_arrIcons[col][row]:setPositionX(self.argT.SLOT_WIDTH / 2)
			self.m_arrIcons2[col][row]:setPositionX(self.argT.SLOT_WIDTH / 2)
			self.m_arrIcons[col][row]:setScale(1)
			self.m_arrIcons2[col][row]:setScale(1)
		end
	end

	for nCol = 1, self.argT.COL_NUM do
		local v2OrPosY = self.m_arrSlots[nCol]:getPositionY();
		self.m_arrSlots[nCol]:GetAcc():SetCurAngularVelo(self.argT.speed)
		self.m_arrSlots[nCol]:setVisible(true)
		self.m_arrSlots[nCol]:runAction(cc.Sequence:create(
        cc.CallFunc:create(function()
            local frames = self.m_arrSlots[nCol]:GetFrames()
	        frames = (frames[1]:getPositionY() == 0 and frames[1] or frames[2])
            frames:runAction(cc.Sequence:create(
                cc.MoveBy:create(0.2, cc.p(0, self.argT.easeBegin or 40)),                             -- 启动前的上下晃动
                cc.MoveTo:create(0.01, cc.p(frames:getPositionX(), 0))          -- 启动前的上下晃动
            ))
        end),
        cc.DelayTime:create(0.21),         -- 启动前的上下晃动等待
        cc.CallFunc:create(function()
			local fDur = self.m_GameData.runInfo[nCol].dur
			self.m_arrSlots[nCol]:Start(0, fDur)    -- 启动
            self.m_arrSlots[nCol]:setPositionY(v2OrPosY)   -- 晃动完毕立即回位
            if self.m_arrRunningBG then
    			self.m_arrRunningBG[nCol]:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(fDur - 0.5), cc.FadeOut:create(0.5), NULL))
	    		self.m_arrRunningEff[nCol]:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(fDur - 0.5), cc.FadeOut:create(0.5), NULL))
			end
            for i = 1, self.argT.ROW_NUM do
				-- 模糊一列
				self.SetImageTextureWithOther(self.m_arrIcons[nCol][i], self.m_arrIcon_Tb[self.m_arrIcons[nCol][i]:getTag()])
				self.SetImageTextureWithOther(self.m_arrIcons2[nCol][i], self.m_arrIcon_Tb[self.m_arrIcons2[nCol][i]:getTag()])
				self.m_arrIcons[nCol][i]:setScaleY(self.argT.iconScaleY)
				self.m_arrIcons2[nCol][i]:setScaleY(self.argT.iconScaleY)
			end
			self:LayOutIconByResult(nCol, self.m_GameData.m_Table[nCol][1], self.m_GameData.m_Table[nCol][2], self.m_GameData.m_Table[nCol][3])
		end),
        cc.DelayTime:create(self.m_GameData.runInfo[nCol].accMoment or 0),   -- 启动后等到加速的时刻到来
        cc.CallFunc:create(function()
            if self.m_GameData.runInfo[nCol].accMoment then
                local accDur = self.m_GameData.runInfo[nCol].dur - self.m_GameData.runInfo[nCol].accMoment
                if self.m_GameData.runInfo[nCol].speedUP then     -- 如果需要提升速度则修改速度后重启，否则只播放加速音
			        self.m_arrSlots[nCol]:GetAcc():Stop()
		            self.m_arrSlots[nCol]:GetAcc():SetCurAngularVelo(self.m_GameData.runInfo[nCol].speedUP)
			        self.m_arrSlots[nCol]:Start(0, accDur)
                end
                if self.m_GameData.runInfo[nCol].accEff then      -- 是否有加速特效
                    local eff = utils.GetAmt(self.m_GameData.runInfo[nCol].accEff)
                    eff:setPosition(cc.pAdd(cc.p(self.m_arrSlots[nCol]:getPosition()), cc.pMul(cc.pFromSize(self.m_arrSlots[nCol]:getContentSize()), 0.5)))
		            self.m_arrSlots[nCol]:getParent():addChild(eff)
		            self.m_arrSlots[nCol].eff = eff
                    eff:waitAndActions(accDur, cc.RemoveSelf:create())
                end

                self:OnColAcc(nCol)               		        
            end
        end),
        cc.DelayTime:create(self.m_GameData.runInfo[nCol].soundTime or 0),   -- 加速音是否有延迟
        cc.CallFunc:create(function()
            if self.m_GameData.runInfo[nCol].accMoment then
                PLAY_SOUND(self.argT.sounds["acc"..nCol])  -- 加速音
            end
            end)))
	end

	if ((self.m_nTimesLeft4Free or 0) == 0) then
        if self.m_pPlayers then 
            self.m_pPlayers:ActiveMe(true)
        end
--        dataManager.userInfo.money = dataManager.userInfo.money - self:RunOnceCost()
        if self.m_MyMoney then self.m_MyMoney:setString(utils:moneyString(lastMoney - self:RunOnceCost(), 2)) end
		if self.m_pPlayers then
            self.m_pPlayers:UpdatePlayers()
	    	self.m_pPlayers:ActiveMe(false)
		end
	end
    if self.argT.sounds.spin then
        STOP_ALL_SOUND()
		PLAY_SOUND(self.argT.sounds.spin)
    end

    if self.m_pIcome then self.m_pIcome:setString("0") end
	self.m_bRunning = true
end

-- 当某列停止滚动时。
function SlotsBase:SlotsStopped(i)
	if (i == self.argT.COL_NUM) then
	    self.m_bStopping = false;
        if self.argT.SUB_C_ROUND_OVER then
--    	    MsgCenter:SendDataToServerG(200, self.argT.SUB_C_ROUND_OVER);
	        self.core:sendGameMsg(self.argT.SUB_C_ROUND_OVER)
	    end

	    local fDuration = self:MakeResult();
	    if (fDuration ~= -1) then
		    self:runAction(cc.Sequence:create(cc.DelayTime:create(fDuration), cc.CallFunc:create(function()
		    self.m_bRunning = false
		    self:CheckAutoStart()
		    end)))
        end
	end
end

-- 滚动前要把上一轮界面上的特效全部清除，所有图标恢复正常样子。
function SlotsBase:ClearAllEffects()
	self.m_pEffectLayer:setVisible(false)
	self.m_pEffectLayer:removeAllChildren()
	self.m_bRunning = false

	for col = 1, self.argT.COL_NUM do
	    for row = 1, self.argT.ROW_NUM do
			self.m_arrIcons[col][row]:setVisible(true)
			self.m_arrIcons2[col][row]:setVisible(true)
			self.m_arrIcons[col][row]:setColor(cc.c3b(255, 255, 255))
			self.m_arrIcons2[col][row]:setColor(cc.c3b(255, 255, 255))
			self.m_arrIcons[col][row]:setOpacity(255)
			self.m_arrIcons2[col][row]:setOpacity(255)
			self.m_arrIcons[col][row]:removeAllChildren()
			self.m_arrIcons2[col][row]:removeAllChildren()
			self.m_arrIcons[col][row]:stopAllActions()
			self.m_arrIcons2[col][row]:stopAllActions()
			self.m_arrIcons[col][row].eff = nil
			self.m_arrIcons2[col][row].eff = nil
		end
        self.m_arrSlots[col].eff = nil
	end

	for i, v in ipairs(self.m_arrLines or {}) do
	    v:setVisible(false)
	    v:setOpacity(255)
    end
end

-- 滚动完毕后出奖，根据子类提供的分数等级划分来触发大小奖。
function SlotsBase:MakeResult()
	local llWinNum = self.m_GameData.winScore
	self:HLIconByResult()

    local fResultLast = 0

	if self.m_pFreeTimes then self.m_pFreeTimes:setString(string.format("%d", self.m_GameData.FreePullTime)) end
    if self.m_GameData.littleGameWin and self.m_GameData.littleGameWin > 0 then
        self:StartGame()
        return -1
    end

    if llWinNum > 0 then
	    self.m_pEffectLayer:setVisible(true);
        fResultLast = self:Win(llWinNum)
    end

    if self.m_nTimesLeft4Free then
        if self.m_GameData.FreePullTime and self.m_GameData.FreePullTime > self.m_nTimesLeft4Free then
            fResultLast = self:OnNewFreeTimes(fResultLast)
        elseif self.m_nTimesLeft4Free > 0 and self.m_GameData.FreePullTime == 0 then
            fResultLast = self:OnFreeTimesOver(fResultLast)
        end
        if self.m_nTimesLeft4Free > 0 then
            self.m_llWinFreeTurn = self.m_llWinFreeTurn + llWinNum
        end

	    self.m_nTimesLeft4Free = self.m_GameData.FreePullTime
    end
    dataManager.userInfo.money = self.m_GameData.userScore or dataManager.userInfo.money
    if self.m_MyMoney then self.m_MyMoney:setString(utils:moneyString(dataManager.userInfo.money, 2)) end
    if self.m_pPlayers then 
        self.m_pPlayers:ActiveMe(true)
    end

    return self:AfterMakeResult(fResultLast, llWinNum)
end

function SlotsBase:AfterMakeResult(fResultLast, llWinNum)
    return fResultLast
end

function SlotsBase:Update()
--    local kind = MsgCenter.gameKindID
--    if App.gameData[kind] then
--        App.gameData[kind].m_nCurMultiple = self.m_nCurMultiple or 1
--        App.gameData[kind].m_bAutoRunning = self.m_bAutoRunning
--    end
end

-- 一些游戏需要用到的滚动金币效果，比如火焰连击。
function SlotsBase:RollCoin(llNum, pParent, pTarget, offset, callfunc)
    offset = offset or cc.p(0, 0)
	local nCoinNum = 0;
	local llTmp = llNum;
	while (llTmp>0) do
		llTmp = math.floor(llTmp / 10)
		nCoinNum = nCoinNum + 1
	end
	nCoinNum = nCoinNum * 3;

	local pMoney = ccui.TextBMFont:create("", "LobbyResources/fonts/ziti_10_0.fnt");
	pMoney:setPosition(cc.pAdd(cc.p(677, 197), offset))
	pMoney:setScale(0.8)
	pMoney:setString(utils:moneyString(llNum));
	pParent:addChild(pMoney);
	for i = 0, nCoinNum do
		local pCoin = cc.Sprite:create();
		pParent:addChild(pCoin);
		pCoin:setPosition(cc.pAdd(cc.p(667, 367), offset))
		pCoin:setScale(1.2)
		pCoin:setVisible(false)
		local fLanMove = (math.random() - 0.5) * 100
		local v2Target = pTarget:getParent():convertToWorldSpace(cc.p(pTarget:getPosition()))
		v2Target = pParent:convertToNodeSpace(v2Target);
		pCoin:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
			pCoin:setTexture(string.format("gameCommonUI/coinFrames/roll/jinbi_0%d.png", pCoin:getTag() % 5));
			pCoin:setTag(pCoin:getTag() + 1);
		end), cc.DelayTime:create(0.05))));
		pCoin:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 * (i + math.random() - 0.5)), cc.Show:create(), cc.JumpBy:create(0.4, cc.p(fLanMove, -150), 10, 1),
			cc.MoveBy:create(0.5, cc.p(fLanMove * 2, 0)), cc.MoveTo:create(0.5, v2Target), cc.CallFunc:create(function()
			if (i == nCoinNum - 1) then
				pMoney:removeFromParent()
            end
			if (i == 0) then
				PLAY_SOUND("WHEEL_GETCOIN")
            end
		end), cc.RemoveSelf:create(), cc.CallFunc:create(
            function() 
                if callfunc and type(callfunc) == "function" then
                    callfunc()
                end
            end)))
	end
	utils.numberGO(pMoney, 0, llNum, 1, function(l)
		pMoney:setString(utils:moneyString(l));
	end);
	PLAY_SOUND("SLOTFIRE_WINBG");
	return nCoinNum * 0.1;
end



-------------------------------------------------工具函数----------------------------------------------------
function SlotsBase:RunOnceCost()
    return self.argT.lines * self.m_nCurMultiple * self.m_llSingleBet
end

-- 检查是否有条件滚动。
function SlotsBase:CheckMoney4Run()
	if (self.m_nTimesLeft4Free == 0 and self:RunOnceCost() > dataManager.userInfo.money) then
        toastLayer:show("金钱不足!")
--		App.showFadeOnTop(App.stringsDic.System_Tips_goldmb, "")
        return false
    end
    return true
end

-- 检查是否需要自动启动滚动。
function SlotsBase:CheckAutoStart()
	if ((self.m_bAutoRunning or (self.m_nTimesLeft4Free or 0) > 0) and not self.m_bRunning) then
        if not self:CheckMoney4Run() then
			self.m_bAutoRunning = false
			if (self.m_nTimesLeft4Free == 0) then
				return
            end
        end
		self:ReqStart()
	end
end

function SlotsBase:GetShowingFrame(col)
    local ppIconSet = self.m_arrSlots[col]:GetFrames()
	return (ppIconSet[1]:getPositionY() == 0 and self.m_arrIcons or self.m_arrIcons2)
end


-------------------------------------------------事件----------------------------------------------------
function SlotsBase:StartGame()
end

function SlotsBase:OnNewFreeTimes(fResultLast)
    return fResultLast
end

function SlotsBase:OnFreeTimesOver(fResultLast)
    return fResultLast
end

function SlotsBase:OnColAcc(col)
end

function SlotsBase:Win(llWinNum)
	local nWinLv = self:GetWinType(llWinNum)
	if (nWinLv > 1) then
		return self:BigWin(llWinNum, nWinLv)
    else
        return self:LittleWin(llWinNum, nWinLv)
	end
end

-- 按中奖数额划分中奖等级。
function SlotsBase:GetWinType(num)
end

-- 小奖。
function SlotsBase:LittleWin(num)
    return 0
end

-- 大奖，内部可以按lv自己再划分。
function SlotsBase:BigWin(num, lv)
    return 0
end

-- 有些游戏中奖后需要播放头像特效。
function SlotsBase:PlayIconEffect(pIcon, lv, num)
    local PlayerIconList = require("app.widgets.PlayerIconList")
    PlayerIconList.PlayIconEffect(pIcon, lv, num)
end

-- 将某个按钮处理为长按触发某件事的功能clickCallBack为点击回调，longPushCallBack为长按回调， eff为长按过程要播放的效果。
function SlotsBase:MakeLongPushButton(btn, clickCallBack, longPushCallBack, eff)
	btn:addClickEventListener(function()end)
	btn:addTouchEventListener(function(_, event_type_)
        local stop = function() 
            if btn.eff then btn.eff:removeFromParent() btn.eff = nil end
            if btn.act then btn:stopAction(btn.act); btn.act = nil end
        end

		if event_type_ == cc.EventCode.BEGAN then
			PLAY_SOUND("SISTER_PLAY_BTN");
			btn.m_fPushStartMonment = 0;
            local check = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                if btn.m_fPushStartMonment + 0.1 >= 0.5 and btn.m_fPushStartMonment <= 0.5 then
				    local partical = cc.ParticleSystemQuad:create(eff);
				    partical:setPosition(btn:getAnchorPointInPoints());
				    btn:addChild(partical, 1);
				    btn.eff = partical;
                end
                btn.m_fPushStartMonment = btn.m_fPushStartMonment + 0.1
                print(btn.m_fPushStartMonment)
                if btn.m_fPushStartMonment > 1 then
                    stop()
                    longPushCallBack()
                end
            end)))
            btn.act = check
			btn:runAction(check);
		elseif event_type_ == cc.EventCode.ENDED then
            clickCallBack()
            stop()
		elseif event_type_ == cc.EventCode.CANCELED then
            stop()
		end
	end);
end


-----------------------------------------------网络消息--------------------------------------------------





return SlotsBase

--endregion
