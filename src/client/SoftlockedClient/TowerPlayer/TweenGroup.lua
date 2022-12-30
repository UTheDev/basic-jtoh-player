--[[
Handles situations where multiple tweens may be needed,
or certain pausing logic

By udev2192
]]--

local TweenService = game:GetService("TweenService")

local TweenGroup = {}
TweenGroup.__index = TweenGroup
TweenGroup.ClassName = script.Name
TweenGroup.DefaultTweenName = "TweenDefault"

local PLAYBACK_STATE = "PlaybackState"
local TWEEN_COMPLETED = Enum.PlaybackState.Completed

function TweenGroup.AssertTweenCreate(Obj: Instance, Info: TweenInfo, Properties: {string: any})
	assert(typeof(Obj) == "Instance", "Argument 1 must be an instance")
	assert(typeof(Info) == "TweenInfo", "Argument 2 must be a TweenInfo")
	assert(typeof(Properties) == "table", "Argument 3 must be a table")
end

function TweenGroup.New()
	local Group = {}
	local Tweens = {}

	--[[
	Pauses and destroys certain tweens in the group
	
	Params:
	Name <string?> - The name of the tweens to destroy.
					 If unspecified, the whole group will
					 be destroyed.
	]]--
	function Group.Kill(Index: any?)
		--do
		--local Tween = Tweens[Index]
		--if Tween then
		--	Tweens[Index] = nil
		--	Tween:Pause()
		--	Tween:Destroy()
		--end
		--end

		--if typeof(Index) == "string" then
		--	for i, v in pairs(Tweens) do
		--		if v.Name == Index then
		--			v:Pause()
		--			v:Destroy()
		--			table.remove(Tweens, i)
		--		end
		--	end
		--end

		for i, v in pairs(Tweens) do
			if Index == v.Index then
				-- find the index again manually
				-- since the actual index may have
				-- changed during this loop
				local Index = table.find(Tweens, v)
				if Index then
					table.remove(Tweens, Index)
				end

				local Tween = v.Tween
				Tween:Pause()
				Tween:Destroy()
			end
		end
	end

	--[[
	Pauses and destroys all tweens stored in the group
	]]--
	function Group.KillAll()
		for i, v in pairs(Tweens) do
			local Tween = v.Tween
			Tween:Pause()
			Tween:Destroy()
		end

		Tweens = {}
	end

	--[[
	Adds a tween to the group with its arguments
	
	Params:
	Obj <Instance> - The instance to tween
	Info <TweenInfo> - The TweenInfo to use
	Properties <{string: any}> - The properties to tween and their destination values
	Index <any?> - The index of the tween
	Callback <() -> ()?> - A callback to invoke once the tween is finished
	
	Returns:
	<Tween> - The Tween created
	]]--
	function Group.Add(Obj: Instance, Info: TweenInfo, Properties: {[string]: any}, Index: any?, Callback: () -> ()?): Tween
		assert(Callback == nil or typeof(Callback) == "function", "Argument 5 must be a function or nil")
		TweenGroup.AssertTweenCreate(Obj, Info, Properties)

		local Tween = TweenService:Create(Obj, Info, Properties)
		table.insert(Tweens, {Tween = Tween, Index = Index})

		if typeof(Index) == "string" then
			Tween.Name = Index
		end
		Tween:GetPropertyChangedSignal(PLAYBACK_STATE):Connect(function()
			if Tween.PlaybackState == TWEEN_COMPLETED then
				Tween:Destroy()

				Group.Kill(Index)

				if Callback then
					Callback()
				end
			end
		end)

		return Tween
	end

	--[[
	Plays a tween with its arguments, waits until it's done,
	then destroys it
	
	Params:
	Obj <Instance> - The instance to tween
	Info <TweenInfo> - The TweenInfo to use
	Properties <{string: any}> - The properties to tween and their destination values
	Index <any?> - The index of the tween
	Callback <() -> ()?> - A callback to invoke once the tween is finished
	
	Returns:
	<Tween> - The Tween created
	]]--
	function Group.Play(Obj: Instance, Info: TweenInfo, Properties: {[string]: any}, Index: any?, Callback: () -> ()?): Tween
		local Tween = Group.Add(Obj, Info, Properties, Index, Callback)
		Tween:Play()

		return Tween
	end

	Group.OnDisposal = Group.KillAll

	return Group
end

return TweenGroup