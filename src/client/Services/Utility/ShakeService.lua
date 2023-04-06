local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Red = import("Packages/red")
local Shake = import("Packages/shake")
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
    super:__init(self.ClassName)
end

function ShakeService:Start()
    local ClientShake = Red.Client("CameraShake")
    ClientShake:On("CameraShake", function(amplitude, frequency, FadeOutTime, SustainTime, coloring, Transparency, velocity)
        local camShake = Shake.new()
        local function ShakeCamera(pos, rot, done)
            workspace.CurrentCamera.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
            if done then
                camShake:Stop()
            end
        end
        camShake.Amplitude = amplitude
        camShake.Frequency = frequency
        camShake.FadeOutTime = FadeOutTime
        camShake.SustainTime = SustainTime
        camShake:OnSignal(RunService.Heartbeat, ShakeCamera)
        camShake:Start()
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

return ShakeService