-- this section explains itself
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local import = require(ReplicatedStorage.Packages.import)
local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")
local red = import("Packages/red")
local promise = import("Packages/promise")
local Chairs = import("Modules/Chairs")
local trove = import("Packages/trove")
local janitor = import("Packages/janitor")
local ShotgunCollars = import("Modules/ShotgunCollars")
local ragdolling = import("Modules/Ragdolling")

local RNG = Random.new()

local Cleaner = janitor.new()

local RoundService, super = class("RoundService", Superclass) -- this is pretty much just a metatable method. It allows me to make each "service" inherit functions defined in the superclass script

local BlindNet = red.Server("BlindNet", {"BlindNet"}) -- sorta like RemoteEvents but uses the Red module
local BashNet = red.Server("BashNet", {"BashNet"})
local CleanNet = red.Server("CleanNet", {"CleanNet"})

-- ASSETS BELOW
local PlayingTeam = CollectionService:GetTagged("PlayingTeam")[1]
local LobbyTeam = CollectionService:GetTagged("LobbyTeam")[1]
local GameText = CollectionService:GetTagged("GameText")[1]
local AfterText = CollectionService:GetTagged("AfterText")[1]
local LightsEnabled = CollectionService:GetTagged("LightsEnabled")[1]
local ForcedGamemode = CollectionService:GetTagged('ForcedGamemode')[1]
-- LOGIC VARIABLES BELOW
local GameRunning = false

local MINIMUM_PLAYERS = 1
local INTERMISSION_TIME = 5

-- trove just because lol, i don't know why I used janitor and trove at the same time. TODO: why?? fix it
local RoundTimeTrove = trove.new()

function RoundService:LoadInPlayers() -- server function to load in players into the selected gamemode
    local ValidPlayers = {}
    local ChairsDictionary = {}
    for _,player in pairs(LobbyTeam:GetPlayers()) do
        if player.Character then
            if player.Character:FindFirstChildOfClass("Humanoid") then
                if player.Character.Humanoid.Health > 0 then
                    ragdolling:UnRagdoll(player.Character) -- Unragdoll players using my own ragdolling module in the offchance they're ragdolled when the round is loading in
                    player.Character.Humanoid.JumpHeight = 0
                    player.Character.HumanoidRootPart.Anchored = true
                    player.Team = PlayingTeam  -- make the player setup properly for the game, make them unable to jump, anchor them, team them to the playing team
                    local chair = Chairs:RetrieveAChair() -- custom made module to properly retrieve a chair for the player around the table
                    local seat = chair:FindFirstChild("Seat", true)
                    chair:SetAttribute("Occupant", player.Name) -- assign the chair to the player
                    player.Character.HumanoidRootPart.CFrame = seat.CFrame -- set their hrp to the chair whilst anchored and then proceed to unanchor so they get instant teleported
                    player.Character.HumanoidRootPart.Anchored = false
                    RoundTimeTrove:Connect(player.Character.Humanoid.StateChanged, function(old,new) -- anticheat measure, prevents exploiters from changing their state from being seated in the round
                        if player.Team == LobbyTeam then
                            return
                        end
                        if new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Dead then
                            return
                        end
                        if new ~= Enum.HumanoidStateType.Seated and old == Enum.HumanoidStateType.Seated then
                            player.Character.Humanoid.Health = 0
                        end
                    end)
                    table.insert(ValidPlayers, player)
                    ChairsDictionary[player] = chair
                end
            end
        end
    end
    local InactiveChairs = Chairs:InactiveChairs() -- chairs which don't have anyone assigned are made invisible and non collidable
    for _,chair in pairs(InactiveChairs) do
        Chairs:TransparencyChair(chair)
    end
    self:SetAfterText('') -- after text as in the text after the main title, example: "Cool main text [ 5 seconds left! ]". the "[ 5 seconds left! ]" is the aftertext
    return ValidPlayers, ChairsDictionary
end

function RoundService:EndRound(ActivePlayers) -- server function to end the ongoing round properly
    self:SetAfterText('') -- remove aftertext
    self:SetGameText('Round Ended') -- display to players that the round is over
    self:ServerLights(true) -- turn on the lobby lighting
    self:BlindPlayers(false) -- unblind the playing team players
    task.wait(1.5)
    for _,player in pairs(ActivePlayers) do -- team them to the lobby team
        if player.Character then
            player.Team = LobbyTeam 
            player:LoadCharacter()
        end
    end
    task.wait(1.5)
    ShotgunCollars:WipeAllCollars() -- if there are shotgun collars from the Gunhazard gamemode then delete them and disconnect their connections (done through its own module)
    CleanNet:FireAll("CleanNet")
    task.spawn(function()
        local LimbDebris = workspace:WaitForChild("LimbDebris",1) -- delete any torn off limbs from the round
        if LimbDebris then
            LimbDebris:ClearAllChildren()
        end
    end)
    Chairs:ResetChairs() -- make all the chairs unassigned, visible and collidable
    RoundTimeTrove:Clean() -- disconnect all connections
    Cleaner:Cleanup() -- same as above
    self:ServerLights(true) -- oversight, not going to edit this now. TODO: REMOVE THIS
    GameRunning = false -- set the script running variable to false. Logic variable.
end

function RoundService:SetGameText(text) -- the client has the game text animated in a typewriter effect. this sets the value to display
    if GameText then
        GameText.Value = text
        task.wait((#text + (#AfterText.Value or 0)) * 0.025) -- yield it to make it fit
        -- the wait above is to stop potential overlapping of text if there are too many events happening at once
    end
end

function RoundService:SetAfterText(text) -- the client shows this after the main text in a single string, its set and not animated hence why there is no damage control using a wait
    if AfterText then
        AfterText.Value = text
    end
end

function RoundService:PlayClientBash() -- loud "kdung" type sound which gets played upon the start of a round or the end
    BashNet:FireAll("BashNet")
end

function RoundService:BlindPlayers(bool) -- speaks for itself, fires an event to the client using the Red open source library which then blinds the player
    BlindNet:FireAll("BlindNet",bool or false)
end

function RoundService:ServerLights(bool) -- sets the lights in the lobby on / off using the client
    if LightsEnabled then
        LightsEnabled.Value = bool
    end
end

function RoundService:__init()
    super.__init(self) -- if there is an inherited __init event then run it.
end

function RoundService:Start()
    if not PlayingTeam or not LobbyTeam then -- safety, blocks the game from starting if the game instance is missing some assets
        error('Please create the correct teams for the game to have functional rounds. You need a "Playing" team and a "Lobby" team with correct collectionservice tags.')
    end
    local LastUsedGamemode
    promise.new(function() -- uses promise to make sure things don't break.
        while task.wait() do -- not recommended but whatever
            if #LobbyTeam:GetPlayers() < MINIMUM_PLAYERS and GameRunning == false then -- if there are less players than the pre-declared minimum then run a waiting for players loop sequence
                self:SetAfterText(`[ {#LobbyTeam:GetPlayers()} / {MINIMUM_PLAYERS} ]`)
                self:SetGameText('Waiting for players')
                task.wait(1)
                continue
            end
            if not GameRunning then
                GameRunning = true
                self:SetAfterText(`[ {INTERMISSION_TIME} seconds ]`) -- intermission, give the players a break before starting another round
                self:SetGameText('Intermission')
                for i = INTERMISSION_TIME,0,-1 do
                    if #LobbyTeam:GetPlayers() >= MINIMUM_PLAYERS and GameRunning then
                        self:SetAfterText(`[ {i} seconds ]`) -- countdown the intermission on the client's top gametext aftertext
                    else
                        break
                    end
                    task.wait(1)
                end
                if #LobbyTeam:GetPlayers() < MINIMUM_PLAYERS or not GameRunning then -- safety again, incase the requirement was met but someone left
                    GameRunning = false
                    continue
                end
                local NextGamemode = ''
                if ForcedGamemode then
                    NextGamemode = ForcedGamemode.Value -- forced gamemode either using CMDR command or a vote
                end
                local GamemodeModule = script:FindFirstChild(NextGamemode)
                local Gamemodes = script:GetChildren()
                if not GamemodeModule and #Gamemodes > 0 then -- if there isn't a forced gamemode, pick a random one
                    local modules = {}
                    for _, module in pairs(script:GetChildren()) do
                        if not module:GetAttribute("Disabled") then -- skip disabled gamemodes (MAINTENANCE DEV STUFF)
                            table.insert(modules, module)
                        end
                    end
                    if #Gamemodes > 1 and LastUsedGamemode then -- make sure to not run the same gamemode twice if there is more than one gamemode
                        if table.find(modules,LastUsedGamemode) then
                            table.remove(modules,table.find(modules,LastUsedGamemode))
                        end
                    end
                    GamemodeModule = modules[RNG:NextInteger(1,#modules)] -- using Random.new(), pick a random entry from the array / list
                end
                local LoadFailed = nil
                if GamemodeModule then
                    LastUsedGamemode = GamemodeModule
                    local RequiredModule = require(GamemodeModule) -- load the gamemode module for this gamemode
                    if RequiredModule.Start and RequiredModule.init then
                        local success,err = pcall(RequiredModule.init) -- run the gamemode's init function, if it fails send everyone to the lobby and disable this gamemode. then run error message for players to bug report
                        if success then
                            self:SetAfterText("")
                            self:SetGameText("Starting Round")
                            self:ServerLights(false)
                            self:BlindPlayers(true) -- prepare the game for launch
                            task.wait(1.5)
                            self:SetGameText(`Gamemode: {RequiredModule.GamemodeDisplayText or GamemodeModule.Name}`) -- display what gamemode is going to be played while the players are getting setup
                            local RoundTime = false
                            local startTime = os.clock()
                            task.spawn(function()
                                repeat task.wait() until RoundTime or os.clock() - startTime > 400
                                if not RoundTime then -- critical error handle, if the game freezes for more than 400 seconds, teleport all players to a new server and end the current one. this is an error beyond repair
                                    TeleportService.TeleportInitFailed:Connect(function(player)
                                        player:Kick("We're sorry, this server had a critical failure and your teleport to another server has failed.")
                                    end)
                                    for _,player in pairs(Players:GetChildren()) do
                                        TeleportService:Teleport(game.PlaceId, player)
                                    end
                                    Players.PlayerAdded:Connect(function(player)
                                        TeleportService:Teleport(game.PlaceId, player)
                                    end)
                                end
                            end)
                            local ActivePlayers, ChairsDictionary = self:LoadInPlayers() -- returns a list of players and the dictionary of chairs with players assigned
                            local success,err = pcall(RequiredModule.Start, ActivePlayers, ChairsDictionary) -- yields
                                -- the above loads the gamemode module start function from the folder this script initialises as
                            if not success then -- if it fails to start, skip the gamemode and return to the intermission
                                self:ServerLights(true)
                                self:BlindPlayers(false)
                                GamemodeModule:SetAttribute("Disabled", true)
                                LoadFailed = `Failed starting: {GamemodeModule.Name}. Please screenshot this into bug reports.` -- so the devs are made aware that this specific gamemode failed to load
                                warn(`Failed starting gamemode: {GamemodeModule.Name}, error: {err}`) -- dev error warning
                            else
                                RoundTime = true
                            end
                        else
                            GamemodeModule:SetAttribute("Disabled", true)
                            LoadFailed = `Failed initialising: {GamemodeModule.Name}. Please screenshot this into bug reports.`
                            warn(`Failed initialising gamemode: {GamemodeModule.Name}, error: {err}`)
                        end
                    end
                end
                if LoadFailed then
                    self:SetAfterText(' [ 15 seconds ] ') -- gives players 15 seconds with the top saying the game failed to load, afterward it goes back to the intermission
                    self:SetGameText(LoadFailed)
                    for i = 15,0,-1 do
                        self:SetAfterText(` [ {i} seconds ] `)
                        task.wait(1)
                    end
                    self:ServerLights(true)
                    GameRunning = false
                end
            end
        end
    end):catch(function(err) -- incase this promise errors anywhere, its considered a critical failure and the server should be restarted
        warn(tostring(err))
        TeleportService.TeleportInitFailed:Connect(function(player)
            player:Kick("We're sorry, this server had a critical failure and your teleport to another server has failed.") -- on teleport failed, kick the player
        end)
        for _,player in pairs(Players:GetChildren()) do
            TeleportService:Teleport(game.PlaceId, player) -- teleport all the players away
        end
        Players.PlayerAdded:Connect(function(player) -- re-teleport any new players
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end

return RoundService.new()
