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
mainFrame.Size = UDim2.new(0, 300, 0, 440) -- Extra height for timer
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -220)
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

-- Timer Label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, -20, 0, 25)
timerLabel.Position = UDim2.new(0, 10, 0, 85)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Timer: 00:00"
timerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
timerLabel.Font = Enum.Font.SourceSansItalic
timerLabel.TextSize = 16
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = mainFrame

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

-- Function to format seconds to MM:SS
local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

local running = false
local stopUpdateQi = false

-- Modified waitSeconds with timer display and stop check
local function waitSeconds(seconds)
    local start = tick()
    while tick() - start < seconds and running do
        local elapsed = math.floor(tick() - start)
        local remaining = math.max(0, seconds - elapsed)
        timerLabel.Text = "Timer: " .. formatTime(remaining)
        wait(1)
    end
    timerLabel.Text = "Timer: 00:00"
end

local function runCycle()
    updateStatus("Reincarnating...")
    local args = {}
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Reincarnate"):FireServer(unpack(args))

    spawn(function()
        while running do
            local args = {}
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("IncreaseAptitude"):FireServer(unpack(args))
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Mine"):FireServer(unpack(args))
            wait()
        end
    end)

    stopUpdateQi = false
    spawn(function()
        while running and not stopUpdateQi do
            local args = {}
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateQi"):FireServer(unpack(args))
            wait(1)
        end
    end)

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

    updateStatus("Waiting 1:30")
    waitSeconds(90)

    local args = { [1] = "immortal" }
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer(unpack(args))

    args = { [1] = "chaos" }
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer(unpack(args))

    updateStatus("Running ChaoticRoad")
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChaoticRoad"):FireServer(unpack({}))

    updateStatus("Waiting 0:40")
    waitSeconds(40)

    local itemList2 = {
        "Traceless Breeze Lotus",
        "Reincarnation World Destruction Black Lotus",
        "Ten Thousand Bodhi Tree"
    }
    for _, item in ipairs(itemList2) do
        local args = { [1] = item }
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BuyItem"):FireServer(unpack(args))
    end

    args = { [1] = "immortal" }
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer(unpack(args))

    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("HiddenRemote"):FireServer(unpack({}))

    updateStatus("Waiting 1:00")
    waitSeconds(60)

    updateStatus("Entering ForbiddenZone")
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ForbiddenZone"):FireServer(unpack({}))

    updateStatus("Comprehend 2:00")
    stopUpdateQi = true
    local startTime = tick()
    while tick() - startTime < 120 and running do
        local args = {}
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Comprehend"):FireServer(unpack(args))
        local remaining = math.max(0,120 - math.floor(tick() - startTime))
        timerLabel.Text = "Timer: " .. formatTime(remaining)
        wait(1)
    end

    updateStatus("UpdateQi 5:00")
    stopUpdateQi = false
    waitSeconds(300)

    stopUpdateQi = true
    timerLabel.Text = "Timer: 00:00"
end

startButton.MouseButton1Click:Connect(function()
    if not running then
        running = true
        updateStatus("Cycle Started")
        spawn(function()
            while running do
                runCycle()
            end
        end)
    end
end)

stopButton.MouseButton1Click:Connect(function()
    running = false
    updateStatus("Cycle Stopped")
    timerLabel.Text = "Timer: 00:00"
end)

updateStatus("Idle")
