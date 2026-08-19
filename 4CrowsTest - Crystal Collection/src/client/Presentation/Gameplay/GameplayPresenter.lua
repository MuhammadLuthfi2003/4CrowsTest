local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local GameplayView = require(script.Parent.GameplayView)

local GameplayPresenter = {
	_trove = Trove.new(),
}

function GameplayPresenter:Init()
	GameplayView:Init()

	print("GameplayPresenter Init")
end

return GameplayPresenter
