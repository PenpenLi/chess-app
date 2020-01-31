#pragma once
#include "SPlatformHead.h"
#include "SConfig.h"
#include "SPlatform.h"
#include "SPacker.h"
#include "SMsgManager.h"
#include "SLua.h"

namespace SDK
{
//<Server>-------------------------------------------------------------------------------------------------
	class Server
	{
	public:
		Server();
	public:
		void					Loop();
	public:
		bool					Start(unsigned int nPort);
		void					Close();
		void					Kill(SOCKETID id);
		bool					IsStart();
	public:
		void					Send(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id);
		void					Send(const SPacker &pack,SOCKETID id);
		void					Send(unsigned int nProtocol,SVar *p,SOCKETID id);
		void					Bordcast(unsigned int nProtocol,void *pBuffer,unsigned int nSize);
		void					Bordcast(const SPacker &pack);
		void					Bordcast(unsigned int nProtocol,SVar *p);
	private:
		SSocket					m_listenSocket;
		bool					m_bStart;
		map<SOCKETID,SSocket*>	m_connectTable;
		long					m_lCurrentSocketID;
	};
}