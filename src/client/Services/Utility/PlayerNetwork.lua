local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Red = import("Packages/red")
local roact = import("Packages/roact")

local PlayerNetwork, super = class("PlayerNetwork", Superclass)

local Blinder = roact.Component:extend("BlindingUI")
function Blinder:render()
    return roact.createElement("ScreenGui", {
        IgnoreGuiInset = true;
        ResetOnSpawn = false;
    },{
        Frame = roact.createElement("Frame", {
            Name = 'Darkness is inevitable';
            Size = UDim2.fromScale(1,1);
            BackgroundColor3 = Color3.fromRGB(0,0,0);
            Visible = self.props.visible or false;
        })
    })
end

function PlayerNetwork:__init()
    super.__init(self)
end

function PlayerNetwork:Start() 
    local StateNet = Red.Client("HumanoidStates")
    local VelocityNet = Red.Client("ObjectVelocity")
    local BlindNet = Red.Client("BlindNet")
    local BashNet = Red.Client("BashNet")
    local BeepNet = Red.Client("BeepNet")
    local BlockedStates = false
    StateNet:On("HumanoidStates",function(state, blockOthers)
        local Character = Players.LocalPlayer.Character
        if Character then
            if blockOthers then
                BlockedStates = true
                local Items = Enum.HumanoidStateType:GetEnumItems()
                local Exceptions = {Enum.HumanoidStateType.None, state}
                for _,enum in ipairs(Items) do
                    if not table.find(Exceptions, enum) then
                        Character.Humanoid:SetStateEnabled(enum, false)
                    end
                end
            else
                if BlockedStates then
                    BlockedStates = false
                    local Items = Enum.HumanoidStateType:GetEnumItems()
                    local Exceptions = {Enum.HumanoidStateType.None}
                    for i,enum in ipairs(Items) do
                        if not table.find(Exceptions, enum) then
                            Character.Humanoid:SetStateEnabled(enum, true)
                        end
                    end
                end
            end
            Character.Humanoid:ChangeState(state)
        end
    end)
    VelocityNet:On("ObjectVelocity",function(object, velocity)
        object:ApplyImpulse(velocity)
    end)
    local UI = roact.createElement(Blinder, {
        visible = false
    })
    local Handle = roact.mount(UI, Players.LocalPlayer.PlayerGui, 'Blindness')
    BlindNet:On("BlindNet",function(visible)
        Handle = roact.update(Handle, roact.createElement(Blinder, {
            visible = visible
        }))
    end)
    BashNet:On("BashNet", function()
        local Bash = CollectionService:GetTagged("Bash")[1]
        if Bash then
            Bash:Play()
        end
    end)
    BeepNet:On("BeepNet", function(timer, model)
        if model then
            local timePercentage = os.clock()
            repeat 
                if model then
                    local Beep = model.Head.beep
                    Beep:Play()
                    Beep.Ended:Wait()
                end
                task.wait(math.clamp(0.7 * (-((os.clock()-timePercentage)/timer)+1), 0.01,1))
            until os.clock() - timePercentage >= timer+1
        end
    end)
end

return PlayerNetwork.new()