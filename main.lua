local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.5, -75, 0.35, -25)
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "AUTO DUNGEON OP: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel
_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local lastSkillTime = 0
local noEnemyTimer = 0 

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoDungeon = not _G.AutoDungeon
    if _G.AutoDungeon then
        ToggleButton.Text = "AUTO DUNGEON OP: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        noEnemyTimer = tick() 
    else
        ToggleButton.Text = "AUTO DUNGEON OP: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end
end)

-- Fungsi Cari Portal Terdekat (Validasi Keluar)
local function EnterCorrectPortal()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Mencari semua portal di dalam RoundDoor
    if workspace:FindFirstChild("RoundDoor") then
        for _, v in pairs(workspace.RoundDoor:GetDescendants()) do
            -- Mencari objek 'Root' yang berada di dalam folder 'Portal'
            if v.Name == "Root" and v.Parent.Name == "Portal" then
                local rf = v:FindFirstChild("RF")
                if rf then
                    -- Teleport tipis ke posisi portal agar valid di server
                    hrp.CFrame = v.CFrame
                    task.wait(0.1)
                    -- Jalankan Invoke
                    pcall(function()
                        rf:InvokeServer()
                    end)
                    return true
                end
            end
        end
    end
    return false
end

-- Loop Utama
RunService.Stepped:Connect(function()
    if _G.AutoDungeon then
        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 1. AUTO SKILL QER
            if tick() - lastSkillTime >= 3 then
                local skills = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R}
                for _, k in pairs(skills) do
                    VIM:SendKeyEvent(true, k, false, game)
                    VIM:SendKeyEvent(false, k, false, game)
                end
                lastSkillTime = tick()
            end

            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            local enemies = enemyFolder and enemyFolder:GetChildren() or {}
            local activeEnemy = nil
            
            for _, enemy in pairs(enemies) do
                local eHum = enemy:FindFirstChild("Humanoid")
                if eHum and eHum.Health > 0 then
                    activeEnemy = enemy
                    break
                end
            end

            if activeEnemy then
                noEnemyTimer = tick() 
                local eHrp = activeEnemy:FindFirstChild("HumanoidRootPart")
                if eHrp then
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = eHrp.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    eHrp.Size = Vector3.new(35, 35, 35)
                    eHrp.CanCollide = false
                    game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                end
            else
                -- 2. LOGIKA ANTI-STUCK / PORTAL (10 Detik Musuh Habis)
                if tick() - noEnemyTimer >= 10 then
                    local success = EnterCorrectPortal()
                    if success then noEnemyTimer = tick() end
                end

                -- 3. AUTO CHEST
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name:match("Chest") or v.Name == "TreasureChests" then
                        local cp = v:FindFirstChild("Root") or v:FindFirstChildWhichIsA("BasePart")
                        if cp then
                            hrp.CFrame = cp.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                            game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                            break
                        end
                    end
                end
                
                -- 4. PINTU MANUAL (F)
                if workspace:FindFirstChild("RoundDoor") then
                    for _, d in pairs(workspace.RoundDoor:GetDescendants()) do
                        if d.Name == "LocalRoundDoor" then
                            hrp.CFrame = d.CFrame * CFrame.new(0, 0, 3)
                            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            task.wait(0.05)
                            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        end
                    end
                end
            end
        end)
    end
end)
