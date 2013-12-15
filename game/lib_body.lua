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

function D.hand(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		poly = D.polytrip2(P.ellipse(0, 0, 0.2, 0.2, 15), 0.03,
			1.0, 0.8, 0, 1),
		lx = 0, ly = 0, lz = 1,
	}

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		local lx, ly, lz = norm(this.lx, this.ly, this.lz)
		M.translate(lmat, lx*0.4, ly*0.4, 0)
		M.load_modelview(lmat)
		this.poly(stage)
	end

	function this.look(x, y, z)
		this.lx, this.ly = x - this.x, y - this.y
		this.lz = z or this.lz
	end

	function this.tick(sec_current, sec_delta)
	end

	return this
end

function D.boot(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		foot = D.polytrip3(P.ellipse(0, 0, 0.2, 0.12, 10), 0.03,
			0.6, 0.3, 0, 1),
	}

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.load_modelview(lmat)
		this.foot(stage)
	end

	function this.tick(sec_current, sec_delta)
	end

	return this
end

function D.body(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		radius = 0.8,
		scale = settings.scale or 1,
		r = settings.r or 0.5,
		g = settings.g or 0.5,
		b = settings.b or 0.5,
		phys = settings.phys,
		breath = 0,
		breath_period = settings.breath_period or 3.0,
		breath_amp = settings.breath_amp or 0.05,
		vx = 0, vy = 0,
		tvx = 0, tvy = 0,
		tvsx = 0, tvsy = 0,
		can_jump = nil,
		can_jump_x = 0, can_jump_y = 0,
	}

	this.chest = D.polytrip2(P.ellipse(0, 0, 0.4, 0.5, 20), 0.03,
		this.r, this.g, this.b, 1)
	this.hand0 = D.hand { x = -0.4, y = -0.1 }
	this.hand1 = D.hand { x =  0.4, y = -0.1 }
	this.boot0 = D.boot { x = -0.3, y = -0.6 }
	this.boot1 = D.boot { x =  0.3, y = -0.6 }

	this.face = D.face {
		parent = this,
		x = 0.0,
		y = 0.9,
		follow = settings.follow,
		blink_delay = settings.blink_delay,
	}

	function this.look(x, y, z)
		x, y = x - this.x, y - this.y
		this.face.look(x, y, z)
		this.hand0.look(x, y, z)
		this.hand1.look(x, y, z)
	end

	function this.jump()
		if this.can_jump then
			this.vy = 5.0 * this.can_jump_y
			this.vx = 5.0 * this.can_jump_x
			this.can_jump = nil
		end
	end

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.load_modelview(lmat)

		local boffs = math.sin(this.breath) * this.breath_amp

		M.scale(lmat, 1, 1 + boffs, 1)
		M.translate(lmat, 0, boffs/2, 0)
		M.load_modelview(lmat)
		this.chest(stage)
		M.translate(lmat, 0, -boffs/2, 0)
		M.scale(lmat, 1, 1 / (1 + boffs), 1)
		this.face.y = 0.9 + boffs
		if stage == 3 then
			local i
			for i=1,3 do
				this.face.draw(lmat, i)
				this.hand0.draw(lmat, i)
				this.hand1.draw(lmat, i)
				this.boot0.draw(lmat, i)
				this.boot1.draw(lmat, i)
			end
		end
	end

	function this.collide_world(sec_current, sec_delta)
		local i
		local sdx, sdy = 0, 0
		local svx, svy = 0, 0

		for i = 1, #world_terrain do
			local dx, dy, amt, dmul = world_terrain[i].push_away(this)
			local dvx, dvy = norm(this.vx, this.vy)
			sdx = sdx + dx * amt
			sdy = sdy + dy * amt
			local vdot = math.max(0, -(this.vx*sdx + this.vy*sdy))
				/ math.sqrt(this.vx*this.vx + this.vy*this.vy)
			if dmul*dy > 0.5 then
				this.can_jump = oneshot(0.4, sec_current)
				this.can_jump_x = dx
				this.can_jump_y = dy
			end
			svx = svx + dmul * (-vdot*this.vx)
			svy = svy + dmul * (-vdot*this.vy)
		end

		this.x = this.x + sdx
		this.y = this.y + sdy
		this.vx = this.vx + svx
		this.vy = this.vy + svy
	end

	function this.tick(sec_current, sec_delta)
		this.vx = this.vx + (this.tvx - this.vx)
			* (1 - math.exp(-this.tvsx*sec_delta))
		this.vy = this.vy + (this.tvy - this.vy)
			* (1 - math.exp(-this.tvsy*sec_delta))
		if not edit_mode then
			this.vy = this.vy - 9.81 * sec_delta
		end

		if this.can_jump and this.can_jump(sec_current) then
			this.can_jump = nil
		end
		this.x = this.x + this.vx * sec_delta
		this.y = this.y + this.vy * sec_delta
		if not edit_mode then
			this.collide_world(sec_current, sec_delta)
		end
		this.breath = this.breath +
			(1/this.breath_period) * math.pi * 2 * sec_delta
		this.face.tick(sec_current, sec_delta)
		this.hand0.tick(sec_current, sec_delta)
		this.hand1.tick(sec_current, sec_delta)
		this.boot0.tick(sec_current, sec_delta)
		this.boot1.tick(sec_current, sec_delta)
	end

	return this
end
