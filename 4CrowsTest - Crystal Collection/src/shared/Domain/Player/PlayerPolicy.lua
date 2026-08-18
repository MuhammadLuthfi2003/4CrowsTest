-- PlayerPolicy.lua
local PlayerTypes = require(script.Parent.PlayerTypes)
local MatchTypes = require(script.Parent.Parent.Match.MatchTypes)
local MatchQuery = require(script.Parent.Parent.Match.MatchQuery)

local PlayerPolicy = {}

function PlayerPolicy.CanAddScore(match: MatchTypes.MatchTypes): boolean
	return MatchQuery.IsMatchActive(match)
end

return PlayerPolicy