local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "PUPPET MASTER | Arceus X",
   LoadingTitle = "Executing Chaos...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main", 4483362458)

local _G = _G or {}
_G.Active = false
local targetPos = nil

-- Fungsi untuk mendapatkan target titik kumpul yang valid
local function getTargetCFrame()
    local folder = workspace:FindFirstChild("Enemy")
    if not folder then return nil end
    
    local enemies = folder:GetChildren()
    if #enemies == 0 then return nil end
    
    -- Mencari musuh indeks ke-33, jika tidak ada cari yang paling belakang
    local master = enemies[33] or enemies[#enemies]
    if master and master:FindFirstChild("HumanoidRootPart") then
        return master.HumanoidRootPart.CFrame
    end
    return nil
end

-- Loop Utama (Heartbeat agar menang lawan AI game)
game:GetService("RunService").Heartbeat:Connect(function()
    if not _G.Active then return end
    
    local folder = workspace:FindFirstChild("Enemy")
    if not folder then return end
    
    local masterCFrame = getTargetCFrame()
    if not masterCFrame then return end

    for _, enemy in ipairs(folder:GetChildren()) do
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        
        -- Hanya pindahkan jika musuh masih hidup agar tidak hancur/glitch
        if hrp and hum and hum.Health > 0 then
            -- PAKSA posisi ke target (tapi beri sedikit offset agar tidak menumpuk kaku)
            hrp.CFrame = masterCFrame * CFrame.new(0, 0, 0.1)
            
            -- Matikan kecepatan agar tidak mental
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

Tab:CreateToggle({
   Name = "Master Gather (Loop 1s Cycle)",
   CurrentValue = false,
   Flag = "MasterGather",
   Callback = function(Value)
      _G.Active = Value
      -- Memberikan jeda 1 detik sesuai permintaan awal agar script "bernafas"
      task.spawn(function()
          while _G.Active do
              -- Trigger kumpul dikelola oleh Heartbeat di atas
              task.wait(1) 
          end
      end)
   end,
})

-- Teleport CFrame dari permintaan pertama
Tab:CreateButton({
   Name = "Jump & Teleport ke CFrame",
   Callback = function()
       local player = game.Players.LocalPlayer
       local hrp = player.Character.HumanoidRootPart
       local target = CFrame.new(1.95877993, -5.97917175, 304.821838, -0.982867241, -0.0337362401, 0.181201249, -0.0397345014, 0.998772502, -0.029574357, -0.179981127, -0.0362676568, -0.983001173)
       
       hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
       task.wait(0.2)
       hrp.CFrame = target
   end,
})
