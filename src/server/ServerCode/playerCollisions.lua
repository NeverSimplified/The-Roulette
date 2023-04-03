local collisions = {}

local Players = game:GetService("Players")
local Physics = game:GetService("PhysicsService")

function collisions:init()
    Physics:RegisterCollisionGroup("Players")
    Physics:CollisionGroupSetCollidable("Players", "Players", false)
    Physics:CollisionGroupSetCollidable("Default", "Players", true)
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            for i,basepart in pairs(character:GetDescendants()) do
                if basepart:IsA("BasePart") then
                    basepart.CollisionGroup = "Players"
                end
            end
        end)
    end)
end

return collisions