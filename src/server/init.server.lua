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
local Promise = import("Packages/promise")
for i,module in pairs(script.Modules:GetChildren()) do
    if module:IsA("ModuleScript") then
        local promised = Promise.new(function(resolve, reject, onCancel)
            require(module):init()
        end):catch(function(error)
            warn(`[SERVER INITIALISATION]: Something failed!: {error}`)
        end)
    end
end
print('[SERVER-FRAMEWORK]: Initialising.')