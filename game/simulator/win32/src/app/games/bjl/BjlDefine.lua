-- region BjlDefine.lua
-- Date 2019年12月13日17:56:30
local proto = {
    SC_BJL_CONFIG_P                    = 2500, -- 发送配置
    SC_BJL_GAMESTATE_P                    = 2501, -- 游戏状态切换
    CS_BJL_BUYHORSE_P                = 2502, -- 请求下注
    SC_BJL_BUYHORSE_P                    = 2503, -- 下注 发送倍数_不用
    SC_BJL_SHOWCARD_P                    = 2504, -- 通知亮牌操作
    SC_BJL_SETTLEMENT_P                = 2505, -- 比牌结果&结算
    SC_BJL_OPER_ERROR_P                    = 2506, -- 服务端返回操作错误码
    CS_BJL_HISTORY_P                    = 2507, -- 请求历史信息
    SC_BJL_HISTORY_P                    = 2508, -- 返回历史信息 
    CS_BJL_FOLLOW_BUY_P                    = 2509, -- 请求续投
    SC_BJL_FOLLOW_BUY_P                    = 2510, -- 续投
    SC_BJL_BET_END_P                    = 2511, -- 其他玩家下注
    CS_BJL_PLAYERLIST_P                    = 2512, -- 请求玩家列表信息
    SC_BJL_PLAYERLIST_P                = 2513, -- 返回玩家列表信息
}


local errorCode = {
    EM_GAME_ERROR_NOT_MONEY            = 0, --   // not enough money
    EM_GAME_ERROR_BUY_LIMIT            = 1, --   // get the limit
    EM_GAME_ERROR_NOT_ROUND            = 2, --   // can not off zhuang.. round does not reach the min..
    EM_GAME_ERROR_OZ_STATE            = 3, --   // 
    EM_GAME_ERROR_ZHUANG_NO_MONEY    = 4, --       // 上庄金钱不足
    EM_GAME_ERROR_NEXT_ROUND            = 5, --     // 下轮下庄
    EM_GAME_ERROR_OFFZHUANG_WUNIU    = 6, --       // 无牛下庄
    EM_GAME_ERROR_APPLYZHUANG_OK        = 7, --      // 申请上庄成功
    EM_GAME_ERROR_NOT_MONEY_TO_BET    = 8, --       // 金钱不足不能下注
    EM_GAME_ERROR_FOLLOW_TO_BET        = 9, --     // 没有续投的记录
    EM_GAME_ERROR_FOLLOW_LIMIT        = 10, --       //续投超出房间限制
    EM_GAME_ERROR_FOLLOW_NOT_MONEY    = 11, --       //续投个人金钱不足
    EM_GAME_ERROR_CANTZHUANG            = 12, --    /当前不允许上庄
}

local roomState = {
    Wait = 0, --无状态
    Betting = 1, --下注阶段
    Result = 2, --亮牌阶段  
    Rest = 3, --游戏休息,等下一局开始
    Deal = 4,
}

local betType = {
    Banker = 1, --庄家
    Player = 2, --闲家
    Tie = 3, --和
    BankerPair = 4, --庄对子
    PlayerPair = 5, --闲对子
}

local cardValues = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" }

local cardColors = {
    Heart    = 3,
    Diamond = 4,
    Club    = 5,
    Spade    = 6,
}

BjlDefine = { proto = proto, roomState = roomState, betType = betType, cardValues = cardValues, cardColors = cardColors }

return BjlDefine
--endregion