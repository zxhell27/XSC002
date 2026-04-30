local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- ==========================================
-- 1. TAMPILAN UI (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RangeFarmUI"
ScreenGui.ResetOnSpawn = false

local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
ToggleBtn.Text = "START RANGE"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.Parent = ToggleBtn

-- ==========================================
-- 2. LOGIKA DISTANCE BRING (UNTUK MENEMBAK)
-- ==========================================
local function rangeBring()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemiesFolder = workspace:FindFirstChild("Enemy") 
    if not enemiesFolder then return end

    local enemies = enemiesFolder:GetChildren()
    local targetIndex = 3 -- Musuh acuan ke-3
    local centerEnemy = enemies[targetIndex]

    if centerEnemy and centerEnemy:FindFirstChild("HumanoidRootPart") then
        local gatherPos = centerEnemy.HumanoidRootPart.Position

        -- 1. Kumpulkan semua musuh di satu titik
        for _, enemy in ipairs(enemies) do
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            if eHrp then
                eHrp.CFrame = CFrame.new(gatherPos)
            end
        end

        -- 2. Tentukan jarak tembak (Jarak aman dari musuh)
        -- Ubah angka 15 jika ingin lebih jauh atau lebih dekat
        local jarakTembak = 15 
        
        -- Kita buat posisi kamu berada di depan titik kumpul (menggunakan offset sumbu Z atau X)
        -- Di sini kita pakai CFrame.lookAt agar kamu selalu menghadap musuh
        local myNewPos = gatherPos + Vector3.new(0, 2, jarakTembak) -- Sedikit lebih tinggi (2) agar peluru tidak kena lantai
        
        hrp.CFrame = CFrame.lookAt(myNewPos, gatherPos)
        
        -- Kunci posisi agar tidak terdorong saat menembak
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.Anchored = true 
    end
end

-- ==========================================
-- 3. TOGGLE ON/OFF
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "RANGE ACTIVE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
        loopConnection = RunService.Heartbeat:Connect(rangeBring)
    else
        ToggleBtn.Text = "START RANGE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
