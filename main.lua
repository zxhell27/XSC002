-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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
titleLabel.Text = "Zedlist Cultivation Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -40, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Parent = mainFrame

-- Input Fields
local inputLabels = {
    "Delay sebelum beli item 1 (detik)",
    "Delay sebelum ganti map (detik)",
    "Delay sebelum beli item 2 (detik)",
    "Durasi Comprehend (detik)",
    "Durasi UpdateQi sesudahnya (detik)"
}

local inputBoxes = {}

for i, labelText in ipairs(inputLabels) do
    local yPosition = 50 + (i - 1) * 50

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Position = UDim2.new(0, 10, 0, yPosition)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 80, 0, 25)
    textBox.Position = UDim2.new(0, 210, 0, yPosition)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.BorderSizePixel = 0
    textBox.Text = "60"
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    textBox.Parent = mainFrame

    table.insert(inputBoxes, textBox)
end

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

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 1, -40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Open Menu"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14
toggleButton.Visible = false
toggleButton.Parent = screenGui

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
    while running do
        updateStatus("Reincarnating")
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Reincarnate"):FireServer({})

        -- Infinite loop process
        spawn(function()
            while running do
                ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("IncreaseAptitude"):FireServer({})
                ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Mine"):FireServer({})
                wait()
            end
        end)

        -- Update Qi Loop
        stopUpdateQi = false
        spawn(function()
            while running and not stopUpdateQi do
                ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateQi"):FireServer({})
                wait(1)
            end
        end)

        -- Delay sebelum beli item pertama
        waitSeconds(tonumber(inputBoxes[1].Text))

        updateStatus("Buying Item Batch 1")
        for _, item in ipairs({
            "Nine Heavens Galaxy Water",
            "Buzhou Divine Flower",
            "Fusang Divine Tree",
            "Calm Cultivation Mat"
        }) do
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BuyItem"):FireServer({item})
        end

        -- Delay sebelum ganti map
        waitSeconds(tonumber(inputBoxes[2].Text))

        updateStatus("Changing Map")
        local function changeMap(name)
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChangeMap"):FireServer({name})
        end
        changeMap("immortal")
        changeMap("chaos")

        updateStatus("Chaotic Road")
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ChaoticRoad"):FireServer({})

        -- Delay sebelum beli item kedua
        waitSeconds(tonumber(inputBoxes[3].Text))

        updateStatus("Buying Item Batch 2")
        for _, item in ipairs({
            "Traceless Breeze Lotus",
            "Reincarnation World Destruction Black Lotus",
            "Ten Thousand Bodhi Tree"
        }) do
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BuyItem"):FireServer({item})
        end

        updateStatus("Returning to Immortal")
        changeMap("immortal")

        updateStatus("Hidden Remote")
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("HiddenRemote"):FireServer({})

        waitSeconds(60)

        updateStatus("Entering Forbidden Zone")
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AreaEvents"):WaitForChild("ForbiddenZone"):FireServer({})

        -- Comprehend
        updateStatus("Comprehending")
        stopUpdateQi = true
        local startTime = tick()
        while tick() - startTime < tonumber(inputBoxes[4].Text) do
            if not running then return end
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Comprehend"):FireServer({})
            wait()
        end

        -- UpdateQi again
        updateStatus("Final UpdateQi")
        stopUpdateQi = false
        waitSeconds(tonumber(inputBoxes[5].Text))
        stopUpdateQi = true

        updateStatus("Cycle Complete - Restarting")
    end
end

 

