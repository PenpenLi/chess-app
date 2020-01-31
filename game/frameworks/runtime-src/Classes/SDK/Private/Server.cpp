#include "../Server.h"
#include "../SInit.h"
using namespace SDK;

//<Server>-------------------------------------------------------------------------------------------------
Server::Server()
{
	m_bStart=false;
	m_lCurrentSocketID=1;
}
bool Server::Start(unsigned int nPort)
{
	Close();

	m_listenSocket.Init();
	m_listenSocket.SetAttrib(false);
	if(m_listenSocket.BindListen(nPort)==false)
	{
		m_listenSocket.Close();
		return false;
	}

	m_bStart=true;
	return true;
}
void Server::Close()
{
	if(m_bStart)
	{
		//关闭监听
		m_listenSocket.Close();

		//删除链接队列
		for(map<SOCKETID,SSocket*>::iterator it=m_connectTable.begin();it!=m_connectTable.end();++it)
		{
			if(it->first!=0)
			{
				it->second->Close();
				delete it->second;
			}
		}
		m_connectTable.clear();

		//初始化
		m_bStart=false;
	}
}
void Server::Kill(SOCKETID id)
{
	map<SOCKETID,SSocket*>::iterator it=m_connectTable.find(id);
	it->second->Close();
	delete it->second;
	m_connectTable.erase(it);
}
bool Server::IsStart()
{
	return m_bStart;
}
void Server::Send(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id)
{
	if(m_bStart==false)
		return;
	if(nSize+8>MAX_SIZE)
		throw("Server::Send 发包过长");

    map<SOCKETID,SSocket*>::iterator it=m_connectTable.find(id);
    if(it==m_connectTable.end())
        return;

	char *pSend=INSTANCE(SInit)->GetBuffer();
	*((int*)pSend)=nSize+8;
	*((int*)pSend+1)=nProtocol;
	memcpy((int*)pSend+2,pBuffer,nSize);

	if(it->second->Send(pSend,nSize+8)==false)
	{
		INSTANCE(SMsgManager)->AddServerCloseMsg(it->first);
		Kill(it->first);
	}
}
void Server::Send(const SPacker &pack,SOCKETID id)
{
    Send(pack.GetProtocol(),pack.GetBuffer(),pack.GetSize(),id);
}
void Server::Send(unsigned int nProtocol,SVar *p,SOCKETID id)
{
	if(m_bStart==false)
		return;

    map<SOCKETID,SSocket*>::iterator it=m_connectTable.find(id);
    if(it==m_connectTable.end())
        return;

	char *pSend=INSTANCE(SInit)->GetBuffer();
	if(p)
		*((unsigned int*)pSend)=SSerialize::ToBinary(*p,(unsigned char*)pSend+8,MAX_SIZE-8)+8;
	else
		*((unsigned int*)pSend)=8;
	*((unsigned int*)pSend+1)=nProtocol;

	if(it->second->Send(pSend,*((unsigned int*)pSend))==false)
	{
		INSTANCE(SMsgManager)->AddServerCloseMsg(it->first);
		Kill(it->first);
	}
}
void Server::Bordcast(unsigned int nProtocol,void *pBuffer,unsigned int nSize)
{
	if(m_bStart==false)
		return;

	for(map<SOCKETID,SSocket*>::iterator it=m_connectTable.begin();it!=m_connectTable.end();++it)
	{
		Send(nProtocol,pBuffer,nSize,it->first);
	}
}
void Server::Bordcast(const SPacker &pack)
{
	if(m_bStart==false)
		return;

	for(map<SOCKETID,SSocket*>::iterator it=m_connectTable.begin();it!=m_connectTable.end();++it)
	{
		Send(pack,it->first);
	}
}
void Server::Bordcast(unsigned int nProtocol,SVar *p)
{
	if(m_bStart==false)
		return;

	for(map<SOCKETID,SSocket*>::iterator it=m_connectTable.begin();it!=m_connectTable.end();++it)
	{
		Send(nProtocol,p,it->first);
	}
}
void Server::Loop()
{
	if(m_bStart==false)
		return;

	//监听
	SSocket *p=m_listenSocket.Accept(false);
	if(p)
	{
		m_connectTable[m_lCurrentSocketID]=p;
		INSTANCE(SMsgManager)->AddServerConnectMsg(m_lCurrentSocketID);
		++m_lCurrentSocketID;
	}

	//缓冲区
	char *pSend=INSTANCE(SInit)->GetBuffer();

	//接收
    for(int i=0;i<10;++i)
    {
GOTO1:
	for(map<SOCKETID,SSocket*>::iterator it=m_connectTable.begin();it!=m_connectTable.end();)
	{
		if(it->first==0)
		{
			++it;
			continue;
		}
GOTO2:
		SSocket *p=it->second;

		//接收包长
		unsigned int nSize=4;
		while(nSize!=0)
		{
			int nRecv=p->Recv(pSend+(4-nSize),nSize);
			switch(nRecv)
			{
			case -1:
				{
 INSTANCE(SMsgManager)->AddServerCloseMsg(it->first);	
 Kill(it->first);
 goto GOTO1;
				}
				break;
			case 0:
				{
 if(nSize==4)
 {
 	++it;
 	if(it==m_connectTable.end())
                            goto GOTO3;
 	else
 		goto GOTO2;
 }
				}
				break;
			default:
				{
 nSize-=nRecv;
				}
			}
		}

		//判断包长
		unsigned int nTotalSize=*((unsigned int*)pSend);
		if(nTotalSize<8||nTotalSize>MAX_SIZE)
		{
			INSTANCE(SMsgManager)->AddServerCloseMsg(it->first);	
			Kill(it->first);
			goto GOTO1;
		}

		//接收包体
		nSize=nTotalSize-4;
		while(nSize!=0)
		{
			int nRecv=p->Recv(pSend+(nTotalSize-nSize),nSize);
			switch(nRecv)
			{
			case -1:
				{
 INSTANCE(SMsgManager)->AddServerCloseMsg(it->first);	
 Kill(it->first);
 goto GOTO1;
				}
				break;
			default:
				{
 nSize-=nRecv;
				}
			}
		}

		INSTANCE(SMsgManager)->AddServerMsg(*((unsigned int*)pSend+1),pSend+8,nTotalSize-8,it->first);
		++it;
	}
GOTO3:
    int a=0;
    }
}