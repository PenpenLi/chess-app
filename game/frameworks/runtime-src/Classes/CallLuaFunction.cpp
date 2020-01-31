//
//  CallLuaFunction.cpp
//  majo
//
//  Created by 李 丁 on 14-7-23.
//
//

#include <iostream>
#include "CallLuaFunction.h"
#include "./SDK/SHead.h"
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <time.h>
#include <stdio.h>
#include "cocos2d.h"

#include "SDK/SInstance.h"

#ifdef WIN32
#include "SStringConverter.h"
#endif

#include "MyListener.h"
using namespace std;
using namespace cocos2d;

enum emHttpRequstType
{
    emHttpRequstType_HeadData_RequestHead,
    emHttpRequstType_HeadData_UploadHead,
    emHttpRequstType_Competition_RequestHead,
    emHttpRequstType_TopPlayer_RequestHead,
    emHttpRequstType_Gift_RequestHead,
    emHttpRequstType_IOS_Buy,
    emHttpRequstType_Web,
    emHttpRequstType_IOS_GetOrderID,
};

CallLuaFunction::CallLuaFunction()
{
    
}

// ios支付专用
void CallLuaFunction::SetIOSPayInfo(string strIP, int nPort, string pageName)
{
    m_iosStrIP = strIP;
    m_iosPort = nPort;
    m_pageName = pageName;
}

string CallLuaFunction::GetIOSPayPrivateInfo(string itemName)
{
    vector<SVar> ret;
    INSTANCE(SLua)->InitFun("GetIOSPayPrivateInfo");
    INSTANCE(SLua)->Push(itemName);
    ret = INSTANCE(SLua)->ExecFun(1);
    if (ret.size() > 0)
    {
        string privateInfo = ret[0].ToString();
        CCLOG("GetIOSPayPrivateInfo %s",privateInfo.c_str());
        return privateInfo;
    }
    CCLOG("GetIOSPayPrivateInfo ERROR!!!");
    return "";
}

void CallLuaFunction::SendIOSPayResult(string strPayID, string payTran)
{
    INSTANCE(SLua)->InitFun("SendIOSPayResult");
    INSTANCE(SLua)->Push(strPayID);
    INSTANCE(SLua)->Push(payTran);
    INSTANCE(SLua)->ExecFun(0);
}


void CallLuaFunction::SenIOSBuyToServer(string receipt, string privateInfo, string itemStr, string httpServer, int httpServerPort, string httpServerPage)
{
    // 记录信息
    INSTANCE(SLua)->InitFun("SaveIOSBuyInfo");
    INSTANCE(SLua)->Push("receipt");
    INSTANCE(SLua)->Push(itemStr);
    INSTANCE(SLua)->Push(privateInfo);
    INSTANCE(SLua)->ExecFun(0);
    
    // 验证
    char *szBuffer = new char[1*1024*1024];
    memset(szBuffer,0,1*1024*1024);
    sprintf(szBuffer,"receipt=%s&info=%s&item=%s",receipt.c_str(),privateInfo.c_str(),itemStr.c_str());
    INSTANCE(Http)->Post(httpServer.c_str(), httpServerPort, httpServerPage.c_str(),emHttpRequstType_IOS_Buy,szBuffer);
    delete []szBuffer;
}

void CallLuaFunction::SenIOSBuyToServer(string receipt, string itemStr,string privateInfo)
{
    // 获取privateInfo
    //string privateInfo = GetIOSPayPrivateInfo(itemStr);
    
    // 验证
    char *szBuffer = new char[1*1024*1024];
    memset(szBuffer,0,1*1024*1024);
    sprintf(szBuffer,"receipt=%s&info=%s&item=%s",receipt.c_str(),privateInfo.c_str(),itemStr.c_str());
    //INSTANCE(Http)->Post(m_iosStrIP.c_str(),m_iosPort,m_pageName.c_str(),emHttpRequstType_IOS_Buy,szBuffer);
    INSTANCE(Http)->NewPost(m_iosStrIP.c_str(),emHttpRequstType_IOS_Buy,szBuffer);
    delete []szBuffer;
}

void CallLuaFunction::FinishIOSBuy(void *pBuffer,unsigned int nSize)
{
    CCLOG("%s",(const char*)pBuffer);
    SVar iosVar;
    iosVar = SSerialize::ToSVar((const char*)pBuffer);
    string itemStr = iosVar["data"].ToString();
    
    INSTANCE(SLua)->InitFun("CompletIOSBuy");
    INSTANCE(SLua)->Push(itemStr);
    INSTANCE(SLua)->ExecFun(0);
}

void CallLuaFunction::SendEventToLua(string data)
{
	INSTANCE(SLua)->InitFun("SendEventToLua");
	INSTANCE(SLua)->Push(data);
	INSTANCE(SLua)->ExecFun(0);
}

string CallLuaFunction::GetUsecTime()
{
	struct timeval start; 
	gettimeofday(&start, NULL); 
	// 秒 微秒 
	char backStr[30] = {0};
	sprintf(backStr, "%f",(start.tv_sec + start.tv_usec/1000000.0));
	//CCLOG("CallLuaFunction::GetUsecTime %s",backStr);
	string backString = backStr;
	return backString; 
}

string CallLuaFunction::GetFormatCountDownTime(time_t nTimeSec)
{
    int nYear = 0;
    int nDay = 0;
    int nHour = 0;
    int nMin = 0;
    int nSec = 0;
    if (nTimeSec > 0)
    {
        if (nTimeSec >= (365 * 24 * 60 * 60))
        {// 年
            nYear = nTimeSec / (365 * 24 * 60 * 60);
            nTimeSec %= (365 * 24 * 60 * 60);
        }
        if (nTimeSec >= (24 * 60 * 60))
        {// 天
            nDay = nTimeSec / (24 * 60 * 60);
            nTimeSec %= (24 * 60 * 60);
        }
        if (nTimeSec >= (60 * 60))
        {// 小时
            nHour = nTimeSec / (60 * 60);
            nTimeSec %= (60 * 60);
        }
        if (nTimeSec >= 60)
        {
            nMin = nTimeSec / 60;
            nTimeSec %= 60;
        }
        if (nTimeSec >= 0)
        {
            nSec = nTimeSec;
        }
    }
    
    // 格式化
    char backStr[30] = {0};
    if (nYear > 0)
    {
        sprintf(backStr, "%d年%d天%.2d小时%.2d分钟%.2d秒",nYear,nDay,nHour,nMin,nSec);
    }
    else if (nDay > 0)
    {
        sprintf(backStr, "%d天%.2d小时%.2d分钟%.2d秒",nDay,nHour,nMin,nSec);
    }
    else if (nHour > 0)
    {
        sprintf(backStr, "%.2d小时%.2d分钟%.2d秒",nHour,nMin,nSec);
    }
    else if (nMin > 0)
    {
        sprintf(backStr, "%.2d分钟%.2d秒",nMin,nSec);
    }
    else if (nSec >= 0)
    {
        sprintf(backStr, "%.2d秒",nSec);
    }
    string backString = backStr;
    return backString;
}

string CallLuaFunction::GetFormatTime(time_t nTimeSec)
{
    tm *nowTM;
    time_t nowTime = nTimeSec;
    nowTM = localtime(&nowTime);
    // 格式化
    char backStr[30] = {0};
	sprintf(backStr, "%d.%d.%d %.2d:%.2d",nowTM->tm_year+1900, nowTM->tm_mon+1,nowTM->tm_mday,nowTM->tm_hour,nowTM->tm_min);
    string backString = backStr;
    return backString;
}

string CallLuaFunction::GetFormatTimeWithSecond(time_t nTimeSec)
{
    tm *nowTM;
    time_t nowTime = nTimeSec;
    nowTM = localtime(&nowTime);
    // 格式化
    char backStr[30] = {0};
	sprintf(backStr, "%d/%d/%d %.2d:%.2d:%.2d",nowTM->tm_year+1900, nowTM->tm_mon+1,nowTM->tm_mday,nowTM->tm_hour,nowTM->tm_min,nowTM->tm_sec);
    string backString = backStr;
    return backString;
}

void CallLuaFunction::OpenBlockNetMsg()
{
	INSTANCE(SLua)->InitFun("Pt_Public_OpenBlockNetMsg");
    INSTANCE(SLua)->ExecFun(0);
}

void CallLuaFunction::SetSysTime()
{
	INSTANCE(SLua)->InitFun("Pt_Public_SetSysTime");
    INSTANCE(SLua)->ExecFun(0);
}

void CallLuaFunction::SendGetIPTBSuccess(string strIP)
{
	//string strIP, int nPort, string pageName,int nCompetitionID
	INSTANCE(SLua)->InitFun("SendGetIPTBSuccess");
	INSTANCE(SLua)->Push(strIP);
    INSTANCE(SLua)->ExecFun(0);
}

#ifdef WIN32
#ifndef GLFW_EXPOSE_NATIVE_WIN32
#define GLFW_EXPOSE_NATIVE_WIN32
#endif
#ifndef GLFW_EXPOSE_NATIVE_WGL
#define GLFW_EXPOSE_NATIVE_WGL
#endif
#include "glfw3native.h"
#endif

bool CallLuaFunction::CheckIsHaveFramwork4()
{
#ifdef WIN32
	HKEY hKey;
    LPCTSTR path=TEXT("SOFTWARE\\Microsoft\\.NETFramework\\v4.0.30319");
    LONG lResult=RegOpenKeyEx(HKEY_LOCAL_MACHINE,path,0,KEY_READ,&hKey);
    ::RegCloseKey(hKey);
    if(lResult != ERROR_SUCCESS)
    {
        cout<<"系统里没安装.NETFramework!"<<endl;
        return false;
    }
    else
    {
        cout<<"系统里已经安装.NETFramework!"<<endl;
        return true;
    }
	return false;
#else
	return true;
#endif
}

#ifdef WIN32
#define _WIN32_DCOM
#include <iostream>
using namespace std;
#include <comdef.h>
#include <Wbemidl.h>
# pragma comment(lib, "wbemuuid.lib")
#endif
int CallLuaFunction::GetWinUuid(string &uuid)
{
#ifdef WIN32
	if (m_uuid.length() > 0)
	{
		uuid = m_uuid;
		return 1;
	}

	HRESULT hres;

	// Step 1: --------------------------------------------------
	// Initialize COM. ------------------------------------------

	hres = CoInitializeEx(0, COINIT_MULTITHREADED);
	if (FAILED(hres))
	{
		cout << "Failed to initialize COM library. Error code = 0x"
			<< hex << hres << endl;
		return 1;                  // Program has failed.
	}

	// Step 2: --------------------------------------------------
	// Set general COM security levels --------------------------
	// Note: If you are using Windows 2000, you need to specify -
	// the default authentication credentials for a user by using
	// a SOLE_AUTHENTICATION_LIST structure in the pAuthList ----
	// parameter of CoInitializeSecurity ------------------------

	hres = CoInitializeSecurity(
		NULL,
		-1,                          // COM authentication
		NULL,                        // Authentication services
		NULL,                        // Reserved
		RPC_C_AUTHN_LEVEL_DEFAULT,   // Default authentication 
		RPC_C_IMP_LEVEL_IMPERSONATE, // Default Impersonation  
		NULL,                        // Authentication info
		EOAC_NONE,                   // Additional capabilities 
		NULL                         // Reserved
	);

	if (FAILED(hres))
	{
		cout << "Failed to initialize security. Error code = 0x"
			<< hex << hres << endl;
		CoUninitialize();
		return 1;                    // Program has failed.
	}

	// Step 3: ---------------------------------------------------
	// Obtain the initial locator to WMI -------------------------

	IWbemLocator *pLoc = NULL;

	hres = CoCreateInstance(
		CLSID_WbemLocator,
		0,
		CLSCTX_INPROC_SERVER,
		IID_IWbemLocator, (LPVOID *)&pLoc);

	if (FAILED(hres))
	{
		cout << "Failed to create IWbemLocator object."
			<< " Err code = 0x"
			<< hex << hres << endl;
		CoUninitialize();
		return 1;                 // Program has failed.
	}

	// Step 4: -----------------------------------------------------
	// Connect to WMI through the IWbemLocator::ConnectServer method

	IWbemServices *pSvc = NULL;

	// Connect to the root\cimv2 namespace with
	// the current user and obtain pointer pSvc
	// to make IWbemServices calls.
	hres = pLoc->ConnectServer(
		_bstr_t(L"ROOT\\CIMV2"), // Object path of WMI namespace
		NULL,                    // User name. NULL = current user
		NULL,                    // User password. NULL = current
		0,                       // Locale. NULL indicates current
		NULL,                    // Security flags.
		0,                       // Authority (e.g. Kerberos)
		0,                       // Context object 
		&pSvc                    // pointer to IWbemServices proxy
	);

	if (FAILED(hres))
	{
		cout << "Could not connect. Error code = 0x"
			<< hex << hres << endl;
		pLoc->Release();
		CoUninitialize();
		return 1;                // Program has failed.
	}

	cout << "Connected to ROOT\\CIMV2 WMI namespace" << endl;

	// Step 5: --------------------------------------------------
		// Set security levels on the proxy -------------------------

	hres = CoSetProxyBlanket(
		pSvc,                        // Indicates the proxy to set
		RPC_C_AUTHN_WINNT,           // RPC_C_AUTHN_xxx
		RPC_C_AUTHZ_NONE,            // RPC_C_AUTHZ_xxx
		NULL,                        // Server principal name 
		RPC_C_AUTHN_LEVEL_CALL,      // RPC_C_AUTHN_LEVEL_xxx 
		RPC_C_IMP_LEVEL_IMPERSONATE, // RPC_C_IMP_LEVEL_xxx
		NULL,                        // client identity
		EOAC_NONE                    // proxy capabilities 
	);

	if (FAILED(hres))
	{
		cout << "Could not set proxy blanket. Error code = 0x"
			<< hex << hres << endl;
		pSvc->Release();
		pLoc->Release();
		CoUninitialize();
		return 1;               // Program has failed.
	}

	// Step 6: --------------------------------------------------
	// Use the IWbemServices pointer to make requests of WMI ----

	// For example, get the name of the operating system
	IEnumWbemClassObject* pEnumerator = NULL;
	hres = pSvc->ExecQuery(
		bstr_t("WQL"),
		bstr_t("SELECT * FROM Win32_PhysicalMedia"),
		WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY,
		NULL,
		&pEnumerator);

	if (FAILED(hres))
	{
		cout << "Query for physical media failed."
			<< " Error code = 0x"
			<< hex << hres << endl;
		pSvc->Release();
		pLoc->Release();
		CoUninitialize();
		return 1;               // Program has failed.
	}

	// Step 7: -------------------------------------------------
	// Get the data from the query in step 6 -------------------

	IWbemClassObject *pclsObj;
	ULONG uReturn = 0;

	while (pEnumerator)
	{
		HRESULT hr = pEnumerator->Next(WBEM_INFINITE, 1,
			&pclsObj, &uReturn);

		if (0 == uReturn)
		{
			break;
		}

		VARIANT vtProp;

		// Get the value of the Name property
		hr = pclsObj->Get(L"SerialNumber", 0, &vtProp, 0, 0);

		wcout << "Serial Number : " << vtProp.bstrVal << endl;
		_bstr_t bstr_t(vtProp.bstrVal);
		std::string uuidStr(bstr_t);
		uuid = uuidStr;
		m_uuid = uuid;
		VariantClear(&vtProp);
		break; // only need one number
	}

	// Cleanup
	// ========

	pSvc->Release();
	pLoc->Release();
	pEnumerator->Release();
	pclsObj->Release();
	CoUninitialize();
#endif
	return 0;   // Program successfully completed.
}


#ifdef WIN32
#ifndef GLFW_EXPOSE_NATIVE_WIN32
#define GLFW_EXPOSE_NATIVE_WIN32
#endif
#ifndef GLFW_EXPOSE_NATIVE_WGL
#define GLFW_EXPOSE_NATIVE_WGL
#endif
#include "glfw3native.h"
#endif
void CallLuaFunction::SetWinCopyStr(string str)
{
#ifdef WIN32
	GLViewImpl* glview = dynamic_cast<GLViewImpl*> (Director::getInstance()->getOpenGLView());
	GLFWwindow *glfwWindow = glview->getWindow();
	HWND hwnd = glfwGetWin32Window(glfwWindow);
	OpenClipboard(hwnd);
	EmptyClipboard();
	HGLOBAL hgl = GlobalAlloc(GMEM_MOVEABLE, 100 * sizeof(WCHAR));
	LPWSTR lpstrcpy = (LPWSTR)GlobalLock(hgl);
	WCHAR ntext[100];
	//memcpy(lpstrcpy, str.c_str(), 100 * sizeof(WCHAR));  
	GlobalUnlock(hgl);
	string tmpStr = "";
	tmpStr = SStringConverter::UTF8_ANSI(str.c_str());
	memcpy(lpstrcpy, tmpStr.c_str(), 100 * sizeof(WCHAR));
	SetClipboardData(CF_TEXT, lpstrcpy);
	CloseClipboard();
#endif
}

string CallLuaFunction::GetWinCopyStr()
{
	string str = "";
#ifdef WIN32
	GLViewImpl* glview = dynamic_cast<GLViewImpl*> (Director::getInstance()->getOpenGLView());
	GLFWwindow *glfwWindow = glview->getWindow();
	HWND hwnd = glfwGetWin32Window(glfwWindow);
	OpenClipboard(hwnd);
	if (IsClipboardFormatAvailable(CF_TEXT))
	{
		//取出数据  
		HGLOBAL hg = GetClipboardData(CF_TEXT);
		//锁定内存块  
	   // LPWSTR wstr = (LPWSTR)GlobalLock(hg);  
		LPBYTE wstr = (LPBYTE)GlobalLock(hg); // 锁定内存

		if (wstr != NULL)
		{
			str = (LPSTR)wstr;
		}
		GlobalUnlock(hg);
	}
	CloseClipboard();

	WCHAR wszBuf[512] = { 0 };
	MultiByteToWideChar(936, 0, str.c_str(), -1, wszBuf, sizeof(wszBuf) / sizeof(wszBuf[0]));
	str = SStringConverter::Unicode_UTF8(wszBuf);
#endif
	return str;
}

void CallLuaFunction::OpenWinUrl(string url)
{
#ifdef WIN32
	unsigned len = url.size() * 2;// 预留字节数
	setlocale(LC_CTYPE, "");     //必须调用此函数
	wchar_t *p = new wchar_t[len];// 申请一段内存存放转换后的字符串
	mbstowcs(p, url.c_str(), len);// 转换
	std::wstring str1(p);
	delete[] p;// 释放申请的内存
	ShellExecute(NULL, L"open", str1.c_str(), NULL, NULL, SW_SHOW);
#endif
}






