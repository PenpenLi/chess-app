//跨平台
#pragma once
//#include "SWindowsHead.h"
#ifdef Def_Server
	#include "SMemoryLeakHead.h"
	#define SERROR SASSERT
	extern "C" 
	{
		#include "Lua/lua.h"
		#include "Lua/lualib.h"
		#include "Lua/lauxlib.h"
	}
#else
	#include "SPlatformHead.h"
	#define SERROR	throw
	#define INT64	long long
    #define byte	unsigned char
	extern "C" 
	{
		#include "lua.h"
		#include "lualib.h"
		#include "lauxlib.h"
	}
#endif

#pragma warning(disable:4244)		//warning C4244: “=”: 从“__int64”转换到“double”，可能丢失数据
#pragma warning(disable:4800)		//warning C4800: “double”: 将值强制为布尔值“true”或“false”(性能警告)

/*
遍历:
for(int i=0;i<s.GetSize();++i)
{
	SVar& sKey=s.GetKey(i);
	SVar& sValue=s.GetValue(i);
}
*/
#define	 Def_Lua_Max_Num		99999999999
namespace SDK
{
//<SVar>----------------------------------------------------------------------------------------
	enum SType  
	{  
		TP_NIL,  
		TP_NUMBER,
		TP_STRING,  
		TP_TABLE,	
		TP_NULL,
	};
	class SVar  
	{  
		friend class SSerialize;
		friend class SLua;  
		friend class SVarFunctor;
	public://构造  
		SVar();  
		SVar(int n);
		SVar(unsigned int n);
		SVar(INT64 n);
		SVar(double n);
		SVar(const char *p);
		SVar(const string &str);
		SVar(const SVar &s);
		~SVar();   
		SVar&    						operator=(int n);
		SVar&    						operator=(unsigned int n);
		SVar&    						operator=(INT64 n);
		SVar&    						operator=(double n);    
		SVar&    						operator=(const char *p);
		SVar&    						operator=(const string &str);
		SVar&    						operator=(const SVar &s); 
	public:
		template<typename T,typename U>
		void							Insert(T key,U value)
		{
			if(Push(new SVar(key),new SVar(value))==false)
				throw("Insert 错误1");
		};
		template<typename U>
		void							Insert(U value)
		{
			SVar *pKey=new SVar(1);
			for(int i=0;i<(int)m_dbNumber;i+=2)
			{
				if(m_pTable[i]->m_type==TP_NUMBER)
				{
					if(m_pTable[i]->m_dbNumber>=pKey->m_dbNumber)
					{
						pKey->m_dbNumber=(long long)(m_pTable[i]->m_dbNumber+1);
					}
				}
			}

			if(Push(pKey,new SVar(value))==false)
				throw("Insert 错误1");
		};
	public:
		void							Clear();
		void							ClearTable();
		SType							Type();
		void							SetType(SType tp);
		bool							IsEmpty();
		bool							IsNil();
		bool							IsNumber();
		bool							IsString();
		bool							IsTable();
	public://基本类型  
		template<typename T>
		T         						ToNumber()
		{
			return (T)m_dbNumber;
		}
		string		 					ToString();      
	public://表类型
		bool							Find(int n);
		bool							Find(unsigned int n);
		bool							Find(INT64 n);
		bool							Find(double n);
		bool							Find(const char *p);
		bool							Find(const string &str);

		SVar&							operator[](int n);
		SVar&							operator[](unsigned int n);
		SVar&							operator[](INT64 n);
		SVar&							operator[](double n);
		SVar&							operator[](const char *p);
		SVar&							operator[](const string &str);
		SVar&							operator[](SVar *p);

		int								GetSize();
		SVar&							GetKey(int i);
		SVar&							GetValue(int i);
		bool							Push(SVar *pKey,SVar *pValue);
public:
		template<typename T>
		static bool			CheckNumber( T &nNum)			
		{
			INT64 nMax = Def_Lua_Max_Num;
			if ( nNum>(T)nMax)
			{				
				return false;
			}
			if (nNum<-(T)nMax)
				return false;
			return true;
		}
	private:  
		SType     						m_type;
		double      					m_dbNumber;
		string      					m_str;    
		SVar*							*m_pTable;
	};

//<SSerialize>----------------------------------------------------------------------------------
	class SSerialize
	{
	public:
		static unsigned int				ToBinary(SVar &s,byte *p,unsigned int nSize);				
		static string					ToString(SVar &s);
		static string					ToStringByFormat(SVar &s);
		static bool						ToSVar(SVar &s,byte *p,unsigned int nSize);			
		static SVar						ToSVar(const char *p);	
		static string				    DoubleToStr(double db);//将转成STRING
	private:
		static bool						ToSVar_Helper(SVar &s,byte *&p,unsigned int &nSize);
		static void						ToSVar_Helper(SVar &s,char *&p);
		static void						ToSVar_Helper_Delete(char *&p);
		static string					ToStringByFormat_Helper(SVar &s,int n);
	private:
		static void						DeleteZero(char *p);
	};

//<SLua>----------------------------------------------------------------------------------------
	class SLua
	{
	public:
		SLua();
		~SLua();
	public:
		void							SetLuaState(lua_State *p);
		void							CreateLuaState();
		bool							LoadFile(const char *pPath);
		bool							LoadFolder(const char *pPath);
		bool							LoadFolderByFullPath(const char *pPath);
		void							Close();							
		bool							Reload();						
		void							Register(const char *funcName,lua_CFunction function);
	public:
		vector<SVar>					Get();								//lua调用C++,得到传入参数
		void							PushNil();
		void							Push(const char *pstr);
        void							Push(string &str);
		void							Push(double dbNumber);
		void							Push(SVar& s);
	public://操作lua全局变量
		SVar							GetGlobal(const char* pName);
		void							SetGlobal(const char* pName);		//先Push,再调用
	public://调用lua函数
		void							InitFun(const char* pFunName);
		vector<SVar>					ExecFun(int nReturn); 
	private:
		void							Helper1(SVar &s);
	public:
		lua_State						*m_pLua;
		bool							m_bCreateLuaState;
		vector<string>					m_strPath;
		map<string,lua_CFunction>		m_mapFun;
		int								m_nStack;
	};
}

//测试代码
/*
SVar s;
SVar s1;
s1[1]=-999999999999;
s1[2]=-99999999999;
s1[3]=-9999999999;
s1[4]=-999999999;
s1[5]=-99999999;
s1[6]=-9999999;
s1[7]=-999999;
s1[8]=-99999;
s1[9]=-9999;
s1[10]=-999;
s1[11]=-99;
s1[12]=-9;
s1[13]=0;
s1[14]=9;
s1[15]=99;
s1[16]=999;
s1[17]=9999;
s1[18]=99999;
s1[19]=999999;
s1[20]=9999999;
s1[21]=99999999;
s1[22]=999999999;
s1[23]=9999999999;
s1[24]=99999999999;
s1[25]=999999999999;
s1[26]=123.456;
s1[27]="";
s1[28]="abc";
s1[29]="1dsaklfjsklajdlksadkjsaljdlkjlkqwjdlkajklsdjklsajdlkAAAAAAAAAsajdlksjaldjslakjdlksajdlksajkldjsakldjlksajdlksajdasldsadow1";
s1[30]=0;
s1[31]=1;
s1[32]=2;
s1[33]=3;
s1[34]=4;
s1[35]=5;
s[1]=s1;
s[2]=s1;
s[3][1]=s1;
s[3][2]=s1;

//测试网络还原
byte *pBuffer=new byte[1024*1024];
int nSize=SSerialize::ToBinary(s,pBuffer,1024*1024);
SVar s2;
bool bSuccess=SSerialize::ToSVar(s2,pBuffer,nSize);

//测试字符串还原
//string str=SSerialize::ToString(s);
//SVar s2=SSerialize::ToSVar(str.c_str());

SHOW(s2);
*/