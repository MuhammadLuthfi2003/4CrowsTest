local MatchTypes = require(script.Parent.MatchTypes)
local MatchConfig = require(script.Parent.MatchConfig)
local MatchQuery = require(script.Parent.MatchQuery)
local MatchPolicy = require(script.Parent.MatchPolicy)

local MatchRules = {}

-- Advances the match timer by deltaTime.
-- When RemainingTime reaches 0:
--   - If State was "Intermission", switches to "Game" with GameplayTime.
--   - If State was "Game", switches to "Intermission" with IntermissionTime.
-- Immutable: does not modify the original match table.
function MatchRules.Tick(match: MatchTypes.MatchTypes, deltaTime: number): MatchTypes.MatchTypes
	local newMatch = table.clone(match)
	newMatch.RemainingTime = newMatch.RemainingTime - deltaTime

	if MatchQuery.IsMatchActive(match) then
		newMatch.TimeSinceLastCrystalSpawn += deltaTime
	end

	if newMatch.RemainingTime <= 0 then
		if newMatch.State == "Intermission" then
			newMatch.State = "Game"
			newMatch.RemainingTime = MatchConfig.GameplayTime
		else
			newMatch.State = "Intermission"
			newMatch.RemainingTime = MatchConfig.IntermissionTime
		end
	end

	return newMatch
end

function MatchRules.AddSpawnedCrystal(match: MatchTypes.MatchTypes): MatchTypes.MatchTypes
	if not MatchPolicy.CanSpawnCrystal(match) then
		return match  -- return unchanged, never nil
	end

	local newMatch = table.clone(match)
	newMatch.CurrentSpawnedCrystals = newMatch.CurrentSpawnedCrystals + 1
	newMatch.TimeSinceLastCrystalSpawn = 0
	return newMatch
end

function MatchRules.RemoveSpawnedCrystal(match: MatchTypes.MatchTypes): MatchTypes.MatchTypes
	local newMatch = table.clone(match)
	newMatch.CurrentSpawnedCrystals = newMatch.CurrentSpawnedCrystals - 1
	return newMatch
end

-- called when there is a state change
function MatchRules.ResetAllCrystals(match: MatchTypes.MatchTypes): MatchTypes.MatchTypes
	local newMatch = table.clone(match)
	newMatch.CurrentSpawnedCrystals = 0
	newMatch.TimeSinceLastCrystalSpawn = 0
	return newMatch
end

return MatchRules
