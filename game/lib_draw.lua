--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
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
		local dx, dy = norm(x - cx, y - cy)
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
			ret(2)
			return ret(3)
		else
			return plist[pi](...)
		end
	end

	return ret
end


