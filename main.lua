local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- Remote dari TurtleSpy
local weaponRemote = workspace:FindFirstChild("Lutung055") and workspace.Lutung055:FindFirstChild("Weapon") and workspace.Lutung055.Weapon:FindFirstChild("revent")

-- ==========================================
-- 1. UI SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrackFarmUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
ToggleBtn.Text = "ACTIVATE HACK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", MainFrame)
Instance.new("UICorner", ToggleBtn)

-- ==========================================
-- 2. LOGIKA UTAMA (PATH: Block1.Track)
-- ==========================================
local function executeHack()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    -- MENCARI PATH: workspace.Block1.Track
    local block1 = workspace:FindFirstChild("Block1")
    local trackTarget = block1 and block1:FindFirstChild("Track")
    local enemyFolder = workspace:FindFirstChild("Enemy")

    -- Validasi apakah objek ditemukan
    if not hrp or not trackTarget then 
        return 
    end

    -- 1. PINDAHKAN KARAKTER KE TRACK
    -- Menggunakan CFrame dari Track dan naik 3 stud agar tidak masuk ke dalam objek
    hrp.Anchored = true
    hrp.CFrame = trackTarget.CFrame * CFrame.new(0, 3, 0)
    hrp.Velocity = Vector3.new(0, 0, 0)

    -- 2. KELOLA MUSUH
    if enemyFolder then
        local enemies = enemyFolder:GetChildren()
        if #enemies > 0 then
            -- Ambil musuh ke-3 atau pertama yang tersedia
            local targetEnemy = enemies[3] or enemies[1]
            local targetHrp = targetEnemy:FindFirstChild("HumanoidRootPart")
            
            if targetHrp then
                local gatherPos = targetHrp.Position

                for _, enemy in ipairs(enemies) do
                    local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                    local eHum = enemy:FindFirstChild("Humanoid")
                    
                    if eHrp then
                        -- Tarik musuh ke depan Track agar bisa ditembak (jarak 10 stud)
                        eHrp.CFrame = trackTarget.CFrame * CFrame.new(0, 0, -10)
                        
                        -- Buat musuh cepat
                        if eHum then eHum.WalkSpeed = 120 end
                    end
                end

                -- 3. AUTO HIT REMOTE
                if weaponRemote then
                    weaponRemote:FireServer("bullet", "Bu1", CFrame.new(hrp.Position, gatherPos))
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
        ToggleBtn.Text = "HACK ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 150, 20)
        -- Gunakan Heartbeat agar mengikuti pergerakan kereta dengan mulus
        loopConnection = RunService.Heartbeat:Connect(executeHack)
    else
        ToggleBtn.Text = "ACTIVATE HACK"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
        
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
