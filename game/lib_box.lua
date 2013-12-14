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

function box_new(settings)
	local this = {
		x = settings.x,
		y = settings.y,
		s = settings.s,
		size = settings.size or 2/50,
		scale = 1,
		dead = false,
		dead_timer = nil,
	}

	do
		local w, h = f_main.calc_size(this.s)
		w = w + 3
		h = h + 1
		local bw, bh = this.size * w, this.size * h * f_main.ratio
		local x, y = 0, 0
		this.bl = D.polytrip(
			P.roundrect(x, y, x+bw, y-bh, this.size*0.9, 4),
			0.03, 0, 0.2, 1, 1)
	end

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.scale(lmat, this.scale, this.scale, this.scale)
		M.load_modelview(lmat)
		this.bl(stage)

		if stage == 2 then
			f_main.puts_shad(this.size*1.5, -this.size*f_main.ratio*0.5,
				this.s, this.size)
		end
	end

	function this.tick(sec_current, sec_delta)
	end

	return this
end

