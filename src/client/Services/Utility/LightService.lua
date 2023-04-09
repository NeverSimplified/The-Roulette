local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local import = require(ReplicatedStorage.Packages.import)
local Class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Sift = import("Packages/sift")

local Array = Sift.Array
local Every = Array.every

local LightService, super = Class("LightService", Superclass)

local LobbyTeam = CollectionService:GetTagged("LobbyTeam")[1]

function LightService:__init()
    super.__init(self)
end

function LightService:Start()
    local Lights = CollectionService:GetTagged("Lights")
    local LightsEnabled = CollectionService:GetTagged("LightsEnabled")
    local Bash = CollectionService:GetTagged("Bash")
    if not LightsEnabled[1] or not Bash[1] then
        error('Missing critical values for LightService to work.') -- these will get caught in a pcall and warned, dont worry
    end
    if not LightsEnabled[1]:IsA("BoolValue") or not Bash[1]:IsA("Sound") then
        error("Incorrect object type for critical values.")
    end
    LightsEnabled[1]:GetPropertyChangedSignal("Value"):Connect(function()
        Bash[1]:Play()
        local lightColor = Color3.fromRGB(0,0,0)
        local lightOn = false
        local Brightness = 0
        if LightsEnabled[1].Value then
            lightColor = Color3.fromRGB(255,255,255)
            lightOn = true
            Brightness = 1.5
        end
        Every(Lights, function(light)
            for i,object in pairs(light:GetChildren()) do
                if object:IsA("BasePart") then
                    if object.Name:lower():find("lightpart") then
                        object.Color = lightColor
                    elseif object.Name:lower():find("light") then
                        local Spotlight = object:FindFirstChildOfClass("SpotLight")
                        if Spotlight then
                            Spotlight.Enabled = lightOn
                            Spotlight.Brightness = Brightness
                        end
                    end
                end
            end
            return true
        end)
    end)
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        if Players.LocalPlayer.Team == LobbyTeam and not LightsEnabled[1].Value then
            Every(Lights, function(light)
                for i,object in pairs(light:GetChildren()) do
                    if object:IsA("BasePart") then
                        if object.Name:lower():find("lightpart") then
                            object.Color = Color3.fromRGB(116, 111, 95)
                        elseif object.Name:lower():find("light") then
                            local Spotlight = object:FindFirstChildOfClass("SpotLight")
                            if Spotlight then
                                Spotlight.Enabled = true
                                Spotlight.Brightness = 0.3
                            end
                        end
                    end
                end
                return true
            end)
        end
    end)
end

return LightService.new()