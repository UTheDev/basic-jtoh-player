--[[
    Saves a list of instances and provides a way to specify what to do with them
]]--

local InstanceCache = {}
InstanceCache.mt = {}
InstanceCache.mt.__index = InstanceCache.mt

function InstanceCache.new()
    local self = setmetatable({}, InstanceCache.mt)

    --[[
        <{Instance}> - The cached list of instances.
    ]]--
    self.instanceList = {}

    --[[
        Callback that's fired when an instance is initially found using one of the search functions

        Callback parameters:
        inst <Instance> - The instance found
    ]]--
    self.onInitialFind = nil

    return self
end

--[[
    Returns whether or not an instance is already added cached and therefore added to instanceList

    Parameters:
    inst <Instance> - The instance to check

    Returns:
    <boolean> - Whether or not the instance is added
]]--
function InstanceCache.mt:isCached(inst: Instance)
    return table.find(self.instanceList, inst) == nil
end

--[[
    Searches an instance for relevant descendants by name

    Parameters:
    inst <Instance> - The instance that will have its descendants searched
    name <string> - The instance name to look for
]]--
function InstanceCache.mt:searchByName(inst: Instance, name: string)
    local instList = self.instanceList
    local onInitialFind = self.onInitialFind

    for i, v in pairs(inst:GetDescendants()) do
        if v.Name == name and self:isCached(v) == false then
            table.insert(instList, v)

            if onInitialFind then
                onInitialFind(v)
            end
        end
    end
end

--[[
    Captures any instance with a given name that has been added to a specified instance
    after the corresponding Instance.DescendantAdded connection is established

    Returns:
    <RBXScriptConnection> - The corresponding Instance.DescendantAdded connection
]]--
function InstanceCache.mt:searchByEvent(inst: Instance, name: string)
    return inst.DescendantAdded:Connect(function(newInst: Instance)
        if newInst.Name == name and self:isCached(newInst) == false then
            if self.onInitialFind then
                self.onInitialFind(newInst)
            end
        end
    end)
end

return InstanceCache
