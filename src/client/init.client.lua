local ReplicatedStorage = game:GetService("ReplicatedStorage")
local import = require(ReplicatedStorage.Packages.import)
local FrameworkMain = {}
local TimeElapsed
import.setAliases({
    ReplicatedStorage = game.ReplicatedStorage,
    Shared = game.ReplicatedStorage.Shared,
    Services = script.Services,
    Modules = script.Modules,
    Packages = game.ReplicatedStorage.Packages,
})
local ServiceStorage = import("Shared/ServiceStorage")
local Services = {
    "Decorative/radioService";
    "Decorative/LimbClientService";
    "Utility/LightService";
    "Utility/PlayerNetwork";
    "Utility/ShakeService";
    "Utility/DeathService";
    "Utility/GameTextService";
    "Utility/PlayerSetup";
    "Administration/AdminService";
    "Action/GunService";
}
function FrameworkMain:BootServices()
    warn('---- [ LOADING SYSTEMS ] ----')
    TimeElapsed = os.clock()
    for _, serviceName in pairs(Services) do
        local success,service = pcall(import, `Services/{serviceName}`)
        if success then
            ServiceStorage(service.ClassName, service)
            print(`Successfully initialized: {serviceName}`)
        else
            warn(`Failed Initializing ({serviceName}), {service}`)
        end
    end
    print('Client Services initialized.')
end
function FrameworkMain:StartServices()
    for name, service in pairs(ServiceStorage) do
        local success,err = pcall(service.Start, service)
        if not success then
            warn(`{name} has failed while starting. {err}`)
        end
    end
    print('Client Services started.')
    warn('---- [ LOADING FINISHED ] ----')
    warn(`---- TIME TAKEN: {math.ceil(os.clock()-TimeElapsed)} SECONDS ----`)
end
function FrameworkMain:BootFramework()
    self:BootServices()
    self:StartServices()
end
FrameworkMain:BootFramework()