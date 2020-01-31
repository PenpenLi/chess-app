#include "../SInit.h"
#include "../SConfig.h"
#include "../STools.h"
using namespace SDK;

//<SInit>----------------------------------------------------------------------------------------------------------
SInit::SInit()
{
#ifdef WIN32
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2,2),&wsaData);
	//Random_Init;
#else

#endif

	//Random_Init;

    m_pSend=new char[MAX_SIZE];
}
SInit::~SInit()
{
#ifdef WIN32
	WSACleanup();
#endif

    delete[] m_pSend;
	m_pSend=NULL;
}
char*						SInit::GetBuffer()
{
    return m_pSend;
}