BRNN = {
	--协议
	CMD = {
		SC_CONFIG_P = 1900,							   --配置信息
		SC_GAMESTATE_P = 1901,                         --游戏状态
		SC_FIRST_P = 1902,                             --发牌头家
		SC_FAPAI_P = 1903,                             --发牌
		SC_OPTTIME_P = 1904,                           --可操作时间
		CS_BUYHORSE_P = 1905,                          --下注
		SC_BUYHORSE_P = 1906,                          --发送倍数_不用
		CS_REQUEST_ZHUANG_P = 1907,                    --请求上庄
		CS_REQUEST_NOT_ZHUANG_P = 1908,                --请求下庄
		CS_REQUEST_ZHUANG_LIST_P = 1909,               --请求申请上庄玩家列表
		SC_ZHUANG_LIST_P = 1910,					   --返回申请上庄玩家列表
		SC_ZHUANG_INFO_P = 1911,                       --返回当前庄信息
		SC_NO_ZHUANG_P = 1912,                         --返回没庄
		SC_NOTICE_NO_ZHUANG_P = 1913,                  --tell zhuang can off
		SC_SHOWCARD_P = 1914,                          --亮牌操作成功
		SC_SETTLEMENT_P = 1915,                        --比牌结果&结算
		SC_OPER_ERROR_P = 1916,                        --服务端返回操作错误码
		CS_HISTORY_P = 1917,                           --request history
		SC_HISTORY_P = 1918,                           --response
		CS_CLEAR_BUY_P = 1919,                         --clear buy info
		SC_CLEAR_BUY_P = 1920,                         --response
		CS_FOLLOW_BUY_P = 1921,                        --续投
		SC_FOLLOW_BUY_P = 1922,                        --response
		SC_NOTICE_ZHUANG_LIST_P = 1923,                
		CS_ZHUANG_OFF_P = 1924,                        --当前庄请求下庄
		SC_BEGIN_INFO_P = 1925,                        --百人牛牛开局相关信息
		SC_BUYHORSE_INFO_P = 1926, 					   --没在座位上的玩家下注消息
		CS_COLOR_POOL_P = 1927, 					   --彩池信息请求
		SC_COLOR_POOL_P = 1928,
		CS_RANKLIST_P = 1929,               		   --在座位上的玩家列表          
	  	SC_RANKLIST_P = 1930,						   --返回再坐玩家列表
	  	CS_ALLLIST_P = 1931,       					   --玩家列表  
	  	SC_ALLLIST_P = 1932,						   --返回所有玩家列表
	  	CS_TIME_P = 1933,							   --请求状态时间
	},

	--牌型倍数
	TYPE_BEI = {
		NONE = 0,
		NORMAL_NIU = 7,
		NIU_8 = 8,
		NIU_9 = 9,
		NIU_NIU = 10,
		TONGHUA = 11,
		SHUNZI = 12,
		HULU = 13,
		WUHUANIU = 14,
		ZHADAN = 15,
		TONGHUASHUN = 16,
		WUXIAONIU = 17,
	},

	--牌型
	TYPE = {
		NONE = 0,
		NORMAL_NIU = 1,
		NIU_8 = 2,
		NIU_9 = 3,
		NIU_NIU = 4,
		TONGHUA = 5,
		SHUNZI = 6,
		HULU = 7,
		WUHUANIU = 8,
		ZHADAN = 9,
		TONGHUASHUN = 10,
		WUXIAONIU = 11,
	},

	--状态
	STATUS = {
		NONE = 0,
		START = 1,
		BET = 2,
		COMPARE = 3,
		RESULT = 4,
	},

	--错误
	ERROR = {
		NOT_MONEY = 0,			--金币不足
		BET_LIMIT = 1,			--超过下注限制
		NOT_ROUND = 2,			--申请下庄轮数未到达
		OZ_STATE = 3,
		BANKER_NOT_MONEY = 4,	--上庄金币不足
		NEXT_ROUND = 5,			--下轮下庄
		OFF_BANKER_NONIU = 6,	--无牛下庄
		APPLY_BANKER_OK = 7,	--申请上庄成功
		NOT_MONEY_BET = 8,		--金币不足不能下注
		NOT_BET_HISTORY = 9,		--无续投记录
		NOT_MONEY_TO_CONTINUE=10, --金币不足，无法续压
	},
}

local define = {
}

return define