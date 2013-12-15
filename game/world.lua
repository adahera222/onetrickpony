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

local function is_concave(x0, y0, x1, y1, x2, y2)
	local xr = -(y2-y1)
	local yr = (x2-x1)

	return xr*(x1-x0) + yr*(y1-y0) < 0
end

local function is_concave_at(l, offs)
	local i0 = (offs - 1) % #l
	local i2 = (offs + 1) % #l
	local i1 = offs % #l

	local p0 = l[i0 + 1]
	local p1 = l[i1 + 1]
	local p2 = l[i2 + 1]

	return is_concave(
		p0.x, p0.y,
		p1.x, p1.y,
		p2.x, p2.y)
end

W = {}

function W.convexify(l, b)
	local i, offs

	b = b or {}

	-- screw this, i'm going to use 0-based indexing
	offs = 0
	-- find a concave point followed by a convex point
	while offs < #l do
		if is_concave_at(l, offs) and not is_concave_at(l, offs + 1) then
			-- build up a list until we either:
			-- 1. hit a concave point, or
			-- 2. become concave again
			local nl = {l[offs+1]}
			local noffs = offs + 1
			nl[#nl+1] = l[(noffs % #l) + 1]
			noffs = noffs + 1
			while true do
				-- concave point
				if is_concave_at(l, noffs) then break end

				nl[#nl+1] = l[(noffs % #l) + 1]

				-- point becomes concave
				if is_concave_at(nl, 0) then
					nl[#nl] = nil
					break
				end

				-- none of those happened? advance!
				noffs = noffs + 1
			end

			-- split it off
			noffs = noffs - 1
			local nl2 = {l[(noffs % #l)+1]}
			while (noffs % #l) ~= (offs % #l) do
				noffs = noffs + 1
				nl2[#nl2+1] = l[(noffs % #l)]
			end
			noffs = noffs + 1
			nl2[#nl2+1] = l[(noffs % #l)]

			-- convexify the parts
			print("ls", #nl, #nl2)
			--b = {nl, nl2} return b
			return W.convexify(nl2, W.convexify(nl, b))
		else
			offs = offs + 1
		end
	end

	-- if the whole poly is concave, give up
	-- if the whole poly is convex, there's nothing to do
	b[#b+1] = l
	return b
end

