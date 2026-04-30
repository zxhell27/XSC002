local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- ==========================================
-- 1. UI SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoKillUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ToggleBtn.Text = "AUTO KILL MODE"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", MainFrame)
Instance.new("UICorner", ToggleBtn)

-- ==========================================
-- 2. LOGIKA AUTO KILL (PULL TO BLOCK1)
-- ==========================================
local lockedPos = nil

local function autoKillFarm()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    -- Path: workspace.Block1.Track
    local block1 = workspace:FindFirstChild("Block1")
    local trackTarget = block1 and block1:FindFirstChild("Track")
    local enemyFolder = workspace:FindFirstChild("Enemy")

    if not hrp or not trackTarget then return end

    -- 1. Kunci posisi kamu di belakang kereta agar aman (Hanya sekali set)
    if not lockedPos then
        -- Kamu diam di koordinat rel yang sudah dilewati (150 stud di belakang)
        lockedPos = trackTarget.CFrame * CFrame.new(0, 10, 150)
    end
    
    hrp.Anchored = true
    hrp.CFrame = lockedPos

    -- 2. Tarik paksa semua musuh ke DALAM Block1 agar mati otomatis
    if enemyFolder then
        local enemies = enemyFolder:GetChildren()
        for _, enemy in ipairs(enemies) do
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            if eHrp then
                -- Menaruh musuh tepat di posisi Block1 (Kill Zone)
                -- Kita beri sedikit offset agar benar-benar masuk ke tengah block
                eHrp.CFrame = trackTarget.CFrame * CFrame.new(0, 0, 0)
                
                -- Opsional: Matikan velocity agar mereka tidak terdorong keluar dari block
                eHrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- ==========================================
-- 3. TOGGLE HANDLER
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        lockedPos = nil -- Reset posisi agar mengambil koordinat baru saat aktif
        ToggleBtn.Text = "KILLER ACTIVE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        loopConnection = RunService.Heartbeat:Connect(autoKillFarm)
    else
        ToggleBtn.Text = "AUTO KILL MODE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        if loopConnection then loopConnection:Disconnect() end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end)
