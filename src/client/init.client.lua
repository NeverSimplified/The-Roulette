local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local import = require(ReplicatedStorage.Packages.import)
import.setAliases({
    client = StarterPlayer.StarterPlayerScripts,
    shared = ReplicatedStorage,
    Packages = ReplicatedStorage.Packages,
})
local Promise = import("Packages/promise")
for i,module in pairs(script.ClientCode:GetChildren()) do
    if module:IsA("ModuleScript") then
        local promised = Promise.new(function(resolve, reject, onCancel)
            require(module):init()
        end):catch(function(error)
            warn(`[CLIENT INITIALISATION]: Something failed!: {error}`)
        end)
    end
end
print('[CLIENT-FRAMEWORK]: Initialising.')