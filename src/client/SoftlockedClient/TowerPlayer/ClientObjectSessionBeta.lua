--[[
Runs client objects for a tower

not in use right now
(this is a jumbled mess of an attempt at optimizing this)

by udev2192
]]--

local CLIENT_OBJECT_NAME = "ClientObject"

local PhysicsService = game:GetService("PhysicsService")

local clientObjectScriptRepo = script.Parent:WaitForChild("ClientObjects");

local ClientObjectSession = {};

ClientObjectSession.mt = {};
ClientObjectSession.mt.__index = ClientObjectSession.mt;

-- reference to LocalPartScript
--[[
function ApplyPart(w)
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
		local scr = script.ScriptRepo:FindFirstChild(w.Value)
		if scr then
			scr = scr:Clone()
			scr.Name = "RepoScript"
			scr.Parent = w.Parent
			spawn(function()
				require(scr)()
			end)
		end
	elseif w.Name == "ClientObjectScript" then
		delay(.05,function()
			spawn(function()
				require(w)()
			end)
		end)
	elseif w:IsA("BasePart") then
		if w:FindFirstChild'SetCollisionGroup' then
			spawn(function()
				PhysicsService:SetPartCollisionGroup(w,w.SetCollisionGroup.Value)
			end)
		end
		--		spawn(function()
		--			while not game.Players.LocalPlayer.Character do wait() end
		--			while game.Players.LocalPlayer.Character:WaitForChild("Head").CollisionGroupId == 0 do wait() end
		--			w.CollisionGroupId = game.Players.LocalPlayer.Character:WaitForChild("Head").CollisionGroupId
		--		end)
	end
end
]]--

-- constructor
function ClientObjectSession.new(clientObjectFolder: Folder)
	local self = {};

	self.isRunning = false;
	
	self.clientObjects = {};
	
	-- client object values that request script repository usages
	self.scriptRepoUsages = {};
	
	self.clientObjectScripts = {};
	
	-- which ones are client objects?
	for i, v in pairs(clientObjectFolder:GetChildren()) do
		-- look for client object values
		local coVal = v:FindFirstChild(CLIENT_OBJECT_NAME)
		if coVal then
			table.insert(self.clientObjects, v);
		else
			-- since certain client objects don't
			-- include the client object value as a direct child,
			-- search their descendants
			for i2, v2 in pairs(v:GetDescendants()) do
				if v2.Name == CLIENT_OBJECT_NAME then
					coVal = v2
					table.insert(self.clientObjects, v);
					break;
				end
			end
		end
		
		if coVal:GetAttribute("") then
			
		end
	end
	
	--[[
	<{}>
	list of tables that a client object
	might choose to return
	]]--
	self.runningObjects = {};

	return setmetatable(self, ClientObjectSession.mt);
end

--[[
Stops the script for a specified client object table

Params:
runningObject <{}> - the table
]]--
function ClientObjectSession.stopClientObject(runningObject: {})
	local f = runningObject.stop
	
	if typeof(f) == "function" then
		f()
	end
end

--[[
Runs the script for a client object

Params:
coFunc <function> - The function returned by the client object
]]--
function ClientObjectSession.mt:runScript(coValue: ValueBase, coFunc: (ref: ValueBase) -> ({}?))
	-- run the function
	task.spawn(function()
		local result = coFunc(coValue)
		
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

--[[
Runs all client object scripts
]]--
function ClientObjectSession.mt:run()
	if not self.isRunning then
		self.isRunning = true;
		
		for i, v in pairs(self.clientObjectScripts) do
			
		end

		for i, v in pairs(self.clientObjects) do
			-- look for the client object value
			local clientObjectVal: ValueBase = v:FindFirstChild("ClientObject")
			if not clientObjectVal then
				for i, v in pairs(v:GetDescendants()) do
					if v.Name == "ClientObject" then
						clientObjectVal = v;
						break;
					end
				end

				-- if we get to this point,
			end

			task.spawn(function()
				-- call object function and see
				-- if it returns a table we can
				-- use

			end);
		end
	end
end

--[[
Stops all client objects
]]--
function ClientObjectSession.mt:stop()
	if self.isRunning then
		self.isRunning = false;
		
		for i, v in pairs(runningObjects) do
			
		end
	end
end

return