--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

function P.eyesocket(settings)
	-- TODO!
	return P.ellipse(0, 0, 0.3, 0.3 * settings.blink_level, 15)
end

function D.eye(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		lx = settings.lx or 0,
		ly = settings.ly or 0,
		eye_side = settings.eye_side,
		parent = settings.parent,
		iris0 = D.poly(P.ellipse(0, 0, 0.23, 0.23, 15),
			0.3, 0.3, 1.0, 1),
		pupil0 = D.poly(P.ellipse(0.00, 0.00, 0.15, 0.15, 15),
			0.0, 0.0, 0.0, 1),
		pupil1 = D.poly(P.ellipse(-0.03, 0.03, 0.10, 0.10, 15),
			1.0, 1.0, 1.0, 1),
	}

	function this.look(x, y)
		this.lx, this.ly = x, y
	end

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.rotate(lmat, this.eye_side * -this.parent.eye_tilt, 0, 0, 1)
		M.load_modelview(lmat)
		this.ipoly = D.polytrip(P.eyesocket {
				blink_level = this.parent.blink_level,
			}, 0.03,
			0.7, 0.7, 0.7, 1)

		if stage == 2 then
			GL.glStencilFunc(GL.ALWAYS, 1, 255)
			GL.glStencilOp(GL.KEEP, GL.KEEP, GL.REPLACE)
			this.ipoly(2)
			GL.glStencilOp(GL.KEEP, GL.KEEP, GL.KEEP)
		else
			this.ipoly(stage)
		end
		if stage == 3 then
			M.dup(lmat, gmat)
			M.translate(lmat, this.x, this.y, 0)
			M.translate(lmat, this.lx, this.ly, 0)
			M.load_modelview(lmat)
			GL.glStencilFunc(GL.EQUAL, 1, 255)
			this.iris0()
			M.translate(lmat, this.lx*0.2, this.ly*0.2, 0)
			M.load_modelview(lmat)
			this.pupil0()
			M.translate(lmat, this.lx*0.2, this.ly*0.2, 0)
			M.load_modelview(lmat)
			this.pupil1()
			M.dup(lmat, gmat)
			M.translate(lmat, this.x, this.y, 0)
			M.rotate(lmat, this.eye_side * -this.parent.eye_tilt, 0, 0, 1)
			M.load_modelview(lmat)
			GL.glStencilFunc(GL.NEVER, 0, 255)
			GL.glStencilOp(GL.REPLACE, GL.REPLACE, GL.REPLACE)
			this.ipoly(2)
			GL.glStencilFunc(GL.ALWAYS, 0, 255)
			GL.glStencilOp(GL.KEEP, GL.KEEP, GL.KEEP)
		end
	end

	return this
end

function D.face(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		eye_tilt = 0,
		eye_tilt_target = 0.0,
		blink_delay = settings.blink_delay or 3.0,
		blink_next = nil,
		blink_down = nil,
		blink_level = 0.1,
		blink_target = 1.0,
		fpoly = D.polytrip(P.ellipse(0, 0, 0.8, 0.7, 30), 0.03,
			1.0, 0.8, 0, 1),
	}
	this.eye0 = D.eye { x = -0.35, y =  0.15, parent = this, eye_side = -1, }
	this.eye1 = D.eye { x =  0.35, y =  0.15, parent = this, eye_side =  1, }

	function this.look(x, y)
		this.eye0.look(x, y)
		this.eye1.look(x, y)
	end

	function this.tick(sec_current, sec_delta)
		if this.blink_next and this.blink_next(sec_current) then
			this.blink_down = oneshot(0.08, sec_current)
			this.blink_next = nil
		end

		if not this.blink_next then
			-- TODO: Poisson distribution
			local d = this.blink_delay
			d = d * -math.log(math.random())
			this.blink_next = oneshot(d, sec_current)
		end

		if this.blink_down and this.blink_down(sec_current) then
			this.blink_down = nil
		end

		if this.blink_down then
			this.blink_level = math.max(0.06, this.blink_level - sec_delta/0.08)
		else
			this.blink_level = this.blink_level
				+ (this.blink_target - this.blink_level)
				* (1 - math.exp(-20*sec_delta))
		end

		this.eye_tilt = this.eye_tilt
			+ (this.eye_tilt_target - this.eye_tilt)
			* (1 - math.exp(-20*sec_delta))
	end

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.load_modelview(lmat)

		this.fpoly(stage)
		if stage == 3 then
			this.eye0.draw(lmat, 1)
			this.eye1.draw(lmat, 1)
			this.eye0.draw(lmat, 2)
			this.eye0.draw(lmat, 3)
			this.eye1.draw(lmat, 2)
			this.eye1.draw(lmat, 3)
		end
	end

	return this
end

