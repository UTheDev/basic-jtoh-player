--[[
	This script is from Juke's Towers of Hell Creation Kit v5.4 by Jukereise and Gammattor
]]--

local p = script.Parent

return function()
	local destinations = {}
	local rb = p:FindFirstChild'RemoveButtons' and p.RemoveButtons.Value
	for _, tp in pairs(p:GetDescendants()) do
		if tp.Name == "Destination" then
			tp.Transparency = 1
			table.insert(destinations, tp)
		elseif tp.Name == "Teleporter" then
			tp.Transparency = 1
			tp.Touched:Connect(function(t)
				if t:FindFirstChild"Activated" and not t.Activated.Value then return end
				local dests = {}
				for _, d in pairs(destinations) do
					if not (d:FindFirstChild"Activated" and not d.Activated.Value) then
						table.insert(dests, d)
					end
				end
				if #dests <= 0 then return end
				local d = dests[math.random(1, #dests)]
				if p:FindFirstChild('TeleportPushboxes') and p.TeleportPushboxes.Value then
					if t.Name == 'Pushbox' then
						d.TeleportSound:Play()
						t.CFrame=d.CFrame*CFrame.new(0,5,0)
					end
				end
				if game.Players:GetPlayerFromCharacter(t.Parent) == game.Players.LocalPlayer then
					if rb then
						for _, b in pairs(_G.Button.Buttons) do
							b.Pressed.Value = false
						end
					end
					d.TeleportSound:Play()
					t.Parent:SetPrimaryPartCFrame(d.CFrame * CFrame.new(0, 5, 0))
				end
			end)
		end
	end
end