LHD = 
{
    --协议
    CMD = 
    {
        SC_LHD_CONFIG_P              = 3900,				--发送配置
	    SC_LHD_GAMESTATE_P           = 3901,				--游戏状态切换
	    SC_LHD_FIRST_P               = 3902,				--开始发牌动画
	    SC_LHD_OPTTIME_P             = 3903,				--下注亮牌的[[可操作？]]时间
	    CS_LHD_BUYHORSE_P            = 3904,				--请求下注
	    SC_LHD_BUYHORSE_P            = 3905,				--下注 发送倍数_不用
	    CS_LHD_REQUEST_ZHUANG_P      = 3906,				--请求上庄
	    CS_LHD_REQUEST_NOT_ZHUANG_P  = 3907,			    --请求取消上庄
	    SC_LHD_ZHUANG_LIST_P         = 3908,				--上庄列表
	    SC_LHD_ZHUANG_INFO_P         = 3909,				--庄家信息
	    SC_LHD_NO_ZHUANG_P           = 3910,				--下庄公告
	    SC_LHD_NOTICE_NO_ZHUANG_P    = 3911,				--通知庄家可以开始主动下庄
	    SC_LHD_SHOWCARD_P            = 3912,				--通知亮牌操作
	    SC_LHD_SETTLEMENT_P          = 3913,				--比牌结果&结算
	    SC_LHD_OPER_ERROR_P          = 3914,				--服务端返回操作错误码
	    CS_LHD_HISTORY_P             = 3915,				--请求历史信息
	    SC_LHD_HISTORY_P             = 3916,				--返回历史信息 
	    CS_LHD_FOLLOW_BUY_P          = 3917,				--请求续投
	    SC_LHD_FOLLOW_BUY_P          = 3918,				--续投
	    CS_LHD_ZHUANG_OFF_P          = 3919,				--当前庄请求下庄
        CS_LHD_ALLLIST_P             = 3920,                --请求玩家列表
        SC_LHD_ALLLIST_P             = 3921,                --返回玩家列表
        SC_LHD_BETINFO               = 3922,                --下注信息
        SC_LHD_SYNC_BET              = 3923,                --下注同步
        CS_LHD_REQUEST_ZHUANG_LIST_P = 3924,                --请求上庄列表
    },

    LHD_GameState = 
    {
        LHD_GameState_None       = 0,	            --无状态
	    LHD_GameState_BuyHorse   = 1,	            --下注阶段
	    LHD_GameState_Combine    = 2,	            --亮牌阶段	
	    LHD_GameState_End        = 3,	            --游戏休息,等下一局开始
    },
    ---[[
    LHDPos	=			                            --龙虎斗方位定义 
    {
	    LHDPos_None   = 0,                          --无效
	    LHDPos_Long   = 1,                          -- 龙位
	    LHDPos_Hu     = 2,	                        -- 虎位
	    LHDPos_He     = 3,                          -- 和位
	    LHDPos_Max    = 4,
    },

    GAME_ERROR	=				                    --返回错误提示
    {
	    GAME_ERROR_NOT_MONEY         = 0,	        -- not enough money
	    GAME_ERROR_BUY_LIMIT         = 1,	        -- get the limit
	    GAME_ERROR_NOT_ROUND         = 2,           -- can not off zhuang.. round does not reach the min..
	    GAME_ERROR_OZ_STATE          = 3,	        -- 
	    GAME_ERROR_ZHUANG_NO_MONEY   = 4,	        -- 上庄金钱不足
	    GAME_ERROR_NEXT_ROUND        = 5,	        -- 下轮下庄
	    GAME_ERROR_OFFZHUANG_WUNIU   = 6,	        -- 无牛下庄
	    GAME_ERROR_APPLYZHUANG_OK    = 7,	        -- 申请上庄成功
	    GAME_ERROR_NOT_MONEY_TO_BET  = 8,           -- 金钱不足不能下注
	    GAME_ERROR_FOLLOW_TO_BET     = 9,	        -- 没有续投的记录
	    GAME_ERROR_FOLLOW_LIMIT      = 10,	        --续投超出房间限制
	    GAME_ERROR_FOLLOW_NOT_MONEY  = 11,          --续投个人金钱不足
        GAME_ERROR_SLIENTCE_TOMANNY  = 12,	        --沉默次数太多
    },
   --]]
}
--[[
enum em_LHD_GameState				//游戏阶段
{
	em_LHD_GameState_None,		 //无状态
	em_LHD_GameState_BuyHorse,	//下注阶段
	em_LHD_GameState_Combine,	//亮牌阶段	
	em_LHD_GameState_End,		//游戏休息,等下一局开始
};

enum EM_GAME_ERROR					//返回错误提示
{
	EM_GAME_ERROR_NOT_MONEY,		// not enough money
	EM_GAME_ERROR_BUY_LIMIT,		// get the limit
	EM_GAME_ERROR_NOT_ROUND,		// can not off zhuang.. round does not reach the min..
	EM_GAME_ERROR_OZ_STATE,			// 
	EM_GAME_ERROR_ZHUANG_NO_MONEY,	// 上庄金钱不足
	EM_GAME_ERROR_NEXT_ROUND,		// 下轮下庄
	EM_GAME_ERROR_OFFZHUANG_WUNIU,	// 无牛下庄
	EM_GAME_ERROR_APPLYZHUANG_OK,	// 申请上庄成功
	EM_GAME_ERROR_NOT_MONEY_TO_BET, // 金钱不足不能下注
	EM_GAME_ERROR_FOLLOW_TO_BET,	// 没有续投的记录
	EM_GAME_ERROR_FOLLOW_LIMIT,		//续投超出房间限制
	EM_GAME_ERROR_FOLLOW_NOT_MONEY, //续投个人金钱不足
};

enum emLHDPos				//龙虎斗方位定义 
{
	emLHDPos_None,  //无效
	emLHDPos_Long,  // 龙位
	emLHDPos_Hu,	 // 虎位
	emLHDPos_He,  // 和位
	emLHDPos_Max,
};

//<宏>-----------------------------------------------------------------------------------------------------------
#define			LHD_RELOAD_TIME				3			//断线重连加载时间
#define			LHD_SHOW_CARD_TIME			6			//给牌后 结算前的时间
#define			LHD_SHOW_COIN_TIME			2			//9
#define			LHD_FAPAI_MOVIE_TIME		0		//
#define			LHD_BUY_MOVIE_TIME			2			//
#define			LHD_COLOR_POOL_BR_TIME		3			//彩池开奖动画时间
]]