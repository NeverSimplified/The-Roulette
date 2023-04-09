local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local class = import("Packages/class")
local Service = class("Service")
function Service:__init()
    print(`Initialising {self.ClassName or 'Unnamed Service'}`)
    Service.ClassName = self.ClassName
end
return Service