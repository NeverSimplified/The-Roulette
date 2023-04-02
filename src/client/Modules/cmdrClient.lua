local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = {}
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
function module:Init()
    Cmdr:SetActivationKeys({Enum.KeyCode.Semicolon, Enum.KeyCode.F2})
    Cmdr:SetPlaceName("-RouletteMain-")
end
return module