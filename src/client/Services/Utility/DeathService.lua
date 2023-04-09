local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local red = import("Packages/red")
local trove = import("Packages/trove")

local DeathRagdoll = red.Client("DeathRagdoll")
local DeathRespawn = red.Client("DeathRespawn")

local DeathCameraTrove = trove.new()
local ColorCorrection

local SaturationTween = TweenInfo.new(5, Enum.EasingStyle.Sine)
local ContrastTween = TweenInfo.new(3, Enum.EasingStyle.Sine)

local DeathService, super = class("DeathService", Superclass)

function onCharacter(character)
    local Head = character:WaitForChild("Head") :: Part
    local Humanoid = character:WaitForChild("Humanoid") :: Humanoid -- might not be there yet
    if ColorCorrection then
        local CloneCorrection = ColorCorrection:Clone()
        CloneCorrection.Parent = game.Lighting
        ColorCorrection:Destroy()
        ColorCorrection = nil
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.CameraSubject = Humanoid
        local T = TweenService:Create(CloneCorrection, SaturationTween, {Saturation = 0, Contrast = 0, TintColor = Color3.fromRGB(255,255,255)})
        T:Play()
        T.Completed:Connect(function()
            CloneCorrection:Destroy()
            CloneCorrection = nil
            return
        end)
    end
    local con
    con = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if Humanoid.Health <= 0 then
            con:Disconnect()
            DeathRagdoll:Fire("DeathRagdoll")
            ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Parent = game.Lighting
            ColorCorrection.TintColor = Color3.fromRGB(255,255,255)
            TweenService:Create(ColorCorrection, SaturationTween, {Saturation = -2}):Play()
            TweenService:Create(ColorCorrection, ContrastTween, {Contrast = 0.2}):Play()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            local origin = workspace.CurrentCamera.CFrame
            DeathCameraTrove:Connect(RunService.RenderStepped, function(deltaTime)
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(origin.Position + Vector3.new(0,4.5,0), Head.Position), 0.8 * deltaTime)
            end)
            task.wait(5)
            local Bash = CollectionService:GetTagged("Bash")[1]
            if Bash then
                Bash:Play()
            end
            ColorCorrection.TintColor = Color3.fromRGB(0,0,0)
            task.wait(3)
            local DeathRespawn = red.Client("DeathRespawn")
            DeathRespawn:Fire("DeathRespawn")
        end
    end)
end

function DeathService:__init()
    super.__init(self)
end

function DeathService:Start()
    if Players.LocalPlayer.Character then
        onCharacter(Players.LocalPlayer.Character)
    end
    Players.LocalPlayer.CharacterAdded:Connect(onCharacter)
    Players.LocalPlayer.CharacterRemoving:Connect(function()
        DeathCameraTrove:Clean()
    end)
end

return DeathService.new()