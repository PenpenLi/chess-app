local C = class("ZjhCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.zjh"
--场景配置
C.SCENE_CONFIG = {scenename = "zjh_scene", filename = "ZjhScene", logic="ZjhLogic", define="ZjhDefine", model="ZjhModel"}

function C:start()
    self:registerGameMsg(ZJH.CMD.SC_PLAYER_STATE_P,handler(self,self.onGamePlayerState))
    self:registerGameMsg(ZJH.CMD.SC_BANKER_P,handler(self,self.onBanker))
    self:registerGameMsg(ZJH.CMD.SC_BET_P,handler(self,self.onBet))
    self:registerGameMsg(ZJH.CMD.SC_DEAL_P,handler(self,self.onSendCard))
    self:registerGameMsg(ZJH.CMD.SC_WAIT_OPT_P,handler(self,self.onWaitOpt))
    self:registerGameMsg(ZJH.CMD.SC_FOLD_P,handler(self,self.onFold))
    self:registerGameMsg(ZJH.CMD.SC_CHECK_P,handler(self,self.onCheck))
    self:registerGameMsg(ZJH.CMD.SC_CHECK_SELF_P,handler(self,self.onCheckSelf))
    self:registerGameMsg(ZJH.CMD.SC_COMPETITION_P,handler(self,self.onCompare))
    self:registerGameMsg(ZJH.CMD.SC_SHOW_CARD_PACK_P,handler(self,self.onShowCard))
    self:registerGameMsg(ZJH.CMD.SC_SYS_SHOW_CARD,handler(self,self.onSystemShowCard))
    self:registerGameMsg(ZJH.CMD.SC_TURN_P,handler(self,self.onTurn))
    self:registerGameMsg(ZJH.CMD.SC_STATE_P,handler(self,self.onGameState))
    self:registerGameMsg(ZJH.CMD.SC_READY_P,handler(self,self.onReady))
    C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(ZJH.CMD.SC_PLAYER_STATE_P)
    self:unregisterGameMsg(ZJH.CMD.SC_BANKER_P)
    self:unregisterGameMsg(ZJH.CMD.SC_BET_P)
    self:unregisterGameMsg(ZJH.CMD.SC_DEAL_P)
    self:unregisterGameMsg(ZJH.CMD.SC_WAIT_OPT_P)
    self:unregisterGameMsg(ZJH.CMD.SC_FOLD_P)
    self:unregisterGameMsg(ZJH.CMD.SC_CHECK_P)
    self:unregisterGameMsg(ZJH.CMD.SC_CHECK_SELF_P)
    self:unregisterGameMsg(ZJH.CMD.SC_COMPETITION_P)
    self:unregisterGameMsg(ZJH.CMD.SC_SHOW_CARD_PACK_P)
    self:unregisterGameMsg(ZJH.CMD.SC_TURN_P)
    self:unregisterGameMsg(ZJH.CMD.SC_STATE_P)
    self:unregisterGameMsg(ZJH.CMD.SC_READY_P)
	C.super.exit(self)
end

--子游戏公共协议
--收到开始匹配
function C:onStartMatch( info )
	C.super.onStartMatch(self,info)
    dump(info,"onStartMatch")
    self.model.isGaming = false
    self.scene:hideOtherPlayers()
    self.scene:cleanDesktop()
    self.scene:showMatchLayer()
end

--收到匹配结束
function onFinishMatch( info )
	C.super.onFinishMatch(self,info)
    dump(info,"onFinishMatch")
    self.scene:hideOtherPlayers()
    self.scene:cleanDesktop()
    self.scene:hideMatchLayer()
end

--玩家加入
function C:onPlayerEnter( info )
    C.super.onPlayerEnter(self,info)
    dump(info,"onPlayerEnter")
    if self.model.playerlist then
        table.insert(self.model.playerlist,info)
    end
    local localSeatId = self.scene:getLocalSeatId(info["seat"])
    self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.NONE
    self.scene:showPlayer(info)
end

--玩家离开
function C:onPlayerQuit( info )
    C.super.onPlayerQuit(self,info)
    --不再退出
    dump(info,"onPlayerQuit")
    local playerId = info["playerid"]
    if playerId ~= dataManager.userInfo["playerid"] then
        self.scene:setPlayerSpeakById(playerId,7)
    end
end

--游戏结束,你条件不满足被踢出房间,如果你在暂离状态,也会被踢出房间
function C:onDeletePlayer( info )
    C.super.onDeletePlayer(self,info)
    self.model.isKicked = true
end

--金币不足，服务器发同意退出，父类收到直接退出，这里需要弹窗，玩家点确定才退出
function C:onQuitGame( info )
    --什么都不做
end

--玩家状态
function C:onPlayerState( info )
    C.super.onPlayerState(self,info)
    --什么都不做
end

--更新玩家金币
function C:updatePlayerMoney( info )
    C.super.updatePlayerMoney(self,info)
    local playerId = info["playerid"]
    local blance = info["coin"]
    self.scene:setPlayerBlanceByPlayerId(playerId,blance)
end

--进入房间，房间信息
function C:onRoomInfo( info )
    C.super.onRoomInfo(self,info)
    dump(info,"onRoomInfo")
    --设置model
    self.model:reset()
    self.model.difen = info["difen"] or 0
    self.model.inmoney = info["inmoney"] or 0
    local playerlist = info["playerlist"]
    self.model.playerlist = playerlist or {}
    for k,v in pairs(playerlist) do
        if v["playerid"] == dataManager.userInfo["playerid"] then
            self.model.mySeatId = v["seat"]
            break
        end
    end
    --设置页面
    self.scene:cleanDesktop()
    self.scene:cleanPlayers()
    self.scene:hideMatchLayer()
    self.scene:setDizhu(self.model.difen)
    self.scene:setZongzhu(0)
    self.scene:hideOtherPlayers()
    dump(playerlist,"playerlist")
    for k,v in pairs(playerlist) do
        self.scene:showPlayer(v)
    end
end

--房间状态
function C:onRoomState( info )
    C.super.onRoomState(self,info)
    --什么都不做
end

--断线重连
function C:onToOtherRoom( info )
    C.super.onToOtherRoom(self,info)
    dump(info,"onToOtherRoom")
    self.scene:cleanDesktop()
    --设置model
    self.model.zhuangLocalSeatId = self.scene:getLocalSeatId(info["banker"])
    self.model.currentSingleChip = info["betcurrent"]
    self.model.currentTotalChips = info["bottom"]
    self.model.isAuto = info["follow"] == 1
    self.model.currentRound = info["nturn"]
    self.model.currentOptLocalSeatId = self.scene:getLocalSeatId(info["optseat"])
    self.model.currentOptLeftTime = info["timer"]
    if self.model.currentOptLocalSeatId == 1 then
        self.model.turnToMe = true
        if info["opt"] then
            self.model:updateOptConfigs(info["opt"])
        end
    end
    local playerlist = info["player"]
    --设置页面
    self.scene:showBankerImg()
    self.scene:setZongzhu(self.model.currentTotalChips)
    self.scene:createDesktopChips()
    if info["state"] == ZJH.GAME_STATUS.PLAYING then
        self.scene:showPlayerTimer(self.model.currentOptLocalSeatId,self.model.currentOptLeftTime)
    end
    for i,v in ipairs(playerlist) do
        local localSeatId = self.scene:getLocalSeatId(v["seatid"])
        local isPlaying = v["play"] == 1
        if isPlaying then
            self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.NOT_LOOKED
            if localSeatId == 1 then
                self.model.isGaming = true
            end
            self.scene:sendPlayerPokerImm(localSeatId)
            self.scene:setPlayerChips(localSeatId,v["hasbet"])
            if v["ischeck"] == 1 then
                self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.HAD_LOOKED
                self.scene:setPlayerStatus(localSeatId,1)
                if localSeatId == 1 and info["cards"] then
                    self.scene:showPlayerPoker(localSeatId,info["cards"],false)
                end
            elseif v["bipai"] == 1 then
                self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.TAOTAI
                self.scene:setPlayerStatus(localSeatId,2)
                self.scene:hidePlayerTimer(localSeatId)
                if localSeatId == 1 then
                    self.model.isGaming = false
                end
            elseif v["fold"] == 1 then
                self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.QIPAI
                self.scene:setPlayerStatus(localSeatId,3)
                self.scene:hidePlayerTimer(localSeatId)
                if localSeatId == 1 then
                    self.model.isGaming = false
                end
            end
        else
            if localSeatId == 1 then
                self.model.isGaming = false
                self.scene:showWaitNext()
            end
            self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.NONE
        end
    end
    self.scene:updateOperationBtns()
end

--结算
function C:onSettlement( info )
    C.super.onSettlement(self,info)
    dump(info,"炸金花结算",10)
    --改了玩法之后服务器下发两次结算，第二次下是因为销毁房间触发的
    if info["jiesuan"] == nil or info["jiesuan"]["paiju"] == nil then
        return
    end
    self.model.currentGameState = self.define.GAMESTATE_JIESUAN
    self.model.isGaming = false
    self.model.isAuto = false
    self.model.turnToMe = false
    self.model.currentOptConfigs = {}
    self.scene:updateBattery()
    self.scene:hideAllPlayerTimer()
    self.scene:updateOperationBtns()
    --模拟测试
    -- local allcards={}
    -- allcards[1]={}
    -- allcards[1].seat=1
    -- allcards[1].cards={
    --    [1]= {color=6,number=3},
    --    [2]= {color=4,number=7},
    --    [3]= {color=6,number=13}
    -- }
    -- allcards[2]={}
    -- allcards[2].seat=2
    -- allcards[2].cards={
    --    [1]= {color=3,number=2},
    --    [2]= {color=4,number=3},
    --    [3]= {color=5,number=14}
    -- }
    -- allcards[3]={}
    -- allcards[3].seat=3
    -- allcards[3].cards={
    --    [1]= {color=3,number=3},
    --    [2]= {color=6,number=7},
    --    [3]= {color=3,number=11}
    -- }
    -- allcards[4]={}
    -- allcards[4].seat=4
    -- allcards[4].cards={
    --    [1]= {color=3,number=6},
    --    [2]= {color=5,number=9},
    --    [3]= {color=3,number=12}
    -- }
    -- info.jiesuan.allcard=allcards
    self.scene:doSettlement(info)
end

--子游戏协议
--玩家状态改变 state: 0=无效 1=游戏 2=弃牌 3=旁观
function C:onGamePlayerState( info )
    dump(info,"onGamePlayerState")
    --什么都不做
end

--游戏状态 state: 0=准备阶段 1=游戏开始 2=游戏结束
function C:onGameState( info )
    dump(info,"onGameState")
    --显示等待开始时间
    if info["state"] == ZJH.GAME_STATUS.READY then
        self.model.isGaming = false
        self.scene:showStartTimer(info["time"])
        self.scene:hideMatchLayer()
    end
end

--庄家信息
function C:onBanker( info )
    dump(info,"onBanker")
    self.model.zhuangLocalSeatId = self.scene:getLocalSeatId(info["zhuangjia"])
    self.scene:showBankerImg()
end

--发牌
function C:onSendCard( info )
    dump(info,"onSendCard")
    local temp = info["playerlist"]
    table.sort(temp)
    local list = {}
    for i = 1, 4 do 
        local nextID = (self.model.zhuangLocalSeatId + i) % 5
        if nextID == 0 then 
            nextID = 5
        end
        for _,seatId in ipairs(temp) do
            if self.scene:getLocalSeatId(seatId) == nextID then 
                table.insert(list, nextID)
                break
            end
        end
    end
    --庄家放到最后发
    table.insert(list,self.model.zhuangLocalSeatId)
    if self.model.myInfo["sex"] == 1 then
        PLAY_SOUND(GAME_ZJH_SOUND_RES.."fapai_girl.mp3")
    else
        PLAY_SOUND(GAME_ZJH_SOUND_RES.."fapai_boy.mp3")
    end
    self.scene:hideStartTimer()
    self.model.isGaming = true
    for i=1,#list do
        local localSeatId = list[i]
        local delay = 0.16*(i-1) --0.16
        local callback = nil
        if i == #list then
            callback = function()
                self.scene:updateOperationBtns()
            end
        end
        self.scene:sendPlayerPokerAni(localSeatId,delay,callback)
        self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.NOT_LOOKED
    end
end

--玩家下注
function C:onBet( info )
    dump(info,"onBet")
    local localSeatId = self.scene:getLocalSeatId(info["betseat"])
    self.model.currentTotalChips = info["betbottom"]
    self.model.currentSingleChip = info["betcurrent"]
    self.scene:setZongzhu(self.model.currentTotalChips)
    self.scene:setPlayerChips(localSeatId,info["mybetall"])
    self.scene:setPlayerBlanceBySeatId(localSeatId,info["pmoney"])
    self.scene:hidePlayerTimer(localSeatId)
    if localSeatId == 1 then
        self.model.turnToMe = false
        if self.model.isAuto or info["bettype"] == ZJH.OPT.BOTTOM then
            self.scene:throwPlayerChips(localSeatId,info["bet"],info["bettype"])
        end
    else
        self.scene:throwPlayerChips(localSeatId,info["bet"],info["bettype"])
    end
end

--等待玩家操作
function C:onWaitOpt( info )
    dump(info,"onWaitOpt")
    self.model.currentOptLocalSeatId = self.scene:getLocalSeatId(info["optseatid"])
    self.model.currentOptLeftTime = info["waittime"]
    if self.model.currentOptLocalSeatId == 1 then
        self.model.turnToMe = true
    else
        self.model.turnToMe = false
    end
    self.model:updateOptConfigs(info)
    self.scene:updateOperationBtns()
    self.scene:showPlayerTimer(self.model.currentOptLocalSeatId,self.model.currentOptLeftTime)
end

--玩家弃牌
function C:onFold( info )          
    dump(info,"onFold")
    local localSeatId = self.scene:getLocalSeatId(info["fold"])
    self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.QIPAI
    self.scene:setPlayerStatus(localSeatId,3)
    self.scene:hidePlayerTimer(localSeatId)
    self.scene:hideComparePanel()
    if localSeatId == 1 then
        self.model.isGaming = false
        self.model.turnToMe = false
        self.scene:showContinueBtn()
        self.scene:updateOperationBtns()
        if self.model.isDrop == false then
            self.scene:playPlayerSpeakSound(localSeatId,"drop",1)
        end
    else
        self.scene:playPlayerSpeakSound(localSeatId,"drop",1)
        self:checkGameOver()
    end
end

--玩家看牌
function C:onCheck( info )
    dump(info,"onCheck")
    local localSeatId = self.scene:getLocalSeatId(info["checkseat"])
    self.model.playerGameStatusArr[localSeatId] = ZJH.PLAYER_GAME_STATUS.HAD_LOOKED
    self.scene:setPlayerStatus(localSeatId,1)
    if localSeatId ~= 1 then
        self.scene:setPlayerSpeak(localSeatId,3)
    end
end

--自己看牌，获得自己的牌信息
function C:onCheckSelf( info )
    dump(info,"onCheckSelf")
    self.model.playerGameStatusArr[1] = ZJH.PLAYER_GAME_STATUS.HAD_LOOKED
    self.scene:showPlayerPoker(1,info["cards"],true)
    self.scene:setPlayerSpeak(1,3)
    self.scene:updateOperationBtns()
end

--玩家比牌
function C:onCompare( info )
    dump(info,"onCompare")
    local fromSeatId = self.scene:getLocalSeatId(info["seatid"])
    local winnerSeatId = self.scene:getLocalSeatId(info["winner"])
    local loserSeatId = self.scene:getLocalSeatId(info["loser"])
    self.model.playerGameStatusArr[loserSeatId] = ZJH.PLAYER_GAME_STATUS.TAOTAI
    self.scene:hideAllPlayerTimer()
    self.scene:playCompareAni(fromSeatId,winnerSeatId,loserSeatId)
    if loserSeatId == 1 then
        self.model.isGaming = false
        self.scene:showContinueBtn()
        self.scene:updateOperationBtns()
    else
        self:checkGameOver()
    end
end

--检查游戏状态，在有玩家弃牌或者比牌输的时候，提前判断游戏是否已经结束
function C:checkGameOver()
    local count = 0
    for i=1,5 do
        if self.model.playerGameStatusArr[i] == ZJH.PLAYER_GAME_STATUS.NOT_LOOKED or
           self.model.playerGameStatusArr[i] == ZJH.PLAYER_GAME_STATUS.HAD_LOOKED then
           count = count+1
        end
    end
    if count < 2 then
        self.model.isGaming = false
        self.scene:updateOperationBtns()
    end
end

--玩家开牌
function C:onShowCard( info )
    dump(info,"onShowCard")
    local localSeatId = self.scene:getLocalSeatId(info["showseat"])
    if localSeatId ~= 1 then
        self.scene:setPlayerSpeak(localSeatId,5)
    end
    self.scene:showAutoCmpAni(function()
        for k,v in pairs(info) do
            if type(v) == "table" then
                local seatId = self.scene:getLocalSeatId(v["seatid"])
                local cards = v["cards"]
                self.scene:showPlayerPoker(seatId,cards,false)
            end
        end
    end)
end

--系统自动开牌
function C:onSystemShowCard( info )
    dump(info,"onSystemShowCard")
    self.scene:showAutoCmpAni(function()
        for k,v in pairs(info) do
            if type(v) == "table" then
                local seatId = self.scene:getLocalSeatId(v["seatid"])
                local cards = v["cards"]
                self.scene:showPlayerPoker(seatId,cards,false)
            end
        end
    end)
end

--游戏轮数
function C:onTurn( info )
    dump(info,"onTurn")
    self.model.currentRound = info["nturn"]
    local maxRound = tonumber(info["nmaxturn"]) or 16
    self.scene:setRound(self.model.currentRound,maxRound)
    self.scene:updateOperationBtns()
end

--玩家准备
function C:onReady( info )
    dump(info,"onReady")
end

--发送游戏协议------------------------
--发送下注
function C:sendBet( info )
    self:sendGameMsg(ZJH.CMD.CS_BET_P,info)
end

--发送弃牌
function C:sendFold()
    self:sendGameMsg(ZJH.CMD.CS_FOLD_P)
end

--发送看牌
function C:sendCheck()
    self:sendGameMsg(ZJH.CMD.CS_CHECK_P)
end

--发送比牌 seatId:服务器座位号
function C:sendCompare( seatId )
    local info = {}
    info["otherseat"] = seatId
    self:sendGameMsg(ZJH.CMD.CS_COMPETITION_P,info)
end

--发送开牌(孤注一掷)
function C:sendShowCard()
    self:sendGameMsg(ZJH.CMD.CS_SHOW_CARD_PACK_P)
end

--发送跟到底/取消跟到底 follow: 0=取消跟到底 1=跟到底
function C:sendFollow( follow )
    local info = {}
    info["follow"] = follow
    self:sendGameMsg(ZJH.CMD.CS_FOLLOW_P,info)
end

--发送准备(继续游戏)
function C:sendReady()
    self:sendGameMsg(ZJH.CMD.CS_READY_P)
end

--举报
function C:sendReport( historyId, ids )
    local info = {}
    info["jubaoPlayerID"] = self.model.myInfo["playerid"]
    info["paiju_bs"] = historyId
    info["beijubaoPlayerID"] = ids
    dump(info)
    self:sendCommonMsg(MainProto.Game,ZJH.CMD.CS_REPORT_P,info)
end

return C