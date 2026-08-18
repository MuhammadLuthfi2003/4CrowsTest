-- PlayerPolicy.lua
local PlayerTypes = require(script.Parent.PlayerTypes)
local MatchTypes = require(script.Parent.Parent.Match.MatchTypes)
local MatchQuery = require(script.Parent.Parent.Match.MatchQuery)
local PlayerConfig = require(script.Parent.PlayerConfig)

local PlayerPolicy = {}

function PlayerPolicy.CanAddScore(match: MatchTypes.MatchTypes): boolean
	return MatchQuery.IsMatchActive(match)
end

-- Returns true if the player is allowed to dash right now.
-- Conditions:
--   1. Enough time must have passed since LastDashTime, per DashCooldown.
function PlayerPolicy.CanDash(player: PlayerTypes.Player, currentTime: number): boolean
	return currentTime - player.LastDashTime >= PlayerConfig.DashCooldown
end

return PlayerPolicy