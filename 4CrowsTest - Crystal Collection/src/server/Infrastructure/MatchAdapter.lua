local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MatchDomain = ReplicatedStorage.Shared.Domain.Match
local MatchFactory = require(MatchDomain.MatchFactory)
local MatchRules = require(MatchDomain.MatchRules)
local MatchPolicy = require(MatchDomain.MatchPolicy)
local MatchQuery = require(MatchDomain.MatchQuery)

local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)

local MatchAdapter = {
    runningMatch = nil,
    connection = nil,
    trove = Trove.new(),

    OnGameStarted = Signal.new(),
    OnGameFinished = Signal.new(),
    StateChanged = Signal.new(),
    SpawnCrystal = Signal.new(),
}

function MatchAdapter.GetMatch()
    return MatchAdapter.runningMatch
end

function MatchAdapter.StartMatch()
    MatchAdapter.runningMatch = MatchFactory.Create()

    MatchAdapter.connection = RunService.Heartbeat:Connect(function(deltaTime)
        local match = MatchAdapter.runningMatch
        local previousState = match.State

        match = MatchRules.Tick(match, deltaTime)

        if match.State ~= previousState then
            match = MatchRules.ResetAllCrystals(match)
            MatchAdapter.StateChanged:Fire(match.State)

            if match.State == "Intermission" then
                MatchAdapter.OnGameFinished:Fire()
            elseif match.State == "Game" then
                MatchAdapter.OnGameStarted:Fire()
            end
        end

        MatchAdapter.runningMatch = match

        -- Check policy against the committed state, fire only — no count mutation here
        if MatchPolicy.CanSpawnCrystal(MatchAdapter.runningMatch) then
            MatchAdapter.SpawnCrystal:Fire()
        end
    end)
end

function MatchAdapter.NotifyCrystalSpawned()
	MatchAdapter.runningMatch = MatchRules.AddSpawnedCrystal(MatchAdapter.runningMatch)
end

function MatchAdapter.NotifyCrystalCollected()
	MatchAdapter.runningMatch = MatchRules.RemoveSpawnedCrystal(MatchAdapter.runningMatch)
end

return MatchAdapter