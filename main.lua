-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
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
    wait_1m30s_after_first_items = 90, 
    alur_wait_40s_hide_qi = 40,             
    -- wait_1m_before_forbidden = 60, -- --- MODIFIED: Dihilangkan sesuai permintaan ---
    comprehend_duration = 120,         
    post_comprehend_qi_duration = 120, 

    user_script_wait1_before_items1 = 60, 
    user_script_wait2_after_items1 = 30,  
    user_script_wait3_before_items2 = 60, 
    user_script_wait4_before_forbidden = 60, 

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
    if not Frame.Parent or Frame.Parent ~= ScreenGui then
        Frame.Parent = ScreenGui
    end
    if not StartButton.Parent or StartButton.Parent ~= Frame then
        StartButton.Parent = Frame
    end
    if not StatusLabel.Parent or StatusLabel.Parent ~= Frame then
        StatusLabel.Parent = Frame
    end
end
setupCoreGuiParenting() 

-- // Desain UI (Struktur Asli Dipertahankan, dengan penambahan untuk timer dan minimize) //
Frame.Size = UDim2.new(0, 280, 0, 420) 
Frame.Position = UDim2.new(0.02, 0, 0.02, 0) 
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true 
Frame.Draggable = true 
Frame.BorderSizePixel = 1 
Frame.BorderColor3 = Color3.fromRGB(80, 80, 80) 

StartButton.Size = UDim2.new(1, -20, 0, 30) 
StartButton.Position = UDim2.new(0, 10, 0, 10)
StartButton.Text = "Start Script"
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold 

StatusLabel.Size = UDim2.new(1, -20, 0, 40) 
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.Text = "Status: Idle"
StatusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans 
StatusLabel.TextWrapped = true 
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left 

local timerElements = {} 
local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"
TimerTitleLabel.Parent = Frame
TimerTitleLabel.Size = UDim2.new(1, -20, 0, 20)
TimerTitleLabel.Position = UDim2.new(0, 10, 0, 100)
TimerTitleLabel.Text = "Konfigurasi Timer Alur (detik):"
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TimerTitleLabel.Font = Enum.Font.SourceSansSemibold
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local function createTimerInput(name, yPos, labelText, timerKey)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.45, -15, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    timerElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.55, -15, 0, 20)
    input.Position = UDim2.new(0.45, 5, 0, yPos)
    input.Text = tostring(timers[timerKey])
    input.PlaceholderText = "Detik"
    input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    input.TextColor3 = Color3.fromRGB(220, 220, 220)
    input.Font = Enum.Font.SourceSans
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(20,20,20)
    timerElements[name .. "Input"] = input
    return input 
end

local currentY = 130
timerElements.wait1m30sInput = createTimerInput("Wait1m30s", currentY, "Wait Pasca Item1:", "wait_1m30s_after_first_items")
currentY = currentY + 30
timerElements.wait40sInput = createTimerInput("Wait40s", currentY, "Wait Item2 (QI Hidden):", "alur_wait_40s_hide_qi")
currentY = currentY + 30
-- Input untuk wait_1m_before_forbidden dihilangkan karena timer ditiadakan
-- currentY = currentY + 30 
timerElements.comprehendInput = createTimerInput("Comprehend", currentY, "Durasi Comprehend:", "comprehend_duration")
currentY = currentY + 30
timerElements.postComprehendQiInput = createTimerInput("PostComprehendQi", currentY, "Durasi Post-Comp QI:", "post_comprehend_qi_duration")
currentY = currentY + 40 

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"
ApplyTimersButton.Parent = Frame
ApplyTimersButton.Size = UDim2.new(1, -20, 0, 30)
ApplyTimersButton.Position = UDim2.new(0, 10, 0, currentY) -- Posisi disesuaikan
ApplyTimersButton.Text = "Terapkan Semua Timer"
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
ApplyTimersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyTimersButton.Font = Enum.Font.SourceSansBold
timerElements.ApplyButton = ApplyTimersButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 20, 0, 20) 
MinimizeButton.Position = UDim2.new(1, -25, 0, 5) 
MinimizeButton.Text = "-" 
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 2 

local isMinimized = false
local originalFrameSizeY = Frame.Size.Y.Offset 
local minimizedFrameSizeY = 95 

local elementsToToggleVisibility = {
    TimerTitleLabel, 
    timerElements.Wait1m30sLabel, timerElements.wait1m30sInput,
    timerElements.Wait40sLabel, timerElements.wait40sInput,
    -- timerElements.Wait1mLabel, timerElements.wait1mInput, -- Dihilangkan dari toggle karena inputnya ditiadakan
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
             StatusLabel.Text = "Status: Error firing " .. remoteName 
        end
        print("Error firing " .. remoteName .. ": " .. errMessage)
        success = false
    end
    return success
end

-- // Fungsi utama (Struktur Asli Dipertahankan, dengan penyesuaian logika & pemanggilan fireRemoteEnhanced dari skrip Anda) //
local function runCycle()
	local function updateStatus(text) 
        if StatusLabel and StatusLabel.Parent then
		    StatusLabel.Text = "Status: " .. text
        end
	end

	updateStatus("Reincarnating")
	if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnateDelay) 

	if not scriptRunning then return end 
	updateStatus("Persiapan item set 1...")
	waitSeconds(timers.user_script_wait1_before_items1) 
	if not scriptRunning then return end

	local item1 = {
		"Nine Heavens Galaxy Water", "Buzhou Divine Flower",
		"Fusang Divine Tree", "Calm Cultivation Mat"
	}
	for _, item in ipairs(item1) do
		if not scriptRunning then return end 
		updateStatus("Membeli: " .. item)
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay) 
	end

	if not scriptRunning then return end
	updateStatus("Persiapan ganti map...")
	waitSeconds(timers.wait_1m30s_after_first_items) -- Menggunakan timer Alur yang sudah ada
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
	updateStatus("Chaotic Road")
	if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay) 

	if not scriptRunning then return end
	updateStatus("Persiapan item set 2...")
	pauseUpdateQiTemporarily = true 
	updateStatus("UpdateQi dijeda untuk persiapan item (" .. timers.alur_wait_40s_hide_qi .. "s)...") 
	waitSeconds(timers.alur_wait_40s_hide_qi) 
	pauseUpdateQiTemporarily = false 
	updateStatus("UpdateQi dilanjutkan.")
	if not scriptRunning then return end

	local item2 = {
		"Traceless Breeze Lotus",
		"Reincarnation World Destruction Black Lotus",
		"Ten Thousand Bodhi Tree"
	}
	for _, item in ipairs(item2) do
		if not scriptRunning then return end
		updateStatus("Membeli: " .. item)
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay)
	end

	if not scriptRunning then return end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay) 

	if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
		updateStatus("Menjalankan HiddenRemote (UpdateQi aktif)...")
		if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
	else
		updateStatus("Melewati HiddenRemote (UpdateQi tidak aktif/dijeda).")
	end
	task.wait(timers.genericShortDelay) 

    -- --- MODIFIED: Waktu tunggu sebelum Forbidden Zone dihilangkan ---
	-- updateStatus("Persiapan Forbidden Zone (" .. timers.wait_before_forbidden_zone .. "s)...")
	-- waitSeconds(timers.wait_before_forbidden_zone) 
    updateStatus("Persiapan Forbidden Zone (langsung)...")
    -- --- END MODIFIED ---
	if not scriptRunning then return end

	updateStatus("Memasuki Forbidden Zone...")
	if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay) 

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
		task.wait(1) 
	end
    if not scriptRunning then return end
    updateStatus("Comprehend Selesai.")

    -- --- ADDED: Kembali ke Hidden setelah Comprehend selesai, sebelum UpdateQi pasca-Comprehend ---
    if scriptRunning then
        updateStatus("Mengatur status ke Hidden setelah Comprehend...")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then
            updateStatus("Gagal menjalankan HiddenRemote setelah Comprehend.")
            -- Pertimbangkan apakah skrip harus berhenti di sini atau melanjutkan
            -- Untuk saat ini, kita hanya catat dan lanjutkan
        end
        task.wait(timers.genericShortDelay) -- Beri jeda singkat
    end
    -- --- END ADDED ---

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
        task.wait(1)
    end
    if not scriptRunning then return end
	stopUpdateQi = true 

	updateStatus("Cycle Done - Restarting")
end

-- Loop Latar Belakang yang Ditingkatkan (Dari skrip Anda)
local function increaseAptitudeMineLoop_enhanced()
    if StatusLabel and StatusLabel.Parent then 
        StatusLabel.Text = "Status: Loop Aptitude/Mine Dimulai."
    end
    while scriptRunning do 
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        task.wait(timers.aptitudeMineInterval) 
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait() 
    end
end

local function updateQiLoop_enhanced()
    if StatusLabel and StatusLabel.Parent then 
        StatusLabel.Text = "Status: Loop UpdateQi Dimulai."
    end
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
        StartButton.Text = "Running..."
        StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Memulai skrip..." end

        stopUpdateQi = false
        pauseUpdateQiTemporarily = false

        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
            aptitudeMineThread = spawn(increaseAptitudeMineLoop_enhanced)
        end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
            updateQiThread = spawn(updateQiLoop_enhanced)
        end

        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = spawn(function()
                while scriptRunning do
                    runCycle() 
                    if not scriptRunning then break end
                    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Siklus selesai. Memulai ulang..." end
                    task.wait(1) 
                end
                if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Skrip Dihentikan." end
                StartButton.Text = "Start Script"
                StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            end)
        end
    else
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Menghentikan skrip..." end
    end
end)

-- Event Listener untuk Tombol Terapkan Timer (Dari skrip Anda)
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false
        if not inputElement then return false end -- Pemeriksaan tambahan jika elemen UI tidak ada
        local value = tonumber(inputElement.Text)
        if value and value > 0 then
            timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor = Color3.fromRGB(0,200,0) end) end 
            success = true
        else
            if labelElement then pcall(function() labelElement.TextColor = Color3.fromRGB(200,0,0) end) end 
        end
        return success
    end

    local allTimersValid = true
    allTimersValid = applyTextInput(timerElements.wait1m30sInput, "wait_1m30s_after_first_items", timerElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.wait40sInput, "alur_wait_40s_hide_qi", timerElements.Wait40sLabel) and allTimersValid
    -- Timer untuk wait_1m_before_forbidden ditiadakan, jadi validasinya juga
    allTimersValid = applyTextInput(timerElements.comprehendInput, "comprehend_duration", timerElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.postComprehendQiInput, "post_comprehend_qi_duration", timerElements.PostComprehendQiLabel) and allTimersValid

    local originalStatus = StatusLabel.Text:gsub("Status: ", "")
    if allTimersValid then
        updateStatus("Semua timer berhasil diterapkan.")
    else
        updateStatus("Ada input timer tidak valid! Periksa angka (harus > 0).")
    end

    task.wait(2) 
    if timerElements.Wait1m30sLabel then pcall(function() timerElements.Wait1m30sLabel.TextColor = Color3.fromRGB(200,200,200) end) end
    if timerElements.Wait40sLabel then pcall(function() timerElements.Wait40sLabel.TextColor = Color3.fromRGB(200,200,200) end) end
    if timerElements.ComprehendLabel then pcall(function() timerElements.ComprehendLabel.TextColor = Color3.fromRGB(200,200,200) end) end
    if timerElements.PostComprehendQiLabel then pcall(function() timerElements.PostComprehendQiLabel.TextColor = Color3.fromRGB(200,200,200) end) end
    updateStatus(originalStatus) 
end)

-- Logika untuk Tombol Minimize (Dari skrip Anda)
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+" 
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, minimizedFrameSizeY) 
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        StartButton.Position = UDim2.new(0, 10, 0, 10)
        StatusLabel.Position = UDim2.new(0, 10, 0, 50)
        MinimizeButton.Position = UDim2.new(1, -25, 0, 5)

    else
        MinimizeButton.Text = "-" 
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, originalFrameSizeY) 
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = true end
        end
        StartButton.Position = UDim2.new(0, 10, 0, 10) 
        StatusLabel.Position = UDim2.new(0, 10, 0, 50) 
    end
end)

-- BindToClose (Dari skrip Anda)
game:BindToClose(function()
    if scriptRunning then
        print("Game ditutup, menghentikan skrip...")
        scriptRunning = false
        task.wait(0.5) 
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end) 
    end
    print("Pembersihan skrip selesai.")
end)

-- Inisialisasi dari skrip Anda
print("Skrip Otomatisasi (Versi Alur Forbidden Disesuaikan) Telah Dimuat.")
task.wait(1)
if ScreenGui and not ScreenGui.Parent then 
    print("Mencoba memparentkan UI ke CoreGui lagi...")
    setupCoreGuiParenting()
end
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then
    StatusLabel.Text = "Status: Idle"
end
