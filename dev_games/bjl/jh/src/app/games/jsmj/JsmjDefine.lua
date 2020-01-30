--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local proto = 
{
    SC_START_SEND_CARD = 2000,        --发牌
    CS_SEND_CARD_END = 2001,          --发牌(C->S)
    SC_GAME_START = 2002,             --游戏开始
		
	SC_OUT_CARD = 2003,               --玩家出牌
	CS_OUT_CARD = 2004,               --用户出牌(C->S)

	SC_DISPATCH_CARD = 2005,          --分发扑克
		
	CS_TRUSTEE = 2006,                --用户托管(C->S)
	SC_TRUSTEE = 2007,                --用户托管

	CS_OPERATE = 2008,                --用户操作(C->S)
    SC_GAME_OVER = 2009,              --游戏结束
	SC_USER_STATUS = 1010,            --玩家状态
}

local gameState = 
{ 
    Init = 0,                              --初始值
    GameStart = 1,                         --游戏开始,开始设置庄家
    FaPai = 2,                             --庄家设置结束,开始发牌
    JiaoDiZhu = 3,                         --发牌结束,开始叫地主
    AddMuti = 4,                           --加倍圈
    Game = 5,                              --倍率和地主和底牌设置结束,开始游戏
    Over = 6,                              --游戏结束,显示所有牌面并开始结算
    GameOver = 7,                          --结算结束,游戏同时结束.
}

local playerGameState =
{
    UnPrepare = 0,                        --未准备					未开始游戏
    Prepare = 1,                          --准备						未开始游戏	开始游戏
    Game = 2,                             --游戏中								开始游戏
    Leave = 3,                            --离线托管状态							开始游戏
    ZanLi = 4,                            --暂时离开								开始游戏
}

local roomState =	
{
    Wait = 0,                               --等待状态				
    Game = 1,                               --游戏状态
    Delete = 2,                             --删除状态
    UnInit = 3,                             --还未初始化状态
}

local identity =
{
    Farmer,
    Landlord,
    None,
}

local timeout = 
{
    DiZhuFirstChuPai = 30,
    JiaoFen = 15,
    JiaBei = 10,
    ChuPai = 15
}

local MahjongPos = 
{ 
    POSITION_UNKNOWN = 0,
    POSITION_BOTTOM = 1,
    POSITION_TOP = 2,
    POSITION_RIGHT = 3,
    POSITION_LEFT = 4,

    POSITION_DISCARD_BOTTOM = 11,
    POSITION_DISCARD_TOP = 12,
    POSITION_DISCARD_RIGHT = 13,
    POSITION_DISCARD_LEFT = 14,

    TILE_SHOW_STATE_STAND = 21,
    TILE_SHOW_STATE_FACE = 22,
    ILE_SHOW_STATE_BACK = 23
}

return {proto = proto,gameState = gameState,playerGameState = playerGameState,roomState = roomState,identity = identity,timeout = timeout,MahjongPos = MahjongPos}

--endregion
