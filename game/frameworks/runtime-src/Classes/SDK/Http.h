#pragma once
#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "SPlatformHead.h"
#include "SConfig.h"
#include "SPlatform.h"
#include "SPacker.h"
#include "SMsgManager.h"
#include "network/HttpClient.h"

USING_NS_CC;
using namespace cocos2d::network;

namespace SDK
{
//<SHttpThread>----------------------------------------------------------------------------
	class SHttpThread:public SThread
	{
	public:
		virtual void			Close();
		virtual void			ThreadProc();
	private:
		bool					OnRecv(SPacker *pPacker,int nID,int nType);
		bool					IsFullTrunk(char *pBuffer,int nSize);
		bool					IsEndTrunk(char *pBuffer);
		void					JumpTrunk(char* &pBuffer,int &nSize);
	private:
		SSocket					m_socket;	
	};
//<stHttp>-------------------------------------------------------------------------------
	struct stHttp
	{
	public:
		stHttp(const char *pIP,int nPort,void *pBuffer,int nSize,int nID,int nType);
		~stHttp();
	public:
		string					strIP;
		int						nPort;
		void					*pBuffer;
		int						nSize;
		int						nID;
		int						nType;
	};
//<Http>----------------------------------------------------------------------------------
	class Http
	{
		friend class SHttpThread;
	public:
		Http();
		~Http();
	public:
		void					Init(int nSize);
        void                    Close();
		int						Post(const char *pIP,int nPort,const char *pPageName,int nType,const char *pSend=NULL);
		int						NewPost(const char *pIP,int nType,const char *pSend=NULL);
		int						Get(int nType,const char *pIP,const char *pHost,unsigned int nPort,const char*pUrl,const char*pAddr);
	private:
		stHttp*					GetData();

		void					onHttpsRequestCompleted(HttpClient*sender, HttpResponse *response);
	private:
		vector<SHttpThread*>	m_vThread;
		list<stHttp*>			m_lData;
		SLock					m_lock;
		int						m_nID;
		std::map<int,int>		m_mapSendID;

		int						m_MsgID;
		SLock					m_MsgMapLock;
	private:
		void					AddMsgType(int nID,int nType);
		void					DelMsgType(int nID);
		int						GetMsgType(int nID);

		bool					OnRecode(SPacker *pPacker,int nID,int nType);
		bool					IsFullTrunk(char *pBuffer,int nSize);
		bool					IsEndTrunk(char *pBuffer);
		void					JumpTrunk(char* &pBuffer,int &nSize);
	};
}
