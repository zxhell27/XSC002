-- // UI FRAME //
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local TitleLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")

-- // Parent UI ke player //
ScreenGui.Parent = game:GetService("CoreGui")
Frame.Parent = ScreenGui
StartButton.Parent = Frame
StatusLabel.Parent = Frame
TitleLabel.Parent = Frame
MinimizeButton.Parent = Frame

-- // Desain UI //
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Text = "Zedlist"
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true

StartButton.Size = UDim2.new(0, 180, 0, 40)
StartButton.Position = UDim2.new(0, 10, 0, 40)
StartButton.Text = "Start Script"
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)

StatusLabel.Size = UDim2.new(0, 180, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.Text = "Status: Idle"
StatusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -40, 0, 0)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)

-- // Fungsi tunggu //
local function waitSeconds(sec)
	local start = tick()
	while tick() - start < sec do wait() end
end

-- // Fungsi utama //
local function runCycle()
	local function updateStatus(text)
		StatusLabel.Text = "Status: " .. text
	end

	updateStatus("Reincarnating")
	game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("Reincarnate", 9e9):FireServer({})

	spawn(function()
		while true do
			local args = {}
			game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("IncreaseAptitude", 9e9):FireServer(args)
			game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("Mine", 9e9):FireServer(args)
			wait()
		end
	end)

	local stopUpdateQi = false
	spawn(function()
		while not stopUpdateQi do
			local args = {}
			game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("UpdateQi", 9e9):FireServer(args)
			wait(1)
		end
	end)

	waitSeconds(60)
	local item1 = {
		"Nine Heavens Galaxy Water",
		"Buzhou Divine Flower",
		"Fusang Divine Tree",
		"Calm Cultivation Mat"
	}
	for _, item in ipairs(item1) do
		game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("BuyItem", 9e9):FireServer({item})
	end

	waitSeconds(30)
	local function changeMap(name)
		game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9):WaitForChild("ChangeMap", 9e9):FireServer({name})
	end
	changeMap("immortal")
	changeMap("chaos")

	updateStatus("Chaotic Road")
	game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9):WaitForChild("ChaoticRoad", 9e9):FireServer({})

	updateStatus("Preparing Items")
	waitSeconds(60)
	local item2 = {
		"Traceless Breeze Lotus",
		"Reincarnation World Destruction Black Lotus",
		"Ten Thousand Bodhi Tree"
	}
	for _, item in ipairs(item2) do
		game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("BuyItem", 9e9):FireServer({item})
	end

	changeMap("immortal")
	game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9):WaitForChild("HiddenRemote", 9e9):FireServer({})

	waitSeconds(60)
	game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("AreaEvents", 9e9):WaitForChild("ForbiddenZone", 9e9):FireServer({})

	updateStatus("Comprehending")
	stopUpdateQi = true
	local start = tick()
	while tick() - start < 120 do
		game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("Comprehend", 9e9):FireServer({})
		wait()
	end

	updateStatus("Final UpdateQi")
	stopUpdateQi = false
	waitSeconds(120)
	stopUpdateQi = true

	updateStatus("Cycle Done - Restarting")
end

-- // Jalankan saat tombol ditekan //
StartButton.MouseButton1Click:Connect(function()
	spawn(function()
		while true do
			runCycle()
		end
	end)
	StartButton.Text = "Running..."
	StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end)

-- // Fungsi untuk meminimalkan UI //
MinimizeButton.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end)
