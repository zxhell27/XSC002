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

-- <<<< PERBAIKAN UTAMA: Definisi fungsi updateStatus >>>>
local function updateStatus(newStatus)
    if statusLabel then
        statusLabel.Text = "Status: " .. tostring(newStatus)
        -- print("Status Updated: " .. tostring(newStatus)) -- Uncomment untuk debugging di console
    else
        warn("Error: statusLabel is nil. Cannot update status to: " .. tostring(newStatus))
    end
end

local running = false
local stopUpdateQi = false -- Flag untuk mengontrol loop UpdateQi secara spesifik

-- Updated waitSeconds with timer and stop check
local function waitSeconds(secondsToWait) -- Mengganti nama parameter agar lebih jelas
    local startTime = tick()
    while tick() - startTime < secondsToWait and running do
        local elapsed = math.floor(tick() - startTime)
        local remaining = math.max(0, secondsToWait - elapsed)
        timerLabel.Text = "Timer: "..formatTime(remaining)
        wait(1) -- Tunggu 1 detik
    end
    if running then -- Hanya reset timer jika siklus masih berjalan dan waktu tunggu selesai
        timerLabel.Text = "Timer: 00:00"
    end
end

local function safeNumberInput(textBox, default)
    local num = tonumber(textBox.Text)
    if num == nil or num <= 0 then
        return default
    end
    return num
end

-- Fungsi untuk melakukan satu siklus penuh
local function runCycle()
    -- Menggunakan pcall untuk menangani potensi error saat FireServer
    local function safeFireServer(remoteEvent, ...)
        local success, err = pcall(function()
            remoteEvent:FireServer(...)
        end)
        if not success then
            warn("Error firing RemoteEvent "..remoteEvent.Name..":", err)
            updateStatus("Error: "..remoteEvent.Name)
            running = false -- Hentikan siklus jika ada error kritis
        end
        return success
    end
    
    -- Pastikan RemoteEvents folder ada
    local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
    if not remoteEventsFolder then
        updateStatus("Error: RemoteEvents folder missing!")
        running = false
        return
    end

    -- Fungsi helper untuk mendapatkan RemoteEvent dengan aman
    local function getRemote(name)
        local event = remoteEventsFolder:FindFirstChild(name)
        if not event then
            warn("RemoteEvent not found:", name)
            updateStatus("Error: Missing event "..name)
            running = false -- Hentikan jika event penting tidak ada
        end
        return event
    end
    
    local areaEventsFolder = remoteEventsFolder:FindFirstChild("AreaEvents")
    if not areaEventsFolder then
        updateStatus("Error: AreaEvents folder missing!")
        running = false
        return
    end
    
    local function getAreaRemote(name)
        local event = areaEventsFolder:FindFirstChild(name)
        if not event then
            warn("AreaRemoteEvent not found:", name)
            updateStatus("Error: Missing area event "..name)
            running = false
        end
        return event
    end

    updateStatus("Reincarnating...")
    local reincarnateEvent = getRemote("Reincarnate")
    if not reincarnateEvent or not safeFireServer(reincarnateEvent) then return end

    -- Spawn thread untuk IncreaseAptitude dan Mine
    local aptitudeMineThread
    aptitudeMineThread = spawn(function()
        local increaseAptitudeEvent = getRemote("IncreaseAptitude")
        local mineEvent = getRemote("Mine")
        if not increaseAptitudeEvent or not mineEvent then 
            running = false -- Hentikan jika event penting tidak ada
            return -- Keluar dari thread ini jika event tidak ditemukan
        end

        while running do
            if not safeFireServer(increaseAptitudeEvent) then break end
            if not safeFireServer(mineEvent) then break end
            wait() -- Beri sedikit jeda agar tidak membebani server
        end
    end)

    -- Spawn thread untuk UpdateQi
    stopUpdateQi = false -- Reset flag sebelum memulai loop baru
    local updateQiThread
    updateQiThread = spawn(function()
        local updateQiEvent = getRemote("UpdateQi")
        if not updateQiEvent then 
            running = false
            return 
        end
        
        while running and not stopUpdateQi do
            if not safeFireServer(updateQiEvent) then break end
            wait(1)
        end
    end)

    local itemList1 = {
        "Nine Heavens Galaxy Water",
        "Buzhou Divine Flower",
        "Fusang Divine Tree",
        "Calm Cultivation Mat"
    }
    local buyItemEvent = getRemote("BuyItem")
    if not buyItemEvent then return end
    for _, item in ipairs(itemList1) do
        if not running then return end -- Periksa flag running sebelum setiap aksi
        if not safeFireServer(buyItemEvent, item) then return end
    end

    local waitAfterBatch1 = safeNumberInput(waitAfterBatch1Input, 90)
    updateStatus("Waiting " .. waitAfterBatch1 .. "s after Batch 1")
    waitSeconds(waitAfterBatch1)
    if not running then return end

    local changeMapEvent = getAreaRemote("ChangeMap")
    if not changeMapEvent then return end
    if not safeFireServer(changeMapEvent, "immortal") then return end
    if not running then return end
    if not safeFireServer(changeMapEvent, "chaos") then return end
    if not running then return end

    updateStatus("Running ChaoticRoad")
    local chaoticRoadEvent = getAreaRemote("ChaoticRoad")
    if not chaoticRoadEvent or not safeFireServer(chaoticRoadEvent) then return end
    if not running then return end

    local waitAfterChaoticRoad = safeNumberInput(waitAfterChaoticRoadInput, 40)
    updateStatus("Waiting " .. waitAfterChaoticRoad .. "s after ChaoticRoad")
    waitSeconds(waitAfterChaoticRoad)
    if not running then return end

    local itemList2 = {
        "Traceless Breeze Lotus",
        "Reincarnation World Destruction Black Lotus",
        "Ten Thousand Bodhi Tree"
    }
    -- buyItemEvent sudah didapatkan sebelumnya
    for _, item in ipairs(itemList2) do
        if not running then return end
        if not safeFireServer(buyItemEvent, item) then return end
    end
    if not running then return end
    
    if not safeFireServer(changeMapEvent, "immortal") then return end
    if not running then return end

    local hiddenRemoteEvent = getAreaRemote("HiddenRemote")
    if not hiddenRemoteEvent or not safeFireServer(hiddenRemoteEvent) then return end
    if not running then return end

    local waitBeforeForbidden = safeNumberInput(waitBeforeForbiddenInput, 60)
    updateStatus("Waiting " .. waitBeforeForbidden .. "s before ForbiddenZone")
    waitSeconds(waitBeforeForbidden)
    if not running then return end

    updateStatus("Entering ForbiddenZone")
    local forbiddenZoneEvent = getAreaRemote("ForbiddenZone")
    if not forbiddenZoneEvent or not safeFireServer(forbiddenZoneEvent) then return end
    if not running then return end

    local comprehendDuration = safeNumberInput(comprehendDurationInput, 120)
    updateStatus("Comprehending " .. comprehendDuration .. "s")
    stopUpdateQi = true -- Hentikan UpdateQi selama comprehend
    
    local comprehendStartTime = tick()
    local comprehendEvent = getRemote("Comprehend")
    if not comprehendEvent then return end

    while tick() - comprehendStartTime < comprehendDuration and running do
        if not safeFireServer(comprehendEvent) then break end
        local elapsed = math.floor(tick() - comprehendStartTime)
        local remaining = math.max(0, comprehendDuration - elapsed)
        timerLabel.Text = "Timer: " .. formatTime(remaining)
        wait(1)
    end
    if not running then return end
    timerLabel.Text = "Timer: 00:00" -- Reset timer setelah comprehend selesai atau dihentikan

    local updateQiDuration = safeNumberInput(updateQiDurationInput, 300)
    updateStatus("UpdateQi for " .. updateQiDuration .. "s")
    stopUpdateQi = false -- Izinkan UpdateQi berjalan lagi
    -- Loop UpdateQi utama akan mengambil alih jika masih berjalan, atau kita tunggu di sini
    waitSeconds(updateQiDuration) 
    if not running then return end

    stopUpdateQi = true -- Pastikan UpdateQi berhenti di akhir siklus jika belum
    timerLabel.Text = "Timer: 00:00" -- Final reset timer
    updateStatus("Cycle finished. Restarting if still running...")
end

-- Buttons
startButton.MouseButton1Click:Connect(function()
    if not running then
        running = true
        updateStatus("Cycle Started")
        -- Menggunakan coroutine.wrap untuk penanganan error yang lebih baik pada thread utama siklus
        local cycleCoroutine = coroutine.wrap(function()
            while running do
                runCycle()
                if running then -- Jika masih running, beri jeda sebelum siklus berikutnya
                    wait(1) 
                end
            end
            updateStatus("Cycle Stopped Internally") -- Jika loop selesai karena running = false
            timerLabel.Text = "Timer: 00:00"
        end)
        cycleCoroutine() -- Jalankan coroutine
    end
end)

stopButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        updateStatus("Cycle Stopping...") -- Beri tahu pengguna bahwa sedang proses berhenti
        -- Tidak perlu secara eksplisit menghentikan thread spawn karena mereka memeriksa flag `running`
        -- Namun, pastikan semua waitSeconds dan loop internal menghormati flag `running`
    end
    -- Status akan diupdate menjadi "Cycle Stopped" oleh loop utama atau setelah waitSeconds selesai
end)

-- Initialize UI
updateStatus("Idle")
