local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Red = import("Packages/red")

local PlayerNetwork, super = class("PlayerNetwork", Superclass)

function PlayerNetwork:__init()
    super:__init(self.ClassName)
end

function PlayerNetwork:Start() 
    local StateNet = Red.Client("HumanoidStates")
    local VelocityNet = Red.Client("ObjectVelocity")
    local BlockedStates = false
    StateNet:On("HumanoidStates",function(state, blockOthers)
        local Character = Players.LocalPlayer.Character
        if Character then
            if blockOthers then
                BlockedStates = true
                local Items = Enum.HumanoidStateType:GetEnumItems()
                local Exceptions = {Enum.HumanoidStateType.None}
                for i,enum in ipairs(Items) do
                    if table.find(Exceptions, enum) or enum == state then
                        table.remove(Items, i)
                    end
                end
                for i,validEnum in pairs(Items) do
                    Character.Humanoid:SetStateEnabled(validEnum, false)
                end
            else
                if BlockedStates then
                    BlockedStates = false
                    local Items = Enum.HumanoidStateType:GetEnumItems()
                    local Exceptions = {Enum.HumanoidStateType.None}
                    for i,enum in ipairs(Items) do
                        if table.find(Exceptions, enum) then
                            table.remove(Items, i)
                        end
                    end
                    for i,validEnum in pairs(Items) do
                        Character.Humanoid:SetStateEnabled(validEnum, true)
                    end
                end
            end
            Character.Humanoid:ChangeState(state)
        end
    end)
    VelocityNet:On("ObjectVelocity",function(object, velocity)
        object:ApplyImpulse(velocity)
    end)
end

return PlayerNetwork