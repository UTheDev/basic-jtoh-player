--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

return function()
	script.Parent.Transparency=1
	script.Parent.Touched:Connect(function(t)
		if game.Players:GetPlayerFromCharacter(t.Parent)==game.Players.LocalPlayer then
			if script.Parent:FindFirstChild("ColorSpecific") and script.Parent.ColorSpecific.Value then
				for _,d in pairs(script.Parent.Parent:GetDescendants()) do
					if d and d.Name=='Pressed' and d.Parent.Name=='Button' then
						for _,v in pairs(d.Parent:GetChildren()) do
							if v:IsA("BasePart") and v.Color == script.Parent.Color and v.Press ~= nil then
								d.Value=false
							end
						end
						
					end
				end
			else
				for _,d in pairs(script.Parent.Parent:GetDescendants()) do
					if d and d.Name=='Pressed' and d.Parent.Name=='Button' then
						d.Value=false
					end
				end
			end
		end
	end)
end