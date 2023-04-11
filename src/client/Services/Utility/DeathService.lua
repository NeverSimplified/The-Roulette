local Debris = game:GetService("Debris")
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
local ClientCorpse = red.Client("ClientCorpse")
local CleanNet = red.Client("CleanNet")

local DeathCameraTrove = trove.new()
local ColorCorrection

local SaturationTween = TweenInfo.new(5, Enum.EasingStyle.Sine)
local ContrastTween = TweenInfo.new(3, Enum.EasingStyle.Sine)

local DeathService, super = class("DeathService", Superclass)

local DeadBodyTrack = {}

RunService.Heartbeat:Connect(function()
    for i,body in ipairs(DeadBodyTrack) do
        if not body:FindFirstChildOfClass("Humanoid") then
            table.remove(DeadBodyTrack, i)
            continue
        end
        local Humanoid = body.Humanoid
        for _,object in pairs(body:GetChildren()) do
            if object:IsA("Humanoid") then
                if object.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
                    object.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
            end
        end
        if Humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end
end)

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
                workspace.CurrentCamera.CFrame *= CFrame.new(Humanoid.CameraOffset)
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(origin.Position + Vector3.new(0,4.5,0), Head.Position), 0.8 * deltaTime)
            end)
            task.wait(5)
            local Bash = CollectionService:GetTagged("Bash")[1]
            if Bash then
                Bash:Play()
            end
            if ColorCorrection then
                ColorCorrection.TintColor = Color3.fromRGB(0,0,0)
            end
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
    ClientCorpse:On("ClientCorpse", function(Character)
        Character.Archivable = true
        local ClonedCharacter = Character:Clone()
        Character.Archivable = false
        ClonedCharacter.Parent = workspace:WaitForChild("DeadBodies",3) or workspace.Terrain
        for _,char in pairs(ClonedCharacter:GetChildren()) do
            if char:IsA("BasePart") then
                char.CFrame = Character:FindFirstChild(char.Name).CFrame
            end
        end
        table.insert(DeadBodyTrack, ClonedCharacter)
        Debris:AddItem(ClonedCharacter,30)
    end)
    CleanNet:On("CleanNet", function()
        local DeadBodies = workspace:WaitForChild("DeadBodies", 3) or workspace.Terrain
        if DeadBodies then
            DeadBodies:ClearAllChildren()
        end
    end)
end

return DeathService.new()