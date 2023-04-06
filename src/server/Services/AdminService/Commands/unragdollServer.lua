local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local Ragdolling = import("Modules/Ragdolling")
return function(context, players)
    Ragdolling:UnRagdoll(players.Character)
    return `UnRagdolled {players.Name} successfully`
end