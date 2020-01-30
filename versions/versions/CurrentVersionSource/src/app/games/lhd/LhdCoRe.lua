local C = class("LhdCore", GameCoreBase)
require("app.games.lhd.LhdToastLayer")
if LhdShowTips then
	LhdShowTips:release()
end
LhdShowTips = LhdToastLayer.new()
LhdShowTips:retain()
-- 模块路径
C.MODULE_PATH = "app.games.lhd"
-- 场景配置
C.SCENE_CONFIG = { scenename = "LhdScene", filename = "LhdScene", logic = "LhdLogic", define = "LhdDefine", model = "LhdModel" }

local tipsBG = GAME_LHD_IMAGES_RES.."game/tishitiao_bg.png";

function C:start()
    self:registerGameMsg(LHD.CMD.SC_LHD_CONFIG_P, handler(self, self.onConfigs));               --配置
    self:registerGameMsg(LHD.CMD.SC_LHD_GAMESTATE_P, handler(self, self.onGameStatus));         --游戏状态
    self:registerGameMsg(LHD.CMD.SC_LHD_FIRST_P, handler(self, self.onFirstPokers));            --发牌动画
    self:registerGameMsg(LHD.CMD.SC_LHD_OPTTIME_P, handler(self, self.onOperateTime));          --下注亮牌操作时间
    self:registerGameMsg(LHD.CMD.SC_LHD_BUYHORSE_P, handler(self, self.onTablePlayerBet));      --玩家下注
    self:registerGameMsg(LHD.CMD.SC_LHD_ZHUANG_LIST_P, handler(self, self.onBankerList));       --上庄列表
    self:registerGameMsg(LHD.CMD.SC_LHD_ZHUANG_INFO_P, handler(self, self.onBankerInfo));       --庄家信息
    self:registerGameMsg(LHD.CMD.SC_LHD_NO_ZHUANG_P, handler(self, self.onNoBanker));           --下庄公告
    self:registerGameMsg(LHD.CMD.SC_LHD_NOTICE_NO_ZHUANG_P, handler(self, self.onCanOffBanker));--通知玩家可以主动下庄
    self:registerGameMsg(LHD.CMD.SC_LHD_SHOWCARD_P, handler(self, self.onShowPokers));          --亮牌
    self:registerGameMsg(LHD.CMD.SC_LHD_SETTLEMENT_P, handler(self, self.onResult));            --游戏结算
    self:registerGameMsg(LHD.CMD.SC_LHD_OPER_ERROR_P, handler(self, self.onError));             --错误消息
    self:registerGameMsg(LHD.CMD.SC_LHD_HISTORY_P, handler(self, self.onHistory));              --历史记录
    self:registerGameMsg(LHD.CMD.SC_LHD_FOLLOW_BUY_P, handler(self, self.onFollowBet));         --续押
    self:registerGameMsg(LHD.CMD.SC_LHD_ALLLIST_P, handler(self, self.onAllPlayerList));        --玩家列表
    --self:registerGameMsg(LHD.CMD.SC_LHD_BETINFO, handler(self, self.onUserBetInfo));          --下注信息
    self:registerGameMsg(LHD.CMD.SC_LHD_SYNC_BET, handler(self, self.onPlayerBet));
    C.super.start(self)
end

function C:exit()
    --self:unregisterGameMsg(LHD.CMD.SC_CONFIG_P)
    C.super.exit(self)
end

-- 进入房间，房间信息
function C:onRoomInfo(info)
    --dump(info, "进入房间：");
    dump(info.playerlist, "玩家：");
    --dump(self.model.myInfo, "自己的信息：");
    C.super.onRoomInfo(self, info)
    if self.scene then
        self.scene:onSaveUserInfo(info.playerlist);
    end
end

-- 玩家加入
function C:onPlayerEnter(info)
    dump(info, "玩家加入：");
    C.super.onPlayerEnter(self, info)
    if self.scene then
        self.scene:onUserEnter(info);
        --self:requestAllPlayerList();
    end
   -- self.model:addPlayer(info)
end

-- 玩家离开
function C:onPlayerQuit(info)
    dump(info, "玩家离开：");
    C.super.onPlayerQuit(self, info)
    if self.scene then
        self.scene:onUserLeave(info);
        --self:requestAllPlayerList();
    end
    --self.model:removePlayer(info["playerid"])
end

function C:onQuitGame(info)
    dump(info, "被踢出房间：");
    if SCENE_NAME ~= "Hall" then
        --local reason = info.sxreason;
		--if reason == 8 then
        if self.scene then
            if self.model.NotBetCount then
			    self.scene:messageBox("您已经"..self.model.NotBetCount.."局没有参与游戏，感谢关注", function()
				    self:quitGame();
			    end, true);
		    else
			    self.scene:messageBox("您已被踢出房间", function()
				    self:quitGame();
			    end, true);
		    end
        end
        --self.scene:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
        --    self:quitGame();
        --end)));
    end
end

-- 断线重连
function C:onToOtherRoom(info)
    dump(info, "断线重连：");
    C.super.onToOtherRoom(self, info)
    if not self.scene then
        return;
    end
    if info and info.config and info.config.Bet then
        self.scene.SELECT_CONFIG = info.config.Bet;
        self.model.BET_TIME = info.config.TimeLimit.BuyHorse;
        self.model.betNeed = info.config.BetNeed;
        self.scene:offLineToOnline(info)
    else
        print("断线重连可下注配置为空");
        dump(info.config.Bet, "下注配置: ");
    end
    if info.nextat then
        self.model.BET_TIME = info.nextat - 2;
        self.scene:betTimeOut();
    end
    --庄家
    if info and info.config then
        self.model.bankerMaxTurn = info.config.Zhuang and info.config.Zhuang.MaxTurn or nil;
        self.model.bankerMinTurn = info.config.Zhuang and info.config.Zhuang.MinTurn or nil;
        self.model.bankerNeed = info.config.Zhuang and info.config.Zhuang.Need or nil;
        --print("self.model.bankerNeed 庄家需要：", self.model.bankerNeed, info.config.Zhuang.Need);
    end

    local msg = {};
    msg.zhuangheadid = info.zhuangdata.zhuangheadid;
    msg.zhuangid = info.zhuangdata.zhuangid;
    msg.zhuangturn = info.zhuangdata.zhuangturn;
    msg.chouma = info.zhuangdata.rchouma;
    msg.zhuangname = info.zhuangdata.zhuangname;
    msg.list = info.zhuangdata.zhuanglist;
    self.scene:onUpdateBankerInfo(msg, true);
    if info.zhuangdata.zhuanglist then
        self.scene:onUpdateBankerList(msg);
    end
    if info.data then
        self.scene:onUpdateHistoryIcon(info.data);
        self.scene:updateTrendData(info.data);
    end
    self.scene.gameState = info.state;
    if info.state == LHD.LHD_GameState.LHD_GameState_BuyHorse then
        self.scene:sendCard();
        LhdShowTips:show("当前正在下注", nil, tipsBG);
    elseif info.state == LHD.LHD_GameState.LHD_GameState_Combine then
        self.scene:playWaitAct();
    elseif info.state == LHD.LHD_GameState.LHD_GameState_End then
        self.scene:hideWaitAct();
        self.scene:playWaitAct();
        self.scene:onSleep();
    end
end

-- time:1
function C:handleOnToOtherRoomStatusNone(info)
    --if self.model.myInfo["money"] < self.model.betNeed then
    --    self.scene:showBetNeedTips()
    --end
end

-- time:2
function C:handleOnToOtherRoomStatusStart(info)

end

-- time:12
function C:handleOnToOtherRoomStatusBet(info)
    
end

-- time:7
function C:handleOnToOtherRoomStatusCompare(info)
    
end

-- time:8
function C:handleOnToOtherRoomStatusResult(info)
    -- 金币不足
    --if self.model.myInfo["money"] < self.model.betNeed then
    --    self.scene:showBetNeedTips()
    --end
    --self.scene:showWaitting()
end

function C:onOperateTime(info)
    dump(info, "onOperateTime: ");
end

-- 房间状态
function C:onRoomState(info)
    C.super.onRoomState(self, info)
end

-- 更新玩家金币
function C:updatePlayerMoney(info)
    dump(info, "充值成功更新玩家金币：");
    C.super.updatePlayerMoney(self, info)
    if not self.scene then
        return;
    end
	if info.playerid == self.model.myInfo.playerid then
		self.scene:updateMyScore(info.coin)
	else
		self.scene:updateOtherScore(info.playerid,info.coin)
	end
	--TODO 这里更新下注按钮状态
	self.scene:updateUserScore(info);
end

-- 配置信息
function C:onConfigs(info)
    dump(info, "获取游戏配置：");
    if not self.scene then
        return;
    end
    -- 下注按钮面值
    if info.Bet then
        --self.model.BET_CONFIGS = utils:copyTable(info["Bet"])
        self.scene.SELECT_CONFIG = info.Bet;
        --self.scene.selectScore = self.scene.SELECT_CONFIG[3];
        dump(self.scene.SELECT_CONFIG, "保存下注：");
    end
    --赔率
    if info.Odds then
        self.model.TYPE_BEI_CONFIGS = utils:copyTable(info["Odds"])
    end
    -- 下注时间
    self.model.BET_TIME = info["TimeLimit"]["BuyHorse"]
    -- 上庄条件
    if info["Zhuang"] and self.model.roomInfo.orderid and info["Zhuang"][self.model.roomInfo.orderid] then
        local temp = info["Zhuang"][self.model.roomInfo.orderid]
        self.model.bankerMaxTurn = temp.MaxTurn
        self.model.bankerMinTurn = temp.MinTurn
        self.model.bankerNeed = temp.Need
        --self.scene:setUpBankerNeedMoney(self.model.bankerNeed)
    end
    -- 下注需要金币
    self.model.betNeed = info.BetNeed;
    -- 更新下注按钮
    --self.scene:updateChipBtnText()
end

-- 游戏状态
function C:onGameStatus(info)
    dump(info, "游戏状态：");
    if not self.scene then
        return;
    end
    self.scene.gameState = info.state;
    if info.state == LHD.LHD_GameState.LHD_GameState_None then          --无状态
        print("\n\n\n没有状态============================\n\n\n");
    elseif info.state == LHD.LHD_GameState.LHD_GameState_BuyHorse then  --下注状态
        self.scene:onStartBet();
    elseif info.state == LHD.LHD_GameState.LHD_GameState_Combine then   --亮牌状态
        self.scene:onStopBet();
    elseif info.state == LHD.LHD_GameState.LHD_GameState_End then       --结算状态
        print("\n\n\n游戏休息============================\n\n\n");
        self.scene:onSleep();
    elseif info.state == 4 then
        print("\n\n\n状态4不知道什么状态============================\n\n\n");
    end
end

-- 开局相关信息
function C:onBeginInfo(info)
    print("开局相关信息---------------");
    -- --dump(info,"onBeginInfo",10)
end

--下注信息（断线重连恢复场景用）
function C:onUserBetInfo(info)
    dump(info, "断线重连下注信息：");
    if not self.scene then
        return;
    end
    self.scene:restoreScene(info);
end

-- 发牌动画 1:east 2:south 3:west 4:north banker:zhuang
function C:onFirstPokers(info)
    -- dump(info,"onFirstPokers",10)
    print("发牌动画---------------");
    dump(info, "发牌动画：");
    --self.scene:onSendPoker();
end

--玩家下注
function C:onPlayerBet(info)
    print("玩家下注---------------");
    --dump(info, "其他玩家下注：")
    --self.scene:onUserBet(info);
end

-- 在桌玩家下注
function C:onTablePlayerBet(info)
    --dump(info,"在桌玩家下注")
    if not self.scene then
        return;
    end
    self.scene:onDeskUserBetMsg(info);
end

-- 玩家续押
function C:onFollowBet(info)
    dump(info, "玩家续押")
    print("玩家续押---------------");
end

-- 在线玩家下注
function C:onOnlinePlayerBet(info)
     dump(info,"在线玩家下注")
    print("在线玩家下注---------------");
end

-- 上庄列表(主动下发)
function C:onBankerList(info)
    --dump(info, "上庄列表：");
    if not self.scene then
        return;
    end
    self.scene:onUpdateBankerList(info);
end

-- 当前庄家信息(主动下发)
function C:onBankerInfo(info)
    dump(info, "当前庄家信息：")
    -- dump(info,"onBankerInfo",10)
    if not self.scene then
        return;
    end
    self.scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function()
        self.scene:onUpdateBankerInfo(info);
    end)));
end

-- 玩家下庄
function C:onNoBanker(info)
    dump(info, "玩家下庄：");
    --self.scene:onUserCancelBanker(info);
end

-- 玩家可以下庄
function C:onCanOffBanker(info)
    dump(info, "玩家可以下庄：");
    if info["round"] then
        LhdShowTips:show("您可以在" .. tostring(info["round"]) .. "局后下庄", nil, tipsBG)
    end
end

-- 开牌
function C:onShowPokers(info)
    dump(info, "亮牌：");
    if not self.scene then
        return;
    end
    self.scene:onLookCard(info);
    -- dump(info,"onShowPokers",10)
    --self.scene:openPokers(info)
end

-- 错误提示消息
function C:onError(info)
    dump(info, "onError")
    ----[[
    local code = info.code;
    if code == LHD.GAME_ERROR.GAME_ERROR_NOT_MONEY then
        LhdShowTips:show("每轮下注不能超过自身金币的1/3", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_BUY_LIMIT then
        LhdShowTips:show("当前下注已达上限", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_NOT_ROUND then
        LhdShowTips:show("坐庄轮次不足 不能下庄", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_OZ_STATE then
        LhdShowTips:show("当前游戏状态不能下庄", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_ZHUANG_NO_MONEY then
        local text = utils:moneyString(self.model.bankerNeed).."元余额才可上庄，请充值"
        LhdShowTips:show(text, nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_NEXT_ROUND then
        LhdShowTips:show("您将在下一局下庄", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_OFFZHUANG_WUNIU then
        LhdShowTips:show("当前下注已达上限", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_APPLYZHUANG_OK then
        LhdShowTips:show("申请上庄成功，已加入上庄列表", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_NOT_MONEY_TO_BET then
        self.model.betMoneyValue = info.value;
        local text = "金币大于" .. utils:moneyString(info.value) .. "元才可以下注，请充值"
        LhdShowTips:show(text, nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_FOLLOW_TO_BET then
        LhdShowTips:show("续投失败,没有投注记录", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_FOLLOW_LIMIT then
        LhdShowTips:show("金币不足，续投失败", nil, tipsBG)
    elseif code == LHD.GAME_ERROR.GAME_ERROR_SLIENTCE_TOMANNY then      --10局没下注踢出房间
        self.model.NotBetCount = info.value;
        print("10局没有下注=====================");
        --LhdShowTips:show("您已"..info.value.."局没有参与游戏，感谢关注", nil, tipsBG)
    end
    --]]
end

-- 奖池信息
function C:onJackpotInfo(info)
    -- --dump(info,"onJackpotInfo",10)
    if not self.scene then
        return;
    end
    if info["data"] then
        self.scene:reloadRewardPlayerList(info["data"])
    end
end

-- 走势图返回
function C:onHistory(info)
    dump(info, "历史记录:");
    if not self.scene then
        return;
    end
    if info["data"] then
        self.scene:updateTrendData(info.data);
        self.scene:onUpdateHistoryIcon(info.data);
        self.scene:initTrendData(info);
        self.model.lastRefreshHistoryTime = os.time()
    end
end

function C:onClearBetInfo(info)
    -- dump(info,"onClearBetInfo",10)
    if not self.scene then
        return;
    end
    if info["playerid"] == self.model.myInfo["playerid"] then
        self.model.lastHadBet = false
        self.scene:setXuyaBtnEnabled(false)
    end
end

-- (未处理)
function C:onNoticeBankerList(info)
    -- dump(info,"onNoticeBankerList",10)
end

-- 在桌玩家列表(主动下发)
function C:onTablePlayerList(info)
    -- --dump(info,"onTablePlayerList",10)
    --print("在桌玩家列表(主动下发)");
    --self.model.tablePlayerList = info["playerlist"]
    --self.scene:showTablePlayerList(self.model.tablePlayerList)
end

-- 玩家列表(请求下发)
function C:onAllPlayerList(info)
    dump(info, "玩家列表：");
    if not self.scene then
        return;
    end
    self.scene:onUpdateUserData(info);
    self.scene:initPlayerListData(info)
end

-- 结算消息
function C:onResult(info)
    dump(info, "游戏结算：");
    if not self.scene then
        return;
    end
    self.scene:onGameResult(info);
    -- dump(info,"onResult",10)
    --[[self.scene:doResult(info)
    -- 每30分钟刷新走势图数据
    local nowTime = os.time()
    if nowTime - self.model.lastRefreshHistoryTime >= 30 * 60 then
        -- 奖池信息
        self:requestJackpotInfo()
        -- 走势图
        self:requestHistory()
    end
    --]]
end

-- 发送协议
-- 下注
function C:sendBet(area, money)
    local info = { }
    info["odds"] = money
    info["direction"] = area
    self:sendGameMsg(LHD.CMD.CS_LHD_BUYHORSE_P, info)
end

-- 请求申请上庄列表(没看到请求)
function C:requestBankerList()
    self:sendGameMsg(LHD.CMD.CS_LHD_REQUEST_ZHUANG_LIST_P)
end

-- 申请上庄
function C:applyOnBanker()
    self:sendGameMsg(LHD.CMD.CS_LHD_REQUEST_ZHUANG_P)
end

-- 取消申请上庄
function C:cancelApplyOnBanker()
    self:sendGameMsg(LHD.CMD.CS_LHD_REQUEST_NOT_ZHUANG_P)
end

--自己在庄上申请下庄
function C:offBanker()
    self:sendGameMsg(LHD.CMD.CS_LHD_ZHUANG_OFF_P);
end

-- 申请下注(当前自己是庄家)
function C:applyOffBanker()
    --self:sendGameMsg(LHD.CMD.CS_ZHUANG_OFF_P)
end

-- 请求走势
function C:requestHistory()
    --self:sendGameMsg(LHD.CMD.CS_HISTORY_P)
end

-- 清除下注(停用)
function C:clearBetHistory(info)
    --self:sendGameMsg(LHD.CMD.CS_CLEAR_BUY_P, info)
end

-- 续押
function C:followHistoryBet()
    --self:sendGameMsg(LHD.CMD.CS_FOLLOW_BUY_P)
end

-- 请求奖池信息
function C:requestJackpotInfo()
    --self:sendGameMsg(LHD.CMD.CS_COLOR_POOL_P)
end

-- 请求在桌玩家(不用请求，服务器主动下发)
function C:requestTablePlayerList()
    --self:sendGameMsg(LHD.CMD.CS_RANKLIST_P)
end

-- 请求玩家列表
function C:requestAllPlayerList()
    ---local info = { }
    ---info["page"] = page
    print("请求玩家列表：", LHD.CMD.CS_LHD_ALLLIST_P);
    self:sendGameMsg(LHD.CMD.CS_LHD_ALLLIST_P)
end

-- 请求状态时间配置(断线重新正在下注阶段请求)
function C:requestStatusTime()
    --self:sendGameMsg(LHD.CMD.CS_TIME_P)
end

--请求历史记录
function C:requestHistory()
    self:sendGameMsg(LHD.CMD.CS_LHD_HISTORY_P);
end

return C