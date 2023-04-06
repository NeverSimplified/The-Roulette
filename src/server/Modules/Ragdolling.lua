local Ragdolling = {}
local Sockets = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.red)

local StateNet = Red.Server("HumanoidStates", {
    "HumanoidStates"
})
local VelocityNet = Red.Server("ObjectVelocity", {
    "ObjectVelocity"
})

function ReplaceM6DWithBallSocket(Motor)
    local NewBallSocket = Instance.new("BallSocketConstraint")
    NewBallSocket.Parent = Motor.Parent
    NewBallSocket.Name = `BallSocket-{Motor.Name}`
    local att1 = Instance.new("Attachment")
    att1.Parent = Motor.Part1
    att1.CFrame = Motor.C1
    local att0 = Instance.new("Attachment")
    att0.Parent = Motor.Part0
    att0.CFrame = Motor.C0
    NewBallSocket.Attachment0 = att0
    NewBallSocket.Attachment1 = att1
    Motor.Enabled = false
    return NewBallSocket
end

function Ragdolling:Ragdoll(character)
    for _,Motor in pairs(character:GetDescendants()) do
        if Motor:IsA("Motor6D") then
            if Motor.Name == 'RootJoint' then
                continue
            end
            if not Sockets[Motor] then
                local Socket = ReplaceM6DWithBallSocket(Motor)
                Sockets[Motor] = Socket
            end
            Sockets[Motor].Enabled = true
            Motor.Enabled = false
        end
    end
    local P = Players:GetPlayerFromCharacter(character)
    StateNet:Fire(P,"HumanoidStates", Enum.HumanoidStateType.Ragdoll, true)
    if character.Torso.AssemblyLinearVelocity.Magnitude <= 10 then
        VelocityNet:Fire(P,"ObjectVelocity", character.Torso, (character.PrimaryPart.Position - (character.PrimaryPart.CFrame * CFrame.new(0,0,-5)).Position).Unit * 175)
    end
end

function Ragdolling:UnRagdoll(character)
    for _,Motor in pairs(character:GetDescendants()) do
        if Motor:IsA("Motor6D") then
            if Sockets[Motor] then
                Motor.Enabled = true
                Sockets[Motor].Enabled = false
            end
        end
    end
    local P = Players:GetPlayerFromCharacter(character)
    StateNet:Fire(P, "HumanoidStates", Enum.HumanoidStateType.GettingUp, false)
end

return Ragdolling