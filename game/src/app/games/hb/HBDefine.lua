HB = {
	--协议
	CMD = {
		APPLY_BANK = 100,						   --申请埋雷
		CANCAL_BANK = 101,						   --取消埋雷
		CHANGE_SCANCE = 102,					   --场景消息

        ROD_RED = 103,
        ROD_RED_BACK = 104,
        BANK_RED_WINLOSER = 105,
        FAILD_RESULT = 106,
        STATUSFREE = 107,
	},

	--错误
	ERROR = {
--		NOT_MONEY = 0,			--金币不足
--		BET_LIMIT = 1,			--超过下注限制
--		NOT_ROUND = 2,			--申请下庄轮数未到达
--		OZ_STATE = 3,
--		BANKER_NOT_MONEY = 4,	--上庄金币不足
--		NEXT_ROUND = 5,			--下轮下庄
--		OFF_BANKER_NONIU = 6,	--无牛下庄
--		APPLY_BANKER_OK = 7,	--申请上庄成功
--		NOT_MONEY_BET = 8,		--金币不足不能下注
--		NOT_BET_HISTORY = 9,		--无续投记录
	},
}

local define = {
}

return define