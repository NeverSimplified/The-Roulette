local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local FrameworkMain = {}
import.setAliases({
    Server = game.ServerScriptService.Framework,
    Client = game.StarterPlayer.StarterPlayerScripts.Framework,
    Shared = game.ReplicatedStorage.Shared,
    Services = game.ServerScriptService.Framework.Services,
    Modules = game.ServerScriptService.Framework.Modules,
    Packages = game.ReplicatedStorage.Packages,
})
local ServiceStorage = import("Shared/ServiceStorage")
local Services = {

}
function FrameworkMain:BootServices()
    for _, serviceName in pairs(Services) do
        local success,service = pcall(import, `Services/{serviceName}`)
        if success then
            service:__init(service.ClassName)
            ServiceStorage(service.ClassName, service)
            print(`Successfully initialized: {serviceName}`)
        else
            warn(`Failed Initializing ({serviceName}), {service}`)
        end
    end
    print('Services initialized.')
end
function FrameworkMain:StartServices()
    for name, service in pairs(ServiceStorage) do
        local success,err = pcall(service.Start, service)
        if not success then
            warn(`{name} has failed while starting. {err}`)
        end
    end
    print('Services started.')
end
function FrameworkMain:BootFramework()
    self:BootServices()
    self:StartServices()
end
FrameworkMain:BootFramework()