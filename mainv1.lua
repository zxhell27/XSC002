--[[ 
    PROJECT: SUPREME MINING SYSTEM - V4 OVERDRIVE
    ARCHITECT: ROBOX (SENIOR LEVEL DESIGNER)
    OBJECTIVE: MAXIMIZE DROP OUTPUT VIA REMOTE BURSTING
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
    Multiplier = 5, -- JUMLAH TEMBAKAN PER CYCLE (Ubah ke 10 atau 20 jika server kuat)
    SafeHeight = 10 -- Menghindari Physics Clipping agar tidak mati masuk tanah
}

-- UI CONSTRUCTOR (INDUSTRIAL GRADE)
local function CreateUI()
    local Gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    Gui.Name = "Architect_Overdrive_UI"
    
    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0, 220, 0, 280)
    Main.Position = UDim2.new(0.05, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Text = "OVERDRIVE SYSTEM"
    Title.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red Alert Theme
    Title.BackgroundColor3 = Color3.fromRGB(40, 5, 5)
    Title.Font = Enum.Font.GothamBold

    local Toggle = Instance.new("TextButton", Main)
    Toggle.Size = UDim2.new(0.9, 0, 0, 45)
    Toggle.Position = UDim2.new(0.05, 0, 0.18, 0)
    Toggle.Text = "OVERDRIVE: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Font = Enum.Font.GothamBold

    local MultiLabel = Instance.new("TextLabel", Main)
    MultiLabel.Size = UDim2.new(1, 0, 0, 20)
    MultiLabel.Position = UDim2.new(0, 0, 0.38, 0)
    MultiLabel.Text = "MULTIPLIER: " .. State.Multiplier .. "X"
    MultiLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    MultiLabel.BackgroundTransparency = 1

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(0.9, 0, 0, 130)
    Scroll.Position = UDim2.new(0.05, 0, 0.48, 0)
    Scroll.CanvasSize = UDim2.new(0, 0, 10, 0)
    Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UIListLayout", Scroll)

    Toggle.MouseButton1Click:Connect(function()
        State.Enabled = not State.Enabled
        Toggle.Text = State.Enabled and "OVERDRIVE: ACTIVE" or "OVERDRIVE: OFF"
        Toggle.BackgroundColor3 = State.Enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 20, 20)
    end)

    -- Scanner Button Generation
    local function UpdateList()
        for _, b in ipairs(BlocksFolder:GetChildren()) do
            if b:IsA("BasePart") and b.MaterialVariant ~= "" then
                local btn = Instance.new("TextButton", Scroll)
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.Text = b.MaterialVariant
                btn.MouseButton1Click:Connect(function() State.TargetMaterial = b.MaterialVariant end)
            end
        end
    end
    UpdateList()
end

-- BURST MINING ENGINE
task.spawn(function()
    while true do
        if State.Enabled and State.TargetMaterial then
            local Char = LocalPlayer.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            
            if HRP then
                for _, block in ipairs(BlocksFolder:GetChildren()) do
                    if not State.Enabled then break end
                    
                    if block:IsA("BasePart") and block.MaterialVariant == State.TargetMaterial then
                        -- 1. STABLE POSITIONING (Zero Velocity & High Offset)
                        HRP.Velocity = Vector3.zero
                        Char:PivotTo(block.CFrame * CFrame.new(0, State.SafeHeight, 0))
                        
                        -- 2. THE OVERDRIVE BURST
                        -- Mengirimkan sinyal serangan berkali-kali dalam satu frame
                        repeat
                            if not State.Enabled then break end
                            
                            -- Kirim burst tembakan berdasarkan Multiplier
                            for i = 1, State.Multiplier do
                                Remote:FireServer(block)
                            end
                            
                            task.wait(0.05) -- Jeda kecil untuk mencegah Kick oleh server
                        until not block or not block.Parent or (not State.Enabled)
                        
                        print("Architect: Block Decimated with Burst.")
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- HIGH-SPEED VACUUM
DropsFolder.ChildAdded:Connect(function(drop)
    if State.Enabled then
        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            -- Langsung tarik ke posisi karakter tanpa menunggu physics
            task.wait(0.05)
            if drop:IsA("BasePart") then
                drop.CFrame = HRP.CFrame
            elseif drop:IsA("Model") then
                drop:SetPrimaryPartCFrame(hrp.CFrame)
            end
        end
    end
end)

CreateUI()
