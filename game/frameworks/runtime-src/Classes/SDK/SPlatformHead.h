#pragma once

//std
#include <vector>
#include <string>
#include <map>
#include <list>
#include <queue>
#include <set>
#include <stack>
#include <algorithm>
#include <cmath>
#include <iostream>  
#include <time.h>
using namespace std;

#ifdef _WIN32
	#include <WinSock2.h>
	#include <Windows.h>
	#include <process.h>
	#include <mstcpip.h>
	#include <WS2tcpip.h>
	#pragma comment(lib,"WS2_32.lib")
	#pragma comment(lib,"Winmm.lib")
	#define Def_Sleep(t) Sleep(t)
#else
	#include <pthread.h>
	//#include <iostream>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <sys/time.h>
	#include <sys/stat.h>
    #include <arpa/inet.h>
	#include <unistd.h>
	#include <fcntl.h>
    #include <netinet/in.h>
    #include <netinet/tcp.h>
    
    #include <errno.h>
	#include <Netdb.h>
	#include <stdio.h>	
	#include <stdlib.h>
	#include <netdb.h>
	#define Def_Sleep(t) usleep(t)
#endif