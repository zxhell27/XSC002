local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- Mencoba mencari Remote (Jika nama senjata berubah, sesuaikan bagian ini)
local weaponRemote = workspace:FindFirstChild("Lutung055") and workspace.Lutung055:FindFirstChild("Weapon") and workspace.Lutung055.Weapon:FindFirstChild("revent")

-- ==========================================
-- 1. UI SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FixFarmUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Text = "FORCE START"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", MainFrame)
Instance.new("UICorner", ToggleBtn)

-- ==========================================
-- 2. LOGIKA UTAMA (FIXED)
-- ==========================================
local function startHack()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    -- Ambil Block1 secara dinamis
    local block = workspace:FindFirstChild("Block1")
    local enemyFolder = workspace:FindFirstChild("Enemy")

    if not hrp or not block then return end

    -- 1. PAKSA PINDAH KE BLOCK1 (Setiap frame agar tidak bisa gerak)
    hrp.Anchored = true
    hrp.CFrame = block.CFrame * CFrame.new(0, 3, 0) -- Berdiri di atas block
    
    if enemyFolder then
        local enemies = enemyFolder:GetChildren()
        -- Target index ke-3 atau gunakan musuh pertama yang ada jika kurang dari 3
        local targetEnemy = enemies[3] or enemies[1]

        if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
            local gatherPos = targetEnemy.HumanoidRootPart.Position

            -- 2. TARIK SEMUA MUSUH KE DEPAN BLOCK1
            for _, enemy in ipairs(enemies) do
                local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                local eHum = enemy:FindFirstChild("Humanoid")
                if eHrp then
                    -- Musuh dikumpulkan 8 stud di depan posisi kamu di Block1
                    eHrp.CFrame = block.CFrame * CFrame.new(0, 0, -8)
                    
                    -- Percepat musuh
                    if eHum then eHum.WalkSpeed = 150 end
                end
            end

            -- 3. AUTO REMOTE HIT (Berdasarkan TurtleSpy kamu)
            if weaponRemote then
                weaponRemote:FireServer("bullet", "Bu1", CFrame.new(hrp.Position, gatherPos))
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
        ToggleBtn.Text = "RUNNING..."
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        -- Gunakan Stepped agar berjalan sebelum physics (lebih paksa)
        loopConnection = RunService.Stepped:Connect(startHack)
    else
        ToggleBtn.Text = "FORCE START"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        -- Lepas Anchor agar bisa gerak lagi
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
