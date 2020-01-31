#pragma once

namespace SDK
{
	//<SPacker>-------------------------------------------------------------------------------------
	class SPacker
	{
	public:
		SPacker();
		~SPacker();
		SPacker(const SPacker& pack);
		SPacker operator=(const SPacker& pack);
	public:
		void			SetProtocol(unsigned int nProtocol);
		void			Push(void *pBuffer,unsigned int nLen);
		void			Clear();
	public:
		void*			GetBuffer()const;
		unsigned int	GetSize()const;
		unsigned int	GetProtocol()const;
	private:
		char			*m_pBuffer;
		unsigned int	m_nCurrentSize;
		unsigned int	m_nProtocol;
	};
}