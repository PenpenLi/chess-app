--region LOGIN_TYPE .lua

CONST_LOGIN_TYPE_NORMAL = 1
CONST_LOGIN_TYPE_FAST = 3
CONST_LOGIN_TYPE_WECHAT = 5
CONST_LOGIN_TYPE_SMS = 7

--endregion

--region HD_TYPE .lua

CONST_HD_TYPE_PC = 1
CONST_HD_TYPE_ANDROID = 2
CONST_HD_TYPE_APPLE = 3

--endregion

--region UC_TYPE .lua

CONST_UC_TYPE_ADID=3                        --苹果广告ID
CONST_UC_TYPE_CARD=4                        --手机卡序列号
CONST_UC_TYPE_ANDROID_ID=5                  --安卓ID

--endregion

--region LOGIN_RESULT .lua

CONST_LOGIN_RESULT_SUCCESS=0                --登录成功
CONST_LOGIN_RESULT_SUCCESS_LEAVE=1          --登录成功,玩家此刻处于离线托管状态

CONST_LOGIN_RESULT_FORBID=2                 --账号被封
CONST_LOGIN_RESULT_NO_ACCOUNT=3             --没有此账号
CONST_LOGIN_RESULT_PSW_ERROR=4              --密码错误
CONST_LOGIN_RESULT_VERSION=10                --版本错误
--endregion

--region VerifyCodeType.lua

CONST_VERIFY_CODE_CHANGE_PWD = 0
CONST_VERIFY_CODE_FIND_PWD = 1
CONST_VERIFY_CODE_LOGIN = 2

--endregion

--region ExchangeType.lua

CONST_EXCHANGE_ALIPAY = 1
CONST_EXCHANGE_BANK = 3

--endregion

--region NET_TYEP.lua

CONST_NET_TYPE_UNKNOWN = 0
CONST_NET_TYPE_WIFI = 1
CONST_NET_TYPE_4G = 2

--endregion

--region RankType.lua

CONST_RANK_TODAY_TIME = 1
CONST_RANK_TODAY_MONEY = 2

--endregion

--region Mail Read Type .lua

CONST_MAIL_UNREADY = 0
CONST_MAIL_READY = 1

--endregion

--region Pay Type .lua

CONST_PAY_TYPE_ALIPAY = 22
CONST_PAY_TYPE_WX = 30
CONST_PAY_TYPE_BANK = 31
CONST_PAY_TYPE_QQ = 32
CONST_PAY_TYPE_JD = 33
CONST_PAY_TYPE_ALIPAY_QUOTA = 36

--endregion