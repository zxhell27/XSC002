local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Treasure Auto-Farm",
   LoadingTitle = "Arceus X Script",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = false
   }
})

local Tab = Window:CreateTab("Main", nil) -- Title, Image
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
            local items = treasureFolder:GetChildren()
            
            for _, item in pairs(items) do
                if not _G.AutoFarm then break end
                
                -- Mencari part di dalam model treasure
                local target = item:FindFirstChildWhichIsA("BasePart") or item
                
                if target and target:IsA("BasePart") then
                    -- Teleport ke item
                    rootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.5)
                    
                    -- Tekan F
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    
                    -- Tahan selama 4 detik
                    local startTime = tick()
                    repeat 
                        task.wait(0.1)
                    until tick() - startTime >= 4 or not _G.AutoFarm
                    
                    -- Lepas F
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    task.wait(0.5)
                end
            end
        else
            Rayfield:Notify({
               Title = "Error",
               Content = "Folder 'Treasure' tidak ditemukan di Workspace!",
               Duration = 5,
               Image = 4483362458,
            })
            _G.AutoFarm = false
            break
        end
        task.wait(1)
    end
end

local Toggle = Tab:CreateToggle({
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
