local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local import = require(ReplicatedStorage.Packages.import)

local RandomNum = Random.new()

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Red = import("Packages/red")
local Roact = import("Packages/roact")
local Flipper = import("Packages/flipper")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local ShakeService, super = class("ShakeService", Superclass)

local ColoringUI = Roact.Component:extend("ColoringUI")

function ColoringUI:init()
    self.FrameRef = Roact.createRef()
    self.motor = Flipper.SingleMotor.new(self.props.Transparency)
    local binding, setBinding = Roact.createBinding(self.motor:getValue())
    self.binding = binding
    self.motor:onStep(setBinding)
    self.motor:setGoal(Flipper.Linear.new(1, {velocity = self.props.Velocity}))
end
function ColoringUI:render()
    return Roact.createElement("ScreenGui", {
        Name = 'Interface';
        ResetOnSpawn = true;
        IgnoreGuiInset = true;
    },{
        Frame = Roact.createElement("Frame", {
            [Roact.Ref] = self.FrameRef;
            Size = UDim2.fromScale(1,1);
            BackgroundColor3 = self.props.Color or Color3.fromRGB(255,255,255);
            BackgroundTransparency = self.binding;
            AnchorPoint = Vector2.new(0.5,0.5);
            Position = UDim2.fromScale(0.5,0.5);
        })
    })
end

function ShakeService:__init()
    super.__init(self)
end

function ShakeService:Start()
    local ClientShake = Red.Client("CameraShake")
    ClientShake:On("CameraShake", function(strength, length, coloring, Transparency, velocity)
        task.spawn(function()
            local BeginTime = os.clock()
            while true do
                if os.clock() - BeginTime >= length then
                    break
                end
                local Percentage = 1-((os.clock() - BeginTime) / length)
                local X = RandomNum:NextInteger(-strength,strength) / 1000 * Percentage
                local Y = RandomNum:NextInteger(-strength,strength) / 1000 * Percentage
                local Z = RandomNum:NextInteger(-strength,strength) / 1000 * Percentage
                local Character = Players.LocalPlayer.Character
                if Character then
                    local Humanoid = Character.Humanoid
                    Humanoid.CameraOffset = Vector3.new(X,Y,Z)
                    workspace.CurrentCamera.CFrame *= CFrame.Angles(X/strength, Y/strength, Z/strength)
                end
                task.wait()
            end
            local Character = Players.LocalPlayer.Character
            if Character then
                local Humanoid = Character.Humanoid
                Humanoid.CameraOffset = Vector3.new(0,0,0)
            end
        end)
        if coloring then
            local UI = Roact.createElement(ColoringUI, {
                Color = coloring,
                Transparency = Transparency or 0.3;
                Velocity = velocity or 0.5;
            })
            local holder = Roact.mount(UI, PlayerGui, "ColoringUI")
            task.wait(5)
            Roact.unmount(holder)
        end
    end)
end

return ShakeService.new()