local Level = require(script.Parent:WaitForChild("Level"))

--[[
    Represents a Tower in the Juke's Towers of Hell format.

    This is different than the base class, Level, in that it contains support for things like winpads.

    @class Tower
]]--
local Tower = 
Tower.__index = Tower

function Tower:connectWinpad() end

return Tower