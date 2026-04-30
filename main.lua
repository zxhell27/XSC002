local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRunning = false
local loopConnection = nil

-- Remote dari TurtleSpy
local weaponRemote = workspace:FindFirstChild("Lutung055") and workspace.Lutung055:FindFirstChild("Weapon") and workspace.Lutung055.Weapon:FindFirstChild("revent")

-- ==========================================
-- UI SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrainFollowUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Text = "FOLLOW TRAIN"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", MainFrame)
Instance.new("UICorner", ToggleBtn)

-- ==========================================
-- LOGIKA UTAMA (RELATIVE MOVEMENT)
-- ==========================================
local function moveWithTrain()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    local trackTarget = workspace:FindFirstChild("Block1") and workspace.Block1:FindFirstChild("Track")
    local enemyFolder = workspace:FindFirstChild("Enemy")

    if not hrp or not trackTarget then return end

    -- JANGAN gunakan Anchored agar bisa mengikuti pergerakan physics kereta
    hrp.Anchored = false 
    
    -- Paksa posisi karakter tepat di atas Track (mengikuti pergerakan Track setiap frame)
    hrp.CFrame = trackTarget.CFrame * CFrame.new(0, 3, 0)
    
    -- Matikan momentum agar tidak terpental karena kecepatan kereta
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)

    if enemyFolder then
        local enemies = enemyFolder:GetChildren()
        if #enemies > 0 then
            local targetEnemy = enemies[3] or enemies[1]
            
            for _, enemy in ipairs(enemies) do
                local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                if eHrp then
                    -- Tarik musuh agar SELALU di depan Track (ikut bergerak maju bersama kereta)
                    eHrp.CFrame = trackTarget.CFrame * CFrame.new(0, 0, -10)
                    eHrp.Velocity = Vector3.new(0, 0, 0)
                end
            end

            -- Auto Hit Remote
            if weaponRemote and targetEnemy:FindFirstChild("HumanoidRootPart") then
                weaponRemote:FireServer("bullet", "Bu1", CFrame.new(hrp.Position, targetEnemy.HumanoidRootPart.Position))
            end
        end
    end
end

-- ==========================================
-- TOGGLE HANDLER
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "FOLLOWING..."
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        -- Menggunakan RenderStepped adalah cara tercepat agar tidak ketinggalan kereta
        loopConnection = RunService.RenderStepped:Connect(moveWithTrain)
    else
        ToggleBtn.Text = "FOLLOW TRAIN"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        if loopConnection then loopConnection:Disconnect() end
    end
end)
