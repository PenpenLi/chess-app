#include "FishPathManager.h"
#include "cocos2d.h"
USING_NS_CC;
//////////////////////////////////////////////////////////////////////////

//#define MAX_SMALL_PATH				     209
#define PATH_TYPE_SMALL                    0
#define PATH_TYPE_BIG                      1
#define PATH_TYPE_HUGE                     2
#define PATH_TYPE_SPECIAL                  3
#define PATH_TYPE_SCENE                    4

#define MAX_SMALL_PATH				     209
#define MAX_BIG_PATH					 130
#define MAX_HUGE_PATH					 62
#define MAX_SPECIAL_PATH				 24
#define MAX_SCENE_PATH                    4


Path_Manager* Path_Manager::msInstance = 0;

Path_Manager* Path_Manager::shared()
{
	if (msInstance == 0)
	{
		msInstance = new Path_Manager();
	}

	return msInstance;
}


void Path_Manager::purge()
{
	if (msInstance)
		delete msInstance;
	msInstance = 0;
}

///////////////////////////////////////////////////////////////////////////
Path_Manager::Path_Manager()
{
}

Path_Manager::~Path_Manager()
{
	small_paths_.clear();
	big_paths_.clear();
	huge_paths_.clear();
	special_paths_.clear();
	scene_paths_.clear();
}

size_t Dntg_pfwrite(void* data, int elemsize, int count, std::string &sz_path)
{
	unsigned char dataa[1024];
	int size_byte = elemsize*count;

	unsigned char* src = (unsigned char*)data;
	unsigned char* dest = dataa;

	for (int i = 0; i < size_byte; i++)
		*(dest++) = (*src++) ^ 0xDE;

	dataa[size_byte] = '\0';
	sz_path += (char*)dataa;

	return size_byte;
}

bool Dntg_get_string_line(std::string& path, const std::string& all, unsigned int& start_pos)
{
	path.clear();
	int end_pos = 0;
	unsigned int n = all.length();

	if ((start_pos >= 0) && (start_pos < n))
	{
		end_pos = all.find_first_of("\n ", start_pos);

		if ((end_pos < 0) && (end_pos >n))
			end_pos = n;

		path += all.substr(start_pos, end_pos - start_pos);
		start_pos = end_pos + 1;

	}
	return !path.empty();
}

bool Dntg_path_load(std::vector<Move_Points>& paths, int count, const char* format)
{
	paths.clear();
	std::string sData;
	std::string line;

	for (int i = 0; i < count; i++)
	{

		char filename[128] = { 0 };

		sprintf(filename, format, i);
		//
		std::string filepath = CCFileUtils::sharedFileUtils()->fullPathForFilename(filename);
		if (filepath.size() < 2)
		{
			return false;
		}
		//
		ssize_t nread = 0;
		//
		unsigned char *rdata = CCFileUtils::sharedFileUtils()->getFileData(filepath.c_str(), "rb", &nread);
		if (nread <= 0 || rdata == 0)
			return false;

		//
		sData.clear();
		sData.resize(nread, 0);
		for (int i = 0; i < nread; i++)
			sData[i] = rdata[i] ^ 0xDE;
		delete[] rdata;

		//
		paths.push_back(Move_Points());
		Move_Points &move_points = paths[paths.size() - 1];

		//Ã¿ÐÐ¶ÁÈ¡
		unsigned int start_pos = 0;
		Dntg_get_string_line(line, sData, start_pos);

		while (Dntg_get_string_line(line, sData, start_pos))
		{
			int x, y, staff;
			float angle;
			//
			sscanf(line.c_str(), "(%d,%d,%f,%d)", &x, &y, &angle, &staff);
			//CCLOG("(%d,%d,%d,%d)", i, x, y, staff);
			move_points.push_back(Vec3(x, y, angle));
		}
	}

	return true;
}

bool Path_Manager::initialise_paths(const std::string &directory)
{
	std::string smallformat = StringUtils::format("%s%s", directory.c_str(), "/small/%d.dat");
	if (!Dntg_path_load(small_paths_, MAX_SMALL_PATH, smallformat.c_str()))
	{
		cocos2d::log("fail: initialise_paths: %d,%d", MAX_SMALL_PATH, small_paths_.size());
	}
	std::string bigformat = StringUtils::format("%s%s", directory.c_str(), "/big/%d.dat");
	if (!Dntg_path_load(big_paths_, MAX_BIG_PATH, bigformat.c_str()))
	{
		cocos2d::log("fail: initialise_paths: %d,%d", MAX_BIG_PATH, big_paths_.size());
	}
	std::string hugeformat = StringUtils::format("%s%s", directory.c_str(), "/huge/%d.dat");
	if (!Dntg_path_load(huge_paths_, MAX_HUGE_PATH, hugeformat.c_str()))
	{
		cocos2d::log("fail: initialise_paths: %d,%d", MAX_HUGE_PATH, huge_paths_.size());
	}
	std::string specialformat = StringUtils::format("%s%s", directory.c_str(), "/special/%d.dat");
	if (!Dntg_path_load(special_paths_, MAX_SPECIAL_PATH, specialformat.c_str()))
	{
		cocos2d::log("fail: initialise_paths: %d,%d", MAX_SPECIAL_PATH, special_paths_.size());
	}
	std::string sceneformat = StringUtils::format("%s%s", directory.c_str(), "/scene/%d.dat");
	if (!Dntg_path_load(scene_paths_, MAX_SCENE_PATH, sceneformat.c_str()))
	{
		cocos2d::log("fail: initialise_paths: %d,%d", MAX_SCENE_PATH, scene_paths_.size());
	}

	return true;
}

Move_Points &Path_Manager::get_paths(int path_id, int path_type)
{
	if (path_type == PATH_TYPE_SMALL)
	{
		if (path_id >= small_paths_.size())
			throw("get_paths small path_id too big");

		return small_paths_[path_id];
	}
	else if (path_type == PATH_TYPE_BIG)
	{
		if (path_id >= big_paths_.size())
			throw("get_paths big path_id too big");

		return big_paths_[path_id];
	}
	else if (path_type == PATH_TYPE_HUGE)
	{
		if (path_id >= huge_paths_.size())
			throw("get_paths huge path_id too big");

		return huge_paths_[path_id];
	}
	else if (path_type == PATH_TYPE_SPECIAL)
	{
		if (path_id >= special_paths_.size())
			throw("get_paths special path_id too big");

		return special_paths_[path_id];
	}
	else
	{
		if (path_id >= scene_paths_.size())
			throw("get_paths scene path_id too big");

		return scene_paths_[path_id];
	}
}


///////////////////////////////////////////////////////////////////////////
