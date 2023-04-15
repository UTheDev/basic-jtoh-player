--[[
Modified version of the music script that comes with the Juke's Towers of Hell kit by Jukereise and Gammattor

Some modifications to the original script:
- The MuteButtonGui is created inside this module (instead of depending on something preloaded)
- When MusicName is specified within a sound instance, it should no longer try to look things up from roblox.com
]]
--

return function()
	local thefolder = game.ReplicatedStorage:WaitForChild("BackgroundMusic")

	local zones = thefolder:WaitForChild("BackgroundMusicZones")
	local glob = thefolder:WaitForChild("GlobalBackgroundMusic")

	-- MODIFICATION: Create the MuteButtonGui here
	local createInstance =
		require(game:GetService("ReplicatedStorage"):WaitForChild("BasicJToHPlayer"):WaitForChild("createInstance"))
	--local mutebutton = script:WaitForChild("MuteButtonGui")
	local mutebutton = createInstance("ScreenGui", {
		Name = "MuteButtonGui",

		ResetOnSpawn = false,

		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true,
		DisplayOrder = 3,

		Enabled = true,
		AutoLocalize = true,
	}, {
		createInstance("TextButton", {
			Name = "Button",

			Visible = true,

			AnchorPoint = Vector2.new(0, 0),
			Size = UDim2.new(0, 90, 0, 35),
			Position = UDim2.new(1, -92, 1, -37),

			Style = Enum.ButtonStyle.RobloxRoundDefaultButton,

			Font = Enum.Font.Cartoon,
			TextSize = 18,
			TextScaled = false,
			TextWrapped = false,
			TextTruncate = Enum.TextTruncate.None,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeColor3 = Color3.fromRGB(40, 41, 45),

			ZIndex = 1
		}),
		createInstance("TextLabel", {
			Name = "SongTitle",

			Visible = false,

			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(0.5, -100, 0, 40),
			Position = UDim2.new(1, -100, 1, 0),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Font = Enum.Font.SourceSansLight,
			TextSize = 35,
			TextScaled = true,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),

			TextXAlignment = Enum.TextXAlignment.Right,
			
			ZIndex = 2,
		}, {
			createInstance("Frame", {
				Name = "Background",

				Visible = true,

				AnchorPoint = Vector2.new(1, 0.5),
				Size = UDim2.new(0, 0, 0.9, 0),
				Position = UDim2.new(1, 5, 0.5, 0),
				
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,

				ZIndex = 1
			}),
		}),
	})
	-----

	local p = game.Players.LocalPlayer

	_G.MusicUseSmoothTransition = true --compatible with change at any time
	local mute = false
	local disableButton = false

	local firstSongStarted = false --so that the first song that plays in a server starts at full volume instead of fading in

	local introName = "IntroMusic"

	--settings stuff
	local config = script:FindFirstChild("Settings")
	if config then
		config = require(config)
		if config.UseSmoothAsDefaultTransition ~= nil then
			_G.MusicUseSmoothTransition = config.UseSmoothAsDefaultTransition
		end
		if config.DisableMuteButton ~= nil then
			disableButton = config.DisableMuteButton
		end
	end
	if not disableButton then
		mutebutton.Parent = p.PlayerGui
	end

	--this function was given to me by funwolf7

	--This function will determine if a point is inside of an object
	local function isPointInCubeObject(Point, Object)
		--A variable for the size for simplicity
		local Size = Object.Size

		--The offset orientated to the object's cframe
		local PointOffset = Object.CFrame:PointToObjectSpace(Point)

		--The offset of that axis is less than or equal to half the size of the part on that axis
		--Basically, the offset on that axis will not go outside of the part
		local InsideX = math.abs(PointOffset.X) <= Size.X / 2
		local InsideY = math.abs(PointOffset.Y) <= Size.Y / 2
		local InsideZ = math.abs(PointOffset.Z) <= Size.Z / 2

		--Return whether or not it is inside all three axis
		return InsideX and InsideY and InsideZ
	end
	local function isPointInBallObject(Point, Object)
		return (Object.Position - Point).Magnitude <= Object.Size.X / 2
	end
	local function isPointInCylinderObject(Point, Object)
		--A variable for the size for simplicity
		local Size = Object.Size

		--The offset orientated to the object's cframe
		local PointOffset = Object.CFrame:PointToObjectSpace(Point)

		--The offset of that axis is less than or equal to half the size of the part on that axis
		--Basically, the offset on that axis will not go outside of the part
		local InsideX = math.abs(PointOffset.X) <= Size.X / 2
		local InsideYZ = Vector3.new(0, PointOffset.Y, PointOffset.Z).Magnitude <= math.min(Size.Y, Size.Z) / 2

		--Return whether or not it is inside all three axis
		return InsideX and InsideYZ
	end

	local RegisteredZones = {}

	local currentlyplaying = {}
	local musicnames = {}
	local focusedzone --this is the current zone that the player is determined to be within
	--inside every single sound in the music folder is a numbervalue called OriginalVolume

	local function updatemutetext()
		mutebutton.Button.Text = ("Music: " .. (mute and "OFF" or "ON"))
		mutebutton.Button.TextColor3 = mute and Color3.new() or Color3.new(1, 1, 1)
		mutebutton.Button.Style = mute and Enum.ButtonStyle.RobloxRoundDropdownButton
			or Enum.ButtonStyle.RobloxRoundDefaultButton
	end
	updatemutetext()

	-- needed due to the positioning of the jump button on mobile devices
	local UserInputService = game:GetService("UserInputService")
	if UserInputService.TouchEnabled then
		local muteButton = mutebutton:FindFirstChild("Button")

		muteButton.Size = UDim2.new(0, 90, 0, 16)
		muteButton.Position = UDim2.new(1, -92, 1, -17)
	end

	mutebutton.Button.MouseButton1Click:Connect(function()
		mute = not mute
		updatemutetext()
		if currentlyplaying[focusedzone] then
			currentlyplaying[focusedzone].Volume = currentlyplaying[focusedzone]:GetAttribute("OriginalVolume")
		end
	end)
	mutebutton.Button.MouseEnter:Connect(function()
		mutebutton.SongTitle.Visible = true
	end)
	mutebutton.Button.MouseLeave:Connect(function()
		mutebutton.SongTitle.Visible = false
	end)

	local function checkZoneButton(zone)
		local color = zone:GetAttribute("ButtonActivated")
		if color and _G.Button and typeof(_G.Button) == "table" then
			local active
			local success, msg = pcall(function()
				active = _G.Button[color]
			end)
			if not success then
				warn(
					"Failed to check if the color frequency of "
						.. tostring(color)
						.. " is active! Assuming it is inactive."
				)
			end
			if zone:GetAttribute("Invert") then
				active = not active
			end
			return active
		else
			return true
		end
	end
	local function fillSongName(play)
		if not musicnames[play] then
			musicnames[play] = "[getting song name]" --add a placeholder once it's initially found so that GetProductInfo isn't repeatedly called

			local CustomMusicName: StringValue = play:FindFirstChild("MusicName")

			if CustomMusicName and CustomMusicName:IsA("StringValue") then
				musicnames[play] = CustomMusicName.Value
			else
				local ID = play.SoundId
				if string.sub(ID, 1, 13) == "rbxassetid://" then
					ID = string.sub(play.SoundId, 14)
				end --extract the ID itself as idk if it works with the extra characters
				if string.sub(ID, 1, 32) == "http://www.roblox.com/asset/?id=" then
					ID = string.sub(play.SoundId, 33)
				end --in some rare circumstances this URL is used instead

				ID = tonumber(ID)

				if typeof(ID) == "number" then
					task.spawn(function()
						local success, err = pcall(function()
							local mName = game:GetService("MarketplaceService"):GetProductInfo(ID).Name
							local removeString = "Audio/"
							if string.sub(mName, 1, string.len(removeString)) == removeString then
								mName = string.sub(mName, string.len(removeString) + 1)
							end
							musicnames[play] = mName
						end)

						if not success then
							warn("Failed to fetch song name for " .. tostring(ID) .. "\nError: " .. tostring(err))
						end
					end)
				end
			end
		end
	end
	local function newSound(m) --WAY better approach to this than in the older version, this covers even new sounds
		if m:IsA("Sound") then
			m:SetAttribute("OriginalVolume", m.Volume)
			local function triggerLoop()
				if not m.Playing then
					return
				end
				local othermusics = {}
				for _, mu in pairs(m.Parent:GetChildren()) do
					if mu.Name ~= introName and mu ~= m then
						table.insert(othermusics, mu)
					end
				end
				if focusedzone ~= m.Parent then --if the music is already fading in, instantly stop it now
					--	m.Volume = 0
					--	m:Stop()
					--	currentlyplaying[m.Parent] = nil
					return
				end
				if #othermusics <= 0 then --do nothing if the music is by itself
					if m:GetAttribute("StartAt") then
						m.TimePosition = m:GetAttribute("StartAt")
					end
					return
				end
				local newm = othermusics[math.random(1, #othermusics)]
				newm.Volume = newm:GetAttribute("OriginalVolume") --also in extremely rare cases where the length is insanely short, the next audio will just play at full volume
				if newm:GetAttribute("StartAt") then
					newm.TimePosition = newm:GetAttribute("StartAt")
				end
				newm:Play()
				fillSongName(newm)
				currentlyplaying[m.Parent] = newm
				m:Stop()
			end
			if m.Name == introName then
				m.Played:Connect(function()
					if m.Name == "IntroMusic" then
						task.delay(m.TimeLength - 0.05, function()
							if m.TimePosition > m.TimeLength - 1 and m.Playing then
								triggerLoop()
							end
						end)
					end
				end)
			else
				m.DidLoop:Connect(triggerLoop)
			end

			local Zone = m.Parent.Parent
			if table.find(RegisteredZones, Zone) == nil then
				--print("added song", m)
				table.insert(RegisteredZones, m.Parent.Parent)
			end
		end
	end
	for _, m in pairs(thefolder:GetDescendants()) do
		newSound(m)
	end
	thefolder.DescendantAdded:Connect(newSound)

	print("music script is now starting")

	while task.wait(_G.MusicUseSmoothTransition and 1 / 10 or 1 / 20) do --yeah kinda weird
		--first, check if the character even exists
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local playerpos = p.Character.HumanoidRootPart.Position
			--next, check every zone and see which ones the player is in
			local BestZone = glob --highest priority zone
			for _, z in pairs(RegisteredZones) do --zones:GetChildren()) do
				if z:FindFirstChild("Music") and not z:GetAttribute("Disabled") and checkZoneButton(z) then
					local priority = z:GetAttribute("Priority")
						or (z:FindFirstChild("Priority") and z.Priority.Value)
						or 1
					--check to see if it classifies as a real zone
					local active = false --false by default
					for _, pt in pairs(z:GetChildren()) do --check for every part inside
						if pt:IsA("BasePart") and not pt:GetAttribute("Disabled") and checkZoneButton(pt) then
							if pt:IsA("Part") and pt.Shape == Enum.PartType.Ball then
								if isPointInBallObject(playerpos, pt) then
									active = true
								end
							elseif pt:IsA("Part") and pt.Shape == Enum.PartType.Cylinder then
								if isPointInCylinderObject(playerpos, pt) then
									active = true
								end
							else
								if isPointInCubeObject(playerpos, pt) then
									active = true
								end
							end
						end
					end
					if
						(z:FindFirstChild("AreaValid") and z.AreaValid:IsA("ModuleScript")) and not require(z.AreaValid)
					then
						active = false
					end
					if active and (BestZone == glob or z.Priority.Value > BestZone.Priority.Value) then --take over the best zone if it doesn't exist or this zone has a higher priority
						BestZone = z
					end
				end
			end
			if BestZone ~= glob then
				BestZone = BestZone:FindFirstChild("Music")
			end --set it to the music folder to make it not distinguished between the global music and the music zones
			if not _G.LockMusicPlaying then
				focusedzone = BestZone
			end
			local isplaying
			local allplaying = 0
			for _, _ in pairs(currentlyplaying) do --apparently i gotta do this dumb workaround to properly get the list...
				allplaying += 1
			end
			for mz, s in pairs(currentlyplaying) do
				local increment = s:GetAttribute("OriginalVolume") / 30 --this is the increment each tick to increase/decrease the volume
				if mz == focusedzone then
					isplaying = true --do nothing but increase the volume
					if not mute then
						if s.Playing then --here is where smooth transition comes into play
							if firstSongStarted then
								local newvol = s.Volume + increment
								if newvol > s:GetAttribute("OriginalVolume") then
									newvol = s:GetAttribute("OriginalVolume")
								end --without this the audio would rapidly increase to hilariously but ear shatteringly loud
								s.Volume = newvol
							else
								s.Volume = s:GetAttribute("OriginalVolume")
								firstSongStarted = true
							end
						else --should only occur if smooth transition is disabled
							if allplaying <= 1 then
								s.Volume = s:GetAttribute("OriginalVolume")
								if not s.Playing then
									if s:GetAttribute("StartAt") then
										s.TimePosition = s:GetAttribute("StartAt")
									end
									s:Play()
								end
							end
						end
					else
						s.Volume = 0
					end
				else
					--fade out the music by an increment, and if its volume is already 0 then just stop it and remove it altogether
					s.Volume -= increment
					if s.Volume <= 0 or mute then
						s:Stop()
						s.Volume = 0 --may not even be needed, but just to be safe
						currentlyplaying[mz] = nil
					end
				end
			end
			if not isplaying and #focusedzone:GetChildren() > 0 then --do nothing if the folder is empty
				local play = focusedzone:FindFirstChild(introName)
					or focusedzone:GetChildren()[math.random(1, #focusedzone:GetChildren())]
				play.Volume = 0 --again may not be needed, but i gotta be safe ok
				if _G.MusicUseSmoothTransition then
					if play:GetAttribute("StartAt") then
						play.TimePosition = play:GetAttribute("StartAt")
					end
					play:Play()
				end
				currentlyplaying[focusedzone] = play
				fillSongName(play)
			end
			_G.CurrentlyPlayingMusic = currentlyplaying[focusedzone]
			_G.MusicName = (
				(
					currentlyplaying[focusedzone]
					and currentlyplaying[focusedzone]:FindFirstChild("MusicName")
					and currentlyplaying[focusedzone].MusicName.Value
				) or musicnames[currentlyplaying[focusedzone]]
			) or ""
			--if idtodisplay ~= nil and _G.MusicName ~= "" then
			--	_G.MusicName ..= string.format(" (ID: %d)", idtodisplay)
			--end
			mutebutton.SongTitle.Text = _G.MusicName
			mutebutton.SongTitle.Background.Size = UDim2.new(0, mutebutton.SongTitle.TextBounds.X + 10, 0.9, 0)
		end
	end

	-- insert the gui
	--mutebutton.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
