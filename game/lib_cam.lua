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
		follow_speed = settings.follow_speed or 10.0,
	}

	local lmat = M.new()
	function this.get_mat()
		M.identity(lmat)
		local zoom = this.zoom
		M.scale(lmat, zoom, zoom, 1)
		M.translate(lmat, -this.x, -this.y, -1)
		return lmat
	end

	function this.w2s(x, y)
		local sw, sh = sys.get_screen_dims()
		x = (x*2 - sw) / sh
		y = (y*2 - sh) / sh
		y = -y
		x = x/this.zoom + cam_main.x
		y = y/this.zoom + cam_main.y
		return x, y
	end

	function this.tick(sec_current, sec_delta)
		if this.follow then
			local k = 1 - math.exp(-this.follow_speed * sec_delta)
			this.x = this.x + (this.follow.x - this.x) * k
			this.y = this.y + (this.follow.y - this.y) * k
		end
	end

	return this
end


