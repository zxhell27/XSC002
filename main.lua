local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Name = "IronSoul_V5_SmartStuck"
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -75, 0.35, -25)
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "SMART AFK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 12
UICorner.Parent = MainFrame

CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = "X"

-- Variabel Kontrol
_G.AutoDungeon = false
local Player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local lastSkillTime = 0
local noEnemyTimer = tick()
local portalBlacklist = {}

-- Variabel Anti-Stuck (10 studs / 8 detik)
local checkPos = Vector3.new(0,0,0)
local lastCheckTime = tick()

local function ResetMemori()
    portalBlacklist = {}
    lastCheckTime = tick()
    print("Memori Direset untuk Game Baru.")
end

local function SetToggle(state)
    _G.AutoDungeon = state
    if _G.AutoDungeon then
        ToggleButton.Text = "SMART AFK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noEnemyTimer = tick()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            checkPos = Player.Character.HumanoidRootPart.Position
            lastCheckTime = tick()
        end
    else
        ToggleButton.Text = "SMART AFK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

ToggleButton.MouseButton1Click:Connect(function() SetToggle(not _G.AutoDungeon) end)
CloseButton.MouseButton1Click:Connect(function() _G.AutoDungeon = false ScreenGui:Destroy() end)

-- Auto Start
task.spawn(function()
    for i = 5, 1, -1 do
        if _G.AutoDungeon then break end
        ToggleButton.Text = "AUTO START: " .. i
        task.wait(1)
    end
    if not _G.AutoDungeon then SetToggle(true) end
end)

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon and ScreenGui.Parent then
        -- AUTO PLAY AGAIN
        pcall(function()
            local resGui = Player.PlayerGui:FindFirstChild("ResultGui")
            if resGui and resGui.ScreenSettlement.BtnGroup.PlayAgainBtn.Visible then
                ResetMemori()
                GuiService.SelectedObject = resGui.ScreenSettlement.BtnGroup.PlayAgainBtn
                VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end)

        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            -- 1. AUTO SKILL QER
            if tick() - lastSkillTime >= 3 then
                for _, k in pairs({"Q", "E", "R"}) do
                    VIM:SendKeyEvent(true, k, false, game)
                    VIM:SendKeyEvent(false, k, false, game)
                end
                lastSkillTime = tick()
            end

            -- 2. TARGETING MUSUH
            local target = nil
            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            if enemyFolder then
                for _, v in pairs(enemyFolder:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        target = v.HumanoidRootPart
                        break
                    end
                end
            end

            if target then
                noEnemyTimer = tick()
                lastCheckTime = tick() -- Reset timer stuck saat bertarung
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = target.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                target.Size = Vector3.new(40, 40, 40)
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            else
                -- 3. JIKA MUSUH HABIS: CEK PETI
                local chest = nil
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name:match("Chest") then
                        chest = v:FindFirstChild("Root") or v:FindFirstChildWhichIsA("BasePart")
                        if chest then break end
                    end
                end

                if chest then
                    hrp.CFrame = chest.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
                    lastCheckTime = tick() -- Reset timer stuck saat ambil peti
                elseif tick() - noEnemyTimer >= 5 then
                    -- 4. LOGIKA PORTAL
                    local closestPortal = nil
                    local minHealthDist = math.huge
                    
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent.Name == "Portal" then
                            local portalID = tostring(v.Position)
                            if not portalBlacklist[portalID] then
                                local dist = (v.Position - hrp.Position).Magnitude
                                if dist < minHealthDist then
                                    minHealthDist = dist
                                    closestPortal = v
                                end
                            end
                        end
                    end

                    if closestPortal then
                        -- LOGIKA ANTI-STUCK: 10 studs dalam 8 detik
                        if tick() - lastCheckTime >= 8 then
                            local movedDist = (hrp.Position - checkPos).Magnitude
                            if movedDist < 10 then
                                -- Karakter SANGKUT: Force Teleport ke portal
                                hrp.CFrame = closestPortal.CFrame * CFrame.new(0, 2, 0)
                                print("Karakter Sangkut! Melakukan Force Teleport...")
                            end
                            -- Update posisi pengecekan berikutnya
                            checkPos = hrp.Position
                            lastCheckTime = tick()
                        end

                        -- Perintah jalan ke portal
                        hum:MoveTo(closestPortal.Position)
                        
                        -- Interaksi jika sudah dekat
                        if (closestPortal.Position - hrp.Position).Magnitude < 15 then
                            local rf = closestPortal:FindFirstChild("RF")
                            if rf then 
                                portalBlacklist[tostring(closestPortal.Position)] = true
                                rf:InvokeServer()
                                task.wait(1.5)
                                noEnemyTimer = tick()
                            end
                        end
                    end
                end
            end
        end)
    end
end)
