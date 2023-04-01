local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = {}
local import = require(ReplicatedStorage.Packages.import)
local cmdr = import("Packages/cmdr")
function module:init()
    cmdr:RegisterDefaultCommands()
end
return module