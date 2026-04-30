local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Enemy Gatherer V3 | Arceus X",
   LoadingTitle = "Menjalankan Script...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main", 4483362458)

local gatheringActive = false

-- Fungsi Utama Gather
local function gatherEnemies()
    local enemiesFolder = workspace:FindFirstChild("Enemy")
    if not enemiesFolder then return end
    
    local allEnemies = enemiesFolder:GetChildren()
    if #allEnemies == 0 then return end

    -- Target Index 33 atau yang terakhir
    local targetEnemy = allEnemies[33] or allEnemies[#allEnemies] 
    
    if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
        local gatherPosition = targetEnemy.HumanoidRootPart.Position

        for _, enemy in ipairs(allEnemies) do
            local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
            if enemyHrp then
                -- 1. Pindahkan Posisi
                enemyHrp.CFrame = CFrame.new(gatherPosition)
                
                -- 2. Kunci Posisi (Agar tidak kembali ke awal)
                enemyHrp.Anchored = true
                
                -- 3. Reset Kecepatan
                enemyHrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- Fungsi Un-Anchor (Agar musuh bisa mati/bergerak lagi jika diinginkan)
local function unanchorEnemies()
    local enemiesFolder = workspace:FindFirstChild("Enemy")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
            if enemyHrp then
                enemyHrp.Anchored = false
            end
        end
    end
end

-- Toggle Loop
Tab:CreateToggle({
   Name = "Auto Gather & Freeze Musuh",
   CurrentValue = false,
   Flag = "GatherToggle",
   Callback = function(Value)
      gatheringActive = Value
      if gatheringActive then
         task.spawn(function()
            while gatheringActive do
               gatherEnemies()
               task.wait(1) -- Siklus kumpul tiap 1 detik
            end
         end)
      else
         unanchorEnemies() -- Lepaskan kunci jika toggle dimatikan
      end
   end,
})

-- Button Teleport Tetap Ada
Tab:CreateButton({
   Name = "Jump & Teleport ke CFrame",
   Callback = function()
       local player = game.Players.LocalPlayer
       local char = player.Character or player.CharacterAdded:Wait()
       local hrp = char:WaitForChild("HumanoidRootPart")
       local targetCFrame = CFrame.new(1.95877993, -5.97917175, 304.821838, -0.982867241, -0.0337362401, 0.181201249, -0.0397345014, 0.998772502, -0.029574357, -0.179981127, -0.0362676568, -0.983001173)
       
       hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
       task.wait(0.2)
       hrp.CFrame = targetCFrame
   end,
})
