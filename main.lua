local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, -25)
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "SMART FARM: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel Kontrol
_G.AutoAttack = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoAttack = not _G.AutoAttack
    if _G.AutoAttack then
        ToggleButton.Text = "SMART FARM: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 150, 45)
    else
        ToggleButton.Text = "SMART FARM: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoAttack then
        pcall(function()
            local character = Player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                -- Menghilangkan deteksi serangan jarak jauh (Optional: Anti-Projectile)
                for _, v in pairs(character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = false -- Membuat karakter tidak bisa "disentuh" peluru musuh
                    end
                end

                if workspace:FindFirstChild("EnemyNpc") then
                    for _, enemy in pairs(workspace.EnemyNpc:GetChildren()) do
                        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHum = enemy:FindFirstChild("Humanoid")
                        
                        if enemyHRP and enemyHum and enemyHum.Health > 0 then
                            -- 1. HITBOX EXPANDER (Moderasi: 15 studs cukup luas tapi tidak berlebihan)
                            enemyHRP.Size = Vector3.new(15, 15, 15)
                            enemyHRP.Transparency = 1 
                            enemyHRP.CanCollide = false
                            
                            -- 2. POSITIONING (Musuh ditaruh 15 stud di depan agar jarak jauh tidak sampai hit)
                            -- Jarak 15 stud biasanya di luar jangkauan serangan melee dan projectile awal NPC
                            enemyHRP.CFrame = rootPart.CFrame * CFrame.new(0, -1, -15)
                            enemyHRP.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
                
                -- 3. ATTACK (Kecepatan standar agar tidak terdeteksi spam berlebih)
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            end
        end)
    else
        -- Mengembalikan CanTouch ke true jika script dimatikan
        pcall(function()
            for _, v in pairs(Player.Character:GetChildren()) do
                if v:IsA("BasePart") then v.CanTouch = true end
            end
        end)
    end
end)
