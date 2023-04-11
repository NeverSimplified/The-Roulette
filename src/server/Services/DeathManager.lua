local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local red = import("Packages/red")
local Ragdolling = import("Modules/Ragdolling")
local Promise = import("Packages/promise")
local Trove = import("Packages/trove")

local DeathTrove = Trove.new()

local LobbyTeam = CollectionService:GetTagged("LobbyTeam")[1]

local DeathRagdoll = red.Server("DeathRagdoll")
local DeathRespawn = red.Server("DeathRespawn")
local ClientCorpse = red.Server("ClientCorpse", {"ClientCorpse"})

local Traced = {}

local DeathManagerService, super = class("DeathManager", Superclass)

local Bodies = Instance.new("Folder")
Bodies.Name = 'DeadBodies'
Bodies.Parent = workspace

function DeathManagerService:__init()
    super.__init(self)
end

function DeathManagerService:Start()
    DeathRagdoll:On("DeathRagdoll", function(player)
        if player.Character then
            if Traced[player] then
                Traced[player] = nil
                return
            end
            Traced[player] = true
            if not player.Character:FindFirstChildOfClass("Humanoid") then
                player:Kick("Humanoid removal... really?")
                return
            end
            player.Character.Humanoid.Health = 0
            local character = player.Character
            DeathTrove:Connect(RunService.Heartbeat, function()
                for i,characterPiece in pairs(character:GetDescendants()) do
                    if characterPiece:IsA("BasePart") then
                        if characterPiece:IsDescendantOf(workspace) then
                            if characterPiece:GetNetworkOwner() ~= player then
                                characterPiece:SetNetworkOwner(player) -- players loose ownership on death
                            end
                        end
                    end
                end
                task.wait()
            end)
            Ragdolling:Ragdoll(player.Character)
        else
            player:Kick("Awww, seriously?")
        end
    end)
    DeathRespawn:On("DeathRespawn", function(player)
        if not Traced[player] then
            return
        end
        DeathTrove:Clean()
        Traced[player] = nil
        if player.Team then
            if player.Team.Name == 'Playing' then
                local Character = player.Character
                if Character then
                    player.Team = LobbyTeam
                    ClientCorpse:FireAll("ClientCorpse",Character)
                end
            end
        end
        player:LoadCharacter()
    end)
end

return DeathManagerService