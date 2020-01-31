#include "../SPlatform.h"
#include "../SConfig.h"
#include "../STools.h"
#include "../SBind.h"
using namespace SDK;
//<SThread>-------------------------------------------------------------------------------------
SThread::SThread()
{
    m_bRun=false;
	m_bWait=false;
}
void				SThread::StartThread()
{
	if(IsRun())
		return;
    m_bRun=true;
	m_bWait=true;

#ifdef WIN32
	HANDLE hd=(HANDLE)_beginthreadex(NULL,0,Run,(void*)this,true,NULL);
	CloseHandle(hd);
#else
	pthread_t hd=0;
    pthread_attr_t  attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr,PTHREAD_CREATE_DETACHED);
    pthread_create(&hd,&attr,&Run,this);
    pthread_attr_destroy(&attr);
#endif
}
void				SThread::Close()
{
	m_bRun=false;
	while(m_bWait)
	{
#ifdef WIN32
		Sleep(1);
#else
		sleep(1);
#endif
	}
}
bool				SThread::IsRun()
{
    return m_bRun;
}
#ifdef WIN32
unsigned int WINAPI SThread::Run(LPVOID pParam)
{
	SThread *p=(SThread*)pParam;
	p->ThreadProc();
	p->m_bRun=false;
	p->m_bWait=false;
	return 0;
}
#else
void*               SThread::Run(void *pParam)
{
	SThread *p=(SThread*)pParam;
	p->ThreadProc();
	p->m_bRun=false;
	p->m_bWait=false;
	return NULL;
}
#endif

//<SLock>--------------------------------------------------------------------------------------------------------
SLock::SLock()
{
#ifdef WIN32
	InitializeCriticalSectionAndSpinCount(&m_cs,4000);
#else
	pthread_mutexattr_t info;
	pthread_mutexattr_init(&info);
	pthread_mutexattr_settype(&info,PTHREAD_MUTEX_RECURSIVE);

	pthread_mutex_init(&m_lock,&info);

	pthread_mutexattr_destroy(&info);
#endif
}
SLock::~SLock()
{
#ifdef WIN32
	DeleteCriticalSection(&m_cs);
#else
	pthread_mutex_destroy(&m_lock);
#endif
}
void                SLock::Enter()
{
#ifdef WIN32	
	EnterCriticalSection(&m_cs);
#else
	pthread_mutex_lock(&m_lock);
#endif
}
void                SLock::Leave()
{
#ifdef WIN32
	LeaveCriticalSection(&m_cs);
#else
	pthread_mutex_unlock(&m_lock);
#endif
}

//<SSocket>--------------------------------------------------------------------------------------------------------
SSocket::SSocket()
{
	m_nSocket=0;
	m_bBlock=true;
}
SSocket::~SSocket()
{
	Close();
}
void		SSocket::Init()
{
	Close();
	m_nSocket=socket(AF_INET,SOCK_STREAM,0);
}
void		SSocket::SetAttrib(bool bBlock/*=true*/)
{
	if(m_nSocket==0)
		return;

	m_bBlock=bBlock;

	if(m_bBlock==false)
	{
#ifdef WIN32
		unsigned long lBlock=1;
		ioctlsocket(m_nSocket,FIONBIO,(unsigned long*)&lBlock); 
#else
		int flags=fcntl(m_nSocket,F_GETFL,0);
		fcntl(m_nSocket,F_SETFL,flags|O_NONBLOCK);
#endif
	}

#ifdef WIN32
    //强制关闭
	LINGER Linger;
	Linger.l_onoff=1;
	Linger.l_linger=0;
	setsockopt(m_nSocket,SOL_SOCKET,SO_LINGER,(const char *)&Linger,sizeof(Linger));
    
    //复用端口
	bool bReuseAddr=true;
	setsockopt(m_nSocket,SOL_SOCKET,SO_REUSEADDR,(const char *)&bReuseAddr,sizeof(bool));
    
	//Nagle算法
	bool bNoDelay=true;
	setsockopt(m_nSocket,IPPROTO_TCP,TCP_NODELAY,(const char *)&bNoDelay,sizeof(bool));
    
	//开启心跳检测
	bool bKeepAlive=true;
	setsockopt(m_nSocket,SOL_SOCKET,SO_KEEPALIVE,(char*)&bKeepAlive,sizeof(bool));
#else
    //强制关闭
    linger Linger;
	Linger.l_onoff=1;
	Linger.l_linger=0;
	setsockopt(m_nSocket,SOL_SOCKET,SO_LINGER,(const char *)&Linger,sizeof(Linger));
    
    //复用端口
	int bReuseAddr=1;
	setsockopt(m_nSocket,SOL_SOCKET,SO_REUSEADDR,(const char *)&bReuseAddr,sizeof(int));
    
	//Nagle算法
	int bNoDelay=1;
    if(setsockopt(m_nSocket,IPPROTO_TCP,TCP_NODELAY,(const char *)&bNoDelay,sizeof(int))!=0)
       throw("TCP_NODELAY ERROR");
    
	//开启心跳检测
	int bKeepAlive=1;
	setsockopt(m_nSocket,SOL_SOCKET,SO_KEEPALIVE,(char*)&bKeepAlive,sizeof(int));
#endif

    //设置心跳检查
#ifdef WIN32
	tcp_keepalive alive_in;
	tcp_keepalive alive_out;
	ZeroMemory(&alive_in,sizeof(tcp_keepalive));
	ZeroMemory(&alive_out,sizeof(tcp_keepalive));
	alive_in.keepalivetime=  HEARTBEAT_FIRST_TIME; 
	alive_in.keepaliveinterval= HEARTBEAT_SECOND_TIME; 	
	alive_in.onoff=TRUE; 
	unsigned long ulBytesReturn=0; 
	int xx=WSAIoctl(m_nSocket,SIO_KEEPALIVE_VALS,&alive_in,sizeof(tcp_keepalive),
		&alive_out,sizeof(tcp_keepalive),&ulBytesReturn,NULL,NULL);
#else

    int n=30;//HEARTBEAT_FIRST_TIME/1000;
	#ifdef ANDROID
		setsockopt(m_nSocket,IPPROTO_TCP,TCP_KEEPIDLE,&n,sizeof(int));
	#else
		setsockopt(m_nSocket,IPPROTO_TCP,TCP_KEEPALIVE,&n,sizeof(int));
	#endif
    
    n=1;//HEARTBEAT_SECOND_TIME/1000;
    setsockopt(m_nSocket,IPPROTO_TCP,TCP_KEEPINTVL,&n,sizeof(int));
    n=3;
    setsockopt(m_nSocket,IPPROTO_TCP,TCP_KEEPCNT,&n,sizeof(int));
#endif
}
void		SSocket::Close()
{
	if(m_nSocket!=0)
	{
		shutdown(m_nSocket,2);
#ifdef WIN32
		closesocket(m_nSocket);
#else
		::close(m_nSocket);
#endif
	}
	m_nSocket=0;
}
bool				SSocket::Connect(const char *strIP,unsigned int port)
{
	if(m_nSocket==0)
		return false;
	if(strIP==NULL)
		return false;
	if(port<=0)
		return false;

	/*struct sockaddr_in server_addr;
	server_addr.sin_family=AF_INET;
	server_addr.sin_port=htons(port);
	server_addr.sin_addr.s_addr=inet_addr(strIP);
	
	return connect(m_nSocket,(struct sockaddr *)&server_addr,sizeof(struct sockaddr_in))==0;*/


	char szConnectIP[100]={};
	sprintf(szConnectIP,"%s",strIP);

	char strPort[100]={};
	sprintf(strPort,"%d",port);

	struct addrinfo *ailist, *aip;
	struct addrinfo hint;
	struct sockaddr_in *sinp;
	int sockfd;
	int err;
	char seraddr[INET_ADDRSTRLEN];
	short serport;

	hint.ai_family = 0;
	hint.ai_socktype = SOCK_STREAM;
	hint.ai_flags = AI_CANONNAME;
	hint.ai_protocol = 0;
	hint.ai_addrlen = 0;
	hint.ai_addr = NULL;
	hint.ai_canonname = NULL;
	hint.ai_next = NULL;
	if ((err = getaddrinfo(szConnectIP, strPort, &hint, &ailist)) != 0) {
	//	printf("getaddrinfo error: %s\n", gai_strerror(err));
		return false;
	}
	bool isConnectOk = false;
	//printf("getaddrinfo ok\n");
	for (aip = ailist; aip != NULL; aip = aip->ai_next) {

		sinp = (struct sockaddr_in *)aip->ai_addr;
		if (inet_ntop(sinp->sin_family, &sinp->sin_addr, seraddr, INET_ADDRSTRLEN) != NULL)
		{
		//	printf("server address is %s\n", seraddr);
		}
		serport = ntohs(sinp->sin_port);
		//printf("server port is %d\n", serport);
		if ((sockfd = socket(aip->ai_family, SOCK_STREAM, 0)) < 0) {
			//printf("create socket failed: %s\n", strerror(errno));
			isConnectOk = false;
			continue;
		}
		//printf("create socket ok\n");
		if (connect(sockfd, aip->ai_addr, aip->ai_addrlen) != 0) {

			printf("can't connect to %s: %s\n", strIP, strerror(errno));
			isConnectOk = false;
			continue;
		}
		isConnectOk = true;

		break;
	}
	freeaddrinfo(ailist);
	

	if (isConnectOk) 
	{
		m_nSocket = sockfd;		
	}
	return isConnectOk;

}
bool				SSocket::BindListen(unsigned int nPort)
{
	if(m_nSocket==0)
		return false;

	sockaddr_in ServerAddress;
	memset((char *)&ServerAddress,0,sizeof(ServerAddress));
	ServerAddress.sin_family=AF_INET;          
	ServerAddress.sin_addr.s_addr=INADDR_ANY;   
	ServerAddress.sin_port=htons((u_short)nPort);
#ifdef WIN32
	if(bind(m_nSocket,(sockaddr*)&ServerAddress,sizeof(sockaddr_in))==SOCKET_ERROR)
		return false;
#else
    if(SBind::Bind(m_nSocket,(sockaddr*)&ServerAddress)==false)
		return false;
#endif
	if(listen(m_nSocket,SOMAXCONN))
		return false;

	return true;
}
SSocket*			SSocket::Accept(bool bBlock/*=true*/)
{
#ifdef WIN32
	SOCKET				nSocket;
#else
	int                 nSocket;
#endif

	nSocket=accept(m_nSocket,NULL,NULL);
#ifdef WIN32
	if(nSocket==INVALID_SOCKET)
		return NULL;
#else
    if(nSocket==-1)
		return NULL;
#endif

	SSocket *p=new SSocket;
	p->m_nSocket=nSocket;
	p->SetAttrib(bBlock);
	return p;
}
bool				SSocket::Send(void *pBuffer,unsigned int nSize)
{
	if(m_nSocket==0)
		return false;
	if(pBuffer==NULL)
		return false;
	if(nSize==0)
		return false;

	if(m_bBlock)
		return send(m_nSocket,(const char*)pBuffer,nSize,0)==nSize;
	else
	{
		unsigned int nTemp=nSize;
		while(nTemp!=0)
		{
			int nSend=send(m_nSocket,(const char*)pBuffer+(nSize-nTemp),nTemp,0);

#ifdef WIN32
			if(nSend==0)
				return false;
			else if(nSend==SOCKET_ERROR)
			{
				if(WSAGetLastError()!=WSAEWOULDBLOCK)
					return false;
			}
			else
				nTemp-=nSend;
#else
            if(nSend==0)
				return false;
			else if(nSend==-1)
			{
				if(errno!=EAGAIN&&errno!=EWOULDBLOCK)
					return false;
			}
			else
				nTemp-=nSend;
#endif
		}

		return true;
	}
}
int					SSocket::Recv(char *pBuffer,unsigned int nSize)
{
	if(m_nSocket==0)
		return 0;
	if(pBuffer==NULL)
		return 0;
	if(nSize==0)
		return 0;

	memset(pBuffer,0,nSize);
	if(m_bBlock)
		return recv(m_nSocket,pBuffer,nSize,0);
	else
	{
		int nRecv=recv(m_nSocket,pBuffer,nSize,0);
#ifdef WIN32
		if(nRecv==0)
			return -1;
		else if(nRecv==SOCKET_ERROR)
		{
			if(WSAGetLastError()==WSAEWOULDBLOCK)
				return 0;
			else
				return -1;
		}
		else
			return nRecv;
#else
        if(nRecv==0)
			return -1;
		else if(nRecv==-1)
		{
			if(errno==EAGAIN||errno==EWOULDBLOCK)
				return 0;
			else
				return -1;
		}
		else
			return nRecv;
#endif
	}
}
//<SUdpSocket>----------------------------------------------------------------------------------
SUdpSocket::SUdpSocket()
{
	m_nSocket=socket(AF_INET,SOCK_DGRAM,0);
#ifdef WIN32
	bool bReuseAddr=true;
	setsockopt(m_nSocket,SOL_SOCKET,SO_REUSEADDR,(const char *)&bReuseAddr,sizeof(bool));
#else
    int bReuseAddr=1;
	setsockopt(m_nSocket,SOL_SOCKET,SO_REUSEADDR,(const char *)&bReuseAddr,sizeof(int));
#endif
}
SUdpSocket::~SUdpSocket()
{
	shutdown(m_nSocket,2);
#ifdef WIN32
	closesocket(m_nSocket);
#else
	::close(m_nSocket);
#endif
	m_nSocket=0;
}
void			SUdpSocket::InitBordcast()
{
#ifdef WIN32
	bool b=true;
	setsockopt(m_nSocket,SOL_SOCKET,SO_BROADCAST,(const char *)&b,sizeof(bool));
#else
    int b=1;
	setsockopt(m_nSocket,SOL_SOCKET,SO_BROADCAST,(const char *)&b,sizeof(int));
#endif
}
void			SUdpSocket::Bordcast(unsigned int nPort,void *pBuffer,unsigned int nSize)
{
	if(pBuffer==NULL)
		return;
	if(nSize==0)
		return;

	sockaddr_in ser;
	memset((char *)&ser,0,sizeof(ser));
	ser.sin_family=AF_INET;          
	ser.sin_addr.s_addr=INADDR_BROADCAST;   
	ser.sin_port=htons((u_short)nPort);   

	sendto(m_nSocket,(const char*)pBuffer,nSize,0,(sockaddr*)&ser,sizeof(sockaddr_in));
}
void			SUdpSocket::InitRecv(unsigned int nPort)
{
#ifdef WIN32
	unsigned long lBlock=1;
	ioctlsocket(m_nSocket,FIONBIO,(unsigned long*)&lBlock); 
#else
	int flags=fcntl(m_nSocket,F_GETFL,0);
	fcntl(m_nSocket,F_SETFL,flags|O_NONBLOCK);
#endif

	sockaddr_in ser;
	memset((char *)&ser,0,sizeof(ser));
	ser.sin_family=AF_INET;          
	ser.sin_addr.s_addr=htonl(INADDR_ANY);
	ser.sin_port=htons((u_short)nPort);

#ifdef WIN32
	bind(m_nSocket,(sockaddr*)&ser,sizeof(sockaddr_in));
#else
    SBind::Bind(m_nSocket,(sockaddr*)&ser);
#endif
}
int				SUdpSocket::Recv(char *pBuffer,unsigned int nSize,string &strIP)
{
	if(pBuffer==NULL)
		return 0;
	if(nSize==0)
		return 0;
	strIP.clear();

	sockaddr_in ser;
	memset((char *)&ser,0,sizeof(ser));
    
#ifdef WIN32
	int nLen=sizeof(sockaddr_in);
#else
    socklen_t nLen=sizeof(sockaddr_in);
#endif

	memset(pBuffer,0,nSize);
    
	int nRecv=recvfrom(m_nSocket,pBuffer,nSize,0,(sockaddr*)&ser,&nLen);
	if(nRecv<=0)
		return 0;
	else
	{
		strIP=inet_ntoa(ser.sin_addr);
		return nRecv;
	}
}
//<STime>------------------------------------------------------------------------------------
unsigned int		STime::GetTime()
{
#ifdef WIN32
	return timeGetTime();
#else
    timeval psv;
    gettimeofday(&psv,NULL);
    unsigned long int n=psv.tv_sec*1000+psv.tv_usec/1000;
    return n;
#endif
}