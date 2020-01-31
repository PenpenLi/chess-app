#include "../SBind.h"
using namespace SDK;

//<SBind>------------------------------------------------------------------------------------
#ifndef WIN32
bool        SBind::Bind(int nSocket,sockaddr *pAddr)
{
    if(bind(nSocket,pAddr,sizeof(sockaddr_in))==-1)
		return false;
    else
        return true;
}
#endif