#include "../SFile.h"
using namespace SDK;
#pragma warning(disable:4996)

//<SFile>------------------------------------------------------------------------------------------------------------
string		SFile::GetPath()
{
	char szBuf[500+1]={0};
	getcwd(szBuf,500);
	char *p=szBuf;
	while(*p!=0)
	{
		if(*p=='\\')
			*p='/';
		++p;
	}
	return string(szBuf);
}
int			SFile::GetFileSize(const char *pFile)
{
	if(pFile==NULL)
		SERROR("SFile::GetFileSize 参数错误:pFile==NULL");

	FILE *p=fopen(pFile,"rb");
	if(p==NULL)
		return 0;
	fseek(p,0,SEEK_END);
	int nSize=ftell(p);
	fclose(p);
	return nSize;
}
int			SFile::ReadFile(const char *pFile,void *pBuffer,unsigned int nSize)
{
	if(pFile==NULL)
		SERROR("SFile::ReadFile 参数错误:pFile==NULL");
	if(pBuffer==NULL)
		SERROR("SFile::ReadFile 参数错误:pBuffer==NULL");
	if(nSize==0)
		SERROR("SFile::ReadFile 参数错误:nSize==NULL");

	FILE *p=fopen(pFile,"rb");
	if(p==NULL)
		return 0;
	fseek(p,0,SEEK_END);
	unsigned int nFileSize=ftell(p);
	if(nFileSize==0)
	{
		fclose(p);
		return 0;
	}
	if(nFileSize>nSize)
		SERROR("SFile::ReadFile 错误:nFileSize>nSize");

	fseek(p,0,SEEK_SET);
	fread(pBuffer,nFileSize,1,p);
	fclose(p);
	return nFileSize;
}
void		SFile::Create(const char *pFile,void *pBuffer/*=NULL*/,unsigned int nSize/*=0*/)
{
	if(pFile==NULL)
		SERROR("SFile::Create 参数错误:pFile==NULL");
	if((nSize>0)&&(pBuffer==NULL))
		SERROR("SFile::Create 参数错误:(nSize>0)&&(pBuffer==NULL)");

	FILE *p=fopen(pFile,"wb");
	if(p==NULL)
		return;
	if(pBuffer!=NULL&&nSize>0)
		fwrite(pBuffer,nSize,1,p);
	fclose(p);
}
void		SFile::CreateFolder(const char *pFile)
{
	if(pFile==NULL)
		SERROR("SFile::CreateFolder 参数错误:pFile==NULL");

	string str=pFile;
	int nPos=str.find("/");
	while(nPos!=-1)
	{
		string sub=str.substr(0,nPos);
#ifdef _WIN32
		mkdir(sub.c_str());
#else
		mkdir(sub.c_str(),S_IRWXU|S_IRWXG|S_IRWXO);
#endif
		nPos=str.find("/",nPos+1);
	}
#ifdef _WIN32
	mkdir(pFile);
#else
	mkdir(pFile,S_IRWXU|S_IRWXG|S_IRWXO);
#endif
}
void		SFile::Delete(const char *pFile)
{
	if(pFile==NULL)
		SERROR("SFile::Delete 参数错误:pFile==NULL");

#ifdef _WIN32
	SHFILEOPSTRUCTA FileOp={0}; 
	FileOp.fFlags=
		FOF_NOCONFIRMATION|			//不出现确认对话框
		FOF_NOERRORUI|				//出错不出现错误对话框
		FOF_SILENT;					//不显示进度对话框
	FileOp.pFrom=pFile; 
	FileOp.pTo=NULL;				
	FileOp.wFunc=FO_DELETE;			//删除操作
	SHFileOperationA(&FileOp);
#else
	struct stat s;
	lstat(pFile,&s);
	if(s.st_mode&S_IFDIR)
	{
		//删除所有子文件
		vector<string> v=GetAllFile(pFile);
		for(unsigned int i=0;i<v.size();++i)
			remove(v[i].c_str());

		//删除所有子文件夹
		v=GetAllFolder(pFile);
		for(vector<string>::reverse_iterator it=v.rbegin();it!=v.rend();++it)
			remove(it->c_str());
	}

	remove(pFile);
#endif
}
vector<string>	SFile::GetAllFile(const char*pFile,const char *pSuffix/*=NULL*/)
{
	if(pFile==NULL)
		SERROR("SFile::GetAllFile 参数错误:pFile==NULL");

#ifdef _WIN32
	vector<string> vReturn;
	vector<string> vSubPath;	//存储子路径

	string str=pFile;
	str+="/*.*";
	WIN32_FIND_DATAA st;
	ZeroMemory(&st,sizeof(st));
	HANDLE hFind = FindFirstFileA(str.c_str(),&st);
	if(hFind==INVALID_HANDLE_VALUE)
		return vReturn;

	BOOL bFind=true;
	while(bFind)
	{
		if(strcmp(st.cFileName,".")!=0&&strcmp(st.cFileName,"..")!=0)
		{
			string strTemp;
			if(st.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)
			{
				strTemp=pFile;
				strTemp+="/";
				strTemp+=st.cFileName;
				vSubPath.push_back(strTemp);
			}
			else
			{
				if(pSuffix==NULL)
				{
					strTemp=pFile;
					strTemp+="/";
					strTemp+=st.cFileName;
					vReturn.push_back(strTemp);
				}
				else
				{
					strTemp=st.cFileName;
					int nPos=strTemp.rfind(pSuffix);
					if(nPos!=-1)
					{
						if(nPos+strlen(pSuffix)==strTemp.length())
						{
							strTemp=pFile;
							strTemp+="/";
							strTemp+=st.cFileName;
							vReturn.push_back(strTemp);
						}
					}
				}
			}
		}
		bFind=FindNextFileA(hFind,&st);
	}
	FindClose(hFind);

	//查找子路径
	for(unsigned int i=0;i<vSubPath.size();++i)
	{
		vector<string> vTemp=GetAllFile(vSubPath[i].c_str(),pSuffix);
		vReturn.insert(vReturn.end(),vTemp.begin(),vTemp.end());
	}

	return vReturn;
#else
	vector<string> vReturn;
	vector<string> vSubPath;	//存储子路径

	DIR *pDir=opendir(pFile);
	if(pDir==NULL)
		return vReturn;
	dirent *p=readdir(pDir);
    struct stat s;
	while(p)
	{
		if(strcmp(p->d_name,".")!=0&&strcmp(p->d_name,"..")!=0)
		{
			string strTemp;
            strTemp=pFile;
            strTemp+="/";
            strTemp+=p->d_name;
            
            lstat(strTemp.c_str(),&s);
			if(s.st_mode&S_IFDIR)
			{
				vSubPath.push_back(strTemp);
			}
			else
			{
				if(pSuffix==NULL)
				{
					vReturn.push_back(strTemp);
				}
				else
				{
					strTemp=p->d_name;
					int nPos=strTemp.rfind(pSuffix);
					if(nPos!=-1)
					{
						if(nPos+strlen(pSuffix)==strTemp.length())
						{
							strTemp=pFile;
							strTemp+="/";
							strTemp+=p->d_name;
							vReturn.push_back(strTemp);
						}
					}
				}
			}
		}
		p=readdir(pDir);
	}
	closedir(pDir);

	//查找子路径
	for(unsigned int i=0;i<vSubPath.size();++i)
	{
		vector<string> vTemp=GetAllFile(vSubPath[i].c_str(),pSuffix);
		vReturn.insert(vReturn.end(),vTemp.begin(),vTemp.end());
	}

	return vReturn;
#endif
}
vector<string>	SFile::GetAllFolder(const char*pFile)
{
	if(pFile==NULL)
		SERROR("SFile::GetAllFolder 参数错误:pFile==NULL");

#ifdef _WIN32
	vector<string> vReturn;
	vector<string> vSubPath;	//存储子路径

	string str=pFile;
	str+="/*.*";
	WIN32_FIND_DATAA st;
	ZeroMemory(&st,sizeof(st));
	HANDLE hFind = FindFirstFileA(str.c_str(),&st);
	if(hFind==INVALID_HANDLE_VALUE)
		return vReturn;

	BOOL bFind=true;
	while(bFind)
	{
		if(strcmp(st.cFileName,".")!=0&&strcmp(st.cFileName,"..")!=0)
		{
			if(st.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)
			{
				string strTemp=pFile;
				strTemp+="/";
				strTemp+=st.cFileName;
				vReturn.push_back(strTemp);
			}
		}
		bFind=FindNextFileA(hFind,&st);
	}
	FindClose(hFind);

	//查找子路径
	vSubPath=vReturn;
	for(unsigned int i=0;i<vSubPath.size();++i)
	{
		vector<string> vTemp=GetAllFolder(vSubPath[i].c_str());
		vReturn.insert(vReturn.end(),vTemp.begin(),vTemp.end());
	}

	return vReturn;
#else
	vector<string> vReturn;
	vector<string> vSubPath;	//存储子路径

	DIR *pDir=opendir(pFile);
	if(pDir==NULL)
		return vReturn;
	dirent *p=readdir(pDir);
    struct stat s;
	while(p)
	{
		if(strcmp(p->d_name,".")!=0&&strcmp(p->d_name,"..")!=0)
		{
            string strTemp=pFile;
            strTemp+="/";
            strTemp+=p->d_name;
            
            lstat(strTemp.c_str(),&s);
			if(s.st_mode&S_IFDIR)
			{
				vReturn.push_back(strTemp);
			}
		}
		p=readdir(pDir);
	}
	closedir(pDir);

	//查找子路径
	vSubPath=vReturn;
	for(unsigned int i=0;i<vSubPath.size();++i)
	{
		vector<string> vTemp=GetAllFolder(vSubPath[i].c_str());
		vReturn.insert(vReturn.end(),vTemp.begin(),vTemp.end());
	}

	return vReturn;
#endif
}
vector<string>	SFile::GetFirstFolder(const char*pFile)
{
	if(pFile==NULL)
		SERROR("SFile::GetFirstFolder 参数错误:pFile==NULL");

#ifdef _WIN32
	vector<string> vReturn;

	string str=pFile;
	str+="/*.*";
	WIN32_FIND_DATAA st;
	ZeroMemory(&st,sizeof(st));
	HANDLE hFind = FindFirstFileA(str.c_str(),&st);
	if(hFind==INVALID_HANDLE_VALUE)
		return vReturn;

	BOOL bFind=true;
	while(bFind)
	{
		if(strcmp(st.cFileName,".")!=0&&strcmp(st.cFileName,"..")!=0)
		{
			if(st.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)
			{
				string strTemp=pFile;
				strTemp+="/";
				strTemp+=st.cFileName;
				vReturn.push_back(strTemp);
			}
		}
		bFind=FindNextFileA(hFind,&st);
	}
	FindClose(hFind);

	return vReturn;
#else
	vector<string> vReturn;

	DIR *pDir=opendir(pFile);
	if(pDir==NULL)
		return vReturn;
	dirent *p=readdir(pDir);
    struct stat s;
	while(p)
	{
		if(strcmp(p->d_name,".")!=0&&strcmp(p->d_name,"..")!=0)
		{
            string strTemp=pFile;
            strTemp+="/";
            strTemp+=p->d_name;
            
            lstat(strTemp.c_str(),&s);
			if(s.st_mode&S_IFDIR)
			{
				vReturn.push_back(strTemp);
			}
		}
		p=readdir(pDir);
	}
	closedir(pDir);

	return vReturn;
#endif
}