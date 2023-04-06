local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local Permissions = import("Shared/Permissions")
return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
        if not context.Group then
            return "Command improperly registered."
        end
        local Rank = Permissions:RetrievePermissionLevel(context.Executor)
        if Rank < context.Group then
            return "You don't have the needed permission to run this command."
        end
	end)
end