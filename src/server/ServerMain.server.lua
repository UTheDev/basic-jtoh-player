-- main script responsible for running server-sided code

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remote = ReplicatedStorage:WaitForChild("Remote")
local SoftlockedServer = script.Parent:WaitForChild("SoftlockedServer")

local RemoteCooldown = require(SoftlockedServer:WaitForChild("RemoteCooldown"))
local TowerSession = require(SoftlockedServer:WaitForChild("TowerSession"))

-- put the towers into replicated storage for canister mode
local Towers = workspace:WaitForChild("Towers")

Towers.Parent = nil

-- get rid of studio archive
ServerStorage:WaitForChild("Archive"):Destroy()

-- make a music folder
local MusicFolder = script:WaitForChild("BackgroundMusic")
MusicFolder.Name = "BackgroundMusic"

local BGMusicZones = Instance.new("Folder")
BGMusicZones.Name = "BackgroundMusicZones"

-- Server stores the client objects until a client needs them
local ClientObjects = {}

-- put all of the tower music into the folder
local function addMusicZoneFolder(inst: Instance)
	inst:WaitForChild("Music").Parent = BGMusicZones
end

for i, v in pairs(Towers:GetChildren()) do
	addMusicZoneFolder(v)
end
addMusicZoneFolder(workspace:WaitForChild("Lobby"))

BGMusicZones.Parent = MusicFolder

-- Allow players to enter and leave towers
local OnTowerWin = Remote:WaitForChild("OnTowerWin")

local requestTowerCooldowns = RemoteCooldown.new(3)
local towerSessions = {}

local function removeTowerSession(player)
	local session = towerSessions[player]

	if session then
		towerSessions[player] = nil
		session:stop()
	end
end

Players.PlayerRemoving:Connect(removeTowerSession)

Remote:WaitForChild("StopTower").OnServerInvoke = function(player: Player, winData: {})
	if player and player.Parent == Players then
		-- make sure they aren't requesting too quickly
		local userId = player.UserId
		if requestTowerCooldowns:canFire(userId) then
			task.spawn(function()
				requestTowerCooldowns:add(userId)
			end)
		else
			return false, "Requesting too quickly"
		end
		
		local currentSession = towerSessions[player]
		if not currentSession then
			return false, "Not in a tower"
		end
		
		if typeof(winData) ~= "table" then
			return false, "Win data isn't a table"
		end
		
		local winTime = winData.time
		if typeof(winTime) ~= "number" then
			return false, "No win time provided (number)"
		end
		
		currentSession:stop()
		
		if not currentSession:isWinValid(winTime) then
			player:Kick("Invalid win")
			return false, "nope"
		end
		
		-- let all players know they won
		OnTowerWin:FireAllClients(player, currentSession.towerId, winData.time)
		
		return true
	end
end

Remote:WaitForChild("RequestTower").OnServerInvoke = function(player: Player, entryData: {})
	if player and player.Parent == Players then
		local userId = player.UserId
		if requestTowerCooldowns:canFire(userId) then
			task.spawn(function()
				requestTowerCooldowns:add(userId)
			end)
		else
			return false, "Requesting too quickly"
		end
		
		if towerSessions[player] then
			return false, "Already in a tower"
		end
		
		if typeof(entryData) ~= "table" then
			return false, "No entryData was provided (as a table)"
		end

		local towerId = entryData.towerId
		if typeof(towerId) ~= "string" then
			return false, "No towerId was provided (as a string)"
		end
		
		local newSession = TowerSession.new(player, towerId)
		towerSessions[player] = newSession
		newSession:start()
		
		-- player starts the tower
		return true
	end
	
	return false, "Probably left the game"
end

local function onPlayerJoin(player: Player)
	player.CharacterAdded:Connect(function()
		removeTowerSession(player)
	end)
end

for i, v in pairs(Players:GetPlayers()) do
	onPlayerJoin(v)
end
Players.PlayerAdded:Connect(onPlayerJoin)

Towers.Parent = ReplicatedStorage
MusicFolder.Parent = ReplicatedStorage