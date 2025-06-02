-- // Services (Beberapa mungkin tidak digunakan secara aktif di logika inti script ini, tapi disertakan untuk UI) //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Untuk drag UI

-- // UI ELEMENTS //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZXHELL_UI_V2"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartScriptButton = Instance.new("TextButton") -- Mengganti nama dari StartButton
StartScriptButton.Name = "StartScriptButton"

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"

local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"

-- Elemen baru dari mainv2.lua
local LogFrame = Instance.new("Frame")
LogFrame.Name = "LogFrame"
local LogTitle = Instance.new("TextLabel")
LogTitle.Name = "LogTitle"
local LogOutput = Instance.new("TextLabel")
LogOutput.Name = "LogOutput"
local MinimizedElementButton = Instance.new("TextButton") -- Tombol saat minimize
MinimizedElementButton.Name = "MinimizedElementButton"

-- Variabel Kontrol dan State (Dari main.lua)
local scriptRunning = false
local stopUpdateQi = false
local pauseUpdateQiTemporarily = false
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil

-- Variabel UI dari mainv2.lua
local isMinimized = false
local originalFrameHeight = 470 -- Disesuaikan untuk konten main.lua + Log
local originalFrameWidth = 300
local originalFrameSize = UDim2.new(0, originalFrameWidth, 0, originalFrameHeight)
local minimizedFrameSize = UDim2.new(0, 50, 0, 50) -- Ukuran saat minimize

local elementsToToggleVisibility = {} -- Akan diisi nanti

-- Tabel Konfigurasi Timer (Dari main.lua)
local timers = {
    wait_1m30s_after_first_items = 0,
    alur_wait_40s_hide_qi = 0,
    comprehend_duration = 20,
    post_comprehend_qi_duration = 60,

    user_script_wait1_before_items1 = 15,
    -- user_script_wait2_after_items1 = 10, -- Tidak relevan jika item buying dihapus
    -- user_script_wait3_before_items2 = 0.01, -- Tidak relevan
    -- user_script_wait4_before_forbidden = 0.01, -- Tidak relevan

    update_qi_interval = 1,
    aptitude_mine_interval = 0.1,
    genericShortDelay = 0.5,
    reincarnateDelay = 0.5,
    -- buyItemDelay = 0.25, -- Tidak relevan
    changeMapDelay = 0.5,
    fireserver_generic_delay = 0.25,
    log_clear_interval = 120 -- Dari mainv2.lua
}
local timerInputElements = {} -- Untuk menyimpan referensi input timer UI

-- Karakter untuk animasi glitch (dari mainv2.lua)
local glitchChars = {"@", "#", "$", "%", "&", "*", "!", "?", "/", "\\", "|", "_", "1", "0", "Z", "X", "E"}

-- // Parent UI ke player //
local function setupCoreGuiParenting()
    local coreGuiService = game:GetService("CoreGui")
    if not ScreenGui.Parent or ScreenGui.Parent ~= coreGuiService then
        ScreenGui.Parent = coreGuiService
    end
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
    MinimizedElementButton.Parent = Frame -- Parent tombol minimize
end
setupCoreGuiParenting()

-- // DESAIN UI (Mengadaptasi dari mainv2.lua) //
Frame.Size = originalFrameSize
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset / 2, 0.5, -Frame.Size.Y.Offset / 2) -- Tengah layar
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Merah terang
Frame.ClipsDescendants = false
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- UiTitleLabel (Style dari mainv2.lua, teks dari main.lua)
UiTitleLabel.Size = UDim2.new(1, -20, 0, 35)
UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
UiTitleLabel.Font = Enum.Font.SourceSansSemibold -- Font lebih modern
UiTitleLabel.Text = "ZXHELL X ZEDLIST"
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 25, 25) -- Merah menyala
UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 24
UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.BackgroundTransparency = 1
UiTitleLabel.ZIndex = 2
UiTitleLabel.TextStrokeTransparency = 0.5
UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)

local yPos = UiTitleLabel.Position.Y.Offset + UiTitleLabel.Size.Y.Offset + 10

-- StartScriptButton (Style dari mainv2.lua)
StartScriptButton.Size = UDim2.new(1, -40, 0, 35)
StartScriptButton.Position = UDim2.new(0, 20, 0, yPos)
StartScriptButton.Text = "START SCRIPT"
StartScriptButton.Font = Enum.Font.SourceSansBold
StartScriptButton.TextSize = 16
StartScriptButton.TextColor3 = Color3.fromRGB(220, 220, 220)
StartScriptButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20) -- Merah gelap untuk start
StartScriptButton.BorderSizePixel = 1
StartScriptButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
StartScriptButton.ZIndex = 2
local StartButtonCorner = Instance.new("UICorner")
StartButtonCorner.CornerRadius = UDim.new(0, 5)
StartButtonCorner.Parent = StartScriptButton
yPos = yPos + StartScriptButton.Size.Y.Offset + 10

-- StatusLabel (Style dari mainv2.lua)
StatusLabel.Size = UDim2.new(1, -40, 0, 45)
StatusLabel.Position = UDim2.new(0, 20, 0, yPos)
StatusLabel.Text = "STATUS: IDLE"
StatusLabel.Font = Enum.Font.SourceSansLight
StatusLabel.TextSize = 14
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Gelap
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.BorderSizePixel = 0
StatusLabel.ZIndex = 2
local StatusLabelCorner = Instance.new("UICorner")
StatusLabelCorner.CornerRadius = UDim.new(0, 5)
StatusLabelCorner.Parent = StatusLabel
yPos = yPos + StatusLabel.Size.Y.Offset + 15

-- TimerTitleLabel (Style dari mainv2.lua)
TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20)
TimerTitleLabel.Position = UDim2.new(0, 20, 0, yPos)
TimerTitleLabel.Text = "// SCRIPT TIMERS (seconds)"
TimerTitleLabel.Font = Enum.Font.Code
TimerTitleLabel.TextSize = 14
TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Merah untuk judul
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerTitleLabel.ZIndex = 2
yPos = yPos + TimerTitleLabel.Size.Y.Offset + 5

-- Fungsi untuk membuat input timer dengan style mainv2.lua
local function createTimerInput(name, labelText, timerKey, currentY)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.55, -25, 0, 20) -- Lebar label
    label.Position = UDim2.new(0, 20, 0, currentY)
    label.Text = labelText .. ":"
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    timerInputElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.45, -25, 0, 20) -- Lebar input
    input.Position = UDim2.new(0.55, 5, 0, currentY) -- Sejajar dengan label
    input.Text = tostring(timers[timerKey])
    input.PlaceholderText = "secs"
    input.Font = Enum.Font.SourceSansSemibold
    input.TextSize = 12
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40) -- Background input gelap
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(100, 100, 120)
    input.BorderSizePixel = 1
    input.ZIndex = 2
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 3)
    InputCorner.Parent = input
    timerInputElements[name .. "Input"] = input
    
    table.insert(elementsToToggleVisibility, label) -- Tambah ke list untuk minimize
    table.insert(elementsToToggleVisibility, input) -- Tambah ke list untuk minimize
    return input, currentY + 25 -- Kembalikan Y berikutnya
end

-- Membuat Input Timer (menggunakan timer dari main.lua)
yPos = createTimerInput("Wait1m30s", "Wait Pasca Item1", "wait_1m30s_after_first_items", yPos)
yPos = createTimerInput("Wait40s", "Wait Item2 (QI Hidden)", "alur_wait_40s_hide_qi", yPos)
yPos = createTimerInput("Comprehend", "Durasi Comprehend", "comprehend_duration", yPos)
yPos = createTimerInput("PostComprehendQi", "Durasi Post-Comp QI", "post_comprehend_qi_duration", yPos)
yPos = yPos + 10 -- Sedikit spasi sebelum tombol Apply

-- ApplyTimersButton (Style dari mainv2.lua)
ApplyTimersButton.Size = UDim2.new(1, -40, 0, 30)
ApplyTimersButton.Position = UDim2.new(0, 20, 0, yPos)
ApplyTimersButton.Text = "APPLY TIMERS"
ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.TextSize = 14
ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(30, 80, 30) -- Hijau untuk apply
ApplyTimersButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
ApplyTimersButton.BorderSizePixel = 1
ApplyTimersButton.ZIndex = 2
local ApplyButtonCorner = Instance.new("UICorner")
ApplyButtonCorner.CornerRadius = UDim.new(0, 5)
ApplyButtonCorner.Parent = ApplyTimersButton
yPos = yPos + ApplyTimersButton.Size.Y.Offset + 15

-- LogFrame (Baru, dari mainv2.lua)
LogFrame.Size = UDim2.new(1, -40, 0, 100) -- Tinggi log frame
LogFrame.Position = UDim2.new(0, 20, 0, yPos)
LogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
LogFrame.BorderSizePixel = 1
LogFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
LogFrame.ZIndex = 1
local LogFrameCorner = Instance.new("UICorner")
LogFrameCorner.CornerRadius = UDim.new(0, 5)
LogFrameCorner.Parent = LogFrame

LogTitle.Size = UDim2.new(1, -20, 0, 20)
LogTitle.Position = UDim2.new(0, 10, 0, 5) -- Di dalam LogFrame
LogTitle.Text = "// SCRIPT LOG"
LogTitle.Font = Enum.Font.Code
LogTitle.TextSize = 14
LogTitle.TextColor3 = Color3.fromRGB(255, 200, 80) -- Oranye untuk log title
LogTitle.BackgroundTransparency = 1
LogTitle.TextXAlignment = Enum.TextXAlignment.Left
LogTitle.ZIndex = 2

LogOutput.Size = UDim2.new(1, -20, 0, LogFrame.Size.Y.Offset - LogTitle.Size.Y.Offset - 15) -- Mengisi sisa LogFrame
LogOutput.Position = UDim2.new(0, 10, 0, LogTitle.Position.Y.Offset + LogTitle.Size.Y.Offset + 5)
LogOutput.Text = "Log: System Initialized."
LogOutput.Font = Enum.Font.SourceSansLight
LogOutput.TextSize = 11
LogOutput.TextColor3 = Color3.fromRGB(200, 200, 200)
LogOutput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
LogOutput.TextWrapped = true
LogOutput.TextXAlignment = Enum.TextXAlignment.Left
LogOutput.TextYAlignment = Enum.TextYAlignment.Top
LogOutput.BorderSizePixel = 0
LogOutput.ZIndex = 2
local LogOutputCorner = Instance.new("UICorner")
LogOutputCorner.CornerRadius = UDim.new(0, 3)
LogOutputCorner.Parent = LogOutput

-- MinimizeButton (Style dari mainv2.lua)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -35, 0, 10) -- Pojok kanan atas frame
MinimizeButton.Text = "_"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.BorderColor3 = Color3.fromRGB(100, 100, 120)
MinimizeButton.BorderSizePixel = 1
MinimizeButton.ZIndex = 3
local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 3)
MinimizeButtonCorner.Parent = MinimizeButton

-- Tombol yang muncul saat minimize (dari mainv2.lua)
MinimizedElementButton.Size = UDim2.new(1, 0, 1, 0) -- Mengisi frame yang di-minimize
MinimizedElementButton.Position = UDim2.new(0,0,0,0)
MinimizedElementButton.Text = "Z" -- Bisa diganti ikon lain
MinimizedElementButton.Font = Enum.Font.SourceSansBold
MinimizedElementButton.TextScaled = false
MinimizedElementButton.TextSize = 38
MinimizedElementButton.TextColor3 = Color3.fromRGB(255, 0, 0)
MinimizedElementButton.TextXAlignment = Enum.TextXAlignment.Center
MinimizedElementButton.TextYAlignment = Enum.TextYAlignment.Center
MinimizedElementButton.BackgroundColor3 = Color3.fromRGB(15,15,20)
MinimizedElementButton.BackgroundTransparency = 0
MinimizedElementButton.BorderColor3 = Color3.fromRGB(255,0,0)
MinimizedElementButton.BorderSizePixel = 2
MinimizedElementButton.ZIndex = 4
MinimizedElementButton.Visible = false -- Awalnya tidak terlihat
MinimizedElementButton.AutoButtonColor = false

-- Isi elementsToToggleVisibility (dari mainv2.lua, disesuaikan)
elementsToToggleVisibility = {
    UiTitleLabel, StartScriptButton, StatusLabel, TimerTitleLabel, ApplyTimersButton, LogFrame, MinimizeButton
    -- Input timer sudah ditambahkan di createTimerInput
}
for _, elName in pairs({"Wait1m30s", "Wait40s", "Comprehend", "PostComprehendQi"}) do
    if timerInputElements[elName .. "Label"] then table.insert(elementsToToggleVisibility, timerInputElements[elName .. "Label"]) end
    if timerInputElements[elName .. "Input"] then table.insert(elementsToToggleVisibility, timerInputElements[elName .. "Input"]) end
end


-- // Fungsi Bantu UI (dari mainv2.lua) //
local function appendLog(text)
    if LogOutput and LogOutput.Parent then
        local currentText = LogOutput.Text
        local newText = os.date("[%H:%M:%S] ") .. text .. "\n" .. currentText
        if #newText > 1000 then -- Batasi panjang log
            newText = newText:sub(1, 1000) .. "..."
        end
        LogOutput.Text = newText
    end
    print("Log: " .. text)
end

local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = "STATUS: " .. string.upper(text)
    end
    appendLog("Status changed: " .. text) -- Juga catat status ke log
end

local function clearLog()
    if LogOutput and LogOutput.Parent then LogOutput.Text = "Log: Cleared." end
    appendLog("Log cleared manually or by interval.")
end

-- // Fungsi Animasi UI (dari mainv2.lua) //
local function animateFrame(targetSize, targetPosition, callback)
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {Size = targetSize, Position = targetPosition}
    local tween = TweenService:Create(Frame, info, properties)
    tween:Play()
    if callback then
        tween.Completed:Wait()
        callback()
    end
end

-- // Fungsi Minimize/Maximize UI (dari mainv2.lua) //
local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        MinimizedElementButton.Visible = true
        -- Pindahkan frame ke pojok kanan bawah (contoh)
        local targetX = 1 - (minimizedFrameSize.X.Offset / ScreenGui.AbsoluteSize.X) - 0.02
        local targetY = 1 - (minimizedFrameSize.Y.Offset / ScreenGui.AbsoluteSize.Y) - 0.02
        local targetPosition = UDim2.new(targetX, 0, targetY, 0)
        animateFrame(minimizedFrameSize, targetPosition)
        Frame.Draggable = true -- Tetap bisa di-drag saat minimize
        MinimizeButton.Visible = false -- Sembunyikan tombol '_'
    else
        MinimizedElementButton.Visible = false
        MinimizeButton.Text = "_"
        local targetPosition = UDim2.new(0.5, -originalFrameSize.X.Offset/2, 0.5, -originalFrameSize.Y.Offset/2) -- Kembali ke tengah
        animateFrame(originalFrameSize, targetPosition, function()
            for _, element in ipairs(elementsToToggleVisibility) do
                if element and element.Parent then element.Visible = true end
            end
            Frame.Draggable = true
            MinimizeButton.Visible = true -- Tampilkan kembali tombol '_'
        end)
    end
end
MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
if MinimizedElementButton:IsA("TextButton") then
    MinimizedElementButton.MouseButton1Click:Connect(toggleMinimize)
end


-- Fungsi tunggu (Dari main.lua)
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat
        RunService.Heartbeat:Wait() -- Lebih responsif daripada task.wait()
    until not scriptRunning or tick() - startTime >= sec
end

-- Fungsi fireRemoteEnhanced (Dari main.lua)
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
        appendLog("Fired: " .. remoteName .. " (" .. pathType .. ")")
    else
        errMessage = tostring(pcallResult)
        updateStatus("Error firing " .. remoteName)
        appendLog("ERROR Firing " .. remoteName .. ": " .. errMessage)
        success = false
    end
    return success
end


-- // Fungsi utama (Dari main.lua, DIMODIFIKASI) //
local function runCycle()
    updateStatus("Reincarnating")
    if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    waitSeconds(timers.reincarnateDelay)

    if not scriptRunning then return end
    updateStatus("Persiapan awal...") -- Mengganti status pembelian item
    waitSeconds(timers.user_script_wait1_before_items1)
    if not scriptRunning then return end

    -- PEMBELIAN ITEM 1 DIHILANGKAN
    -- local item1 = {
    --  "Nine Heavens Galaxy Water", "Buzhou Divine Flower",
    --  "Fusang Divine Tree", "Calm Cultivation Mat"
    -- }
    -- for _, item in ipairs(item1) do
    --  if not scriptRunning then return end
    --  updateStatus("Membeli: " .. item) -- DIHILANGKAN
    --  if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end -- DIHILANGKAN
    --  waitSeconds(timers.buyItemDelay)
    -- end
    appendLog("Melewati pembelian item set 1.")


    if not scriptRunning then return end
    updateStatus("Menunggu sebelum ganti map...")
    waitSeconds(timers.wait_1m30s_after_first_items)
    if not scriptRunning then return end

    local function changeMap(name)
        return fireRemoteEnhanced("ChangeMap", "AreaEvents", name)
    end
    if not changeMap("immortal") then scriptRunning = false; return end
    waitSeconds(timers.changeMapDelay)
    
    -- CHAOTIC ROAD DIHILANGKAN
    -- if not scriptRunning then return end
    -- if not changeMap("chaos") then scriptRunning = false; return end
    -- waitSeconds(timers.changeMapDelay)
    -- if not scriptRunning then return end
    -- updateStatus("Chaotic Road") -- DIHILANGKAN
    -- if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end -- DIHILANGKAN
    -- waitSeconds(timers.genericShortDelay)
    appendLog("Melewati Chaotic Road.")


    if not scriptRunning then return end
    updateStatus("Persiapan sebelum jeda UpdateQi...")
    pauseUpdateQiTemporarily = true
    updateStatus("UpdateQi dijeda (" .. timers.alur_wait_40s_hide_qi .. "s)...")
    waitSeconds(timers.alur_wait_40s_hide_qi)
    pauseUpdateQiTemporarily = false
    updateStatus("UpdateQi dilanjutkan.")
    if not scriptRunning then return end

    -- PEMBELIAN ITEM 2 DIHILANGKAN
    -- local item2 = {
    --  "Traceless Breeze Lotus",
    --  "Reincarnation World Destruction Black Lotus",
    --  "Ten Thousand Bodhi Tree"
    -- }
    -- for _, item in ipairs(item2) do
    --  if not scriptRunning then return end
    --  updateStatus("Membeli: " .. item) -- DIHILANGKAN
    --  if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end -- DIHILANGKAN
    --  waitSeconds(timers.buyItemDelay)
    -- end
    appendLog("Melewati pembelian item set 2.")

    if not scriptRunning then return end
    -- Kembali ke immortal sudah dilakukan sebelumnya, atau pastikan alur map sesuai
    -- if not changeMap("immortal") then scriptRunning = false; return end 
    -- waitSeconds(timers.changeMapDelay)

    if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
        updateStatus("Menjalankan HiddenRemote (UpdateQi aktif)...")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
    else
        updateStatus("Melewati HiddenRemote (UpdateQi tidak aktif/dijeda).")
    end
    waitSeconds(timers.genericShortDelay)

    updateStatus("Persiapan Forbidden Zone...")
    if not scriptRunning then return end

    updateStatus("Memasuki Forbidden Zone...")
    if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
    waitSeconds(timers.genericShortDelay)

    if not scriptRunning then return end
    updateStatus("Comprehending (" .. timers.comprehend_duration .. "s)...")
    stopUpdateQi = true

    local comprehendStartTime = tick()
    while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
        if not fireRemoteEnhanced("Comprehend", "Base", {}) then
            updateStatus("Event Comprehend gagal.")
            break
        end
        updateStatus(string.format("Comprehending... %d detik tersisa", math.floor(timers.comprehend_duration - (tick() - comprehendStartTime))))
        waitSeconds(1)
    end
    if not scriptRunning then return end
    updateStatus("Comprehend Selesai.")

    if scriptRunning then
        updateStatus("Mengatur status ke Hidden setelah Comprehend...")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then
            updateStatus("Gagal HiddenRemote setelah Comprehend.")
        end
        waitSeconds(timers.genericShortDelay)
    end

    if not scriptRunning then return end
    updateStatus("Final UpdateQi (" .. timers.post_comprehend_qi_duration .. "s)...")
    stopUpdateQi = false

    updateStatus(string.format("Post-Comprehend UpdateQi selama %d detik...", timers.post_comprehend_qi_duration))
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        if stopUpdateQi then
            updateStatus("Loop UpdateQi terhenti saat Post-Comprehend.")
            break
        end
        updateStatus(string.format("Post-Comprehend UpdateQi aktif... %d detik tersisa", math.floor(timers.post_comprehend_qi_duration - (tick() - postComprehendQiStartTime))))
        waitSeconds(1)
    end
    if not scriptRunning then return end
    stopUpdateQi = true

    updateStatus("Cycle Done - Restarting")
end

-- Loop Latar Belakang (Dari main.lua)
local function increaseAptitudeMineLoop_enhanced()
    appendLog("Loop Aptitude/Mine Dimulai.")
    while scriptRunning do
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        waitSeconds(timers.aptitudeMineInterval)
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait() -- Minimal wait
    end
    appendLog("Loop Aptitude/Mine Dihentikan.")
end

local function updateQiLoop_enhanced()
    appendLog("Loop UpdateQi Dimulai.")
    while scriptRunning do
        if not stopUpdateQi and not pauseUpdateQiTemporarily then
            fireRemoteEnhanced("UpdateQi", "Base", {})
        end
        waitSeconds(timers.updateQiInterval)
    end
    appendLog("Loop UpdateQi Dihentikan.")
end

-- Tombol Start/Stop (Dari main.lua, disesuaikan)
StartScriptButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning

    if scriptRunning then
        StartScriptButton.Text = "STOP SCRIPT"
        StartScriptButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30) -- Merah terang saat running
        StartScriptButton.TextColor3 = Color3.fromRGB(255,255,255)
        updateStatus("Memulai skrip...")

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
                    updateStatus("Siklus selesai. Memulai ulang...")
                    waitSeconds(1)
                end
                if StatusLabel and StatusLabel.Parent then updateStatus("Skrip Dihentikan.") end
                StartScriptButton.Text = "START SCRIPT"
                StartScriptButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
                StartScriptButton.TextColor3 = Color3.fromRGB(220,220,220)
            end)
        end
    else
        updateStatus("Menghentikan skrip...")
        -- ScriptRunning sudah false, loop akan berhenti secara alami
    end
end)

-- Tombol Apply Timers (Dari main.lua, style dari mainv2.lua)
ApplyTimersButton.MouseButton1Click:Connect(function()
    if not scriptRunning then updateStatus("Script tidak berjalan, timer bisa diubah.") end
    
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false; if not inputElement then return false end
        local value = tonumber(inputElement.Text)
        if value and value >= 0 then timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(80,255,80) end) end; success = true -- Hijau jika valid
        else if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(255,80,80) end) end -- Merah jika tidak valid
        end
        return success
    end
    
    local allTimersValid = true
    allTimersValid = applyTextInput(timerInputElements.Wait1m30sInput, "wait_1m30s_after_first_items", timerInputElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.Wait40sInput, "alur_wait_40s_hide_qi", timerInputElements.Wait40sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.ComprehendInput, "comprehend_duration", timerInputElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.PostComprehendQiInput, "post_comprehend_qi_duration", timerInputElements.PostComprehendQiLabel) and allTimersValid

    local originalStatusText = StatusLabel.Text:match("STATUS: (.*)") or "IDLE" -- Ambil status asli
    if allTimersValid then
        updateStatus("TIMERS_APPLIED_SUCCESSFULLY")
    else
        updateStatus("ERR_INVALID_TIMER_INPUT")
    end
    
    task.delay(2, function() -- Reset warna label dan status
        if not scriptRunning and not ScreenGui.Parent then return end -- Cek jika UI sudah dihancurkan
        local labelsToReset = {timerInputElements.Wait1m30sLabel, timerInputElements.Wait40sLabel, timerInputElements.ComprehendLabel, timerInputElements.PostComprehendQiLabel}
        for _, lbl in ipairs(labelsToReset) do
            if lbl and lbl.Parent then pcall(function() lbl.TextColor3 = Color3.fromRGB(180,180,200) end) end -- Warna default
        end
        if StatusLabel and StatusLabel.Parent then updateStatus(originalStatusText) end
    end)
end)

-- Log Clearing Loop (dari mainv2.lua)
task.spawn(function()
    while scriptRunning or (ScreenGui and ScreenGui.Parent) do -- Terus berjalan selama UI ada
        waitSeconds(timers.log_clear_interval)
        if ScreenGui and ScreenGui.Parent then -- Hanya clear jika UI masih ada
             clearLog()
        else
            break -- Hentikan loop jika UI hilang
        end
    end
end)


-- // ANIMASI UI (Diambil dan disesuaikan dari mainv2.lua) //
-- Animasi Frame Border
task.spawn(function()
    if not Frame or not Frame.Parent then return end
    local baseColor = Frame.BackgroundColor3
    local borderBaseColor = Frame.BorderColor3
    local borderThicknessBase = Frame.BorderSizePixel
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            local r = math.random()
            if r < 0.05 then -- Efek "glitch" singkat pada border dan posisi
                Frame.BackgroundColor3 = Color3.fromRGB(math.random(10,30),math.random(10,30),math.random(15,35))
                Frame.BorderColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                Frame.BorderSizePixel = math.random(borderThicknessBase + 1, borderThicknessBase + 3)
                Frame.Position = Frame.Position + UDim2.fromOffset(math.random(-1,1), math.random(-1,1))
                task.wait(0.03)
                Frame.BackgroundColor3 = Color3.fromRGB(math.random(5,25),math.random(5,25),math.random(10,30))
                Frame.BorderColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                Frame.BorderSizePixel = math.random(borderThicknessBase -1, borderThicknessBase + 1)
                Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2) -- Kembali ke tengah
                task.wait(0.03)
            elseif r < 0.2 then -- Perubahan warna border halus
                Frame.BorderColor3 = Color3.Lerp(borderBaseColor, Color3.fromRGB(0,255,255), math.random()*0.7)
                Frame.BorderSizePixel = math.random(borderThicknessBase -1, borderThicknessBase + 1)
                task.wait(0.05)
            end
            Frame.BackgroundColor3 = baseColor
            local h,s,v = Color3.toHSV(Frame.BorderColor3)
            Frame.BorderColor3 = Color3.fromHSV((h + 0.008)%1, 1, 1) -- Warna border berputar pelan
            Frame.BorderSizePixel = borderThicknessBase
        else
            task.wait(0.1) -- Kurangi update saat minimize
        end
        task.wait(0.04)
    end
end)

-- Animasi UiTitleLabel (Glitch Text dari mainv2.lua)
task.spawn(function()
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText1 = "ZXHELL X ZEDLIST"
    local originalText2 = "AUTO FARM UTILS" -- Teks alternatif
    local currentTargetText = originalText1
    local baseColor = UiTitleLabel.TextColor3
    local originalPos = UiTitleLabel.Position
    local transitionTime = 1.5 -- Waktu transisi glitch
    local displayTime = 5 -- Waktu tampilan teks normal

    local function applyGlitchToText(text)
        local newText = ""
        for i = 1, #text do
            if math.random() < 0.7 then newText = newText .. glitchChars[math.random(#glitchChars)]
            else newText = newText .. text:sub(i,i) end
        end
        return newText
    end

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            local startTime = tick()
            -- Fase transisi glitch
            while tick() - startTime < transitionTime and (ScreenGui and ScreenGui.Parent) do
                if isMinimized then break end -- Hentikan jika minimize saat transisi
                local progress = (tick() - startTime) / transitionTime
                local mixedText = ""
                local textToGlitchFrom = (currentTargetText == originalText1) and originalText2 or originalText1
                for i = 1, math.max(#currentTargetText, #textToGlitchFrom) do
                    local char1 = currentTargetText:sub(i,i)
                    local char2 = textToGlitchFrom:sub(i,i)
                    if math.random() < progress then mixedText = mixedText .. (char2 ~= "" and char2 or glitchChars[math.random(#glitchChars)])
                    else mixedText = mixedText .. (char1 ~= "" and char1 or glitchChars[math.random(#glitchChars)]) end
                end
                UiTitleLabel.Text = applyGlitchToText(mixedText)
                UiTitleLabel.TextColor3 = Color3.fromHSV(math.random(), 1, 1) -- Warna acak
                UiTitleLabel.Position = originalPos + UDim2.fromOffset(math.random(-1,1), math.random(-1,1))
                UiTitleLabel.Rotation = math.random(-1,1) * 0.3
                task.wait(0.05)
            end
            if not (ScreenGui and ScreenGui.Parent) or isMinimized then task.wait(0.1); continue end

            -- Fase tampilan normal
            UiTitleLabel.Text = currentTargetText
            local hue = (tick()*0.1) % 1 -- Warna berputar pelan
            local r_rgb, g_rgb, b_rgb = Color3.fromHSV(hue, 1, 1).R, Color3.fromHSV(hue, 1, 1).G, Color3.fromHSV(hue, 1, 1).B
            r_rgb = math.min(1, r_rgb + 0.6); g_rgb = g_rgb * 0.4; b_rgb = b_rgb * 0.4 -- Dominasi merah
            UiTitleLabel.TextColor3 = Color3.new(r_rgb, g_rgb, b_rgb)
            UiTitleLabel.TextStrokeTransparency = 0.5
            UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
            UiTitleLabel.Position = originalPos
            UiTitleLabel.Rotation = 0
            
            waitSeconds(displayTime) -- Tunggu sebelum transisi berikutnya
            if not (ScreenGui and ScreenGui.Parent) or isMinimized then task.wait(0.1); continue end

            -- Ganti target teks
            if currentTargetText == originalText1 then currentTargetText = originalText2 else currentTargetText = originalText1 end
        else
            -- Reset ke kondisi default saat minimize
            UiTitleLabel.Text = originalText1
            UiTitleLabel.TextColor3 = baseColor
            UiTitleLabel.TextStrokeTransparency = 0.5
            UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
            UiTitleLabel.Position = originalPos
            UiTitleLabel.Rotation = 0
            task.wait(0.1)
        end
    end
end)

-- Animasi Tombol (Border dari mainv2.lua)
task.spawn(function()
    local buttonsToAnimate = {StartScriptButton, ApplyTimersButton, MinimizeButton}
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            for _, btn in ipairs(buttonsToAnimate) do
                if btn and btn.Parent and btn.Visible then
                    local originalBorderColor = btn.BorderColor3
                    if btn.Name == "StartScriptButton" and scriptRunning then
                        btn.BorderColor3 = Color3.fromRGB(255,100,100) -- Border merah saat running
                    else
                        local h,s,v = Color3.toHSV(originalBorderColor)
                        btn.BorderColor3 = Color3.fromHSV(h,s, math.sin(tick()*2)*0.1 + 0.9) -- Efek pulsasi pada value
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Animasi Tombol Minimized (dari mainv2.lua)
task.spawn(function()
    local originalZText = MinimizedElementButton.Text -- "Z" atau ikon lain
    while ScreenGui and ScreenGui.Parent do
        if isMinimized and MinimizedElementButton and MinimizedElementButton.Visible then
            local r = math.random()
            if r < 0.3 then -- Efek glitch pada tombol minimize
                MinimizedElementButton.Text = glitchChars[math.random(#glitchChars)]
                MinimizedElementButton.TextColor3 = Color3.fromHSV(math.random(), 1, 1)
                MinimizedElementButton.BorderColor3 = Color3.fromHSV(math.random(), 1, 1)
                MinimizedElementButton.BorderSizePixel = math.random(1,4)
                MinimizedElementButton.Rotation = math.random(-7,7)
                Frame.BorderSizePixel = math.random(2,5) -- Frame ikut glitch
                Frame.BorderColor3 = MinimizedElementButton.BorderColor3
                task.wait(0.03 + math.random()*0.03)
                MinimizedElementButton.Text = originalZText
                MinimizedElementButton.TextColor3 = Color3.fromHSV(math.random(), 1, 1)
                MinimizedElementButton.BorderColor3 = Color3.fromHSV(math.random(), 1, 1)
                MinimizedElementButton.BorderSizePixel = math.random(2,3)
                MinimizedElementButton.Rotation = math.random(-4,4)
                Frame.BorderSizePixel = 2
                Frame.BorderColor3 = MinimizedElementButton.BorderColor3
                task.wait(0.04 + math.random()*0.03)
            else -- Kondisi normal tombol minimize
                MinimizedElementButton.Text = originalZText
                local hue = (tick() * 0.3) % 1
                MinimizedElementButton.TextColor3 = Color3.fromHSV(hue, 1, 1)
                MinimizedElementButton.BorderColor3 = Color3.fromHSV((hue + 0.3)%1, 0.8, 1)
                MinimizedElementButton.BorderSizePixel = 2
                MinimizedElementButton.Rotation = 0
                Frame.BorderColor3 = MinimizedElementButton.BorderColor3
                Frame.BorderSizePixel = MinimizedElementButton.BorderSizePixel
            end
        end
        task.wait(0.05)
    end
end)

-- BindToClose (Dari main.lua)
game:BindToClose(function()
    scriptRunning = false -- Hentikan semua loop
    appendLog("Game ditutup, menghentikan skrip...")
    task.wait(0.5) -- Beri waktu untuk loop berhenti
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    print("Pembersihan skrip selesai.")
end)

-- Inisialisasi
appendLog("Skrip Otomatisasi (Versi UI V2) Telah Dimuat.")
task.wait(0.1) -- Waktu singkat untuk UI render
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "STATUS: " then -- Jika status kosong
    updateStatus("IDLE")
end
