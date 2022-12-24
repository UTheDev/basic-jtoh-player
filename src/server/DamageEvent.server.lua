--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local DamageEvent = game:GetService("ReplicatedStorage").DamageEvent
local DebounceArray = {}

local types={
	Normal=5,
	DoubleDamage=10,
	HighDamage=20,
	Instakill=math.huge, --scary number
}

DamageEvent.OnServerEvent:Connect(function(Player,Type)
	if DebounceArray[Player.Name] then return end
	DebounceArray[Player.Name] = true
	local char = Player.Character
	if char ~= nil then
		local Humanoid = char:WaitForChild("Humanoid")
		if tonumber(Type) ~= nil then
			Humanoid:TakeDamage(Type)
		else
			Humanoid:TakeDamage(types[Type] or types.Normal)
		end
		wait(0.05) 
		DebounceArray[Player.Name] = nil
	end
end)