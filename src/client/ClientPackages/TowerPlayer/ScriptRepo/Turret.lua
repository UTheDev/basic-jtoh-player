--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local holysize=math.huge
return function()
	local p=script.Parent
	local plr=game.Players.LocalPlayer
	local holesize=math.huge
	p.FrontSurface='Smooth'
	if p.Size.X<holesize then holesize=p.Size.X end
	if p.Size.Y<holesize then holesize=p.Size.Y end
	local bulletsize=holesize*.9
	if p.Size.Z<bulletsize then bulletsize=p.Size.Z end
	local h=Instance.new('Part')
	h.Name='Hole'
	h.CanCollide=false
	h.Color=Color3.new()
	h.Material='Neon'
	h.Shape='Cylinder'
	h.Size=Vector3.new(.1,holesize,holesize)
	h.CFrame=(p.CFrame*CFrame.new(0,0,-p.Size.Z/2))*CFrame.Angles(0,math.pi/2,0)
	local w=Instance.new('WeldConstraint',p)
	w.Part0=p
	w.Part1=h
	h.Parent=p
	while wait(p.Delay.Value) do
		local c=plr.Character
		if c and c.PrimaryPart then
			local pp=c.PrimaryPart
			if (pp.Position-p.Position).magnitude<p.Distance.Value then
				local c=p.Fire:Clone()
				c.Name='SoundEffect'
				c.Parent=p
				c:Play()
				game.Debris:AddItem(c,5)
				local b=Instance.new('Part')
				b.Name='Bullet'
				b.CanCollide=false
				b.Color=p.Color
				b.Material='Neon'
				b.Shape='Ball'
				b.Size=Vector3.new(bulletsize,bulletsize,bulletsize)
				b.CFrame=p.CFrame
				local bv=Instance.new('BodyVelocity',b)
				bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
				bv.Velocity=b.CFrame.lookVector*p.Speed.Value
				b.Parent=p
				game.Debris:AddItem(b,30)
				b.Touched:Connect(function(t)
					if t.CanCollide and t~=p and t.Parent~=p then
						b:Destroy()
						local h=t.Parent:FindFirstChild'Humanoid'
						if h and t:IsDescendantOf(plr.Character) then
							game.ReplicatedStorage.DamageEvent:FireServer(h,p.Damage.Value)
						end
					end
				end)
			end
		end
	end
end