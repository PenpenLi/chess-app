#include "../SListener.h"
#include "../SInstance.h"
#include "../SMsgManager.h"
#include "../Server.h"
#include "../SInit.h"
using namespace SDK;

//<SLoop>--------------------------------------------------------------------------------------------------
SLoop::SLoop()
{
	INSTANCE(SInit);
	m_pListener=NULL;
	m_bLockMsg1=false;
	m_bLockMsg2=false;
}
SLoop::~SLoop()
{
	for(list<SMsg*>::iterator it=m_lMsg.begin();it!=m_lMsg.end();++it)
		delete *it;
}
void			SLoop::Register(SListener *pListener)
{
	m_pListener=pListener;
}
void			SLoop::Loop()
{
	INSTANCE(Server)->Loop();

	list<SMsg*>	lServerMsg=INSTANCE(SMsgManager)->GetServerMsg();
	while(lServerMsg.empty()==false)
	{
		SMsg *p=*(lServerMsg.begin());
		lServerMsg.pop_front();

		switch(p->type)
		{
		case SMsg::Server_MSG:
			m_pListener->OnServerRecv(p->pPacker->GetProtocol(),p->pPacker->GetBuffer(),p->pPacker->GetSize(),p->id);
			break;
		case SMsg::ServerConnect_MSG:
			m_pListener->OnServerConnect(p->id);
			break;
		case SMsg::ServerClose_MSG:
			m_pListener->OnServerClose(p->id);
			break;
		}
		delete p;
	}

	if(m_bLockMsg1)
		return;
	if(m_bLockMsg2)
		return;

	if(m_lMsg.empty())
		m_lMsg=INSTANCE(SMsgManager)->GetMsg();
	while(m_lMsg.empty()==false)
	{
		SMsg *p=*(m_lMsg.begin());
		m_lMsg.pop_front();
		switch(p->type)
		{
		case SMsg::Client_MSG:
			m_pListener->OnClientRecv(p->pPacker->GetProtocol(),p->pPacker->GetBuffer(),p->pPacker->GetSize(),p->pNet);
			break;
		case SMsg::ClientConnect_MSG:
			m_pListener->OnClientConnect(p->pNet);
			break;
		case SMsg::ClientFaild_MSG:
			m_pListener->OnClientFaild(p->pNet);
			break;
		case SMsg::ClientClose_MSG:
			m_pListener->OnClientClose(p->pNet);
			break;
		case SMsg::Http_MSG:
			m_pListener->OnHttpRecv(p->pPacker->GetBuffer(),p->pPacker->GetSize(),p->nID,p->nType);
			break;
		case SMsg::HttpFaild_MSG:
			m_pListener->OnHttpFaild(p->nID,p->nType);
			break;
		case SMsg::HttpPercent_MSG:
			m_pListener->OnHttpPercent(p->nID,p->nType,p->nPercent);
			break;
		case SMsg::UpdateEnd_Msg:
           m_pListener-> OnUpdateEndRecv();
            break;
		case SMsg::UpdateNotNeed_Msg:
            m_pListener->OnUpdateNotNeedRecv();
            break;
		case SMsg::AppQuit_Msg:
			m_pListener->OnAppQuit();
			break;
		case SMsg::UpdateCancel_Msg:
			m_pListener->OnUpdateCancel();
			break;
		case SMsg::UpdateFail_Msg:
			m_pListener->OnUpdateFail();
			break;
		case SMsg::UpdatePackBroke_Msg:
			m_pListener->OnUpdatePackBroke();
			break;
		case SMsg::GetIPTBEnd_Msg:
			m_pListener->OnGetIPTBEnd_Msg(p->str);
			break;
		case SMsg::DownloadEnd_Msg:
			m_pListener->OnDownloadEnd();
			break;
		case SMsg::DownloadFail_Msg:
			m_pListener->OnDownloadFail();
			break;
		case SMsg::Game_Need_Update_Msg:
			m_pListener->OnGameNeedUpdate();
			break;
		case SMsg::Game_Not_Need_Update_Msg:
			m_pListener->OnGameNotNeedUpdate();
			break;
		case SMsg::GGDownloadEnd_Msg:
			m_pListener->OnGGDownloadEnd();
			break;
		case SMsg::GGDownloadFail_Msg:
			m_pListener->OnGGDownloadFail();
			break;
		case SMsg::Android_Not_Need_Full_Update_Msg:
			m_pListener->OnAndroidFullUpdateNotNeed();
			break;
		case SMsg::Android_Need_Full_Update_Msg:
			m_pListener->OnAndroidFullUpdateNeed();
			break;
		case SMsg::Android_Full_Update_Fail:
			m_pListener->OnAndroidFullUpdateFail();
			break;
		case SMsg::Android_Full_Update_End:
			m_pListener->OnAndroidFullUpdateEnd();
			break;
		}
		delete p;

		if(m_bLockMsg1)
			return;
		if(m_bLockMsg2)
			return;
	}
}