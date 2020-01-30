local C = class("FruitCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.fruit"
--场景配置
C.SCENE_CONFIG = {scenename = "fruit_scene", filename = "FruitScene", logic="FruitLogic", define="FruitDefine", model="FruitModel"}

function C:start()
    self:registerGameMsg(FRUIT.CMD.SUB_S_PULL,handler(self.scene,self.scene.startRun))
    self:registerGameMsg(FRUIT.CMD.SUB_S_MARRY,handler(self.scene,self.scene.startLGame))
    self:registerGameMsg(FRUIT.CMD.SUB_S_STATUSFREE,handler(self.scene,self.scene.FreeGameScene))

--    eventManager:on("OpenCannonKuangbao",self.OpenCannonKuangbao)
--    eventManager:on("OpenCannonDouble",self.OpenCannonDouble)

    C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(FRUIT.CMD.SUB_S_PULL)
	self:unregisterGameMsg(FRUIT.CMD.SUB_S_MARRY)
	self:unregisterGameMsg(FRUIT.CMD.SUB_S_STATUSFREE)

--    self.OpenCannonKuangbao = handler(self.scene,self.scene.OpenCannonKuangbao)
--    self.OpenCannonDouble = handler(self.scene,self.scene.OpenCannonDouble)

--    eventManager:off("OpenCannonKuangbao",self.OpenCannonKuangbao)
--    eventManager:off("OpenCannonDouble",self.OpenCannonDouble)

	C.super.exit(self)
end

--进入房间，房间信息
function C:onRoomInfo( s )
    printInfo("<==================房间信息==================>")
--    self.model:updateAllPlayerList(s.playerlist)
    for k,v in pairs(s.playerlist) do
        if v.playerid == self.model.myPlayerId then
            self.model.mySeatId = v.seat
--            self.scene:ISitDown(v.playerid, v.seat)
        else
--            self.scene:SomeOneSitDown(v.playerid, v.seat)
        end
--        self.model:setPlayerInfo(v)
    end
end

--玩家加入
function C:onPlayerEnter( info )
    C.super.onPlayerEnter(self,info)
end

--玩家离开
function C:onPlayerQuit( info )
    C.super.onPlayerQuit(self,info)
    local playerId = info["playerid"]
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