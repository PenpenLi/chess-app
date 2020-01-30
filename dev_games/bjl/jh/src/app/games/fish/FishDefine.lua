FISH = {
	--协议
	CMD = {
		SUB_S_CHANGE_SCENE = 100,						   --改变场景
		SUB_S_FIRE_FAILED = 107,						   --配置信息
		SUB_S_CATCH_BIRD = 105,							   --打死鱼
		SUB_S_SEND_BIRD = 101,							   --发送鱼
		SUB_S_SEND_BULLET = 106,						   --发送子弹
		SUB_S_SEND_BIRD_LINEAR = 104,					   --发送特殊鱼阵
		SUB_S_SEND_BIRD_ROUND = 103,					   --配置信息
		SUB_S_SEND_BIRD_PAUSE_LINEAR = 102,				   --暂停
        SUB_S_STATUS_FREE = 110,

        SUB_C_FIRE = 108,
        SUB_C_CATCH_FISH = 109,
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