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
local isBusy = false  -- sedang proses portal/door

local function HasEnemy()
    local enemyFolder = workspace:FindFirstChild("EnemyNpc")
    if not enemyFolder then return false end
    for _, v in ipairs(enemyFolder:GetChildren()) do
        local hum = v:FindFirstChild("Humanoid")
        local eHrp = v:FindFirstChild("HumanoidRootPart")
        if hum and eHrp and hum.Health > 0 then
            return true
        end
    end
    return false
end

local function GetEnemy()
    local enemyFolder = workspace:FindFirstChild("EnemyNpc")
    if not enemyFolder then return nil end
    for _, v in ipairs(enemyFolder:GetChildren()) do
        local hum = v:FindFirstChild("Humanoid")
        local eHrp = v:FindFirstChild("HumanoidRootPart")
        if hum and eHrp and hum.Health > 0 then
            return eHrp
        end
    end
    return nil
end

-- Kumpulkan semua portal di RoundDoor yang punya RF
local function GetAllPortals()
    local list = {}
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then return list end
    for _, child in ipairs(roundDoor:GetChildren()) do
        local root = child:FindFirstChild("Root")
        if root then
            local rf = root:FindFirstChildWhichIsA("RemoteFunction")
            if rf then
                table.insert(list, {root = root, rf = rf, name = child.Name})
            end
        end
    end
    return list
end

-- Kumpulkan semua door F (tidak punya RF)
local function GetAllDoors()
    local list = {}
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then return list end
    for _, child in ipairs(roundDoor:GetChildren()) do
        if not child:FindFirstChild("Root") or not child:FindFirstChild("Root"):FindFirstChildWhichIsA("RemoteFunction") then
            -- Cari semua BasePart di dalamnya
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(list, part)
                    break
                end
            end
        end
    end
    return list
end

local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
        lastTeleportTime = tick()
        isBusy = false
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        isBusy = false
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
                isBusy = false
                noEnemyTimer = tick()
                lastTeleportTime = tick()
            end
        end
    end)
end

-- PROSES UTAMA: teleport ke semua portal satu per satu sampai ketemu musuh
local function DoFindEnemy()
    isBusy = true
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then isBusy = false return end

    -- Coba semua portal RF dulu
    local portals = GetAllPortals()
    ToggleButton.Text = "SCAN " .. #portals .. " PORTAL..."

    for i, p in ipairs(portals) do
        if not _G.AutoDungeon then break end
        if HasEnemy() then break end

        if p.root and p.root.Parent then
            ToggleButton.Text = "PORTAL " .. i .. "/" .. #portals

            -- Teleport ke portal
            hrp.CFrame = p.root.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.3)

            -- Invoke RF
            pcall(function() p.rf:InvokeServer() end)
            task.wait(2)  -- tunggu efek portal

            -- Cek musuh setelah masuk
            if HasEnemy() then
                ToggleButton.Text = "MUSUH DITEMUKAN!"
                break
            end

            task.wait(0.5)
        end
    end

    -- Kalau masih belum ada musuh, coba door F
    if not HasEnemy() then
        local doors = GetAllDoors()
        for i, doorPart in ipairs(doors) do
            if not _G.AutoDungeon then break end
            if HasEnemy() then break end

            ToggleButton.Text = "DOOR F " .. i .. "/" .. #doors

            hrp.CFrame = doorPart.CFrame * CFrame.new(0, 3, 3)
            task.wait(0.3)

            -- Tekan F
            for _ = 1, 5 do
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.2)
            end

            task.wait(2)
            if HasEnemy() then
                ToggleButton.Text = "MUSUH DITEMUKAN!"
                break
            end
        end
    end

    lastTeleportTime = tick()
    noEnemyTimer = tick()
    isBusy = false

    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
    end
end

-- Loop Utama
RS.Heartbeat:Connect(function()
    if not _G.AutoDungeon or not ScreenGui.Parent then return end
    if isBusy then return end

    HandleResultGui()

    pcall(function()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChild("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then return end

        -- 1. AUTO SKILL
        if tick() - lastSkillTime >= 3 then
            for _, key in pairs({"Q", "E", "R"}) do
                VIM:SendKeyEvent(true, key, false, game)
                task.wait(0.02)
                VIM:SendKeyEvent(false, key, false, game)
            end
            lastSkillTime = tick()
        end

        -- 2. ADA MUSUH → SERANG
        local targetEnemy = GetEnemy()
        if targetEnemy then
            noEnemyTimer = tick()
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.CFrame = targetEnemy.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            targetEnemy.Size = Vector3.new(40, 40, 40)
            targetEnemy.CanCollide = false
            game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            return
        end

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
            return
        end

        -- 4. TIDAK ADA MUSUH & TIDAK ADA CHEST → CARI PORTAL
        if tick() - noEnemyTimer >= 5 and tick() - lastTeleportTime >= 5 then
            task.spawn(DoFindEnemy)
        end
    end)
end)
