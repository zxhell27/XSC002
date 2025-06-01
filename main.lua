
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
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Make MainFrame draggable
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "ZXHELL - Zedlist Cultivation Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(1, -80, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 20
minimizeButton.Parent = mainFrame

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
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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

-- Open Menu Button (shown when main UI is hidden)
local openMenuButton = Instance.new("TextButton")
openMenuButton.Name = "OpenMenuButton"
openMenuButton.Size = UDim2.new(0, 150, 0, 40)
openMenuButton.Position = UDim2.new(0, 10, 0, 10)
openMenuButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
openMenuButton.BorderSizePixel = 0
openMenuButton.Text = "Open Menu"
openMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openMenuButton.Font = Enum.Font.SourceSansBold
openMenuButton.TextSize = 18
openMenuButton.Visible = false
openMenuButton.Parent = screenGui

-- Function to update status
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

-- Function to minimize the UI (reduce height to title only)
local function minimizeUI()
    mainFrame.Size = UDim2.new(0, 300, 0, 40)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    -- Hide all children except titleLabel, minimizeButton, closeButton
    for _, child in pairs(mainFrame:GetChildren()) do
        if child ~= titleLabel and child ~= minimizeButton and child ~= closeButton then
            child.Visible = false
        else
            child.Visible = true
        end
    end
    -- Hide minimize button (replace with restore button)
    minimizeButton.Visible = false
    -- Show a restore button instead
    if not mainFrame:FindFirstChild("RestoreButton") then
        local restoreButton = Instance.new("TextButton")
        restoreButton.Name = "RestoreButton"
        restoreButton.Size = UDim2.new(0, 40, 0, 40)
        restoreButton.Position = UDim2.new(1, -80, 0, 0)
        restoreButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        restoreButton.BorderSizePixel = 0
        restoreButton.Text = "+"
        restoreButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        restoreButton.Font = Enum.Font.SourceSansBold
        restoreButton.TextSize = 20
        restoreButton.Parent = mainFrame

        restoreButton.MouseButton1Click:Connect(function()
            restoreUI()
        end)
    else
        mainFrame.RestoreButton.Visible = true
    end
    closeButton.Visible = false
end

-- Function to restore the UI (original size)
function restoreUI()
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    -- Show all children again
    for _, child in pairs(mainFrame:GetChildren()) do
        child.Visible = true
    end
    -- Remove restore button if exists
    local restoreButton = mainFrame:FindFirstChild("RestoreButton")
    if restoreButton then
        restoreButton:Destroy()
    end
    minimizeButton.Visible = true
    closeButton.Visible = true
end

-- Minimize button click
minimizeButton.MouseButton1Click:Connect(function()
    minimizeUI()
end)

-- Close button click (hide mainFrame, show openMenuButton)
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openMenuButton.Visible = true
end)

-- Open menu button click (show mainFrame, hide openMenuButton)
openMenuButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openMenuButton.Visible = false
end)

--[[
Remaining code like running, updating status, etc., remains unchanged.
]]

-- Function to wait seconds (preserving original function)
local function waitSeconds(seconds)
    local start = tick()
    while tick() - start < seconds do
        wait()
    end
end

-- Example placeholder for the runCycle function and script's main logic
-- (Omitted here to keep focus on UI optimization & minimize/close fixes)
