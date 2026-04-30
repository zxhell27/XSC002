local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- Remote dari TurtleSpy kamu
local weaponRemote = workspace:FindFirstChild("Lutung055") and workspace.Lutung055:FindFirstChild("Weapon") and workspace.Lutung055.Weapon:FindFirstChild("revent")

-- ==========================================
-- 1. UI SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateKillUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
ToggleBtn.Text = "ULTIMATE KILL"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", MainFrame)
Instance.new("UICorner", ToggleBtn)

-- ==========================================
-- 2. LOGIKA STAND, PULL, & AUTO SHOOT
-- ==========================================
local function ultimateFarm()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    local block1 = workspace:FindFirstChild("Block1")
    local trackTarget = block1 and block1:FindFirstChild("Track")
    local enemyFolder = workspace:FindFirstChild("Enemy")

    if not hrp or not trackTarget then return end

    -- 1. Berdiri di Kill Zone (Block1)
    hrp.Anchored = true
    hrp.CFrame = trackTarget.CFrame * CFrame.new(0, 3, 0)
    hrp.Velocity = Vector3.new(0, 0, 0)

    -- 2. Tarik & Tembak Semua Musuh
    if enemyFolder then
        local enemies = enemyFolder:GetChildren()
        for _, enemy in ipairs(enemies) do
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            if eHrp then
                -- Tarik musuh ke titik kumpul (Kill Zone)
                local enemyPos = trackTarget.CFrame
                eHrp.CFrame = enemyPos
                
                -- 3. AUTO SHOOT (Menggunakan Remote FireServer)
                -- Menembak setiap musuh yang terdeteksi di folder Enemy
                if weaponRemote then
                    weaponRemote:FireServer("bullet", "Bu1", CFrame.new(hrp.Position, eHrp.Position))
                end
            end
        end
    end
end

-- ==========================================
-- 3. TOGGLE HANDLER
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "ACTIVE & SHOOTING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        -- Menggunakan Heartbeat agar serangan remote tidak terlalu lag tapi tetap cepat
        loopConnection = RunService.Heartbeat:Connect(ultimateFarm)
    else
        ToggleBtn.Text = "ULTIMATE KILL"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
        if loopConnection then loopConnection:Disconnect() end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
