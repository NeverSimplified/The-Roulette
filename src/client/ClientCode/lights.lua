local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lights = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local GameValues = ReplicatedStorage.GameValues
local CurrentToggle = false
local function Toggle()
    for _,light in pairs(CollectionService:GetTagged("Lights")) do
        for _,object in pairs(light:GetChildren()) do
            if object.Name:lower():find("lightpart") then
                if not CurrentToggle then
                    object.Color = Color3.fromRGB(0,0,0)
                else
                    object.Color = Color3.fromRGB(255,255,255)
                end
            elseif object.Name:lower() == 'light' then
                local spotlight = object:FindFirstChildOfClass("SpotLight")
                if spotlight then
                    if not CurrentToggle then
                        spotlight.Enabled = false
                    else
                        spotlight.Enabled = true
                    end
                end
            end
        end
    end
end
function lights:init()
    local LightsEnabled = GameValues.LightsEnabled
    local Bash = SoundService.Bash
    LightsEnabled:GetPropertyChangedSignal("Value"):Connect(function()
        Bash:Play()
        CurrentToggle = LightsEnabled.Value
        Toggle()
    end)
    CurrentToggle = LightsEnabled.Value
    Toggle()
end
return lights