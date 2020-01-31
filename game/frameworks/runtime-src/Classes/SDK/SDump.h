
#pragma once
#include <winbase.h>
#include <Dbghelp.h>
#include <time.h>
/*#include "SWindowsHead.h"
#include "SMemoryLeakHead.h"
#include "SDebug.h"*/
#pragma comment(lib,"Dbghelp.lib")
#define OPEN_DUMP_CHECK SDump::GetInstance();
#define SetDumpCallBack(FunName) SDump::GetInstance()->SetCallBack(FunName);

namespace SDK
{

	class SDump
	{
	public:
		typedef void		(*CallbackFun)();	
	public:
		SDump()
		{
			m_pCallbackFun=NULL;
			::SetUnhandledExceptionFilter(OnFileDump);
		}
		static SDump*		GetInstance()
		{
			static SDump s;
			return &s;
		}
	public:
		void				SetCallBack(CallbackFun pFun)
		{
			if(pFun==NULL)
			{
// 				SHOW("SDump::SetCallBack ²ÎÊý´íÎó:pFun==NULL");
				return;
			}

			m_pCallbackFun=pFun;
		}
	public:
		static LONG WINAPI	OnFileDump(LPEXCEPTION_POINTERS pExceptionInfo)
		{
			if(SDump::GetInstance()->m_pCallbackFun)
				(SDump::GetInstance()->m_pCallbackFun)();

			time_t  nowtime;
			time(&nowtime);
			tm tempTime;
			localtime_s(&tempTime,&nowtime);
			char szFile[256]={};
			sprintf_s(szFile,256,"./Dump/%4d.%02d.%02d_%02d.%02d.%02d.dmp",
				tempTime.tm_year+1900,tempTime.tm_mon+1,tempTime.tm_mday,tempTime.tm_hour,tempTime.tm_min,tempTime.tm_sec);
			::CreateDirectoryA("Dump",0);
			HANDLE hFile=::CreateFileA(szFile,GENERIC_WRITE,FILE_SHARE_WRITE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
			if(hFile!=INVALID_HANDLE_VALUE)
			{
				MINIDUMP_EXCEPTION_INFORMATION ExInfo;
				ExInfo.ThreadId=GetCurrentThreadId();
				ExInfo.ExceptionPointers=pExceptionInfo;
				ExInfo.ClientPointers=false;

				MiniDumpWriteDump(GetCurrentProcess(),GetCurrentProcessId(),hFile,MiniDumpWithFullMemory,&ExInfo,NULL,NULL);
				::CloseHandle(hFile);
			}

			return EXCEPTION_EXECUTE_HANDLER;
		}
	private:
		CallbackFun			m_pCallbackFun;
	};
}