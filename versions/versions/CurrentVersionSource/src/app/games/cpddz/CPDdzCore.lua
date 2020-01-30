local C = class("CPDdzCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.cpddz"
--场景配置
C.SCENE_CONFIG = {scenename = "cpddz_scene", filename = "CPDdzScene", logic="CPDdzLogic", define="CPDdzDefine", model="CPDdzModel"}

C.preform = false

function C:ctor(roomInfo)
	C.super.ctor(self,roomInfo)
end

function C:start()
    --注册协议
    self:registerAll()
    print("百变斗地主-------------" .. self.model.roomInfo.difen)
    self.scene:setDiFen(utils:moneyString(self.model.roomInfo.difen,2))
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
    self:registerGameMsg(self.define.proto.SC_CPDDZ_FAPAI_P,  handler(self,self.s2cDealCard));                               --发牌

    -- 换牌有两个步骤，一个是选择要换出去的牌，另外一个是选择要换回来的牌
    self:registerGameMsg(self.define.proto.SC_CPDDZ_CHANGEPOKER_P,handler(self,self.s2cExchangeOutCards)) -- 通知一个玩家选好了换出去牌
    self:registerGameMsg(self.define.proto.SC_CPDDZ_CHOOSE_NEED_POKER_OVER_P,handler(self,self.s2cExchangeOutCardsFinish)) -- 全部玩家选择好了要换的牌 并且返回能换回来的牌
    self:registerGameMsg(self.define.proto.SC_CPDDZ_CHOOSEPOKER_P,handler(self,self.s2cExchangeInCards)) -- 通知一个玩家选择好了要换回来的牌

    self:registerGameMsg(self.define.proto.SC_CPDDZ_SET_DIZHU_P,  handler(self,self.s2cSetDiZhu));                           --设置地主和底牌(广播),客户端根据自己是否是地主判断是否获得底牌
    self:registerGameMsg(self.define.proto.SC_CPDDZ_DZCHOOSEPOKER_P,handler(self,self.s2cDizhuSelectFinish))  -- 地主选牌返回

    self:registerGameMsg(self.define.proto.SC_CPDDZ_SET_STATE_P,  handler(self,self.s2cSetGameState));                       --设置当前游戏状态(广播)

    self:registerGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_P,  handler(self,self.s2cPlayerJiaoDiZhu));                    --一个玩家叫了地主(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_TIMEOUT_P,  handler(self,self.s2cPlayerJiaoDiZhuTimeout));     --一个玩家叫地主超时(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_PASS_P,  handler(self,self.s2cPlayerJiaoDiZhuPass));           --一个玩家不叫地主(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_NOTIFY_P,  handler(self,self.s2cNotifyJiaoDiZhu));             --通知一个玩家叫地主
    self:registerGameMsg(self.define.proto.SC_CPDDZ_REQUEST_CHUPAI_P,  handler(self,self.s2cNotifyChuPai));                  --通知一个玩家该出牌了(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_WARNING_CHUPAI_P,  handler(self,self.s2cWarningChuPai));                 --警告一个玩家该出牌了(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_CHUPAI_END_P,  handler(self,self.s2cChuPaiEnd));                         --下发一个玩家出牌结束的消息(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_CHUPAI_PASS_P,  handler(self,self.s2cChuPaiPass));                       --下发一个玩家过牌(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_TUOGUAN_P,  handler(self,self.s2cTuoGuan));                              --托管(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_SHOW_P,  handler(self,self.s2cShowAllCards));                            --显示所有牌面(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_SET_BEILV_P,  handler(self,self.s2cSetBeiLv));                           --设置倍率(广播)
    self:registerGameMsg(self.define.proto.SC_CPDDZ_SET_PLAYER_STATE_P,  handler(self,self.s2cSetPlayerState));              --设置玩家状态(广播)

    self:registerGameMsg(self.define.proto.SC_CPDDZ_ANYONEPLAYERPAI_P,  handler(self,self.s2cGetMyShouPai));                 --请求发送自己当前手上的牌
    self:registerGameMsg(self.define.proto.SC_CPDDZ_LIUJU_P,  handler(self,self.s2cLiuJu));                                  --流局

    self:registerGameMsg(self.define.proto.SC_CPDDZ_PLAYER_ADD_MUTI_P,  handler(self,self.s2cPlayerAddMulti));
    self:registerGameMsg(self.define.proto.SC_CPDDZ_PLAYER_ADD_MUTI_NOTIFY_P,  handler(self,self.s2cNotifyPlayerAddMuti));   --通知一个加倍
end

function C:unregisterAll()
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_FAPAI_P);                                 --发牌
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_SET_DIZHU_P);                             --设置地主和底牌(广播),客户端根据自己是否是地主判断是否获得底牌
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_SET_STATE_P);                             --设置当前游戏状态(广播)

    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_P);                             --一个玩家叫了地主(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_TIMEOUT_P);                     --一个玩家叫地主超时(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_PASS_P);                        --一个玩家不叫地主(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_JIAODIZHU_NOTIFY_P);                      --通知一个玩家叫地主
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_REQUEST_CHUPAI_P);                        --通知一个玩家该出牌了(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_WARNING_CHUPAI_P);                        --警告一个玩家该出牌了(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_CHUPAI_END_P);                            --下发一个玩家出牌结束的消息(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_CHUPAI_PASS_P);                           --下发一个玩家过牌(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_TUOGUAN_P);                               --托管(广播)
    self:unregisterGameMsg(XC.XC_JIESUAN_P);                                                    --结算(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_SHOW_P);                                  --显示所有牌面(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_SET_BEILV_P);                             --设置倍率(广播)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_SET_PLAYER_STATE_P);                      --设置玩家状态(广播)

    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_ANYONEPLAYERPAI_P);                       --请求发送自己当前手上的牌
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_LIUJU_P);                                 --流局

    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_PLAYER_ADD_MUTI_P);
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_PLAYER_ADD_MUTI_NOTIFY_P);                --通知一个加倍

    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_CHANGEPOKER_P)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_CHOOSE_NEED_POKER_OVER_P)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_CHOOSEPOKER_P)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_SET_DIZHU_P)
    self:unregisterGameMsg(self.define.proto.SC_CPDDZ_DZCHOOSEPOKER_P)
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
    dump(s,"<==================房间信息==================>",10)
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
    dump(s,"<==================玩家状态==================>"  .. tostring(self.model.mySeat))
    local localSeat = self:getLocalSeat(s.seat)
    if localSeat == 1 and s.playerstate == self.define.playerGameState.Game then
        self.model.isGaming = true
    else
        self.model.isGaming = false
    end
end

--玩家退出
function C:onPlayerQuit(s)
    dump(s,"<==================玩家退出==================>")
    local info = self.model:getPlayerInfo(s.playerid)
    -- if info.localSeat ~= 1 then
    --     self.scene:hidePlayer(info.localSeat)
    -- end
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
    dump(s,"<==================断线重连==================>  mySeat : " .. tostring(self.model.mySeat))
    self.model.isGaming = true
    self.scene:clean()

    --底分
    self.scene:setDiFen(utils:moneyString(s.difen,2))
    -- if s.badd and s.badd == 1 then
    --     --沉默，不播放声音
    --     self.scene:showJiaBei(1,true,true)
    -- end

    --玩家状态
    for k,v in pairs(s.playerstate) do
        local localSeat = self:getLocalSeat(v.seat)
        -- if v.badded and v.badded == 1 and v.badd and v.badd == 1 then
        --     self.scene:showJiaBei(localSeat,true)
        -- end
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
        --修改：服务器已计算好倍率 beilv=jiaofen*(2^炸弹数)服务器限制最大限制
        self.scene:setBeiLv(s.beilv * num)
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

    if s.gamestate == self.define.gameState.SelectChangePoker then
        if s.discardinfo then
            for i , info in pairs(s.discardinfo) do
                local localSeat = self:getLocalSeat(info.seat)
                if info.isdiscard == 0 then
                    self.scene:showSelecting(localSeat)
                    if info.seat == self.model.mySeat then
                        local changepai = s.changepai or {}
                        local _cards = {}
                        for i , v in pairs(changepai) do
                            table.insert(_cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
                        end
                        self.model.exchangeInCards = _cards
                        self.scene:showMySelectingCards(s.endtime , _cards)
                    end
                end
                if info.isdiscard == 1 then
                    local outCards = (info.seat == self.model.mySeat and s.outCards or {}) or {}
                    self.scene:showExchangeOutCards(localSeat,outCards)
                end
            end
        end
    end

    if s.gamestate == self.define.gameState.SelectGetPoker then
        if s.chooseCardInfo then
            for i, info in pairs(s.chooseCardInfo) do
                if info.isChoose == 0 then
                    local localSeat = self:getLocalSeat(info.seat)
                    self.scene:showSelecting(localSeat)
                    if info.seat == self.model.mySeat then
                        local cards = {}
                        for i ,v in pairs(s.canchoosecard or {}) do
                            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
                        end
                        local suggestpokers = {}
                        for i ,v in pairs(s.suggestchoosecard or {}) do
                            table.insert(suggestpokers,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
                        end
                        self.scene:showSelectInCard(cards,suggestpokers,s.endtime)
                    end
                end
            end
        end
    end

    --叫地主
    local dizhuseat = 1
    if s.gamestate == self.define.gameState.JiaoDiZhu then
        local currentSeat = self:getLocalSeat(s.currentseat)
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

    --加倍  也是地主选牌阶段
    if s.gamestate == self.define.gameState.AddMuti then
        if s.jiabeiinfo then
            for i ,v in pairs(s.jiabeiinfo) do
                local localSeat = self:getLocalSeat(v.seat)
                --是否已经操作过
                if v.isoperatejiabei == 1 then
                    --沉默，不播放声音
                    self.scene:showJiaBei(localSeat,v.isjiabei==1,true)
                else
                    if v.seat == self.model.mySeat then
                        self.scene:showJiaBeiButtons(s.endtime,handler(self,self.buJiaBei))
                    else
                        self.scene:showClock(localSeat,s.endtime)
                    end
                end
            end
        end
        if s.isdizhuchoosepoker == 0 then
            local cards = {}
            for i , v in pairs(s.dipai or {}) do
                table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
            end
            local advanceCard = {}
            for i , v in pairs(s.suggestdipai or {}) do
                table.insert(advanceCard,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
            end
            self.model.blindCards = cards
            self.scene:showSelectBlindCards(cards,advanceCard,dizhuseat,s.endtime,false)
        end
    end

    --底牌
    if s.dipai and s.dizhuchoosecard then
        local cards = {}
        for k,v in pairs(s.dipai) do
            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        local discards = utils:copyTable(cards)
        for k , v in pairs(s.dizhuchoosecard ) do
            local id = self.logic:colorNumber2Id(v.cardcolor,v.cardnumber)
            -- 找差集
            for i , v in ipairs(discards) do
                if id == v then
                    table.remove(discards,i)
                    break
                end
            end
        end
        self.model.blindCards = cards
        self.scene:showBlindCards(cards,discards)
    end

    --记牌器
    if s.passcards then
        self.model:resetRemainCard(s.pai)
        for k,v in pairs(s.passcards) do
            self.model:minusRemainCard(k,v)
        end
        self:updateRemainCards()

        if s.discardpokers then
            for k,v in pairs(s.discardpokers) do
                self.model:minusRemainCard(v.cardnumber)
            end
        end
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
        local currentSeat = self:getLocalSeat(s.currentseat)
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
    dump(s,"<==================更新金币==================>")
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
    dump(s,"<==================显示结算==================>",10)
    self.model.isGaming = false
    self.scene:hideAutoChuPaiAnim()
    local info = {}
    info.exitHandler = handler(self,self.quitGame)
    info.continueHandler = handler(self,self.continueGame)

    info.isLord = self.model.isLord
    info.win = false

    info.rows = {}
    local difen = utils:moneyString(self.model.roomInfo.difen,2)

    --修改：服务器已计算好倍率 beilv=jiaofen*(2^炸弹数)服务器限制最大限制
    local beishu = s.jiesuan.beilv or 1
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

    -- printInfo("————————s.jiesuan.chuntian——————————" .. tostring(s.jiesuan.chuntian))
    self:delayInvoke(1,function()
        local delay = self.scene:showResult(info.isLord,info.win,s.jiesuan.chuntian > 1)

        self:delayInvoke(delay,function()
            self.scene:showSettlement(info)
        end)

        self:lockMsgForTime(delay)
    end)
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

   -- s.changepai
    self:lockMsgForTime(1)
    self:delayInvoke(1,function()
        self:s2cStartExchangeOutCards(s)
    end)
end

function C:s2cSetDiZhu(s)
    dump(s,"<==================设置地主==================>")
    local dizhuSeat = self:getLocalSeat(s.dizhuseat)
    self.scene:showDiZhu(dizhuSeat,true)
    self.model.jiaoFen = s.jiaofen or 1
    self.scene:setBeiLv(self.model.jiaoFen)
    self.model.badd = 0
    

    local cards = {}
    local pai = s.pai or {}
    for k,v in pairs(pai) do
        local id = self.logic:colorNumber2Id(v.cardcolor,v.cardnumber)
        table.insert(cards,id)
    end

    local advanceCards = s.advanceCards or {}
    local _advanceCards = {}
    for k,v in pairs(advanceCards) do
        local id = self.logic:colorNumber2Id(v.cardcolor,v.cardnumber)
        table.insert(_advanceCards,id)
    end
    advanceCards = _advanceCards

    self.scene:hideAllJiaoFen()
    local timeOut = self.define.timeout.SetDiZhu
    self.model.blindCards = cards
    self.model.dizhuSeat = dizhuSeat
    self.model.isLord = dizhuSeat == 1
    self.scene:showSelectBlindCards(cards,advanceCards,dizhuSeat,timeOut  --[[动画时间]],true)
end

function C:s2cDizhuSelectFinish(s)

    dump(s,"<==================设置地主==================>   2138  ")

--  self.preform

    -- 播放飞牌动画
    -- 显示牌的选择结果
    -- 设置玩家牌的数量
    -- 设置地主的底牌
    local cardNumTab = s.remainnum or {}
    if self.model.dizhuSeat ~= 1 then
        for i , info in ipairs(cardNumTab) do
            local localSeat = self:getLocalSeat(info.seat)
            if localSeat ~= self.model.dizhuSeat then
                self.scene:showRemainCardNumber(localSeat,info.num)
            end
        end
    end

    local cards = s.pokers      -- 选择的牌
    if cards then
        local _cards = {}
        for k,v in pairs(cards) do
            local id = self.logic:colorNumber2Id(v.cardcolor,v.cardnumber)
            table.insert(_cards,id)
        end
        cards = _cards
    end

    dump(cards,"________s2cDizhuSelectFinish___________s___")
    dump(self.model.blindCards,"________s2cDizhuSelectFinish___________blindCards___")

    if self.preform and self.model:isSameCards(cards) then
        -- do nothing
    else
        if self.model.dizhuSeat == 1 then
            for k ,id in ipairs(cards) do
                table.insert(self.model.myCards,id)
            end
        end

        local discards = {}
        if self.model.blindCards and cards then
            for i , id in ipairs(self.model.blindCards) do
                local isFound = false
                for i ,bId in ipairs(cards) do
                    if id == bId then
                        isFound = true
                        break
                    end
                end
                if not isFound then
                    table.insert(discards,id)
                end
            end
        end

        dump(discards,"________s2cDizhuSelectFinish___________discards___")
        if self.model.dizhuSeat == 1 then
            self.scene:createMyCards(self.model.myCards,false,true)
            self:c2sGetMyCard()
        end
        local callback = function()
            self.scene:hideDizhuSelectCard()
            self.scene:showBlindCards(self.model.blindCards,discards)
        end
        self.scene:playMoveToBlind(callback)
    end

    -- 最后修正一次记牌器
    local pai = {}
    for i , id in ipairs(self.model.myCards) do
        local card = self.logic:id2ColorNumber(id)
        table.insert(pai,card)
    end
    for i , card in pairs(s.discardpokers or {}) do
        table.insert(pai,card)
    end
    self.model:resetRemainCard(pai)

    self.preform = false
    self:lockMsgForTime(1)
end

function C:s2cSetGameState(s)
    dump(s,"<==================游戏状态==================>")
    self.model.logKey = s.logkey
    self.model.gameState = s.gamestate
    if s.gamestate == self.define.gameState.JiaoDiZhu then
        self.scene:hideAllClocks()
        self.scene:hideAllSelecting()
    elseif s.gamestate == self.define.gameState.AddMuti then
        self.scene:hideAllClocks()
        self.scene:hideAllJiaoFen()
        self.scene:hideAllSelecting()
        self.scene:hideAllSelecting()
    elseif s.gamestate == self.define.gameState.Game then
        self.scene:hideAllClocks()
        self.scene:hideAllJiaoFen()
        --self.scene:hideAllJiaBei()
        self:updateRemainCards()
        self.scene:showJiPaiQi()
        self.scene:setAllCardsClickable(true)
    elseif s.gamestate == self.define.gameState.SelectChangePoker then
        self.scene:setAllCardsClickable(true)
    elseif s.gamestate == self.define.gameState.SelectGetPoker then
        self.scene:setAllCardsClickable(false)
        self.scene:hideExchangeOutNode()
        self.scene:unselectAllCards()
    elseif s.gamestate == self.define.gameState.DizhuSelectPoker then
        self.scene:setAllCardsClickable(false)
        self.scene:unselectAllCards()
    else
        self.scene:setAllCardsClickable(false)
        self.scene:unselectAllCards()
    end
end

function C:s2cPlayerJiaoDiZhu(s)
    dump(s,"<==================玩家叫分==================>")
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
    self.scene:showDizhuSelectCardBg()
end

function C:s2cPlayerJiaoDiZhuTimeout(s)
    dump(s,"<==================叫分超时==================>")
    local localSeat = self:getLocalSeat(s.seat)
    if localSeat == 1 then
        self.scene:hideJiaoFenButtons()
    end
    self.scene:showJiaoFen(localSeat,0)
    self.scene:hideClock(localSeat)

end

function C:s2cPlayerJiaoDiZhuPass(s)
    dump(s,"<==================玩家不叫==================>")
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
    dump(s,"<==================通知叫分==================>")
	self.preform = false
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
    dump(s,"<==================玩家加倍==================>")
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideClock(localSeat)
    if localSeat ~= 1 then
        local add = s.badd or 0
        --不沉默，播放声音
        self.scene:showJiaBei(localSeat,add == 1,false)
    else
        self.scene:hideJiaBeiButtons()
        self.model.badd = s.badd or 0
        local num = self.model.badd == 1 and 2 or 1
        self.scene:setBeiLv(self.model.jiaoFen * num)
        if self.model.isTuoGuan or not self.preform then
            --不沉默，播放声音
            self.scene:showJiaBei(localSeat,self.model.badd == 1,false)
        end
        self.preform = false
    end
end

function C:s2cNotifyPlayerAddMuti(s)
    dump(s,"<==================通知加倍==================>")
	self.preform = false

    self.scene:hideAllClocks()
    for localSeat = 1 , 3 do
        if localSeat ~= self.model.dizhuSeat then         
            self.scene:hideJiaoFen(localSeat)
            if localSeat == 1 then
                if not self.model.isTuoGuan then
                    self.scene:showJiaBeiButtons(self.define.timeout.JiaBei,handler(self,self.buJiaBei))
                end
            else
                self.scene:showClock(localSeat,self.define.timeout.JiaBei)
            end
        end
    end
end

function C:s2cNotifyChuPai(s)
    dump(s,"<==================通知出牌==================>" .. tostring(self.model.mySeat))
    local localSeat = self:getLocalSeat(s.seat)
    self.scene:hideAllClocks()
    self.scene:hideJiaBei(localSeat)
    self.scene:hideCards(localSeat)
    self.scene:hideBuYao(localSeat)

	self.preform = false

    local time = self.define.timeout.ChuPai
    if s.optime then time = s.optime end
    if localSeat == 1 then
        self.model.isMyTurn = true
        local first = s.firstchupai == 1
        if not self.model.isTuoGuan then
            if #self.logic:getAllHints() == 0 then
                self.scene:showYaoBuQiButtons(time,handler(self,self.buYao))
				self.scene:unselectAllCards()
            else
                if self.model.autoShowCard and #self.model.myCards == 1 then
                    dump(self.model.myCards)
                    self:chuPai(self.model.myCards)
                else
					if self.model.selectedCards and #self.model.selectedCards > 0 then
						self.scene:resetShowedSelectedHintCards()
					end
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
    dump(s,"<==================玩家出牌==================>")
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
        dump(self.model.myCards,"self.model.myCards")
        if not self.model:isSameShowCards(cards) then
            self:c2sGetMyCard()
            self.scene:showCards(1,cards,false,false, s.remainnum == 0)
        elseif self.model.isTuoGuan or not self.preform then
            self.scene:playMyCards(cards)
            self.scene:showCards(1,cards,true,false,s.remainnum == 0)
        end
        self.scene:hideChuPaiButtons()
        self.scene:hideYaoBuQiButtons()

        if #self.model.myCards == 1 and not self.model.isTuoGuan then
            self.scene:playAutoChuPaiAnim()
        end
        printInfo(">>>>>>>>>self.model.myCards>>>>>>>>>>>>"..#self.model.myCards)
        if #self.model.myCards == 0 then
            self.scene:hideAutoChuPaiAnim()
        end
        self.preform = false
    else
        self.model.lastCards = cards
        self.logic:setOtherCards(self.logic:protoToCards(cards))
        self.scene:showRemainCardNumber(localSeat,s.remainnum)
        self.scene:showCards(localSeat,cards,true,false,s.remainnum == 0)
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
    dump(s,"<==================玩家托管==================>" .. tostring(self.model.mySeat))
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
    dump(s,"<==================显示手牌==================>")

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
    dump(s,"<==================设置倍率==================>")
    local num = self.model.badd == 1 and 2 or 1
    --修改：服务器已计算好倍率 beilv=jiaofen*(2^炸弹数)服务器限制最大限制
    self.scene:setBeiLv(s.beilv * num)
end

function C:s2cSetPlayerState(s)
    dump(s,"<==================玩家状态==================>"  .. tostring(self.model.mySeat))
    local localSeat = self:getLocalSeat(s.seat)
    local isTuoGuan = s.state == 1
    if isTuoGuan then
        self.scene:showTuoGuan(localSeat)
        if localSeat == 1 then
            self.scene:hideChuPaiButtons()
            self.scene:hideJiaBeiButtons()
            self.scene:hideJiaoFenButtons()
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
    dump(s,"<==================我的手牌==================>")
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
    self:sendGameMsg(self.define.proto.CS_CPDDZ_JIAODIZHU_PASS_P);
end

--玩家叫地主(不需要有具体信息)
--<param name="fen">叫几分</param>
function C:c2sJiaoDiZhu(fen)
    self:sendGameMsg(self.define.proto.CS_CPDDZ_JIAODIZHU_P, {jiaofen = fen})
end

--一个玩家过牌(不需要有具体信息)
function C:c2sChuPaiPass()
    self:sendGameMsg(self.define.proto.CS_CPDDZ_CHUPAI_PASS_P);
end

--出牌
function C:c2sChuPai(cards)
    local pai = {}
    for k,v in pairs(cards) do
        table.insert(pai,self.logic:id2ColorNumber(v))
    end
    self:sendGameMsg(self.define.proto.CS_CPDDZ_CHUPAI_P, {pai = pai})
end

--换牌（换出）
function C:c2sExchangeOut(cards)
    local pai = {}
    for k,v in ipairs(cards) do
        table.insert(pai,self.logic:id2ColorNumber(v))
    end
    self:sendGameMsg(self.define.proto.CS_CPDDZ_CHANGEPOKER_P, {pai = pai})
end

--换牌（换入）
function C:c2sExchangeIn(cards)
    local pai = {}
    for k,v in pairs(cards) do
        table.insert(pai,self.logic:id2ColorNumber(v))
    end
    self:sendGameMsg(self.define.proto.CS_CPDDZ_CHOOSEPOKER_P, {pai = pai})
end

--选择的地主牌
function C:c2sSelectDizhuCards(cards)
    local pai = {}
    for k,v in pairs(cards) do
        table.insert(pai,self.logic:id2ColorNumber(v))
    end
    self:sendGameMsg(self.define.proto.CS_CPDDZ_DZCHOOSEPOKER_P, {pai = pai})
end

--玩家加倍 不加倍
function C:c2sJiaBeiOrBuJiaBei(add)
    self:sendGameMsg(self.define.proto.CS_CPDDZ_PLAYER_ADD_MUTI_P, {badd = add and 1 or 0});
end

--向服务器请求自己的手牌，每一次出牌后，都必须由服务器重新刷新一次自己的手牌
function C:c2sGetMyCard()
    self:sendGameMsg(self.define.proto.CS_CPDDZ_ANYONEPLAYERPAI_P);
end

--向服务器请求托管
function C:c2sTuoGuan()
    self:sendGameMsg(self.define.proto.CS_CPDDZ_TUOGUAN_P);
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
    self.scene:updateExchangeOutBtn()
end

--选牌
function C:selectCard(id)
    self.scene:updateExchangeOutBtn()
end

--不叫
function C:buJiao()
    if self.preform then
        return
    end
    self.scene:hideJiaoFenButtons()
    self.scene:showJiaoFen(1,0)
    self:c2sJiaoDiZhuPass()
    self.preform = true
end

--叫分
function C:jiaoFen(fen)
    if self.preform then
        return
    end
    self.scene:hideJiaoFenButtons()
    self.scene:showJiaoFen(1,fen)
    self:c2sJiaoDiZhu(fen)
    self.preform = true
end

--不加倍
function C:buJiaBei()
    if self.preform then
        return
    end
    self.scene:hideJiaBeiButtons()
    self.scene:showJiaBei(1,false,false)
    self:c2sJiaBeiOrBuJiaBei(false)
    self.preform = true
end

--加倍
function C:jiaBei()
    if self.preform then
        return
    end
    self.scene:hideJiaBeiButtons()
    self.scene:showJiaBei(1,true,false)
    self:c2sJiaBeiOrBuJiaBei(true)
    self.preform = true
end

--不要
function C:buYao()
    if self.preform then
        return
    end
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
    if self.preform then
        return
    end
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

-- 换出
function C:onExchangeOut(cards)
    if #cards == 3 then
        self:c2sExchangeOut(cards)
        self.scene:hideExchangeOutNode()
        self.scene:playMyCards(cards)
        self.scene:unselectAllCards()
        self.scene:showExchangeOutCards(1,cards)
        self.preform = true
    end
end

-- 换入
function C:onExchangeIn(cards)
    self:c2sExchangeIn(cards)
    self.scene:hideSelectInCard()
    self.model.exchangeInCards = cards
    if cards and #cards > 0 then
        for i ,v in ipairs(cards) do
            table.insert(self.model.myCards,v)
        end
        self.scene:createMyCards(self.model.myCards,false,false,true)
    end
    self.preform = true
end

-- 选择地主牌
function C:onSelectDizhuCards(cards)
    if cards and #cards >= 2 then
        self.scene:hideDizhuSelectCard(true)
        self:c2sSelectDizhuCards(cards)

        -- 预表现
        local discards = {}
        if self.model.blindCards and cards then
            for i , id in ipairs(self.model.blindCards) do
                local isFound = false
                for i ,bId in ipairs(cards) do
                    if id == bId then
                        isFound = true
                        break
                    end
                end
                if not isFound then
                    table.insert(discards,id)
                else
                    table.insert(self.model.myCards,id)
                end
            end
        end
        self.scene:createMyCards(self.model.myCards,false,true)
        local callback = function()
            self.scene:hideDizhuSelectCard()
            self.scene:showBlindCards(self.model.blindCards,discards)
        end
        self.scene:playMoveToBlind(callback)

        self.preform = true
    else
        self.scene:playNoticeEnough()
    end
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

-- region 换牌
function C:s2cStartExchangeOutCards(s)
    -- 推荐换的牌
    -- 显示倒计时
    local timeOut = self.define.timeout.ExchangeOut
    local advanceSelectingCards = s.changepai

    self.scene:showAllSelecting()
    if advanceSelectingCards then
        local cards = {}
        for k,v in pairs(advanceSelectingCards) do
            table.insert(cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        self.scene:showMySelectingCards(timeOut - 1 ,cards)
    end
    self:lockMsgForTime(1)
end

-- 通知一个玩家选出了要换的牌
function C:s2cExchangeOutCards(s)
    -- 其它玩家出牌的位置上显示要换的牌
    -- 其它玩家就是盖牌
    -- 自己是开牌
    local seat = s.seat
    local cards = s.outCards or {}

    if not seat then
        return
    end

    local localSeat = self:getLocalSeat(seat)
    self.scene:hideSelecting(localSeat)

    if cards then
        local _cards = {}
        for k,v in pairs(cards) do
            table.insert(_cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        cards = _cards
    end

    if localSeat == 1 then
        if not self.model:isSameCards(cards) and self.preform then
        else
            self.scene:hideExchangeOutNode()
            self.scene:playMyCards(cards)
            self:c2sGetMyCard()
        end
        self.preform = false
    end
    self.scene:showExchangeOutCards(localSeat,cards)
    self:lockMsgForTime(1)
end

-- 选择要换出的环节结束
function C:s2cExchangeOutCardsFinish(s)

    -- 服务器告知自己能够选进的牌
    -- 选进动画
    local cards = s.pokers
    local isClockWise = s.direction
    local suggestpokers = s.suggestpokers or {}
    local timeOut = self.define.timeout.ExchangeOutCardsFinish
    -- 初始化数据
    if cards then
        local _cards = {}
        for k,v in pairs(cards) do
            table.insert(_cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        cards = _cards
    end

    if suggestpokers then
        local _cards = {}
        for k,v in pairs(suggestpokers) do
            table.insert(_cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        suggestpokers = _cards
    end

    self.model.exchangeInCards = {}
    for i , id in ipairs(cards) do
        self.model.exchangeInCards[id] = false
    end

    self.scene:hideAllSelecting()
    self.scene:turnBackCards(function()
        self.scene:hideAllExchangeOutCards()
        PLAY_SOUND(GAME_CPDDZ_SOUND_RES .. "bblord_exchange_cards.mp3")
        self.scene:playExchangeSpringAnim(isClockWise,function()
            self.scene:hideExchangeSpringAnim()
            self.scene:showSelecting(2)  -- 两个都是选牌中
            self.scene:showSelecting(3)
            self.scene:turnFrontCards(cards,function()
                self.scene:hideAllExchangeOutCards()
                self.scene:showSelectInCard(cards,suggestpokers,timeOut - (0.8 + 1.8 + 1.8) --[[动画时间]])
                self:lockMsgForTime(0.1)
            end)
        end)
    end)
    self:lockMsgForTime(10)
end

-- 通知一个玩家选进了牌
function C:s2cExchangeInCards(s)

    -- 通知一个玩家选进了牌
    local seat = s.seat
    local cardsNum = s.cardnum
    local cards = s.cards
    local myCards = s.myCards

    if cards then
        local _cards = {}
        for k,v in pairs(cards) do
            table.insert(_cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        cards = _cards
    end

    if myCards then
        local _cards = {}
        for k,v in pairs(myCards) do
            table.insert(_cards,self.logic:colorNumber2Id(v.cardcolor,v.cardnumber))
        end
        myCards = _cards
    end

    if seat == self.model.mySeat then
        if self.preform  and self.model:isSameCards(cards) then
        else
            self.scene:hideSelectInCard()
            self.model.exchangeInCards = cards
            self.model.myCards = myCards
            self.scene:createMyCards(self.model.myCards,false,false,true)
            self:c2sGetMyCard()
        end
        for k , v in pairs(s.cards or {}) do
            self.model:minusRemainCard(v.cardnumber)
        end
        self.preform = false
    end
    local localSeat = self:getLocalSeat(seat)
    self.scene:finishExchangeInCards(localSeat,cards,cardsNum)
    self:lockMsgForTime(0.5)
end

-- endregion











return C