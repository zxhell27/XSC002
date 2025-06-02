-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CultivationHelperScreenGui"
ScreenGui.ResetOnSpawn = false -- Mencegah UI direset saat karakter respawn

local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- --- Variabel Kontrol dan State (Dari skrip Anda) ---
local scriptRunning = false
local stopUpdateQi = false
local pauseUpdateQiTemporarily = false
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil

-- --- Tabel Konfigurasi Timer (Dari skrip Anda, dengan penyesuaian) ---
local timers = {
    wait_1m30s_after_first_items = 0,
    alur_wait_40s_hide_qi = 0,
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

-- // Parent UI ke player (Struktur Asli Dipertahankan) //
local function setupCoreGuiParenting()
    local coreGuiService = game:GetService("CoreGui")
    if not ScreenGui.Parent or ScreenGui.Parent ~= coreGuiService then
        ScreenGui.Parent = coreGuiService
    end
    Frame.Parent = ScreenGui
    StartButton.Parent = Frame
    StatusLabel.Parent = Frame
end
setupCoreGuiParenting()

-- // Desain UI (Tema Kultivasi dengan Peningkatan) //

-- --- Frame Utama ---
Frame.Size = UDim2.new(0, 300, 0, 480) -- Sedikit lebih besar untuk estetika
Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 30) -- Latar belakang ungu tua misterius
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(180, 150, 90) -- Border emas kusam (kultivasi kuno)
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

-- --- Judul UI dengan Animasi Glitch ---
local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"
UiTitleLabel.Parent = Frame
UiTitleLabel.Size = UDim2.new(1, -20, 0, 30) -- Ukuran disesuaikan
UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
UiTitleLabel.Font = Enum.Font.Code -- Font 'Code' cocok untuk efek glitch
UiTitleLabel.Text = "ZXHELL X ZEDLIST"
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 60, 60) -- Warna dasar merah menyala
UiTitleLabel.TextScaled = true
UiTitleLabel.BackgroundTransparency = 1
UiTitleLabel.ZIndex = 2

local yOffsetForTitle = 45 -- Penyesuaian offset untuk elemen di bawah judul

-- --- Tombol Start ---
StartButton.Size = UDim2.new(1, -20, 0, 35)
StartButton.Position = UDim2.new(0, 10, 0, yOffsetForTitle)
StartButton.Text = "Mulai Kultivasi"
StartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah energi Qi
StartButton.TextColor3 = Color3.fromRGB(255, 230, 200) -- Teks krem/emas muda
StartButton.Font = Enum.Font.SourceSansBold
local StartButtonCorner = Instance.new("UICorner")
StartButtonCorner.CornerRadius = UDim.new(0, 5)
StartButtonCorner.Parent = StartButton

-- --- Label Status ---
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, yOffsetForTitle + 45)
StatusLabel.Text = "Status: Menunggu Perintah..."
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 35, 50) -- Warna latar lebih gelap dari frame
StatusLabel.TextColor3 = Color3.fromRGB(210, 200, 220) -- Teks lavender muda
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
local StatusLabelCorner = Instance.new("UICorner")
StatusLabelCorner.CornerRadius = UDim.new(0, 4)
StatusLabelCorner.Parent = StatusLabel

-- --- Konfigurasi Timer ---
local timerElements = {}
local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"
TimerTitleLabel.Parent = Frame
TimerTitleLabel.Size = UDim2.new(1, -20, 0, 20)
TimerTitleLabel.Position = UDim2.new(0, 10, 0, yOffsetForTitle + 95)
TimerTitleLabel.Text = "Pengaturan Aliran Energi (detik):"
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextColor3 = Color3.fromRGB(220, 200, 240) -- Lavender cerah
TimerTitleLabel.Font = Enum.Font.SourceSansSemibold
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local function createTimerInput(name, yPos, labelText, timerKey)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.45, -15, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos + yOffsetForTitle)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 170, 190) -- Lavender abu-abu
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    timerElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.55, -15, 0, 20)
    input.Position = UDim2.new(0.45, 5, 0, yPos + yOffsetForTitle)
    input.Text = tostring(timers[timerKey])
    input.PlaceholderText = "Detik"
    input.BackgroundColor3 = Color3.fromRGB(50, 45, 60) -- Ungu gelap untuk input
    input.TextColor3 = Color3.fromRGB(230, 230, 240) -- Teks input cerah
    input.Font = Enum.Font.SourceSans
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(80, 70, 90) -- Border input
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 3)
    InputCorner.Parent = input
    timerElements[name .. "Input"] = input
    return input
end

local currentYConfig = 125 -- Disesuaikan dengan yOffsetForTitle
timerElements.wait1m30sInput = createTimerInput("Wait1m30s", currentYConfig, "Meditasi Pasca Item1:", "wait_1m30s_after_first_items")
currentYConfig = currentYConfig + 30
timerElements.wait40sInput = createTimerInput("Wait40s", currentYConfig, "Segel Qi (Item2):", "alur_wait_40s_hide_qi")
currentYConfig = currentYConfig + 30
timerElements.comprehendInput = createTimerInput("Comprehend", currentYConfig, "Durasi Pencerahan:", "comprehend_duration")
currentYConfig = currentYConfig + 30
timerElements.postComprehendQiInput = createTimerInput("PostComprehendQi", currentYConfig, "Stabilisasi Qi Pasca Pencerahan:", "post_comprehend_qi_duration")
currentYConfig = currentYConfig + 40

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"
ApplyTimersButton.Parent = Frame
ApplyTimersButton.Size = UDim2.new(1, -20, 0, 30)
ApplyTimersButton.Position = UDim2.new(0, 10, 0, currentYConfig + yOffsetForTitle)
ApplyTimersButton.Text = "Terapkan Konfigurasi Energi"
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180) -- Biru mistis
ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 255) -- Teks lavender muda
ApplyTimersButton.Font = Enum.Font.SourceSansBold
local ApplyButtonCorner = Instance.new("UICorner")
ApplyButtonCorner.CornerRadius = UDim.new(0, 5)
ApplyButtonCorner.Parent = ApplyTimersButton
timerElements.ApplyButton = ApplyTimersButton

-- --- Tombol Minimize ---
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 25, 0, 25) -- Sedikit lebih besar
MinimizeButton.Position = UDim2.new(1, -30, 0, 7)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 60, 80) -- Warna gelap subtil
MinimizeButton.TextColor3 = Color3.fromRGB(200, 190, 210)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 3
local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 4)
MinimizeButtonCorner.Parent = MinimizeButton

local isMinimized = false
local originalFrameSizeY = Frame.Size.Y.Offset
-- Perkiraan tinggi header saat minimize: Judul + Tombol Start + Status + Padding
local minimizedHeaderHeight = (UiTitleLabel.Position.Y.Offset + UiTitleLabel.Size.Y.Offset + 5 +
                              StartButton.Size.Y.Offset + 5 +
                              StatusLabel.Size.Y.Offset + 15) -- Ditambah padding bawah

local elementsToToggleVisibility = {
    TimerTitleLabel,
    timerElements.Wait1m30sLabel, timerElements.wait1m30sInput,
    timerElements.Wait40sLabel, timerElements.wait40sInput,
    timerElements.ComprehendLabel, timerElements.comprehendInput,
    timerElements.PostComprehendQiLabel, timerElements.postComprehendQiInput,
    ApplyTimersButton
}

-- // Fungsi tunggu (Struktur Asli Dipertahankan, dengan modifikasi dari skrip Anda) //
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat
        task.wait()
    until not scriptRunning or tick() - startTime >= sec
end

-- Fungsi fireRemoteEnhanced (Dari skrip Anda)
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

    if pcallSuccess then
        success = true
    else
        errMessage = tostring(pcallResult)
        if StatusLabel and StatusLabel.Parent then
             StatusLabel.Text = "Status: Gagal mengirim sinyal " .. remoteName
        end
        print("Error firing " .. remoteName .. ": " .. errMessage)
        success = false
    end
    return success
end

-- // Fungsi utama (Struktur Asli Dipertahankan, dengan penyesuaian dari skrip Anda) //
local function runCycle()
	local function updateStatus(text)
        if StatusLabel and StatusLabel.Parent then
		    StatusLabel.Text = "Status: " .. text
        end
	end

	updateStatus("Memulai Reinkarnasi...")
	if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnateDelay)

	if not scriptRunning then return end
	updateStatus("Persiapan Set Artefak Pertama...")
	waitSeconds(timers.user_script_wait1_before_items1)
	if not scriptRunning then return end

	local item1 = {
		"Nine Heavens Galaxy Water", "Buzhou Divine Flower",
		"Fusang Divine Tree", "Calm Cultivation Mat"
	}
	for _, item in ipairs(item1) do
		if not scriptRunning then return end
		updateStatus("Mengambil Artefak: " .. item)
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay)
	end

	if not scriptRunning then return end
	updateStatus("Meditasi & Penyesuaian Aliran Energi...")
	waitSeconds(timers.wait_1m30s_after_first_items)
	if not scriptRunning then return end

	local function changeMap(name)
		return fireRemoteEnhanced("ChangeMap", "AreaEvents", name)
	end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay)
	if not scriptRunning then return end
	if not changeMap("chaos") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay)

	if not scriptRunning then return end
	updateStatus("Menapaki Jalan Kekacauan...")
	if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)

	if not scriptRunning then return end
	updateStatus("Persiapan Set Artefak Kedua...")
	pauseUpdateQiTemporarily = true
	updateStatus("Aliran Qi dijeda untuk Artefak (" .. timers.alur_wait_40s_hide_qi .. "s)...")
	waitSeconds(timers.alur_wait_40s_hide_qi)
	pauseUpdateQiTemporarily = false
	updateStatus("Aliran Qi dilanjutkan.")
	if not scriptRunning then return end

	local item2 = {
		"Traceless Breeze Lotus",
		"Reincarnation World Destruction Black Lotus",
		"Ten Thousand Bodhi Tree"
	}
	for _, item in ipairs(item2) do
		if not scriptRunning then return end
		updateStatus("Mengambil Artefak: " .. item)
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay)
	end

	if not scriptRunning then return end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay)

	if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
		updateStatus("Mengaktifkan Segel Tersembunyi (Aliran Qi aktif)...")
		if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
	else
		updateStatus("Melewati Segel Tersembunyi (Aliran Qi tidak aktif/dijeda).")
	end
	task.wait(timers.genericShortDelay)

    updateStatus("Persiapan Memasuki Zona Terlarang...")
	if not scriptRunning then return end

	updateStatus("Memasuki Zona Terlarang...")
	if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)

	if not scriptRunning then return end
	updateStatus("Proses Pencerahan (" .. timers.comprehend_duration .. "s)...")
	stopUpdateQi = true

	local comprehendStartTime = tick()
	while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
		if not fireRemoteEnhanced("Comprehend", "Base", {}) then
            updateStatus("Gagal Memahami Esensi.")
            break
        end
        updateStatus(string.format("Memahami Esensi... %d detik tersisa", math.floor(timers.comprehend_duration - (tick() - comprehendStartTime))))
		task.wait(1)
	end
    if not scriptRunning then return end
    updateStatus("Pencerahan Selesai.")

    if scriptRunning then
        updateStatus("Menstabilkan Energi Pasca Pencerahan...")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then
            updateStatus("Gagal Menstabilkan Energi.")
        end
        task.wait(timers.genericShortDelay)
    end

	if not scriptRunning then return end
	updateStatus("Sirkulasi Qi Akhir (" .. timers.post_comprehend_qi_duration .. "s)...")
	stopUpdateQi = false

    updateStatus(string.format("Sirkulasi Qi Pasca Pencerahan selama %d detik...", timers.post_comprehend_qi_duration))
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        if stopUpdateQi then
            updateStatus("Sirkulasi Qi terhenti saat Pasca Pencerahan.")
            break
        end
        updateStatus(string.format("Sirkulasi Qi aktif... %d detik tersisa", math.floor(timers.post_comprehend_qi_duration - (tick() - postComprehendQiStartTime))))
        task.wait(1)
    end
    if not scriptRunning then return end
	stopUpdateQi = true

	updateStatus("Siklus Kultivasi Selesai - Memulai Ulang")
end

-- Loop Latar Belakang yang Ditingkatkan (Dari skrip Anda)
local function increaseAptitudeMineLoop_enhanced()
    while scriptRunning do
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        task.wait(timers.aptitudeMineInterval)
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait()
    end
end

local function updateQiLoop_enhanced()
    while scriptRunning do
        if not stopUpdateQi and not pauseUpdateQiTemporarily then
            fireRemoteEnhanced("UpdateQi", "Base", {})
        end
        task.wait(timers.updateQiInterval)
    end
end

-- Jalankan saat tombol ditekan (Struktur Asli Dipertahankan, dengan modifikasi untuk kontrol dari skrip Anda)
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning

    if scriptRunning then
        StartButton.Text = "Mengalirkan Energi..."
        StartButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80) -- Warna merah lebih intens saat aktif
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Memulai siklus kultivasi..." end

        stopUpdateQi = false
        pauseUpdateQiTemporarily = false

        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
            aptitudeMineThread = coroutine.create(increaseAptitudeMineLoop_enhanced)
            coroutine.resume(aptitudeMineThread)
        end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
            updateQiThread = coroutine.create(updateQiLoop_enhanced)
            coroutine.resume(updateQiThread)
        end

        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = coroutine.create(function()
                while scriptRunning do
                    runCycle()
                    if not scriptRunning then break end
                    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Siklus selesai. Memulai ulang..." end
                    task.wait(1)
                end
                if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Kultivasi Dihentikan." end
                StartButton.Text = "Mulai Kultivasi"
                StartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Kembali ke warna awal
            end)
            coroutine.resume(mainCycleThread)
        end
    else
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Menghentikan aliran energi..." end
        -- Penghentian thread akan terjadi secara alami karena `scriptRunning` menjadi false
    end
end)

-- Event Listener untuk Tombol Terapkan Timer (Dari skrip Anda)
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false
        if not inputElement then return false end
        local value = tonumber(inputElement.Text)
        if value and value >= 0 then
            timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(100, 220, 100) end) end -- Hijau sukses
            success = true
        else
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(220, 100, 100) end) end -- Merah gagal
        end
        return success
    end

    local allTimersValid = true
    allTimersValid = applyTextInput(timerElements.wait1m30sInput, "wait_1m30s_after_first_items", timerElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.wait40sInput, "alur_wait_40s_hide_qi", timerElements.Wait40sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.comprehendInput, "comprehend_duration", timerElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.postComprehendQiInput, "post_comprehend_qi_duration", timerElements.PostComprehendQiLabel) and allTimersValid

    local originalStatusText = StatusLabel.Text
    if StatusLabel and StatusLabel.Parent then
        if allTimersValid then
            StatusLabel.Text = "Status: Konfigurasi energi berhasil diterapkan."
        else
            StatusLabel.Text = "Status: Input tidak valid! Periksa angka (harus >= 0)."
        end
    end

    task.wait(2.5)
    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = originalStatusText end
    -- Reset warna label input
    local defaultLabelColor = Color3.fromRGB(180, 170, 190)
    if timerElements.Wait1m30sLabel then pcall(function() timerElements.Wait1m30sLabel.TextColor3 = defaultLabelColor end) end
    if timerElements.Wait40sLabel then pcall(function() timerElements.Wait40sLabel.TextColor3 = defaultLabelColor end) end
    if timerElements.ComprehendLabel then pcall(function() timerElements.ComprehendLabel.TextColor3 = defaultLabelColor end) end
    if timerElements.PostComprehendQiLabel then pcall(function() timerElements.PostComprehendQiLabel.TextColor3 = defaultLabelColor end) end
end)

-- Logika untuk Tombol Minimize (Dari skrip Anda, disesuaikan posisi elemen)
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+"
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, minimizedHeaderHeight)
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        -- Atur ulang posisi elemen header saat minimize
        UiTitleLabel.Position = UDim2.new(0, 10, 0, 5)
        StartButton.Position = UDim2.new(0, 10, 0, UiTitleLabel.Position.Y.Offset + UiTitleLabel.Size.Y.Offset + 5)
        StatusLabel.Position = UDim2.new(0, 10, 0, StartButton.Position.Y.Offset + StartButton.Size.Y.Offset + 5)

    else
        MinimizeButton.Text = "-"
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, originalFrameSizeY)
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = true end
        end
        -- Kembalikan posisi elemen ke posisi asli mereka (sudah diatur saat pembuatan UI awal)
        UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
        StartButton.Position = UDim2.new(0, 10, 0, yOffsetForTitle)
        StatusLabel.Position = UDim2.new(0, 10, 0, yOffsetForTitle + 45)
        -- Posisi elemen timer lainnya sudah diatur relatif saat pembuatan UI awal
    end
end)

-- --- Animasi Glitch Canggih untuk UiTitleLabel ---
coroutine.wrap(function()
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText = UiTitleLabel.Text
    local textLength = string.len(originalText)
    -- Karakter glitch yang lebih beragam, bisa ditambahkan simbol kultivasi jika ada font yang mendukung
    local glitchChars = {"█", "▓", "▒", "░", "*", "#", "$", "%", "&", "@", "~", "^", "ç", "µ", " विद्रोह"} -- ' विद्रोह' (pemberontakan dalam Hindi, contoh)

    local hue = 0
    local S, V = 0.95, 0.95 -- Saturasi & Value untuk warna dasar yang kuat
    local baseSpeed = 0.007 -- Kecepatan perubahan hue dasar

    local originalPosition = UiTitleLabel.Position
    local lastGlitchTime = tick()

    while ScreenGui and ScreenGui.Parent and UiTitleLabel and UiTitleLabel.Parent do
        -- Siklus Warna Dasar Kultivasi (Merah menyala, Emas berkilau, Biru mistis)
        hue = (hue + baseSpeed) % 1
        local r, g, b
        if hue < 0.33 then -- Merah ke Oranye menyala
            local h_adj = hue * 2.5 -- Rentang hue lebih lebar untuk merah/oranye
            r, g, b = Color3.fromHSV(h_adj, S, V).R, Color3.fromHSV(h_adj, S, V).G * 0.6, Color3.fromHSV(h_adj, S, V).B * 0.3
        elseif hue < 0.66 then -- Emas ke Kuning berkilau
            local h_adj = ((hue - 0.33) * 2.5) + 0.08 -- Geser ke rentang emas/kuning (0.08 - 0.16)
            r, g, b = Color3.fromHSV(h_adj, S, V).R, Color3.fromHSV(h_adj, S, V).G, Color3.fromHSV(h_adj, S, V).B * 0.4
        else -- Biru mistis ke Ungu gaib
            local h_adj = ((hue - 0.66) * 2.5) + 0.55 -- Geser ke rentang biru/ungu (0.55 - 0.75)
            r, g, b = Color3.fromHSV(h_adj, S, V).R * 0.7, Color3.fromHSV(h_adj, S, V).G * 0.8, Color3.fromHSV(h_adj, S, V).B
        end
        UiTitleLabel.TextColor3 = Color3.new(r, g, b)
        UiTitleLabel.TextStrokeTransparency = 1 -- Default: stroke tidak terlihat

        -- Pemicu Efek Glitch (lebih sering tapi bisa lebih halus)
        if tick() - lastGlitchTime > math.random() * 0.5 + 0.1 then -- Interval glitch acak (0.1s - 0.6s)
            lastGlitchTime = tick()
            local glitchDurationFrames = math.random(2, 6) -- Glitch berlangsung selama 2-6 frame cepat
            local tempOriginalColor = UiTitleLabel.TextColor3

            for i = 1, glitchDurationFrames do
                if not (UiTitleLabel and UiTitleLabel.Parent) then break end

                -- 1. Glitch Warna: Berkedip ke warna kontras/terang
                if math.random() < 0.8 then -- Peluang tinggi untuk mengubah warna
                    local glitchColor = Color3.fromRGB(math.random(180,255), math.random(180,255), math.random(180,255))
                    if math.random() < 0.4 then -- Kadang-kadang warna neon yang sangat kontras
                        glitchColor = math.random(1,3) == 1 and Color3.fromRGB(0,255,255) or (math.random(1,2) == 1 and Color3.fromRGB(255,0,255) or Color3.fromRGB(100,255,100))
                    end
                    UiTitleLabel.TextColor3 = glitchColor
                end

                -- 2. Glitch Teks: Mengganti beberapa karakter sementara
                if math.random() < 0.65 then
                    local newTextArray = {}
                    for k = 1, textLength do newTextArray[k] = string.sub(originalText, k, k) end

                    local charsToGlitch = math.random(1, math.floor(textLength / 2)) -- Glitch 1 hingga separuh karakter
                    for _ = 1, charsToGlitch do
                        local randomIndex = math.random(1, textLength)
                        newTextArray[randomIndex] = glitchChars[math.random(#glitchChars)]
                    end
                    UiTitleLabel.Text = table.concat(newTextArray)
                end

                -- 3. Glitch Posisi: Pergeseran kecil dan cepat
                if math.random() < 0.75 then
                    local offsetX = math.random(-3, 3)
                    local offsetY = math.random(-3, 3)
                    UiTitleLabel.Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + offsetX, originalPosition.Y.Scale, originalPosition.Y.Offset + offsetY)
                end
                
                -- 4. Glitch Stroke: Stroke acak dan berkedip
                if math.random() < 0.55 then
                    UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(math.random(0,150), math.random(0,150), math.random(0,150)) -- Stroke gelap atau berwarna
                    UiTitleLabel.TextStrokeTransparency = math.random() * 0.35 -- Stroke lebih terlihat
                else
                    UiTitleLabel.TextStrokeTransparency = 1
                end

                task.wait() -- Tunggu sangat singkat untuk kedipan cepat antar frame glitch
            end

            -- Kembalikan ke kondisi normal setelah iterasi glitch
            if UiTitleLabel and UiTitleLabel.Parent then
                UiTitleLabel.Text = originalText
                UiTitleLabel.Position = originalPosition
                UiTitleLabel.TextColor3 = tempOriginalColor -- Kembali ke warna siklus dasar saat ini
                UiTitleLabel.TextStrokeTransparency = 1
            end
        end
        task.wait(0.016) -- Kontrol kecepatan animasi dasar (sekitar 60 FPS jika memungkinkan)
    end
end)()
-- --- END ADDED ---

-- BindToClose (Dari skrip Anda)
game:BindToClose(function()
    if scriptRunning then
        print("Game ditutup, menghentikan skrip kultivasi...")
        scriptRunning = false
        -- Beri waktu untuk loop berhenti secara alami
        task.wait(0.5)
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    print("Pembersihan skrip kultivasi selesai.")
end)

-- Inisialisasi dari skrip Anda
print("Skrip Otomatisasi Kultivasi (Versi UI Kultivasi & Glitch Canggih) Telah Dimuat.")
task.wait(1)
if ScreenGui and not ScreenGui.Parent then
    print("Mencoba memparentkan UI ke CoreGui lagi...")
    setupCoreGuiParenting()
end
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then
    StatusLabel.Text = "Status: Menunggu Perintah..."
end
