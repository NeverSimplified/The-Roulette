local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local import = require(ReplicatedStorage.Packages.import)

for i,module in pairs(script.Modules:GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module):Init()
    end
end