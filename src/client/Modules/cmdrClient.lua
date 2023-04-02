local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = {}
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
function module:Init()
    Cmdr:SetActivationKeys({Enum.KeyCode.F2})
end
return module