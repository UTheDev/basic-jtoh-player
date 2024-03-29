--[[
GUI that displays how long a current level session has been active
]]
--

local createInstance =
	require(game:GetService("ReplicatedStorage"):WaitForChild("BasicJToHPlayer"):WaitForChild("createInstance"))

local TimerFrame = {}
TimerFrame.mt = {}
TimerFrame.mt.__index = TimerFrame.mt

function TimerFrame.new()
	local self = setmetatable({}, TimerFrame.mt)

	self.element = createInstance("Frame", {
		Name = "levelSessionTimer",

		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 130, 0, 30),
		Position = UDim2.new(0.5, 0, 0, 20),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		ClipsDescendants = false,
	}, {
		createInstance("TextLabel", {
			Name = "timerName",

			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0.4, 0, 0.9, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 20,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = false,
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,

			Text = "---",

			Visible = true,
		}),

		createInstance("TextLabel", {
			Name = "timeLeft",

			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0.4, 0, 1, 0),
			Position = UDim2.new(0.75, 0, 0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.SourceSans,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			Text = TimerFrame.formatTime(0),
		}),

		createInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})

	return self
end

function TimerFrame.formatTime(seconds: number)
	local minutes = math.floor(seconds / 60)
	seconds -= minutes * 60

	if seconds < 10 then
		return minutes .. ":" .. "0" .. string.format("%.3f", seconds)
	else
		return minutes .. ":" .. string.format("%.3f", seconds)
	end
end

function TimerFrame.mt:rename(newName: string)
	local newNameLabel = self.element:FindFirstChild("timerName")

	if newNameLabel then
		newNameLabel.Text = newName
	end
end

function TimerFrame.mt:updateTime(newSeconds: number)
	local timeLeft = self.element:FindFirstChild("timeLeft")

	if timeLeft then
		timeLeft.Text = TimerFrame.formatTime(newSeconds)
	end
end

function TimerFrame.mt:onLevelChange(newLevel: {id: string})
	if newLevel then
		self:rename(newLevel.id)
	else
		self:rename("---")
	end
end

function TimerFrame.mt:unbindPlayer()
	local timeChangeConnection = self.timeChangeConnection
	local levelChangeConnection = self.levelChangeConnection

	if timeChangeConnection then
		self.timeChangeConnection = nil
		timeChangeConnection:Disconnect()
	end

	if levelChangeConnection then
		self.levelChangeConnection = nil
		levelChangeConnection:Disconnect()
	end
end

function TimerFrame.mt:bindPlayer(levelPlr)
	if self.timeChangeConnection == nil then
		self.timeChangeConnection = levelPlr.onCurrentTimeChange:Connect(function(newTime)
			self:updateTime(newTime)
		end)
	end

	if self.levelChangeConnection == nil then
		self.levelChangeConnection = levelPlr.onCurrentLevelChange:Connect(function(newLevel)
			self:onLevelChange(newLevel)
		end)
	end
end

return TimerFrame
