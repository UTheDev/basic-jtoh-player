--[[
Runs the level player

By udev (UTheDev)
]]
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local StarterGui = game:GetService("StarterGui")
--local TextChatService = game:GetService("TextChatService")

local client = script.Parent

local SoftlockedReplicated = ReplicatedStorage:WaitForChild("Softlocked")

local JToHKitClient = client:WaitForChild("JToHKitClient")

local SoftlockedClient = script.Parent
local LevelPlayer = SoftlockedClient:WaitForChild("LevelPlayer")

--local GameStats = require(SoftlockedReplicated:WaitForChild("Info"):WaitForChild("GameStats"))

local WinReceiver = require(LevelPlayer:WaitForChild("WinReceiver"))

local ClientLevelPlayer = require(LevelPlayer:WaitForChild("ClientLevelPlayer"))
local ClientObjectSession = require(LevelPlayer:WaitForChild("ClientObjectSession"))
local TimerFrame = require(LevelPlayer:WaitForChild("TimerFrame"))

local createInstance = require(SoftlockedReplicated:WaitForChild("createInstance"))

local localPlayer = game:GetService("Players").LocalPlayer

--local portals = workspace:WaitForChild("Portals")

local levels = ReplicatedStorage:WaitForChild("Levels")

local mainGui = createInstance("ScreenGui", {
	Name = "mainGui",

	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local mainLevelPlayer = ClientLevelPlayer.new()
local mainTimerFrame = TimerFrame.new()

local lobbyCOs = workspace:WaitForChild("Lobby"):WaitForChild("ClientSidedObjects")
local lobbyCOSession = ClientObjectSession.new(lobbyCOs, lobbyCOs.Parent)
lobbyCOs.Parent = nil

-- do initial setup for the towers
for i, v in pairs(levels:GetChildren()) do
	mainLevelPlayer:register(v)
end

-- connect timer to tower player
mainTimerFrame:bindPlayer(mainLevelPlayer)

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
					mainLevelPlayer:play(v.Name)

					isTouchingPortal = false
				end
			end
		end)
	else
		warn("Couldn't find " .. v.Name .. "'s teleport")
	end
end

-- listen to wins
WinReceiver.new(ReplicatedStorage:WaitForChild("Softlocked"):WaitForChild("Remote"):WaitForChild("OnPlayerWin"), levels)
	:connect()

local function onCharSpawn()
	mainLevelPlayer:stop()
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
levels.Parent = workspace
lobbyCOSession:run()
