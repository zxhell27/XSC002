-- LocalScript dalam TextButton
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local rs = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local remote = replicatedStorage.Remotes.Chunks.damageBlock

-- Konfigurasi
local isActive = false
local currentTarget = nil
local BUTTON_ON_COLOR = Color3.fromRGB(0, 255, 100)
local BUTTON_OFF_COLOR = Color3.fromRGB(255, 50, 50)

local button = script.Parent

-- Fungsi Mencari Target Terdekat dengan MaterialVariant
local function findTarget()
    local blocks = workspace.Blocks:GetChildren()
    local closestDist = math.huge
    local selected = nil

    for _, block in ipairs(blocks) do
        -- Memastikan objek memiliki properti MaterialVariant dan tidak kosong
        local success, variant = pcall(function() return block.MaterialVariant end)
        if success and variant ~= "" then
            local dist = (player.Character.HumanoidRootPart.Position - block.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                selected = block
            end
        end
    end
    return selected
end

-- Logika Utama Loop
task.spawn(function()
    while true do
        if isActive then
            if not currentTarget or not currentTarget.Parent then
                currentTarget = findTarget()
            end

            if currentTarget then
                -- 1. Hadapkan karakter ke target (Opsional tapi lebih aman dari Anticheat)
                player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, currentTarget.Position)
                
                -- 2. Kirim sinyal Damage (Sesuai Remote Anda)
                remote:FireServer(currentTarget)

                -- 3. Simulasi 'Hold' (Jika server butuh durasi, kita loop remote ini)
                -- Catatan: Jika server butuh mouse click asli, Anda memerlukan VirtualInputManager
                -- Namun biasanya Remote cukup dipanggil berulang kali.
            end
        end
        task.wait(0.1) -- Delay untuk stabilitas
    end
end)

-- Deteksi Drop & Teleport Otomatis
workspace.Drops.ChildAdded:Connect(function(child)
    if isActive then
        -- Tunggu sejenak agar part benar-benar muncul
        task.wait(0.1)
        if child:IsA("BasePart") then
            -- Teleport part ke posisi pemain agar otomatis terambil
            child.CFrame = player.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- Toggle Button
button.MouseButton1Click:Connect(function()
    isActive = not isActive
    button.Text = isActive and "AUTOFARM: ON" or "AUTOFARM: OFF"
    button.BackgroundColor3 = isActive and BUTTON_ON_COLOR or BUTTON_OFF_COLOR
    
    if not isActive then currentTarget = nil end
end)
