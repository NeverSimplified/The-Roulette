local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Red = import("Packages/red")

local LimbService,super = class("LimbHealthService", Superclass)

local Net = Red.Server("CameraShake", {
    "CameraShake"
})

local HPSpreadSheet = {
    ['Head'] = math.huge;
    ['Torso'] = 100;
    ['Right Arm'] = 50;
    ['Left Arm'] = 50;
    ['Right Leg'] = 60;
    ['Left Leg'] = 60;
}

local LimbDebris = Instance.new("Folder")
LimbDebris.Parent = workspace
LimbDebris.Name = 'LimbDebris'

function LimbDestructionSound(object)
    local Sound = Instance.new("Sound")
    Sound.Parent = object
    Sound.Name = 'LimbDestruction'
    Sound.SoundId = 'rbxassetid://12440068167'
    Sound.PlaybackSpeed = 1.4
    Sound.Volume = 0.6
    Sound:Play()
    Sound.Ended:Connect(function()
        Sound:Destroy()
    end)
end

function CreateHumanoidModel(character)
    local Model = Instance.new("Model")
    Model.Name = character.Name
    Model.Parent = LimbDebris
    local ClonedHumanoid = character.Humanoid:Clone()
    ClonedHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
    ClonedHumanoid.MaxHealth = math.huge
    ClonedHumanoid.Health = math.huge
    ClonedHumanoid.Parent = Model
    ClonedHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    for _,rest in pairs(character:GetChildren()) do
        if not rest:IsA("BasePart") and rest.Name ~= 'Animate' and not rest:IsA("Accessory") and not rest:IsA("Humanoid") then
            rest:Clone().Parent = Model
        end
    end
    Debris:AddItem(Model, 30)
    return Model
end

function WeldBlood(weldTo)
    local Blood = CollectionService:GetTagged("BloodPart")[1]
    if Blood then
        local Clone = Blood:Clone()
        CollectionService:RemoveTag(Clone, "BloodPart")
        Clone.Parent = LimbDebris
        Clone:SetNetworkOwner(nil)
        Clone.CFrame = weldTo.CFrame
        local Weld = Instance.new("Weld")
        Weld.Parent = Clone
        Weld.Part0 = Clone
        Weld.Part1 = weldTo
        Weld.C0 = Weld.Part0.CFrame:Inverse()
        Weld.C1 = Weld.Part1.CFrame:Inverse()
        for _,blood in pairs(Clone:GetChildren()) do
            if blood:IsA("ParticleEmitter") then
                blood.Enabled = true
                task.delay(1, function()
                    blood.Enabled = false
                end)
            end
        end
        task.delay(7, function()
            Clone:Destroy()
        end)
    end
end

function OnCharacterAdded(character)
    local Humanoid = character:WaitForChild("Humanoid")
    for _,objectInPairs in pairs(character:GetChildren()) do
        if HPSpreadSheet[objectInPairs.Name] then
            objectInPairs:SetAttribute("Health", HPSpreadSheet[objectInPairs.Name])
            local Last = HPSpreadSheet[objectInPairs.Name]
            local con
            con = objectInPairs:GetAttributeChangedSignal("Health"):Connect(function()
                local Lost = math.clamp(Last - objectInPairs:GetAttribute("Health"),0,100)
                Last = objectInPairs:GetAttribute("Health")
                if Last <= 0 then
                    con:Disconnect()
                    local Model = CreateHumanoidModel(character)
                    LimbDestructionSound(objectInPairs)
                    local Player = Players:GetPlayerFromCharacter(character)
                    if Player then
                        if objectInPairs.Name == 'Head' then
                            Net:Fire(Player,"CameraShake",550,1,Color3.fromRGB(255, 57, 57),0.2,0.5)
                        else
                            Net:Fire(Player,"CameraShake",250,1,Color3.fromRGB(255, 57, 57),0.7,0.5)
                        end
                    end
                    if not objectInPairs:GetAttribute("Exploded") then
                        local ClonedObject = objectInPairs:Clone()
                        ClonedObject.Parent = Model
                        ClonedObject.CFrame = objectInPairs.CFrame
                        ClonedObject.AssemblyLinearVelocity = objectInPairs.AssemblyLinearVelocity
                        ClonedObject.CanCollide = true
                        if objectInPairs.Name == 'Head' then
                            for _,object in pairs(character:GetChildren()) do
                                if object:IsA("Accessory") then
                                    local ClonedHat = object:Clone()
                                    ClonedHat.Parent = Model
                                    local Handle = ClonedHat.Handle
                                    local AccessoryWeld = Handle.AccessoryWeld
                                    AccessoryWeld.Part0 = Handle
                                    AccessoryWeld.Part1 = ClonedObject
                                    object:Destroy()
                                end
                            end
                        end
                        ClonedObject:SetNetworkOwner(nil)
                        local GoreExternal = CollectionService:GetTagged("Gore-External")[1]
                        if GoreExternal then
                            local LimbAddon = GoreExternal:FindFirstChild(objectInPairs.Name)
                            if LimbAddon then
                                local ClonedAddon = LimbAddon:Clone()
                                ClonedAddon.Parent = ClonedObject
                                ClonedAddon:PivotTo(ClonedObject.CFrame)
                                ClonedAddon.PrimaryPart.Transparency = 1
                                ClonedAddon.PrimaryPart:SetNetworkOwner(nil)
                                local Weld = Instance.new("Weld")
                                Weld.Name = 'Main_Weld'
                                Weld.Part0 = ClonedObject
                                Weld.Part1 = ClonedAddon.PrimaryPart
                                Weld.C0 = ClonedObject.CFrame:Inverse()
                                Weld.C1 = ClonedAddon.PrimaryPart.CFrame:Inverse()
                                Weld.Parent = ClonedAddon
                                WeldBlood(ClonedAddon.PrimaryPart)
                            end
                        end
                    else
                        if objectInPairs.Name == 'Head' then
                            for _,object in pairs(character:GetChildren()) do
                                if object:IsA("Accessory") then
                                    object:Destroy()
                                end
                            end
                        end
                    end
                    WeldBlood(objectInPairs)
                end
                if objectInPairs.Name:lower():find('leg') then
                    local RLeg = character:FindFirstChild("Right Leg")
                    local LLeg = character:FindFirstChild("Left Leg")
                    if RLeg then
                        if RLeg:GetAttribute("Health") <= 0 and objectInPairs ~= RLeg then
                            Lost = Humanoid.Health
                        end
                    end
                    if LLeg then
                        if LLeg:GetAttribute("Health") <= 0 and objectInPairs ~= LLeg then
                            Lost = Humanoid.Health
                        end
                    end
                end
                Humanoid:TakeDamage(Lost)
            end)
        end
    end
end

function OnPlayerAdded(player)
    if player.character then
        OnCharacterAdded(player.character)
    end
    player.CharacterAdded:Connect(OnCharacterAdded)
end

function LimbService:__init()
    super.__init(self)
end

function LimbService:Start()
    for _,player in pairs(Players:GetChildren()) do
        OnPlayerAdded(player)
    end
    Players.PlayerAdded:Connect(OnPlayerAdded)
end

return LimbService.new()