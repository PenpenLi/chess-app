#pragma once
#include "SDK/SHead.h"
//#include "SDK/MyCrypt.h"
using namespace SDK;
#include "cocos2d.h"
using namespace cocos2d;

#define LANCHER		// mild lancher

//<MyUpdate>------------------------------------------------------------
class MyUpdate:public cocos2d::NetUpdate
{
public:
    MyUpdate();
public:
    virtual void Update();
};

#define SHOW(pStr) MyListener::__SHOW(pStr);
//<MyListener>----------------------------------------------------------------------------------
class MyListener:public SListener
{
public:
    void                Init(lua_State *L);
    void                Loop();
public://Server
	virtual void		OnServerRecv(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id);
	virtual void		OnServerConnect(SOCKETID id);
	virtual void		OnServerClose(SOCKETID id);
public://Client
	virtual void        OnClientRecv(unsigned int nProtocol,void *pBuffer,unsigned int nSize,void *pNet);
	virtual void		OnClientConnect(void *pNet);
	virtual void		OnClientFaild(void *pNet);
	virtual void		OnClientClose(void *pNet);

public:
	static int			Encrypt(lua_State *L);
public://SDK.lua
    static int          _Send(lua_State *L);
	static int          _Send1(lua_State *L);
	static int          _Send2(lua_State *L);
	static int          _Send3(lua_State *L);
    static int          Connect(lua_State *L);
	static int			IsConnect(lua_State *L);
	static int          Connect1(lua_State *L);
	static int			IsConnect1(lua_State *L);
	static int          Connect2(lua_State *L);
	static int			IsConnect2(lua_State *L);
	static int          Connect3(lua_State *L);
	static int			IsConnect3(lua_State *L);
	static int			CheckSafeConnect(lua_State *L);						//IP安全验证
    static int          Close(lua_State *L);
	static int          Close1(lua_State *L);
	static int          Close2(lua_State *L);
	static int          Close3(lua_State *L);

    static int          _Random_Int(lua_State *L);

	virtual void        OnGetIPTBEnd_Msg(string str);

public:// lua调用c++函数
	static int		   GetUsecTime(lua_State *L);
    static int         GetFormatTime(lua_State *L);
	static int         GetFormatTimeWithSecond(lua_State *L);
	static int		   GetFormatCountDownTime(lua_State *L);

	static int		   LockMsg(lua_State *L);
	static int		   UnlockMsg(lua_State *L);
	static int		   LockMsg2(lua_State *L);
	static int		   UnlockMsg2(lua_State *L);

	// ios支付专用
	static int		   SetIOSPayInfo(lua_State *L);

	static int		   GetDirAllFile(lua_State *L);

	// xxtea加解密
	static int			GetDecryptData(lua_State *L);
	static int			GetEncryptData(lua_State *L);

	static int			GetWinUuid(lua_State *L);
	static int			SetWinCopyStr(lua_State *L);
	static int			GetWinCopyStr(lua_State *L);
	static int		    OpenWinUrl(lua_State *L);
	static int			init_paths(lua_State *L);
	static int			get_paths(lua_State *L);	
private:
	SOCKETID			m_id;
};
