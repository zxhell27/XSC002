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
ScreenGui.Name = "Block1FarmUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
ToggleBtn.Text = "ACTIVATE BLOCK1 HACK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", MainFrame)
Instance.new("UICorner", ToggleBtn)

-- ==========================================
-- 2. LOGIKA BLOCK1 & FAST ENEMY
-- ==========================================
local function block1Farm()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    -- Lokasi aman yang kamu minta
    local safeBlock = workspace:FindFirstChild("Block1")
    if not safeBlock then 
        warn("Block1 tidak ditemukan di Workspace!")
        return 
    end

    local enemiesFolder = workspace:FindFirstChild("Enemy") 
    if not enemiesFolder then return end

    local enemies = enemiesFolder:GetChildren()
    local targetEnemy = enemies[3] -- Tetap menggunakan index ke-3 sebagai pusat

    -- Pindahkan karakter ke Block1
    hrp.CFrame = safeBlock.CFrame * CFrame.new(0, 3, 0) -- 3 stud di atas block agar tidak nyangkut
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.Anchored = true

    if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
        local gatherPos = targetEnemy.HumanoidRootPart.Position
        
        -- Tarik dan Percepat Musuh
        for _, enemy in ipairs(enemies) do
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChild("Humanoid")
            
            if eHrp then
                -- Tarik ke satu titik di depan Block1 agar bisa ditembak
                eHrp.CFrame = safeBlock.CFrame * CFrame.new(0, 0, -10) 
                
                -- Coba percepat musuh (WalkSpeed)
                if eHum then
                    eHum.WalkSpeed = 100 -- Nilai default biasanya 16
                end
            end
        end

        -- Auto Hit menggunakan Remote
        if weaponRemote then
            weaponRemote:FireServer("bullet", "Bu1", CFrame.new(hrp.Position, gatherPos))
        end
    end
end

-- ==========================================
-- 3. TOGGLE CONTROL
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "HACK ON (BLOCK1)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        loopConnection = RunService.Heartbeat:Connect(block1Farm)
    else
        ToggleBtn.Text = "ACTIVATE BLOCK1 HACK"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        if loopConnection then loopConnection:Disconnect() end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
        
        -- Kembalikan kecepatan musuh ke normal saat OFF (opsional)
        local enemiesFolder = workspace:FindFirstChild("Enemy")
        if enemiesFolder then
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                local eHum = enemy:FindFirstChild("Humanoid")
                if eHum then eHum.WalkSpeed = 16 end
            end
        end
    end
end)
