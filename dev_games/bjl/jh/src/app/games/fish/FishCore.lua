local C = class("FishCore",GameCoreBase)

--模块路径
C.MODULE_PATH = "app.games.fish"
--场景配置
C.SCENE_CONFIG = {scenename = "fish_scene", filename = "FishScene", logic="FishLogic", define="FishDefine", model="FishModel"}

function C:start()
    self:registerGameMsg(FISH.CMD.SUB_S_CHANGE_SCENE,handler(self.scene,self.scene.S_Change_Scene))
    self:registerGameMsg(FISH.CMD.SUB_S_FIRE_FAILED,handler(self.scene,self.scene.S_Fire_Failed))
    self:registerGameMsg(FISH.CMD.SUB_S_CATCH_BIRD,handler(self.scene,self.scene.S_Catch_Bird))
    self:registerGameMsg(FISH.CMD.SUB_S_SEND_BIRD,handler(self.scene,self.scene.S_Send_Bird))
    self:registerGameMsg(FISH.CMD.SUB_S_SEND_BULLET,handler(self.scene,self.scene.S_Send_Bullet))
    self:registerGameMsg(FISH.CMD.SUB_S_SEND_BIRD_LINEAR,handler(self.scene,self.scene.S_Send_Bird_Linear))
    self:registerGameMsg(FISH.CMD.SUB_S_SEND_BIRD_ROUND,handler(self.scene,self.scene.S_Send_Bird_Round))
    self:registerGameMsg(FISH.CMD.SUB_S_SEND_BIRD_PAUSE_LINEAR,handler(self.scene,self.scene.S_Send_Bird_Pause_Linear))
    self:registerGameMsg(FISH.CMD.SUB_S_STATUS_FREE,handler(self.scene,self.scene.S_StatusFree))

    self.OpenCannonKuangbao = handler(self.scene,self.scene.OpenCannonKuangbao)
    self.OpenCannonDouble = handler(self.scene,self.scene.OpenCannonDouble)

    eventManager:on("OpenCannonKuangbao",self.OpenCannonKuangbao)
    eventManager:on("OpenCannonDouble",self.OpenCannonDouble)

    C.super.start(self)
end

function C:exit()
	self:unregisterGameMsg(FISH.CMD.SUB_S_CHANGE_SCENE)
	self:unregisterGameMsg(FISH.CMD.SUB_S_FIRE_FAILED)
	self:unregisterGameMsg(FISH.CMD.SUB_S_CATCH_BIRD)
	self:unregisterGameMsg(FISH.CMD.SUB_S_SEND_BIRD)
	self:unregisterGameMsg(FISH.CMD.SUB_S_SEND_BULLET)
	self:unregisterGameMsg(FISH.CMD.SUB_S_SEND_BIRD_LINEAR)
	self:unregisterGameMsg(FISH.CMD.SUB_S_SEND_BIRD_ROUND)
	self:unregisterGameMsg(FISH.CMD.SUB_S_SEND_BIRD_PAUSE_LINEAR)
	self:unregisterGameMsg(FISH.CMD.SUB_S_STATUS_FREE)

    eventManager:off("OpenCannonKuangbao",self.OpenCannonKuangbao)
    eventManager:off("OpenCannonDouble",self.OpenCannonDouble)

	C.super.exit(self)
end

function C:run(transition, time, more)
    C.super.run(self, transition, time, more)
end


--进入房间，房间信息
function C:onRoomInfo( s )
    printInfo("<==================房间信息 保证我自己先坐下==================>")
    self.model:updateAllPlayerList(s.playerlist)
    for k,v in pairs(s.playerlist) do
        if v.playerid == self.model.myPlayerId then
            self.model.mySeatId = v.seat
            self.scene:ISitDown(v.playerid, v.seat)
        end
    end
    for k,v in pairs(s.playerlist) do
        if v.playerid ~= self.model.myPlayerId then
            self.scene:SomeOneSitDown(v.playerid, v.seat)
        end
    end
end

--玩家加入
function C:onPlayerEnter( info )
    C.super.onPlayerEnter(self,info)
    self.model:addPlayer(info)
    self.scene:SomeOneSitDown(info.playerid, info.seat)
end

--玩家离开
function C:onPlayerQuit( info )
    C.super.onPlayerQuit(self,info)
    local playerId = info["playerid"]
    local info = self.model:getPlayer2(playerId)
    if info then
        self.scene:SomebodyLeave(playerId, info.seat)
    end
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
    self.scene:updatePlayerMoney(info.playerid,info.coin)
end


return C