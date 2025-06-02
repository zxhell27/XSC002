-- Pastikan skrip ini adalah LocalScript dan ditempatkan di StarterPlayerScripts atau StarterGui.

print("ZXHELL UI Script: Memulai eksekusi LocalScript...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("ZXHELL UI Script: LocalPlayer tidak ditemukan. Skrip tidak akan berjalan.")
    return -- Hentikan skrip jika tidak ada LocalPlayer (misalnya, dijalankan di server)
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("ZXHELL UI Script: LocalPlayer dan PlayerGui ditemukan.")

-- // UI FRAME //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberpunkUI_Optimized_AutoNav" -- Nama diubah sedikit untuk menandakan versi
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false 
ScreenGui.Enabled = true 

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Active = true 
Frame.Visible = true 
Frame.Draggable = true 

local UiTitleLabel = Instance.new("TextLabel")
UiTitleLabel.Name = "UiTitleLabel"

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Active = true 

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
local stopUpdateQi = true -- Mulai dengan true, karena kondisi map/area belum tentu terpenuhi
local mainCycleThread = nil
local updateQiThread = nil

local isMinimized = false
local originalFrameSize = UDim2.new(0, 260, 0, 480)
local minimizedFrameSize = UDim2.new(0, 50, 0, 50)

local minimizedZLabel = Instance.new("TextLabel") 
minimizedZLabel.Name = "MinimizedZLabelButton" 
minimizedZLabel.Active = true 
minimizedZLabel.Visible = false 
local MinimizedClickDetector = Instance.new("ClickDetector") -- Untuk klik pada TextLabel
MinimizedClickDetector.Parent = minimizedZLabel


local elementsToToggleVisibility = {}

-- --- Tabel Konfigurasi Timer ---
local timers = {
    reincarnate_delay = 1,
    change_map_delay = 0.5,
    pre_comprehend_qi_duration = 60,
    comprehend_duration = 20,
    post_comprehend_qi_duration = 30,
    update_qi_interval = 1,
    genericShortDelay = 0.5, -- Tidak banyak digunakan di flow ini, tapi bisa untuk masa depan
    area_setup_delay = 1 -- Delay setelah mencoba masuk area khusus
}

-- // Parent UI ke player //
local function setupGuiParenting()
    if not (ScreenGui and PlayerGui) then
        warn("ZXHELL UI Script: ScreenGui atau PlayerGui nil saat setupGuiParenting.")
        return
    end

    ScreenGui.Parent = PlayerGui 
    print("ZXHELL UI Script: ScreenGui diparentkan ke PlayerGui.")

    if not Frame.Parent or Frame.Parent ~= ScreenGui then Frame.Parent = ScreenGui end
    UiTitleLabel.Parent = Frame
    StartButton.Parent = Frame
    StatusLabel.Parent = Frame
    MinimizeButton.Parent = Frame
    TimerTitleLabel.Parent = Frame
    ApplyTimersButton.Parent = Frame
    minimizedZLabel.Parent = Frame 

    print("ZXHELL UI Script: Semua elemen UI utama telah diparentkan ke Frame.")
end

setupGuiParenting()


-- // Desain UI (Sebagian besar sama dengan versi sebelumnya) //
Frame.Size = originalFrameSize
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
Frame.ClipsDescendants = true
local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = Frame

UiTitleLabel.Size = UDim2.new(1, -20, 0, 35); UiTitleLabel.Position = UDim2.new(0, 10, 0, 10)
UiTitleLabel.Font = Enum.Font.SourceSansSemibold; UiTitleLabel.Text = "ZXHELL (AUTONAV V3)" 
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 25, 25); UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 22; UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.BackgroundTransparency = 1; UiTitleLabel.ZIndex = 2 
UiTitleLabel.TextStrokeTransparency = 0.5; UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)

local yOffsetForTitle = 50

StartButton.Size = UDim2.new(1, -40, 0, 35); StartButton.Position = UDim2.new(0, 20, 0, yOffsetForTitle)
StartButton.Text = "START SEQUENCE"; StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 16; StartButton.TextColor3 = Color3.fromRGB(220, 220, 220)
StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20); StartButton.BorderSizePixel = 1
StartButton.BorderColor3 = Color3.fromRGB(255, 50, 50); StartButton.ZIndex = 2
local StartButtonCorner = Instance.new("UICorner"); StartButtonCorner.CornerRadius = UDim.new(0, 5); StartButtonCorner.Parent = StartButton

StatusLabel.Size = UDim2.new(1, -40, 0, 45); StatusLabel.Position = UDim2.new(0, 20, 0, yOffsetForTitle + 45)
StatusLabel.Text = "STATUS: STANDBY"; StatusLabel.Font = Enum.Font.SourceSansLight
StatusLabel.TextSize = 14; StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30); StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.BorderSizePixel = 0; StatusLabel.ZIndex = 2
local StatusLabelCorner = Instance.new("UICorner"); StatusLabelCorner.CornerRadius = UDim.new(0, 5); StatusLabelCorner.Parent = StatusLabel

local yOffsetForTimers = yOffsetForTitle + 100

TimerTitleLabel.Size = UDim2.new(1, -40, 0, 20); TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffsetForTimers)
TimerTitleLabel.Text = "// TIMER_CONFIG_AUTONAV"; TimerTitleLabel.Font = Enum.Font.Code
TimerTitleLabel.TextSize = 14; TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
TimerTitleLabel.BackgroundTransparency = 1; TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TimerTitleLabel.ZIndex = 2

local function createTimerInput(name, yPos, labelText, initialValue)
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
timerInputElements.reincarnateDelayInput = createTimerInput("ReincarnateDelay", currentYConfig, "T1_REINCARNATE_DELAY", timers.reincarnate_delay); currentYConfig = currentYConfig + timerSpacing
timerInputElements.changeMapDelayInput = createTimerInput("ChangeMapDelay", currentYConfig, "T2_CHANGE_MAP_DELAY", timers.change_map_delay); currentYConfig = currentYConfig + timerSpacing
timerInputElements.preComprehendQiInput = createTimerInput("PreComprehendQi", currentYConfig, "T3_PRE_COMP_QI_DUR", timers.pre_comprehend_qi_duration); currentYConfig = currentYConfig + timerSpacing
timerInputElements.comprehendDurationInput = createTimerInput("ComprehendDuration", currentYConfig, "T4_COMPREHEND_DUR", timers.comprehend_duration); currentYConfig = currentYConfig + timerSpacing
timerInputElements.postComprehendQiDurationInput = createTimerInput("PostComprehendQiDuration", currentYConfig, "T5_POST_COMP_QI_DUR", timers.post_comprehend_qi_duration); currentYConfig = currentYConfig + timerSpacing
timerInputElements.updateQiIntervalInput = createTimerInput("UpdateQiInterval", currentYConfig, "T6_UPDATE_QI_INTV", timers.update_qi_interval); currentYConfig = currentYConfig + timerSpacing
timerInputElements.areaSetupDelayInput = createTimerInput("AreaSetupDelay", currentYConfig, "T7_AREA_SETUP_DELAY", timers.area_setup_delay); currentYConfig = currentYConfig + timerSpacing + 10


ApplyTimersButton.Size = UDim2.new(1, -40, 0, 30); ApplyTimersButton.Position = UDim2.new(0, 20, 0, currentYConfig + yOffsetForTimers)
ApplyTimersButton.Text = "APPLY_TIMERS"; ApplyTimersButton.Font = Enum.Font.SourceSansBold
ApplyTimersButton.TextSize = 14; ApplyTimersButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(30, 80, 30); ApplyTimersButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
ApplyTimersButton.BorderSizePixel = 1; ApplyTimersButton.ZIndex = 2
local ApplyButtonCorner = Instance.new("UICorner"); ApplyButtonCorner.CornerRadius = UDim.new(0, 5); ApplyButtonCorner.Parent = ApplyTimersButton

MinimizeButton.Size = UDim2.new(0, 25, 0, 25); MinimizeButton.Position = UDim2.new(1, -35, 0, 10)
MinimizeButton.Text = "_"; MinimizeButton.Font = Enum.Font.SourceSansBold; MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180); MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.BorderColor3 = Color3.fromRGB(100,100,120); MinimizeButton.BorderSizePixel = 1; MinimizeButton.ZIndex = 3 
local MinimizeButtonCorner = Instance.new("UICorner"); MinimizeButtonCorner.CornerRadius = UDim.new(0, 3); MinimizeButtonCorner.Parent = MinimizeButton

minimizedZLabel.Size = UDim2.new(1, 0, 1, 0); minimizedZLabel.Position = UDim2.new(0,0,0,0)
minimizedZLabel.Text = "Z"; minimizedZLabel.Font = Enum.Font.SourceSansBold; minimizedZLabel.TextScaled = false
minimizedZLabel.TextSize = 40; minimizedZLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
minimizedZLabel.TextXAlignment = Enum.TextXAlignment.Center; minimizedZLabel.TextYAlignment = Enum.TextYAlignment.Center
minimizedZLabel.BackgroundTransparency = 1; minimizedZLabel.ZIndex = 4 
minimizedZLabel.AutoButtonColor = false 

elementsToToggleVisibility = {
    UiTitleLabel, StartButton, StatusLabel, TimerTitleLabel, ApplyTimersButton,
    timerInputElements.ReincarnateDelayLabel, timerInputElements.reincarnateDelayInput,
    timerInputElements.ChangeMapDelayLabel, timerInputElements.changeMapDelayInput,
    timerInputElements.PreComprehendQiLabel, timerInputElements.preComprehendQiInput,
    timerInputElements.ComprehendDurationLabel, timerInputElements.comprehendDurationInput,
    timerInputElements.PostComprehendQiDurationLabel, timerInputElements.postComprehendQiDurationInput,
    timerInputElements.UpdateQiIntervalLabel, timerInputElements.updateQiIntervalInput,
    timerInputElements.AreaSetupDelayLabel, timerInputElements.areaSetupDelayInput, 
    MinimizeButton 
}

local function updateStatus(text)
    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: " .. string.upper(text) end
end

local TweenService = game:GetService("TweenService")
local function animateFrame(targetSize, targetPosition, callback)
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {Size = targetSize, Position = targetPosition}
    local tween = TweenService:Create(Frame, info, properties)
    tween:Play()
    if callback then tween.Completed:Wait(); callback() end
end

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        for _, element in ipairs(elementsToToggleVisibility) do
            if element and element.Parent then element.Visible = false end
        end
        minimizedZLabel.Visible = true
        local screenWidth = ScreenGui.AbsoluteSize.X
        local screenHeight = ScreenGui.AbsoluteSize.Y
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
            Frame.Draggable = true
        end)
    end
end

print("ZXHELL UI Script: Fungsi dan variabel UI telah didefinisikan. Menghubungkan event...")

if MinimizeButton then
    MinimizeButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI: MinimizeButton DIKLIK!")
        toggleMinimize()
    end)
else warn("ZXHELL UI: MinimizeButton adalah nil sebelum menghubungkan event.") end

if MinimizedClickDetector then
    MinimizedClickDetector.MouseButton1Click:Connect(function()
         print("ZXHELL UI: minimizedZLabel (via ClickDetector) DIKLIK!")
        toggleMinimize()
    end)
else warn("ZXHELL UI: MinimizedClickDetector adalah nil.") end


local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end
    local startTime = tick()
    repeat task.wait() until not scriptRunning or tick() - startTime >= sec
end

local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...); local remoteEventFolder; local success = false; local errMessage = "Unknown error"
    local pcallSuccess, pcallResult = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10) 
        if not RemoteEventsFolder then warn("Folder RemoteEvents tidak ditemukan di ReplicatedStorage"); return false end

        if pathType == "AreaEvents" then
            remoteEventFolder = RemoteEventsFolder:WaitForChild("AreaEvents", 10)
            if not remoteEventFolder then warn("Folder AreaEvents tidak ditemukan di RemoteEvents"); return false end
        else
            remoteEventFolder = RemoteEventsFolder
        end
        local remote = remoteEventFolder:WaitForChild(remoteName, 10)
        if not remote then warn("RemoteEvent '"..remoteName.."' tidak ditemukan di "..remoteEventFolder.Name); return false end

        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
        return true 
    end)
    if pcallSuccess and pcallResult then 
        success = true 
    else 
        errMessage = tostring(pcallResult)
        updateStatus("ERR_FIRE_" .. string.upper(remoteName))
        warn("Error firing " .. remoteName .. ": " .. errMessage); 
        success = false 
    end
    return success
end

-- Siklus utama yang disederhanakan dengan navigasi otomatis
local function runCycle()
    if not scriptRunning then return end
    
    updateStatus("REINCARNATING_PROC"); 
    if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; updateStatus("ERR_REINCARNATE_FAILED"); return end
    waitSeconds(timers.reincarnate_delay); if not scriptRunning then return end

    -- >>> FASE: PERSIAPAN QI SEBELUM COMPREHEND (Map Immortal + Area Hidden) <<<
    updateStatus("NAVIGATING_IMMORTAL_MAP_FOR_PRE_QI"); 
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then 
        scriptRunning = false; updateStatus("ERR_NAV_IMMORTAL_PRE_QI"); return 
    end
    waitSeconds(timers.change_map_delay); if not scriptRunning then return end

    updateStatus("ENTERING_HIDDEN_AREA_FOR_PRE_QI");
    if not fireRemoteEnhanced("EnsureHiddenArea", "AreaEvents", {}) then 
        updateStatus("ERR_ENTER_HIDDEN_PRE_QI"); 
        waitSeconds(timers.area_setup_delay); 
        return -- Gagal masuk area, siklus ini batal untuk QI
    end
    waitSeconds(timers.area_setup_delay); if not scriptRunning then return end
    updateStatus("IN_HIDDEN_AREA_PRE_QI_OKAY")

    stopUpdateQi = false -- AKTIFKAN UpdateQi
    updateStatus("PRE_COMP_QI_UPDATE_ACTIVE (" .. timers.pre_comprehend_qi_duration .. "s)");
    local preComprehendQiStartTime = tick()
    while scriptRunning and (tick() - preComprehendQiStartTime < timers.pre_comprehend_qi_duration) do
        -- stopUpdateQi bisa di-set false oleh external logic jika perlu, tapi normalnya loop ini selesai by time
        updateStatus(string.format("PRE_COMP_QI_RUNNING... %ds Left", math.floor(timers.pre_comprehend_qi_duration - (tick() - preComprehendQiStartTime))))
        task.wait(1)
    end
    stopUpdateQi = true -- NONAKTIFKAN UpdateQi sebelum fase berikutnya
    if not scriptRunning then return end


    -- >>> FASE: COMPREHEND (Map Immortal + Area Forbidden) <<<
    updateStatus("NAVIGATING_IMMORTAL_MAP_FOR_COMPREHEND"); 
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then 
        scriptRunning = false; updateStatus("ERR_NAV_IMMORTAL_COMP"); return 
    end
    waitSeconds(timers.change_map_delay); if not scriptRunning then return end

    updateStatus("ENTERING_FORBIDDEN_AREA_FOR_COMPREHEND");
    if not fireRemoteEnhanced("EnsureForbiddenArea", "AreaEvents", {}) then 
        updateStatus("ERR_ENTER_FORBIDDEN_COMP"); 
        waitSeconds(timers.area_setup_delay);
        return -- Gagal masuk area, siklus ini batal untuk Comprehend
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


    -- >>> FASE: PERSIAPAN QI SETELAH COMPREHEND (Map Immortal + Area Hidden) <<<
    updateStatus("NAVIGATING_IMMORTAL_MAP_FOR_POST_QI"); 
    if not fireRemoteEnhanced("ChangeMap", "AreaEvents", "immortal") then 
        scriptRunning = false; updateStatus("ERR_NAV_IMMORTAL_POST_QI"); return 
    end
    waitSeconds(timers.change_map_delay); if not scriptRunning then return end

    updateStatus("ENTERING_HIDDEN_AREA_FOR_POST_QI");
    if not fireRemoteEnhanced("EnsureHiddenArea", "AreaEvents", {}) then 
        updateStatus("ERR_ENTER_HIDDEN_POST_QI"); 
        waitSeconds(timers.area_setup_delay);
        return -- Gagal masuk area, siklus ini batal untuk QI
    end
    waitSeconds(timers.area_setup_delay); if not scriptRunning then return end
    updateStatus("IN_HIDDEN_AREA_POST_QI_OKAY")

    stopUpdateQi = false -- AKTIFKAN UpdateQi lagi
    updateStatus("POST_COMP_QI_UPDATE_ACTIVE (" .. timers.post_comprehend_qi_duration .. "s)");
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        updateStatus(string.format("POST_COMP_QI_RUNNING... %ds Left", math.floor(timers.post_comprehend_qi_duration - (tick() - postComprehendQiStartTime))))
        task.wait(1)
    end
    stopUpdateQi = true -- NONAKTIFKAN UpdateQi setelah selesai
    if not scriptRunning then return end
    
    updateStatus("CYCLE_AUTONAV_COMPLETE_RESTARTING")
end


local function updateQiLoop_enhanced()
    while scriptRunning do
        if not stopUpdateQi then 
            -- Tidak perlu cek map/area di sini, runCycle sudah memastikan kondisi
            if not fireRemoteEnhanced("UpdateQi", "Base", {}) then
                -- updateStatus("WARN_UPDATE_QI_REMOTE_FAIL") -- Opsional: status jika remote UpdateQi gagal
            end
        end
        local interval = timers.update_qi_interval; if interval <= 0 then interval = 0.01 end
        waitSeconds(interval) 
    end
end

if StartButton then
    StartButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI: StartButton DIKLIK! scriptRunning sebelumnya:", scriptRunning)
        scriptRunning = not scriptRunning
        if scriptRunning then
            StartButton.Text = "SYSTEM_ACTIVE"; StartButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30); StartButton.TextColor3 = Color3.fromRGB(255,255,255)
            updateStatus("INIT_AUTONAV_SEQUENCE"); 
            stopUpdateQi = true 
            
            if not updateQiThread or coroutine.status(updateQiThread) == "dead" then 
                updateQiThread = task.spawn(updateQiLoop_enhanced) 
            end
            if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
                mainCycleThread = task.spawn(function()
                    while scriptRunning do 
                        runCycle(); 
                        if not scriptRunning then break end; 
                        updateStatus("CYCLE_AUTONAV_REINIT"); 
                        task.wait(1) 
                    end
                    updateStatus("SYSTEM_AUTONAV_HALTED"); StartButton.Text = "START SEQUENCE"; StartButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
                    StartButton.TextColor3 = Color3.fromRGB(220,220,220); 
                    stopUpdateQi = true 
                end)
            end
        else 
            updateStatus("HALT_AUTONAV_REQUESTED") 
        end
    end)
else warn("ZXHELL UI: StartButton adalah nil sebelum menghubungkan event.") end

if ApplyTimersButton then
    ApplyTimersButton.MouseButton1Click:Connect(function()
        print("ZXHELL UI: ApplyTimersButton DIKLIK!")
        local function applyTextInput(inputElement, timerKey, labelElement)
            local success = false; if not inputElement then return false end; local value = tonumber(inputElement.Text)
            if value and value >= 0 then timers[timerKey] = value; if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(80,255,80) end) end; success = true
            else if labelElement then pcall(function() labelElement.TextColor3 = Color3.fromRGB(255,80,80) end) end end
            return success
        end
        local allTimersValid = true
        allTimersValid = applyTextInput(timerInputElements.reincarnateDelayInput, "reincarnate_delay", timerInputElements.ReincarnateDelayLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.changeMapDelayInput, "change_map_delay", timerInputElements.ChangeMapDelayLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.preComprehendQiInput, "pre_comprehend_qi_duration", timerInputElements.PreComprehendQiLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.comprehendDurationInput, "comprehend_duration", timerInputElements.ComprehendDurationLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.postComprehendQiDurationInput, "post_comprehend_qi_duration", timerInputElements.PostComprehendQiDurationLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.updateQiIntervalInput, "update_qi_interval", timerInputElements.UpdateQiIntervalLabel) and allTimersValid
        allTimersValid = applyTextInput(timerInputElements.areaSetupDelayInput, "area_setup_delay", timerInputElements.AreaSetupDelayLabel) and allTimersValid

        local originalStatus = StatusLabel.Text:gsub("STATUS: ", "")
        if allTimersValid then updateStatus("TIMER_CONFIG_AUTONAV_APPLIED") else updateStatus("ERR_TIMER_AUTONAV_INPUT_INVALID") end
        task.wait(2)
        local labelsToReset = {
            timerInputElements.ReincarnateDelayLabel, timerInputElements.ChangeMapDelayLabel, 
            timerInputElements.PreComprehendQiLabel, timerInputElements.ComprehendDurationLabel, 
            timerInputElements.PostComprehendQiDurationLabel, timerInputElements.UpdateQiIntervalLabel,
            timerInputElements.AreaSetupDelayLabel
        }
        for _, lbl in ipairs(labelsToReset) do if lbl then pcall(function() lbl.TextColor3 = Color3.fromRGB(180,180,200) end) end end
        updateStatus(originalStatus)
    end)
else warn("ZXHELL UI: ApplyTimersButton adalah nil sebelum menghubungkan event.") end


-- --- ANIMASI UI (Sama seperti sebelumnya, tidak diubah) ---
task.spawn(function() if not Frame or not Frame.Parent then return end; local bC=Color3.fromRGB(15,15,20);local g1=Color3.fromRGB(25,20,30);local g2=Color3.fromRGB(10,10,15);local brB=Color3.fromRGB(255,0,0);local brG=Color3.fromRGB(0,255,255);while ScreenGui and ScreenGui.Parent do if not isMinimized then local r=math.random();if r<0.05 then Frame.BackgroundColor3=g1;Frame.BorderColor3=brG;task.wait(0.05);Frame.BackgroundColor3=g2;task.wait(0.05) elseif r<0.2 then Frame.BackgroundColor3=Color3.Lerp(bC,g1,math.random());Frame.BorderColor3=Color3.Lerp(brB,brG,math.random()*0.5);task.wait(0.1) else Frame.BackgroundColor3=bC;Frame.BorderColor3=brB end local h,s,v=Color3.toHSV(Frame.BorderColor3);Frame.BorderColor3=Color3.fromHSV((h+0.005)%1,s,v) else Frame.BackgroundColor3=bC;Frame.BorderColor3=brB end task.wait(0.05) end end)
task.spawn(function() if not UiTitleLabel or not UiTitleLabel.Parent then return end;local oT=UiTitleLabel.Text;local gCs={"@","#","$","%","&","*","!","?","/","\\","|_"};local bC=Color3.fromRGB(255,25,25);local oP=UiTitleLabel.Position;while ScreenGui and ScreenGui.Parent do if not isMinimized then local r=math.random();local iGT=false;if r<0.02 then iGT=true;local nT="";for i=1,#oT do if math.random()<0.7 then nT=nT..gCs[math.random(#gCs)] else nT=nT..oT:sub(i,i) end end UiTitleLabel.Text=nT;UiTitleLabel.TextColor3=Color3.fromRGB(math.random(200,255),math.random(0,50),math.random(0,50));UiTitleLabel.Position=oP+UDim2.fromOffset(math.random(-2,2),math.random(-2,2));UiTitleLabel.Rotation=math.random(-1,1)*0.5;task.wait(0.07) elseif r<0.1 then UiTitleLabel.TextColor3=Color3.fromHSV(math.random(),1,1);UiTitleLabel.TextStrokeColor3=Color3.fromHSV(math.random(),0.8,1);UiTitleLabel.TextStrokeTransparency=math.random()*0.3;UiTitleLabel.Rotation=math.random(-1,1)*0.2;task.wait(0.1) else UiTitleLabel.Text=oT;UiTitleLabel.TextStrokeTransparency=0.5;UiTitleLabel.TextStrokeColor3=Color3.fromRGB(50,0,0);UiTitleLabel.Position=oP;UiTitleLabel.Rotation=0 end if not iGT then local h=(tick()*0.1)%1;local rR,gR,bR=Color3.fromHSV(h,1,1).R,Color3.fromHSV(h,1,1).G,Color3.fromHSV(h,1,1).B;rR=math.min(1,rR+0.6);gR=gR*0.4;bR=bR*0.4;UiTitleLabel.TextColor3=Color3.new(rR,gR,bR) end end task.wait(0.05) end end)
task.spawn(function() local bts={StartButton,ApplyTimersButton,MinimizeButton};while ScreenGui and ScreenGui.Parent do if not isMinimized then for _,btn in ipairs(bts) do if btn and btn.Parent then local oB=btn.BorderColor3;if btn.Name=="StartButton" and scriptRunning then btn.BorderColor3=Color3.fromRGB(255,100,100) else local h,s,v=Color3.toHSV(oB);btn.BorderColor3=Color3.fromHSV(h,s,math.sin(tick()*2)*0.1+0.9) end end end end task.wait(0.1) end end)
task.spawn(function() while ScreenGui and ScreenGui.Parent do if isMinimized and minimizedZLabel.Visible then local h=(tick()*0.2)%1;minimizedZLabel.TextColor3=Color3.fromHSV(h,1,1) end task.wait(0.05) end end)

game:BindToClose(function()
    if scriptRunning then warn("ZXHELL UI (AUTONAV): Game ditutup, menghentikan skrip..."); scriptRunning = false; task.wait(0.5) end
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    print("ZXHELL UI (AUTONAV): Pembersihan skrip selesai.")
end)

print("ZXHELL UI Script (AUTONAV): Eksekusi LocalScript selesai. UI seharusnya sudah muncul dan interaktif.")
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "STATUS: " then StatusLabel.Text = "STATUS: STANDBY_AUTONAV" end
