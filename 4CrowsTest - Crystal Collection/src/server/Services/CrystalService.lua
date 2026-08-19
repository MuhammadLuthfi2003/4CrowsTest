local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Infrastructure = script.Parent.Parent.Infrastructure
local CrystalAdapter = require(Infrastructure.CrystalAdapter)
local MatchAdapter = require(Infrastructure.MatchAdapter)
local PlayerAdapter = require(Infrastructure.PlayerAdapter)

local MatchDomain = ReplicatedStorage.Shared.Domain.Match
local MatchPolicy = require(MatchDomain.MatchPolicy) -- or wherever these live relative to Service
local MatchRules = require(MatchDomain.MatchRules)

local Signal = require(ReplicatedStorage.Packages.Signal)

local CrystalDomain = ReplicatedStorage.Shared.Domain.Crystal
local CrystalDefinition = require(CrystalDomain.CrystalDefinition)

local CrystalService = Knit.CreateService({
	Name = "CrystalService",
	Client = {},
})

local spawnZone: BasePart = workspace.CrystalSpawnZone 

function CrystalService:GetRandomSpawnPoint(): CFrame
	local halfSize = spawnZone.Size / 2

	local offset = Vector3.new(
		math.random(-halfSize.X, halfSize.X),
		halfSize.Y, -- sit on top of the part
		math.random(-halfSize.Z, halfSize.Z)
	)

	return spawnZone.CFrame * CFrame.new(offset)
end

function CrystalService:SpawnCrystalAtRandomPoint()
	local cframe = self:GetRandomSpawnPoint()
	CrystalAdapter.SpawnCrystal(cframe)
end

function CrystalService:KnitStart()
	-- Clear the board on Intermission <-> Game transitions
	MatchAdapter.StateChanged:Connect(function(_, newState)
		for _, crystalId in CrystalAdapter.GetAllCrystalIds() do
			CrystalAdapter.RemoveCrystal(crystalId)
		end
	end)

	CrystalAdapter.CrystalCollected:Connect(function(crystalId, rarity, player)
		local crystalDef = CrystalDefinition[rarity]
		print("[CrystalService] awarding score to", player.Name, "def:", crystalDef)
		PlayerAdapter.AddScore(player.UserId, crystalDef, MatchAdapter.GetMatch())
	end)

    MatchAdapter.SpawnCrystal:Connect(function()
        self:SpawnCrystalAtRandomPoint()
    end)
end

return CrystalService