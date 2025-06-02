--[[
    Skrip UI ZXHELL (Dioptimalkan)
    Direvisi untuk perbaikan bug, peningkatan UI/UX, optimasi, dan kompatibilitas executor.

    Perubahan Utama:
    - Mengganti tick() dengan time() untuk manajemen waktu yang lebih modern.
    - Mengubah minimizedZLabel menjadi TextButton untuk interaksi yang lebih baik dan konsisten.
    - Perbaikan logika pada tombol ApplyTimersButton agar status error tidak cepat hilang.
    - Pengecekan instance UI sebelum mengakses propertinya dalam loop animasi untuk mencegah error.
    - Penambahan komentar dan perbaikan kecil pada struktur kode.
    - Memastikan semua elemen UI yang dibuat secara dinamis diparentkan dengan benar.
    - Optimasi kecil pada loop dan event handling.
]]

print("ZXHELL UI Script (Optimized): Memulai eksekusi LocalScript...")

-- Layanan Roblox
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService") -- Digunakan untuk Heartbeat jika diperlukan, tapi task.wait() umumnya cukup
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player Lokal
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("ZXHELL UI Script (Optimized): LocalPlayer tidak ditemukan. Skrip tidak akan berjalan.")
    return
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if not PlayerGui then
    warn("ZXHELL UI Script (Optimized): PlayerGui tidak ditemukan untuk LocalPlayer: " .. LocalPlayer.Name)
    return
end

print("ZXHELL UI Script (Optimized): LocalPlayer dan PlayerGui ditemukan.")

-- // UI FRAME //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberpunkUI_Optimized_V2"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Active = true
Frame.Visible = true
Frame.Draggable = true -- Akan diatur false saat minimize

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Active = true

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Active = true

local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"
ApplyTimersButton.Active = true

local timerInputElements = {}

-- --- Variabel Kontrol dan State ---
local scriptRunning = false
local stopUpdateQi = false -- Kontrol untuk loop update Qi
local mainCycleThread = nil
local updateQiThread = nil

local isMinimized = false
local originalFrameSize = UDim2.new(0, 280, 0, 500) -- Sedikit lebih besar untuk mengakomodasi konten
local minimizedFrameSize = UDim2.new(0, 50, 0, 50) -- Ukuran saat minimize

-- Mengubah minimizedZLabel menjadi TextButton untuk klik yang lebih andal
local MinimizedZButton = Instance.new("TextButton")
MinimizedZButton.Name = "MinimizedZButton"
MinimizedZButton.Active = true
MinimizedZButton.Visible = false -- Awalnya tidak terlihat

local elementsToToggleVisibility = {} -- Akan diisi setelah semua elemen dibuat

-- --- Tabel Konfigurasi Timer (Default Values) ---
local timers = {
    reincarnate_delay = 1,
    change_map_delay = 0.5,
    pre_comprehend_qi_duration = 60,
    comprehend_duration = 20,
    post_comprehend_qi_duration = 30,
    update_qi_interval = 1,
    genericShortDelay = 0.5 -- Contoh delay tambahan jika diperlukan
}

-- // Parent UI ke player //
-- Pastikan fungsi ini dipanggil SETELAH semua instance UI dibuat
local function setupGuiParenting()
    if not ScreenGui or not PlayerGui then
        warn("ZXHELL UI Script (Optimized): ScreenGui atau PlayerGui nil saat setupGuiParenting.")
        return
    end
    ScreenGui.Parent = PlayerGui
    print("ZXHELL UI Script (Optimized): ScreenGui diparentkan ke PlayerGui.")

    -- Parent elemen utama ke ScreenGui atau Frame
    Frame.Parent = ScreenGui
    UiTitleLabel.Parent = Frame
    StartButton.Parent = Frame
    StatusLabel.Parent = Frame
    MinimizeButton.Parent = Frame
    TimerTitleLabel.Parent = Frame
    ApplyTimersButton.Parent = Frame
    MinimizedZButton.Parent = Frame -- Parentkan tombol Z yang baru

    -- Pastikan elemen input timer juga diparentkan ke Frame (dilakukan di createTimerInput)
    print("ZXHELL UI Script (Optimized): Semua elemen UI utama telah diparentkan.")
end
-- Panggil setupGuiParenting setelah semua elemen UI dibuat instance-nya
-- Ini akan dipanggil setelah pembuatan elemen timer input

-- // Desain UI (Pastikan ZIndex dan Visibilitas Awal) //
Frame.Size = originalFrameSize
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset / 2, 0.5, -Frame.Size.Y.Offset / 2)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
Frame.ClipsDescendants = true
local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = Frame

UiTitleLabel.Size = UDim2.new(1, -20, 0, 35); UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
UiTitleLabel.Font = Enum.Font.SourceSansSemibold; UiTitleLabel.Text = "ZXHELL (OPTIMIZED V2)"
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 25, 25); UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 20; UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.BackgroundTransparency = 1; UiTitleLabel.ZIndex = 2
UiTitleLabel.TextStrokeTransparency = 0.5; UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)

local yOffsetForTitle = 50

StartButton.Size = UDim2.new(1, -40, 0, 35); StartButton.Position = UDim2.new(0, 20, 0, yOffsetForTitle)
StartButton.Text = "START SEQUENCE"; StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 16; StartButton.TextColor3 = Color3.fromRGB(220, 220, 220)
StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20); StartButton.BorderSizePixel = 1
StartButton.BorderColor3 = Color3.fromRGB(255, 50, 50); StartButton.ZIndex = 2
local StartButtonCorner = Instance.new("UICorner"); StartButtonCorner.CornerRadius = UDim.new(0, 5); StartButtonCorner.Parent = StartButton

StatusLabel.Size = UDim2.new(1, -40, 0, 45); StatusLabel.Position = UDim2.new(0, 20, 0, yOffsetForTitle + 45)
StatusLabel.Text = "STATUS: STANDBY"; StatusLabel.Font = Enum.Font.SourceSansLight
StatusLabel.TextSize = 14; StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30); StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.BorderSizePixel = 0; StatusLabel.ZIndex = 2
local StatusLabelCorner = Instance.new("UICorner"); StatusLabelCorner.CornerRadius = UDim.new(0, 5); StatusLabelCorner.Parent = StatusLabel

local yOffsetForTimers = yOffsetForTitle + 100

TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20); TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffsetForTimers)
TimerTitleLabel.Text = "// TIMER_CONFIG_OPTIMIZED"; TimerTitleLabel.Font = Enum.Font.Code
TimerTitleLabel.TextSize = 14; TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
TimerTitleLabel.BackgroundTransparency = 1; TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TimerTitleLabel.ZIndex = 2

local function createTimerInput(name, yPos, labelText, initialValue)
    local label = Instance.new("TextLabel"); label.Name = name .. "Label"
    label.Size = UDim2.new(0.65, -25, 0, 20); label.Position = UDim2.new(0, 20, 0, yPos + yOffsetForTimers)
    label.Text = labelText .. ":"; label.Font = Enum.Font.SourceSans; label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(180, 180, 200); label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 2
    label.Parent = Frame -- Pastikan parent diatur
    table.insert(elementsToToggleVisibility, label) -- Tambahkan ke daftar toggle
    timerInputElements[name .. "Label"] = label

    local input = Instance.new("TextBox"); input.Name = name .. "Input"
    input.Size = UDim2.new(0.35, -25, 0, 20); input.Position = UDim2.new(0.65, 5, 0, yPos + yOffsetForTimers)
    input.Text = tostring(initialValue); input.PlaceholderText = "sec"; input.Font = Enum.Font.SourceSansSemibold
    input.TextSize = 11; input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40); input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(100, 100, 120); input.BorderSizePixel = 1; input.ZIndex = 2
    input.Parent = Frame -- Pastikan parent diatur
    table.insert(elementsToToggleVisibility, input) -- Tambahkan ke daftar toggle
    timerInputElements[name .. "Input"] = input
    local InputCorner = Instance.new("UICorner"); InputCorner.CornerRadius = UDim.new(0, 3); InputCorner.Parent = input
    return input
end

local currentYConfig = 30; local timerSpacing = 22
createTimerInput("ReincarnateDelay", currentYConfig, "T1_REINCARNATE_DELAY", timers.reincarnate_delay); currentYConfig = currentYConfig + timerSpacing
createTimerInput("ChangeMapDelay", currentYConfig, "T2_CHANGE_MAP_DELAY", timers.change_map_delay); currentYConfig = currentYConfig + timerSpacing
createTimerInput("PreComprehendQi", currentYConfig, "T3_PRE_COMP_QI_DUR", timers.pre_comprehend_qi_duration); currentYConfig = currentYConfig + timerSpacing
createTimerInput("ComprehendDuration", currentYConfig, "T4_COMPREHEND_DUR", timers.comprehend_duration); currentYConfig = currentYConfig + timerSpacing
createTimerInput("PostComprehendQiDuration", currentYConfig, "T5_POST_COMP_QI_DUR", timers.post_comprehend_qi_duration); currentYConfig = currentYConfig + timerSpacing
createTimerInput("UpdateQiInterval", currentYConfig, "T6_UPDATE_QI_INTV", timers.update_qi_interval); currentYConfig = currentYConfig + timerSpacing + 10

ApplyTimersButton.Size = UDim2.new(1, -40, 0, 30); ApplyTimersButton.Position = UDim2.new(0, 20, 0, currentYConfig + yOffsetForTimers)
ApplyTimersButton.Text = "APPLY_TIMERS"; ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.TextSize = 14; ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(30, 80, 30); ApplyTimersButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
ApplyTimersButton.BorderSizePixel = 1; ApplyTimersButton.ZIndex = 2
local ApplyButtonCorner = Instance.new("UICorner"); ApplyButtonCorner.CornerRadius = UDim.new(0, 5); ApplyButtonCorner.Parent = ApplyTimersButton

MinimizeButton.Size = UDim2.new(0, 25, 0, 25); MinimizeButton.Position = UDim2.new(1, -35, 0, 10)
MinimizeButton.Text = "_"; MinimizeButton.Font = Enum.Font.SourceSansBold; MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180); MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.BorderColor3 = Color3.fromRGB(100, 100, 120); MinimizeButton.BorderSizePixel = 1; MinimizeButton.ZIndex = 3
local MinimizeButtonCorner = Instance.new("UICorner"); MinimizeButtonCorner.CornerRadius = UDim.new(0, 3); MinimizeButtonCorner.Parent = MinimizeButton

-- Pengaturan untuk MinimizedZButton (sebagai tombol)
MinimizedZButton.Size = UDim2.new(1, 0, 1, 0); MinimizedZButton.Position = UDim2.new(0, 0, 0, 0)
MinimizedZButton.Text = "Z"; MinimizedZButton.Font = Enum.Font.SourceSansBold; MinimizedZButton.TextScaled = false
MinimizedZButton.TextSize = 38; MinimizedZButton.TextColor3 = Color3.fromRGB(255, 0, 0)
MinimizedZButton.TextXAlignment = Enum.TextXAlignment.Center; MinimizedZButton.TextYAlignment = Enum.TextYAlignment.Center
MinimizedZButton.BackgroundColor3 = Color3.fromRGB(20,20,25) -- Warna latar sedikit berbeda
MinimizedZButton.BorderColor3 = Color3.fromRGB(255,0,0)
MinimizedZButton.BorderSizePixel = 1
MinimizedZButton.ZIndex = 4 -- ZIndex tertinggi saat minimize
MinimizedZButton.AutoButtonColor = true -- Biarkan default untuk feedback visual
local MinimizedZButtonCorner = Instance.new("UICorner"); MinimizedZButtonCorner.CornerRadius = UDim.new(0,5); MinimizedZButtonCorner.Parent = MinimizedZButton


-- Panggil setupGuiParenting SEKARANG setelah semua elemen UI dibuat
setupGuiParenting()

-- Isi elementsToToggleVisibility setelah semua elemen utama didefinisikan dan diparentkan
elementsToToggleVisibility = {
    UiTitleLabel, StartButton, StatusLabel, TimerTitleLabel, ApplyTimersButton, MinimizeButton
    -- Elemen timer input sudah ditambahkan di createTimerInput
}
-- Tambahkan elemen yang sudah ada sebelumnya (seperti label dan input timer)
for _, element in pairs(timerInputElements) do
    table.insert(elementsToToggleVisibility, element)
end


local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = "STATUS: " .. string.upper(text)
    else
        warn("ZXHELL UI (Optimized): StatusLabel tidak valid saat mencoba update status ke: " .. text)
    end
end

local function animateFrame(targetSize, targetPosition, callback)
    if not Frame or not Frame.Parent then
        warn("ZXHELL UI (Optimized): Frame tidak valid untuk animasi.")
        if callback then callback() end -- Panggil callback jika ada untuk menghindari hang
        return
    end
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Sedikit lebih cepat
    local properties = {Size = targetSize, Position = targetPosition}
    local tween = TweenService:Create(Frame, info, properties)
    tween:Play()
    if callback then
        -- Menggunakan task.delay atau koneksi ke tween.Completed yang lebih aman
        local completedConnection
        completedConnection = tween.Completed:Connect(function()
            if completedConnection then completedConnection:Disconnect() end
            callback()
        end)
    end
end

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent and element ~= MinimizedZButton then -- Jangan sembunyikan tombol Z itu sendiri
                element.Visible = false
            end
        end
        MinimizeButton.Visible = false -- Sembunyikan tombol minimize asli
        MinimizedZButton.Visible = true -- Tampilkan tombol Z

        -- Kalkulasi posisi agar tetap di pojok kanan bawah relatif terhadap ukuran layar
        local screenX, screenY = ScreenGui.AbsoluteSize.X, ScreenGui.AbsoluteSize.Y
        local targetXOffset = screenX - minimizedFrameSize.X.Offset - (screenX * 0.02) -- 2% margin dari kanan
        local targetYOffset = screenY - minimizedFrameSize.Y.Offset - (screenY * 0.02) -- 2% margin dari bawah
        local targetPosition = UDim2.fromOffset(targetXOffset, targetYOffset)

        animateFrame(minimizedFrameSize, targetPosition)
        Frame.Draggable = false
    else
        MinimizedZButton.Visible = false -- Sembunyikan tombol Z
        -- Posisi tengah default
        local targetPosition = UDim2.new(0.5, -originalFrameSize.X.Offset / 2, 0.5, -originalFrameSize.Y.Offset / 2)
        animateFrame(originalFrameSize, targetPosition, function()
            for _, element in ipairs(elementsToToggleVisibility) do
                if element and element.Parent then
                    element.Visible = true
                end
            end
            MinimizeButton.Visible = true -- Tampilkan kembali tombol minimize asli
            Frame.Draggable = true
        end)
    end
end

print("ZXHELL UI Script (Optimized): Fungsi dan variabel UI telah didefinisikan. Menghubungkan event...")

-- // KONEKSI EVENT //
if MinimizeButton and MinimizeButton.Parent then
    MinimizeButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI (Optimized): MinimizeButton DIKLIK!")
        toggleMinimize()
    end)
else warn("ZXHELL UI (Optimized): MinimizeButton tidak valid atau tidak diparentkan sebelum menghubungkan event.") end

if MinimizedZButton and MinimizedZButton.Parent then
    MinimizedZButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI (Optimized): MinimizedZButton DIKLIK!")
        toggleMinimize()
    end)
else warn("ZXHELL UI (Optimized): MinimizedZButton tidak valid atau tidak diparentkan sebelum menghubungkan event.") end


-- Fungsi tunggu yang lebih aman dan menggunakan time()
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end -- Handle non-positive delay
    local startTime = time() -- Menggunakan time() sebagai pengganti tick()
    repeat
        task.wait() -- Memberi kesempatan pada task scheduler Roblox
    until not scriptRunning or (time() - startTime >= sec)
end

-- Fungsi fire remote yang ditingkatkan dengan penanganan error dan timeout
local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = {...} -- Lebih sederhana untuk menangkap varargs
    local remoteEventFolder
    local success = false
    local errMessage = "Unknown error"

    local pcallSuccess, pcallResult = pcall(function()
        if not ReplicatedStorage then
            warn("ZXHELL UI (Optimized): ReplicatedStorage service tidak tersedia.")
            return
        end
        local RemoteEventsFolderInstance = ReplicatedStorage:WaitForChild("RemoteEvents", 5) -- Timeout 5 detik
        if not RemoteEventsFolderInstance then
            warn("ZXHELL UI (Optimized): Folder RemoteEvents tidak ditemukan di ReplicatedStorage.")
            return
        end

        if pathType == "AreaEvents" then
            remoteEventFolder = RemoteEventsFolderInstance:WaitForChild("AreaEvents", 5)
            if not remoteEventFolder then
                warn("ZXHELL UI (Optimized): Folder AreaEvents tidak ditemukan di RemoteEvents.")
                return
            end
        else
            remoteEventFolder = RemoteEventsFolderInstance -- Asumsi "Base" path
        end

        local remote = remoteEventFolder:WaitForChild(remoteName, 5)
        if not remote then
            warn("ZXHELL UI (Optimized): RemoteEvent '"..remoteName.."' tidak ditemukan di "..remoteEventFolder.Name)
            return
        end

        if remote:IsA("RemoteEvent") then
            remote:FireServer(table.unpack(argsToUnpack))
            success = true -- Anggap sukses jika FireServer berhasil dipanggil tanpa error langsung
        else
            warn("ZXHELL UI (Optimized): Objek '"..remoteName.."' bukan RemoteEvent.")
        end
    end)

    if not pcallSuccess then
        errMessage = tostring(pcallResult)
        updateStatus("ERR_FIRE_" .. string.upper(remoteName))
        warn("ZXHELL UI (Optimized): Error firing " .. remoteName .. ": " .. errMessage)
        success = false -- Pastikan success adalah false jika pcall gagal
    elseif not success and pcallSuccess then
        -- Ini berarti pcall berhasil tapi salah satu kondisi di dalamnya (misal WaitForChild timeout) gagal
        updateStatus("ERR_FIND_REMOTE_" .. string.upper(remoteName))
        warn("ZXHELL UI (Optimized): Gagal menemukan atau memvalidasi remote: " .. remoteName)
    end
    return success
end

-- Fungsi utama untuk siklus operasi
local function runCycle()
    if not scriptRunning then return end
    updateStatus("Reincarnating_Proc")
    if not fireRemoteEnhanced("Reincarnate", "Base") then scriptRunning = false; updateStatus("REINCARNATE_FAIL"); return end
    waitSeconds(timers.reincarnate_delay)
    if not scriptRunning then return end

    updateStatus("Map_Change_To_Immortal")
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then scriptRunning = false; updateStatus("MAP_IMMORTAL_FAIL"); return end
    waitSeconds(timers.change_map_delay)
    if not scriptRunning then return end

    updateStatus("Map_Change_To_Chaos")
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "chaos") then scriptRunning = false; updateStatus("MAP_CHAOS_FAIL"); return end
    waitSeconds(timers.change_map_delay)
    if not scriptRunning then return end

    updateStatus("Pre_Comprehend_QI_Update (" .. timers.pre_comprehend_qi_duration .. "s)")
    stopUpdateQi = false -- Mulai update Qi
    local preComprehendQiStartTime = time()
    while scriptRunning and (time() - preComprehendQiStartTime < timers.pre_comprehend_qi_duration) do
        if stopUpdateQi then updateStatus("Pre_Comp_QI_Halted"); break end -- Bisa dihentikan dari luar
        updateStatus(string.format("Pre_Comp_QI_Active... %ds Left", math.floor(timers.pre_comprehend_qi_duration - (time() - preComprehendQiStartTime))))
        task.wait(1) -- Cek setiap detik
    end
    if not scriptRunning then return end

    updateStatus("Comprehend_Proc (" .. timers.comprehend_duration .. "s)")
    stopUpdateQi = true -- Hentikan update Qi selama comprehend
    local comprehendStartTime = time()
    while scriptRunning and (time() - comprehendStartTime < timers.comprehend_duration) do
        if not fireRemoteEnhanced("Comprehend", "Base") then
            updateStatus("Comprehend_Event_Fail");
            -- Mungkin tidak perlu menghentikan seluruh skrip jika satu event gagal, tergantung kebutuhan
            -- scriptRunning = false; return
            break -- Keluar dari loop comprehend jika gagal
        end
        updateStatus(string.format("Comprehending... %ds Left", math.floor(timers.comprehend_duration - (time() - comprehendStartTime))))
        task.wait(1) -- Cek setiap detik, atau sesuaikan interval jika perlu lebih sering/jarang
    end
    if not scriptRunning then return end
    updateStatus("Comprehend_Complete")

    updateStatus("Post_Comprehend_QI_Update (" .. timers.post_comprehend_qi_duration .. "s)")
    stopUpdateQi = false -- Mulai lagi update Qi
    local postComprehendQiStartTime = time()
    while scriptRunning and (time() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        if stopUpdateQi then updateStatus("Post_Comp_QI_Halted"); break end
        updateStatus(string.format("Post_Comp_QI_Active... %ds Left", math.floor(timers.post_comprehend_qi_duration - (time() - postComprehendQiStartTime))))
        task.wait(1)
    end
    if not scriptRunning then return end
    stopUpdateQi = true -- Hentikan update Qi setelah selesai post-comprehend
    updateStatus("Cycle_Complete_Restarting")
end

-- Loop untuk update Qi
local function updateQiLoop_enhanced()
    while scriptRunning do
        if not stopUpdateQi then
            fireRemoteEnhanced("UpdateQi", "Base")
        end
        local interval = timers.update_qi_interval
        if interval <= 0 then interval = 0.03 end -- Minimum interval untuk menghindari spam berlebih
        waitSeconds(interval)
    end
    print("ZXHELL UI (Optimized): updateQiLoop_enhanced berhenti.")
end

-- Event handler untuk tombol Start/Stop
if StartButton and StartButton.Parent then
    StartButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI (Optimized): StartButton DIKLIK! scriptRunning sebelumnya:", scriptRunning)
        scriptRunning = not scriptRunning
        if scriptRunning then
            StartButton.Text = "SYSTEM_ACTIVE"; StartButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30); StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            updateStatus("INIT_OPTIMIZED_SEQUENCE")
            stopUpdateQi = true -- Pastikan Qi tidak langsung aktif sebelum siklus utama mengaturnya

            -- Hanya buat thread baru jika belum ada atau sudah mati
            if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
                updateQiThread = task.spawn(updateQiLoop_enhanced)
                print("ZXHELL UI (Optimized): updateQiThread dimulai.")
            end

            if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
                mainCycleThread = task.spawn(function()
                    print("ZXHELL UI (Optimized): mainCycleThread dimulai.")
                    while scriptRunning do
                        runCycle()
                        if not scriptRunning then break end
                        updateStatus("CYCLE_REINIT")
                        task.wait(1) -- Delay singkat sebelum memulai siklus baru
                    end
                    -- Ini akan dijalankan ketika scriptRunning menjadi false
                    updateStatus("SYSTEM_HALTED")
                    StartButton.Text = "START SEQUENCE"; StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
                    StartButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                    stopUpdateQi = true -- Pastikan Qi berhenti
                    print("ZXHELL UI (Optimized): mainCycleThread berhenti.")
                end)
            end
        else
            updateStatus("HALT_REQUESTED")
            -- scriptRunning sudah false, loop di mainCycleThread dan updateQiThread akan berhenti secara alami
            -- Tombol dan status akan diupdate oleh mainCycleThread saat keluar dari loopnya
        end
    end)
else warn("ZXHELL UI (Optimized): StartButton tidak valid atau tidak diparentkan sebelum menghubungkan event.") end

-- Event handler untuk tombol Apply Timers
if ApplyTimersButton and ApplyTimersButton.Parent then
    ApplyTimersButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI (Optimized): ApplyTimersButton DIKLIK!")
        local function applyTextInput(inputElement, timerKey, labelElement)
            local success = false
            if not inputElement or not inputElement.Parent then
                warn("ZXHELL UI (Optimized): Input element untuk " .. timerKey .. " tidak valid.")
                return false
            end
            local value = tonumber(inputElement.Text)
            if value and value >= 0 then
                timers[timerKey] = value
                if labelElement and labelElement.Parent then
                    pcall(function() labelElement.TextColor3 = Color3.fromRGB(80, 255, 80) end) -- Hijau untuk sukses
                end
                success = true
            else
                if labelElement and labelElement.Parent then
                    pcall(function() labelElement.TextColor3 = Color3.fromRGB(255, 80, 80) end) -- Merah untuk error
                end
                warn("ZXHELL UI (Optimized): Nilai tidak valid untuk " .. timerKey .. ": " .. inputElement.Text)
            end
            return success
        end

        local allTimersValid = true
        -- Iterasi melalui tabel konfigurasi timer untuk validasi dan aplikasi
        for key, inputField in pairs(timerInputElements) do
            if string.sub(key, -5) == "Input" then -- Hanya proses field input
                local timerKeyName = string.sub(key, 1, -6) -- Dapatkan nama asli timer (misal "ReincarnateDelay")
                -- Konversi nama field ke nama key di tabel timers (misal ReincarnateDelay -> reincarnate_delay)
                local actualTimerKey = string.lower(string.sub(timerKeyName, 1, 1)) .. string.sub(timerKeyName, 2)
                -- Cari key yang cocok dengan pola case-insensitive jika perlu, atau pastikan konsisten
                -- Untuk sekarang, kita asumsikan polanya adalah: ReincarnateDelayInput -> reincarnate_delay
                -- Ini mungkin perlu disesuaikan jika penamaan tidak konsisten.
                -- Contoh sederhana:
                if timerKeyName == "ReincarnateDelay" then actualTimerKey = "reincarnate_delay"
                elseif timerKeyName == "ChangeMapDelay" then actualTimerKey = "change_map_delay"
                elseif timerKeyName == "PreComprehendQi" then actualTimerKey = "pre_comprehend_qi_duration"
                elseif timerKeyName == "ComprehendDuration" then actualTimerKey = "comprehend_duration"
                elseif timerKeyName == "PostComprehendQiDuration" then actualTimerKey = "post_comprehend_qi_duration"
                elseif timerKeyName == "UpdateQiInterval" then actualTimerKey = "update_qi_interval"
                else actualTimerKey = nil -- Tidak ditemukan, skip
                end

                if actualTimerKey and timers[actualTimerKey] then
                    local labelField = timerInputElements[timerKeyName .. "Label"]
                    if not applyTextInput(inputField, actualTimerKey, labelField) then
                        allTimersValid = false
                    end
                end
            end
        end

        local originalStatusText = StatusLabel.Text -- Simpan status saat ini
        if allTimersValid then
            updateStatus("TIMER_CONFIG_APPLIED")
        else
            updateStatus("ERR_TIMER_INPUT_INVALID")
        end

        -- Kembalikan warna label dan status setelah beberapa detik
        task.delay(2, function()
            for key, labelElement in pairs(timerInputElements) do
                if string.sub(key, -5) == "Label" and labelElement and labelElement.Parent then
                    pcall(function() labelElement.TextColor3 = Color3.fromRGB(180, 180, 200) end) -- Warna default
                end
            end
            -- Hanya kembalikan status jika tidak ada error yang lebih baru
            if StatusLabel.Text == "STATUS: TIMER_CONFIG_APPLIED" or StatusLabel.Text == "STATUS: ERR_TIMER_INPUT_INVALID" then
                 -- Cek apakah status masih sama dengan yang kita set, atau sudah diubah oleh proses lain
                if string.find(StatusLabel.Text, "TIMER_CONFIG_APPLIED") or string.find(StatusLabel.Text, "ERR_TIMER_INPUT_INVALID") then
                    -- Jika status masih terkait timer, kembalikan ke status sebelum apply timer.
                    -- Jika ada status lain (misal dari proses game), biarkan.
                    -- Ini adalah logika yang lebih aman:
                    local currentMainStatus = string.match(originalStatusText, "STATUS:%s*(.+)")
                    if currentMainStatus then
                        updateStatus(currentMainStatus)
                    else
                        updateStatus("STANDBY") -- Fallback
                    end
                end
            end
        end)
    end)
else warn("ZXHELL UI (Optimized): ApplyTimersButton tidak valid atau tidak diparentkan sebelum menghubungkan event.") end


-- --- ANIMASI UI (Diringkas, dengan pengecekan tambahan) ---
task.spawn(function()
    local baseColor = Color3.fromRGB(15, 15, 20)
    local glitchColor1 = Color3.fromRGB(25, 20, 30)
    local glitchColor2 = Color3.fromRGB(10, 10, 15)
    local borderBase = Color3.fromRGB(255, 0, 0)
    local borderGlitch = Color3.fromRGB(0, 255, 255)

    while ScreenGui and ScreenGui.Parent and Frame and Frame.Parent do
        if not isMinimized then
            local r = math.random()
            if r < 0.05 then
                Frame.BackgroundColor3 = glitchColor1
                Frame.BorderColor3 = borderGlitch
                task.wait(0.05)
                Frame.BackgroundColor3 = glitchColor2
                task.wait(0.05)
            elseif r < 0.2 then
                Frame.BackgroundColor3 = baseColor:Lerp(glitchColor1, math.random())
                Frame.BorderColor3 = borderBase:Lerp(borderGlitch, math.random() * 0.5)
                task.wait(0.1)
            else
                Frame.BackgroundColor3 = baseColor
                Frame.BorderColor3 = borderBase
            end
            local h, s, v = Color3.toHSV(Frame.BorderColor3)
            Frame.BorderColor3 = Color3.fromHSV((h + 0.005) % 1, s, v)
        else
            -- Saat minimize, kembalikan ke warna dasar jika perlu
            if Frame.BackgroundColor3 ~= baseColor then Frame.BackgroundColor3 = baseColor end
            if Frame.BorderColor3 ~= borderBase then Frame.BorderColor3 = borderBase end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText = UiTitleLabel.Text
    local glitchChars = {"@", "#", "$", "%", "&", "*", "!", "?", "/", "\\", "|_"}
    local baseColor = Color3.fromRGB(255, 25, 25)
    local originalPosition = UiTitleLabel.Position

    while ScreenGui and ScreenGui.Parent and UiTitleLabel and UiTitleLabel.Parent do
        if not isMinimized then
            local r = math.random()
            local isGlitchingText = false
            if r < 0.02 then
                isGlitchingText = true
                local newText = ""
                for i = 1, #originalText do
                    if math.random() < 0.7 then
                        newText = newText .. glitchChars[math.random(#glitchChars)]
                    else
                        newText = newText .. originalText:sub(i, i)
                    end
                end
                UiTitleLabel.Text = newText
                UiTitleLabel.TextColor3 = Color3.fromRGB(math.random(200, 255), math.random(0, 50), math.random(0, 50))
                UiTitleLabel.Position = originalPosition + UDim2.fromOffset(math.random(-2, 2), math.random(-2, 2))
                UiTitleLabel.Rotation = math.random(-1, 1) * 0.5
                task.wait(0.07)
            elseif r < 0.1 then
                UiTitleLabel.TextColor3 = Color3.fromHSV(math.random(), 1, 1)
                UiTitleLabel.TextStrokeColor3 = Color3.fromHSV(math.random(), 0.8, 1)
                UiTitleLabel.TextStrokeTransparency = math.random() * 0.3
                UiTitleLabel.Rotation = math.random(-1, 1) * 0.2
                task.wait(0.1)
            else
                if UiTitleLabel.Text ~= originalText then UiTitleLabel.Text = originalText end
                UiTitleLabel.TextStrokeTransparency = 0.5
                UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)
                if UiTitleLabel.Position ~= originalPosition then UiTitleLabel.Position = originalPosition end
                if UiTitleLabel.Rotation ~= 0 then UiTitleLabel.Rotation = 0 end
            end

            if not isGlitchingText then -- Efek warna pelangi jika tidak sedang glitch text
                local hue = (time() * 0.1) % 1
                local rR, gR, bR = Color3.fromHSV(hue, 1, 1).R, Color3.fromHSV(hue, 1, 1).G, Color3.fromHSV(hue, 1, 1).B
                rR = math.min(1, rR + 0.6) -- Lebih merah
                gR = gR * 0.4
                bR = bR * 0.4
                UiTitleLabel.TextColor3 = Color3.new(rR, gR, bR)
            end
        else
             -- Reset saat minimize jika perlu
            if UiTitleLabel.Text ~= originalText then UiTitleLabel.Text = originalText end
            if UiTitleLabel.TextColor3 ~= baseColor then UiTitleLabel.TextColor3 = baseColor end
            if UiTitleLabel.Position ~= originalPosition then UiTitleLabel.Position = originalPosition end
            if UiTitleLabel.Rotation ~= 0 then UiTitleLabel.Rotation = 0 end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    local buttonsToAnimate = {StartButton, ApplyTimersButton, MinimizeButton}
    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            for _, btn in ipairs(buttonsToAnimate) do
                if btn and btn.Parent then
                    local originalBorderColor = btn.BorderColor3 -- Simpan warna asli untuk lerp atau reset
                    if btn.Name == "StartButton" and scriptRunning then
                        btn.BorderColor3 = Color3.fromRGB(255, 100, 100) -- Warna border saat aktif
                    else
                        -- Efek pulsasi border
                        local h, s, v = Color3.toHSV(originalBorderColor)
                        btn.BorderColor3 = Color3.fromHSV(h, s, math.sin(time() * 2) * 0.1 + 0.9)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while ScreenGui and ScreenGui.Parent and MinimizedZButton and MinimizedZButton.Parent do
        if isMinimized and MinimizedZButton.Visible then
            local hue = (time() * 0.3) % 1 -- Animasi warna lebih cepat untuk tombol Z
            MinimizedZButton.TextColor3 = Color3.fromHSV(hue, 1, 1)
            MinimizedZButton.BorderColor3 = Color3.fromHSV((hue + 0.5)%1, 0.8, 1) -- Warna border kontras
        end
        task.wait(0.05)
    end
end)

-- Pembersihan saat game ditutup
game:BindToClose(function()
    if scriptRunning then
        warn("ZXHELL UI (Optimized): Game ditutup, menghentikan skrip...")
        scriptRunning = false -- Ini akan menghentikan loop utama dan loop Qi
        task.wait(0.5) -- Beri waktu untuk loop berhenti
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
        print("ZXHELL UI (Optimized): ScreenGui dihancurkan.")
    end
    print("ZXHELL UI (Optimized): Pembersihan skrip selesai.")
end)

print("ZXHELL UI Script (Optimized): Eksekusi LocalScript selesai. UI seharusnya sudah muncul dan interaktif.")
if StatusLabel and StatusLabel.Parent and (StatusLabel.Text == "STATUS: " or StatusLabel.Text == "") then
    updateStatus("STANDBY_READY") -- Status awal yang lebih jelas
end

