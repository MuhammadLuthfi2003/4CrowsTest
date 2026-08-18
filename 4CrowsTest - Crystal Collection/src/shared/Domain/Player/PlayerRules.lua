local PlayerTypes = require(script.Parent.PlayerTypes)
local CrystalTypes = require(script.Parent.Parent.Crystal.CrystalTypes)

local PlayerRules = {}

-- Returns a new Player model with score increased by the crystal's Score value.
-- Immutable: does not modify the original player table.
function PlayerRules.AddScore(player: PlayerTypes.Player, crystalDef: CrystalTypes.CrystalDefinitionTypes): PlayerTypes.Player
	local newPlayer = table.clone(player)
	newPlayer.CurrentPoint = newPlayer.CurrentPoint + crystalDef.Score
	return newPlayer
end

-- Returns a new Player model with CurrentPoint reset to 0.
-- Immutable: does not modify the original player table.
function PlayerRules.ResetScore(player: PlayerTypes.Player): PlayerTypes.Player
	local newPlayer = table.clone(player)
	newPlayer.CurrentPoint = 0
	return newPlayer
end

return PlayerRules