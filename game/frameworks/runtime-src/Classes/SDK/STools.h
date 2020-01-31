#pragma once
#include "SPlatformHead.h"
#include "SPlatform.h"
#include "SInstance.h"

#ifndef WIN32
#define byte unsigned char
#endif

namespace SDK
{
//<字符转换>--------------------------------------------------------------------------
    class STools
    {
    public:
        static string			    ANSI_UTF8(const char* pFormat,...);
		static int					RandomInt(int a,int b);
		static int					RandomInt();
	public:
		static void					BoolToBit(bool *pIn,int nSize,byte *pOut,bool bLittleEndian=true);
		static void					BitToBool(byte *pIn,int nSize,bool *pOut,bool bLittleEndian=true);
	public:
		static string				BinaryToString(void *pBuffer,int nSize);
		static int					StringToBinary(const char *pStr,void *pBuffer);
	public:
		static void					Simple_Encrypt(byte *p,int nSize);
		static void					Simple_Decrypt(byte *p,int nSize);
		
    };                                     
//<宏定义>----------------------------------------------------------------------------
    #define SM                      STools::ANSI_UTF8            
    #define SAFE_DELETE(p)			if(p){delete p;p=NULL;}
	#define SAFE_DELETE_ARRAY(p)	if(p){delete[] p;p=NULL;}
	#define ZERO(st)				st(){memset(this,0,sizeof(st));};				//结构体初始化

    #define Random_Init				srand(INSTANCE(STime)->GetTime());		    
	#define Random_Int(a,b)			STools::RandomInt((a),(b))						//产生一个[a,b]的随机数
	#define Random_Test(n)			(Random_Int(1,99)<n)							//随机判定,参数范围[0,100],<=0恒定返回false,>=100恒定返回true
	#define Random_Test_Ex(n,n1,n2)	(Random_Int(n1+1,n2-1)<n)						//随机判定,参数范围[n1,n2],<=n1恒定返回false,>=n2恒定返回true
	

}

