local define = {
	--游戏协议
	SC_CONFIG_P 					= 2900,		-- 游戏配置
	SC_GAMESTATE_P 				 	= 2901,		-- 返回状态
	SC_CARD 					 	= 2902, 	-- 玩家手牌
	SC_PLAYER_INFO 					= 2907,    	-- 玩家信息 (底分，赔率，是否为庄家)
	SC_SHOW_JIESHUAN 				= 2909,   	-- 本局结算信息
	CS_SELECT_QIANGZHUANG 			= 2911,   	-- 客户端抢庄，选择底分
	CS_SELECT_PEILV 				= 2912,    	-- 客户端选择赔率
    CS_SHOWCARD                    	= 2915,   	-- 玩家主动摊牌
    SC_SHOWCARD                    	= 2916,    	-- 服务器要求玩家摊牌
    CS_REDAY                       	= 2917,    	-- 玩家准备

	-- 游戏状态
	GAMESTATE_NONE 					= 0,      	-- 无状态(等待玩家加入)
	GAMESTATE_XIUXI 			    = 1,    	-- 休息3秒
	GAMESTATE_QIANGZHUANG 			= 2,     	-- 抢庄
	GAMESTATE_QIANGZHUANG2			= 3, 		-- 播放抢庄动画
	GAMESTATE_PEILV 			    = 4,   		-- 选择赔率  
	GAMESTATE_FAPAI 			    = 5,		-- 发牌
	GAMESTATE_TANPAI				= 6,   		-- 摊牌
	GAMESTATE_JIESUAN 				= 7,     	-- 游戏结算,等下一局开始
	GAMESTATE_ZHUNBEI 				= 8,		-- 准备

	-- 牌型
	HandPX_ERROR					= -1,                          
	HandPX_None						= 0,        -- 无牛
	HandPX_NormalNiu				= 1,        -- 牛一到牛六
	HandPX_HighNiu					= 2,        -- 牛七到牛九
	HandPX_NiuNiu					= 3,        -- 牛牛
	HandPX_FiveFlower				= 4,        -- 五花牛
	HandPX_Bomb						= 5,        -- 炸弹
	HandPX_FiveCalf					= 6,        -- 五小牛
	HandPX_MAX						= 7,		--
}

return define