local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")

-- // REGISTER CONTROLLERS // --
Knit.AddControllers(PlayerScripts:WaitForChild("Client"):WaitForChild("Controllers"))

-- // START KNIT // --
Knit.Start()
	:andThen(function()
		print("Knit Client Started")

		-- init presentation
		local presentationsFolder = script.Presentation
		for _, presentationFolder in presentationsFolder:GetChildren() do
			for _, presenter in presentationFolder:GetChildren() do
				-- check if name ends with "Presenter"
				if presenter.Name:sub(-9) == "Presenter" then
					local presenterModule = require(presenter)
					task.spawn(function()
						presenterModule:Init()
					end)
				end
			end
		end
	end)
	:catch(warn)
