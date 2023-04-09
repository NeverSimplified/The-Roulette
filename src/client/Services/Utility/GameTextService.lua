local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local roact = import("Packages/roact")

local GameTextService, super = class("GameTextService", Superclass)

local GameText = CollectionService:GetTagged('GameText')[1]
local TextColor = CollectionService:GetTagged("TextColor")[1]
local AfterText = CollectionService:GetTagged("AfterText")[1]

local GameTextUI = roact.Component:extend("GameTextUI")
function GameTextUI:render()
    return roact.createElement("ScreenGui",{
        IgnoreGuiInset = true;
        DisplayOrder = 100;
        ResetOnSpawn = false;
    },{
        Label = roact.createElement("TextLabel", {
            Name = 'GameTextLabel';
            RichText = true;
            Size = UDim2.new(1,0,0,30);
            Text = `<i>{self.props.Text or ''}</i>`;
            TextColor3 = self.props.TextColor or Color3.fromRGB(255,255,255);
            BackgroundTransparency = 1;
            Font = Enum.Font.TitilliumWeb;
            Position = UDim2.fromScale(0.5,0.05);
            AnchorPoint = Vector2.new(0.5,0.5);
            TextScaled = true;
        })
    })
end

function GameTextService:__init()
    super.__init(self)
end

function GameTextService:Start()
    if GameText and AfterText then
        local UI = roact.createElement(GameTextUI, {
            Text = `{GameText.Value} {AfterText.Value}`;
            TextColor = TextColor.Value;
        })
        local Handle = roact.mount(UI, Players.LocalPlayer.PlayerGui, 'GameTextGUI')
        local GeneralText = GameText.Value
        GameText:GetPropertyChangedSignal("Value"):Connect(function()
            GeneralText = GameText.Value
            local LocalText = GameText.Value
            local typewrite = `{LocalText} {AfterText.Value}`
            for i = 0,#typewrite do
                if GeneralText == LocalText then
                    Handle = roact.update(Handle, roact.createElement(GameTextUI, {
                        Text = `{string.sub(typewrite,1,i)}`;
                    }))
                    task.wait(0.025)
                else
                    break
                end
            end
            Handle = roact.update(Handle, roact.createElement(GameTextUI, {
                Text = `{LocalText} {AfterText.Value}`
            }))
        end)
        AfterText:GetPropertyChangedSignal("Value"):Connect(function()
            Handle = roact.update(Handle, roact.createElement(GameTextUI, {
                Text = `{GeneralText} {AfterText.Value}`
            }))
        end)
    end
end

return GameTextService.new()