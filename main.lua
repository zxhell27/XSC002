local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup (Black & Gold for OP Look)
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, -25)
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "VOID GOD: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
UICorner.Parent = MainFrame

-- Variabel Kontrol
_G.VoidGod = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local SafePlatform = nil

-- Fungsi Membuat Platform Rahasia di Langit
local function CreateSafePlatform()
    if not SafePlatform then
        SafePlatform = Instance.new("Part")
        SafePlatform.Size = Vector3.new(20, 1, 20)
        SafePlatform.Position = Vector3.new(0, 5000, 0) -- Jauh di atas langit
        SafePlatform.Anchored = true
        SafePlatform.Transparency = 0.5
        SafePlatform.Parent = workspace
    end
    return SafePlatform
end

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    _G.VoidGod = not _G.VoidGod
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if _G.VoidGod then
        ToggleButton.Text = "VOID GOD: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 0)
        local plate = CreateSafePlatform()
        if hrp then hrp.CFrame = plate.CFrame + Vector3.new(0, 3, 0) end
    else
        ToggleButton.Text = "VOID GOD: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
        -- Jika dimatikan, karakter akan jatuh kembali (atau Anda bisa TP ke tempat aman)
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0) end
    end
end)

-- Loop Utama (Super Fast & Untouchable)
RS.RenderStepped:Connect(function()
    if _G.VoidGod then
        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- 1. GOD MODE: Mematikan Hitbox Karakter (Anti-Hit 100%)
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = false
                    end
                end

                -- 2. ABIDUCTION: Tarik Musuh ke Langit
                if workspace:FindFirstChild("EnemyNpc") then
                    for _, enemy in pairs(workspace.EnemyNpc:GetChildren()) do
                        local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                        local eHum = enemy:FindFirstChild("Humanoid")
                        
                        if eHRP and eHum and eHum.Health > 0 then
                            -- Perbesar Hitbox Musuh secara brutal
                            eHRP.Size = Vector3.new(40, 40, 40)
                            eHRP.CanCollide = false
                            
                            -- Pindahkan Musuh ke depan karakter di langit
                            eHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
                            eHRP.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
                
                -- 3. INSANE ATTACK SPEED (5x FireServer per Frame)
                local rem = game:GetService("ReplicatedStorage").Remotes.PlayerActionRE
                rem:FireServer("SkillAction", "BaseAttack", 1)
                rem:FireServer("SkillAction", "BaseAttack", 1)
                rem:FireServer("SkillAction", "BaseAttack", 1)
                rem:FireServer("SkillAction", "BaseAttack", 1)
                rem:FireServer("SkillAction", "BaseAttack", 1)
            end
        end)
    end
end)
