--[[
One Trick Pony
Copyright (C) 2013 Ben "GreaseMonkey" Russell

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
]]

function string.split(s, c)
	local l = {}

	while true do
		local t = s:find(c)
		if not t then break end
		l[#l+1] = s:sub(1,t-1)
		s = s:sub(t+#c)
	end

	l[#l+1] = s

	return l
end

dofile("game/lib_sdlkey.lua")
dofile("game/lib_time.lua")
dofile("game/lib_draw.lua")
dofile("game/lib_font.lua")
dofile("game/lib_box.lua")
dofile("game/lib_face.lua")
dofile("game/lib_pony.lua")

m_7th = mus.load("dat/7th.it")
mus.play(m_7th)

mat_iden = M.new()
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
	if state then
		if key == SDLK_n then
			ch_main.blink_target = 0.9
			ch_main.eye_tilt_target = 0
		elseif key == SDLK_g then
			ch_main.blink_target = 1.5
			ch_main.eye_tilt_target = 0
		elseif key == SDLK_a then
			ch_main.blink_target = 0.6
			ch_main.eye_tilt_target = -0.3
		elseif key == SDLK_h then
			ch_main.blink_target = 0.9
			ch_main.eye_tilt_target = 0.2
		elseif key == SDLK_s then
			ch_main.blink_target = 0.3
			ch_main.eye_tilt_target = 0.1
		elseif key == SDLK_c then
			ch_main.blink_target = 0.2
			ch_main.eye_tilt_target = -0.1
		elseif key == SDLK_t then
			ch_main.blink_target = 0.3
			ch_main.eye_tilt_target = 0.03
		elseif key == SDLK_p then
			ch_main.blink_target = 0.6
			ch_main.eye_tilt_target = 0.2
		end
	end
end

function hook_click(sec_current, x, y, button, state)
	--
end

function hook_tick(sec_current, sec_delta)
	local sw, sh = sys.get_screen_dims()
	local mx, my = sys.get_mouse()
	mx = (mx*2 - sw) / sh
	my = (my*2 - sh) / sh
	my = -my

	ch_main.tick(sec_current, sec_delta)
	ch_main.look(mx*0.3, my*0.3)
end

box_a = box_new {
s = [[So if I beat you up,
do I become the chief maid?]],
	x = -0.8,
	y = -0.5,
}

wpy = pony_wood_new {}
ch_main = D.face {}
function hook_render(sec_current, sec_delta)
	--
	M.load_projection(mat_prj_small)

	GL.glEnable(GL.STENCIL_TEST)
	GL.glClearColor(0, 0.5, 1, 1)
	GL.glClear(GL.COLOR_BUFFER_BIT + GL.STENCIL_BUFFER_BIT)
	GL.glStencilFunc(GL.ALWAYS, 0, 255)
	GL.glStencilOp(GL.KEEP, GL.KEEP, GL.KEEP)

	local stage 
	for stage=1,2 do
		M.identity(mat_cam)
		ch_main.draw(mat_cam, stage)
		wpy.draw(mat_cam, stage)
	end
	for stage=1,2 do
		box_a.draw(mat_cam, stage)
	end

	GL.glDisable(GL.STENCIL_TEST)
end

--print(string.split("butt", "t")[1])


