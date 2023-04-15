--[[
Runs levels on the client
]]
--

local CHAR_SPAWN_HEIGHT = 5

local ClientObjectPlayer = require(script.Parent:WaitForChild("ClientObjectPlayer"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Signal"))

local localPlayer = game:GetService("Players").LocalPlayer

local ClientLevelPlayer = {}
ClientLevelPlayer.__index = ClientLevelPlayer

local function getPlayerRootPart()
	local character = localPlayer.Character

	if character then
		local primaryPart = character:WaitForChild("HumanoidRootPart")

		if primaryPart then
			return primaryPart
		end
	end

	return nil
end

-- constructor
function ClientLevelPlayer.new()
	local self = setmetatable({}, ClientLevelPlayer)
	local remote = game:GetService("ReplicatedStorage"):WaitForChild("BasicJToHPlayer"):WaitForChild("Remote")

	self.remoteRequestLevel = remote:WaitForChild("RequestLevel")
	self.remoteStopLevel = remote:WaitForChild("StopLevel")

	self.isPlayingLevel = false
	self.currentLevel = nil
	self.levels = {}

	--[[
		<number>
		The number of seconds that the current
		level session has lasted.
	]]
	--
	self.currentTime = 0

	self.defaultWinroomSpawn = workspace:WaitForChild("Winrooms"):WaitForChild("Default"):WaitForChild("SpawnLocation")

	--[[
		Fired when currentTime changes

		@param currentTime <number> - The new value of currentTime
	]]
	--
	self.onCurrentTimeChange = Signal.new()

	--[[
		Fired when currentLevel changes

		@param newCurrentLevel <{}> - The new value of currentLevel
	]]
	--
	self.onCurrentLevelChange = Signal.new()

	return self
end

--[[
Registers a level model so it can be handled by the player

@param <Instance> levelInst - The level's model/folder
]]
--
function ClientLevelPlayer:register(levelInst: Instance)
	local levelStore = {}
	local coFolder = levelInst:FindFirstChild("ClientSidedObjects")

	levelStore.id = levelInst.Name
	levelStore.model = levelInst

	if coFolder then
		levelStore.coSession = ClientObjectPlayer.new(coFolder, coFolder.Parent)
	end

	table.insert(self.levels, levelStore)
end

function ClientLevelPlayer:setCurrentTime(currentTime: number)
	self.currentTime = currentTime
	self.onCurrentTimeChange:Fire(currentTime)
end

function ClientLevelPlayer:setCurrentLevel(currentLevel: {}?)
	self.currentLevel = currentLevel
	self.onCurrentLevelChange:Fire(currentLevel)
end

function ClientLevelPlayer:disconnectWinpad()
	local winpadTouchConnection = self.winpadTouchConnection
	if winpadTouchConnection then
		winpadTouchConnection:Disconnect()
		self.winpadTouchConnection = nil
	end
end

--[[
Stops the current level session if there is one
]]
--
function ClientLevelPlayer:stop(keepCurrentLevel: boolean?)
	self.isPlayingLevel = false
	self:disconnectWinpad()

	local currentLevel = self.currentLevel

	if currentLevel then
		local coSession = currentLevel.coSession
		if coSession then
			coSession:stop()
		end

		if not keepCurrentLevel then
			self:setCurrentLevel(nil)
		end
	end
end

--[[
Requests that the current level session be stopped because the
player won
]]
--
function ClientLevelPlayer:requestWin()
	self.isPlayingLevel = false

	local currentLevel = self.currentLevel
	if currentLevel then
		local success, result = self.remoteStopLevel:InvokeServer({
			--win = true,
			time = self.currentTime * 1000,
		})

		if success then
			self:stop(true)

			local winroomSpawn = self.defaultWinroomSpawn
			if winroomSpawn then
				local primaryPart = getPlayerRootPart()

				if primaryPart then
					primaryPart.CFrame = winroomSpawn.CFrame:ToWorldSpace(
						CFrame.new(Vector3.new(0, (winroomSpawn.Size.Y / 2) + (CHAR_SPAWN_HEIGHT / 2), 0))
					)
				end
			end
		else
			warn("Win request failed: " .. tostring(result))
		end
	end
end

function ClientLevelPlayer:canTimerRun()
	return self.isPlayingLevel and self.currentLevel
end

function ClientLevelPlayer:runTimerUntilStop()
	self:setCurrentTime(0)

	while self:canTimerRun() do
		local delta = task.wait()

		if self:canTimerRun() then
			self:setCurrentTime(self.currentTime + delta)
		end
	end
end

--[[
Runs a play session of a level if one isn't being played already

@param <String> levelId - The ID of the level to run (e.g. ToET)
]]
--
function ClientLevelPlayer:play(levelId: string)
	assert(typeof(levelId) == "string", "Argument 1 must be a string.")

	local currentLevel = self.currentLevel
	if currentLevel then
		warn("Cannot start level because one is already in session: " .. currentLevel.id)
		return
	end

	-- just in case
	if self.isPlayingLevel then
		return
	end

	local level
	for i, v in pairs(self.levels) do
		if v.id == levelId then
			level = v
			break
		end
	end

	if level then
		local success, result = self.remoteRequestLevel:InvokeServer({
			levelId = level.id,
		})

		if success then
			self.isPlayingLevel = true
			self:setCurrentLevel(level)

			local model = level.model
			local coSession = level.coSession

			-- run client objects
			if coSession then
				coSession:run()
			end

			-- winpad connection
			local winpad = model:FindFirstChild("Winpad")
			if winpad then
				local isTouchingWinpad = false
				self.winpadTouchConnection = winpad.Touched:Connect(function()
					if not isTouchingWinpad then
						isTouchingWinpad = true
						self:requestWin()
						isTouchingWinpad = false
					end
				end)
			end

			-- spawn the player into the level
			local levelSpawn = model:WaitForChild("SpawnLocation")
			if levelSpawn then
				local primaryPart = getPlayerRootPart()
				if primaryPart then
					primaryPart.CFrame = levelSpawn.CFrame:ToWorldSpace(
						CFrame.new(Vector3.new(0, (levelSpawn.Size.Y / 2) + (CHAR_SPAWN_HEIGHT / 2), 0))
					)
				end
			end

			self:runTimerUntilStop()
		else
			warn("Failed to start level: " .. tostring(result))
		end
	else
		warn(
			"Could not play " .. levelId .. " because it hasn't been registered by this instance of ClientLevelPlayer."
		)
	end
end

return ClientLevelPlayer
