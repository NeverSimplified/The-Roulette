local CollectionService = game:GetService("CollectionService")
local RNG = Random.new()
local ActiveChairs = {}
local chairsModule = {}

function chairsModule:RetrieveAChair()
    local CollectedChairs = CollectionService:GetTagged("Chairs")
    local InactiveChairs = {}
    for _,chair in ipairs(CollectedChairs) do
        if not ActiveChairs[chair] then
            table.insert(InactiveChairs, chair)
        end
    end
    local Chair = InactiveChairs[RNG:NextInteger(1,#InactiveChairs)]
    ActiveChairs[Chair] = true
    return Chair
end

function chairsModule:TransparencyChair(chair, transparency)
    for _,object in pairs(chair:GetDescendants()) do
        if object:IsA("BasePart") and not object:IsA("Seat") then
            object.Transparency = transparency
            if object:FindFirstChildOfClass("Seat") then
                if transparency ~= 1 then
                    object:FindFirstChildOfClass("Seat").Disabled = false
                else
                    object:FindFirstChildOfClass("Seat").Disabled = true
                end
            end
        end
    end
end

function chairsModule:ReturnAChair(chair)
    if ActiveChairs[chair] then
        self:TransparencyChair(chair, 0)
        ActiveChairs[chair] = nil
    end
end

function chairsModule:ResetChairs()
    local CollectedChairs = CollectionService:GetTagged("Chairs")
    for _,chair in ipairs(CollectedChairs) do
        self:TransparencyChair(chair, 0)
    end
    ActiveChairs = {}
end

function chairsModule:InactiveChairs()
    local CollectedChairs = CollectionService:GetTagged("Chairs")
    local InactiveChairs = {}
    for _,chair in ipairs(CollectedChairs) do
        if not ActiveChairs[chair] then
            table.insert(InactiveChairs, chair)
        end
    end
    return InactiveChairs
end

return chairsModule