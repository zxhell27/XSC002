-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- --- ADDED: Variabel Kontrol dan State ---
local scriptRunning = false
local stopUpdateQi = false -- Flag dari skrip asli Anda
local pauseUpdateQiTemporarily = false -- Flag baru untuk jeda UpdateQi sementara
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil
local uiCreated = false -- Flag untuk memastikan UI hanya dibuat sekali atau di-refresh

-- --- ADDED: Tabel Konfigurasi Timer (nilai dari "Alur" dan skrip Anda) ---
local timers = {
    -- Durasi dari skrip referensi Anda (bisa disesuaikan atau dikaitkan ke UI)
    wait_before_items1 = 60,
    wait_after_items1_before_map_change = 30,
    wait_before_items2 = 60, -- Skrip Anda menggunakan 60, "Alur" menyebut 40. Default ke 60, bisa diubah.
    wait_before_forbidden_zone = 60,
    comprehendDuration = 120, -- Akan dikaitkan ke UI
    postComprehendUpdateQiDuration = 120, -- Akan dikaitkan ke UI

    -- Interval & penundaan lain dari "Alur" atau untuk operasi
    updateQiInterval = 1,
    aptitudeMineInterval = 0.1, -- Penundaan kecil antar Aptitude & Mine
    genericShortDelay = 0.5, -- Untuk operasi singkat seperti FireServer
    reincarnateDelay = 0.5
}
-- --- END ADDED ---

-- // Parent UI ke player (Struktur Asli Dipertahankan) //
-- --- MODIFIED: Dibungkus fungsi agar bisa dipanggil ulang jika perlu & memastikan CoreGui siap ---
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
setupCoreGuiParenting() -- Panggil saat inisialisasi

-- // Desain UI (Struktur Asli Dipertahankan, dengan penambahan untuk timer) //
Frame.Size = UDim2.new(0, 250, 0, 320) -- --- MODIFIED: Ukuran Frame diperbesar untuk UI timer ---
Frame.Position = UDim2.new(0.02, 0, 0.02, 0) -- --- MODIFIED: Posisi sedikit disesuaikan ---
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true -- --- ADDED: Untuk memastikan bisa di-drag ---
Frame.Draggable = true -- --- ADDED: Membuat frame bisa digeser ---
Frame.BorderSizePixel = 1 -- --- ADDED ---
Frame.BorderColor3 = Color3.fromRGB(80, 80, 80) -- --- ADDED ---


StartButton.Size = UDim2.new(1, -20, 0, 30) -- --- MODIFIED: Ukuran disesuaikan dengan frame baru ---
StartButton.Position = UDim2.new(0, 10, 0, 10) -- --- MODIFIED: Posisi disesuaikan ---
StartButton.Text = "Start Script"
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold -- --- ADDED: Konsistensi Font ---

StatusLabel.Size = UDim2.new(1, -20, 0, 40) -- --- MODIFIED: Ukuran disesuaikan ---
StatusLabel.Position = UDim2.new(0, 10, 0, 50) -- --- MODIFIED: Posisi disesuaikan ---
StatusLabel.Text = "Status: Idle"
StatusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans -- --- ADDED: Konsistensi Font ---
StatusLabel.TextWrapped = true -- --- ADDED ---
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left -- --- ADDED ---

-- --- ADDED: UI Elements untuk Timer Configuration ---
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
ApplyTimersButton.Position = UDim2.new(0, 10, 0, 200) -- Di bawah input
ApplyTimersButton.Text = "Terapkan Timer"
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
ApplyTimersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyTimersButton.Font = Enum.Font.SourceSansBold
-- --- END ADDED UI Elements ---

-- // Fungsi tunggu (Struktur Asli Dipertahankan) //
-- --- MODIFIED: Diganti dengan task.wait() untuk efisiensi dan presisi ---
local function waitSeconds(sec)
    --[[ Versi Asli Pengguna:
	local start = tick()
	while tick() - start < sec do wait() end
    --]]
    -- Versi yang Dioptimalkan:
    if sec <= 0 then task.wait() return end -- Handle non-positive waits
    local startTime = tick()
    repeat
        task.wait() -- Yield to other scripts
    until not scriptRunning or tick() - startTime >= sec
end
-- --- END MODIFIED ---

-- --- ADDED: Fungsi fireRemote dengan pcall ---
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
        -- print("Berhasil fire: " .. remoteName) -- Komentari untuk mengurangi spam log
    else
        errMessage = tostring(pcallResult)
        if StatusLabel and StatusLabel.Parent then -- Pastikan UI ada
             StatusLabel.Text = "Status: Error firing " .. remoteName -- Tampilkan error di UI
        end
        print("Error firing " .. remoteName .. ": " .. errMessage)
        success = false
    end
    return success
end
-- --- END ADDED ---

-- // Fungsi utama (Struktur Asli Dipertahankan, dengan penyesuaian logika & pemanggilan fireRemoteEnhanced) //
local function runCycle()
	local function updateStatus(text) -- Fungsi updateStatus lokal dari skrip Anda
        if StatusLabel and StatusLabel.Parent then
		    StatusLabel.Text = "Status: " .. text
        end
        print("Status: " .. text) -- Tambahkan print untuk log
	end

	updateStatus("Reincarnating")
	-- --- MODIFIED: Menggunakan fireRemoteEnhanced ---
	if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnateDelay) -- --- ADDED: Penundaan singkat setelah Reincarnate ---

    -- Loop Aptitude/Mine dan UpdateQi dikontrol oleh thread terpisah dan flag scriptRunning

	if not scriptRunning then return end -- --- ADDED: Pemeriksaan scriptRunning ---
	updateStatus("Persiapan item set 1...")
	-- --- MODIFIED: Menggunakan timers.wait_before_items1 ---
	waitSeconds(timers.wait_before_items1) -- Sesuai struktur asli Anda: tunggu dulu
	if not scriptRunning then return end

	local item1 = {
		"Nine Heavens Galaxy Water", "Buzhou Divine Flower",
		"Fusang Divine Tree", "Calm Cultivation Mat"
	}
	for _, item in ipairs(item1) do
		if not scriptRunning then return end -- --- ADDED: Pemeriksaan scriptRunning ---
		updateStatus("Membeli: " .. item)
		-- --- MODIFIED: Menggunakan fireRemoteEnhanced, dan argumen item langsung ---
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay) -- --- ADDED: Penundaan kecil antar pembelian ---
	end

	if not scriptRunning then return end
	updateStatus("Persiapan ganti map...")
	-- --- MODIFIED: Menggunakan timers.wait_after_items1_before_map_change ---
	waitSeconds(timers.wait_after_items1_before_map_change)
	if not scriptRunning then return end

	local function changeMap(name) -- Fungsi changeMap lokal dari skrip Anda
		-- --- MODIFIED: Menggunakan fireRemoteEnhanced ---
		return fireRemoteEnhanced("ChangeMap", "AreaEvents", name)
	end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)
	if not scriptRunning then return end
	if not changeMap("chaos") then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)

	if not scriptRunning then return end
	updateStatus("Chaotic Road")
	-- --- MODIFIED: Menggunakan fireRemoteEnhanced ---
	if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)

	if not scriptRunning then return end
	updateStatus("Persiapan item set 2...")
	-- --- MODIFIED: Menggunakan timers.wait_before_items2 (default 40s dari Alur, bisa diubah) ---
	-- --- "Alur" meminta UpdateQi dijeda di sini (selama 40 detik) ---
	pauseUpdateQiTemporarily = true -- --- ADDED: Jeda UpdateQi ---
	updateStatus("UpdateQi dijeda untuk persiapan item...")
	waitSeconds(timers.wait_before_items2)
	pauseUpdateQiTemporarily = false -- --- ADDED: Lanjutkan UpdateQi ---
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
		-- --- MODIFIED: Menggunakan fireRemoteEnhanced ---
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay)
	end

	if not scriptRunning then return end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)

	-- --- ADDED: Logika kondisional untuk HiddenRemote sesuai "Alur" ---
	if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
		updateStatus("Menjalankan HiddenRemote (UpdateQi aktif)...")
		if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
	else
		updateStatus("Melewati HiddenRemote (UpdateQi tidak aktif/dijeda).")
	end
	task.wait(timers.genericShortDelay)
	-- --- END ADDED ---

	if not scriptRunning then return end
	updateStatus("Persiapan Forbidden Zone...")
	-- --- MODIFIED: Menggunakan timers.wait_before_forbidden_zone (Alur: 1 menit) ---
	waitSeconds(timers.wait_before_forbidden_zone)
	if not scriptRunning then return end
	updateStatus("Memasuki Forbidden Zone...")
	-- --- MODIFIED: Menggunakan fireRemoteEnhanced ---
	if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay)

	if not scriptRunning then return end
	updateStatus("Comprehending...")
	stopUpdateQi = true -- Flag dari skrip asli Anda, ini akan menghentikan loop UpdateQi
	
    -- --- MODIFIED: Menggunakan timers.comprehendDuration dan loop yang lebih aman ---
	local comprehendStartTime = tick()
	while scriptRunning and (tick() - comprehendStartTime < timers.comprehendDuration) do
		if not fireRemoteEnhanced("Comprehend", "Base", {}) then
            updateStatus("Event Comprehend gagal.")
            -- Mungkin tidak perlu `scriptRunning = false` di sini agar siklus bisa lanjut ke post-comprehend
            break -- Keluar dari loop comprehend jika gagal
        end
        updateStatus(string.format("Comprehending... %d detik tersisa", math.floor(timers.comprehendDuration - (tick() - comprehendStartTime))))
		task.wait(1) -- "Alur" tidak menyebut interval, 1 detik adalah asumsi wajar
        -- wait() asli dari skrip Anda di sini akan membuat CPU usage tinggi
	end
    if not scriptRunning then return end
    updateStatus("Comprehend Selesai.")


	if not scriptRunning then return end
	updateStatus("Final UpdateQi")
	stopUpdateQi = false -- Izinkan UpdateQi berjalan lagi
    -- Loop UpdateQi akan mengambil alih secara otomatis jika scriptRunning true.

    -- --- MODIFIED: Menggunakan timers.postComprehendUpdateQiDuration ---
	-- Daripada `waitSeconds` di sini, kita biarkan loop UpdateQi berjalan selama durasi ini
    updateStatus(string.format("Post-Comprehend UpdateQi selama %d detik...", timers.postComprehendUpdateQiDuration))
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.postComprehendUpdateQiDuration) do
        -- Pastikan loop UpdateQi benar-benar berjalan (stopUpdateQi = false)
        if stopUpdateQi then -- Jika ada kondisi tak terduga yang menghentikannya lagi
            updateStatus("Loop UpdateQi terhenti saat Post-Comprehend.")
            break
        end
        updateStatus(string.format("Post-Comprehend UpdateQi aktif... %d detik tersisa", math.floor(timers.postComprehendUpdateQiDuration - (tick() - postComprehendQiStartTime))))
        task.wait(1)
    end
    if not scriptRunning then return end
    -- "Alur" menyiratkan setelah ini skrip dimulai dari awal (Reincarnate).
    -- Skrip asli Anda memiliki: stopUpdateQi = true di akhir. Ini akan menghentikan UpdateQi sebelum restart siklus.
    -- Jika UpdateQi harus terus berjalan hingga Reincarnate berikutnya, baris ini bisa dihilangkan.
    -- Untuk saat ini, kita pertahankan perilaku asli skrip Anda:
	stopUpdateQi = true 

	updateStatus("Cycle Done - Restarting")
end


-- --- ADDED: Loop Latar Belakang yang Ditingkatkan ---
local function increaseAptitudeMineLoop_enhanced()
    if StatusLabel and StatusLabel.Parent then -- Pastikan UI ada
        StatusLabel.Text = "Status: Loop Aptitude/Mine Dimulai."
    end
    print("Status: Loop Aptitude/Mine Dimulai.")
    while scriptRunning do -- --- MODIFIED: Menggunakan scriptRunning ---
        -- local args = {} -- Args tidak perlu didefinisikan ulang setiap iterasi jika selalu kosong
        fireRemoteEnhanced("IncreaseAptitude", "Base", {})
        task.wait(timers.aptitudeMineInterval) -- --- MODIFIED: Menggunakan task.wait dan timer ---
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {})
        task.wait() -- wait() asli dari skrip Anda, untuk yield
    end
    print("Status: Loop Aptitude/Mine Dihentikan.")
end

local function updateQiLoop_enhanced()
    if StatusLabel and StatusLabel.Parent then -- Pastikan UI ada
        StatusLabel.Text = "Status: Loop UpdateQi Dimulai."
    end
    print("Status: Loop UpdateQi Dimulai.")
    while scriptRunning do -- --- MODIFIED: Menggunakan scriptRunning ---
        if not stopUpdateQi and not pauseUpdateQiTemporarily then -- Memeriksa kedua flag
            -- local args = {} -- Args tidak perlu didefinisikan ulang
            fireRemoteEnhanced("UpdateQi", "Base", {})
        end
        task.wait(timers.updateQiInterval) -- --- MODIFIED: Menggunakan task.wait dan timer ---
    end
    print("Status: Loop UpdateQi Dihentikan.")
end
-- --- END ADDED ---


-- // Jalankan saat tombol ditekan (Struktur Asli Dipertahankan, dengan modifikasi untuk kontrol) //
-- --- MODIFIED: Logika Start/Stop yang Lebih Baik ---
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning -- Toggle state

    if scriptRunning then
        StartButton.Text = "Running..."
        StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Memulai skrip..." end
        print("Status: Memulai skrip...")

        -- Pastikan flag disetel dengan benar sebelum memulai loop
        stopUpdateQi = false
        pauseUpdateQiTemporarily = false

        -- Mulai loop latar belakang jika belum berjalan atau sudah mati
        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
            aptitudeMineThread = spawn(increaseAptitudeMineLoop_enhanced)
        end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
            updateQiThread = spawn(updateQiLoop_enhanced)
        end

        -- Mulai siklus utama dalam thread baru jika belum berjalan atau sudah mati
        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = spawn(function()
                while scriptRunning do
                    runCycle() -- Panggil fungsi runCycle asli Anda (yang telah dimodifikasi di atas)
                    if not scriptRunning then break end
                    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Siklus selesai. Memulai ulang..." end
                    print("Status: Siklus selesai. Memulai ulang...")
                    task.wait(1) -- Penundaan singkat sebelum siklus berikutnya
                end
                if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Skrip Dihentikan." end
                print("Status: Skrip Dihentikan.")
                -- Reset tampilan tombol setelah loop utama benar-benar berhenti
                StartButton.Text = "Start Script"
                StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            end)
        end
    else
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "Status: Menghentikan skrip..." end
        print("Status: Menghentikan skrip...")
        -- Loop akan berhenti karena 'scriptRunning' menjadi false.
        -- Tombol akan direset teks & warnanya ketika mainCycleThread selesai.
    end
end)
-- --- END MODIFIED ---

-- --- ADDED: Event Listener untuk Tombol Terapkan Timer ---
ApplyTimersButton.MouseButton1Click:Connect(function()
    local newComprehend = tonumber(ComprehendInput.Text)
    local newPostQi = tonumber(PostComprehendQiInput.Text)
    local changesApplied = false
    local originalStatus = StatusLabel.Text:gsub("Status: ", "")

    if newComprehend and newComprehend > 0 then
        timers.comprehendDuration = newComprehend
        ComprehendInput.BorderColor3 = Color3.fromRGB(0, 200, 0) -- Hijau untuk sukses
        changesApplied = true
    else
        ComprehendInput.BorderColor3 = Color3.fromRGB(200, 0, 0) -- Merah untuk error
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
    ComprehendInput.BorderColor3 = Color3.fromRGB(20,20,20) -- Reset warna border
    PostComprehendQiInput.BorderColor3 = Color3.fromRGB(20,20,20)
    updateStatus(originalStatus) -- Kembalikan status sebelumnya
end)
-- --- END ADDED ---

-- --- ADDED: BindToClose untuk pembersihan ---
game:BindToClose(function()
    if scriptRunning then
        print("Game ditutup, menghentikan skrip...")
        scriptRunning = false
        task.wait(0.5) -- Beri waktu untuk loop berhenti
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end) -- Hapus UI
    end
    print("Pembersihan skrip selesai.")
end)
-- --- END ADDED ---

print("Skrip Otomatisasi (Versi Tambahan) Telah Dimuat. UI mungkin perlu beberapa saat untuk muncul.")
-- Panggil setupCoreGuiParenting lagi setelah beberapa saat jika ada masalah timing dengan CoreGui
task.wait(1)
if not ScreenGui.Parent then
    print("Mencoba memparentkan UI ke CoreGui lagi...")
    setupCoreGuiParenting()
end
-- Inisialisasi status awal di UI jika belum
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then
    StatusLabel.Text = "Status: Idle"
end
