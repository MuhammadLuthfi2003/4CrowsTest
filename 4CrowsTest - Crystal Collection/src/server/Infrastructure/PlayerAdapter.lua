local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)

local PlayerDomain = ReplicatedStorage.Shared.Domain.Player
local PlayerFactory = require(PlayerDomain.PlayerFactory)
local PlayerRules = require(PlayerDomain.PlayerRules)
local PlayerPolicy = require(PlayerDomain.PlayerPolicy)

local PlayerAdapter = {
	DashUsed = Signal.new()
}

-- 1. Own the mutable state: one model + one Trove per userId
local players: { [number]: any } = {}
local troves: { [number]: any } = {}

PlayerAdapter.ScoreChanged = Signal.new() -- (userId, newPlayerModel)
PlayerAdapter.PlayerRemoved = Signal.new() -- (userId)

-- 2. Lifecycle: create model + Trove on join, clean up on leave
function PlayerAdapter.Init()
	Players.PlayerAdded:Connect(function(player)
		PlayerAdapter.AddPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerAdapter.RemovePlayer(player)
	end)
end

function PlayerAdapter.AddPlayer(player: Player)
	print("[PlayerAdapter] AddPlayer called for", player.UserId, player.Name)
	local trove = Trove.new()
	troves[player.UserId] = trove

	players[player.UserId] = PlayerFactory.Create(player.UserId, 0)

	-- example: hook a leaderstats/dash-cooldown attribute cleanup to trove
	-- trove:Add(someConnection)
end

function PlayerAdapter.RemovePlayer(player: Player)
	local trove = troves[player.UserId]
	if trove then
		trove:Destroy()
		troves[player.UserId] = nil
	end

	players[player.UserId] = nil
	PlayerAdapter.PlayerRemoved:Fire(player.UserId)
end

-- 3. Reads (this is effectively your PlayerQuery, inlined since there's no PlayerQuery module yet)
function PlayerAdapter.GetPlayer(userId: number)
	return players[userId]
end

-- Returns the top `count` players sorted by CurrentPoint descending, as
-- { { UserId = number, Model = playerModel }, ... }
function PlayerAdapter.GetTopPlayers(count: number)
	local list = {}
	for userId, model in players do
		table.insert(list, { UserId = userId, Model = model })
	end

	table.sort(list, function(a, b)
		return a.Model.CurrentPoint > b.Model.CurrentPoint
	end)

	local top = {}
	for i = 1, math.min(count, #list) do
		table.insert(top, list[i])
	end

	return top
end

-- 4. Writes: delegate to Rules, replace stored model, fire signal
function PlayerAdapter.AddScore(userId: number, crystalDef, match)
	local current = players[userId]
	if not current then return end

	if not PlayerPolicy.CanAddScore(match) then return end

	local updated = PlayerRules.AddScore(current, crystalDef)
	players[userId] = updated
	PlayerAdapter.ScoreChanged:Fire(userId, updated)
end

function PlayerAdapter.ResetScore(userId: number)
	local current = players[userId]
	if not current then return end

	local updated = PlayerRules.ResetScore(current)
	players[userId] = updated
	PlayerAdapter.ScoreChanged:Fire(userId, updated)
end

function PlayerAdapter.ResetAllScores()
	for userId in players do
		PlayerAdapter.ResetScore(userId)
	end
end

function PlayerAdapter.TryDash(userId: number): boolean
	local current = players[userId]
	if not current then return false end

	local currentTime = os.clock()
	if not PlayerPolicy.CanDash(current, currentTime) then
		return false
	end

	local updated = PlayerRules.Dash(current, currentTime)
	players[userId] = updated
	PlayerAdapter.DashUsed:Fire(userId, updated)

	return true
end

return PlayerAdapter