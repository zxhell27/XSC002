local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, -25)
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "GOD KILLER: OFF"
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
        ToggleButton.Text = "GOD KILLER: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
    else
        ToggleButton.Text = "GOD KILLER: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
    end
end)

-- Loop Utama (Heartbeat untuk Kecepatan Maksimal)
RS.Heartbeat:Connect(function()
    if _G.AutoAttack then
        pcall(function()
            local character = Player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                if workspace:FindFirstChild("EnemyNpc") then
                    for _, enemy in pairs(workspace.EnemyNpc:GetChildren()) do
                        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHum = enemy:FindFirstChild("Humanoid")
                        
                        if enemyHRP and enemyHum and enemyHum.Health > 0 then
                            -- 1. KILL HITBOX (Membuat musuh sangat besar agar mudah kena hit)
                            enemyHRP.Size = Vector3.new(25, 25, 25)
                            enemyHRP.Transparency = 0.9 -- Nyaris transparan agar tidak silau
                            enemyHRP.CanCollide = false
                            
                            -- 2. SAFE DISTANCE (Posisi musuh di bawah dan depan)
                            -- Kita taruh di -5 (bawah) dan -10 (depan) 
                            -- Jarak ini cukup jauh agar musuh tidak bisa memukul balik
                            enemyHRP.CFrame = rootPart.CFrame * CFrame.new(0, -5, -10)
                            enemyHRP.Velocity = Vector3.new(0, 0, 0)
                            
                            -- 3. DISABLE ENEMY ATTACK (Opsional jika game mendukung)
                            -- Membuat musuh tidak bisa melihat/menargetkan kita
                            enemyHum.WalkSpeed = 0
                            enemyHum.JumpPower = 0
                        end
                    end
                end
                
                -- 4. SPAM ATTACK (Makin banyak baris = makin cepat hit)
                local remote = game:GetService("ReplicatedStorage").Remotes.PlayerActionRE
                remote:FireServer("SkillAction", "BaseAttack", 1)
                remote:FireServer("SkillAction", "BaseAttack", 1)
            end
        end)
    end
end)
