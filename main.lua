local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Name = "IronSoul_UltimateAFK_Fixed"
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
local usedPortals = {} -- MEMORI PORTAL

-- Fungsi Reset Memori
local function ResetDungeonSession()
    usedPortals = {}
    noEnemyTimer = tick()
end

-- Fungsi Utama Toggle
local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

ToggleButton.MouseButton1Click:Connect(function() SetToggle(not _G.AutoDungeon) end)
CloseButton.MouseButton1Click:Connect(function() _G.AutoDungeon = false ScreenGui:Destroy() end)

-- LOGIKA AUTO-START (5 DETIK)
task.spawn(function()
    for i = 5, 1, -1 do
        if _G.AutoDungeon then break end
        ToggleButton.Text = "AUTO START IN: " .. i
        task.wait(1)
    end
    if not _G.AutoDungeon and ScreenGui.Parent then SetToggle(true) end
end)

-- Fungsi Play Again
local function HandleResultGui()
    pcall(function()
        local resultGui = Player.PlayerGui:FindFirstChild("ResultGui")
        if resultGui and resultGui.ScreenSettlement.BtnGroup.PlayAgainBtn.Visible then
            ResetDungeonSession() -- RESET MEMORI SAAT MULAI BARU
            local btn = resultGui.ScreenSettlement.BtnGroup.PlayAgainBtn
            GuiService.SelectedObject = btn
            VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end
    end)
end

-- Loop Utama (Heartbeat)
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon and ScreenGui.Parent then
        HandleResultGui()

        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 1. AUTO SKILL QER
            if tick() - lastSkillTime >= 2.5 then
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
                elseif tick() - noEnemyTimer >= 3 then -- LEBIH CEPAT KE PORTAL
                    -- 4. LOGIKA PORTAL DENGAN MEMORI ( ANTI BOLAK-BALIK )
                    local portalToUse = nil
                    
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent.Name == "Portal" then
                            -- Gunakan posisi X dan Z sebagai ID portal
                            local portalID = math.floor(v.Position.X) .. "_" .. math.floor(v.Position.Z)
                            
                            -- Syarat: Belum pernah dimasuki DAN Jarak > 50 studs (menghindari portal spawn)
                            local dist = (v.Position - hrp.Position).Magnitude
                            if not usedPortals[portalID] and dist > 50 then
                                portalToUse = v
                                break 
                            end
                        end
                    end

                    if portalToUse then
                        -- Masukkan ke blacklist sebelum masuk
                        local pID = math.floor(portalToUse.Position.X) .. "_" .. math.floor(portalToUse.Position.Z)
                        usedPortals[pID] = true
                        
                        -- Instant Teleport
                        hrp.CFrame = portalToUse.CFrame
                        local rf = portalToUse:FindFirstChild("RF")
                        if rf then 
                            rf:InvokeServer()
                            task.wait(1.5) -- Jeda sinkronisasi server
                            noEnemyTimer = tick()
                        end
                    else
                        -- Cadangan: Cari Pintu (F) jika portal tidak ditemukan
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
