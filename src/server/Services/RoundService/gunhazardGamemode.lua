local Round = {}
Round.GamemodeDisplayText = 'Gun Hazard'

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local import = require(ReplicatedStorage.Packages.import)
local Parent = require(script.Parent)

local RNG = Random.new()

local ShotgunCollars = import("Modules/ShotgunCollars")
local promise = import("Packages/promise")
local trove = import("Packages/trove")
local janitor = import("Packages/janitor")

local GameJanitor = janitor.new()
local GamemodeTrove = trove.new()
local ActivePlayerTrove = trove.new()

local PlayingTeam = CollectionService:GetTagged("PlayingTeam")[1]

function Round:init()

end

function Round.Start(ActivePlayers, ChairsDictionary)
    local GunTracing = ServerStorage:WaitForChild("GunTracing",3)
    if not GunTracing then
        error('No gun tracing bindable event!')
    end
    local ActiveCollars = {}
    local GamePromise
    ActivePlayerTrove:Connect(Players.PlayerRemoving, function(player)
        if table.find(ActivePlayers,player) then
            table.remove(ActivePlayers,table.find(ActivePlayers,player))
        end
    end)
    for _,player in ipairs(ActivePlayers) do
        local Collar = ShotgunCollars.new(player.Character)
        ActiveCollars[player.Character] = Collar
        ActivePlayerTrove:Connect(player.Character.Humanoid:GetPropertyChangedSignal("Health"), function()
            if player.Character.Humanoid.Health <= 0 then
                if ChairsDictionary[player] then
                    local Seat = ChairsDictionary[player]:FindFirstChild("Seat", true)
                    if Seat then
                        Seat:Destroy()
                    end
                end
                table.remove(ActivePlayers, table.find(ActivePlayers, player))
                Collar:DestroySystem()
                ActiveCollars[player.Character] = nil
                if #ActivePlayers <= 1 then
                    if GamePromise then
                        GamePromise:cancel()
                    end
                end
            end
        end)
        if player.Character.Humanoid.Health <= 0 then
            if ChairsDictionary[player] then
                local Seat = ChairsDictionary[player]:FindFirstChild("Seat", true)
                if Seat then
                    Seat:Destroy()
                end
            end
            table.remove(ActivePlayers, table.find(ActivePlayers, player))
            Collar:DestroySystem()
            ActiveCollars[player.Character] = nil
            if #ActivePlayers <= 1 then
                if GamePromise then
                    GamePromise:cancel()
                end
            end
        end
    end
    task.wait(2)
    Parent:BlindPlayers(false)
    Parent:PlayClientBash()
    local GameOver = false
    GamePromise = promise.new(function(resolve,reject,onCancel)
        GameJanitor:Add(task.defer(function()
            local LastChosenPlayer
            while true do
                if #ActivePlayers >= 2 then
                    -- do what it should normally
                    local PossiblePlayers = {table.unpack(ActivePlayers)}
                    if #ActivePlayers >= 4 and LastChosenPlayer then
                        if table.find(PossiblePlayers, LastChosenPlayer) then
                            table.remove(PossiblePlayers, table.find(LastChosenPlayer))
                        end
                    end
                    local RandomPlayer = PossiblePlayers[RNG:NextInteger(1,#PossiblePlayers)]
                    LastChosenPlayer = RandomPlayer
                    local timer = 10
                    Parent:SetAfterText(`[ Time to shoot: {timer} sec. ]`)
                    Parent:SetGameText(`{RandomPlayer.Name} has been chosen to shoot an opponent.`)
                    local Gun = CollectionService:GetTagged("Guns")[1]:Clone()
                    Gun.Parent = RandomPlayer.Backpack
                    local Shot = false
                    local KillPromise
                    GamemodeTrove:Connect(GunTracing.Event, function(player, target)
                        if player == RandomPlayer then
                            Shot = true
                            Parent:SetAfterText('')
                            Parent:SetGameText(`{RandomPlayer.Name} has shot: {target.Name}.`)
                        end
                    end)
                    promise.try(function() 
                        for i = timer,0,-1 do
                            if Shot or GameOver or not table.find(ActivePlayers,RandomPlayer) then
                                break
                            end
                            Parent:SetAfterText(`[ Time to shoot: {i} sec. ]`)
                            task.wait(1)
                        end
                    end):finally(function()
                        if not table.find(ActivePlayers, RandomPlayer) then
                            Parent:SetAfterText('')
                            Parent:SetGameText(`{RandomPlayer.Name} has quit the round.`)
                            task.wait(3)
                            resolve()
                        end
                        if not Shot and not GameOver and table.find(ActivePlayers, RandomPlayer) then
                            local Collar = ActiveCollars[RandomPlayer.Character]
                            if Collar then
                                if Gun then
                                    Gun:Destroy()
                                end
                                Parent:SetAfterText('')
                                Parent:SetGameText(`{RandomPlayer.Name} has failed to kill anyone.`)
                                Collar:ExplodeCollar()
                            end
                        end
                    end):catch(function(err)
                        warn('Failed inside round promise!', err)
                    end):awaitStatus()
                else
                    break
                end
                GamemodeTrove:Clean()
                task.wait(3)
            end
        end))
        if #ActivePlayers <= 1 then
            resolve()
        end
    end):catch(function(err)
        warn('Failed during game:', err)
    end):finally(function()
        GameJanitor:Cleanup() -- cleans the thread up
        GameOver = true
        Parent:SetAfterText('')
        if #ActivePlayers == 1 then
            Parent:SetGameText(`{ActivePlayers[1]} has won the round.`)
        elseif #ActivePlayers < 1 then
            Parent:SetGameText(`Nobody has won the round.`)
        else
            Parent:SetGameText(`Round unexpectedly ended.`)
        end
        task.wait(3)
        Parent:EndRound(ActivePlayers)
    end)
end

return Round