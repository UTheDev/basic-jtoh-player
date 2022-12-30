--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local pushBoxSpawnButton = script.Parent
local button = pushBoxSpawnButton:WaitForChild("Button")
local pushBox = pushBoxSpawnButton:WaitForChild("Pushbox")

local currentBox = nil

local function spawnBox()
	if currentBox then
		currentBox:Destroy()
	end
	local box = pushBox:Clone()
	box.Parent = pushBoxSpawnButton
	currentBox = box
	if box:IsA("BasePart") then
		box.Anchored = false
	else
		for _,b in pairs(box:GetDescendants()) do
			if b:IsA("BasePart") and b:FindFirstChild("BoxAnchor") == nil then
				b.Anchored = false
			end
		end
	end
	for _,bc in pairs(box:GetDescendants()) do
		if bc:IsA("ModuleScript") and bc.Name == ("PushboxScript") then
			spawn(function()
				require(bc)()
			end)
		end
	end
end
return function()
	button.Touched:Connect(function(touch)
		if Players:GetPlayerFromCharacter(touch.Parent) == player then
			spawnBox()
		end
	end)
	pushBox.Parent = nil
	if not script.Parent:FindFirstChild("DontSpawnFirst") then spawnBox() end
end