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

-- points go CLOCKWISE
-- (but of course convexify gives no shits about this)
local function dir_at(l, offs)
	local i0 = (offs + 0) % #l + 1
	local i1 = (offs + 1) % #l + 1
	return l[i1].x - l[i0].x,
		l[i1].y - l[i0].y
end

local function normal_at(l, offs)
	local xr, yr = dir_at(l, offs)
	xr, yr = -yr, xr
	return xr, yr
end

W = {}

local function convexify_main(l, offs, b)
	local i, offs

	-- screw this, i'm going to use 0-based indexing
	offs = 0

	-- get directions 
	local dx0, dy0 = norm(dir_at(l, offs - 1))
	local dx1, dy1 = norm(dir_at(l, offs))
	dx1, dy1 = -dx1, -dy1

	-- get cosine of angle between
	local dot_wnd = dx0*dx1 + dy0*dy1
	local dot_prog = 1

	-- build new list
	local nl = {}
	local o2 = offs
	local pb = l[(offs % #l) + 1]
	while true do
		-- store point and advance
		nl[#nl+1] = l[o2]
		o2 = o2 + 1

		-- if we've come full circle, just use our list
		if o2 == offs + #l then
			b[#b+1] = l
			return b
		end

		-- get the actual point + offset from our base point
		local p2 = l[(o2 % #l) + 1]
		local px, py = norm(p2.x - pb.x, p2.y - pb.y)
		local dot_d2 = px*dx0, py*dy0

		-- angle got smaller OR angle exceeded max
		if dot_d2 > dot_prog or dot_d2 <= dot_wnd then
			if o2 - offs == 2 then
				-- make sure we get at least a triangle
				offs = offs - 1
				nl[#nl+1] = l[(offs % #l) + 1]
			end
			b[#b+1] = nl

			-- build second list
			nl = {}
			while o2 ~= offs + #l + 1 do
				nl[#nl+1] = l[(o2 % #l) + 1]
				o2 = o2 + 1
			end

			return convexify_main(nl, 0, b)
		end

		-- ensure monotoneness
		dot_prog = dot_d2
	end
end

function W.convexify_fails(l)
	-- find a convex point
	for i=0,#l-1 do
		local nx, ny = normal_at(l, i-1)
		local dx, dy = dir_at(l, i)
		if nx*dx + ny*dy < 0 then
			-- convex! let's roll.
			return convexify_main(l, i, {})
		end

		-- otherwise, concave.
	end

	-- no convex points? return nothing.
	return {}
	--return {l}
end

function W.convexify(l)
	-- Too much effort.
	-- Just make sure everything is convex, mmkay?
	return {l}
end

function W.base(l)
	local this = {}

	-- Calculate centre + point list
	do
		local cx, cy = 0, 0
		local i
		local pl = {}
		local pb = {}

		for i=1,#l do
			cx = cx + l[i].x
			cy = cy + l[i].y
			pl[#pl+1] = {x = l[i].x, y = l[i].y}
			pb[#pb+1] = l[i].x
			pb[#pb+1] = l[i].y
		end

		cx, cy = cx/#l, cy/#l
		this.cx = cx
		this.cy = cy
		this.point_blob = pb
		this.point_list = pl

		local al = {}
		for i=1,#l do
			al[i] = math.atan2(l[i].y - cy, l[i].x - cx)
		end
		this.angle_list = al
	end

	this.poly_list = {}
	
	function this.draw(gmat, stage)
		local i
		M.load_modelview(gmat)
		for i=1,#this.poly_list do
			this.poly_list[i](stage)
		end
	end

	function this.tick(sec_current, sec_delta)
	end

	return this
end

function W.meep(l)
	local this = W.base(l)

	this.poly_list[#this.poly_list + 1] = D.polytrip3(
		this.point_blob, 0.03,
		0, 1, 0, 1)

	function this.tick(sec_current, sec_delta)
	end

	return this
end
