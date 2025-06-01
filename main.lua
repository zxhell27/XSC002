local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui") -- Digunakan jika menargetkan CoreGui untuk UI

-- Variabel Global Skrip
local mainScriptActive = false
local scriptCoroutine = nil -- Untuk menampung coroutine utama
local increaseAptitudeMineCoroutine = nil
local updateQiCoroutine = nil

local currentPhase = "Idle" -- Untuk umpan balik UI

-- Konfigurasi default dan dapat diubah oleh UI
local config = {
    timers = {
        reincarnateDelay = 0.5, -- Penundaan kecil setelah reinkarnasi
        buyItemDelay = 0.5, -- Penundaan antar pembelian item
        changeMapDelay = 1, -- Penundaan setelah ganti peta
        chaoticRoadDelay = 0.5, -- Penundaan setelah chaotic road
        hiddenRemoteDelay = 0.5, -- Penundaan setelah hidden remote
        forbiddenZoneDelay = 0.5, -- Penundaan setelah forbidden zone

        wait_1m30s = 90, -- "tunggu 1 menit 30 detik"
        wait_40s = 40, -- "Tunggu 40 detik"
        wait_1m = 60, -- "Tunggu 1 menit"

        comprehendDuration = 120, -- default 2 menit
        postComprehendUpdateQiDuration = 120, -- default 2 menit
        updateQiInterval = 1 -- default 1 detik untuk UpdateQi
    },
    remoteEventPaths = {
        base = function() return ReplicatedStorage:WaitForChild("RemoteEvents", 9e9) end,
        areaEvents = function() return ReplicatedStorage:WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9) end
    }
}

-- Status untuk loop UpdateQi
local updateQiEnabled = false -- Dikontrol oleh logika utama
local updateQiGloballyPaused = false -- Untuk jeda sementara seperti saat menunggu 40 detik

-- UI Elements (akan diisi oleh fungsi createUI)
local uiElements = {}

-- Fungsi Utilitas untuk Remote Event
local function fireRemoteEvent(pathFunction, eventName,...)
    local args = {...}
    local success, err = pcall(function()
        local eventFolder = pathFunction()
        local remote = eventFolder:WaitForChild(eventName, 9e9)
        remote:FireServer(unpack(args))
    end)
    if not success then
        print(string.format("Error firing RemoteEvent '%s': %s", eventName, tostring(err)))
        uiElements.StatusLabel.Text = string.format("Error: %s (%s)", eventName, tostring(err))
        -- Pertimbangkan untuk menghentikan skrip utama jika ini adalah event kritis
        if eventName == "Reincarnate" then -- Contoh event kritis
            -- error("Critical event failed: ".. eventName) -- Dapat menghentikan skrip jika tidak ditangani
        end
    else
        print(string.format("Fired RemoteEvent: %s", eventName))
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

-- Loop untuk IncreaseAptitude dan Mine (berjalan secara independen)
local function increaseAptitudeMineTask()
    while mainScriptActive do
        local emptyArgs = {}
        fireRemoteEvent(config.remoteEventPaths.base, "IncreaseAptitude", unpack(emptyArgs))
        task.wait(0.1) -- Penundaan kecil antara aptitude dan mine
        fireRemoteEvent(config.remoteEventPaths.base, "Mine", unpack(emptyArgs))
        task.wait() -- Yield default, sesuai alur asli "wait()"
    end
    print("IncreaseAptitude/Mine task stopped.")
end

-- Loop untuk UpdateQi (bersyarat)
local function updateQiTask()
    while mainScriptActive do
        if updateQiEnabled and not updateQiGloballyPaused then
            local emptyArgs = {}
            fireRemoteEvent(config.remoteEventPaths.base, "UpdateQi", unpack(emptyArgs))
        end
        task.wait(config.timers.updateQiInterval)
    end
    print("UpdateQi task stopped.")
end

-- Logika Otomatisasi Utama
local function mainAutomationLogic()
    updateStatus("Initializing...")

    while mainScriptActive do
        -- 1. Awali dengan menjalankan Reincarnate
        updateStatus("Reincarnating...")
        local reincarnateArgs = {}
        if not fireRemoteEvent(config.remoteEventPaths.base, "Reincarnate", unpack(reincarnateArgs)) then break end
        task.wait(config.timers.reincarnateDelay)

        -- Setelah Reincarnate, UpdateQi mulai berjalan (jika belum)
        updateQiEnabled = true -- Aktifkan UpdateQi setelah Reincarnate awal

        -- 2. Jalankan 4 pembelian item (cukup sekali setelah Reincarnate)
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
            local buyArgs = { = itemName}
            if not fireRemoteEvent(config.remoteEventPaths.base, "BuyItem", unpack(buyArgs)) then break end
            task.wait(config.timers.buyItemDelay)
        end
        if not mainScriptActive then break end

        -- 3. Tunggu 1 menit 30 detik setelah updateqi berjalan, kemudian jalankan ChangeMap "immortal"
        updateStatus(string.format("Waiting for %d seconds (map change prep)...", config.timers.wait_1m30s))
        for i = config.timers.wait_1m30s, 1, -1 do
            if not mainScriptActive then break end
            updateStatus(string.format("Waiting for map change... %ds left", i))
            task.wait(1)
        end
        if not mainScriptActive then break end

        updateStatus("Changing map to 'immortal'...")
        local changeMapImmortalArgs = { = "immortal"}
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChangeMap", unpack(changeMapImmortalArgs)) then break end
        task.wait(config.timers.changeMapDelay)

        -- 4. Lalu dilanjutkan dengan ChangeMap "chaos"
        updateStatus("Changing map to 'chaos'...")
        local changeMapChaosArgs = { = "chaos"}
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChangeMap", unpack(changeMapChaosArgs)) then break end
        task.wait(config.timers.changeMapDelay)

        -- 5. Kemudian ChaoticRoad
        updateStatus("Entering Chaotic Road...")
        local chaoticRoadArgs = {}
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChaoticRoad", unpack(chaoticRoadArgs)) then break end
        task.wait(config.timers.chaoticRoadDelay)

        -- 6. Tunggu 40 detik, sembari menunggu UpdateQi di hidden (dijeda)
        updateStatus(string.format("Waiting for %d seconds (item purchase prep)...", config.timers.wait_40s))
        updateQiGloballyPaused = true -- Jeda UpdateQi sementara
        for i = config.timers.wait_40s, 1, -1 do
            if not mainScriptActive then break end
            updateStatus(string.format("Waiting for item purchases... %ds left (UpdateQi Paused)", i))
            task.wait(1)
        end
        updateQiGloballyPaused = false -- Lanjutkan UpdateQi
        if not mainScriptActive then break end

        -- Beli 3 item berikutnya
        updateStatus("Buying second set of items...")
        local itemsToBuy2 = {
            "Traceless Breeze Lotus",
            "Reincarnation World Destruction Black Lotus",
            "Ten Thousand Bodhi Tree"
        }
        for _, itemName in ipairs(itemsToBuy2) do
            if not mainScriptActive then break end
            updateStatus("Buying: ".. itemName)
            local buyArgs = { = itemName}
            if not fireRemoteEvent(config.remoteEventPaths.base, "BuyItem", unpack(buyArgs)) then break end
            task.wait(config.timers.buyItemDelay)
        end
        if not mainScriptActive then break end

        -- 7. Jika sudah maka jalankan ChangeMap "immortal" lagi
        updateStatus("Changing map back to 'immortal'...")
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ChangeMap", unpack(changeMapImmortalArgs)) then break end -- Gunakan args immortal yg sama
        task.wait(config.timers.changeMapDelay)

        -- 8. Lalu kemudian jalankan HiddenRemote sekali jika sedang UpdateQi
        --    Asumsi: "jika sedang UpdateQi" berarti updateQiEnabled adalah true.
        --    Alur juga mensyaratkan "jika Updateqi harus berada di hidden". Ini berarti kita harus di map/state "hidden".
        --    Pemanggilan ChangeMap ke "immortal" sebelumnya mungkin adalah persiapan untuk ini.
        if updateQiEnabled then
            updateStatus("Firing HiddenRemote...")
            local hiddenRemoteArgs = {}
            if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "HiddenRemote", unpack(hiddenRemoteArgs)) then break end
            task.wait(config.timers.hiddenRemoteDelay)
        end
        if not mainScriptActive then break end

        -- 9. Tunggu 1 menit kemudian jalankan ForbiddenZone
        updateStatus(string.format("Waiting for %d seconds (Forbidden Zone prep)...", config.timers.wait_1m))
        for i = config.timers.wait_1m, 1, -1 do
            if not mainScriptActive then break end
            updateStatus(string.format("Waiting for Forbidden Zone... %ds left", i))
            task.wait(1)
        end
        if not mainScriptActive then break end

        updateStatus("Entering Forbidden Zone...")
        local forbiddenZoneArgs = {} -- Tidak ada argumen yang ditentukan
        if not fireRemoteEvent(config.remoteEventPaths.areaEvents, "ForbiddenZone", unpack(forbiddenZoneArgs)) then break end
        task.wait(config.timers.forbiddenZoneDelay)

        -- 10. Lalu Comprehend jalankan selama X menit (dapat dikonfigurasi, default 2 menit)
        --     Selama Comprehend, UpdateQi dihentikan.
        --     "jika melakukan comprehend harus berada di Forbidden" - sudah dipastikan dengan ForbiddenZone
        updateStatus(string.format("Starting Comprehend for %d seconds...", config.timers.comprehendDuration))
        updateQiEnabled = false -- Hentikan UpdateQi
        local comprehendArgs = {}
        local comprehendStartTime = tick()
        while tick() - comprehendStartTime < config.timers.comprehendDuration do
            if not mainScriptActive then break end
            -- Terus menerus memanggil Comprehend selama durasi
            if not fireRemoteEvent(config.remoteEventPaths.base, "Comprehend", unpack(comprehendArgs)) then
                -- Jika Comprehend gagal, mungkin lebih baik keluar dari loop Comprehend
                updateStatus("Comprehend event failed. Skipping Comprehend phase.")
                break
            end
            updateStatus(string.format("Comprehending... %ds left", math.floor(config.timers.comprehendDuration - (tick() - comprehendStartTime))))
            task.wait(1) -- Panggil Comprehend setiap detik, atau sesuaikan jika perlu
        end
        if not mainScriptActive then break end
        updateStatus("Comprehend finished.")

        -- 11. Setelah Comprehend, lanjutkan dengan UpdateQi selama Y menit (dapat dikonfigurasi, default 2 menit)
        --     "jika Updateqi harus berada di hidden" - mungkin perlu kembali ke map "hidden" jika ForbiddenZone mengubahnya.
        --     Namun, alur tidak secara eksplisit menyebutkan ChangeMap lagi di sini.
        --     Kita akan mengasumsikan bahwa kita bisa langsung menjalankan UpdateQi.
        updateStatus(string.format("Starting Post-Comprehend UpdateQi for %d seconds...", config.timers.postComprehendUpdateQiDuration))
        updateQiEnabled = true -- Aktifkan kembali UpdateQi
        local postComprehendUpdateQiStartTime = tick()
        while tick() - postComprehendUpdateQiStartTime < config.timers.postComprehendUpdateQiDuration do
            if not mainScriptActive then break end
            -- UpdateQi akan berjalan melalui loop updateQiTask sendiri
            updateStatus(string.format("Post-Comprehend UpdateQi... %ds left", math.floor(config.timers.postComprehendUpdateQiDuration - (tick() - postComprehendUpdateQiStartTime))))
            task.wait(1)
        end
        if not mainScriptActive then break end
        updateStatus("Post-Comprehend UpdateQi finished.")

        -- Selesai satu siklus, akan mulai lagi dari Reincarnate karena loop while utama
        updateStatus("Cycle complete. Restarting...")
        task.wait(1) -- Penundaan singkat sebelum restart
    end

    -- Jika loop utama berhenti (mainScriptActive menjadi false)
    updateQiEnabled = false -- Pastikan UpdateQi berhenti
    updateStatus("Automation stopped.")
    print("Main automation logic stopped.")
end


-- Fungsi untuk membuat UI
local function createUI()
    if uiElements.MainScreenGui and uiElements.MainScreenGui.Parent then
        uiElements.MainScreenGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutomationMainScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    uiElements.MainScreenGui = screenGui

    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlFrame"
    controlFrame.Size = UDim2.new(0, 300, 0, 220) -- Ukuran disesuaikan
    controlFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
    controlFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    controlFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
    controlFrame.BorderSizePixel = 2
    controlFrame.Active = true -- Untuk bisa digeser
    controlFrame.Draggable = true
    controlFrame.Parent = screenGui
    uiElements.ControlFrame = controlFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.Text = "Kontrol Otomatisasi"
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.Parent = controlFrame
    uiElements.TitleLabel = titleLabel

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Text = "Status: Idle"
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = controlFrame
    uiElements.StatusLabel = statusLabel

    local startStopButton = Instance.new("TextButton")
    startStopButton.Name = "StartStopButton"
    startStopButton.Size = UDim2.new(0, 100, 0, 30)
    startStopButton.Position = UDim2.new(0.5, -50, 0, 70)
    startStopButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startStopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startStopButton.Text = "Mulai"
    startStopButton.Font = Enum.Font.SourceSansBold
    startStopButton.TextSize = 16
    startStopButton.Parent = controlFrame
    uiElements.StartStopButton = startStopButton

    -- Frame untuk konfigurasi timer
    local timerConfigFrame = Instance.new("Frame")
    timerConfigFrame.Name = "TimerConfigFrame"
    timerConfigFrame.Size = UDim2.new(1, -20, 0, 100)
    timerConfigFrame.Position = UDim2.new(0, 10, 0, 110)
    timerConfigFrame.BackgroundTransparency = 1
    timerConfigFrame.Parent = controlFrame
    uiElements.TimerConfigFrame = timerConfigFrame

    local comprehendLabel = Instance.new("TextLabel")
    comprehendLabel.Size = UDim2.new(0.5, -5, 0, 20)
    comprehendLabel.Position = UDim2.new(0, 0, 0, 0)
    comprehendLabel.BackgroundTransparency = 1
    comprehendLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    comprehendLabel.Text = "Comprehend (s):"
    comprehendLabel.Font = Enum.Font.SourceSans
    comprehendLabel.TextSize = 14
    comprehendLabel.TextXAlignment = Enum.TextXAlignment.Left
    comprehendLabel.Parent = timerConfigFrame

    local comprehendInput = Instance.new("TextBox")
    comprehendInput.Name = "ComprehendTimerInput"
    comprehendInput.Size = UDim2.new(0.5, -5, 0, 20)
    comprehendInput.Position = UDim2.new(0.5, 5, 0, 0)
    comprehendInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    comprehendInput.TextColor3 = Color3.fromRGB(220, 220, 220)
    comprehendInput.Text = tostring(config.timers.comprehendDuration)
    comprehendInput.Font = Enum.Font.SourceSans
    comprehendInput.TextSize = 14
    comprehendInput.ClearTextOnFocus = false
    comprehendInput.Parent = timerConfigFrame
    uiElements.ComprehendTimerInput = comprehendInput

    local updateQiPostLabel = Instance.new("TextLabel")
    updateQiPostLabel.Size = UDim2.new(0.5, -5, 0, 20)
    updateQiPostLabel.Position = UDim2.new(0, 0, 0, 25)
    updateQiPostLabel.BackgroundTransparency = 1
    updateQiPostLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateQiPostLabel.Text = "Post-Comp Qi (s):"
    updateQiPostLabel.Font = Enum.Font.SourceSans
    updateQiPostLabel.TextSize = 14
    updateQiPostLabel.TextXAlignment = Enum.TextXAlignment.Left
    updateQiPostLabel.Parent = timerConfigFrame

    local updateQiPostInput = Instance.new("TextBox")
    updateQiPostInput.Name = "UpdateQiTimerInput"
    updateQiPostInput.Size = UDim2.new(0.5, -5, 0, 20)
    updateQiPostInput.Position = UDim2.new(0.5, 5, 0, 25)
    updateQiPostInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    updateQiPostInput.TextColor3 = Color3.fromRGB(220, 220, 220)
    updateQiPostInput.Text = tostring(config.timers.postComprehendUpdateQiDuration)
    updateQiPostInput.Font = Enum.Font.SourceSans
    updateQiPostInput.TextSize = 14
    updateQiPostInput.ClearTextOnFocus = false
    updateQiPostInput.Parent = timerConfigFrame
    uiElements.UpdateQiTimerInput = updateQiPostInput

    local applyTimersButton = Instance.new("TextButton")
    applyTimersButton.Name = "ApplyTimersButton"
    applyTimersButton.Size = UDim2.new(1, 0, 0, 25)
    applyTimersButton.Position = UDim2.new(0, 0, 0, 55)
    applyTimersButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    applyTimersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyTimersButton.Text = "Terapkan Timer"
    applyTimersButton.Font = Enum.Font.SourceSansBold
    applyTimersButton.TextSize = 14
    applyTimersButton.Parent = timerConfigFrame
    uiElements.ApplyTimersButton = applyTimersButton

    -- Event Listeners untuk UI
    startStopButton.MouseButton1Click:Connect(function()
        mainScriptActive = not mainScriptActive
        if mainScriptActive then
            startStopButton.Text = "Berhenti"
            startStopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            updateStatus("Starting...")

            -- Mulai coroutine utama jika belum ada atau sudah selesai
            if not scriptCoroutine or coroutine.status(scriptCoroutine) == "dead" then
                scriptCoroutine = coroutine.create(mainAutomationLogic)
                coroutine.resume(scriptCoroutine)
            end
            -- Mulai coroutine latar belakang
            if not increaseAptitudeMineCoroutine or coroutine.status(increaseAptitudeMineCoroutine) == "dead" then
                increaseAptitudeMineCoroutine = task.spawn(increaseAptitudeMineTask)
            end
            if not updateQiCoroutine or coroutine.status(updateQiCoroutine) == "dead" then
                updateQiCoroutine = task.spawn(updateQiTask)
            end
        else
            startStopButton.Text = "Mulai"
            startStopButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            updateStatus("Stopping...")
            -- Logika untuk menghentikan coroutine akan ditangani oleh flag mainScriptActive di dalam loop mereka
            -- Tidak perlu secara eksplisit menghentikan coroutine di sini jika mereka memeriksa mainScriptActive
        end
    end)

    applyTimersButton.MouseButton1Click:Connect(function()
        local newComprehendTime = tonumber(comprehendInput.Text)
        local newUpdateQiTime = tonumber(updateQiPostInput.Text)
        local valid = true

        if newComprehendTime and newComprehendTime > 0 then
            config.timers.comprehendDuration = newComprehendTime
            comprehendInput.BorderColor3 = Color3.fromRGB(0,255,0) -- Hijau untuk valid
        else
            comprehendInput.BorderColor3 = Color3.fromRGB(255,0,0) -- Merah untuk tidak valid
            valid = false
        end

        if newUpdateQiTime and newUpdateQiTime > 0 then
            config.timers.postComprehendUpdateQiDuration = newUpdateQiTime
            updateQiPostInput.BorderColor3 = Color3.fromRGB(0,255,0)
        else
            updateQiPostInput.BorderColor3 = Color3.fromRGB(255,0,0)
            valid = false
        end

        if valid then
            updateStatus("Timer diperbarui.")
            task.wait(1) -- Tampilkan status update sebentar
            comprehendInput.BorderColor3 = Color3.fromRGB(20,20,20) -- Reset border
            updateQiPostInput.BorderColor3 = Color3.fromRGB(20,20,20)
            updateStatus(currentPhase) -- Kembali ke status sebelumnya
        else
            updateStatus("Input timer tidak valid!")
        end
    end)

    -- Tentukan parent terakhir untuk ScreenGui
    -- Biasanya PlayerGui, tapi untuk eksekutor bisa CoreGui jika diizinkan
    local player = Players.LocalPlayer
    if player and player:FindFirstChild("PlayerGui") then
        screenGui.Parent = player.PlayerGui
    else
        screenGui.Parent = CoreGui -- Fallback jika PlayerGui tidak tersedia segera
    end

    print("UI Created.")
end

-- Inisialisasi UI saat skrip dimuat
createUI()
updateStatus("Idle. Klik 'Mulai'.")

-- Pastikan skrip tidak berjalan ganda jika dimuat ulang oleh eksekutor
if _G.AutomationScriptLoaded then
    print("Automation script already loaded. Halting previous instance if possible.")
    -- Tambahkan logika untuk menghentikan instance sebelumnya jika diperlukan dan memungkinkan
    -- Ini bisa kompleks dan tergantung pada bagaimana eksekutor menangani pemuatan ulang
    return
end
_G.AutomationScriptLoaded = true

-- Membersihkan saat skrip dihentikan (jika eksekutor mendukungnya atau jika game ditutup)
game:BindToClose(function()
    if mainScriptActive then
        print("Game closing, stopping automation script...")
        mainScriptActive = false
        -- Beri waktu sedikit untuk coroutine berhenti
        task.wait(0.5)
    end
    if uiElements.MainScreenGui and uiElements.MainScreenGui.Parent then
        uiElements.MainScreenGui:Destroy()
    end
    _G.AutomationScriptLoaded = false -- Izinkan pemuatan ulang di sesi berikutnya
    print("Automation script cleaned up.")
end)
