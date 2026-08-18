local Types = require(script.Parent.CrystalTypes)

local CrystalFactory = {}

function CrystalFactory.Create(id: string, rarity: Types.CrystalRarity): Types.CrystalTypes
	return {
		CrystalId = id,
		Rarity = rarity,
		Collected = false,
	}
end

return CrystalFactory
