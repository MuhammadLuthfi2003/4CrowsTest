local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)

local CrystalDomain = ReplicatedStorage.Shared.Domain.Crystal
local Types = require(CrystalDomain.CrystalTypes)
local CrystalFactory = require(CrystalDomain.CrystalFactory)
local CrystalRules = require(CrystalDomain.CrystalRules)
local CrystalPolicy = require(CrystalDomain.CrystalPolicy)
local CrystalDefinition = require(CrystalDomain.CrystalDefinition)

local CrystalAdapter = {}

local CRYSTAL_DIRECTORY = ReplicatedStorage:WaitForChild("Crystals")

-- 1. Own the mutable state: model + instance + Trove per crystalId
local crystals: { [string]: any } = {}
local instances: { [string]: Instance } = {}
local troves: { [string]: any } = {}

CrystalAdapter.CrystalCollected = Signal.new() -- (crystalId, rarity, playerWhoCollected)
CrystalAdapter.CrystalSpawned = Signal.new()

-- 2. Spawn: create model, create world instance, wire pickup detection
function CrystalAdapter.SpawnCrystal(cframe: CFrame, rarity: Types.CrystalRarity?): string
	rarity = rarity or CrystalAdapter.PickRandomRarity()
	local crystal = CrystalFactory.Create(HttpService:GenerateGUID(false), rarity)
	local trove = Trove.new()

	local instance = trove:Add(CRYSTAL_DIRECTORY:WaitForChild(rarity, 10):Clone()) -- adjust to your asset path
	instance.CFrame = cframe
	instance.Parent = workspace
	CollectionService:AddTag(instance, "Crystal")

	trove:Connect(instance.Touched, function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end

		local current = crystals[crystal.CrystalId]
		if not current or not CrystalPolicy.CanCollect(current) then return end

		crystals[crystal.CrystalId] = CrystalRules.MarkCollected(current)
		CrystalAdapter.CrystalCollected:Fire(crystal.CrystalId, current.Rarity, player)
		CrystalAdapter.RemoveCrystal(crystal.CrystalId)
	end)

	crystals[crystal.CrystalId] = crystal
	instances[crystal.CrystalId] = instance
	troves[crystal.CrystalId] = trove

    CrystalAdapter.CrystalSpawned:Fire(crystal.CrystalId)
	return crystal.CrystalId
end

-- 3. Cleanup: destroy instance + disconnect via Trove
function CrystalAdapter.RemoveCrystal(crystalId: string)
	local trove = troves[crystalId]
	if trove then
		trove:Destroy()
		troves[crystalId] = nil
	end

	crystals[crystalId] = nil
	instances[crystalId] = nil
end

-- 4. Reads
function CrystalAdapter.GetCrystal(crystalId: string)
	return crystals[crystalId]
end

function CrystalAdapter.GetAllCrystalIds(): { string }
	local ids = {}
	for id in crystals do
		table.insert(ids, id)
	end
	return ids
end

-- Picks a random rarity, weighted by each definition's SpawnRate.
-- SpawnRates don't need to sum to 100 — they're treated as relative weights.
function CrystalAdapter.PickRandomRarity(): Types.CrystalRarity
	local totalWeight = 0
	for _, def in CrystalDefinition do
		totalWeight += def.SpawnRate
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for rarity, def in CrystalDefinition do
		cumulative += def.SpawnRate
		if roll < cumulative then
			return rarity
		end
	end

	-- fallback in case of floating point edge case at the boundary
	return "Common"
end

return CrystalAdapter