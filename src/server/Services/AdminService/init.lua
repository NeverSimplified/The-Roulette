local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)

local cmdr = import("Packages/cmdr")
local class = import("Packages/class")
local Superclass = import("Shared/Superclass/Service")

local AdminService, super = class("AdminService", Superclass)

function AdminService:__init()
    super.__init(self)
end

function AdminService:Start()
    cmdr:RegisterCommandsIn(script.Commands)
    cmdr:RegisterHooksIn(script.Hooks)
end

return AdminService