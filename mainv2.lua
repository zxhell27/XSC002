-- Pastikan skrip ini adalah LocalScript dan ditempatkan di StarterPlayerScripts atau StarterGui.

print("ZXHELL X ZEDLIST Script: Memulai eksekusi LocalScript...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("ZXHELL X ZEDLIST Script: LocalPlayer tidak ditemukan. Skrip tidak akan berjalan.")
    return -- Hentikan skrip jika tidak ada LocalPlayer (misalnya, dijalankan di server)
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("ZXHELL X ZEDLIST Script: LocalPlayer dan PlayerGui ditemukan.")

-- // UI FRAME //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZXHELL_ZEDLIST_UI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false -- PENTING: Mencegah UI hilang saat respawn
ScreenGui.Enabled = true -- Pastikan ScreenGui aktif dari awal

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Active = true
Frame.Visible = true
Frame.Draggable = true

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Active = true

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"

local MinimizeButton = Instance.new("TextButton") -- Tombol minimize asli
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Active = true

local MinimizedActionButton = Instance.new("TextButton") -- Tombol "Z" saat minimize
MinimizedActionButton.Name = "MinimizedActionButton"
MinimizedActionButton.Active = true
MinimizedActionButton.Visible = false -- Awalnya tidak terlihat

local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"
ApplyTimersButton.Active = true

local timerInputElements = {}

-- --- Variabel Kontrol dan State ---
local scriptRunning = false
local stopUpdateQi = true -- Awalnya Qi dihentikan sampai siklus dimulai
local mainCycleThread = nil
local updateQiThread = nil
local aptitudeMineThread = nil -- Thread untuk Aptitude dan Mine

local isMinimized = false
-- Ukuran frame disesuaikan agar lebih proporsional
local originalFrameSize = UDim2.new(0, 280, 0, 420) -- Sedikit lebih lebar, lebih pendek
local minimizedFrameSize = UDim2.new(0, 50, 0, 50) -- Ukuran saat minimize (tombol Z)

local elementsToToggleVisibility = {}

-- --- Tabel Konfigurasi Timer ---
-- Timer disesuaikan dengan kebutuhan siklus baru
local timers = {
    reincarnate_delay = 1.5,
    change_map_delay = 0.7,
    -- Durasi untuk fase Update Qi pertama (sebelum Comprehend)
    qi_update_phase1_duration = 45,
    -- Durasi untuk proses Comprehend
    comprehend_duration = 20,
    -- Durasi untuk fase Update Qi kedua (setelah Comprehend)
    qi_update_phase2_duration = 30,
    -- Interval untuk memanggil remote UpdateQi
    update_qi_interval = 1,
    -- Interval untuk memanggil remote Aptitude dan Mine
    aptitude_mine_interval = 0.2, -- Interval yang lebih wajar
    genericShortDelay = 0.5
}

-- // Parent UI ke player //
local function setupGuiParenting()
    if not (ScreenGui and PlayerGui) then
        warn("ZXHELL X ZEDLIST Script: ScreenGui atau PlayerGui nil saat setupGuiParenting.")
        return
    end

    ScreenGui.Parent = PlayerGui
    print("ZXHELL X ZEDLIST Script: ScreenGui diparentkan ke PlayerGui.")

    Frame.Parent = ScreenGui
    UiTitleLabel.Parent = Frame
    StartButton.Parent = Frame
    StatusLabel.Parent = Frame
    MinimizeButton.Parent = Frame
    MinimizedActionButton.Parent = Frame -- Parentkan tombol Z
    TimerTitleLabel.Parent = Frame
    ApplyTimersButton.Parent = Frame

    print("ZXHELL X ZEDLIST Script: Semua elemen UI utama telah diparentkan ke Frame.")
end
setupGuiParenting()


-- // Desain UI (Pastikan ZIndex dan Visibilitas Awal) //
Frame.Size = originalFrameSize
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18) -- Gelap kebiruan
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(200, 0, 0) -- Merah
Frame.ClipsDescendants = true
local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 12); UICorner.Parent = Frame

UiTitleLabel.Size = UDim2.new(1, -20, 0, 35); UiTitleLabel.Position = UDim2.new(0, 10, 0, 8)
UiTitleLabel.Font = Enum.Font.SourceSansSemibold
UiTitleLabel.Text = "ZXHELL X ZEDLIST" -- Nama UI baru
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 40, 40); UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 24; UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.BackgroundTransparency = 1; UiTitleLabel.ZIndex = 2
UiTitleLabel.TextStrokeTransparency = 0.4; UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(60,0,0)

local yOffsetForTitle = 45 -- Jarak dari atas setelah title

StartButton.Size = UDim2.new(1, -40, 0, 38); StartButton.Position = UDim2.new(0, 20, 0, yOffsetForTitle)
StartButton.Text = "START SEQUENCE"; StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 17; StartButton.TextColor3 = Color3.fromRGB(230, 230, 230)
StartButton.BackgroundColor3 = Color3.fromRGB(100, 25, 25); StartButton.BorderSizePixel = 1
StartButton.BorderColor3 = Color3.fromRGB(255, 60, 60); StartButton.ZIndex = 2
local StartButtonCorner = Instance.new("UICorner"); StartButtonCorner.CornerRadius = UDim.new(0, 6); StartButtonCorner.Parent = StartButton

StatusLabel.Size = UDim2.new(1, -40, 0, 50); StatusLabel.Position = UDim2.new(0, 20, 0, yOffsetForTitle + 48)
StatusLabel.Text = "STATUS: STANDBY"; StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14; StatusLabel.TextColor3 = Color3.fromRGB(210, 210, 230)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28); StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.PaddingLeft = UDim.new(0,5); StatusLabel.PaddingTop = UDim.new(0,5)
StatusLabel.BorderSizePixel = 0; StatusLabel.ZIndex = 2
local StatusLabelCorner = Instance.new("UICorner"); StatusLabelCorner.CornerRadius = UDim.new(0, 6); StatusLabelCorner.Parent = StatusLabel

local yOffsetForTimers = yOffsetForTitle + 110 -- Jarak untuk bagian timer

TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20); TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffsetForTimers)
TimerTitleLabel.Text = "// TIMER_CONFIGURATION"; TimerTitleLabel.Font = Enum.Font.Code
TimerTitleLabel.TextSize = 15; TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
TimerTitleLabel.BackgroundTransparency = 1; TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TimerTitleLabel.ZIndex = 2

local function createTimerInput(name, yPos, labelText, timerKey)
    local label = Instance.new("TextLabel"); label.Name = name .. "Label"; label.Parent = Frame
    label.Size = UDim2.new(0.68, -25, 0, 20); label.Position = UDim2.new(0, 20, 0, yPos + yOffsetForTimers)
    label.Text = labelText .. ":"; label.Font = Enum.Font.SourceSans; label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(190, 190, 210); label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 2
    timerInputElements[name .. "Label"] = label

    local input = Instance.new("TextBox"); input.Name = name .. "Input"; input.Parent = Frame
    input.Size = UDim2.new(0.32, -25, 0, 20); input.Position = UDim2.new(0.68, 5, 0, yPos + yOffsetForTimers)
    input.Text = tostring(timers[timerKey]); input.PlaceholderText = "sec"; input.Font = Enum.Font.SourceSansSemibold
    input.TextSize = 12; input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 45); input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(110, 110, 130); input.BorderSizePixel = 1; input.ZIndex = 2
    timerInputElements[name .. "Input"] = input
    local InputCorner = Instance.new("UICorner"); InputCorner.CornerRadius = UDim.new(0, 4); InputCorner.Parent = input
    return input
end

local currentYConfig = 25; local timerSpacing = 23 -- Spasi antar input timer
timerInputElements.reincarnateDelayInput = createTimerInput("ReincarnateDelay", currentYConfig, "T1_REINCARNATE", "reincarnate_delay"); currentYConfig = currentYConfig + timerSpacing
timerInputElements.changeMapDelayInput = createTimerInput("ChangeMapDelay", currentYConfig, "T2_CHANGE_MAP", "change_map_delay"); currentYConfig = currentYConfig + timerSpacing
timerInputElements.qiUpdatePhase1Input = createTimerInput("QiUpdatePhase1", currentYConfig, "T3_QI_PHASE1_DUR", "qi_update_phase1_duration"); currentYConfig = currentYConfig + timerSpacing
timerInputElements.comprehendDurationInput = createTimerInput("ComprehendDuration", currentYConfig, "T4_COMPREHEND_DUR", "comprehend_duration"); currentYConfig = currentYConfig + timerSpacing
timerInputElements.qiUpdatePhase2Input = createTimerInput("QiUpdatePhase2", currentYConfig, "T5_QI_PHASE2_DUR", "qi_update_phase2_duration"); currentYConfig = currentYConfig + timerSpacing
timerInputElements.updateQiIntervalInput = createTimerInput("UpdateQiInterval", currentYConfig, "T6_UPDATE_QI_INTV", "update_qi_interval"); currentYConfig = currentYConfig + timerSpacing
timerInputElements.aptitudeMineIntervalInput = createTimerInput("AptitudeMineInterval", currentYConfig, "T7_APT_MINE_INTV", "aptitude_mine_interval"); currentYConfig = currentYConfig + timerSpacing + 8

ApplyTimersButton.Size = UDim2.new(1, -40, 0, 32); ApplyTimersButton.Position = UDim2.new(0, 20, 0, currentYConfig + yOffsetForTimers)
ApplyTimersButton.Text = "APPLY TIMERS"; ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.TextSize = 15; ApplyTimersButton.TextColor3 = Color3.fromRGB(230, 230, 230)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(35, 90, 35); ApplyTimersButton.BorderColor3 = Color3.fromRGB(90, 255, 90)
ApplyTimersButton.BorderSizePixel = 1; ApplyTimersButton.ZIndex = 2
local ApplyButtonCorner = Instance.new("UICorner"); ApplyButtonCorner.CornerRadius = UDim.new(0, 6); ApplyButtonCorner.Parent = ApplyTimersButton

MinimizeButton.Size = UDim2.new(0, 25, 0, 25); MinimizeButton.Position = UDim2.new(1, -35, 0, 8) -- Posisi di kanan atas title
MinimizeButton.Text = "_"; MinimizeButton.Font = Enum.Font.SourceSansBold; MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(190, 190, 190); MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinimizeButton.BorderColor3 = Color3.fromRGB(110,110,130); MinimizeButton.BorderSizePixel = 1; MinimizeButton.ZIndex = 3
local MinimizeButtonCorner = Instance.new("UICorner"); MinimizeButtonCorner.CornerRadius = UDim.new(0, 4); MinimizeButtonCorner.Parent = MinimizeButton

-- Pengaturan untuk MinimizedActionButton (tombol "Z")
MinimizedActionButton.Size = UDim2.new(1,0,1,0) -- Mengisi frame saat minimize
MinimizedActionButton.Position = UDim2.new(0,0,0,0)
MinimizedActionButton.Text = "Z"; MinimizedActionButton.Font = Enum.Font.FredokaOne -- Font yang lebih menonjol
MinimizedActionButton.TextScaled = false; MinimizedActionButton.TextSize = 32
MinimizedActionButton.TextColor3 = Color3.fromRGB(255, 50, 50)
MinimizedActionButton.TextXAlignment = Enum.TextXAlignment.Center; MinimizedActionButton.TextYAlignment = Enum.TextYAlignment.Center
MinimizedActionButton.BackgroundColor3 = Color3.fromRGB(20,20,28) -- Background seragam dengan frame luar
MinimizedActionButton.BorderColor3 = Color3.fromRGB(255,0,0)
MinimizedActionButton.BorderSizePixel = 2
MinimizedActionButton.ZIndex = 4 -- ZIndex tertinggi saat minimize
local MinimizedActionCorner = Instance.new("UICorner"); MinimizedActionCorner.CornerRadius = UDim.new(0,8); MinimizedActionCorner.Parent = MinimizedActionButton


elementsToToggleVisibility = {
    UiTitleLabel, StartButton, StatusLabel, TimerTitleLabel, ApplyTimersButton, MinimizeButton,
    timerInputElements.ReincarnateDelayLabel, timerInputElements.reincarnateDelayInput,
    timerInputElements.ChangeMapDelayLabel, timerInputElements.changeMapDelayInput,
    timerInputElements.QiUpdatePhase1Label, timerInputElements.qiUpdatePhase1Input,
    timerInputElements.ComprehendDurationLabel, timerInputElements.comprehendDurationInput,
    timerInputElements.QiUpdatePhase2Label, timerInputElements.qiUpdatePhase2Input,
    timerInputElements.UpdateQiIntervalLabel, timerInputElements.updateQiIntervalInput,
    timerInputElements.AptitudeMineIntervalLabel, timerInputElements.aptitudeMineIntervalInput
}

-- Fungsi untuk memperbarui status dengan aman
local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then
        -- Pastikan pembaruan UI dilakukan di thread utama jika memungkinkan (Roblox menangani ini secara implisit untuk LocalScripts)
        StatusLabel.Text = "STATUS: " .. string.upper(text)
    else
        warn("ZXHELL X ZEDLIST: StatusLabel tidak valid saat mencoba updateStatus: " .. text)
    end
end

-- Fungsi tunggu yang menghormati scriptRunning
local function waitSeconds(sec)
    if sec == nil or sec <= 0 then task.wait() return end -- Handle nil or non-positive seconds
    local startTime = tick()
    repeat
        task.wait() -- Yields the current thread, allowing other scripts to run
    until not scriptRunning or (tick() - startTime >= sec)
    -- Jika scriptRunning menjadi false, fungsi akan keluar lebih awal
end

-- Fungsi fireRemote yang ditingkatkan dengan pemeriksaan dan timeout
local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...)
    local remoteEventFolder
    local success = false
    local errMessage = "Unknown error"

    -- Pcall untuk menangani error saat mencari remote atau saat FireServer
    local pcallSuccess, pcallResult = pcall(function()
        local RemoteEventsContainer = ReplicatedStorage:WaitForChild("RemoteEvents", 10) -- Timeout 10 detik
        if not RemoteEventsContainer then
            warn("ZXHELL X ZEDLIST: Folder RemoteEvents tidak ditemukan di ReplicatedStorage.")
            return -- Keluar jika folder utama tidak ada
        end

        if pathType == "AreaEvents" then
            remoteEventFolder = RemoteEventsContainer:WaitForChild("AreaEvents", 5) -- Timeout lebih pendek untuk subfolder
            if not remoteEventFolder then
                warn("ZXHELL X ZEDLIST: Folder AreaEvents tidak ditemukan di RemoteEvents.")
                return
            end
        else
            remoteEventFolder = RemoteEventsContainer -- Untuk path "Base"
        end

        local remote = remoteEventFolder:WaitForChild(remoteName, 5)
        if not remote then
            warn("ZXHELL X ZEDLIST: RemoteEvent '"..remoteName.."' tidak ditemukan di "..remoteEventFolder.Name)
            return
        end

        -- Memastikan remote adalah RemoteEvent sebelum FireServer
        if remote:IsA("RemoteEvent") then
            remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
        else
            warn("ZXHELL X ZEDLIST: Objek '"..remoteName.."' bukan RemoteEvent.")
            return
        end
    end)

    if pcallSuccess and pcallResult == nil then -- pcallResult nil berarti fungsi di dalam pcall berjalan tanpa error return
        success = true
    else
        errMessage = tostring(pcallResult or "Error during pcall execution") -- Tangkap pesan error
        updateStatus("ERR_FIRE_" .. string.upper(remoteName))
        warn("ZXHELL X ZEDLIST: Error firing " .. remoteName .. ": " .. errMessage)
        success = false -- Tetap false jika ada error atau remote tidak ditemukan
    end
    return success
end


-- Fungsi untuk animasi minimize/maximize
local function animateFrame(targetSize, targetPosition, isMinimizing, callback)
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {Size = targetSize, Position = targetPosition}
    local tween = TweenService:Create(Frame, info, properties)
    tween:Play()

    if callback then
        tween.Completed:Wait()
        callback()
    end
end

-- Fungsi untuk toggle minimize state
local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        -- Menyembunyikan elemen-elemen utama
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        MinimizedActionButton.Visible = true -- Tampilkan tombol Z
        Frame.Draggable = false -- Nonaktifkan drag saat minimize

        -- Hitung posisi target untuk sudut kanan bawah (dengan sedikit margin)
        local screenX, screenY = ScreenGui.AbsoluteSize.X, ScreenGui.AbsoluteSize.Y
        local targetX = screenX - minimizedFrameSize.X.Offset - 10 -- 10px margin dari kanan
        local targetY = screenY - minimizedFrameSize.Y.Offset - 10 -- 10px margin dari bawah
        local targetPosition = UDim2.fromOffset(targetX, targetY)

        animateFrame(minimizedFrameSize, targetPosition, true)
    else
        MinimizedActionButton.Visible = false -- Sembunyikan tombol Z
        local targetPosition = UDim2.new(0.5, -originalFrameSize.X.Offset/2, 0.5, -originalFrameSize.Y.Offset/2)
        animateFrame(originalFrameSize, targetPosition, false, function()
            -- Tampilkan kembali elemen setelah animasi selesai
            for _, element in ipairs(elementsToToggleVisibility) do
                if element and element.Parent then element.Visible = true end
            end
            Frame.Draggable = true -- Aktifkan kembali drag
        end)
    end
end


-- // SIKLUS UTAMA //
local function runCycle()
    if not scriptRunning then return end

    -- 1. Reinkarnasi
    updateStatus("Reincarnating_Proc")
    if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    waitSeconds(timers.reincarnate_delay)
    if not scriptRunning then return end

    -- 2. Fase Update Qi Pertama (dengan HiddenRemote)
    -- Asumsi: HiddenRemote mungkin memerlukan map tertentu, misal "immortal"
    updateStatus("Map_Change_To_Immortal (For Hidden)")
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then scriptRunning = false; return end
    waitSeconds(timers.change_map_delay)
    if not scriptRunning then return end

    updateStatus("QI_Update_P1_With_Hidden (" .. timers.qi_update_phase1_duration .. "s)")
    stopUpdateQi = false -- Aktifkan updateQiLoop_enhanced
    if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then
        updateStatus("HiddenRemote_P1_Fail")
        -- Pertimbangkan apakah akan menghentikan siklus atau lanjut jika HiddenRemote gagal
    end
    local qiPhase1StartTime = tick()
    while scriptRunning and (tick() - qiPhase1StartTime < timers.qi_update_phase1_duration) do
        if stopUpdateQi then updateStatus("QI_P1_Halted"); break end -- Jika dihentikan dari luar
        updateStatus(string.format("QI_P1_Hidden_Active... %ds Left", math.max(0, math.floor(timers.qi_update_phase1_duration - (tick() - qiPhase1StartTime)))))
        task.wait(1) -- Update status setiap detik
    end
    if not scriptRunning then return end

    -- 3. Comprehend (dengan ForbiddenZone)
    -- Asumsi: ForbiddenZone mungkin memerlukan map tertentu, misal "chaos"
    updateStatus("Map_Change_To_Chaos (For Forbidden)")
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "chaos") then scriptRunning = false; return end
    waitSeconds(timers.change_map_delay)
    if not scriptRunning then return end

    updateStatus("Forbidden_Zone_Entry")
    if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then
        updateStatus("ForbiddenZone_Fail")
        scriptRunning = false; return -- ForbiddenZone adalah prasyarat kritis
    end
    waitSeconds(timers.genericShortDelay) -- Delay setelah masuk zona
    if not scriptRunning then return end

    updateStatus("Comprehend_Proc (" .. timers.comprehend_duration .. "s)")
    stopUpdateQi = true -- Hentikan UpdateQi selama Comprehend
    local comprehendStartTime = tick()
    while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
        if not fireRemoteEnhanced("Comprehend", "Base", {}) then
            updateStatus("Comprehend_Event_Fail")
            -- Mungkin tidak perlu menghentikan seluruh skrip jika satu event Comprehend gagal, tergantung desain game
            break
        end
        updateStatus(string.format("Comprehending... %ds Left", math.max(0, math.floor(timers.comprehend_duration - (tick() - comprehendStartTime)))))
        task.wait(1) -- Panggil Comprehend setiap detik
    end
    if not scriptRunning then return end
    updateStatus("Comprehend_Complete")

    -- 4. Fase Update Qi Kedua (dengan HiddenRemote, setelah Comprehend)
    -- Kembali ke map "immortal" jika HiddenRemote memerlukannya
    updateStatus("Map_Change_To_Immortal (For Hidden P2)")
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then scriptRunning = false; return end
    waitSeconds(timers.change_map_delay)
    if not scriptRunning then return end

    updateStatus("QI_Update_P2_With_Hidden (" .. timers.qi_update_phase2_duration .. "s)")
    stopUpdateQi = false -- Aktifkan kembali updateQiLoop_enhanced
    if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then
        updateStatus("HiddenRemote_P2_Fail")
    end
    local qiPhase2StartTime = tick()
    while scriptRunning and (tick() - qiPhase2StartTime < timers.qi_update_phase2_duration) do
        if stopUpdateQi then updateStatus("QI_P2_Halted"); break end
        updateStatus(string.format("QI_P2_Hidden_Active... %ds Left", math.max(0, math.floor(timers.qi_update_phase2_duration - (tick() - qiPhase2StartTime)))))
        task.wait(1)
    end
    if not scriptRunning then return end
    stopUpdateQi = true -- Hentikan UpdateQi di akhir siklus sebelum restart

    updateStatus("Cycle_Complete. Restarting_Soon...")
end

-- // LOOP LATAR BELAKANG //

-- Loop untuk UpdateQi
local function updateQiLoop_enhanced()
    print("ZXHELL X ZEDLIST: updateQiLoop_enhanced thread started.")
    while scriptRunning do
        if not stopUpdateQi then
            if not fireRemoteEnhanced("UpdateQi", "Base", {}) then
                updateStatus("UpdateQi_Call_Fail")
                -- Tidak menghentikan loop, biarkan mencoba lagi
            end
        end
        local interval = timers.update_qi_interval
        if interval <= 0.03 then interval = 0.03 end -- Batas bawah interval untuk mencegah spam berlebih
        waitSeconds(interval) -- Gunakan waitSeconds yang menghormati scriptRunning
    end
    print("ZXHELL X ZEDLIST: updateQiLoop_enhanced thread ended.")
end

-- Loop untuk IncreaseAptitude dan Mine
local function increaseAptitudeMineLoop_enhanced()
    print("ZXHELL X ZEDLIST: increaseAptitudeMineLoop_enhanced thread started.")
    while scriptRunning do
        if not fireRemoteEnhanced("IncreaseAptitude", "Base", {}) then
            updateStatus("Aptitude_Call_Fail")
        end
        -- Interval dibagi dua agar Aptitude dan Mine dipanggil secara bergantian dengan cepat
        waitSeconds(timers.aptitude_mine_interval / 2)
        if not scriptRunning then break end

        if not fireRemoteEnhanced("Mine", "Base", {}) then
            updateStatus("Mine_Call_Fail")
        end
        waitSeconds(timers.aptitude_mine_interval / 2)
    end
    print("ZXHELL X ZEDLIST: increaseAptitudeMineLoop_enhanced thread ended.")
end


-- // KONEKSI EVENT //
if StartButton then
    StartButton.MouseButton1Click:Connect(function()
        scriptRunning = not scriptRunning
        if scriptRunning then
            StartButton.Text = "SYSTEM ACTIVE"; StartButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40); StartButton.TextColor3 = Color3.fromRGB(255,255,255)
            updateStatus("INIT_ZXHELL_SEQUENCE")
            stopUpdateQi = true -- Pastikan Qi berhenti sebelum siklus utama mungkin mengubahnya

            -- Mulai thread latar belakang jika belum berjalan
            if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
                aptitudeMineThread = task.spawn(increaseAptitudeMineLoop_enhanced)
            end
            if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
                updateQiThread = task.spawn(updateQiLoop_enhanced)
            end

            -- Mulai thread siklus utama
            if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
                mainCycleThread = task.spawn(function()
                    print("ZXHELL X ZEDLIST: Main cycle thread started.")
                    while scriptRunning do
                        runCycle()
                        if not scriptRunning then break end
                        updateStatus("CYCLE_REINIT_WAIT")
                        task.wait(1) -- Delay singkat sebelum memulai siklus baru
                    end
                    updateStatus("SYSTEM_HALTED")
                    StartButton.Text = "START SEQUENCE"; StartButton.BackgroundColor3 = Color3.fromRGB(100, 25, 25)
                    StartButton.TextColor3 = Color3.fromRGB(230,230,230)
                    stopUpdateQi = true -- Pastikan Qi berhenti saat skrip dihentikan
                    print("ZXHELL X ZEDLIST: Main cycle thread ended.")
                end)
            end
        else
            updateStatus("HALT_REQUESTED")
            -- scriptRunning sudah false, loop di thread akan berhenti secara alami
            -- stopUpdateQi sudah diatur true di akhir siklus atau saat start button ditekan stop
        end
    end)
else warn("ZXHELL X ZEDLIST: StartButton adalah nil sebelum menghubungkan event.") end

if ApplyTimersButton then
    ApplyTimersButton.MouseButton1Click:Connect(function()
        local function applyTextInput(inputElement, timerKey, labelElement)
            local success = false
            if not inputElement then warn("Input element for "..timerKey.." is nil."); return false end
            local value = tonumber(inputElement.Text)
            if value and value >= 0 then
                timers[timerKey] = value
                if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(90,255,90) end) end
                success = true
            else
                if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(255,90,90) end) end
                warn("Invalid input for timer "..timerKey..": "..tostring(inputElement.Text))
            end
            return success
        end

        local allTimersValid = true
        allTimersValid = applyTextInput(timerInputElements.reincarnateDelayInput, "reincarnate_delay", timerInputElements.ReincarnateDelayLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.changeMapDelayInput, "change_map_delay", timerInputElements.ChangeMapDelayLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.qiUpdatePhase1Input, "qi_update_phase1_duration", timerInputElements.QiUpdatePhase1Label) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.comprehendDurationInput, "comprehend_duration", timerInputElements.ComprehendDurationLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.qiUpdatePhase2Input, "qi_update_phase2_duration", timerInputElements.QiUpdatePhase2Label) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.updateQiIntervalInput, "update_qi_interval", timerInputElements.UpdateQiIntervalLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.aptitudeMineIntervalInput, "aptitude_mine_interval", timerInputElements.AptitudeMineIntervalLabel) and allTimersValid

        local originalStatus = StatusLabel.Text:gsub("STATUS: ", "")
        if allTimersValid then updateStatus("TIMER_CONFIG_APPLIED") else updateStatus("ERR_TIMER_INPUT_INVALID") end
        task.wait(1.5)
        local labelsToResetColor = {
            timerInputElements.ReincarnateDelayLabel, timerInputElements.ChangeMapDelayLabel,
            timerInputElements.QiUpdatePhase1Label, timerInputElements.ComprehendDurationLabel,
            timerInputElements.QiUpdatePhase2Label, timerInputElements.UpdateQiIntervalLabel,
            timerInputElements.AptitudeMineIntervalLabel
        }
        for _, lbl in ipairs(labelsToResetColor) do
            if lbl then pcall(function() lbl.TextColor3 = Color3.fromRGB(190,190,210) end) end
        end
        updateStatus(originalStatus)
    end)
else warn("ZXHELL X ZEDLIST: ApplyTimersButton adalah nil sebelum menghubungkan event.") end

-- Koneksi event untuk tombol minimize dan tombol Z
if MinimizeButton then MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
else warn("ZXHELL X ZEDLIST: MinimizeButton adalah nil.") end

if MinimizedActionButton then MinimizedActionButton.MouseButton1Click:Connect(toggleMinimize)
else warn("ZXHELL X ZEDLIST: MinimizedActionButton adalah nil.") end


-- --- ANIMASI UI (Ditingkatkan dan Dibuat Lebih Halus) ---
task.spawn(function() -- Animasi Border Frame Utama
    if not Frame or not Frame.Parent then return end
    local baseBorderColor = Frame.BorderColor3
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            local hue = (tick() * 0.3) % 1 -- Kecepatan perubahan warna border
            Frame.BorderColor3 = Color3.fromHSV(hue, 0.8, 1) -- Saturasi dan Value tinggi
        else
            Frame.BorderColor3 = Color3.fromRGB(255,0,0) -- Warna statis saat minimize
        end
        task.wait(0.05)
    end
end)

task.spawn(function() -- Animasi Title "ZXHELL X ZEDLIST" (Efek Nafas Warna Halus)
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local baseTextColor = UiTitleLabel.TextColor3
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            local cycle = math.sin(tick() * 2) -- Osilasi halus
            local r = baseTextColor.R + cycle * 0.1
            local g = baseTextColor.G - cycle * 0.05
            local b = baseTextColor.B - cycle * 0.05
            UiTitleLabel.TextColor3 = Color3.fromRGB(math.clamp(r*255,0,255), math.clamp(g*255,0,255), math.clamp(b*255,0,255))
            UiTitleLabel.TextStrokeTransparency = 0.4 - cycle * 0.1
        end
        task.wait(0.05)
    end
end)

task.spawn(function() -- Animasi Tombol Start (Pulse saat aktif)
    if not StartButton or not StartButton.Parent then return end
    local originalBgColor = StartButton.BackgroundColor3
    local activeBgColor = Color3.fromRGB(220, 40, 40)
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            if scriptRunning then
                local cycle = (math.sin(tick() * 4) + 1) / 2 -- 0 to 1
                StartButton.BackgroundColor3 = originalBgColor:Lerp(activeBgColor, cycle * 0.3 + 0.7) -- Lebih dominan warna aktif
                StartButton.BorderSizePixel = 2
            else
                StartButton.BackgroundColor3 = originalBgColor
                StartButton.BorderSizePixel = 1
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function() -- Animasi Tombol Z saat minimize (Glow)
    if not MinimizedActionButton or not MinimizedActionButton.Parent then return end
    local baseTextColor = MinimizedActionButton.TextColor3
    while ScreenGui and ScreenGui.Parent do
        if isMinimized and MinimizedActionButton.Visible then
            local cycle = (math.sin(tick() * 3) + 1) / 2 -- 0 to 1
            MinimizedActionButton.TextColor3 = baseTextColor:Lerp(Color3.fromRGB(255,150,150), cycle)
            MinimizedActionButton.TextTransparency = cycle * 0.3 -- Sedikit transparan saat redup
        else
             MinimizedActionButton.TextColor3 = baseTextColor
             MinimizedActionButton.TextTransparency = 0
        end
        task.wait(0.05)
    end
end)

-- BindToClose untuk pembersihan
game:BindToClose(function()
    if scriptRunning then
        warn("ZXHELL X ZEDLIST: Game ditutup, menghentikan skrip...")
        scriptRunning = false -- Ini akan menghentikan semua loop yang bergantung padanya
        task.wait(0.6) -- Beri waktu agar loop berhenti
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    print("ZXHELL X ZEDLIST: Pembersihan skrip selesai.")
end)

print("ZXHELL X ZEDLIST Script: Eksekusi LocalScript selesai. UI seharusnya sudah muncul dan interaktif.")
if StatusLabel and StatusLabel.Parent and (StatusLabel.Text == "STATUS: " or StatusLabel.Text == "") then
    StatusLabel.Text = "STATUS: STANDBY"
end
