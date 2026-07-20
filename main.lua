-- Memuat Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Membuat Window UI
local Window = Rayfield:CreateWindow({
   Name = "Auto Upgrade & Prestige",
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "Arceus X / Executor",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Membuat Tab Main
local Tab = Window:CreateTab("Auto Farm", 4483362458) 

-- Variabel kontrol untuk loop
getgenv().autoFarmEnabled = false

-- Referensi ke Remote Event (ditaruh di luar loop agar lebih optimal)
local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")

-- Fungsi utama untuk otomatisasi
local function startAutoFarm()
    task.spawn(function()
        while getgenv().autoFarmEnabled do
            -- 1. Loop Upgrade dari ground_upg1 sampai ground_upg43
            for i = 1, 43 do
                -- Cek jika toggle dimatikan di tengah-tengah proses
                if not getgenv().autoFarmEnabled then break end 
                
                local upgradeArgs = {
                    2,
                    "RequestUpgrade",
                    "ground_upg" .. tostring(i),
                    "max"
                }
                
                -- Eksekusi RemoteEvent Upgrade
                remoteEvent:FireServer(unpack(upgradeArgs))
                
                -- Jeda sangat singkat untuk mencegah crash/kick karena spam remote
                task.wait(0.05) 
            end
            
            -- Cek ulang sebelum melakukan prestige
            if not getgenv().autoFarmEnabled then break end

            -- 2. Eksekusi Prestige / Awakening setelah mencapai 43
            local prestigeArgs = {
                2,
                "RequestPrestige",
                "Awakening"
            }
            remoteEvent:FireServer(unpack(prestigeArgs))
            
            -- Jeda 1 detik setelah prestige memberi waktu server memproses sebelum reset loop
            task.wait(1) 
        end
    end)
end

-- Membuat Toggle On/Off di dalam UI
Tab:CreateToggle({
   Name = "Auto Upgrade 1-43 & Awakening",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       getgenv().autoFarmEnabled = Value
       if Value then
           -- Jika On, jalankan fungsi
           startAutoFarm()
       end
   end,
})

-- Notifikasi bahwa script berhasil dimuat
Rayfield:Notify({
   Title = "Script Ready!",
   Content = "Toggle auto farm di menu untuk memulai.",
   Duration = 5,
   Image = 4483362458,
})
