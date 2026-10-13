local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- // GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiAFKGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local MARGIN = 20
local ON_SCREEN = UDim2.new(1, -MARGIN, 1, -MARGIN)
local OFF_SCREEN = UDim2.new(1, 160, 1, -MARGIN)

local function createFrame(size, position, anchor)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchor
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.ZIndex = 2

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 74, 74)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	gradient.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 8)
	corner.Parent = frame

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(-0.32, 0, -0.92, 0)
	shadow.Size = UDim2.new(1.6, 0, 3.1, 0)
	shadow.ZIndex = 0
	shadow.Image = "rbxassetid://9637602897"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.Parent = frame

	return frame
end

local Counter = createFrame(UDim2.new(0, 140, 0, 52), OFF_SCREEN, Vector2.new(1, 1))
Counter.Name = "Counter"
Counter.Parent = ScreenGui
Counter.Visible = true

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Parent = Counter
TimeLabel.Size = UDim2.new(0, 63, 0, 23)
TimeLabel.Position = UDim2.new(0.065, 0, 0.26, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "00:00:00"
TimeLabel.Font = Enum.Font.FredokaOne
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.TextScaled = true
TimeLabel.TextWrapped = true
TimeLabel.BorderSizePixel = 0
TimeLabel.ZIndex = 3

local Icon = Instance.new("ImageLabel")
Icon.Name = "Icon"
Icon.Parent = Counter
Icon.Position = UDim2.new(0.59, 1, 0.10, 3)
Icon.Size = UDim2.new(0, 40, 0, 33)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://1083501283"
Icon.BorderSizePixel = 0
Icon.ZIndex = 3

local Aspect = Instance.new("UIAspectRatioConstraint")
Aspect.AspectRatio = 2.635
Aspect.Parent = Counter

-- // Timer
task.spawn(function()
	local seconds = 0
	while ScreenGui.Parent do
		task.wait(1)
		seconds += 1

		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds % 3600) / 60)
		local secs = seconds % 60

		TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, secs)
	end
end)

-- // Anti-AFK (more reliable)
local function doAntiAFK()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end

-- Best method: disable the Idled connections completely (if executor supports it)
local usedBestMethod = false
pcall(function()
	if getconnections then
		for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
			if connection.Disable then
				connection:Disable()
				usedBestMethod = true
			elseif connection.Disconnect then
				connection:Disconnect()
				usedBestMethod = true
			end
		end
	end
end)

-- Fallback: classic VirtualUser method (always works)
if not usedBestMethod then
	LocalPlayer.Idled:Connect(doAntiAFK)
end

-- Extra safety: periodic click every 15 minutes (just in case)
task.spawn(function()
	while ScreenGui.Parent do
		task.wait(900) -- 15 minutes
		doAntiAFK()
	end
end)

-- // Toggle Animation
local slideInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local isVisible = true
local currentTween

local function toggleCounter(visible)
	isVisible = visible

	if currentTween then
		currentTween:Cancel()
	end

	if visible then
		Counter.Visible = true
		currentTween = TweenService:Create(Counter, slideInfo, { Position = ON_SCREEN })
		currentTween:Play()
	else
		currentTween = TweenService:Create(Counter, slideInfo, { Position = OFF_SCREEN })
		currentTween:Play()
		currentTween.Completed:Once(function()
			if not isVisible then
				Counter.Visible = false
			end
		end)
	end
end

toggleCounter(true)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.RightControl then
		toggleCounter(not isVisible)
	end
end)
