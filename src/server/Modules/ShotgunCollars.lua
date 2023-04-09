local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local import = require(ReplicatedStorage.Packages.import)
local Red = import("Packages/red")

local CollarTemplate = CollectionService:GetTagged("ShotgunCollar")[1]

local Net = Red.Server("CameraShake", {"CameraShake"})
local BeepNet = Red.Server("BeepNet", {"BeepNet"})

local Collars = {}
Collars.__index = Collars

function Collars:ExplodeCollar(timer)
    if timer then
        BeepNet:FireAll("BeepNet", timer-1, self.Model)
        if self.Model then
            TweenService:Create(self.Model.light, TweenInfo.new(timer-1, Enum.EasingStyle.Linear), {Color = Color3.fromRGB(160, 24, 17)}):Play()
        end
        task.wait(timer)
    else
        if self.Model then
            self.Model.light.Color = Color3.fromRGB(248, 43, 43)
        end
    end
    if self.Character then
        local Head = self.Character:FindFirstChild("Head")
        if Head then
            local Player = Players:GetPlayerFromCharacter(self.Character)
            if Player then
                Net:FireAllExcept(Player,"CameraShake",250,1,Color3.fromRGB(251, 251, 251),0.8,0.5)
            else
                Net:FireAll("CameraShake",250,1,Color3.fromRGB(251, 251, 251),0.8,0.5)
            end
            if self.Model then
                self.Model.Head.shot:Play()
            end
            Head:SetAttribute("Exploded", true)
            Head:SetAttribute("Health",0)
        end
    end
end

function Collars.new(character)
    local NewCollar = {}
    setmetatable(NewCollar, Collars)
    NewCollar.Character = character
    if CollarTemplate then
        local Collar = CollarTemplate:Clone()
        Collar.Parent = character
        Collar.PrimaryPart.CFrame = character.Head.CFrame
        local Weld = Instance.new("Weld")
        Weld.Parent = Collar
        Weld.Name = 'Main_Weld'
        Weld.Part0 = character.Torso
        Weld.Part1 = Collar.PrimaryPart
        Weld.C0 = Weld.Part0.CFrame:Inverse()
        Weld.C1 = Weld.Part1.CFrame:Inverse()
        NewCollar.Model = Collar
        Collar.PrimaryPart.Anchored = false
        Collar.Head.equip:Play()
        Collar.Head.lock:Play()
    end
    return NewCollar
end

return Collars