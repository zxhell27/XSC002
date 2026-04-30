local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- ==========================================
-- 1. TAMPILAN UI (GUI) - Tetap Sama
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GunFarmUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ToggleBtn.Text = "START GUN"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.Parent = ToggleBtn

-- ==========================================
-- 2. LOGIKA GUN FARM (DIDEPAN, SEJAJAR)
-- ==========================================
local function gunBring()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemiesFolder = workspace:FindFirstChild("Enemy") 
    if not enemiesFolder then return end

    local enemies = enemiesFolder:GetChildren()
    local targetIndex = 3 
    local centerEnemy = enemies[targetIndex]

    if centerEnemy and centerEnemy:FindFirstChild("HumanoidRootPart") then
        local enemyHrp = centerEnemy.HumanoidRootPart
        
        -- Ambil Posisi dan Arah Hadap Musuh Acuan
        local enemyCFrame = enemyHrp.CFrame
        local gatherPos = enemyCFrame.Position

        -- 1. Kumpulkan semua musuh di SATU TITIK & ARAH YANG SAMA
        for _, enemy in ipairs(enemies) do
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            if eHrp then
                -- Semua musuh ditumpuk di posisi enemy ke-3 dan menghadap arah yang sama
                eHrp.CFrame = enemyCFrame 
            end
        end

        -- 2. Tentukan Posisi Kamu (Di Depan Musuh)
        -- Ubah angka 15 untuk mengatur jarak tembak (horizontal)
        local jarakTembak = 15 
        
        -- Kita hitung posisi tepat di depan musuh
        -- enemyCFrame.LookVector adalah arah depan musuh
        -- Kita kalikan dengan jarak, lalu tambahkan ke posisi musuh
        local positionInFront = gatherPos + (enemyCFrame.LookVector * jarakTembak)
        
        -- Buat CFrame baru di posisi depan tersebut, dan paksa menghadap kembali ke musuh
        hrp.CFrame = CFrame.lookAt(positionInFront, gatherPos)
        
        -- 3. Kunci Karakter (Anchored) agar tidak jatuh atau didorong physics
        hrp.Anchored = true
        hrp.Velocity = Vector3.new(0, 0, 0) 
    end
end

-- ==========================================
-- 3. TOGGLE ON/OFF
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "GUN ACTIVE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        loopConnection = RunService.Heartbeat:Connect(gunBring)
    else
        ToggleBtn.Text = "START GUN"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
