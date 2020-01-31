--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local proto = 
{
    SC_HH_GAMESTATE_P    	= 4400,    -- 游戏状态
	CS_HH_BET_P        		= 4401,    -- 玩家下注
	SC_HH_BET_P        		= 4402,    -- 玩家下注
	CS_HH_FOLLOW_BUY_P  	= 4403,    -- 玩家续投
	SC_HH_FOLLOW_BUY_P  	= 4404,    -- 续投返回
	CS_HH_HISTORY_P      	= 4405,    -- 请求历史信息
	SC_HH_HISTORY_P      	= 4406,    -- 返回历史信息 
	CS_HH_PLAYERLIST_P    	= 4407,    -- 请求玩家列表信息
	SC_HH_PLAYERLIST_P    	= 4408,    -- 返回玩家列表信息 
	SC_HH_JIESUAN_P      	= 4409,    -- 结算
	SC_HH_ERROR_P      		= 4410,
    SC_HH_DESK_PLAYER_P     = 4411,    -- 上桌的玩家
    SC_HH_BET_END_P         = 4412,    -- 同步下注信息
}

local errorCode = 
{ 
    None 				= 0,
  	OneFaction 			= 1, 				-- 红黑只能资助一方
  	NotEnoughMoney  	= 2, 				-- 没有足够的钱下注
  	NoMoney 			= 3, 				-- 没有达到下注的最低要求
}

local cardType =
{
    Invalid         = 0,                 -- 无效
    Single 			= 1,                 -- 散牌
  	Pair9A 			= 2,                 -- 9-A对子
  	Straight 		= 3,                 -- 顺子
  	Flush 			= 4,                 -- 同花
  	StraightFlush 	= 5,                 -- 同花顺
  	ThreeKind 		= 6,                 -- 豹子
    Pair            = 8,                 -- 对子
}

local roomState =
{
    Wait = 0,                           --等待
    Betting = 1,                        --下注
    Result = 2,                         --亮牌了
    Rest = 3,                           --休息 
}

local betType =
{
    Red = 1,                        --红方
    Black = 2,                      --黑方
    Lucky = 3,                      --幸运一击
}

local cardValues = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
local cardColors = {Diamond = 0,Club = 1,Heart = 2,Spade = 3}

local TrendTabTag = 
{
    ZPL = 1,
    DL = 2,
    DYZL = 3,
    XL = 4,
    YYL = 5,
}

HhdzDefine = {proto = proto,errorCode = errorCode,cardType = cardType,roomState = roomState,betType = betType,cardValues=cardValues,cardColors=cardColors}

return HhdzDefine

--endregion
