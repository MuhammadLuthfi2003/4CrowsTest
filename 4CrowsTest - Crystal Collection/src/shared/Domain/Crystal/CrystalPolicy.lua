-- CrystalPolicy.lua
local CrystalTypes = require(script.Parent.CrystalTypes)

local CrystalPolicy = {}

-- Returns true if this crystal is still eligible to be collected.
-- Prevents a double-collect race when two players touch the same
-- instance in the same frame.
function CrystalPolicy.CanCollect(crystal: CrystalTypes.CrystalTypes): boolean
	return not crystal.Collected
end

return CrystalPolicy