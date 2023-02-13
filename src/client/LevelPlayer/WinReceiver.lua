-- By udev (UTheDev)

local GameStats = require(
	game:GetService("ReplicatedStorage"):WaitForChild("Softlocked"):WaitForChild("Info"):WaitForChild("GameStats")
)

local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local TimerFrame = require(script.Parent:WaitForChild("TimerFrame"))

--[[
    For the client, this displays level wins in chat

	@class WinReceiver
]]
--
local WinReceiver = {}
WinReceiver.__index = WinReceiver

--[[
	Creates a new WinReceiver

	@param remote RemoteEvent -- The remote event that the player wins will be sent through
	@param levelsFolder Folder -- The folder that contains the game's levels
]]
--
function WinReceiver.new(remote: RemoteEvent, levelsFolder: Folder)
	assert(typeof(remote) == "Instance" and remote:IsA("RemoteEvent"), "Argument 1 expected a RemoteEvent")
	assert(typeof(levelsFolder) == "Instance", "Argument 2 expected an Instance")

	local self = setmetatable({}, WinReceiver)

	self.levels = levelsFolder
	self.remote = remote

	return self
end

function WinReceiver:disconnect()
	local connection = self.connection
	if connection then
		connection:Disconnect()
		self.connection = nil
	end
end

function WinReceiver:connect()
	local levels = self.levels
	local remote = self.remote

	if remote and self.connection == nil then
		-- level win display
		-- reminder that win time is in seconds
		self.connection = remote.OnClientEvent:Connect(function(player: Player, levelId: string, winTime: number)
			if not (typeof(player) == "Instance" and player:IsA("Player")) then
				warn("Invalid player")
				return
			end

			if typeof(levelId) ~= "string" then
				warn("levelId must be a string")
				return
			end

			if typeof(winTime) ~= "number" then
				warn("winTime must be a number")
				return
			end

			local level = levels:FindFirstChild(levelId)
			if not level then
				warn("Cannot display win for", levelId, "because it doesn't exist")
				return
			end

			local metadata = require(level:WaitForChild("Metadata"))
			local difficulty = GameStats.difficulties[metadata.difficulty]
			if not difficulty then
				warn("Cannot display win because the difficulty for", levelId, "is invalid")
				return
			end

			local winText = "[SERVER]: "
				.. player.Name
				.. " has beaten "
				.. metadata.fullName
				.. " in "
				.. TimerFrame.formatTime(winTime / 1000)
			local color = difficulty.color

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
					Color = color,
				})
			end)

			if not success then
				warn("Level win display failed.\nError: " .. tostring(result) .. "\nOriginal message: " .. winText)
			end
		end)
	end
end

return WinReceiver
