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

local Traced = {}
local DeadBodyTrack = {}

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
            player:Kick("Attempting to manipulate events")
            return
        end
        DeathTrove:Clean()
        Traced[player] = nil
        if player.Team then
            if player.Team.Name == 'Playing' then
                local Character = player.Character
                if Character then
                    player.Team = LobbyTeam
                    Character.Archivable = true
                    local ClonedCharacter = Character:Clone()
                    Character.Archivable = false
                    ClonedCharacter.Parent = Bodies
                    for _,char in pairs(ClonedCharacter:GetChildren()) do
                        if char:IsA("BasePart") then
                            char.CFrame = player.Character:FindFirstChild(char.Name).CFrame
                        end
                    end
                    table.insert(DeadBodyTrack, ClonedCharacter)
                    Debris:AddItem(ClonedCharacter,30)
                end
            end
        end
        player:LoadCharacter()
    end)
    RunService.Heartbeat:Connect(function(deltaTime)
        for i,body in ipairs(DeadBodyTrack) do
            if not body:FindFirstChildOfClass("Humanoid") then
                table.remove(DeadBodyTrack, i)
                continue
            end
            local Humanoid = body.Humanoid
            for _,object in pairs(body:GetDescendants()) do
                if object:IsA("BasePart") then
                    if object:IsDescendantOf(workspace) then
                        if object.Anchored == false then
                            local IsAnchored = false
                            for _, v in pairs(object:GetConnectedParts(true)) do
                                if v.Anchored then
                                    if v:IsA("Seat") then
                                        v.Disabled = true
                                    else
                                        IsAnchored = true
                                    end
                                end
                            end
                            if not IsAnchored then
                                if object:GetNetworkOwner() ~= nil then
                                    object:SetNetworkOwner(nil)
                                end
                            end
                        end
                    end
                elseif object:IsA("Humanoid") then
                    if object.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
                        object.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    end
                end
            end
            if Humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end)
end

return DeathManagerService