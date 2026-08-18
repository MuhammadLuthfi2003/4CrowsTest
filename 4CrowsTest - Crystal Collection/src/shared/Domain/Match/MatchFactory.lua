local Types = require(script.Parent.MatchTypes)
local Config = require(script.Parent.MatchConfig)

local MatchFactory = {}

function MatchFactory.Create(): Types.MatchTypes
	return {
		RemainingTime = Config.IntermissionTime,
		State = "Intermission",
	}
end

return MatchFactory
