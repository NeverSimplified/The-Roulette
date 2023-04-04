local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local class = import("Packages/class")
local Service = class("Service")
function Service:__init(serviceName)
    print(`Initializing {serviceName or 'Unnamed Service'}`)
end
return Service