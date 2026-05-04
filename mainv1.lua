--[[ 
    PROJECT: SUPREME MINING SYSTEM - V3 GUARDIAN
    ARCHITECT: ROBOX (SENIOR LEVEL DESIGNER)
    FIX: ZERO-CLIP TELEPORT, PHYSICS LOCK, & STRIKE VALIDATION
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remote = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Chunks", 5):WaitForChild("damageBlock", 5)
local BlocksFolder = Workspace:WaitForChild("Blocks", 10)
local DropsFolder = Workspace:WaitForChild("Drops", 10)

local LocalPlayer = Players.LocalPlayer
local State = {
    Enabled = false,
    TargetMaterial = nil,
    MiningSpeed = 0.08, -- Sedikit lebih lambat untuk stabilitas server
    SafeHeight = 8 -- Offset tinggi agar tidak terjepit di tanah
}

-- UI CONSTRUCTOR (STABLE VERSION)
local function InitUI()
    local Gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    Gui.Name = "Architect_Guardian_UI"
    Gui.ResetOnSpawn = false

    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0, 200, 0, 250)
    Main.Position = UDim2.new(0.05, 0, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "ARCHITECT V3"
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.TextColor3 = Color3.new(1, 0.8, 0) -- Gold Accent
    Title.Font = Enum.Font.GothamBold

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.9, 0, 0, 40)
    Toggle.Position = UDim2.new(0.05, 0, 0.15, 0)
    Toggle.Text = "STATUS: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Toggle.TextColor3 = Color3.new(1, 1, 1)

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(0.9, 0, 0, 150)
    Scroll.Position = UDim2.new(0.05, 0, 0.35, 0)
    Scroll.CanvasSize = UDim2.new(0, 0, 5, 0)
    Scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

    local Layout = Instance.new("UIListLayout", Scroll)
    
    Toggle.MouseButton1Click:Connect(function()
        State.Enabled = not State.Enabled
        Toggle.Text = State.Enabled and "STATUS: ACTIVE" or "STATUS: OFF"
        Toggle.BackgroundColor3 = State.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)

    -- Scanner
    for _, b in ipairs(BlocksFolder:GetChildren()) do
        if b:IsA("BasePart") and b.MaterialVariant ~= "" then
            local btn = Instance.new("TextButton", Scroll)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = b.MaterialVariant
            btn.MouseButton1Click:Connect(function() State.TargetMaterial = b.MaterialVariant end)
        end
    end
end

-- LOGIKA ANTI-DEATH & MINING
task.spawn(function()
    while true do
        if State.Enabled and State.TargetMaterial then
            local Char = LocalPlayer.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

            if HRP and Hum and Hum.Health > 0 then
                for _, block in ipairs(BlocksFolder:GetChildren()) do
                    if not State.Enabled or Hum.Health <= 0 then break end
                    
                    if block:IsA("BasePart") and block.MaterialVariant == State.TargetMaterial then
                        -- [THE SAFETY LOCK]
                        -- Matikan gravitasi sementara agar tidak jatuh menembus lantai
                        HRP.Velocity = Vector3.new(0, 0, 0)
                        
                        -- Teleport ke atas blok (bukan di dalam blok)
                        Char:PivotTo(block.CFrame * CFrame.new(0, State.SafeHeight, 0))
                        
                        -- Tunggu posisi stabil
                        task.wait(0.1)

                        -- [MINING LOOP]
                        repeat
                            if not State.Enabled or Hum.Health <= 0 then break end
                            
                            -- Kirim damage
                            Remote:FireServer(block)
                            
                            -- Animasi visual (Opsional tapi membantu validasi server)
                            -- LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate() 

                            task.wait(State.MiningSpeed)
                        until not block or not block.Parent or (not State.Enabled)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- AUTO COLLECT (SOPHISTICATED TELEPORT)
DropsFolder.ChildAdded:Connect(function(drop)
    if State.Enabled then
        task.wait(0.2)
        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP and drop:IsA("BasePart") then
            drop.CFrame = HRP.CFrame
        end
    end
end)

InitUI()
