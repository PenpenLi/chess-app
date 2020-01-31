#ifndef __Dntg_PATH_MANAGER_H__
#define __Dntg_PATH_MANAGER_H__

///////////////////////////////////////////////////////////////////////////////////////////
#include "cocos2d.h"
USING_NS_CC;

	typedef std::vector<Vec3> Move_Points;

	///////////////////////////////////////////////////////////////////////////////////////////
	class Path_Manager
	{
	private:
		static Path_Manager* msInstance;
	public:
		static Path_Manager* shared();
		static void purge();

	public:
		Move_Points &get_paths(int path_id, int path_type);

		bool initialise_paths(const std::string &directory);
    public:
		Path_Manager();
		~Path_Manager();

	private:
		std::vector<Move_Points> small_paths_;
		std::vector<Move_Points> big_paths_;
		std::vector<Move_Points> huge_paths_;
		std::vector<Move_Points> special_paths_;
		std::vector<Move_Points> scene_paths_;
	};


///////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////

#endif