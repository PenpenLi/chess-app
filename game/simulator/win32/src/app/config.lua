--是否正式版
NORMAL_VER = true;

---------------------------------------------------------------------------

--正式服
NORMAL_SERVERLIST              ={}
NORMAL_SERVERLIST[1]           = "http://150.109.24.227:8000/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--"http://sl.nbwaimai.com/ServerList_v2?"
NORMAL_SERVERLIST[2]           = "http://150.109.24.227:8000/ServerList_v2?"--"http://res.nbwaimai.com/sl/%d_%d.txt?"
NORMAL_SERVERLIST[3]           = "http://150.109.24.227:8000/ServerList_v2?"
NORMAL_SERVERLIST[4]           = "http://150.109.24.227:8000/ServerList_v2?"
NORMAL_SERVERLIST[5]           = "http://150.109.24.227:8000/ServerList_v2?"

----正式服
--NORMAL_SERVERLIST              ={}
--NORMAL_SERVERLIST[1]           = "http://sl.jljs.org/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--"http://sl.nbwaimai.com/ServerList_v2?"
--NORMAL_SERVERLIST[2]           = "http://sl.jljs.org/ServerList_v2?"--"http://res.nbwaimai.com/sl/%d_%d.txt?"
--NORMAL_SERVERLIST[3]           = "http://sl.jljs.org/ServerList_v2?"
--NORMAL_SERVERLIST[4]           = "http://sl.jljs.org/ServerList_v2?"
--NORMAL_SERVERLIST[5]           = "http://sl.jljs.org/ServerList_v2?"

--测试服
-- TEST_SERVERLIST                ={}//172.18.90.22:8000
-- TEST_SERVERLIST[1]             = "http://47.52.142.55:8000/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--"http://47.52.142.55:8000/ServerList_v2?"--
-- TEST_SERVERLIST[2]             = "http://154.222.142.93:805/ServerList_v2?"--"http://120.78.153.176:8000/ServerList_v2?"--
-- TEST_SERVERLIST[3]             = "http://154.222.142.93:805/ServerList_v2?"--"http://47.52.142.55:8000/ServerList_v2?"--
-- TEST_SERVERLIST[4]             = "http://154.222.142.93:805/ServerList_v2?"--"http://120.78.153.176:8000/ServerList_v2?"--
-- TEST_SERVERLIST[5]             = "http://154.222.142.93:805/ServerList_v2?"--"http://47.52.142.55:8000/ServerList_v2?"--

--开发服
TEST_SERVERLIST                ={}      
TEST_SERVERLIST[1]             = "http://172.18.90.6:8098/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--
TEST_SERVERLIST[2]             = "http://172.18.90.6:8098/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--
TEST_SERVERLIST[3]             = "http://172.18.90.6:8098/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--
TEST_SERVERLIST[4]             = "http://172.18.90.6:8098/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--
TEST_SERVERLIST[5]             = "http://172.18.90.6:8098/ServerList_v2?"--"http://154.222.142.93:805/ServerList_v2?"--

SERVERLIST = NORMAL_VER and NORMAL_SERVERLIST or TEST_SERVERLIST;

----------------------------------------------------------------------------

--默认更新地址   "http://flyfox.oss-ap-southeast-1.aliyuncs.com/update"
DEFAULT_UPDATE_URL = "http://127.0.0.1:8080//update" 
--默认支付地址
DEFAULT_PAY_URL = "http://59.56.97.60:10000/paycenter/heepay"
--默认代理列表地址
DEFAULT_AGENT_URL= "http://59.56.97.60:10000/Agent/GetAgentByRand"
--默认游戏规则地址
DEFAULT_GAME_RULE_URL = "http://59.56.97.60:10000"
--默认兑换记录地址
DEFAULT_EXCHANGE_LOG_URL = "http://59.56.97.60:10000"
--支付宝兑换记录地址
DEFAULT_ALIPAY_EXCHANGELOG = "/AlipayExchange/index?userid=%s&pwd=%s"
--银行卡兑换记录地址
DEFAULT_BANK_EXCHANGELOG = "/BankExchange/index?userid=%s&pwd=%s"
--iOS支付服务器地址
DEFAULT_IOS_PAY_URL = "http://59.56.97.60:10000/paycenter"
--默认客服地址
DEFAULT_SERVICE_URL = "https://chat.livechatvalue.com/chat/chatClient/chatbox.jsp?companyID=1075382&configID=83050&jid=1118244771&s=1"
--默认代充地址
DEFAULT_FLASH_PAY_URL = "https://tb.53kf.com/code/client/%s/1"

----------------------------------------------------------------------------