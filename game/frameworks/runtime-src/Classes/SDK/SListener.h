#pragma once
#include "SPlatformHead.h"
#include "SConfig.h"
#include "SPlatform.h"
#include "SMsgManager.h"

namespace SDK
{
//<SListener>-----------------------------------------------------------------------------------------------
	class SListener
	{
	public:
		virtual ~SListener(){};
	public://Server
		virtual void		OnServerRecv(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id){};
		virtual void		OnServerConnect(SOCKETID id){};
		virtual void		OnServerClose(SOCKETID id){};
	public://Client
		virtual void        OnClientRecv(unsigned int nProtocol,void *pBuffer,unsigned int nSize,void *pNet){};
		virtual void		OnClientConnect(void *pNet){};
		virtual void		OnClientFaild(void *pNet){};
		virtual void		OnClientClose(void *pNet){};
	public://Http
		virtual void		OnHttpRecv(void *pBuffer,unsigned int nSize,int nID,int nType){};
		virtual void		OnHttpFaild(int nID,int nType){};
		virtual void		OnHttpPercent(int nID,int nType,unsigned int nPercent){};
	public://Update
        virtual void        OnUpdateEndRecv(){};
		virtual void        OnUpdateNotNeedRecv(){};
		virtual void        OnAppQuit(){};
		virtual void        OnUpdateCancel(){};
		virtual void        OnUpdateFail(){};
		virtual void        OnUpdatePackBroke(){};
		virtual void        OnDownloadEnd(){};
		virtual void        OnDownloadFail(){};
		virtual void        OnGameNeedUpdate(){};
		virtual void        OnGameNotNeedUpdate(){};
		virtual void        OnGGDownloadEnd(){};
		virtual void        OnGGDownloadFail(){};
		virtual void        OnAndroidFullUpdateNotNeed(){};
		virtual void        OnAndroidFullUpdateNeed(){};
		virtual void        OnAndroidFullUpdateFail(){};
		virtual void        OnAndroidFullUpdateEnd(){};

		virtual void        OnGetIPTBEnd_Msg(string str){};
	};

//<SLoop>-----------------------------------------------------------------------------------------------
	class SLoop
	{
		friend class SListener;
	public:
		SLoop();
		~SLoop();
	public:
		void				Loop();
		void                Register(SListener *pListener);
		void				LockMsg1(bool bLock){m_bLockMsg1=bLock;};
		void				LockMsg2(bool bLock){m_bLockMsg2=bLock;};
	private:
		SListener			*m_pListener;
		bool				m_bLockMsg1;
		bool				m_bLockMsg2;
		list<SMsg*>			m_lMsg;
	};
}
