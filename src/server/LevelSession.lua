--[[
Basically a validation that the player's in a level

server use only

by udev (UTheDev)
]]--

local LevelSession = {}

LevelSession.__index = LevelSession

function LevelSession.new(player: Player, levelId: string)
	local self = {}
	
	self.startTime = 0
	self.endTime = 0
	self.isActive = false
	self.player = player
	self.levelId = levelId
	
	-- number of milliseconds that the client sent time can be offset
	-- from the number the server has
	self.maxAllowedPing = 11000
	
	return setmetatable(self, LevelSession)
end

function LevelSession:isWinValid(clientTimeMs: number)
	return math.abs(clientTimeMs - (self.endTime - self.startTime)) <= self.maxAllowedPing
end

function LevelSession:stop()
	if self.isActive then
		self.isActive = false
		self.endTime = DateTime.now().UnixTimestampMillis
	end
end

function LevelSession:start()
	if not self.isActive then
		self.isActive = true
		self.startTime = DateTime.now().UnixTimestampMillis
	end
end

return LevelSession