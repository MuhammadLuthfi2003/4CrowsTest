local CrystalTypes = require(script.Parent.CrystalTypes)
local CrystalDefinition = require(script.Parent.CrystalDefinition)

local CrystalQuery = {}

function CrystalQuery.GetScore(crystal: CrystalTypes.CrystalTypes): number
	return CrystalDefinition[crystal.Rarity].Score
end

function CrystalQuery.GetRarity(crystal: CrystalTypes.CrystalTypes): CrystalTypes.CrystalRarity
	return crystal.Rarity
end

return CrystalQuery
