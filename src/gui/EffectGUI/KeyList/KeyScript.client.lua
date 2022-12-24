--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local p = script.Parent
local ex = p.KeyPreview
ex.Parent = nil
p.Visible = true

local pickupsnd = 'rbxassetid://424002310'
local unlocksnd = 'rbxassetid://4381793351'
local keylist = {} --keys detected
local keydoorlist = {} --key doors detected
local keys = {} --keys the player owns

local trails = {}
local increment = 20
local trailPos --center position of the current trail position, adds to the trail and resets to the character position when the character moves a distance
local trailLogLimit = 100 --how far it may log the trail
local trailThreshold = 2 / increment --distance from trailPos to where it adds to the trail list

local altKeyDisplayLimit = 5 --if the key limit setting isn't detected, it will set to this

local cam = Instance.new('Camera')
cam.Name = 'KeyPreviewCamera' --USELESS CODE LOL XD
cam.CFrame = CFrame.new(Vector3.new(0, 0, 4), Vector3.new())
ex.CurrentCamera = cam

local ts = game:GetService'TweenService'
function tween(part, time, inf)
	local tweeninf = TweenInfo.new(time)
	local tw = ts:Create(part, tweeninf, inf)
	tw:Play()
end
function getTrailPosition(p)
	return trails[math.floor((p * increment) / 3)] or trails[#trails] or 
	(game.Players.LocalPlayer.Character and game.Players.LocalPlayer:FindFirstChild"HumanoidRootPart" and game.Players.LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.new()
	--wow that's a long list of failsafes lol
end
function PlaySound(p, id)
	if p:FindFirstChild'ReplaceSound' then
		p.ReplaceSound:Play()
	else
		local s = Instance.new('Sound',p)
		s.SoundId = id
		s.Volume = 4
		s:Play()
		game.Debris:AddItem(s, 5)
	end
end
function findKey(id) --searches the collected key list for the id, if it finds it then it returns it here
	local nu
	local kInfo
	for num, k in pairs(keys) do
		if k.id == id then
			kInfo = k
			nu = num
			break
		end
	end
	return kInfo, nu
end
function isKeyInList(key)
	for num, k in pairs(keys) do
		if k.key == key then
			return num, k
		end
	end
end

function AddKey(id,key, cl)
	local pkey = cl:Clone()
	local keysid = #keys + 1
	local exc = ex:Clone()
	exc.Name = id
	pkey:SetPrimaryPartCFrame(CFrame.new())
	pkey.Parent = exc
	exc.LayoutOrder = keysid
	exc.Visible = false --start as invisible
	keys[keysid] = {id = id, gui = exc, key = key}
	exc.Parent = p
	return keys[keysid]
end
function RemoveKey(id, keyReturn)
	local kInfo, nu
	if type(id) == "userdata" then --assume that it is a key instance
		nu, kInfo = isKeyInList(id)
	else
		kInfo, nu = findKey(id)
	end
	if kInfo then
		kInfo.gui:Destroy()
		if not keyReturn then
			game.Debris:AddItem(kInfo.key, .2)
			kInfo.key.KeyID:Destroy()
		else
			local c = Instance.new("BoolValue", kInfo.key)
			c.Name = "Cooldown"
			game.Debris:AddItem(c, 2)
		end
		table.remove(keys, nu)
		return kInfo.key
	end
	return false
end

function CheckDescendant(d)
	wait(.2)
	local par = d.Parent
	if d.Name == 'KeyID' and d.Parent then
		local kh = d.Parent:FindFirstChild'KeyHitbox'
		if kh then
			kh.Transparency = 1
			local db = true
			if d:FindFirstChild'Door' then --classify as door
				kh.Touched:Connect(function(t)
					if db and game.Players:GetPlayerFromCharacter(t.Parent)==game.Players.LocalPlayer then
						local key = RemoveKey(d.Value)
						if not key then return end
						if key then
							local v = Instance.new("Vector3Value", key)
							v.Name = "MoveToP"
							v.Value = kh.Position
						end
						db = false
						PlaySound(kh,unlocksnd)
						for _,ds in pairs(par:GetDescendants()) do
							if ds:IsA'BasePart' then
								if ds.Name == 'Fall' then
									ds.Anchored = false
									ds.CanCollide = false
									ds.RotVelocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
									ds.Velocity = Vector3.new(math.random(-30,30),math.random(-30,30),math.random(-30,30))
									ds:BreakJoints()
								elseif ds.Name == 'Vanish' then
									tween(ds, .5, {Transparency = 1})
									ds.CanCollide = false
									delay(.5,function()
										ds:Destroy()
									end)
								end
							end
						end
					end
				end)
			else --classify as a key
				local key = d.Parent
				local kc = par:Clone()
				local parts = {}
				local defPos = kh.Position
				local defPar = key.Parent
				key:SetPrimaryPartCFrame(CFrame.new(kh.Position))
				for _, kp in pairs(key:GetDescendants()) do --oh man, advanced stuff because FLOATING POINT MISALIGNEMTENDRS
					if kp:IsA"BasePart" and kp ~= kh then
						parts[kp] = kp.CFrame * kh.CFrame:inverse()
						kp.CanCollide = false
					end
				end
				local curRot = 0
				local rotSpeed = 2
				local moveSpeed = .1
				
				local setTimer = key:FindFirstChild"Timer" and key.Timer:IsA"NumberValue" and key.Timer.Value > 0 and key.Timer.Value
				local beginTime
				local timerBill
				local timerGui
				
				local kCon
				kCon = game:GetService('RunService').RenderStepped:Connect(function() --this will be really complex huh
					local moveTo = defPos
					local kN, kI = isKeyInList(key)
					if not kN then db = true end
					if (not d or not key or not kh or not kh.Parent) and kCon then kCon:Disconnect() return end
					if key:FindFirstChild"MoveToP" then
						moveTo = key.MoveToP.Value
					else
						if kN then
							moveTo = getTrailPosition(kN)
						end
					end
					if beginTime and not key:FindFirstChild"MoveToP" then
						local timeLeft = math.max(math.floor(math.abs(setTimer - (tick() - beginTime))), 0)
						if timerBill then timerBill.Time.Text = timeLeft end
						if timerGui then timerGui.Time.Text = timeLeft end
						if timeLeft <= 0 then
							timerBill:Destroy()
							timerGui = nil
							beginTime = nil
							RemoveKey(key, true)
						end
					end
					if kN and kN > (_G.KeyDisplayLimit or altKeyDisplayLimit) then
						key.Parent = nil
					else
						key.Parent = defPar
					end
					if kI and kI.gui then
						kI.gui.Visible = not key.Parent
					end
					curRot = (curRot + rotSpeed) % 360
					if (moveTo - workspace.CurrentCamera.CFrame.Position).magnitude < 100 or kN then
						key:SetPrimaryPartCFrame(CFrame.new(kh.Position:lerp(moveTo, moveSpeed)) * CFrame.Angles(0, math.rad(curRot), 0))
					end
					for pt, p in pairs(parts) do
						pt.CFrame = kh.CFrame * p
					end
				end)
				kh.Touched:Connect(function(t)
					if d and d.Parent and db and game.Players:GetPlayerFromCharacter(t.Parent) == game.Players.LocalPlayer and not isKeyInList(key) and not key:FindFirstChild"Cooldown" then
						db = false
						local hb = kh:Clone()
						hb.Parent = workspace
						local e = script.Effect:Clone()
						e.Parent = hb
						e:Emit(math.random(20,50))
						PlaySound(hb, pickupsnd)
						game.Debris:AddItem(hb, 5)
						local inf = AddKey(d.Value, key, kc)
						if setTimer then
							beginTime = tick()
							timerBill = script.KeyTimer:Clone()
							timerBill.Parent = kh
							timerBill.Enabled = true
							timerGui = inf.gui
						end
					end
				end)
			end
		end
	end
end
for _, d in pairs(workspace:GetDescendants()) do spawn(function()
		CheckDescendant(d)
	end) end
workspace.DescendantAdded:Connect(CheckDescendant)
for _,kt in pairs(workspace:GetDescendants()) do
	if kt:FindFirstChild"ReturnKey" and kt.ReturnKey:IsA"StringValue" then
		kt.Touched:Connect(function(t)
			if not t.Parent or game.Players:GetPlayerFromCharacter(t.Parent) ~= game.Players.LocalPlayer then return end
			RemoveKey(kt.ReturnKey.Value, true)
		end)
	end
end
while wait(.05) do
	local trail = trails
	local char = game.Players.LocalPlayer.Character
	if char and char:FindFirstChild"HumanoidRootPart" then
		local hrp = char.HumanoidRootPart
		if not trailPos or (hrp.Position - trailPos).magnitude > trailThreshold then
			--move up in the trail list
			trail = {} --dump the list here to recount, is this even necessary hahahaha too lazy
			table.insert(trail, 1, trailPos) --add the trail position, first thing
			for num, t in pairs(trails) do if num <= trailLogLimit * increment then table.insert(trail, num + 1, t) end end --add the other trails to the list
			trailPos = hrp.Position
		end
	end
	trails = trail --update the list once done counting
end