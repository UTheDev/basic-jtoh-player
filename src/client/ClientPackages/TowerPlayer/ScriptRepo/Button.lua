--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local p=script.Parent.Parent
local plr=game.Players.LocalPlayer
local unpressedcf=script.Parent.CFrame
local pressedcf=unpressedcf*CFrame.new(0,-script.Parent.Size.Y*.75,0)
local ts=game:GetService'TweenService'
local invert=p:FindFirstChild'Invert' and p.Invert.Value
local ch=0
function tween(part,time,inf)
	local tweeninf=TweenInfo.new(
		time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tw=ts:Create(part,tweeninf,inf)
	tw:Play()
end
function update(v)
	local truev=v
	if invert then v=not v end
	local invertedbutton
	local pressedbutton
	for n,b in pairs(_G.Buttons[script.Parent.Color]) do
		if n~='Active' then
			local isinvert=b:FindFirstChild'Invert' and b.Invert.Value
			local ispressed=b:FindFirstChild'Pressed' and b.Pressed.Value
			if ispressed then pressedbutton=true end
			if isinvert and ispressed then invertedbutton=true end
			local invertfactor=isinvert and not ispressed
		end
	end
	if not invert and (pressedbutton and not truev) then return end
	if not pressedbutton and invert then return end
	if invertedbutton and not invert then return end
	for _,pl in pairs(p.Parent:GetDescendants()) do
		if pl:IsA'BasePart' then
			local v=v
			local c=pl.Color
			local co=pl:FindFirstChild'ColorOverride'
			if co then
				c=co.Value
			end
			c=Color3.fromRGB(math.floor(c.r*255 + 0.5),math.floor(c.g*255 + 0.5),math.floor(c.b*255 + 0.5))
			if pl:FindFirstChild'Invert' then v=not v end
			local function asfd()
				for _,d in pairs(pl:GetDescendants()) do
					if d:IsA'ParticleEmitter' then
						d.Enabled=v
					end
					if d:IsA'Decal' or d:IsA'Texture' then
						tween(d,.3,{Transparency=(v and 0 or (pl:FindFirstChild'FullHide' and 1 or .6))})
					end
					if d.Name=='Activated' and d:IsA'BoolValue' then
						d.Value=v
					end
				end
			end
			local samecolor=c==Color3.fromRGB(math.floor(script.Parent.Color.r*255 + 0.5),math.floor(script.Parent.Color.g*255 + 0.5),math.floor(script.Parent.Color.b*255 + 0.5))
			if (pl.Name=='ButtonActivatedPlatform' or pl:FindFirstChild("ButtonActivated") ~= nil) and samecolor then
				asfd()
				if not pl:FindFirstChild"IgnoreCanCollide" and not pl:FindFirstChild"IgnoreAll" then
					pl.CanCollide=v
				end
				if not pl:FindFirstChild"IgnoreTransparency" and not pl:FindFirstChild"IgnoreAll" then
					tween(pl,.3,{Transparency=(v and 0 or (pl:FindFirstChild'FullHide' and 1 or .6))})
				end
			end
		end
	end
end
return function()
	local pr=p:WaitForChild'Pressed'
	local snd=script.Parent:WaitForChild'Press'
	update(false)
	pr.Changed:Connect(function(v)
		ch=ch+1
		script.Parent.Material=v and 'Neon' or 'Metal'
		if script.Parent.Anchored then
			tween(script.Parent,1,{CFrame=(v and pressedcf or unpressedcf)})
		end
		if v then snd:Play() end
		update(v)
	end)
	script.Parent.Touched:Connect(function(t)
		local h=t.Parent:FindFirstChild'Humanoid'
		local yesplr=p.SupportPlayers.Value and h and game.Players:GetPlayerFromCharacter(t.Parent)==plr
		local yesbox=p.SupportPushboxes.Value and t.Name=='Pushbox' and not (p.ColorSpecific.Value and t.Color ~= script.Parent.Color)
		local yesbal=p.SupportBalloons.Value and 
			t.Name == "Part" and t.Material == Enum.Material.Neon and t:FindFirstChild("BodyVelocity") and not (p.ColorSpecific.Value and t.Color ~= script.Parent.Color)
		if (yesplr or yesbox or yesbal) and not pr.Value then
			pr.Value=true
			if p:FindFirstChild('Timer') and p.Timer.Value>0.01 then
				local pre=ch
				local sg=Instance.new('SurfaceGui')
				sg.Face='Top'
				sg.CanvasSize=Vector2.new(100,100)
				local txt=Instance.new('TextLabel',sg)
				txt.BackgroundTransparency=1
				local c=script.Parent.Color
				txt.Size=UDim2.new(1,0,1,0)
				txt.BackgroundTransparency=1
				txt.TextColor3=Color3.new(1-c.r,1-c.g,1-c.b)
				txt.TextScaled=true
				txt.Text=p.Timer.Value
				if _G.AttachTimer then
					_G:AttachTimer(script.Parent,txt)
				end
				sg.Parent=script.Parent
				for i=p.Timer.Value,1,-1 do
					if ch~=pre then break end
					txt.Text=i
					wait(1)
				end
				sg:Destroy()
				if ch==pre then pr.Value=false end
			end
		end
	end)
end