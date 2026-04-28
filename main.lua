local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.5, -75, 0.35, -25)
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "ULTIMATE AFK: OFF"
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
local noEnemyTimer = 0 

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoDungeon = not _G.AutoDungeon
    if _G.AutoDungeon then
        ToggleButton.Text = "ULTIMATE AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        noEnemyTimer = tick() 
    else
        ToggleButton.Text = "ULTIMATE AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end
end)

-- Fungsi Skill (Q, E, R)
local function CastSkills()
    local skills = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R}
    for _, key in pairs(skills) do
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, key, false, game)
    end
end

-- Fungsi Mencari Chest
local function FindChest()
    if workspace:FindFirstChild("TreasureChests") then
        local chests = workspace.TreasureChests:GetChildren()
        if #chests > 0 then return chests[1] end
    end
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name:match("Chest%d+") then return v end
    end
    return nil
end

-- Fungsi Mencari Portal secara Dinamis
local function TeleportToPortal()
    local roundDoor = workspace:FindFirstChild("RoundDoor")
    if roundDoor then
        for _, obj in pairs(roundDoor:GetChildren()) do
            -- Mencari objek yang mengandung nama PortalBlue (tidak peduli nomor indeksnya)
            if obj.Name:find("PortalBlue") then
                local portalRoot = obj:FindFirstChild("Root")
                if portalRoot and portalRoot:FindFirstChild("RF") then
                    pcall(function()
                        portalRoot.RF:InvokeServer()
                    end)
                    return true
                end
            end
        end
    end
    return false
end

-- Loop Utama
RunService.Stepped:Connect(function()
    if _G.AutoDungeon then
        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 1. AUTO SKILL (3 Detik)
            if tick() - lastSkillTime >= 3 then
                task.spawn(CastSkills)
                lastSkillTime = tick()
            end

            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            local enemies = enemyFolder and enemyFolder:GetChildren() or {}
            
            local activeEnemy = nil
            for _, enemy in pairs(enemies) do
                local eHum = enemy:FindFirstChild("Humanoid")
                if eHum and eHum.Health > 0 then
                    activeEnemy = enemy
                    break
                end
            end

            if activeEnemy then
                noEnemyTimer = tick() 
                local eHrp = activeEnemy:FindFirstChild("HumanoidRootPart")
                if eHrp then
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.CFrame = eHrp.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    eHrp.Size = Vector3.new(35, 35, 35)
                    eHrp.CanCollide = false
                    game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                end
            else
                -- 2. CEK STUCK TIMER (10 Detik Tanpa Musuh)
                if tick() - noEnemyTimer >= 10 then
                    local success = TeleportToPortal()
                    if success then
                        noEnemyTimer = tick() -- Reset jika berhasil invoke
                    end
                end

                -- 3. CEK CHEST
                local targetChest = FindChest()
                if targetChest then
                    local chestPart = targetChest:FindFirstChild("Root") or targetChest:FindFirstChildWhichIsA("BasePart")
                    if chestPart then
                        hrp.CFrame = chestPart.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                    end
                else
                    -- 4. CEK PINTU (Manual F)
                    local roundDoor = workspace:FindFirstChild("RoundDoor")
                    if roundDoor then
                        -- Mencari Door.Root.LocalRoundDoor secara dinamis
                        for _, d in pairs(roundDoor:GetDescendants()) do
                            if d.Name == "LocalRoundDoor" then
                                hrp.CFrame = d.CFrame * CFrame.new(0, 0, 3)
                                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                task.wait(0.1)
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
