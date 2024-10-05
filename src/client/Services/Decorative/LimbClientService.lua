-- Client part of the server limb system. Provided just as context.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)

local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")

local LimbService, super = class("LimbService", Superclass)

function OnDismembered(limb, character)
    limb.Transparency = 1
    if limb.Name == 'Head' then
        if limb:FindFirstChildOfClass("Decal") then
            limb:FindFirstChildOfClass("Decal"):Destroy()
        end
    end
    local GoreModel = character:FindFirstChild("Gore-Character")
    if GoreModel then
        if GoreModel:FindFirstChild(limb.Name) then
            GoreModel[limb.Name].Transparency = 0
        end
    end
end

function OnCharacterInFolder(character)
    task.wait()
    for _,basePart in pairs(character:GetChildren()) do
        if basePart:GetAttribute("Health") then
            if basePart:GetAttribute("Health") <= 0 then
                OnDismembered(basePart, character)
            else
                local con
                con = basePart:GetAttributeChangedSignal("Health"):Connect(function()
                    if basePart:GetAttribute("Health") <= 0 then
                        con:Disconnect()
                        OnDismembered(basePart, character)
                    end
                end)
            end
        end
    end
end

function LimbService:__init()
    super.__init(self)
end

function LimbService:Start()
    local CharacterFolder = workspace:WaitForChild("Characters", 5)
    if not CharacterFolder then
        error("There is no character folder?!")
    end
    for _, character in pairs(CharacterFolder:GetChildren()) do
        OnCharacterInFolder(character)
    end
    CharacterFolder.ChildAdded:Connect(OnCharacterInFolder)
    for _,body in pairs(workspace.DeadBodies:GetChildren()) do
        OnCharacterInFolder(body)
    end
    workspace.DeadBodies.ChildAdded:Connect(OnCharacterInFolder)
end

return LimbService.new()
