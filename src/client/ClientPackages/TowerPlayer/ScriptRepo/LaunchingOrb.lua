--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local sounds = {
	Trigger = "rbxassetid://12222124",
	Launch = "rbxassetid://84318179",
}

function Play(snd,par)
	local s = Instance.new('Sound',par)
	s.SoundId = sounds[snd] or ''
	s:Play()
	game.Debris:AddItem(s, 10)
	return s
end

function tween(p, time, t)
	game:GetService("TweenService"):Create(p, TweenInfo.new(time), t):Play()
end

local deb = true

return function()
	local force = script.Parent:FindFirstChild("Force") and script.Parent.Force.Value or 100
	local orb = script.Parent
	local orb2 = orb:Clone()
	orb2:ClearAllChildren()
	orb2.Size = orb.Size * 1.5
	orb2.Transparency = .5
	orb2.Parent = orb
	local oSize = orb.Size
	local o2Size = orb2.Size
	script.Burst.Parent = orb
	orb.Touched:Connect(function(t)
		local c = t.Parent
		if c and game.Players:GetPlayerFromCharacter(c) == game.Players.LocalPlayer and c:FindFirstChild"HumanoidRootPart" and c:FindFirstChild"Humanoid"
		and c.Humanoid:FindFirstChild"Animator" and c:FindFirstChild"Head" and deb and not c.HumanoidRootPart:FindFirstChild"LaunchParticles" then
			deb = false
			local char = t.Parent
			local hrp = char:FindFirstChild"HumanoidRootPart"
			hrp.Anchored = true
			tween(hrp, .3, {CFrame = CFrame.new(orb.Position) * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)})
			Play("Trigger", orb).Pitch = 1.3
			tween(orb, .5, {Size = o2Size})
			tween(orb2, .5, {Size = o2Size})
			local oAnim = char.Humanoid.Animator:LoadAnimation(script.Fly)
			wait(.5)
			oAnim:Play()
			orb.Transparency = 1
			orb2.Transparency =  1
			orb.Size = oSize
			orb2.Size = o2Size
			orb.Burst:Emit(40)
			local launchP = script.LaunchParticles:Clone()
			launchP.Parent = hrp
			launchP.Enabled = true
			local launch = Instance.new("BodyVelocity")
			launch.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			launch.Velocity = Vector3.new(0, force, 0)
			launch.Parent = hrp
			Play("Launch", hrp).Pitch = .6
			hrp.Anchored = false
			local touch
			wait(.2)
			touch = char.Head.Touched:Connect(function(t)
				if not t:IsDescendantOf(char) and (t.CanCollide or t.Name == "OrbLaunchStopper") then
					game.Debris:AddItem(launch, .3)
					launchP.Enabled = false
					oAnim:Stop()
					game.Debris:AddItem(launchP, 2)
					tween(orb, 1, {Transparency = 0})
					tween(orb2, 1, {Transparency = .5})
					wait(1)
					deb = true
				end
			end)
		end
	end)	
end