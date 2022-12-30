--[[
Runs the tower player

By udev (@UTheDev)
]]
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local client = script.Parent

local Common = ReplicatedStorage:WaitForChild("Common")

local JToHKitClient = client:WaitForChild("JToHKitClient")

local SoftlockedClient = client:WaitForChild("SoftlockedClient")
local TowerPlayer = SoftlockedClient:WaitForChild("TowerPlayer")

local GameStats = require(Common:WaitForChild("Info"):WaitForChild("GameStats"))

local ClientTowerPlayer = require(TowerPlayer:WaitForChild("ClientTowerPlayer"))
local ClientObjectSession = require(TowerPlayer:WaitForChild("ClientObjectSession"))
local TimerFrame = require(TowerPlayer:WaitForChild("TimerFrame"))

local createInstance = require(Common:WaitForChild("createInstance"))

local localPlayer = game:GetService("Players").LocalPlayer

local portals = workspace:WaitForChild("Portals")

local towers = ReplicatedStorage:WaitForChild("Towers")

local mainGui = createInstance("ScreenGui", {
	Name = "mainGui",

	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
local mainTowerPlayer = ClientTowerPlayer.new()
local mainTimerFrame = TimerFrame.new()

local lobbyCOs = workspace:WaitForChild("Lobby"):WaitForChild("ClientSidedObjects")
local lobbyCOSession = ClientObjectSession.new(lobbyCOs, lobbyCOs.Parent)
lobbyCOs.Parent = nil

-- do initial setup for the towers
for i, v in pairs(towers:GetChildren()) do
	mainTowerPlayer:register(v)
end

-- connect timer to tower player
mainTimerFrame:bindPlayer(mainTowerPlayer)

-- tower win display
-- reminder that win time is in seconds
ReplicatedStorage:WaitForChild("Remote"):WaitForChild("OnTowerWin").OnClientEvent:Connect(function(player: Player, towerId: string, winTime: number)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		warn("Invalid player")
		return
	end
	
	if typeof(towerId) ~= "string" then
		warn("towerId must be a string")
		return
	end
	
	if typeof(winTime) ~= "number" then
		warn("winTime must be a number")
		return
	end
	
	local tower = towers:FindFirstChild(towerId)
	if not tower then
		warn("Cannot display win for", towerId, "because it doesn't exist")
		return
	end
	
	local metadata = require(tower:WaitForChild("Metadata"))
	local difficulty = GameStats.difficulties[metadata.difficulty]
	if not difficulty then
		warn("Cannot display win because the difficulty for", towerId, "is invalid")
		return
	end

	local winText = "[SERVER]: "
	.. player.Name .. " has beaten " .. metadata.fullName
	.. " in " .. TimerFrame.formatTime(winTime / 1000)
	local color = difficulty.Color
	
	local success, result = pcall(function()
		-- new chat system (TextChatService)
		local rbxSystemChannel = TextChatService:FindFirstChild("TextChannels")
		if rbxSystemChannel then
			rbxSystemChannel = rbxSystemChannel:FindFirstChild("RBXSystem")

			if rbxSystemChannel then
				rbxSystemChannel:DisplaySystemMessage(
					"<font color='#" .. color:ToHex() .. "'>" .. winText .. "</font>"
				)

				return
			end
		end

		-- old chat system
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = winText,
			Color = color
		})
	end)
	
	if not success then
		warn("Tower win display failed.\nError: " .. tostring(result) .. "\nOriginal message: " .. winText)
	end
end)

-- player physics
task.spawn(require(JToHKitClient:WaitForChild("LocalPartScriptPhysics")))

-- music
task.spawn(require(JToHKitClient:WaitForChild("NewMusicScript")))

-- tower portal setup
local isTouchingPortal = false
for i, v in pairs(workspace:WaitForChild("Portals"):GetChildren()) do
	local tpPart = v:WaitForChild("Teleport", 5)

	if tpPart and tpPart:IsA("BasePart") then
		tpPart.Touched:Connect(function(otherPart: BasePart)
			local character = localPlayer.Character

			-- make sure it's themselves that touched it
			if character and character.Parent and otherPart.Parent == character then
				if not isTouchingPortal then
					isTouchingPortal = true

					-- corresponding tower id is read from the
					-- name of the portal's model
					mainTowerPlayer:play(v.Name)

					isTouchingPortal = false
				end
			end
		end)
	else
		warn("Couldn't find " .. v.Name .. "'s teleport")
	end
end

local function onCharSpawn(char: Model)
	mainTowerPlayer:stop()
	mainTimerFrame:updateTime(0)
	mainTimerFrame:rename("---")

	if _G.SetLighting then
		_G:SetLighting("Default")
	end
end
task.spawn(onCharSpawn)
localPlayer.CharacterAdded:Connect(onCharSpawn)

-- setup should be done!
-- display towers and timer
--mainTimerFrame.component.Visible = true
mainTimerFrame.element.Parent = mainGui
mainGui.Parent = localPlayer:WaitForChild("PlayerGui")
towers.Parent = workspace
lobbyCOSession:run()
