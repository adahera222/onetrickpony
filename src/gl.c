/*
Boilerplate 28: GreaseMonkey's boilerplate code for Ludum Dare #28
2013, Ben "GreaseMonkey" Russell - Public Domain
*/

#include "common.h"

#define WRF_1I(name) \
	int lf_##name(lua_State *L) \
	{ \
		GLint i1 = lua_tointeger(L, 1); \
		name(i1); \
		return 0; \
	}

#define WRF_3I(name) \
	int lf_##name(lua_State *L) \
	{ \
		GLint i1 = lua_tointeger(L, 1); \
		GLint i2 = lua_tointeger(L, 2); \
		GLint i3 = lua_tointeger(L, 3); \
		name(i1, i2, i3); \
		return 0; \
	}

#define WRF_4D(name) \
	int lf_##name(lua_State *L) \
	{ \
		GLdouble d1 = lua_tonumber(L, 1); \
		GLdouble d2 = lua_tonumber(L, 2); \
		GLdouble d3 = lua_tonumber(L, 3); \
		GLdouble d4 = lua_tonumber(L, 4); \
		name(d1, d2, d3, d4); \
		return 0; \
	}

WRF_1I(glClear)
WRF_4D(glClearColor)
WRF_3I(glStencilOp)
WRF_3I(glStencilFunc)
WRF_1I(glEnable)
WRF_1I(glDisable)

void load_gl_lua_state(lua_State *L)
{
	// load constants
	lua_pushinteger(L, GL_DEPTH_BUFFER_BIT); lua_setfield(L, -2, "DEPTH_BUFFER_BIT");
	lua_pushinteger(L, GL_ACCUM_BUFFER_BIT); lua_setfield(L, -2, "ACCUM_BUFFER_BIT");
	lua_pushinteger(L, GL_STENCIL_BUFFER_BIT); lua_setfield(L, -2, "STENCIL_BUFFER_BIT");
	lua_pushinteger(L, GL_COLOR_BUFFER_BIT); lua_setfield(L, -2, "COLOR_BUFFER_BIT");

	lua_pushinteger(L, GL_POINTS); lua_setfield(L, -2, "POINTS");
	lua_pushinteger(L, GL_LINES); lua_setfield(L, -2, "LINES");
	lua_pushinteger(L, GL_LINE_LOOP); lua_setfield(L, -2, "LINE_LOOP");
	lua_pushinteger(L, GL_LINE_STRIP); lua_setfield(L, -2, "LINE_STRIP");
	lua_pushinteger(L, GL_TRIANGLES); lua_setfield(L, -2, "TRIANGLES");
	lua_pushinteger(L, GL_TRIANGLE_STRIP); lua_setfield(L, -2, "TRIANGLE_STRIP");
	lua_pushinteger(L, GL_TRIANGLE_FAN); lua_setfield(L, -2, "TRIANGLE_FAN");
	lua_pushinteger(L, GL_QUADS); lua_setfield(L, -2, "QUADS");
	lua_pushinteger(L, GL_QUAD_STRIP); lua_setfield(L, -2, "QUAD_STRIP");
	lua_pushinteger(L, GL_POLYGON); lua_setfield(L, -2, "POLYGON");

	lua_pushinteger(L, GL_NEVER); lua_setfield(L, -2, "NEVER");
	lua_pushinteger(L, GL_LESS); lua_setfield(L, -2, "LESS");
	lua_pushinteger(L, GL_LEQUAL); lua_setfield(L, -2, "LEQUAL");
	lua_pushinteger(L, GL_GREATER); lua_setfield(L, -2, "GREATER");
	lua_pushinteger(L, GL_GEQUAL); lua_setfield(L, -2, "GEQUAL");
	lua_pushinteger(L, GL_EQUAL); lua_setfield(L, -2, "EQUAL");
	lua_pushinteger(L, GL_NOTEQUAL); lua_setfield(L, -2, "NOTEQUAL");
	lua_pushinteger(L, GL_ALWAYS); lua_setfield(L, -2, "ALWAYS");

	lua_pushinteger(L, GL_STENCIL_TEST); lua_setfield(L, -2, "STENCIL_TEST");

	lua_pushinteger(L, GL_KEEP); lua_setfield(L, -2, "KEEP");
	lua_pushinteger(L, GL_ZERO); lua_setfield(L, -2, "ZERO");
	lua_pushinteger(L, GL_REPLACE); lua_setfield(L, -2, "REPLACE");
	lua_pushinteger(L, GL_INCR); lua_setfield(L, -2, "INCR");
	lua_pushinteger(L, GL_DECR); lua_setfield(L, -2, "DECR");
	lua_pushinteger(L, GL_INVERT); lua_setfield(L, -2, "INVERT");

	// load functions
	lua_pushcfunction(L, lf_glClearColor); lua_setfield(L, -2, "glClearColor");
	lua_pushcfunction(L, lf_glClear); lua_setfield(L, -2, "glClear");
	lua_pushcfunction(L, lf_glStencilOp); lua_setfield(L, -2, "glStencilOp");
	lua_pushcfunction(L, lf_glStencilFunc); lua_setfield(L, -2, "glStencilFunc");
	lua_pushcfunction(L, lf_glEnable); lua_setfield(L, -2, "glEnable");
	lua_pushcfunction(L, lf_glDisable); lua_setfield(L, -2, "glDisable");
}

