local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, -25)
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "AUTO DUNGEON: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel
_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoDungeon = not _G.AutoDungeon
    if _G.AutoDungeon then
        ToggleButton.Text = "AUTO DUNGEON: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "AUTO DUNGEON: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Loop Utama
RunService.Stepped:Connect(function()
    if _G.AutoDungeon then
        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            local enemies = enemyFolder and enemyFolder:GetChildren() or {}
            
            -- Cek apakah ada musuh yang tersisa (HP > 0)
            local activeEnemy = nil
            for _, enemy in pairs(enemies) do
                local eHum = enemy:FindFirstChild("Humanoid")
                if eHum and eHum.Health > 0 then
                    activeEnemy = enemy
                    break
                end
            end

            if activeEnemy then
                -- LOGIKA SERANG: Melayang di atas musuh terdekat
                local eHrp = activeEnemy:FindFirstChild("HumanoidRootPart")
                if eHrp then
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = eHrp.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Expand Hitbox
                    eHrp.Size = Vector3.new(30, 30, 30)
                    eHrp.CanCollide = false
                    
                    -- Serang
                    game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                end
            else
                -- LOGIKA PINTU: Jika musuh habis, cari pintu
                local door = workspace:FindFirstChild("RoundDoor") and workspace.RoundDoor:FindFirstChild("Door") 
                             and workspace.RoundDoor.Door:FindFirstChild("Root") 
                             and workspace.RoundDoor.Door.Root:FindFirstChild("LocalRoundDoor")

                if door then
                    -- Teleport ke depan pintu
                    hrp.CFrame = door.CFrame * CFrame.new(0, 0, 3)
                    
                    -- Simulasi Tekan Tombol F
                    -- Kita kirim input F berulang kali sampai pintu terbuka/pindah area
                    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
            end
        end)
    end
end)
