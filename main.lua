-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZedlistGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create MainFrame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Make MainFrame draggable
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "ZXHELL - Zedlist Cultivation Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Start Button
local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(0, 130, 0, 40)
startButton.Position = UDim2.new(0, 10, 1, -90)
startButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
startButton.BorderSizePixel = 0
startButton.Text = "▶ Start"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 20
startButton.Parent = mainFrame

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 130, 0, 40)
stopButton.Position = UDim2.new(0, 160, 1, -90)
stopButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
stopButton.BorderSizePixel = 0
stopButton.Text = "■ Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 20
stopButton.Parent = mainFrame

-- Function to update status
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

-- Function to wait for a certain number of seconds
local function waitSeconds(seconds)
    local start = tick()
    while tick() - start < seconds do
        wait()
    end
end

-- Main script execution
local running = false
local stopUpdateQi = false

local function runCycle()
    updateStatus("Running Cycle...")
    -- 1. Jalankan Reincarnate
    local args = {}
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Reincarnate"):FireServer(unpack(args))

    -- 2. Perulangan IncreaseAptitude & Mine (tanpa henti)
    spawn(function()
        while running do
            local args = {}
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("IncreaseAptitude"):FireServer(unpack(args))
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Mine"):FireServer(unpack(args))
            wait()
        end
    end)

    -- 3. UpdateQi setiap 1 detik (dihentikan saat Comprehend)
    stopUpdateQi = false
    spawn(function()
        while running and not stopUpdateQi do
            local args = {}
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateQi"):FireServer(unpack(args))
            wait(1)
        end
    end)

    -- 4. Tunggu 1 menit, lalu beli item batch 1
    waitSeconds(60)
    local itemList1 = {
        "Nine Heavens Galaxy Water",
        "Buzhou Divine Flower",
        "Fusang Divine Tree",
        "Calm Cultivation Mat"
    }
    for _, item in ipairs(itemList1) do
        local args = { [1] = item }
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BuyItem"):FireServer(unpack(args))
    end

    -- 5. Tunggu 30 detik setelah beli item
    waitSeconds(30)

    -- 6. Ganti map: immortal → chaos
    local function changeMap(mapName)
        local args = { [1] = mapName }
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer(unpack(args))
    end
    changeMap("immortal")
    changeMap("chaos")

    -- 7. Jalankan ChaoticRoad
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChaoticRoad"):FireServer(unpack({}))

    -- 8. Tunggu 1 menit sambil updateQi, lalu beli item batch 2
    local tempStop = stopUpdateQi
    stopUpdateQi = false
    waitSeconds(60)
    local itemList2 = {
        "Traceless Breeze Lotus",
        "Reincarnation World Destruction Black Lotus",
        "Ten Thousand Bodhi Tree"
    }
    for _, item in ipairs(itemList2) do
        local args = { [1] = item }
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BuyItem"):FireServer(unpack(args))
    end
    stopUpdateQi = tempStop

    -- 9. Kembali ke map immortal
    changeMap("immortal")

    -- 10. Jalankan HiddenRemote
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("HiddenRemote"):FireServer(unpack({}))

    -- 11. Tunggu 1 menit
    waitSeconds(60)

    -- 12. Masuk ke ForbiddenZone
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ForbiddenZone"):FireServer(unpack({}))

    -- 13. Jalankan Comprehend selama 2 menit (hentikan UpdateQi sementara)
    stopUpdateQi = true
    local startTime = tick()
    while tick() - startTime < 120 do
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Comprehend"):FireServer(unpack({}))
        wait()
    end

    -- 14. Lanjutkan UpdateQi selama 2 menit
    stopUpdateQi = false
    waitSeconds(120)
    stopUpdateQi = true -- hentikan sebelum mulai siklus lagi
end

-- Start Button Click
startButton.MouseButton1Click:Connect(function()
    running = true
    updateStatus("Cycle Started")
    while running do
        runCycle()
    end
end)

-- Stop Button Click
stopButton.MouseButton1Click:Connect(function()
    running = false
    updateStatus("Cycle Stopped")
end)

-- Initialize UI
updateStatus("Idle")
