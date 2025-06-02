-- // Services //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // UI ELEMENTS //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KultivasiUI_ZX"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartScriptButton = Instance.new("TextButton")
StartScriptButton.Name = "StartScriptButton"

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"

local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"

local LogFrame = Instance.new("Frame")
LogFrame.Name = "LogFrame"
local LogTitle = Instance.new("TextLabel")
LogTitle.Name = "LogTitle"
local LogOutput = Instance.new("TextLabel")
LogOutput.Name = "LogOutput"
local MinimizedElementButton = Instance.new("TextButton")
MinimizedElementButton.Name = "MinimizedElementButton"

-- Variabel Kontrol dan State
local scriptRunning = false
local stopUpdateQi = false
local pauseUpdateQiTemporarily = false
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil

-- UI State
local isMinimized = false
local originalFrameHeight = 480 -- Disesuaikan agar semua elemen muat
local originalFrameWidth = 320
local originalFrameSize = UDim2.new(0, originalFrameWidth, 0, originalFrameHeight)
local minimizedFrameSize = UDim2.new(0, 50, 0, 50)

local elementsToToggleVisibility = {}
local timerInputElements = {}

-- Tabel Konfigurasi Timer (Tema Kultivasi)
local timers = {
    wait_after_reincarnate = 2, -- Waktu setelah reinkarnasi sebelum tindakan lain
    wait_before_forbidden_zone = 5, -- Waktu sebelum masuk Forbidden Zone (menggantikan item buying)
    jeda_update_qi_duration = 30, -- Durasi UpdateQi dijeda (sebelumnya alur_wait_40s_hide_qi)
    comprehend_dao_duration = 25, -- Durasi Pemahaman Dao (sebelumnya comprehend_duration)
    qi_gathering_post_comprehend = 45, -- Pengumpulan Qi setelah Pemahaman (sebelumnya post_comprehend_qi_duration)

    update_qi_interval = 1,
    aptitude_mine_interval = 0.1,
    generic_delay = 0.5, -- Penundaan umum
    reincarnate_delay = 1,
    change_map_delay = 0.7,
    log_clear_interval = 180
}

-- Karakter untuk animasi glitch
local glitchChars = {"道", "气", "仙", "魔", "力", "魂", "*", "#", "?", " অমর ", "混乱"} -- Karakter bertema

-- // Parent UI ke player //
local function setupCoreGuiParenting()
    local coreGuiService = game:GetService("CoreGui")
    ScreenGui.Parent = coreGuiService
    Frame.Parent = ScreenGui
    UiTitleLabel.Parent = Frame
    StartScriptButton.Parent = Frame
    StatusLabel.Parent = Frame
    MinimizeButton.Parent = Frame
    TimerTitleLabel.Parent = Frame
    ApplyTimersButton.Parent = Frame
    LogFrame.Parent = Frame
    LogTitle.Parent = LogFrame
    LogOutput.Parent = LogFrame
    MinimizedElementButton.Parent = Frame
end
setupCoreGuiParenting()

-- // DESAIN UI (Gaya mainv2.lua, Tema Kultivasi) //
Frame.Size = originalFrameSize
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset / 2, 0.5, -Frame.Size.Y.Offset / 2)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Gelap kebiruan
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(180, 50, 255) -- Ungu mistis
Frame.ClipsDescendants = true -- Klip konten yang meluap
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- UiTitleLabel
local titleYPos = 10
UiTitleLabel.Size = UDim2.new(1, -20, 0, 40)
UiTitleLabel.Position = UDim2.new(0, 10, 0, titleYPos)
UiTitleLabel.Font = Enum.Font.SourceSansSemibold -- Atau Enum.Font.Cinzel untuk tema fantasi
UiTitleLabel.Text = "JALUR KULTIVASI ABADI"
UiTitleLabel.TextColor3 = Color3.fromRGB(220, 180, 255) -- Ungu muda
UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 22
UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.BackgroundTransparency = 1
UiTitleLabel.ZIndex = 2
UiTitleLabel.TextStrokeTransparency = 0.6
UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50, 20, 80) -- Stroke ungu tua
titleYPos = titleYPos + UiTitleLabel.Size.Y.Offset + 10

-- StartScriptButton
StartScriptButton.Size = UDim2.new(1, -40, 0, 40)
StartScriptButton.Position = UDim2.new(0, 20, 0, titleYPos)
StartScriptButton.Text = "MULAI KULTIVASI"
StartScriptButton.Font = Enum.Font.SourceSansBold
StartScriptButton.TextSize = 18
StartScriptButton.TextColor3 = Color3.fromRGB(230, 230, 230)
StartScriptButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120) -- Ungu tua untuk tombol
StartScriptButton.BorderSizePixel = 1
StartScriptButton.BorderColor3 = Color3.fromRGB(150, 80, 200)
StartScriptButton.ZIndex = 2
local StartButtonCorner = Instance.new("UICorner")
StartButtonCorner.CornerRadius = UDim.new(0, 8)
StartButtonCorner.Parent = StartScriptButton
titleYPos = titleYPos + StartScriptButton.Size.Y.Offset + 10

-- StatusLabel
StatusLabel.Size = UDim2.new(1, -40, 0, 50)
StatusLabel.Position = UDim2.new(0, 20, 0, titleYPos)
StatusLabel.Text = "STATUS: MENUNGGU PERINTAH"
StatusLabel.Font = Enum.Font.SourceSansLight
StatusLabel.TextSize = 14
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top -- Agar teks mulai dari atas
StatusLabel.PaddingLeft = UDim.new(0, 5)
StatusLabel.PaddingTop = UDim.new(0, 5)
StatusLabel.BorderSizePixel = 0
StatusLabel.ZIndex = 2
local StatusLabelCorner = Instance.new("UICorner")
StatusLabelCorner.CornerRadius = UDim.new(0, 6)
StatusLabelCorner.Parent = StatusLabel
titleYPos = titleYPos + StatusLabel.Size.Y.Offset + 15

-- TimerTitleLabel
TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20)
TimerTitleLabel.Position = UDim2.new(0, 20, 0, titleYPos)
TimerTitleLabel.Text = "// PENGATURAN SIKLUS KULTIVASI (detik)"
TimerTitleLabel.Font = Enum.Font.Code -- Font 'teknis'
TimerTitleLabel.TextSize = 13
TimerTitleLabel.TextColor3 = Color3.fromRGB(180, 150, 220) -- Ungu muda
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerTitleLabel.ZIndex = 2
titleYPos = titleYPos + TimerTitleLabel.Size.Y.Offset + 8

-- Fungsi untuk membuat input timer
local function createTimerInput(name, labelText, timerKey, currentY)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.6, -25, 0, 22)
    label.Position = UDim2.new(0, 20, 0, currentY)
    label.Text = labelText .. ":"
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(190, 190, 210)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    timerInputElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.4, -25, 0, 22)
    input.Position = UDim2.new(0.6, 5, 0, currentY)
    input.Text = tostring(timers[timerKey])
    input.PlaceholderText = "detik"
    input.Font = Enum.Font.SourceSansSemibold
    input.TextSize = 12
    input.TextColor3 = Color3.fromRGB(240, 240, 255)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(100, 70, 130)
    input.BorderSizePixel = 1
    input.ZIndex = 2
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = input
    timerInputElements[name .. "Input"] = input
    
    table.insert(elementsToToggleVisibility, label)
    table.insert(elementsToToggleVisibility, input)
    return currentY + 22 + 5 -- Tinggi elemen + spasi
end

-- Membuat Input Timer
titleYPos = createTimerInput("ReincarnateWait", "Jeda Pasca Reinkarnasi", "wait_after_reincarnate", titleYPos)
titleYPos = createTimerInput("ForbiddenZoneWait", "Jeda Pra-Wilayah Terlarang", "wait_before_forbidden_zone", titleYPos)
titleYPos = createTimerInput("QiPause", "Jeda Pembaruan Qi", "jeda_update_qi_duration", titleYPos)
titleYPos = createTimerInput("DaoComprehend", "Durasi Pemahaman Dao", "comprehend_dao_duration", titleYPos)
titleYPos = createTimerInput("PostComprehendQi", "Pengumpulan Qi Pasca Dao", "qi_gathering_post_comprehend", titleYPos)
titleYPos = titleYPos + 5 -- Spasi ekstra

-- ApplyTimersButton
ApplyTimersButton.Size = UDim2.new(1, -40, 0, 35)
ApplyTimersButton.Position = UDim2.new(0, 20, 0, titleYPos)
ApplyTimersButton.Text = "TERAPKAN PENGATURAN DAO"
ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.TextSize = 14
ApplyTimersButton.TextColor3 = Color3.fromRGB(230, 230, 230)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(60, 100, 80) -- Hijau giok
ApplyTimersButton.BorderColor3 = Color3.fromRGB(100, 160, 120)
ApplyTimersButton.BorderSizePixel = 1
ApplyTimersButton.ZIndex = 2
local ApplyButtonCorner = Instance.new("UICorner")
ApplyButtonCorner.CornerRadius = UDim.new(0, 6)
ApplyButtonCorner.Parent = ApplyTimersButton
titleYPos = titleYPos + ApplyTimersButton.Size.Y.Offset + 15

-- LogFrame
LogFrame.Size = UDim2.new(1, -40, 0, 100)
LogFrame.Position = UDim2.new(0, 20, 0, titleYPos)
LogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
LogFrame.BorderSizePixel = 1
LogFrame.BorderColor3 = Color3.fromRGB(80, 60, 110)
LogFrame.ZIndex = 1
local LogFrameCorner = Instance.new("UICorner")
LogFrameCorner.CornerRadius = UDim.new(0, 6)
LogFrameCorner.Parent = LogFrame

LogTitle.Size = UDim2.new(1, -20, 0, 20)
LogTitle.Position = UDim2.new(0, 10, 0, 5)
LogTitle.Text = "// CATATAN PERJALANAN KULTIVASI"
LogTitle.Font = Enum.Font.Code
LogTitle.TextSize = 12
LogTitle.TextColor3 = Color3.fromRGB(160, 130, 200) -- Ungu pudar
LogTitle.BackgroundTransparency = 1
LogTitle.TextXAlignment = Enum.TextXAlignment.Left
LogTitle.ZIndex = 2

LogOutput.Size = UDim2.new(1, -20, 1, - (LogTitle.Position.Y.Offset + LogTitle.Size.Y.Offset + 10)) -- Mengisi sisa
LogOutput.Position = UDim2.new(0, 10, 0, LogTitle.Position.Y.Offset + LogTitle.Size.Y.Offset + 5)
LogOutput.Text = "Log: Menunggu takdir terungkap..."
LogOutput.Font = Enum.Font.SourceSansLight
LogOutput.TextSize = 11
LogOutput.TextColor3 = Color3.fromRGB(180, 180, 200)
LogOutput.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
LogOutput.TextWrapped = true
LogOutput.TextXAlignment = Enum.TextXAlignment.Left
LogOutput.TextYAlignment = Enum.TextYAlignment.Top
LogOutput.PaddingLeft = UDim.new(0,5)
LogOutput.PaddingTop = UDim.new(0,5)
LogOutput.BorderSizePixel = 0
LogOutput.ZIndex = 2
local LogOutputCorner = Instance.new("UICorner")
LogOutputCorner.CornerRadius = UDim.new(0, 4)
LogOutputCorner.Parent = LogOutput

-- Perbarui originalFrameHeight jika diperlukan setelah semua elemen ditempatkan
originalFrameHeight = titleYPos + LogFrame.Size.Y.Offset + 20 -- Tambahkan padding bawah
Frame.Size = UDim2.new(0, originalFrameWidth, 0, originalFrameHeight)
originalFrameSize = Frame.Size -- Simpan ukuran final


-- MinimizeButton
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -40, 0, 10)
MinimizeButton.Text = "—" -- Karakter minimize
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 200)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
MinimizeButton.BorderColor3 = Color3.fromRGB(100, 100, 120)
MinimizeButton.BorderSizePixel = 1
MinimizeButton.ZIndex = 3
local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 6)
MinimizeButtonCorner.Parent = MinimizeButton

-- MinimizedElementButton
MinimizedElementButton.Size = UDim2.new(1, 0, 1, 0)
MinimizedElementButton.Position = UDim2.new(0,0,0,0)
MinimizedElementButton.Text = "仙" -- Karakter "Immortal"
MinimizedElementButton.Font = Enum.Font.SourceSansBold -- Atau font Cina jika tersedia
MinimizedElementButton.TextScaled = false
MinimizedElementButton.TextSize = 36
MinimizedElementButton.TextColor3 = Color3.fromRGB(200, 150, 255)
MinimizedElementButton.TextXAlignment = Enum.TextXAlignment.Center
MinimizedElementButton.TextYAlignment = Enum.TextYAlignment.Center
MinimizedElementButton.BackgroundColor3 = Color3.fromRGB(25,25,35)
MinimizedElementButton.BackgroundTransparency = 0
MinimizedElementButton.BorderColor3 = Color3.fromRGB(180, 50, 255)
MinimizedElementButton.BorderSizePixel = 2
MinimizedElementButton.ZIndex = 4
MinimizedElementButton.Visible = false
MinimizedElementButton.AutoButtonColor = false
local MinimizedBtnCorner = Instance.new("UICorner")
MinimizedBtnCorner.CornerRadius = UDim.new(0, 8)
MinimizedBtnCorner.Parent = MinimizedElementButton

table.insert(elementsToToggleVisibility, UiTitleLabel)
table.insert(elementsToToggleVisibility, StartScriptButton)
table.insert(elementsToToggleVisibility, StatusLabel)
table.insert(elementsToToggleVisibility, TimerTitleLabel)
table.insert(elementsToToggleVisibility, ApplyTimersButton)
table.insert(elementsToToggleVisibility, LogFrame)
-- Elemen input timer sudah ditambahkan saat dibuat


-- // Fungsi Bantu UI //
local function appendLog(text)
    if LogOutput and LogOutput.Parent then
        local currentText = LogOutput.Text
        local newText = os.date("[%H:%M:%S] ") .. text .. "\n" .. currentText
        if #newText > 1200 then newText = newText:sub(1, 1200) .. "..." end
        LogOutput.Text = newText
    end
    print("Log: " .. text)
end

local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: " .. string.upper(text) end
    appendLog("Status: " .. text)
end

local function clearLog()
    if LogOutput and LogOutput.Parent then LogOutput.Text = "Log: Catatan dibersihkan." end
    appendLog("Catatan kultivasi dibersihkan.")
end

-- // Fungsi Animasi UI //
local function animateFrameUI(targetSize, targetPosition, callback)
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {Size = targetSize, Position = targetPosition}
    local tween = TweenService:Create(Frame, info, properties)
    tween:Play()
    if callback then
        tween.Completed:Wait()
        callback()
    end
end

-- // Fungsi Minimize/Maximize UI //
local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        MinimizedElementButton.Visible = true
        local targetX = 1 - (minimizedFrameSize.X.Offset / ScreenGui.AbsoluteSize.X) - 0.015
        local targetY = 1 - (minimizedFrameSize.Y.Offset / ScreenGui.AbsoluteSize.Y) - 0.015
        local targetPosition = UDim2.new(targetX, 0, targetY, 0)
        animateFrameUI(minimizedFrameSize, targetPosition)
        Frame.Draggable = true
        MinimizeButton.Visible = false
    else
        MinimizedElementButton.Visible = false
        local targetPosition = UDim2.new(0.5, -originalFrameSize.X.Offset/2, 0.5, -originalFrameSize.Y.Offset/2)
        animateFrameUI(originalFrameSize, targetPosition, function()
            for _, element in ipairs(elementsToToggleVisibility) do
                if element and element.Parent then element.Visible = true end
            end
            Frame.Draggable = true
            MinimizeButton.Visible = true
        end)
    end
end
MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
if MinimizedElementButton:IsA("TextButton") then
    MinimizedElementButton.MouseButton1Click:Connect(toggleMinimize)
end

-- Fungsi tunggu
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat
        RunService.Heartbeat:Wait()
    until not scriptRunning or tick() - startTime >= sec
end

-- Fungsi fireRemoteEnhanced
local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...)
    local remoteEventFolder
    local success = false
    local errMessage = "Unknown error"

    local pcallSuccess, pcallResult = pcall(function()
        if pathType == "AreaEvents" then
            remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9)
        else
            remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 9e9)
        end
        local remote = remoteEventFolder:WaitForChild(remoteName, 9e9)
        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
    end)

    if pcallSuccess then
        success = true
        appendLog("Aksi Terkirim: " .. remoteName .. " (" .. pathType .. ")")
    else
        errMessage = tostring(pcallResult)
        updateStatus("Gagal mengirim aksi " .. remoteName)
        appendLog("ERROR Aksi " .. remoteName .. ": " .. errMessage)
        success = false
    end
    return success
end

-- // Fungsi utama (Logika Kultivasi) //
local function runCycle()
    updateStatus("Memulai Siklus Reinkarnasi...")
    if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    waitSeconds(timers.reincarnate_delay)

    if not scriptRunning then return end
    updateStatus("Persiapan memasuki alam fana...")
    waitSeconds(timers.wait_after_reincarnate)
    if not scriptRunning then return end

    appendLog("Melewati pembelian item (fokus pada kultivasi inti).")

    if not scriptRunning then return end
    updateStatus("Menuju alam abadi...")
    
    local function changeMap(name)
        return fireRemoteEnhanced("ChangeMap", "AreaEvents", name)
    end
    if not changeMap("immortal") then scriptRunning = false; return end
    waitSeconds(timers.change_map_delay)
    
    appendLog("Melewati Chaotic Road (tidak relevan untuk jalur ini).")

    if not scriptRunning then return end
    updateStatus("Persiapan meditasi mendalam...")
    pauseUpdateQiTemporarily = true
    updateStatus("Update Qi dijeda (" .. timers.jeda_update_qi_duration .. "s) untuk fokus...")
    waitSeconds(timers.jeda_update_qi_duration)
    pauseUpdateQiTemporarily = false
    updateStatus("Update Qi dilanjutkan, energi mengalir.")
    if not scriptRunning then return end

    if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
        updateStatus("Mengaktifkan segel tersembunyi (HiddenRemote)...")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
    else
        updateStatus("Melewati segel tersembunyi (kondisi tidak terpenuhi).")
    end
    waitSeconds(timers.generic_delay)

    updateStatus("Persiapan memasuki Wilayah Terlarang...")
    waitSeconds(timers.wait_before_forbidden_zone)
    if not scriptRunning then return end

    updateStatus("Memasuki Wilayah Terlarang untuk mencari pencerahan...")
    if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
    waitSeconds(timers.generic_delay)

    if not scriptRunning then return end
    updateStatus("Memahami Dao Agung (" .. timers.comprehend_dao_duration .. "s)...")
    stopUpdateQi = true

    local comprehendStartTime = tick()
    while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_dao_duration) do
        if not fireRemoteEnhanced("Comprehend", "Base", {}) then
            updateStatus("Pemahaman Dao terganggu!")
            break
        end
        updateStatus(string.format("Memahami Dao... %d detik tersisa", math.floor(timers.comprehend_dao_duration - (tick() - comprehendStartTime))))
        waitSeconds(1)
    end
    if not scriptRunning then return end
    updateStatus("Pemahaman Dao selesai, wawasan baru terbuka.")

    if scriptRunning then
        updateStatus("Mengaktifkan segel pasca-pemahaman...")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then
            updateStatus("Gagal aktifkan segel pasca-pemahaman.")
        end
        waitSeconds(timers.generic_delay)
    end

    if not scriptRunning then return end
    updateStatus("Mengumpulkan Qi Langit & Bumi (" .. timers.qi_gathering_post_comprehend .. "s)...")
    stopUpdateQi = false

    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.qi_gathering_post_comprehend) do
        if stopUpdateQi then
            updateStatus("Pengumpulan Qi terhenti.")
            break
        end
        updateStatus(string.format("Mengumpulkan Qi... %d detik tersisa", math.floor(timers.qi_gathering_post_comprehend - (tick() - postComprehendQiStartTime))))
        waitSeconds(1)
    end
    if not scriptRunning then return end
    stopUpdateQi = true
    updateStatus("Pengumpulan Qi selesai, energi melimpah.")

    updateStatus("Siklus Kultivasi Selesai - Memulai Ulang Perjalanan...")
end

-- Loop Latar Belakang
local function increaseAptitudeMineLoop_enhanced()
    appendLog("Loop Bakat & Tambang Dimulai.")
    while scriptRunning do
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        waitSeconds(timers.aptitude_mine_interval)
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait()
    end
    appendLog("Loop Bakat & Tambang Dihentikan.")
end

local function updateQiLoop_enhanced()
    appendLog("Loop Pembaruan Qi Dimulai.")
    while scriptRunning do
        if not stopUpdateQi and not pauseUpdateQiTemporarily then
            fireRemoteEnhanced("UpdateQi", "Base", {})
        end
        waitSeconds(timers.update_qi_interval)
    end
    appendLog("Loop Pembaruan Qi Dihentikan.")
end

-- Tombol Start/Stop
StartScriptButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning
    if scriptRunning then
        StartScriptButton.Text = "HENTIKAN KULTIVASI"
        StartScriptButton.BackgroundColor3 = Color3.fromRGB(180, 40, 60) -- Merah saat aktif
        StartScriptButton.TextColor3 = Color3.fromRGB(240,220,220)
        updateStatus("Memulai perjalanan kultivasi...")

        stopUpdateQi = false
        pauseUpdateQiTemporarily = false

        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
            aptitudeMineThread = task.spawn(increaseAptitudeMineLoop_enhanced)
        end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
            updateQiThread = task.spawn(updateQiLoop_enhanced)
        end

        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = task.spawn(function()
                while scriptRunning do
                    runCycle()
                    if not scriptRunning then break end
                    updateStatus("Siklus selesai. Mempersiapkan siklus berikutnya...")
                    waitSeconds(2) -- Jeda antar siklus
                end
                if StatusLabel and StatusLabel.Parent then updateStatus("Kultivasi Dihentikan.") end
                StartScriptButton.Text = "MULAI KULTIVASI"
                StartScriptButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120) -- Kembali ke warna ungu
                StartScriptButton.TextColor3 = Color3.fromRGB(230,230,230)
            end)
        end
    else
        updateStatus("Menghentikan perjalanan kultivasi...")
    end
end)

-- Tombol Apply Timers
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false; if not inputElement then return false end
        local value = tonumber(inputElement.Text)
        if value and value >= 0 then timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(120,220,150) end) end; success = true
        else if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(220,100,100) end) end
        end
        return success
    end
    
    local allTimersValid = true
    allTimersValid = applyTextInput(timerInputElements.ReincarnateWaitInput, "wait_after_reincarnate", timerInputElements.ReincarnateWaitLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.ForbiddenZoneWaitInput, "wait_before_forbidden_zone", timerInputElements.ForbiddenZoneWaitLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.QiPauseInput, "jeda_update_qi_duration", timerInputElements.QiPauseLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.DaoComprehendInput, "comprehend_dao_duration", timerInputElements.DaoComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.PostComprehendQiInput, "qi_gathering_post_comprehend", timerInputElements.PostComprehendQiLabel) and allTimersValid

    local originalStatusText = StatusLabel.Text:match("STATUS: (.*)") or "MENUNGGU PERINTAH"
    if allTimersValid then
        updateStatus("Pengaturan Dao berhasil diterapkan.")
        appendLog("Timer kultivasi diperbarui: " .. serpent.dump(timers)) -- Log detail timer
    else
        updateStatus("Input pengaturan Dao tidak valid!")
    end
    
    task.delay(2.5, function()
        if not ScreenGui or not ScreenGui.Parent then return end
        local labelsToResetColor = {
            timerInputElements.ReincarnateWaitLabel, timerInputElements.ForbiddenZoneWaitLabel,
            timerInputElements.QiPauseLabel, timerInputElements.DaoComprehendLabel, timerInputElements.PostComprehendQiLabel
        }
        for _, lbl in ipairs(labelsToResetColor) do
            if lbl and lbl.Parent then pcall(function() lbl.TextColor3 = Color3.fromRGB(190,190,210) end) end
        end
        if StatusLabel and StatusLabel.Parent then updateStatus(originalStatusText) end
    end)
end)

-- Log Clearing Loop
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        waitSeconds(timers.log_clear_interval)
        if ScreenGui and ScreenGui.Parent then clearLog() end
    end
end)

-- // ANIMASI UI //
task.spawn(function() -- Animasi Border Frame
    if not Frame or not Frame.Parent then return end
    local borderBaseColor = Frame.BorderColor3
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            local h,s,v = Color3.toHSV(Frame.BorderColor3)
            Frame.BorderColor3 = Color3.fromHSV((h + 0.005)%1, s, v) -- Rotasi hue lambat
            if math.random() < 0.02 then -- Glitch sesekali
                Frame.BorderSizePixel = math.random(2,4)
                task.wait(0.05)
                Frame.BorderSizePixel = 2
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function() -- Animasi UiTitleLabel
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText1 = "JALUR KULTIVASI ABADI"
    local originalText2 = "ZXHELL x ZEDLIST" -- Teks sekunder
    local currentTargetText = originalText1
    local baseColor = UiTitleLabel.TextColor3
    local originalPos = UiTitleLabel.Position
    local transitionTime = 1.8
    local displayTime = 7

    local function applyCultivationGlitch(text)
        local newText = ""
        for i = 1, #text do
            if math.random() < 0.65 then newText = newText .. glitchChars[math.random(#glitchChars)]
            else newText = newText .. text:sub(i,i) end
        end
        return newText
    end

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            local startTime = tick()
            while tick() - startTime < transitionTime and ScreenGui and ScreenGui.Parent and not isMinimized do
                local progress = (tick() - startTime) / transitionTime
                local mixedText = ""
                local textToGlitchFrom = (currentTargetText == originalText1) and originalText2 or originalText1
                for i = 1, math.max(#currentTargetText, #textToGlitchFrom) do
                    local char1 = currentTargetText:sub(i,i)
                    local char2 = textToGlitchFrom:sub(i,i)
                    if math.random() < progress then mixedText = mixedText .. (char2 ~= "" and char2 or glitchChars[math.random(#glitchChars)])
                    else mixedText = mixedText .. (char1 ~= "" and char1 or glitchChars[math.random(#glitchChars)]) end
                end
                UiTitleLabel.Text = applyCultivationGlitch(mixedText)
                UiTitleLabel.TextColor3 = Color3.fromHSV(math.random(), 0.8, 1) -- Warna cerah
                UiTitleLabel.Position = originalPos + UDim2.fromOffset(math.random(-1,1), math.random(-1,1))
                UiTitleLabel.Rotation = math.random(-0.5,0.5)
                task.wait(0.06)
            end
            if not (ScreenGui and ScreenGui.Parent and not isMinimized) then task.wait(0.1); continue end

            UiTitleLabel.Text = currentTargetText
            local hue = (tick()*0.05) % 1
            UiTitleLabel.TextColor3 = Color3.fromHSV(hue, 0.7, 0.95) -- Warna berputar
            UiTitleLabel.Position = originalPos
            UiTitleLabel.Rotation = 0
            
            waitSeconds(displayTime)
            if not (ScreenGui and ScreenGui.Parent and not isMinimized) then task.wait(0.1); continue end
            if currentTargetText == originalText1 then currentTargetText = originalText2 else currentTargetText = originalText1 end
        else
            UiTitleLabel.Text = originalText1
            UiTitleLabel.TextColor3 = baseColor
            UiTitleLabel.Position = originalPos
            UiTitleLabel.Rotation = 0
            task.wait(0.1)
        end
    end
end)

task.spawn(function() -- Animasi Tombol
    local buttonsToAnimate = {StartScriptButton, ApplyTimersButton, MinimizeButton}
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            for _, btn in ipairs(buttonsToAnimate) do
                if btn and btn.Parent and btn.Visible then
                    local originalBorder = btn.BorderColor3
                    if btn.Name == "StartScriptButton" and scriptRunning then
                        btn.BorderColor3 = Color3.Lerp(originalBorder, Color3.fromRGB(255,100,100), math.abs(math.sin(tick()*3)))
                    else
                        local h,s,v = Color3.toHSV(originalBorder)
                        btn.BorderColor3 = Color3.fromHSV(h,s, math.sin(tick()*1.5)*0.1 + 0.9)
                    end
                end
            end
        end
        task.wait(0.08)
    end
end)

task.spawn(function() -- Animasi Tombol Minimized
    local originalIconText = MinimizedElementButton.Text
    while ScreenGui and ScreenGui.Parent do
        if isMinimized and MinimizedElementButton and MinimizedElementButton.Visible then
            if math.random() < 0.25 then
                MinimizedElementButton.Text = glitchChars[math.random(#glitchChars)]
                MinimizedElementButton.TextColor3 = Color3.fromHSV(math.random(), 0.9, 1)
                MinimizedElementButton.BorderColor3 = Color3.fromHSV(math.random(), 0.9, 1)
                MinimizedElementButton.Rotation = math.random(-5,5)
                Frame.BorderColor3 = MinimizedElementButton.BorderColor3
                task.wait(0.04 + math.random()*0.04)
                MinimizedElementButton.Text = originalIconText
                MinimizedElementButton.Rotation = math.random(-2,2)
            else
                MinimizedElementButton.Text = originalIconText
                local hue = (tick() * 0.4) % 1
                MinimizedElementButton.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
                MinimizedElementButton.BorderColor3 = Color3.fromHSV((hue + 0.2)%1, 0.7, 1)
                MinimizedElementButton.Rotation = 0
                Frame.BorderColor3 = MinimizedElementButton.BorderColor3
            end
        end
        task.wait(0.06)
    end
end)

-- BindToClose
game:BindToClose(function()
    scriptRunning = false
    appendLog("Keluar dari permainan, menghentikan semua proses kultivasi...")
    task.wait(0.6)
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    print("Pembersihan skrip kultivasi selesai.")
end)

-- Inisialisasi
appendLog("Skrip Asisten Kultivasi Abadi (ZX Edition) V4 Telah Dimuat.")
task.wait(0.2)
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "STATUS: " then
    updateStatus("MENUNGGU PERINTAH")
end

-- Pastikan serpent ada di environment Anda atau hapus bagian logging detail timer jika tidak.
-- Jika tidak ada, ganti serpent.dump(timers) dengan loop manual untuk mencetak timer.
if not _G.serpent then
    _G.serpent = {
        dump = function(tbl)
            local s = "{"
            for k, v in pairs(tbl) do
                s = s .. tostring(k) .. "=" .. tostring(v) .. ","
            end
            return s .. "}"
        end
    }
    appendLog("Perpustakaan 'serpent' tidak ditemukan, menggunakan fallback sederhana untuk log timer.")
end
