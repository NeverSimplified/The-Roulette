local Players = game:GetService("Players")
local Collar = script:FindFirstChild("Collar")
local collarModule = {}
collarModule.__index = collarModule

local function BlowUp(class)
    local character = class.Holder
    local Humanoid = character.Humanoid
    Humanoid:TakeDamage(Humanoid.Health)
    if class.Model then
        local shot = class.Model
    end
end

function collarModule:Explode(timer : number | nil)
    if not timer then
        BlowUp(self)
    end

    if self.Model then
        
    end
end

function collarModule:RigCharacter(character)
    local newCollar = {}
    setmetatable(newCollar, collarModule)
    newCollar.Holder = character
    if Collar then
        local ClonedCollar = Collar:Clone()
        ClonedCollar.Parent = character
        ClonedCollar:MoveTo(character.Head)
        local weld = Instance.new("Weld")
        weld.Name = 'HeadWeld'
        weld.Part0 = ClonedCollar.PrimaryPart
        weld.Part1 = character.Head
        weld.C0 = ClonedCollar.PrimaryPart.CFrame:Inverse()
        weld.C1 = character.Head.CFrame:Inverse()
        weld.Parent = ClonedCollar.PrimaryPart
        ClonedCollar.PrimaryPart.Anchored = false
        local EquipSound = ClonedCollar.PrimaryPart:FindFirstChild("equip")
        if EquipSound then
            EquipSound:Play()
        end
        local LockSound = ClonedCollar.PrimaryPart:FindFirstChild("lock")
        if LockSound then
            LockSound:Play()
        end
        newCollar.Model = ClonedCollar
    end
    return newCollar
end

return collarModule