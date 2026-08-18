local CrystalTypes = require(script.Parent.CrystalTypes)

local CrystalRules = {}

-- Returns a new Crystal model marked as collected.
-- Immutable: does not modify the original crystal table.
function CrystalRules.MarkCollected(crystal: CrystalTypes.CrystalTypes): CrystalTypes.CrystalTypes
	local newCrystal = table.clone(crystal)
	newCrystal.Collected = true
	return newCrystal
end

return CrystalRules
