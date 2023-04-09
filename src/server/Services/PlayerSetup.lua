local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")

local PlayerSetup, super = class("PlayerSetup", Superclass)

local CharacterFolder = Instance.new("Folder")
CharacterFolder.Name = 'Characters'
CharacterFolder.Parent = workspace

function PlayerSetup:__init()
    super.__init(self)
end

function PlayerSetup:Start()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait()
            character.Parent = CharacterFolder
            local Health = character:FindFirstChild("Health")
            if Health then
                Health:Destroy()
            end
            local GoreCharacter = CollectionService:GetTagged("Gore-Character")[1]
            if GoreCharacter then
                local ClonedGore = GoreCharacter:Clone()
                CollectionService:RemoveTag(ClonedGore, 'Gore-Character')
                ClonedGore.Parent = character
                ClonedGore.PrimaryPart.CFrame = character.HumanoidRootPart.CFrame
                local Weld = Instance.new("Weld")
                Weld.Name = 'Main_Weld'
                Weld.Part0 = ClonedGore.PrimaryPart
                Weld.Part1 = character.HumanoidRootPart
                Weld.C0 = Weld.Part0.CFrame:Inverse()
                Weld.C1 = Weld.Part1.CFrame:Inverse()
                Weld.Parent = ClonedGore
            end
        end)
    end)
end

return PlayerSetup.new()