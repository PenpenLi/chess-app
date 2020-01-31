#include "../STools.h"
using namespace SDK;
void				STools::BoolToBit(bool *pIn,int nSize,byte *pOut,bool bLittleEndian/*=true*/)
{
	if(bLittleEndian)
	{
		for(int i=0;i<nSize;++i)
			pOut[i/8]|=(pIn[i]<<(i%8));
	}
	else
	{
		for(int i=0;i<nSize;++i)
			pOut[i/8]|=(pIn[i]<<(7-i%8));
	}
}
void				STools::BitToBool(byte *pIn,int nSize,bool *pOut,bool bLittleEndian/*=true*/)
{
	if(bLittleEndian)
	{
		for(int i=0;i<nSize;++i)
			pOut[i]=(pIn[i/8]>>(i%8))&1;
	}
	else
	{
		for(int i=0;i<nSize;++i)
			pOut[i]=(pIn[i/8]>>(7-i%8))&1;
	}
}
string			STools::ANSI_UTF8(const char* pFormat,...)
{
    char pStr[4096+1]={0};
    va_list ap;
    va_start(ap,pFormat);
    vsnprintf(pStr,4096,pFormat,ap);
    va_end(ap);

#ifdef _WIN32
    wstring str;

    //ANSI_Unicode
    int  len = 0;
    len = strlen(pStr);
    int  unicodeLen = ::MultiByteToWideChar( CP_ACP,
        0,
        pStr,
        -1,
        NULL,
        0 );  
    wchar_t *  pUnicode;  
    pUnicode = new  wchar_t[unicodeLen+1];  
    memset(pUnicode,0,(unicodeLen+1)*sizeof(wchar_t));  
    ::MultiByteToWideChar( CP_ACP,
        0,
        pStr,
        -1,
        (LPWSTR)pUnicode,
        unicodeLen );   
    str = ( wchar_t* )pUnicode;
    delete  pUnicode; 

    //Unicode_UTF8
    char*     pElementText;
    int    iTextLen;
    // wide char to multi char
    iTextLen = WideCharToMultiByte( CP_UTF8,
        0,
        str.c_str(),
        -1,
        NULL,
        0,
        NULL,
        NULL );
    pElementText = new char[iTextLen + 1];
    memset( ( void* )pElementText, 0, sizeof( char ) * ( iTextLen + 1 ) );
    ::WideCharToMultiByte( CP_UTF8,
        0,
        str.c_str(),
        -1,
        pElementText,
        iTextLen,
        NULL,
        NULL );
    string strText;
    strText = pElementText;
    delete[] pElementText;
    return strText;
#else
    string str=pStr;
    return str;
#endif
}
int					STools::RandomInt(int a,int b)
{
	if(a>b)
		throw("STools::RandomInt 参数错误:a>b");

	int n=a+(int)(((double)rand()/RAND_MAX)*(b-a+1));
	if(n>b)
		return b;
	else
		return n;

}
string				STools::BinaryToString(void *pBuffer,int nSize)
{
	static char szBuf[16]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

	string str;
	const char *pTemp=(const char*)pBuffer;
	while(nSize--)
	{
		unsigned char c;

		c=*pTemp;
		c=c>>4;
		str+=szBuf[(int)c];

		c=*pTemp;
		c=c<<4;
		c=c>>4;
		str+=szBuf[(int)c];

		++pTemp;
	}
	return str;
}
int					STools::StringToBinary(const char *pStr,void *pBuffer)
{
	int nReturn=0;
	const char *pTemp=(const char*)pBuffer;
	while(*pStr!=0)
	{
		switch(*pStr)
		{
		case '0':*((unsigned char*)pTemp)=0;break;
		case '1':*((unsigned char*)pTemp)=1;break;
		case '2':*((unsigned char*)pTemp)=2;break;
		case '3':*((unsigned char*)pTemp)=3;break;
		case '4':*((unsigned char*)pTemp)=4;break;
		case '5':*((unsigned char*)pTemp)=5;break;
		case '6':*((unsigned char*)pTemp)=6;break;
		case '7':*((unsigned char*)pTemp)=7;break;
		case '8':*((unsigned char*)pTemp)=8;break;
		case '9':*((unsigned char*)pTemp)=9;break;
		case 'A':*((unsigned char*)pTemp)=10;break;
		case 'B':*((unsigned char*)pTemp)=11;break;
		case 'C':*((unsigned char*)pTemp)=12;break;
		case 'D':*((unsigned char*)pTemp)=13;break;
		case 'E':*((unsigned char*)pTemp)=14;break;
		case 'F':*((unsigned char*)pTemp)=15;break;
		}
		*(unsigned char*)pTemp=(*(unsigned char*)pTemp)<<4;

		++pStr;
		switch(*pStr)
		{
		case '0':*((unsigned char*)pTemp)+=0;break;
		case '1':*((unsigned char*)pTemp)+=1;break;
		case '2':*((unsigned char*)pTemp)+=2;break;
		case '3':*((unsigned char*)pTemp)+=3;break;
		case '4':*((unsigned char*)pTemp)+=4;break;
		case '5':*((unsigned char*)pTemp)+=5;break;
		case '6':*((unsigned char*)pTemp)+=6;break;
		case '7':*((unsigned char*)pTemp)+=7;break;
		case '8':*((unsigned char*)pTemp)+=8;break;
		case '9':*((unsigned char*)pTemp)+=9;break;
		case 'A':*((unsigned char*)pTemp)+=10;break;
		case 'B':*((unsigned char*)pTemp)+=11;break;
		case 'C':*((unsigned char*)pTemp)+=12;break;
		case 'D':*((unsigned char*)pTemp)+=13;break;
		case 'E':*((unsigned char*)pTemp)+=14;break;
		case 'F':*((unsigned char*)pTemp)+=15;break;
		}

		++pStr;
		++pTemp;
		++nReturn;
	}

	return nReturn;
}
void					STools::Simple_Encrypt(byte *p,int nSize)
{
	unsigned char c=nSize%256;
	for(int i=0;i<nSize;++i)
	{
		*(p+i)=~(*(p+i)^c);

		switch(p[i]&24)
		{
		case 0:
			p[i]+=24;
			break;
		case 8:
			p[i]+=8;
			break;
		case 16:
			p[i]&=239;
			p[i]+=8;
			break;
		case 24:
			p[i]-=24;
			break;
		}
	}
}
void					STools::Simple_Decrypt(byte *p,int nSize)
{
	unsigned char c=nSize%256;
	for(int i=0;i<nSize;++i)
	{
		*(p+i)=(~(*(p+i)))^c;

		switch(p[i]&24)
		{
		case 0:
			p[i]+=24;
			break;
		case 8:
			p[i]+=8;
			break;
		case 16:
			p[i]&=239;
			p[i]+=8;
			break;
		case 24:
			p[i]-=24;
			break;
		}
	}
}