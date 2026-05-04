--[[ 
    PROJECT: SUPREME MINING SYSTEM - FINAL DEBUGGED VERSION
    ARCHITECT: ROBOX (SENIOR LEVEL DESIGNER)
    LOGIC: RECURSIVE TARGETING & PIVOT INJECTION
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- [VITAL CHECK] Pastikan jalur Remote dan Folder benar
local Remote = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Chunks", 5):WaitForChild("damageBlock", 5)
local BlocksFolder = Workspace:WaitForChild("Blocks", 10)
local DropsFolder = Workspace:WaitForChild("Drops", 10)

if not Remote or not BlocksFolder then
    warn("!!! ARCHITECT FATAL ERROR: STRUKTUR WORKSPACE TIDAK SESUAI !!!")
    return
end

local LocalPlayer = Players.LocalPlayer
local State = {
    Enabled = false,
    TargetMaterial = nil,
    MiningSpeed = 0.05 -- Delay antar serangan remote
}

-- UI CONSTRUCTOR (INDUSTRIAL GRADE)
local function CreateArchitectUI()
    local Gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    Gui.Name = "Architect_Final_UI"
    Gui.ResetOnSpawn = false

    local Frame = Instance.new("Frame", Gui)
    Frame.Size = UDim2.new(0, 220, 0, 300)
    Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Cyan Accent
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "SYSTEM CONTROL"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Title.Font = Enum.Font.GothamBold

    local Toggle = Instance.new("TextButton", Frame)
    Toggle.Size = UDim2.new(0.9, 0, 0, 45)
    Toggle.Position = UDim2.new(0.05, 0, 0.18, 0)
    Toggle.Text = "SYSTEM: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Toggle.TextColor3 = Color3.new(1, 1, 1)

    local Scrolling = Instance.new("ScrollingFrame", Frame)
    Scrolling.Size = UDim2.new(0.9, 0, 0, 160)
    Scrolling.Position = UDim2.new(0.05, 0, 0.4, 0)
    Scrolling.CanvasSize = UDim2.new(0, 0, 5, 0)
    Scrolling.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    local Layout = Instance.new("UIListLayout", Scrolling)
    Layout.Padding = UDim.new(0, 5)

    -- Toggle Logic
    Toggle.MouseButton1Click:Connect(function()
        State.Enabled = not State.Enabled
        Toggle.Text = State.Enabled and "SYSTEM: ON" or "SYSTEM: OFF"
        Toggle.BackgroundColor3 = State.Enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)

    -- Scanner Logic
    local function ScanMaterials()
        local detected = {}
        for _, block in ipairs(BlocksFolder:GetChildren()) do
            if block:IsA("BasePart") and block.MaterialVariant ~= "" and not detected[block.MaterialVariant] then
                detected[block.MaterialVariant] = true
                local Btn = Instance.new("TextButton", Scrolling)
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.Text = block.MaterialVariant
                Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                Btn.TextColor3 = Color3.new(1, 1, 1)
                
                Btn.MouseButton1Click:Connect(function()
                    State.TargetMaterial = block.MaterialVariant
                    print("Architect: Locked onto " .. block.MaterialVariant)
                end)
            end
        end
    end
    ScanMaterials()
end

-- MAIN ENGINE: TELEPORT & EXECUTION
task.spawn(function()
    while true do
        if State.Enabled and State.TargetMaterial then
            local Character = LocalPlayer.Character
            local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
            
            if HRP then
                for _, block in ipairs(BlocksFolder:GetChildren()) do
                    if not State.Enabled then break end
                    
                    if block:IsA("BasePart") and block.MaterialVariant == State.TargetMaterial then
                        -- FORCE TELEPORT (PivotTo lebih stabil untuk karakter)
                        Character:PivotTo(block.CFrame * CFrame.new(0, 5, 0))
                        
                        -- LOCK ON DESTROY
                        repeat
                            if not State.Enabled then break end
                            Remote:FireServer(block)
                            task.wait(State.MiningSpeed)
                        until not block or not block.Parent or (not State.Enabled)
                    end
                end
            end
        end
        task.wait(1) -- Scan interval untuk efisiensi CPU
    end
end)

-- AUTO COLLECT ENGINE
DropsFolder.ChildAdded:Connect(function(drop)
    if State.Enabled then
        task.wait(0.1)
        local Character = LocalPlayer.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        if HRP and (drop:IsA("BasePart") or drop:IsA("Model")) then
            if drop:IsA("Model") then drop:PivotTo(HRP.CFrame) else drop.CFrame = HRP.CFrame end
        end
    end
end)

CreateArchitectUI()
print("Architect: System Initialized.")
