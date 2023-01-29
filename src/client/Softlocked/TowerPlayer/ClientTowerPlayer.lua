--[[
Runs towers on the client
]]
--

local CHAR_SPAWN_HEIGHT = 5

local ClientObjectSession = require(script.Parent:WaitForChild("ClientObjectSession"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"):WaitForChild("Signal"))

local localPlayer = game:GetService("Players").LocalPlayer

local ClientTowerPlayer = {}
ClientTowerPlayer.mt = {}
ClientTowerPlayer.mt.__index = ClientTowerPlayer

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
function ClientTowerPlayer.new()
	local self = setmetatable({}, ClientTowerPlayer.mt)
	local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote")

	self.remoteRequestTower = remote:WaitForChild("RequestTower")
	self.remoteStopTower = remote:WaitForChild("StopTower")

	self.isPlayingTower = false
	self.currentTower = nil
	self.towers = {}

	--[[
		<number>
		The number of seconds that the current
		tower session has lasted.
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
		Fired when currentTower changes

		@param newCurrentTower <{}> - The new value of currentTower
	]]
	--
	self.onCurrentTowerChange = Signal.new()

	return self
end

--[[
Registers a tower model so it can be handled by the player

@param <Instance> towerInst - The tower's model/folder
]]
--
function ClientTowerPlayer:register(towerInst: Instance)
	local towerStore = {}
	local coFolder = towerInst:FindFirstChild("ClientSidedObjects")

	towerStore.id = towerInst.Name
	towerStore.model = towerInst

	if coFolder then
		towerStore.coSession = ClientObjectSession.new(coFolder, coFolder.Parent)
	end

	table.insert(self.towers, towerStore)
end

function ClientTowerPlayer:setCurrentTime(currentTime: number)
	self.currentTime = currentTime
	self.onCurrentTimeChange:Fire(currentTime)
end

function ClientTowerPlayer:setCurrentTower(currentTower: {}?)
	self.currentTower = currentTower
	self.onCurrentTowerChange:Fire(currentTower)
end

function ClientTowerPlayer:disconnectWinpad()
	local winpadTouchConnection = self.winpadTouchConnection
	if winpadTouchConnection then
		winpadTouchConnection:Disconnect()
		self.winpadTouchConnection = nil
	end
end

--[[
Stops the current tower session if there is one
]]
--
function ClientTowerPlayer:stop(keepCurrentTower: boolean?)
	self.isPlayingTower = false
	self:disconnectWinpad()

	local currentTower = self.currentTower

	if currentTower then
		local coSession = currentTower.coSession
		if coSession then
			coSession:stop()
		end

		if not keepCurrentTower then
			self:setCurrentTower(nil)
		end
	end
end

--[[
Requests that the current tower session be stopped because the
player won
]]
--
function ClientTowerPlayer:requestWin()
	self.isPlayingTower = false

	local currentTower = self.currentTower
	if currentTower then
		local success, result = self.remoteStopTower:InvokeServer({
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

function ClientTowerPlayer:canTimerRun()
	return self.isPlayingTower and self.currentTower
end

function ClientTowerPlayer:runTimerUntilStop()
	self:setCurrentTime(0)

	while self:canTimerRun() do
		local delta = task.wait()

		if self:canTimerRun() then
			self:setCurrentTime(self.currentTime + delta)
		end
	end
end

--[[
Runs a play session of a tower if one isn't being played already

@param <String> towerId - The ID of the tower to run (e.g. ToET)
]]
--
function ClientTowerPlayer:play(towerId: string)
	assert(typeof(towerId) == "string", "Argument 1 must be a string.")

	local currentTower = self.currentTower
	if currentTower then
		warn("Cannot start tower because one is already in session: " .. currentTower.id)
		return
	end

	-- just in case
	if self.isPlayingTower then
		return
	end

	local tower
	for i, v in pairs(self.towers) do
		if v.id == towerId then
			tower = v
			break
		end
	end

	if tower then
		local success, result = self.remoteRequestTower:InvokeServer({
			towerId = tower.id,
		})

		if success then
			self.isPlayingTower = true
			self:setCurrentTower(tower)

			local model = tower.model
			local coSession = tower.coSession

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

			-- spawn the player into the tower
			local towerSpawn = model:WaitForChild("SpawnLocation")
			if towerSpawn then
				local primaryPart = getPlayerRootPart()
				if primaryPart then
					primaryPart.CFrame = towerSpawn.CFrame:ToWorldSpace(
						CFrame.new(Vector3.new(0, (towerSpawn.Size.Y / 2) + (CHAR_SPAWN_HEIGHT / 2), 0))
					)
				end
			end

			self:runTimerUntilStop()
		else
			warn("Failed to start tower: " .. tostring(result))
		end
	else
		warn("Could not play " .. towerId .. " because it hasn't been registered by this instance of ClientTowerPlayer.")
	end
end

return ClientTowerPlayer
