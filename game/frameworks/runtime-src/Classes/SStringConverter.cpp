#ifdef WIN32
#include "SStringConverter.h"

string SStringConverter::UTF8_ANSI(const char* pStr)
{
	wstring str=UTF8_Unicode(pStr);
	return Unicode_ANSI(str.c_str());
}

wstring SStringConverter::UTF8_Unicode(const char* pStr)
{
	int  len = 0;
	len = strlen(pStr);
	int  unicodeLen = ::MultiByteToWideChar( CP_UTF8,
		0,
		pStr,
		-1,
		NULL,
		0 );  
	wchar_t *  pUnicode;  
	pUnicode = new  wchar_t[unicodeLen+1];  
	memset(pUnicode,0,(unicodeLen+1)*sizeof(wchar_t));  
	::MultiByteToWideChar( CP_UTF8,
		0,
		pStr,
		-1,
		(LPWSTR)pUnicode,
		unicodeLen );  
	wstring  rt;  
	rt = ( wchar_t* )pUnicode;
	delete  pUnicode; 

	return  rt;  
}

string SStringConverter::ANSI_UTF8(const char* pStr)
{
	wstring str=ANSI_Unicode(pStr);
	return Unicode_UTF8(str.c_str());
}

wstring SStringConverter::ANSI_Unicode(const char* pStr)
{
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
	wstring  rt;  
	rt = ( wchar_t* )pUnicode;
	delete  pUnicode; 

	return  rt;  
}

string SStringConverter::Unicode_ANSI(const wchar_t *pStr)
{
	char*     pElementText;
	int    iTextLen;
	// wide char to multi char
	iTextLen = WideCharToMultiByte( CP_ACP,
		0,
		pStr,
		-1,
		NULL,
		0,
		NULL,
		NULL );
	pElementText = new char[iTextLen + 1];
	memset( ( void* )pElementText, 0, sizeof( char ) * ( iTextLen + 1 ) );
	::WideCharToMultiByte( CP_ACP,
		0,
		pStr,
		-1,
		pElementText,
		iTextLen,
		NULL,
		NULL );
	string strText;
	strText = pElementText;
	delete[] pElementText;
	return strText;
}

string SStringConverter::Unicode_UTF8(const wchar_t *pStr)
{
	char*     pElementText;
	int    iTextLen;
	// wide char to multi char
	iTextLen = WideCharToMultiByte( CP_UTF8,
		0,
		pStr,
		-1,
		NULL,
		0,
		NULL,
		NULL );
	pElementText = new char[iTextLen + 1];
	memset( ( void* )pElementText, 0, sizeof( char ) * ( iTextLen + 1 ) );
	::WideCharToMultiByte( CP_UTF8,
		0,
		pStr,
		-1,
		pElementText,
		iTextLen,
		NULL,
		NULL );
	string strText;
	strText = pElementText;
	delete[] pElementText;
	return strText;
}

#endif
