ZJH = {
	--协议号
	CMD = {
		SC_PLAYER_STATE_P=101,                         --单个玩家状态改变
		SC_BANKER_P=102,                               --发送庄家信息
		CS_BET_P=103,                                  --下注
		SC_BET_P=104,                                  --下注
		SC_DEAL_P=105,                                 --发牌
		SC_WAIT_OPT_P=106,                             --等待操作
		CS_FOLD_P=107,                                 --弃牌
		SC_FOLD_P=108,                                 --弃牌
		CS_CHECK_P=109,                                --看牌
		SC_CHECK_P=110,                               --看牌，广播给别人
		SC_CHECK_SELF_P=111,                           --看牌，发送给自己
		CS_COMPETITION_P=112,                          --比牌
		SC_COMPETITION_P=113,                          --比牌
		CS_SHOW_CARD_PACK_P=114,                       --开牌
		SC_SHOW_CARD_PACK_P=115,                       --开牌
		SC_TURN_P=116,                                 --轮数
		CS_FOLLOW_P=117,                               --跟到底
		CS_READY_P = 125,                              --玩家下一局准备
		SC_READY_P = 126,                              --玩家下一局准备
		SC_STATE_P = 127,                              --游戏状态
		CS_REPORT_P = 151,							   --举报
	},

	--下注操作类型
	OPT = {
		BOTTOM = 0,                           --下底注
		BET = 1,                              --下注
		CALL = 2,                             --跟注
		FILL = 3,                             --加注
		FOLD = 4,                             --弃牌
		COMPETITION = 5,                      --比牌
		SHOW_CARD = 6,                        --开牌
		SHOW_HAND = 7,                        --全押
	},

	--牌型
	POKER_TYPE = {
		NONE = 0,		                  --无	
		SANPAI = 1,		                  --散牌
		SANPAI_A = 2,		              --带A散牌
		DUIZI = 3,		                  --对子
		SHUNZI = 4,		                  --顺子	三张花色不同、牌点连续的牌
		JINHUA = 5,		                  --金花  三张花色相同的牌，非顺子
		SHUNJIN = 6,		              --顺金	花色相同的顺子(同花顺)
		BAOZI = 7,		                  --豹子	三张点相同的牌
		TESHU = 8,		                  --特殊牌235
	},

	--操作按钮
	BTN_NAME = {
		QIPAI = "QIPAI",
		UNALWAYS = "UNALWAYS",
		ALWAYS = "ALWAYS",
		GZYZ = "GZYZ",
		GENZHU = "GENZHU",
		KANPAI = "KANPAI",
		BIPAI = "BIPAI",
		QUANYA = "QUANYA",
		JIAZHU3 = "JIAZHU3",
		JIAZHU2 = "JIAZHU2",
		JIAZHU1 = "JIAZHU1",
	},

	--玩家在桌状态
	PLAYER_TABLE_STATUS = {
		NONE = 0,
		WATCHING = 1,
		READY = 2,
		PLAYING = 3,
	},

	--玩家游戏状态
	PLAYER_GAME_STATUS = {
		NONE = 0,
		NOT_LOOKED = 1,
		HAD_LOOKED = 2,
		QIPAI = 3,
		TAOTAI = 4,
	},

	--游戏状态
	GAME_STATUS = {
		NONE = -1,
		READY = 0,
		PLAYING = 1,
		SETTLEMENT = 2,
	},
}

local define = {
	--玩家状态
	-- PLAYER_STATE_ERROR = 0,                  	  --错误状态
	-- PLAYER_STATE_PLAY = 1,                         --游戏状态
	-- PLAYER_STATE_FOLD = 2,                         --弃牌状态
	-- PLAYER_STATE_OFFLINE_NONE = 0,                 --无离开状态
	-- PLAYER_STATE_OFFLINE_QUIT = 1,                 --玩家退出游戏
	-- PLAYER_STATE_OFFLINE_LEAVE = 2,                --离线---暂加，掉线一类的
	-- PLAYER_STATE_OFFLINE_ZANLI = 3,                --暂离
}

return define