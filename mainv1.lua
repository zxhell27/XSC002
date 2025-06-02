--[[
    ZXHELL X ZEDLIST - Enhanced UI & Animation Overhaul
    Client-Side Automation Script for Roblox
    (Versi dengan penyesuaian parenting UI)
]]

-- // Layanan Roblox //
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
-- CoreGui akan diakses secara langsung atau melalui Players.LocalPlayer.PlayerGui
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Tetap menggunakan GetService untuk ini

-- ... (SEMUA variabel state, tabel timers, variabel UI global lainnya tetap sama seperti skrip terakhir) ...
-- local ScreenGui, Frame, StartButton, StatusLabel -- dideklarasikan global
-- local UiTitleLabel, TimerTitleLabel, ApplyTimersButton, MinimizeButton
-- local ComprehendInput, PostComprehendQiInput 
-- local timerElements = {} 
-- local BackgroundGlitchFrame 
-- local MinimizedPopupFrame
-- local isMinimized = false
-- local originalFrameSize, originalFramePosition

-- // Fungsi Setup UI (Akan membuat SEMUA elemen UI) //
local function CreateAdvancedUI()
    if ScreenGui and ScreenGui.Parent then 
        pcall(function() ScreenGui:Destroy() end) 
    end 

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZXHELL_ZEDLIST_AdvancedUI_TEMP" -- Nama sementara hingga berhasil diparentkan
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    -- Parenting akan dilakukan di akhir fungsi ini

    -- 1. Latar Belakang Glitch "ZXHELL"
    BackgroundGlitchFrame = Instance.new("Frame")
    BackgroundGlitchFrame.Name = "BackgroundGlitch"
    BackgroundGlitchFrame.Parent = ScreenGui -- Parent ke ScreenGui dulu
    BackgroundGlitchFrame.Size = UDim2.new(1, 0, 1, 0)
    BackgroundGlitchFrame.Position = UDim2.new(0, 0, 0, 0)
    BackgroundGlitchFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    BackgroundGlitchFrame.BackgroundTransparency = 0.85 
    BackgroundGlitchFrame.ZIndex = 0 

    local BackgroundGlitchText = Instance.new("TextLabel")
    BackgroundGlitchText.Name = "GlitchTextOverlay"
    BackgroundGlitchText.Parent = BackgroundGlitchFrame
    BackgroundGlitchText.Size = UDim2.new(1, 0, 1, 0)
    BackgroundGlitchText.Text = string.rep("ZXHELL ERR ", 100) 
    BackgroundGlitchText.Font = Enum.Font.Code
    BackgroundGlitchText.TextSize = 30
    BackgroundGlitchText.TextColor3 = Color3.fromRGB(100, 0, 0) 
    BackgroundGlitchText.TextWrapped = true
    BackgroundGlitchText.TextXAlignment = Enum.TextXAlignment.Center
    BackgroundGlitchText.TextYAlignment = Enum.TextYAlignment.Center
    BackgroundGlitchText.BackgroundTransparency = 1
    BackgroundGlitchText.TextTransparency = 0.7 

    -- 2. Frame Utama Kontrol
    Frame = Instance.new("Frame")
    Frame.Name = "ZXMainControlFrame"
    Frame.Parent = ScreenGui -- Parent ke ScreenGui dulu
    Frame.Size = UDim2.new(0, 340, 0, 520)
    Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.5, -Frame.Size.Y.Offset/2)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.Active = true
    Frame.Draggable = true
    Frame.BorderSizePixel = 0 
    Frame.ZIndex = 1

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 12)
    FrameCorner.Parent = Frame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(255, 0, 0)
    FrameStroke.Thickness = 2
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FrameStroke.Parent = Frame

    local FrameGradient = Instance.new("UIGradient")
    FrameGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30,10,10)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40,15,25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30,10,10))
    })
    FrameGradient.Rotation = 45
    FrameGradient.Parent = Frame

    -- 3. Title UI "ZXHELL X ZEDLIST"
    UiTitleLabel = Instance.new("TextLabel")
    UiTitleLabel.Name = "UiTitle_ZXHELL_ZEDLIST"
    UiTitleLabel.Parent = Frame
    UiTitleLabel.Size = UDim2.new(1, 0, 0, 60)
    UiTitleLabel.Position = UDim2.new(0,0,0,0)
    UiTitleLabel.Font = Enum.Font.Michroma
    UiTitleLabel.Text = "ZXHELL X ZEDLIST"
    UiTitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    UiTitleLabel.TextSize = 30
    UiTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    UiTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    UiTitleLabel.BackgroundTransparency = 1
    UiTitleLabel.ZIndex = Frame.ZIndex + 1
    UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(100,0,0)
    UiTitleLabel.TextStrokeTransparency = 0.2

    local yOffset = 70 

    -- 4. Tombol Start/Stop
    StartButton = Instance.new("TextButton")
    StartButton.Name = "Control_StartButton"
    StartButton.Parent = Frame
    StartButton.Size = UDim2.new(1, -40, 0, 45)
    StartButton.Position = UDim2.new(0, 20, 0, yOffset)
    StartButton.Font = Enum.Font.Orbitron
    StartButton.Text = "[[ INITIALIZE SEQUENCE ]]"
    StartButton.TextSize = 18
    StartButton.TextColor3 = Color3.fromRGB(220, 200, 255)
    StartButton.BackgroundColor3 = Color3.fromRGB(40, 20, 60) 
    StartButton.ZIndex = Frame.ZIndex + 1
    local sbCorner = Instance.new("UICorner"); sbCorner.Parent = StartButton;
    local sbStroke = Instance.new("UIStroke"); sbStroke.Color = Color3.fromRGB(150,80,200); sbStroke.Thickness = 1.5; sbStroke.Parent = StartButton

    yOffset = yOffset + StartButton.Size.Y.Offset + 15

    -- 5. Status Label
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Display_StatusLabel"
    StatusLabel.Parent = Frame
    StatusLabel.Size = UDim2.new(1, -40, 0, 65)
    StatusLabel.Position = UDim2.new(0, 20, 0, yOffset)
    StatusLabel.Font = Enum.Font.ShareTechMono
    StatusLabel.Text = "SYSTEM STATUS: AWAITING INITIALIZATION..."
    StatusLabel.TextSize = 14
    StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150) 
    StatusLabel.BackgroundColor3 = Color3.fromRGB(10,25,10)
    StatusLabel.TextWrapped = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.PaddingLeft = UDim.new(0,8); StatusLabel.PaddingTop = UDim.new(0,8); StatusLabel.PaddingRight = UDim.new(0,8); StatusLabel.PaddingBottom = UDim.new(0,8)
    StatusLabel.ZIndex = Frame.ZIndex + 1
    local slCorner = Instance.new("UICorner"); slCorner.Parent = StatusLabel;
    local slStroke = Instance.new("UIStroke"); slStroke.Color = Color3.fromRGB(50,150,50); slStroke.Thickness = 1; slStroke.Parent = StatusLabel

    yOffset = yOffset + StatusLabel.Size.Y.Offset + 20

    -- 6. Konfigurasi Timer UI
    TimerTitleLabel = Instance.new("TextLabel") 
    TimerTitleLabel.Name = "Config_TimerHeader"
    TimerTitleLabel.Parent = Frame
    TimerTitleLabel.Size = UDim2.new(1, -40, 0, 25)
    TimerTitleLabel.Position = UDim2.new(0, 20, 0, yOffset)
    TimerTitleLabel.Text = "CRITICAL_TIMING_ADJUSTMENTS:"
    TimerTitleLabel.Font = Enum.Font.NovaMono
    TimerTitleLabel.TextSize = 16
    TimerTitleLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    TimerTitleLabel.BackgroundTransparency = 1
    TimerTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimerTitleLabel.ZIndex = Frame.ZIndex + 1

    yOffset = yOffset + TimerTitleLabel.Size.Y.Offset + 10
    
    timerElements = {} -- Reset tabel timerElements untuk UI baru

    local timerConfigData = {
        {name="Wait1m30s", label="T_PASC_ITEM1", key="wait_1m30s_after_first_items"},
        {name="Wait40s", label="T_ITEM2_QI_PAUSE", key="alur_wait_40s_hide_qi"},
        {name="Comprehend", label="T_COMPREHEND_DUR", key="comprehend_duration"},
        {name="PostCompQi", label="T_POST_COMP_QI_DUR", key="post_comprehend_qi_duration"}
    }

    for i, data in ipairs(timerConfigData) do
        local label = Instance.new("TextLabel")
        label.Name = data.name .. "Label"
        label.Parent = Frame
        label.Size = UDim2.new(0.6, -25, 0, 22)
        label.Position = UDim2.new(0, 20, 0, yOffset)
        label.Text = data.label .. ":"
        label.Font = Enum.Font.ShareTechMono
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(190, 190, 220)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = Frame.ZIndex + 1
        timerElements[data.name .. "Label"] = label

        local input = Instance.new("TextBox")
        input.Name = data.name .. "Input"
        input.Parent = Frame
        input.Size = UDim2.new(0.4, -25, 0, 22)
        input.Position = UDim2.new(0.6, 5, 0, yOffset)
        input.Text = tostring(timers[data.key])
        input.PlaceholderText = "sec"
        input.Font = Enum.Font.NovaMono
        input.TextSize = 14
        input.TextColor3 = Color3.fromRGB(240, 240, 255)
        input.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        input.ClearTextOnFocus = false
        input.ZIndex = Frame.ZIndex + 1
        local tiCorner = Instance.new("UICorner"); tiCorner.Parent = input;
        local tiStroke = Instance.new("UIStroke"); tiStroke.Color = Color3.fromRGB(100,100,150); tiStroke.Thickness = 1; tiStroke.Parent = input;
        timerElements[data.name .. "Input"] = input
        
        yOffset = yOffset + label.Size.Y.Offset + 8 
    end

    yOffset = yOffset + 10 

    ApplyTimersButton = Instance.new("TextButton")
    ApplyTimersButton.Name = "Config_ApplyTimersButton"
    ApplyTimersButton.Parent = Frame
    ApplyTimersButton.Size = UDim2.new(1, -40, 0, 35)
    ApplyTimersButton.Position = UDim2.new(0, 20, 0, yOffset)
    ApplyTimersButton.Font = Enum.Font.Orbitron
    ApplyTimersButton.Text = "[[ OVERRIDE_TIMERS ]]"
    ApplyTimersButton.TextSize = 16
    ApplyTimersButton.TextColor3 = Color3.fromRGB(200, 255, 200)
    ApplyTimersButton.BackgroundColor3 = Color3.fromRGB(20, 70, 20)
    ApplyTimersButton.ZIndex = Frame.ZIndex + 1
    local atbCorner = Instance.new("UICorner"); atbCorner.Parent = ApplyTimersButton;
    local atbStroke = Instance.new("UIStroke"); atbStroke.Color = Color3.fromRGB(80,200,80); atbStroke.Thickness = 1.5; atbStroke.Parent = ApplyTimersButton;

    -- 7. Tombol Minimize
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Control_MinimizeButton"
    MinimizeButton.Parent = Frame 
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -40, 0, 10) 
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Text = "_"
    MinimizeButton.TextSize = 20
    MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 200)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    MinimizeButton.ZIndex = Frame.ZIndex + 2 
    local mbCorner = Instance.new("UICorner"); mbCorner.Parent = MinimizeButton;
    local mbStroke = Instance.new("UIStroke"); mbStroke.Color = Color3.fromRGB(100,100,150); mbStroke.Thickness = 1; mbStroke.Parent = MinimizeButton;

    -- 8. Frame untuk Pop-up Minimize (Awalnya tidak terlihat)
    MinimizedPopupFrame = Instance.new("Frame")
    MinimizedPopupFrame.Name = "MinimizedLightningPopup"
    MinimizedPopupFrame.Parent = ScreenGui -- Parent ke ScreenGui dulu
    MinimizedPopupFrame.Size = UDim2.fromOffset(80, 80)
    MinimizedPopupFrame.Position = UDim2.new(0.02, 0, 0.5, -MinimizedPopupFrame.Size.Y.Offset/2) 
    MinimizedPopupFrame.BackgroundColor3 = Color3.fromRGB(150,0,0) 
    MinimizedPopupFrame.BackgroundTransparency = 0.1
    MinimizedPopupFrame.BorderSizePixel = 0
    MinimizedPopupFrame.Visible = false 
    MinimizedPopupFrame.ZIndex = 10 
    local mpfCorner = Instance.new("UICorner"); mpfCorner.CornerRadius = UDim.new(0.5,0); mpfCorner.Parent = MinimizedPopupFrame; 
    local mpfStroke = Instance.new("UIStroke"); mpfStroke.Color = Color3.fromRGB(255,50,50); mpfStroke.Thickness = 2; mpfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; mpfStroke.Parent = MinimizedPopupFrame;

    local MaximizeButton = Instance.new("TextButton") 
    MaximizeButton.Name = "Control_MaximizeButton"
    MaximizeButton.Parent = MinimizedPopupFrame
    MaximizeButton.Size = UDim2.new(1, -10, 0, 25)
    MaximizeButton.Position = UDim2.new(0, 5, 1, -30) 
    MaximizeButton.Text = "MAXIMIZE"
    MaximizeButton.Font = Enum.Font.SourceSansBold
    MaximizeButton.TextSize = 12
    MaximizeButton.TextColor3 = Color3.fromRGB(255,200,200)
    MaximizeButton.BackgroundColor3 = Color3.fromRGB(80,0,0)
    MaximizeButton.BackgroundTransparency = 0.3
    MaximizeButton.ZIndex = MinimizedPopupFrame.ZIndex + 1
    local maxBCorner = Instance.new("UICorner"); maxBCorner.CornerRadius = UDim.new(0,4); maxBCorner.Parent = MaximizeButton;
    timerElements.MaximizeButton = MaximizeButton 

    originalFrameSize = Frame.Size
    originalFramePosition = Frame.Position

    -- --- MODIFIED PARENTING SECTION ---
    local parentSuccess = false
    local finalParent = nil
    local errMessage = ""

    -- Try game.CoreGui first (direct access)
    if game and game.CoreGui then
        finalParent = game.CoreGui
    end

    -- If game.CoreGui fails or is not preferred, try PlayerGui
    if not finalParent then
        local Players = game:GetService("Players") -- This uses GetService, but is a common fallback
        if Players and Players.LocalPlayer then
            local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if PlayerGui then
                finalParent = PlayerGui
                print("UI_PARENT_INFO: Using PlayerGui.")
            else
                errMessage = "PlayerGui not found."
            end
        else
            errMessage = "Players service or LocalPlayer not found. " .. errMessage
        end
    end

    if finalParent then
        local pcallSuccessParent, pcallErrorParent = pcall(function()
            ScreenGui.Parent = finalParent
        end)
        if pcallSuccessParent then
            ScreenGui.Name = "ZXHELL_ZEDLIST_AdvancedUI_Container"
            print("CreateAdvancedUI: UI Dibuat dan Berhasil Diparentkan ke " .. finalParent.Name)
            parentSuccess = true
        else
            errMessage = "Error saat memparentkan ke " .. finalParent.Name .. ": " .. tostring(pcallErrorParent) .. ". " .. errMessage
        end
    else
        errMessage = "Tidak ditemukan parent yang valid (CoreGui atau PlayerGui). " .. errMessage
    end

    if not parentSuccess then
        print("GAGAL MEMPARENTKAN UI: " .. errMessage .. " UI tidak akan tampil.")
        pcall(function() ScreenGui:Destroy() end) -- Hapus ScreenGui jika gagal diparentkan
        return false -- Mengindikasikan kegagalan pembuatan UI
    end
    -- --- END MODIFIED PARENTING SECTION ---
    
    print("CreateAdvancedUI: UI Dibuat/Diperbarui (Sebelum parenting akhir).")
    return true -- Mengindikasikan keberhasilan pembuatan UI
end


-- ... (Sisa dari skrip: waitSeconds, fireRemoteEnhanced, runCycle, loop latar belakang, logika tombol, animasi, BindToClose tetap sama seperti versi terakhir) ...
-- Pastikan logika tombol MinimizeButton dan MaximizeButton (timerElements.MaximizeButton) dihubungkan dengan benar:

-- Di dalam CreateAdvancedUI() atau setelahnya, pastikan koneksi event untuk MaximizeButton:
if timerElements.MaximizeButton then
    timerElements.MaximizeButton.MouseButton1Click:Connect(function()
        if MinimizedPopupFrame then MinimizedPopupFrame.Visible = false end
        if Frame then Frame.Visible = true end
        isMinimized = false 
        -- Anda mungkin perlu mengatur ulang teks MinimizeButton di Frame utama di sini jika perlu
        if MinimizeButton then MinimizeButton.Text = "_" end
    end)
end

-- Modifikasi koneksi event MinimizeButton yang sudah ada:
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized -- Toggle state
    if isMinimized then
        if Frame then Frame.Visible = false end
        if MinimizedPopupFrame then MinimizedPopupFrame.Visible = true end
        -- Tombol MinimizeButton di Frame utama sekarang efektif menyembunyikan Frame utama
        -- dan menampilkan MinimizedPopupFrame. Teksnya mungkin tidak perlu diubah di sini lagi
        -- karena Frame utama disembunyikan.
    else
        -- Aksi ini sekarang ditangani oleh MaximizeButton di MinimizedPopupFrame
        if Frame then Frame.Visible = true end
        if MinimizedPopupFrame then MinimizedPopupFrame.Visible = false end
    end
end)


-- // Inisialisasi //
local uiReady = CreateAdvancedUI() -- Panggil fungsi pembuatan UI baru

if uiReady then
    if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "SYSTEM STATUS: ONLINE // STANDBY" end
    print("Skrip Otomatisasi (Versi UI MAX ANIMATION & Parenting Disesuaikan) Telah Dimuat.")
else
    print("GAGAL MEMUAT UI SKRIP OTOMATISASI.")
end

--[[
Sisa dari skrip Anda (definisi fungsi waitSeconds, fireRemoteEnhanced, runCycle, 
increaseAptitudeMineLoop_enhanced, updateQiLoop_enhanced, logika StartButton, 
logika ApplyTimersButton, semua spawn animasi, dan BindToClose) 
akan mengikuti di sini, persis seperti pada versi terakhir yang saya berikan.
Saya tidak akan menyalin ulang semua itu untuk menjaga respons ini tetap fokus pada perubahan parenting UI.
Pastikan Anda menggabungkan bagian CreateAdvancedUI() yang dimodifikasi ini dengan sisa skrip Anda yang sudah ada.
Logika inti dan animasi lainnya tidak diubah dalam snippet ini.
]]

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
        StartButton.Text = "[[ SYSTEM_PROCESSING ]]"
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
                StartButton.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
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
    allTimersValid = applyTextInput(timerElements.Wait1m30sInput, "wait_1m30s_after_first_items", timerElements.Wait1m30sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.Wait40sInput, "alur_wait_40s_hide_qi", timerElements.Wait40sLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.ComprehendInput, "comprehend_duration", timerElements.ComprehendLabel) and allTimersValid
    allTimersValid = applyTextInput(timerElements.PostComprehendQiInput, "post_comprehend_qi_duration", timerElements.PostComprehendQiLabel) and allTimersValid
    local originalStatus = StatusLabel.Text:gsub("STATUS: ", "")
    if allTimersValid then updateStatus("TIMER_CONFIG_APPLIED") else updateStatus("ERR_TIMER_INPUT_INVALID") end
    task.wait(2) 
    if timerElements.Wait1m30sLabel then pcall(function() timerElements.Wait1m30sLabel.TextColor = Color3.fromRGB(190,190,220) end) end
    if timerElements.Wait40sLabel then pcall(function() timerElements.Wait40sLabel.TextColor = Color3.fromRGB(190,190,220) end) end
    if timerElements.ComprehendLabel then pcall(function() timerElements.ComprehendLabel.TextColor = Color3.fromRGB(190,190,220) end) end
    if timerElements.PostComprehendQiLabel then pcall(function() timerElements.PostComprehendQiLabel.TextColor = Color3.fromRGB(190,190,220) end) end
    updateStatus(originalStatus) 
end)

-- --- MODIFIED: Logika Tombol Minimize untuk Pop-up Petir ---
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Frame.Visible = false -- Sembunyikan frame utama
        MinimizedPopupFrame.Visible = true -- Tampilkan pop-up petir
        -- Tombol Maximize di dalam MinimizedPopupFrame akan menangani pengembalian
    else
        -- Ini seharusnya ditangani oleh tombol Maximize di dalam MinimizedPopupFrame
        Frame.Visible = true
        MinimizedPopupFrame.Visible = false
    end
end)

if timerElements.MaximizeButton then -- Pastikan tombol Maximize ada
    timerElements.MaximizeButton.MouseButton1Click:Connect(function()
        isMinimized = false -- Set status kembali ke tidak minimize
        Frame.Visible = true
        MinimizedPopupFrame.Visible = false
    end)
end
-- --- END MODIFIED ---

-- --- ANIMASI UI BARU (CANGGIH & PENUH ANIMASI DENGAN INSTANCE BARU) ---

-- 1. Animasi Background Glitch "ZXHELL"
spawn(function()
    if not BackgroundGlitchText or not BackgroundGlitchText.Parent then return end
    local hue = 0
    while ScreenGui and ScreenGui.Parent do
        hue = (hue + 0.001) % 1
        BackgroundGlitchText.TextColor3 = Color3.fromHSV(hue, 0.5, 0.3) -- Warna glitch halus
        BackgroundGlitchText.TextTransparency = 0.7 + math.sin(tick()*2) * 0.1 -- Efek pudar
        if math.random() < 0.1 then -- Sesekali ganti posisi sedikit untuk efek glitch
            BackgroundGlitchText.Position = UDim2.new(math.random(-5,5)/100, 0, math.random(-5,5)/100, 0)
        end
        task.wait(0.05)
    end
end)

-- 2. Animasi Frame Utama (Border dan Gradient)
spawn(function()
    if not Frame or not Frame.Parent then return end
    local frameStroke = Frame:FindFirstChildOfClass("UIStroke")
    local frameGradient = Frame:FindFirstChildOfClass("UIGradient")
    local hue = 0
    local angle = 0
    while ScreenGui and ScreenGui.Parent do
        hue = (hue + 0.005) % 1
        if frameStroke then frameStroke.Color = Color3.fromHSV(hue, 1, 1) end
        if frameGradient then
            angle = (angle + 1) % 360
            frameGradient.Rotation = angle
            -- Animasi warna gradient
            local c1 = Color3.fromHSV((hue + 0.0)%1, 0.6, 0.2)
            local c2 = Color3.fromHSV((hue + 0.1)%1, 0.7, 0.25)
            frameGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(0.5, c2),
                ColorSequenceKeypoint.new(1, c1)
            })
        end
        task.wait(0.03)
    end
end)

-- 3. Animasi Title UI "ZXHELL X ZEDLIST" dengan Petir
local function createLightningBolt(parentFrame, startPos, endPos, color, thickness, duration)
    local distance = (startPos - endPos).Magnitude
    if distance == 0 then return end

    local boltFrame = Instance.new("Frame")
    boltFrame.Name = "LightningBoltSegment"
    boltFrame.Parent = parentFrame
    boltFrame.Size = UDim2.new(0, distance, 0, thickness)
    boltFrame.Position = UDim2.fromOffset((startPos.X + endPos.X)/2, (startPos.Y + endPos.Y)/2)
    boltFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    boltFrame.Rotation = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X) * (180 / math.pi)
    boltFrame.BackgroundColor3 = color
    boltFrame.BorderSizePixel = 0
    boltFrame.ZIndex = UiTitleLabel.ZIndex + 1 -- Di atas title
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, thickness/2)
    corner.Parent = boltFrame

    local tweenInfoAppear = TweenInfo.new(duration * 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tweenAppear = TweenService:Create(boltFrame, tweenInfoAppear, {BackgroundTransparency = 0.2})
    local tweenInfoFade = TweenInfo.new(duration * 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    local tweenFade = TweenService:Create(boltFrame, tweenInfoFade, {BackgroundTransparency = 1})

    tweenAppear:Play()
    tweenAppear.Completed:Connect(function()
        tweenFade:Play()
    end)
    Debris:AddItem(boltFrame, duration)
end

local function createBranchingLightning(parentFrame, originX, originY, numSegments, baseColor)
    local currentPos = Vector2.new(originX, originY)
    for i = 1, numSegments do
        local angle = math.random() * 2 * math.pi
        local length = math.random(15, 40)
        local endPos = currentPos + Vector2.new(math.cos(angle) * length, math.sin(angle) * length)
        
        -- Batasi agar petir tidak terlalu keluar dari area title
        endPos = Vector2.new(
            math.clamp(endPos.X, UiTitleLabel.AbsolutePosition.X - 20, UiTitleLabel.AbsolutePosition.X + UiTitleLabel.AbsoluteSize.X + 20),
            math.clamp(endPos.Y, UiTitleLabel.AbsolutePosition.Y - 10, UiTitleLabel.AbsolutePosition.Y + UiTitleLabel.AbsoluteSize.Y + 10)
        )
        
        -- Konversi kembali ke posisi relatif terhadap Frame utama jika parentFrame adalah Frame utama
        local relativeEndPos = endPos - parentFrame.AbsolutePosition
        local relativeCurrentPos = currentPos - parentFrame.AbsolutePosition

        createLightningBolt(parentFrame, relativeCurrentPos, relativeEndPos, baseColor, math.random(1,3), math.random(2,5)/10)
        currentPos = endPos
        if math.random() < 0.3 and i < numSegments then -- Peluang bercabang
            createBranchingLightning(parentFrame, currentPos.X, currentPos.Y, math.random(1,2), baseColor)
        end
    end
end


spawn(function() -- Animasi UiTitleLabel (Termasuk Petir)
    if not UiTitleLabel or not UiTitleLabel.Parent then return end
    local originalText = UiTitleLabel.Text
    local originalPos = UiTitleLabel.Position
    local originalRot = UiTitleLabel.Rotation
    local baseTextColor = UiTitleLabel.TextColor3
    local lightningColors = {Color3.fromRGB(255,0,0), Color3.fromRGB(255,100,0), Color3.fromRGB(200,0,200)}

    while ScreenGui and ScreenGui.Parent do
        if not isMinimized then
            UiTitleLabel.Position = originalPos
            UiTitleLabel.Rotation = originalRot
            UiTitleLabel.Text = originalText

            -- Animasi warna RGB halus pada teks
            local hue = (tick() * 0.3) % 1
            local r, g, b = Color3.fromHSV(hue, 1, 1).R, Color3.fromHSV(hue, 1, 1).G, Color3.fromHSV(hue, 1, 1).B
            r = math.min(1, r + 0.6); g = g * 0.4; b = b * 0.4; -- Dominasi merah
            UiTitleLabel.TextColor3 = Color3.new(r, g, b)
            
            -- Efek Glitch pada TextStroke
            if math.random() < 0.2 then
                UiTitleLabel.TextStrokeColor3 = Color3.fromHSV(math.random(),1,1)
                UiTitleLabel.TextStrokeTransparency = math.random()*0.4
            else
                UiTitleLabel.TextStrokeColor3 = Color3.fromRGB(50,0,0)
                UiTitleLabel.TextStrokeTransparency = 0.3
            end

            -- Animasi Petir Menyambar di Title
            if math.random() < 0.05 then -- Peluang petir muncul
                 -- Titik acak di sekitar title (relatif terhadap Frame)
                local titleAbsPos = UiTitleLabel.AbsolutePosition
                local titleAbsSize = UiTitleLabel.AbsoluteSize
                local frameAbsPos = Frame.AbsolutePosition

                local startX = titleAbsPos.X + math.random(0, titleAbsSize.X)
                local startY = titleAbsPos.Y + math.random(0, titleAbsSize.Y)
                
                createBranchingLightning(Frame, startX - frameAbsPos.X, startY - frameAbsPos.Y, math.random(3,5), lightningColors[math.random(#lightningColors)])
            end
        end
        task.wait(0.05 + math.random()*0.05)
    end
end)


-- 4. Animasi Tombol (Hover & Active)
spawn(function() 
    local buttons = {StartButton, ApplyTimersButton, MinimizeButton, timerElements.MaximizeButton}
    local originalButtonProperties = {}

    for _, btn in ipairs(buttons) do
        if btn and btn.Parent then
            originalButtonProperties[btn] = {
                bg = btn.BackgroundColor3,
                text = btn.TextColor3,
                stroke = btn:FindFirstChildOfClass("UIStroke") and btn:FindFirstChildOfClass("UIStroke").Color or nil
            }
        end
    end

    while ScreenGui and ScreenGui.Parent do
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        for _, btn in ipairs(buttons) do
            if btn and btn.Parent and btn.Visible and btn:IsA("GuiButton") then
                local isHovering = btn.AbsolutePosition.X <= mouse.X and mouse.X <= btn.AbsolutePosition.X + btn.AbsoluteSize.X and
                                 btn.AbsolutePosition.Y <= mouse.Y and mouse.Y <= btn.AbsolutePosition.Y + btn.AbsoluteSize.Y
                
                local targetBg, targetText, targetStroke
                local props = originalButtonProperties[btn]
                if not props then goto continue_button_loop end

                if btn == StartButton and scriptRunning then
                    targetBg = Color3.fromRGB(255, 60, 60)
                    targetText = Color3.fromRGB(255, 255, 255)
                    targetStroke = Color3.fromRGB(255,150,150)
                elseif isHovering then
                    targetBg = props.bg:Lerp(Color3.new(1,1,1), 0.3)
                    targetText = props.text:Lerp(Color3.new(0,0,0), 0.2)
                    if props.stroke then targetStroke = props.stroke:Lerp(Color3.new(1,1,1), 0.5) end
                else
                    targetBg = props.bg
                    targetText = props.text
                    targetStroke = props.stroke
                end
                
                btn.BackgroundColor3 = btn.BackgroundColor3:Lerp(targetBg, 0.25)
                btn.TextColor3 = btn.TextColor3:Lerp(targetText, 0.25)
                local strokeChild = btn:FindFirstChildOfClass("UIStroke")
                if strokeChild and targetStroke then
                    strokeChild.Color = strokeChild.Color:Lerp(targetStroke, 0.25)
                end
            end
            ::continue_button_loop::
        end
        task.wait(0.03)
    end
end)

-- 5. Animasi untuk MinimizedPopupFrame (Petir Merah Menyambar)
spawn(function()
    if not MinimizedPopupFrame or not MinimizedPopupFrame.Parent then return end
    local mpfStroke = MinimizedPopupFrame:FindFirstChildOfClass("UIStroke")
    local hue = 0
    local lightningActive = false
    local lightningFrames = {}

    local function createPopupLightning()
        for _, f in ipairs(lightningFrames) do if f and f.Parent then f:Destroy() end end
        table.clear(lightningFrames)
        if not MinimizedPopupFrame.Visible then return end

        local numBolts = math.random(2,4)
        for i=1, numBolts do
            local bolt = Instance.new("Frame")
            bolt.Parent = MinimizedPopupFrame
            bolt.BorderSizePixel = 0
            bolt.Size = UDim2.new(math.random(5,15)/100, 0, math.random(60,90)/100, 0) -- Persentase dari popup
            bolt.Position = UDim2.new(math.random(10,80)/100, 0, math.random(5,20)/100, 0)
            bolt.Rotation = math.random(-30,30)
            bolt.BackgroundColor3 = Color3.fromRGB(255, math.random(100,200), math.random(100,200))
            bolt.BackgroundTransparency = 0.2
            local c = Instance.new("UICorner"); c.Parent = bolt;
            table.insert(lightningFrames, bolt)
            Debris:AddItem(bolt, 0.2)
        end
    end

    while ScreenGui and ScreenGui.Parent do
        if MinimizedPopupFrame.Visible then
            hue = (hue + 0.05) % 1
            MinimizedPopupFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 0.7) -- Warna dasar merah berdenyut
            if mpfStroke then mpfStroke.Color = Color3.fromHSV((hue+0.5)%1, 1, 1) end
            
            if not lightningActive and math.random() < 0.2 then
                lightningActive = true
                createPopupLightning()
                task.wait(0.2)
                lightningActive = false
            end
        end
        task.wait(0.05)
    end
end)

-- --- END ANIMASI UI BARU ---

-- BindToClose (Dari skrip Anda)
game:BindToClose(function()
    if scriptRunning then print("Game ditutup, menghentikan skrip..."); scriptRunning = false; task.wait(0.5) end
    if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
    print("Pembersihan skrip selesai.")
end)

-- Inisialisasi
CreateAdvancedUI() -- Panggil fungsi pembuatan UI baru
if StatusLabel and StatusLabel.Parent then StatusLabel.Text = "SYSTEM STATUS: ONLINE // STANDBY" end
print("Skrip Otomatisasi (Versi UI MAX ANIMATION) Telah Dimuat.")
