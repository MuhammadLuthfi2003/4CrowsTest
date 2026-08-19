local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local GameplayView = require(script.Parent.GameplayView)
local LeaderboardView = require(script.Parent.LeaderboardView)

local GameplayPresenter = {
	_trove = Trove.new(),
	_remainingTime = 0,
	_matchState = nil,
	_round = 0,
}

local MatchService
local PlayerService

function GameplayPresenter:Init()
	GameplayView:Init()
	LeaderboardView:Init()

	MatchService = Knit.GetService("MatchService")
	PlayerService = Knit.GetService("PlayerService")

	-- seed initial state/timer from the server
	self:_syncMatchState()

	-- seed initial score
	PlayerService:GetScore():andThen(function(score)
		GameplayView:UpdateScore(score)
	end):catch(function(err)
		warn("Failed to fetch initial score:", err)
	end)

	-- state transitions
	self._trove:Add(MatchService.OnStateChanged:Connect(function(newState)
		self._matchState = newState
		GameplayView:UpdateMatchState(newState)
		self:_syncMatchState()
	end))

	-- round increments each time a game starts
	self._trove:Add(MatchService.OnGameStarted:Connect(function()
		self._round += 1
		GameplayView:UpdateRound(self._round)
	end))

	-- show the leaderboard with the top 3 scorers once the match ends
	self._trove:Add(MatchService.OnGameFinished:Connect(function()
		PlayerService:GetTopPlayers(3):andThen(function(topPlayers)
			LeaderboardView:ShowLeaderboard(topPlayers)
		end):catch(function(err)
			warn("Failed to fetch top players:", err)
		end)
	end))

	-- score updates pushed from the server
	self._trove:Add(PlayerService.ScoreChanged:Connect(function(newScore)
		GameplayView:UpdateScore(newScore)
	end))

	-- smooth local countdown between syncs
	self._trove:Add(RunService.Heartbeat:Connect(function(dt)
		self:_tick(dt)
	end))

	print("GameplayPresenter Init")
end

function GameplayPresenter:_syncMatchState()
	MatchService:GetMatchState():andThen(function(data)
		self._matchState = data.State
		self._remainingTime = data.RemainingTime

		GameplayView:UpdateMatchState(self._matchState)
		GameplayView:UpdateTimeRemaining(self._remainingTime)
	end):catch(function(err)
		warn("Failed to fetch match state:", err)
	end)
end

function GameplayPresenter:_tick(dt: number)
	if not self._remainingTime then
		return
	end

	self._remainingTime = math.max(self._remainingTime - dt, 0)
	GameplayView:UpdateTimeRemaining(self._remainingTime)
end

return GameplayPresenter