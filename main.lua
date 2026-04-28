-- Iron Soul: Beta Exploit Script

-- // Services // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Variables // --
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local isFlying = false
local flySpeed = 50
local auraRadius = 15

-- // Functions // --

-- Fly Mode
function Fly()
    if isFlying then
        isFlying = false
        Humanoid.PlatformStand = false
        print("Fly mode disabled.")
    else
        isFlying = true
        Humanoid.PlatformStand = true
        print("Fly mode enabled.")
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Parent = RootPart
        bodyGyro.MaxTorque = Vector3.new(99999, 99999, 99999)
        bodyGyro.P = 5000
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = RootPart
        bodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
        
        RunService.Stepped:Connect(function()
            if not isFlying then
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
                return
            end
            
            bodyGyro.CFrame = RootPart.CFrame
            
            local direction = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + RootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - RootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - RootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + RootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0,1,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0,1,0)
            end

            bodyVelocity.Velocity = direction.Unit * flySpeed
        end)
    end
end

-- Aura Kill
function AuraKill()
    for i, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= Character and v:FindFirstChild("Humanoid") then
            local distance = (RootPart.Position - v:GetPrimaryPartCFrame().Position).Magnitude
            if distance <= auraRadius then
                v.Humanoid.Health = 0
            end
        end
    end
end

-- Auto Farm (Basic - Implement game-specific farming logic)
function AutoFarm()
    -- This is a placeholder.  You will need to adapt this to the specific game's mechanics.
    -- Example: Detect nearby enemies, move to them, and attack.

    while true do
        wait(1) -- Adjust the wait time as needed
        AuraKill() --  Call Aura Kill to eliminate nearby entities

        -- Example for moving to the nearest enemy.  Requires game-specific enemy detection.
        -- local nearestEnemy = FindNearestEnemy() -- Placeholder function
        -- if nearestEnemy then
        --    Character:MoveTo(nearestEnemy.Position)
        --    -- Attack the enemy (game-specific)
        -- end
    end
end

--// Mobile Support (Simple Toggle with Button) //--
local mobileButton = Instance.new("TextButton")
mobileButton.Size = UDim2.new(0, 100, 0, 30)
mobileButton.Position = UDim2.new(0, 10, 0, 10)
mobileButton.Text = "Toggle Fly"
mobileButton.BackgroundTransparency = 0.5
mobileButton.Parent = LocalPlayer.PlayerGui

mobileButton.MouseButton1Click:Connect(Fly)

-- // Keybinds // --
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.F then
        Fly()
    elseif input.KeyCode == Enum.KeyCode.K then
        AuraKill()
    elseif input.KeyCode == Enum.KeyCode.J then
        AutoFarm()
    end
end)

-- // Initialization // --
print("Iron Soul: Beta - Loaded")
