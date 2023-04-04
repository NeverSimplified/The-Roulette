local CollectionService = game:GetService("CollectionService")
local RNG = Random.new()
local ActiveChairs = {}
local chairsModule = {}

function chairsModule:RetrieveAChair()
    local CollectedChairs = CollectionService:GetTagged("Chairs")
    local InactiveChairs = {}
    for i,chair in ipairs(CollectedChairs) do
        if not ActiveChairs[chair] then
            table.insert(InactiveChairs, chair)
        end
    end
    local Chair = InactiveChairs[RNG:NextInteger(1,#InactiveChairs)]
    ActiveChairs[Chair] = true
    return Chair
end

function chairsModule:ReturnAChair(chair)
    if ActiveChairs[chair] then
        ActiveChairs[chair] = nil
    end
end

function chairsModule:ResetChairs()
    ActiveChairs = {}
end

return chairsModule