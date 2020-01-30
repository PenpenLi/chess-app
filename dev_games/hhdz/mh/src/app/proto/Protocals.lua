--region MainProto.lua

MainProto = {}
MainProto.RegLogin=0                           --注册登录
MainProto.FindPsw=1                            --找回密码
MainProto.Pay=2                                --支付相关
MainProto.IDRecord=3                           --查询ID记录系统
MainProto.Game=4                               --游戏逻辑
MainProto.XC=5                                 --子游戏服务器和客户端交互的协议

MainProto.BaseInfo=6                           --基本信息
MainProto.Money=7                              --金钱钱包相关
MainProto.LevelExp=8                           --等级经验相关
MainProto.EMail=9                              --邮箱
MainProto.Phone=10                             --手机号
MainProto.Cryptoguard=11                       --密保相关
MainProto.GameTime=12                          --游戏时间
MainProto.MoneyRecord=13                       --金钱钱包记录
MainProto.MailManager=14                       --邮件系统
MainProto.NoticeManager=15                     --公告系统
MainProto.CompetitionManager=16                --大奖赛
MainProto.TopPlayerManager=17                  --大奖赛置顶玩家
MainProto.Relief=18                            --救济金
MainProto.LoginRecord=19                       --登陆记录
MainProto.OnlineReward=20                      --在线奖励
MainProto.DayLogin=21                          --每日签到
MainProto.Lock=22                              --锁机
MainProto.CheckSystem=23                       --验证系统
MainProto.ChengJiuManager=24                   --成就
MainProto.TaskManager=25                       --任务
MainProto.Present=26                           --礼品
MainProto.PresentManager=27                    --礼品管理
MainProto.GameRecord=28                        --游戏记录
MainProto.PresentNotice=29                     --礼品领取公告
MainProto.Vip=30                               --vip
MainProto.PlayerTimer=31                       --玩家定时器
MainProto.Card=32                              --实物卡
MainProto.AccountInfo=33                       --账号信息

MainProto.DBServer=34                          --HallServer,GameServer,FCServer和DBServer通信
MainProto.ChatServer=35                        --聊天服务器

MainProto.LocalServer = 36                     --本地存储
MainProto.Rank=40                              --排行榜
MainProto.QMAgent=41						   --全民代理

--endregion

--region RegLoginProto.lua

RegLogin = {}
RegLogin.CS_NORMAL_REG_P=0                                --普通注册
RegLogin.SC_NORMAL_REG_P=1                                
RegLogin.CS_LOGIN_P=2                                     --开始登陆
RegLogin.SC_LOGIN_P=3                                     
RegLogin.CS_LOGIN_OUT_P=4                                 --登出
RegLogin.SC_ONLINE_P=5                                    --发送上线信息

RegLogin.CS_CHECK_REGINFO_P=6                             --校验注册信息
RegLogin.SC_CHECK_REGINFO_P=7                             --["code"]=emNoramalReg
RegLogin.CS_GET_RANDOM_NICKNAME_P=8                       --客户端请求一个随机昵称
RegLogin.SC_GET_RANDOM_NICKNAME_P=9                       
RegLogin.SC_OHTER_LOGIN_P=10                              --你的账号在别处登录,你已经被挤下线
RegLogin.SC_LOGIN_OTHER_P=11                              --你的账号在别处登录,你把它挤下线

RegLogin.SC_SERVER_STOP_P=12                              --服务器处于停机维护状态

RegLogin.SC_UPDATE_SAVE_RANDOM_P=13                       --更新保存密码随机数
RegLogin.SC_FULLCONNECT_ATTACK_P=14                       --因为全连接攻击,你被断开连接
RegLogin.SC_WEB_KILL_P=15                                 --你被踢下线

--GameServer
RegLogin.CS_GAMESERVER_LOGIN_P=16                         
RegLogin.SC_GAMESERVER_LOGIN_P=17                         

RegLogin.SC_GAMESERVER_ONLIEN_P=18                        

RegLogin.CS_HEART_CHECK_P=19                              
RegLogin.SC_HALL_SERVER_VERSION_P=20                      --大厅版本号
RegLogin.SC_GAME_SERVER_VERSION_P=21                      --游戏服务版本号

RegLogin.CS_A_LOGIN_P=22                                 
RegLogin.SC_A_LOGIN_P=23                                 

RegLogin.CS_B_LOGIN_PC_P=24                              
RegLogin.CS_B_LOGIN_PHONE_P=25                           
RegLogin.SD_B_LOGIN_P=26                                 --发到DB玩家上线
RegLogin.SC_B_LOGIN_P=27                                 
RegLogin.CS_WINDOW_MIN_WAIT_P=28                          --进入最小化等待
RegLogin.CS_REQUEST_REG_PHONECODE_P=29                    --手机注册请求手机验证码
RegLogin.SC_REQUEST_REG_PHONECODE_P=30                    

RegLogin.CS_PHONECODE_REG_P=31                            --手机注册
RegLogin.SC_PHONECODE_REG_P=32                            


RegLogin.CS_C_LOGIN_P=33                            
RegLogin.SC_C_LOGIN_P=34                            
RegLogin.CS_CHECK_SAFE_CLOSE_SERVER_P=35                  --验证后关服
RegLogin.CS_CHECK_CONNECT_P=36                            --检测是否与服务器消息发送是否正常
RegLogin.SC_CHECK_CONNECT_P=37                            

RegLogin.CS_REQUEST_SERVER_VERSION_P=38                   --请求版本号

RegLogin.CS_REQUEST_VERCODE_P =41-- 请求
RegLogin.SC_REQUEST_VERCODE_P=42  -- 
RegLogin.CS_RESPONSE_VERCODE_P=43
RegLogin.SC_VERCODE_HALL_RESULT_P=44
RegLogin.SC_VERCODE_GAME_RESULT_P=45

--以下是新协议
RegLogin.CD_REQUEST_SYSTEM_STATUS_P=49                     -- 请求系统配置
RegLogin.DC_REQUEST_SYSTEM_STATUS_P=50                     -- 返回系统配置
RegLogin.CS_REQUEST_GAMEVERSIONS_P=51                      -- 请求游戏版本号列表
RegLogin.SC_REQUEST_GAMEVERSIONS_P=52                      -- 服务器下发游戏版本号列表

--endregion

--region BaseInfo.lua

BaseInfo = {}
BaseInfo.CS_SET_NICKNAME_P=0                              --设置昵称
BaseInfo.SC_SET_NICKNAME_RESULT_P=1                       
BaseInfo.SC_SET_NICKNAME_P=2                              

BaseInfo.CS_SET_HEADID_P=3                                --设置头像ID
BaseInfo.CS_SET_CUSTOM_HEAD_P=4                           --设置为使用自定义头像

BaseInfo.CS_CHANGE_PSW_P=5                                --修改密码
BaseInfo.SC_CHANGE_PSW_RESULT_P=6                         

BaseInfo.SC_SET_LOTTERY_P=7                               --奖券改变

BaseInfo.CS_CHANGE_PSW_CHECK_P=8                          --验证修改后密码有效性
BaseInfo.SC_CHANGE_PSW_CHECK_P=9                          

BaseInfo.CS_SET_SPECPHONE_P=10                            --设置特殊手机号
BaseInfo.SC_SET_SPECPHONE_P=11                            

BaseInfo.CS_FRIEND_P=12                                   --朋友圈
BaseInfo.SC_FRIEND_P=13                                   

BaseInfo.SC_SET_ROBOT_LEVEL_P=14                          

BaseInfo.SC_CHANGE_LOTTERY_P=15                           --变更奖券(变更量)

BaseInfo.CD_SET_SEX_P=16                                  --设置玩家的性别
BaseInfo.DC_SET_SEX_P=17    

--endregion

--region DbServer.lua

DbServer = {}
DbServer.CS_REGISTER_P=0                                  --HallServer向DBServer注册
DbServer.SC_RECV_MSG_P=1                                  --DBServer向HallServer确认收到了一条消息
DbServer.CS_PLAYER_QUIT_P=2                               --HallServer通知DBserver一个玩家断开连接

--GameServer
DbServer.CS_REGISTER1_P=3                                 --GameServer向DBServer注册
DbServer.SC_REGISTER1_P=4                                 --DBServer通知GameServer注册成功
DbServer.CS_GS_PLAYER_QUIT_P=5                            --一个玩家退出GameServer
DbServer.GD_CLOSE_GAME_SERVER_P=6                         --游戏服务器关闭

--ChatServer 聊天服务器
DbServer.CS_REGISTER_CHAT_P=7                             --ChatServer向DBServer注册

DbServer.SD_MODE3_CHANGE_JIFEN_P=8                        --GameServern改变积分
DbServer.SD_LOG_SPECIAL_PX_P=9                            --记录特殊牌型日志

--请求比赛列表
DbServer.CS_MODE3_LIST_ENTER_P=10                         --玩家请求进入比赛活动专区(大奖赛列表)CS_MODE3_ENTER_P,F-db

DbServer.SC_MODE3_GETCOMPLIST_P=11                        --发送大奖赛列表信息到玩家
DbServer.SC_MODE3_TOP_PALYER_INFO_P=12                    --置顶玩家信息

--最近的大奖赛获奖记录
DbServer.CS_MODE3_GETLATELYREWARDRECORD_P=13              --请求获得最近的大奖赛获奖记录
DbServer.SC_MODE3_GETLATELYREWARDRECORD_P=14              --下发最近的大奖赛获奖记录

----比赛及时排名前6名与自己的名次
--CS_MODE3_GETCOMPPLAYERRANK_P,     --获得大奖赛玩家排名
--SC_MODE3_GETCOMPPLAYERRANK_P,     --下发大奖赛玩家排名

DbServer.CS_MODE3_GET_QISHU_MINGCI_P=15                   --发送指定大奖赛指定期数指定名字范围的玩家信息
DbServer.SC_MODE3_GET_QISHU_MINGCI_P=16                   


DbServer.CS_MODE3_COMPDETAIL_ENTER_P=17                   --玩家请求进入模式3中的某个大奖赛详情界面CS_MODE3COMP_ENTER_P
DbServer.SC_MODE3_GETCOMPDETAIL_P=18                      --发送大奖赛明细信息到玩家(仅比赛本身的信息)
DbServer.SC_MODE3_COMPDETAIL_QISHU_P=19                   
DbServer.SC_MODE3_COMPDETAIL_ENTER_P=20                   --玩家进入模式3中一个大奖赛详情页面    SC_MODE3COMP_ENTER_P

DbServer.CS_MODE3_GETMYREWARD_P=21                        --获得大奖赛某玩家所有获奖信息
DbServer.SC_MODE3_GETMYREWARD_P=22                        --下发大奖赛某玩家所有获奖信息

DbServer.CS_MODE3_FIND_GAME_SHOW_P=23                     --请求指定游戏的可显示比赛
DbServer.SC_MODE3_FIND_GAME_SHOW_P=24                     


DbServer.SC_MODE3_BEGIN_END_CLEW_P=25                     --开启比赛结束提示
DbServer.SC_MODE3_RANK_WAIT_BEGIN_P=26                    --开启比赛排名等待时间提示

DbServer.SC_MODE3_REWARDEMAIL_P=27                        --下发大奖赛获奖邮件消息协议（告诉玩家获奖了，如果玩家不是正在游戏的话就要弹出提示框）
DbServer.SC_MODE3_COMPEND_P=28                            --比赛时间已到


DbServer.SD_BUYU_INIT_PLAYER_KUCHUN_P=29                  --捕鱼初始化玩家的数据
DbServer.DS_BUYU_INIT_PLAYER_KUCHUN_P=30                  

DbServer.SD_REQUEST_UPDATE_ROBOT_P=31                     --请求更新机器人
DbServer.DS_REQUEST_UPDATE_ROBOT_P=32                     

DbServer.SD_BUYU_PLAYER_INOUT_P=33                        --捕鱼玩家进出游戏时的随身库存记录
DbServer.SD_BUYU_BONUS_P=34                               --捕鱼分红记录
DbServer.SD_BUYU_PLAYER_STOCK_P=35                        --捕鱼玩家随身库存
DbServer.SD_BUYU_TOTALCATCH_P=36                          --记录玩家每种鱼的捕鱼数

DbServer.SC_WEB_CHANGE_ATTRIB_P=37                        --web请求变更玩家的属性

DbServer.SD_SERVER_HEART_P=38                             --GameServer与DBServer之间的心跳检测
DbServer.HD_SERVER_HEART_P=39                             --HallServer与DBServer之间的心跳检测

DbServer.DG_INIT_COMP_PARAM_P=40                          -- 初始化比赛参数
DbServer.SD_LOG_GAME_IMPORTANTDATE_P=41                   --游戏进行中重要数据记录
DbServer.SD_LOG_GAME_DATA_P=42                            --游戏日志

DbServer.SC_SET_HEADID_P=43                               --设置头像返回
DbServer.CS_PLAYER_OFFLINE_P=44                           --玩家离线

DbServer.SD_TRIG_MONEY_NOTICE_P=45                        --触发金钱提示
DbServer.CS_GET_LIMIT_CHONG_ZHI_P=46                      --得到充值限额
DbServer.SC_GET_LIMIT_CHONG_ZHI_P=47                      --得到充值限额
DbServer.SC_END_COMP_INFO_HTTP_P=48                       --Web通知比赛结束信息

DbServer.SC_BODY_WORD_ERROR_P=49                          --发送的包内存在非法字符
DbServer.NS_NOTITY_MSG_INFO_P=50                          --通知程序通知处理消息
DbServer.SN_NOTITY_MSG_INFO_P=51                          --回送处理
DbServer.SC_REGISTER_P=52                                 --HallServer向DBServer注册返回

DbServer.CS_REQUEST_OTHER_PLAYER_INFO_P=53                --查询其他玩家数据
DbServer.SC_REQUEST_OTHER_PLAYER_INFO_P=54                

DbServer.CS_REQUEST_BIND_ACCOUNT_P=55                     --请求绑定帐号
DbServer.SC_REQUEST_BIND_ACCOUNT_P=56                     

DbServer.CS_REQUEST_MONEY_RECORD_P=57                     --请求金币记录
DbServer.SC_REQUEST_MONEY_RECORD_P=58                     

DbServer.CS_REQUEST_LOTTERY_RECORD_P=59                   --请求奖券记录
DbServer.SC_REQUEST_LOTTERY_RECORD_P=60                   

DbServer.CS_REQUEST_COMP_RECORD_P=61                      --请求比赛记录
DbServer.SC_REQUEST_COMP_RECORD_P=62                      

DbServer.SD_LOG_GAME_TIMEDATA_P=63                        --计时回存游戏数据
DbServer.SC_BROADCAST_GAMELIST_P=64                       --主播游戏列表
DbServer.CS_BROADCAST_GAMELIST_P=65                       --主播游戏列表

DbServer.CS_REQUEST_RANK_P=66                             --请求各类排行榜通用协议
DbServer.SC_REQUEST_RANK_P=67                             

DbServer.CS_REQUEST_DIAMONDS_RECORD_P=68                  --获取钻石记录
DbServer.SC_REQUEST_DIAMONDS_RECORD_P=69                  

DbServer.CS_REQUEST_HONOR_RECORD_P=70                     --获取荣誉点记录
DbServer.SC_REQUEST_HONOR_RECORD_P=71                     

DbServer.DS_REQUEST_ROOM_TALK_P=72                        --请求桌子随机说话配置
DbServer.SD_REQUEST_ROOM_TALK_P=73                        

DbServer.SD_REGISTER_ROBOT_STATE_P=74                     --注册机器人服务器状态
DbServer.SD_REGISTER_SERVERMGR_P=75                       --注册服务器管理服务器
DbServer.SD_HEAT_REGISTER_SERVERMGR_P=76                  --心跳注册服务器管理服务器

DbServer.CD_REQUEST_CHONGZHI_DATA_P=77                    --请求充值数据
DbServer.DC_REQUEST_CHONGZHI_DATA_P=78                    

DbServer.DS_SERVER_HEART_P=79                             --GameServer与DBServer之间的心跳检测返回

DbServer.CD_REQUEST_ADDRESS_NAME_P=80                     --请求地名
DbServer.DC_REQUEST_ADDRESS_NAME_P=81                     

DbServer.SD_CHECK_GAMESERVER_LOCK_P=82                    --检测GameServer是否有锁

DbServer.CS_REQUEST_MEILI_RANK_P=83                       --请求魅力排行榜
DbServer.SC_REQUEST_MEILI_RANK_P=84                       

DbServer.CD_REQUEST_CHONGZHI_DINGDAN_ID_P=85              --请求充值定单号
DbServer.DC_REQUEST_CHONGZHI_DINGDAN_ID_P=86              

DbServer.SD_SAVE_JIESUAN_DATA_P=87                        --回存每局记录（结算数据）
DbServer.DS_SAVE_JIESUAN_DATA_P=88                        --返回玩家作弊参数

DbServer.CD_GET_PROXY_LIST_P=89                           --获取代理列表
DbServer.DC_GET_PROXY_LIST_P=90                           

DbServer.CD_PROXY_CHAT_P=91                               --代理聊天
DbServer.DC_PROXY_CHAT_P=92                               

DbServer.CD_PROXY_RECHARGE_P=93                           --代理充值
DbServer.DC_PROXY_RECHARGE_P=94                           

DbServer.CD_REQUEST_PROXY_P=95                            --申请代理
DbServer.DC_REQUEST_PROXY_P=96

DbServer.CD_TRANSFER_P=97                                 --玩家转帐
DbServer.DC_TRANSFER_P=98                                 --转帐返回

DbServer.CD_REQUEST_TRANSFERLOG=99                        --查询转帐记录
DbServer.DC_REQUEST_TRANSFERLOG=100                       --查询转帐记录返回

--FCServer 朋友圈服务器协议
DbServer.CS_REGISTER_FC_P=1000                            --FCServer向DBServer注册
DbServer.SC_REGISTER_FC_P=1001                            

DbServer.FD_UPDATE_PARAMETERS_FC_P=1002                   --定时请求捐献-赠送设置
DbServer.DF_UPDATE_PARAMETERS_FC_P=1003                   

DbServer.FD_UPDATEPLAYER_P=1004                           --请求变化的玩家信息
DbServer.DF_UPDATEPLAYER_P=1005                           

DbServer.FD_CHECK_LOGIN_P=1006                            --验证登录
DbServer.DF_CHECK_LOGIN_P=1007                            

DbServer.FD_GET_PLAYER_INFO_P=1008                        --通过昵称或者playerid请求玩家基本信息
DbServer.DF_GET_PLAYER_INFO_P=1009                        

DbServer.FD_DONATE_MONEY_P=1010                           --捐献金币
DbServer.DF_DONATE_MONEY_P=1011                           

DbServer.FD_PROVIDE_MONEY_P=1012                          --派发金币
DbServer.DF_PROVIDE_MONEY_P=1013                          

DbServer.FD_PRESENTED_MONEY_P=1014                        --好友赠送金币
DbServer.DF_PRESENTED_MONEY_P=1015                        

DbServer.FD_GET_CRYPT_P=1016                              --获取一个密保
DbServer.DF_GET_CRYPT_P=1017                              

DbServer.FD_CHECK_CRYPT_P=1018                            --验证密保
DbServer.DF_CHECK_CRYPT_P=1019                            

DbServer.FD_SEND_EMAIL_P=1020                             --通过playerid发送邮件

DbServer.FD_LOAD_ALL_CIRCLE_P=1021                        --加载所有圈子信息
DbServer.DF_LOAD_ALL_CIRCLE_P=1022                        

DbServer.FD_LOAD_ALL_CIRCLE_MEMBERS_P=1023                --加载圈子成员表
DbServer.DF_LOAD_ALL_CIRCLE_MEMBERS_P=1024                

DbServer.FD_LOAD_ALL_PLAYERS_P=1025                       --加载圈子玩家
DbServer.DF_LOAD_ALL_PLAYERS_P=1026                       

DbServer.FD_LOAD_ALL_FRIENDS_P=1027                       --加载好友数据
DbServer.DF_LOAD_ALL_FRIENDS_P=1028                       

DbServer.FD_LOAD_ALL_PLAYER_CIRCLES_P=1029                --加载玩家所在圈子数据
DbServer.DF_LOAD_ALL_PLAYER_CIRCLES_P=1030                

DbServer.FD_LOAD_ALL_SYS_MESSAGE_P=1031                   --加载系统消息数据
DbServer.DF_LOAD_ALL_SYS_MESSAGE_P=1032                   

DbServer.FD_SAVE_PLAYER_P=1033                            --保存一个玩家的数据

DbServer.FD_SAVE_SYS_MESSAGE_P=1034                       --保存一条系统消息

DbServer.FD_SAVE_FRIEND_P=1035                            --保存一条好友关系数据

DbServer.FD_DELETE_FRIEND_P=1036                          --删除一条好友关系数据

DbServer.FD_SAVE_PLAYER_CIRCLE_P=1037                     --保存一条玩家圈子数据

DbServer.FD_DELETE_PLAYER_CIRCLE_P=1038                   --删除一条玩家圈子数据

DbServer.FD_SAVE_CIRCLE_P=1039                            --保存一条圈子数据

DbServer.FD_DELETE_CIRCLE_P=1040                          --删除一条圈子数据

DbServer.FD_SAVE_CIRCLE_MEMBERS_P=1041                    --保存圈子成员数据

DbServer.FD_DELETE_CIRCLE_MEMBERS_P=1042                  --删除一条圈子成员数据

DbServer.FD_GET_IF_CHECK_P=1043                           --向db确认是否需要验证一个玩家的密保
DbServer.DF_GET_IF_CHECK_P=1044                           

DbServer.FD_GET_FRIEND_LIST_P=1045                        --获取玩家的好友列表
DbServer.DF_GET_FRIEND_LIST_P=1046                        

DbServer.FD_GET_SYS_MESSAGE_LIST_P=1047                   --获取玩家的系统消息列表（最近50条）
DbServer.DF_GET_SYS_MESSAGE_LIST_P=1048                   

DbServer.FD_GET_CIRCLE_LIST_P=1049                        --获取玩家的圈子列表
DbServer.DF_GET_CIRCLE_LIST_P=1050                        

DbServer.FD_GET_CIRCLE_MEMBER_LIST_P=1051                 --获取圈子的成员列表
DbServer.DF_GET_CIRCLE_MEMBER_LIST_P=1052                 

DbServer.DF_SAVE_SYS_MESSAGE_RETURN_P=1053                --保存系统消息返回

DbServer.FD_GET_CIRCLE_P=1054                             --通过circleid获取一个圈子的基础数据
DbServer.DF_GET_CIRCLE_P=1055                             

DbServer.FD_GET_CIRCLE_RECOMMEND_P=1056                   --获取复数个推荐圈子
DbServer.DF_GET_CIRCLE_RECOMMEND_P=1057                   

DbServer.FD_CIRCLE_CREATE_P=1058                          --创建圈子
DbServer.DF_CIRCLE_CREATE_P=1059                          

DbServer.FD_CIRCLE_MODIFY_NOTICE_P=1060                   --修改圈子公告
DbServer.DF_CIRCLE_MODIFY_NOTICE_P=1061                   

DbServer.FD_CIRCLE_EXIT_P=1062                            --退出圈子
DbServer.DF_CIRCLE_EXIT_P=1063                            

DbServer.FD_CIRCLE_KICK_P=1064                            --踢出圈子
DbServer.DF_CIRCLE_KICK_P=1065                            

DbServer.FD_CIRCLE_SET_MANAGER_P=1066                     --设置管理员
DbServer.DF_CIRCLE_SET_MANAGER_P=1067                     

DbServer.FD_CIRCLE_ACCEPT_JOIN_P=1068                     --同意玩家的申请入圈请求
DbServer.DF_CIRCLE_ACCEPT_JOIN_P=1069                     

DbServer.FD_CIRCLE_GET_RECORD_P=1070                      --获取公会记录
DbServer.DF_CIRCLE_GET_RECORD_P=1071                      

DbServer.FD_CIRCLE_ASK_JOIN_P=1072                        --申请加入公会
DbServer.DF_CIRCLE_ASK_JOIN_P=1073                        

DbServer.FD_WORLD_CHAT_P=1074                             --世界聊天
DbServer.DF_WORLD_CHAT_P=1075                             

DbServer.FD_CIRCLE_GET_INCOME_P=1076                      --公会收益记录
DbServer.DF_CIRCLE_GET_INCOME_P=1077                      

DbServer.FD_CIRCLE_SEND_INFO_P=1078                       --转发消息
DbServer.DF_CIRCLE_SEND_INFO_P=1079                       

DbServer.CS_CUSTSRV_REPLY_P = 110
DbServer.SC_CUSTSRV_REPLY_P = 111
--endregion

--region Money.lua
Money={}
Money.SC_SET_MONEY_P=0                                 --金钱改变
Money.SC_SET_WALLETMONEY_P=1                           --钱包改变

Money.CS_SAVE_MONEY_P=2                                --存钱
Money.SC_SAVE_MONEY_RESULT_P=3                         

Money.CS_GET_MONEY_P=4                                 --取钱
Money.SC_GET_MONEY_RESULT_P=5                          

Money.CS_TEST_ADD_MONEY_P=6                            --测试,加钱
Money.SC_SET_GAME_MONEY_P=7                            --金钱改变
Money.SC_SET_GAME_WALLETMONEY_P=8                      --钱包改变

Money.SC_SET_HONOR_VALUE_P=9                           --荣誉点改变
Money.SC_SET_DIAMONDS_VALUE_P=10                       --钻石改变

Money.CS_DIAMONDS_CHANGE_MONEY_P=11                    --钻石 兑换金币
Money.SC_DIAMONDS_CHANGE_MONEY_P=12                    

Money.CS_DIAMONDS_CHANGE_VIP_P=13                      --钻石 兑换会员
Money.SC_DIAMONDS_CHANGE_VIP_P=14                      

Money.CS_DIAMONDS_TRANS_MONEY_CONFING_P=15             --钻石兑换金币配置
Money.SC_DIAMONDS_TRANS_MONEY_CONFING_P=16             

Money.CS_DIAMONDS_TRANS_VIP_CONFING_P=17               --钻石兑换会员配置
Money.SC_DIAMONDS_TRANS_VIP_CONFING_P=18               


Money.CS_RMB_TRANS_DIAMONDS_CONFING_P=19               --人民币换钻石配置
Money.SC_RMB_TRANS_DIAMONDS_CONFING_P=20               

Money.CS_RMB_TRANS_DIAMONDS_CONFING_IOS_P=21           --人民币换钻石配置_IOS
Money.SC_RMB_TRANS_DIAMONDS_CONFING_IOS_P=22           

Money.CS_TRANSFER_MONEY_P=23                           --玩家转帐
Money.SC_TRANSFER_MONEY_P=24                           

Money.CD_BIND_PICKUP_P=25                              --绑定提取号(支付宝\微信\卡)
Money.DS_BIND_PICKUP_P=26                              

Money.CD_BANK_PASSWORD_P=27                            --修改银行密码
Money.DS_BANK_PASSWORD_P=28                            

Money.CD_MONEY_CHANG_RMB_P=29                          --游戏币兑换现金
Money.DS_MONEY_CHANG_RMB_P=30                          

Money.CD_SEND_MSG_GUEST_SERVER_P=31                    --发送消息给客服务
Money.DC_SEND_MSG_GUEST_SERVER_P=32  
Money.CD_BIND_BANK_P = 33                             -- 绑定银行卡
Money.DS_BIND_BANK_P = 34                             -- 绑定银行卡返回                  

-- 返还金
Money.CS_REQUEST_ALMS_P = 37                            -- 查询救济金
Money.SC_REQUEST_ALMS_RESULT_P = 38                   -- 查询救济金结果 
Money.CS_GET_ALMS_P = 35                              -- 领取救济金 
Money.SC_GET_ALMS_RESULT_P = 36                       -- 领取救济金结果

-- 服务器定义
Money.CS_AGENT_COMPLAINT_P = 46                       -- 投诉代理
Money.CS_SERVICE_COMPLAINT_P = 47                     -- 投诉客服
Money.SC_COMPLAINT_RESULT_P = 48                       -- 投诉结果

--endregion

--region FindPsw.lua

FindPsw = {}
FindPsw.CS_FINDPSW_P=0                                   --找回密码
FindPsw.SC_FINDPSW_P=1                                   

FindPsw.CS_FINDPSW_REQUEST_CODE_P=2                      --请求手机验证码
FindPsw.SC_FINDPSW_REQUEST_CODE_RESULT_P=3               

FindPsw.CS_FINDPSW_CRYPT_P=4                             --输入密保答案
FindPsw.CS_FINDPSW_PHONECODE_P=5                         --输入手机验证码答案
FindPsw.SC_FINDPSW_CKECK_P=6                             --验证结果

FindPsw.CS_FINDPSW_SET_NEW_PSW_P=7                       --验证结束,设置新密码
FindPsw.SC_FINDPSW_SET_NEW_PSW_RESULT_P=8            

--endregion

--region NoticeManager.lua
NoticeManager = {}
NoticeManager.SC_NOTICE_P=0                                    
NoticeManager.CS_SEND_NOTICE_P=1                               --请求发送公告
NoticeManager.SC_SEND_NOTICE_P=2                               
NoticeManager.CS_REQUEST_NOTICE_NEED_P=3                       --请求发送公告所需
NoticeManager.SC_REQUEST_NOTICE_NEED_P=4                       
	
NoticeManager.CD_REQUEST_SYSTEM_NOTICE_P=5                     --请求系统公告内容
NoticeManager.DC_REQUEST_SYSTEM_NOTICE_P=6    

--endregion

--region Rank.lua

Rank = {}
Rank.CS_RANK_DATA          =   0   --获得排行榜信息
Rank.SC_RANK_DATA          =   1    --后端返回排行榜信息

Rank.CD_RANK_LIST          =   2    --向dbserver 获得排行榜信息
Rank.DC_RANK_LIST          =   3    --dbserver返回排行榜信息

Rank.CS_SELF_RANK_DATA_P		=	4
Rank.SC_SELF_RANK_DATA_P		=	5

Rank.CD_SELF_RANK_DATA		=	6
Rank.DC_SELF_RANK_DATA		=	7

--endregion

--region MailManager.lua

MailManager = {}

MailManager.CS_REQUEST_MAIL_INFO_P=0                         --请求一封邮件的内容
MailManager.SC_REQUEST_MAIL_INFO_P=1                         

MailManager.CS_MAIL_SET_READ_P=2                             --请求将一封邮件设置为已读
MailManager.CS_DEL_MAIL_INFO_P=3                             --请求删除一封邮件

MailManager.SC_ADD_MAIL_P=4                                  --添加一封邮件

MailManager.CS_REQUEST_MAILLIST_P=5                          --请求邮件列表
MailManager.SC_REQUEST_MAILLIST_P=6                          

--endregion

--region Game .lua
Game = {}
Game.SC_ADD_GAMELIST_P=0                              
Game.SC_DEL_GAMELIST_P=1                              

--房间协议
Game.SC_ROOM_INFO_P=2                                 --房间数据
Game.CS_ROOM_SET_PLAYER_STATE_P=3                     --玩家设置自己的状态
Game.SC_ROOM_SET_PLAYER_STATE_P=4                     --设置玩家状态(广播)
Game.SC_ROOM_SET_STATE_P=5                            --设置房间状态(广播)
Game.CS_ROOM_CHAT_P=6                                 --聊天
Game.SC_ROOM_CHAT_P=7                                 --聊天(广播)
Game.SC_ROOM_RESET_COIN_P=8                           

Game.SC_ROOM_ZANLI_SUCCESS_P=9                        --暂离成功
Game.CS_ROOM_ZANLI_COMBACK_P=10                       --玩家请求暂离回来
Game.SC_ROOM_ZANLI_COMBACK_SUCCESS_P=11               --玩家请求暂离回来成功

Game.SC_ROOM_PLAYER_ENTER_P=12                        --玩家进入房间(广播)
Game.SC_ROOM_WATCH_ENTER_P=13                         --观看者进入房间(广播)
Game.SC_ROOM_PLAYER_QUIT_P=14                         --玩家离开房间(广播)
Game.SC_ROOM_WATCH_QUIT_P=15                          --观看者离开房间(广播)
Game.SC_ROOM_DEL_P=16                                 --同意退出房间

Game.SC_ROOM_PREPARE_TIMEOUT_P=17                     --准备超时,你被踢出房间
Game.SC_ROOM_DEL_PLAYER_P=18                          --游戏结束,你条件不满足被踢出房间,如果你在暂离状态,也会被踢出房间
Game.SC_ROOM_DEL_WATCH_P=19                           --你是观看者,由于房间已经没有人了,你被踢出房间

--子游戏服务器协议
Game.XS_REGISTER_P=20                                 --子游戏服务器注册
Game.XS_DEL_WATCH_P=21                                --删除观看者
Game.XS_ZANLI_P=22                                    --玩家暂离
Game.XS_PLAYER_RESULT_P=23                            --一个玩家结算
Game.XS_RESULT_P=24                                   --游戏结束结算
Game.XS_RESET_COIN_P=25                               

Game.SX_CREATE_GAME_P=26                              --开始游戏 
Game.SX_ADD_WATCH_P=27                                --添加观看者
Game.SX_DEL_WATCH_P=28                                --删除观看者
Game.SX_RESET_COIN_P=29                               
Game.SX_PLAYER_LEAVE_P=30                             --玩家离线托管
Game.SX_PLAYER_ONLINE_P=31                            --玩家离线托管后上线
Game.SX_PLAYER_ZANLI_COMBACK_P=32                     --玩家暂离回来
Game.SX_QUIT_P=33                                     --客户端点击X

--公共
Game.CS_GAME_PLAYER_NUM_P=34                          --请求每个游戏玩家人数表
Game.SC_GAME_PLAYER_NUM_P=35                          
Game.SC_UPDATE_GAME_LIST_P=36                         --更新游戏列表
Game.CS_SELECT_GAME_P=37                              --客户端选择一个游戏
Game.SC_SELECT_GAME_P=38                              
Game.CS_ROBOT_ADD_MONEY_P=39                          --机器人请求加钱
Game.CS_QUIT_P=40                                     
Game.CS_WATCH_P=41                                    --请求观看
Game.SC_WATCH_P=42                                    
Game.CS_HUANZHUO_P=43                                 --换桌
Game.SC_HUANZHUO_P=44                                 

--模式1
Game.CS_MODE1_ENTER_P=45                              --玩家请求进入
Game.CS_MODE1_ROBOT_ENTER_P=46                        --机器人请求进入
Game.SC_MODE1_ENTER_P=47                              
Game.SC_MODE1_ROBOT_FAILD_P=48                        --机器人请求进入后续失败

--模式2
Game.CS_MODE2_ENTER_P=49                              --玩家请求进入模式2
Game.SC_MODE2_DATA_P=50                               --子厅可见数据
Game.SC_MODE2_ADD_PLAYER_P=51                         --子厅可见数据,增加一个玩家
Game.SC_MODE2_DEL_PLAYER_P=52                         --子厅可见数据,删除一个玩家
Game.SC_MODE2_ROOM_STATE_P=53                         --子厅可见数据,房间状态改变
Game.SC_MODE2_DATA_CREAT_ROOM_P=54                    --子厅可见数据,增加一张桌子
Game.SC_MODE2_DATA_CLEAR_ROOM_P=55                    --子厅可见数据,清空一张桌子

Game.CS_MODE2_CREATE_ROOM_P=56                        --创建房间
Game.SC_MODE2_CREATE_ROOM_P=57                        --结果
Game.CS_MODE2_ENTER_ROOM_P=58                         --进入房间
Game.SC_MODE2_ENTER_ROOM_P=59                         --结果

--模式3
Game.CS_MODE3_ENTER_P=60                              --玩家请求进入模式3 

Game.CS_MODE3_COMPDETAIL_EXIT_P=61                    --玩家离开大奖赛详情界面-不离开MOD3模式（请求离开模式3或退出游戏才退出MODE3模式
Game.CS_MODE3_GAME_ENTER_P=62                         --玩家请求进入模式3某个大奖赛进行游戏CS_MODE3GAME_ENTER_P 

Game.SC_MODE3_ENTER_P=63                              --玩家进入模式3

Game.SC_MODE3_GAME_ENTER_P=64                         --玩家进入模式3中一个大奖赛进行游戏SC_MODE3GAME_ENTER_P
Game.SC_MODE3_RETURNERROR_P=65                        --返回错误信息协议

Game.CS_MODE3_ENTER_PIPEI_P=66                        --一局完成后,通知其继续匹配
Game.SC_MODE3_ENTER_PIPEI_P=67                        --通知其进入匹配状态
Game.SC_MODE3_PIPEI_OVER_P=68                         --匹配成功,通知进入房间
Game.SC_MODE3_QUIT_PIPEI_SUCCESS_P=69                 --退出匹配成功(模式3退出时发送给客户端，没有这个协议，玩家打完一局退出时，就不会关闭游戏窗口)

Game.CS_MODE3_CHAT_P=70                               --玩家发送聊天信息
Game.SC_MODE3_CHAT_P=71                               --玩家发送聊天信息(服务器接收到玩家聊天信息之后，要广播)

Game.SC_MODE3_PALYERONLINE_P=72                       --玩家上下线协议

Game.CS_MODE3_GETCOMPPLAYERRANK_P=73                  --获得大奖赛玩家排名
Game.SC_MODE3_GETCOMPPLAYERRANK_P=74                  --下发大奖赛玩家排名

Game.SC_MODE3_OTHER_ONLINE_P=75                       --其它在线玩家


Game.SC_GAME_CLOSE_P=76                               --此游戏被关闭
Game.SX_KILL_P=77                                     --要求子游戏服务器关闭
Game.SX_ADD_PLAYER_P=78                               --可以中途进入的游戏,增加新玩家
Game.XS_ADD_PLAYER_P=79                               
Game.SX_JIESUAN_ALL_PLAYER_P=80                       --优雅关服,要求子游戏结算所有玩家
Game.SX_WEB_SET_P=81                                  --网站设置数据
Game.SX_WEB_GET_P=82                                  --网站获取数据
Game.XS_WEB_GET_P=83                                  
Game.XS_VIRTUAL_ENDGAME_P=84                          --虚拟结束游戏
Game.SC_VIRTUAL_ENDGAME_P=85                          

Game.SC_ROOM_DELETE_P=86                              --房间被主动删除,通知客户端
Game.XS_PLAYER_HAND_TUO_GUAN_P=87                     --玩家进入手动托管

Game.XS_ADD_WATCH_FAIL_P=88                           --增加观察者失败
Game.XS_XIAOBAISHA_24_P=89                            --一个玩家在小白鲨压中24倍

Game.CS_REQUEST_UNONLINE_CLEW_P=90                    --请求得到离线挽留信息
Game.SC_REQUEST_UNONLINE_CLEW_P=91                    

Game.SC_ROBOT_START_PREPARE_P=92                      --通知子服务器让玩家准备

Game.CS_MODE1_ENTER_PIPEI_P=93                        --一局完成后,通知其继续匹配
Game.SC_MODE1_ENTER_PIPEI_P=94                        --通知其进入匹配状态
Game.SC_MODE1_PIPEI_OVER_P=95                         --匹配成功,通知进入房间
Game.SC_MODE1_QUIT_PIPEI_SUCCESS_P=96                 --退出匹配成功
Game.XS_WEB_SET_P=97                                  -- web设置后，返回给web数据协议
Game.SC_CHANGE_PLAYER_GAME_RESULT_P=98                --改变玩家游戏结果
Game.SC_MODE3_PIPEI_STOP_P=99                         --停止比赛匹配

Game.CS_FORCE_CLOSE_SOCKET_P=100                      --强制与服务器断开

Game.XS_SAFE_CREATE_ROOM_P=101                        --安全创建房间

Game.SX_RELOAD_CONFIG_P=102                           --重新加载游戏配置

Game.XS_VIRTUAL_ENDGAME_OVER_P=103                    --虚拟结算完成通知GameServer对桌面成员进行处理
Game.XS_RESULT_OVER_P=104                             --结算完成通知GameServer对桌面进行处理 

Game.SX_UPDATE_LOGKEY_P=105                           --更新日志 
Game.SX_UPDATE_PLAYER_INFO_P=106                      --更新玩家信息到子游戏对100人游戏
Game.SX_DEL_ROOM_P=107                                --删除指定的房间
Game.SC_PLAYER_LEAVE_MODE_P=108                       --离开模式
Game.CS_REQUEST_ROOM_P=109                            --重新请求一次游戏房间数据
Game.SC_REQUEST_ROOM_P=110                            

Game.CS_REQUEST_BROADCAST_PLAYERNUM_P=111             --请求指定游戏主播房间人数
Game.SC_REQUEST_BROADCAST_PLAYERNUM_P=112             

Game.SC_ADD_BROADCAST_GAME_P=113                      --增加主播游戏
Game.SC_DEL_BROADCAST_GAME_P=114                      --减少主播游戏

Game.SC_RAND_ROOM_CHAT_P=115                          --随机在真人房间内说句话
Game.SC_ROOM_VIP_DEL_P=116                            --Vip退出删除房间

Game.CS_BROAD_PLAYERNUM_DETAIL_P=117                  --请求指定游戏类别的主播玩家数量统计
Game.SC_BROAD_PLAYERNUM_DETAIL_P=118                  

Game.SC_UPDATE_GAME_P=119                             --变更游戏服务器参数(低分、显示名字变更) 

Game.SC_SET_PLAYER_SEATID_P=120                       --设置玩家的坐位ID,暂只是robot有用
Game.SC_CLEAR_PLAYER_SEATID_P=121                     --清除于家的坐位ID,暂只用于robot

Game.XS_PLAYER_ONLINE_FAIL_P=122                      --请求得到子游戏数据失败

Game.CS_REQUEST_ENTER_GAME_P=123                     -- 客户端请求进入游戏房间
Game.SC_REQUEST_ENTER_GAME_P=124                     -- 客户端请求进入游戏房间返回

Game.CS_PLAYER_REPORT_P=125                           -- 玩家举报
Game.SC_PLAYER_REPORT_P=126                           -- 举报的响应
Game.SC_SLIDE_VERIFY_REQUEST_P = 127                  -- 发送验证请求 Server -> Client
Game.CS_SLIDE_VERIFY_P=128                            -- 客户端验证结果 Client -> Server 
Game.SC_SLIDE_VERIFY_P=129                            -- 服务器验证结果 Server -> Client
Game.GS_2_CLIENT_LOGIN_KEY_P = 132                    --捕鱼End
--百家乐游戏消息
Game.CS_GAME_BJL_ALLINFO_P   = 1300                 -- 请求百家乐全部桌面信息
Game.SC_GAME_BJL_ALLINFO_P   = 1310                    -- 返回百家乐全部桌面信息
Game.CS_MODE4_ENTER_P        = 1320               -- 玩家请求进入
Game.CS_MODE4_ROBOT_ENTER_P  = 1330                  -- 机器人请求进入
Game.SC_MODE4_ENTER_P        = 1340
Game.SC_MODE4_ROBOT_FAILD_P  = 1350                    -- 机器人请求进入后续失败
Game.XS_UPDATE_GAMERESULT_P  = 1360                 -- 传局结果

--endregion

--region XC .lua

XC = {}
XC.XC_ROOM_INFO_P=0                                 --房间数据
XC.XC_JIESUAN_P=1                                   --结算数据

XC.SC_VIRTUAL_BROADCAST_TIPS_P=2                    --虚拟主播游戏进行时的TIPS
XC.XC_BROADCAST_PROTOCOL_P=3                        --子游戏发送的广播消息
XC.XC_ROBOT_BROADCAST_P=4                           --子游戏广播给所有机器人的协议

--endregion

--region 全民代理
QMAgent = {}
QMAgent.CS_AGENT_PROMOTIONDATA=0		--获得推广佣金信息
QMAgent.SC_AGENT_PROMOTIONDATA=1        --返回获得推广佣金信息
QMAgent.CS_AGENT_GETMONEY=2             --领取佣金
QMAgent.SC_AGENT_GETMONEY=3             --领取佣金
QMAgent.CS_AGENT_MONEYDETAIL=4          --佣金明细
QMAgent.SC_AGENT_MONEYDETAIL=5          --佣金明细
QMAgent.CS_AGENT_MYTEAM=6               --我的团队
QMAgent.SC_AGENT_MYTEAM=7     			--我的团队

--endregion