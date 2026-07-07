-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Remote Definitions
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local ActionRemote = NetFolder:WaitForChild("RE/ActionRemote")
local SkillRemote = NetFolder:WaitForChild("RE/SkillRemote")

-- State Variables
local getgenv = getgenv or function() return _G end
getgenv().AutoFarmMob = false
getgenv().AutoFarmBoss = false
getgenv().BringMobs = false -- Variabel baru untuk fitur narik musuh
getgenv().SelectedMob = nil
getgenv().SelectedBoss = nil

-- Skill States
getgenv().AutoM1 = false
getgenv().AutoZ = false
getgenv().AutoX = false
getgenv().AutoC = false

local DistanceOffset = CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(-90), 0, 0)

-- ================= DETECTIONS UTILITIES ================= --

local function GetEnemiesList()
    local enemies = {}
    local added = {}
    if Workspace:FindFirstChild("Enemies") then
        for _, parentObj in pairs(Workspace.Enemies:GetChildren()) do
            for _, enemyModel in pairs(parentObj:GetChildren()) do
                if enemyModel:IsA("Model") and enemyModel:FindFirstChild("Humanoid") and not added[enemyModel.Name] then
                    table.insert(enemies, enemyModel.Name)
                    added[enemyModel.Name] = true
                end
            end
        end
    end
    return enemies
end

local function GetBossList()
    local bosses = {}
    local added = {}
    if Workspace:FindFirstChild("Boss") and Workspace.Boss:FindFirstChild("BossSummoner") then
        for _, bossModel in pairs(Workspace.Boss.BossSummoner:GetChildren()) do
            if bossModel:IsA("Model") and bossModel:FindFirstChild("Humanoid") and not added[bossModel.Name] then
                table.insert(bosses, bossModel.Name)
                added[bossModel.Name] = true
            end
        end
    end
    return bosses
end

local function GetTargetMob(targetName)
    if Workspace:FindFirstChild("Enemies") then
        for _, parentObj in pairs(Workspace.Enemies:GetChildren()) do
            local enemy = parentObj:FindFirstChild(targetName)
            if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                return enemy
            end
        end
    end
    return nil
end

local function GetTargetBoss(targetName)
    if Workspace:FindFirstChild("Boss") and Workspace.Boss:FindFirstChild("BossSummoner") then
        local boss = Workspace.Boss.BossSummoner:FindFirstChild(targetName)
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
            return boss
        end
    end
    return nil
end

-- ================= RAYFIELD UI SETUP ================= --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm Hub | Magnet Edition",
   LoadingTitle = "Memuat Fitur Magnet...",
   LoadingSubtitle = "Arceus X Edition",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local SkillTab = Window:CreateTab("Auto Skills", 4483362458)

-- Mob Setup
local MobDropdown = FarmTab:CreateDropdown({
   Name = "Pilih Musuh Biasa",
   Options = GetEnemiesList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "MobDrop",
   Callback = function(Option) getgenv().SelectedMob = Option[1] end,
})

FarmTab:CreateButton({
   Name = "Refresh Daftar Musuh",
   Callback = function() MobDropdown:Refresh(GetEnemiesList()) end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm Mob",
   CurrentValue = false,
   Flag = "ToggleMob",
   Callback = function(Value) getgenv().AutoFarmMob = Value end,
})

-- FITUR BARU: BRING MOBS
FarmTab:CreateToggle({
   Name = "Kumpulkan Musuh (Bring Mobs)",
   CurrentValue = false,
   Flag = "ToggleBring",
   Callback = function(Value) getgenv().BringMobs = Value end,
})

FarmTab:CreateDivider()

-- Boss Setup
local BossDropdown = FarmTab:CreateDropdown({
   Name = "Pilih Boss",
   Options = GetBossList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "BossDrop",
   Callback = function(Option) getgenv().SelectedBoss = Option[1] end,
})

FarmTab:CreateButton({
   Name = "Refresh Daftar Boss",
   Callback = function() BossDropdown:Refresh(GetBossList()) end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm Boss",
   CurrentValue = false,
   Flag = "ToggleBoss",
   Callback = function(Value) getgenv().AutoFarmBoss = Value end,
})

-- Skills Setup
SkillTab:CreateLabel("Pilih aksi/skill untuk looping:")
SkillTab:CreateToggle({ Name = "Auto M1 (Basic)", CurrentValue = false, Callback = function(v) getgenv().AutoM1 = v end })
SkillTab:CreateToggle({ Name = "Auto Skill Z", CurrentValue = false, Callback = function(v) getgenv().AutoZ = v end })
SkillTab:CreateToggle({ Name = "Auto Skill X", CurrentValue = false, Callback = function(v) getgenv().AutoX = v end })
SkillTab:CreateToggle({ Name = "Auto Skill C", CurrentValue = false, Callback = function(v) getgenv().AutoC = v end })

-- ================= CORE TELEPORT, MAGNET & ATTACK LOGIC ================= --

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local target = nil

    if getgenv().AutoFarmBoss and getgenv().SelectedBoss then
        target = GetTargetBoss(getgenv().SelectedBoss)
    elseif getgenv().AutoFarmMob and getgenv().SelectedMob then
        target = GetTargetMob(getgenv().SelectedMob)
    end

    if target and target:FindFirstChild("HumanoidRootPart") then
        -- 1. Kunci posisi player di atas target
        hrp.CFrame = target.HumanoidRootPart.CFrame * DistanceOffset
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        -- 2. Logika Bring Mobs (Menarik musuh lain)
        if getgenv().BringMobs and getgenv().AutoFarmMob then
            if Workspace:FindFirstChild("Enemies") then
                for _, parentObj in pairs(Workspace.Enemies:GetChildren()) do
                    for _, enemy in pairs(parentObj:GetChildren()) do
                        -- Mengecek apakah nama sama, masih hidup, dan BUKAN target utama
                        if enemy.Name == getgenv().SelectedMob and enemy ~= target then
                            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                                
                                -- Pindahkan musuh lain persis ke posisi target utama yang sedang diserang
                                enemy.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                                
                                -- Hilangkan daya pantul/lemparan (Velocity) agar musuh menumpuk dengan rapi
                                enemy.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                                enemy.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                                
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Loop Pengiriman Remote Event
task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().AutoFarmMob or getgenv().AutoFarmBoss then
            if getgenv().AutoM1 then pcall(function() ActionRemote:FireServer("M1", "Light") end) end
            if getgenv().AutoZ then pcall(function() SkillRemote:FireServer("Light", "Z") end) end
            if getgenv().AutoX then pcall(function() SkillRemote:FireServer("Light", "X") end) end
            if getgenv().AutoC then pcall(function() SkillRemote:FireServer("Light", "C") end) end
        end
    end
end)

Rayfield:Notify({
    Title = "Bring Mobs Aktif",
    Content = "Tambahan fitur 'Kumpulkan Musuh' berhasil dimuat.",
    Duration = 5,
    Image = 4483362458,
})
