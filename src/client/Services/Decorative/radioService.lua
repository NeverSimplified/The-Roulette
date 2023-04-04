local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local Sift = import("Packages/sift")
local Janitor = import("Packages/janitor")
local Roact = import("Packages/roact")

local Array = Sift.Array
local Foreach = Array.every

local radioService, SClass = class("RadioService", Superclass)

local Cleaner = Janitor.new()
local RandomNumber = Random.new()
local ActiveRadios = {}
local LastSongInRadio = {}
local RoactElements = {}
local ActiveReferences = {}

local TweenOUT = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TweenIN = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local FadeTween = TweenInfo.new(1, Enum.EasingStyle.Sine)

local RadioUI = Roact.Component:extend("RadioBillboard")
function RadioUI:init()
    self.LabelRef = Roact.createRef()
    self.HolderRef = Roact.createRef()
end
function RadioUI:render()
    return Roact.createElement("BillboardGui", {
        [Roact.Ref] = self.HolderRef;
        Name = 'RadioInterface';
        Size = UDim2.fromScale(8,0.5);
        AlwaysOnTop = true;
        SizeOffset = Vector2.new(0,2);
        MaxDistance = math.huge;
        ResetOnSpawn = false;
    },{
        Label = Roact.createElement("TextLabel", {
            [Roact.Ref] = self.LabelRef;
            Text = `<i>Now playing: <b>{tostring(self.props.Song)}</b></i>`;
            Font = Enum.Font.TitilliumWeb;
            RichText = true;
            Size = UDim2.fromScale(1,1);
            Position = UDim2.fromScale(0.5,0.5);
            AnchorPoint = Vector2.new(0.5,0.5);
            Name = 'SongName';
            TextScaled = true;
            BackgroundTransparency = 1;
            TextColor3 = Color3.fromRGB(255,255,255);
        })
    }
    )
end
function RadioUI:didMount()
    table.insert(ActiveReferences, self)
end

function radioService:__init()
    SClass:__init(self.ClassName)
end

function radioService:Start()
    local Music = CollectionService:GetTagged("RadioMusic")
    Foreach(CollectionService:GetTagged("Radios"), function(radioObject)
        local UI = Roact.createElement(RadioUI, {
            Song = '',
        })
        RoactElements[radioObject] = Roact.mount(UI, radioObject, "RadioBillboard")
        return true
    end)
    task.spawn(function()
        while true do
            Foreach(CollectionService:GetTagged("Radios"), function(radioObject)
                if not ActiveRadios[radioObject] then
                    ActiveRadios[radioObject] = true
                    local LocalMusic = {table.unpack(Music)}
                    if LastSongInRadio[radioObject] then
                        if table.find(LocalMusic, LastSongInRadio[radioObject]) then
                            table.remove(table.find(LocalMusic, LastSongInRadio[radioObject]))
                        end
                        Cleaner:Add(LastSongInRadio[radioObject])
                    end
                    for i,song in ipairs(LocalMusic) do
                        if not song.IsLoaded or song.TimeLength <= 0 then
                            table.remove(LocalMusic, i)
                        end
                    end
                    if #LocalMusic < 2 then
                        ActiveRadios[radioObject] = nil
                        return true
                    end
                    local RandomSong = LocalMusic[RandomNumber:NextInteger(1, #LocalMusic)]
                    if RandomSong.TimeLength <= 0 then
                        ActiveRadios[radioObject] = nil
                        return true
                    end
                    if RoactElements[radioObject] then
                        RoactElements[radioObject] = Roact.update(RoactElements[radioObject],Roact.createElement(RadioUI, {
                            Song = RandomSong.Name;
                        }))
                    end
                    local Equalizer = Instance.new("EqualizerSoundEffect")
                    Equalizer.HighGain = 10
                    Equalizer.MidGain = -80
                    Equalizer.LowGain = 2
                    local ClonedSound = RandomSong:Clone()
                    ClonedSound.Parent = radioObject
                    LastSongInRadio[radioObject] = ClonedSound
                    Equalizer.Parent = ClonedSound
                    ClonedSound:Play()
                    task.delay(RandomSong.TimeLength, function()
                        ActiveRadios[radioObject] = nil
                    end)
                end
                return true
            end)
            for i,reference in ipairs(ActiveReferences) do
                local Label = reference.LabelRef:getValue()
                local Holder = reference.HolderRef:getValue()
                local Object = Holder.Parent
                local Camera = workspace.CurrentCamera
                local Distance = (Camera.CFrame.Position - Object.Position).Magnitude
                if Distance <= 25 then
                    if not Label.Visible then
                        table.remove(ActiveReferences, i)
                        Label.Visible = true
                        Label.TextTransparency = 1
                        Holder.SizeOffset = Vector2.new(0,0)
                        local Tween = TweenService:Create(Holder, TweenOUT, {SizeOffset = Vector2.new(0,2)})
                        TweenService:Create(Label, FadeTween, {TextTransparency = 0}):Play()
                        Tween:Play()
                        Tween.Completed:Connect(function()
                            table.insert(ActiveReferences, reference)
                        end)
                    end
                else
                    if Label.Visible then
                        table.remove(ActiveReferences, i)
                        Label.TextTransparency = 0
                        Holder.SizeOffset = Vector2.new(0,2)
                        local Tween = TweenService:Create(Holder, TweenIN, {SizeOffset = Vector2.new(0,0)})
                        TweenService:Create(Label, FadeTween, {TextTransparency = 1}):Play()
                        Tween:Play()
                        Tween.Completed:Connect(function()
                            table.insert(ActiveReferences, reference)
                            Label.Visible = false
                        end)
                    end
                end
            end
            task.wait(1)
            Cleaner:Cleanup()
        end
    end)
end

return radioService