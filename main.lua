local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Enemy Gatherer V2 | Arceus X",
   LoadingTitle = "Menjalankan Script...",
   LoadingSubtitle = "by Lamun",
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

    -- Mengambil target sesuai referensimu (Indeks 33 atau yang terakhir tersedia)
    local targetIndex = 33
    local targetEnemy = allEnemies[targetIndex] or allEnemies[#allEnemies] 
    
    if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
        local gatherPosition = targetEnemy.HumanoidRootPart.Position

        for i, enemy in ipairs(allEnemies) do
            -- Kita tidak memindahkan si target itu sendiri
            if enemy ~= targetEnemy then
                local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
                if enemyHrp then
                    enemyHrp.CFrame = CFrame.new(gatherPosition)
                    enemyHrp.Velocity = Vector3.new(0, 0, 0) -- Mencegah terpental
                end
            end
        end
    end
end

-- Toggle Loop
Tab:CreateToggle({
   Name = "Auto Gather Musuh (Siklus 1s)",
   CurrentValue = false,
   Flag = "GatherToggle",
   Callback = function(Value)
      gatheringActive = Value
      if gatheringActive then
         task.spawn(function()
            while gatheringActive do
               gatherEnemies()
               task.wait(1) -- "Mematikan" loop selama 1 detik sesuai permintaan
            end
         end)
      end
   end,
})

-- Button Teleport CFrame
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
