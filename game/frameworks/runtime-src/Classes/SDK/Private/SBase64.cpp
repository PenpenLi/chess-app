#include "../SBase64.h"
using namespace SDK;

//<SBase64>---------------------------------------------------------------------------------------------------
map<char,int> SBase64::m_map=SBase64::InitMap();
map<char,int>	SBase64::InitMap()
{
	map<char,int> temp;

	int n=0;
	for(int i='A';i<='Z';++i)
		temp[i]=n++;
	for(int i='a';i<='z';++i)
		temp[i]=n++;
	for(int i='0';i<='9';++i)
		temp[i]=n++;
	temp['+']=62;
	temp['/']=63;

	return temp;
}
string			SBase64::Encrypt(const char *pIn)
{
	return Encrypt((byte*)pIn,strlen(pIn));
}
string			SBase64::Encrypt(byte *pIn,int nSize)
{
	string str;
	if(pIn==NULL)
		return str;
	if(nSize<=0)
		return str;
		
	for(int i=0;i<nSize;i+=3)
	{
		//将24bit存储在bTemp中
		bool bTemp[24]={0};
		int nTemp=(nSize-i)*8;
		nTemp=nTemp>24?24:nTemp;
		STools::BitToBool(pIn+i,nTemp,bTemp,false);

		//对nTemp补成6的整数倍
		if(nTemp%6!=0)
			nTemp=(nTemp/6+1)*6;

		//每6bit转换为索引
		for(int j=0;j<nTemp;j+=6)
		{
			int nIndex=0;
			STools::BoolToBit(bTemp+j,6,(byte*)&nIndex,false);
			nIndex=nIndex>>2;
			str+=m_szTable[nIndex];
		}

		//补=
		if(nTemp==12)
			str+="==";
		else if(nTemp==18)
			str+="=";
	}

	return str;
}
string			SBase64::Decrypt(const char* pIn)
{
	int nSize=strlen(pIn);
	byte *p=new byte[(nSize/4)*3+1];
	memset(p,0,(nSize/4)*3+1);
	Decrypt(pIn,p);
	string str=(char*)p;
	delete[] p;
	return str;
}
int				SBase64::Decrypt(const char* pIn,byte *pOut)
{
	if(pIn==NULL)
		return 0;
	if(pOut==NULL)
		return 0;
	int nSize=strlen(pIn);
	if(nSize<=0)
		return 0;
	if(nSize%4!=0)
		return 0;
	
	for(int i=0;i<nSize;i+=4)
	{	
		bool bTemp[24]={0};
		char c=0;

		if(pIn[i]=='='||pIn[i+1]=='=')
			return 0;
		if(pIn[i+2]=='='&&pIn[i+3]!='=')
			return 0;

		c=m_map[pIn[i]]<<2;
		STools::BitToBool((byte*)&c,6,bTemp,false);

		c=m_map[pIn[i+1]]<<2;
		STools::BitToBool((byte*)&c,6,bTemp+6,false);

		if(pIn[i+2]!='=')
		{
			c=m_map[pIn[i+2]]<<2;
			STools::BitToBool((byte*)&c,6,bTemp+12,false);
		}
		else
		{
			STools::BoolToBit(bTemp,12,pOut,false);
			return (nSize/4)*3-2;
		}

		if(pIn[i+3]!='=')
		{
			c=m_map[pIn[i+3]]<<2;
			STools::BitToBool((byte*)&c,6,bTemp+18,false);
		}
		else
		{
			STools::BoolToBit(bTemp,18,pOut,false);
			return (nSize/4)*3-1;
		}

		//处理24bit数据
		STools::BoolToBit(bTemp,24,pOut,false);
		pOut+=3;
	}

	return (nSize/4)*3;
}
char SBase64::m_szTable[65]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";