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
local lastTeleportTime = 0
local portalInProgress = false

-- Fungsi jalan ke posisi, tunggu sampai dekat atau timeout
local function WalkTo(hrp, humanoid, targetPos, timeout, stopDist)
    stopDist = stopDist or 5
    timeout = timeout or 10
    humanoid:MoveTo(targetPos)
    local startTime = tick()
    while tick() - startTime < timeout do
        if not hrp or not hrp.Parent then break end
        local dist = (hrp.Position - targetPos).Magnitude
        if dist <= stopDist then break end
        -- Refresh MoveTo setiap 1 detik supaya tidak berhenti sendiri
        if (tick() - startTime) % 1 < 0.05 then
            humanoid:MoveTo(targetPos)
        end
        task.wait(0.1)
    end
end

-- Fungsi tekan tombol F berkali-kali sambil di depan pintu
local function PressF(times, interval)
    times = times or 5
    interval = interval or 0.3
    for i = 1, times do
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        task.wait(interval)
    end
end

-- Cari semua portal RF di RoundDoor
local function GetValidPortals()
    local portals = {}
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then return portals end
    for _, child in ipairs(roundDoor:GetChildren()) do
        local root = child:FindFirstChild("Root")
        if root then
            local rf = root:FindFirstChildWhichIsA("RemoteFunction")
            if rf then
                table.insert(portals, {root = root, rf = rf, name = child.Name})
            end
        end
    end
    return portals
end

-- Cari part pintu F (doorL/doorR di RoundDoor.Door)
local function GetDoorFPart()
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then return nil end
    local door = roundDoor:FindFirstChild("Door")
    if not door then return nil end
    -- Coba ambil part dari doorL atau doorR
    for _, sub in ipairs(door:GetChildren()) do
        local part = sub:FindFirstChildWhichIsA("BasePart")
        if part then return part end
    end
    -- Fallback: ambil langsung BasePart di Door
    return door:FindFirstChildWhichIsA("BasePart")
end

local function ResetState()
    noEnemyTimer = tick()
    lastTeleportTime = tick()
    portalInProgress = false
end

local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ResetState()
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        portalInProgress = false
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
                task.wait(0.05)
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

-- Proses masuk portal RF (Portal/PortalD)
local function DoPortal(hrp, humanoid, portalData)
    portalInProgress = true
    ToggleButton.Text = "MENUJU PORTAL..."

    -- Jalan ke dekat portal dulu
    local targetPos = portalData.root.Position
    WalkTo(hrp, humanoid, targetPos, 12, 6)
    task.wait(0.3)

    -- Invoke RF
    pcall(function()
        portalData.rf:InvokeServer()
    end)

    -- Tunggu stage baru load
    ToggleButton.Text = "LOADING STAGE..."
    task.wait(4)

    ResetState()
    ToggleButton.Text = "ULTIMATE AFK: ON"
end

-- Proses masuk pintu F
local function DoDoorF(hrp, humanoid)
    portalInProgress = true
    ToggleButton.Text = "MENUJU PINTU..."

    local doorPart = GetDoorFPart()
    if not doorPart then
        portalInProgress = false
        return
    end

    local doorPos = doorPart.Position

    -- Jalan ke depan pintu (offset 4 studs)
    local approachPos = doorPos + Vector3.new(0, 0, 4)
    WalkTo(hrp, humanoid, approachPos, 15, 3)
    task.wait(0.3)

    -- Posisi tepat di depan pintu
    humanoid:MoveTo(doorPos)
    task.wait(0.5)

    -- Tekan F beberapa kali
    ToggleButton.Text = "TEKAN F..."
    PressF(8, 0.25)

    -- Tunggu transisi/loading
    ToggleButton.Text = "LOADING..."
    task.wait(3)

    -- Cek apakah sudah pindah (posisi berubah jauh dari pintu)
    if hrp and hrp.Parent then
        local distFromDoor = (hrp.Position - doorPos).Magnitude
        if distFromDoor < 10 then
            -- Belum pindah, coba sekali lagi
            humanoid:MoveTo(doorPos)
            task.wait(0.3)
            PressF(5, 0.2)
            task.wait(2)
        end
    end

    ResetState()
    ToggleButton.Text = "ULTIMATE AFK: ON"
end

-- Loop utama
RS.Heartbeat:Connect(function()
    if not _G.AutoDungeon or not ScreenGui.Parent then return end
    if portalInProgress then return end

    HandleResultGui()

    pcall(function()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChild("Humanoid")
        if not hrp or not humanoid then return end
        if humanoid.Health <= 0 then return end

        -- 1. AUTO SKILL
        if tick() - lastSkillTime >= 3 then
            for _, key in pairs({"Q", "E", "R"}) do
                VIM:SendKeyEvent(true, key, false, game)
                task.wait(0.02)
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
            -- Serang musuh
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

            elseif tick() - noEnemyTimer >= 6 and tick() - lastTeleportTime >= 6 then

                -- 4. CEK PORTAL RF DULU (Portal / PortalD)
                local portals = GetValidPortals()

                if #portals > 0 then
                    -- Ambil portal terdekat
                    local best = nil
                    local minDist = math.huge
                    for _, p in ipairs(portals) do
                        if p.root and p.root.Parent then
                            local d = (hrp.Position - p.root.Position).Magnitude
                            if d < minDist then
                                minDist = d
                                best = p
                            end
                        end
                    end

                    if best then
                        task.spawn(function()
                            DoPortal(hrp, humanoid, best)
                        end)
                    end

                else
                    -- 5. TIDAK ADA PORTAL → JALAN KE PINTU F
                    task.spawn(function()
                        DoDoorF(hrp, humanoid)
                    end)
                end
            end
        end
    end)
end)
