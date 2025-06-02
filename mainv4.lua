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

-- // Desain UI (Tema Cyber Kultivasi dengan Peningkatan Latar Belakang) //

-- --- Frame Utama ---
Frame.Size = UDim2.new(0, 300, 0, 480)
Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
-- Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 30) -- Warna solid digantikan gradient
Frame.BackgroundTransparency = 0.1 -- Sedikit transparan untuk efek kedalaman jika ada elemen lain di belakangnya
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(180, 150, 90) -- Border emas kusam (kultivasi kuno)
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

-- --- ADDED: Latar Belakang Cyber Kultivasi ---
local BackgroundGradient = Instance.new("UIGradient")
BackgroundGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 5, 20)),  -- Ungu sangat gelap (hampir hitam)
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(30, 15, 50)), -- Ungu tua kebiruan
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(20, 30, 60)), -- Biru tua keunguan
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 10, 25))   -- Biru sangat gelap
})
BackgroundGradient.Rotation = 45 -- Rotasi gradient untuk efek diagonal
BackgroundGradient.Parent = Frame

-- --- ADDED: Efek Garis Energi Halus (Cyber Lines) ---
local CyberLinesContainer = Instance.new("Frame")
CyberLinesContainer.Name = "CyberLinesContainer"
CyberLinesContainer.Parent = Frame
CyberLinesContainer.Size = UDim2.new(1, 0, 1, 0)
CyberLinesContainer.BackgroundTransparency = 1
CyberLinesContainer.ZIndex = 0 -- Di belakang semua elemen lain di dalam Frame utama

local numberOfLines = 7 -- Jumlah garis energi
for i = 1, numberOfLines do
    local line = Instance.new("Frame")
    line.Name = "CyberLine_" .. i
    line.Parent = CyberLinesContainer
    line.BackgroundColor3 = Color3.fromRGB(70, 150, 255) -- Biru cyber terang
    line.BorderColor3 = Color3.fromRGB(70, 150, 255)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 0

    -- Ukuran dan posisi acak, serta animasi
    local isHorizontal = math.random() < 0.5
    if isHorizontal then
        line.Size = UDim2.new(math.random(0.2, 0.7), 0, 0, math.random(1, 2)) -- Panjang acak, tinggi 1-2 pixel
        line.Position = UDim2.new(math.random(), 0, math.random(), 0)
    else
        line.Size = UDim2.new(0, math.random(1, 2), math.random(0.2, 0.7), 0) -- Lebar 1-2 pixel, tinggi acak
        line.Position = UDim2.new(math.random(), 0, math.random(), 0)
    end

    coroutine.wrap(function()
        local initialPosition = line.Position
        local speed = math.random(50, 150) / 1000 -- Kecepatan pergerakan
        local direction = math.random(1,4) -- 1: kanan, 2: kiri, 3: bawah, 4: atas
        local moveDistance = math.random(5, 20) / 100 -- Jarak pergerakan (persentase dari ukuran frame)

        while line and line.Parent do
            local currentTransparency = math.abs(math.sin(tick() * (math.random(5,15)/10))) * 0.4 + 0.1 -- Transparansi berdenyut (0.1 - 0.5)
            line.BackgroundTransparency = 1 - currentTransparency

            local newX, newY = initialPosition.X.Scale, initialPosition.Y.Scale
            local offset = math.sin(tick() * speed) * moveDistance

            if isHorizontal then
                if direction == 1 then newX = initialPosition.X.Scale + offset
                elseif direction == 2 then newX = initialPosition.X.Scale - offset
                end
            else
                if direction == 3 then newY = initialPosition.Y.Scale + offset
                elseif direction == 4 then newY = initialPosition.Y.Scale - offset
                end
            end
            
            -- Jaga agar garis tetap dalam batas frame (kurang lebih)
            newX = math.clamp(newX, 0, 1)
            newY = math.clamp(newY, 0, 1)
            
            line.Position = UDim2.new(newX, initialPosition.X.Offset, newY, initialPosition.Y.Offset)
            
            task.wait(0.03) -- Update rate animasi
        end
    end)()
end
-- --- END ADDED BACKGROUND ELEMENTS ---


-- --- Judul UI dengan Animasi Glitch ---
local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"
UiTitleLabel.Parent = Frame
UiTitleLabel.Size = UDim2.new(1, -20, 0, 30)
UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
UiTitleLabel.Font = Enum.Font.Code
UiTitleLabel.Text = "ZXHELL X ZEDLIST"
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
UiTitleLabel.TextScaled = true
UiTitleLabel.BackgroundTransparency = 1
UiTitleLabel.ZIndex = 2 -- Pastikan di atas background

local yOffsetForTitle = 45

-- --- Tombol Start ---
StartButton.Size = UDim2.new(1, -20, 0, 35)
StartButton.Position = UDim2.new(0, 10, 0, yOffsetForTitle)
StartButton.Text = "Mulai Kultivasi"
StartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
StartButton.TextColor3 = Color3.fromRGB(255, 230, 200)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.ZIndex = 1 -- Di atas background
local StartButtonCorner = Instance.new("UICorner")
StartButtonCorner.CornerRadius = UDim.new(0, 5)
StartButtonCorner.Parent = StartButton

-- --- Label Status ---
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, yOffsetForTitle + 45)
StatusLabel.Text = "Status: Menunggu Perintah..."
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
StatusLabel.TextColor3 = Color3.fromRGB(210, 200, 220)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.ZIndex = 1 -- Di atas background
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
TimerTitleLabel.TextColor3 = Color3.fromRGB(220, 200, 240)
TimerTitleLabel.Font = Enum.Font.SourceSansSemibold
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerTitleLabel.ZIndex = 1 -- Di atas background

local function createTimerInput(name, yPos, labelText, timerKey)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.45, -15, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos + yOffsetForTitle)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 170, 190)
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1 -- Di atas background
    timerElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.55, -15, 0, 20)
    input.Position = UDim2.new(0.45, 5, 0, yPos + yOffsetForTitle)
    input.Text = tostring(timers[timerKey])
    input.PlaceholderText = "Detik"
    input.BackgroundColor3 = Color3.fromRGB(50, 45, 60)
    input.TextColor3 = Color3.fromRGB(230, 230, 240)
    input.Font = Enum.Font.SourceSans
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(80, 70, 90)
    input.ZIndex = 1 -- Di atas background
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 3)
    InputCorner.Parent = input
    timerElements[name .. "Input"] = input
    return input
end

local currentYConfig = 125
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
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 255)
ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.ZIndex = 1 -- Di atas background
local ApplyButtonCorner = Instance.new("UICorner")
ApplyButtonCorner.CornerRadius = UDim.new(0, 5)
ApplyButtonCorner.Parent = ApplyTimersButton
timerElements.ApplyButton = ApplyTimersButton

-- --- Tombol Minimize ---
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0, 7)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 60, 80)
MinimizeButton.TextColor3 = Color3.fromRGB(200, 190, 210)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 3 -- Di atas judul dan elemen lain
local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 4)
MinimizeButtonCorner.Parent = MinimizeButton

local isMinimized = false
local originalFrameSizeY = Frame.Size.Y.Offset
local minimizedHeaderHeight = (UiTitleLabel.Position.Y.Offset + UiTitleLabel.Size.Y.Offset + 5 +
                              StartButton.Size.Y.Offset + 5 +
                              StatusLabel.Size.Y.Offset + 15)

local elementsToToggleVisibility = {
    TimerTitleLabel,
    timerElements.Wait1m30sLabel, timerElements.wait1m30sInput,
    timerElements.Wait40sLabel, timerElements.wait40sInput,
    timerElements.ComprehendLabel, timerElements.comprehendInput,
    timerElements.PostComprehendQiLabel, timerElements.postComprehendQiInput,
    ApplyTimersButton
}

-- // Fungsi tunggu (Struktur Asli Dipertahankan) //
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat
        task.wait()
    until not scriptRunning or tick() - startTime >= sec
end

-- Fungsi fireRemoteEnhanced (Struktur Asli Dipertahankan) //
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

-- // Fungsi utama (Struktur Asli Dipertahankan) //
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

-- Loop Latar Belakang yang Ditingkatkan (Struktur Asli Dipertahankan) //
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

-- Jalankan saat tombol ditekan (Struktur Asli Dipertahankan) //
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning

    if scriptRunning then
        StartButton.Text = "Mengalirkan Energi..."
        StartButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
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
                StartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end)
            coroutine.resume(mainCycleThread)
        end
    else
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Menghentikan aliran energi..." end
    end
end)

-- Event Listener untuk Tombol Terapkan Timer (Struktur Asli Dipertahankan) //
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false
        if not inputElement then return false end
        local value = tonumber(inputElement.Text)
        if value and value >= 0 then
            timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(100, 220, 100) end) end
            success = true
        else
            if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(220, 100, 100) end) end
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
    local defaultLabelColor = Color3.fromRGB(180, 170, 190)
    if timerElements.Wait1m30sLabel then pcall(function() timerElements.Wait1m30sLabel.TextColor3 = defaultLabelColor end) end
    if timerElements.Wait40sLabel then pcall(function() timerElements.Wait40sLabel.TextColor3 = defaultLabelColor end) end
    if timerElements.ComprehendLabel then pcall(function() timerElements.ComprehendLabel.TextColor3 = defaultLabelColor end) end
    if timerElements.PostComprehendQiLabel then pcall(function() timerElements.PostComprehendQiLabel.TextColor3 = defaultLabelColor end) end
end)

-- Logika untuk Tombol Minimize (Struktur Asli Dipertahankan) //
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+"
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, minimizedHeaderHeight)
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        CyberLinesContainer.Visible = false -- Sembunyikan garis saat minimize
        UiTitleLabel.Position = UDim2.new(0, 10, 0, 5)
        StartButton.Position = UDim2.new(0, 10, 0, UiTitleLabel.Position.Y.Offset + UiTitleLabel.Size.Y.Offset + 5)
        StatusLabel.Position = UDim2.new(0, 10, 0, StartButton.Position.Y.Offset + StartButton.Size.Y.Offset + 5)

    else
        MinimizeButton.Text = "-"
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, originalFrameSizeY)
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = true end
        end
        CyberLinesContainer.Visible = true -- Tampilkan kembali garis
        UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
        StartButton.Position = UDim2.new(0, 10, 0, yOffsetForTitle)
        StatusLabel.Position = UDim2.new(0, 10, 0, yOffsetForTitle + 45)
    end
end)

-- --- Animasi Glitch Canggih untuk UiTitleLabel (Struktur Asli Dipertahankan) ---
coroutine.wrap(function()
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText = UiTitleLabel.Text
    local textLength = string.len(originalText)
    local glitchChars = {"█", "▓", "▒", "░", "*", "#", "$", "%", "&", "@", "~", "^", "ç", "µ", " विद्रोह"}

    local hue = 0
    local S, V = 0.95, 0.95
    local baseSpeed = 0.007

    local originalPosition = UiTitleLabel.Position
    local lastGlitchTime = tick()

    while ScreenGui and ScreenGui.Parent and UiTitleLabel and UiTitleLabel.Parent do
        hue = (hue + baseSpeed) % 1
        local r, g, b
        if hue < 0.33 then
            local h_adj = hue * 2.5
            r, g, b = Color3.fromHSV(h_adj, S, V).R, Color3.fromHSV(h_adj, S, V).G * 0.6, Color3.fromHSV(h_adj, S, V).B * 0.3
        elseif hue < 0.66 then
            local h_adj = ((hue - 0.33) * 2.5) + 0.08
            r, g, b = Color3.fromHSV(h_adj, S, V).R, Color3.fromHSV(h_adj, S, V).G, Color3.fromHSV(h_adj, S, V).B * 0.4
        else
            local h_adj = ((hue - 0.66) * 2.5) + 0.55
            r, g, b = Color3.fromHSV(h_adj, S, V).R * 0.7, Color3.fromHSV(h_adj, S, V).G * 0.8, Color3.fromHSV(h_adj, S, V).B
        end
        UiTitleLabel.TextColor3 = Color3.new(r, g, b)
        UiTitleLabel.TextStrokeTransparency = 1

        if tick() - lastGlitchTime > math.random() * 0.5 + 0.1 then
            lastGlitchTime = tick()
            local glitchDurationFrames = math.random(2, 6)
            local tempOriginalColor = UiTitleLabel.TextColor3

            for i = 1, glitchDurationFrames do
                if not (UiTitleLabel and UiTitleLabel.Parent) then break end
                if math.random() < 0.8 then
                    local glitchColor = Color3.fromRGB(math.random(180,255), math.random(180,255), math.random(180,255))
                    if math.random() < 0.4 then
                        glitchColor = math.random(1,3) == 1 and Color3.fromRGB(0,255,255) or (math.random(1,2) == 1 and Color3.fromRGB(255,0,255) or Color3.fromRGB(100,255,100))
                    end
                    UiTitleLabel.TextColor3 = glitchColor
                end
                if math.random() < 0.65 then
                    local newTextArray = {}
                    for k = 1, textLength do newTextArray[k] = string.sub(originalText, k, k) end
                    local charsToGlitch = math.random(1, math.floor(textLength / 2))
                    for _ = 1, charsToGlitch do
                        local randomIndex = math.random(1, textLength)
                        newTextArray[randomIndex] = glitchChars[math.random(#glitchChars)]
                    end
                    UiTitleLabel.Text = table.concat(newTextArray)
                end
                if math.random() < 0.75 then
                    local offsetX = math.random(-3, 3)
                    local offsetY = math.random(-3, 3)
                    UiTitleLabel.Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + offsetX, originalPosition.Y.Scale, originalPosition.Y.Offset + offsetY)
                end
                if math.random() < 0.55 then
                    UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(math.random(0,150), math.random(0,150), math.random(0,150))
                    UiTitleLabel.TextStrokeTransparency = math.random() * 0.35
                else
                    UiTitleLabel.TextStrokeTransparency = 1
                end
                task.wait()
            end
            if UiTitleLabel and UiTitleLabel.Parent then
                UiTitleLabel.Text = originalText
                UiTitleLabel.Position = originalPosition
                UiTitleLabel.TextColor3 = tempOriginalColor
                UiTitleLabel.TextStrokeTransparency = 1
            end
        end
        task.wait(0.016)
    end
end)()

-- BindToClose (Struktur Asli Dipertahankan) //
game:BindToClose(function()
    if scriptRunning then
        print("Game ditutup, menghentikan skrip kultivasi...")
        scriptRunning = false
        task.wait(0.5)
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
    print("Pembersihan skrip kultivasi selesai.")
end)

-- Inisialisasi (Struktur Asli Dipertahankan) //
print("Skrip Otomatisasi Kultivasi (Versi UI Cyber Kultivasi Lanjutan) Telah Dimuat.")
task.wait(1)
if ScreenGui and not ScreenGui.Parent then
    print("Mencoba memparentkan UI ke CoreGui lagi...")
    setupCoreGuiParenting()
end
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then
    StatusLabel.Text = "Status: Menunggu Perintah..."
end
