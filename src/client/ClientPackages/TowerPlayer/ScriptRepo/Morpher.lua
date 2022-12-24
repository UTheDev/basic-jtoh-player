-- Morpher by Ep_och (EloEppo)


local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


local player = Players.LocalPlayer


local durationGui = script:WaitForChild("DurationGui")
local pressSound = script:WaitForChild("Press")
local tickSound = script:WaitForChild("Tick")


local morpher = script.Parent
local morph = morpher:WaitForChild("Morph")


local DEFAULT_DURATION = 0
local DEFAULT_SPEED = .25


local function getButtons()
	local buttons = {}
	
	
	for k, v in pairs(morpher:GetDescendants()) do
		if v.Name == "Button" then
			local button = v:FindFirstChild("Button")
			
			
			local newMorphs = {}
			
			
			for k, v in pairs(v:GetDescendants()) do
				if v.Name == "NewMorph" then
					table.insert(newMorphs, v)
				end
			end
			
			
			if button and #newMorphs > 0 then
				local duration = v:FindFirstChild("MorphDuration")
				local speed = v:FindFirstChild("MorphSpeed")
				
				
				duration = duration and duration.Value or DEFAULT_DURATION
				speed = speed and speed.Value or DEFAULT_SPEED
				
				
				buttons[button] = {NewMorphs = newMorphs, Duration = duration, Speed = speed}
			end
		end
	end
	
	
	return buttons
end


return function()
	local id = HttpService:GenerateGUID()
	
	
	local buttons = getButtons()
	
	
	local currentButton = nil
	
	
	local defaultMorph = morph:Clone()
	defaultMorph.Transparency = 1
	defaultMorph.CanCollide = false
	
	
	defaultMorph.Parent = morpher
	
	
	local cloneMorphs = {}
	
	
	for k, v in pairs(buttons) do
		k.Touched:Connect(function(touch)
			local yesplr=k.Parent.SupportPlayers.Value and Players:GetPlayerFromCharacter(touch.Parent)==player
			local yesbox=k.Parent.SupportPushboxes.Value and touch.Name=='Pushbox'
			local yesbal=k.Parent.SupportBalloons.Value and 
			 touch.Name == "Part" and touch.Material == Enum.Material.Neon and touch:FindFirstChild("BodyVelocity") 
			if (yesplr or yesbox or yesbal) and k ~= currentButton then

				local pressSound = pressSound:Clone()
				pressSound.Parent = k
					
					
				pressSound:Play()
					
					
				Debris:AddItem(pressSound, 5)
					
					
				local info = TweenInfo.new(v.Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					
					
				for _, newMorph in pairs(v.NewMorphs) do
					if newMorph == v.NewMorphs[1] then
						TweenService:Create(k, info, {Color = newMorph.Color}):Play()
						TweenService:Create(morph, info, {Color = newMorph.Color, Size = newMorph.Size, CFrame = newMorph.CFrame}):Play()
							
							
						morph.Material = newMorph.Material
							
							
						for _, cloneMorph in pairs(cloneMorphs) do
							spawn(function()
								TweenService:Create(cloneMorph, info, {Color = newMorph.Color, Size = newMorph.Size, CFrame = newMorph.CFrame}):Play()
									
									
								wait(v.Speed)
									
									
								cloneMorph:Destroy()
							end)
						end
					else
						local cloneMorph = morph:Clone()
						cloneMorph.Parent = morpher
							
							
						TweenService:Create(cloneMorph, info, {Color = newMorph.Color, Size = newMorph.Size, CFrame = newMorph.CFrame}):Play()
							
							
						cloneMorph.Material = newMorph.Material
							
							
						table.insert(cloneMorphs, cloneMorph)
					end
				end
					
					
				if currentButton then
					local durationGui = currentButton:FindFirstChild("DurationGui")
						
						
					if durationGui then
						durationGui:Destroy()
					end
						
						
					TweenService:Create(currentButton, info, {Color = Color3.new(0, 0, 0)}):Play()
				end
					
					
				currentButton = k
					
					
				RunService:UnbindFromRenderStep("MorpherDuration" .. id)
					
					
				if v.Duration > 0 then
					local durationGui = durationGui:Clone()
					durationGui.Enabled = true
						
						
					durationGui.Parent = k
						
						
					local tickSound = tickSound:Clone()
					tickSound.Parent = k
						
						
					tickSound:Play()
						
						
					local epoch = time() -- No, it's not named after me
						
						
					RunService:BindToRenderStep("MorpherDuration" .. id, 1, function()
						local elapsed = time() - epoch
						local remaining = math.ceil(v.Duration - elapsed)
								
								
						if elapsed >= v.Duration then
							durationGui:Destroy()
								
								
							Debris:AddItem(tickSound, 5)
								
								
							local info = TweenInfo.new(DEFAULT_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
								
								
							TweenService:Create(k, info, {Color = Color3.new(0, 0, 0)}):Play()
							TweenService:Create(morph, info, {Color = defaultMorph.Color, Size = defaultMorph.Size, CFrame = defaultMorph.CFrame}):Play()
								
								
							morph.Material = defaultMorph.Material
								
								
							for _, cloneMorph in pairs(cloneMorphs) do
								spawn(function()
									TweenService:Create(cloneMorph, info, {Color = defaultMorph.Color, Size = defaultMorph.Size, CFrame = defaultMorph.CFrame}):Play()
										
										
									wait(v.Speed)
										
										
									cloneMorph:Destroy()
								end)
							end
								
								
							if currentButton then
								TweenService:Create(currentButton, info, {Color = Color3.new(0, 0, 0)}):Play()
							end
								
								
							currentButton = nil
								
								
							RunService:UnbindFromRenderStep("MorpherDuration" .. id)
						else
							durationGui.TextLabel.Text = remaining
							
							
							durationGui.TextLabel.Changed:Connect(function(property)
								if property == "Text" then
									tickSound:Play()
								end
							end)
						end
					end)
				end
			end
		end)
	end
end