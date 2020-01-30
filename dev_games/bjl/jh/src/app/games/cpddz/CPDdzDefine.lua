--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local proto = 
{
	SC_CPDDZ_FAPAI_P=2100,                            --发牌
	SC_CPDDZ_SET_DIZHU_P=2101,                        --设置地主和底牌(广播),客户端根据自己是否是地主判断是否获得底牌
	SC_CPDDZ_SET_STATE_P=2102,                        --设置当前游戏状态(广播)

	CS_CPDDZ_JIAODIZHU_P=2103,                        --玩家叫地主(不需要有具体信息)
	CS_CPDDZ_JIAODIZHU_PASS_P=2104,                   --玩家不叫地主(不需要有具体信息)
	SC_CPDDZ_JIAODIZHU_P=2105,                        --一个玩家叫了地主(广播)
	SC_CPDDZ_JIAODIZHU_TIMEOUT_P=2106,                --一个玩家叫地主超时(广播)
	SC_CPDDZ_JIAODIZHU_PASS_P=2107,                   --一个玩家不叫地主(广播)
	SC_CPDDZ_JIAODIZHU_NOTIFY_P=2108,                 --通知一个玩家叫地主

	CS_CPDDZ_CHUPAI_P=2109,                           --一个玩家出牌
	CS_CPDDZ_CHUPAI_PASS_P=2110,                      --一个玩家过牌(不需要有具体信息)
	SC_CPDDZ_REQUEST_CHUPAI_P=2111,                   --通知一个玩家该出牌了(广播)
	SC_CPDDZ_WARNING_CHUPAI_P=2112,                   --警告一个玩家该出牌了(广播)
	SC_CPDDZ_CHUPAI_END_P=2113,                       --下发一个玩家出牌结束的消息(广播)
	SC_CPDDZ_CHUPAI_PASS_P=2114,                      --下发一个玩家过牌(广播)
	
	CS_CPDDZ_TUOGUAN_P=2115,                          --打开关闭托管
	SC_CPDDZ_TUOGUAN_P=2116,                          --托管(广播)

	SC_CPDDZ_JIESUAN_P=2117,                          --结算(广播)
	SC_CPDDZ_SHOW_P=2118,                             --显示所有牌面(广播)

	SC_CPDDZ_SET_BEILV_P=2119,                        --设置倍率(广播)
	SC_CPDDZ_SET_PLAYER_STATE_P=2120,                 --设置玩家状态(广播)

	SC_CPDDZ_RECONNECT_P=2121,                        --断线重连
 
	CS_CPDDZ_ANYONEPLAYERPAI_P=2122,                  --请求发送自己当前手上的牌
	SC_CPDDZ_ALLPLAYERPAI_P=2123,                     --发送所有玩家手牌
	SC_CPDDZ_ANYONEPLAYERPAI_P=2124,                  --向某一个玩家发送他自己手上的牌

	SC_CPDDZ_ENDGAME_P=2125,                          --斗地主游戏结束(一局结束)
	SC_CPDDZ_LIUJU_P=2126,                            --流局

	SC_CPDDZ_PLAYER_ADD_MUTI_P=2128,
	SC_CPDDZ_PLAYER_ADD_MUTI_NOTIFY_P=2129,           --通知一个加倍

	CS_CPDDZ_REPORT_P = 2130,										-- 举报牌局
	SC_CPDDZ_REPORT_P = 2131,										-- 举报牌局的响应

	CS_CPDDZ_CHANGEPOKER_P = 2132,										-- 玩家换牌    玩家选择需要换掉的手牌
	SC_CPDDZ_CHANGEPOKER_P = 2133,										-- 玩家换牌
	SC_CPDDZ_CHOOSE_NEED_POKER_OVER_P = 2134,							-- 通知玩家已经选择好了准备换掉的牌
	CS_CPDDZ_CHOOSEPOKER_P = 2135,										-- 玩家选择牌
	SC_CPDDZ_CHOOSEPOKER_P = 2136,										-- 玩家选牌结果
	CS_CPDDZ_DZCHOOSEPOKER_P = 2137,									-- 地主选择底牌
	SC_CPDDZ_DZCHOOSEPOKER_P = 2138,									-- 地主选择底牌
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
	SelectChangePoker = 8,				   --	发牌结束 开始选择需要换的牌
	SelectGetPoker = 9,						-- 选择需要换上手的牌
	DizhuSelectPoker = 10,					-- 地主选择底牌
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
    ChuPai = 15,
	ExchangeOut = 10,
	ExchangeOutCardsFinish = 15,
	SetDiZhu = 10,
}

return {proto = proto,gameState = gameState,playerGameState = playerGameState,roomState = roomState,identity = identity,timeout = timeout}

--endregion
