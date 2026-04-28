local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -75, 0.35, -25)
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "FORCE AFK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel Kontrol
_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local lastSkillTime = 0
local noEnemyTimer = tick()

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoDungeon = not _G.AutoDungeon
    if _G.AutoDungeon then
        ToggleButton.Text = "FORCE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
    else
        ToggleButton.Text = "FORCE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

-- Loop Utama (Kecepatan Tinggi)
RunService.Heartbeat:Connect(function()
    if _G.AutoDungeon then
        pcall(function()
            local char = Player.Character or Player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end

            -- 1. AUTO SKILL (Tiap 3 Detik)
            if tick() - lastSkillTime >= 3 then
                for _, key in pairs({"Q", "E", "R"}) do
                    VIM:SendKeyEvent(true, key, false, game)
                    VIM:SendKeyEvent(false, key, false, game)
                end
                lastSkillTime = tick()
            end

            -- 2. CARI MUSUH (Looping Lebih Agresif)
            local targetEnemy = nil
            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            
            if enemyFolder then
                for _, v in pairs(enemyFolder:GetChildren()) do
                    local hum = v:FindFirstChild("Humanoid")
                    local eHrp = v:FindFirstChild("HumanoidRootPart")
                    if hum and eHrp and hum.Health > 0 then
                        targetEnemy = eHrp
                        break
                    end
                end
            end

            if targetEnemy then
                -- AKSI TELEPORT KE MUSUH
                noEnemyTimer = tick()
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = targetEnemy.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                
                -- Expand Hitbox & Attack
                targetEnemy.Size = Vector3.new(40, 40, 40)
                targetEnemy.CanCollide = false
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            else
                -- 3. JIKA TIDAK ADA MUSUH (Cek Chest & Portal)
                
                -- AUTO CHEST
                local chest = nil
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name:match("Chest") or v.Name == "TreasureChests" then
                        chest = v:FindFirstChild("Root") or v:FindFirstChildWhichIsA("BasePart")
                        if chest then break end
                    end
                end

                if chest then
                    hrp.CFrame = chest.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                else
                    -- 4. PINTU & PORTAL (Jika 5 detik sepi)
                    if tick() - noEnemyTimer >= 5 then
                        -- Cari Portal Terlebih Dahulu
                        local foundPortal = false
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == "Root" and v.Parent.Name == "Portal" then
                                hrp.CFrame = v.CFrame
                                local rf = v:FindFirstChild("RF")
                                if rf then 
                                    rf:InvokeServer() 
                                    foundPortal = true
                                    break 
                                end
                            end
                        end
                        
                        -- Cari Pintu Jika Portal Tidak Ada
                        if not foundPortal then
                            for _, d in pairs(workspace:GetDescendants()) do
                                if d.Name == "LocalRoundDoor" then
                                    hrp.CFrame = d.CFrame * CFrame.new(0, 0, 3)
                                    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)
