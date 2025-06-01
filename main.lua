-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- --- ADDED: Variabel Kontrol dan State (Dari skrip Anda) ---
local scriptRunning = false
local stopUpdateQi = false -- Flag dari skrip Anda (digunakan untuk Comprehend)
local pauseUpdateQiTemporarily = false -- Flag baru untuk jeda UpdateQi sementara
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil
-- local uiCreated = false -- Flag ini ada di skrip Anda, bisa dipertimbangkan jika ada re-creation UI

-- --- ADDED: Tabel Konfigurasi Timer (Dari skrip Anda) ---
local timers = {
    wait_before_items1 = 60,
    wait_after_items1_before_map_change = 30,
    wait_before_items2 = 60, -- Skrip Anda menggunakan 60, "Alur" menyebut 40.
                            -- Agar sesuai "Alur" untuk jeda QI, logika runCycle akan pakai 40 dari Alur untuk ini.
                            -- Timer ini bisa tetap 60 jika ada wait lain yang Anda maksud.
                            -- Untuk kejelasan, saya akan tambahkan timer spesifik Alur:
    alur_wait_40s_hide_qi = 40, -- Timer dari Alur untuk jeda UpdateQi
    
    wait_before_forbidden_zone = 60,
    comprehendDuration = 120, 
    postComprehendUpdateQiDuration = 120, 

    updateQiInterval = 1,
    aptitudeMineInterval = 0.1, 
    genericShortDelay = 0.5, 
    reincarnateDelay = 0.5,
    buyItemDelay = 0.25, -- Dari skrip Anda
    changeMapDelay = 0.5, -- Dari skrip Anda
}
-- --- END ADDED (Dari skrip Anda) ---

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
Frame.Size = UDim2.new(0, 250, 0, 320) 
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

-- UI Elements untuk Timer Configuration (Dari skrip Anda)
local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "TimerTitle"
TimerTitleLabel.Parent = Frame
TimerTitleLabel.Size = UDim2.new(1, -20, 0, 20)
TimerTitleLabel.Position = UDim2.new(0, 10, 0, 100)
TimerTitleLabel.Text = "Konfigurasi Timer (detik):"
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TimerTitleLabel.Font = Enum.Font.SourceSansBold
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ComprehendLabel = Instance.new("TextLabel")
ComprehendLabel.Name = "ComprehendLabel"
ComprehendLabel.Parent = Frame
ComprehendLabel.Size = UDim2.new(0.5, -15, 0, 20)
ComprehendLabel.Position = UDim2.new(0, 10, 0, 130)
ComprehendLabel.Text = "Comprehend:"
ComprehendLabel.BackgroundTransparency = 1
ComprehendLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ComprehendLabel.Font = Enum.Font.SourceSans
ComprehendLabel.TextXAlignment = Enum.TextXAlignment.Left

local ComprehendInput = Instance.new("TextBox")
ComprehendInput.Name = "ComprehendInput"
ComprehendInput.Parent = Frame
ComprehendInput.Size = UDim2.new(0.5, -15, 0, 20)
ComprehendInput.Position = UDim2.new(0.5, 5, 0, 130)
ComprehendInput.Text = tostring(timers.comprehendDuration)
ComprehendInput.PlaceholderText = "Detik"
ComprehendInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ComprehendInput.TextColor3 = Color3.fromRGB(220, 220, 220)
ComprehendInput.Font = Enum.Font.SourceSans
ComprehendInput.ClearTextOnFocus = false
ComprehendInput.BorderColor3 = Color3.fromRGB(20,20,20)

local PostComprehendQiLabel = Instance.new("TextLabel")
PostComprehendQiLabel.Name = "PostCompQiLabel"
PostComprehendQiLabel.Parent = Frame
PostComprehendQiLabel.Size = UDim2.new(0.5, -15, 0, 30)
PostComprehendQiLabel.Position = UDim2.new(0, 10, 0, 160)
PostComprehendQiLabel.Text = "Post-Comp Qi:"
PostComprehendQiLabel.BackgroundTransparency = 1
PostComprehendQiLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PostComprehendQiLabel.Font = Enum.Font.SourceSans
PostComprehendQiLabel.TextXAlignment = Enum.TextXAlignment.Left
PostComprehendQiLabel.TextWrapped = true

local PostComprehendQiInput = Instance.new("TextBox")
PostComprehendQiInput.Name = "PostCompQiInput"
PostComprehendQiInput.Parent = Frame
PostComprehendQiInput.Size = UDim2.new(0.5, -15, 0, 20)
PostComprehendQiInput.Position = UDim2.new(0.5, 5, 0, 165)
PostComprehendQiInput.Text = tostring(timers.postComprehendUpdateQiDuration)
PostComprehendQiInput.PlaceholderText = "Detik"
PostComprehendQiInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PostComprehendQiInput.TextColor3 = Color3.fromRGB(220, 220, 220)
PostComprehendQiInput.Font = Enum.Font.SourceSans
PostComprehendQiInput.ClearTextOnFocus = false
PostComprehendQiInput.BorderColor3 = Color3.fromRGB(20,20,20)

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"
ApplyTimersButton.Parent = Frame
ApplyTimersButton.Size = UDim2.new(1, -20, 0, 30)
ApplyTimersButton.Position = UDim2.new(0, 10, 0, 200) 
ApplyTimersButton.Text = "Terapkan Timer"
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
ApplyTimersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyTimersButton.Font = Enum.Font.SourceSansBold

-- --- ADDED: Tombol Minimize dan variabel terkait ---
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 20, 0, 20) -- Ukuran kecil
MinimizeButton.Position = UDim2.new(1, -25, 0, 5) -- Pojok kanan atas Frame
MinimizeButton.Text = "-" -- Teks awal untuk minimize
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 2 -- Pastikan di atas elemen lain jika ada tumpang tindih

local isMinimized = false
local originalFrameSizeY = Frame.Size.Y.Offset -- Simpan tinggi asli frame
local minimizedFrameSizeY = 95 -- Tinggi frame saat minimize (cukup untuk StartButton & StatusLabel)

-- Daftar elemen yang akan di-toggle visibilitasnya saat minimize/maximize
local elementsToToggleVisibility = {
    TimerTitleLabel, ComprehendLabel, ComprehendInput,
    PostComprehendQiLabel, PostComprehendQiInput, ApplyTimersButton
}
-- --- END ADDED ---

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
        -- print("Status: " .. text) -- Dikomentari untuk mengurangi log, status UI cukup
	end

	updateStatus("Reincarnating")
	if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnateDelay) 

	if not scriptRunning then return end 
	updateStatus("Persiapan item set 1...")
	waitSeconds(timers.wait_before_items1) 
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
	waitSeconds(timers.wait_after_items1_before_map_change)
	if not scriptRunning then return end

	local function changeMap(name) 
		return fireRemoteEnhanced("ChangeMap", "AreaEvents", name)
	end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay) -- Menggunakan timer yang sudah ada
	if not scriptRunning then return end
	if not changeMap("chaos") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay) -- Menggunakan timer yang sudah ada

	if not scriptRunning then return end
	updateStatus("Chaotic Road")
	if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay) -- Menggunakan timer yang sudah ada

	if not scriptRunning then return end
	updateStatus("Persiapan item set 2...")
	pauseUpdateQiTemporarily = true 
	updateStatus("UpdateQi dijeda untuk persiapan item (" .. timers.alur_wait_40s_hide_qi .. "s)...") -- Menggunakan timer Alur
	waitSeconds(timers.alur_wait_40s_hide_qi) -- Menggunakan timer Alur
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
	task.wait(timers.changeMapDelay) -- Menggunakan timer yang sudah ada

	if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
		updateStatus("Menjalankan HiddenRemote (UpdateQi aktif)...")
		if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
	else
		updateStatus("Melewati HiddenRemote (UpdateQi tidak aktif/dijeda).")
	end
	task.wait(timers.genericShortDelay) -- Menggunakan timer yang sudah ada

	if not scriptRunning then return end
	updateStatus("Persiapan Forbidden Zone (" .. timers.wait_before_forbidden_zone .. "s)...")
	waitSeconds(timers.wait_before_forbidden_zone)
	if not scriptRunning then return end
	updateStatus("Memasuki Forbidden Zone...")
	if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay) -- Menggunakan timer yang sudah ada

	if not scriptRunning then return end
	updateStatus("Comprehending (" .. timers.comprehendDuration .. "s)...")
	stopUpdateQi = true 
	
	local comprehendStartTime = tick()
	while scriptRunning and (tick() - comprehendStartTime < timers.comprehendDuration) do
		if not fireRemoteEnhanced("Comprehend", "Base", {}) then
            updateStatus("Event Comprehend gagal.")
            break 
        end
        updateStatus(string.format("Comprehending... %d detik tersisa", math.floor(timers.comprehendDuration - (tick() - comprehendStartTime))))
		task.wait(1) 
	end
    if not scriptRunning then return end
    updateStatus("Comprehend Selesai.")

	if not scriptRunning then return end
	updateStatus("Final UpdateQi (" .. timers.postComprehendUpdateQiDuration .. "s)...")
	stopUpdateQi = false 
    
    updateStatus(string.format("Post-Comprehend UpdateQi selama %d detik...", timers.postComprehendUpdateQiDuration))
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.postComprehendUpdateQiDuration) do
        if stopUpdateQi then 
            updateStatus("Loop UpdateQi terhenti saat Post-Comprehend.")
            break
        end
        updateStatus(string.format("Post-Comprehend UpdateQi aktif... %d detik tersisa", math.floor(timers.postComprehendUpdateQiDuration - (tick() - postComprehendQiStartTime))))
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
    -- print("Status: Loop Aptitude/Mine Dimulai.") -- Dikomentari
    while scriptRunning do 
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        task.wait(timers.aptitudeMineInterval) 
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait() 
    end
    -- print("Status: Loop Aptitude/Mine Dihentikan.") -- Dikomentari
end

local function updateQiLoop_enhanced()
    if StatusLabel and StatusLabel.Parent then 
        StatusLabel.Text = "Status: Loop UpdateQi Dimulai."
    end
    -- print("Status: Loop UpdateQi Dimulai.") -- Dikomentari
    while scriptRunning do 
        if not stopUpdateQi and not pauseUpdateQiTemporarily then 
            fireRemoteEnhanced("UpdateQi", "Base", {})
        end
        task.wait(timers.updateQiInterval) 
    end
    -- print("Status: Loop UpdateQi Dihentikan.") -- Dikomentari
end

-- Jalankan saat tombol ditekan (Struktur Asli Dipertahankan, dengan modifikasi untuk kontrol dari skrip Anda)
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning 

    if scriptRunning then
        StartButton.Text = "Running..."
        StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Memulai skrip..." end
        -- print("Status: Memulai skrip...")

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
                    -- print("Status: Siklus selesai. Memulai ulang...")
                    task.wait(1) 
                end
                if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Skrip Dihentikan." end
                -- print("Status: Skrip Dihentikan.")
                StartButton.Text = "Start Script"
                StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            end)
        end
    else
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Menghentikan skrip..." end
        -- print("Status: Menghentikan skrip...")
    end
end)

-- Event Listener untuk Tombol Terapkan Timer (Dari skrip Anda)
ApplyTimersButton.MouseButton1Click:Connect(function()
    local newComprehend = tonumber(ComprehendInput.Text)
    local newPostQi = tonumber(PostComprehendQiInput.Text)
    local changesApplied = false
    local originalStatus = StatusLabel.Text:gsub("Status: ", "")

    if newComprehend and newComprehend > 0 then
        timers.comprehendDuration = newComprehend
        ComprehendInput.BorderColor3 = Color3.fromRGB(0, 200, 0) 
        changesApplied = true
    else
        ComprehendInput.BorderColor3 = Color3.fromRGB(200, 0, 0) 
    end

    if newPostQi and newPostQi > 0 then
        timers.postComprehendUpdateQiDuration = newPostQi
        PostComprehendQiInput.BorderColor3 = Color3.fromRGB(0, 200, 0)
        changesApplied = true
    else
        PostComprehendQiInput.BorderColor3 = Color3.fromRGB(200, 0, 0)
    end

    if changesApplied then
        updateStatus("Timer berhasil diperbarui.")
    else
        updateStatus("Input timer tidak valid.")
    end
    task.wait(1.5)
    ComprehendInput.BorderColor3 = Color3.fromRGB(20,20,20) 
    PostComprehendQiInput.BorderColor3 = Color3.fromRGB(20,20,20)
    updateStatus(originalStatus) 
end)

-- --- ADDED: Logika untuk Tombol Minimize ---
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+" -- Teks untuk maximize
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, minimizedFrameSizeY) -- Perkecil frame
        -- Sembunyikan elemen konfigurasi timer
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        -- Pindahkan tombol Start dan StatusLabel jika diperlukan agar tetap terlihat di frame kecil
        StartButton.Position = UDim2.new(0, 10, 0, 10)
        StatusLabel.Position = UDim2.new(0, 10, 0, 50)
        -- Tombol minimize tetap di posisi relatifnya
        MinimizeButton.Position = UDim2.new(1, -25, 0, 5)

    else
        MinimizeButton.Text = "-" -- Teks untuk minimize
        Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, originalFrameSizeY) -- Kembalikan ukuran frame
        -- Tampilkan kembali elemen konfigurasi timer
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = true end
        end
        -- Kembalikan posisi tombol Start dan StatusLabel ke posisi asli mereka jika diubah
        -- (Posisi asli mereka adalah relatif terhadap frame yang lebih besar, jadi tidak perlu diubah eksplisit jika tata letak UI timer diatur dengan baik)
        StartButton.Position = UDim2.new(0, 10, 0, 10) -- Tetap
        StatusLabel.Position = UDim2.new(0, 10, 0, 50) -- Tetap
         -- Posisi elemen timer lainnya sudah absolut relatif terhadap frame
    end
end)
-- --- END ADDED ---

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
print("Skrip Otomatisasi (Versi dengan Minimize) Telah Dimuat. UI mungkin perlu beberapa saat untuk muncul.")
task.wait(1)
if ScreenGui and not ScreenGui.Parent then -- Periksa ScreenGui, bukan Frame
    print("Mencoba memparentkan UI ke CoreGui lagi...")
    setupCoreGuiParenting()
end
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then
    StatusLabel.Text = "Status: Idle"
end
