--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

return function()
	local db = true
	script.Parent.Touched:Connect(function(hit)
		if hit.Anchored == false and db == true then
			db = false
			spawn(function()
				wait(0.05)
				db = true
			end)
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(0, math.huge, 0)
			bv.Velocity = Vector3.new(0, script.Parent.Power.Value, 0)
			bv.Parent = hit
			wait(0.15)
			bv:Destroy()
		end
	end)
end