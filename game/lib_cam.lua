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

function cam_new(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		zoom = settings.zoom or 1,
		follow = settings.follow,
	}

	local lmat = M.new()
	function this.get_mat()
		M.identity(lmat)
		local zoom = this.zoom
		M.translate(lmat, -this.x, -this.y, -1)
		M.scale(lmat, zoom, zoom, 1)
		return lmat
	end

	function this.tick(sec_current, sec_delta)
	end

	return this
end


