#include "../SMsgManager.h"
using namespace SDK;

//<SMsg>---------------------------------------------------------------------------------------
SMsg::SMsg()
{
	pNet=NULL;
	pPacker=NULL;
	id=0;
	nID=0;
	nType=0;
	nPercent=0;
}
SMsg::~SMsg()
{
	if(pPacker)
		delete pPacker;
}

//<SMsgManager>---------------------------------------------------------------------------------------
SMsgManager::~SMsgManager()
{
	for(list<SMsg*>::iterator it=m_lMessage.begin();it!=m_lMessage.end();++it)
	{
		delete *it;
	}
}
list<SMsg*>				SMsgManager::GetMsg()
{
	m_lock.Enter();
	list<SMsg*> l=m_lMessage;
	m_lMessage.clear();
	m_lock.Leave();

	return l;
}
list<SMsg*>				SMsgManager::GetServerMsg()
{
	list<SMsg*> l;

	m_lock.Enter();
	for(list<SMsg*>::iterator it=m_lMessage.begin();it!=m_lMessage.end();)
	{
		switch((*it)->type)
		{
		case SMsg::Server_MSG:
		case SMsg::ServerConnect_MSG:
		case SMsg::ServerClose_MSG:
			{
				l.push_back(*it);
				m_lMessage.erase(it);
				it=m_lMessage.begin();
			}
			break;
		default:
			++it;
		}
	}
	m_lock.Leave();

	return l;
}
void					SMsgManager::AddServerMsg(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::Server_MSG;
	pMessage->pPacker=new SPacker;
	pMessage->pPacker->SetProtocol(nProtocol);
	pMessage->pPacker->Push(pBuffer,nSize);
	pMessage->id=id;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddServerConnectMsg(SOCKETID id)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::ServerConnect_MSG;
	pMessage->id=id;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddServerCloseMsg(SOCKETID id)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::ServerClose_MSG;
	pMessage->id=id;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddClientMsg(unsigned int nProtocol,void *pBuffer,unsigned int nSize,void *pNet)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::Client_MSG;
	pMessage->pNet=pNet;
	pMessage->pPacker=new SPacker;
	pMessage->pPacker->SetProtocol(nProtocol);
	pMessage->pPacker->Push(pBuffer,nSize);

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddClientConnectMsg(void *pNet)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::ClientConnect_MSG;
	pMessage->pNet=pNet;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddClientFaildMsg(void *pNet)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::ClientFaild_MSG;
	pMessage->pNet=pNet;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddClientCloseMsg(void *pNet)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::ClientClose_MSG;
	pMessage->pNet=pNet;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddHttpMsg(SPacker *pPacker,int nID,int nType)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::Http_MSG;
	pMessage->pPacker=pPacker;
	pMessage->nID=nID;
	pMessage->nType=nType;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddHttpFaild(int nID,int nType)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::HttpFaild_MSG;
	pMessage->nID=nID;
	pMessage->nType=nType;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}
void					SMsgManager::AddHttpPercent(int nID,int nType,unsigned int nPercent)
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::HttpPercent_MSG;
	pMessage->nID=nID;
	pMessage->nType=nType;
	pMessage->nPercent=nPercent;

	m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddGGDownloadEndMsg()
{
    SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::GGDownloadEnd_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddGGDownloadFailMsg()
{
    SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::GGDownloadFail_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddUpdateEndMsg()
{
    SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::UpdateEnd_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddUpdateNotNeedMsg()
{
    SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::UpdateNotNeed_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddAppQuitMsg()
{
    SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::AppQuit_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddUpdateCancelMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::UpdateCancel_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddUpdateFailMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::UpdateFail_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddUpdatePackBrokeMsg()
{
	SMsg *pMessage=new SMsg;
	pMessage->type=SMsg::UpdatePackBroke_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddDownloadEndMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::DownloadEnd_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddDownloadFailMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::DownloadFail_Msg;
    
    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddGameNeedUpdateMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::Game_Need_Update_Msg;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddGameNotNeedUpdateMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::Game_Not_Need_Update_Msg;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddAndroidNeedFullUpdateMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::Android_Need_Full_Update_Msg;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::GetIPTBEnd(std::string str )
{
	m_IpStr = str;
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::GetIPTBEnd_Msg;
	pMessage->str = str;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}


void					SMsgManager::AddAndroidNotNeedFullUpdateMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::Android_Not_Need_Full_Update_Msg;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddAndoridFullUpdatFailMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::Android_Full_Update_Fail;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}

void					SMsgManager::AddAndoridFullUpdateEndMsg()
{
	SMsg *pMessage=new SMsg;
    pMessage->type=SMsg::Android_Full_Update_End;

    m_lock.Enter();
	m_lMessage.push_back(pMessage);
	m_lock.Leave();
}