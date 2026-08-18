local MatchTypes = require(script.Parent.MatchTypes)

local MatchQuery = {}

function MatchQuery.IsMatchActive(match: MatchTypes.MatchTypes): boolean
	return match.State == "Game"
end

function MatchQuery.GetCurrentSpawnedCrystals(match: MatchTypes.MatchTypes): number
	return match.CurrentSpawnedCrystals
end

function MatchQuery.GetRemainingTime(match: MatchTypes.MatchTypes): number
	return match.RemainingTime
end

return MatchQuery
