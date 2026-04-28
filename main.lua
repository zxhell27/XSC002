local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Name = "IronSoul_UltimateAFK"
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
local spawnPos = nil

-- PERBAIKAN: Sistem anti-skip portal
local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 5        -- detik tunggu setelah masuk portal
local usedPortalPositions = {}     -- blacklist posisi portal yang sudah dipakai
local PORTAL_BLACKLIST_RADIUS = 20 -- jarak minimum untuk dianggap portal yang sama

-- Fungsi cek apakah portal sudah pernah dipakai
local function IsPortalUsed(pos)
    for _, usedPos in ipairs(usedPortalPositions) do
        if (pos - usedPos).Magnitude < PORTAL_BLACKLIST_RADIUS then
            return true
        end
    end
    return false
end

-- Fungsi toggle utama
local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
        usedPortalPositions = {} -- reset blacklist saat mulai
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            spawnPos = Player.Character.HumanoidRootPart.Position
        end
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    SetToggle(not _G.AutoDungeon)
end)

CloseButton.MouseButton1Click:Connect(function()
    _G.AutoDungeon = false
    ScreenGui:Destroy()
end)

-- Auto-start 5 detik
task.spawn(function()
    for i = 5, 1, -1 do
        if _G.AutoDungeon then break end
        ToggleButton.Text = "AUTO START IN: " .. i
        task.wait(1)
    end
    if not _G.AutoDungeon and ScreenGui.Parent then
        SetToggle(true)
    end
end)

-- Fungsi Play Again
local function HandleResultGui()
    pcall(function()
        local resultGui = Player.PlayerGui:FindFirstChild("ResultGui")
        if resultGui then
            local btn = resultGui.ScreenSettlement.BtnGroup.PlayAgainBtn
            if btn and btn.Visible and btn.AbsoluteSize.X > 0 then
                GuiService.SelectedObject = btn
                VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                if getconnections then
                    for _, v in pairs(getconnections(btn.MouseButton1Click)) do v:Fire() end
                    for _, v in pairs(getconnections(btn.Activated)) do v:Fire() end
                end
                -- Reset semua state saat play again
                usedPortalPositions = {}
                lastTeleportTime = tick()
                noEnemyTimer = tick()
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    spawnPos = Player.Character.HumanoidRootPart.Position
                end
            end
        end
    end)
end

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon and ScreenGui.Parent then
        HandleResultGui()

        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 1. AUTO SKILL QER
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
                -- 3. CEK CHEST
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

                -- PERBAIKAN: Cek cooldown dulu sebelum cari portal
                elseif tick() - noEnemyTimer >= 6 and tick() - lastTeleportTime >= TELEPORT_COOLDOWN then

                    -- 4. CARI PORTAL (ANTI-SKIP)
                    -- Prioritas: portal terjauh dari spawn yang BELUM dipakai
                    local bestPortal = nil
                    local maxDist = -1

                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent and v.Parent.Name == "Portal" then
                            local pos = v.Position

                            -- Skip portal yang sudah dipakai sebelumnya
                            if not IsPortalUsed(pos) then
                                local distFromSpawn = spawnPos and (pos - spawnPos).Magnitude or 0
                                -- Pilih portal terjauh dari titik spawn stage ini
                                if distFromSpawn > maxDist then
                                    maxDist = distFromSpawn
                                    bestPortal = v
                                end
                            end
                        end
                    end

                    if bestPortal then
                        -- Teleport ke portal
                        hrp.CFrame = bestPortal.CFrame

                        local rf = bestPortal:FindFirstChild("RF")
                        if rf then
                            -- Catat portal ini sebagai "sudah dipakai"
                            table.insert(usedPortalPositions, bestPortal.Position)

                            rf:InvokeServer()
                            lastTeleportTime = tick() -- mulai cooldown

                            -- Tunggu player benar-benar pindah stage
                            task.wait(3)

                            -- Update spawnPos ke posisi baru (stage baru)
                            if hrp and hrp.Parent then
                                spawnPos = hrp.Position
                            end
                            noEnemyTimer = tick()
                        end
                    else
                        -- Semua portal sudah dipakai → reset blacklist (stage baru?)
                        -- atau cari pintu
                        local allPortalCount = 0
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == "Root" and v.Parent and v.Parent.Name == "Portal" then
                                allPortalCount = allPortalCount + 1
                            end
                        end

                        -- Kalau tidak ada portal sama sekali → cari pintu
                        if allPortalCount == 0 then
                            for _, d in pairs(workspace:GetDescendants()) do
                                if d.Name == "LocalRoundDoor" then
                                    hrp.CFrame = d.CFrame * CFrame.new(0, 0, 3)
                                    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                                    break
                                end
                            end
                        else
                            -- Ada portal tapi semua di-blacklist → reset blacklist
                            -- (kemungkinan stage baru load dengan portal posisi berbeda)
                            usedPortalPositions = {}
                        end
                    end
                end
            end
        end)
    end
end)
