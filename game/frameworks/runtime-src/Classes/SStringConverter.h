#pragma once
#ifdef WIN32
#include "SDK\SHead.h"

//<SStringConverter>----------------------------------------------------------------------------
class SStringConverter
{
public:
	static string UTF8_ANSI(const char* pStr);
	static wstring UTF8_Unicode(const char* pStr);
public:
	static string ANSI_UTF8(const char* pStr);
	static wstring ANSI_Unicode(const char* pStr);
public:
	static string Unicode_ANSI(const wchar_t *pStr);
	static string Unicode_UTF8(const wchar_t *pStr);
};
#endif