local C = class("JsmjCore",GameCoreBase)
local bit = require("bit")
local Tile = import(".JsmjTile")

--模块路径
C.MODULE_PATH = "app.games.jsmj"
--场景配置
C.SCENE_CONFIG = {scenename = "Jsmj_scene", filename = "JsmjScene", logic="JsmjLogic", define="JsmjDefine", model="JsmjModel"}

local TILEIDCOUNT = { }

C.preform = false

function C:ctor(roomInfo)
	C.super.ctor(self,roomInfo)
end

function C:start()
    --注册协议
    self:registerAll()
    --self.scene:setDiFen(self.model.roomInfo.difen)
    print("欢迎来到极速二人麻将")
    C.super.start(self)

    self:initIdCount()
end

function C:initIdCount()
	TILEIDCOUNT[0x01] = 4
    TILEIDCOUNT[0x02] = 4
    TILEIDCOUNT[0x03] = 4
    TILEIDCOUNT[0x04] = 4
    TILEIDCOUNT[0x05] = 4
    TILEIDCOUNT[0x06] = 4
    TILEIDCOUNT[0x07] = 4
    TILEIDCOUNT[0x08] = 4
    TILEIDCOUNT[0x09] = 4
    TILEIDCOUNT[0x31] = 4
    TILEIDCOUNT[0x32] = 4
    TILEIDCOUNT[0x33] = 4
end

function C:exit()
	--注销协议
    self:unregisterAll()
	C.super.exit(self)
end

function C:run(transition, time, more)
    C.super.run(self,transition, time, more)
end

function C:registerAll()
    self:registerGameMsg(self.define.proto.SC_START_SEND_CARD,  handler(self,self.s2cDealCard)); --发牌
    self:registerGameMsg(self.define.proto.SC_GAME_START,  handler(self,self.s2cGameStart)); --开始游戏
    self:registerGameMsg(self.define.proto.SC_OUT_CARD,  handler(self,self.s2cOutCard)); --用户出牌
    self:registerGameMsg(self.define.proto.SC_DISPATCH_CARD,  handler(self,self.s2cDispatchCard)); --用户摸牌
    self:registerGameMsg(self.define.proto.SC_TRUSTEE,  handler(self,self.s2cTrust)); --托管
    self:registerGameMsg(self.define.proto.SC_USER_STATUS,  handler(self,self.s2cUserStatus)); --用户状态

    self:registerGameMsg(self.define.proto.SC_USER_STATUS,  handler(self,self.s2cUserStatus)); --用户状态
    self:registerGameMsg(self.define.proto.SC_GAME_OVER,  handler(self,self.s2cGameOver)); --游戏结算
    --self:registerGameMsg(self.define.proto.SC_START_READY,  handler(self,self.s2cGameOver)); --游戏结算
end

function C:unregisterAll()
    self:unregisterGameMsg(self.define.proto.SC_START_SEND_CARD); --发牌
    self:unregisterGameMsg(self.define.proto.SC_GAME_START); --开始游戏
    self:unregisterGameMsg(self.define.proto.SC_OUT_CARD); --用户出牌
    self:unregisterGameMsg(self.define.proto.SC_DISPATCH_CARD); --用户摸牌
    self:unregisterGameMsg(self.define.proto.SC_TRUSTEE); --托管
    self:unregisterGameMsg(self.define.proto.SC_USER_STATUS); --用户状态

    self:unregisterGameMsg(self.define.proto.SC_USER_STATUS); --用户状态
    self:unregisterGameMsg(self.define.proto.SC_GAME_OVER); --游戏结算
end

--region S2C Common
    
--玩家进入房间
function C:onPlayerEnter(s)
    printInfo("<==================玩家进入==================>")
    local localSeat = self:getLocalSeat(s.seat)
    s.localSeat = localSeat
    self.scene:showPlayer(localSeat,s)
    self.model:setPlayerInfo(s)
end

--房间信息
function C:onRoomInfo(s)
    printInfo("<==================房间信息==================>")
    for k,v in pairs(s.playerlist) do
        if v.playerid == self.model.myPlayerId then
            self.model.mySeat = v.seat
            break
        end
    end

    for k,v in pairs(s.playerlist) do
        local localSeat = self:getLocalSeat(v.seat)
        v.localSeat = localSeat
        self.model:setPlayerInfo(v)
        self.scene:showPlayer(localSeat,v)
    end
end

--房间状态
function C:onRoomState(s)
    printInfo("<==================房间状态==================>")
    if s.roomstate == self.define.roomState.Game then 
        self.model.isGaming = true
    else
        self.model.isGaming = false
    end
end

--玩家状态
function C:onPlayerState(s)
    printInfo("<==================玩家状态==================>")
    local localSeat = self:getLocalSeat(s.seat)
    if localSeat == 1 and s.playerstate == self.define.playerGameState.Game then
        self.model.isGaming = true
    else
        self.model.isGaming = false
    end
end

--玩家退出
function C:onPlayerQuit(s)
    printInfo("<==================玩家退出==================>")
    printInfo()
    local info = self.model:getPlayerInfo(s.playerid)
    self.scene:hidePlayer(info.localSeat)
    if info.localSeat == 1 then
        self.model.isGaming = false
    end
end

--玩家被踢
function C:onDeletePlayer(s)
    printInfo("<==================玩家被踢==================>")
    C.super.onDeletePlayer(self,s)
end

--断线重连
function C:onToOtherRoom(s)
    printInfo("<==================断线重连==================>")
    dump(s)
    local mySeat = self.model.mySeat
    self.scene:clean()
    self.model:reConnect()
    self:initIdCount()
    local gameState = s.GameStatus

    self.scene:disableCurrentDiscardTile()
    self.model.isGaming = true
    self.model.outTime = s.OutCardTime
    self.model.trustTime = s.TrusteeTime

    if gameState == 1 then --GAME_STATUS_SEND_CARD, //发牌状态
        self.model.mySeat = mySeat

        self.model.leftCardNum = s.LeftCardCount
        self.model.bankerSeat = s.BankerUserSeatID

        self.model.myCards = s.HandCard
        for k,v in pairs(self.model.myCards) do
            self.model.myCards[k] = self:getTileId(v)
        end

        self.scene:doOpenDoorAnimEnd()
    elseif gameState == 2 then --GAME_STATUS_PLAY,      //游戏状态
        self.model.mySeat = mySeat

        self.model.curSeat = s.CurrentUserSeatID
        self.model.leftCardNum = s.LeftCardCount
        self.model.bankerSeat = s.BankerUserSeatID
        --self.model.myCards = s.HandCard
        --处理自己手牌刷新
        local addDispatched = false
        local dispatchCard = 0
        for k,v in pairs(s.HandCard) do
            if s.CurrentUserSeatID == self.model.mySeat and s.Card and v == s.Card  and addDispatched == false then
                dispatchCard = self:getTileId(s.Card)
                addDispatched = true
            else
                table.insert(self.model.myCards, self:getTileId(v))
--                local card = Tile.new(self.model.myCards[k])
--                self.model:addTile(card)
            end
        end
        if dispatchCard ~= 0 then
             local drawTile = Tile.new(dispatchCard)
             self.scene.ownTileView_:startGetTiles(self.model.myCards, true, drawTile)
             self.scene.ownTileView_:displayCard()
             if drawTile then
                self.scene.ownTileView_:setDrawTile(drawTile)
             end
        else
             self.scene.ownTileView_:startGetTiles(self.model.myCards, true, nil)
             self.scene.ownTileView_:displayCard()
        end
        --胡牌操作
        if s.CurrentUserSeatID == self.model.mySeat then
            if s.FanCount then
                self.model.huFan = s.FanCount
            end
            self.model.hasTing = s.HaveListen
            self.model.tingInfo = s.ListenInfo
        end
        
        --处理牌池刷新
        for i=1,self.model.playerCount do
            if i <= #s.DiscardCard then
                for k,v in pairs(s.DiscardCard[i]) do
                    local card = self:getTileId(v)
                    self.model:addOutTileById(i, card)
                end
            end
        end
        --最后出的一张牌
--        local card = self:getTileId(s.OutCardData)
--        self.model:addOutTileById(s.OutCardUserSeatID, card)
--        if s.OutCardUserSeatID == mySeat then
--            self.myOutCard = card
--        end
        for i=1,self.model.playerCount do
            local pos = self.model:getLocalSeat(i)
            self.scene:RefreshDiscardTilesByPos(pos, i)
        end

        --处理对家手牌刷新
        if s.CurrentUserSeatID ~= self.model.mySeat and s.Card then
            self.model.topLeftNum = 5
        else
            self.model.topLeftNum = 4
        end
        if self.scene.otherUserTiles_[2] then
            self.scene.otherUserTiles_[2]:setTileNum(self.model.topLeftNum)
            self.scene.otherUserTiles_[2]:refresh()
        end
        --托管处理
        if s.TrusteeFlag == 1 then --托管
            self.scene:showTrust()
        else --取消托管
            self.scene:hideTrust()
        end
    elseif gameState == 3 then --GAME_STATUS_GAME_OVER, //游戏结束
    elseif gameState == 4 then --GAME_STATUS_OVER,      //结算结束
    end

    self.scene:RefreshReconnect(s.RemainTime)

    self.preform = false
end

--更新金币
function C:updatePlayerMoney(s)
    printInfo("<==================更新金币==================>")
    C.super.updatePlayerMoney(self,s)
    local info = self.model:getPlayerInfo(s.playerid)
    self.scene:setMoney(info.localSeat,s.coin)
end

--开始匹配
function C:onStartMatch(s)
    printInfo("<==================开始匹配==================>")
    self.scene:clean()
    self.model:reset()
    self.scene:showWaiting()
end

--完成匹配
function C:onFinishMatch(s)
    printInfo("<==================完成匹配==================>")
    self.scene:hideWaiting()
end

--结算
function C:onSettlement(s)
    printInfo("<==================显示结算==================>")
    dump(s)
    self.model.isGaming = false
--    local info = {}
--    info.exitHandler = handler(self,self.quitGame)
--    info.continueHandler = handler(self,self.continueGame)

--    local delay = self.scene:showResult(info.isLord,info.win)

--    self:delayInvoke(delay,function()
--        self.scene:showSettlement(info)
--    end)

--    self:lockMsgForTime(delay)
end
--endregion

function C:getTileId(card)
    local id = bit.bor(bit.lshift(TILEIDCOUNT[card], 8), card)
    TILEIDCOUNT[card] = TILEIDCOUNT[card] + 1
    return id
end

--region S2C Game
function C:s2cDealCard(s)
    printInfo("<==================开始发牌==================>")
    dump(s)
    self.model.mySeat = s.SeatID
    self.model.diceNum1 = s.SiceNum1
    self.model.diceNum2 = s.SiceNum2
    self.model.leftCardNum = s.LeftCardCount
    self.model.outTime = s.OutCardTime
    self.model.trustTime = s.TrusteeTime
    self.model.bankerSeat = s.BankerUserSeatID

    self.model.myCards = s.HandCard
    for k,v in pairs(self.model.myCards) do
        self.model.myCards[k] = self:getTileId(v)
    end

    self.scene:DealCard()

    self.preform = false
end

function C:s2cGameStart(s)
    printInfo("<==================游戏开始==================>")
    dump(s)
    self.model.curSeat = s.CurrentUserSeatID
    self.model.huFan = s.FanCount
    self.model.hasTing = s.HaveListen
    self.model.tingInfo = s.ListenInfo

    self.scene:RefreshStartGame()
    self.preform = false
end

function C:s2cOutCard(s)
    printInfo("<==================玩家出牌==================>")
    dump(s)
    self.model.curSeat = s.CurrentUserSeatID
    
    local card = self:getTileId(s.OutCardData)
    self.model:addOutTileById(s.OutCardUserSeatID, card)
    if s.OutCardUserSeatID ~= self.model.mySeat then
        self.model.huFan = s.FanCount
        self.model.topLeftNum = self.model.topLeftNum - 1
        self.scene:OutCard(s.OutCardUserSeatID, card)
    else
        self.model:removeMyCards(s.OutCardData)
        --错误检查
        self.scene:OutCard(s.OutCardUserSeatID, card)
    end
    self.preform = false
end

function C:s2cDispatchCard(s)
    printInfo("<==================玩家摸牌==================>")
    dump(s)
    self.model.curSeat = s.DispatchCardSeatID
    self.model.leftCardNum = self.model.leftCardNum-1

    if s.DispatchCardSeatID ~= self.model.mySeat then
        self.model.topLeftNum = self.model.topLeftNum + 1
        self.scene:DispatchCard(s.DispatchCardSeatID, s.Card)
    else
        local card = self:getTileId(s.Card)
        self.model.huFan = s.FanCount
        self.model.hasTing = s.HaveListen
        self.model.tingInfo = s.ListenInfo
        table.insert(self.model.myCards, card)
        self.scene:DispatchCard(s.DispatchCardSeatID, card)
    end
    self.preform = false
end

function C:s2cTrust(s)
    printInfo("<==================玩家托管==================>")
    dump(s)

    if s.TrusteeSeatID == self.model.mySeat then
        if s.TrusteeFlag == 1 then --托管
            PLAY_SOUND(GAME_JSMJ_SOUND_RES.."trust.mp3")
            self.scene:showTrust()
        else --取消托管
            PLAY_SOUND(GAME_JSMJ_SOUND_RES.."untrust.mp3")
            self.scene:hideTrust()
        end
    end

    self.preform = false
end

function C:s2cUserStatus(s)
    printInfo("<==================用户状态==================>")
    dump(s)
    self.model.userStatus[s.SeatID] = s.Status
    self.scene:RefreshStatus(s.SeatID, s.Status)

    self.preform = false
end
function C:s2cGameOver(s)
    printInfo("<==================游戏结束==================>")
    dump(s)

    self.scene:disableCurrentDiscardTile()
    local info = {}
    info.exitHandler = handler(self,self.quitGame)
    info.continueHandler = handler(self,self.continueGame)

    info.winSeat = s.WinUserSeatID

    --显示所有玩家手牌
    local otherSeat = 1
    for i=1,self.model.playerCount do
        if i ~= self.model.mySeat then
            otherSeat = i
            break
        end
    end
    local otherTiles = { }
    local huTile = nil
    local huEd = false
    for k,v in pairs(s.HandCard[otherSeat]) do
        if otherSeat == s.WinUserSeatID and huEd == false and v == s.ChiHuCardData then
            local drawTile = Tile.new(self:getTileId(v))
            huTile = drawTile
            huEd = true
        else
            local drawTile = Tile.new(self:getTileId(v))
            table.insert(otherTiles, drawTile)
        end
    end      
    self.scene:showOtherUserTiles(otherSeat, info.winSeat,otherTiles,huTile,true )
    --显示所有玩家手牌

    if info.winSeat ~= 0 then
        info.flowerCard = s.LuckyCards--奖花牌
        info.hitFlower = s.BingoCard--命中的奖花牌
        info.fanTotal = s.GameMul--游戏番数
        info.fanFlower = s.LuckyMul--奖花番数
        info.lScore = s.lScore--玩家输赢金币数
        info.handCard = s.HandCard--玩家手牌
        --self.scene:showSettlement(info)

        --显示桌面分数，播放桌面动画
        info.loseSeat = info.winSeat%2+1
        if s.ChiHuFlag == 1 then --自摸胡
            PLAY_SOUND(GAME_JSMJ_SOUND_RES.."g_zimo_" .. math.random(1,2) ..".mp3")
            self.scene:playNewAnim("zimo", self.model:getLocalSeat(info.winSeat),function()
            self.scene.players[self.model:getLocalSeat(info.winSeat)]:showResult(s.lScore[info.winSeat])
            self.scene.players[self.model:getLocalSeat(info.loseSeat)]:showResult(s.lScore[info.loseSeat])
            end)
        elseif s.ChiHuFlag == 2 then --放炮胡
            PLAY_SOUND(GAME_JSMJ_SOUND_RES.."g_hu_" .. math.random(1,2) ..".mp3")
            self.scene:playNewAnim("hu", self.model:getLocalSeat(info.winSeat))
            self.scene:playNewAnim("pao", self.model:getLocalSeat(info.loseSeat),function()
            self.scene.players[self.model:getLocalSeat(info.winSeat)]:showResult(s.lScore[info.winSeat])
            self.scene.players[self.model:getLocalSeat(info.loseSeat)]:showResult(s.lScore[info.loseSeat])
            end)
        end
        --显示桌面分数，播放桌面动画

        --显示奖花界面
        for k,v in pairs(s.LuckyCards) do
            local drawTile = Tile.new(self:getTileId(v))
            if s.BingoCard then
                for l,n in pairs(s.BingoCard) do
                    if v == n then
                        table.insert(self.model.hitTiles_, drawTile)
                        break
                    end
                end
            end
            table.insert(self.model.awardTiles_, drawTile)
        end
        self:delayInvoke(2,function()
            self.scene:showAwardFlowerView(true, true,function( )
                self.scene:showSettlement(info)
		    end)
        end)
        --显示奖花界面
        self:lockMsgForTime(7)
    else
        --流局
        info.handCard = s.HandCard
        self.scene:playNewAnim("abort", -1)

        --显示结算界面
        self:delayInvoke(2,function()
            self.scene:showSettlement(info)
        end)
        self:lockMsgForTime(2)
    end
    
    --显示结算界面
    --local delay = self.scene:showResult(info)
end
--endregion

--region C2S
--发送开始消息
function C:c2sSendCardEnd()
    self:sendGameMsg(self.define.proto.CS_SEND_CARD_END);
end

--客户端出牌消息
function C:c2sSendCard(paiValue)
    printInfo("<-------------------发送出牌------------>")
    print(paiValue)
    self:sendGameMsg(self.define.proto.CS_OUT_CARD, {OutCardData = paiValue})
    self.preform = true
end

--发送托管消息
function C:c2sSendTuoGuan(isTuoguan)
    self:sendGameMsg(self.define.proto.CS_TRUSTEE, {TrusteeFlag = isTuoguan});
    self.preform = true
end

--发送用户操作
function C:c2sSendOperate(opCode)
    printInfo("<-------------------发送胡牌------------>")
    self:sendGameMsg(self.define.proto.CS_OPERATE, {OperCode = opCode});--1 - 胡牌
    self.preform = true
end
--endregion

function C:continueGame()
    printInfo("<==================继续游戏==================>")
    self:sendMatchMsg()
    self.scene:clean()
    self.model:reset()
end

--region Other

--获取本地座位
function C:getLocalSeat(seat)
    if seat < 1 or seat > self.model.playerCount then
        printInfo("座位ID不正确")
    end
    local s = seat - self.model.mySeat
	if s < 0 then
		s = s + self.model.playerCount
	end
	return s+1
end

--阻塞消息
function C:lockMsgForTime(time)
    LockMsg2()
    utils:delayInvoke("jsmj.lockmsg",time, function()
        UnlockMsg2()
    end)
end

--延迟调用
function C:delayInvoke(time,callback)
    self.scene:delayInvoke(time,callback)
end
--endregion

return C