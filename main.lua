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
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "ZXHELL - Zedlist Cultivation Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 22
titleLabel.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Timer Label
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -20, 0, 25)
timerLabel.Position = UDim2.new(0, 10, 0, 70)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Timer: 00:00"
timerLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
timerLabel.Font = Enum.Font.SourceSansItalic
timerLabel.TextSize = 16
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = mainFrame

-- Helper function to create label and textbox for seconds input
local function createLabeledInput(text, positionY, defaultValue)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 25)
    label.Position = UDim2.new(0, 10, 0, positionY)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.25, 0, 0, 25)
    textBox.Position = UDim2.new(0.72, 0, 0, positionY)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(defaultValue)
    textBox.ClearTextOnFocus = false
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 14
    textBox.Parent = mainFrame

    return textBox
end

-- Create inputs for each wait duration
local waitAfterBatch1Input = createLabeledInput("Wait after buying Batch 1 (seconds)", 105, 90)
local waitAfterChaoticRoadInput = createLabeledInput("Wait after ChaoticRoad (seconds)", 135, 40)
local waitBeforeForbiddenInput = createLabeledInput("Wait before ForbiddenZone (seconds)", 165, 60)
local comprehendDurationInput = createLabeledInput("Comprehend duration (seconds)", 195, 120)
local updateQiDurationInput = createLabeledInput("UpdateQi duration (seconds)", 225, 300)

-- Start Button
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 160, 0, 40)
startButton.Position = UDim2.new(0, 20, 1, -60)
startButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
startButton.BorderSizePixel = 0
startButton.Text = "▶ Start"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 20
startButton.Parent = mainFrame

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 160, 0, 40)
stopButton.Position = UDim2.new(0, 180, 1, -60)
stopButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
stopButton.BorderSizePixel = 0
stopButton.Text = "■ Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 20
stopButton.Parent = mainFrame

-- Utility: format seconds MM:SS
local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

local running = false
local stopUpdateQi = false

-- Updated waitSeconds with timer and stop check
local function waitSeconds(seconds)
    local start = tick()
    while tick() - start < seconds and running do
        local elapsed = math.floor(tick() - start)
        local remaining = math.max(0, seconds - elapsed)
        timerLabel.Text = "Timer: "..formatTime(remaining)
        wait(1)
    end
    timerLabel.Text = "Timer: 00:00"
end

local function safeNumberInput(textBox, default)
    local num = tonumber(textBox.Text)
    if num == nil or num <= 0 then
        return default
    end
    return num
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

    local waitAfterBatch1 = safeNumberInput(waitAfterBatch1Input, 90)
    updateStatus("Waiting " .. waitAfterBatch1 .. " seconds after Batch 1")
    waitSeconds(waitAfterBatch1)

    local args = { [1] = "immortal" }
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer(unpack(args))

    args = { [1] = "chaos" }
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer(unpack(args))

    updateStatus("Running ChaoticRoad")
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChaoticRoad"):FireServer(unpack({}))

    local waitAfterChaoticRoad = safeNumberInput(waitAfterChaoticRoadInput, 40)
    updateStatus("Waiting " .. waitAfterChaoticRoad .. " seconds after ChaoticRoad")
    waitSeconds(waitAfterChaoticRoad)

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

    local waitBeforeForbidden = safeNumberInput(waitBeforeForbiddenInput, 60)
    updateStatus("Waiting " .. waitBeforeForbidden .. " seconds before ForbiddenZone")
    waitSeconds(waitBeforeForbidden)

    updateStatus("Entering ForbiddenZone")
    ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ForbiddenZone"):FireServer(unpack({}))

    local comprehendDuration = safeNumberInput(comprehendDurationInput, 120)
    updateStatus("Comprehending " .. comprehendDuration .. " seconds")
    stopUpdateQi = true
    local startTime = tick()
    while tick() - startTime < comprehendDuration and running do
        local args = {}
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Comprehend"):FireServer(unpack(args))
        local remaining = math.max(0, comprehendDuration - math.floor(tick() - startTime))
        timerLabel.Text = "Timer: " .. formatTime(remaining)
        wait(1)
    end

    local updateQiDuration = safeNumberInput(updateQiDurationInput, 300)
    updateStatus("UpdateQi for " .. updateQiDuration .. " seconds")
    stopUpdateQi = false
    waitSeconds(updateQiDuration)

    stopUpdateQi = true
    timerLabel.Text = "Timer: 00:00"
end

-- Buttons
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

-- Initialize UI
updateStatus("Idle")
