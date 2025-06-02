--[[
    ZXHELL UI Script - Arceus X Compatibility Fix Attempt v2
    Fokus: Memperbaiki animasi dan respons tombol.
]]

-- Beri sedikit jeda, terkadang membantu di beberapa eksekutor
task.wait(0.8) -- Sedikit lebih lama dari sebelumnya

print("ZXHELL UI Script (Fix v2): Memulai...")

-- Pastikan game sudah dimuat sepenuhnya
if not game:IsLoaded() then
    print("ZXHELL UI Script (Fix v2): Menunggu game dimuat...")
    game.Loaded:Wait()
end
print("ZXHELL UI Script (Fix v2): Game telah dimuat.")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("ZXHELL UI Script (Fix v2): LocalPlayer tidak ditemukan. Skrip tidak akan berjalan.")
    return 
end
print("ZXHELL UI Script (Fix v2): LocalPlayer ditemukan: " .. LocalPlayer.Name)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15) -- Timeout untuk PlayerGui

if not PlayerGui then
    warn("ZXHELL UI Script (Fix v2): PlayerGui tidak ditemukan setelah 15 detik. UI mungkin tidak tampil.")
    -- Pertimbangkan untuk mencoba CoreGui sebagai fallback jika PlayerGui gagal total
    -- local CoreGui = game:GetService("CoreGui")
    -- if CoreGui then
    --     PlayerGui = CoreGui -- Gunakan CoreGui jika PlayerGui tidak ada
    --     print("ZXHELL UI Script (Fix v2): Menggunakan CoreGui sebagai fallback untuk PlayerGui.")
    -- else
    --     warn("ZXHELL UI Script (Fix v2): CoreGui juga tidak ditemukan. UI tidak dapat diparentkan.")
    --     return
    -- end
    return -- Hentikan jika PlayerGui (atau fallback) tidak ada
end
print("ZXHELL UI Script (Fix v2): PlayerGui ditemukan.")

-- // UI FRAME //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberpunkUI_ArcFix_V2" 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false 
ScreenGui.Enabled = true 
print("ZXHELL UI Script (Fix v2): ScreenGui dibuat. Enabled: " .. tostring(ScreenGui.Enabled))

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Active = true 
Frame.Visible = true 
Frame.Draggable = true 
Frame.ClipsDescendants = true
print("ZXHELL UI Script (Fix v2): MainFrame dibuat. Active: " .. tostring(Frame.Active) .. ", Visible: " .. tostring(Frame.Visible))

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Active = true -- Pastikan tombol aktif untuk menerima input

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
local stopUpdateQi = true 
local mainCycleThread = nil
local updateQiThread = nil

local isMinimized = false
local originalFrameSize = UDim2.new(0, 260, 0, 480)
local minimizedFrameSize = UDim2.new(0, 50, 0, 50)

local minimizedZLabel = Instance.new("TextLabel") 
minimizedZLabel.Name = "MinimizedZLabelButton" 
minimizedZLabel.Active = true -- Penting agar ClickDetector berfungsi
minimizedZLabel.Visible = false 
local MinimizedClickDetector = Instance.new("ClickDetector")
MinimizedClickDetector.Parent = minimizedZLabel
print("ZXHELL UI Script (Fix v2): MinimizedZLabel dan ClickDetector dibuat.")


local elementsToToggleVisibility = {}

-- --- Tabel Konfigurasi Timer ---
local timers = {
    reincarnate_delay = 1,
    change_map_delay = 0.5,
    pre_comprehend_qi_duration = 60,
    comprehend_duration = 20,
    post_comprehend_qi_duration = 30,
    update_qi_interval = 1,
    genericShortDelay = 0.5,
    area_setup_delay = 1 
}

-- // Parent UI ke player //
local function setupGuiParenting()
    if not ScreenGui then
        warn("ZXHELL UI Script (Fix v2): ScreenGui nil saat setupGuiParenting.")
        return
    end
    if not PlayerGui then
        warn("ZXHELL UI Script (Fix v2): PlayerGui nil saat setupGuiParenting. UI tidak akan diparentkan.")
        return
    end

    ScreenGui.Parent = PlayerGui
    print("ZXHELL UI Script (Fix v2): ScreenGui diparentkan ke PlayerGui.")

    if Frame and ScreenGui and (not Frame.Parent or Frame.Parent ~= ScreenGui) then Frame.Parent = ScreenGui end
    if UiTitleLabel and Frame then UiTitleLabel.Parent = Frame end
    if StartButton and Frame then StartButton.Parent = Frame end
    if StatusLabel and Frame then StatusLabel.Parent = Frame end
    if MinimizeButton and Frame then MinimizeButton.Parent = Frame end
    if TimerTitleLabel and Frame then TimerTitleLabel.Parent = Frame end
    if ApplyTimersButton and Frame then ApplyTimersButton.Parent = Frame end
    if minimizedZLabel and Frame then minimizedZLabel.Parent = Frame end

    print("ZXHELL UI Script (Fix v2): Semua elemen UI utama telah diparentkan ke Frame di dalam ScreenGui.")
end

setupGuiParenting()


-- // Desain UI (Pastikan semua elemen ada sebelum properti diatur) //
if Frame then
    Frame.Size = originalFrameSize
    Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = Frame
end

if UiTitleLabel then
    UiTitleLabel.Size = UDim2.new(1, -20, 0, 35); UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
    UiTitleLabel.Font = Enum.Font.SourceSansSemibold; UiTitleLabel.Text = "ZXHELL (ARCFIX V2.1)" 
    UiTitleLabel.TextColor3 = Color3.fromRGB(255, 25, 25); UiTitleLabel.TextScaled = false
    UiTitleLabel.TextSize = 20; UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center -- Ukuran disesuaikan sedikit
    UiTitleLabel.BackgroundTransparency = 1; UiTitleLabel.ZIndex = 2 
    UiTitleLabel.TextStrokeTransparency = 0.5; UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
end

local yOffsetForTitle = 50

if StartButton then
    StartButton.Size = UDim2.new(1, -40, 0, 35); StartButton.Position = UDim2.new(0, 20, 0, yOffsetForTitle)
    StartButton.Text = "START SEQUENCE"; StartButton.Font = Enum.Font.SourceSansBold
    StartButton.TextSize = 16; StartButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20); StartButton.BorderSizePixel = 1
    StartButton.BorderColor3 = Color3.fromRGB(255, 50, 50); StartButton.ZIndex = 2
    local StartButtonCorner = Instance.new("UICorner"); StartButtonCorner.CornerRadius = UDim.new(0, 5); StartButtonCorner.Parent = StartButton
end

if StatusLabel then
    StatusLabel.Size = UDim2.new(1, -40, 0, 45); StatusLabel.Position = UDim2.new(0, 20, 0, yOffsetForTitle + 45)
    StatusLabel.Text = "STATUS: STANDBY"; StatusLabel.Font = Enum.Font.SourceSansLight
    StatusLabel.TextSize = 14; StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30); StatusLabel.TextWrapped = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.BorderSizePixel = 0; StatusLabel.ZIndex = 2
    local StatusLabelCorner = Instance.new("UICorner"); StatusLabelCorner.CornerRadius = UDim.new(0, 5); StatusLabelCorner.Parent = StatusLabel
end

local yOffsetForTimers = yOffsetForTitle + 100

if TimerTitleLabel then
    TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20); TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffsetForTimers)
    TimerTitleLabel.Text = "// TIMER_CONFIG_ARCFIX"; TimerTitleLabel.Font = Enum.Font.Code
    TimerTitleLabel.TextSize = 14; TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    TimerTitleLabel.BackgroundTransparency = 1; TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TimerTitleLabel.ZIndex = 2
end

local function createTimerInput(name, yPos, labelText, initialValue)
    if not Frame then return nil end
    local label = Instance.new("TextLabel"); label.Name = name .. "Label"; label.Parent = Frame
    label.Size = UDim2.new(0.65, -25, 0, 20); label.Position = UDim2.new(0, 20, 0, yPos + yOffsetForTimers)
    label.Text = labelText .. ":"; label.Font = Enum.Font.SourceSans; label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(180, 180, 200); label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 2
    timerInputElements[name .. "Label"] = label

    local input = Instance.new("TextBox"); input.Name = name .. "Input"; input.Parent = Frame
    input.Size = UDim2.new(0.35, -25, 0, 20); input.Position = UDim2.new(0.65, 5, 0, yPos + yOffsetForTimers)
    input.Text = tostring(initialValue); input.PlaceholderText = "sec"; input.Font = Enum.Font.SourceSansSemibold
    input.TextSize = 11; input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40); input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(100, 100, 120); input.BorderSizePixel = 1; input.ZIndex = 2
    timerInputElements[name .. "Input"] = input
    local InputCorner = Instance.new("UICorner"); InputCorner.CornerRadius = UDim.new(0, 3); InputCorner.Parent = input
    return input
end

local currentYConfig = 30; local timerSpacing = 22
if Frame then -- Hanya buat input jika Frame ada
    timerInputElements.reincarnateDelayInput = createTimerInput("ReincarnateDelay", currentYConfig, "T1_REINCARNATE_DELAY", timers.reincarnate_delay); currentYConfig = currentYConfig + timerSpacing
    timerInputElements.changeMapDelayInput = createTimerInput("ChangeMapDelay", currentYConfig, "T2_CHANGE_MAP_DELAY", timers.change_map_delay); currentYConfig = currentYConfig + timerSpacing
    timerInputElements.preComprehendQiInput = createTimerInput("PreComprehendQi", currentYConfig, "T3_PRE_COMP_QI_DUR", timers.pre_comprehend_qi_duration); currentYConfig = currentYConfig + timerSpacing
    timerInputElements.comprehendDurationInput = createTimerInput("ComprehendDuration", currentYConfig, "T4_COMPREHEND_DUR", timers.comprehend_duration); currentYConfig = currentYConfig + timerSpacing
    timerInputElements.postComprehendQiDurationInput = createTimerInput("PostComprehendQiDuration", currentYConfig, "T5_POST_COMP_QI_DUR", timers.post_comprehend_qi_duration); currentYConfig = currentYConfig + timerSpacing
    timerInputElements.updateQiIntervalInput = createTimerInput("UpdateQiInterval", currentYConfig, "T6_UPDATE_QI_INTV", timers.update_qi_interval); currentYConfig = currentYConfig + timerSpacing
    timerInputElements.areaSetupDelayInput = createTimerInput("AreaSetupDelay", currentYConfig, "T7_AREA_SETUP_DELAY", timers.area_setup_delay); currentYConfig = currentYConfig + timerSpacing + 10
end

if ApplyTimersButton then
    ApplyTimersButton.Size = UDim2.new(1, -40, 0, 30); ApplyTimersButton.Position = UDim2.new(0, 20, 0, currentYConfig + yOffsetForTimers)
    ApplyTimersButton.Text = "APPLY_TIMERS"; ApplyTimersButton.Font = Enum.Font.SourceSansBold
    ApplyTimersButton.TextSize = 14; ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(30, 80, 30); ApplyTimersButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
    ApplyTimersButton.BorderSizePixel = 1; ApplyTimersButton.ZIndex = 2
    local ApplyButtonCorner = Instance.new("UICorner"); ApplyButtonCorner.CornerRadius = UDim.new(0, 5); ApplyButtonCorner.Parent = ApplyTimersButton
end

if MinimizeButton then
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25); MinimizeButton.Position = UDim2.new(1, -35, 0, 10)
    MinimizeButton.Text = "_"; MinimizeButton.Font = Enum.Font.SourceSansBold; MinimizeButton.TextSize = 20
    MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180); MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    MinimizeButton.BorderColor3 = Color3.fromRGB(100,100,120); MinimizeButton.BorderSizePixel = 1; MinimizeButton.ZIndex = 3 
    local MinimizeButtonCorner = Instance.new("UICorner"); MinimizeButtonCorner.CornerRadius = UDim.new(0, 3); MinimizeButtonCorner.Parent = MinimizeButton
end

if minimizedZLabel then
    minimizedZLabel.Size = UDim2.new(1, 0, 1, 0); minimizedZLabel.Position = UDim2.new(0,0,0,0)
    minimizedZLabel.Text = "Z"; minimizedZLabel.Font = Enum.Font.SourceSansBold; minimizedZLabel.TextScaled = false
    minimizedZLabel.TextSize = 40; minimizedZLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    minimizedZLabel.TextXAlignment = Enum.TextXAlignment.Center; minimizedZLabel.TextYAlignment = Enum.TextYAlignment.Center
    minimizedZLabel.BackgroundTransparency = 1; minimizedZLabel.ZIndex = 4 
    minimizedZLabel.AutoButtonColor = false 
end

elementsToToggleVisibility = {
    UiTitleLabel, StartButton, StatusLabel, TimerTitleLabel, ApplyTimersButton, MinimizeButton 
}
-- Tambahkan elemen timer ke elementsToToggleVisibility secara dinamis
for key, element in pairs(timerInputElements) do
    if typeof(element) == "Instance" then -- Pastikan itu adalah instance UI
        table.insert(elementsToToggleVisibility, element)
    end
end
print("ZXHELL UI Script (Fix v2): Desain UI selesai. Jumlah elemen untuk toggle: " .. #elementsToToggleVisibility)


local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then 
        StatusLabel.Text = "STATUS: " .. string.upper(text) 
        print("ZXHELL UI STATUS: " .. string.upper(text)) -- Cetak status ke konsol juga
    end
end

local TweenService = game:GetService("TweenService")
local function animateFrame(targetSize, targetPosition, callback)
    if not Frame or not Frame.Parent then 
        warn("ZXHELL UI (Fix v2): animateFrame gagal, Frame tidak ada.")
        return 
    end
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {Size = targetSize, Position = targetPosition}
    local tween = TweenService:Create(Frame, info, properties)
    tween:Play()
    if callback then 
        local status, err = pcall(function() tween.Completed:Wait() end)
        if not status then warn("ZXHELL UI (Fix v2): Error saat tween.Completed:Wait(): " .. tostring(err)) end
        callback() 
    end
end

local function toggleMinimize()
    if not Frame or not Frame.Parent or not ScreenGui or not ScreenGui.Parent or not minimizedZLabel then 
        warn("ZXHELL UI (Fix v2): toggleMinimize gagal, salah satu elemen UI utama nil.")
        return 
    end

    isMinimized = not isMinimized
    print("ZXHELL UI (Fix v2): toggleMinimize dipanggil. isMinimized sekarang: " .. tostring(isMinimized))
    if isMinimized then
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        minimizedZLabel.Visible = true
        local screenWidth = ScreenGui.AbsoluteSize.X
        local screenHeight = ScreenGui.AbsoluteSize.Y
        if screenWidth == 0 or screenHeight == 0 then 
            screenWidth = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X) or 1024
            screenHeight = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y) or 768
            print("ZXHELL UI (Fix v2): ScreenGui.AbsoluteSize nol, menggunakan ViewportSize fallback.")
        end
        local targetX = screenWidth - minimizedFrameSize.X.Offset - (0.02 * screenWidth) 
        local targetY = screenHeight - minimizedFrameSize.Y.Offset - (0.02 * screenHeight)
        
        local targetPosition = UDim2.new(0, targetX, 0, targetY) 
        animateFrame(minimizedFrameSize, targetPosition)
        Frame.Draggable = false
    else
        minimizedZLabel.Visible = false
        local targetPosition = UDim2.new(0.5, -originalFrameSize.X.Offset/2, 0.5, -originalFrameSize.Y.Offset/2)
        animateFrame(originalFrameSize, targetPosition, function()
            for _, element in ipairs(elementsToToggleVisibility) do
                if element and element.Parent then element.Visible = true end
            end
            if Frame then Frame.Draggable = true end
        end)
    end
end

print("ZXHELL UI Script (Fix v2): Fungsi UI didefinisikan. Menghubungkan event...")

if MinimizeButton then
    local success, err = pcall(function()
        MinimizeButton.MouseButton1Click:Connect(function()
            print("ZXHELL UI (Fix v2): MinimizeButton DIKLIK!")
            toggleMinimize()
        end)
    end)
    if success then print("ZXHELL UI (Fix v2): MinimizeButton.MouseButton1Click terhubung.")
    else warn("ZXHELL UI (Fix v2): GAGAL menghubungkan MinimizeButton.MouseButton1Click: " .. tostring(err)) end
else warn("ZXHELL UI (Fix v2): MinimizeButton adalah nil, tidak dapat menghubungkan event.") end

if MinimizedClickDetector then
     local success, err = pcall(function()
        MinimizedClickDetector.MouseButton1Click:Connect(function()
            print("ZXHELL UI (Fix v2): minimizedZLabel (via ClickDetector) DIKLIK!")
            toggleMinimize()
        end)
    end)
    if success then print("ZXHELL UI (Fix v2): MinimizedClickDetector.MouseButton1Click terhubung.")
    else warn("ZXHELL UI (Fix v2): GAGAL menghubungkan MinimizedClickDetector.MouseButton1Click: " .. tostring(err)) end
else warn("ZXHELL UI (Fix v2): MinimizedClickDetector adalah nil, tidak dapat menghubungkan event.") end


local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat task.wait() until not scriptRunning or tick() - startTime >= sec
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventsFolder_Path = "RemoteEvents"
local AreaEventsFolder_Name = "AreaEvents"

local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...)
    local remoteEventFolder
    local success = false
    local errMessage = "Unknown error"

    local pcallSuccess, pcallResult = pcall(function()
        if not ReplicatedStorage then
            warn("ZXHELL UI (Fix v2): ReplicatedStorage service not found for fireRemoteEnhanced.")
            return false
        end

        local mainRemoteFolder = ReplicatedStorage:WaitForChild(RemoteEventsFolder_Path, 20) 
        if not mainRemoteFolder then 
            warn("ZXHELL UI (Fix v2): Folder '"..RemoteEventsFolder_Path.."' tidak ditemukan di ReplicatedStorage setelah 20 detik.")
            return false 
        end

        if pathType == "AreaEvents" then
            remoteEventFolder = mainRemoteFolder:WaitForChild(AreaEventsFolder_Name, 20)
            if not remoteEventFolder then 
                warn("ZXHELL UI (Fix v2): Folder '"..AreaEventsFolder_Name.."' tidak ditemukan di "..mainRemoteFolder.Name.." setelah 20 detik.")
                return false 
            end
        else
            remoteEventFolder = mainRemoteFolder
        end

        local remote = remoteEventFolder:WaitForChild(remoteName, 20)
        if not remote then 
            warn("ZXHELL UI (Fix v2): RemoteEvent '"..remoteName.."' tidak ditemukan di "..remoteEventFolder.Name.." setelah 20 detik.")
            return false 
        end
        
        print("ZXHELL UI (Fix v2): Firing RemoteEvent: " .. remoteName .. " di " .. remoteEventFolder.Name)
        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
        return true 
    end)

    if pcallSuccess and pcallResult then 
        success = true 
        print("ZXHELL UI (Fix v2): RemoteEvent " .. remoteName .. " berhasil di-fire.")
    else 
        errMessage = tostring(pcallResult)
        if not pcallSuccess then 
            updateStatus("ERR_PCALL_FIRE_" .. string.upper(remoteName))
            warn("ZXHELL UI (Fix v2): Pcall error firing " .. remoteName .. ": " .. errMessage)
        else 
            updateStatus("ERR_LOGIC_FIRE_" .. string.upper(remoteName))
            warn("ZXHELL UI (Fix v2): Logic error firing " .. remoteName .. ". Pesan internal: " .. (errMessage or "Tidak ada pesan spesifik"))
        end
        success = false 
    end
    return success
end

local function runCycle()
    if not scriptRunning then return end
    print("ZXHELL UI (Fix v2): Memulai runCycle.")
    
    updateStatus("REINCARNATING_PROC"); 
    if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; updateStatus("ERR_REINCARNATE_FAILED"); return end
    waitSeconds(timers.reincarnate_delay); if not scriptRunning then return end

    updateStatus("NAVIGATING_IMMORTAL_MAP_FOR_PRE_QI"); 
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then 
        scriptRunning = false; updateStatus("ERR_NAV_IMMORTAL_PRE_QI"); return 
    end
    waitSeconds(timers.change_map_delay); if not scriptRunning then return end

    updateStatus("ENTERING_HIDDEN_AREA_FOR_PRE_QI");
    if not fireRemoteEnhanced("EnsureHiddenArea", "AreaEvents", {}) then 
        updateStatus("ERR_ENTER_HIDDEN_PRE_QI"); 
        waitSeconds(timers.area_setup_delay); 
        return 
    end
    waitSeconds(timers.area_setup_delay); if not scriptRunning then return end
    updateStatus("IN_HIDDEN_AREA_PRE_QI_OKAY")

    stopUpdateQi = false 
    updateStatus("PRE_COMP_QI_UPDATE_ACTIVE (" .. timers.pre_comprehend_qi_duration .. "s)");
    local preComprehendQiStartTime = tick()
    while scriptRunning and (tick() - preComprehendQiStartTime < timers.pre_comprehend_qi_duration) do
        updateStatus(string.format("PRE_COMP_QI_RUNNING... %ds Left", math.floor(timers.pre_comprehend_qi_duration - (tick() - preComprehendQiStartTime))))
        task.wait(1)
    end
    stopUpdateQi = true 
    if not scriptRunning then return end

    updateStatus("NAVIGATING_IMMORTAL_MAP_FOR_COMPREHEND"); 
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then 
        scriptRunning = false; updateStatus("ERR_NAV_IMMORTAL_COMP"); return 
    end
    waitSeconds(timers.change_map_delay); if not scriptRunning then return end

    updateStatus("ENTERING_FORBIDDEN_AREA_FOR_COMPREHEND");
    if not fireRemoteEnhanced("EnsureForbiddenArea", "AreaEvents", {}) then 
        updateStatus("ERR_ENTER_FORBIDDEN_COMP"); 
        waitSeconds(timers.area_setup_delay);
        return 
    end
    waitSeconds(timers.area_setup_delay); if not scriptRunning then return end
    updateStatus("IN_FORBIDDEN_AREA_COMP_OKAY")
    
    updateStatus("COMPREHEND_PROCESS_ACTIVE (" .. timers.comprehend_duration .. "s)");
    local comprehendStartTime = tick()
    while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
        if not fireRemoteEnhanced("Comprehend", "Base", {}) then 
            updateStatus("COMPREHEND_REMOTE_EVENT_FAIL"); break 
        end
        updateStatus(string.format("COMPREHENDING... %ds Left", math.floor(timers.comprehend_duration - (tick() - comprehendStartTime))))
        task.wait(1) 
    end; if not scriptRunning then return end; updateStatus("COMPREHEND_PROCESS_COMPLETE")

    updateStatus("NAVIGATING_IMMORTAL_MAP_FOR_POST_QI"); 
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then 
        scriptRunning = false; updateStatus("ERR_NAV_IMMORTAL_POST_QI"); return 
    end
    waitSeconds(timers.change_map_delay); if not scriptRunning then return end

    updateStatus("ENTERING_HIDDEN_AREA_FOR_POST_QI");
    if not fireRemoteEnhanced("EnsureHiddenArea", "AreaEvents", {}) then 
        updateStatus("ERR_ENTER_HIDDEN_POST_QI"); 
        waitSeconds(timers.area_setup_delay);
        return 
    end
    waitSeconds(timers.area_setup_delay); if not scriptRunning then return end
    updateStatus("IN_HIDDEN_AREA_POST_QI_OKAY")

    stopUpdateQi = false 
    updateStatus("POST_COMP_QI_UPDATE_ACTIVE (" .. timers.post_comprehend_qi_duration .. "s)");
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        updateStatus(string.format("POST_COMP_QI_RUNNING... %ds Left", math.floor(timers.post_comprehend_qi_duration - (tick() - postComprehendQiStartTime))))
        task.wait(1)
    end
    stopUpdateQi = true 
    if not scriptRunning then return end
    
    updateStatus("CYCLE_ARCFIX_V2_COMPLETE_RESTARTING")
    print("ZXHELL UI (Fix v2): runCycle selesai.")
end


local function updateQiLoop_enhanced()
    print("ZXHELL UI (Fix v2): updateQiLoop_enhanced dimulai.")
    while scriptRunning do
        if not stopUpdateQi then 
            if not fireRemoteEnhanced("UpdateQi", "Base", {}) then
                -- updateStatus("WARN_UPDATE_QI_REMOTE_FAIL") 
            end
        end
        local interval = timers.update_qi_interval; if interval <= 0 then interval = 0.01 end
        waitSeconds(interval) 
    end
    print("ZXHELL UI (Fix v2): updateQiLoop_enhanced berhenti.")
end

if StartButton then
    local success, err = pcall(function()
        StartButton.MouseButton1Click:Connect(function()
            print("ZXHELL UI (Fix v2): StartButton DIKLIK! scriptRunning sebelumnya:", scriptRunning)
            scriptRunning = not scriptRunning
            if scriptRunning then
                StartButton.Text = "SYSTEM_ACTIVE"; StartButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30); StartButton.TextColor3 = Color3.fromRGB(255,255,255)
                updateStatus("INIT_ARCFIX_V2_SEQ"); 
                stopUpdateQi = true 
                
                if not updateQiThread or coroutine.status(updateQiThread) == "dead" then 
                    print("ZXHELL UI (Fix v2): Membuat thread baru untuk updateQiLoop_enhanced.")
                    updateQiThread = task.spawn(updateQiLoop_enhanced) 
                end
                if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
                    print("ZXHELL UI (Fix v2): Membuat thread baru untuk mainCycle.")
                    mainCycleThread = task.spawn(function()
                        print("ZXHELL UI (Fix v2): Thread mainCycle dimulai.")
                        while scriptRunning do 
                            runCycle(); 
                            if not scriptRunning then break end; 
                            updateStatus("CYCLE_ARCFIX_V2_REINIT"); 
                            task.wait(1) 
                        end
                        updateStatus("SYSTEM_ARCFIX_V2_HALTED"); 
                        if StartButton then StartButton.Text = "START SEQUENCE"; StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20); StartButton.TextColor3 = Color3.fromRGB(220,220,220) end
                        stopUpdateQi = true 
                        print("ZXHELL UI (Fix v2): Thread mainCycle berhenti.")
                    end)
                end
            else 
                updateStatus("HALT_ARCFIX_V2_REQUESTED") 
            end
        end)
    end)
    if success then print("ZXHELL UI (Fix v2): StartButton.MouseButton1Click terhubung.")
    else warn("ZXHELL UI (Fix v2): GAGAL menghubungkan StartButton.MouseButton1Click: " .. tostring(err)) end
else warn("ZXHELL UI (Fix v2): StartButton adalah nil, tidak dapat menghubungkan event.") end

if ApplyTimersButton then
    local success, err = pcall(function()
        ApplyTimersButton.MouseButton1Click:Connect(function()
            print("ZXHELL UI (Fix v2): ApplyTimersButton DIKLIK!")
            local function applyTextInput(inputElement, timerKey, labelElement)
                local successApply = false; if not inputElement then return false end; local value = tonumber(inputElement.Text)
                if value and value >= 0 then timers[timerKey] = value; if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(80,255,80) end) end; successApply = true
                else if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(255,80,80) end) end end
                return successApply
            end
            local allTimersValid = true
            allTimersValid = applyTextInput(timerInputElements.reincarnateDelayInput, "reincarnate_delay", timerInputElements.ReincarnateDelayLabel) and allTimersValid
            allTimersValid = applyTextInput(timerInputElements.changeMapDelayInput, "change_map_delay", timerInputElements.ChangeMapDelayLabel) and allTimersValid
            allTimersValid = applyTextInput(timerInputElements.preComprehendQiInput, "pre_comprehend_qi_duration", timerInputElements.PreComprehendQiLabel) and allTimersValid
            allTimersValid = applyTextInput(timerInputElements.comprehendDurationInput, "comprehend_duration", timerInputElements.ComprehendDurationLabel) and allTimersValid
            allTimersValid = applyTextInput(timerInputElements.postComprehendQiDurationInput, "post_comprehend_qi_duration", timerInputElements.PostComprehendQiDurationLabel) and allTimersValid
            allTimersValid = applyTextInput(timerInputElements.updateQiIntervalInput, "update_qi_interval", timerInputElements.UpdateQiIntervalLabel) and allTimersValid
            allTimersValid = applyTextInput(timerInputElements.areaSetupDelayInput, "area_setup_delay", timerInputElements.AreaSetupDelayLabel) and allTimersValid

            local originalStatusText = StatusLabel and StatusLabel.Text:gsub("STATUS: ", "") or "N/A"
            if allTimersValid then updateStatus("TIMER_CONFIG_ARCFIX_APPLIED") else updateStatus("ERR_TIMER_ARCFIX_INPUT_INVALID") end
            task.wait(2)
            local labelsToReset = {
                timerInputElements.ReincarnateDelayLabel, timerInputElements.ChangeMapDelayLabel, 
                timerInputElements.PreComprehendQiLabel, timerInputElements.ComprehendDurationLabel, 
                timerInputElements.PostComprehendQiDurationLabel, timerInputElements.UpdateQiIntervalLabel,
                timerInputElements.AreaSetupDelayLabel
            }
            for _, lbl in ipairs(labelsToReset) do if lbl then pcall(function() lbl.TextColor3 = Color3.fromRGB(180,180,200) end) end end
            updateStatus(originalStatusText)
        end)
    end)
    if success then print("ZXHELL UI (Fix v2): ApplyTimersButton.MouseButton1Click terhubung.")
    else warn("ZXHELL UI (Fix v2): GAGAL menghubungkan ApplyTimersButton.MouseButton1Click: " .. tostring(err)) end
else warn("ZXHELL UI (Fix v2): ApplyTimersButton adalah nil, tidak dapat menghubungkan event.") end


-- --- ANIMASI UI (PENTING: Pastikan elemen ada sebelum diakses di dalam loop) ---
task.spawn(function()
    print("ZXHELL UI (Fix v2): Thread animasi Frame dimulai.")
    while ScreenGui and ScreenGui.Parent do -- Loop utama animasi
        if Frame and Frame.Parent then -- Hanya animasikan jika Frame ada
            if not isMinimized then 
                local bC=Color3.fromRGB(15,15,20);local g1=Color3.fromRGB(25,20,30);local g2=Color3.fromRGB(10,10,15);local brB=Color3.fromRGB(255,0,0);local brG=Color3.fromRGB(0,255,255); 
                local r=math.random();
                if r<0.05 then Frame.BackgroundColor3=g1;Frame.BorderColor3=brG;task.wait(0.05);Frame.BackgroundColor3=g2;task.wait(0.05) 
                elseif r<0.2 then Frame.BackgroundColor3=Color3.Lerp(bC,g1,math.random());Frame.BorderColor3=Color3.Lerp(brB,brG,math.random()*0.5);task.wait(0.1) 
                else Frame.BackgroundColor3=bC;Frame.BorderColor3=brB end 
                local h,s,v=Color3.toHSV(Frame.BorderColor3);Frame.BorderColor3=Color3.fromHSV((h+0.005)%1,s,v) 
            else 
                Frame.BackgroundColor3=Color3.fromRGB(15,15,20);Frame.BorderColor3=Color3.fromRGB(255,0,0) 
            end
        end
        task.wait(0.05) 
    end 
    print("ZXHELL UI (Fix v2): Thread animasi Frame berhenti.") 
end)

task.spawn(function() 
    print("ZXHELL UI (Fix v2): Thread animasi Judul dimulai.")
    local originalTextValue = "ZXHELL (ARCFIX V2.1)" -- Simpan teks asli
    while ScreenGui and ScreenGui.Parent do 
        if UiTitleLabel and UiTitleLabel.Parent then -- Hanya animasikan jika UiTitleLabel ada
            if not isMinimized then 
                local oT = originalTextValue
                local gCs={"@","#","$","%","&","*","!","?","/","\\","|_"};local bC=Color3.fromRGB(255,25,25);local oP=UiTitleLabel.Position; 
                local r=math.random();local iGT=false;
                if r<0.02 then iGT=true;local nT="";for i=1,#oT do if math.random()<0.7 then nT=nT..gCs[math.random(#gCs)] else nT=nT..oT:sub(i,i) end end UiTitleLabel.Text=nT;UiTitleLabel.TextColor3=Color3.fromRGB(math.random(200,255),math.random(0,50),math.random(0,50));UiTitleLabel.Position=oP+UDim2.fromOffset(math.random(-2,2),math.random(-2,2));UiTitleLabel.Rotation=math.random(-1,1)*0.5;task.wait(0.07) 
                elseif r<0.1 then UiTitleLabel.TextColor3=Color3.fromHSV(math.random(),1,1);UiTitleLabel.TextStrokeColor3=Color3.fromHSV(math.random(),0.8,1);UiTitleLabel.TextStrokeTransparency=math.random()*0.3;UiTitleLabel.Rotation=math.random(-1,1)*0.2;task.wait(0.1) 
                else UiTitleLabel.Text=oT;UiTitleLabel.TextStrokeTransparency=0.5;UiTitleLabel.TextStrokeColor3=Color3.fromRGB(50,0,0);UiTitleLabel.Position=oP;UiTitleLabel.Rotation=0 end 
                if not iGT then local h=(tick()*0.1)%1;local rR,gR,bR=Color3.fromHSV(h,1,1).R,Color3.fromHSV(h,1,1).G,Color3.fromHSV(h,1,1).B;rR=math.min(1,rR+0.6);gR=gR*0.4;bR=bR*0.4;UiTitleLabel.TextColor3=Color3.new(rR,gR,bR) end 
            end
        end
        task.wait(0.05) 
    end 
    print("ZXHELL UI (Fix v2): Thread animasi Judul berhenti.") 
end)

task.spawn(function() 
    print("ZXHELL UI (Fix v2): Thread animasi Tombol dimulai.")
    local bts={StartButton,ApplyTimersButton,MinimizeButton};
    while ScreenGui and ScreenGui.Parent do 
        if not isMinimized then 
            for _,btn in ipairs(bts) do 
                if btn and btn.Parent then -- Hanya animasikan jika tombol ada
                    local oB=btn.BorderColor3;
                    if btn.Name=="StartButton" and scriptRunning then btn.BorderColor3=Color3.fromRGB(255,100,100) 
                    else local h,s,v=Color3.toHSV(oB);btn.BorderColor3=Color3.fromHSV(h,s,math.sin(tick()*2)*0.1+0.9) end 
                end 
            end 
        end 
        task.wait(0.1) 
    end 
    print("ZXHELL UI (Fix v2): Thread animasi Tombol berhenti.") 
end)

task.spawn(function() 
    print("ZXHELL UI (Fix v2): Thread animasi Z Label dimulai.")
    while ScreenGui and ScreenGui.Parent do 
        if minimizedZLabel and minimizedZLabel.Parent then -- Hanya animasikan jika Z Label ada
            if isMinimized and minimizedZLabel.Visible then 
                local h=(tick()*0.2)%1;minimizedZLabel.TextColor3=Color3.fromHSV(h,1,1) 
            end 
        end
        task.wait(0.05) 
    end 
    print("ZXHELL UI (Fix v2): Thread animasi Z Label berhenti.") 
end)


game:BindToClose(function()
    print("ZXHELL UI (Fix v2): BindToClose dipanggil.")
    scriptRunning = false 
    warn("ZXHELL UI (Fix v2): Game ditutup, menghentikan skrip...")
    
    -- Hentikan thread secara eksplisit jika masih berjalan
    if mainCycleThread and coroutine.status(mainCycleThread) ~= "dead" then
        print("ZXHELL UI (Fix v2): Mencoba menghentikan mainCycleThread.")
        -- Tidak ada cara langsung untuk 'membunuh' thread dari luar di Lua, 
        -- tapi flag scriptRunning seharusnya sudah cukup.
    end
    if updateQiThread and coroutine.status(updateQiThread) ~= "dead" then
         print("ZXHELL UI (Fix v2): Mencoba menghentikan updateQiThread.")
    end

    task.wait(0.8) -- Beri waktu lebih untuk loop berhenti berdasarkan flag scriptRunning
    
    if ScreenGui and ScreenGui.Parent then 
        print("ZXHELL UI (Fix v2): Menghancurkan ScreenGui.")
        pcall(function() ScreenGui:Destroy() end) 
    end
    print("ZXHELL UI (Fix v2): Pembersihan skrip selesai.")
end)

print("ZXHELL UI Script (Fix v2): Eksekusi LocalScript selesai. UI seharusnya sudah muncul dan interaktif.")
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "STATUS: " then 
    updateStatus("STANDBY_ARCFIX_V2")
end
```

**Perubahan Utama dan Penjelasan:**

1.  **Peningkatan `print` Debugging:** Hampir setiap langkah penting kini memiliki `print` untuk memberi tahu Anda apa yang sedang terjadi atau apa yang gagal.
2.  **`WaitForChild` untuk `PlayerGui`:** Diberi timeout 15 detik. Jika gagal, skrip akan memberi peringatan dan berhenti (atau Anda bisa mengaktifkan fallback ke `CoreGui` jika diperlukan).
3.  **Pemeriksaan `nil` yang Lebih Ketat:**
    * Sebelum mengatur properti elemen UI atau mem-parent-kannya, ada pemeriksaan apakah elemen tersebut `nil`.
    * Dalam loop animasi, ada pemeriksaan apakah `Frame`, `UiTitleLabel`, dll., masih ada dan memiliki parent sebelum mencoba mengakses propertinya. Ini mencegah error jika UI dihancurkan saat animasi masih berjalan.
4.  **Koneksi Event dengan `pcall`:** Koneksi event tombol sekarang dibungkus dengan `pcall` untuk menangkap potensi error saat menghubungkan dan mencetaknya. Ini membantu mengidentifikasi apakah masalahnya ada pada koneksi event itu sendiri.
5.  **`Active = true` Dikonfirmasi:** Properti `Active` untuk tombol sudah benar, ini penting untuk interaksi.
6.  **`ScreenGui.Enabled = true` Dikonfirmasi:** Ini juga sudah benar dan penting agar UI terlihat dan interaktif.
7.  **`elementsToToggleVisibility` Dinamis:** Pengisian tabel ini dibuat lebih aman dengan memeriksa tipe elemen.
8.  **`fireRemoteEnhanced` Timeout:** Timeout untuk `WaitForChild` pada RemoteEvents dinaikkan menjadi 20 detik.
9.  **Animasi Loop:** Kondisi `while ScreenGui and ScreenGui.Parent do` tetap ada, dan ditambahkan pemeriksaan individual untuk elemen yang dianimasikan di dalam loop.
10. **`BindToClose`:** Ditambahkan `print` untuk mengetahui kapan fungsi ini dipanggil dan sedikit penyesuaian pada pesan.

**Langkah-Langkah Diagnosis untuk Anda:**

1.  **Salin dan Jalankan Skrip Ini:** Gunakan versi terbaru di atas.
2.  **Buka Konsol Arceus X SEBELUM Menjalankan:** Pastikan konsol sudah terbuka untuk menangkap semua output dari awal.
3.  **Analisis Output Konsol:**
    * **Pesan Sukses:** Cari pesan seperti "ZXHELL UI Script (Fix v2): StartButton.MouseButton1Click terhubung." Jika semua koneksi event berhasil, itu pertanda baik.
    * **Peringatan (`warn`):** Perhatikan pesan kuning, misalnya jika `PlayerGui` tidak ditemukan atau `RemoteEvents` gagal dimuat.
    * **Error (Merah):** Ini yang paling penting. Jika ada error, catat baris kode dan pesan errornya. Ini akan menunjukkan di mana masalah sebenarnya terjadi.
    * **Status Updates:** Perhatikan `print("ZXHELL UI STATUS: ...")` untuk melihat apakah logika `runCycle` berjalan.
    * **Animasi Thread Prints:** Lihat apakah thread animasi melaporkan "dimulai" dan apakah mereka melaporkan "berhenti" hanya saat game ditutup. Jika mereka berhenti lebih awal, ada masalah.
4.  **Interaksi Tombol:**
    * Klik tombol Start. Apakah Anda melihat pesan "ZXHELL UI (Fix v2): StartButton DIKLIK!" di konsol?
    * Apakah status berubah? Apakah thread `mainCycle` dan `updateQiLoop_enhanced` melaporkan bahwa mereka dimulai?
5.  **Animasi:**
    * Apakah ada perubahan visual pada UI (warna border, teks judul glitch)?
    * Jika tidak, apakah ada error di konsol yang berkaitan dengan loop animasi?

Dengan output konsol yang detail, kita seharusnya bisa lebih mudah menemukan akar masalahnya. Jika UI masih tidak merespons sama sekali (tidak ada `print` dari klik tombol), masalahnya mungkin lebih mendasar pada bagaimana Arceus X menangani event input untuk UI yang dibuat skrip, atau bagaimana UI di-rend
