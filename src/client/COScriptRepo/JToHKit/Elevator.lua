--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

return function()
	script.Parent.TopSurface = 'Studs'
	local players = not script.Parent:FindFirstChild("IgnorePlayers")
	local boxes = not script.Parent:FindFirstChild("IgnoreBoxes")
	local speed = script.Parent:FindFirstChild("Speed") and script.Parent.Speed.Value or 40
	script.Parent.Touched:Connect(function(part)
		local torso = part.Parent:FindFirstChild("Torso") or part
		if not torso:FindFirstChild("ElevatorVelocity") and (part.Parent:FindFirstChild("Humanoid") and players) or (part.Name == "Pushbox" and boxes) 
			and not (script.Parent:FindFirstChild("Activated") and not script.Parent.Activated.Value) then
			local velocity = Instance.new("BodyVelocity", torso)
			velocity.Name = "ElevatorVelocity"
			local uv=script.Parent.CFrame.UpVector
			local maxf=Vector3.new(0,math.huge,0)
			if uv.X ~= 0 then maxf = Vector3.new(math.huge, maxf.Y, maxf.Z) end
			if uv.Z ~= 0 then maxf = Vector3.new(maxf.X, maxf.Y, math.huge) end

			velocity.MaxForce = maxf
			velocity.Velocity = script.Parent.CFrame.UpVector*speed
		end
	end)
	script.Parent.TouchEnded:Connect(function(part)
		local torso = part.Parent:FindFirstChild("Torso") or part
		if torso:FindFirstChild("ElevatorVelocity") and (part.Parent:FindFirstChild("Humanoid") and players) or (part.Name == "Pushbox" and boxes) then torso.ElevatorVelocity:Destroy() end
	end)
end