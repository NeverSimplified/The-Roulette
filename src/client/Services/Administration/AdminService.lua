local ReplicatedStorage = game:GetService("ReplicatedStorage")

local import = require(ReplicatedStorage.Packages.import)

local cmdr = import("ReplicatedStorage/CmdrClient")
local class = import("Packages/class")
local superclass = import("Shared/Superclass/Service")

local AdminService, super = class("AdminService", superclass)

function AdminService:__init()
    super.__init(self)
end

function AdminService:Start()
    cmdr:SetActivationKeys({Enum.KeyCode.F2, Enum.KeyCode.Semicolon})
end

return AdminService.new()