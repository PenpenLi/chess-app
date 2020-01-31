#pragma once
#include "SPlatformHead.h"

namespace SDK
{
//<SThread>----------------------------------------------------------------------------------
	class SThread
	{
	public:
		SThread();
		virtual ~SThread(){};
	public:
		void				StartThread();
		virtual void		Close();					
		bool				IsRun();				
	public:
		virtual void		ThreadProc()=0;
	private:
	#ifdef WIN32
		static unsigned int WINAPI Run(LPVOID pParam);
	#else
		static void*        Run(void *pParam);
	#endif
	private:
		volatile bool		m_bRun;
		volatile bool		m_bWait;
	};
//<SLock>------------------------------------------------------------------------------------
	class SLock
	{
	public:
		SLock();
		~SLock();
	public:
		void                Enter();
		void                Leave();
	private:
	#ifdef WIN32
		CRITICAL_SECTION	m_cs;
	#else
		pthread_mutex_t     m_lock;
	#endif
	};
//<STime>------------------------------------------------------------------------------------
	class STime
	{
	public:
		unsigned int		GetTime();
	};
//<SSocket>----------------------------------------------------------------------------------
	class SSocket
	{
	public:
		SSocket();
		~SSocket();
	public:
		void				Init();
		void				SetAttrib(bool bBlock=true);
		void				Close();
	public:
		bool				BindListen(unsigned int nPort);
		SSocket*			Accept(bool bBlock=true);
		bool				Connect(const char *strIP,unsigned int port);
		bool				Send(void *pBuffer,unsigned int nSize);
		/*
			0:	阻塞模式下链接断开,非阻塞模式下没有数据
			-1:	阻塞模式下不会返回此值,非阻塞模式下链接断开
			>0: 接收到的字节数
		*/
		int					Recv(char *pBuffer,unsigned int nSize);		
	public:
	#ifdef WIN32
		SOCKET				m_nSocket;
	#else
		int                 m_nSocket;
	#endif
		bool				m_bBlock;
	};
//<SUdpSocket>----------------------------------------------------------------------------------
	class SUdpSocket
	{
	public:
		SUdpSocket();
		~SUdpSocket();
	public:
		void				InitBordcast();
		void				Bordcast(unsigned int nPort,void *pBuffer,unsigned int nSize);
	public:
		void				InitRecv(unsigned int nPort);
		/*
			0: 没有数据
			>0:接收到的字节数
		*/
		int					Recv(char *pBuffer,unsigned int nSize,string &strIP);
	public:
#ifdef WIN32
		SOCKET				m_nSocket;
#else
		int                 m_nSocket;
#endif
	};
}