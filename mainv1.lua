local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Pastikan path ReplicatedStorage benar
local replicatedStorage = game:GetService("ReplicatedStorage")
-- Menggunakan WaitForChild agar tidak error 'Not Found'
local remotesFolder = replicatedStorage:WaitForChild("Remotes", 5)
local chunksFolder = remotesFolder and remotesFolder:WaitForChild("Chunks", 5)
local damageRemote = chunksFolder and chunksFolder:WaitForChild("damageBlock", 5)

local button = script.Parent -- Pastikan script ini ADA DI DALAM TextButton
local isActive = false

-- Cek apakah remote ditemukan
if not damageRemote then
    warn("CRITICAL: Remote damageBlock tidak ditemukan! Periksa path-nya.")
end

-- Fungsi mencari target (Filter MaterialVariant)
local function getClosestBlock()
    local blocksFolder = workspace:FindFirstChild("Blocks")
    if not blocksFolder then return nil end
    
    local closest = nil
    local shortestDist = math.huge
    
    for _, block in ipairs(blocksFolder:GetChildren()) do
        -- Cek Properti MaterialVariant
        local hasVariant = pcall(function() return block.MaterialVariant end)
        if hasVariant and block.MaterialVariant ~= "" then
            local dist = (rootPart.Position - block.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = block
            end
        end
    end
    return closest
end

-- Fungsi Loop Utama
task.spawn(function()
    while task.wait(0.2) do
        if isActive and damageRemote then
            local target = getClosestBlock()
            if target then
                -- Menghadap ke target
                rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(target.Position.X, rootPart.Position.Y, target.Position.Z))
                
                -- Spam remote untuk simulasi 'Hold' (Tekan lama)
                damageRemote:FireServer(target)
            end
        end
    end
end)

-- Auto-Collect Drops (Teleport Item ke Pemain)
local dropsFolder = workspace:WaitForChild("Drops", 10)
if dropsFolder then
    dropsFolder.ChildAdded:Connect(function(item)
        if isActive and item:IsA("BasePart") then
            task.wait(0.1) -- Tunggu sebentar agar physics-nya siap
            item.CFrame = rootPart.CFrame
        end
    end)
end

-- Handle Klik Button
button.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        button.Text = "AUTOFARM: ACTIVE"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "AUTOFARM: OFF"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
