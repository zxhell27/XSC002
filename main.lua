local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, -25)
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "BIG HITBOX: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
UICorner.Parent = MainFrame

-- Variabel Kontrol
_G.AutoAttack = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- Fungsi Memperbesar HITBOX Senjata secara Manual
local function ExpandWeaponHitbox()
    pcall(function()
        local weapon = workspace:FindFirstChild("Lutung055") and workspace.Lutung055:FindFirstChild("Weapon")
        if weapon then
            -- Cari semua Part di dalam senjata untuk diperbesar hitboxnya
            for _, part in pairs(weapon:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(20, 20, 20) -- Ukuran hitbox raksasa (20x20x20 studs)
                    part.Transparency = 0.8 -- Transparan agar tidak menutupi layar (ubah ke 1 untuk invisible)
                    part.CanCollide = false -- Agar tidak nabrak objek lain
                    part.Massless = true
                end
            end
        end
    end)
end

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoAttack = not _G.AutoAttack
    if _G.AutoAttack then
        ToggleButton.Text = "BIG HITBOX: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        ExpandWeaponHitbox()
    else
        ToggleButton.Text = "BIG HITBOX: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- Loop Utama (Speed + God Position)
RS.Heartbeat:Connect(function()
    if _G.AutoAttack then
        pcall(function()
            local character = Player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                -- 1. Pindahkan Musuh ke Area Hitbox (Sedikit di bawah & depan)
                if workspace:FindFirstChild("EnemyNpc") then
                    for _, enemy in pairs(workspace.EnemyNpc:GetChildren()) do
                        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHum = enemy:FindFirstChild("Humanoid")
                        
                        if enemyHRP and enemyHum and enemyHum.Health > 0 then
                            -- Musuh ditaruh di titik di mana hitbox 20x20 Anda pasti kena
                            enemyHRP.CFrame = rootPart.CFrame * CFrame.new(0, -2, -8)
                            enemyHRP.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
                
                -- 2. Spam Serangan
                local remote = game:GetService("ReplicatedStorage").Remotes.PlayerActionRE
                remote:FireServer("SkillAction", "BaseAttack", 1)
            end
        end)
    end
end)
