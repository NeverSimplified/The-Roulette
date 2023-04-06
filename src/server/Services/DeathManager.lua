local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local red = import("Packages/red")
local Ragdolling = import("Modules/Ragdolling")
local Promise = import("Packages/promise")

local DeathRagdoll = red.Server("DeathRagdoll")
local DeathRespawn = red.Server("DeathRespawn")

local Traced = {}

local DeathManagerService, super = class("DeathManager", Superclass)

function DeathManagerService:__init()
    super:__init(self.ClassName)
end

function DeathManagerService:Start()
    DeathRagdoll:On("DeathRagdoll", function(player)
        if player.Character then
            if Traced[player] then
                Traced[player] = nil
                player:Kick("Attempting to play with remote events, go play something else")
                return
            end
            Traced[player] = true
            if not player.Character:FindFirstChildOfClass("Humanoid") then
                player:Kick("Humanoid removal... really?")
                return
            end
            player.Character.Humanoid.Health = 0
            local character = player.Character
            Promise.new(function(resolve, reject, onCancel)
                while true do
                    for i,characterPiece in pairs(character:GetDescendants()) do
                        if characterPiece:IsA("BasePart") then
                            if characterPiece:GetNetworkOwner() ~= player then
                                characterPiece:SetNetworkOwner(player) -- players loose ownership on death
                            end
                        end
                    end
                    task.wait()
                end
            end):catch(function()
                print(`{player.Name} has despawned!`)
                Traced[player] = nil
            end)
            Ragdolling:Ragdoll(player.Character)
        else
            player:Kick("Awww, seriously?")
        end
    end)
    DeathRespawn:On("DeathRespawn", function(player)
        if not Traced[player] then
            player:Kick("Attempting to manipulate events")
            return
        end
        Traced[player] = nil
        player:LoadCharacter()
    end)
end

return DeathManagerService