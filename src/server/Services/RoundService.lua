local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local import = require(ReplicatedStorage.Packages.import)
local ChairsModule = import("Modules/Chairs")
local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")

local RoundService, super = class("RoundService", Superclass)

function ServerToggleLights()
    
end

function RoundService:__init()
    super.__init(self)
end

function RoundService:Start()

end

return RoundService