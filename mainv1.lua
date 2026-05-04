--[[
    PROJECT: ARCEUS X MINING AUTOMATION
    ARCHITECT: ROBOX (SENIOR LEVEL DESIGNER & DEVELOPER)
    OBJECTIVE: DYNAMIC SCANNING, UI SELECTION, AND REMOTE FIRING
]]--

local Library = {} -- Placeholder untuk struktur UI sederhana
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local DamageRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Chunks"):WaitForChild("damageBlock")

-- Konfigurasi State
local Settings = {
    AutoMine = false,
    SelectedMaterial = nil,
    TargetFolder = Workspace:WaitForChild("Blocks"),
    DropFolder = Workspace:WaitForChild("Drops")
}

-- 1. FUNGSI PEMINDAIAN (SCANNING)
-- Memindai MaterialVariant secara unik agar UI tidak penuh
local function GetAvailableMaterials()
    local materials = {}
    local children = Settings.TargetFolder:GetChildren()
    
    for _, block in ipairs(children) do
        if block:IsA("BasePart") and block.MaterialVariant ~= "" then
            materials[block.MaterialVariant] = true
        end
    end
    return materials
end

-- 2. LOGIKA PENAMBANGAN (MINING LOGIC)
-- Catatan: Karena Remote tidak menghancurkan instan, kita mensimulasikan hold.
local function StartMining()
    task.spawn(function()
        while Settings.AutoMine do
            if Settings.SelectedMaterial then
                for _, block in ipairs(Settings.TargetFolder:GetChildren()) do
                    if not Settings.AutoMine then break end
                    
                    if block:IsA("BasePart") and block.MaterialVariant == Settings.SelectedMaterial then
                        -- Jarak aman agar tidak terdeteksi anti-cheat (Magnitude Check)
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - block.Position).Magnitude
                        if dist < 25 then 
                            -- Fire Remote
                            DamageRemote:FireServer(block)
                            
                            -- Simulasi delay penambangan agar natural
                            task.wait(0.1) 
                            
                            -- Logika Teleport Drop (Hanya jika drop muncul)
                            -- Menggunakan ChildAdded untuk efisiensi tinggi
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- 3. LOGIKA AUTO-COLLECT DROPS
Settings.DropFolder.ChildAdded:Connect(function(drop)
    if Settings.AutoMine then
        task.wait(0.1) -- Menunggu physics drop stabil
        if drop:IsA("BasePart") or drop:IsA("Model") then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Teleport drop ke posisi pemain (lebih aman daripada pemain ke drop)
                if drop:IsA("Model") then
                    drop:SetPrimaryPartCFrame(root.CFrame)
                else
                    drop.CFrame = root.CFrame
                end
            end
        end
    end
end)

-- 4. PEMBUATAN UI (MINIMALIST & FUNCTIONAL)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Architect_Miner_UI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ARCHITECT MINER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "AUTO-MINE: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

local Dropdown = Instance.new("ScrollingFrame", MainFrame)
Dropdown.Size = UDim2.new(0.9, 0, 0, 130)
Dropdown.Position = UDim2.new(0.05, 0, 0.4, 0)
Dropdown.CanvasSize = UDim2.new(0, 0, 5, 0)
Dropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- Handler Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    Settings.AutoMine = not Settings.AutoMine
    ToggleBtn.Text = "AUTO-MINE: " .. (Settings.AutoMine and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = Settings.AutoMine and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    
    if Settings.AutoMine then
        StartMining()
    end
end)

-- Populating Dropdown dengan MaterialVariant
local function RefreshList()
    for _, v in ipairs(Dropdown:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    local mats = GetAvailableMaterials()
    local count = 0
    for matName, _ in pairs(mats) do
        local btn = Instance.new("TextButton", Dropdown)
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.Position = UDim2.new(0, 0, 0, count * 25)
        btn.Text = matName
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)
        
        btn.MouseButton1Click:Connect(function()
            Settings.SelectedMaterial = matName
            print("Selected: " .. matName)
        end)
        count = count + 1
    end
end

RefreshList()
