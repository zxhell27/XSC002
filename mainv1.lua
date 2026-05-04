local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TreasureRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Treasure"):WaitForChild("lootChest")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local PlaceName = game:GetService("AssetService"):GetGamePlacesAsync(game.GameId):GetCurrentPage()[1].Name

-- Variabel Global
getgenv().PlaceName = PlaceName
getgenv().AutoCollectChests = false
getgenv().collectedChests = {}
getgenv().ChestESP = false
getgenv().ChestESPInstances = {}
getgenv().ChestColor = Color3.new(0, 1, 0)
getgenv().BlockESP = false
getgenv().BlockESPInstances = {}
getgenv().BlockColor = Color3.new(0, 1, 0)
getgenv().SelectedItems = {}
getgenv().SellAmount = 1
getgenv().AutoSellEnabled = false
getgenv().AutoSellCooldown = 5

-- Setup Jendela Rayfield
local Window = Rayfield:CreateWindow({
   Name = "U N I X - " .. PlaceName,
   Icon = 0, 
   LoadingTitle = "U N I X - " .. PlaceName,
   LoadingSubtitle = "by 0x251",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "U N I X"
   },
   Discord = {
      Enabled = true,
      Invite = "2sZV8k3B97",
      RememberJoins = true
   },
})

-- Fungsi Bantuan Dasar
local function Float(character, position)
    if not character:FindFirstChild("HumanoidRootPart") then return end
    local floatVelocity = Instance.new("BodyVelocity")
    floatVelocity.Velocity = Vector3.new(0, 0, 0)
    floatVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    floatVelocity.Parent = character.HumanoidRootPart
    character.HumanoidRootPart.CFrame = CFrame.new(position)
    return floatVelocity
end

local function OpenInvite()
    local InviteCode = "2sZV8k3B97"
    local request = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
    if request then
        pcall(function()
            request({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com"
                },
                Body = HttpService:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    args = {code = InviteCode},
                    nonce = HttpService:GenerateGUID(false)
                })
            })
        end)
    end
end

-- Panggil HTTP request di background agar tidak memblokir render UI
task.spawn(OpenInvite)

-- ==========================================
-- TAB: ESP
-- ==========================================
local Tab2 = Window:CreateTab("ESP", "repeat")
Tab2:CreateSection("Chests")

local function CreateChestESP(chest)
    if not chest or chest:FindFirstChild("ChestESP") or not getgenv().ChestESP then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ChestESP"
    highlight.Adornee = chest
    highlight.FillColor = getgenv().ChestColor
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = getgenv().ChestColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = chest

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ChestESPLabel"
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = chest:IsA("Model") and chest.PrimaryPart or chest
    billboard.AlwaysOnTop = true
    billboard.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BackgroundTransparency = 0.4
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Parent = billboard

    local label = Instance.new("TextLabel")
    label.Text = chest.Name
    label.TextColor3 = getgenv().ChestColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextStrokeTransparency = 0.5
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = frame

    getgenv().ChestESPInstances[chest] = {
        Highlight = highlight,
        Billboard = billboard
    }
end

local ColorPicker = Tab2:CreateColorPicker({
    Name = "• ESP Color",
    Color = getgenv().ChestColor,
    Flag = "ChestColor",
    Callback = function(Value)
        getgenv().ChestColor = Value
        for chest, espObjects in pairs(getgenv().ChestESPInstances) do
            if espObjects.Highlight then
                espObjects.Highlight.FillColor = Value
                espObjects.Highlight.OutlineColor = Value
            end
            if espObjects.Billboard then
                espObjects.Billboard.Frame.TextLabel.TextColor3 = Value
            end
        end
    end
})

Tab2:CreateToggle({
    Name = "• Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(Value)
        getgenv().ChestESP = Value
        if Value then
            for _, item in pairs(workspace.Debris:GetDescendants()) do
                if item.Name == "WoodenChest" or item.Name == "GoldenChestLock" or item.Name == "WoodenChestLock" then
                    CreateChestESP(item)
                end
            end
            workspace.Debris.DescendantAdded:Connect(function(item)
                if (item.Name == "WoodenChest" or item.Name == "GoldenChestLock" or item.Name == "WoodenChestLock") and getgenv().ChestESP then
                    CreateChestESP(item)
                end
            end)
        else
            for chest, espObjects in pairs(getgenv().ChestESPInstances) do
                if espObjects.Highlight then espObjects.Highlight:Destroy() end
                if espObjects.Billboard then espObjects.Billboard:Destroy() end
            end
            getgenv().ChestESPInstances = {}
        end
        ColorPicker:Set(getgenv().ChestColor)
    end
})

Tab2:CreateSection("Ores")

local function CreateBlockESP(block)
    if not block:IsA("BasePart") or not block.Parent or string.gsub(block.Name, "Handle", "") == "" then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = getgenv().BlockColor
    highlight.OutlineColor = getgenv().BlockColor
    highlight.FillTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = block
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(6, 0, 3, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = getgenv().BlockColor
    label.TextStrokeTransparency = 0.5
    label.Text = string.gsub(block.Name, "Handle", "")
    label.Parent = billboard
    
    billboard.Parent = block
    getgenv().BlockESPInstances[block] = {Highlight = highlight, Billboard = billboard}
end

local BlockColorPicker = Tab2:CreateColorPicker({
    Name = "• Ore Color",
    Color = getgenv().BlockColor,
    Flag = "BlockColor",
    Callback = function(Value)
        getgenv().BlockColor = Value
        for block, espObjects in pairs(getgenv().BlockESPInstances) do
            if espObjects.Highlight then
                espObjects.Highlight.FillColor = Value
                espObjects.Highlight.OutlineColor = Value
            end
            if espObjects.Billboard and espObjects.Billboard:FindFirstChild("TextLabel") then
                espObjects.Billboard.TextLabel.TextColor3 = Value
            end
        end
    end
})

Tab2:CreateToggle({
    Name = "• Ore ESP",
    CurrentValue = false,
    Flag = "BlockESP",
    Callback = function(Value)
        getgenv().BlockESP = Value
        if Value then
            for _, block in pairs(workspace.Blocks:GetDescendants()) do
                if block:IsA("BasePart") and string.find(block.Name, "Ore") then
                    CreateBlockESP(block)
                end
            end
            workspace.Blocks.DescendantAdded:Connect(function(block)
                if block:IsA("BasePart") and string.find(block.Name, "Ore") and getgenv().BlockESP then
                    CreateBlockESP(block)
                end
            end)
        else
            for block, espObjects in pairs(getgenv().BlockESPInstances) do
                if espObjects.Highlight then espObjects.Highlight:Destroy() end
                if espObjects.Billboard then espObjects.Billboard:Destroy() end
            end
            getgenv().BlockESPInstances = {}
        end
        BlockColorPicker:Set(getgenv().BlockColor)
    end
})

-- ==========================================
-- TAB: AUTO FARM
-- ==========================================
local Tab = Window:CreateTab("Auto Farm", "repeat")
Tab:CreateSection("Chests")

local function CollectAllChests()
    while getgenv().AutoCollectChests do
        local Chests = workspace.Debris:GetDescendants()
        local WoodenChests = {}

        for _, item in pairs(Chests) do
            if item.Name == "WoodenChest" and not getgenv().collectedChests[item] then
                table.insert(WoodenChests, item)
            end
        end

        if #WoodenChests == 0 then
            getgenv().AutoCollectChests = false
            Rayfield.Flags["Chests"]:Set(false)
            break
        end

        for _, chest in ipairs(WoodenChests) do
            if not getgenv().AutoCollectChests then break end
            if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then
                getgenv().AutoCollectChests = false
                Rayfield.Flags["Chests"]:Set(false)
                break
            end

            getgenv().collectedChests[chest] = true
            local targetPivot = chest:GetPivot()

            Player.Character:PivotTo(targetPivot)
            local floatVelocity = Float(Player.Character, targetPivot.Position)
            
            task.wait(0.5)
            local posString = string.format("%.0f,%.0f,%.0f", targetPivot.Position.X, targetPivot.Position.Y, targetPivot.Position.Z)
            TreasureRemote:FireServer(posString)

            task.wait(1.5)

            if floatVelocity then
                floatVelocity:Destroy()
            end
        end
        task.wait()
    end
end

Tab:CreateToggle({
    Name = "• Auto Collect Chests",
    CurrentValue = false,
    Flag = "Chests",
    Callback = function(Value)
        getgenv().AutoCollectChests = Value
        if Value then
            coroutine.wrap(CollectAllChests)()
        else
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                for _, v in pairs(Player.Character.HumanoidRootPart:GetChildren()) do
                    if v:IsA("BodyVelocity") then
                        v:Destroy()
                    end
                end
            end
        end
    end
})

Tab:CreateSection("Drops")

local DropCollector = {
    Enabled = false,
    Delay = 0.2,
    Collected = {},
    RemoveSparkles = false,
    OriginalPosition = nil,
    TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
}

local function ValidateCharacter()
    return Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart")
end

local function GetValidDrops()
    local drops = {}
    for _, drop in pairs(workspace.Drops:GetDescendants()) do
        if drop:IsA("Part") and drop:FindFirstChild("Sparkles") and not DropCollector.Collected[drop] then
            table.insert(drops, drop)
        end
    end
    return drops
end

local function CollectDrop(drop)
    if not drop:FindFirstChild("Sparkles") then return end
    
    local humanoidRootPart = Player.Character.HumanoidRootPart
    local targetPosition = drop:GetPivot()
    
    humanoidRootPart.CFrame = targetPosition
    DropCollector.Collected[drop] = true
    
    if DropCollector.RemoveSparkles then
        drop.Sparkles:Destroy()
    end
end

local function ReturnToOriginalPosition()
    if DropCollector.OriginalPosition and ValidateCharacter() then
        local humanoid = Player.Character.Humanoid
        local humanoidRootPart = Player.Character.HumanoidRootPart
        
        while humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Seated do
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.1)
        end
        
        humanoidRootPart.CFrame = DropCollector.OriginalPosition
    end
end

local function CollectDrops()
    DropCollector.OriginalPosition = Player.Character.HumanoidRootPart.CFrame
    while DropCollector.Enabled do
        if not ValidateCharacter() then
            Rayfield.Flags["Drops"]:Set(false)
            break
        end

        local validDrops = GetValidDrops()
        if #validDrops > 0 then
            for _, drop in ipairs(validDrops) do
                if not DropCollector.Enabled then break end
                CollectDrop(drop)
                task.wait(DropCollector.Delay)
            end
        end
        task.wait()
    end
end

Tab:CreateSlider({
    Name = "• Drop Collection Delay",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = DropCollector.Delay,
    Flag = "DropDelay",
    Callback = function(Value)
        DropCollector.Delay = Value
    end
})

Tab:CreateToggle({
    Name = "• Auto Collect Drops",
    CurrentValue = DropCollector.Enabled,
    Flag = "Drops",
    Callback = function(Value)
        DropCollector.Enabled = Value
        if Value then
            coroutine.wrap(CollectDrops)()
        else
            ReturnToOriginalPosition()
            DropCollector.Collected = {}
        end
    end
})

Tab:CreateSection("Sell Ores")

local playerId = tostring(Player.UserId)
local inventoryFolder = ReplicatedStorage:WaitForChild("playerData"):WaitForChild(playerId):WaitForChild("Inventory")
local VENDOR_LOCATION = workspace.Map.vendorBuilding:GetPivot()
local NPCStore = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NPCStore")
local SellRemote = NPCStore:WaitForChild("Sell")

local Dropdown = Tab:CreateDropdown({
    Name = "• Select Items to Sell",
    Options = {"Loading inventory..."},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ItemFilter",
    Callback = function(Selected)
        getgenv().SelectedItems = Selected
    end
})

local function UpdateInventory()
    local items = {}
    local currentItems = {}
    
    for _, item in pairs(inventoryFolder:GetChildren()) do
        if item:IsA("StringValue") then
            table.insert(items, item.Name)
            currentItems[item.Name] = true
        end
    end
    
    table.sort(items)
    Dropdown:Refresh(#items > 0 and items or {"Inventory Empty"})
    
    local validSelections = {}
    for _, selected in pairs(getgenv().SelectedItems) do
        if currentItems[selected] then
            table.insert(validSelections, selected)
        end
    end
    
    Dropdown:Set(validSelections)
end

local function SellSelectedItems()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    local soldSomething = false
    local itemsToProcess = {}

    for _, itemName in pairs(getgenv().SelectedItems) do
        if itemName ~= "Inventory Empty" then
            table.insert(itemsToProcess, itemName)
        end
    end

    local originalPosition = Player.Character.HumanoidRootPart.CFrame
    Player.Character:PivotTo(VENDOR_LOCATION)
    
    local floatVelocity = Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
    if floatVelocity then
        floatVelocity:Destroy()
    end

    for _, itemName in ipairs(itemsToProcess) do
        local item = inventoryFolder:FindFirstChild(itemName)
        if item then
            local success, stackData = pcall(HttpService.JSONDecode, HttpService, item.Value)
            if success and stackData and stackData.Stack and stackData.Stack > 0 then
                local sellCount = math.min(getgenv().SellAmount, stackData.Stack)
                SellRemote:FireServer(item, sellCount)
                soldSomething = true
                task.wait(0.1)
                
                local _, newStackData = pcall(HttpService.JSONDecode, HttpService, item.Value)
                if newStackData and newStackData.Stack == 0 then
                    break
                end
            end
        end
    end

    task.wait(0.5)
    Player.Character:PivotTo(originalPosition)
    return soldSomething
end

UpdateInventory()

task.spawn(function()
    while task.wait(30) do
        UpdateInventory()
    end
end)

Tab:CreateSlider({
    Name = "• Item Sell Amount",
    Range = {1, 100},
    Increment = 1,
    Suffix = "items",
    CurrentValue = 1,
    Flag = "SellAmount",
    Callback = function(Value)
        getgenv().SellAmount = Value
    end
})

Tab:CreateSlider({
    Name = "• Auto Sell Cooldown",
    Range = {1, 60},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = 5,
    Flag = "AutoSellCooldown",
    Callback = function(Value)
        getgenv().AutoSellCooldown = Value
    end
})

Tab:CreateToggle({
    Name = "• Auto Sell Items",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        if Value and (getgenv().AutoCollectChests or DropCollector.Enabled) then
            Rayfield:Notify({
                Title = "Auto Sell Error",
                Content = "Please turn off Auto Collect Chests/Drops to prevent teleport loops",
                Duration = 6.5,
                Image = 4483362458,
            })
            getgenv().AutoSellEnabled = false
            Rayfield.Flags["AutoSell"]:Set(false)
            return
        end
        getgenv().AutoSellEnabled = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().AutoSellEnabled do
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        SellSelectedItems()
                        UpdateInventory()
                    end
                    task.wait(getgenv().AutoSellCooldown)
                end
            end)()
        end
    end
})

Tab:CreateButton({
    Name = "• Sell Selected Items",
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SellSelectedItems()
            UpdateInventory()
        end
    end
})

-- ==========================================
-- LOAD CONFIGURATION (PENTING)
-- ==========================================
Rayfield:LoadConfiguration()
