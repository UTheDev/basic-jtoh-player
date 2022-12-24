--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local tt = tonumber(script.Parent.ToggleTime.Value)
local changeFrame = tonumber(script.Parent.ChangeFrame.Value)
local on = tonumber(script.Parent.OnTransparency.Value)
local off = tonumber(script.Parent.OffTransparency.Value)
local indicator = script.Parent.Indicator
local beat = 0
local maximum = 0

local parts = {}
for _, p in pairs(script.Parent:GetDescendants()) do
	if p:IsA"BasePart" and tonumber(p.Name) then
		table.insert(parts, p)
	end
end

local ignore = {game.Players.LocalPlayer.Character} --ignore uncollidable parts and the player

function pointIsNearBlocks(pos)
	local maxDistance = 50 --maximum distance for raycasting
	local isInSight = false
	for _, p in pairs(parts) do
		local ray = Ray.new(pos, CFrame.new(pos, p.Position).lookVector * maxDistance)
		local part = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
		if part and part:IsDescendantOf(script.Parent) then isInSight = true end
	end
	return isInSight
end

function ding()
	local char = game.Players.LocalPlayer.Character
	if not char or not char.PrimaryPart or not pointIsNearBlocks(char.PrimaryPart.Position) then return end --only play the ding when beat blocks are within immediate view
	local snd = script.Ding:Clone()
	snd.Parent = workspace
	snd.PlayOnRemove = true --set it here so that the player doesn't hear a ding when leaving the place
	snd:Destroy()
end

function setActive(p, active, changing)
	if p:FindFirstChild('Invert') then active = not active end
	if changing then
		if active then
			p.Transparency = (off - 0.1)
			p.Mesh.Scale = Vector3.new(1, 1, 1) * .8
		else
			p.Mesh.Scale = Vector3.new(1, 1, 1) * .95
		end
	else
		if active then
			p.Mesh.Scale = Vector3.new(1, 1, 1)
			p.Transparency = on
			p.CanCollide = true
		else
			p.Mesh.Scale = Vector3.new(1, 1, 1) * .7
			p.Transparency = off
			p.CanCollide = false
		end
	end
end


return function()
	if indicator.Value == true then
		for _, p in pairs(parts) do --initialization
			local num = tonumber(p.Name)
			maximum = math.max(num, maximum)
			local bmesh = Instance.new("BlockMesh", p)
			bmesh.Name = "Mesh"
			local orgSize = Instance.new("Vector3Value")
			orgSize.Name = "OriginalSize"
			orgSize.Value = p.Size
			orgSize.Parent = p
			setActive(p, false)
		end
		while script.Parent do --loop
			beat += 1
			if (beat > maximum) then
				beat = 1
			end
			ding()
			for _, p in pairs(parts) do
				if p.Name == tostring(beat) then
					setActive(p, true)
				end
			end
			wait(tt - changeFrame)
			--change imminent indicator
			for _, p in pairs(parts) do
				if p.Name == tostring(beat) then
					setActive(p, false, true)
				end
				local nextbeat = beat + 1
				if nextbeat > maximum then nextbeat = 1 end
				if p.Name == tostring(nextbeat) then
					setActive(p, true, true)
				end
			end
			wait(changeFrame)
			for _, p in pairs(parts) do
				if p.Name == tostring(beat) then
					setActive(p, false)
				end
			end
		end
	else
		local beat = 0
		local maximum = 0
		local parts = script.Parent:GetDescendants()
		for _, p in pairs(parts) do
			local num = tonumber(p.Name)
			if (num and p:IsA'BasePart') then
				maximum = math.max(num, maximum)
				if (p:FindFirstChild('Invert')) then
					p.Transparency = on
					p.CanCollide = true
				else
					p.Transparency = off
					p.CanCollide = false
				end
			end
		end
		while script.Parent do
			beat = beat + 1
			if (beat > maximum) then
				beat = 1
			end
			for _, p in pairs(parts) do
				if (p.Name == tostring(beat) and p:IsA'BasePart') then
					if (p:FindFirstChild('Invert')) then
						p.Transparency = off
						p.CanCollide = false
					else
						p.Transparency = on
						p.CanCollide = true
					end
				end
			end
			wait(tt)
			for _, p in pairs(parts) do
				if (p.Name == tostring(beat) and p:IsA'BasePart') then
					if (p:FindFirstChild('Invert')) then
						p.Transparency = on
						p.CanCollide = true
					else
						p.Transparency = off
						p.CanCollide = false
					end
				end
			end
		end
	end
end