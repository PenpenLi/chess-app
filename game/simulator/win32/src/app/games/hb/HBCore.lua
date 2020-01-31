local C = class("HBCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.hb"
--场景配置
C.SCENE_CONFIG = {scenename = "hb_scene", filename = "HBScene", logic="HBLogic", define="HBDefine", model="HBModel"}

function C:start()
    self:registerGameMsg(HB.CMD.APPLY_BANK,handler(self.scene,self.scene.newBomb))
    self:registerGameMsg(HB.CMD.CANCAL_BANK,handler(self.scene,self.scene.cancalBomb))
    self:registerGameMsg(HB.CMD.CHANGE_SCANCE,handler(self.scene,self.scene.changeStatge))
    self:registerGameMsg(HB.CMD.ROD_RED,handler(self.scene,self.scene.playerRob))
    self:registerGameMsg(HB.CMD.ROD_RED_BACK,handler(self.scene,self.scene.handleLeftRed))
    self:registerGameMsg(HB.CMD.BANK_RED_WINLOSER,handler(self.scene,self.scene.bankerWin))
    self:registerGameMsg(HB.CMD.FAILD_RESULT,handler(self.scene,self.scene.failed))
    self:registerGameMsg(HB.CMD.STATUSFREE,handler(self.scene,self.scene.FreeGameScene))

--    eventManager:on("OpenCannonKuangbao",self.OpenCannonKuangbao)
--    eventManager:on("OpenCannonDouble",self.OpenCannonDouble)

    C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(HB.CMD.APPLY_BANK)
	self:unregisterGameMsg(HB.CMD.CANCAL_BANK)
	self:unregisterGameMsg(HB.CMD.CHANGE_SCANCE)
	self:unregisterGameMsg(HB.CMD.ROD_RED)
	self:unregisterGameMsg(HB.CMD.FAILD_RESULT)
	self:unregisterGameMsg(HB.CMD.STATUSFREE)

--    self.OpenCannonKuangbao = handler(self.scene,self.scene.OpenCannonKuangbao)
--    self.OpenCannonDouble = handler(self.scene,self.scene.OpenCannonDouble)

--    eventManager:off("OpenCannonKuangbao",self.OpenCannonKuangbao)
--    eventManager:off("OpenCannonDouble",self.OpenCannonDouble)

	C.super.exit(self)
end

--进入房间，房间信息
function C:onRoomInfo( s )
--    dump(s, "<==================房间信息==================>")
    self.model:updateAllPlayerList(s.playerlist)
    self.scene:clearPlayers()
    for k,v in pairs(s.playerlist) do
        if v.playerid == self.model.myPlayerId then
            self.model.mySeatId = v.seat
--            self.scene:ISitDown(v.playerid, v.seat)
        else
--            self.scene:SomeOneSitDown(v.playerid, v.seat)
        end
        self.scene:updatePlayers(v)
    end
end

--玩家加入
function C:onPlayerEnter( info )
    C.super.onPlayerEnter(self,info)
    self.model:addPlayer(info)
    self.scene:updatePlayers(info)
end

--玩家离开
function C:onPlayerQuit( info )
    C.super.onPlayerQuit(self,info)
    local playerId = info["playerid"]
    self.model:removePlayer(playerId)
    self.scene:updatePlayers(info, true)
--    self.scene:SomebodyLeave(playerId, info.seat)
--    if playerId == dataManager.userInfo["playerid"] then
--    else
--    end
end

--断线重连
function C:onToOtherRoom( info )
    C.super.onToOtherRoom(self,info)
end

--房间状态
function C:onRoomState( info )
    C.super.onRoomState(self,info)
end

--更新玩家金币
function C:updatePlayerMoney( info )
	C.super.updatePlayerMoney(self,info)
    if info.playerid == dataManager.playerId then
        dataManager.userInfo.money = info.coin
        eventManager:publish("Money",info.coin)
        self.model.myInfo["money"] = info.coin
    end
--    self.scene:updatePlayerMoney(info.playerid,info.coin)
end


return C