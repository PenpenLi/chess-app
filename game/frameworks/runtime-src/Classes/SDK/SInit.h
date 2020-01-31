#pragma once
#include "SPlatformHead.h"

namespace SDK
{
//<SInit>------------------------------------------------------------------------------------
	class SInit
	{
	public:
		SInit();
		~SInit();
    public:
        char*						GetBuffer();
    private:
        char						*m_pSend;				//发送缓存
	};
}