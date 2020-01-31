#pragma once
#ifndef __LUA_FPM_HPP__
#define __LUA_FPM_HPP__

#if __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"


int luaopen_fpm(lua_State *L);

#if __cplusplus
}
#endif




#endif
