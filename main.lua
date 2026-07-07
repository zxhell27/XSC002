-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager") 

local LocalPlayer = Players.LocalPlayer

-- ================= FITUR: AUTO TEKAN 2 SAAT RESPAWN ================= --
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(3) -- Tunggu 3 detik setelah respawn
    -- Menyimulasikan menekan tombol 2 (Equip)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
end)
-- ======================================================================= --

-- Remote Definitions
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local ActionRemote = NetFolder:WaitForChild("RE/ActionRemote")
local SkillRemote = NetFolder:WaitForChild("RE/SkillRemote")

-- State Variables
local getgenv = getgenv or function() return _G end
getgenv().AutoFarmMob = false
getgenv().AutoFarmBoss = false
getgenv().BringMobs = false
getgenv().SelectedMob = nil
getgenv().SelectedBoss = nil

-- Variabel global untuk menyimpan target utama
getgenv().CurrentMainTarget = nil

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
    if Workspace:FindFirstChild("Boss") then
        local bossFolders = {
            Workspace.Boss:FindFirstChild("BossSummoner"),
            Workspace.Boss:FindFirstChild("ServerTimeBossSpawner"),
            Workspace.Boss:FindFirstChild("JJKBossSummoner"),
            Workspace.Boss:FindFirstChild("ShinjukuSummoner")
        }
        
        for _, folder in pairs(bossFolders) do
            if folder then
                for _, bossModel in pairs(folder:GetChildren()) do
                    if bossModel:IsA("Model") and bossModel:FindFirstChild("Humanoid") and not added[bossModel.Name] then
                        table.insert(bosses, bossModel.Name)
                        added[bossModel.Name] = true
                    end
                end
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
    if Workspace:FindFirstChild("Boss") then
        local bossFolders = {
            Workspace.Boss:FindFirstChild("BossSummoner"),
            Workspace.Boss:FindFirstChild("ServerTimeBossSpawner"),
            Workspace.Boss:FindFirstChild("JJKBossSummoner"),
            Workspace.Boss:FindFirstChild("ShinjukuSummoner")
        }

        for _, folder in pairs(bossFolders) do
            if folder then
                local boss = folder:FindFirstChild(targetName)
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
                    return boss
                end
            end
        end
    end
    return nil
end

-- ================= RAYFIELD UI SETUP ================= --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm Hub | Boss M1 Fix",
   LoadingTitle = "Memuat Logika targeting...",
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
    
    getgenv().CurrentMainTarget = nil

    -- 1. PRIORITAS UTAMA: Cari Boss Terlebih Dahulu
    if getgenv().AutoFarmBoss and getgenv().SelectedBoss then
        target = GetTargetBoss(getgenv().SelectedBoss)
    end

    -- 2. PRIORITAS KEDUA: Lanjut ke Mob
    if not target and getgenv().AutoFarmMob and getgenv().SelectedMob then
        target = GetTargetMob(getgenv().SelectedMob)
    end

    if target and target:FindFirstChild("HumanoidRootPart") then
        getgenv().CurrentMainTarget = target
        
        hrp.CFrame = target.HumanoidRootPart.CFrame * DistanceOffset
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        if getgenv().BringMobs and getgenv().AutoFarmMob then
            if Workspace:FindFirstChild("Enemies") then
                for _, parentObj in pairs(Workspace.Enemies:GetChildren()) do
                    for _, enemy in pairs(parentObj:GetChildren()) do
                        if enemy.Name == getgenv().SelectedMob and enemy ~= target then
                            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                                enemy.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
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

-- ================= LOOP PENYERANGAN (DIPERBARUI) ================= --
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if (getgenv().AutoFarmMob or getgenv().AutoFarmBoss) and getgenv().CurrentMainTarget then
            local currentTarget = getgenv().CurrentMainTarget
            
            -- PERBAIKAN: Memisahkan pcall dan menambahkan bypass serangan tool/mouse
            if getgenv().AutoM1 then 
                -- Tembak remote bawaan
                pcall(function() ActionRemote:FireServer("M1", "Light", currentTarget) end)
                
                -- Backup 1: Paksa ayunan senjata (Paling efektif jika remote mem-blokir target Boss)
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end)
                
                -- Backup 2: Memicu raw virtual click
                if mouse1click then pcall(function() mouse1click() end) end
            end
            
            -- Skill dieksekusi secara terpisah agar saling tidak mengganggu jika ada error remote
            if getgenv().AutoZ then pcall(function() SkillRemote:FireServer("Light", "Z", currentTarget) end) end
            if getgenv().AutoX then pcall(function() SkillRemote:FireServer("Light", "X", currentTarget) end) end
            if getgenv().AutoC then pcall(function() SkillRemote:FireServer("Light", "C", currentTarget) end) end
        end
    end
end)

Rayfield:Notify({
    Title = "Auto M1 Fix Diterapkan",
    Content = "Bypass serangan Boss telah ditambahkan ke sistem M1.",
    Duration = 5,
    Image = 4483362458,
})
