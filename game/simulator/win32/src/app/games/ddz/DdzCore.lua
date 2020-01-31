local C = class("DdzCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.ddz"
--场景配置
C.SCENE_CONFIG = {scenename = "ddz_scene", filename = "DdzScene", logic="DdzLogic", define="DdzDefine", model="DdzModel"}

C.preform = false

function C:ctor(roomInfo)
	C.super.ctor(self,roomInfo)
end

function C:start()
    --注册协议
    self:registerAll()
    self.scene:setDiFen(utils:moneyString(self.model.roomInfo.difen * 10,2))
    print("欢迎来到斗地主")
    C.super.start(self)
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
    self:registerGameMsg(self.define.proto.SC_CODDZ_FAPAI_P,  handler(self,self.s2cDealCard));                               --发牌
    self:registerGameMsg(self.define.proto.SC_CODDZ_SET_DIZHU_P,  handler(self,self.s2cSetDiZhu));                           --设置地主和底牌(广播),客户端根据自己是否是地主判断是否获得底牌  
    self:registerGameMsg(self.define.proto.SC_CODDZ_SET_STATE_P,  handler(self,self.s2cSetGameState));                       --设置当前游戏状态(广播)

    self:registerGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_P,  handler(self,self.s2cPlayerJiaoDiZhu));                    --一个玩家叫了地主(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_TIMEOUT_P,  handler(self,self.s2cPlayerJiaoDiZhuTimeout));     --一个玩家叫地主超时(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_PASS_P,  handler(self,self.s2cPlayerJiaoDiZhuPass));           --一个玩家不叫地主(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_NOTIFY_P,  handler(self,self.s2cNotifyJiaoDiZhu));             --通知一个玩家叫地主
    self:registerGameMsg(self.define.proto.SC_CODDZ_REQUEST_CHUPAI_P,  handler(self,self.s2cNotifyChuPai));                  --通知一个玩家该出牌了(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_WARNING_CHUPAI_P,  handler(self,self.s2cWarningChuPai));                 --警告一个玩家该出牌了(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_CHUPAI_END_P,  handler(self,self.s2cChuPaiEnd));                         --下发一个玩家出牌结束的消息(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_CHUPAI_PASS_P,  handler(self,self.s2cChuPaiPass));                       --下发一个玩家过牌(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_TUOGUAN_P,  handler(self,self.s2cTuoGuan));                              --托管(广播)
    self:registerGameMsg(self.define.proto.SC_CODDZ_SHOW_P,  handler(self,self.s2cShowAllCards));                            --显示所有牌面(广播)	   
    self:registerGameMsg(self.define.proto.SC_CODDZ_SET_BEILV_P,  handler(self,self.s2cSetBeiLv));                           --设置倍率(广播)	   
    self:registerGameMsg(self.define.proto.SC_CODDZ_SET_PLAYER_STATE_P,  handler(self,self.s2cSetPlayerState));              --设置玩家状态(广播)	

    self:registerGameMsg(self.define.proto.SC_CODDZ_ANYONEPLAYERPAI_P,  handler(self,self.s2cGetMyShouPai));                 --请求发送自己当前手上的牌
    self:registerGameMsg(self.define.proto.SC_CODDZ_LIUJU_P,  handler(self,self.s2cLiuJu));                                  --流局

    self:registerGameMsg(self.define.proto.SC_CODDZ_PLAYER_ADD_MUTI_P,  handler(self,self.s2cPlayerAddMulti));
    self:registerGameMsg(self.define.proto.SC_CODDZ_PLAYER_ADD_MUTI_NOTIFY_P,  handler(self,self.s2cNotifyPlayerAddMuti));   --通知一个加倍
end

function C:unregisterAll()
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_FAPAI_P);                                 --发牌
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_SET_DIZHU_P);                             --设置地主和底牌(广播),客户端根据自己是否是地主判断是否获得底牌  
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_SET_STATE_P);                             --设置当前游戏状态(广播)

    self:unregisterGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_P);                             --一个玩家叫了地主(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_TIMEOUT_P);                     --一个玩家叫地主超时(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_PASS_P);                        --一个玩家不叫地主(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_JIAODIZHU_NOTIFY_P);                      --通知一个玩家叫地主
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_REQUEST_CHUPAI_P);                        --通知一个玩家该出牌了(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_WARNING_CHUPAI_P);                        --警告一个玩家该出牌了(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_CHUPAI_END_P);                            --下发一个玩家出牌结束的消息(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_CHUPAI_PASS_P);                           --下发一个玩家过牌(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_TUOGUAN_P);                               --托管(广播)
    self:unregisterGameMsg(XC.XC_JIESUAN_P);                                                    --结算(广播)
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_SHOW_P);                                  --显示所有牌面(广播)	   
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_SET_BEILV_P);                             --设置倍率(广播)	   
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_SET_PLAYER_STATE_P);                      --设置玩家状态(广播)	

    self:unregisterGameMsg(self.define.proto.SC_CODDZ_ANYONEPLAYERPAI_P);                       --请求发送自己当前手上的牌
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_LIUJU_P);                                 --流局

    self:unregisterGameMsg(self.define.proto.SC_CODDZ_PLAYER_ADD_MUTI_P);
    self:unregisterGameMsg(self.define.proto.SC_CODDZ_PLAYER_ADD_MUTI_NOTIFY_P);                --通知一个加倍
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
        self.scene:showPlayer(localSeat,v)
        self.model:setPlayerInfo(v)
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
    local info = self.model:getPlayerInfo(s.playerid)
    --self.scene:hidePlayer(info.localSeat)
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
    self.model.isGaming = true
    self.scene:clean()
    
    --底分
    self.scene:setDiFen(utils:moneyString(s.difen,2))
    if s.badd and s.badd == 1 then
        self.scene:showJiaBei(1,true)
    end

    --玩家状态
    for k,v in pairs(s.playerstate) do
        local localSeat = self:getLocalSeat(v.seat)
        if v.badded and v.badded == 1 and v.badd and v.badd == 1 then
            self.scene:showJiaBei(localSeat,true)
        end
        if v.istuoguan and v.istuoguan == 1 then
            self.scene:showTuoGuan(localSeat)
        end
        if v.lastopt and v.lastopt == 1 then --不要
            self.scene:showBuYao(localSeat)
        end
        if v.lastopt and v.lastopt == 2 and v.lastCards and #v.lastcards > 0 then --出牌
            local cards = {}
            for k2,v2 in pairs(v.lastCards) do 
                table.insert(cards,self.logic:colorNumber2Id(v2.cardcolor,v2.cardnumber))
            end
            self.scene:showCards(localSeat,cards,false)
        end
    end

    --倍率
    local jiaofen = 0
    if s.jiaofen then
        jiaofen = s.jiaofen
    end

    self.model.badd = s.badd or 0
    self.model.jiaoFen = jiaofen
    local num = self.model.badd == 1 and 2 or 1
    if s.beilv then
        if jiaofen > 0 then
            self.scene:setBeiLv(s.beilv * jiaofen * num)
        else
            self.scene:setBeiLv(s.beilv * num)
        end
    end

    --底牌
    if s.dipai then
        local cards = {}
        for k,v in pairs(s.dipai) do 
            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        self.model.blindCards = cards
        self.scene:showBlindCards(cards)
    end

    --自己手牌
    if s.pai then
        local cards = {}
        for k,v in pairs(s.pai) do 
            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        self.model.myCards = cards
        self.scene:createMyCards(cards,false)
    end

    --剩余牌数
    if s.painum then
        for k,v in pairs(s.painum) do 
            self.scene:showRemainCardNumber(self:getLocalSeat(v.seat),v.num)
        end
    end

    local currentSeat = self:getLocalSeat(s.currentseat)

    --叫地主
    local dizhuseat = 1
    if s.gamestate == self.define.gameState.JiaoDiZhu then
        if currentSeat == 1 and s.canfen then
            self.scene:showJiaoFenButtons(s.canfen,s.endtime,handler(self,self.buJiao))
        else
            self.scene:showClock(currentSeat,s.endtime)
        end
        self.scene:showRemainCardNumber(2,17)
        self.scene:showRemainCardNumber(3,17)
    else
        if s.dizhuseat then
            dizhuseat = self:getLocalSeat(s.dizhuseat)
            self.scene:showDiZhu(dizhuseat,false)
            self.model.dizhuSeat = dizhuseat
            self.model.isLord = dizhuseat == 1
        end
    end

    --加倍
    if s.gamestate == self.define.gameState.AddMuti then
        if currentSeat == 1 then
            self.scene:showJiaBeiButtons(s.endtime,handler(self,self.buJiaBei))
        else
            self.scene:showClock(currentSeat,s.endtime)
        end
        self.scene:showRemainCardNumber(2,dizhuseat== 2 and 20 or 17)
        self.scene:showRemainCardNumber(3,dizhuseat== 3 and 20 or 17)
    end

    --记牌器
    if s.passcards then
        self.model:resetRemainCard(s.pai)
        for k,v in pairs(s.passcards) do
            self.model:minusRemainCard(k,v)
        end
        self:updateRemainCards()
    else
        self.model:resetRemainCard(s.pai)
        self:updateRemainCards()
    end

    --出牌
    if s.gamestate == self.define.gameState.Game then
        if s.currentpaiseat and s.currentpai then
            local cards = {}
            for k,v in pairs(s.currentpai) do 
                table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
            end
            self.scene:showCards(s.currentpaiseat,cards)
            self.logic:setOtherCards(self.logic:protoToCards(cards))
        end

        if currentSeat == 1 then
            local first = s.firstchupai == 1
            if first then 
                self.scene:hideAllBuYao()
                self.scene:hideAllCards()
            end
            self.scene:showChuPaiButtons(s.endtime,handler(self,self.buYao),first)
        else
            self.scene:showClock(currentSeat,s.endtime)
        end

        self.scene:showJiPaiQi()
    end
    self.model.gameState = s.gamestate
    self.preform = false
end

--更新金币
function C:updatePlayerMoney(s)
    printInfo("<==================更新金币==================>")
    C.super.updatePlayerMoney(self,s)
    local info = self.model:getPlayerInfo(s.playerid)
    if info then
        self.scene:setMoney(info.localSeat,s.coin)
    end
end

--开始匹配
function C:onStartMatch(s)
    printInfo("<==================开始匹配==================>")
    self.scene:clean()
    self.scene:hideOtherPlayers()
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
    self.model.isGaming = false
    local info = {}
    info.exitHandler = handler(self,self.quitGame)
    info.continueHandler = handler(self,self.continueGame)

    info.isLord = self.model.isLord
    info.win = false

    info.rows = {}
    local difen = utils:moneyString(self.model.roomInfo.difen,2)

    local beishu = s.jiesuan.jiaofen * s.jiesuan.beilv
    local dizhuBeiShu = 0
    local farmerAdd = 1

    for k,v in pairs(s.jiesuan.fen) do
        local localSeat = self:getLocalSeat(v.seat)
        local playerBeiShu = beishu * (v.badd == 1 and 2 or 1)
        if localSeat ~= self.model.dizhuSeat then dizhuBeiShu = dizhuBeiShu + playerBeiShu end
 
        if v.win == 1 and localSeat == 1 then info.win = true end
        if v.badd == 1 and localSeat == 1 then farmerAdd = 2 end

        info.rows[localSeat] = 
        {
            name = s.player[k].playerid,
            difen = difen,
            beishu = playerBeiShu,
            win = v.winnum,
            dizhu = (localSeat == self.model.dizhuSeat)
        }
    end
    info.rows[self.model.dizhuSeat].beishu = dizhuBeiShu

    local zhadan = s.jiesuan.zhadan
    if s.jiesuan.huojian > 0 then
        zhadan = zhadan * s.jiesuan.huojian
    end
    if self.model.isLord then
        info.detail = 
        {
            name = self.model.myPlayerId,
            jiaofen = s.jiesuan.jiaofen,
            zhadan = zhadan,
            chuntian = s.jiesuan.chuntian,
            totalAdd = dizhuBeiShu
        }
    else
        info.detail = 
        {
            name = self.model.myPlayerId,
            jiaofen = s.jiesuan.jiaofen,
            zhadan = zhadan,
            commonAdd = beishu,
            farmerAdd = farmerAdd,
            totalAdd = beishu * farmerAdd
        }
    end

    local delay = self.scene:showResult(info.isLord,info.win,s.jiesuan.chuntian > 1)

    self:delayInvoke(delay,function()
        self.scene:showSettlement(info)
    end)

    self:lockMsgForTime(delay)
end

--endregion

--region S2C Game

function C:s2cDealCard(s)
    dump(s,"<==================开始发牌==================>")
    self.model:resetSoundIndex()
    if s.pai then
        local cards = {}
        for k,v in pairs(s.pai) do 
            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        self.model.myCards = cards
        self.scene:createMyCards(cards,true)
    end
    self.scene:showRemainCardNumber(2,17)
    self.scene:showRemainCardNumber(3,17)
    self.model.isGaming = true
    self.preform = false
    self.model:resetRemainCard(s.pai)

    self.scene:updateBattery()
end

function C:s2cSetDiZhu(s)
    printInfo("<==================设置地主==================>")

    local dizhuSeat = self:getLocalSeat(s.dizhuseat)
    self.scene:showDiZhu(dizhuSeat,true)
    self.scene:setBeiLv(s.jiaofen * s.beilv)
    self.model.jiaoFen = s.jiaofen
    self.model.badd = 0

    local cards = {}
    for k,v in pairs(s.pai) do 
        local id = self.logic:colorNumber2Id(v.cardcolor,v.cardnumber)
        table.insert(cards,id)
        if dizhuSeat == 1 then
            self.model:minusRemainCard(v.cardnumber)
            table.insert(self.model.myCards,id)
        end
    end
    self.model.blindCards = cards
    self.scene:showBlindCards(cards)
    if dizhuSeat == 1 then
        self.scene:createMyCards(self.model.myCards,false,true)
    else
        self.scene:showRemainCardNumber(dizhuSeat,20)
    end
    self.model.dizhuSeat = dizhuSeat
    self.model.isLord = dizhuSeat == 1
end

function C:s2cSetGameState(s)
    printInfo("<==================游戏状态==================>")
    self.model.logKey = s.logkey
    self.model.gameState = s.gamestate
    if s.gamestate == self.define.gameState.JiaoDiZhu then
        self.scene:hideAllClocks()
    elseif s.gamestate == self.define.gameState.AddMuti then
        self.scene:hideAllClocks()
        self.scene:hideAllJiaoFen()
    elseif s.gamestate == self.define.gameState.Game then
        self.scene:hideAllClocks()
        self.scene:hideAllJiaoFen()
        --self.scene:hideAllJiaBei()
        self:updateRemainCards()
        self.scene:showJiPaiQi()
        self.scene:setAllCardsClickable(true)
    else
        self.scene:setAllCardsClickable(false)
        self.scene:unselectAllCards()
    end
end

function C:s2cPlayerJiaoDiZhu(s)
    printInfo("<==================玩家叫分==================>")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideClock(localSeat)
    if localSeat ~= 1 then
        self.scene:showJiaoFen(localSeat,s.jiaofen)
    else
        self.scene:hideJiaoFenButtons()
        if self.model.isTuoGuan or not self.preform then 
            self.scene:showJiaoFen(localSeat,s.jiaofen)
        end
        self.preform = false
    end
end

function C:s2cPlayerJiaoDiZhuTimeout(s)
    printInfo("<==================叫分超时==================>")
    local localSeat = self:getLocalSeat(s.seat)
    if localSeat == 1 then
        self.scene:hideJiaoFenButtons()
    end
    self.scene:showJiaoFen(localSeat,0)
    self.scene:hideClock(localSeat)

end

function C:s2cPlayerJiaoDiZhuPass(s)
    printInfo("<==================玩家不叫==================>")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideClock(localSeat)
    if localSeat ~= 1 then
        self.scene:showJiaoFen(localSeat,0)
    else
        self.scene:hideJiaoFenButtons()
        if self.model.isTuoGuan or not self.preform then 
            self.scene:showJiaoFen(localSeat,0)
        end
        self.preform = false
    end
end

function C:s2cNotifyJiaoDiZhu(s)
    printInfo("<==================通知叫分==================>")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideAllClocks()
    if localSeat == 1 then
        if not self.model.isTuoGuan then
            self.scene:showJiaoFenButtons(s.canfen,self.define.timeout.JiaoFen,handler(self,self.buJiao))
        end
    else
        self.scene:showClock(localSeat,self.define.timeout.JiaoFen)
    end
end

function C:s2cPlayerAddMulti(s)
    --printInfo("<==================玩家加倍==================>")
    dump(s,"玩家加倍")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideClock(localSeat)
    if localSeat ~= 1 then
        self.scene:showJiaBei(localSeat,s.badd == 1)
    else
        self.scene:hideJiaBeiButtons()
        self.model.badd = s.badd
        local num = self.model.badd == 1 and 2 or 1
        self.scene:setBeiLv(self.model.jiaoFen * num)
        if self.model.isTuoGuan or not self.preform then 
            self.scene:showJiaBei(localSeat,s.badd == 1)
        end
        self.preform = false
    end
end

function C:s2cNotifyPlayerAddMuti(s)
    printInfo("<==================通知加倍==================>")
    dump(s,"通知加倍")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideAllClocks()
    self.scene:hideJiaoFen(localSeat)
    if localSeat == 1 then
        if not self.model.isTuoGuan then
            self.scene:showJiaBeiButtons(self.define.timeout.JiaBei,handler(self,self.buJiaBei))
        end
    else
        self.scene:showClock(localSeat,self.define.timeout.JiaBei)
    end
end

function C:s2cNotifyChuPai(s)
    printInfo("<==================通知出牌==================>")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideAllClocks()
    self.scene:hideJiaBei(localSeat)
    self.scene:hideCards(localSeat)
    self.scene:hideBuYao(localSeat)

    local time = self.define.timeout.ChuPai
    if s.optime then time = s.optime end
    if localSeat == 1 then
        self.model.isMyTurn = true
        local first = s.firstchupai == 1
        if not self.model.isTuoGuan then
            if #self.logic:getAllHints() == 0 then
                self.scene:showYaoBuQiButtons(time,handler(self,self.buYao))
            else
                if self.model.autoShowCard and #self.model.myCards == 1 then
                    dump(self.model.myCards)
                    self:chuPai(self.model.myCards)
                else
                    self.scene:showChuPaiButtons(time,function() self.scene:hideChuPaiButtons() end,first)
                end
            end
        end
    else
        self.model.isMyTurn = false
        if time > 0 and time < 10 then time = 10 end
        self.scene:showClock(localSeat,time)
    end
end

function C:s2cWarningChuPai(s)
  
end

function C:s2cChuPaiEnd(s)
    printInfo("<==================玩家出牌==================>")
    local localSeat = self:getLocalSeat(s.seat)
    local cards = {}
    for k,v in pairs(s.pai) do 
        table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
    end
    
    self.scene:hideClock(localSeat)
    self.scene:hideBuYao(localSeat)
    self.scene:hideJiaBei(localSeat)
    self.scene:hideJiaoFen(localSeat)

    if localSeat == 1 then
        self.model.lastCards = nil
        self.logic:setOtherCards({})
        if not self.model:isSameShowCards(cards) then
            self:c2sGetMyCard()
            self.scene:showCards(1,cards,false)
        elseif self.model.isTuoGuan or not self.preform then
            self.scene:playMyCards(cards)
            self.scene:showCards(1,cards,true)
        end
        self.scene:hideChuPaiButtons()
        self.scene:hideYaoBuQiButtons()
        self.preform = false
    else
        self.model.lastCards = cards
        self.logic:setOtherCards(self.logic:protoToCards(cards))
        self.scene:showRemainCardNumber(localSeat,s.remainnum)
        self.scene:showCards(localSeat,cards,true)
        for k,v in pairs(s.pai) do 
            self.model:minusRemainCard(v.cardnumber)
        end
        self:updateRemainCards()
    end
end

function C:s2cChuPaiPass(s)
    printInfo("<==================玩家不要==================>")
    local localSeat = self:getLocalSeat(s.seat)

    self.scene:hideClock(localSeat)
    self.scene:hideCards(localSeat)
    self.scene:hideJiaBei(localSeat)
    self.scene:hideJiaoFen(localSeat)

    if localSeat ~= 1 then
        self.scene:showBuYao(localSeat)
    else
        self.scene:hideChuPaiButtons()
        self.scene:hideYaoBuQiButtons()
        if self.model.isTuoGuan or not self.preform then 
            self.scene:showBuYao(localSeat)
        end
        if self.model.myShowCards then
            self:c2sGetMyCard()
            self.scene:showBuYao(localSeat)
        end
        self.preform = false
    end
end

function C:s2cTuoGuan(s)
    printInfo("<==================玩家托管==================>")
    local localSeat = self:getLocalSeat(s.seat)
    local tuoguan = s.type == 1
    if localSeat == 1 then
        self.model.isTuoGuan = tuoguan
    end
    if tuoguan then
        self.scene:showTuoGuan(localSeat)
        self.scene:hideChuPaiButtons()
        self.scene:hideJiaBeiButtons()
        self.scene:hideJiaofenButtons()
        self.scene:hideYaoBuQiButtons()
    else
        self.scene:hideTuoGuan(localSeat)
    end
end

function C:s2cShowAllCards(s)
    printInfo("<==================显示手牌==================>")

    for i = 1,3 do
        local player = s[i]
        local localSeat = self:getLocalSeat(player.seat)
        self.scene:hideClock(localSeat)
        self.scene:hideAlert(localSeat)
        self.scene:hideBuYao(localSeat)
        self.scene:hideRemainCardNumber(localSeat)
        if player.pai then
            local cards = {}
            for k,v in pairs(player.pai) do
                table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
            end
            self.scene:showCards(localSeat,cards,false,true)
        end
    end

    self.scene:hideChuPaiButtons()
    self.scene:hideYaoBuQiButtons()
    self.scene:hideTuoGuan(1)
    self.scene:cleanMyCards()
end

function C:s2cSetBeiLv(s)
    printInfo("<==================设置倍率==================>")
    local num = self.model.badd == 1 and 2 or 1
    if self.model.jiaoFen > 0 then
        self.scene:setBeiLv(self.model.jiaoFen * s.beilv * num) 
    else
        self.scene:setBeiLv(s.beilv * num)
    end
end

function C:s2cSetPlayerState(s)
    printInfo("<==================玩家状态==================>")
    local localSeat = self:getLocalSeat(s.seat)
    local isTuoGuan = s.state == 1
    if isTuoGuan then
        self.scene:showTuoGuan(localSeat)
        if localSeat == 1 then
            self.scene:hideChuPaiButtons()
            self.scene:hideJiaBeiButtons()
            self.scene:hideJiaofenButtons()
            self.scene:hideYaoBuQiButtons()
        end
    else
        self.scene:hideTuoGuan(localSeat)
    end
    if localSeat == 1 then
        self.model.isTuoGuan = isTuoGuan
    end
end

function C:s2cGetMyShouPai(s)
    printInfo("<==================我的手牌==================>")
    if s.pai and #s.pai then
        local cards = {}
        for k,v in pairs(s.pai) do
            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        self.model.myCards = cards
        self.scene:createMyCards(cards,false)
    else
        self.scene:cleanMyCards()
    end
end

function C:s2cLiuJu(s)
    printInfo("<==================流局==================>")
    self.scene:clean()
end

--endregion

--region C2S

function C:c2sJiaoDiZhuPass()
    self:sendGameMsg(self.define.proto.CS_CODDZ_JIAODIZHU_PASS_P);
end

--玩家叫地主(不需要有具体信息)
--<param name="fen">叫几分</param>
function C:c2sJiaoDiZhu(fen)      
    self:sendGameMsg(self.define.proto.CS_CODDZ_JIAODIZHU_P, {jiaofen = fen})
end


--一个玩家过牌(不需要有具体信息)
function C:c2sChuPaiPass()
    self:sendGameMsg(self.define.proto.CS_CODDZ_CHUPAI_PASS_P);
end
        

--出牌
--<param name="cards"></param>
function C:c2sChuPai(cards)
    local pai = {}
    for k,v in pairs(cards) do 
        table.insert(pai,self.logic:id2ColorNumber(v))
    end
    self:sendGameMsg(self.define.proto.CS_CODDZ_CHUPAI_P, {pai = pai})
end

--玩家加倍 不加倍
function C:c2sJiaBeiOrBuJiaBei(add)
    self:sendGameMsg(self.define.proto.CS_CODDZ_PLAYER_ADD_MUTI_P, {badd = add and 1 or 0});
end

--向服务器请求自己的手牌，每一次出牌后，都必须由服务器重新刷新一次自己的手牌
function C:c2sGetMyCard()
    self:sendGameMsg(self.define.proto.CS_CODDZ_ANYONEPLAYERPAI_P);
end

--向服务器请求托管
function C:c2sTuoGuan()
    self:sendGameMsg(self.define.proto.CS_CODDZ_TUOGUAN_P);
end

--举报
function C:c2sJuBao()
    self:sendGameMsg(self.define.proto.CS_PLAYER_REPORT_P, {playerid = self.model.myPlayerId,report_type = 1,logkey = self.model.logKey});
end

--endregion

--region UI Event

function C:continueGame()
    printInfo("<==================继续游戏==================>")
    self:sendMatchMsg()
    self.scene:clean()
    self.scene:hidePlayer(1)
    self.scene:hideOtherPlayers()
    self.model:reset()
end

--托管
function C:tuoGuan()
    if self.model.isGaming and self.model.gameState == self.define.gameState.Game then
        self.scene:showTuoGuan(1)
        self.scene:hideChuPaiButtons()
        self.scene:hideJiaBeiButtons()
        self.scene:hideJiaoFenButtons()
        self.scene:hideYaoBuQiButtons()
        self.model.isTuoGuan = isTuoGuan
        self:c2sTuoGuan()
    end
end

--取消托管
function C:cancelTuoGuan()
    self.scene:hideTuoGuan(1)
    self:c2sTuoGuan()
end

--取消选牌
function C:unSelectCard(id)

end

--选牌
function C:selectCard(id)

end

--不叫
function C:buJiao()
    self.scene:hideJiaoFenButtons()
    self.scene:showJiaoFen(1,0)
    self:c2sJiaoDiZhuPass()
    self.preform = true
end

--叫分
function C:jiaoFen(fen)
    self.scene:hideJiaoFenButtons()
    self.scene:showJiaoFen(1,fen)
    self:c2sJiaoDiZhu(fen)
    self.preform = true
end

--不加倍
function C:buJiaBei()
    self.scene:hideJiaBeiButtons()
    self.scene:showJiaBei(1,false)
    self:c2sJiaBeiOrBuJiaBei(false)
    self.preform = true
end

--加倍
function C:jiaBei()
    self.scene:hideJiaBeiButtons()
    self.scene:showJiaBei(1,true)
    self:c2sJiaBeiOrBuJiaBei(true)
    self.preform = true
end

--不要
function C:buYao()
    self.scene:hideChuPaiButtons()
    self.scene:hideYaoBuQiButtons()
    self.scene:showBuYao(1)
    self.scene:unselectAllCards()
    self.model.myShowCards = nil
    self:c2sChuPaiPass()
    self.preform = true
end

--出牌
function C:chuPai(selectedCards)
    local cards = selectedCards or self.model.selectedCards
    if cards == nil or #cards ==  0 then return end
    if not self.logic:isValidCards() then
        self.scene:unselectAllCards()
        return
    end
    self.model.myShowCards = cards
    self.scene:hideChuPaiButtons()
    self.scene:hideYaoBuQiButtons()
    self.scene:showCards(1,cards,true)
    self.scene:playMyCards(cards)
    self:c2sChuPai(cards)
    self.model:removeMyCards(cards)
    self.model.myShowCards = cards
    self.preform = true
end

--更新记牌器
function C:updateRemainCards()
    for k,v in pairs(self.model.remainCards) do
        self.scene:setJiPaiQiNumber(k,v)
    end
end

--endregion

--region Other

--获取本地座位
function C:getLocalSeat(seat)
    if seat < 1 or seat > 3 then
        printInfo("座位ID不正确")
    end
    local s = seat - self.model.mySeat
	if s < 0 then
		s = s + 3
	end
	return s+1
end

--阻塞消息
function C:lockMsgForTime(time)
    LockMsg2()
    utils:delayInvoke("ddz.lockmsg",time, function()
        UnlockMsg2()
    end)
end

--延迟调用
function C:delayInvoke(time,callback)
    self.scene:delayInvoke(time,callback)
end
--endregion

return C