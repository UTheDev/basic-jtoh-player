--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

--i accidentally lost the revamp of this script somehow ahahahahahahaahaha
--i'm in pain why do i have to do this again

return function()
	script.Parent.Platform.BodyGyro.CFrame = script.Parent.Platform.CFrame
	script.Parent.Platform.BodyPosition.Position = script.Parent.Platform.Position
	script.Parent.Platform.Anchored = false
	if script.Parent:FindFirstChild("InvisiblePositions") and script.Parent.InvisiblePositions.Value then
		for _, p in pairs(script.Parent.Positions:GetChildren()) do
			if p:IsA"BasePart" then
				p.Transparency = 1
				p.CanCollide = false --this is probably completely useless
				p.Size = Vector3.new() --otherwise, funky hitboxes
			end
		end
	end
	while wait() do
		for _,p in pairs(script.Parent.Positions:GetChildren()) do
			script.Parent.Platform.BodyPosition.Position = p.Position
			wait(script.Parent:FindFirstChild("Delay") and script.Parent.Delay.Value or 5)
		end
	end
end