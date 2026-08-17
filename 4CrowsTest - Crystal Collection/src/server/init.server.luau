local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ServerScriptService = game:GetService("ServerScriptService")

-- // REGISTER SERVICES // --
Knit.AddServices(ServerScriptService.Server.Services)

-- // START KNIT // --
Knit.Start():andThen(function()
    print("Knit Server Started")
end):catch(warn)
