//跨平台
//文件系统一律采用/作为分隔符

//#define SERVER

#ifdef SERVER
	#include "SWindowsHead.h"
	#include "SDebug.h"
	#define SERROR SASSERT
#else
	#define SERROR throw
#endif

#pragma once
#ifdef _WIN32 
	#include <Windows.h>
    #include <direct.h>
#else
	#include <sys/stat.h>
	#include <sys/types.h>
	#include <dirent.h>
    #include <unistd.h>
#endif
#include <stdio.h>
#include <string>
#include <vector>
using namespace std;

namespace SDK
{
//<SFile>------------------------------------------------------------------------------------------------------------
	class SFile
	{
	public:
		static string			GetPath();																	//得到当前进程路径

		static int				GetFileSize(const char *pFile);												//获取文件大小
		static int				ReadFile(const char *pFile,void *pBuffer,unsigned int nSize);				//读取文件
		static void				Create(const char *pFile,void *pBuffer=NULL,unsigned int nSize=0);			//创建并写入新文件,如果有文件则删除,如果路径没有文件夹则创建失败
		static void				CreateFolder(const char *pFile);											//递归创建文件夹
		static void				Delete(const char *pFile);													//删除文件或者文件夹

		static vector<string>	GetAllFile(const char*pFile,const char *pSuffix=NULL);						//获得所有文件,pSuffix格式如:"lua",如果pSuffix==NULL,则返回所有文件
		static vector<string>	GetAllFolder(const char*pFile);												//获得所有文件夹
		static vector<string>	GetFirstFolder(const char*pFile);											//获得第一层字文件夹
	};
}