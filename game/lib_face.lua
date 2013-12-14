--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

function D.eye(settings)
	local this = {
		x = settings.x or 0,
		y = settings.y or 0,
		ipoly = D.polytrip(P.ellipse(0, 0, 0.3, 0.3, 15), 0.03,
			0.7, 0.7, 0.7, 1),
		iris0 = D.poly(P.ellipse(0, 0, 0.23, 0.23, 15),
			0.3, 0.3, 1.0, 1),
		pupil0 = D.poly(P.ellipse(0, 0, 0.15, 0.15, 15),
			0.0, 0.0, 0.0, 1),
		pupil1 = D.poly(P.ellipse(-0.02, 0.02, 0.10, 0.10, 15),
			1.0, 1.0, 1.0, 1),
	}

	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.load_modelview(lmat)

		this.ipoly(stage)
		if stage == 3 then
			this.iris0()
			this.pupil0()
			this.pupil1()
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
	}

	local eye0 = D.eye { x = -0.35, y =  0.25 }
	local eye1 = D.eye { x =  0.35, y =  0.25 }
	local lmat = M.new()
	function this.draw(gmat, stage)
		M.dup(lmat, gmat)
		M.translate(lmat, this.x, this.y, 0)
		M.load_modelview(lmat)

		this.fpoly(stage)
		if stage == 3 then
			local i
			for i=1,3 do
				eye0.draw(lmat, i)
				eye1.draw(lmat, i)
			end
		end
	end

	return this
end

