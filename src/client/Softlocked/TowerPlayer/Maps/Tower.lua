--[[
    Represents a single tower in the Juke's Towers of Hell format

    @class Tower
]]
--

local CHAR_SPAWN_HEIGHT = 5

local ClientObjectSession = require(script.Parent.Parent:WaitForChild("ClientObjectSession"))

local Tower = {}
Tower = {}
Tower.__index = Tower

--[[
    Constructs a new representation of a Tower model

    @param model The tower model to represent
]]
--
function Tower.new(model: Instance)
	local self = setmetatable({}, Tower)
	local coFolder = model:FindFirstChild("ClientSidedObjects")

	self.id = model.Name
	self.model = model
	self.towerSpawn = model:FindFirstChild("SpawnLocation")

	--[[
        Whether or not this tower is being played
    ]]
	--
	self.isPlaying = false

	if coFolder then
		self.coSession = ClientObjectSession.new(coFolder, coFolder.Parent)
	end

	return self
end

--[[
    Spawns a character into the Tower

    @param char The character to spawn
]]
--
function Tower:spawnCharacter(character: Model)
	local rootPart = character:WaitForChild("HumanoidRootPart")

	if rootPart and rootPart:IsA("BasePart") then
		local towerSpawn = self.towerSpawn

		rootPart.CFrame = towerSpawn.CFrame:ToWorldSpace(
			CFrame.new(Vector3.new(0, (towerSpawn.Size.Y / 2) + (CHAR_SPAWN_HEIGHT / 2), 0))
		)
	end
end

--[[
    Stops the tower
]]
--
function Tower:stop()
	if self.isPlaying then
		self.isPlaying = false
		self.coSession:stop()
	end
end

--[[
    Runs the tower
]]
--
function Tower:play()
	if not self.isPlaying then
		self.isPlaying = true
		self.coSession:run()
	end
end

return Tower
