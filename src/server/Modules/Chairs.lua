local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local RNG = Random.new()
local ActiveChairs = {}
local chairsModule = {}

local OriginalChairs = {}
if not ServerStorage:FindFirstChild("OriginalChairs") then
    local Folder = Instance.new("Folder")
    Folder.Name = 'OriginalChairs'
    Folder.Parent = ServerStorage
    for _,chair in pairs(CollectionService:GetTagged("Chairs")) do
        local Cloned = chair:Clone()
        Cloned.Parent = Folder
        local ObjectValue = Instance.new("ObjectValue")
        ObjectValue.Value = chair.Parent
        ObjectValue.Name = 'RealParent'
        ObjectValue.Parent = Cloned
        CollectionService:RemoveTag(Cloned, "Chairs")
        table.insert(OriginalChairs, Cloned)
    end
else
    OriginalChairs = ServerStorage:FindFirstChild("OriginalChairs"):GetChildren()
end
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

function chairsModule:TransparencyChair(chair)
    chair:Destroy()
end

function chairsModule:ResetChairs()
    local CollectedChairs = CollectionService:GetTagged("Chairs")
    for _,chair in pairs(CollectedChairs) do
        chair:Destroy()
    end
    for _,chair in pairs(OriginalChairs) do
        local newChair = chair:Clone()
        newChair.Parent = chair.RealParent.Value
        CollectionService:AddTag(newChair, "Chairs")
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