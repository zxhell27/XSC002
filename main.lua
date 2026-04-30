local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "OVERPOWERED GATHERER | Arceus X",
   LoadingTitle = "Initiating God Mode...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Chaos", 4483362458)

local _G = _G or {}
_G.GodGather = false
local connection = nil

-- FUNGSI GILA: Mengunci CFrame di tingkat RenderStepped
local function startBlackHole()
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not _G.GodGather then 
            if connection then connection:Disconnect() end
            return 
        end

        local folder = workspace:FindFirstChild("Enemy")
        if not folder then return end
        
        local enemies = folder:GetChildren()
        -- Gunakan index 33 atau musuh terjauh sebagai gravitasi pusat
        local center = enemies[33] or enemies[#enemies]
        
        if center and center:FindFirstChild("HumanoidRootPart") then
            local targetPos = center.HumanoidRootPart.CFrame
            
            for _, enemy in ipairs(enemies) do
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                
                if hrp and enemy ~= center then
                    -- PAKSA POSISI (Ini akan menang melawan AI game manapun)
                    hrp.CFrame = targetPos
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    -- KREATIF: Matikan state berjalan agar AI-nya 'patah'
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Physics)
                        hum.PlatformStand = true -- Musuh jadi lemas dan tidak bisa lari
                    end
                end
            end
        end
    end)
end

Tab:CreateToggle({
   Name = "ACTIVATE BLACK HOLE (Force Gather)",
   CurrentValue = false,
   Flag = "GodGather",
   Callback = function(Value)
      _G.GodGather = Value
      if Value then
         startBlackHole()
      else
         -- Reset musuh agar bisa bergerak lagi saat dimatikan
         local folder = workspace:FindFirstChild("Enemy")
         if folder then
            for _, enemy in ipairs(folder:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if hum then 
                    hum.PlatformStand = false 
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
         end
      end
   end,
})

-- Fitur Tambahan: Kill Aura Simulator (Opsional - Mengosongkan HP Musuh yang terkumpul)
Tab:CreateButton({
   Name = "Instant Snap (Set HP 0)",
   Callback = function()
       for _, enemy in ipairs(workspace.Enemy:GetChildren()) do
           local hum = enemy:FindFirstChildOfClass("Humanoid")
           if hum then hum.Health = 0 end
       end
   end,
})

-- Teleport CFrame Original
Tab:CreateButton({
   Name = "Jump & Teleport",
   Callback = function()
       local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
       hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
       task.wait(0.2)
       hrp.CFrame = CFrame.new(1.95877993, -5.97917175, 304.821838, -0.982867241, -0.0337362401, 0.181201249, -0.0397345014, 0.998772502, -0.029574357, -0.179981127, -0.0362676568, -0.983001173)
   end,
})
