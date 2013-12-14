--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

dofile("game/lib_sdlkey.lua")
dofile("game/lib_draw.lua")
dofile("game/lib_face.lua")

mat_cam = M.new()
M.translate(mat_cam, 0, 0, -1)
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

ch_main = D.face {}
function hook_render(sec_current, sec_delta)
	--
	M.load_projection(mat_prj_small)

	GL.glClearColor(0, 0.5, 1, 1)
	GL.glClear(GL.COLOR_BUFFER_BIT)

	local stage 
	for stage=1,3 do
		ch_main.draw(mat_cam, stage)
	end
end

