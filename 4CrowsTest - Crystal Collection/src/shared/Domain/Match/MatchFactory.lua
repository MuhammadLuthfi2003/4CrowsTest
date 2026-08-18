local Types = require(script.Parent.MatchTypes)
local Config = require(script.Parent.MatchConfig)

local MatchFactory = {}

function MatchFactory.Create(): Types.MatchTypes
	return {
		RemainingTime = Config.IntermissionTime,
		State = "Intermission",
		CurrentSpawnedCrystals = 0,
		TimeSinceLastCrystalSpawn = 0,
	}
end

return MatchFactory
