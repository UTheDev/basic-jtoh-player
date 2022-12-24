--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local userinput = game:GetService("UserInputService")

local plr = game.Players.LocalPlayer

function flip()
	local char = plr.Character
	if char then
		local hrp = char:FindFirstChild("Torso")
		if hrp then
			local touch = hrp:FindFirstChild("TouchInterest")
			if not touch then hrp.Touched:Connect(function() end) end
			for _, t in pairs(hrp:GetTouchingParts()) do
				if t:FindFirstChild("CanFlip") and t.CanCollide then
					local offsetFromPart = t.CFrame:ToObjectSpace(hrp.CFrame)
					local cframeSet = t
					if t:FindFirstChild("TeleToObject") then
						cframeSet = t.TeleToObject.Value
					end
					hrp.CFrame = (cframeSet.CFrame * CFrame.Angles(0, math.pi, 0)) * offsetFromPart
					local snd = script.DoNotChange:Clone()
					snd.Parent = cframeSet
					snd:Play()
					game.Debris:AddItem(snd, .8)
					break
				end
			end
		end
	end
end

userinput.InputBegan:Connect(function(inputObj, proc)
	if not proc then
		local keycode = inputObj.KeyCode
		if keycode == Enum.KeyCode.F or keycode == Enum.KeyCode.ButtonX then
			flip()
		end
	end
end)

if userinput.TouchEnabled and not userinput.KeyboardEnabled then
	local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	gui.ResetOnSpawn = false
	userinput.TouchTap:Connect(function(touches, proc)
		if not proc then
			for _, pos in pairs(touches) do
				local res = gui.AbsoluteSize
				local centerVect = res / 2
				local centerTapCircleSize = res.Y * .2
				if (pos - centerVect).Magnitude < centerTapCircleSize then
					flip()
					break
				end
			end
		end
	end)
end