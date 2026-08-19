local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Trove = require(ReplicatedStorage.Packages.Trove)

local FormatDuration = require(ReplicatedStorage.Shared.Helpers.FormatDuration)

attempts = 10

local GameplayView = {
	_trove = nil,

	gameplayHUD = nil,
	timerFrame = nil,
	scoreFrame = nil,

	-- ui components
	timerText = nil,
	matchStateText = nil,

	roundText = nil,
	scoreText = nil,
}

function GameplayView:Init()
	self._trove = Trove.new()

	local success, result = pcall(function()
		local playerGUI = player:WaitForChild("PlayerGui", 10)
		if not playerGUI then
			error("PlayerGui not found")
		end
		self.gameplayHUD = playerGUI:WaitForChild("GameplayHUD", 10)
		if not self.gameplayHUD then
			error("GameplayHUD not found in StarterGUI")
		end

		self.scoreFrame = self.gameplayHUD:WaitForChild("RoundUI", 10)
		if not self.scoreFrame then
			error("RoundUI not found in StarterGUI.GameplayHUD")
		end
		self.timerFrame = self.gameplayHUD:WaitForChild("Timer", 10)
		if not self.timerFrame then
			error("Timer not found in StarterGUI.GameplayHUD")
		end

		-- components
		-- timer frame
		self.timerText = self.timerFrame:WaitForChild("TimeRemaining",10)
		if not self.timerText then
			error("TimeRemaining not found in StarterGUI.GameplayHUD.Timer")
		end

		self.matchStateText = self.timerFrame:WaitForChild("StateText",10)
		if not self.matchStateText then
			error("StateText not found in StarterGUI.GameplayHUD.Timer")
		end

		-- round frame
		self.roundText = self.scoreFrame:WaitForChild("RoundText",10)
		if not self.roundText then
			error("RoundText not found in StarterGUI.GameplayHUD.RoundUI")
		end

		self.scoreText = self.scoreFrame:WaitForChild("CurrentScore",10)
		if not self.scoreText then
			error("CurrentScore not found in StarterGUI.GameplayHUD.RoundUI")
		end
	end)

	if not success then
		warn("Failed to initialize GameplayView:", result)
		attempts = attempts - 1
		if attempts > 0 then
			task.wait(0.5)
			return self:Init()
		end
		warn("Exceeded maximum attempts to initialize GameplayView.")
		return false, result
	end
	return true
end

function GameplayView:UpdateTimeRemaining(timeRemaining:number)
	if not self.timerText then
		warn("TimeRemaining not found in StarterGUI.GameplayHUD.Timer")
	end

	self.timerText.Text = FormatDuration(timeRemaining)
end

function GameplayView:UpdateMatchState(MatchState:string)
	if not self.matchStateText then
		warn("StateText not found in StarterGUI.GameplayHUD.Timer")
	end

	self.matchStateText.Text = MatchState
end

function GameplayView:UpdateScore(newScore:number)
	if not self.scoreText then
		warn("CurrentScore not found in StarterGUI.GameplayHUD.RoundUI")
	end

	self.scoreText.Text = tostring(newScore)
end

function GameplayView:UpdateRound(newRound:number)
	if not self.roundText then
		warn("RoundText not found in StarterGUI.GameplayHUD.RoundUI")
	end

	self.roundText.Text = "Current Round: " .. tostring(newRound) 
end

return GameplayView
