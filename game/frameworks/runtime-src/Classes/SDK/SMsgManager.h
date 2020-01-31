#pragma once
#include "SPlatformHead.h"
#include "SPacker.h"
#include "SPlatform.h"
#include "SInstance.h"
#include "SConfig.h"

namespace SDK
{
//<SMsg>---------------------------------------------------------------------------------------------
	class SMsg
	{
	public:
		enum MSG_TYPE
		{
			Server_MSG,
			ServerConnect_MSG,
			ServerClose_MSG,
			Client_MSG,
			ClientConnect_MSG,
			ClientFaild_MSG,
			ClientClose_MSG,
			Http_MSG,
			HttpFaild_MSG,
			HttpPercent_MSG,
			UpdateEnd_Msg,
			AppQuit_Msg,
			UpdateCancel_Msg,
			UpdateFail_Msg,
			UpdatePackBroke_Msg,
			DownloadEnd_Msg,
			DownloadFail_Msg,
			Game_Need_Update_Msg,
			Game_Not_Need_Update_Msg,
			GGDownloadEnd_Msg,
			GGDownloadFail_Msg,
			UpdateNotNeed_Msg,
			Android_Not_Need_Full_Update_Msg,
			Android_Need_Full_Update_Msg,
			Android_Full_Update_Fail,
			Android_Full_Update_End,
			GetIPTBEnd_Msg,
		};
	public:
		SMsg();
		~SMsg();
	public:
		MSG_TYPE		type;
		void			*pNet;
		SPacker			*pPacker;	
		SOCKETID		id;			//Server
		int				nID;		//Http
		int				nType;		//Http
		unsigned int	nPercent;	//Http
		string			str;
	};
//<SMsgManager>---------------------------------------------------------------------------------------
	class SMsgManager
	{
	public:
		~SMsgManager();
	public:
		list<SMsg*>				GetMsg();
		list<SMsg*>				GetServerMsg();
	public://Server
		void					AddServerMsg(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id);
		void					AddServerConnectMsg(SOCKETID id);
		void					AddServerCloseMsg(SOCKETID id);
	public://Client
		void					AddClientMsg(unsigned int nProtocol,void *pBuffer,unsigned int nSize,void *pNet);
		void					AddClientConnectMsg(void *pNet);
		void					AddClientFaildMsg(void *pNet);
		void					AddClientCloseMsg(void *pNet);
	public://Http
		void					AddHttpMsg(SPacker *pPacker,int nID,int nType);
		void					AddHttpFaild(int nID,int nType);
		void					AddHttpPercent(int nID,int nType,unsigned int nPercent);
	public://Update
		void                    AddGGDownloadEndMsg();
		void                    AddGGDownloadFailMsg();
        void                    AddUpdateEndMsg();
		void                    AddUpdateNotNeedMsg();
		void                    AddAppQuitMsg();
		void                    AddUpdateCancelMsg();
		void                    AddUpdateFailMsg();
		void					AddUpdatePackBrokeMsg();
		void					AddDownloadEndMsg();
		void					AddDownloadFailMsg();
		void					AddGameNeedUpdateMsg();
		void					AddGameNotNeedUpdateMsg();
		void					AddAndroidNeedFullUpdateMsg();
		void					AddAndroidNotNeedFullUpdateMsg();
		void					AddAndoridFullUpdatFailMsg();
		void					AddAndoridFullUpdateEndMsg();
		void					GetIPTBEnd(std::string str );
	private:
		list<SMsg*>				m_lMessage;
		SLock					m_lock;

		string					m_IpStr;
	};
}