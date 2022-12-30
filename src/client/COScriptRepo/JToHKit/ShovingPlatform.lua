--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

return function()
	local model = script.Parent.Parent
	local prismc = script.Parent.PrismaticConstraint
	prismc.UpperLimit = model.Distance.Value
	while true do
		wait(model.OutDelay.Value)
		prismc.LinearResponsiveness=model.OutSpeed.Value
		prismc.Speed=model.OutSpeed.Value
		prismc.TargetPosition=model.Distance.Value
		wait(model.InDelay.Value)
		prismc.LinearResponsiveness=model.InSpeed.Value
		prismc.Speed=model.InSpeed.Value
		prismc.TargetPosition=0
	end
end