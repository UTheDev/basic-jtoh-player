--[[
    Saves a list of instances and provides a way to specify what to do with them
]]
--

local InstanceCache = {}
InstanceCache.mt = {}
InstanceCache.mt.__index = InstanceCache.mt

function InstanceCache.new()
	local self = setmetatable({}, InstanceCache.mt)

	--[[
        <{Instance}> - The cached list of instances.
    ]]
	--
	self.instanceList = {}

	--[[
        Callback that's fired when an instance is initially found using one of the search functions

        Callback parameters:
        inst <Instance> - The instance found
    ]]
	--
	self.onInitialFind = nil

	return self
end

--[[
    Returns whether or not an instance is already added cached and therefore added to instanceList

    Parameters:
    inst <Instance> - The instance to check

    Returns:
    <boolean> - Whether or not the instance is added
]]
--
function InstanceCache.mt:isCached(inst: Instance)
	return table.find(self.instanceList, inst) == nil
end

--[[
	Checks whether or not an instance can be added to the cache or removed from it.
	This method can be checked to see if an instance has things in common to those
	in the instance cache.
	This method is intended to be overriden.

	Parameters:
	inst <Instance> - The instance to check

	Returns:
	<boolean> - Whether or not the instance can be cached
]]--
function InstanceCache.mt:canCache()
	return true
end

--[[
    Saves a reference of an instance to the instanceList

    Parameters:
    inst <Instance> - The instance reference to add
]]
--
function InstanceCache.mt:cache(inst: Instance)
	if self:isCached(inst) == false then
		table.insert(self.instanceList, inst)

		if self.onInitialFind then
			self.onInitialFind(inst)
		end
	end
end

--[[
    Searches an instance for relevant descendants by name

    Parameters:
    inst <Instance> - The instance that will have its descendants searched
    name <string> - The instance name to look for
]]
--
function InstanceCache.mt:searchByName(inst: Instance, name: string)
	local instList = self.instanceList
	local onInitialFind = self.onInitialFind

	for i, v in pairs(inst:GetDescendants()) do
		if self:canCache(v) then
			self:cache(v)
		end
	end
end

--[[
    Captures any instance with a given name that has been added to a specified instance
    after the corresponding Instance.DescendantAdded connection is established

	Parameters:
	inst <Instance> - The instance to bind the Instance.DescendantAdded connection to

    Returns:
    <RBXScriptConnection> - The corresponding Instance.DescendantAdded connection
]]
--
function InstanceCache.mt:searchByEvent(inst: Instance)
	return inst.DescendantAdded:Connect(function(newInst: Instance)
		if self:canCache(inst) then
			self:cache(newInst)
		end
	end)
end

--[[
	Binds an Instance.DescendantRemoving connection to remove a particular instance from cache

	Parameters:
	inst <Instance> - The instance to bind the Instance.DescendantRemoving connection to

    Returns:
    <RBXScriptConnection> - The corresponding Instance.DescendantRemoving connection
]]--
function InstanceCache.mt:bindRemoval()
	return inst.DescendantRemoving:Connect(function(inst: Instance)
		if self:canCache(inst) then
			local index = table.find(self.instanceCache, inst)
			if index then
				table.remove(self.instanceCache, index)
			end
		end
	end)
end

return InstanceCache
