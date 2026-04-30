local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm Tool | Arceus X",
   LoadingTitle = "Menyiapkan Script...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Combat", 4483362458)

local gathering = false -- Status loop

local Toggle = Tab:CreateToggle({
   Name = "Auto Gather Musuh (5m)",
   CurrentValue = false,
   Flag = "GatherToggle",
   Callback = function(Value)
      gathering = Value
      
      if gathering then
         spawn(function()
            while gathering do
               local player = game.Players.LocalPlayer
               local character = player.Character
               if character and character:FindFirstChild("HumanoidRootPart") then
                  local myPos = character.HumanoidRootPart.Position
                  
                  -- Mencari musuh di workspace.Enemy
                  for _, enemy in pairs(workspace.Enemy:GetChildren()) do
                     local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("UpperTorso")
                     
                     if enemyRoot then
                        local distance = (myPos - enemyRoot.Position).Magnitude
                        
                        -- Jika musuh dalam radius 5 meter
                        if distance <= 5 then
                           enemyRoot.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2) -- Taruh di depan pemain
                        end
                     end
                  end
               end
               
               -- Jeda 1 detik sesuai permintaan (siklus matikan loop internal)
               task.wait(1) 
            end
         end)
      end
   end,
})

-- Tombol Teleport tetap tersedia
local TPButton = Tab:CreateButton({
   Name = "Jump & Teleport ke CFrame",
   Callback = function()
       local player = game.Players.LocalPlayer
       local hrp = player.Character.HumanoidRootPart
       local targetCFrame = CFrame.new(1.95877993, -5.97917175, 304.821838, -0.982867241, -0.0337362401, 0.181201249, -0.0397345014, 0.998772502, -0.029574357, -0.179981127, -0.0362676568, -0.983001173)
       
       hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
       task.wait(0.2)
       hrp.CFrame = targetCFrame
   end,
})
