local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local red = import("Packages/red")
local Ragdolling = import("Modules/Ragdolling")

local GunTrace = Instance.new("BindableEvent")
GunTrace.Name = 'GunTracing'
GunTrace.Parent = ServerStorage

local GunshotRed = red.Server("GunshotRed", {"GunshotRed"})
local ObjectVelocity = red.Server("ObjectVelocity", {"ObjectVelocity"})
local ShakeNet = red.Server("CameraShake", {"CameraShake"})

local GunService, super = class("GunService", Superclass)

function GunService:__init()
    super.__init(self)
end

function GunService:Start()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            character.ChildAdded:Connect(function(obj)
                if obj:IsA("Tool") and CollectionService:HasTag(obj, "Guns") then
                    local NewWeld = Instance.new("Motor6D")
                    NewWeld.Parent = character['Right Arm']
                    NewWeld.Part0 = character['Right Arm']
                    NewWeld.Part1 = obj.PrimaryPart
                    NewWeld:SetAttribute("Used", true)
                    local rightGrip = character["Right Arm"]:WaitForChild("RightGrip",2)
                    if rightGrip then
                        rightGrip:Destroy()
                    end
                    for _,mesh in pairs(obj:GetChildren()) do
                        if mesh:IsA("MeshPart") then
                            mesh.Transparency = 0
                        end
                    end
                end       
            end)
            character.ChildRemoved:Connect(function(obj)
                if obj:IsA("Tool") and CollectionService:HasTag(obj, "Guns") then
                    if character["Right Arm"]:FindFirstChildOfClass("Motor6D") then
                        if character["Right Arm"]:FindFirstChildOfClass("Motor6D"):GetAttribute("Used") then
                            character["Right Arm"]:FindFirstChildOfClass("Motor6D"):Destroy()
                        end
                    end
                    for _,mesh in pairs(obj:GetChildren()) do
                        if mesh:IsA("MeshPart") then
                            mesh.Transparency = 1
                        end
                    end
                end      
            end)
        end)
    end)
    GunshotRed:On("GunshotRed", function(player,target)
        if player.Character then
            local Tool = player.Character:FindFirstChildOfClass("Tool")
            if Tool then
                if Tool:GetAttribute("Used") then
                    return
                end
                if CollectionService:HasTag(Tool, "Guns") then
                    if target then
                        Tool:SetAttribute("Used", true)
                        local Firepart = Tool.FirePart
                        for _,effect in pairs(Firepart:GetChildren()) do
                            if effect:IsA("Sound") then
                                effect:Play()
                            elseif effect:IsA("ParticleEmitter") then
                                effect:Emit(5)
                            elseif effect:IsA("PointLight") then
                                effect.Enabled = true
                                task.delay(0.1, function()
                                    effect.Enabled = false
                                end)
                            end
                        end
                        GunTrace:Fire(player, target)
                        local Humanoid = target:FindFirstChildOfClass("Humanoid")
                        if Humanoid then
                            Humanoid:TakeDamage(Humanoid.Health)
                        end
                        local Player = Players:GetPlayerFromCharacter(target)
                        Ragdolling:Ragdoll(target)
                        local Velocity = (target.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Unit * 500
                        if Player then
                            for _,chair in pairs(CollectionService:GetTagged("Chairs")) do
                                if chair:GetAttribute("Occupant") == Player.Name then
                                    for _, object in pairs(chair:GetChildren()) do
                                        object.Anchored = false
                                        object.CanCollide = true
                                        object:SetNetworkOwner(nil)
                                        object:ApplyImpulse(Velocity/500*2)
                                    end
                                end
                            end
                            ObjectVelocity:Fire(Player, "ObjectVelocity", target.HumanoidRootPart, Velocity * 0.8 + Vector3.new(0,350,0))
                        else
                            target.HumanoidRootPart:ApplyImpulse(Velocity)
                        end
                        local Player = Players:GetPlayerFromCharacter(target)
                        if Player then
                            ShakeNet:FireAllExcept(Player,"CameraShake",150,1,Color3.fromRGB(251, 251, 251),0.8,0.5,true)
                            ShakeNet:Fire(Player,"CameraShake",350,1.5,Color3.fromRGB(182, 3, 3),0.5,0.5,true)
                        else
                            ShakeNet:FireAll("CameraShake",150,1,Color3.fromRGB(251, 251, 251),0.8,0.5,true)
                        end
                        Debris:AddItem(Tool, 5)
                    end
                end
            end
        end
    end)
end

return GunService.new()