--[[
Basically a validation that the player's in a tower

server use only

by udev2192
]]--

local TowerSession = {}

TowerSession.__index = TowerSession

function TowerSession.new(player: Player, towerId: string)
	local self = {}
	
	self.startTime = 0
	self.endTime = 0
	self.isActive = false
	self.player = player
	self.towerId = towerId
	
	-- number of milliseconds that the client sent time can be offset
	-- from the number the server has
	self.maxAllowedPing = 11000
	
	return setmetatable(self, TowerSession)
end

function TowerSession:isWinValid(clientTimeMs: number)
	return math.abs(clientTimeMs - (self.endTime - self.startTime)) <= self.maxAllowedPing
end

function TowerSession:stop()
	if self.isActive then
		self.isActive = false
		self.endTime = DateTime.now().UnixTimestampMillis
	end
end

function TowerSession:start()
	if not self.isActive then
		self.isActive = true
		self.startTime = DateTime.now().UnixTimestampMillis
	end
end

return TowerSession