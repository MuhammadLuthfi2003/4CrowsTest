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

-- 1. Own the mutable state: model + instance + Trove per crystalId
local crystals: { [string]: any } = {}
local instances: { [string]: Instance } = {}
local troves: { [string]: any } = {}

CrystalAdapter.CrystalCollected = Signal.new() -- (crystalId, rarity, playerWhoCollected)

-- 2. Spawn: create model, create world instance, wire pickup detection
function CrystalAdapter.SpawnCrystal(rarity: Types.CrystalRarity, cframe: CFrame): string
	local crystal = CrystalFactory.Create(HttpService:GenerateGUID(false), rarity)
	local trove = Trove.new()

	local instance = trove:Add(ReplicatedStorage.Assets.Crystal:Clone()) -- adjust to your asset path
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

return CrystalAdapter