-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Remote Definitions
-- Menggunakan FindFirstChild/WaitForChild dengan aman untuk menghindari error jika path belum ter-load sepenuhnya
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local ActionRemote = NetFolder:WaitForChild("RE/ActionRemote")
local SkillRemote = NetFolder:WaitForChild("RE/SkillRemote")

-- State Variables
local getgenv = getgenv or function() return _G end
getgenv().AutoFarmMob = false
getgenv().AutoFarmBoss = false
getgenv().SelectedMob = nil
getgenv().SelectedBoss = nil

-- Skill States
getgenv().AutoM1 = false
getgenv().AutoZ = false
getgenv().AutoX = false
getgenv().AutoC = false

local DistanceOffset = CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(-90), 0, 0) -- Posisi aman: 8 stud di atas musuh, menghadap ke bawah

-- Utility Functions
local function GetEnemiesList()
    local enemies = {}
    local added = {}
    if Workspace:FindFirstChild("Enemies") then
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not added[v.Name] then
                table.insert(enemies, v.Name)
                added[v.Name] = true
            end
        end
    end
    return enemies
end

local function GetBossList()
    local bosses = {}
    local added = {}
    if Workspace:FindFirstChild("Boss") then
        for _, v in pairs(Workspace.Boss:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not added[v.Name] then
                table.insert(bosses, v.Name)
                added[v.Name] = true
            end
        end
    end
    return bosses
end

local function GetTarget(folderName, targetName)
    local folder = Workspace:FindFirstChild(folderName)
    if folder then
        for _, v in pairs(folder:GetChildren()) do
            if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                return v
            end
        end
    end
    return nil
end

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm Hub | Arceus X",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Professional Logic",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

-- ================= TABS ================= --
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local SkillTab = Window:CreateTab("Auto Skills", 4483362458)

-- ================= FARM TAB ================= --
local MobDropdown = FarmTab:CreateDropdown({
   Name = "Pilih Musuh Biasa",
   Options = GetEnemiesList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "MobDrop",
   Callback = function(Option)
        getgenv().SelectedMob = Option[1]
   end,
})

FarmTab:CreateButton({
   Name = "Refresh Daftar Musuh",
   Callback = function()
        MobDropdown:Refresh(GetEnemiesList())
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm Mob",
   CurrentValue = false,
   Flag = "ToggleMob",
   Callback = function(Value)
        getgenv().AutoFarmMob = Value
   end,
})

FarmTab:CreateDivider()

local BossDropdown = FarmTab:CreateDropdown({
   Name = "Pilih Boss",
   Options = GetBossList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "BossDrop",
   Callback = function(Option)
        getgenv().SelectedBoss = Option[1]
   end,
})

FarmTab:CreateButton({
   Name = "Refresh Daftar Boss",
   Callback = function()
        BossDropdown:Refresh(GetBossList())
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm Boss",
   CurrentValue = false,
   Flag = "ToggleBoss",
   Callback = function(Value)
        getgenv().AutoFarmBoss = Value
   end,
})

-- ================= SKILL TAB ================= --
SkillTab:CreateLabel("Pilih aksi yang ingin di-loop:")

SkillTab:CreateToggle({
   Name = "Auto M1 (Basic Attack)",
   CurrentValue = false,
   Flag = "TogM1",
   Callback = function(Value) getgenv().AutoM1 = Value end,
})

SkillTab:CreateToggle({
   Name = "Auto Skill Z",
   CurrentValue = false,
   Flag = "TogZ",
   Callback = function(Value) getgenv().AutoZ = Value end,
})

SkillTab:CreateToggle({
   Name = "Auto Skill X",
   CurrentValue = false,
   Flag = "TogX",
   Callback = function(Value) getgenv().AutoX = Value end,
})

SkillTab:CreateToggle({
   Name = "Auto Skill C",
   CurrentValue = false,
   Flag = "TogC",
   Callback = function(Value) getgenv().AutoC = Value end,
})

-- ================= CORE LOGIC ================= --

-- 1. Teleport & CFrame Hold Loop
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local target = nil

    if getgenv().AutoFarmBoss and getgenv().SelectedBoss then
        target = GetTarget("Boss", getgenv().SelectedBoss)
    elseif getgenv().AutoFarmMob and getgenv().SelectedMob then
        target = GetTarget("Enemies", getgenv().SelectedMob)
    end

    if target and target:FindFirstChild("HumanoidRootPart") then
        -- Menahan posisi di atas target agar tidak terkena hit
        hrp.CFrame = target.HumanoidRootPart.CFrame * DistanceOffset
        
        -- Mencegah karakter jatuh/terpental akibat fisika game
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end
end)

-- 2. Skills & Action Firing Loop
-- Dipisah ke task.spawn agar interval (wait) tidak mengganggu mulusnya teleportasi Heartbeat
task.spawn(function()
    while true do
        task.wait(0.1) -- Jeda aman agar tidak terkena limit server (Kick)
        
        -- Hanya menembakkan remote jika salah satu auto farm sedang aktif
        if getgenv().AutoFarmMob or getgenv().AutoFarmBoss then
            
            -- Catatan: "Light" bisa diganti secara dinamis jika senjata berubah, 
            -- untuk saat ini disesuaikan dengan permintaan.
            
            if getgenv().AutoM1 then
                pcall(function() ActionRemote:FireServer("M1", "Light") end)
            end
            
            if getgenv().AutoZ then
                pcall(function() SkillRemote:FireServer("Light", "Z") end)
            end
            
            if getgenv().AutoX then
                pcall(function() SkillRemote:FireServer("Light", "X") end)
            end
            
            if getgenv().AutoC then
                pcall(function() SkillRemote:FireServer("Light", "C") end)
            end
            
        end
    end
end)

Rayfield:Notify({
    Title = "Script Siap",
    Content = "Logika sistem dimuat. Pastikan Anda telah me-refresh dropdown musuh sebelum memulai.",
    Duration = 5,
    Image = 4483362458,
})
