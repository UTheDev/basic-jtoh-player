--[[
	This module describes some game statistics about JToH related games (e.g. difficulties).
]]
--
local GameStats = {}

--[[
	Represents a single difficulty
]]
--
export type Difficulty = {
	index: number,
	name: string?,
	color: Color3?,
}

--[[
Creates a difficulty info table

@param index The index of the difficulty to use as an identifier
@param name The name of the difficulty
@param color The difficulty's color

@return The created difficulty info table
]]
--
function GameStats.createDifficulty(index: number, name: string?, color: Color3?): Difficulty
	assert(typeof(index) == "number", "Argument 1 must be a number")
	assert(name == nil or typeof(name) == "string", "Argument 2 must be a string or nil")
	assert(color == nil or typeof(color) == "Color3", "Argument 3 must be a Color3")

	return {
		index = index,
		name = name or "n/a",
		color = color or Color3.fromRGB(128, 128, 128),
	}
end

--[[
	The assortment of difficuties as defined by the Juke's Towers of Hell community.
]]
--
GameStats.difficulties = {
	-- tower game difficulties, as of February 2022
	GameStats.createDifficulty(1, "Easy", Color3.fromRGB(118, 244, 71)),
	GameStats.createDifficulty(2, "Medium", Color3.fromRGB(255, 255, 2)),
	GameStats.createDifficulty(3, "Hard", Color3.fromRGB(254, 124, 0)),
	GameStats.createDifficulty(4, "Difficult", Color3.fromRGB(255, 12, 4)),
	GameStats.createDifficulty(5, "Challenging", Color3.fromRGB(193, 0, 0)),
	GameStats.createDifficulty(6, "Intense", Color3.fromRGB(25, 40, 50)),
	GameStats.createDifficulty(7, "Remorseless", Color3.fromRGB(201, 1, 201)),
	GameStats.createDifficulty(8, "Insane", Color3.fromRGB(0, 58, 220)),
	GameStats.createDifficulty(9, "Extreme", Color3.fromRGB(3, 137, 255)),
	GameStats.createDifficulty(10, "Terrifying", Color3.fromRGB(1, 255, 255)),
	GameStats.createDifficulty(11, "Catastrophic", Color3.fromRGB(255, 255, 255)),

	-- rng difficulties (according to the obby community)
	GameStats.createDifficulty(12, "Horrific", Color3.fromRGB(236, 178, 250)),
	GameStats.createDifficulty(13, "Unreal", Color3.fromRGB(83, 24, 139)),
	GameStats.createDifficulty(14, "nil", Color3.fromRGB(101, 102, 109)),
}

return GameStats
