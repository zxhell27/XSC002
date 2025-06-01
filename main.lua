-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- --- ADDED: Variabel Kontrol dan State ---
local scriptRunning = false
local mainCycleThread = nil -- Untuk menampung thread siklus utama
local aptitudeMineThread = nil -- Untuk loop IncreaseAptitude/Mine
local updateQiThread = nil -- Untuk loop UpdateQi

-- Flag 'stopUpdateQi' dari skrip asli Anda, akan dikelola lebih eksplisit
-- Flag baru 'pauseUpdateQiTemporarily' untuk kondisi "UpdateQi di hidden"
local stopUpdateQiGlobal = false
local pauseUpdateQiTemporarily = false

-- --- ADDED: Tabel Konfigurasi Timer (dalam detik) ---
-- Ini adalah tempat Anda dapat menyesuaikan semua durasi tunggu.
local timers = {
    reincarnate_delay = 0.5, -- Penundaan singkat setelah reincarnate
    increase_aptitude_mine_interval = 0.1, -- Interval dalam loop IncreaseAptitude/Mine (ditambah task.wait())
    update_qi_interval = 1, -- Interval untuk UpdateQi [cite: 12]
    
    -- Pembelian item (cukup sekali)
    buy_item_delay_short = 0.25, -- Penundaan antar pembelian item

    -- Urutan setelah pembelian item pertama
    wait_after_first_items_before_map_change = 90, -- 1 menit 30 detik [cite: 1, 12]
    change_map_delay = 0.5, -- Penundaan singkat setelah ganti map

    -- Urutan setelah ChaoticRoad
    wait_before_second_items_and_hide_qi = 40, -- Tunggu 40 detik, UpdateQi di hidden [cite: 1, 12]

    -- Urutan setelah kembali ke map immortal kedua kali
    wait_before_forbidden_zone = 60, -- Tunggu 1 menit [cite: 1, 12]
    
    -- Fase Comprehend
    comprehend_duration = 120, -- 2 menit [cite: 1, 12]
    comprehend_fire_interval = 1, -- Seberapa sering FireServer("Comprehend") dipanggil selama durasi

    -- Fase UpdateQi setelah Comprehend
    post_comprehend_update_qi_duration = 120, -- 2 menit [cite: 1, 12]

    -- Penundaan lain jika diperlukan
    generic_short_pause = 0.5
}

-- // Parent UI ke player (Struktur Asli Dipertahankan) //
ScreenGui.Parent = game:GetService("CoreGui")
Frame.Parent = ScreenGui
StartButton.Parent = Frame
StatusLabel.Parent = Frame

-- // Desain UI (Struktur Asli Dipertahankan) //
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0.02, 0, 0.02, 0) -- Sedikit penyesuaian untuk tidak terlalu ke pinggir
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true -- Untuk memastikan bisa di-drag
Frame.Draggable = true -- Membuat frame bisa digeser
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(80,80,80)


StartButton.Size = UDim2.new(1, -20, 0, 40) -- Disesuaikan dengan padding frame
StartButton.Position = UDim2.new(0, 10, 0, 10)
StartButton.Text = "Start Script"
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold

StatusLabel.Size = UDim2.new(1, -20, 0, 40) -- Disesuaikan dengan padding frame
StatusLabel.Position = UDim2.new(0, 10, 0, 60)
StatusLabel.Text = "Status: Idle"
StatusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left


-- // Fungsi tunggu (Struktur Asli Dipertahankan, namun implementasi dioptimalkan) //
local function waitSeconds(sec)
    local targetTime = tick() + sec
    while tick() < targetTime and scriptRunning do -- --- MODIFIED: Memeriksa scriptRunning ---
        task.wait() -- --- MODIFIED: Menggunakan task.wait() untuk efisiensi ---
    end
end

-- --- ADDED: Fungsi utilitas untuk memanggil RemoteEvent dengan aman (pcall) ---
local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...) -- Menggunakan table.pack untuk menangani nil arguments dengan aman
    local remoteEventFolder
    local success = false
    local errorMessage = "Unknown error"

    local pcallSuccess, result = pcall(function()
        if pathType == "AreaEvents" then
            remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9)
        else -- "Base"
            remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9)
        end
        
        local remote = remoteEventFolder:WaitForChild(remoteName, 9e9)
        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
    end)

    if pcallSuccess then
        success = true
        -- print("Berhasil fire: " .. remoteName) -- Bisa di-uncomment untuk debugging
    else
        errorMessage = tostring(result)
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = "Status: Error firing " .. remoteName
        end
        print("Error firing " .. remoteName .. ": " .. errorMessage)
    end
    return success
end
-- --- END ADDED ---


-- // Fungsi utama (Struktur Asli Dipertahankan, dengan penyesuaian logika & timer) //
local function runCycle()
	local function updateStatus(text) -- Fungsi updateStatus lokal dari skrip Anda
		if StatusLabel and StatusLabel.Parent then -- Pastikan UI masih ada
			StatusLabel.Text = "Status: " .. text
		end
		print("Status: " .. text) -- Tambahkan print untuk logging
	end

    if not scriptRunning then return end -- Keluar jika skrip dihentikan di tengah siklus
	updateStatus("Reincarnating...")
	if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end -- [cite: 12]
	task.wait(timers.reincarnate_delay) -- Penundaan singkat

    -- Loop IncreaseAptitude/Mine dan UpdateQi sudah berjalan di thread terpisah
    -- dan dikontrol oleh flag 'scriptRunning' serta 'stopUpdateQiGlobal'/'pauseUpdateQiTemporarily'.

    if not scriptRunning then return end
	updateStatus("Membeli item set 1...")
	local itemsToBuy1 = {
		"Nine Heavens Galaxy Water", -- [cite: 13]
		"Buzhou Divine Flower", -- [cite: 14]
		"Fusang Divine Tree", -- [cite: 15]
		"Calm Cultivation Mat" -- [cite: 16]
	}
	for _, itemName in ipairs(itemsToBuy1) do
		if not scriptRunning then return end
		updateStatus("Membeli: " .. itemName)
		if not fireRemoteEnhanced("BuyItem", "Base", itemName) then scriptRunning = false; return end
		task.wait(timers.buy_item_delay_short) -- Penundaan singkat antar pembelian
	end

    if not scriptRunning then return end
	updateStatus(string.format("Menunggu %.1f detik sebelum ganti map...", timers.wait_after_first_items_before_map_change))
	waitSeconds(timers.wait_after_first_items_before_map_change) -- [cite: 1]
	if not scriptRunning then return end

	local function changeMap(mapName) -- Fungsi changeMap lokal dari skrip Anda
		return fireRemoteEnhanced("ChangeMap", "AreaEvents", mapName)
	end
	updateStatus("Mengganti map ke 'immortal'...")
	if not changeMap("immortal") then scriptRunning = false; return end -- [cite: 17]
	task.wait(timers.change_map_delay)
	
    if not scriptRunning then return end
	updateStatus("Mengganti map ke 'chaos'...")
	if not changeMap("chaos") then scriptRunning = false; return end -- [cite: 18]
	task.wait(timers.change_map_delay)

    if not scriptRunning then return end
	updateStatus("Memasuki Chaotic Road...")
	if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end -- [cite: 1]
	task.wait(timers.generic_short_pause)

    if not scriptRunning then return end
	updateStatus(string.format("Menunggu %.1f detik (UpdateQi akan dijeda)...", timers.wait_before_second_items_and_hide_qi))
	pauseUpdateQiTemporarily = true -- "UpdateQi di hidden" [cite: 1]
	updateStatus("UpdateQi dijeda sementara.")
	waitSeconds(timers.wait_before_second_items_and_hide_qi) -- [cite: 1]
	pauseUpdateQiTemporarily = false
	updateStatus("UpdateQi dilanjutkan.")
	if not scriptRunning then return end

	updateStatus("Membeli item set 2...")
	local itemsToBuy2 = {
		"Traceless Breeze Lotus", -- [cite: 19]
		"Reincarnation World Destruction Black Lotus", -- [cite: 20]
		"Ten Thousand Bodhi Tree" -- [cite: 21]
	}
	for _, itemName in ipairs(itemsToBuy2) do
		if not scriptRunning then return end
		updateStatus("Membeli: " .. itemName)
		if not fireRemoteEnhanced("BuyItem", "Base", itemName) then scriptRunning = false; return end
		task.wait(timers.buy_item_delay_short)
	end

    if not scriptRunning then return end
	updateStatus("Mengganti map kembali ke 'immortal'...")
	if not changeMap("immortal") then scriptRunning = false; return end -- [cite: 22]
	task.wait(timers.change_map_delay)

    -- "Lalu kemudian jalankan inii sekali jika sedang Updateqi" [cite: 1]
    if scriptRunning and not stopUpdateQiGlobal and not pauseUpdateQiTemporarily then
	    updateStatus("Menjalankan HiddenRemote (karena UpdateQi aktif)...")
	    if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end -- [cite: 1]
    else
        updateStatus("Melewati HiddenRemote (UpdateQi tidak aktif/dijeda).")
    end
	task.wait(timers.generic_short_pause)

    if not scriptRunning then return end
	updateStatus(string.format("Menunggu %.1f detik sebelum Forbidden Zone...", timers.wait_before_forbidden_zone))
	waitSeconds(timers.wait_before_forbidden_zone) -- [cite: 1]
	if not scriptRunning then return end

	updateStatus("Memasuki Forbidden Zone...")
	if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end -- [cite: 1]
	task.wait(timers.generic_short_pause)

    if not scriptRunning then return end
	updateStatus(string.format("Memulai Comprehend selama %.1f detik...", timers.comprehend_duration))
	stopUpdateQiGlobal = true -- Hentikan UpdateQi selama Comprehend [cite: 12]
	updateStatus("UpdateQi dihentikan untuk Comprehend.")
	
	local comprehendStartTime = tick()
	while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
		if not fireRemoteEnhanced("Comprehend", "Base", {}) then -- [cite: 1]
            updateStatus("Event Comprehend gagal, melanjutkan...")
            break -- Keluar dari loop Comprehend jika ada error
        end
        updateStatus(string.format("Comprehending... %.0f detik tersisa", timers.comprehend_duration - (tick() - comprehendStartTime)))
		task.wait(timers.comprehend_fire_interval) -- Panggil Comprehend secara berkala
	end
    if not scriptRunning then return end
	updateStatus("Comprehend selesai.")

    if not scriptRunning then return end
	updateStatus(string.format("Melanjutkan UpdateQi selama %.1f detik...", timers.post_comprehend_update_qi_duration))
	stopUpdateQiGlobal = false -- Aktifkan kembali UpdateQi [cite: 1]
	updateStatus("UpdateQi dilanjutkan setelah Comprehend.")
	
    -- Biarkan loop UpdateQi yang sudah ada berjalan. Cukup tunggu durasinya di sini.
	waitSeconds(timers.post_comprehend_update_qi_duration) -- [cite: 1]
    if not scriptRunning then return end
	updateStatus("Fase UpdateQi setelah Comprehend selesai.")
    
    -- Skrip akan restart dari awal karena loop di StartButton.MouseButton1Click
	updateStatus("Siklus Selesai - Akan Memulai Ulang...")
end

-- --- ADDED: Loop Latar Belakang yang Ditingkatkan ---
local function increaseAptitudeMineLoop()
    updateStatus("Loop Aptitude & Mine dimulai.")
    while scriptRunning do -- --- MODIFIED: Menggunakan scriptRunning ---
        fireRemoteEnhanced("IncreaseAptitude", "Base", {}) -- [cite: 12]
        task.wait(timers.increase_aptitude_mine_interval)
        if not scriptRunning then break end -- Periksa lagi sebelum fire berikutnya
        fireRemoteEnhanced("Mine", "Base", {}) -- [cite: 12]
        task.wait() -- task.wait() tanpa argumen akan yield selama satu frame (mirip wait() lama) [cite: 12]
    end
    print("Loop Aptitude & Mine dihentikan.")
end

local function updateQiLoop()
    updateStatus("Loop UpdateQi dimulai.")
    while scriptRunning do -- --- MODIFIED: Menggunakan scriptRunning ---
        -- Periksa kedua flag: stopUpdateQiGlobal (untuk Comprehend) dan pauseUpdateQiTemporarily (untuk "hidden")
        if not stopUpdateQiGlobal and not pauseUpdateQiTemporarily then
            fireRemoteEnhanced("UpdateQi", "Base", {}) -- [cite: 12]
        end
        task.wait(timers.update_qi_interval) -- [cite: 12]
    end
    print("Loop UpdateQi dihentikan.")
end
-- --- END ADDED ---


-- // Jalankan saat tombol ditekan (Struktur Asli Dipertahankan, dengan modifikasi untuk kontrol yang lebih baik) //
-- --- MODIFIED: Logika Start/Stop yang Lebih Baik ---
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning -- Toggle state

    if scriptRunning then
        StartButton.Text = "Running..."
        StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        updateStatus("Memulai skrip...")

        -- Reset flag sebelum memulai loop
        stopUpdateQiGlobal = false
        pauseUpdateQiTemporarily = false

        -- Mulai loop latar belakang jika belum berjalan atau sudah mati
        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
            aptitudeMineThread = spawn(increaseAptitudeMineLoop)
        end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
            updateQiThread = spawn(updateQiLoop)
        end

        -- Mulai siklus utama dalam thread baru jika belum berjalan atau sudah mati
        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = spawn(function()
                while scriptRunning do
                    runCycle() -- Panggil fungsi runCycle yang telah disempurnakan
                    if not scriptRunning then break end -- Keluar jika skrip dihentikan di tengah siklus
                    -- Status "Siklus Selesai - Akan Memulai Ulang..." sudah diatur di akhir runCycle()
                    task.wait(1) -- Penundaan singkat sebelum benar-benar memulai ulang siklus
                end
                -- Ini hanya akan tercapai jika scriptRunning menjadi false
                updateStatus("Skrip Dihentikan.")
                StartButton.Text = "Start Script" -- Reset tampilan tombol
                StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            end)
        end
    else
        updateStatus("Menghentikan skrip...")
        -- Flag 'scriptRunning = false' akan secara otomatis menghentikan semua loop yang memeriksanya.
        -- Tampilan tombol akan direset ketika mainCycleThread selesai (karena 'scriptRunning' jadi false).
    end
end)
-- --- END MODIFIED ---

-- Inisialisasi status UI awal
StatusLabel.Text = "Status: Idle. Klik 'Start Script'."

-- --- ADDED: BindToClose untuk pembersihan jika game ditutup ---
game:BindToClose(function()
    if scriptRunning then
        print("Game ditutup, menghentikan skrip...")
        scriptRunning = false -- Memberi sinyal semua loop untuk berhenti
        task.wait(0.5) -- Beri waktu sedikit untuk loop berhenti
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end) -- Hapus UI dengan aman
    end
    print("Pembersihan skrip saat game ditutup selesai.")
end)
-- --- END ADDED ---

print("Skrip Otomatisasi (Versi Tambahan Detail) Telah Dimuat.")
