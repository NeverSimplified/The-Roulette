local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local class = import("Packages/class")
local Service = class("Service")
function Service:__init(service)
    print(`Initializing {service.ClassName or 'Unnamed Service'}`)
end
return Service