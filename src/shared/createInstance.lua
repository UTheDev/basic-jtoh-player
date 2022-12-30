--[[
Shortened way for developers to quickly create instances
]]--

local function createInstance(className: string, properties: {[string]: name}?, children: {Instance}?)
    local newInst = Instance.new(className)

    if properties then
        for i, v in pairs(properties) do
            newInst[i] = v
        end
    end

    if children then
        for i, v in ipairs(children) do
            v.Parent = newInst
        end
    end

    return newInst
end

return createInstance
