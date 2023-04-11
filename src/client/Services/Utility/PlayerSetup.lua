local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ChatService = game:GetService("Chat")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")

local PlayerSetup, super = class("PlayerSetup", Superclass)

function PlayerSetup:__init()
    super.__init(self)
end

function PlayerSetup:Start()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        
    end)
end

return PlayerSetup.new()