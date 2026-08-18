-- Knit Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Infrastructure = script.Parent.Parent.Infrastructure
local MatchAdapter = require(Infrastructure.MatchAdapter)

-- Services
local Players = game:GetService("Players")

local MatchService = Knit.CreateService({
	Name = "TemplateService",
	Client = {},
    -- tracks player score
    playerScores = {},
})


-- KNIT START
function MatchService:KnitStart()

	local function playerAdded(player: Player)
		-- code playeradded
        
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetChildren()) do
		playerAdded(player)
	end

    MatchAdapter.StartMatch()
end

return MatchService