local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Trove = require(ReplicatedStorage.Packages.Trove)

attempts = 10

local GameplayView = {
	_trove = nil,

	gameplayHUD = nil,
	timerFrame = nil,
	scoreFrame = nil,
	leaderBoardFrame = nil,

	leaderboardEntryTemplate = nil,
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
		self.leaderBoardFrame = self.gameplayHUD:WaitForChild("LeaderboardUI", 10)
		if not self.leaderBoardFrame then
			error("LeaderBoardGUI not found in StarterGUI.GameplayHUD")
		end
		self.scoreFrame = self.gameplayHUD:WaitForChild("RoundUI", 10)
		if not self.scoreFrame then
			error("RoundUI not found in StarterGUI.GameplayHUD")
		end
		self.timerFrame = self.gameplayHUD:WaitForChild("Timer", 10)
		if not self.timerFrame then
			error("Timer not found in StarterGUI.GameplayHUD")
		end
		self.leaderboardEntryTemplate = ReplicatedStorage.UITemplate:WaitForChild("RankFrame", 10)
		if not self.leaderboardEntryTemplate then
			error("RankFrame not found in ReplicatedStorage.UITemplate")
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

return GameplayView
