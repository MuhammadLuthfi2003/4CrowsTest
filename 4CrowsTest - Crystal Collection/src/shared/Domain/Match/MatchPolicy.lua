local MatchTypes = require(script.Parent.MatchTypes)

local MatchPolicy = {}

-- Returns true if a new crystal is allowed to be spawned.
-- Conditions:
--   1. The match must currently be in "Game" state (not Intermission).
--   2. The number of currently active crystals must be below the configured maximum.
function MatchPolicy.CanSpawnCrystal(
	match: MatchTypes.MatchTypes,
	config: MatchTypes.MatchConfigTypes,
	currentSpawnedCount: number
): boolean
	return match.State == "Game" and currentSpawnedCount < config.MaxSpawnedCrystals
end

return MatchPolicy
