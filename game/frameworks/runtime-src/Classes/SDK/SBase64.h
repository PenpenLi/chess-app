#pragma once
#include "SPlatformHead.h"
#include "STools.h"
namespace SDK
{
//<SBase64>---------------------------------------------------------------------------------------------------
	class SBase64
	{
	public:
		static string			Encrypt(const char *pIn);
		static string			Encrypt(byte *pIn,int nSize);
		static string			Decrypt(const char* pIn);
		static int				Decrypt(const char* pIn,byte *pOut);
	private:
		static map<char,int>	InitMap();
	private:
		static map<char,int>	m_map;
		static char				m_szTable[65];							
	};
}

//≤‚ ‘
//"a":YQ==
//"abc":YWJj
//"woshizhaoying":d29zaGl6aGFveWluZw==