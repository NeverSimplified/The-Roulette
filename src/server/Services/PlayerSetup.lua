local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")

local PlayerSetup, super = class("PlayerSetup", Superclass)

function PlayerSetup:__init()
    super:__init(self.ClassName)
end

function PlayerSetup:Start()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local Humanoid = character:WaitForChild("Humanoid") :: Humanoid
            Humanoid.BreakJointsOnDeath = false;
            Humanoid.RequiresNeck = false;
            local Health = character:FindFirstChild("Health")
            if Health then
                Health:Destroy()
            end
        end)
    end)
end

return PlayerSetup