local Types = require(script.Parent.CrystalTypes)

local CrystalDefinition: { [Types.CrystalRarity]: Types.CrystalDefinitionTypes } = {
	["Common"] = {
		Rarity = "Common",
		Score = 1,
		SpawnRate = 70
	},
	["Rare"] = {
		Rarity = "Rare",
		Score = 3,
		SpawnRate = 25
	},
	["Epic"] = {
		Rarity = "Epic",
		Score = 8,
		SpawnRate = 5
	},
}

return CrystalDefinition
