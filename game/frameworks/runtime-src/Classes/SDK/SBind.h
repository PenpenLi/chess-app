#pragma once

#ifndef WIN32
    #include <pthread.h>
    #include <iostream>
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <arpa/inet.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <netinet/in.h>
    #include <netinet/tcp.h>
    #include <sys/time.h>
#endif

namespace SDK
{
//<SBind>----------------------------------------------------------------------------------
#ifndef WIN32
    class SBind
    {
    public:
        static bool            Bind(int nSocket,sockaddr *pAddr);
    };
#endif
}
