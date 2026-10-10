local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CounterGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local margin = 20

local function createStyledFrame(size, position, anchorPoint)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchorPoint
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0

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

local onScreenPos = UDim2.new(1, -margin, 1, -margin)
local offScreenPos = UDim2.new(1, 160, 1, -margin)

local Counter = createStyledFrame(
	UDim2.new(0, 140, 0, 52),
	offScreenPos,
	Vector2.new(1, 1)
)

Counter.Name = "Counter"
Counter.Parent = ScreenGui
Counter.Visible = true
Counter.ZIndex = 2

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Counter
TextLabel.Size = UDim2.new(0, 63, 0, 23)
TextLabel.Position = UDim2.new(0.065, 0, 0.26, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "00:00:00"
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextWrapped = true
TextLabel.BorderSizePixel = 0
TextLabel.ZIndex = 3

local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Parent = Counter
ImageLabel.Position = UDim2.new(0.59, 1, 0.10, 3)
ImageLabel.Size = UDim2.new(0, 40, 0, 33)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Image = "rbxassetid://1083501283"
ImageLabel.BorderSizePixel = 0
ImageLabel.ZIndex = 3

local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.Parent = Counter
UIAspectRatioConstraint.AspectRatio = 2.635

task.spawn(function()
	local seconds = 0

	while ScreenGui.Parent do
		task.wait(1)

		seconds += 1

		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds % 3600) / 60)
		local secs = seconds % 60

		TextLabel.Text = string.format(
			"%02d:%02d:%02d",
			hours,
			minutes,
			secs
		)
	end
end)

local function antiAfk()
	pcall(function()
		VirtualUser:CaptureController()

		local camera = workspace.CurrentCamera

		if camera then
			VirtualUser:Button2Down(
				Vector2.new(0, 0),
				camera.CFrame
			)

			task.wait(0.1)

			VirtualUser:Button2Up(
				Vector2.new(0, 0),
				camera.CFrame
			)
		else
			VirtualUser:ClickButton2(Vector2.new(0, 0))
		end
	end)
end

LocalPlayer.Idled:Connect(function()
	antiAfk()
end)

local slideTweenInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

local isCounterVisible = true
local currentTween

local function toggleCounter(visible)
	isCounterVisible = visible

	if currentTween then
		currentTween:Cancel()
	end

	if visible then
		Counter.Visible = true

		currentTween = TweenService:Create(
			Counter,
			slideTweenInfo,
			{
				Position = onScreenPos
			}
		)

		currentTween:Play()
	else
		currentTween = TweenService:Create(
			Counter,
			slideTweenInfo,
			{
				Position = offScreenPos
			}
		)

		currentTween:Play()

		currentTween.Completed:Once(function()
			if not isCounterVisible then
				Counter.Visible = false
			end
		end)
	end
end

toggleCounter(true)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightControl then
		toggleCounter(not isCounterVisible)
	end
end)
