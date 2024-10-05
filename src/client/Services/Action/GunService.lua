-- CLIENT CONTROLLER FOR THE SYSTEM BEHIND A GUN IN THE GUN HAZARD GAMEMODE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local import = require(ReplicatedStorage.Packages.import)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local trove = import("Packages/trove")
local red = import("Packages/red")
local roact = import("Packages/roact")

local GunshotRed = red.Client("GunshotRed")

local GunTrove = trove.new()

local GunService, super = class("GunService", Superclass)

local GunAnimFolder = CollectionService:GetTagged("GunAnimations")[1]

local ActiveAnimations = {}

-- Render a highlight upon the potential target of the player
local TargetUsernameUI = roact.Component:extend()
function TargetUsernameUI:render()
    return roact.createElement("BillboardGui", {
        AlwaysOnTop = true;
        Size = UDim2.fromOffset(500,50)
    },{
        Label = roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1,0.7);
            AnchorPoint = Vector2.new(0.5,1);
            Position = UDim2.fromScale(0.5,1);
            BackgroundTransparency = 1;
            TextScaled = true;
            TextColor3 = Color3.fromRGB(255,255,255);
            Text = self.props.Username or '';
            Font = Enum.Font.TitilliumWeb;
        }),
        SecondLabel = roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1,0.5);
            AnchorPoint = Vector2.new(0.5,0);
            Position = UDim2.fromScale(0.5,0);
            BackgroundTransparency = 1;
            TextScaled = true;
            TextColor3 = Color3.fromRGB(255, 192, 114);
            Text = `@{self.props.DisplayName}`;
            Font = Enum.Font.TitilliumWeb;
        })
    })
end

local roactHandle
local highLight = nil

function onCharacter(character)
    if highLight then
        highLight:Destroy()
    end
    if roactHandle then
        roact.unmount(roactHandle)
        roactHandle = nil
    end
    local Humanoid = character:WaitForChild("Humanoid")
    local Animator = Humanoid:WaitForChild("Animator")
    -- Broadened system in the case of potential future update which adds more guns or gun remodels as skins.
    character.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") and CollectionService:HasTag(obj, "Guns") then
            local UI = roact.createElement(TargetUsernameUI, {})
            local Target = nil
            if GunAnimFolder then
                local PersonalFolder = GunAnimFolder:FindFirstChild(obj.Name)
                if PersonalFolder then
                    local hold = PersonalFolder:FindFirstChild("Hold")
                    if hold then
                        local Track = Animator:LoadAnimation(hold)
                        Track.Looped = true
                        Track.Priority = Enum.AnimationPriority.Action
                        Track:Play()
                        table.insert(ActiveAnimations, Track)
                    end
                end
            end
            GunTrove:Connect(obj.Activated, function()
                if Target and not obj:GetAttribute("Used") then
                    local Humanoid = Target:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        if Humanoid.Health > 0 then
                            GunshotRed:Fire("GunshotRed", Target)
                            if GunAnimFolder then
                                local PersonalFolder = GunAnimFolder:FindFirstChild(obj.Name)
                                if PersonalFolder then
                                    local Fired = PersonalFolder:FindFirstChild("Fired")
                                    if Fired then
                                        local Track = Animator:LoadAnimation(Fired)
                                        Track.Priority = Enum.AnimationPriority.Action2
                                        Track:Play()
                                        table.insert(ActiveAnimations, Track)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            -- Heartbeat to check if there is a player on the shooter's cursor, if there is one, highlight them using the roact component. Could've used a better function for detection instead of heartbeat.
            GunTrove:Connect(RunService.Heartbeat, function()
                if Mouse.Target and not obj:GetAttribute("Used") then
                    local ModelParent = Mouse.Target:FindFirstAncestorOfClass("Model")
                    if ModelParent then
                        local TargetHumanoid = ModelParent:FindFirstChildOfClass("Humanoid")
                        local HumanoidRootPart = ModelParent:FindFirstChild("HumanoidRootPart")
                        if TargetHumanoid and HumanoidRootPart then
                            if Target ~= ModelParent then
                                if roactHandle then
                                    roact.unmount(roactHandle)
                                end
                                roactHandle = roact.mount(UI,HumanoidRootPart,'Target Name')
                                local DisplayName = TargetHumanoid.DisplayName
                                roactHandle = roact.update(roactHandle,roact.createElement(TargetUsernameUI, {
                                    Username = ModelParent.Name;
                                    DisplayName = DisplayName
                                }))
                                if highLight then
                                    highLight:Destroy()
                                    highLight = nil
                                end
                                Target = ModelParent
                                highLight = Instance.new("Highlight")
                                highLight.Parent = ModelParent
                                highLight.FillTransparency = 0.2
                                highLight.OutlineTransparency = 0
                                highLight.FillColor = Color3.fromRGB(255,70,70)
                                highLight.OutlineColor = Color3.fromRGB(255,0,0)
                                return
                            else
                                return
                            end
                        end
                    end
                end
                Target = nil
                if highLight then
                    highLight:Destroy()
                end
                if roactHandle then
                    roact.unmount(roactHandle)
                    roactHandle = nil
                end
            end)
        end
    end)
    character.ChildRemoved:Connect(function(obj)
        if obj:IsA("Tool") and CollectionService:HasTag(obj, "Guns") then
            if highLight then
                highLight:Destroy()
            end
            if roactHandle then
                roact.unmount(roactHandle)
                roactHandle = nil
            end
            GunTrove:Clean() -- clear all the connections related to the guns, prevent a memory leak.
            for _,track in pairs(ActiveAnimations) do
                track:Stop()
            end
        end
    end)
end

function GunService:__init()
    super.__init(self)
end

function GunService:Start()
    if LocalPlayer.Character then
        onCharacter(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(onCharacter)
end

return GunService.new()
