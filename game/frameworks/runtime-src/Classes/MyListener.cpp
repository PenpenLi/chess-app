#include "MyListener.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "CallLuaFunction.h"
#include "external/xxtea/xxtea.h"
#include "SDK/Byte2hex.h"
#include "SDK/FishPath/FishPathManager.h"

#ifndef WIN32
#include <dlfcn.h>
#endif
#ifdef WIN32
#include <iostream>
#include <fstream>
#include "SStringConverter.h"
#endif

//extern "C" int detect();

//<MyUpdate>------------------------------------------------------------
MyUpdate::MyUpdate()
{
	Director::getInstance()->NetUpdateHandler = this;
}

void MyUpdate::Update()
{
    INSTANCE(MyListener)->Loop();
}



//<MyListener>----------------------------------------------------------------------------------
#include "cocos2d.h"
void MyListener::Init(lua_State *L)
{
    CCLOG("MyListener::Init");
    //初始化
	INSTANCE(SLoop)->Register(this);
	INSTANCE(MyUpdate);

	m_id = 0;

    //初始化Lua
    INSTANCE(SLua)->SetLuaState(L);

	/*auto platform = CCApplication::getInstance()->getTargetPlatform();
    string sdkPath ="";
	if (platform == ApplicationProtocol::Platform::OS_ANDROID)
		sdkPath=FileUtils::getInstance()->fullPathForFilename("game/Pt/PtScripts/PtCore");
	else
		sdkPath=FileUtils::getInstance()->fullPathForFilename("src/game/Pt/PtScripts/PtCore");
    CCLOG("%s",sdkPath.c_str());
    auto pos = sdkPath.find("/path.data");
    sdkPath = sdkPath.substr(0,pos);

    CCLOG("MyListener::Init(lua_State *L)");
    CCLOG("%s",sdkPath.c_str());

    INSTANCE(SLua)->LoadFolderByFullPath(sdkPath.c_str());*/

	//加密
	INSTANCE(SLua)->Register("Encrypt",(lua_CFunction)&Encrypt);

    //SDK.lua
    INSTANCE(SLua)->Register("_Send",(lua_CFunction)&_Send);
	INSTANCE(SLua)->Register("_Send1",(lua_CFunction)&_Send1);
	INSTANCE(SLua)->Register("_Send2",(lua_CFunction)&_Send2);
	INSTANCE(SLua)->Register("_Send3",(lua_CFunction)&_Send3);

    INSTANCE(SLua)->Register("Connect",(lua_CFunction)&Connect);
	INSTANCE(SLua)->Register("Connect1",(lua_CFunction)&Connect1);
	INSTANCE(SLua)->Register("Connect2",(lua_CFunction)&Connect2);
	INSTANCE(SLua)->Register("Connect3",(lua_CFunction)&Connect3);

	INSTANCE(SLua)->Register("IsConnect",(lua_CFunction)&IsConnect);
	INSTANCE(SLua)->Register("IsConnect1",(lua_CFunction)&IsConnect1);
	INSTANCE(SLua)->Register("IsConnect2",(lua_CFunction)&IsConnect2);
	INSTANCE(SLua)->Register("IsConnect3",(lua_CFunction)&IsConnect3);
	 
	INSTANCE(SLua)->Register("CheckSafeConnect",(lua_CFunction)&CheckSafeConnect);//IP安全验证

    INSTANCE(SLua)->Register("_Close",(lua_CFunction)&Close);
	INSTANCE(SLua)->Register("_Close1",(lua_CFunction)&Close1);
	INSTANCE(SLua)->Register("_Close2",(lua_CFunction)&Close2);
	INSTANCE(SLua)->Register("_Close3",(lua_CFunction)&Close3);

    INSTANCE(SLua)->Register("Random_Int",(lua_CFunction)&_Random_Int);

	INSTANCE(SLua)->Register("GetUsecTime",(lua_CFunction)&GetUsecTime);
    INSTANCE(SLua)->Register("GetFormatTime",(lua_CFunction)&GetFormatTime);
	INSTANCE(SLua)->Register("GetFormatTimeWithSecond",(lua_CFunction)&GetFormatTimeWithSecond);
	INSTANCE(SLua)->Register("GetFormatCountDownTime",(lua_CFunction)&GetFormatCountDownTime);

	INSTANCE(SLua)->Register("LockMsg",(lua_CFunction)&LockMsg);
	INSTANCE(SLua)->Register("UnlockMsg",(lua_CFunction)&UnlockMsg);
	INSTANCE(SLua)->Register("LockMsg2",(lua_CFunction)&LockMsg2);
	INSTANCE(SLua)->Register("UnlockMsg2",(lua_CFunction)&UnlockMsg2);

	INSTANCE(SLua)->Register("SetIOSPayInfo", (lua_CFunction)&SetIOSPayInfo);
	INSTANCE(SLua)->Register("GetDirAllFile", (lua_CFunction)&GetDirAllFile);

	INSTANCE(SLua)->Register("GetDecryptData", (lua_CFunction)&GetDecryptData);
	INSTANCE(SLua)->Register("GetEncryptData", (lua_CFunction)&GetEncryptData);


	INSTANCE(SLua)->Register("GetWinUuid", (lua_CFunction)&GetWinUuid);
	INSTANCE(SLua)->Register("SetWinCopy", (lua_CFunction)&SetWinCopyStr);
	INSTANCE(SLua)->Register("GetWinCopy", (lua_CFunction)&GetWinCopyStr);
	INSTANCE(SLua)->Register("OpenWinUrl", (lua_CFunction)&OpenWinUrl);
	INSTANCE(SLua)->Register("init_paths", (lua_CFunction)&init_paths);
	INSTANCE(SLua)->Register("get_paths", (lua_CFunction)&get_paths);
}

// ios支付专用
int MyListener::SetIOSPayInfo(lua_State *L)
{
	vector<SVar> v = INSTANCE(SLua)->Get();
	string strIP = v[0].ToString();
	int nPort = v[1].ToNumber<int>();
	string pageName = v[2].ToString();
	INSTANCE(CallLuaFunction)->SetIOSPayInfo(strIP, nPort, pageName);
	return 1;
}


int MyListener::GetDirAllFile(lua_State *L)
{
	//指定目录下的所有指定文件
	vector<SVar> v=INSTANCE(SLua)->Get();
	if (v.size()<=0)return 0;

	string strPath = v[0].ToString();		//路径
	string strFileEx = v[1].ToString();		//文件格式
	vector<string> vFile = SFile::GetAllFile(strPath.c_str(),strFileEx.c_str());
	string str;
	for(unsigned int i = 0;i<vFile.size();i++)
	{
		INSTANCE(SLua)->Push(vFile[i]);
	}
	return vFile.size();

}
void MyListener::Loop()
{
    INSTANCE(SLoop)->Loop();
}

int MyListener::Encrypt(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();

	string str=v[0].ToString();
	int nSize=str.length();
	STools::Simple_Encrypt((byte*)str.c_str(),nSize);

	string strxx=SBase64::Encrypt((byte*)str.c_str(),nSize);
	INSTANCE(SLua)->Push(strxx.c_str());

	return 1;
}
void MyListener::OnServerRecv(unsigned int nProtocol,void *pBuffer,unsigned int nSize,SOCKETID id)
{
	SVar s;
	if(pBuffer!=NULL&&nSize>0)
		s["data"]=SBase64::Encrypt((byte*)pBuffer,nSize);

	nProtocol+=(5<<16);
	MINSTANCE(Client,1)->Send(nProtocol,&s);
}
void MyListener::OnServerConnect(SOCKETID id)
{
	m_id = id;

	INSTANCE(SLua)->InitFun("OnServerConnect");
	INSTANCE(SLua)->ExecFun(0);
}
void MyListener::OnServerClose(SOCKETID id)
{
	m_id = 0;

	INSTANCE(SLua)->InitFun("OnServerClose");
	INSTANCE(SLua)->ExecFun(0);
}
void MyListener::OnClientRecv(unsigned int nProtocol,void *pBuffer,unsigned int nSize,void *pNet)
{
	unsigned int nFirstProtocol=nProtocol>>16;
    unsigned int nSecondProtocol=(nProtocol<<16)>>16;

    SVar s;
	SSerialize::ToSVar(s,(unsigned char*)pBuffer,nSize);

	INSTANCE(SLua)->InitFun("OnRecv");
	INSTANCE(SLua)->Push(nFirstProtocol);
	INSTANCE(SLua)->Push(nSecondProtocol);

	int nConnectID = 0; //连接ID，告诉Lua是哪个连接得到的收到的消息
	if (pNet == INSTANCE(Client))
		nConnectID = 0;
	else if (pNet == MINSTANCE(Client, 1))
		nConnectID = 1;
	else if (pNet == MINSTANCE(Client, 2))
		nConnectID = 2;
	else if (pNet == MINSTANCE(Client, 3))
		nConnectID = 3;
	INSTANCE(SLua)->Push(nConnectID);

	if (s.IsEmpty() == false)
		INSTANCE(SLua)->Push(s);
	INSTANCE(SLua)->ExecFun(0);
}
void MyListener::OnClientConnect(void *pNet)
{
    if(pNet==INSTANCE(Client))
    {
        INSTANCE(SLua)->InitFun("OnClientConnect");
    }
	else if(pNet==MINSTANCE(Client,1))
	{
		INSTANCE(SLua)->InitFun("OnClientConnect1");
	}
    else if(pNet==MINSTANCE(Client,2))
    {
        INSTANCE(SLua)->InitFun("OnClientConnect2");
    }
	else if(pNet==MINSTANCE(Client,3))
	{
		INSTANCE(SLua)->InitFun("OnClientConnect3");
	}

    INSTANCE(SLua)->ExecFun(0);
}
void MyListener::OnClientFaild(void *pNet)
{
    if(pNet==INSTANCE(Client))
    {
        INSTANCE(SLua)->InitFun("OnClientFaild");
    }
	else if(pNet==MINSTANCE(Client,1))
	{
		INSTANCE(SLua)->InitFun("OnClientFaild1");
	}
    else if(pNet==MINSTANCE(Client,2))
    {
        INSTANCE(SLua)->InitFun("OnClientFaild2");
    }
	else if(pNet==MINSTANCE(Client,3))
	{
		INSTANCE(SLua)->InitFun("OnClientFaild3");
	}

    INSTANCE(SLua)->ExecFun(0);
}
void MyListener::OnClientClose(void *pNet)
{
    if(pNet==INSTANCE(Client))
    {
        INSTANCE(SLua)->InitFun("OnClientClose");
    }
	else if(pNet==MINSTANCE(Client,1))
	{
		INSTANCE(SLua)->InitFun("OnClientClose1");
	}
    else if(pNet==MINSTANCE(Client,2))
    {
        INSTANCE(SLua)->InitFun("OnClientClose2");
    }
	else if(pNet==MINSTANCE(Client,3))
	{
		INSTANCE(SLua)->InitFun("OnClientClose3");
	}

    INSTANCE(SLua)->ExecFun(0);
}
//SDK.lua
int MyListener::_Send(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
    unsigned int nProtocol=((v[0].ToNumber<unsigned int>())<<16)+v[1].ToNumber<unsigned int>();
    INSTANCE(Client)->Send(nProtocol,&(v[2]));
    return 0;
}
int MyListener::_Send1(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
	unsigned int nProtocol=((v[0].ToNumber<unsigned int>())<<16)+v[1].ToNumber<unsigned int>();
	MINSTANCE(Client,1)->Send(nProtocol,&(v[2]));
	return 0;
}
int MyListener::_Send2(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
	unsigned int nProtocol=((v[0].ToNumber<unsigned int>())<<16)+v[1].ToNumber<unsigned int>();
	MINSTANCE(Client,2)->Send(nProtocol,&(v[2]));
	return 0;
}
int MyListener::_Send3(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
	unsigned int nProtocol=((v[0].ToNumber<unsigned int>())<<16)+v[1].ToNumber<unsigned int>();
	SVar &s = v[2];
	bool b =false;
	if (s.Find("presented"))
	{
		b = true;
	}
	MINSTANCE(Client,3)->Send(nProtocol,&(v[2]));
	if (b)
	{
		return 0;
	}
}

int MyListener::Connect(lua_State *L)
{
    vector<SVar> v=INSTANCE(SLua)->Get();
	CCLOG("client begin");
    INSTANCE(Client)->Connect(v[0].ToString().c_str(),v[1].ToNumber<unsigned int>());
	CCLOG("client %s:%d=%d",v[0].ToString().c_str(),v[1].ToNumber<unsigned int>(),INSTANCE(Client)->m_socket.m_nSocket);

    return 0;
}
int	MyListener::IsConnect(lua_State *L)
{
	bool  bConnect = INSTANCE(Client)->IsConnect();
	INSTANCE(SLua)->Push(bConnect);
	return 1;
}
int	MyListener::IsConnect1(lua_State *L)
{
	bool  bConnect = MINSTANCE(Client,1)->IsConnect();
	INSTANCE(SLua)->Push(bConnect);
	return 1;
}

int	MyListener::IsConnect2(lua_State *L)
	{
	bool  bConnect = MINSTANCE(Client,2)->IsConnect();
	INSTANCE(SLua)->Push(bConnect);
	return 1;
}
int	MyListener::IsConnect3(lua_State *L)
{
	bool  bConnect = MINSTANCE(Client,3)->IsConnect();
	INSTANCE(SLua)->Push(bConnect);
	return 1;
}
int MyListener::CheckSafeConnect(lua_State *L)
{//IP安全验证 //0验证成功 1验证失败 2服务未开启 3验证返回超时
	vector<SVar> v=INSTANCE(SLua)->Get();
	int  nRe = -1;
	if (v.size()==2)
	{
		string strIP = v[0].ToString();
		int	nPort	 = v[1].ToNumber< int>();
		CheckClient check;
		int  nRe = check.safeconnectex(strIP.c_str(),nPort,time(NULL));
		INSTANCE(SLua)->Push(nRe);
	}
	return 1;
}
int MyListener::Close(lua_State *L)
{
	CCLOG("client %d",INSTANCE(Client)->m_socket.m_nSocket);
    INSTANCE(Client)->Close();
    return 0;
}
int MyListener::Connect1(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
	CCLOG("client1 begin");
	MINSTANCE(Client,1)->Connect(v[0].ToString().c_str(),v[1].ToNumber<unsigned int>());
	CCLOG("client1 %s:%d=%d",v[0].ToString().c_str(),v[1].ToNumber<unsigned int>(),MINSTANCE(Client,1)->m_socket.m_nSocket);
	return 0;
}
int MyListener::Connect2(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
		CCLOG("client2 begin");
	MINSTANCE(Client,2)->Connect(v[0].ToString().c_str(),v[1].ToNumber<unsigned int>());
	CCLOG("client2 %s:%d=%d",v[0].ToString().c_str(),v[1].ToNumber<unsigned int>(),MINSTANCE(Client,2)->m_socket.m_nSocket);
	return 0;
}
int MyListener::Connect3(lua_State *L)
{
	vector<SVar> v=INSTANCE(SLua)->Get();
	CCLOG("client3 begin");
	MINSTANCE(Client,3)->Connect(v[0].ToString().c_str(),v[1].ToNumber<unsigned int>());
	CCLOG("client3 %s:%d=%d",v[0].ToString().c_str(),v[1].ToNumber<unsigned int>(),MINSTANCE(Client,3)->m_socket.m_nSocket);
	return 0;
}
int MyListener::Close1(lua_State *L)
{
	CCLOG("client1 %d",MINSTANCE(Client,1)->m_socket.m_nSocket);
	MINSTANCE(Client,1)->Close();
	return 0;
}
int MyListener::Close2(lua_State *L)
{
	CCLOG("client2 %d",MINSTANCE(Client,2)->m_socket.m_nSocket);
	MINSTANCE(Client,2)->Close();
	return 0;
}
int MyListener::Close3(lua_State *L)
{
	CCLOG("client3 %d",MINSTANCE(Client,3)->m_socket.m_nSocket);
	MINSTANCE(Client,3)->Close();
	return 0;
}


#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/CCCommon.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

int MyListener::_Random_Int(lua_State *L)
{
    vector<SVar> v=INSTANCE(SLua)->Get();
    INSTANCE(SLua)->Push(Random_Int(v[0].ToNumber<int>(),v[1].ToNumber<int>()));
    return 0;
}

void MyListener::OnGetIPTBEnd_Msg(string str)
{
	INSTANCE(CallLuaFunction)->SendGetIPTBSuccess(str);
}

int MyListener::GetUsecTime(lua_State *L)
{
	string timeString = INSTANCE(CallLuaFunction)->GetUsecTime();
    INSTANCE(SLua)->Push(timeString);
    return 1;
}

// 获取格式化时间
int MyListener::GetFormatTime(lua_State *L)
{
    vector<SVar> v=INSTANCE(SLua)->Get();
    time_t time = v[0].ToNumber<time_t>();
    string timeString = INSTANCE(CallLuaFunction)->GetFormatTime(time);
    INSTANCE(SLua)->Push(timeString);
    return 1;
}
int MyListener::GetFormatTimeWithSecond(lua_State *L)
{
    vector<SVar> v=INSTANCE(SLua)->Get();
    time_t time = v[0].ToNumber<time_t>();
    string timeString = INSTANCE(CallLuaFunction)->GetFormatTimeWithSecond(time);
    INSTANCE(SLua)->Push(timeString);
    return 1;
}
// 获取倒计时时间格式
int MyListener::GetFormatCountDownTime(lua_State *L)
{
    vector<SVar> v=INSTANCE(SLua)->Get();
    time_t time = v[0].ToNumber<time_t>();
    string timeString = INSTANCE(CallLuaFunction)->GetFormatCountDownTime(time);
    INSTANCE(SLua)->Push(timeString);
    return 1;
}

int MyListener::LockMsg(lua_State *L)
{
	INSTANCE(SLoop)->LockMsg1(true);
	return 0;
}
int MyListener::UnlockMsg(lua_State *L)
{
	INSTANCE(SLoop)->LockMsg1(false);
	return 0;
}
int MyListener::LockMsg2(lua_State *L)
{
	INSTANCE(SLoop)->LockMsg2(true);
	return 0;
}
int MyListener::UnlockMsg2(lua_State *L)
{
	INSTANCE(SLoop)->LockMsg2(false);
	return 0;
}

int MyListener::GetEncryptData(lua_State *L)
{
	vector<SVar> v = INSTANCE(SLua)->Get();
	string strKey = v[0].ToString();
	string strData = v[1].ToString();

	unsigned char* pSrcData = new unsigned char[strData.length()+1];
	memcpy(pSrcData,  strData.c_str(), strData.length());
	pSrcData[strData.length()] = 0;

	unsigned char* pSrcKey = new unsigned char[strKey.length()+1];
	memcpy(pSrcKey,  strKey.c_str(), strKey.length());
	pSrcKey[strKey.length()] = 0;

	// xxtea_encrypt(unsigned char *data, xxtea_long data_len, unsigned char *key, xxtea_long key_len, xxtea_long *ret_length)
	xxtea_long nResLen = 0;
	unsigned char* pEncryptData = xxtea_encrypt(pSrcData, strData.length(), pSrcKey, strKey.length(), &nResLen);

	int datalen = nResLen * 2 +1;
	char* pEncryptData2 = new char[datalen];
	int len = byte2hex(pEncryptData, nResLen, pEncryptData2, datalen);
	 
	//printf(pEncryptData2);
	INSTANCE(SLua)->Push((const char*)pEncryptData2);
	delete [] pSrcData;
	delete [] pSrcKey;
	free(pEncryptData);
	return 1;
}

int MyListener::GetDecryptData(lua_State *L)
{
	vector<SVar> v = INSTANCE(SLua)->Get();
	string strKey = v[0].ToString();
	string strData = v[1].ToString();
	int datalen = strData.length() / 2;
	unsigned char* pSrcData = new unsigned char[datalen + 1];
	int len = hex2byte(strData.c_str(), pSrcData, datalen);

	pSrcData[datalen] = 0;

	unsigned char* pSrcKey = new unsigned char[strKey.length()+1];
	memcpy(pSrcKey, strKey.c_str(), strKey.length());
	pSrcKey[strKey.length()] = 0;

	// xxtea_encrypt(unsigned char *data, xxtea_long data_len, unsigned char *key, xxtea_long key_len, xxtea_long *ret_length)
	xxtea_long nResLen = 0;
	unsigned char* pDecryptData = xxtea_decrypt(pSrcData, datalen, pSrcKey, strKey.length(), &nResLen);

	//printf((const char*)pDecryptData);
	INSTANCE(SLua)->Push((const char*)pDecryptData);

	delete pSrcData;
	delete pSrcKey;
	free(pDecryptData);
	return 1;
}

// 获取硬盘序列号
int MyListener::GetWinUuid(lua_State *L)
{
	string uuid = "";
	int ret = INSTANCE(CallLuaFunction)->GetWinUuid(uuid);
	INSTANCE(SLua)->Push(uuid);
	return 1;
}

int MyListener::SetWinCopyStr(lua_State *L)
{
	vector<SVar> v = INSTANCE(SLua)->Get();
	string str = v[0].ToString();
	INSTANCE(CallLuaFunction)->SetWinCopyStr(str);
	return 0;
}

int MyListener::GetWinCopyStr(lua_State *L)
{
	string str = "";
	str = INSTANCE(CallLuaFunction)->GetWinCopyStr();
	INSTANCE(SLua)->Push(str);
	return 1;
}

int MyListener::OpenWinUrl(lua_State *L)
{
	vector<SVar> v = INSTANCE(SLua)->Get();
	string str = v[0].ToString();
	INSTANCE(CallLuaFunction)->OpenWinUrl(str);
	return 0;
}

int MyListener::init_paths(lua_State* L)
{
	bool isSuc = Path_Manager::shared()->initialise_paths(luaL_checkstring(L, 1));
	return 1;
}

int MyListener::get_paths(lua_State* L)
{
	std::vector<Vec3> &path = Path_Manager::shared()->get_paths(luaL_checknumber(L, 1), luaL_checknumber(L, 2));
	std_vector_vec3_to_luaval(L, path);
	return 1;
}