local define = {
	--游戏协议
	SC_SG_CONFIG_P 					= 3000,		-- 游戏配置
	SC_SG_GAMESTATE_P               = 3001,     -- 游戏状态
    SC_SG_CARD               = 3002,     -- 玩家手牌
    SC_SG_SHOW_QIANGZHUANG               = 3003,     -- 开始显示抢庄
    SC_SG_SELECT_ZHUANG               = 3004,     -- 确定庄家
    SC_SG_SHOW_PEILV               = 3005,     -- 开始选择赔率
    SC_SG_SELECT_PEILV               = 3006,     -- 确定玩家赔率
    SC_SG_PLAYER_INFO               = 3007,     -- 玩家信息 (底分，赔率，是否为庄家)
    SC_SG_SHOW_DIPAI               = 3008,     -- 显示底牌
    SC_SG_SHOW_JIESHUAN               = 3009,     -- 本局结算信息
    SC_SG_ZANLI_COMBACK               = 3010,     -- 回到游戏
    CS_SG_SELECT_QIANGZHUANG               = 3011,     -- 客户端抢庄，选择底分
    CS_SG_SELECT_PEILV               = 3012,     -- 客户端选择赔率
    SC_SG_ROOM_INFO               = 3013,     -- 房间信息(所有玩家)
    CS_SG_SHOWCARD               = 3014,     -- 摊牌
    SC_SG_SHOWCARD               = 3015,     -- 摊牌
    CS_SG_READY               = 3016,     -- 准备
    SC_SG_PEILV               = 3017,     -- 玩家可押注的赔率

	-- 游戏状态
	EM_SG_GAMESTATE_NONE 					= 0,      	-- 无状态(等待玩家加入)
	EM_SG_GAMESTATE_XIUXI 			    = 1,    	-- 休息3秒
	EM_SG_GAMESTATE_QIANGZHUANG 			= 2,     	-- 抢庄
	EM_SG_GAMESTATE_DINGZHUANG			= 3, 		-- 抢庄动画（有相同，随机抢庄）
	EM_SG_GAMESTATE_PEILV 			    = 4,   		-- 选择赔率  
	EM_SG_GAMESTATE_FAPAI 			    = 5,		-- 发牌
	EM_SG_GAMESTATE_TANPAI				= 6,   		-- 摊牌
	EM_SG_GAMESTATE_JIESUAN 				= 7,     	-- 游戏结算,等下一局开始
	EM_SG_GAMESTATE_READY 				= 8,		-- 准备

	-- 牌型
	em_SG_HandPX_ERROR=-1,
    em_SG_HandPX_None,      
    em_SG_HandPX_NormalSix,      --0点到6点 1倍
    em_SG_HandPX_High,        --七点到九点 2倍
    em_SG_HandPX_SanGong,        --三公 3倍
    em_SG_HandPX_Bomb,      --炸弹    4倍
    em_SG_HandPX_BombNine,        --爆九  5倍
    em_SG_HandPX_MAX,

    --仅用于配置文件发指定点的牌用运行时不计算
    em_SG_HandPX_Num0,        --0~9点
    em_SG_HandPX_Num1,        
    em_SG_HandPX_Num2,  
    em_SG_HandPX_Num3,
    em_SG_HandPX_Num4,
    em_SG_HandPX_Num5,
    em_SG_HandPX_Num6,
    em_SG_HandPX_Num7,
    em_SG_HandPX_Num8,
    em_SG_HandPX_Num9,
}

return define