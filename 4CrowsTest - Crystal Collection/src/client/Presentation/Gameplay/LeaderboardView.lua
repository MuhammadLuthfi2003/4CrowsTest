local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Trove = require(ReplicatedStorage.Packages.Trove)

attempts = 10

local LeaderboardView = {
	_trove = nil,

	gameplayHUD = nil,
	leaderBoardFrame = nil,
    leaderboardEntryTemplate = nil,
    entryContainer = nil,
    closeButton = nil
}

function LeaderboardView:Init()
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

		self.leaderboardEntryTemplate = ReplicatedStorage.UITemplate:WaitForChild("RankFrame", 10)
		if not self.leaderboardEntryTemplate then
			error("RankFrame not found in ReplicatedStorage.UITemplate")
		end

        self.entryContainer = self.leaderBoardFrame:WaitForChild("LeaderboardContainer",10)
        if not self.entryContainer then
			error("LeaderboardContainer not found in StarterGUI.GameplayHUD.LeaderboardUI")
		end

        self.closeButton = self.leaderBoardFrame:WaitForChild("CloseButton",10)
        if not self.closeButton then
			error("CloseButton not found in StarterGUI.GameplayHUD.LeaderboardUI")
		end

        -- automatically bind events to the close button
        self:BindButton()
	end)

	if not success then
		warn("Failed to initialize LeaderboardView:", result)
		attempts = attempts - 1
		if attempts > 0 then
			task.wait(0.5)
			return self:Init()
		end
		warn("Exceeded maximum attempts to initialize LeaderboardView.")
		return false, result
	end
	return true
end

function LeaderboardView:BindButton()
    if not self.closeButton then
        warn("CloseButton not found in StarterGUI.GameplayHUD.LeaderboardUI")
    end

    self.closeButton.MouseButton1Click:Connect(function()
        self:ToggleLeaderboard(false)
    end)
end

function LeaderboardView:ToggleLeaderboard(isShow:boolean)
    self.leaderBoardFrame = self.gameplayHUD:WaitForChild("LeaderboardUI", 10)
    if not self.leaderBoardFrame then
        warn("LeaderBoardGUI not found in StarterGUI.GameplayHUD")
    end

    self.leaderBoardFrame.Visible = isShow
    self.leaderBoardFrame.Interactable = isShow
end

function LeaderboardView:AddEntry()
end

function LeaderboardView:DeleteAllEntry()
end

return LeaderboardView
