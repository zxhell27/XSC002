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
ToggleButton.Text = "ULTIMATE AFK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel Kontrol
_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local lastSkillTime = 0
local noEnemyTimer = tick()
local spawnPos = nil 

-- Fungsi Klik Otomatis Play Again
local function HandleResultGui()
    pcall(function()
        local resultGui = Player.PlayerGui:FindFirstChild("ResultGui")
        if resultGui then
            local btn = resultGui.ScreenSettlement.BtnGroup.PlayAgainBtn
            if btn and btn.Visible and btn.AbsoluteSize.X > 0 then
                -- Simulasi Klik
                GuiService.SelectedObject = btn
                VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                
                -- Backup Klik via Connections
                if getconnections then
                    for _, v in pairs(getconnections(btn.MouseButton1Click)) do v:Fire() end
                    for _, v in pairs(getconnections(btn.Activated)) do v:Fire() end
                end
            end
        end
    end)
end

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoDungeon = not _G.AutoDungeon
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            spawnPos = Player.Character.HumanoidRootPart.Position
        end
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon then
        -- Selalu cek tombol Play Again setiap frame
        HandleResultGui()

        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 1. AUTO SKILL QER (3 Detik Sekali)
            if tick() - lastSkillTime >= 3 then
                for _, key in pairs({"Q", "E", "R"}) do
                    VIM:SendKeyEvent(true, key, false, game)
                    VIM:SendKeyEvent(false, key, false, game)
                end
                lastSkillTime = tick()
            end

            -- 2. DETEKSI MUSUH
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
                noEnemyTimer = tick()
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = targetEnemy.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                targetEnemy.Size = Vector3.new(40, 40, 40)
                targetEnemy.CanCollide = false
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            else
                -- 3. JIKA MUSUH HABIS: CEK CHEST
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
                elseif tick() - noEnemyTimer >= 6 then
                    -- 4. LOGIKA PORTAL & PINTU
                    local furthestPortal = nil
                    local maxDist = -1
                    
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent.Name == "Portal" then
                            local distFromSpawn = spawnPos and (v.Position - spawnPos).Magnitude or 0
                            if distFromSpawn > maxDist then
                                maxDist = distFromSpawn
                                furthestPortal = v
                            end
                        end
                    end

                    if furthestPortal then
                        hrp.CFrame = furthestPortal.CFrame
                        local rf = furthestPortal:FindFirstChild("RF")
                        if rf then 
                            rf:InvokeServer()
                            task.wait(1)
                            spawnPos = hrp.Position 
                            noEnemyTimer = tick()
                        end
                    else
                        -- Cari Pintu (F)
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
        end)
    end
end)
