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
dofile("game/lib_cam.lua")
dofile("game/lib_font.lua")
dofile("game/lib_box.lua")
dofile("game/lib_face.lua")
dofile("game/lib_body.lua")
dofile("game/lib_pony.lua")

dofile("game/world.lua")

m_song1 = mus.load("dat/song1.it")
--mus.play(m_song1)

mat_iden = M.new()
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
	local tspd = (state and 7.0) or 0
	ch_main.tvs = 3.0
	if key == SDLK_a then ch_main.tvx = -tspd
	elseif key == SDLK_d then ch_main.tvx = tspd
	elseif key == SDLK_w then ch_main.tvy = tspd
	elseif key == SDLK_s then ch_main.tvy = -tspd
	end
	--[[
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
	]]
end

wpl = {}
wtl = {}
wbl = {}

function hook_click(sec_current, x, y, button, state)
	if button == 1 and state then
		x, y = cam_main.w2s(x, y)
		wpl[#wpl+1] = {x = x, y = y}
		if #wpl >= 1 then
			wbl = {}
			local pl = {}
			local j

			for j=1,#wpl do
				pl[#pl+1] = wpl[j].x
				pl[#pl+1] = wpl[j].y
			end
			
			-- I think my GPU drivers have a bug.
			-- Enabling this results in extraneous red lines.
			-- (I think the GPU assumes wireframe tri strip
			--  rather than line loop.)
			--[[
			pl[#pl+1] = wpl[1].x
			pl[#pl+1] = wpl[1].y
			]]

			local bl = blob.new(GL.LINE_LOOP, 2, pl)
			wbl[#wbl+1] = function ()
				blob.render(bl, 1, 0, 0, 1.0)
			end
		end
	elseif button == 3 and state then
		if #wpl >= 3 then
			wtl[#wtl+1] = W.meep(wpl)
		end
		wpl = {}
		wbl = {}
	end
end

function hook_tick(sec_current, sec_delta)
	local mx, my = sys.get_mouse()

	if mx ~= -1 then
		mx, my = cam_main.w2s(mx, my)
		ch_main.look(mx, my, 3)
	end

	ch_main.tick(sec_current, sec_delta)
	cam_main.follow = ch_main
	cam_main.tick(sec_current, sec_delta)

	local i
	for i=1,#boxes do
		boxes[i].tick(sec_current, sec_delta)
	end
	for i=1,#wtl do
		wtl[i].tick(sec_current, sec_delta)
	end
end

boxes = {}

--[=[
boxes[#boxes+1] = box_new {
s = [[This is a text box.
Stupid text box.]],
	x = -0.8,
	y = -1.2,
	size = 2/20,
	scale = 1,
}
]=]

wpy = pony_wood_new {}
cam_main = cam_new { x = 0, y = 0, zoom = 0.25 }
ch_main = D.body {
	r = 1, g = 0, b = 1,
}
function hook_render(sec_current, sec_delta)
	--
	M.load_projection(mat_prj_small)

	GL.glEnable(GL.STENCIL_TEST)
	GL.glClearColor(0, 0.5, 1, 1)
	GL.glClear(GL.COLOR_BUFFER_BIT + GL.STENCIL_BUFFER_BIT)
	GL.glStencilFunc(GL.ALWAYS, 0, 255)
	GL.glStencilOp(GL.KEEP, GL.KEEP, GL.KEEP)

	local mat_cam = cam_main.get_mat()

	local stage 
	for stage=1,3 do
		ch_main.draw(mat_cam, stage)
		wpy.draw(mat_cam, stage)

		local i
		for i=1,#wtl do
			wtl[i].draw(mat_cam, stage)
		end
	end
	for stage=1,3 do
		local i
		for i=1,#boxes do
			boxes[i].draw(mat_cam, stage)
		end
	end
	for stage=1,3 do
		local i
		M.load_modelview(mat_cam)
		for i=1,#wbl do
			wbl[i](stage)
		end
	end
	

	GL.glDisable(GL.STENCIL_TEST)
end

--print(string.split("butt", "t")[1])


