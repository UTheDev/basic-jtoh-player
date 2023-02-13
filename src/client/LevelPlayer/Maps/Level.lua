local CHAR_SPAWN_HEIGHT = 5

local ClientObjectPlayer = require(script.Parent.Parent:WaitForChild("ClientObjectPlayer"))

--[[
    Represents a single level in the Juke's Towers of Hell tower format

    @class Level
]]
--
local Level = {}
Level.__index = Level

--[[
    Constructs a new representation of a Level model

    @param model Model -- The tower model to represent
]]
--
function Level.new(model: Instance)
	local self = setmetatable({}, Level)
	local coFolder = model:FindFirstChild("ClientSidedObjects")

	self.id = model.Name
	self.model = model
	self.levelSpawn = model:FindFirstChild("SpawnLocation")

	--[[
        Whether or not this tower is being played
    ]]
	--
	self.isPlaying = false

	if coFolder then
		self.coSession = ClientObjectPlayer.new(coFolder, coFolder.Parent)
	end

	return self
end

--[[
    Spawns a character into the Level

    @param char Model -- The character to spawn
]]
--
function Level:spawnCharacter(character: Model)
	local rootPart = character:WaitForChild("HumanoidRootPart")

	if rootPart and rootPart:IsA("BasePart") then
		local levelSpawn = self.levelSpawn

		rootPart.CFrame = levelSpawn.CFrame:ToWorldSpace(
			CFrame.new(Vector3.new(0, (levelSpawn.Size.Y / 2) + (CHAR_SPAWN_HEIGHT / 2), 0))
		)
	end
end

--[[
    Stops the tower
]]
--
function Level:stop()
	if self.isPlaying then
		self.isPlaying = false
		self.coSession:stop()
	end
end

--[[
    Runs the tower
]]
--
function Level:play()
	if not self.isPlaying then
		self.isPlaying = true
		self.coSession:run()
	end
end

return Level
