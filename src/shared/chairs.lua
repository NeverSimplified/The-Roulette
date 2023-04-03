local CollectionService = game:GetService("CollectionService")
local RNG = Random.new()
local ch = {}
local usedChairs = {}
function ch:RetrieveAChair()
    local LocalChairs = CollectionService:GetTagged("Chairs")
    if #LocalChairs <= #usedChairs then
        return nil
    end
    for i,chair in pairs(usedChairs) do
        if table.find(LocalChairs, chair) then
            table.remove(LocalChairs, table.find(LocalChairs, chair))
            print('Removed a chair')
        end
    end
    local RandomChair = LocalChairs[RNG:NextInteger(1, #LocalChairs)]
    usedChairs[#usedChairs+1] = RandomChair
    return RandomChair
end
function ch:ResetChairs()
    usedChairs = {}
    print(`Chairs cleaned. {#usedChairs}`)
end
return ch