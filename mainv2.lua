-- MainScript.lua
-- Gabungan UI dan Logika dengan UI pop-up 'Z' merah RGB

-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberpunkUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Penting untuk memastikan UI selalu di atas

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"

local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"

-- Tabel untuk menyimpan referensi elemen input timer
local timerInputElements = {}

-- --- Variabel Kontrol dan State ---
local scriptRunning = false
local stopUpdateQi = false
local pauseUpdateQiTemporarily = false
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil

local isMinimized = false
local originalFrameSize = UDim2.new(0, 260, 0, 420) -- Ukuran awal UI lebih kecil
local minimizedFrameSize = UDim2.new(0, 50, 0, 50) -- Ukuran pop-up 'Z'
local minimizedZLabel = Instance.new("TextLabel") -- Label khusus untuk pop-up 'Z'

-- Kumpulan elemen yang visibilitasnya akan di-toggle
local elementsToToggleVisibility = {} -- Akan diisi setelah semua elemen UI dibuat

-- --- Tabel Konfigurasi Timer ---
local timers = {
    wait_1m30s_after_first_items = 90,
    alur_wait_40s_hide_qi = 40,
    comprehend_duration = 20,
    post_comprehend_qi_duration = 60,

    user_script_wait1_before_items1 = 15,
    user_script_wait2_after_items1 = 10,
    user_script_wait3_before_items2 = 0.01,
    user_script_wait4_before_forbidden = 0.01,

    update_qi_interval = 1,
    aptitude_mine_interval = 0.1,
    genericShortDelay = 0.5,
    reincarnateDelay = 0.5,
    buyItemDelay = 0.25,
    changeMapDelay = 0.5,
    fireserver_generic_delay = 0.25
}

-- // Parent UI ke player //
local function setupCoreGuiParenting()
    local coreGuiService = game:GetService("CoreGui")
    if not ScreenGui.Parent or ScreenGui.Parent ~= coreGuiService then
        ScreenGui.Parent = coreGuiService
    end
    if not Frame.Parent or Frame.Parent ~= ScreenGui then
        Frame.Parent = ScreenGui
    end
    -- Pastikan semua elemen UI diparenting di sini
    UiTitleLabel.Parent = Frame
    StartButton.Parent = Frame
    StatusLabel.Parent = Frame
    MinimizeButton.Parent = Frame
    TimerTitleLabel.Parent = Frame
    ApplyTimersButton.Parent = Frame
    minimizedZLabel.Parent = Frame -- Parentkan label Z ke Frame
end

-- Panggil setupCoreGuiParenting di awal
setupCoreGuiParenting()

-- // Desain UI //

-- --- Frame Utama ---
Frame.Size = originalFrameSize
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2) -- Tengah layar
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Latar belakang gelap kebiruan
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Awalnya merah, akan dianimasikan
Frame.ClipsDescendants = true -- Penting untuk animasi masuk/keluar elemen

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10) -- Sudut lebih membulat
UICorner.Parent = Frame

-- --- Nama UI Label ("ZXHELL X ZEDLIST") ---
UiTitleLabel.Size = UDim2.new(1, -20, 0, 35) -- Lebih kecil sedikit
UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
UiTitleLabel.Font = Enum.Font.SourceSansSemibold
UiTitleLabel.Text = "ZXHELL X ZEDLIST"
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 25, 25)
UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 24 -- Ukuran font sedang
UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.BackgroundTransparency = 1
UiTitleLabel.ZIndex = 2
UiTitleLabel.TextStrokeTransparency = 0.5
UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)

-- Posisi elemen lain disesuaikan dengan layout baru
local yOffsetForTitle = 50 -- Jarak dari atas frame ke elemen berikutnya (disesuaikan)

-- --- Tombol Start/Stop ---
StartButton.Size = UDim2.new(1, -40, 0, 35) -- Lebih kecil
StartButton.Position = UDim2.new(0, 20, 0, yOffsetForTitle)
StartButton.Text = "START SEQUENCE"
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 16 -- Ukuran font sedang
StartButton.TextColor3 = Color3.fromRGB(220, 220, 220)
StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20) -- Merah gelap
StartButton.BorderSizePixel = 1
StartButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
StartButton.ZIndex = 2

local StartButtonCorner = Instance.new("UICorner")
StartButtonCorner.CornerRadius = UDim.new(0, 5)
StartButtonCorner.Parent = StartButton

-- --- Status Label ---
StatusLabel.Size = UDim2.new(1, -40, 0, 45) -- Lebih kecil
StatusLabel.Position = UDim2.new(0, 20, 0, yOffsetForTitle + 45)
StatusLabel.Text = "STATUS: STANDBY"
StatusLabel.Font = Enum.Font.SourceSansLight
StatusLabel.TextSize = 14 -- Ukuran font sedang
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220) -- Putih kebiruan
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Gelap
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.BorderSizePixel = 0
StatusLabel.ZIndex = 2

local StatusLabelCorner = Instance.new("UICorner")
StatusLabelCorner.CornerRadius = UDim.new(0, 5)
StatusLabelCorner.Parent = StatusLabel

local yOffsetForTimers = yOffsetForTitle + 100 -- Disesuaikan

-- --- Konfigurasi Timer UI ---
TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20) -- Lebih kecil
TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffsetForTimers)
TimerTitleLabel.Text = "// TIMER CONFIGURATION_SEQ"
TimerTitleLabel.Font = Enum.Font.Code
TimerTitleLabel.TextSize = 14 -- Ukuran font sedang
TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Merah terang
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerTitleLabel.ZIndex = 2

local function createTimerInput(name, yPos, labelText, initialValue)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.55, -25, 0, 20) -- Lebih kecil
    label.Position = UDim2.new(0, 20, 0, yPos + yOffsetForTimers)
    label.Text = labelText .. ":"
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12 -- Ukuran font sedang
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    timerInputElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.45, -25, 0, 20) -- Lebih kecil
    input.Position = UDim2.new(0.55, 5, 0, yPos + yOffsetForTimers)
    input.Text = tostring(initialValue)
    input.PlaceholderText = "sec"
    input.Font = Enum.Font.SourceSansSemibold
    input.TextSize = 12 -- Ukuran font sedang
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(100, 100, 120)
    input.BorderSizePixel = 1
    input.ZIndex = 2
    timerInputElements[name .. "Input"] = input

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 3)
    InputCorner.Parent = input

    return input
end

local currentYConfig = 30 -- Jarak dari TimerTitleLabel (disesuaikan)
-- Inisialisasi nilai input timer dari tabel timers
timerInputElements.wait1m30sInput = createTimerInput("Wait1m30s", currentYConfig, "T1_POST_ITEM_SET1", timers.wait_1m30s_after_first_items)
currentYConfig = currentYConfig + 25 -- Jarak antar input (disesuaikan)
timerInputElements.wait40sInput = createTimerInput("Wait40s", currentYConfig, "T2_ITEM2_QI_PAUSE", timers.alur_wait_40s_hide_qi)
currentYConfig = currentYConfig + 25
timerInputElements.comprehendInput = createTimerInput("Comprehend", currentYConfig, "T3_COMPREHEND_DUR", timers.comprehend_duration)
currentYConfig = currentYConfig + 25
timerInputElements.postComprehendQiInput = createTimerInput("PostComprehendQi", currentYConfig, "T4_POST_COMP_QI_DUR", timers.post_comprehend_qi_duration)
currentYConfig = currentYConfig + 35 -- Disesuaikan

ApplyTimersButton.Size = UDim2.new(1, -40, 0, 30) -- Lebih kecil
ApplyTimersButton.Position = UDim2.new(0, 20, 0, currentYConfig + yOffsetForTimers)
ApplyTimersButton.Text = "APPLY_TIMERS"
ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.TextSize = 14 -- Ukuran font sedang
ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(30, 80, 30) -- Hijau gelap
ApplyTimersButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
ApplyTimersButton.BorderSizePixel = 1
ApplyTimersButton.ZIndex = 2

local ApplyButtonCorner = Instance.new("UICorner")
ApplyButtonCorner.CornerRadius = UDim.new(0, 5)
ApplyButtonCorner.Parent = ApplyTimersButton

-- --- Tombol Minimize ---
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -35, 0, 10)
MinimizeButton.Text = "_" -- Simbol minimize
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.BorderColor3 = Color3.fromRGB(100,100,120)
MinimizeButton.BorderSizePixel = 1
MinimizeButton.ZIndex = 3

local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 3)
MinimizeButtonCorner.Parent = MinimizeButton

-- --- Pop-up 'Z' (Baru) ---
minimizedZLabel.Size = UDim2.new(1, 0, 1, 0) -- Akan mengisi seluruh Frame saat minimized
minimizedZLabel.Position = UDim2.new(0,0,0,0)
minimizedZLabel.Text = "Z"
minimizedZLabel.Font = Enum.Font.SourceSansBold
minimizedZLabel.TextScaled = false
minimizedZLabel.TextSize = 40 -- Ukuran besar agar memenuhi pop-up kecil
minimizedZLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Merah
minimizedZLabel.TextXAlignment = Enum.TextXAlignment.Center
minimizedZLabel.TextYAlignment = Enum.TextYAlignment.Center
minimizedZLabel.BackgroundTransparency = 1
minimizedZLabel.ZIndex = 4 -- Pastikan di atas semua
minimizedZLabel.Visible = false -- Awalnya sembunyi

-- Kumpulan elemen yang visibilitasnya akan di-toggle
elementsToToggleVisibility = {
    UiTitleLabel, StartButton, StatusLabel, TimerTitleLabel, ApplyTimersButton,
    timerInputElements.wait1m30sLabel, timerInputElements.wait1m30sInput,
    timerInputElements.wait40sLabel, timerInputElements.wait40sInput,
    timerInputElements.comprehendLabel, timerInputElements.comprehendInput,
    timerInputElements.postComprehendQiLabel, timerInputElements.postComprehendQiInput,
    MinimizeButton -- Include MinimizeButton here to hide it during 'Z' mode
}

-- // Fungsi Bantu UI //
local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: " .. string.upper(text) end
end

-- // Fungsi Animasi UI //
local TweenService = game:GetService("TweenService")
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

-- // Fungsi Minimize/Maximize UI //
local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        -- Simpan posisi original Frame sebelum diubah
        local originalFramePosition = Frame.Position

        -- Sembunyikan semua elemen kecuali Frame dan 'Z' label
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        minimizedZLabel.Visible = true -- Tampilkan 'Z'

        -- Hitung posisi target pop-up di pojok kanan bawah
        local targetX = 1 - (minimizedFrameSize.X.Offset / ScreenGui.AbsoluteSize.X) - 0.02 -- Sedikit dari kanan
        local targetY = 1 - (minimizedFrameSize.Y.Offset / ScreenGui.AbsoluteSize.Y) - 0.02 -- Sedikit dari bawah
        local targetPosition = UDim2.new(targetX, 0, targetY, 0)

        animateFrame(minimizedFrameSize, targetPosition)
        Frame.Draggable = false -- Matikan draggable saat diminimize untuk mencegah pergeseran
    else
        -- Tampilkan tombol minimize sebelum animasi maximize dimulai
        for _, element in ipairs(elementsToToggleVisibility) do
            if element == MinimizeButton and element.Parent then element.Visible = true end
        end

        minimizedZLabel.Visible = false -- Sembunyikan 'Z'
        MinimizeButton.Text = "_" -- Kembali ke simbol minimize

        -- Posisikan kembali ke tengah layar (gunakan originalFrameSize untuk posisi yang benar)
        local targetPosition = UDim2.new(0.5, -originalFrameSize.X.Offset/2, 0.5, -originalFrameSize.Y.Offset/2)
        animateFrame(originalFrameSize, targetPosition, function()
            -- Tampilkan semua elemen setelah animasi ukuran selesai
            for _, element in ipairs(elementsToToggleVisibility) do
                if element and element.Parent then element.Visible = true end
            end
            Frame.Draggable = true -- Aktifkan kembali draggable setelah maximize
        end)
    end
end

MinimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- // Fungsi tunggu //
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat
        task.wait()
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
            remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9)
        else
            remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9)
        end
        local remote = remoteEventFolder:WaitForChild(remoteName, 9e9)
        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
    end)
    if pcallSuccess then success = true
    else
        errMessage = tostring(pcallResult)
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: ERR_FIRE_" .. string.upper(remoteName) end
        warn("Error firing " .. remoteName .. ": " .. errMessage)
        success = false
    end
    return success
end

-- // Fungsi utama //
local function runCycle()
    updateStatus("Reincarnating_Proc")
    if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnateDelay)
    if not scriptRunning then return end
    updateStatus("Item_Set1_Prep")
    waitSeconds(timers.user_script_wait1_before_items1)
    if not scriptRunning then return end
    local item1 = {"Nine Heavens Galaxy Water", "Buzhou Divine Flower", "Fusang Divine Tree", "Calm Cultivation Mat"}
    for _, item in ipairs(item1) do
        if not scriptRunning then return end
        updateStatus("Buying: " .. item:sub(1,15).."...")
        if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
        task.wait(timers.buyItemDelay)
    end
    if not scriptRunning then return end
    updateStatus("Map_Change_Prep")
    waitSeconds(timers.wait_1m30s_after_first_items)
    if not scriptRunning then return end
    local function changeMap(name) return fireRemoteEnhanced("ChangeMap", "AreaEvents", name) end
    if not changeMap("immortal") then scriptRunning = false; return end
    task.wait(timers.changeMapDelay); updateStatus("Map: Immortal")
    if not scriptRunning then return end
    if not changeMap("chaos") then scriptRunning = false; return end
    task.wait(timers.changeMapDelay); updateStatus("Map: Chaos")
    if not scriptRunning then return end
    updateStatus("Chaotic_Road_Proc")
    if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
    task.wait(timers.genericShortDelay)
    if not scriptRunning then return end
    updateStatus("Item_Set2_Prep")
    pauseUpdateQiTemporarily = true
    updateStatus("QI_Update_Paused (" .. timers.alur_wait_40s_hide_qi .. "s)")
    waitSeconds(timers.alur_wait_40s_hide_qi)
    pauseUpdateQiTemporarily = false
    updateStatus("QI_Update_Resumed")
    if not scriptRunning then return end
    local item2 = {"Traceless Breeze Lotus", "Reincarnation World Destruction Black Lotus", "Ten Thousand Bodhi Tree"}
    for _, item in ipairs(item2) do
        if not scriptRunning then return end
        updateStatus("Buying: " .. item:sub(1,15).."...")
        if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
        task.wait(timers.buyItemDelay)
    end
    if not scriptRunning then return end
    if not changeMap("immortal") then scriptRunning = false; return end
    task.wait(timers.changeMapDelay); updateStatus("Map: Immortal (Return)")
    if not scriptRunning then return end
    if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
        updateStatus("HiddenRemote_Proc (QI_Active)")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
    else updateStatus("HiddenRemote_Skip (QI_Inactive)") end
    task.wait(timers.genericShortDelay)
    updateStatus("Forbidden_Zone_Prep (Direct)")
    if not scriptRunning then return end
    updateStatus("Forbidden_Zone_Enter")
    if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
    task.wait(timers.genericShortDelay)
    if not scriptRunning then return end
    updateStatus("Comprehend_Proc (" .. timers.comprehend_duration .. "s)")
    stopUpdateQi = true
    local comprehendStartTime = tick()
    while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
        if not fireRemoteEnhanced("Comprehend", "Base", {}) then updateStatus("Comprehend_Event_Fail"); break end
        updateStatus(string.format("Comprehending... %ds Left", math.floor(timers.comprehend_duration - (tick() - comprehendStartTime))))
        task.wait(1)
    end
    if not scriptRunning then return end; updateStatus("Comprehend_Complete")
    if scriptRunning then
        updateStatus("Post_Comprehend_Hidden_Proc")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then updateStatus("Post_Comp_Hidden_Fail") end
        task.wait(timers.genericShortDelay)
    end
    if not scriptRunning then return end
    updateStatus("Final_QI_Update (" .. timers.post_comprehend_qi_duration .. "s)")
    stopUpdateQi = false
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        if stopUpdateQi then updateStatus("Post_Comp_QI_Halt"); break end
        updateStatus(string.format("Post_Comp_QI_Active... %ds Left", math.floor(timers.post_comprehend_qi_duration - (tick() - postComprehendQiStartTime))))
        task.wait(1)
    end
    if not scriptRunning then return end; stopUpdateQi = true
    updateStatus("Cycle_Complete_Restarting")
end

-- Loop Latar Belakang
local function increaseAptitudeMineLoop_enhanced()
    while scriptRunning do
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        task.wait(timers.aptitude_mine_interval)
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait()
    end
end
local function updateQiLoop_enhanced()
    while scriptRunning do
        if not stopUpdateQi and not pauseUpdateQiTemporarily then fireRemoteEnhanced("UpdateQi", "Base", {}) end
        task.wait(timers.update_qi_interval)
    end
end

-- Tombol Start
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning
    if scriptRunning then
        StartButton.Text = "SYSTEM_ACTIVE"
        StartButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30) -- Merah menyala
        StartButton.TextColor3 = Color3.fromRGB(255,255,255)
        updateStatus("INIT_SEQUENCE")
        stopUpdateQi = false; pauseUpdateQiTemporarily = false
        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then aptitudeMineThread = task.spawn(increaseAptitudeMineLoop_enhanced) end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then updateQiThread = task.spawn(updateQiLoop_enhanced) end
        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = task.spawn(function()
                while scriptRunning do
                    runCycle()
                    if not scriptRunning then break end
                    updateStatus("CYCLE_REINIT")
                    task.wait(1)
                end
                updateStatus("SYSTEM_HALTED")
                StartButton.Text = "START SEQUENCE"
                StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
                StartButton.TextColor3 = Color3.fromRGB(220,220,220)
            end)
        end
    else
        updateStatus("HALT_REQUESTED")
    end
end)

-- Tombol Apply Timers
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false; if not inputElement then return false end
        local value = tonumber(inputElement.Text)
        if value and value >= 0 then timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(80,255,80) end) end; success = true
        else if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(255,80,80) end) end
        end
        return success
    end
    local allTimersValid = true
    allTimersValid = applyTextInput(timerInputElements.wait1m30sInput, "wait_1m30s_after_first_items", timerInputElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.wait40sInput, "alur_wait_40s_hide_qi", timerInputElements.Wait40sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.comprehendInput, "comprehend_duration", timerInputElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerInputElements.postComprehendQiInput, "post_comprehend_qi_duration", timerInputElements.PostComprehendQiLabel) and allTimersValid
    local originalStatus = StatusLabel.Text:gsub("STATUS: ", "")
    if allTimersValid then updateStatus("TIMER_CONFIG_APPLIED") else updateStatus("ERR_TIMER_INPUT_INVALID") end
    task.wait(2)
    if timerInputElements.Wait1m30sLabel then pcall(function() timerInputElements.Wait1m30sLabel.TextColor3 = Color3.fromRGB(180,180,200) end) end
    if timerInputElements.Wait40sLabel then pcall(function() timerInputElements.Wait40sLabel.TextColor3 = Color3.fromRGB(180,180,200) end) end
    if timerInputElements.ComprehendLabel then pcall(function() timerInputElements.ComprehendLabel.TextColor3 = Color3.fromRGB(180,180,200) end) end
    if timerInputElements.PostComprehendQiLabel then pcall(function() timerInputElements.PostComprehendQiLabel.TextColor3 = Color3.fromRGB(180,180,200) end) end
    updateStatus(originalStatus)
end)

-- --- ANIMASI UI ---
-- Menggunakan task.spawn() untuk memastikan animasi berjalan di thread terpisah.
-- task.spawn() umumnya lebih andal dan direkomendasikan daripada spawn() lama.

task.spawn(function() -- Animasi Latar Belakang Frame (Glitchy Background)
    if not Frame or not Frame.Parent then return end
    local baseColor = Color3.fromRGB(15, 15, 20)
    local glitchColor1 = Color3.fromRGB(25, 20, 30)
    local glitchColor2 = Color3.fromRGB(10, 10, 15)
    local borderBase = Color3.fromRGB(255,0,0)
    local borderGlitch = Color3.fromRGB(0,255,255)

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then -- Hanya beranimasi saat tidak diminimize
            local r = math.random()
            if r < 0.05 then -- Glitch intens
                Frame.BackgroundColor3 = glitchColor1
                Frame.BorderColor3 = borderGlitch
                task.wait(0.05)
                Frame.BackgroundColor3 = glitchColor2
                task.wait(0.05)
            elseif r < 0.2 then -- Glitch ringan
                Frame.BackgroundColor3 = Color3.Lerp(baseColor, glitchColor1, math.random())
                Frame.BorderColor3 = Color3.Lerp(borderBase, borderGlitch, math.random()*0.5)
                task.wait(0.1)
            else
                Frame.BackgroundColor3 = baseColor
                Frame.BorderColor3 = borderBase
            end
            -- Animasi border utama (HSV shift)
            local h,s,v = Color3.toHSV(Frame.BorderColor3)
            Frame.BorderColor3 = Color3.fromHSV((h + 0.005)%1, s, v)
        else -- Jika diminimize, pastikan warna kembali normal untuk 'Z'
            Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            Frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Atau warna solid apa pun yang Anda inginkan untuk pop-up
        end
        task.wait(0.05)
    end
end)

task.spawn(function() -- Animasi UiTitleLabel (ZXHELL Glitch)
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText = UiTitleLabel.Text
    local glitchChars = {"@", "#", "$", "%", "&", "*", "!", "?", "/", "\\", "|", "_"}
    local baseColor = Color3.fromRGB(255, 25, 25)
    local originalPos = UiTitleLabel.Position

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then -- Hanya beranimasi saat tidak diminimize
            local r = math.random()
            local isGlitchingText = false

            if r < 0.02 then -- Glitch Text Parah & Posisi
                isGlitchingText = true
                local newText = ""
                for i = 1, #originalText do
                    if math.random() < 0.7 then
                        newText = newText .. glitchChars[math.random(#glitchChars)]
                    else
                        newText = newText .. originalText:sub(i,i)
                    end
                end
                UiTitleLabel.Text = newText
                UiTitleLabel.TextColor3 = Color3.fromRGB(math.random(200,255), math.random(0,50), math.random(0,50))
                UiTitleLabel.Position = originalPos + UDim2.fromOffset(math.random(-2,2), math.random(-2,2))
                UiTitleLabel.Rotation = math.random(-1,1) * 0.5
                task.wait(0.07)
            elseif r < 0.1 then -- Glitch Warna & Stroke
                UiTitleLabel.TextColor3 = Color3.fromHSV(math.random(), 1, 1)
                UiTitleLabel.TextStrokeColor3 = Color3.fromHSV(math.random(), 0.8, 1)
                UiTitleLabel.TextStrokeTransparency = math.random() * 0.3
                UiTitleLabel.Rotation = math.random(-1,1) * 0.2
                task.wait(0.1)
            else -- Kembali normal atau animasi warna halus
                UiTitleLabel.Text = originalText
                UiTitleLabel.TextStrokeTransparency = 0.5
                UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
                UiTitleLabel.Position = originalPos
                UiTitleLabel.Rotation = 0
            end

            -- Animasi warna RGB halus jika tidak sedang glitch parah
            if not isGlitchingText then
                local hue = (tick()*0.1) % 1
                local r_rgb, g_rgb, b_rgb = Color3.fromHSV(hue, 1, 1).R, Color3.fromHSV(hue, 1, 1).G, Color3.fromHSV(hue, 1, 1).B
                r_rgb = math.min(1, r_rgb + 0.6) -- Dominasi merah
                g_rgb = g_rgb * 0.4
                b_rgb = b_rgb * 0.4
                UiTitleLabel.TextColor3 = Color3.new(r_rgb, g_rgb, b_rgb)
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function() -- Animasi Tombol (Subtle Pulse)
    local buttonsToAnimate = {StartButton, ApplyTimersButton, MinimizeButton}
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then -- Hanya beranimasi saat tidak diminimize
            for _, btn in ipairs(buttonsToAnimate) do
                if btn and btn.Parent then
                    local originalBorder = btn.BorderColor3

                    -- Efek hover/pulse sederhana pada border
                    if btn.Name == "StartButton" and scriptRunning then
                        btn.BorderColor3 = Color3.fromRGB(255,100,100) -- Merah lebih terang saat running
                    else
                        local h,s,v = Color3.toHSV(originalBorder)
                        btn.BorderColor3 = Color3.fromHSV(h,s, math.sin(tick()*2)*0.1 + 0.9) -- Pulse V
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function() -- Animasi Pop-up 'Z' (RGB Pulse)
    while ScreenGui and ScreenGui.Parent do
        if isMinimized and minimizedZLabel.Visible then
            local hue = (tick() * 0.2) % 1 -- Animasi warna RGB
            minimizedZLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
        end
        task.wait(0.05)
    end
end)
-- --- END ANIMASI UI ---

-- BindToClose
game:BindToClose(function()
    if scriptRunning then warn("Game ditutup, menghentikan skrip..."); scriptRunning = false; task.wait(0.5) end
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    print("Pembersihan skrip selesai.")
end)

-- Inisialisasi
print("Skrip Otomatisasi (Versi UI Canggih) Telah Dimuat.")
task.wait(1)
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then StatusLabel.Text = "STATUS: STANDBY" end
