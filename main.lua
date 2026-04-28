local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- UI Setup
ScreenGui.Name = "IronSoul_V6_WallBypass"
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
ToggleButton.Text = "WALL-BYPASS: OFF"
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
local checkPos = Vector3.new(0,0,0)
local lastCheckTime = tick()

-- Fungsi Cek Tembok di Depan
local function IsWallInFront(hrp, targetPos)
    local rayOrigin = hrp.Position
    local rayDirection = (targetPos - rayOrigin).Unit * 10 -- Cek 10 studs ke depan
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Player.Character, workspace.EnemyNpc} -- Abaikan diri sendiri & musuh
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        return true -- Ada tembok/objek
    end
    return false
end

local function SetToggle(state)
    _G.AutoDungeon = state
    ToggleButton.Text = _G.AutoDungeon and "WALL-BYPASS: ON" or "WALL-BYPASS: OFF"
    ToggleButton.BackgroundColor3 = _G.AutoDungeon and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    if _G.AutoDungeon then 
        noEnemyTimer = tick() 
        lastCheckTime = tick()
    end
end

ToggleButton.MouseButton1Click:Connect(function() SetToggle(not _G.AutoDungeon) end)
CloseButton.MouseButton1Click:Connect(function() _G.AutoDungeon = false ScreenGui:Destroy() end)

-- Loop Utama
RS.Heartbeat:Connect(function()
    if _G.AutoDungeon and ScreenGui.Parent then
        -- AUTO PLAY AGAIN
        pcall(function()
            local resGui = Player.PlayerGui:FindFirstChild("ResultGui")
            if resGui and resGui.ScreenSettlement.BtnGroup.PlayAgainBtn.Visible then
                portalBlacklist = {}
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

            -- 1. AUTO SKILL
            if tick() - lastSkillTime >= 3 then
                for _, k in pairs({"Q", "E", "R"}) do
                    VIM:SendKeyEvent(true, k, false, game)
                    VIM:SendKeyEvent(false, k, false, game)
                end
                lastSkillTime = tick()
            end

            -- 2. TARGET MUSUH (Tetap TP ke atas musuh)
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
                lastCheckTime = tick()
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
                elseif tick() - noEnemyTimer >= 4 then
                    -- 4. LOGIKA PORTAL DENGAN WALL-DETECTION
                    local closestPortal = nil
                    local minHealthDist = math.huge
                    
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Root" and v.Parent.Name == "Portal" then
                            if not portalBlacklist[tostring(v.Position)] then
                                local dist = (v.Position - hrp.Position).Magnitude
                                if dist < minHealthDist then
                                    minHealthDist = dist
                                    closestPortal = v
                                end
                            end
                        end
                    end

                    if closestPortal then
                        -- DETEKSI TEMBOK & STUCK
                        local wallInFront = IsWallInFront(hrp, closestPortal.Position)
                        local stuckTime = tick() - lastCheckTime
                        local movedDist = (hrp.Position - checkPos).Magnitude
                        
                        -- JIKA ADA TEMBOK ATAU SANGKUT 8 DETIK > TP LANGSUNG
                        if wallInFront or (stuckTime >= 8 and movedDist < 10) then
                            hrp.CFrame = closestPortal.CFrame * CFrame.new(0, 2, 0)
                            lastCheckTime = tick()
                            checkPos = hrp.Position
                        else
                            hum:MoveTo(closestPortal.Position)
                        end
                        
                        -- Update check position setiap 1 detik
                        if tick() - lastCheckTime > 1 then
                            checkPos = hrp.Position
                        end

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
