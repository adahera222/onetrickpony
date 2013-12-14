--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

dofile("game/lib_sdlkey.lua")
dofile("game/lib_draw.lua")

mat_prj_big = M.new()
mat_prj_small = M.new()
do
	local sw, sh = sys.get_screen_dims()
	M.scale(mat_prj_big, sh / sw, 1, 1)
	M.scale(mat_prj_small, 1, sw / sh, 1)
	if sw > sh then
		mat_prj_big, mat_prj_small = mat_prj_small, mat_prj_big
	end
end

function hook_key(sec_current, mod, key, state)
	--
end

function hook_click(sec_current, x, y, button, state)
	--
end

function hook_tick(sec_current, sec_delta)
	--
end

bl_star = D.polytrip(P.star(0, 0, 0.2, 0.1, 5), 0.03, 0.8, 0.8, 0, 1)
function hook_render(sec_current, sec_delta)
	--
	M.load_projection(mat_prj_small)

	GL.glClearColor(0, 0.5, 1, 1)
	GL.glClear(GL.COLOR_BUFFER_BIT)

	bl_star(1)
	bl_star(2)
	bl_star(3)
end

