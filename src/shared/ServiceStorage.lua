local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local class = import("Packages/class")
local Storage = {}
setmetatable(Storage, {
    __call = function(self, name, service)
        self[name] = service
    end
})
return Storage