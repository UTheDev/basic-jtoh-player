--[[
for storing player cooldowns associated with client-to-server remote calls

user id is used instead of the player instance

by udev2192
]]--

local RemoteCooldown = {}

RemoteCooldown.__index = RemoteCooldown

function RemoteCooldown.new(cooldownTime: number?)
	local self = {
		-- cooldown time in seconds
		cooldownTime = cooldownTime or 0,
		
		-- user ids actively in cooldown
		activeUserIds = {}
	}
	
	return setmetatable(self, RemoteCooldown)
end

function RemoteCooldown:canFire(userId: number)
	return table.find(self.activeUserIds, userId) == nil
end

function RemoteCooldown:remove(userId: number)
	local activeUserIds = self.activeUserIds
	local index = table.find(activeUserIds, userId)
	
	if index then
		table.remove(activeUserIds, index)
	end
end

function RemoteCooldown:add(userId: number)
	if self:canFire(userId) then
		table.insert(self.activeUserIds, userId)
		
		local timeLeft = self.cooldownTime
		
		while true do
			if self:canFire(userId) then
				break
			end
			
			if timeLeft <= 0 then
				self:remove(userId)
				break
			end
			
			timeLeft -= task.wait()
		end
	end
end

return RemoteCooldown