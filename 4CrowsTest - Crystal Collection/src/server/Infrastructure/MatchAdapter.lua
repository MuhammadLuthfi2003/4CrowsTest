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
    return match
end

function MatchAdapter.StartMatch()
    MatchAdapter.runningMatch = MatchFactory.Create()

    MatchAdapter.connection = RunService.Heartbeat:Connect(function(deltaTime)
        local match = MatchAdapter.runningMatch
        local previousState = match.State

        match = MatchRules.Tick(match, deltaTime)

        if match.State ~= previousState then
            match = MatchRules.ResetAllCrystals(match)
            MatchAdapter.StateChanged:Fire()

            if match.State == "Intermission" then
                MatchAdapter.OnGameFinished:Fire()
            elseif match.State == "Game" then
                MatchAdapter.OnGameStarted:Fire()
            end
        end

        if MatchPolicy.CanSpawnCrystal(match) then
            match = MatchRules.AddSpawnedCrystal(match)
            MatchAdapter.SpawnCrystal:Fire()
        end

        MatchAdapter.runningMatch = match 
    end)
end

function MatchAdapter.NotifyCrystalSpawned()
	match = MatchRules.AddSpawnedCrystal(match)
end

function MatchAdapter.NotifyCrystalCollected()
	match = MatchRules.RemoveSpawnedCrystal(match)
end

return MatchAdapter