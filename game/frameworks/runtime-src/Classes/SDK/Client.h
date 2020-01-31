#pragma once
#include "SPlatformHead.h"
#include "SConfig.h"
#include "SPlatform.h"
#include "SPacker.h"
#include "SMsgManager.h"
#include "SLua.h"

namespace SDK
{
	class Client;
//<SNetThread>--------------------------------------------------------------------------------------------------------------------
	class SNetThread:public SThread
	{
	public:
		SNetThread();
		void                SetClient(Client *pClient);
		Client*			    GetClient();
	public:
		Client              *m_pClient;
		SLock               m_lockxx;
	};
//<SConnectRecvThread>------------------------------------------------------------------------------------------------------------
	class SConnectRecvThread:public SNetThread
	{
	public:
		SConnectRecvThread();
	public:
		void                Connect(const char *strIP,int nPort);
		void                ThreadProc();
		virtual void		Close();
	private:
		bool				AssistantParse(char *pBuffer,int dw32Size,char *pTotalBuffer,int &nTotalBufferSize);
		void				CloseSocket();
	private:
		string              m_strIP;
		int                 m_nPort;
	};
//<SSendThread>-------------------------------------------------------------------------------------------------------------------
	class SSendThread:public SNetThread
	{
	public:
		SSendThread();
		~SSendThread();
	public:
		void                Send(unsigned int nProtocol,void *pBuffer,unsigned int nSize);
		void                ThreadProc();
		void				SetFix4(bool bVa){m_bFix4=bVa;}
		bool				IsFix4(){return m_bFix4;}
		virtual void		Close();
	private:
		list<SPacker*>      m_lPacker;
		SLock               m_lock;
		bool				m_bFix4;		//是否发送4个字节的固定长度
	};
//<连接状态>----------------------------------------------------------------------------------------------------------------------
	enum CLIENT_STATE
	{
		INIT_STATE,			//初始状态(没有连接)
		CONNECTING_STATE,	//正在连接状态
		CONN_STATE,			//连接成功状态
	};
//<Client>------------------------------------------------------------------------------------------------------------------------
	class Client
	{
	public:
		Client();
		virtual ~Client();
	public:
		void				Connect(const char *strIP,unsigned int port);
		void				Close();
	public:
		void                Send(unsigned int nProtocol,void *pBuffer,unsigned int nSize);
		void                Send(const SPacker &pack);
		void				Send(unsigned int nProtocol,SVar *p);
		bool				IsConnect(){return m_emState==CONN_STATE;}
	public:
		void				Lock();
		void				Unlock();
	public:
		SSocket				m_socket;
		volatile CLIENT_STATE m_emState;
		SLock				m_lock;
		SConnectRecvThread  *m_pMainThread;
		SSendThread         m_sendThread;
	};

////验证连接------------------------------------------------------------------------------------------------------	
#pragma pack(1)
	struct ClientData
	{
		long long Time;
		char key[33];
		char MD5[33];
		unsigned int Ret;
	};
#pragma pack()
	class CheckClient
	{
	public:
		CheckClient();
		~CheckClient();
		void encrypt_code(char* buf,char* xorkeys,int xorlen,int count);			//加密码
		int  safeconnect(const char* ip,int port,time_t Unixdate);						//连接
		int  safeconnectex(const char* ip,int port,time_t Unixdate);
	private:
		int		m_Socket;
	};
	//验证连接------------------------------------------------------------------------------------------------------	
}
