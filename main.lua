--]

-- Layanan Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Variabel Global Skrip
local mainScriptActive = false
local mainAutomationThread = nil
local increaseAptitudeMineThread = nil
local updateQiThread = nil

local currentPhase = "Idle" -- Untuk umpan balik UI

-- Konfigurasi default dan dapat diubah oleh UI
local config = {
    timers = {
        reincarnateDelay = 0.5,
        buyItemDelay = 0.5,
        changeMapDelay = 1,
        chaoticRoadDelay = 0.5,
        hiddenRemoteDelay = 0.5,
        forbiddenZoneDelay = 0.5,

        wait_1m30s = 90, -- "tunggu 1 menit 30 detik" [1]
        wait_40s = 40,   -- "Tunggu 40 detik" [1]
        wait_1m = 60,    -- "Tunggu 1 menit" [1]

        comprehendDuration = 120, -- default 2 menit, dapat dikonfigurasi [1]
        postComprehendUpdateQiDuration = 120, -- default 2 menit, dapat dikonfigurasi [1]
        updateQiInterval = 1 -- default 1 detik untuk UpdateQi [1]
    },
    remoteEventPaths = {
        -- Menggunakan fungsi untuk WaitForChild agar lebih aman jika RemoteEvents folder belum ada saat skrip pertama kali dijalankan
        base = function() return ReplicatedStorage:WaitForChild("RemoteEvents", 9e9) end,
        areaEvents = function() return ReplicatedStorage:WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9) end
    }
}

-- Status untuk loop UpdateQi
local isUpdateQiGloballyActive = false -- Kontrol utama, false saat Comprehend
local isUpdateQiTemporarilyPaused = false -- True saat "UpdateQi di hidden" selama 40 detik

-- Elemen UI (akan diisi oleh fungsi createUI)
local uiElements = {}

-- Fungsi Utilitas untuk Remote Event
local function fireRemoteEvent(pathFunction, eventName,...)
    local argsToUnpack = {...} -- Kumpulkan semua argumen tambahan
    local success, err = pcall(function()
        local eventFolder = pathFunction()
        local remote = eventFolder:WaitForChild(eventName, 9e9)
        remote:FireServer(unpack(argsToUnpack)) -- Gunakan unpack di sini [1]
    end)
    if not success then
        print(string.format("Error firing RemoteEvent '%s': %s", eventName, tostring(err)))
        if uiElements and uiElements.StatusLabel then
            uiElements.StatusLabel.Text = string.format("Error: %s (%s)", eventName, tostring(err):sub(1, 50)) -- Batasi panjang pesan error di UI
        end
    else
        print(string.format("Fired RemoteEvent: %s with args: %s", eventName, table.concat(argsToUnpack, ", ")))
    end
    return success
end

-- Fungsi untuk memperbarui status di UI
local function updateStatus(newStatus)
    currentPhase = newStatus
    if uiElements and uiElements.StatusLabel then
        uiElements.StatusLabel.Text = "Status: ".. currentPhase
    end
    print("Current Phase: ".. currentPhase)
end

-- Loop untuk IncreaseAptitude dan Mine (berjalan secara independen) [1]
local function increaseAptitudeMineTask()
    print("IncreaseAptitude/Mine task started.")
    while mainScriptActive do
        fireRemoteEvent(config.remoteEventPaths.base, "IncreaseAptitude") -- args kosong
        task.wait(0.1) -- Penundaan kecil, jika diperlukan
        fireRemoteEvent(config.remoteEventPaths.base, "Mine") -- args kosong
        task.wait() -- Sesuai alur asli "wait()" [1]
    end
    print("IncreaseAptitude/Mine task stopped.")
end

-- Loop untuk UpdateQi (bersyarat) [1]
local function updateQiTask()
    print("UpdateQi task started.")
    while mainScriptActive do
        if isUpdateQiGloballyActive and not isUpdateQiTemporarilyPaused then
            fireRemoteEvent(config.remoteEventPaths.base, "UpdateQi") -- args kosong
        end
        task.wait(config.timers.updateQiInterval)
    end
    print("UpdateQi task stopped.")
end

-- Logika Otomatisasi Utama
local function mainAutomationLogic()
    updateStatus("Initializing...")

    while mainScriptActive do
        -- 1. Awali dengan menjalankan Reincarnate [1]
        updateStatus("Reincarnating...")
        if not fireRemoteEvent(config.remoteEventPaths.base, "Reincarnate") then if mainScriptActive then break end end
        task.wait(config.timers.reincarnateDelay)
        if not mainScriptActive then break end

        isUpdateQiGloballyActive = true -- Aktifkan UpdateQi setelah Reincarnate awal

        -- 2. Jalankan 4 pembelian item (cukup sekali setelah Reincarnate) [1]
        updateStatus("Buying initial items...")
        local itemsToBuy1 = {
            "Nine Heavens Galaxy Water",
            "Buzhou Divine Flower",
            "Fusang Divine Tree",
            "Calm Cultivation Mat"
        }
        for _, itemName in ipairs(itemsToBuy1) do
            if not mainScriptActive then break end
            updateStatus("Buying: ".. itemName)
            if not fireRemoteEvent(config.remoteEventPaths.base, "BuyItem", itemName) then if mainScriptActive then break end end
            task.wait(config.timers.buyItemDelay)
        end
        if not mainScriptActive then break end

        -- 3. Tunggu 1 menit 30 detik setelah updateqi berjalan, kemudian jalankan ChangeMap "immortal" [1]
        updateStatus(string.format("Waiting %ds (map change prep)...", config.timers.wait_1m30s))
        for i = config.timers.wait_1m30s, 1, -1 do
            if not mainScriptActive then break end
            updateStatus(string.format("Waiting for map change... %ds left", i))
            task.wait(1)
        end
        if not mainScriptActive then break end

        updateStatus("Changing map to 'immortal'...")
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChangeMap", "immortal") then if mainScriptActive then break end end
        task.wait(config.timers.changeMapDelay)
        if not mainScriptActive then break end

        -- 4. Lalu dilanjutkan dengan ChangeMap "chaos" [1]
        updateStatus("Changing map to 'chaos'...")
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChangeMap", "chaos") then if mainScriptActive then break end end
        task.wait(config.timers.changeMapDelay)
        if not mainScriptActive then break end

        -- 5. Kemudian ChaoticRoad [1]
        updateStatus("Entering Chaotic Road...")
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChaoticRoad") then if mainScriptActive then break end end
        task.wait(config.timers.chaoticRoadDelay)
        if not mainScriptActive then break end

        -- 6. Tunggu 40 detik, sembari menunggu UpdateQi di hidden (dijeda) [1]
        updateStatus(string.format("Waiting %ds (item purchase prep)...", config.timers.wait_40s))
        isUpdateQiTemporarilyPaused = true -- Jeda UpdateQi sementara
        for i = config.timers.wait_40s, 1, -1 do
            if not mainScriptActive then break end
            updateStatus(string.format("Waiting for item purchases... %ds left (UpdateQi Paused)", i))
            task.wait(1)
        end
        isUpdateQiTemporarilyPaused = false -- Lanjutkan UpdateQi
        if not mainScriptActive then break end

        -- Beli 3 item berikutnya [1]
        updateStatus("Buying second set of items...")
        local itemsToBuy2 = {
            "Traceless Breeze Lotus",
            "Reincarnation World Destruction Black Lotus",
            "Ten Thousand Bodhi Tree"
        }
        for _, itemName in ipairs(itemsToBuy2) do
            if not mainScriptActive then break end
            updateStatus("Buying: ".. itemName)
            if not fireRemoteEvent(config.remoteEventPaths.base, "BuyItem", itemName) then if mainScriptActive then break end end
            task.wait(config.timers.buyItemDelay)
        end
        if not mainScriptActive then break end

        -- 7. Jika sudah maka jalankan ChangeMap "immortal" lagi [1]
        updateStatus("Changing map back to 'immortal'...")
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChangeMap", "immortal") then if mainScriptActive then break end end
        task.wait(config.timers.changeMapDelay)
        if not mainScriptActive then break end

        -- 8. Lalu kemudian jalankan HiddenRemote sekali jika sedang UpdateQi [1]
        --    Alur: "jika Updateqi harus berada di hidden" - ini diinterpretasikan sebagai kondisi untuk *bisa* menjalankan UpdateQi,
        --    dan HiddenRemote dipanggil jika UpdateQi *sedang aktif* (isUpdateQiGloballyActive).
        if isUpdateQiGloballyActive then
            updateStatus("Firing HiddenRemote...")
            if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "HiddenRemote") then if mainScriptActive then break end end
            task.wait(config.timers.hiddenRemoteDelay)
        end
        if not mainScriptActive then break end

        -- 9. Tunggu 1 menit kemudian jalankan ForbiddenZone [1]
        updateStatus(string.format("Waiting %ds (Forbidden Zone prep)...", config.timers.wait_1m))
        for i = config.timers.wait_1m, 1, -1 do
            if not mainScriptActive then break end
            updateStatus(string.format("Waiting for Forbidden Zone... %ds left", i))
            task.wait(1)
        end
        if not mainScriptActive then break end

        updateStatus("Entering Forbidden Zone...")
        -- Alur: "jika melakukan comprehend harus berada di Forbidden" - ini dicapai dengan memanggil ForbiddenZone [1]
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ForbiddenZone") then if mainScriptActive then break end end
        task.wait(config.timers.forbiddenZoneDelay)
        if not mainScriptActive then break end
        
        -- 10. Lalu Comprehend jalankan selama X menit (dapat dikonfigurasi, default 2 menit) [1]
        --     Selama Comprehend, UpdateQi dihentikan.
        updateStatus(string.format("Starting Comprehend for %ds...", config.timers.comprehendDuration))
        isUpdateQiGloballyActive = false -- Hentikan UpdateQi
        local comprehendStartTime = tick()
        while tick() - comprehendStartTime < config.timers.comprehendDuration do
            if not mainScriptActive then break end
            if not fireRemoteEvent(config.remoteEventPaths.base, "Comprehend") then
                updateStatus("Comprehend event failed. Skipping phase.")
                break 
            end
            updateStatus(string.format("Comprehending... %ds left", math.floor(config.timers.comprehendDuration - (tick() - comprehendStartTime))))
            task.wait(1) -- Panggil Comprehend setiap detik
        end
        if not mainScriptActive then break end
        updateStatus("Comprehend finished.")

        -- 11. Setelah Comprehend, lanjutkan dengan UpdateQi selama Y menit (dapat dikonfigurasi, default 2 menit) [1]
        --     Alur: "jika Updateqi harus berada di hidden" - kita asumsikan pemain sudah di 'hidden' atau server menanganinya.
        --     Skrip ini tidak secara eksplisit kembali ke map "hidden" di sini kecuali jika HiddenRemote sebelumnya sudah cukup.
        updateStatus(string.format("Starting Post-Comprehend UpdateQi for %ds...", config.timers.postComprehendUpdateQiDuration))
        isUpdateQiGloballyActive = true -- Aktifkan kembali UpdateQi
        local postComprehendUpdateQiStartTime = tick()
        while tick() - postComprehendUpdateQiStartTime < config.timers.postComprehendUpdateQiDuration do
            if not mainScriptActive then break end
            updateStatus(string.format("Post-Comprehend UpdateQi... %ds left", math.floor(config.timers.postComprehendUpdateQiDuration - (tick() - postComprehendUpdateQiStartTime))))
            task.wait(1)
        end
        if not mainScriptActive then break end
        updateStatus("Post-Comprehend UpdateQi finished.")

        -- Selesai satu siklus, akan mulai lagi dari Reincarnate karena loop while utama [1]
        updateStatus("Cycle complete. Restarting...")
        task.wait(1) -- Penundaan singkat sebelum restart
    end

    -- Jika loop utama berhenti (mainScriptActive menjadi false atau break)
    isUpdateQiGloballyActive = false -- Pastikan UpdateQi berhenti
    isUpdateQiTemporarilyPaused = false
    updateStatus("Automation stopped.")
    print("Main automation logic stopped.")
end


-- Fungsi untuk membuat UI
local function createUI()
    if uiElements.MainScreenGui and uiElements.MainScreenGui.Parent then
        uiElements.MainScreenGui:Destroy()
        uiElements = {} -- Reset tabel elemen UI
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutomationMainScreenGui"
    screenGui.ResetOnSpawn = false -- Agar tidak hilang saat respawn
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    uiElements.MainScreenGui = screenGui

    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlFrame"
    controlFrame.Size = UDim2.new(0, 320, 0, 250) -- Ukuran disesuaikan agar muat
    controlFrame.Position = UDim2.new(0.02, 0, 0.1, 0) -- Posisi di kiri atas
    controlFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    controlFrame.BorderColor3 = Color3.fromRGB(10, 10, 10)
    controlFrame.BorderSizePixel = 2
    controlFrame.Active = true
    controlFrame.Draggable = true
    controlFrame.Parent = screenGui
    uiElements.ControlFrame = controlFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.Text = "Kontrol Skrip Otomatisasi"
    titleLabel.Font = Enum.Font.SourceSansSemibold
    titleLabel.TextSize = 18
    titleLabel.Parent = controlFrame
    uiElements.TitleLabel = titleLabel

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 40) -- Lebih tinggi untuk teks panjang
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
    statusLabel.Text = "Status: Idle"
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextSize = 14
    statusLabel.TextWrapped = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Parent = controlFrame
    uiElements.StatusLabel = statusLabel

    local startStopButton = Instance.new("TextButton")
    startStopButton.Name = "StartStopButton"
    startStopButton.Size = UDim2.new(1, -20, 0, 35)
    startStopButton.Position = UDim2.new(0, 10, 0, 90)
    startStopButton.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    startStopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startStopButton.Text = "Mulai Skrip"
    startStopButton.Font = Enum.Font.SourceSansBold
    startStopButton.TextSize = 16
    startStopButton.Parent = controlFrame
    uiElements.StartStopButton = startStopButton

    -- Frame untuk konfigurasi timer
    local timerConfigFrame = Instance.new("Frame")
    timerConfigFrame.Name = "TimerConfigFrame"
    timerConfigFrame.Size = UDim2.new(1, -20, 0, 100)
    timerConfigFrame.Position = UDim2.new(0, 10, 0, 140)
    timerConfigFrame.BackgroundTransparency = 1
    timerConfigFrame.Parent = controlFrame
    uiElements.TimerConfigFrame = timerConfigFrame

    local comprehendLabel = Instance.new("TextLabel")
    comprehendLabel.Size = UDim2.new(0.6, -5, 0, 20)
    comprehendLabel.Position = UDim2.new(0, 0, 0, 5)
    comprehendLabel.BackgroundTransparency = 1
    comprehendLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    comprehendLabel.Text = "Durasi Comprehend (s):"
    comprehendLabel.Font = Enum.Font.SourceSans
    comprehendLabel.TextSize = 14
    comprehendLabel.TextXAlignment = Enum.TextXAlignment.Left
    comprehendLabel.Parent = timerConfigFrame

    local comprehendInput = Instance.new("TextBox")
    comprehendInput.Name = "ComprehendTimerInput"
    comprehendInput.Size = UDim2.new(0.4, -5, 0, 20)
    comprehendInput.Position = UDim2.new(0.6, 5, 0, 5)
    comprehendInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    comprehendInput.BorderColor3 = Color3.fromRGB(80,80,80)
    comprehendInput.TextColor3 = Color3.fromRGB(220, 220, 220)
    comprehendInput.Text = tostring(config.timers.comprehendDuration)
    comprehendInput.Font = Enum.Font.SourceSans
    comprehendInput.TextSize = 14
    comprehendInput.ClearTextOnFocus = false
    comprehendInput.Parent = timerConfigFrame
    uiElements.ComprehendTimerInput = comprehendInput

    local updateQiPostLabel = Instance.new("TextLabel")
    updateQiPostLabel.Size = UDim2.new(0.6, -5, 0, 20)
    updateQiPostLabel.Position = UDim2.new(0, 0, 0, 30)
    updateQiPostLabel.BackgroundTransparency = 1
    updateQiPostLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateQiPostLabel.Text = "Durasi Post-Comp Qi (s):"
    updateQiPostLabel.Font = Enum.Font.SourceSans
    updateQiPostLabel.TextSize = 14
    updateQiPostLabel.TextXAlignment = Enum.TextXAlignment.Left
    updateQiPostLabel.Parent = timerConfigFrame

    local updateQiPostInput = Instance.new("TextBox")
    updateQiPostInput.Name = "UpdateQiTimerInput"
    updateQiPostInput.Size = UDim2.new(0.4, -5, 0, 20)
    updateQiPostInput.Position = UDim2.new(0.6, 5, 0, 30)
    updateQiPostInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    updateQiPostInput.BorderColor3 = Color3.fromRGB(80,80,80)
    updateQiPostInput.TextColor3 = Color3.fromRGB(220, 220, 220)
    updateQiPostInput.Text = tostring(config.timers.postComprehendUpdateQiDuration)
    updateQiPostInput.Font = Enum.Font.SourceSans
    updateQiPostInput.TextSize = 14
    updateQiPostInput.ClearTextOnFocus = false
    updateQiPostInput.Parent = timerConfigFrame
    uiElements.UpdateQiTimerInput = updateQiPostInput

    local applyTimersButton = Instance.new("TextButton")
    applyTimersButton.Name = "ApplyTimersButton"
    applyTimersButton.Size = UDim2.new(1, 0, 0, 30)
    applyTimersButton.Position = UDim2.new(0, 0, 0, 60) -- Di bawah input
    applyTimersButton.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    applyTimersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyTimersButton.Text = "Terapkan Timer"
    applyTimersButton.Font = Enum.Font.SourceSansBold
    applyTimersButton.TextSize = 15
    applyTimersButton.Parent = timerConfigFrame
    uiElements.ApplyTimersButton = applyTimersButton

    -- Event Listeners untuk UI
    startStopButton.MouseButton1Click:Connect(function()
        mainScriptActive = not mainScriptActive
        if mainScriptActive then
            startStopButton.Text = "Hentikan Skrip"
            startStopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            updateStatus("Starting...")

            -- Mulai thread utama jika belum ada atau sudah selesai
            if not mainAutomationThread or coroutine.status(mainAutomationThread) == "dead" then
                 mainAutomationThread = task.spawn(mainAutomationLogic) -- Menggunakan task.spawn
            end
            -- Mulai thread latar belakang
            if not increaseAptitudeMineThread or coroutine.status(increaseAptitudeMineThread) == "dead" then
                increaseAptitudeMineThread = task.spawn(increaseAptitudeMineTask)
            end
            if not updateQiThread or coroutine.status(updateQiThread) == "dead" then
                updateQiThread = task.spawn(updateQiTask)
            end
        else
            startStopButton.Text = "Mulai Skrip"
            startStopButton.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
            updateStatus("Stopping...")
            -- Flag mainScriptActive akan menghentikan loop di dalam thread secara alami.
            -- Tidak perlu menghentikan thread secara paksa jika mereka memeriksa mainScriptActive.
        end
    end)

    applyTimersButton.MouseButton1Click:Connect(function()
        local newComprehendTime = tonumber(comprehendInput.Text)
        local newUpdateQiTime = tonumber(updateQiPostInput.Text)
        local validInputs = true

        if newComprehendTime and newComprehendTime > 0 then
            config.timers.comprehendDuration = newComprehendTime
            comprehendInput.BorderColor3 = Color3.fromRGB(0,180,0) -- Hijau untuk valid
        else
            comprehendInput.BorderColor3 = Color3.fromRGB(180,0,0) -- Merah untuk tidak valid
            validInputs = false
        end

        if newUpdateQiTime and newUpdateQiTime > 0 then
            config.timers.postComprehendUpdateQiDuration = newUpdateQiTime
            updateQiPostInput.BorderColor3 = Color3.fromRGB(0,180,0)
        else
            updateQiPostInput.BorderColor3 = Color3.fromRGB(180,0,0)
            validInputs = false
        end

        if validInputs then
            updateStatus("Timer berhasil diperbarui.")
            task.wait(1.5) -- Tampilkan status update sebentar
            comprehendInput.BorderColor3 = Color3.fromRGB(80,80,80) -- Reset border
            updateQiPostInput.BorderColor3 = Color3.fromRGB(80,80,80)
            updateStatus(currentPhase) -- Kembali ke status sebelumnya
        else
            updateStatus("Input timer tidak valid! Harap masukkan angka positif.")
        end
    end)

    -- Tentukan parent terakhir untuk ScreenGui
    -- Menggunakan CoreGui seperti pada referensi untuk kompatibilitas eksekutor
    screenGui.Parent = CoreGui

    print("UI Created and parented to CoreGui.")
end

-- Inisialisasi UI saat skrip dimuat
if RunService:IsClient() then -- Pastikan hanya berjalan di klien
    createUI()
    updateStatus("Idle. Klik 'Mulai Skrip'.")
else
    warn("Skrip ini dirancang untuk sisi klien (LocalScript) dan tidak akan membuat UI di server.")
end


-- Pastikan skrip tidak berjalan ganda jika dimuat ulang oleh eksekutor
if _G.AutomationScriptLoaded_F7E8C1A0 then -- ID unik untuk mencegah konflik
    warn("Skrip otomatisasi tampaknya sudah dimuat. Instance ini tidak akan berjalan untuk menghindari duplikasi.")
    return -- Hentikan eksekusi instance ini
end
_G.AutomationScriptLoaded_F7E8C1A0 = true

-- Membersihkan saat skrip dihentikan (jika eksekutor mendukungnya atau jika game ditutup)
game:BindToClose(function()
    if mainScriptActive then
        print("Game closing, stopping automation script...")
        mainScriptActive = false -- Ini akan menghentikan loop di thread
        -- Beri waktu sedikit untuk thread berhenti secara alami
        task.wait(0.5)
    end
    if uiElements.MainScreenGui and uiElements.MainScreenGui.Parent then
        uiElements.MainScreenGui:Destroy()
    end
    _G.AutomationScriptLoaded_F7E8C1A0 = false -- Izinkan pemuatan ulang di sesi berikutnya
    print("Automation script cleaned up.")
end)

print("Skrip Otomatisasi Roblox Telah Dimuat.")
