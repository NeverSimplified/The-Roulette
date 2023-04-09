local Round = {}
Round.GamemodeDisplayText = 'test'

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local Parent = require(script.Parent)

local RNG = Random.new()

local ShotgunCollars = import("Modules/ShotgunCollars")

local PlayingTeam = CollectionService:GetTagged("PlayingTeam")[1]

function Round:init()
    print('test gamemode initialised')
end

function Round:Start()
    local PlayingTeam = PlayingTeam:GetPlayers()
    local Player = PlayingTeam[RNG:NextInteger(1,#PlayingTeam)]
    local collar = ShotgunCollars.new(Player.Character)
    Parent:SetGameText(`{Player.Name} was selected for death.`)
    task.wait(2)
    Parent:BlindPlayers(false)
    Parent:PlayClientBash()
    collar:ExplodeCollar(5)
    task.wait(10)
end

return Round