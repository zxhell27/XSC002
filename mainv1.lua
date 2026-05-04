--[[
    PROFESSIONAL MINING AUTOFARM (Arceus X Optimized)
    Fitur: Auto-Scan, Auto-Remote, Auto-Collect Drops, & UI Toggle
]]

local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- 1. PEMBERSIHAN UI LAMA (Mencegah Duplicate UI saat Re-exec)
if player.PlayerGui:FindFirstChild("ArceusAutoMining") then
    player.PlayerGui.ArceusAutoMining:Destroy()
end

-- 2. SETUP UI OTOMATIS
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArceusAutoMining"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0, 160, 0, 45)
mainBtn.Position = UDim2.new(0.5, -80, 0.15, 0)
mainBtn.Text = "MINING: OFF"
mainBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainBtn.Font = Enum.Font.GothamBold
mainBtn.TextSize = 14
mainBtn.Parent = screenGui

-- Membuat sudut membulat agar lebih profesional
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainBtn

-- 3. KONFIGURASI & VARIABEL
local isActive = false
local damageRemote = nil

-- Fungsi mencari Remote secara aman
local function getDamageRemote()
    local success, res = pcall(function()
        return RS.Remotes.Chunks.damageBlock
    end)
    return success and res or nil
end

-- 4. FUNGSI SCANNING (Teliti & Akurat)
local function getTarget()
    local folder = workspace:FindFirstChild("Blocks")
    if not folder then return nil end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local bestPart = nil
    local maxDist = math.huge

    for _, v in ipairs(folder:GetChildren()) do
        -- Validasi Properti MaterialVariant sesuai instruksi
        local success, mVariant = pcall(function() return v.MaterialVariant end)
        
        if success and mVariant ~= "" then
            local dist = (char.HumanoidRootPart.Position - v.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                bestPart = v
            end
        end
    end
    return bestPart
end

-- 5. LOOP UTAMA (Mining)
task.spawn(function()
    while task.wait(0.1) do
        if isActive then
            damageRemote = damageRemote or getDamageRemote()
            
            if damageRemote then
                local target = getTarget()
                if target then
                    -- Simulasi Menghadap Target (Penting untuk beberapa Anticheat)
                    local root = player.Character.HumanoidRootPart
                    root.CFrame = CFrame.new(root.Position, Vector3.new(target.Position.X, root.Position.Y, target.Position.Z))
                    
                    -- Fire Remote
                    damageRemote:FireServer(target)
                end
            end
        end
    end
end)

-- 6. AUTO-COLLECT DROPS (Teleport Drop ke Karakter)
local dropsFolder = workspace:WaitForChild("Drops", 5)
if dropsFolder then
    dropsFolder.ChildAdded:Connect(function(item)
        if isActive and item:IsA("BasePart") then
            task.wait(0.2) -- Jeda agar physics drop stabil
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                item.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end)
end

-- 7. INTERAKSI TOMBOL
mainBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        mainBtn.Text = "MINING: ACTIVE"
        mainBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    else
        mainBtn.Text = "MINING: OFF"
        mainBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    end
end)
