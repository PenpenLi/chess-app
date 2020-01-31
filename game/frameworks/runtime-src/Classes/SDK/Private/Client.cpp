#include "../Client.h"
#include "../SInit.h"
#include "../CommMD5.h"
#include <time.h>
using namespace SDK;

//<SNetThread>---------------------------------------------------------------------------------------------------
SNetThread::SNetThread()
{
	m_pClient=NULL;
}
void                SNetThread::SetClient(Client *pClient)
{
	m_lockxx.Enter();
	m_pClient=pClient;
	m_lockxx.Leave();
}
Client*			SNetThread::GetClient()
{
	return m_pClient;
}

//<SConnectRecvThread>-----------------------------------------------------------------------------------------------
SConnectRecvThread::SConnectRecvThread()
{
	m_nPort=0;
}
void                SConnectRecvThread::Connect(const char *strIP,int nPort)
{
	m_strIP=strIP;
	m_nPort=nPort;
}
void                SConnectRecvThread::ThreadProc()
{
	//开始连接
	if(GetClient()->m_socket.Connect(m_strIP.c_str(),m_nPort))
	{
		m_lockxx.Enter();
		if(GetClient()==NULL)
		{
			m_lockxx.Leave();
			return;
		}
		GetClient()->Lock();
		GetClient()->m_emState=CONN_STATE;
		INSTANCE(SMsgManager)->AddClientConnectMsg(GetClient());
		GetClient()->Unlock();
		m_lockxx.Leave();
	}
	else
	{
		m_lockxx.Enter();
		if(GetClient()==NULL)
		{
			m_lockxx.Leave();
			return;
		}
		GetClient()->Lock();
		GetClient()->m_emState=INIT_STATE;
		GetClient()->m_socket.Close();
		INSTANCE(SMsgManager)->AddClientFaildMsg(GetClient());
		GetClient()->Unlock();
		m_lockxx.Leave();
		return;
	}

	//开始接受网络数据---------------------------

	//一个完整包的缓冲区
	int nBufferSize=0;
	char *pBuffer=new char[MAX_SIZE];
	memset(pBuffer,0,MAX_SIZE);

	//一次接收的缓冲区
	int recvSize=0;
	char *pRecv=new char[BUFFER_SIZE];
	memset(pRecv,0,BUFFER_SIZE);

	while(IsRun())
	{
		memset(pRecv,0,BUFFER_SIZE);
		recvSize=GetClient()->m_socket.Recv(pRecv,BUFFER_SIZE);
		if(recvSize<=0)
		{
			CloseSocket();
			break;
		}

		if(nBufferSize==0)
		{
			if(recvSize<4)
			{
				memcpy(pBuffer,pRecv,recvSize);
				nBufferSize=recvSize;
				continue;
			}

			if(AssistantParse(pRecv,recvSize,pBuffer,nBufferSize))
				break;
		}
		else
		{
			int dwTemp=nBufferSize;
			if(nBufferSize<4)
			{
				if(nBufferSize+recvSize<4)
				{
					memcpy(pBuffer+nBufferSize,pRecv,recvSize);
					nBufferSize+=recvSize;
					continue;
				}
				else
				{
					memcpy(pBuffer+nBufferSize,pRecv,4-nBufferSize);
					nBufferSize=4;

					int dwPackSize=*((int*)pBuffer);
					if(dwPackSize<8||dwPackSize>MAX_SIZE)
					{
						CloseSocket();
						break;
					}

					int dwOffset=4-dwTemp;
					if(recvSize-dwOffset+4>=dwPackSize)
					{
						//Push一个包
						memcpy(pBuffer+4,pRecv+dwOffset,dwPackSize-4);
						INSTANCE(SMsgManager)->AddClientMsg(*((int*)pBuffer+1),(int*)pBuffer+2,*((int*)pBuffer)-8,GetClient());

						//初始化
						memset(pBuffer,0,MAX_SIZE);
						nBufferSize=0;

						if(recvSize-dwOffset+4==dwPackSize)
						{
							continue;
						}
						else
						{
							if(AssistantParse(pRecv+dwOffset+(dwPackSize-4),recvSize-dwOffset-(dwPackSize-4),pBuffer,nBufferSize))
								break;
							else
								continue;
						}
					}
					else
					{
						memcpy(pBuffer+4,pRecv+dwOffset,recvSize-dwOffset);
						nBufferSize=dwTemp+recvSize;
						continue;
					}
				}
			}
			else
			{
				int dwPackSize=*((int*)pBuffer);

				if(recvSize+nBufferSize>=dwPackSize)
				{
					//Push一个包
					int dwTemp1=dwPackSize-nBufferSize;
					memcpy(pBuffer+nBufferSize,pRecv,dwTemp1);
					INSTANCE(SMsgManager)->AddClientMsg(*((int*)pBuffer+1),(int*)pBuffer+2,*((int*)pBuffer)-8,GetClient());

					//初始化
					memset(pBuffer,0,MAX_SIZE);
					nBufferSize=0;

					if(dwTemp1==recvSize)
					{
						continue;
					}

					if(AssistantParse(pRecv+dwTemp1,recvSize-dwTemp1,pBuffer,nBufferSize))
						break;
					else
						continue;
				}
				else
				{
					memcpy(pBuffer+nBufferSize,pRecv,recvSize);
					nBufferSize+=recvSize;
					continue;
				}
			}
		}
	}

	//清空
	delete[] pBuffer;
	delete[] pRecv;
}
bool                SConnectRecvThread::AssistantParse(char *pBuffer,int dw32Size,char *pTotalBuffer,int &nTotalBufferSize)
{
	if(dw32Size==0)
		return false;

	if(dw32Size<4)
	{
		memcpy(pTotalBuffer,pBuffer,dw32Size);
		nTotalBufferSize=dw32Size;
	}
	else
	{
		int dwTemp1=*((int*)(pBuffer));

		if(dwTemp1<8||dwTemp1>MAX_SIZE)
		{
			CloseSocket();
			return true;
		}

		if(dw32Size>=dwTemp1)
		{
			//Push一个包
			INSTANCE(SMsgManager)->AddClientMsg(*((int*)pBuffer+1),(int*)pBuffer+2,*((int*)pBuffer)-8,GetClient());

			//继续解析
			pBuffer+=dwTemp1;
			dw32Size-=dwTemp1;
			return AssistantParse(pBuffer,dw32Size,pTotalBuffer,nTotalBufferSize);
		}
		else
		{
			memcpy(pTotalBuffer,pBuffer,dw32Size);
			nTotalBufferSize=dw32Size;
		}
	}

	return false;
}
void		SConnectRecvThread::CloseSocket()
{
	GetClient()->Lock();
	if(GetClient()->m_emState==CONN_STATE)
	{
		INSTANCE(SMsgManager)->AddClientCloseMsg(GetClient());
	}
	GetClient()->m_emState=INIT_STATE;
	GetClient()->m_socket.Close();
	GetClient()->Unlock();
}
void		SConnectRecvThread::Close()
{
	m_nPort=0;
	SNetThread::Close();
}

//<SSendThread>--------------------------------------------------------------------------------------------------
SSendThread::SSendThread()
{
	m_bFix4 = false;
}
SSendThread::~SSendThread()
{
	for(list<SPacker*>::iterator it=m_lPacker.begin();it!=m_lPacker.end();++it)
	{
		delete *it;
	}
	m_lPacker.clear();
}
void           SSendThread::Send(unsigned int nProtocol,void *pBuffer,unsigned int nSize)
{
	if(nSize+8>MAX_SIZE)
		throw("SSendThread::Send 发包过长");

	SPacker *pack=new SPacker;
	pack->SetProtocol(nProtocol);
	pack->Push(pBuffer,nSize);
	m_lock.Enter();
	m_lPacker.push_back(pack);
	m_lock.Leave();
}
void			SSendThread::Close()
{
	m_lock.Enter();
	for(list<SPacker*>::iterator it=m_lPacker.begin();it!=m_lPacker.end();++it)
	{
		delete *it;
	}
	m_lPacker.clear();
	m_lock.Leave();

	//SNetThread::Close();
}
void            SSendThread::ThreadProc()
{
	char *pBuffer=new char[MAX_SIZE];
	memset(pBuffer,0,MAX_SIZE);

	while(IsRun())
	{
		m_lock.Enter();
		if(m_lPacker.size()==0)
		{
			m_lock.Leave();
#ifdef WIN32
			Sleep(1);
#else
			//sleep(0);
			usleep(10000);
#endif

			continue;
		}
		SPacker *pPack=(*(m_lPacker.begin()));
		m_lPacker.pop_front();
		m_lock.Leave();

		bool bRe =  false;
		int nSize=pPack->GetSize();
		if (IsFix4()==false) //不发送四个字节的头
		{
			*((int*)pBuffer)=nSize+8;
			*((int*)pBuffer+1)=pPack->GetProtocol();
			memcpy((int*)pBuffer+2,pPack->GetBuffer(),pPack->GetSize());
			bRe = GetClient()->m_socket.Send(pBuffer,nSize+8);
		}
		else //发送四个字节的头
		{
			*((int*)pBuffer)=0;		//IP位置
			*((int*)pBuffer+1)=nSize+12; //大小
			*((int*)pBuffer+2)=pPack->GetProtocol();//协议ID
			memcpy((int*)pBuffer+3,pPack->GetBuffer(),pPack->GetSize());//包内容
			bRe = GetClient()->m_socket.Send(pBuffer,nSize+12);			
		}		
		if(bRe==false)
		{
			delete pPack;
			GetClient()->Lock();
			if(GetClient()->m_emState==CONN_STATE)
			{
				INSTANCE(SMsgManager)->AddClientCloseMsg(GetClient());
			}
			GetClient()->m_emState=INIT_STATE;
			GetClient()->m_socket.Close();
			GetClient()->Unlock();
			m_lock.Leave();
			break;
		}
		delete pPack;
	}

	//清空
	m_lock.Enter();
	for(list<SPacker*>::iterator it=m_lPacker.begin();it!=m_lPacker.end();++it)
	{
		delete *it;
	}
	m_lPacker.clear();
	m_lock.Leave();

	delete[] pBuffer;
}

//<Client>-------------------------------------------------------------------------------------------------------
Client::Client()
{
	m_emState=INIT_STATE;
	m_pMainThread=NULL;
	m_sendThread.SetClient(this);
	m_sendThread.SetFix4(true);
	
}
Client::~Client()
{
	Close();
}
void        Client::Connect(const char *strIP,unsigned int port)
{
	Close();

	m_socket.Init();
	m_socket.SetAttrib();
	m_emState=CONNECTING_STATE;

	m_pMainThread=new SConnectRecvThread();
	m_pMainThread->SetClient(this);
	m_pMainThread->Connect(strIP,port);
	m_pMainThread->StartThread();

	m_sendThread.StartThread();
}
void        Client::Close()
{ 
	m_lock.Enter();
	if(m_pMainThread&&m_emState==CONNECTING_STATE)
		m_pMainThread->SetClient(NULL);
	m_emState=INIT_STATE;
	m_socket.Close();
	m_lock.Leave();
	m_pMainThread=NULL;
	m_sendThread.Close();
}
void        Client::Send(unsigned int nProtocol,void *pBuffer,unsigned int nSize)
{
	if(m_emState!=CONN_STATE)
		return;

	m_sendThread.Send(nProtocol,pBuffer,nSize);
}
void        Client::Send(const SPacker &pack)
{
	if(m_emState!=CONN_STATE)
		return;

	m_sendThread.Send(pack.GetProtocol(),pack.GetBuffer(),pack.GetSize());
}
void		Client::Send(unsigned int nProtocol,SVar *p)
{
	if(m_emState!=CONN_STATE)
		return;

	if(p)
	{
		unsigned char *pSend=(unsigned char*)INSTANCE(SInit)->GetBuffer();
		unsigned int nSend=SSerialize::ToBinary(*p,pSend,MAX_SIZE);
		m_sendThread.Send(nProtocol,pSend,nSend);
	}
	else
		m_sendThread.Send(nProtocol,NULL,0);
}
void		Client::Lock()
{
	m_lock.Enter();
}
void		Client::Unlock()
{
	m_lock.Leave();
}
//
//验证连接------------------------------------------------------------------------------------------------------
CheckClient::CheckClient()
{
}
CheckClient::~CheckClient()
{
}
#ifdef _WIN32
// 设定 Socket 为强迫关闭
void SetSocketLingerOFF(SOCKET SocketFD)
{
	// 强制关闭
	linger m_sLinger;

	m_sLinger.l_onoff = 1;
	m_sLinger.l_linger = 0;

	setsockopt(SocketFD, SOL_SOCKET, SO_LINGER, (const char *) &m_sLinger, sizeof(m_sLinger));

	// 服务器 bind 设定
	int option = 1;
	setsockopt(SocketFD, SOL_SOCKET, SO_REUSEADDR, (char *) &option, sizeof(option));

	// No Delay
	setsockopt(SocketFD, IPPROTO_TCP, TCP_NODELAY, (char *) &option, sizeof(option));

	// 设定 非阻塞
	unsigned long tmepOption = 1;
	ioctlsocket(SocketFD, FIONBIO, &tmepOption);
}
#else
// 设定 Socket 为强迫关闭
void SetSocketLingerOFF(int SocketFD)
{
	// 强制关闭
	linger m_sLinger;

	m_sLinger.l_onoff = 1;
	m_sLinger.l_linger = 0;

	setsockopt(SocketFD, SOL_SOCKET, SO_LINGER, (const char *) &m_sLinger, sizeof(m_sLinger));

	// 服务器 bind 设定
	int option = 1;
	setsockopt(SocketFD, SOL_SOCKET, SO_REUSEADDR, (char *) &option, sizeof(option));

	// No Delay
	setsockopt(SocketFD, IPPROTO_TCP, TCP_NODELAY, (char *) &option, sizeof(option));

	// 设定 非阻塞
	int flag = fcntl(SocketFD, F_GETFL, 0);
	fcntl(SocketFD, F_SETFL, flag | O_NONBLOCK);
}
#endif

void CheckClient::encrypt_code( char* buf,char* xorkeys,int xorlen,int count)
{
	int i;
	for (i=0;i<=count-1;i++)
	{
		buf[i]=buf[i] ^ xorkeys[i % xorlen];

	}
}
int CheckClient::safeconnectex(const char* ip,int port,time_t Unixdate)
{
	if (ip==NULL || port<0||port>65536) return -1;
	SSocket _sck;
	_sck.Init();
	_sck.SetAttrib();
	if (_sck.Connect(ip,port)==false)
	{
		_sck.Close();
		return 1;
	}
	int ret = 2;
	char szCHconnect = '*';
	char keystr[8] = {0};	
	//send(_sck.m_nSocket,(char*)&szCHconnect,sizeof(szCHconnect),0);
	if (_sck.Send((char*)&szCHconnect,sizeof(szCHconnect))==false)
	{
		return 4;
	}
	ClientData r_client;
	time_t d1 = 0;
	int num = _sck.Recv((char*)&r_client,sizeof(r_client));
	
	if (num == sizeof(r_client))
	{		
		encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));
		time(&d1);
		int dadd=abs(d1-Unixdate);
		if (dadd>300000) //大于5分钟
		{
			ret=3;//验证超时			
		}
		else
		{		
			r_client.Time=Unixdate;//DateTimeToUnix(d1);
			memcpy(keystr,&r_client.Time,8);
			encrypt_code((char*)&r_client.key,keystr,8,sizeof(r_client.key)-1);			
			string  str = md5(r_client.key);		
			sprintf(r_client.MD5,"%s",str.c_str());
			encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));
			if (_sck.Send((char*)&r_client,sizeof(r_client)))
			{						
			//	if (_sck.Recv((char*)&r_client,sizeof(r_client)) ==sizeof(r_client)) 
				{
					encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));			
					if (r_client.Ret==0)
					{
						ret=0;
					}
					else
						ret = r_client.Ret;					
				} 			
				/*else
				ret = 6;*/
			}
			else
				ret = 7;
		}
	}
	else
		return 5;
	_sck.Close();	
	return ret; //0验证成功 1验证失败 2服务未开启 3验证返回超时
}


int CheckClient::safeconnect(const char* ip,int port,time_t Unixdate)
{
	//VMProtectBegin("PlatSafeConnect");
	//char * g_xorkey="BF3FB36ABA9741F1";
	//char md5str[33]={0};
	//WSAData GInitData;
	//char keystr[8]={0};
	//SOCKET s;
	//sockaddr_in addr;
	//timeval tv;
	//int nNetTimeout=0;
	//time_t d1,d2;

	//fd_set rd;
	//int ret;
	//ret =2;
	//ClientData r_client={0};
	////	MD5 iMD5; 
	//char szCHconnect = '*';
	//if (WSAStartup(MAKEWORD(2,1),&GInitData) !=0) {
	//	return ret;
	//}
	//addr.sin_addr.S_un.S_addr= inet_addr(ip);

	//addr.sin_family = PF_INET;
	//addr.sin_port = htons(port);

	//s = socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
	//nNetTimeout=5000;//1秒，

	//setsockopt(s,SOL_SOCKET,0x700C ,(char*) &nNetTimeout,4);
	//nNetTimeout=5000;//1秒，

	//setsockopt(s,SOL_SOCKET,SO_SNDTIMEO, (char*) &nNetTimeout,4);
	//setsockopt(s,SOL_SOCKET,SO_RCVTIMEO,(char*) &nNetTimeout,4);	
	//connect(s,(sockaddr*) &addr, sizeof(addr));

	//tv.tv_sec = 0;
	//tv.tv_usec = 50;
	//FD_ZERO(&rd);
	//FD_SET(s, &rd);
	//if(select(s + 1, &rd, NULL, NULL, &tv) < 0) 
	//{
	//	closesocket(s);
	//	return ret;
	//} 
	////OutputDebugString('链接成功');
	//send(s,(char*)&szCHconnect,sizeof(szCHconnect),0);
	//if (recv(s,(char*)&r_client,sizeof(r_client),0)==sizeof(r_client)) 
	//{
	//	//OutputDebugString('获取数据.');
	//	encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));
	//	time(&d1);
	//	int dadd=abs(d1-Unixdate);
	//	if (dadd>300) //大于5分钟
	//	{
	//		closesocket(s);
	//		ret=3;
	//		return ret;
	//	}
	//	r_client.Time=Unixdate;//DateTimeToUnix(d1);
	//	memcpy(keystr,&r_client.Time,8);
	//	encrypt_code((char*)&r_client.key,keystr,8,sizeof(r_client.key)-1);			
	//	string  str = md5(r_client.key);		
	//	sprintf(r_client.MD5,"%s",str.c_str());
	//	encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));

	//	send(s,(char*)&r_client,sizeof(r_client),0);
	//	if (recv(s,(char*)&r_client,sizeof(r_client),0) ==sizeof(r_client)) 
	//	{
	//		encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));
	//		//OutputDebugString(PChar('ret:'+inttostr(r_client.Ret)));
	//		if (r_client.Ret==0)
	//		{
	//			ret=0;
	//		}
	//		closesocket(s);
	//		WSACleanup;			
	//	} 
	//}
	//return ret; //0验证成功 1验证失败 2服务未开启 3验证返回超时
	////VMProtectEnd();


	int s;
	char buf[20];
	struct sockaddr_in sock;
	fd_set rset,wset;
	struct timeval tv;
	tv.tv_sec=10;
	s=socket(AF_INET,SOCK_STREAM,0);
	if(-1==s) return false;
	SetSocketLingerOFF(s);

	sock.sin_family=PF_INET;
	sock.sin_port  =htons(port);
	sock.sin_addr.s_addr=inet_addr(ip);

	char * g_xorkey="BF3FB36ABA9741F1";
	char md5str[33]={0};	
	char keystr[8]={0};	
	int nNetTimeout=0;
	time_t d1,d2;

	fd_set rd;
	int ret;
	ret =2;
	ClientData r_client={0};	
	nNetTimeout=5000;//1秒，	

	connect(s,(struct sockaddr*)&sock, sizeof(struct sockaddr_in));

	tv.tv_sec = 0;
	tv.tv_usec = 50;
	FD_ZERO(&rd);
	FD_SET(s, &rd);
	if(select(s + 1, &rd, NULL, NULL, &tv) < 0) 
	{
#ifdef _WIN32
		shutdown(s, SD_BOTH);
		closesocket(s);
		this->m_Socket = INVALID_SOCKET;
#else	
		shutdown(s, 2);
		close(s);
		s = -1;
#endif	
		return ret;
	} 
	char szCHconnect = '*';
	//OutputDebugString('链接成功');
	send(s,(char*)&szCHconnect,sizeof(szCHconnect),0);
	time_t now_time,now_time1;
	now_time = time(NULL);
	int num = -1;
	while (num == -1)
	{
		num = recv(s,(char*)&r_client,sizeof(r_client),0);
		now_time1 = time(NULL);
		if(now_time1-now_time > 3)
		{
			break;
		}
	}
	//int num = recv(s,(char*)&r_client,sizeof(r_client),0);
	int abc = sizeof(r_client);
	if (num==sizeof(r_client)) 
	{
		//OutputDebugString('获取数据.');
		encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));
		time(&d1);
		int dadd=abs(d1-Unixdate);
		if (dadd>300) //大于5分钟
		{
#ifdef _WIN32
			shutdown(s, SD_BOTH);
			closesocket(s);
			this->m_Socket = INVALID_SOCKET;
#else	
			shutdown(s, 2);
			close(s);
			s = -1;
#endif	
			ret=1;
			return ret;
		}

		r_client.Time=Unixdate;//DateTimeToUnix(d1);
		memcpy(keystr,&r_client.Time,8);
		encrypt_code((char*)&r_client.key,keystr,8,sizeof(r_client.key)-1);
		/*iMD5.GenerateMD5((unsigned char*)&r_client.key,sizeof(r_client.key)-1);

		for(int j = 0; j < 16; j++ )
		{
		sprintf( md5str + j * 2, "%02x", ((unsigned char*)iMD5.m_data)[j]);
		}

		memcpy(&r_client.MD5,md5str,strlen(md5str));*/
		string  str = md5(r_client.key);		
		sprintf(r_client.MD5,"%s",str.c_str());
		encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));		

		send(s,(char*)&r_client,sizeof(r_client),0);
		if (recv(s,(char*)&r_client,sizeof(r_client),0) ==sizeof(r_client)) 
		{
			encrypt_code((char*)&r_client,"BF3FB36ABA9741F1",16,sizeof(r_client));
			if (r_client.Ret==0)
			{
				ret=0;
			}
#ifdef _WIN32
			shutdown(s, SD_BOTH);
			closesocket(s);
			this->m_Socket = INVALID_SOCKET;
#else	
			shutdown(s, 2);
			close(s);
			s = -1;
#endif	
			ret = r_client.Ret;
		} 
	}
	return ret;
}