local C = class("GameCoreBase",CoreBase)
GameCoreBase = C

--场景配置
C.SCENE_CONFIG = {scenename = "", filename = "", logic="", define="", model=""}
--游戏逻辑
C.logic = nil
--游戏定义
C.define = nil
--模型
C.model = nil

function C:ctor(roomInfo)
	C.super.ctor(self)
    self.define = require( self.MODULE_PATH.."."..self.SCENE_CONFIG["define"])
	self.logic = require( self.MODULE_PATH.."."..self.SCENE_CONFIG["logic"]).new()
	self.model = require( self.MODULE_PATH.."."..self.SCENE_CONFIG["model"]).new()
    self.model.roomInfo = roomInfo
    self.model.myInfo = dataManager.userInfo
    self.model.myPlayerId = dataManager.playerId
end

function C:run(transition, time, more)
    C.super.run(self, transition, time, more)
    self.scene.logic = self.logic
    self.scene.define = self.define
    self.scene.model = self.model
end

function C:start()
    self:registerCommonMsg()
    --充值
    self.configsResultHandler = handler(self,self.responseRechargeConfig)
    eventManager:on("ConfigResult",self.configsResultHandler)
    UnlockMsg()
end

function C:exit()
    self:unregisterCommonMsg()
    --充值
    eventManager:off("ConfigResult",self.configsResultHandler)
    --解锁消息，避免因为子游戏里通过延迟调用锁住消息，定时器被清除，没有回调，导致没有解锁
    UnlockMsg2()
    self.logic = nil
    self.define = nil
    self.model = nil
    C.super.exit(self)
end

function C:registerCommonMsg()
    Register(MainProto.Game, Game.SC_ROOM_PLAYER_ENTER_P, handler(self,self.onPlayerEnter));
    Register(MainProto.Game, Game.SC_ROOM_INFO_P, handler(self,self.onRoomInfo));
    Register(MainProto.Game, Game.SC_ROOM_SET_STATE_P, handler(self,self.onRoomState));
    Register(MainProto.Game, Game.SC_ROOM_SET_PLAYER_STATE_P, handler(self,self.onPlayerState));
    Register(MainProto.Game, Game.SC_ROOM_PLAYER_QUIT_P, handler(self,self.onPlayerQuit));
    Register(MainProto.Game, Game.SC_ROOM_DEL_PLAYER_P, handler(self,self.onDeletePlayer));
    Register(MainProto.XC, XC.XC_ROOM_INFO_P, handler(self,self.onToOtherRoom));
    Register(MainProto.Game, Game.SC_ROOM_RESET_COIN_P, handler(self,self.updatePlayerMoney));
    Register(MainProto.Game, Game.SC_MODE1_ENTER_PIPEI_P, handler(self,self.onStartMatch));
    Register(MainProto.Game, Game.SC_MODE1_PIPEI_OVER_P, handler(self,self.onFinishMatch));
    Register(MainProto.XC, XC.XC_JIESUAN_P, handler(self,self.onSettlement));

    Register(MainProto.Game, Game.SC_ROOM_DEL_P, handler(self,self.onQuitGame));
    printInfo("registerCommonMsg")
end

function C:unregisterCommonMsg()
    UnRegister(MainProto.Game,Game.SC_ROOM_PLAYER_ENTER_P)
    UnRegister(MainProto.Game,Game.SC_ROOM_INFO_P)
    UnRegister(MainProto.Game,Game.SC_ROOM_SET_STATE_P)
    UnRegister(MainProto.Game,Game.SC_ROOM_SET_PLAYER_STATE_P)
    UnRegister(MainProto.Game,Game.SC_ROOM_PLAYER_QUIT_P)
    UnRegister(MainProto.Game,Game.SC_ROOM_DEL_PLAYER_P)
    UnRegister(MainProto.XC,XC.XC_ROOM_INFO_P)
    UnRegister(MainProto.Game,Game.SC_ROOM_RESET_COIN_P)
    UnRegister(MainProto.Game,Game.SC_MODE1_ENTER_PIPEI_P)
    UnRegister(MainProto.Game,Game.SC_MODE1_PIPEI_OVER_P)
    UnRegister(MainProto.XC, XC.XC_JIESUAN_P)
end

function C:registerGameMsg(proto,callback)
    Register(MainProto.XC,proto,callback)
end

function C:unregisterGameMsg(proto)
    UnRegister(MainProto.XC,proto)
end

--发送协议
function C:sendCommonMsg( mainProto, subProto, info )
    SendGameServer(mainProto,subProto,info)
end

--发送游戏协议
function C:sendGameMsg( subProto, info )
    self:sendCommonMsg(MainProto.XC,subProto,info)
end

--玩家点击返回退出游戏
function C:quitGame()
    self:sendQuitMsg()
    ENTER_HALL_ROOM(self.model.roomInfo.gameid)
end

--获取充值配置信息
function C:requestRechargeConfig()
    loadingLayer:show("正在获取充值信息...")
    eventManager:publish("Config")
end

--显示充值页面
function C:responseRechargeConfig( info )
    loadingLayer:hide() 
    self.scene:showRechargeLayer(info)
end

--发送退出协议
function C:sendQuitMsg()
    self:sendCommonMsg(MainProto.Game,Game.CS_QUIT_P)
end

--发送匹配协议
function C:sendMatchMsg()
    self:sendCommonMsg(MainProto.Game,Game.CS_MODE1_ENTER_PIPEI_P)
end

--开始匹配
function C:onStartMatch( info )
    --dump(info,"onStartMatch")
end

--匹配成功
function C:onFinishMatch( info )
    --dump(info,"onFinishMatch")
end

--玩家加入
function C:onPlayerEnter( info )
    --dump(info,"onPlayerEnter")
end

--玩家离开
function C:onPlayerQuit( info )
    --dump(info,"onPlayerQuit")
    printInfo("========onPlayerQuit"..os.time())
end

--游戏结束,你条件不满足被踢出房间,如果你在暂离状态,也会被踢出房间
function C:onDeletePlayer( info )
    printInfo("===onDeletePlayer====:"..os.time())
end

--玩家状态
function C:onPlayerState( info )
    dump(info,"onPlayerState")
end

--更新玩家金币
function C:updatePlayerMoney( info )
    --dump(info,"updatePlayerMoney")
    if info.playerid == dataManager.playerId then
        dataManager.userInfo.money = info.coin
        eventManager:publish("Money",info.coin)
        if self.model.myInfo then
            self.model.myInfo["money"] = info.coin
        end
    end
end

--进入房间，房间信息
function C:onRoomInfo( info )
    --dump(info,"onRoomInfo",10)
end

--房间状态
function C:onRoomState( info )
    --dump(info,"onRoomState")
end

--断线重连
function C:onToOtherRoom( info )
    --dump(info,"onToOtherRoom",10)
end

--结算
function C:onSettlement( info )
    --dump(info,"onSettlement",10)
end

function C:onQuitGame(info)
    if SCENE_NAME ~= "Hall" then
        self:quitGame()
    end
end

return GameCoreBase