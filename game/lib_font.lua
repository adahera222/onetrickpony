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

function font_new(fname)
	local this = {
		fname = fname,
		img = png.load(fname),
	}

	do
		local iw, ih = png.get_dims(this.img)
		this.cw = iw/95
		this.ch = ih
		this.ratio = this.ch / this.cw
	end

	function this.puts(x, y, s, size, r, g, b, a)
		r = r or 1
		g = g or 1
		b = b or 1
		a = a or 1
		local i
		local bx = x
		for i=1,#s do
			if s:byte(i) == 10 then
				x = bx
				y = y - size * this.ratio
			else
				local c = (s:byte(i) - 32) / 95
				png.render(this.img,
					x, y - size * this.ratio, x + size, y,
					c, 1, c + 0.95/95, 0,
					r, g, b, a)
				x = x + size
			end
		end
	end

	function this.puts_shad(x, y, s, size, r, g, b, a)
		r = r or 1
		g = g or 1
		b = b or 1
		a = a or 1
		this.puts(x + size*0.25, y - size*0.25, s, size, 0, 0, 0, 0.5*a)
		this.puts(x, y, s, size, r, g, b, a)
	end
	
	return this
end

f_main = font_new("dat/font-dejavu-18.png")


