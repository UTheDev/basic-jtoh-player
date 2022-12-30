--[[
    A few utilities for locating instances using cleaner code

    By UTheDev
]]
--

local InstanceLocation = {}

--[[
    This method helps shorten a long :WaitForChild() path.
    Descending instances should be separated by "."
    For example, "Baseplate.Attachment0" where the root instance is ReplicatedStorage would be
    the same as doing ReplicatedStorage:WaitForChild("Baseplate"):WaitForChild("Attachment0")
]]
--
function InstanceLocation.waitForChildByPath(rootInst: Instance?, path: string, timeout: number?)
	-- Assume the root instance is the default DataModel if no root instance is specified
	if not rootInst then
		rootInst = game
	end

	if typeof(timeout) ~= "number" then
		timeout = nil
	end

	local inst = rootInst
	for i, v in ipairs(path:split(".")) do
		inst = inst:WaitForChild(v, timeout)
	end

	return inst
end

--[[
    This method helps shorten a long :FindFirstChild() path.
    Descending instances should be separated by "."
    For example, "Baseplate.Attachment0" where the root instance is ReplicatedStorage would be
    the same as doing ReplicatedStorage:FindFirstChild("Baseplate"):FindFirstChild("Attachment0")
]]
--
function InstanceLocation.findFirstChildByPath(rootInst: Instance?, path: string)
	-- Assume the root instance is the default DataModel if no root instance is specified
	if not rootInst then
		rootInst = game
	end

	local inst = rootInst
	for i, v in ipairs(path:split(".")) do
		inst = inst:FindFirstChild(v, timeout)
	end

	return inst
end

return InstanceLocation
