local define = {
	--游戏协议s
	SC_BRQZNN_CONFIG_P = 3000,							--游戏配置
	SC_BRQZNN_GAMESTATE_P=3001,							--游戏状态
	SC_BRQZNN_CARD=3002,								--玩家手牌
	SC_BRQZNN_SHOW_QIANGZHUANG=3003,					--开始显示抢庄
	SC_BRQZNN_SELECT_ZHUANG=3004,						--确定庄家
	SC_BRQZNN_SHOW_PEILV=3005,							--开始选择赔率
	SC_BRQZNN_SELECT_PEILV=3006,						--确定玩家赔率
	SC_BRQZNN_PLAYER_INFO=3007,							--玩家信息(底分，赔率，是否为庄家)
	SC_BRQZNN_SHOW_DIPAI=3008,							--显示底牌
	SC_BRQZNN_SHOW_JIESHUAN=3009,						--本局结算信息
	SC_BRQZNN_ZANLI_COMBACK=3010,						--回到游戏
	CS_BRQZNN_SELECT_QIANGZHUANG=3011,					--客户端抢庄，选择底分
	CS_BRQZNN_SELECT_PEILV=3012,						--客户端选择赔率
	SC_BRQZNN_ROOM_INFO=3013,							--房间信息(所有玩家)
	SC_BRQZNN_MSGINFO=3014,								--信息
	CS_BRQZNN_SHOWCARD=3015,							--玩家主动摊牌
	SC_BRQZNN_SHOWCARD=3016,							--服务器要求玩家摊牌
	CS_BRQZNN_READY=3017,								--准备
	SC_BRQZNN_INGAME=3018,								--确定玩家在游戏
	SC_BRQZNN_GAMEPEOPLE = 3019,						--当前游戏人数有几个
	CS_BRQZNN_CUOPAI=3020,								--玩家搓牌
	SC_BRQZNN_CUOPAI=3021,								--玩家搓牌
	SC_BRQZNN_CARD_LAST=3022,							--给玩家发最后一张手牌以及牌型的组合
	CS_BRQZNN_CUOPAI_END=3023,            				--结束搓牌
  	SC_BRQZNN_CUOPAI_END=3024,            				--结束搓牌

	-- 游戏状态
	EM_BRQZNN_GAMESTATE_NONE=0,			--无状态(等待玩家加入)
	EM_BRQZNN_GAMESTATE_XIUXI=1,		--休息秒
	EM_BRQZNN_GAMESTATE_QIANGZHUANG=2,	--明牌张牌，抢庄
	EM_BRQZNN_GAMESTATE_DINGZHUANG=3,	--抢庄动画（有相同，随机抢庄）
	EM_BRQZNN_GAMESTATE_PEILV=4,		--选择赔率	
	EM_BRQZNN_GAMESTATE_FAPAI=5,		--发牌
	EM_BRQZNN_GAMESTATE_TANPAI=6,		--摊牌 在摊牌阶段搓牌就行
	EM_BRQZNN_GAMESTATE_JIESUAN=7,		--游戏结算,等待准备
	EM_BRQZNN_GAMESTATE_READY=8,        --准备
	EM_BRQZNN_GAMESTATE_FAPAI_1=9,		--发最后一张牌

	TipState_free=1,  --下一局即将开始 10s
	TipState_ready=2, --请准备
	TipState_readyForOther=3,--请等待其他玩家准备
	TipState_toBanker=4,  --请操作抢庄  8s
	TipState_waitBanker=5, --等待其他玩家抢庄
	TipState_waitOther=6,  --等待闲家下注(自己是庄家)
	TipState_toBet=7,      --请选择下注分数 10s
	TipState_waitBet=8,	   --等待其他玩家下注
	TipState_checkCard=9,  --查看手牌 15s
	TipState_waitShowCard=10, --请等待其他玩家亮牌
	TipState_doresult=11,     --开始比牌

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