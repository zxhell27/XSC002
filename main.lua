-- // UI FRAME (Struktur Asli Dipertahankan) //
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- --- ADDED: Variabel Kontrol dan State ---
local scriptRunning = false
local mainCycleThread = nil
local aptitudeMineThread = nil
local updateQiThread = nil

-- Flag 'stopUpdateQi' dari skrip asli Anda.
-- Flag baru 'pauseUpdateQiTemporarily' untuk kondisi "UpdateQi di hidden".
-- Nama stopUpdateQi diubah menjadi stopUpdateQiForComprehend agar lebih jelas tujuannya.
local stopUpdateQiForComprehend = false 
local pauseUpdateQiTemporarily = false

-- --- ADDED: Tabel Konfigurasi Timer (dalam detik) ---
-- Ini adalah tempat Anda dapat menyesuaikan semua durasi tunggu.
local timers = {
    -- Timer dari "Alur script roblox" yang akan dibuatkan UI
    wait_1m30s_after_first_items = 90, -- (Alur: setelah item, sebelum map change)
    wait_40s_hide_qi = 40,             -- (Alur: sebelum item kedua, UpdateQi hidden)
    wait_1m_before_forbidden = 60,     -- (Alur: sebelum ForbiddenZone)
    comprehend_duration = 120,         -- (Alur: 2 menit)
    post_comprehend_qi_duration = 120, -- (Alur: 2 menit)

    -- Timer internal dari struktur skrip asli Anda (dipertahankan jika berbeda dari Alur)
    -- dan penundaan operasi kecil
    user_script_wait1_before_items1 = 60, -- Dari waitSeconds(60) sebelum item1 di skrip Anda
    user_script_wait2_after_items1 = 30,  -- Dari waitSeconds(30) setelah item1 di skrip Anda
    user_script_wait3_before_items2 = 60, -- Dari waitSeconds(60) sebelum item2 di skrip Anda (Alur: 40s)
                                        -- Saya akan menggunakan timers.wait_40s_hide_qi untuk logika Alur,
                                        -- dan ini bisa diabaikan atau disesuaikan jika strukturnya berbeda.
    user_script_wait4_before_forbidden = 60, -- Dari waitSeconds(60) sebelum forbidden di skrip Anda

    update_qi_interval = 1,
    aptitude_mine_interval = 0.05, -- Penundaan sangat singkat di loop Aptitude/Mine
    reincarnate_delay = 0.5,
    buy_item_delay = 0.2,
    change_map_delay = 0.5,
    fireserver_generic_delay = 0.25 -- Penundaan singkat setelah beberapa FireServer
}
-- --- END ADDED ---

-- // Parent UI ke player (Struktur Asli Dipertahankan) //
ScreenGui.Parent = game:GetService("CoreGui")
Frame.Parent = ScreenGui
StartButton.Parent = Frame
StatusLabel.Parent = Frame

-- // Desain UI (Struktur Asli Dipertahankan, dengan penambahan) //
Frame.Size = UDim2.new(0, 280, 0, 420) -- --- MODIFIED: Frame diperbesar untuk UI timer ---
Frame.Position = UDim2.new(0.02, 0, 0.02, 0) 
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true 
Frame.Draggable = true 
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(80,80,80)

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

-- --- ADDED: UI Elements untuk Timer Configuration ---
local timerElements = {} -- Tabel untuk menyimpan elemen UI timer

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
    return input -- Kembalikan input untuk koneksi event nanti
end

local timerTitle = Instance.new("TextLabel")
timerTitle.Name = "TimerConfTitle"
timerTitle.Parent = Frame
timerTitle.Size = UDim2.new(1, -20, 0, 20)
timerTitle.Position = UDim2.new(0, 10, 0, 100)
timerTitle.Text = "Konfigurasi Timer Alur (detik):"
timerTitle.BackgroundTransparency = 1
timerTitle.TextColor3 = Color3.fromRGB(220,220,220)
timerTitle.Font = Enum.Font.SourceSansSemibold
timerTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Membuat input untuk setiap timer yang diminta
local currentY = 130
timerElements.wait1m30sInput = createTimerInput("Wait1m30s", currentY, "Wait Pasca Item1:", "wait_1m30s_after_first_items")
currentY = currentY + 30
timerElements.wait40sInput = createTimerInput("Wait40s", currentY, "Wait Item2 (QI Hidden):", "wait_40s_hide_qi")
currentY = currentY + 30
timerElements.wait1mInput = createTimerInput("Wait1m", currentY, "Wait Sblm Forbidden:", "wait_1m_before_forbidden")
currentY = currentY + 30
timerElements.comprehendInput = createTimerInput("Comprehend", currentY, "Durasi Comprehend:", "comprehend_duration")
currentY = currentY + 30
timerElements.postComprehendQiInput = createTimerInput("PostComprehendQi", currentY, "Durasi Post-Comp QI:", "post_comprehend_qi_duration")
currentY = currentY + 40 -- Spasi lebih sebelum tombol

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "ApplyTimersButton"
ApplyTimersButton.Parent = Frame
ApplyTimersButton.Size = UDim2.new(1, -20, 0, 30)
ApplyTimersButton.Position = UDim2.new(0, 10, 0, currentY)
ApplyTimersButton.Text = "Terapkan Semua Timer"
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
ApplyTimersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyTimersButton.Font = Enum.Font.SourceSansBold
timerElements.ApplyButton = ApplyTimersButton
-- --- END ADDED UI ---

-- // Fungsi tunggu (Struktur Asli Dipertahankan) //
local function waitSeconds(sec)
    local startTime = tick()
    while tick() - startTime < sec do
        if not scriptRunning then break end -- --- ADDED: Memeriksa scriptRunning agar bisa diinterupsi ---
        wait() -- wait() asli dari skrip Anda
    end
end

-- --- ADDED: Fungsi fireRemote dengan pcall ---
local function fireRemoteEnhanced_pcall(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...)
    local success, result = pcall(function()
        local remoteEventFolder
        if pathType == "AreaEvents" then
            remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9)
        else
            remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9)
        end
        local remote = remoteEventFolder:WaitForChild(remoteName, 9e9)
        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
    end)

    if not success then
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = "Status: Error Firing " .. remoteName
        end
        print("ERROR Firing " .. remoteName .. ": " .. tostring(result))
    else
        -- print("SUCCESS Firing " .. remoteName) -- Uncomment untuk debug
    end
    return success
end
-- --- END ADDED ---

-- // Fungsi utama (Struktur Asli Dipertahankan, dengan penyesuaian) //
local function runCycle()
	local function updateStatus(text) -- Fungsi updateStatus lokal dari skrip Anda
        if StatusLabel and StatusLabel.Parent then
		    StatusLabel.Text = "Status: " .. text
        end
        -- print("Status: " .. text) -- Di-disable agar tidak terlalu banyak log, StatusLabel cukup
	end

    if not scriptRunning then return end
	updateStatus("Reincarnating...")
	-- --- MODIFIED: Menggunakan pcall wrapper dan timer ---
	if not fireRemoteEnhanced_pcall("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnate_delay)

    -- --- ALUR ASLI PENGGUNA (Bagian Item Set 1): wait -> buy -> wait ---
    -- Saya akan tetap menggunakan struktur ini tapi dengan timer dari tabel 'timers'
    -- dan menyelaraskan dengan total waktu "Alur" jika memungkinkan.
    -- "Alur" mengatakan: beli item1 -> tunggu 1m30s.
    -- Skrip Anda: tunggu 60s -> beli item1 -> tunggu 30s.
    -- Di sini, saya akan prioritaskan struktur asli Anda untuk bagian ini.

    if not scriptRunning then return end
    updateStatus("Menunggu sebelum Item Set 1 (dari skrip asli)...")
    waitSeconds(timers.user_script_wait1_before_items1) --- Menggunakan timer dari skrip asli Anda
	if not scriptRunning then return end

	updateStatus("Membeli Item Set 1...")
	local item1 = {
		"Nine Heavens Galaxy Water", "Buzhou Divine Flower",
		"Fusang Divine Tree", "Calm Cultivation Mat"
	}
	for _, item in ipairs(item1) do
		if not scriptRunning then return end
		updateStatus("Membeli: " .. item)
		if not fireRemoteEnhanced_pcall("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buy_item_delay)
	end

    if not scriptRunning then return end
    updateStatus("Menunggu setelah Item Set 1 (dari skrip asli)...")
    waitSeconds(timers.user_script_wait2_after_items1) --- Menggunakan timer dari skrip asli Anda
	if not scriptRunning then return end

    -- --- AKHIR BAGIAN ITEM SET 1 DARI STRUKTUR ASLI PENGGUNA ---
    -- Catatan: Total waktu dari "Alur" (90s) untuk setelah item set 1 mungkin berbeda
    -- dengan user_script_wait1_before_items1 + user_script_wait2_after_items1.
    -- Jika ingin sesuai "Alur", maka `timers.wait_1m30s_after_first_items` harusnya menggantikan
    -- salah satu atau kombinasi dari timer di atas. Untuk saat ini, struktur asli dipertahankan.

	local function changeMap(name) -- Fungsi changeMap lokal dari skrip Anda
		return fireRemoteEnhanced_pcall("ChangeMap", "AreaEvents", name)
	end

	updateStatus("Mengganti map ke 'immortal'...")
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.change_map_delay)
	
    if not scriptRunning then return end
	updateStatus("Mengganti map ke 'chaos'...")
	if not changeMap("chaos") then scriptRunning = false; return end
	task.wait(timers.change_map_delay)

    if not scriptRunning then return end
	updateStatus("Chaotic Road...")
	if not fireRemoteEnhanced_pcall("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.fireserver_generic_delay)

    if not scriptRunning then return end
    -- --- MODIFIED: Menggunakan timer Alur (40s) dan logika pause UpdateQi ---
	updateStatus("Menunggu " .. timers.wait_40s_hide_qi .. "s (UpdateQi dijeda)...")
	pauseUpdateQiTemporarily = true 
	waitSeconds(timers.wait_40s_hide_qi) 
	pauseUpdateQiTemporarily = false
	updateStatus("UpdateQi dilanjutkan.")
	if not scriptRunning then return end

	updateStatus("Membeli Item Set 2...")
	local item2 = {
		"Traceless Breeze Lotus", "Reincarnation World Destruction Black Lotus", "Ten Thousand Bodhi Tree"
	}
	for _, item in ipairs(item2) do
		if not scriptRunning then return end
		updateStatus("Membeli: " .. item)
		if not fireRemoteEnhanced_pcall("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buy_item_delay)
	end

    if not scriptRunning then return end
	updateStatus("Mengganti map ke 'immortal' (lagi)...")
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.change_map_delay)

    -- --- MODIFIED: Panggilan HiddenRemote kondisional ---
	if scriptRunning and not stopUpdateQiForComprehend and not pauseUpdateQiTemporarily then
	    updateStatus("Menjalankan HiddenRemote (UpdateQi aktif)...")
	    if not fireRemoteEnhanced_pcall("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
    else
        updateStatus("Melewati HiddenRemote (UpdateQi tidak aktif/dijeda).")
    end
	task.wait(timers.fireserver_generic_delay)

    if not scriptRunning then return end
    -- --- MODIFIED: Menggunakan timer Alur (1m) ---
	updateStatus("Menunggu " .. timers.wait_1m_before_forbidden .. "s sebelum Forbidden Zone...")
	waitSeconds(timers.wait_1m_before_forbidden)
	if not scriptRunning then return end

	updateStatus("Memasuki Forbidden Zone...")
	if not fireRemoteEnhanced_pcall("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.fireserver_generic_delay)

    if not scriptRunning then return end
	updateStatus("Comprehending (" .. timers.comprehend_duration .. "s)...")
	stopUpdateQiForComprehend = true -- Flag dari skrip asli Anda
	updateStatus("UpdateQi dihentikan untuk Comprehend.")
	
	local comprehendStartTime = tick() -- Variabel 'start' dari skrip asli Anda
	-- --- MODIFIED: Loop comprehend menggunakan timer dan task.wait ---
	while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
		if not fireRemoteEnhanced_pcall("Comprehend", "Base", {}) then
            updateStatus("Event Comprehend gagal.")
            break 
        end
        updateStatus(string.format("Comprehending... %d detik tersisa", math.floor(timers.comprehend_duration - (tick() - comprehendStartTime))))
		-- wait() asli dari skrip Anda diganti task.wait(1) agar lebih terkontrol
        task.wait(1) -- Panggil Comprehend setiap 1 detik, atau sesuaikan jika perlu
	end
    if not scriptRunning then return end
	updateStatus("Comprehend Selesai.")

    if not scriptRunning then return end
	updateStatus("Final UpdateQi (" .. timers.post_comprehend_qi_duration .. "s)...")
	stopUpdateQiForComprehend = false -- Flag dari skrip asli Anda
	updateStatus("UpdateQi dilanjutkan pasca Comprehend.")
	
    -- --- MODIFIED: Menggunakan timer dan membiarkan loop UpdateQi yang ada berjalan ---
	waitSeconds(timers.post_comprehend_qi_duration) 
    if not scriptRunning then return end
    
	-- Perilaku asli skrip Anda: stopUpdateQi = true di akhir.
    -- Ini berarti UpdateQi dihentikan sebelum siklus berikutnya dimulai.
	stopUpdateQiForComprehend = true 
    updateStatus("Fase Final UpdateQi selesai. UpdateQi dihentikan sementara.")

	updateStatus("Siklus Selesai - Akan Memulai Ulang...")
end


-- --- MODIFIED: Loop latar belakang dengan kontrol 'scriptRunning' dan flag lainnya ---
local function aptitudeMineLoop_controlled()
    -- Loop 'IncreaseAptitude' & 'Mine' dari skrip asli Anda
    updateStatus("Loop Aptitude/Mine dimulai.")
    while scriptRunning do -- --- MODIFIED: Menggunakan scriptRunning ---
        -- local args = {} -- Tidak perlu jika selalu kosong
        fireRemoteEnhanced_pcall("IncreaseAptitude", "Base", {})
        task.wait(timers.aptitude_mine_interval) -- Penundaan kecil
        if not scriptRunning then break end
        fireRemoteEnhanced_pcall("Mine", "Base", {})
        wait() -- wait() asli dari skrip Anda
    end
    print("Loop Aptitude/Mine dihentikan.")
end

local function updateQiLoop_controlled()
    -- Loop 'UpdateQi' dari skrip asli Anda
    updateStatus("Loop UpdateQi dimulai.")
    while scriptRunning do -- --- MODIFIED: Menggunakan scriptRunning ---
        -- --- ADDED: Memeriksa flag jeda dan stop ---
        if not stopUpdateQiForComprehend and not pauseUpdateQiTemporarily then
            -- local args = {} -- Tidak perlu jika selalu kosong
            fireRemoteEnhanced_pcall("UpdateQi", "Base", {})
        end
        task.wait(timers.update_qi_interval) -- wait(1) asli dari skrip Anda, diubah ke task.wait & timer
    end
    print("Loop UpdateQi dihentikan.")
end
-- --- END MODIFIED ---

-- // Jalankan saat tombol ditekan (Struktur Asli Dipertahankan, dengan modifikasi kontrol) //
-- --- MODIFIED: Logika Start/Stop yang lebih baik ---
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning -- Toggle state

    if scriptRunning then
        StartButton.Text = "Running..."
        StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        updateStatus("Memulai skrip...")

        -- Reset flag penting sebelum memulai loop
        stopUpdateQiForComprehend = false
        pauseUpdateQiTemporarily = false

        -- Mulai loop latar belakang jika belum ada atau sudah mati
        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then
            aptitudeMineThread = spawn(aptitudeMineLoop_controlled)
        end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
            updateQiThread = spawn(updateQiLoop_controlled)
        end

        -- Mulai siklus utama jika belum ada atau sudah mati
        -- Menggunakan spawn dari skrip asli Anda untuk siklus utama
        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = spawn(function()
                -- Menggunakan 'while scriptRunning do' bukan 'while true do' dari skrip asli Anda
                while scriptRunning do 
                    runCycle() 
                    if not scriptRunning then break end -- Keluar jika dihentikan di tengah
                    -- Status "Siklus Selesai - Akan Memulai Ulang..." sudah di akhir runCycle()
                    task.wait(1) -- Jeda singkat sebelum restart otomatis
                end
                -- Ini hanya akan tercapai jika scriptRunning menjadi false
                updateStatus("Skrip Dihentikan.")
                StartButton.Text = "Start Script" -- Reset tombol
                StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            end)
        end
    else
        updateStatus("Menghentikan skrip...")
        -- Flag 'scriptRunning = false' akan menghentikan semua loop.
        -- Tampilan tombol akan direset saat mainCycleThread selesai.
    end
end)
-- --- END MODIFIED ---

-- --- ADDED: Event Listener untuk Tombol Terapkan Timer ---
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false
        local value = tonumber(inputElement.Text)
        if value and value > 0 then
            timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor = Color3.fromRGB(0,200,0) end) end -- Hijau
            success = true
        else
            if labelElement then pcall(function() labelElement.TextColor = Color3.fromRGB(200,0,0) end) end -- Merah
        end
        return success
    end

    local allTimersValid = true
    allTimersValid = applyTextInput(timerElements.wait1m30sInput, "wait_1m30s_after_first_items", timerElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.wait40sInput, "wait_40s_hide_qi", timerElements.Wait40sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.wait1mInput, "wait_1m_before_forbidden", timerElements.Wait1mLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.comprehendInput, "comprehend_duration", timerElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.postComprehendQiInput, "post_comprehend_qi_duration", timerElements.PostComprehendQiLabel) and allTimersValid

    local originalStatus = StatusLabel.Text:gsub("Status: ", "")
    if allTimersValid then
        updateStatus("Semua timer berhasil diterapkan.")
    else
        updateStatus("Ada input timer tidak valid! Periksa angka (harus > 0).")
    end

    task.wait(2) -- Tampilkan status update timer sejenak
    -- Reset warna label
    pcall(function() timerElements.Wait1m30sLabel.TextColor = Color3.fromRGB(200,200,200) end)
    pcall(function() timerElements.Wait40sLabel.TextColor = Color3.fromRGB(200,200,200) end)
    pcall(function() timerElements.Wait1mLabel.TextColor = Color3.fromRGB(200,200,200) end)
    pcall(function() timerElements.ComprehendLabel.TextColor = Color3.fromRGB(200,200,200) end)
    pcall(function() timerElements.PostComprehendQiLabel.TextColor = Color3.fromRGB(200,200,200) end)
    updateStatus(originalStatus) -- Kembalikan status sebelumnya
end)
-- --- END ADDED ---

-- --- ADDED: BindToClose untuk pembersihan ---
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
-- --- END ADDED ---

StatusLabel.Text = "Status: Idle. Klik Start." -- Inisialisasi status
print("Skrip Otomatisasi (Versi Tambahan dengan UI Timer) Telah Dimuat.")
