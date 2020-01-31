#include "../SLua.h"
#include "../SFile.h"
using namespace SDK;

#ifdef Def_Server
	#include "../SDebug.h"
#endif

//<SVar>----------------------------------------------------------------------------------------
SVar::SVar()
{
	m_type=TP_NULL;
	m_dbNumber=0;
	m_pTable=NULL;
}
SVar::~SVar()
{
	if(m_pTable)
	{
		for(int i=0;i<(int)m_dbNumber;++i)
			delete m_pTable[i];
		delete[] m_pTable;
	}
}
SVar::SVar(int n)
{
	m_type=TP_NUMBER;
	m_dbNumber=n;
	m_pTable=NULL;
}
SVar::SVar(unsigned int n)
{
	m_type=TP_NUMBER;
	m_dbNumber=n;
	m_pTable=NULL;
}
SVar::SVar(INT64 n)
{
	m_type=TP_NUMBER;
	if (CheckNumber(n)==false)	n=0;
	m_dbNumber=(double)n;
	m_pTable=NULL;
}
SVar::SVar(double n)
{
	if (CheckNumber(n)==false)	n=0.0000;
	m_type=TP_NUMBER;
	m_dbNumber=n;
	m_pTable=NULL;
}
SVar::SVar(const char *pStr)
{
	m_type=TP_STRING;
	m_dbNumber=0;
	m_pTable=NULL;

	if(pStr)
		m_str=pStr;
}
SVar::SVar(const string &str)
{
	m_type=TP_STRING;
	m_dbNumber=0;
	m_pTable=NULL;

	m_str=str;
}
SVar::SVar(const SVar &s)
{
	m_type=s.m_type;
	m_dbNumber=0;
	m_pTable=NULL;

	switch(s.m_type)
	{
	case TP_NUMBER:
		m_dbNumber=s.m_dbNumber;
		break;
	case TP_STRING:
		m_str=s.m_str;
		break;
	case TP_TABLE:
		for(int i=0;i<(int)s.m_dbNumber;i+=2)
			Push(new SVar(*s.m_pTable[i]),new SVar(*s.m_pTable[i+1]));
		break;
	}
}
SVar&					SVar::operator=(int n)
{
	Clear();
	m_type=TP_NUMBER;
	m_dbNumber=n;    
	return *this;
}
SVar&					SVar::operator=(unsigned int n)
{
	Clear();
	m_type=TP_NUMBER;
	m_dbNumber=n;    
	return *this;
}
SVar&					SVar::operator=(INT64 n)
{
	Clear();
	m_type=TP_NUMBER;
	if (CheckNumber(n)==false)	n=0;
	m_dbNumber=(double)n;    
	return *this;
}
SVar&					SVar::operator=(double n)
{
	Clear();
	m_type=TP_NUMBER;
	if (CheckNumber(n)==false)	n=0.0000;
	m_dbNumber=n;    
	return *this;
}
SVar&					SVar::operator=(const char *pStr)
{
	Clear();
	m_type=TP_STRING;
	if(pStr)
		m_str=pStr;  
	return *this;  
}
SVar&					SVar::operator=(const string &str)
{
	Clear();
	m_type=TP_STRING;
	m_str=str;  
	return *this;  
}
SVar&					SVar::operator=(const SVar &s)
{
	Clear();
	m_type=s.m_type;

	switch(m_type)
	{
	case TP_NUMBER:
		m_dbNumber=s.m_dbNumber;
		break;
	case TP_STRING:
		m_str=s.m_str;
		break;
	case TP_TABLE:
		for(int i=0;i<(int)s.m_dbNumber;i+=2)
			Push(new SVar(*s.m_pTable[i]),new SVar(*s.m_pTable[i+1]));
		break;
	}

	return *this;
}
bool					SVar::IsEmpty()
{
	return m_type==TP_NULL;
}
void					SVar::Clear()
{
	switch(m_type)
	{
	case TP_NUMBER:
		m_dbNumber=0;
		break;
	case TP_STRING:
		m_str.clear();
		break;
	case TP_TABLE:
		if(m_pTable)
		{
			for(int i=0;i<(int)m_dbNumber;++i)
				delete m_pTable[i];
			delete[] m_pTable;
			m_pTable=NULL;
			m_dbNumber=0;
		}
		break;
	}

	m_type=TP_NULL;
}
void					SVar::ClearTable()
{
	if(m_pTable)
	{
		for(int i=0;i<(int)m_dbNumber;++i)
			delete m_pTable[i];
		delete[] m_pTable;
		m_pTable=NULL;
		m_dbNumber=0;
	}
}
SType					SVar::Type()
{
	return m_type;
}
void					SVar::SetType(SType tp)
{
	Clear();
	m_type=tp;
}
bool					SVar::IsNumber()
{
	return m_type==TP_NUMBER;
}
bool					SVar::IsString()
{
	return m_type==TP_STRING;
}
bool					SVar::IsTable()
{
	return m_type==TP_TABLE;
}
bool					SVar::IsNil()
{
	return m_type==TP_NIL;
}
string					SVar::ToString()  
{
	return m_str;  
}
bool					SVar::Find(int n)
{
	if(m_type!=TP_TABLE)
		return false;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return true;
	}
	return false;
}
bool					SVar::Find(unsigned int n)
{
	if(m_type!=TP_TABLE)
		return false;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return true;
	}
	return false;
}
bool					SVar::Find(INT64 n)
{
	if(m_type!=TP_TABLE)
		return false;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return true;
	}
	return false;
}
bool					SVar::Find(double n)
{
	if(m_type!=TP_TABLE)
		return false;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return true;
	}
	return false;
}
bool					SVar::Find(const char *p)
{
	if(m_type!=TP_TABLE)
		return false;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_STRING&&strcmp(m_pTable[i]->m_str.c_str(),p)==0)
			return true;
	}
	return false;
}
bool					SVar::Find(const string &str)
{
	if(m_type!=TP_TABLE)
		return false;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_STRING&&m_pTable[i]->m_str==str)
			return true;
	}
	return false;
}
SVar&					SVar::operator[](int n)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return *m_pTable[i+1];
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=new SVar(n);
	m_pTable[(int)m_dbNumber++]=new SVar;
	return *m_pTable[(int)m_dbNumber-1];
}
SVar&					SVar::operator[](unsigned int n)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return *m_pTable[i+1];
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=new SVar(n);
	m_pTable[(int)m_dbNumber++]=new SVar;
	return *m_pTable[(int)m_dbNumber-1];
}
SVar&					SVar::operator[](INT64 n)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}
	if (CheckNumber(n)==false)	n=0;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return *m_pTable[i+1];
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=new SVar(n);
	m_pTable[(int)m_dbNumber++]=new SVar;
	return *m_pTable[(int)m_dbNumber-1];
}
SVar&					SVar::operator[](double n)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}
	if (CheckNumber(n)==false)	n=0.0000;

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_NUMBER&&m_pTable[i]->m_dbNumber==n)
			return *m_pTable[i+1];
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=new SVar(n);
	m_pTable[(int)m_dbNumber++]=new SVar;
	return *m_pTable[(int)m_dbNumber-1];
}
SVar&					SVar::operator[](const char *p)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_STRING&&strcmp(m_pTable[i]->m_str.c_str(),p)==0)
			return *m_pTable[i+1];
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=new SVar(p);
	m_pTable[(int)m_dbNumber++]=new SVar;
	return *m_pTable[(int)m_dbNumber-1];
}
SVar&					SVar::operator[](const string &str)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(m_pTable[i]->m_type==TP_STRING&&m_pTable[i]->m_str==str)
			return *m_pTable[i+1];
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=new SVar(str);
	m_pTable[(int)m_dbNumber++]=new SVar;
	return *m_pTable[(int)m_dbNumber-1];
}
int								SVar::GetSize()
{
	return (int)m_dbNumber/2;
}
SVar&							SVar::GetKey(int i)
{
	return *m_pTable[i*2];
}
SVar&							SVar::GetValue(int i)
{
	return *m_pTable[i*2+1];
}
bool							SVar::Push(SVar *pKey,SVar *pValue)
{
	if(m_type!=TP_TABLE)
	{
		Clear();
		m_type=TP_TABLE;
	}

	switch(pKey->m_type)
	{
	case TP_NULL:
	case TP_NIL:
	case TP_TABLE:
		return false;
	}

	switch(pValue->m_type)
	{
	case TP_NULL:
	case TP_NIL:
		return false;
	}

	for(int i=0;i<(int)m_dbNumber;i+=2)
	{
		if(pKey->m_type==m_pTable[i]->m_type)
		{
			if(pKey->m_type==TP_NUMBER&&pKey->m_dbNumber==m_pTable[i]->m_dbNumber)
				return false;
			else if(pKey->m_type==TP_STRING&&pKey->m_str==m_pTable[i]->m_str)
				return false;
		}
	}

	if(m_pTable)
	{
		SVar **pTemp=new SVar*[(int)m_dbNumber+2];
		memcpy(pTemp,m_pTable,(int)m_dbNumber*sizeof(void*));
		delete[] m_pTable;
		m_pTable=pTemp;
	}
	else
		m_pTable=new SVar*[2];

	m_pTable[(int)m_dbNumber++]=pKey;
	m_pTable[(int)m_dbNumber++]=pValue;
	return true;
}

//<SSerialize>----------------------------------------------------------------------------------
/*
	低字节>>>>>>>>>>>>>>高字节

	nil:
	2位类型>6位占位

	数字:
	2位类型>2位字节位(0(代表8字节),1,2,3)
	[2的27次方负整数,2的27次方正整数]:1位符号位>数据
	(小数||(负无穷,2的27次方负整数)||(2的27次方正整数,正无穷):4位占位>8字节double

	字符串:
	2位类型
	后6为如果是[0,62],代表后面跟这么多字节的字符
	后6位如果是63,代表此字符串是以0结尾

	table:
	2位类型>1位表长度标记
	表长度标记0:[0,31]
	表长度标记1:[32,8191]和后一个字节一起构成表长度[32,8191]
*/
unsigned int			SSerialize::ToBinary(SVar &s,byte *p,unsigned int nSize)
{
	if(p==NULL)
		return 0;
	if(nSize==0)
		return 0;

	switch(s.m_type)
	{
	case TP_NULL:
		return 0;
	case TP_NIL:
		{
			//类型
			*p=TP_NIL;
			return 1;
		}
	case TP_NUMBER:
		{
			//整数&&[2的27次方负整数,2的27次方正整数]
			if((long long)(s.m_dbNumber)-s.m_dbNumber==0&&
				s.m_dbNumber>=-134217727&&
				s.m_dbNumber<=134217727)
			{
				unsigned int nTemp=(unsigned int)fabs(s.m_dbNumber);
				if(nTemp<=2047)
				{
					if(nSize<2)
						SERROR("SSerialize::ToBinary_Helper 超出范围");

					if(s.m_dbNumber<0)
						*((unsigned short*)p)=21|(nTemp<<5);
					else
						*((unsigned short*)p)=5|(nTemp<<5);
					return 2;
				}	
				else if(nTemp<=524287)
				{
					if(nSize<3)
						SERROR("SSerialize::ToBinary_Helper 超出范围");

					if(s.m_dbNumber<0)
						*p=25|(nTemp<<5);
					else
						*p=9|(nTemp<<5);
					*((unsigned short*)(p+1))=(nTemp>>3);
					return 3;
				}
				else
				{
					if(nSize<4)
						SERROR("SSerialize::ToBinary_Helper 超出范围");

					if(s.m_dbNumber<0)
						*((unsigned int*)p)=29|(nTemp<<5);
					else
						*((unsigned int*)p)=13|(nTemp<<5);
					return 4;
				}
			}
			else
			{
				if(nSize<9)
					SERROR("SSerialize::ToBinary_Helper 超出范围");

				*p=TP_NUMBER;
				*((double*)(p+1))=s.m_dbNumber;
				return 9;
			}
		}
		break;
	case TP_STRING:
		{
			//包头
			unsigned int length=s.m_str.length();
			if(length<63)
			{
				if(nSize<length+1)
					SERROR("SSerialize::ToBinary_Helper 超出范围");

				*p=TP_STRING|(length<<2);
				memcpy(p+1,s.m_str.c_str(),length);
				return length+1;
			}
			else
			{
				if(nSize<length+2)
					SERROR("SSerialize::ToBinary_Helper 超出范围");

				*p=(char)254;
				memcpy(p+1,s.m_str.c_str(),length+1);
				return length+2;
			}
		}
		break;
	case TP_TABLE:
		{
			//如果表长度为0
			if(s.m_pTable==NULL)
			{
				*p=TP_TABLE;
				return 1;
			}
	
			//长度
			unsigned int nCount=0;
			for(int i=0;i<(int)s.m_dbNumber;i+=2)
			{
				if(s.m_pTable[i+1]->m_type!=TP_NULL)
					++nCount;
			}
			
			if(nCount<=31)
			{
				*p=TP_TABLE|(nCount<<3);

				//数据
				unsigned int nReturn=1;
				for(int i=0;i<(int)s.m_dbNumber;i+=2)
				{
					if(s.m_pTable[i+1]->m_type==TP_NULL)
						continue;
					nReturn+=ToBinary(*s.m_pTable[i],p+nReturn,nSize-nReturn);
					nReturn+=ToBinary(*s.m_pTable[i+1],p+nReturn,nSize-nReturn);
				}
				return nReturn;
			}
			else if(nCount<=8191)
			{
				if(nSize<2)
					SERROR("SSerialize::ToBinary_Helper 超出范围");
				*((unsigned short*)p)=7|(nCount<<3);

				//数据
				unsigned int nReturn=2;
				for(int i=0;i<(int)s.m_dbNumber;i+=2)
				{
					if(s.m_pTable[i+1]->m_type==TP_NULL)
						continue;
					nReturn+=ToBinary(*s.m_pTable[i],p+nReturn,nSize-nReturn);
					nReturn+=ToBinary(*s.m_pTable[i+1],p+nReturn,nSize-nReturn);
				}
				return nReturn;
			}
			else
				SERROR("SSerialize::ToBinary_Helper Table过长");
		}
		break;
	}

	return 0;
}
string					SSerialize::ToString(SVar &s)
{
	string str;

	switch(s.m_type)
	{
	case TP_NULL:
		break;
	case TP_NIL:
		str="nil";
		break;
	case TP_NUMBER:
		{
			/*char szBuf[100]={0};
			sprintf(szBuf,"%f",s.m_dbNumber);
			DeleteZero(szBuf);*/
			str= DoubleToStr(s.m_dbNumber);//szBuf;
		}
		break;   
	case TP_STRING:
		{
			str="\"";

			int nPos=s.m_str.find("\"");
			if(nPos!=-1)
			{
				string strTemp=s.m_str;
				while(nPos!=-1)
				{
					strTemp.replace(nPos,1,"\\\"");
					nPos=strTemp.find("\"",nPos+=2);
				}
				str+=strTemp;
			}
			else
				str+=s.m_str;

			str+="\"";
		}
		break;
	case TP_TABLE:
		{
			str="{";
			for(int i=0;i<(int)s.m_dbNumber;)
			{
				if(s.m_pTable[i+1]->m_type==TP_NULL)
				{
					i+=2;
					continue;
				}

				str+="[";
				str+=ToString(*(s.m_pTable[i++]));
				str+="]=";
				str+=ToString(*(s.m_pTable[i++]));

				if(i==(int)s.m_dbNumber)
					break;
				else if(s.m_pTable[i+1]->m_type!=TP_NULL)
					str+=",";
			}
			str+="}";
		}
		break;
	}

	return str;
}
string					SSerialize::ToStringByFormat(SVar &s)
{
	string str;

	if(s.IsEmpty())
		str="NULL";
	else if(s.IsTable())
		str=ToStringByFormat_Helper(s,0);
	else
		str=SSerialize::ToString(s);

	return str;
}
string					SSerialize::ToStringByFormat_Helper(SVar &s,int n)
{
	string str;
	for(int i=0;i<n;++i)
		str+="    ";
	str+="{";

	if(s.m_dbNumber==0)
	{
		str+="}";
		return str;
	}
	if(s.m_dbNumber==2&&s.m_pTable[1]->m_type!=TP_TABLE)
	{
		//key
		str+="[";
		if(s.m_pTable[0]->m_type==TP_STRING)
		{
			str+="\"";
			str+=s.m_pTable[0]->m_str;
			str+="\"";
		}
		else
		{
			/*char szBuf[100]={0};
			sprintf(szBuf,"%f",s.m_pTable[0]->m_dbNumber);
			DeleteZero(szBuf);*/
			str+= DoubleToStr(s.m_pTable[0]->m_dbNumber);//szBuf;
		}
		str+="]=";

		//value
		switch(s.m_pTable[1]->m_type)
		{
		case TP_NIL:
			str+="nil";
			break;
		case TP_NUMBER:
			{
				/*char szBuf[100]={0};
				sprintf(szBuf,"%f",s.m_pTable[1]->m_dbNumber);
				DeleteZero(szBuf);
				str+=szBuf;*/
				str+= DoubleToStr(s.m_pTable[1]->m_dbNumber);//szBuf;
			}
			break;
		case TP_STRING:
			str+="\"";
			str+=s.m_pTable[1]->m_str;
			str+="\"";
			break;
		}

		str+="}";
		return str;
	}

	str+="\r\n";
	for(int i=0;i<(int)s.m_dbNumber;i+=2)
	{
		for(int j=0;j<n+1;++j)
			str+="    ";

		//key
		str+="[";
		if(s.m_pTable[i]->m_type==TP_STRING)
		{
			str+="\"";
			str+=s.m_pTable[i]->m_str;
			str+="\"";
		}
		else
		{
		/*	char szBuf[100]={0};
			sprintf(szBuf,"%f",s.m_pTable[i]->m_dbNumber);
			DeleteZero(szBuf);
			str+=szBuf;*/
			str+= DoubleToStr(s.m_pTable[i]->m_dbNumber);//szBuf;
		}
		str+="]=";

		//value
		switch(s.m_pTable[i+1]->m_type)
		{
		case TP_NIL:
			str+="nil";
			break;
		case TP_NUMBER:
			{
				/*char szBuf[100]={0};
				sprintf(szBuf,"%f",s.m_pTable[i+1]->m_dbNumber);
				DeleteZero(szBuf);
				str+=szBuf;*/
				str+= DoubleToStr(s.m_pTable[i+1]->m_dbNumber);//szBuf;
			}
			break;
		case TP_STRING:
			str+="\"";
			str+=s.m_pTable[i+1]->m_str;
			str+="\"";
			break;
		case TP_TABLE:
			{
				if(s.m_pTable[i+1]->m_dbNumber!=0)
				{
					if(s.m_pTable[i+1]->m_dbNumber>2)
					{
						str+="\r\n";
						str+=ToStringByFormat_Helper(*(s.m_pTable[i+1]),n+1);
					}
					else if(s.m_pTable[i+1]->m_pTable[1]->m_type==TP_TABLE)
					{
						str+="\r\n";
						str+=ToStringByFormat_Helper(*(s.m_pTable[i+1]),n+1);
					}
					else
						str+=ToStringByFormat_Helper(*(s.m_pTable[i+1]),0);
				}
				else
					str+="{}";
			}
			break;
		}

		//,\r\n
		if(i+2!=(int)s.m_dbNumber)
			str+=",\r\n";
	}
	str+="\r\n";
	for(int i=0;i<n;++i)
		str+="    ";
	str+="}";
	return str;
}
string	 SSerialize::DoubleToStr(double db)
{//将转成STRING
	if (SVar::CheckNumber(db)==false)
		db = 0.000000;
	char szBuf[600]={}; //db很长
	sprintf(szBuf,"%f",db);
	DeleteZero(szBuf);
	return szBuf;
}
bool					SSerialize::ToSVar(SVar &s,byte *p,unsigned int nSize)
{
	if(p==NULL&&nSize==0)
		return true;
	if(p==NULL)
		return false;
	if(nSize==0)
		return false;

	s.Clear();
	byte *pBuffer=p;
	if(ToSVar_Helper(s,pBuffer,nSize)==false)
	{
		s.Clear();
		return false;
	}
	return nSize==0;
}
bool				SSerialize::ToSVar_Helper(SVar &s,byte *&p,unsigned int &nSize)
{
	if(nSize==0)
		return false;

	//得到类型
	s.m_type=(SType)(*p&3);

	//值
	switch(s.m_type)
	{
	case TP_NULL:
		return false;
	case TP_NIL:
		++p;
		--nSize;
		return true;
	case TP_NUMBER:
		{
			//2位字节位
			unsigned int nTemp=((*p)>>2)&3;

			if(nTemp==0)
			{
				++p;
				--nSize;

				if(nSize<8)
					return false;

				//s.m_dbNumber=*((double*)p);
				memcpy(&s.m_dbNumber,p,8);

				p+=8;
				nSize-=8;
			}
			else
			{
				//1位符号位
				unsigned int nSign=((*p)>>4)&1;

				//数据
				if(nTemp==1)
				{
					if(nSize<2)
						return false;

					s.m_dbNumber=(*((unsigned short*)p))>>5;
					if(nSign==1)
						s.m_dbNumber=-s.m_dbNumber;

					p+=2;
					nSize-=2;
				}
				else if(nTemp==2)
				{
					if(nSize<3)
						return false;

					s.m_dbNumber=(((*p)>>5)&7)+((*((unsigned short*)(p+1)))<<3);
					if(nSign==1)
						s.m_dbNumber=-s.m_dbNumber;

					p+=3;
					nSize-=3;
				}
				else
				{
					if(nSize<4)
						return false;

					s.m_dbNumber=(*((unsigned int*)p))>>5;
					if(nSign==1)
						s.m_dbNumber=-s.m_dbNumber;

					p+=4;
					nSize-=4;
				}
			}	
		}
		return true;
	case TP_STRING:
		{
			//后6位
			unsigned int nTemp=(*p)>>2;
			++p;
			--nSize;

			if(nTemp==63)
			{
				while(nSize!=0)
				{
					if(*p==0)
					{
						++p;
						--nSize;
						return true;
					}

					s.m_str+=*p;
					++p;
					--nSize;
				}
				return false;
			}
			else
			{
				if(nSize<nTemp)
					return false;

				while(nTemp--)
				{
					if(*p==0)
						return false;
					s.m_str+=*p;
					++p;
					--nSize;
				}
			}
		}
		return true;
	case TP_TABLE:
		{
			//1位表长度类型
			unsigned int nTemp=((*p)>>2)&1;

			if(nTemp==0)
			{
				nTemp=(*p)>>3;
				++p;
				--nSize;
			}
			else
			{
				if(nSize<2)
					return false;

				nTemp=(*((unsigned short*)p))>>3;
				p+=2;
				nSize-=2;
			}

			for(unsigned int i=0;i<nTemp;++i)
			{
				//key
				SVar *pKey=new SVar;
				if(ToSVar_Helper(*pKey,p,nSize)==false)
				{
					delete pKey;
					return false;
				}

				//value
				SVar *pValue=new SVar;
				if(ToSVar_Helper(*pValue,p,nSize)==false)
				{
					delete pKey;
					delete pValue;
					return false;
				}

				if(s.Push(pKey,pValue)==false)
				{
					delete pKey;
					delete pValue;
					return false;
				}
			}
		}
		return true;
	default:
		return false;
	}
	return 0;
}
SVar					SSerialize::ToSVar(const char *p)
{
	SVar s;
	if(p==NULL)
		return s;

	char *pStr=(char*)p;
	switch(*pStr)
	{
	case 'n':		//TP_NIL
		{
			if(strncmp(pStr,"nil",3)!=0)
				SERROR("SSerialize::ToSVar 错误1");
			s.m_type=TP_NIL;
			pStr+=3;
		}
		break;		
	case '"':		//TP_STRING
		{
			s.m_type=TP_STRING;
			pStr+=1;

			while(*pStr!='"')
			{
				if(*pStr=='\\'&&*(pStr+1)=='"')
				{
					++pStr;
				}
				s.m_str+=*pStr;
				++pStr;
			}

			++pStr;
		}
		break;
	case '{':		//TP_TABLE
		{	
			s.m_type=TP_TABLE;
			ToSVar_Helper(s,pStr);
		}
		break;
	default:		//TP_NUMBER
		{
			s.m_type=TP_NUMBER;
			string strTemp;
			while((*pStr>='0'&&*pStr<='9')||*pStr=='.'||*pStr=='-')
			{
				strTemp+=*pStr;
				++pStr;
			}
			s.m_dbNumber=atof(strTemp.c_str());
		}
	}

	return s;
}
void					SSerialize::ToSVar_Helper(SVar &s,char *&p)
{
	if(*p!='{')
		SERROR("SSerialize::ToSVar_Helper 错误1");

	string strTemp;
	strTemp+=*p;
	++p;
	unsigned int nTemp=1;
	while(true)
	{
		if(*p==0)
			SERROR("SSerialize::ToSVar_Helper 错误2");
		else if(*p=='{')
			++nTemp;
		else if(*p=='}')
			--nTemp;

		strTemp+=*p;
		++p;
		if(nTemp==0)
			break;
	}

	char *pTemp=(char*)strTemp.c_str();
	++pTemp;
	if(*pTemp=='}')
		return;

	while(*pTemp!=0)
	{
		ToSVar_Helper_Delete(pTemp);

		//[
		if(*pTemp!='[')
			SERROR("SSerialize::ToSVar_Helper 错误3");
		++pTemp;

		//key]
		string strKey;
		while(*pTemp!=']')
		{
			if(*pTemp==0)
				SERROR("SSerialize::ToSVar_Helper 错误4");
			strKey+=*pTemp;
			++pTemp;
		}
		++pTemp;
		if(strKey.empty())
			SERROR("SSerialize::ToSVar_Helper 错误5");
		SVar *pKey=new SVar;
		bool bString=false;
		if(strKey[0]=='"')
		{
			if(strKey.length()<2)
				SERROR("SSerialize::ToSVar_Helper 错误6");
			if(strKey[strKey.length()-1]!='"')
				SERROR("SSerialize::ToSVar_Helper 错误7");

			bString=true;
			pKey->m_type=TP_STRING;
			if(strKey.length()>2)
				pKey->m_str=strKey.substr(1,strKey.length()-2).c_str();
		}
		else
		{
			for(unsigned int i=0;i<strKey.length();++i)
			{
				if((strKey[i]<'0'||strKey[i]>'9')&&strKey[i]!='.')
					SERROR("SSerialize::ToSVar_Helper 错误8");
			}

			bString=false;
			pKey->m_type=TP_NUMBER;
			pKey->m_dbNumber=atof(strKey.c_str());
		}

		ToSVar_Helper_Delete(pTemp);

		//=
		if(*pTemp!='=')
			SERROR("SSerialize::ToSVar_Helper 错误9");
		++pTemp;

		ToSVar_Helper_Delete(pTemp);
			
		//value
		SVar *pValue=new SVar;
		switch(*pTemp)
		{
		case 'n':		//TP_NIL	
			SERROR("SSerialize::ToSVar_Helper 错误10");
			break;
		case '"':		//TP_STRING
			{
				pValue->m_type=TP_STRING;
				pTemp+=1;

				while(*pTemp!='"')
				{
					if(*pTemp=='\\')
					{
						++pTemp;
					}
					pValue->m_str+=*pTemp;
					++pTemp;
				}

				++pTemp;
			}
			break;
		case '{':		//TP_TABLE
			{
				pValue->m_type=TP_TABLE;
				ToSVar_Helper(*pValue,pTemp);
			}
			break;
		default:		//TP_NUMBER
			{
				pValue->m_type=TP_NUMBER;
				string strTempNumber;
				while((*pTemp>='0'&&*pTemp<='9')||*pTemp=='.'||*pTemp=='-')
				{
					strTempNumber+=*pTemp;
					++pTemp;
				}

				if(strTempNumber.empty())
					SERROR("SSerialize::ToSVar_Helper 错误12");

				pValue->m_dbNumber=atof(strTempNumber.c_str());
			}
		}

		//将key,value加入表
		if(s.Push(pKey,pValue)==false)
			SERROR("SSerialize::ToSVar_Helper 错误13");

		//,}
		ToSVar_Helper_Delete(pTemp);
		if(*pTemp!=','&&*pTemp!='}')
			SERROR("SSerialize::ToSVar_Helper 错误14");
		++pTemp;
		ToSVar_Helper_Delete(pTemp);
		if(*pTemp==','||*pTemp=='}')
			++pTemp;
		ToSVar_Helper_Delete(pTemp);
	}
}
void						SSerialize::ToSVar_Helper_Delete(char *&p)
{
	while(true)
	{
		if(*p==' '||*p==9||*p=='\r'||*p=='\n')
			++p;
		else
			return;
	}
}
void						SSerialize::DeleteZero(char *p)
{
	if(strchr(p,'.'))
	{
		p+=strlen(p);
		--p;
		while(*p!='.')
		{
			if(*p=='0')
			{
				*p=0;
				--p;
			}
			else
				return;
		}
		if(*p=='.')
			*p=0;
	}
}

//<SLua>----------------------------------------------------------------------------------------
SLua::SLua()
{
	m_pLua=NULL;
	m_bCreateLuaState=false;
	m_nStack=0;
}
SLua::~SLua()
{
	Close();
}
void						SLua::SetLuaState(lua_State *p)
{
	Close();
	m_pLua=p;
	m_bCreateLuaState=false;
}
void						SLua::CreateLuaState()
{
	Close();
	m_pLua=lua_open();
	luaL_openlibs(m_pLua);
	m_bCreateLuaState=true;
}
bool						SLua::LoadFile(const char *pPath)
{
	if(m_pLua==NULL)
	{
		SERROR("SLua::LoadFile lua_State为空");
		return false;
	}

	if(pPath==NULL||strlen(pPath)==0)
	{
		SERROR("SLua::LoadFile 空文件路径");
		return false;
	}

	if(luaL_dofile(m_pLua,pPath)!=0) 
	{
#ifdef Def_Server
		SASSERT("SLua::LoadFile 打开Lua文件%s失败",pPath);
#else
		throw("SLua::LoadFile 打开Lua文件失败");
#endif
		return false;
	}
	string strPath=pPath;
	m_strPath.push_back(strPath);
	return true;
}
bool						SLua::LoadFolder(const char *pPath)
{
	if(pPath==NULL)
	{
		SERROR("SLua::LoadFolder pPath==NULL");
		return false;
	}

	string str=SFile::GetPath();
	str+="/";
	str+=pPath;

	return LoadFolderByFullPath(str.c_str());
}
bool						SLua::LoadFolderByFullPath(const char *pPath)
{
	if(pPath==NULL)
	{
		SERROR("SLua::LoadFolderByFullPath pPath==NULL");
		return false;
	}

	string str=pPath;
	vector<string> v=SFile::GetAllFile(str.c_str(),"lua");
	for(unsigned int i=0;i<v.size();++i)
	{
		if(LoadFile(v[i].c_str())==false)
			return false;
	}

	return true;
}
void						SLua::Close()
{
	if(m_pLua&&m_bCreateLuaState)
		lua_close(m_pLua);
	m_pLua=NULL;
	m_bCreateLuaState=false;
	m_strPath.clear();
	m_mapFun.clear();
	m_nStack=0;
}
bool						SLua::Reload()
{
	vector<string>  vTempPath=m_strPath;
	map<string,lua_CFunction> mapTempFun=m_mapFun;

	Close();
	CreateLuaState();

	for(vector<string>::iterator it=vTempPath.begin();it!=vTempPath.end();++it)
	{
		if(LoadFile(it->c_str())==false)
		{
			Close();
			m_strPath=vTempPath;
			m_mapFun=mapTempFun;
			SERROR("SLua::Reload 失败");
			return false;
		}
	}

	for(map<string,lua_CFunction>::iterator it=m_mapFun.begin();it!=m_mapFun.end();++it)
	{
		Register(it->first.c_str(),it->second);
	}
	return true;
}
void						SLua::Register(const char *funcName,lua_CFunction function)
{
	if(funcName==NULL||strlen(funcName)==0)
		return;
	if(function==NULL)
		return;
	if(m_pLua==NULL)
		return;

	string str=funcName;
	map<string,lua_CFunction>::iterator it=m_mapFun.find(str);
	if(it!=m_mapFun.end())
	{
#ifdef Def_Server
		SHOW("SLua::Register 注册函数%s重复",funcName);
#else
		throw("SLua::Register 注册函数重复");
#endif
		return;
	}

	m_mapFun.insert(make_pair(str,function));
	lua_register(m_pLua,funcName,function);
}
vector<SVar>						SLua::Get()
{
	vector<SVar> vTemp;
	bool isVisibleValue = true;
	while(true)
	{
		SVar s;
		switch(lua_type(m_pLua,-1))  
		{  
		case LUA_TNIL:
			s.SetType(TP_NIL);
			break;
		case LUA_TBOOLEAN:  
			s=lua_toboolean(m_pLua,-1);  
			break; 
		case LUA_TNUMBER:  
			s=lua_tonumber(m_pLua,-1);  
			break;  
		case LUA_TSTRING:  
			s=lua_tostring(m_pLua,-1);  
			break; 
		case LUA_TTABLE:
			Helper1(s);
			break;
		default:
			{
				isVisibleValue = false;
				//SERROR("SLua::Get 错误1");
			}
		}

		if (isVisibleValue)
		{
			vTemp.push_back(s); 
		}

		lua_pop(m_pLua,1);
		if(lua_gettop(m_pLua)==0)
			break;
	}

	//反转元素
	reverse(vTemp.begin(),vTemp.end());
	return vTemp;
}
void					SLua::PushNil()
{
	lua_pushnil(m_pLua);
}
void					SLua::Push(const char *pstr)
{
	if(pstr==NULL)
		return;
	lua_pushstring(m_pLua,pstr);
}
void					SLua::Push(string &str)
{
    Push(str.c_str());
}
void					SLua::Push(double dbNumber)
{
	lua_pushnumber(m_pLua,dbNumber);
}
void					SLua::Push(SVar& s)
{
	switch(s.Type())
	{
	case TP_NULL:
		SERROR("SLua::Push TP_NULL");
		return;
	case TP_NIL:
		PushNil();
		break;
	case TP_NUMBER:
		Push(s.ToNumber<double>());
		break;
	case TP_STRING:
		Push(s.ToString().c_str());
		break;
	case TP_TABLE:
		{
			lua_newtable(m_pLua);
			for(int i=0;i<s.GetSize();++i)
			{
				Push(s.GetKey(i));
				Push(s.GetValue(i));
				lua_rawset(m_pLua,-3);
			}
		}
		break;
	default:
		throw("SLua::Push 错误1");
	}
}
SVar						SLua::GetGlobal(const char* pName)
{
	SVar s;
	if(pName==NULL)
		return s;

	//得到当前栈
	int nStackTop=lua_gettop(m_pLua);

	lua_getglobal(m_pLua,pName);
	switch(lua_type(m_pLua,-1))  
	{  
	case LUA_TBOOLEAN:  
		s=lua_toboolean(m_pLua,-1);  
		break;  
	case LUA_TNUMBER:  
		s=lua_tonumber(m_pLua,-1);  
		break;  
	case LUA_TSTRING:  
		s=lua_tostring(m_pLua,-1);  
		break; 
	case LUA_TTABLE:
		Helper1(s);
		break;
	default:
		SERROR("SLua::GetGlobal 错误1");
	}

	//还原栈
	lua_settop(m_pLua,nStackTop);

	return s;
}
void						SLua::SetGlobal(const char* pName)
{
	if(pName==NULL)
		return;

	lua_setglobal(m_pLua,pName);
}
void						SLua::InitFun(const char* pFunName)
{
	m_nStack=lua_gettop(m_pLua);
	lua_getglobal(m_pLua,pFunName);
}
vector<SVar>				SLua::ExecFun(int nReturn)
{
	vector<SVar> vTemp;

	int nRet=lua_pcall(m_pLua,lua_gettop(m_pLua)-m_nStack-1,nReturn,0);   
	if(nRet!=0)   
	{
		lua_settop(m_pLua,m_nStack);
		return vTemp;
	}
	int nRealReturn=lua_gettop(m_pLua)-m_nStack;

	//获取返回值 
	for(int i=0;i<nRealReturn;++i)
	{
		SVar s;
		switch(lua_type(m_pLua,-1))  
		{  
		case LUA_TNIL:
			s.SetType(TP_NIL);
			break;
		case LUA_TBOOLEAN:  
			s=lua_toboolean(m_pLua,-1);  
			break;  
		case LUA_TNUMBER:  
			s=lua_tonumber(m_pLua,-1);  
			break;  
		case LUA_TSTRING:  
			s=lua_tostring(m_pLua,-1);  
			break; 
		case LUA_TTABLE:
			Helper1(s);
			break;
		//default:
			//SERROR("SLua::ExecFun 错误1");
		}
		vTemp.push_back(s); 
		lua_pop(m_pLua,1);
	}

	//反转元素
	reverse(vTemp.begin(),vTemp.end());

	//还原栈
	lua_settop(m_pLua,m_nStack);
	return vTemp;
}
void						SLua::Helper1(SVar &s)
{
	s.m_type=TP_TABLE;
	lua_pushnil(m_pLua);
	while(lua_next(m_pLua,-2))
	{
		SVar *pKey=new SVar;
		SVar *pValue=new SVar;

		//value 有可能是table
		switch(lua_type(m_pLua,-1))
		{
		case LUA_TBOOLEAN:  
			*pValue=lua_toboolean(m_pLua,-1); 
			break;  
		case LUA_TNUMBER:  
			*pValue=lua_tonumber(m_pLua,-1);  
			break;  
		case LUA_TSTRING:  
			*pValue=lua_tostring(m_pLua,-1);  
			break; 
		case LUA_TTABLE:
			Helper1(*pValue);
			break;
		}
		lua_pop(m_pLua,1);

		//key
		switch(lua_type(m_pLua,-1))
		{
		case LUA_TBOOLEAN:  
			*pKey=lua_toboolean(m_pLua,-1);  
			break;  
		case LUA_TNUMBER:  
			*pKey=lua_tonumber(m_pLua,-1);  
			break;  
		case LUA_TSTRING:  
			*pKey=lua_tostring(m_pLua,-1);  
			break;
		}

		s.Push(pKey,pValue);
	}
}