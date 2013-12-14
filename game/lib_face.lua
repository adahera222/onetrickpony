--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

function D.eye(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		lx = settings.lx or 0,
		ly = settings.ly or 0,
		ipoly = D.polytrip(P.ellipse(0, 0, 0.3, 0.3, 15), 0.03,
			0.7, 0.7, 0.7, 1),
		iris0 = D.poly(P.ellipse(0, 0, 0.23, 0.23, 15),
			0.3, 0.3, 1.0, 1),
		pupil0 = D.poly(P.ellipse(-0.02, 0.02, 0.15, 0.15, 15),
			0.0, 0.0, 0.0, 1),
		pupil1 = D.poly(P.ellipse(-0.04, 0.04, 0.10, 0.10, 15),
			1.0, 1.0, 1.0, 1),
	}

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.load_modelview(lmat)

		if stage == 2 then
			GL.glStencilFunc(GL.ALWAYS, 1, 255)
			GL.glStencilOp(GL.KEEP, GL.KEEP, GL.REPLACE)
			this.ipoly(2)
			GL.glStencilOp(GL.KEEP, GL.KEEP, GL.KEEP)
		else
			this.ipoly(stage)
		end
		if stage == 3 then
			M.translate(lmat, this.lx, this.ly, 0)
			M.load_modelview(lmat)
			GL.glStencilFunc(GL.EQUAL, 1, 255)
			this.iris0()
			this.pupil0()
			this.pupil1()
			M.translate(lmat, -this.lx, -this.ly, 0)
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
		fpoly = D.polytrip(P.ellipse(0, 0, 0.8, 0.7, 30), 0.03,
			1.0, 0.8, 0, 1),
		eye0 = D.eye { x = -0.35, y =  0.15 },
		eye1 = D.eye { x =  0.35, y =  0.15 },
	}

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

