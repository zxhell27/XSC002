local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.Lib:CreateWindow("Treasure Auto-Farm", "Arceus X")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Teleport & Hold F")

local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

_G.AutoFarm = false

-- Fungsi Utama
local function startFarming()
    while _G.AutoFarm do
        local treasures = workspace:WaitForChild("Treasure"):GetChildren()
        
        for _, item in pairs(treasures) do
            if not _G.AutoFarm then break end
            
            -- Cek jika item memiliki Part untuk dituju
            local targetPart = item:FindFirstChildWhichIsA("BasePart") or item
            
            if targetPart then
                -- Teleport ke lokasi item (sedikit di atas agar tidak stuck)
                RootPart.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0)
                task.wait(0.5)
                
                -- Simulasi tekan tombol F
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                print("Holding F on: " .. item.Name)
                
                -- Tunggu 4 detik sesuai permintaan
                task.wait(4)
                
                -- Lepas tombol F
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.5)
            end
        end
        task.wait(1) -- Jeda antar loop pencarian folder
    end
end

-- Toggle UI
Section:NewToggle("Auto Treasure", "Teleport and Hold F for 4s", function(state)
    _G.AutoFarm = state
    if state then
        task.spawn(startFarming)
    end
end)

Section:NewLabel("Dibuat untuk Workspace.Treasure")
