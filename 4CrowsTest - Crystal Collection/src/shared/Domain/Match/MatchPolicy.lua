local MatchTypes = require(script.Parent.MatchTypes)
local MatchConfig = require(script.Parent.MatchConfig)

local MatchPolicy = {}

-- Returns true if a new crystal is allowed to be spawned.
-- Conditions:
--   1. The match must currently be in "Game" state (not Intermission).
--   2. The number of currently active crystals must be below the configured maximum.
function MatchPolicy.CanSpawnCrystal(match: MatchTypes.MatchTypes, currentSpawnedCount: number): boolean
	return match.State == "Game" and currentSpawnedCount < MatchConfig.MaxSpawnedCrystals
end

return MatchPolicy
