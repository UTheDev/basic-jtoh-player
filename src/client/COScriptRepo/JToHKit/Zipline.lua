--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local ts=game:GetService'TweenService'
function tween(part,time,inf)
	local tweeninf=TweenInfo.new(
		time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tw=ts:Create(part,tweeninf,inf)
	tw:Play()
end
local PV=script.Parent:FindFirstChild'PropelVelocity' and script.Parent.PropelVelocity.Value or 0
local EPC=script.Parent.PC
local userinput=game:GetService('UserInputService')
local NOJUMPALLOWED=script.Parent:FindFirstChild'CannotDismount' and script.Parent.CannotDismount.Value
return function()
	local Riding = false
	local DecoRope = Instance.new("RopeConstraint")
	DecoRope.Length = EPC.UpperLimit-1
	DecoRope.Color = script.Parent.BrickColor--BrickColor.new("Really black")
	DecoRope.Visible = true
	DecoRope.Thickness = 0.2
	local R1 = Instance.new("Attachment")
	R1.Position = Vector3.new(0,0,-EPC.UpperLimit)
	R1.Parent = script.Parent
	DecoRope.Attachment0 = script.Parent.Start
	DecoRope.Attachment1 = R1
	DecoRope.Parent = script.Parent.Parent
	DecoRope.Name = "DecoRope"
	local val
	if script.Parent:FindFirstChild("ButtonActivated") ~= nil then
		val=Instance.new('BoolValue',script.Parent)
		val.Name='Activated'
	end
	script.Parent.Touched:Connect(function(part)
		local plr = game.Players:GetPlayerFromCharacter(part.Parent)
		if part.Parent:FindFirstChild("Humanoid") and not (val and not val.Value) and plr == game.Players.LocalPlayer then
			if Riding ~= true then
				Riding = true
				EPC.Parent = nil
				local autodisconnect
				local h=part.Parent.Humanoid
				if not NOJUMPALLOWED then
					userinput.JumpRequest:Connect(function()
						autodisconnect=true
					end)
				end
				local ZPA = Instance.new("Animation")
				ZPA.AnimationId = "rbxassetid://3268037702"
				local ZPAT = part.Parent:FindFirstChild("Humanoid"):LoadAnimation(ZPA)
				part.Parent:WaitForChild("Humanoid").PlatformStand = true
				local Rope = Instance.new("RopeConstraint")
				local RopeGuide = Instance.new("Part")
				local RopeBar = Instance.new("Part")
				local A2 = Instance.new("Attachment")
				local P1 = Instance.new("Attachment")
				local P2 = Instance.new("Attachment")
				local Weld = Instance.new("WeldConstraint")
				local PC = EPC:Clone()
				local BV=Instance.new('BodyVelocity')
				PC.Parent = script.Parent
				BV.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
				BV.Velocity=script.Parent.CFrame.LookVector*PV
				BV.P = 100
				local BG=Instance.new('BodyGyro')
				BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
				RopeBar.Size = Vector3.new(4,0.4,0.4)
				RopeBar.CanCollide = false
				RopeBar.CFrame = part.Parent:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0,2.6,0)
				RopeBar.CustomPhysicalProperties = PhysicalProperties.new(10,0,0)
				RopeBar.Color = script.Parent.Color
				RopeGuide.Size = Vector3.new(1,1,1)
				RopeGuide.CanCollide = false
				RopeGuide.Color=script.Parent.Color
				RopeGuide.Transparency = 1
				RopeGuide.CustomPhysicalProperties = PhysicalProperties.new(20,0,0) 
				RopeGuide.CFrame = script.Parent.CFrame
				A2.Parent = RopeGuide
				PC.Attachment1 = A2
				P1.Parent = RopeGuide
				P2.Parent = RopeBar
				Rope.Length = 8
				Rope.Visible = true
				Rope.Color = script.Parent.BrickColor--BrickColor.new("Really black")
				Rope.Attachment0 = P1
				Rope.Attachment1 = P2
				Rope.Parent = RopeGuide
				if PV~=0 then
					BV.Parent = RopeGuide
				end
				RopeBar.Parent = script.Parent.Parent
				BG.Parent = RopeBar
				BG.CFrame = script.Parent.CFrame
				Weld.Part0 = part.Parent:FindFirstChild("HumanoidRootPart")
				Weld.Part1 = RopeBar
				Weld.Parent = RopeBar
				RopeGuide.Parent = script.Parent.Parent
				ZPAT:Play()
				repeat wait() part.Parent:WaitForChild("Humanoid").PlatformStand = true until not part or not part.Parent or not script or not script.Parent or not PC or PC.CurrentPosition >= PC.UpperLimit or autodisconnect or part.Parent:WaitForChild("Humanoid").Health<=0
				if PC then PC:Destroy() end
				Weld:Destroy()
				Riding=false
				RopeBar.CanCollide=false
				RopeGuide.CanCollide=false
				if not autodisconnect then
					PC.Attachment1=nil
				end
				BG:Destroy()
				RopeBar:Destroy()
				RopeGuide:Destroy()
				ZPAT:Stop()
				ZPAT:Destroy()
				part.Parent:WaitForChild("Humanoid").PlatformStand = false
				(part.Parent:WaitForChild("Humanoid")):ChangeState'Jumping'
			end
		end
	end)
end