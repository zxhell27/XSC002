local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- ==========================================
-- 1. MEMBUAT TAMPILAN UI (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBringUI"
ScreenGui.ResetOnSpawn = false

-- Menggunakan CoreGui agar UI tidak hilang saat karakter mati (khusus Executor)
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Membuat UI bisa digeser dengan jari/mouse
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0.4, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Auto Bring Enemies"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Warna Merah (OFF)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 18
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- ==========================================
-- 2. LOGIKA AUTO BRING (LOOP)
-- ==========================================
local function doAutoBring()
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
        local gatherPosition = centerEnemy.HumanoidRootPart.Position

        -- Kumpulkan musuh
        for _, enemy in ipairs(enemies) do
            local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
            if enemyHrp and enemy ~= centerEnemy then
                enemyHrp.CFrame = CFrame.new(gatherPosition)
            end
        end

        -- Posisi karakter di atas musuh menghadap ke bawah
        local tinggiDariMusuh = 15
        local playerHoverPosition = gatherPosition + Vector3.new(0, tinggiDariMusuh, 0)
        
        hrp.CFrame = CFrame.lookAt(playerHoverPosition, gatherPosition)
        
        -- Kunci karakter agar tidak jatuh/terpental
        hrp.Anchored = true
        hrp.Velocity = Vector3.new(0, 0, 0) 
    end
end

-- ==========================================
-- 3. LOGIKA TOMBOL ON/OFF
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning -- Balikkan status (True jadi False, False jadi True)
    
    if isRunning then
        -- SAAT DIHIDUPKAN (ON)
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- Ubah warna jadi hijau
        
        -- Mulai Loop agar musuh terus ditarik dan karaktermu tetap di atas
        loopConnection = RunService.RenderStepped:Connect(doAutoBring)
    else
        -- SAAT DIMATIKAN (OFF)
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Ubah warna jadi merah
        
        -- Hentikan Loop
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        
        -- Lepaskan anchor karaktermu agar bisa bergerak normal lagi
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
