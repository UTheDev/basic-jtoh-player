--[[
Client object that plays atmospheric sounds when
the local player is in a zone

By udev (@UTheDev)
]]
--

local TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local RunService = game:GetService("RunService")

local abs = math.abs
local TweenGroup = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"):WaitForChild("Tweening"):WaitForChild("TweenGroup"))

return function(ref: ValueBase)
	local isRunning = true

	--[[
	Returns if a point in world space is inside a box
	
	Params:
	Point <Vector3> - The position of the point in world space
	Box <Object3d> - The box to determine if the point is in
	
	Returns:
	<boolean> - If the point is in the box
	]]
	--
	local function isPointInBox(Point: Vector3, Box: Object3d): boolean
		local BoxSize = Box.Size
		local LocalPos = Box.CFrame:PointToObjectSpace(Point)

		return abs(LocalPos.X) <= BoxSize.X / 2
			and abs(LocalPos.Y) <= BoxSize.Y / 2
			and abs(LocalPos.Z) <= BoxSize.Z / 2
	end

	if ref then
		local localPlayer = game:GetService("Players").LocalPlayer
		local tweens = TweenGroup.new()
		local refParent = ref.Parent
		local sounds = {}
		local parts = {}
		local rootPart: BasePart

		local function onCharSpawn(character)
			if character then
				rootPart = character:WaitForChild("HumanoidRootPart")
			end
		end

		for i, v in pairs(refParent:WaitForChild("Sounds"):GetChildren()) do
			if v:IsA("Sound") then
				table.insert(sounds, v)
				v.Volume = 0
			end
		end

		for i, v in pairs(refParent:GetChildren()) do
			if v:IsA("BasePart") then
				table.insert(parts, v)
			end
		end

		onCharSpawn(localPlayer.Character)
		localPlayer.CharacterAdded:Connect(onCharSpawn)

		-- fades out sounds
		local function stopSounds()
			tweens:killAll()

			for i, v in pairs(sounds) do
				tweens:play(
					v,
					TWEEN_INFO,
					{
						Volume = 0,
					},
					nil,
					function()
						v:Stop()
					end
				)
			end
		end

		-- fades in sounds
		local function playSounds()
			tweens:killAll()

			for i, v in pairs(sounds) do
				if not v.IsPlaying then
					v.TimePosition = v:GetAttribute("StartTime") or 0
					v:Play()
				end

				tweens:play(v, TWEEN_INFO, {
					Volume = v:GetAttribute("TargetVolume") or 1,
				})
			end
		end

		-- run loop
		local isPlaying = false

		local runner = RunService.Heartbeat:Connect(function()
			if isRunning and rootPart then
				local pos = rootPart.CFrame.Position

				local isInZone = false

				for i, v in pairs(parts) do
					if isPointInBox(pos, v) then
						isInZone = true
						break
					end
				end

				-- check if isInZone actually changed
				if isRunning and isInZone ~= isPlaying then
					isPlaying = isInZone

					if isPlaying then
						playSounds()
					else
						stopSounds()
					end
				end
			end
		end)

		--print("atmosphere zone started")

		return {
			stop = function()
				runner:Disconnect()
				runner = nil

				isRunning = false
				stopSounds()

				--print("atmosphere zone stopped");
			end,
		}
	end
end
