-- Knit Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Infrastructure = script.Parent.Parent.Infrastructure
local MatchAdapter = require(Infrastructure.MatchAdapter)
local CrystalAdapter = require(Infrastructure.CrystalAdapter)

-- Services
local Players = game:GetService("Players")

local MatchService = Knit.CreateService({
	Name = "TemplateService",
	Client = {},
    -- tracks player score
    playerScores = {},
})


function MatchService.Client:GetMatchState(player: Player)
	local match = MatchAdapter.GetMatch()
	return { State = match.State, RemainingTime = match.RemainingTime }
end

function MatchService:KnitStart()
	MatchAdapter.StartMatch()

    CrystalAdapter.CrystalSpawned:Connect(function()
		MatchAdapter.NotifyCrystalSpawned()
	end)

	CrystalAdapter.CrystalCollected:Connect(function(crystalId, rarity, player)
		MatchAdapter.NotifyCrystalCollected()
	end)
end

return MatchService