local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Name = "IronSoul_UltimateAFK_V2"
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
ToggleButton.TextSize = 12
UICorner.Parent = MainFrame

CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Variabel Kontrol
_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local lastSkillTime = 0
local noEnemyTimer = tick()
local currentSpawnPoint = nil -- Mengunci titik awal ruangan

-- Fungsi Update Spawn Point (Hanya saat pindah ruangan)
local function UpdateSpawnPoint()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        currentSpawnPoint = Player.Character.HumanoidRootPart.Position
        print("Spawn Point Terkunci: ", currentSpawnPoint)
    end
end

-- Fungsi Toggle
local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
        UpdateSpawnPoint()
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

ToggleButton.MouseButton1Click:Connect(function() SetToggle(not _G.AutoDungeon) end)
CloseButton.MouseButton1Click:Connect(function() _G.AutoDungeon = false ScreenGui:Destroy() end)

-- Auto Start 5 Detik
task.spawn(function()
    for i = 5, 1, -1 do
        if _G.AutoDungeon then break end
        ToggleButton.Text = "AUTO START IN: " .. i
        task.wait(1)
    end
    if not _G.AutoDungeon and ScreenGui.Parent then SetToggle(true) end
end)

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon and ScreenGui.Parent then
        -- 0. CEK TOMBOL PLAY AGAIN (RESULT)
        pcall(function()
            local resGui = Player.PlayerGui:FindFirstChild("ResultGui")
            if resGui and resGui.ScreenSettlement.BtnGroup.PlayAgainBtn.Visible then
                GuiService.SelectedObject = resGui.ScreenSettlement.BtnGroup.PlayAgainBtn
                VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end)

        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 1. SKILL QER
            if tick() - lastSkillTime >= 3 then
                for _, k in pairs({"Q", "E", "R"}) do
                    VIM:SendKeyEvent(true, k, false, game)
                    VIM:SendKeyEvent(false, k, false, game)
                end
                lastSkillTime = tick()
            end

            -- 2. CEK MUSUH
            local target = nil
            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            if enemyFolder then
                for _, v in pairs(enemyFolder:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        target = v.HumanoidRootPart
                        break
                    end
                end
            end

            if target then
                noEnemyTimer = tick()
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = target.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                target.Size = Vector3.new(40, 40, 40)
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            else
                -- 3. JIKA MUSUH HABIS: CEK PETI (CHEST)
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
                    -- 4. LOGIKA PORTAL ANTI-BALIK
                    local exitPortal = nil
                    local maxDist = -1
                    
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent.Name == "Portal" then
                            -- Selalu hitung jarak portal dari titik AWAL masuk ruangan
                            -- Bukan dari posisi karakter saat ini (yang mungkin sedang di dekat chest)
                            local distFromSpawn = currentSpawnPoint and (v.Position - currentSpawnPoint).Magnitude or 0
                            
                            -- Portal keluar haruslah yang terjauh dari tempat kita masuk
                            if distFromSpawn > maxDist then
                                maxDist = distFromSpawn
                                exitPortal = v
                            end
                        end
                    end

                    if exitPortal and maxDist > 40 then
                        hrp.CFrame = exitPortal.CFrame
                        local rf = exitPortal:FindFirstChild("RF")
                        if rf then 
                            rf:InvokeServer()
                            task.wait(2)
                            UpdateSpawnPoint() -- Kunci titik spawn baru untuk ruangan selanjutnya
                            noEnemyTimer = tick()
                        end
                    else
                        -- Cari Pintu (F) sebagai cadangan
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
