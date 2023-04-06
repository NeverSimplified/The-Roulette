local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local Ragdolling = import("Modules/Ragdolling")
return function(context, players)
    Ragdolling:Ragdoll(players.Character)
    return `Ragdolled {players.Name} successfully`
end