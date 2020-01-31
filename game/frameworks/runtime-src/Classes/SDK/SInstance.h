//跨平台
#pragma once
#define INSTANCE(CLASS) SSingleton<CLASS,-1>::Instance() 
#define MINSTANCE(CLASS,a) SSingleton<CLASS,a>::Instance() 

namespace SDK
{
//<SSingleton>---------------------------------------------------------------------------------------------------------
	template <typename T,int a>  
	class SSingleton  
	{  
	protected:  
		SSingleton(){}  
		virtual ~SSingleton()  
		{     
			if(m_instance)  
				delete m_instance;  
			m_instance = 0;  
		}  
	public:  
		static T* Instance()  
		{  
			static SSingleton<T,a> i;  
			if(i.m_instance==0)  
				i.m_instance=new T;     
			return i.m_instance;  
		}  
	private:  
		T   *m_instance;  
	};  
}