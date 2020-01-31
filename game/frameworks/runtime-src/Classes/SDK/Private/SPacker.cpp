#include "../SPacker.h"
#include "../SConfig.h"
#include <string>
using namespace SDK;

//<SPacker>-------------------------------------------------------------------------------------
SPacker::SPacker()
{
	m_pBuffer=NULL;
	m_nCurrentSize=0;
	m_nProtocol=0;
}
SPacker::~SPacker()
{
	Clear();
}
SPacker::SPacker(const SPacker& pack)
{
	m_nCurrentSize=pack.m_nCurrentSize;
	m_nProtocol=pack.m_nProtocol;

	if(m_nCurrentSize>BUFFER_SIZE)
	{
		m_pBuffer=new char[m_nCurrentSize];
	}
	else
	{
		m_pBuffer=new char[BUFFER_SIZE];
		memset(m_pBuffer+m_nCurrentSize,0,BUFFER_SIZE-m_nCurrentSize);
	}
	memcpy(m_pBuffer,pack.m_pBuffer,m_nCurrentSize);
}
SPacker			SPacker::operator=(const SPacker& pack)
{
	Clear();
	m_nCurrentSize=pack.m_nCurrentSize;
	m_nProtocol=pack.m_nProtocol;

	if(m_nCurrentSize>BUFFER_SIZE)
	{
		m_pBuffer=new char[m_nCurrentSize];
	}
	else
	{
		m_pBuffer=new char[BUFFER_SIZE];
		memset(m_pBuffer+m_nCurrentSize,0,BUFFER_SIZE-m_nCurrentSize);
	}
	memcpy(m_pBuffer,pack.m_pBuffer,m_nCurrentSize);

	return *this;
}
void			SPacker::SetProtocol(unsigned int nProtocol)
{
	m_nProtocol=nProtocol;
}
void			SPacker::Push(void *pBuffer,unsigned int nLen)
{
	if(pBuffer==NULL)
		return;
	if(nLen==0)
		return;

	if(m_nCurrentSize+nLen>BUFFER_SIZE)
	{
		char *pTemp=new char[m_nCurrentSize+nLen];
		memcpy(pTemp,m_pBuffer,m_nCurrentSize);
		memcpy(pTemp+m_nCurrentSize,pBuffer,nLen);
		if(m_pBuffer)
			delete[] m_pBuffer;
		m_pBuffer=pTemp;
		m_nCurrentSize+=nLen;
	}
	else
	{
		if(m_pBuffer==NULL)
		{
			m_pBuffer=new char[BUFFER_SIZE];
			memset(m_pBuffer+nLen,0,BUFFER_SIZE-nLen);
		}

		memcpy(m_pBuffer+m_nCurrentSize,pBuffer,nLen);
		m_nCurrentSize+=nLen;
	}
}
void*			SPacker::GetBuffer()const
{
	return m_pBuffer;
}
unsigned int	SPacker::GetSize()const
{
	return m_nCurrentSize;
}
unsigned int	SPacker::GetProtocol()const
{
	return m_nProtocol;
}
void			SPacker::Clear()
{
	if(m_pBuffer)
		delete[] m_pBuffer;
	m_pBuffer=NULL;
	m_nCurrentSize=0;
	m_nProtocol=0;
}