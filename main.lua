local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

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

_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local lastSkillTime = 0
local noEnemyTimer = tick()
local spawnPos = nil
local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 6
local portalInProgress = false  -- flag: sedang proses masuk portal

-- Ambil semua portal HANYA dari workspace.RoundDoor yang punya RF
-- Abaikan workspace.World.Portal (portal dunia)
local function GetValidPortals()
    local portals = {}
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then return portals end

    for _, child in ipairs(roundDoor:GetChildren()) do
        -- child bisa: Door, Portal, PortalD
        -- Skip "Door" karena tidak punya RF (pakai tombol F)
        local root = child:FindFirstChild("Root")
        if root then
            local rf = root:FindFirstChildWhichIsA("RemoteFunction")
            if rf then
                -- Ini portal valid (Portal atau PortalD)
                table.insert(portals, {root = root, rf = rf, name = child.Name})
            end
        end
    end
    return portals
end

-- Ambil pintu biasa (pakai tombol F) — child "Door" di RoundDoor
local function GetRoundDoor()
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then return nil end
    local door = roundDoor:FindFirstChild("Door")
    if not door then return nil end
    -- Ambil part apapun dari doorL atau doorR sebagai target teleport
    local doorL = door:FindFirstChild("doorL")
    local part = doorL and doorL:FindFirstChildWhichIsA("BasePart")
    return part
end

local function ResetState()
    noEnemyTimer = tick()
    lastTeleportTime = tick()
    portalInProgress = false
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        spawnPos = Player.Character.HumanoidRootPart.Position
    end
end

local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        portalInProgress = false
        ResetState()
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
                ResetState()
            end
        end
    end)
end

RS.Heartbeat:Connect(function()
    if not _G.AutoDungeon or not ScreenGui.Parent then return end
    if portalInProgress then return end  -- jangan lakukan apapun saat proses portal

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
            for _, v in ipairs(enemyFolder:GetChildren()) do
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
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name:match("Chest") or v.Name == "TreasureChests" then
                    chest = v:FindFirstChild("Root") or v:FindFirstChildWhichIsA("BasePart")
                    if chest then break end
                end
            end

            if chest then
                hrp.CFrame = chest.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)

            elseif tick() - noEnemyTimer >= 6 and tick() - lastTeleportTime >= TELEPORT_COOLDOWN then

                -- 4. CARI PORTAL DI workspace.RoundDoor SAJA
                local portals = GetValidPortals()

                if #portals > 0 then
                    -- Pilih portal terdekat dari player (bukan terjauh dari spawn)
                    -- Karena di RoundDoor semua portal memang untuk next stage
                    local bestPortal = nil
                    local minDist = math.huge

                    for _, p in ipairs(portals) do
                        if p.root and p.root.Parent then
                            local dist = (hrp.Position - p.root.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                bestPortal = p
                            end
                        end
                    end

                    if bestPortal then
                        portalInProgress = true  -- kunci, jangan lakukan hal lain

                        -- Teleport ke portal
                        hrp.CFrame = bestPortal.root.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.3)

                        -- Invoke RF portal
                        pcall(function()
                            bestPortal.rf:InvokeServer()
                        end)

                        -- Tunggu loading stage baru (3 detik)
                        task.wait(3)

                        -- Update posisi setelah masuk stage baru
                        if hrp and hrp.Parent then
                            spawnPos = hrp.Position
                        end

                        lastTeleportTime = tick()
                        noEnemyTimer = tick()
                        portalInProgress = false  -- buka kunci
                    end

                else
                    -- Tidak ada portal di RoundDoor → coba pintu biasa (tombol F)
                    local doorPart = GetRoundDoor()
                    if doorPart then
                        hrp.CFrame = doorPart.CFrame * CFrame.new(0, 0, 3)
                        task.wait(0.2)
                        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.1)
                        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        lastTeleportTime = tick()
                    end
                end
            end
        end
    end)
end)
