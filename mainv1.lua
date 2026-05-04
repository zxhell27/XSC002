-- Memuat Rayfield Library
local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("Gagal memuat Rayfield. Pastikan koneksi internet stabil dan executor mendukung HttpGet.")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Treasure Auto-Farm",
   LoadingTitle = "Arceus X Script",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false -- Dimatikan agar langsung muncul
})

local Tab = Window:CreateTab("Main", 4483362458) 
local Section = Tab:CreateSection("Farm Settings")

_G.AutoFarm = false

local function startFarming()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Player = game.Players.LocalPlayer
    
    while _G.AutoFarm do
        local character = Player.Character or Player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local treasureFolder = workspace:FindFirstChild("Treasure")
        
        if treasureFolder then
            for _, item in pairs(treasureFolder:GetChildren()) do
                if not _G.AutoFarm then break end
                
                local target = item:FindFirstChildWhichIsA("BasePart") or item
                
                if target and target:IsA("BasePart") then
                    -- Teleport
                    rootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.5)
                    
                    -- Tekan F
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    
                    -- Hold 4 detik
                    local t = 0
                    while t < 4 and _G.AutoFarm do
                        task.wait(0.1)
                        t = t + 0.1
                    end
                    
                    -- Lepas F
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    task.wait(0.5)
                end
            end
        else
            Rayfield:Notify({
               Title = "Folder Missing",
               Content = "Workspace.Treasure tidak ditemukan!",
               Duration = 5,
               Image = 4483362458,
            })
            _G.AutoFarm = false
            break
        end
        task.wait(1)
    end
end

Tab:CreateToggle({
   Name = "Auto Collect Treasure",
   CurrentValue = false,
   Flag = "ToggleFarm", 
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
          task.spawn(startFarming)
      end
   end,
})
