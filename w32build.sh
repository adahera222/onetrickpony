#!/bin/sh

make CC=i686-pc-mingw32-gcc OBJDIR=build/win32 BINNAME=ld28-gm.exe \
	LIBS_SDL="-Lwinlibs -Lwinlibs/sdl2_lib -lmingw32 -lSDL2main -lSDL2" \
	CFLAGS_SDL="-Iwinlibs -Iwinlibs/sdl2_inc -Dmain=SDL_main" \
	LIBS_Lua="-llua" \
	LIBS_GL="-lopengl32 ./glew32.dll" \
	NO_JACK=1 \

