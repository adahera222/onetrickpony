--[[
LD28 game without a name atm
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

dofile("game/lib_sdlkey.lua")

function hook_key(sec_current, mod, key, state)
	--
end

function hook_click(sec_current, x, y, button, state)
	--
end

function hook_tick(sec_current, sec_delta)
	--
end

function hook_render(sec_current, sec_delta)
	--
	GL.glClearColor(0, 0, 0, 1)
	GL.glClear(GL.COLOR_BUFFER_BIT)
end

