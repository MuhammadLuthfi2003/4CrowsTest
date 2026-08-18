local Types = require(script.Parent.CrystalTypes)

local CrystalDefinition: { [Types.CrystalRarity]: Types.CrystalDefinitionTypes } = {
	["Common"] = {
		Rarity = "Common",
		Score = 1,
	},
	["Rare"] = {
		Rarity = "Rare",
		Score = 3,
	},
	["Epic"] = {
		Rarity = "Epic",
		Score = 8,
	},
}

return CrystalDefinition
