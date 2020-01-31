#include "../SMemoryPool.h"
using namespace SDK;

//<SMemoryNode>------------------------------------------------------------------------------
SMemoryNode::SMemoryNode()
{
	m_pHead=NULL;
}
void*			SMemoryNode::Alloc()
{
	m_lock.Enter();
	if(m_pHead==NULL)
	{
		m_lock.Leave();
		return NULL;
	}

	void *pMemory=(char*)m_pHead+12;
	m_pHead=(void*)(*((long long*)m_pHead));

	m_lock.Leave();
	return pMemory;
}
void			SMemoryNode::Free(void *pMemory)
{
	m_lock.Enter();
	pMemory=(char*)pMemory-12;
	if(m_pHead==NULL)
	{
		*((long long*)pMemory)=0;
		m_pHead=pMemory;
	}
	else
	{
		*((long long*)pMemory)=(long long)m_pHead;
		m_pHead=pMemory;
	}
	m_lock.Leave();
}
//<SMemoryPool>----------------------------------------------------------------------------------
SMemoryPool*	SMemoryPool::m_pSMemory=NULL;
SMemoryPool::SMemoryPool()
{
	m_pCurrentMemory=NULL;
	m_nSize=0;
}
SMemoryPool*	SMemoryPool::GetInstance()
{
	if(m_pSMemory==NULL)
	{
		m_pSMemory=(SMemoryPool*)malloc(sizeof(SMemoryPool));
		::new(m_pSMemory)SMemoryPool;
	}

	return m_pSMemory;
}
void*		SMemoryPool::Alloc(unsigned int nSize)
{
	if(nSize==0)
		return NULL;

	nSize+=1;	//让每一个分配的内存块都有一个0结尾,屏蔽上层字符串读脏数据BUG
	unsigned int nIndex=nSize/MEMORY_POOL_MULTIPLIER;
	if(nSize%MEMORY_POOL_MULTIPLIER==0)
		nIndex--;

	if(nIndex>=MEMORY_POOL_NODE_NUM)
	{
		void *p=malloc(nSize+4);
		memset(p,0,nSize+4);
		*((unsigned int*)p)=MEMORY_POOL_NODE_NUM;
		return (char*)p+4;
	}

	void *p=m_pNodeArray[nIndex].Alloc();
	if(p==NULL)
	{
		m_lock.Enter();

		nSize=12+(nIndex+1)*MEMORY_POOL_MULTIPLIER;
		if(m_nSize<nSize)
		{
			//看剩余内存能不能回收
			if(m_nSize>=(12+MEMORY_POOL_MULTIPLIER))
			{
				unsigned int nTempIndex=(m_nSize-12)/MEMORY_POOL_MULTIPLIER-1;

				m_pCurrentMemory+=12;
				*((unsigned int*)m_pCurrentMemory-1)=nTempIndex;
				m_pNodeArray[nTempIndex].Free(m_pCurrentMemory);
			}

			m_pCurrentMemory=(char*)malloc(MEMORY_POOL_INC_SIZE);
			memset(m_pCurrentMemory,0,MEMORY_POOL_INC_SIZE);
			m_nSize=MEMORY_POOL_INC_SIZE;
		}
		p=(char*)m_pCurrentMemory+12;
		m_pCurrentMemory+=nSize;
		m_nSize-=nSize;
		*((unsigned int*)p-1)=nIndex;

		m_lock.Leave();
	}
	return p;
}
void		SMemoryPool::Free(void *pMemory)
{
	if(pMemory==NULL)
		return;

	unsigned int nIndex=*((unsigned int*)pMemory-1);	
	if(nIndex==MEMORY_POOL_NODE_NUM)
	{
		free(((unsigned int*)pMemory-1));
		return;
	}
	memset(pMemory,0,(nIndex+1)*MEMORY_POOL_MULTIPLIER);
	m_pNodeArray[nIndex].Free(pMemory);
}
//<全局重载>---------------------------------------------------------------------------------------
//void*	operator new(size_t size)
//{
//	return SDK::SMemoryPool::GetInstance()->Alloc(size);
//}
//void*	operator new[](size_t size)
//{
//	return SDK::SMemoryPool::GetInstance()->Alloc(size);
//}
//void	operator delete(void *p)
//{
//	SDK::SMemoryPool::GetInstance()->Free(p);
//}
//void	operator delete[](void *p)
//{
//	SDK::SMemoryPool::GetInstance()->Free(p);
//}
