-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer
if not player then
    -- Jika script berjalan di environment dimana LocalPlayer tidak langsung tersedia
    -- (sangat jarang untuk LocalScript di PlayerGui, tapi sebagai tindakan pencegahan)
    warn("LocalPlayer not available at script start. Waiting...")
    Players.PlayerAdded:Wait() -- Ini akan menunggu player manapun, bukan spesifik LocalPlayer
    player = Players.LocalPlayer
    if not player then
        error("Fatal: LocalPlayer could not be determined.")
        return -- Hentikan eksekusi script
    end
end
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

-- Fungsi untuk memperbarui label status
local function updateStatus(newStatus)
    if statusLabel and statusLabel.Parent then -- Pastikan statusLabel masih ada
        statusLabel.Text = "Status: " .. tostring(newStatus)
        -- print("Status Updated: " .. tostring(newStatus)) -- Uncomment untuk debugging
    else
        warn("Attempted to update status, but statusLabel is nil or removed. Status: " .. tostring(newStatus))
    end
end

local running = false
local stopUpdateQi = false 

-- Fungsi tunggu yang diperbarui dengan pemeriksaan 'running' dan update timer
local function waitSeconds(secondsToWait)
    local startTime = tick()
    while tick() - startTime < secondsToWait and running do
        local elapsed = math.floor(tick() - startTime)
        local remaining = math.max(0, secondsToWait - elapsed)
        if timerLabel and timerLabel.Parent then
            timerLabel.Text = "Timer: "..formatTime(remaining)
        end
        wait(1)
    end
    if timerLabel and timerLabel.Parent then
        timerLabel.Text = "Timer: 00:00" -- Selalu reset timer jika waktu tunggu selesai atau dihentikan
    end
end

-- Fungsi untuk mendapatkan input angka yang aman dari TextBox
local function safeNumberInput(textBox, default)
    if not (textBox and textBox:IsA("TextBox")) then return default end
    local num = tonumber(textBox.Text)
    if num == nil or num <= 0 then
        return default
    end
    return num
end

-- Fungsi utama untuk menjalankan satu siklus
local function runCycle()
    -- Fungsi wrapper untuk memanggil RemoteEvent dengan aman menggunakan pcall
    local function safeFireServer(remoteEvent, ...)
        if not remoteEvent then
            warn("safeFireServer called with a nil RemoteEvent.")
            updateStatus("Error: Internal script error (nil remote)")
            running = false
            return false
        end
        
        local success, errOrResult = pcall(function()
            remoteEvent:FireServer(...)
        end)
        
        if not success then
            warn("Error firing RemoteEvent '"..remoteEvent.Name.."':", errOrResult)
            updateStatus("Error with: "..remoteEvent.Name)
            running = false -- Hentikan siklus jika ada error kritis saat FireServer
        end
        return success
    end
    
    -- Pastikan RemoteEvents folder ada
    local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10) -- Tunggu maksimal 10 detik
    if not remoteEventsFolder then
        updateStatus("Error: RemoteEvents folder missing!")
        running = false
        return
    end

    -- Fungsi helper untuk mendapatkan RemoteEvent dengan aman
    local function getRemote(folder, name)
        if not folder then return nil end
        local event = folder:FindFirstChild(name)
        if not event then
            warn("RemoteEvent not found: '"..name.."' in folder '"..folder.Name.."'")
            updateStatus("Error: Missing event '"..name.."'")
            running = false -- Hentikan jika event penting tidak ada
        end
        return event
    end
    
    local areaEventsFolder = getRemote(remoteEventsFolder, "AreaEvents")
    if not areaEventsFolder then 
        -- getRemote sudah set running = false dan updateStatus
        return 
    end
    
    -- --- MULAI SIKLUS ---
    if not running then return end -- Cek sebelum setiap langkah besar
    updateStatus("Reincarnating...")
    local reincarnateEvent = getRemote(remoteEventsFolder, "Reincarnate")
    if not safeFireServer(reincarnateEvent) then return end

    -- Spawn thread untuk IncreaseAptitude dan Mine
    local aptitudeMineThread
    aptitudeMineThread = coroutine.create(function() -- Menggunakan coroutine untuk kontrol yang lebih baik
        local increaseAptitudeEvent = getRemote(remoteEventsFolder, "IncreaseAptitude")
        local mineEvent = getRemote(remoteEventsFolder, "Mine")
        if not (increaseAptitudeEvent and mineEvent) then return end

        while running do
            if not safeFireServer(increaseAptitudeEvent) then break end
            if not safeFireServer(mineEvent) then break end
            wait() 
        end
    end)
    coroutine.resume(aptitudeMineThread)

    -- Spawn thread untuk UpdateQi
    stopUpdateQi = false 
    local updateQiThread
    updateQiThread = coroutine.create(function()
        local updateQiEvent = getRemote(remoteEventsFolder, "UpdateQi")
        if not updateQiEvent then return end
        
        while running and not stopUpdateQi do
            if not safeFireServer(updateQiEvent) then break end
            wait(1)
        end
    end)
    coroutine.resume(updateQiThread)

    if not running then return end
    local itemList1 = {
        "Nine Heavens Galaxy Water", "Buzhou Divine Flower",
        "Fusang Divine Tree", "Calm Cultivation Mat"
    }
    local buyItemEvent = getRemote(remoteEventsFolder, "BuyItem")
    for _, item in ipairs(itemList1) do
        if not running then return end 
        if not safeFireServer(buyItemEvent, item) then return end
    end

    if not running then return end
    local waitAfterBatch1 = safeNumberInput(waitAfterBatch1Input, 90)
    updateStatus("Waiting " .. waitAfterBatch1 .. "s after Batch 1")
    waitSeconds(waitAfterBatch1)

    if not running then return end
    local changeMapEvent = getRemote(areaEventsFolder, "ChangeMap")
    if not safeFireServer(changeMapEvent, "immortal") then return end
    if not running then return end
    if not safeFireServer(changeMapEvent, "chaos") then return end

    if not running then return end
    updateStatus("Running ChaoticRoad")
    local chaoticRoadEvent = getRemote(areaEventsFolder, "ChaoticRoad")
    if not safeFireServer(chaoticRoadEvent) then return end

    if not running then return end
    local waitAfterChaoticRoad = safeNumberInput(waitAfterChaoticRoadInput, 40)
    updateStatus("Waiting " .. waitAfterChaoticRoad .. "s after ChaoticRoad")
    waitSeconds(waitAfterChaoticRoad)

    if not running then return end
    local itemList2 = {
        "Traceless Breeze Lotus", "Reincarnation World Destruction Black Lotus",
        "Ten Thousand Bodhi Tree"
    }
    for _, item in ipairs(itemList2) do
        if not running then return end
        if not safeFireServer(buyItemEvent, item) then return end
    end
    
    if not running then return end
    if not safeFireServer(changeMapEvent, "immortal") then return end

    if not running then return end
    local hiddenRemoteEvent = getRemote(areaEventsFolder, "HiddenRemote")
    if not safeFireServer(hiddenRemoteEvent) then return end

    if not running then return end
    local waitBeforeForbidden = safeNumberInput(waitBeforeForbiddenInput, 60)
    updateStatus("Waiting " .. waitBeforeForbidden .. "s before ForbiddenZone")
    waitSeconds(waitBeforeForbidden)

    if not running then return end
    updateStatus("Entering ForbiddenZone")
    local forbiddenZoneEvent = getRemote(areaEventsFolder, "ForbiddenZone")
    if not safeFireServer(forbiddenZoneEvent) then return end

    if not running then return end
    local comprehendDuration = safeNumberInput(comprehendDurationInput, 120)
    updateStatus("Comprehending " .. comprehendDuration .. "s")
    stopUpdateQi = true 
    
    local comprehendStartTime = tick()
    local comprehendEvent = getRemote(remoteEventsFolder, "Comprehend")
    while tick() - comprehendStartTime < comprehendDuration and running do
        if not safeFireServer(comprehendEvent) then break end
        local elapsed = math.floor(tick() - comprehendStartTime)
        local remaining = math.max(0, comprehendDuration - elapsed)
        if timerLabel and timerLabel.Parent then
            timerLabel.Text = "Timer: " .. formatTime(remaining)
        end
        wait(1)
    end
    if timerLabel and timerLabel.Parent then timerLabel.Text = "Timer: 00:00" end

    if not running then return end
    local updateQiDuration = safeNumberInput(updateQiDurationInput, 300)
    updateStatus("UpdateQi for " .. updateQiDuration .. "s")
    stopUpdateQi = false 
    waitSeconds(updateQiDuration) 

    stopUpdateQi = true 
    if timerLabel and timerLabel.Parent then timerLabel.Text = "Timer: 00:00" end
    if running then -- Hanya tampilkan ini jika siklus selesai secara normal dan masih 'running'
        updateStatus("Cycle finished. Restarting...")
    end
end

-- Tombol Start
startButton.MouseButton1Click:Connect(function()
    if not running then
        running = true
        updateStatus("Cycle Started")
        
        -- Menjalankan siklus utama dalam coroutine baru untuk mencegah pembekuan GUI
        -- dan memungkinkan penanganan error yang lebih baik dalam siklus tersebut.
        local mainCycleCoroutine = coroutine.create(function()
            while running do
                runCycle() -- Panggil fungsi siklus
                if not running then -- Jika runCycle (atau sesuatu di dalamnya) mengubah running menjadi false
                    break
                end
                -- Beri jeda singkat sebelum memulai siklus berikutnya jika masih berjalan
                -- Ini juga memberi kesempatan untuk flag 'running' diperbarui oleh tombol stop.
                wait(1) 
            end
            
            -- Setelah loop selesai (baik karena 'running' jadi false atau error yang tidak tertangani di atas)
            if not (statusLabel and statusLabel.Text == "Status: Cycle Stopping...") then
                 updateStatus("Cycle Stopped")
            end
            if timerLabel and timerLabel.Parent then timerLabel.Text = "Timer: 00:00" end
        end)
        coroutine.resume(mainCycleCoroutine)
    end
end)

-- Tombol Stop
stopButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        updateStatus("Cycle Stopping...") 
        -- Loop di coroutine utama akan berhenti karena flag 'running' sudah false.
        -- Semua fungsi waitSeconds dan loop internal juga harus memeriksa flag 'running'.
    end
end)

-- Inisialisasi UI saat skrip dimuat
updateStatus("Idle")
if timerLabel and timerLabel.Parent then timerLabel.Text = "Timer: 00:00" end

print("Zedlist Cultivation Script Loaded and UI Initialized.")
