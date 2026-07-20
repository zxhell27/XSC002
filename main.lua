-- Memuat Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ God Speed Farm V2",
   LoadingTitle = "Memuat Bypass Error...",
   LoadingSubtitle = "Auto Reconnect Edition",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Auto Farm", 4483362458) 

-- Variabel Kontrol
getgenv().autoFarmEnabled = false

-- ==========================================
-- ⚙️ PERSIAPAN DATA (PRE-CACHING)
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat 

-- Siapkan argumen di awal agar tidak lag
local upgradeArgsList = {}
for i = 1, 43 do
    upgradeArgsList[i] = {2, "RequestUpgrade", "ground_upg" .. i, "max"}
end
local prestigeArgs = {2, "RequestPrestige", "Awakening"}
-- ==========================================

local function startGodSpeedFarm()
    task.spawn(function()
        while getgenv().autoFarmEnabled do
            
            -- Menggunakan pcall (Protected Call) agar jika Remote hilang, skrip tidak mati/error
            local success, err = pcall(function()
                -- Cari ulang Remote Event agar selalu mendapatkan data terbaru setelah Prestige
                local remoteFolder = ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents")
                if remoteFolder then
                    local remoteEvent = remoteFolder:FindFirstChild("Replica_ReplicaSignal")
                    
                    if remoteEvent then
                        -- Tembakkan request 1-43 SEKETIKA
                        for i = 1, 43 do
                            remoteEvent:FireServer(unpack(upgradeArgsList[i]))
                        end
                        
                        -- Tembakkan Prestige
                        remoteEvent:FireServer(unpack(prestigeArgs))
                    end
                end
            end)
            
            -- Jika gagal (misal saat proses Prestige game sedang me-loading ulang folder Remote)
            if not success then
                -- Jeda sebentar agar server punya waktu untuk memunculkan kembali RemoteEvent
                task.wait(1) 
            else
                -- Jika sukses, tetap jalan di kecepatan maksimal (1 Frame)
                heartbeat:Wait() 
            end
            
        end
    end)
end

-- UI Toggle
Tab:CreateToggle({
   Name = "⚡ Auto Farm (Anti-Error)",
   CurrentValue = false,
   Flag = "GodSpeedToggleV2",
   Callback = function(Value)
       getgenv().autoFarmEnabled = Value
       if Value then
           startGodSpeedFarm()
       end
   end,
})

Rayfield:Notify({
   Title = "V2 Berhasil Dimuat!",
   Content = "Kebal dari error saat Prestige. Skrip akan otomatis mencari Remote baru jika hilang.",
   Duration = 5,
   Image = 4483362458,
})
