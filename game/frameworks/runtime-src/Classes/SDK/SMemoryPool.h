#pragma once
#include "SPlatformHead.h"
#include "SPlatform.h"

//<宏定义>-----------------------------------------------------------------------------------------
#define MEMORY_POOL_INC_SIZE	1*1024*1024							//增量大小
#define MEMORY_POOL_NODE_NUM	257									//节点个数
#define MEMORY_POOL_MULTIPLIER	32									//倍率,必须为4的整倍数
#define MEMORY_POOL_INIT		SDK::SMemoryPool::GetInstance();

namespace SDK
{	
//<SMemoryNode>------------------------------------------------------------------------------------
	class SMemoryNode
	{
	public:
		SMemoryNode();
	public:
		void*					Alloc();							//分配偏移了指针加索引后的指针
		void					Free(void *pMemory);				//释放偏移了指针加索引后的指针
	private:
		void*					m_pHead;							//存储Buffer最开始
		SLock					m_lock;
	};
//<SMemoryPool>------------------------------------------------------------------------------------
	class SMemoryPool
	{
	private:
		SMemoryPool();
	public:
		static SMemoryPool*		GetInstance();
	public:
		void*					Alloc(unsigned int nSize);
		void					Free(void *pMemory);
	private:
		char					*m_pCurrentMemory;					//当前还没用完的内存块
		unsigned int			m_nSize;							//当前还没用完的内存块的大小
		SMemoryNode				m_pNodeArray[MEMORY_POOL_NODE_NUM];	//SMemoryNode节点数组
		SLock					m_lock;
		static SMemoryPool		*m_pSMemory;
	};
}