#pragma once

#define BUFFER_SIZE				(8*1024)			
#define MAX_SIZE				(100*1024)			

#define SOCKETID				unsigned int

#define HEARTBEAT_FIRST_TIME	5000                //心跳检测,首次检测间隔时间
#define HEARTBEAT_SECOND_TIME	5000                //心跳检测,当HEARTBEAT_FIRST_TIME检测失败,连续监测时间


#define SERVER_PORT				65500				//Server监听端口
#define BORDCAST_PORT			65501				//UDP广播端口	
#define BORDCAST_CLOSE_TIME		400 				//收不到广播数据,被认为已经断开的检测时间
#define FRAME_LOCK				5        		    //帧锁定频率