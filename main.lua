local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, -25)
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "GOD MODE: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel
_G.GodMode = false
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.GodMode = not _G.GodMode
    if _G.GodMode then
        ToggleButton.Text = "GOD MODE: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "GOD MODE: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        -- Reset posisi jika dimatikan
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- Loop Utama (Tanpa Delay)
RunService.Stepped:Connect(function()
    if _G.GodMode then
        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if hrp and hum then
                -- 1. ANTI-DEATH: Paksa Velocity jadi 0 agar tidak terlempar anti-cheat
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                -- 2. CARI MUSUH TERDEKAT (Targeting)
                local target = nil
                local dist = math.huge
                
                if workspace:FindFirstChild("EnemyNpc") then
                    for _, enemy in pairs(workspace.EnemyNpc:GetChildren()) do
                        local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                        local eHum = enemy:FindFirstChild("Humanoid")
                        if eHrp and eHum and eHum.Health > 0 then
                            local d = (hrp.Position - eHrp.Position).Magnitude
                            if d < dist then
                                dist = d
                                target = enemy
                            end
                        end
                    end
                end

                -- 3. POSITIONING: Melayang di atas musuh (Aman dari hit)
                if target then
                    -- Anda dipindahkan tepat 10 stud DI ATAS musuh
                    -- Musuh di bawah tanah tidak bisa hit ke atas
                    hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Perbesar Hitbox Musuh agar dari atas tetap kena
                    target.HumanoidRootPart.Size = Vector3.new(30, 30, 30)
                    target.HumanoidRootPart.CanCollide = false
                end

                -- 4. ULTRA ATTACK
                local remote = game:GetService("ReplicatedStorage").Remotes.PlayerActionRE
                remote:FireServer("SkillAction", "BaseAttack", 1)
            end
        end)
    end
end)
