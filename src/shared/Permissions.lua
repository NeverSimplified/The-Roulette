local Perms = {}
-- good for now
function Perms:RetrievePermissionLevel(player)
    return player:GetRankInGroup(10614584)
end

return Perms