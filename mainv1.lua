--[[
    PROJECT: SUPREME MINING AUTOMATION
    ARCHITECT: ROBOX (THE ARCHITECT)
    BUILD VERSION: 2.1.0 [STABLE]
    
    FEATURES: 
    - Auto-TP to Target Block
    - Focused Fire Remote Execution
    - Instant Drop Vacuum
    - Dynamic Material Scanner
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- PENCARIAN REMOTE (VALIDASI KRITIS)
local Remote = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Chunks", 5):WaitForChild("damageBlock", 5)
if not Remote then 
    warn("!!! ARCHITECT CRITICAL ERROR: REMOTE NOT FOUND !!!") 
    return 
end

local LocalPlayer = Players.LocalPlayer
local State = {
    Enabled = false,
    TargetMaterial = nil,
    TeleportOffset = Vector3.new(0, 5, 0) -- Berdiri di atas blok agar tidak terjebak (Stuck)
}

-- UI CONSTRUCTOR (OPTIMIZED FOR ARCEUS X)
local function BuildInterface()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Architect_Master_UI"
    ScreenGui.ResetOnSpawn = false
    -- Proteksi GUI agar tidak terhapus game
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 250, 0, 320)
    Main.Position = UDim2.new(0.5, -125, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 2
    Main.BorderColor3 = Color3.fromRGB(255, 170, 0) -- Warna Emas Industri
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.Text = "ARCHITECT: MINING SYSTEM"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.9, 0, 0, 50)
    Toggle.Position = UDim2.new(0.05, 0, 0.15, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Toggle.Text = "SYSTEM: DEACTIVATED"
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Font = Enum.Font.GothamBold

    local List = Instance.new("ScrollingFrame", Main)
    List.Size = UDim2.new(0.9, 0, 0, 160)
    List.Position = UDim2.new(0.05, 0, 0.35, 0)
    List.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    List.CanvasSize = UDim2.new(0, 0, 0, 0)
    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout", List)
    Layout.Padding = UDim.new(0, 5)

    -- EVENT: TOGGLE ON/OFF
    Toggle.MouseButton1Click:Connect(function()
        State.Enabled = not State.Enabled
        Toggle.Text = State.Enabled and "SYSTEM: ACTIVE" or "SYSTEM: DEACTIVATED"
        Toggle.BackgroundColor3 = State.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)

    -- SCANNER: MENGISI DAFTAR MATERIAL
    local function RefreshScanner()
        for _, v in ipairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        
        local found = {}
        local blocksFolder = Workspace:WaitForChild("Blocks", 5)
        if not blocksFolder then return end

        for _, block in ipairs(blocksFolder:GetChildren()) do
            if block:IsA("BasePart") and block.MaterialVariant ~= "" and not found[block.MaterialVariant] then
                found[block.MaterialVariant] = true
                local btn = Instance.new("TextButton", List)
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                btn.Text = block.MaterialVariant
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.Font = Enum.Font.Gotham

                btn.MouseButton1Click:Connect(function()
                    State.TargetMaterial = block.MaterialVariant
                    print("Architect: Target Locked to " .. block.MaterialVariant)
                    for _, b in ipairs(List:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end end
                    btn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
                end)
            end
        end
    end

    RefreshScanner()
end

-- LOGIKA INTI: TELEPORT & MINING
task.spawn(function()
    while true do
        if State.Enabled and State.TargetMaterial then
            local Blocks = Workspace:FindFirstChild("Blocks")
            if Blocks then
                for _, block in ipairs(Blocks:GetChildren()) do
                    if not State.Enabled then break end
                    
                    if block:IsA("BasePart") and block.MaterialVariant == State.TargetMaterial then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- 1. TELEPORT KE TARGET
                            hrp.CFrame = block.CFrame * CFrame.new(0, 6, 0) -- Berdiri di atas agar tidak stuck
                            task.wait(0.1) -- Sinkronisasi posisi dengan server

                            -- 2. TARGET LOCK LOOP (Hancurkan Sampai Tuntas)
                            repeat
                                if not State.Enabled then break end
                                Remote:FireServer(block)
                                task.wait(0.05) -- Kecepatan maksimal yang aman dari kick
                            until not block or not block.Parent or (not State.Enabled)
                            
                            print("Architect: Block Destroyed.")
                        end
                    end
                end
            end
        end
        task.wait(0.5) -- Cool-down scanner loop
    end
end)

-- LOGIKA VACUUM DROPS (INSTANT COLLECTION)
Workspace:WaitForChild("Drops").ChildAdded:Connect(function(drop)
    if State.Enabled then
        task.wait(0.1) -- Jeda kecil agar physics drop tidak glitch
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if drop:IsA("BasePart") then
                drop.CFrame = hrp.CFrame
            elseif drop:IsA("Model") then
                drop:SetPrimaryPartCFrame(hrp.CFrame)
            end
        end
    end
end)

BuildInterface()
