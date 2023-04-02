local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local import = require(ReplicatedStorage.Packages.import)
import.setAliases({
    server = ServerScriptService,
    client = StarterPlayer.StarterPlayerScripts,
    shared = ReplicatedStorage,
    Packages = ReplicatedStorage.Packages,
})

for i,module in pairs(script.Modules:GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module):init()
    end
end