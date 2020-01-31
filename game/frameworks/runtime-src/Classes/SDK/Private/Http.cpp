#include "../Http.h"
#include <stdlib.h>
using namespace SDK;

#pragma warning(disable:4996)

//<SHttpThread>----------------------------------------------------------------------------
void		SHttpThread::Close()
{
	m_socket.Close();
	SThread::Close();
}
void		SHttpThread::ThreadProc()
{
	char *pBuffer=new char[BUFFER_SIZE];
	memset(pBuffer,0,BUFFER_SIZE);
	int dwSize=0;

	while(IsRun())
	{
		stHttp *p=INSTANCE(Http)->GetData();
		if(p==NULL)
		{
#ifdef WIN32
			Sleep(1);
#else
			sleep(1);
#endif
			continue;
		}
		m_socket.Init();
		if(m_socket.Connect(p->strIP.c_str(),p->nPort))
		{
			if(m_socket.Send(p->pBuffer,p->nSize))
			{
				SPacker *pPacker=new SPacker;

				while(true)
				{
					dwSize=m_socket.Recv(pBuffer,BUFFER_SIZE);
					if(dwSize>0)
					{
						pPacker->Push(pBuffer,dwSize);
						if(OnRecv(pPacker,p->nID,p->nType))
						{
							string strTemp=(const char*)pPacker->GetBuffer();
							int nPos=strTemp.find("\r\n\r\n");
							if(nPos!=-1)
							{
								nPos+=4;
								int nTempSize=pPacker->GetSize()-nPos;
								SPacker sTemp;
								sTemp.Push((char*)pPacker->GetBuffer()+nPos,nTempSize);
								pPacker->Clear();
								*pPacker=sTemp;
							}

							INSTANCE(SMsgManager)->AddHttpMsg(pPacker,p->nID,p->nType);
							break;
						}
					}
					else
					{
						delete pPacker;
						INSTANCE(SMsgManager)->AddHttpFaild(p->nID,p->nType);
						break;
					}
				}
			}
			else
            {
				INSTANCE(SMsgManager)->AddHttpFaild(p->nID,p->nType);
            }
		}
		else
        {
			INSTANCE(SMsgManager)->AddHttpFaild(p->nID,p->nType);
        }

		delete p;
	}

	delete[] pBuffer;
}
bool		SHttpThread::OnRecv(SPacker *pPacker,int nID,int nType)
{
	int dwDataSize=pPacker->GetSize();
	char  *pTotalBuffer=(char*)pPacker->GetBuffer();

	//解析
	char *p=strstr(pTotalBuffer,"Transfer-Encoding: chunked");
	if(p==NULL)	//要么是Content-length,要么结构还没传输过来
	{
		char *p1=strstr(pTotalBuffer,"Content-Length");
		if(p1==NULL)
			p1=strstr(pTotalBuffer,"content-length");
		if(p1)	//确定此http是Content-length结构
		{
			char *p2=strstr(p1,"\r\n\r\n");
			if(p2)	//结构头已经传输过来了
			{
				//得到理论数据长度
				p1+=strlen("Content-Length: ");
				string strTemp;
				while(*p1!='\r'&&*p1!=0)
				{
					strTemp+=*p1;
					++p1;
				}
				int nLength=atoi(strTemp.c_str());

				//得到实际数据长度
				p2+=strlen("\r\n\r\n");

				//百分百
                if(nLength!=0)
                    INSTANCE(SMsgManager)->AddHttpPercent(nID,nType,(int)(((dwDataSize-((long long)p2-(long long)pTotalBuffer))*100)/nLength));

				if(dwDataSize-((long long)p2-(long long)pTotalBuffer)>=(int)nLength)	//所有数据已经传输过来了
				{
					return true;
				}
			}
		}
	}
	else //确定此http是chunked结构
	{
		char *p2=strstr(p,"\r\n\r\n");
		if(p2)	//结构头已经传输过来了
		{
			p2+=strlen("\r\n\r\n");

			//除去包头,数据长度
			int nTemp=dwDataSize-(p2-pTotalBuffer); //现在是头指针是p2,长度是nTemp
			while(IsFullTrunk(p2,nTemp))
			{
				if(IsEndTrunk(p2))
				{
					return true;
				}
				else
					JumpTrunk(p2,nTemp);
			}
		}
	}

	return false;
}
bool				SHttpThread::IsFullTrunk(char *pBuffer,int nSize)
{
	if(nSize<=0)
		return false;
	if(pBuffer==NULL)
		return false;

	char *p1=strstr(pBuffer,"\r\n");
	if(p1==NULL)
		return false;
	int nTemp=p1-pBuffer+strlen("\r\n");

	//得到长度
	string strTemp;
	while(pBuffer!=p1)
	{
		strTemp+=*pBuffer;
		++pBuffer;
	}
	char *pRet=NULL;
	int nLength=(int)strtol(strTemp.c_str(),&pRet,16);

	return nSize>=nTemp+nLength+(int)strlen("\r\n");
}
bool				SHttpThread::IsEndTrunk(char *pBuffer)
{
	char *p1=strstr(pBuffer,"\r\n");

	//得到长度
	string strTemp;
	while(pBuffer!=p1)
	{
		strTemp+=*pBuffer;
		++pBuffer;
	}
	char *pRet=NULL;
	int nLength=(int)strtol(strTemp.c_str(),&pRet,16);

	return nLength==0;
}
void				SHttpThread::JumpTrunk(char* &pBuffer,int &nSize)
{
	char *p1=strstr(pBuffer,"\r\n");
	nSize=nSize-(p1-pBuffer);

	//得到长度
	string strTemp;
	while(pBuffer!=p1)
	{
		strTemp+=*pBuffer;
		++pBuffer;
	}
	char *pRet=NULL;
	int nLength=(int)strtol(strTemp.c_str(),&pRet,16);

	pBuffer=pBuffer+strlen("\r\n")+nLength+strlen("\r\n");
	nSize=nSize-strlen("\r\n")-nLength-strlen("\r\n");
}
//<stHttp>-------------------------------------------------------------------------------
stHttp::stHttp(const char *pIP,int nPort,void *pBuffer,int nSize,int nID,int nType)
{
	this->strIP=pIP;
	this->nPort=nPort;
	this->pBuffer=new char[nSize];
	memcpy(this->pBuffer,pBuffer,nSize);
	this->nSize=nSize;
	this->nID=nID;
	this->nType=nType;
}
stHttp::~stHttp()
{
	if(pBuffer)
		delete[] pBuffer;
}
//<Http>----------------------------------------------------------------------------------
Http::Http()
{
	m_nID=1;
	m_MsgID = 1;
}
Http::~Http()
{
    Close();
}
void Http::Init(int nSize)
{
	for(int i=0;i<nSize;++i)
	{
		SHttpThread *p=new SHttpThread;
		p->StartThread();
		m_vThread.push_back(p);
	}
}
void Http::Close()
{
    for(unsigned int i=0;i<m_vThread.size();++i)
	{
		m_vThread[i]->Close();
		delete m_vThread[i];
	}
}

int Http::Post(const char *pIP,int nPort,const char *pPageName,int nType,const char *pSend)
{
    char *pBuffer=new char[1*1024*1024];
	if (pBuffer==NULL)
		return 0;
    memset(pBuffer,0,1*1024*1024);
    
    if(pSend)
    {
        sprintf(pBuffer,"POST %s HTTP/1.1\r\n"
            "Accept:*/*\r\n"
            "Accept-Language: zh-CN\r\n"
			"Content-Type: application/x-www-form-urlencoded\r\n"
            "Host: %s:%d\r\n"
            "Content-Length: %d\r\n\r\n%s",
            pPageName,pIP,nPort,strlen(pSend),pSend);
    }
    else
    {
        sprintf(pBuffer,"POST %s HTTP/1.1\r\n"
            "Accept:*/*\r\n"
            "Accept-Language: zh-CN\r\n"
            "Host: %s:%d\r\n"
			"Content-Type: application/x-www-form-urlencoded\r\n"
            "Connection: Keep-Alive\r\n\r\n",\
            pPageName,pIP,nPort);
    }

    stHttp *pTemp=new stHttp(pIP,nPort,pBuffer,strlen(pBuffer),m_nID,nType);
	m_lock.Enter();
	m_lData.push_back(pTemp);
	m_lock.Leave();
    
    delete[] pBuffer;
	return m_nID++;
}

void Http::AddMsgType(int nID,int nType)
{
	m_MsgMapLock.Enter();
	int& nSendType = m_mapSendID[nID];
	nSendType = nType;
	m_MsgMapLock.Leave();
}

void Http::DelMsgType(int nID)
{
	std::map<int,int>::iterator iter = m_mapSendID.find(nID);
	if( iter != m_mapSendID.end() )
	{
		m_MsgMapLock.Enter();
		m_mapSendID.erase(iter);
		m_MsgMapLock.Leave();
	}
}

int Http::GetMsgType(int nID)
{
	std::map<int,int>::iterator iter = m_mapSendID.find(nID);
	if( iter != m_mapSendID.end() )
		return iter->second;

	return -1;
}

int Http::NewPost(const char *pIP,int nType,const char *pSend)
{
	char *pBuffer=new char[1*1024*1024];
	if (pBuffer==NULL)
		return 0;
	memset(pBuffer,0,1*1024*1024);
	
//    char *pHeadBuffer=new char[1*1024*1024];
	if( pSend )
	{
//        sprintf(pBuffer,"POST %s HTTP/1.1\r\n"
//                "Accept:*/*\r\n"
//                "Accept-Language: zh-CN\r\n"
//                "Content-Type: application/x-www-form-urlencoded\r\n"
//                "Host: %s:%d\r\n"
//                "Content-Length: %d\r\n\r\n%s",
//                pPageName,pIP,nPort,strlen(pSend),pSend);
        sprintf(pBuffer,"%s",pSend);
	}

	char szIP[1024] = {};
	sprintf(szIP,"%s",pIP);

	HttpRequest* request = new HttpRequest();
	request->setUrl(szIP);
	request->setRequestType(HttpRequest::Type::POST);
	request->setResponseCallback(CC_CALLBACK_2(Http::onHttpsRequestCompleted, this));
//    request->setHeaders(pBuffer);
	request->setRequestData(pBuffer,strlen(pBuffer));

	if( m_mapSendID.empty() )
		m_MsgID = 1;

	char szTag[1024] = {};
	sprintf( szTag, "%d", m_MsgID );

	request->setTag(szTag);
	cocos2d::network::HttpClient::getInstance()->send(request);
	AddMsgType(m_MsgID,nType);

	request->release();
	delete[] pBuffer;

	return m_MsgID++;
}

int	 Http::Get(int nType,const char *pIP,const char *pHost,unsigned int nPort,const char*pUrl,const char*pAddr)
{
	if(pIP==NULL || pHost==NULL ||nPort<=0   || pUrl==NULL || pAddr ==NULL)
	{
	//	SHOW("HttpClient::Post 参数错误:pIP==%p,pHost=%p,nPort=%d,pUrl=%p nType=%d pAddr=%p",pIP,pHost,nPort,pUrl,nType,pAddr);
		return 0;
	}	 
	int nSize = 1*1024*1024;
	char *pBuffer=new char[nSize];
	if (pBuffer==NULL)
		return 0;
	memset(pBuffer,0,nSize);


	char *pHttpGet = "GET %s?%s HTTP/1.1\r\n"
		"Host: %s:%d\r\n\r\n";	
	
	sprintf(pBuffer,pHttpGet,pAddr,pUrl,pHost,nPort);
	stHttp *pTemp=new stHttp(pIP,nPort,pBuffer,strlen(pBuffer),m_nID,nType);
	m_lock.Enter();
	m_lData.push_back(pTemp);
	m_lock.Leave();
	delete[] pBuffer;
	return m_nID++;
	
}


stHttp*		Http::GetData()
{
	m_lock.Enter();
	if(m_lData.size()==0)
	{
		m_lock.Leave();
		return NULL;
	}
	stHttp *pTemp=*(m_lData.begin());
	m_lData.pop_front();
	m_lock.Leave();

	return pTemp;
}

void Http::onHttpsRequestCompleted(HttpClient*sender, HttpResponse *response)
{
	if (!response)
	{
		return;
	}

	std::string strTag = response->getHttpRequest()->getTag();
	if( strTag.empty() )
		return;

	int nMsgTag = atoi(strTag.c_str());
	int nMsgType = GetMsgType(nMsgTag);
	if( nMsgTag == -1 )
		return;

// 	int statusCode = response->getResponseCode();
// 	char statusString[64] = {};
// 	sprintf(statusString, "HTTP Status Code: %d, tag = %s", statusCode, response->getHttpRequest()->getTag());


	//log("response code: %d", statusCode);
	if (!response->isSucceed())
	{
		INSTANCE(SMsgManager)->AddHttpFaild(nMsgTag,nMsgType);
		return;
	}

	char* pBodyBuf=new char[BUFFER_SIZE];
	memset(pBodyBuf,0,BUFFER_SIZE);
    
    char* pBuffer=new char[BUFFER_SIZE];
    memset(pBuffer,0,BUFFER_SIZE);

    int nBufLen = 0;
    std::vector<char>* verHeadBuf = response->getResponseHeader();
    for (unsigned int i = 0; i < verHeadBuf->size(); i++)
    {
        pBuffer[nBufLen] = (*verHeadBuf)[i];
        ++nBufLen;
    }
    
    std::vector<char>* verBuffer = response->getResponseData();
	for (unsigned int i = 0; i < verBuffer->size(); i++)
	{
		pBuffer[nBufLen+i] = (*verBuffer)[i];
        pBodyBuf[i] = (*verBuffer)[i];
	}
	
	SPacker* pPacker=new SPacker;
	if( pPacker != NULL )
	{
		pPacker->Push(pBuffer,strlen(pBuffer));
		if(OnRecode(pPacker,nMsgTag,nMsgType))
		{
			string strTemp=(const char*)pPacker->GetBuffer();
			int nPos=strTemp.find("\r\n\r\n");
			if(nPos!=-1)
			{
				nPos+=4;
				int nTempSize=pPacker->GetSize()-nPos;
				SPacker sTemp;
				sTemp.Push((char*)pBodyBuf,strlen(pBodyBuf));
				pPacker->Clear();
				*pPacker=sTemp;
			}

			INSTANCE(SMsgManager)->AddHttpMsg(pPacker,nMsgTag,nMsgType);
		}
        else
        {
			delete pPacker;
            INSTANCE(SMsgManager)->AddHttpFaild(nMsgTag,nMsgType);
        }
	}
    DelMsgType(nMsgTag);
	delete[] pBuffer;
    delete[] pBodyBuf;
}

bool Http::OnRecode(SPacker *pPacker,int nID,int nType)
{
	int dwDataSize=pPacker->GetSize();
	char  *pTotalBuffer=(char*)pPacker->GetBuffer();

	//解析
	char *p=strstr(pTotalBuffer,"Transfer-Encoding: chunked");
	if(p==NULL)	//要么是Content-length,要么结构还没传输过来
	{
		char *p1=strstr(pTotalBuffer,"Content-Length");
		if(p1==NULL)
			p1=strstr(pTotalBuffer,"content-length");
		if(p1)	//确定此http是Content-length结构
		{
			char *p2=strstr(p1,"\r\n\r\n");
			if(p2)	//结构头已经传输过来了
			{
				//得到理论数据长度
				p1+=strlen("Content-Length: ");
				string strTemp;
				while(*p1!='\r'&&*p1!=0)
				{
					strTemp+=*p1;
					++p1;
				}
				int nLength=atoi(strTemp.c_str());

				//得到实际数据长度
				p2+=strlen("\r\n\r\n");

				//百分百
				if(nLength!=0)
					INSTANCE(SMsgManager)->AddHttpPercent(nID,nType,(int)(((dwDataSize-((long long)p2-(long long)pTotalBuffer))*100)/nLength));

				if(dwDataSize-((long long)p2-(long long)pTotalBuffer)>=(int)nLength)	//所有数据已经传输过来了
				{
					return true;
				}
			}
		}
	}
	else //确定此http是chunked结构
	{
		char *p2=strstr(p,"\r\n\r\n");
		if(p2)	//结构头已经传输过来了
		{
			p2+=strlen("\r\n\r\n");

			//除去包头,数据长度
			int nTemp=dwDataSize-(p2-pTotalBuffer); //现在是头指针是p2,长度是nTemp
			while(IsFullTrunk(p2,nTemp))
			{
				if(IsEndTrunk(p2))
				{
					return true;
				}
				else
					JumpTrunk(p2,nTemp);
			}
		}
	}

	return false;
}

bool Http::IsFullTrunk(char *pBuffer,int nSize)
{
	if(nSize<=0)
		return false;
	if(pBuffer==NULL)
		return false;

	char *p1=strstr(pBuffer,"\r\n");
	if(p1==NULL)
		return false;
	int nTemp=p1-pBuffer+strlen("\r\n");

	//得到长度
	string strTemp;
	while(pBuffer!=p1)
	{
		strTemp+=*pBuffer;
		++pBuffer;
	}
	char *pRet=NULL;
	int nLength=(int)strtol(strTemp.c_str(),&pRet,16);

	return nSize>=nTemp+nLength+(int)strlen("\r\n");
}

bool Http::IsEndTrunk(char *pBuffer)
{
	char *p1=strstr(pBuffer,"\r\n");

	//得到长度
	string strTemp;
	while(pBuffer!=p1)
	{
		strTemp+=*pBuffer;
		++pBuffer;
	}
	char *pRet=NULL;
	int nLength=(int)strtol(strTemp.c_str(),&pRet,16);

	return nLength==0;
}

void Http::JumpTrunk(char* &pBuffer,int &nSize)
{
	char *p1=strstr(pBuffer,"\r\n");
	nSize=nSize-(p1-pBuffer);

	//得到长度
	string strTemp;
	while(pBuffer!=p1)
	{
		strTemp+=*pBuffer;
		++pBuffer;
	}
	char *pRet=NULL;
	int nLength=(int)strtol(strTemp.c_str(),&pRet,16);

	pBuffer=pBuffer+strlen("\r\n")+nLength+strlen("\r\n");
	nSize=nSize-strlen("\r\n")-nLength-strlen("\r\n");
}








