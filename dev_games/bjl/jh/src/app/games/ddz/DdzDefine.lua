--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local proto = 
{
    SC_CODDZ_FAPAI_P=1800,                            --发牌
	SC_CODDZ_SET_DIZHU_P=1801,                        --设置地主和底牌(广播),客户端根据自己是否是地主判断是否获得底牌  
	SC_CODDZ_SET_STATE_P=1802,                        --设置当前游戏状态(广播)

	CS_CODDZ_JIAODIZHU_P=1803,                        --玩家叫地主(不需要有具体信息)
	CS_CODDZ_JIAODIZHU_PASS_P=1804,                   --玩家不叫地主(不需要有具体信息)
	SC_CODDZ_JIAODIZHU_P=1805,                        --一个玩家叫了地主(广播)
	SC_CODDZ_JIAODIZHU_TIMEOUT_P=1806,                --一个玩家叫地主超时(广播)
	SC_CODDZ_JIAODIZHU_PASS_P=1807,                   --一个玩家不叫地主(广播)
	SC_CODDZ_JIAODIZHU_NOTIFY_P=1808,                 --通知一个玩家叫地主

	CS_CODDZ_CHUPAI_P=1809,                           --一个玩家出牌
	CS_CODDZ_CHUPAI_PASS_P=1810,                      --一个玩家过牌(不需要有具体信息)
	SC_CODDZ_REQUEST_CHUPAI_P=1811,                   --通知一个玩家该出牌了(广播)
	SC_CODDZ_WARNING_CHUPAI_P=1812,                   --警告一个玩家该出牌了(广播)
	SC_CODDZ_CHUPAI_END_P=1813,                       --下发一个玩家出牌结束的消息(广播)
	SC_CODDZ_CHUPAI_PASS_P=1814,                      --下发一个玩家过牌(广播)
	
	CS_CODDZ_TUOGUAN_P=1815,                          --打开关闭托管
	SC_CODDZ_TUOGUAN_P=1816,                          --托管(广播)

	SC_CODDZ_JIESUAN_P=1817,                          --结算(广播)
	SC_CODDZ_SHOW_P=1818,                             --显示所有牌面(广播)	                                     

	SC_CODDZ_SET_BEILV_P=1819,                        --设置倍率(广播)
	SC_CODDZ_SET_PLAYER_STATE_P=1820,                 --设置玩家状态(广播)

	SC_CODDZ_RECONNECT_P=1821,                        --断线重连
 
	CS_CODDZ_ANYONEPLAYERPAI_P=1822,                  --请求发送自己当前手上的牌
	SC_CODDZ_ALLPLAYERPAI_P=1823,                     --发送所有玩家手牌
	SC_CODDZ_ANYONEPLAYERPAI_P=1824,                  --向某一个玩家发送他自己手上的牌

	SC_CODDZ_ENDGAME_P=1825,                          --斗地主游戏结束(一局结束)
	SC_CODDZ_LIUJU_P=1826,                            --流局
	CS_CODDZ_PLAYER_ADD_MUTI_P=1827,                  --玩家加倍 
	SC_CODDZ_PLAYER_ADD_MUTI_P=1828,                  
	SC_CODDZ_PLAYER_ADD_MUTI_NOTIFY_P=1829,           --通知一个加倍
	SC_CODDZ_PLAYER_CARD_PEIWAN_P = 1830,             -- 测试陪玩信息
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

return {proto = proto,gameState = gameState,playerGameState = playerGameState,roomState = roomState,identity = identity,timeout = timeout}

--endregion
