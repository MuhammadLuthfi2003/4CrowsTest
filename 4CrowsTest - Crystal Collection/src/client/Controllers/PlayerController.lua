local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerController = Knit.CreateController({
	Name = "PlayerController",
})

local DASH_KEY = Enum.KeyCode.Q

local PlayerConfig = require(ReplicatedStorage.Shared.Domain.Player.PlayerConfig)

-- client-side prediction values only; server should be the source of truth
-- for anything that affects gameplay outcomes (see note below)
local DASH_SPEED_MULTIPLIER = PlayerConfig.DashMultiplier
local DASH_DURATION = PlayerConfig.DashCooldown

local localPlayer = Players.LocalPlayer

local PlayerService

function PlayerController:KnitInit()
	self._trove = Trove.new()
	self._dashing = false -- simple client-side guard against spamming the remote
end

function PlayerController:KnitStart()
	PlayerService = Knit.GetService("PlayerService")

	self._trove:Add(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == DASH_KEY then
			self:_requestDash()
		end
	end))
end

function PlayerController:_getHumanoid(): Humanoid?
	local character = localPlayer.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

function PlayerController:_applyDashSpeedBoost()
	local humanoid = self:_getHumanoid()
	if not humanoid then
		return
	end

	-- cancel any boost already in progress so re-dashing doesn't stack/desync
	if self._speedBoostTask then
		task.cancel(self._speedBoostTask)
		self._speedBoostTask = nil
	end

	local baseWalkSpeed = self._baseWalkSpeed or humanoid.WalkSpeed
	self._baseWalkSpeed = baseWalkSpeed

	humanoid.WalkSpeed = baseWalkSpeed * DASH_SPEED_MULTIPLIER

	self._speedBoostTask = task.delay(DASH_DURATION, function()
		humanoid.WalkSpeed = self._baseWalkSpeed
		self._baseWalkSpeed = nil
		self._speedBoostTask = nil
	end)
end

function PlayerController:_requestDash()
	if self._dashing then
		return
	end

	self._dashing = true

	PlayerService:RequestDash():andThen(function(success: boolean)
		if success then
			self:_applyDashSpeedBoost()
		else
			-- server rejected the dash (cooldown, policy, etc.)
			-- hook up UI/sound feedback here if desired
		end
	end):catch(function(err)
		warn("Dash request failed:", err)
	end):finally(function()
		self._dashing = false
	end)
end

return PlayerController