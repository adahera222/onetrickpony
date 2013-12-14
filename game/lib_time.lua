--[[
Copyright (C) 2013, Ben "GreaseMonkey" Russell.
Going to slap a licence on this at some stage.
]]

function oneshot(d, sec_start)
	return function(sec_current)
		sec_start = sec_start or sec_current
		return sec_current >= sec_start + d
	end
end

