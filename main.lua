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
local isBusy = false

local function HasEnemy()
    local folder = workspace:FindFirstChild("EnemyNpc")
    if not folder then return false end
    for _, v in ipairs(folder:GetChildren()) do
        local hum = v:FindFirstChild("Humanoid")
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then return true end
    end
    return false
end

local function GetEnemy()
    local folder = workspace:FindFirstChild("EnemyNpc")
    if not folder then return nil end
    for _, v in ipairs(folder:GetChildren()) do
        local hum = v:FindFirstChild("Humanoid")
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then return hrp end
    end
    return nil
end

local function SetToggle(state)
    _G.AutoDungeon = state
    if state then
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

-- CARI MUSUH: teleport ke semua portal & door satu per satu
local function DoFindEnemy()
    isBusy = true

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then isBusy = false return end

    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if not roundDoor then isBusy = false return end

    -- Kumpulkan semua target: portal RF + door F
    local targets = {}

    for _, child in ipairs(roundDoor:GetChildren()) do
        local root = child:FindFirstChild("Root")
        if root then
            local rf = root:FindFirstChildWhichIsA("RemoteFunction")
            if rf then
                -- Portal dengan RF
                table.insert(targets, {
                    type = "portal",
                    pos  = root.Position,
                    root = root,
                    rf   = rf,
                    name = child.Name
                })
            end
        else
            -- Door tanpa Root/RF → pakai F
            -- Cari BasePart pertama di dalamnya
            for _, desc in ipairs(child:GetDescendants()) do
                if desc:IsA("BasePart") then
                    table.insert(targets, {
                        type = "door",
                        pos  = desc.Position,
                        part = desc,
                        name = child.Name
                    })
                    break
                end
            end
        end
    end

    print("Total target ditemukan: " .. #targets)

    for i, t in ipairs(targets) do
        if not _G.AutoDungeon then break end
        if HasEnemy() then break end

        ToggleButton.Text = t.name .. " (" .. i .. "/" .. #targets .. ")"
        print("Mencoba: " .. t.name .. " | type: " .. t.type)

        if t.type == "portal" then
            -- Teleport tepat ke Root portal
            hrp.CFrame = CFrame.new(t.pos + Vector3.new(0, 4, 0))
            task.wait(0.5)

            -- Invoke RF
            pcall(function()
                t.rf:InvokeServer()
            end)
            task.wait(3) -- tunggu loading stage

            -- Cek musuh
            if HasEnemy() then
                print("MUSUH DITEMUKAN di " .. t.name)
                break
            end

        elseif t.type == "door" then
            -- Teleport ke depan pintu
            hrp.CFrame = CFrame.new(t.pos + Vector3.new(0, 4, 3))
            task.wait(0.5)

            -- Tekan F berkali-kali
            for _ = 1, 8 do
                if not _G.AutoDungeon then break end
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.2)
            end
            task.wait(2)

            if HasEnemy() then
                print("MUSUH DITEMUKAN lewat door F")
                break
            end
        end
    end

    lastTeleportTime = tick()
    noEnemyTimer = tick()
    isBusy = false

    if _G.AutoDungeon and ScreenGui.Parent then
        ToggleButton.Text = "ULTIMATE AFK: ON"
    end
end

-- LOOP UTAMA
RS.Heartbeat:Connect(function()
    if not _G.AutoDungeon or not ScreenGui.Parent then return end
    if isBusy then return end

    HandleResultGui()

    pcall(function()
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        -- 1. AUTO SKILL Q E R
        if tick() - lastSkillTime >= 3 then
            for _, key in ipairs({"Q", "E", "R"}) do
                VIM:SendKeyEvent(true, key, false, game)
                task.wait(0.02)
                VIM:SendKeyEvent(false, key, false, game)
            end
            lastSkillTime = tick()
        end

        -- 2. ADA MUSUH → SERANG
        local enemy = GetEnemy()
        if enemy then
            noEnemyTimer = tick()
            hrp.Velocity    = Vector3.new(0, 0, 0)
            hrp.CFrame      = enemy.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            enemy.Size      = Vector3.new(40, 40, 40)
            enemy.CanCollide = false
            game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            return
        end

        -- 3. CEK CHEST
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:match("Chest") or v.Name == "TreasureChests" then
                local chest = v:FindFirstChild("Root") or v:FindFirstChildWhichIsA("BasePart")
                if chest then
                    hrp.CFrame = chest.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                    return
                end
            end
        end

        -- 4. TIDAK ADA MUSUH → CARI PORTAL/DOOR
        if tick() - noEnemyTimer >= 5 and tick() - lastTeleportTime >= 5 then
            task.spawn(DoFindEnemy)
        end
    end)
end)
