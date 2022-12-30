--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

unitmass=workspace.Gravity

local p=script.Parent
local m=p.Parent
local vf=nil
local db=true

for _,v in pairs(m:GetDescendants()) do
	if v:IsA("VectorForce") then
		vf=v
	end
end

local totalmass=0
for _,v in pairs(m:GetDescendants()) do
	if v:IsA("BasePart") and v.Anchored==false then
		totalmass=totalmass+((v.Size.X*v.Size.Y*v.Size.Z)*v.CustomPhysicalProperties.Density*unitmass)
	end
end
--print(totalmass)
local defaultforce=Vector3.new(0,0,1)*totalmass + Vector3.new(0,0,100)
vf.Force=Vector3.new(0,0,-1)*totalmass

return function()
	thing=game["Run Service"].Stepped:Connect(function()
		if not p or not p:FindFirstChild('PrismaticConstraint') then
			thing:Disconnect()
			return
		end
		if p.PrismaticConstraint.CurrentPosition >= (p.PrismaticConstraint.UpperLimit-0.2) and db==true then
			db=false
			vf.Force=defaultforce*3
			repeat
				wait(.1)
			until p.PrismaticConstraint.CurrentPosition <= (p.PrismaticConstraint.LowerLimit+0.2)
			vf.Force=defaultforce
			db=true
			
--			game.TweenService:Create(
--				p.PrismaticConstraint,
--				TweenInfo.new(0.6,0,0,0,false,0),
--				{Velocity=50,MotorMaxForce=10000}
--			):Play()
--			wait(0.7)
--			game.TweenService:Create(
--				p.PrismaticConstraint,
--				TweenInfo.new(0.6,0,0,0,false,0),
--				{Velocity=-5000}
--			):Play()
--			wait(0.6)
--			p.PrismaticConstraint.Velocity=0
--			p.PrismaticConstraint.MotorMaxForce=0
--			db=true
		end
	end)
end