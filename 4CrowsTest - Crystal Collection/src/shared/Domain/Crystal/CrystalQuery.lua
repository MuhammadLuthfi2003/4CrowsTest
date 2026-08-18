local CrystalTypes = require(script.Parent.CrystalTypes)
local CrystalDefinitions = require(script.Parent.CrystalDefinitions)

local CrystalQuery = {}

function CrystalQuery.GetScore(crystal: CrystalTypes.CrystalTypes): number
	return CrystalDefinitions[crystal.Rarity].Score
end

function CrystalQuery.GetRarity(crystal: CrystalTypes.CrystalTypes): CrystalTypes.CrystalRarity
	return crystal.Rarity
end

return CrystalQuery
