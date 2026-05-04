--[[ 
    PROJECT: SUPREME MINING SYSTEM - V5 REPLICATOR
    ARCHITECT: ROBOX (SENIOR LEVEL DESIGNER & SYSTEMS ENGINEER)
    STRATEGY: FRAME-SYNC PACKET INJECTION (LATENCY EXPLOIT)
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- PENCARIAN JALUR KRITIS
local Remote = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Chunks", 5):WaitForChild("damageBlock", 5)
local BlocksFolder = Workspace:WaitForChild("Blocks", 10)
local DropsFolder = Workspace:WaitForChild("Drops", 10)

local LocalPlayer = Players.LocalPlayer
local State = {
    Enabled = false,
    TargetMaterial = nil,
    Multiplier = 15, -- Agresivitas penggandaan (Coba naikkan bertahap)
    SafeHeight = 12  -- Tinggi absolut agar tidak mati menembus lantai
}

-- UI INDUSTRIAL (HIGH-CONTRAST)
local function CreateReplicatorUI()
    local Gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    Gui.Name = "Architect_Replicator_V5"
    Gui.ResetOnSpawn = false

    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0, 240, 0, 300)
    Main.Position = UDim2.new(0.05, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 2
    Main.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Neon Green (Success Theme)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "REPLICATOR ENGINE V5"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.Font = Enum.Font.RobotoMono

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.9, 0, 0, 50)
    Toggle.Position = UDim2.new(0.05, 0, 0.2, 0)
    Toggle.Text = "REPLICATION: DISABLED"
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    Toggle.TextColor3 = Color3.new(1, 1, 1)

    local List = Instance.new("ScrollingFrame", Main)
    List.Size = UDim2.new(0.9, 0, 0, 150)
    List.Position = UDim2.new(0.05, 0, 0.45, 0)
    List.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Instance.new("UIListLayout", List)

    Toggle.MouseButton1Click:Connect(function()
        State.Enabled = not State.Enabled
        Toggle.Text = State.Enabled and "REPLICATION: ACTIVE" or "REPLICATION: DISABLED"
        Toggle.BackgroundColor3 = State.Enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)

    -- Scanner Button
    for _, b in ipairs(BlocksFolder:GetChildren()) do
        if b:IsA("BasePart") and b.MaterialVariant ~= "" then
            local btn = Instance.new("TextButton", List)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = b.MaterialVariant
            btn.MouseButton1Click:Connect(function() State.TargetMaterial = b.MaterialVariant end)
        end
    end
end

-- LOGIKA PENGGANDA (THE HEARTBEAT EXPLOIT)
task.spawn(function()
    while true do
        if State.Enabled and State.TargetMaterial then
            local Char = LocalPlayer.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            
            if HRP then
                for _, block in ipairs(BlocksFolder:GetChildren()) do
                    if not State.Enabled then break end
                    
                    if block:IsA("BasePart") and block.MaterialVariant == State.TargetMaterial then
                        -- 1. POSITION LOCK (Mencegah Karakter Masuk Tanah)
                        HRP.Velocity = Vector3.new(0, 0, 0)
                        Char:PivotTo(block.CFrame * CFrame.new(0, State.SafeHeight, 0))
                        
                        -- 2. THE REPLICATION STRIKE
                        -- Kita menggunakan repeat untuk menghancurkan, 
                        -- tapi di dalamnya kita melakukan "Over-fire"
                        repeat
                            if not State.Enabled then break end
                            
                            -- Mengirimkan Multiplier tembakan tepat sebelum physics frame selesai
                            for i = 1, State.Multiplier do
                                -- Kita panggil Remote secara asinkron agar tidak membebani satu thread
                                task.spawn(function()
                                    Remote:FireServer(block)
                                end)
                            end
                            
                            RunService.Heartbeat:Wait() -- Menunggu satu frame fisika
                        until not block or not block.Parent or (not State.Enabled)
                        
                        print("Architect: Target Replicated & Destroyed.")
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ULTRA-FAST VACUUM (Mencegah Lag Akibat Drop Berlebih)
DropsFolder.ChildAdded:Connect(function(drop)
    if State.Enabled then
        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            -- Langsung tarik tanpa delay fisik
            if drop:IsA("BasePart") then
                drop.CanCollide = false
                drop.CFrame = HRP.CFrame
            elseif drop:IsA("Model") then
                drop:PivotTo(HRP.CFrame)
            end
        end
    end
end)

CreateReplicatorUI()
