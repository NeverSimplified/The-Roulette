local radios = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RNG = Random.new()
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local import = require(ReplicatedStorage.Packages.import)
local roact = import("Packages/roact")
local janitor = import("Packages/janitor")
local Cleaner = janitor.new()
local Interfaces = {}
local Song = nil
local Clones = {}
local Audios = {}
local Playlist = CollectionService:GetTagged("RadioMusic")
local LastPlayed
local function RadioFunction(props)
    local Interface = roact.createElement("BillboardGui",{
        ["Name"] = 'RadioInterface';
        ["Adornee"] = props.Radio;
        ["Size"] = UDim2.new(8,0,0.5,0);
        ["AlwaysOnTop"] = true;
        ["MaxDistance"] = 15;
        ['SizeOffset'] = Vector2.new(0,2),
        ["ResetOnSpawn"] = false,
    },{
        Label = roact.createElement("TextLabel", {
            ["Text"] = `<i>Now Playing: <b>{props.Song}</b></i>`;
            ['RichText'] = true,
            ["BackgroundTransparency"] = 1;
            ["TextScaled"] = true,
            ["Font"] = Enum.Font.TitilliumWeb;
            ['AnchorPoint'] = Vector2.new(0.5,0.5),
            ['Position'] = UDim2.new(0.5,0,0.5,0);
            ["Size"] = UDim2.new(1,0,1,0);
            ["TextColor3"] = Color3.fromRGB(255,255,255),
        })
    })
    return Interface
end
function radios:init()
    for i,radio in pairs(CollectionService:GetTagged("Radios")) do
        task.spawn(function()
            local radioElement = roact.createElement(RadioFunction, {
                Radio = radio,
                Song = '',
            })
            local holder = roact.mount(radioElement, PlayerGui, "RadioUI")
            Interfaces[radioElement] = {
                ['holder'] = holder;
                ['radio'] = radio;
            }
        end)
    end
    while true do
        if Song then
            for element,T in pairs(Interfaces) do
                if not T.radio:FindFirstChild(Song.Name) then
                    local Music = Song:Clone()
                    Music.Parent = T.radio
                    local Equalizer = Instance.new("EqualizerSoundEffect")
                    Equalizer.Name = 'RadioEffect'
                    Equalizer.Parent = Music
                    Equalizer.HighGain = 10
                    Equalizer.LowGain = 0
                    Equalizer.MidGain = -80
                    table.insert(Audios, Music)
                    Music:Play()
                end
                T.holder = roact.update(T.holder, roact.createElement(RadioFunction, {
                    Song = Song.Name;
                    Radio = T.radio;
                }))
            end
        else
            if #Clones > 0 then
                for i,sound in pairs(Clones) do
                    Cleaner:Add(sound, "Destroy")
                end
            end
            local LocalPlaylist = {table.unpack(Playlist)}
            for i,sound in ipairs(LocalPlaylist) do
                if sound.TimeLength == 0 then
                    table.remove(LocalPlaylist, i)
                    continue
                end
                if LastPlayed and #LocalPlaylist > 1 then
                    if sound == LastPlayed then
                        table.remove(LocalPlaylist, i)
                        continue
                    end
                end
            end
            for i,playingSound in pairs(Audios) do
                Cleaner:Add(playingSound, "Destroy")
            end
            local RandomSound = LocalPlaylist[RNG:NextInteger(1,#LocalPlaylist)]
            if not RandomSound.IsLoaded then
                task.wait(1) -- try again, smh
                continue
            end
            LastPlayed = RandomSound
            Song = RandomSound
            task.delay(Song.TimeLength+2, function()
                Song = nil
            end)
        end
        task.wait(1)
        Cleaner:Cleanup()
    end
end
return radios