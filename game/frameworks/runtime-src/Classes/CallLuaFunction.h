//
//  CallLuaFunction.h
//  majo
//
//  Created by 李 丁 on 14-7-23.
//
//

#ifndef __majo__CallLuaFunction__
#define __majo__CallLuaFunction__

#include <iostream>
#include <string>
//#include "F_DouDiZhu.h"
//#include "CProtocolDDZCommon.h"
//#include "CProtocolDDZ.h"
//#include "HuPai.h"
using namespace std;

class CallLuaFunction
{
public:
    CallLuaFunction();
public:
    
	string GetUsecTime();
    string GetFormatCountDownTime(time_t nTimeSec);					// 格式化倒计时时间
    string GetFormatTime(time_t nTimeSec);							// 格式化年月日时间
    string GetFormatTimeWithSecond(time_t nTimeSec);				// 格式化年月日时间

	// c++ to lua
	void OpenBlockNetMsg();				// 开启网络阻塞
	void SetSysTime();					// 设置系统时间

	//IP表返回
	void SendGetIPTBSuccess(string strIP);
	// 检测是否安装了framwork4.0
	bool CheckIsHaveFramwork4();

	void SendEventToLua(string data);

	int GetWinUuid(string &uuid);

	void SetWinCopyStr(string str);									// 复制文字到剪切板
	string GetWinCopyStr();											// 从剪切板获取文字
	void OpenWinUrl(string url);

    // ios支付专用
    void SendIOSPayResult(string strPayID, string payTran);         // 通知服务器ios交易结果
    void SetIOSPayInfo(string strIP, int nPort, string pageName);
    string GetIOSPayPrivateInfo(string itemName);
    string GetIOSPayStrIP() {return m_iosStrIP; }
    int GetIOSPayPort() {return m_iosPort;}
    string GetIOSPayPageName() {return m_pageName;}
    // 发送ios支付到fwq验证
    void SenIOSBuyToServer(string receipt, string privateInfo, string itemStr, string httpServer, int httpServerPort, string httpServerPage);
    //ios支付到fwq验证
    void SenIOSBuyToServer(string receipt, string itemStr,string playerid); // 发送ios支付到fwq验证new
    void FinishIOSBuy(void *pBuffer,unsigned int nSize);            // 完成ios交易

private:
	string m_uuid;
    string m_iosStrIP;
    int m_iosPort;
    string m_pageName;
};

#endif /* defined(__majo__CallLuaFunction__) */
