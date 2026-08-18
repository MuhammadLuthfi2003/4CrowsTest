local Types = require(script.Parent.PlayerTypes)

local PlayerFactory = {}

function PlayerFactory.Create(playerId: number | string, initialScore: number): Types.Player
	return {
		PlayerId = playerId,
		CurrentPoint = initialScore or 0,
	}
end

return PlayerFactory
