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

function norm(x, y)
	local d = math.sqrt(x*x + y*y)
	return x/d, y/d
end

-- polygon generators
P = {}
function P.ellipse(cx, cy, rx, ry, points)
	local a = 0
	local ai = math.pi * 2 / points
	local l = {}

	local i
	for i=1,points*2-1,2 do
		l[i+0] = cx + rx * math.sin(a)
		l[i+1] = cy + ry * math.cos(a)
		a = a + ai
	end

	return l
end

function P.poly(cx, cy, r, ang, points)
	local a = ang
	local ai = math.pi * 2 / points
	local l = {}

	local i
	for i=1,points*2-1,2 do
		l[i+0] = cx + r * math.sin(a)
		l[i+1] = cy + r * math.cos(a)
		a = a + ai
	end

	return l
end

function P.star(cx, cy, r1, r2, points)
	points = points * 2
	local a = 0
	local ai = math.pi * 2 / points
	local l = {}

	local i
	for i=1,points*2-1,2 do
		l[i+0] = cx + r1 * math.sin(a)
		l[i+1] = cy + r1 * math.cos(a)
		r1, r2 = r2, r1
		a = a + ai
	end

	return l
end

function P.roundrect(x1, y1, x2, y2, outs, points)
	local l = {}
	local i
	for i=0,points-1 do
		local a = (math.pi / 2) * (i/(points-1))
		local x, y = math.sin(a)*outs, math.cos(a)*outs
		l[2*(i + points*0) + 1] = x2 + x
		l[2*(i + points*0) + 2] = y1 + y
		l[2*(i + points*1) + 1] = x2 + y
		l[2*(i + points*1) + 2] = y2 - x
		l[2*(i + points*2) + 1] = x1 - x
		l[2*(i + points*2) + 2] = y2 - y
		l[2*(i + points*3) + 1] = x1 - y
		l[2*(i + points*3) + 2] = y1 + x
	end
	print(l[1],l[2],l[3],l[4],l[5],l[6])

	return l
end

function P.outset(sl, amt)
	local l = {}

	-- Get centre
	local cx, cy = 0, 0
	for i=1,#sl-1,2 do
		cx = cx + sl[i+0]
		cy = cy + sl[i+1]
	end

	cx = cx/(#sl/2)
	cy = cy/(#sl/2)

	local i
	for i=1,#sl-1,2 do
		local x, y = sl[i+0], sl[i+1]
		local ax, ay = sl[((i-2)-1)%#sl+1], sl[((i-1)-1)%#sl+1]
		local bx, by = sl[((i+2)-1)%#sl+1], sl[((i+3)-1)%#sl+1]
		-- And that is exactly why 1-based arrays are stupid.

		-- Get deltas
		ax, ay = norm(ax - x, ay - y)
		bx, by = norm(bx - x, by - y)

		-- Get angle
		local dc = (ax*bx + ay*by)
		local da = math.acos(dc) / 2 -- We are *bisecting* this angle.

		-- Get direction + length
		local dcx, dcy = norm(x - cx, y - cy)
		local dx, dy = norm(ax + bx, ay + by)
		if dcx*dx + dcy*dy < 0 then
			dx, dy = -dx, -dy
		end
		local d = amt / math.sin(da)

		-- Add to our list
		l[i+0] = x + dx*d
		l[i+1] = y + dy*d
	end

	return l
end

function P.inset(sl, amt)
	return P.outset(sl, -amt)
end

-- drawing generators
D = {}
function D.poly(sl, sr, sg, sb, sa)
	sr = sr or 1
	sg = sg or 1
	sb = sb or 1
	sa = sa or 1

	-- add a few entries
	local l = {}
	local i
	local cx, cy = 0, 0
	for i=1,#sl-1,2 do
		cx = cx + sl[i+0]
		cy = cy + sl[i+1]
		l[i+2] = sl[i+0]
		l[i+3] = sl[i+1]
	end

	l[1] = cx/(#sl/2)
	l[2] = cy/(#sl/2)
	l[#sl+3] = sl[1]
	l[#sl+4] = sl[2]

	local bl = blob.new(GL.TRIANGLE_FAN, 2, l)

	return function(r, g, b, a)
		r = r or 1
		g = g or 1
		b = b or 1
		a = a or 1

		return blob.render(bl, sr*r, sg*g, sb*b, sa*a)
	end
end

function D.polytrip(l, offs, r, g, b, a)
	local li = 0.3

	r = r or 1
	g = g or 1
	b = b or 1
	a = a or 1

	local plist = {
		D.poly(P.outset(l, offs), 0, 0, 0, a),
		D.poly(l, r, g, b, a),
		D.poly(P.inset(l, offs), r + li, g + li, b + li, a),
	}

	local ret
	ret = function(pi, ...)
		if pi == nil then
			ret(1)
			return ret(2)
		elseif pi == 1 then
			return plist[1](...)
		elseif pi == 2 then
			plist[2](...)
			return plist[3](...)
		end
	end

	return ret
end


