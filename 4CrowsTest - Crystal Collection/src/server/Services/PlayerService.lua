local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")

local Infrastructure = script.Parent.Parent.Infrastructure
local PlayerAdapter = require(Infrastructure.PlayerAdapter)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

function PlayerService.Client:RequestDash(player: Player)
	return PlayerAdapter.TryDash(player.UserId)
end

function PlayerService.Client:GetScore(player: Player)
	local model = PlayerAdapter.GetPlayer(player.UserId)
	return model and model.CurrentPoint or 0
end

function PlayerService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		PlayerAdapter.AddPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerAdapter.RemovePlayer(player)
	end)

	for _, player in Players:GetPlayers() do
		PlayerAdapter.AddPlayer(player)
	end

	PlayerAdapter.ScoreChanged:Connect(function(userId, model)
		local player = Players:GetPlayerByUserId(userId)
		if player then
			PlayerService.Client.ScoreChanged:Fire(player, model.CurrentPoint)
		end
	end)
end

return PlayerService