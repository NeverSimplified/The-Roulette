local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(context, players)
    local index = 0
    for _,player in pairs(players) do
        if player.Character then
            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                index += 1
                Humanoid:TakeDamage(Humanoid.Health)
            end
        end
    end
    return `Killed {index} player(s) successfully`
end