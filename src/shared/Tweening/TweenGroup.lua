--[[
Handles situations where multiple tweens may be needed,
or certain pausing logic

By udev2192
]]
--

local TweenService = game:GetService("TweenService")

local TweenGroup = {}
TweenGroup.mt = {}
TweenGroup.mt.__index = TweenGroup.mt

local PLAYBACK_STATE = "PlaybackState"
local TWEEN_COMPLETED = Enum.PlaybackState.Completed

function TweenGroup.assertTweenCreate(obj: Instance, info: TweenInfo, properties: { string: any })
	assert(typeof(obj) == "Instance", "Argument 1 must be an instance")
	assert(typeof(info) == "TweenInfo", "Argument 2 must be a TweenInfo")
	assert(typeof(properties) == "table", "Argument 3 must be a table")
end

function TweenGroup.new()
	local self = setmetatable({}, TweenGroup.mt)
	self.tweens = {}

	return self
end

--[[
	Pauses and destroys certain tweens in the group
	
	Params:
	Name <string?> - The name of the tweens to destroy.
					 If unspecified, the whole group will
					 be destroyed.
]]
--
function TweenGroup.mt:kill(index: any?)
	local tweens = self.tweens

	for i, v in pairs(tweens) do
		if index == v.index then
			-- find the index again manually
			-- since the actual index may have
			-- changed during this loop
			local index = table.find(tweens, v)
			if index then
				table.remove(tweens, index)
			end

			local tween = v.tween
			tween:Pause()
			tween:Destroy()
		end
	end
end

--[[
	Pauses and destroys all tweens stored in the group
]]
--
function TweenGroup.mt:killAll()
	for i, v in pairs(self.tweens) do
		local tween = v.tween
		tween:Pause()
		tween:Destroy()
	end

	self.tweens = {}
end

--[[
	Adds a tween to the group with its arguments
	
	Params:
	obj <Instance> - The instance to tween
	info <TweenInfo> - The TweenInfo to use
	properties <{string: any}> - The properties to tween and their destination values
	index <any?> - The index of the tween
	callback <() -> ()?> - A callback to invoke once the tween is finished
	
	Returns:
	<Tween> - The Tween created
]]
--
function TweenGroup.mt:add(
	obj: Instance,
	info: TweenInfo,
	properties: { [string]: any },
	index: any?,
	callback: () -> ()?
): Tween
	assert(callback == nil or typeof(callback) == "function", "Argument 5 must be a function or nil")
	TweenGroup.assertTweenCreate(obj, info, properties)

	local tween = TweenService:Create(obj, info, properties)
	table.insert(self.tweens, { tween = tween, index = index })

	if typeof(index) == "string" then
		tween.Name = index
	end
	tween:GetPropertyChangedSignal(PLAYBACK_STATE):Connect(function()
		if tween.PlaybackState == TWEEN_COMPLETED then
			tween:Destroy()

			self:kill(index)

			if callback then
				callback()
			end
		end
	end)

	return tween
end

--[[
	Plays a tween with its arguments, waits until it's done,
	then destroys it
	
	Params:
	obj <Instance> - The instance to tween
	info <TweenInfo> - The TweenInfo to use
	properties <{string: any}> - The properties to tween and their destination values
	index <any?> - The index of the tween
	callback <() -> ()?> - A callback to invoke once the tween is finished
	
	Returns:
	<Tween> - The Tween created
]]
--
function TweenGroup.mt:play(
	obj: Instance,
	info: TweenInfo,
	properties: { [string]: any },
	index: any?,
	callback: () -> ()?
): Tween
	local tween = self:add(obj, info, properties, index, callback)
	tween:Play()

	return tween
end

return TweenGroup
