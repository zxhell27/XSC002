local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Enemy Gatherer | Arceus X",
   LoadingTitle = "Menjalankan Script...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main Features", 4483362458)

local gatheringActive = false

-- Fungsi Utama Gather
local function gatherEnemies()
    local enemiesFolder = workspace:FindFirstChild("Enemy")
    if not enemiesFolder then return end
    
    local enemies = enemiesFolder:GetChildren()
    -- Mengambil target index ke-3 sesuai permintaanmu
    local targetEnemy = enemies[3] 
    
    if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
        local gatherPosition = targetEnemy.HumanoidRootPart.Position

        for _, enemy in ipairs(enemies) do
            local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
            if enemyHrp then
                -- Menarik musuh ke musuh index ke-3
                enemyHrp.CFrame = CFrame.new(gatherPosition)
                
                -- Agar tidak terpental saat bertumpuk
                enemyHrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- Toggle Loop
Tab:CreateToggle({
   Name = "Loop Gather (Index 3)",
   CurrentValue = false,
   Flag = "GatherToggle",
   Callback = function(Value)
      gatheringActive = Value
      if gatheringActive then
         task.spawn(function()
            while gatheringActive do
               gatherEnemies() -- Kumpulkan
               task.wait(1)    -- Matikan/Diam selama 1 detik (Siklus)
            end
         end)
      end
   end,
})

-- Button Teleport CFrame (Dari permintaan pertama)
Tab:CreateButton({
   Name = "Jump & Teleport ke CFrame",
   Callback = function()
       local player = game.Players.LocalPlayer
       local hrp = player.Character:WaitForChild("HumanoidRootPart")
       local targetCFrame = CFrame.new(1.95877993, -5.97917175, 304.821838, -0.982867241, -0.0337362401, 0.181201249, -0.0397345014, 0.998772502, -0.029574357, -0.179981127, -0.0362676568, -0.983001173)
       
       hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
       task.wait(0.2)
       hrp.CFrame = targetCFrame
   end,
})
