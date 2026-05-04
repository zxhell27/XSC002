--[[
    PROJECT: ARCEUS X MINING SYSTEM (RE-ENGINEERED)
    ARCHITECT: ROBOX
    STATUS: BUG FIXED | STABLE
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Pastikan Remote Storage tersedia sebelum lanjut
local RemotePath = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("Chunks", 5):WaitForChild("damageBlock", 5)
if not RemotePath then warn("ARCHITECT: Remote tidak ditemukan!") return end

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- State Management
local State = {
    Enabled = false,
    TargetMaterial = nil,
    IsMining = false
}

-- UI CONSTRUCTOR (Robust Method)
local function CreateUI()
    -- Menggunakan pcall untuk menghindari crash total jika UI gagal dimuat
    local success, err = pcall(function()
        local Gui = Instance.new("ScreenGui")
        -- Gunakan CoreGui jika tersedia, jika tidak jatuh ke PlayerGui
        Gui.Parent = (game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")
        Gui.Name = "Architect_Pro_Miner"
        Gui.ResetOnSpawn = false

        local Main = Instance.new("Frame", Gui)
        Main.Size = UDim2.new(0, 220, 0, 280)
        Main.Position = UDim2.new(0.5, -110, 0.4, 0)
        Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Main.BorderSizePixel = 0
        Main.Active = true
        Main.Draggable = true -- Memudahkan user di mobile

        local Title = Instance.new("TextLabel", Main)
        Title.Size = UDim2.new(1, 0, 0, 35)
        Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Title.Text = "ARCHITECT AUTOMATION"
        Title.TextColor3 = Color3.new(1, 1, 1)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14

        local Toggle = Instance.new("TextButton", Main)
        Toggle.Name = "ToggleBtn" -- Memberi nama eksplisit agar tidak Nil
        Toggle.Size = UDim2.new(0.9, 0, 0, 45)
        Toggle.Position = UDim2.new(0.05, 0, 0.2, 0)
        Toggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        Toggle.Text = "STATUS: OFF"
        Toggle.TextColor3 = Color3.new(1, 1, 1)
        Toggle.Font = Enum.Font.GothamMedium

        local List = Instance.new("ScrollingFrame", Main)
        List.Size = UDim2.new(0.9, 0, 0, 150)
        List.Position = UDim2.new(0.05, 0, 0.4, 0)
        List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        List.CanvasSize = UDim2.new(0, 0, 0, 0)
        List.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local UIListLayout = Instance.new("UIListLayout", List)
        UIListLayout.Padding = UDim.new(0, 5)

        -- LOGIKA TOMBOL TOGGLE
        Toggle.MouseButton1Click:Connect(function()
            State.Enabled = not State.Enabled
            Toggle.Text = State.Enabled and "STATUS: ON" or "STATUS: OFF"
            Toggle.BackgroundColor3 = State.Enabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
        end)

        -- SCANNER & LIST POPULATOR
        local function PopulateList()
            local folder = Workspace:FindFirstChild("Blocks")
            if not folder then return end
            
            local foundMaterials = {}
            for _, block in ipairs(folder:GetChildren()) do
                if block:IsA("BasePart") and block.MaterialVariant ~= "" then
                    if not foundMaterials[block.MaterialVariant] then
                        foundMaterials[block.MaterialVariant] = true
                        
                        local MatBtn = Instance.new("TextButton", List)
                        MatBtn.Size = UDim2.new(1, -10, 0, 30)
                        MatBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        MatBtn.Text = block.MaterialVariant
                        MatBtn.TextColor3 = Color3.new(1, 1, 1)
                        
                        MatBtn.MouseButton1Click:Connect(function()
                            State.TargetMaterial = block.MaterialVariant
                            print("Targeted: " .. block.MaterialVariant)
                            -- Visual feedback
                            for _, v in ipairs(List:GetChildren()) do 
                                if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end 
                            end
                            MatBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                        end)
                    end
                end
            end
        end

        PopulateList()
    end)
    
    if not success then warn("ARCHITECT UI ERROR: " .. err) end
end

-- LOGIKA MINING & AUTO-COLLECT
task.spawn(function()
    while true do
        if State.Enabled and State.TargetMaterial then
            local Blocks = Workspace:FindFirstChild("Blocks")
            if Blocks then
                for _, block in ipairs(Blocks:GetChildren()) do
                    if not State.Enabled then break end
                    if block:IsA("BasePart") and block.MaterialVariant == State.TargetMaterial then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - block.Position).Magnitude
                            if dist < 30 then
                                -- Simulasi "Hold" dengan loop cepat ke remote
                                RemotePath:FireServer(block)
                                task.wait(0.05) 
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- AUTO COLLECT DROPS (PRECISION TELEPORT)
Workspace.Drops.ChildAdded:Connect(function(drop)
    if State.Enabled then
        task.wait(0.2) -- Menunggu drop stabil di server
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and drop:IsA("BasePart") then
            drop.CFrame = hrp.CFrame
        elseif hrp and drop:IsA("Model") then
            drop:SetPrimaryPartCFrame(hrp.CFrame)
        end
    end
end)

CreateUI()
