--[[
Runs client objects for a tower

Various code within this module is from LocalPartScript written
by Jukereise and Gammattor, creators of Juke's Towers of Hell
]]
--

local CLIENT_OBJECT_NAME = "ClientObject"

local PhysicsService = game:GetService("PhysicsService")

local InstanceLocator = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("Softlocked")
		:WaitForChild("InstanceHandling")
		:WaitForChild("InstanceLocator")
)

local ClientObjectScriptRepo =
	InstanceLocator.waitForChildByPath(game.Players.LocalPlayer, "PlayerScripts.COScriptRepo")

--[[
	This class is responsible for running a folder full of client objects.
	
	Each time they're actually running, the client object running session is considered to be "active".
]]--
local ClientObjectSession = {}

ClientObjectSession.mt = {}
ClientObjectSession.mt.__index = ClientObjectSession.mt

--[[
	An index of the script repository for quick referencing
]]--
ClientObjectSession.scriptRepoIndex = {}

--[[
	Creates a new ClientObjectSession runner
]]--
function ClientObjectSession.new(clientObjectFolder: Folder, coFolderParent: Instance)
	local self = {}

	self.isRunning = false

	self.clientObjectFolder = clientObjectFolder
	self.coFolderParent = coFolderParent or clientObjectFolder.Parent

	-- {original, original parent, clone}
	self.coClones = {}

	--[[
	<{}>
	list of tables that a client object
	might choose to return
	]]
	--
	self.runningObjects = {}

	clientObjectFolder.Parent = nil

	return setmetatable(self, ClientObjectSession.mt)
end

--[[
	@return Whether or not the object represented by "obj" is a ClientObject value
]]--
function ClientObjectSession.isClientObjectValue(obj: Instance)
	return obj.Name == CLIENT_OBJECT_NAME and obj:IsA("ValueBase")
end

--[[
Stops the script for a specified client object table

@param runningObject The client object table
]]
--
function ClientObjectSession.stopClientObject(runningObject: {stop: () -> ()?})
	local f = runningObject.stop

	if typeof(f) == "function" then
		f()
	end
end

--[[
	Performs indexing of the ClientObject script repository, COScriptRepo
]]
--
function ClientObjectSession.indexCOScriptRepo()
	local indexTable = {}
	for i, v in pairs(ClientObjectScriptRepo:GetDescendants()) do
		if v:IsA("ModuleScript") and indexTable[v.Name] == nil then
			indexTable[v.Name] = v
		end
	end

	ClientObjectSession.scriptRepoIndex = indexTable
end

----- legacy LocalPartScript button code -----
--all of the code below here is no longer used in new buttons but there for compatibility's sake
local function CheckColor3(color)
	--[[
	return pcall(function()
		local yeet = color:lerp(Color3.new(), 1)
	end)
	]]
	--
	return typeof(color) == "Color3"
end
local function GetAllButtons(color)
	local IsColor3 = CheckColor3(color)
	local buttont = {}
	for _, b in pairs(workspace:GetDescendants()) do
		if b.Name == "Button" and b:FindFirstChild("ClientObject") and b:FindFirstChild("Pressed") then
			local doinsert
			if color and IsColor3 then
				for _, d in pairs(b:GetDescendants()) do
					if d:IsA("BasePart") and d.Color == color then
						doinsert = true
					end
				end
			else
				doinsert = true
			end
			if doinsert then
				table.insert(buttont, b)
			end
		end
	end
	return buttont
end

local mt = {}
mt.__index = function(t, i)
	if i == "All" then
		return GetAllButtons()
	end
	return GetAllButtons(i)
end
mt.__newindex = function() end
mt.__call = function(t, mode, val, color)
	if mode == "Get" then
		return GetAllButtons()
	elseif mode == "SetAll" then
		for _, b in pairs(GetAllButtons(color)) do
			b.Pressed.Value = val
		end
	end

	return nil
end

_G.Buttons = setmetatable({}, mt)
-----

--- modified from LocalPartScript ---
local ts = game:GetService("TweenService")
local origlighting = {}
local origcclighting = {}
--if workspace:FindFirstChild('CPBricks') then
--	workspace.CPBricks:Destroy()
--end

function _G:SetLighting(c, ltype)
	if not c then
		return
	end
	local dur = 2
	if ltype == "ColorCorrection" and game.Lighting:FindFirstChild("ColorCorrection") then
		if c == "Default" then
			c = origcclighting
		end
		for l, p in pairs(c) do
			if not origcclighting[l] then
				origcclighting[l] = game.Lighting.ColorCorrection[l]
			end
		end
		local conf = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tw = ts:Create(game.Lighting.ColorCorrection, conf, c)
		tw:Play()
		for l, p in pairs(c) do
			if type(p) == "string" or type(p) == "boolean" then
				game.Lighting.ColorCorrection[l] = p
			end
		end
	else
		if c == "Default" then
			c = origlighting
		end
		for l, p in pairs(c) do
			if not origlighting[l] then
				origlighting[l] = game.Lighting[l]
			end
		end
		local conf = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tw = ts:Create(game.Lighting, conf, c)
		tw:Play()
		for l, p in pairs(c) do
			if type(p) == "string" or type(p) == "boolean" then
				game.Lighting[l] = p
			end
		end
	end
	wait(dur)
end
-----

--[[
Runs the script for a client object

@param coValue A reference to the ValueBase calling the function if applicable
@param coFunc The function returned by the client object

The callback represented by coFunc will have 2 arguments passed to it:
ref <ValueBase> - Whatever was passed into the coValue parameter
coSession <{}> - The current ClientObjectSession
]]
--
function ClientObjectSession.mt:runScript(coValue: ValueBase?, coFunc: (ref: ValueBase?, coSession: {}) -> ({}?))
	-- run the function
	task.spawn(function()
		local result = coFunc(coValue, self)

		-- see if it returns anything we can utilize
		if typeof(result) == "table" then
			if self.isRunning then
				table.insert(self.runningObjects, result)
			else
				-- since certain client objects yield,
				-- we might have to stop it at this point
				ClientObjectSession.stopClientObject(result)
			end
		end
	end)
end

local function getRepoScriptFromStringValue(val: StringValue)
	local repoModule
	if val:GetAttribute("IsAbsolutePath") == true then
		repoModule = InstanceLocator.findFirstChildByPath(ClientObjectScriptRepo, val.Value)
	else
		repoModule = ClientObjectSession.scriptRepoIndex[val.Value]
	end

	if repoModule and repoModule:IsA("ModuleScript") then
		return repoModule
	else
		return nil
	end
end

--[[
Applies CO behavior to the instance specified

@param w The instance to apply the behavior to
]]
--
function ClientObjectSession.mt:applyPart(w: Instance)
	if w:IsA("ModuleScript") then
		if w.Name == "ChangeLighting" then
			for p, l in pairs(require(w)) do
				if not origlighting[p] then
					origlighting[p] = game.Lighting[p]
				end
				game.Lighting[p] = l
			end
		elseif w.Name == "ClientObjectScript" then
			-- handle client object script
			self:runScript(nil, require(w))
		end
	elseif w:IsA("BasePart") then
		if w.Name == "LightingChanger" or w:FindFirstChild("Invisible") then
			w.Transparency = 1
		end

		local collisionGroupVal = w:FindFirstChild("SetCollisionGroup")
		if collisionGroupVal then
			PhysicsService:SetPartCollisionGroup(w, collisionGroupVal.Value)
		end
	elseif w:IsA("StringValue") then
		-- repository script references

		-- some client object scripts there requiring cloning
		-- into the the corresponding ClientObject itself
		-- for them to work
		if w.Name == "RunRepoScript" then
			local scr = getRepoScriptFromStringValue(w) --ClientObjectScriptRepo:FindFirstChild(w.Value)
			if scr then
				scr = scr:Clone()
				scr.Name = "RepoScript"
				scr.Parent = w.Parent

				self:runScript(w, require(scr))
			end
		elseif w.Name == "ReferenceCOScript" then
			local scr = getRepoScriptFromStringValue(w)
			if scr then
				-- for ClientObjectScripts that use a reference
				-- ValueBase to locate the object they act on
				self:runScript(w, require(scr))
			end
		end
	end

	--[[
	if w.Name=='ChangeLighting' then
		for p,l in pairs(require(w)) do
			if not origlighting[p] then
				origlighting[p]=game.Lighting[p]
			end
			game.Lighting[p]=l
		end
	elseif w.Name=='LightingChanger' and w:IsA'BasePart' then
		w.Transparency=1
	elseif w:FindFirstChild'invisible' and w:IsA'BasePart' then
		w.Transparency=1
	elseif w.Name == "RunRepoScript" and w:IsA"StringValue" then
		local scr = ClientObjectScriptRepo:FindFirstChild(w.Value)
		if scr then
			scr = scr:Clone()
			scr.Name = "RepoScript"
			scr.Parent = w.Parent

			self:runScript(w, require(scr))
			--task.spawn(function()
			--	require(scr)()
			--end)
		end
	elseif w.Name == "ClientObjectScript" then
		--delay(.05,function()
		--	spawn(function()
		--		require(w)()
		--	end)
		--end)

		self:runScript(nil, require(w))
	elseif w:IsA("BasePart") then
		if w:FindFirstChild'SetCollisionGroup' then
			--spawn(function()
			PhysicsService:SetPartCollisionGroup(w,w.SetCollisionGroup.Value)
			--end)
		end
		--		spawn(function()
		--			while not game.Players.LocalPlayer.Character do wait() end
		--			while game.Players.LocalPlayer.Character:WaitForChild("Head").CollisionGroupId == 0 do wait() end
		--			w.CollisionGroupId = game.Players.LocalPlayer.Character:WaitForChild("Head").CollisionGroupId
		--		end)
	end
	]]
	--
end

--[[
Runs all client object scripts
]]
--
function ClientObjectSession.mt:run()
	if self.isRunning == false then
		self.isRunning = true

		-- run a clone of the client object folder
		--local coFolderClone = self.clientObjectFolder:Clone()
		--self.coFolderClone = coFolderClone

		-- clone client objects that request cloning
		-- (they'll have that ClientObject value)
		local clientObjectFolder = self.clientObjectFolder

		for i, v in pairs(clientObjectFolder:GetDescendants()) do
			if ClientObjectSession.isClientObjectValue(v) then
				local original = v.Parent
				local clone = original:Clone()
				local originalParent = original.Parent

				table.insert(self.coClones, { original, originalParent, clone })

				-- make sure to not have the original appear when loaded
				original.Parent = nil

				--[[
				local runScript = v:GetAttribute("RunScript")
				if runScript then
					self:runScript(
						clone:FindFirstChild(CLIENT_OBJECT_NAME),
						require(ClientObjectScriptRepo:FindFirstChild(runScript))
					)
				end
				]]
				--

				clone.Parent = originalParent
			end
		end

		--task.wait(0.25)

		for i, v in pairs(clientObjectFolder:GetDescendants()) do
			--if not ClientObjectSession.isClientObjectValue(v) then
			--local clone = v:Clone();

			--local runScript = v:GetAttribute("RunScript")
			--if runScript then
			--	self:runScript(v, require(ClientObjectScriptRepo:FindFirstChild(runScript)));
			--end
			self:applyPart(v)
			--end
		end

		clientObjectFolder.Parent = self.coFolderParent

		--for i, v in pairs(self.clientObjectScripts) do

		--end

		--for i, v in pairs(self.clientObjects) do
		--	-- look for the client object value
		--	local clientObjectVal: ValueBase = v:FindFirstChild("ClientObject")
		--	if not clientObjectVal then
		--		for i, v in pairs(v:GetDescendants()) do
		--			if v.Name == "ClientObject" then
		--				clientObjectVal = v;
		--				break;
		--			end
		--		end

		--		-- if we get to this point,
		--	end

		--	task.spawn(function()
		--		-- call object function and see
		--		-- if it returns a table we can
		--		-- use

		--	end);
		--end
	end
end

--[[
Stops all client objects
]]
--
function ClientObjectSession.mt:stop()
	if self.isRunning then
		self.isRunning = false

		self.clientObjectFolder.Parent = nil

		for i, v in pairs(self.runningObjects) do
			ClientObjectSession.stopClientObject(v)
		end
		self.runningObjects = {}

		--local coFolder = self.clientObjectFolder
		--coFolder.Parent = nil

		-- destroy client object clones
		for i, v in pairs(self.coClones) do
			v[3]:Destroy()

			-- reparent the original
			v[1].Parent = v[2]
		end
		self.coClones = {}
	end
end

-- run initial indexing of the client object script repo
ClientObjectSession.indexCOScriptRepo()

return ClientObjectSession
