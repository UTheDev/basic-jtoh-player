-- main script responsible for running server-sided code

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remote = ReplicatedStorage:WaitForChild("BasicJToHPlayer"):WaitForChild("Remote")
local BasicJToHServer = script.Parent

local RemoteCooldown = require(BasicJToHServer:WaitForChild("RemoteCooldown"))
local LevelSession = require(BasicJToHServer:WaitForChild("LevelSession"))

-- put the levels into replicated storage for canister mode
local Levels = workspace:WaitForChild("Levels")

Levels.Parent = nil

-- get rid of studio archive
ServerStorage:WaitForChild("Archive"):Destroy()

-- make a music folder
local MusicFolder = game:GetService("ServerStorage"):WaitForChild("BackgroundMusic")
MusicFolder.Name = "BackgroundMusic"

local BGMusicZones = Instance.new("Folder")
BGMusicZones.Name = "BackgroundMusicZones"

-- Server stores the client objects until a client needs them
--local ClientObjects = {}

-- put all of the level music into the folder
local function addMusicZoneFolder(inst: Instance)
	inst:WaitForChild("Music").Parent = BGMusicZones
end

for i, v in pairs(Levels:GetChildren()) do
	addMusicZoneFolder(v)
end
addMusicZoneFolder(workspace:WaitForChild("Lobby"))

BGMusicZones.Parent = MusicFolder

-- Allow players to enter and leave levels
local OnPlayerWin = Remote:WaitForChild("OnPlayerWin")

local requestLevelCooldowns = RemoteCooldown.new(3)
local levelSessions = {}

local function removeLevelSession(player)
	local session = levelSessions[player]

	if session then
		levelSessions[player] = nil
		session:stop()
	end
end

Players.PlayerRemoving:Connect(removeLevelSession)

Remote:WaitForChild("StopLevel").OnServerInvoke = function(player: Player, winData)
	if player and player.Parent == Players then
		-- make sure they aren't requesting too quickly
		local userId = player.UserId
		if requestLevelCooldowns:canFire(userId) then
			task.spawn(function()
				requestLevelCooldowns:add(userId)
			end)
		else
			return false, "Requesting too quickly"
		end
		
		local currentSession = levelSessions[player]
		if not currentSession then
			return false, "Not in a level"
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
		OnPlayerWin:FireAllClients(player, currentSession.levelId, winData.time)
		
		return true, nil
	end

	return false, ""
end

Remote:WaitForChild("RequestLevel").OnServerInvoke = function(player: Player, entryData)
	if player and player.Parent == Players then
		local userId = player.UserId
		if requestLevelCooldowns:canFire(userId) then
			task.spawn(function()
				requestLevelCooldowns:add(userId)
			end)
		else
			return false, "Requesting too quickly"
		end
		
		if levelSessions[player] then
			return false, "Already in a level"
		end
		
		if typeof(entryData) ~= "table" then
			return false, "No entryData was provided (as a table)"
		end

		local levelId = entryData.levelId
		if typeof(levelId) ~= "string" then
			return false, "No levelId was provided (as a string)"
		end
		
		local newSession = LevelSession.new(player, levelId)
		levelSessions[player] = newSession
		newSession:start()
		
		-- player starts the level
		return true
	end
	
	return false, "Probably left the game"
end

local function onPlayerJoin(player: Player)
	player.CharacterAdded:Connect(function()
		removeLevelSession(player)
	end)
end

for i, v in pairs(Players:GetPlayers()) do
	onPlayerJoin(v)
end
Players.PlayerAdded:Connect(onPlayerJoin)

Levels.Parent = ReplicatedStorage
MusicFolder.Parent = ReplicatedStorage