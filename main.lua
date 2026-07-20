-- Memuat Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ God Speed Farm",
   LoadingTitle = "Memuat Optimasi...",
   LoadingSubtitle = "No Lag Edition",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Auto Farm", 4483362458) 

-- Variabel Kontrol
getgenv().autoFarmEnabled = false

-- ==========================================
-- ⚙️ TAHAP OPTIMASI MEMORI & SPEED
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Referensi Event
local remoteEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")

-- 1. Caching fungsi FireServer secara lokal (jauh lebih cepat dari pemanggilan normal)
local fireServer = remoteEvent.FireServer 

-- 2. Pre-generate Array Argumen (Mencegah lag akibat pembuatan tabel berulang di dalam loop)
local upgradeArgsList = {}
for i = 1, 43 do
    upgradeArgsList[i] = {2, "RequestUpgrade", "ground_upg" .. i, "max"}
end

local prestigeArgs = {2, "RequestPrestige", "Awakening"}

-- Caching Heartbeat untuk jeda waktu per frame
local heartbeat = RunService.Heartbeat 
-- ==========================================

local function startGodSpeedFarm()
    task.spawn(function()
        while getgenv().autoFarmEnabled do
            
            -- Tembakkan request 1-43 SEKETIKA tanpa jeda di antaranya
            for i = 1, 43 do
                fireServer(remoteEvent, unpack(upgradeArgsList[i]))
            end
            
            -- Langsung tembakkan Prestige
            fireServer(remoteEvent, unpack(prestigeArgs))
            
            -- Jeda secepat kilat (1 Frame Server / ~0.016 detik)
            -- Ini mencegah Client Crash dan Network Lag tanpa mengurangi kecepatan
            heartbeat:Wait() 
        end
    end)
end

-- UI Toggle
Tab:CreateToggle({
   Name = "⚡ Auto Farm (Max Speed)",
   CurrentValue = false,
   Flag = "GodSpeedToggle",
   Callback = function(Value)
       getgenv().autoFarmEnabled = Value
       if Value then
           startGodSpeedFarm()
       end
   end,
})

Rayfield:Notify({
   Title = "Optimasi Berhasil",
   Content = "Skrip berjalan di kecepatan penuh tanpa membebani memori.",
   Duration = 3,
   Image = 4483362458,
})
