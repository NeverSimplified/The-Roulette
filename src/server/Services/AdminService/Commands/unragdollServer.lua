local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local Ragdolling = import("Modules/Ragdolling")
return function(context, players)
    local index = 0
    for _,player in pairs(players) do
        if player.Character then
            if player.Character:FindFirstChild("HumanoidRootPart") then
                index += 1
                Ragdolling:UnRagdoll(player.Character)
            end
        end
    end
    return `UnRagdolled {index} player(s) successfully`
end