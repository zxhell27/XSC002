local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Teleport Tool | Arceus X",
   LoadingTitle = "Menyiapkan Script...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = false
   }
})

local Tab = Window:CreateTab("Main", 4483362458) -- Icon ID

local Button = Tab:CreateButton({
   Name = "Jump & Teleport ke CFrame",
   Callback = function()
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local hrp = character:WaitForChild("HumanoidRootPart")
       
       -- Target CFrame yang kamu berikan
       local targetCFrame = CFrame.new(1.95877993, -5.97917175, 304.821838, -0.982867241, -0.0337362401, 0.181201249, -0.0397345014, 0.998772502, -0.029574357, -0.179981127, -0.0362676568, -0.983001173)

       -- Langkah 1: Melompat sangat tinggi (Anti-stuck)
       hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
       
       -- Tunggu sebentar agar fisika game memproses posisi
       task.wait(0.2)
       
       -- Langkah 2: Pindah ke target koordinat
       hrp.CFrame = targetCFrame
       
       Rayfield:Notify({
          Title = "Berhasil!",
          Content = "Kamu telah berpindah ke koordinat target.",
          Duration = 3,
          Image = 4483362458,
       })
   end,
})

Rayfield:Notify({
   Title = "Script Ready",
   Content = "Silakan klik tombol untuk teleport.",
   Duration = 5,
   Image = 4483362458,
})
