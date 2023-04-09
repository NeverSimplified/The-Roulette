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

local RNG = Random.new()

local Cleaner = janitor.new()

local RoundService, super = class("RoundService", Superclass)

local BlindNet = red.Server("BlindNet", {"BlindNet"})
local BashNet = red.Server("BashNet", {"BashNet"})
local CleanNet = red.Server("CleanNet", {"CleanNet"})

local PlayingTeam = CollectionService:GetTagged("PlayingTeam")[1]
local LobbyTeam = CollectionService:GetTagged("LobbyTeam")[1]
local GameText = CollectionService:GetTagged("GameText")[1]
local AfterText = CollectionService:GetTagged("AfterText")[1]
local LightsEnabled = CollectionService:GetTagged("LightsEnabled")[1]
local ForcedGamemode = CollectionService:GetTagged('ForcedGamemode')[1]
local GameRunning = false

local MINIMUM_PLAYERS = 1
local INTERMISSION_TIME = 5

local RoundTimeTrove = trove.new()

function RoundService:LoadInPlayers()
    for _,player in pairs(LobbyTeam:GetPlayers()) do
        if player.Character then
            if player.Character:FindFirstChildOfClass("Humanoid") then
                if player.Character.Humanoid.Health > 0 then
                    player.Character.Humanoid.JumpHeight = 0
                    player.Team = PlayingTeam 
                    local chair = Chairs:RetrieveAChair()
                    local seat = chair:FindFirstChild("Seat", true)
                    player.Character.HumanoidRootPart.CFrame = seat.CFrame
                    RoundTimeTrove:Connect(player.Character.Humanoid.StateChanged, function(old,new)
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
                end
            end
        end
    end
    local InactiveChairs = Chairs:InactiveChairs()
    for _,chair in pairs(InactiveChairs) do
        Chairs:TransparencyChair(chair, 1)
    end
    self:SetAfterText('')
end

function RoundService:EndRound()
    self:SetAfterText('')
    self:SetGameText('Round Ended')
    self:ServerLights(true)
    self:BlindPlayers(false)
    task.wait(1.5)
    for _,player in pairs(PlayingTeam:GetPlayers()) do
        if player.Character then
            player.Team = LobbyTeam 
            player:LoadCharacter()
        end
    end
    task.wait(1.5)
    CleanNet:FireAll("CleanNet")
    task.spawn(function()
        local LimbDebris = workspace:WaitForChild("LimbDebris",1)
        if LimbDebris then
            LimbDebris:ClearAllChildren()
        end
    end)
    Chairs:ResetChairs()
    RoundTimeTrove:Clean()
    Cleaner:Cleanup()
end

function RoundService:SetGameText(text)
    if GameText then
        GameText.Value = text
        task.wait((#text + (#AfterText.Value or 0)) * 0.025) -- yield it to make it fit
    end
end

function RoundService:SetAfterText(text)
    if AfterText then
        AfterText.Value = text
    end
end

function RoundService:PlayClientBash()
    BashNet:FireAll("BashNet")
end

function RoundService:BlindPlayers(bool)
    BlindNet:FireAll("BlindNet",bool or false)
end

function RoundService:ServerLights(bool)
    if LightsEnabled then
        LightsEnabled.Value = bool
    end
end

function RoundService:__init()
    super.__init(self)
end

function RoundService:Start()
    if not PlayingTeam or not LobbyTeam then
        error('Please create the correct teams for the game to have functional rounds. You need a "Playing" team and a "Lobby" team with correct collectionservice tags.')
    end
    promise.new(function()
        while task.wait() do -- not recommended but whatever
            if #LobbyTeam:GetPlayers() < MINIMUM_PLAYERS and GameRunning == false then
                self:SetAfterText(`[ {#LobbyTeam:GetPlayers()} / {MINIMUM_PLAYERS} ]`)
                self:SetGameText('Waiting for players')
                task.wait(1)
                continue
            end
            if not GameRunning then
                GameRunning = true
                self:SetAfterText(`[ {INTERMISSION_TIME} seconds ]`)
                self:SetGameText('Intermission')
                for i = INTERMISSION_TIME,0,-1 do
                    if #LobbyTeam:GetPlayers() >= MINIMUM_PLAYERS and GameRunning then
                        self:SetAfterText(`[ {i} seconds ]`)
                    else
                        break
                    end
                    task.wait(1)
                end
                if #LobbyTeam:GetPlayers() < MINIMUM_PLAYERS or not GameRunning then
                    GameRunning = false
                    continue
                end
                local NextGamemode = ''
                if ForcedGamemode then
                    NextGamemode = ForcedGamemode.Value
                end
                local GamemodeModule = script:FindFirstChild(NextGamemode)
                local Gamemodes = script:GetChildren()
                if not GamemodeModule and #Gamemodes > 0 then
                    local modules = {}
                    for _, module in pairs(script:GetChildren()) do
                        if not module:GetAttribute("Disabled") then
                            table.insert(modules, module)
                        end
                    end
                    GamemodeModule = modules[RNG:NextInteger(1,#modules)]
                end
                local LoadFailed = nil
                local RoundStarted = false
                if GamemodeModule then
                    local RequiredModule = require(GamemodeModule)
                    if RequiredModule.Start and RequiredModule.init then
                        local success,err = pcall(RequiredModule.init)
                        if success then
                            self:SetAfterText("")
                            self:SetGameText("Starting Round")
                            self:ServerLights(false)
                            self:BlindPlayers(true)
                            task.wait(1.5)
                            self:LoadInPlayers()
                            self:SetGameText(`Gamemode: {RequiredModule.GamemodeDisplayText or GamemodeModule.Name}`)
                            task.wait(1.5)
                            local success,err = pcall(RequiredModule.Start) -- yields
                            if not success then
                                self:ServerLights(true)
                                self:BlindPlayers(false)
                                GamemodeModule:SetAttribute("Disabled", true)
                                LoadFailed = `Failed starting: {GamemodeModule.Name}. Please screenshot this into bug reports.`
                                warn(`Failed starting gamemode: {GamemodeModule.Name}, error: {err}`)
                            else
                                RoundStarted = true
                            end
                        else
                            GamemodeModule:SetAttribute("Disabled", true)
                            LoadFailed = `Failed initialising: {GamemodeModule.Name}. Please screenshot this into bug reports.`
                            warn(`Failed initialising gamemode: {GamemodeModule.Name}, error: {err}`)
                        end
                    end
                end
                if LoadFailed then
                    self:SetAfterText(' [ 15 seconds ] ')
                    self:SetGameText(LoadFailed)
                    for i = 15,0,-1 do
                        self:SetAfterText(` [ {i} seconds ] `)
                        task.wait(1)
                    end
                end
                if RoundStarted then
                    self:EndRound()
                end
                self:ServerLights(true)
                GameRunning = false
            end
        end
    end):catch(function(err)
        warn(tostring(err))
        TeleportService.TeleportInitFailed:Connect(function(player)
            player:Kick("We're sorry, this server had a critical failure and your teleport to another server has failed.")
        end)
        for _,player in pairs(Players:GetChildren()) do
            TeleportService:Teleport(game.PlaceId, player)
        end
        Players.PlayerAdded:Connect(function(player)
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end

return RoundService.new()