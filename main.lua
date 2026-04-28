local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Name = "IronSoul_V8_Final"
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -75, 0.35, -25)
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "FINAL AFK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 12
UICorner.Parent = MainFrame

CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Position = UDim2.new(1, -22, 0, 2)
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
local usedPortals = {} 

-- Fungsi Reset Sesi
local function ResetDungeonSession()
    usedPortals = {}
    noEnemyTimer = tick()
end

local function SetToggle(state)
    _G.AutoDungeon = state
    ToggleButton.Text = _G.AutoDungeon and "FINAL AFK: ON" or "FINAL AFK: OFF"
    ToggleButton.BackgroundColor3 = _G.AutoDungeon and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    if _G.AutoDungeon then noEnemyTimer = tick() end
end

ToggleButton.MouseButton1Click:Connect(function() SetToggle(not _G.AutoDungeon) end)
CloseButton.MouseButton1Click:Connect(function() _G.AutoDungeon = false ScreenGui:Destroy() end)

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon and ScreenGui.Parent then
        -- 1. AUTO RESTART (PLAY AGAIN)
        pcall(function()
            local resGui = Player.PlayerGui:FindFirstChild("ResultGui")
            if resGui and resGui.ScreenSettlement.BtnGroup.PlayAgainBtn.Visible then
                ResetDungeonSession()
                GuiService.SelectedObject = resGui.ScreenSettlement.BtnGroup.PlayAgainBtn
                VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end)

        pcall(function()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 2. AUTO SKILL QER
            if tick() - lastSkillTime >= 2.5 then
                for _, k in pairs({"Q", "E", "R"}) do
                    VIM:SendKeyEvent(true, k, false, game)
                    VIM:SendKeyEvent(false, k, false, game)
                end
                lastSkillTime = tick()
            end

            -- 3. CEK MUSUH
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
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = target.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                target.Size = Vector3.new(40, 40, 40)
                game:GetService("ReplicatedStorage").Remotes.PlayerActionRE:FireServer("SkillAction", "BaseAttack", 1)
            else
                -- 4. CEK PETI (INSTANT TP)
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
                elseif tick() - noEnemyTimer >= 3 then
                    -- 5. LOGIKA PORTAL (PENCARIAN CERDAS)
                    local bestPortal = nil
                    
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent.Name == "Portal" then
                            -- Buat ID unik berdasarkan posisi
                            local pID = math.floor(v.Position.X) .. "_" .. math.floor(v.Position.Z)
                            
                            -- Jarak portal dari karakter
                            local dist = (v.Position - hrp.Position).Magnitude
                            
                            -- Syarat: Belum pernah dimasuki DAN (Jarak jauh ATAU hanya ada 1 portal di map)
                            -- Jika hanya ada 1 portal di map (spawn awal), dist tidak masalah.
                            if not usedPortals[pID] then
                                bestPortal = v
                                break -- Ambil portal pertama yang valid
                            end
                        end
                    end

                    if bestPortal then
                        -- Simpan ke memori dulu
                        local pID = math.floor(bestPortal.Position.X) .. "_" .. math.floor(bestPortal.Position.Z)
                        usedPortals[pID] = true
                        
                        -- Langsung Teleport & Invoke
                        hrp.CFrame = bestPortal.CFrame
                        local rf = bestPortal:FindFirstChild("RF")
                        if rf then 
                            rf:InvokeServer()
                            task.wait(2)
                            noEnemyTimer = tick()
                        end
                    else
                        -- Cadangan Pintu (F)
                        for _, d in pairs(workspace:GetDescendants()) do
                            if d.Name == "LocalRoundDoor" then
                                hrp.CFrame = d.CFrame * CFrame.new(0, 0, 3)
                                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
end)
