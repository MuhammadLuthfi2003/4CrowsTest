local MatchTypes = require(script.Parent.MatchTypes)

local MatchRules = {}

-- Advances the match timer by deltaTime.
-- When RemainingTime reaches 0:
--   - If State was "Intermission", switches to "Game" with GameplayTime.
--   - If State was "Game", switches to "Intermission" with IntermissionTime.
-- Immutable: does not modify the original match table.
function MatchRules.Tick(
	match: MatchTypes.MatchTypes,
	config: MatchTypes.MatchConfigTypes,
	deltaTime: number
): MatchTypes.MatchTypes
	local newMatch = table.clone(match)
	newMatch.RemainingTime = newMatch.RemainingTime - deltaTime

	if newMatch.RemainingTime <= 0 then
		if newMatch.State == "Intermission" then
			newMatch.State = "Game"
			newMatch.RemainingTime = config.GameplayTime
		else
			newMatch.State = "Intermission"
			newMatch.RemainingTime = config.IntermissionTime
		end
	end

	return newMatch
end

return MatchRules
