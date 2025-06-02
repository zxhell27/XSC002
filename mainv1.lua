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

-- --- Tabel Konfigurasi Timer (Dari skrip Anda, DENGAN NILAI BARU DARI ANDA) ---
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
        ScreenGui.Parent = coreGuiService; ScreenGui.Name = "ZXHELL_ZEDLIST_UI_Container"
    end
    if not Frame.Parent or Frame.Parent ~= ScreenGui then Frame.Parent = ScreenGui end
    if not StartButton.Parent or StartButton.Parent ~= Frame then StartButton.Parent = Frame end
    if not StatusLabel.Parent or StatusLabel.Parent ~= Frame then StatusLabel.Parent = Frame end
end
setupCoreGuiParenting() 

-- // --- DESAIN ULANG UI TOTAL (MODIFIKASI PROPERTI ELEMEN YANG ADA) --- //
Frame.Name = "ZXMainFrame"
Frame.Size = UDim2.new(0, 320, 0, 500) -- Ukuran disesuaikan
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2) 
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Latar belakang sangat gelap
Frame.Active = true 
Frame.Draggable = true 
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(180, 0, 0) -- Aksen merah kuat

local UiTitleLabel = Instance.new("TextLabel") -- Tetap Instance.new karena ini elemen asli dari skrip Anda
UiTitleLabel.Name = "UiTitleLabel_ZXHELL_ZEDLIST"
UiTitleLabel.Parent = Frame
UiTitleLabel.Size = UDim2.new(1, 0, 0, 50) -- Lebih tinggi untuk efek
UiTitleLabel.Position = UDim2.new(0, 0, 0, 0) 
UiTitleLabel.Font = Enum.Font.Michroma -- Font futuristik/gaming
UiTitleLabel.Text = "ZXHELL X ZEDLIST"
UiTitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50) 
UiTitleLabel.TextScaled = false
UiTitleLabel.TextSize = 32
UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
UiTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
UiTitleLabel.BackgroundTransparency = 1
UiTitleLabel.ZIndex = 3 -- Di atas efek latar
UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
UiTitleLabel.TextStrokeTransparency = 0.3

local yOffsetForControls = 60 

StartButton.Name = "Control_StartButton"
StartButton.Size = UDim2.new(1, -40, 0, 45) 
StartButton.Position = UDim2.new(0, 20, 0, yOffsetForControls)
StartButton.Text = "[[ ACTIVATE SEQUENCE ]]"
StartButton.Font = Enum.Font.Orbitron -- Font tech/futuristik
StartButton.TextSize = 18
StartButton.TextColor3 = Color3.fromRGB(200, 220, 255) -- Biru muda
StartButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35) 
StartButton.BorderSizePixel = 1
StartButton.BorderColor3 = Color3.fromRGB(80, 80, 150) -- Biru gelap untuk border

StatusLabel.Name = "Display_StatusLabel"
StatusLabel.Size = UDim2.new(1, -40, 0, 60) 
StatusLabel.Position = UDim2.new(0, 20, 0, yOffsetForControls + 55)
StatusLabel.Text = "SYSTEM STATUS: OFFLINE // WAITING COMMAND"
StatusLabel.Font = Enum.Font.ShareTechMono -- Font mono-space tech
StatusLabel.TextSize = 14
StatusLabel.TextColor3 = Color3.fromRGB(180, 255, 180) -- Hijau muda
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 15) -- Latar hijau sangat gelap
StatusLabel.TextWrapped = true 
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left 
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.PaddingLeft = UDim.new(0,5)
StatusLabel.PaddingTop = UDim.new(0,5)
StatusLabel.BorderSizePixel = 1
StatusLabel.BorderColor3 = Color3.fromRGB(50,100,50)

local yOffsetForTimersSection = yOffsetForControls + 125

local timerElements = {} 
local TimerTitleLabel = Instance.new("TextLabel")
TimerTitleLabel.Name = "Config_TimerTitle"
TimerTitleLabel.Parent = Frame
TimerTitleLabel.Size = UDim2.new(1, -40, 0, 25)
TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffsetForTimersSection)
TimerTitleLabel.Text = "TIMER_CONFIGURATION_MATRIX:"
TimerTitleLabel.Font = Enum.Font.NovaMono
TimerTitleLabel.TextSize = 15
TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100) 
TimerTitleLabel.BackgroundTransparency = 1
TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local function createTimerInput(name, yPos, labelText, timerKey)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = Frame
    label.Size = UDim2.new(0.6, -25, 0, 22)
    label.Position = UDim2.new(0, 20, 0, yPos + yOffsetForTimersSection)
    label.Text = labelText .. ":"
    label.Font = Enum.Font.ShareTechMono
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(170, 170, 190)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    timerElements[name .. "Label"] = label

    local input = Instance.new("TextBox")
    input.Name = name .. "Input"
    input.Parent = Frame
    input.Size = UDim2.new(0.4, -25, 0, 22)
    input.Position = UDim2.new(0.6, 5, 0, yPos + yOffsetForTimersSection)
    input.Text = tostring(timers[timerKey])
    input.PlaceholderText = "s"
    input.Font = Enum.Font.NovaMono
    input.TextSize = 14
    input.TextColor3 = Color3.fromRGB(230, 230, 255)
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    input.ClearTextOnFocus = false
    input.BorderColor3 = Color3.fromRGB(80, 80, 100)
    input.BorderSizePixel = 1
    timerElements[name .. "Input"] = input
    return input 
end

local currentYConfigTimers = 30 
timerElements.wait1m30sInput = createTimerInput("Wait1m30s", currentYConfigTimers, "T_PASC_ITEM1", "wait_1m30s_after_first_items")
currentYConfigTimers = currentYConfigTimers + 28
timerElements.wait40sInput = createTimerInput("Wait40s", currentYConfigTimers, "T_ITEM2_QI_PAUSE", "alur_wait_40s_hide_qi")
currentYConfigTimers = currentYConfigTimers + 28
timerElements.comprehendInput = createTimerInput("Comprehend", currentYConfigTimers, "T_COMPREHEND_DUR", "comprehend_duration")
currentYConfigTimers = currentYConfigTimers + 28
timerElements.postComprehendQiInput = createTimerInput("PostComprehendQi", currentYConfigTimers, "T_POST_COMP_QI_DUR", "post_comprehend_qi_duration")
currentYConfigTimers = currentYConfigTimers + 38 

local ApplyTimersButton = Instance.new("TextButton")
ApplyTimersButton.Name = "Config_ApplyTimersButton"
ApplyTimersButton.Parent = Frame
ApplyTimersButton.Size = UDim2.new(1, -40, 0, 35)
ApplyTimersButton.Position = UDim2.new(0, 20, 0, currentYConfigTimers + yOffsetForTimersSection)
ApplyTimersButton.Text = "[[ APPLY TIMER OVERRIDES ]]"
ApplyTimersButton.Font = Enum.Font.Orbitron
ApplyTimersButton.TextSize = 15
ApplyTimersButton.TextColor3 = Color3.fromRGB(200, 255, 200)
ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(20, 60, 20) 
ApplyTimersButton.BorderColor3 = Color3.fromRGB(80, 180, 80)
ApplyTimersButton.BorderSizePixel = 1
timerElements.ApplyButton = ApplyTimersButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Control_MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 30, 0, 30) 
MinimizeButton.Position = UDim2.new(1, -40, 0, 10) 
MinimizeButton.Text = "_" 
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 22
MinimizeButton.TextColor3 = Color3.fromRGB(150, 150, 180)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MinimizeButton.BorderColor3 = Color3.fromRGB(80,80,100)
MinimizeButton.BorderSizePixel = 1
MinimizeButton.ZIndex = 3 

local isMinimized = false
local originalFrameSize = Frame.Size 
local minimizedPopupSize = UDim2.fromOffset(80, 80) -- Ukuran "pop-up" petir saat minimize
local minimizedPopupIconText = "⚡" -- Simbol petir untuk pop-up

local elementsToHideOnMinimize = {
    StartButton, StatusLabel, TimerTitleLabel, ApplyTimersButton,
    timerElements.Wait1m30sLabel, timerElements.wait1m30sInput,
    timerElements.Wait40sLabel, timerElements.wait40sInput,
    timerElements.ComprehendLabel, timerElements.comprehendInput,
    timerElements.PostComprehendQiLabel, timerElements.postComprehendQiInput
}
-- Sebagian besar UiTitleLabel juga akan disembunyikan, diganti ikon
-- // --- END DESAIN ULANG UI TOTAL --- //

-- // Fungsi tunggu (Struktur Asli Dipertahankan) //
local function waitSeconds(sec)
    if sec <= 0 then task.wait() return end 
    local startTime = tick()
    repeat task.wait() until not scriptRunning or tick() - startTime >= sec
end

-- Fungsi fireRemoteEnhanced (Dari skrip Anda)
local function fireRemoteEnhanced(remoteName, pathType, ...)
    local argsToUnpack = table.pack(...)
    local remoteEventFolder; local success = false; local errMessage = "Unknown error"
    local pcallSuccess, pcallResult = pcall(function()
        if pathType == "AreaEvents" then remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9)
        else remoteEventFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9) end
        local remote = remoteEventFolder:WaitForChild(remoteName, 9e9)
        remote:FireServer(table.unpack(argsToUnpack, 1, argsToUnpack.n))
    end)
    if pcallSuccess then success = true
    else errMessage = tostring(pcallResult)
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: ERR_REMOTE_" .. string.upper(remoteName) end
        print("Error firing " .. remoteName .. ": " .. errMessage); success = false
    end
    return success
end

-- // Fungsi utama (Struktur Asli Dipertahankan) //
local function runCycle()
	local function updateStatus(text) 
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: " .. string.upper(text):gsub("_"," ") end
	end
	updateStatus("Reincarnating_Proc")
	if not fireRemoteEnhanced("Reincarnate", "Base", {}) then scriptRunning = false; return end
    task.wait(timers.reincarnateDelay) 
	if not scriptRunning then return end 
	updateStatus("Item_Set1_Prep")
	waitSeconds(timers.user_script_wait1_before_items1) 
	if not scriptRunning then return end
	local item1 = {"Nine Heavens Galaxy Water", "Buzhou Divine Flower", "Fusang Divine Tree", "Calm Cultivation Mat"}
	for _, item in ipairs(item1) do
		if not scriptRunning then return end 
		updateStatus("Buying: " .. item:sub(1,12).."...")
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay) 
	end
	if not scriptRunning then return end
	updateStatus("Map_Change_Prep")
	waitSeconds(timers.wait_1m30s_after_first_items) 
	if not scriptRunning then return end
	local function changeMap(name) return fireRemoteEnhanced("ChangeMap", "AreaEvents", name) end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay); updateStatus("Map_Target: Immortal")
	if not scriptRunning then return end
	if not changeMap("chaos") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay); updateStatus("Map_Target: Chaos")
	if not scriptRunning then return end
	updateStatus("Chaotic_Road_Proc")
	if not fireRemoteEnhanced("ChaoticRoad", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay) 
	if not scriptRunning then return end
	updateStatus("Item_Set2_Prep")
	pauseUpdateQiTemporarily = true 
	updateStatus("QI_Update_Paused (" .. timers.alur_wait_40s_hide_qi .. "s)") 
	waitSeconds(timers.alur_wait_40s_hide_qi) 
	pauseUpdateQiTemporarily = false 
	updateStatus("QI_Update_Resumed")
	if not scriptRunning then return end
	local item2 = {"Traceless Breeze Lotus", "Reincarnation World Destruction Black Lotus", "Ten Thousand Bodhi Tree"}
	for _, item in ipairs(item2) do
		if not scriptRunning then return end
		updateStatus("Buying: " .. item:sub(1,12).."...")
		if not fireRemoteEnhanced("BuyItem", "Base", item) then scriptRunning = false; return end
		task.wait(timers.buyItemDelay)
	end
	if not scriptRunning then return end
	if not changeMap("immortal") then scriptRunning = false; return end
	task.wait(timers.changeMapDelay); updateStatus("Map_Target: Immortal_Return")
	if not scriptRunning then return end
	if scriptRunning and not stopUpdateQi and not pauseUpdateQiTemporarily then
		updateStatus("HiddenRemote_Proc (QI_Active)")
		if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then scriptRunning = false; return end
	else updateStatus("HiddenRemote_Skip (QI_Inactive)") end
	task.wait(timers.genericShortDelay) 
    updateStatus("Forbidden_Zone_Prep (Direct)")
	if not scriptRunning then return end
	updateStatus("Forbidden_Zone_Enter")
	if not fireRemoteEnhanced("ForbiddenZone", "AreaEvents", {}) then scriptRunning = false; return end
	task.wait(timers.genericShortDelay) 
	if not scriptRunning then return end
	updateStatus("Comprehend_Proc (" .. timers.comprehend_duration .. "s)")
	stopUpdateQi = true 
	local comprehendStartTime = tick()
	while scriptRunning and (tick() - comprehendStartTime < timers.comprehend_duration) do
		if not fireRemoteEnhanced("Comprehend", "Base", {}) then updateStatus("Comprehend_Event_Fail"); break end
        updateStatus(string.format("Comprehending... %ds Left", math.floor(timers.comprehend_duration - (tick() - comprehendStartTime))))
		task.wait(1) 
	end
    if not scriptRunning then return end; updateStatus("Comprehend_Complete")
    if scriptRunning then
        updateStatus("Post_Comprehend_Hidden_Proc")
        if not fireRemoteEnhanced("HiddenRemote", "AreaEvents", {}) then updateStatus("Post_Comp_Hidden_Fail") end
        task.wait(timers.genericShortDelay) 
    end
	if not scriptRunning then return end
	updateStatus("Final_QI_Update (" .. timers.post_comprehend_qi_duration .. "s)")
	stopUpdateQi = false 
    local postComprehendQiStartTime = tick()
    while scriptRunning and (tick() - postComprehendQiStartTime < timers.post_comprehend_qi_duration) do
        if stopUpdateQi then updateStatus("Post_Comp_QI_Halt"); break end
        updateStatus(string.format("Post_Comp_QI_Active... %ds Left", math.floor(timers.post_comprehend_qi_duration - (tick() - postComprehendQiStartTime))))
        task.wait(1)
    end
    if not scriptRunning then return end; stopUpdateQi = true 
	updateStatus("Cycle_Complete_Reinitializing")
end

-- Loop Latar Belakang (Dari skrip Anda)
local function increaseAptitudeMineLoop_enhanced()
    while scriptRunning do 
        fireRemoteEnhanced("IncreaseAptitude", "Base", {}); task.wait(timers.aptitudeMineInterval) 
        if not scriptRunning then break end
        fireRemoteEnhanced("Mine", "Base", {}); task.wait() 
    end
end
local function updateQiLoop_enhanced()
    while scriptRunning do 
        if not stopUpdateQi and not pauseUpdateQiTemporarily then fireRemoteEnhanced("UpdateQi", "Base", {}) end
        task.wait(timers.updateQiInterval) 
    end
end

-- Tombol Start (Dari skrip Anda)
StartButton.MouseButton1Click:Connect(function()
    scriptRunning = not scriptRunning 
    if scriptRunning then
        StartButton.Text = "[[ SYSTEM_ACTIVE ]]"
        StartButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        StartButton.TextColor3 = Color3.fromRGB(255,255,255)
        if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: SEQUENCE_INITIATED" end
        stopUpdateQi = false; pauseUpdateQiTemporarily = false
        if not aptitudeMineThread or coroutine.status(aptitudeMineThread) == "dead" then aptitudeMineThread = spawn(increaseAptitudeMineLoop_enhanced) end
        if not updateQiThread or coroutine.status(updateQiThread) == "dead" then updateQiThread = spawn(updateQiLoop_enhanced) end
        if not mainCycleThread or coroutine.status(mainCycleThread) == "dead" then
            mainCycleThread = spawn(function()
                while scriptRunning do runCycle() 
                    if not scriptRunning then break end
                    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: CYCLE_REINITIALIZING..." end
                    task.wait(1) 
                end
                if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: SYSTEM_HALTED // STANDBY" end
                StartButton.Text = "[[ ACTIVATE SEQUENCE ]]"
                StartButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                StartButton.TextColor3 = Color3.fromRGB(200,220,255)
            end)
        end
    else if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "STATUS: DEACTIVATION_REQUESTED..." end
    end
end)

-- Tombol Apply Timers (Dari skrip Anda)
ApplyTimersButton.MouseButton1Click:Connect(function()
    local function applyTextInput(inputElement, timerKey, labelElement)
        local success = false; if not inputElement then return false end 
        local value = tonumber(inputElement.Text)
        if value and value >= 0 then timers[timerKey] = value
            if labelElement then pcall(function() labelElement.TextColor = Color3.fromRGB(80,255,80) end) end; success = true
        else if labelElement then pcall(function() labelElement.TextColor = Color3.fromRGB(255,80,80) end) end end
        return success
    end
    local allTimersValid = true
    allTimersValid = applyTextInput(timerElements.wait1m30sInput, "wait_1m30s_after_first_items", timerElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.wait40sInput, "alur_wait_40s_hide_qi", timerElements.Wait40sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.comprehendInput, "comprehend_duration", timerElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.postComprehendQiInput, "post_comprehend_qi_duration", timerElements.PostComprehendQiLabel) and allTimersValid
    local originalStatus = StatusLabel.Text:gsub("STATUS: ", "")
    if allTimersValid then updateStatus("TIMER_CONFIG_APPLIED") else updateStatus("ERR_TIMER_INPUT_INVALID") end
    task.wait(2) 
    if timerElements.Wait1m30sLabel then pcall(function() timerElements.Wait1m30sLabel.TextColor = Color3.fromRGB(170,170,190) end) end
    if timerElements.Wait40sLabel then pcall(function() timerElements.Wait40sLabel.TextColor = Color3.fromRGB(170,170,190) end) end
    if timerElements.ComprehendLabel then pcall(function() timerElements.ComprehendLabel.TextColor = Color3.fromRGB(170,170,190) end) end
    if timerElements.PostComprehendQiLabel then pcall(function() timerElements.PostComprehendQiLabel.TextColor = Color3.fromRGB(170,170,190) end) end
    updateStatus(originalStatus) 
end)

-- --- MODIFIED: Logika untuk Tombol Minimize menjadi Pop-up Petir ---
local originalUiTitleText = UiTitleLabel.Text -- Simpan teks asli title
local originalUiTitleSize = UiTitleLabel.TextSize

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "□" -- Simbol maximize
        originalFrameSize = Frame.Size -- Simpan ukuran saat ini sebelum minimize
        Frame.Size = minimizedPopupSize
        Frame.Position = UDim2.new(0.05, 0, 0.5, -minimizedPopupSize.Y.Offset/2) -- Posisi pop-up di kiri tengah
        
        -- Sembunyikan semua elemen kecuali tombol minimize dan title (yang akan jadi ikon)
        for _, element in ipairs(elementsToHideOnMinimize) do
            if element and element.Parent then element.Visible = false end
        end
        UiTitleLabel.Text = minimizedPopupIconText -- Ganti teks title menjadi ikon petir
        UiTitleLabel.TextSize = 48 -- Ukuran ikon besar
        UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
        UiTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
        UiTitleLabel.Size = UDim2.new(1,0,1,0) -- Penuhi pop-up
        UiTitleLabel.Position = UDim2.new(0,0,0,0)
        UiTitleLabel.Visible = true

        MinimizeButton.Position = UDim2.new(1, -MinimizeButton.AbsoluteSize.X - 2, 0, 2) -- Pojok kanan atas pop-up
        MinimizeButton.ZIndex = UiTitleLabel.ZIndex + 1
    else
        MinimizeButton.Text = "_" 
        Frame.Size = originalFrameSize 
        Frame.Position = UDim2.new(0.5, -originalFrameSize.X.Offset/2, 0.5, -originalFrameSize.Y.Offset/2) -- Kembalikan ke tengah
        for _, element in ipairs(elementsToHideOnMinimize) do
            if element and element.Parent then element.Visible = true end
        end
        UiTitleLabel.Text = originalUiTitleText -- Kembalikan teks asli title
        UiTitleLabel.TextSize = 32 -- Kembalikan ukuran asli title
        UiTitleLabel.Size = UDim2.new(1, -20, 0, 40)
        UiTitleLabel.Position = UDim2.new(0, 10, 0, 10) 
        UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
        UiTitleLabel.TextYAlignment = Enum.TextYAlignment.Center

        MinimizeButton.Position = UDim2.new(1, -35, 0, 10) -- Posisi asli di frame besar
    end
end)
-- --- END MODIFIED ---

-- --- ANIMASI UI BARU (CANGGIH & PENUH ANIMASI) ---
spawn(function() -- Animasi Latar Belakang Frame (Glitchy Background & Border)
    if not Frame or not Frame.Parent then return end
    local baseBgColor = Color3.fromRGB(10, 10, 15)
    local glitchBgColors = {Color3.fromRGB(25, 10, 10), Color3.fromRGB(10, 25, 10), Color3.fromRGB(10, 10, 25), Color3.fromRGB(5,5,5)}
    local baseBorderColor = Color3.fromRGB(180, 0, 0)
    local glitchBorderColors = {Color3.fromRGB(255,80,80), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255)}
    local borderHue = 0

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then -- Hanya animasikan latar jika tidak minimize
            local r = math.random()
            if r < 0.03 then -- Glitch BG intens
                Frame.BackgroundColor3 = glitchBgColors[math.random(#glitchBgColors)]
                task.wait(0.03 + math.random()*0.04)
                Frame.BackgroundColor3 = baseBgColor
            elseif r < 0.1 then -- Glitch BG ringan
                Frame.BackgroundColor3 = Color3.Lerp(baseBgColor, glitchBgColors[math.random(#glitchBgColors)], math.random()*0.5)
                task.wait(0.1 + math.random()*0.1)
            else
                Frame.BackgroundColor3 = Color3.Lerp(Frame.BackgroundColor3, baseBgColor, 0.2)
            end
            -- Animasi border RGB
            borderHue = (borderHue + 0.01) % 1
            Frame.BorderColor3 = Color3.fromHSV(borderHue, 0.9, 0.9)
        else -- Animasi "Pop-up Petir Merah Menyambar" saat minimize
            local flashSpeed = 0.05 + math.random()*0.05
            Frame.BackgroundColor3 = Color3.fromRGB(math.random(150,255), 0, 0) -- Kilatan Merah
            UiTitleLabel.TextColor3 = Color3.fromRGB(255, math.random(150,255), math.random(150,255)) -- Ikon Petir Berkedip
            task.wait(flashSpeed)
            Frame.BackgroundColor3 = Color3.fromRGB(math.random(50,100),0,0)
            UiTitleLabel.TextColor3 = Color3.fromRGB(255, math.random(50,100), math.random(50,100))
            task.wait(flashSpeed)
        end
        task.wait(0.03) -- Yield umum
    end
end)

spawn(function() -- Animasi UiTitleLabel (ZXHELL X ZEDLIST - Petir, Glitch, RGB)
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText = "ZXHELL X ZEDLIST"
    local glitchChars = {"Z", "X", "H", "E", "L", "D", "S", "T", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+"}
    local originalPos = UiTitleLabel.Position
    local originalRot = UiTitleLabel.Rotation
    local lightningFlashColor = Color3.fromRGB(255,255,200) -- Kuning pucat untuk petir

    local function generateGlitchText(text)
        local newText = ""
        for i = 1, #text do
            if math.random() < 0.15 then -- Peluang karakter di-glitch
                newText = newText .. glitchChars[math.random(#glitchChars)]
            else
                newText = newText .. text:sub(i,i)
            end
        end
        return newText
    end

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then -- Animasi title normal jika tidak minimize
            UiTitleLabel.Position = originalPos -- Reset posisi dulu
            UiTitleLabel.Rotation = originalRot

            local randAction = math.random()
            if randAction < 0.02 then -- Efek "Sambaran Petir" pada Teks (2% chance)
                local oldColor = UiTitleLabel.TextColor3
                UiTitleLabel.TextColor3 = lightningFlashColor
                UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(255,255,255)
                UiTitleLabel.TextStrokeTransparency = 0
                task.wait(0.05)
                UiTitleLabel.TextColor3 = oldColor
                UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
                UiTitleLabel.TextStrokeTransparency = 0.3
                task.wait(0.05)
                 UiTitleLabel.TextColor3 = lightningFlashColor
                task.wait(0.03)
                UiTitleLabel.TextColor3 = oldColor
            elseif randAction < 0.1 then -- Efek Glitch Teks & Posisi (8% chance)
                UiTitleLabel.Text = generateGlitchText(originalText)
                UiTitleLabel.Position = originalPos + UDim2.fromOffset(math.random(-2,2), math.random(-1,1))
                UiTitleLabel.Rotation = math.random(-10,10) * 0.05
                UiTitleLabel.TextColor3 = Color3.fromHSV(math.random(), 1,1) -- Warna acak saat glitch
            else -- Animasi Warna RGB Merah Halus
                UiTitleLabel.Text = originalText
                local hue = (tick() * 0.2) % 1 
                local r,g,b = Color3.fromHSV(hue, 1, 1).R, Color3.fromHSV(hue, 1, 1).G, Color3.fromHSV(hue, 1, 1).B
                r = math.min(1, r + 0.7) -- Dominasi Merah Kuat
                g = g * 0.3
                b = b * 0.3
                UiTitleLabel.TextColor3 = Color3.new(r,g,b)
                UiTitleLabel.Position = originalPos -- Kembalikan ke posisi normal
                UiTitleLabel.Rotation = originalRot
            end
        else
            -- Saat minimize, title menjadi ikon petir dan dianimasikan oleh loop Frame BG
            -- jadi tidak perlu animasi tambahan di sini kecuali jika ingin berbeda
        end
        task.wait(0.05 + math.random() * 0.05) -- Interval update animasi title
    end
end)

spawn(function() -- Animasi Tombol (Hover & Active)
    local buttons = {StartButton, ApplyTimersButton, MinimizeButton}
    local originalColors = {}
    for _, btn in ipairs(buttons) do
        if btn and btn.Parent then
            originalColors[btn] = {bg = btn.BackgroundColor3, border = btn.BorderColor3, text = btn.TextColor3}
        end
    end

    while ScreenGui and ScreenGui.Parent do
        for _, btn in ipairs(buttons) do
            if btn and btn.Parent and btn.Active and btn.Visible then -- Hanya jika aktif dan terlihat
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local isHovering = btn:IsA("GuiButton") and btn.AbsolutePosition.X <= mouse.X and mouse.X <= btn.AbsolutePosition.X + btn.AbsoluteSize.X and
                                 btn.AbsolutePosition.Y <= mouse.Y and mouse.Y <= btn.AbsolutePosition.Y + btn.AbsoluteSize.Y
                
                local targetBgColor, targetBorderColor, targetTextColor
                
                if btn == StartButton and scriptRunning then
                    targetBgColor = Color3.fromRGB(255, 20, 20) -- Merah terang saat running
                    targetBorderColor = Color3.fromRGB(255, 150, 150)
                    targetTextColor = Color3.fromRGB(255,255,255)
                elseif isHovering then
                    targetBgColor = originalColors[btn].bg:Lerp(Color3.new(1,1,1), 0.2) -- Lebih terang
                    targetBorderColor = originalColors[btn].border:Lerp(Color3.new(1,1,1), 0.4)
                    targetTextColor = originalColors[btn].text:Lerp(Color3.new(0,0,0), 0.1)
                else
                    targetBgColor = originalColors[btn].bg
                    targetBorderColor = originalColors[btn].border
                    targetTextColor = originalColors[btn].text
                end
                
                btn.BackgroundColor3 = btn.BackgroundColor3:Lerp(targetBgColor, 0.2)
                btn.BorderColor3 = btn.BorderColor3:Lerp(targetBorderColor, 0.2)
                btn.TextColor3 = btn.TextColor3:Lerp(targetTextColor, 0.2)
            end
        end
        task.wait(0.03)
    end
end)
-- --- END ANIMASI UI BARU ---

-- BindToClose (Dari skrip Anda)
game:BindToClose(function()
    if scriptRunning then print("Game ditutup, menghentikan skrip..."); scriptRunning = false; task.wait(0.5) end
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    print("Pembersihan skrip selesai.")
end)

-- Inisialisasi (Dari skrip Anda)
print("Skrip Otomatisasi (Versi UI Canggih & Animasi Penuh) Telah Dimuat.")
task.wait(1)
if ScreenGui and not ScreenGui.Parent then print("Mencoba memparentkan UI ke CoreGui lagi..."); setupCoreGuiParenting() end
if StatusLabel and StatusLabel.Parent and StatusLabel.Text == "" then StatusLabel.Text = "SYSTEM STATUS: OFFLINE // WAITING COMMAND" end
