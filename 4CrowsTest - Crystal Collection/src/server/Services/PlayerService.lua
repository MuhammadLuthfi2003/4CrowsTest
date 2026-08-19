local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")

local Infrastructure = script.Parent.Parent.Infrastructure
local PlayerAdapter = require(Infrastructure.PlayerAdapter)
local MatchAdapter = require(Infrastructure.MatchAdapter)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {
		ScoreChanged = Knit.CreateSignal()
	},
})

function PlayerService.Client:RequestDash(player: Player)
	return PlayerAdapter.TryDash(player.UserId)
end

function PlayerService.Client:GetScore(player: Player)
	local model = PlayerAdapter.GetPlayer(player.UserId)
	return model and model.CurrentPoint or 0
end

function PlayerService.Client:GetTopPlayers(player: Player, count: number?)
	local top = PlayerAdapter.GetTopPlayers(count or 3)
	local result = {}

	for rank, entry in top do
		local topPlayer = Players:GetPlayerByUserId(entry.UserId)
		table.insert(result, {
			Rank = rank,
			Name = topPlayer and topPlayer.Name or "Unknown",
			Score = entry.Model.CurrentPoint,
		})
	end

	return result
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
			self.Client.ScoreChanged:Fire(player, model.CurrentPoint)
		end
	end)
end

return PlayerService