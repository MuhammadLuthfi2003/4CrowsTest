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
    SpawnCrystal = Signal.new(),
}

function MatchAdapter.StartMatch()
    -- create the match
    MatchAdapter.runningMatch = MatchFactory.Create()

    -- create the connection
    MatchAdapter.connection = RunService.Heartbeat:Connect(function(deltaTime)
		local previousState = match.State

		-- 2. Advance the timer/state via the pure rules module
		match = MatchRules.Tick(match, deltaTime)

		-- 3. React to a state transition (Intermission <-> Game)
		if match.State ~= previousState then
			match = MatchRules.ResetAllCrystals(match)

            if (match.State == "Intermission") then
                MatchAdapter.OnGameFinished:Fire()
            elseif (match.State == "Game") then
                MatchAdapter.OnGameStarted:Fire()
            end
		end

		-- 4. Ask Policy whether spawning is currently allowed, then apply via Rules
		if MatchPolicy.CanSpawnCrystal(match) then
			match = MatchRules.AddSpawnedCrystal(match)
			-- TODO: actually instantiate the crystal in the world and
			-- CollectionService:AddTag(crystalInstance, "Crystal")
            MatchAdapter.SpawnCrystal:Fire()
		end
    end)
end



return MatchAdapter