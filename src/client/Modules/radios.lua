local radios = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RNG = Random.new()
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local import = require(ReplicatedStorage.Packages.import)
local roact = import("Packages/roact")
local foreach = table.foreach
local Interfaces = {}
local Song 
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
        ['SizeOffset'] = Vector2.new(0,2)
    },{
        Label = roact.createElement("TextLabel", {
            ["Text"] = `Now Playing: {props.Song}`;
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
function radios:Init()
    foreach(CollectionService:GetTagged("Radios"),function(_,radio)
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
                    sound:Destroy()
                end
            end
            local LocalPlaylist = {table.unpack(Playlist)}
            for i,sound in ipairs(LocalPlaylist) do
                if sound.TimeLength == 0 then
                    warn('[RADIO]: Sound was removed for having no time length!')
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
                playingSound:Destroy()
            end
            local RandomSound = LocalPlaylist[RNG:NextInteger(1,#LocalPlaylist)]
            LastPlayed = RandomSound
            Song = RandomSound
            task.delay(Song.TimeLength+2, function()
                Song = nil
            end)
        end
        task.wait(1)
    end
end
return radios