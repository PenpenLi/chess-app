#include "lua_FishPathManager.hpp"
#include "FishPathManager.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"

static int init_paths(lua_State* L)
{
	bool isSuc = Path_Manager::shared()->initialise_paths(luaL_checkstring(L, 1));
	return 1;
}

static int get_paths(lua_State* L)
{
	std::vector<Vec3> &path = Path_Manager::shared()->get_paths(luaL_checknumber(L, 1), luaL_checknumber(L, 2));
	std_vector_vec3_to_luaval(L, path);
    return 1;
}


static const struct luaL_reg pathLib[] =
{
	{ "init_paths", init_paths },
	{ "get_paths", get_paths },
	{ NULL, NULL }
};

int luaopen_fpm(lua_State *L)
{
	lua_newtable(L);
	luaL_register(L, NULL, pathLib);
 //   lua_newtable(L);
 //   lua_pushliteral(L, "get_paths");
	//lua_pushcfunction(L, get_paths);
 //   lua_settable(L, -3);
    return 1;
}
