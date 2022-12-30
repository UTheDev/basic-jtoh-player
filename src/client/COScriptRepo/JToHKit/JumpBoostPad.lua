--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local distance = script.Parent:FindFirstChild("Distance") and script.Parent.Distance.Value

local p = game.Players.LocalPlayer
local pad = script.Parent
local pad2 = pad:Clone()
pad2:ClearAllChildren()
pad2.Transparency = 1
pad2.Size = pad2.Size + Vector3.new(0.5,distance,0.5)
pad2.CFrame = pad.CFrame + script.Parent.CFrame.UpVector * distance/2
pad2.CanCollide = false
pad2.Parent = pad
pad2.Anchored = false
pad2.Massless = true
local wc = Instance.new("WeldConstraint",pad2)
wc.Part0 = pad2
wc.Part1 = pad
local onpad = false

return function()
	pad2.Touched:Connect(function(t)
		if game.Players:GetPlayerFromCharacter(t.Parent) == p and t.Name ~= "Left Arm" and t.Name ~= "Right Arm" and not (script.Parent:FindFirstChild("Activated") and not script.Parent.Activated.Value) then
			local h = t.Parent:FindFirstChild"Humanoid"
			if h and not onpad then
				onpad = true
				h.JumpPower = pad.JumpPower.Value
			end
		end
	end)
	pad2.TouchEnded:Connect(function(t)
		if game.Players:GetPlayerFromCharacter(t.Parent) == p and t.Name ~= "Left Arm" and t.Name ~= "Right Arm" then
			local h = t.Parent:FindFirstChild"Humanoid"
			if h and onpad then
				onpad = false
				h.JumpPower = 50
			end
		end
	end)
end