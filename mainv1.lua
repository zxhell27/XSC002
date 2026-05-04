-- SKRIP AUTO-FARM TREASURE (TANPA UI - LANGSUNG JALAN)
print("Skrip dimulai... Mencari Treasure di Workspace.")

local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer

-- Fungsi utama farming
local function doFarm()
    while true do
        local character = Player.Character or Player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local treasureFolder = workspace:FindFirstChild("Treasure")
        
        if treasureFolder then
            local targets = treasureFolder:GetChildren()
            
            if #targets == 0 then
                print("Menunggu treasure muncul...")
            end

            for _, item in pairs(targets) do
                -- Mencari part tujuan
                local targetPart = item:FindFirstChildWhichIsA("BasePart") or item
                
                if targetPart and targetPart:IsA("BasePart") then
                    print("Teleport ke: " .. item.Name)
                    
                    -- Teleport ke lokasi
                    rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.5)
                    
                    -- Tahan tombol F
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    print("Menahan F selama 4 detik...")
                    
                    task.wait(4)
                    
                    -- Lepas tombol F
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    task.wait(0.5)
                end
            end
        else
            warn("Folder 'Treasure' tidak ditemukan di Workspace!")
        end
        task.wait(2) -- Jeda sebelum scan ulang folder
    end
end

-- Menjalankan skrip di background
task.spawn(doFarm)
