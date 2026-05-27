local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    ShootKey = Enum.KeyCode.E,
    ToggleKey = Enum.KeyCode.K,
    TweenTime = 0.001,
    AimbotEnabled = false,
    ShotPower = 0.8,
    StealReachEnabled = false,
    StealReachMultiplier = 1.5
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusPerfectShot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

if not pcall(function()
    ScreenGui.Parent = CoreGui
end) then
    ScreenGui.Parent = PlayerGui
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(1, -60, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "E"
ToggleButton.TextColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 30)
TitleLabel.Position = UDim2.new(0, 15, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Nexus // PERFECT SHOT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 2)
Divider.Position = UDim2.new(0, 0, 0, 35)
Divider.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local IsDraggingFrame = false
local FrameStartPos
local MouseStartPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingFrame = true
        MouseStartPos = input.Position
        FrameStartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                IsDraggingFrame = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        MouseStartPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == MouseStartPos and IsDraggingFrame then
        local Delta = input.Position - MouseStartPos
        MainFrame.Position = UDim2.new(
            FrameStartPos.X.Scale,
            FrameStartPos.X.Offset + Delta.X,
            FrameStartPos.Y.Scale,
            FrameStartPos.Y.Offset + Delta.Y
        )
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local IsDraggingButton = false
local ButtonStartPos
local ButtonMouseStartPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingButton = true
        ButtonMouseStartPos = input.Position
        ButtonStartPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                IsDraggingButton = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        ButtonMouseStartPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == ButtonMouseStartPos and IsDraggingButton then
        local Delta = input.Position - ButtonMouseStartPos
        ToggleButton.Position = UDim2.new(
            ButtonStartPos.X.Scale,
            ButtonStartPos.X.Offset + Delta.X,
            ButtonStartPos.Y.Scale,
            ButtonStartPos.Y.Offset + Delta.Y
        )
    end
end)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.Parent = ContentFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingLeft = UDim.new(0, 15)
Padding.PaddingRight = UDim.new(0, 15)
Padding.Parent = ContentFrame

local ShotFrame = Instance.new("Frame")
ShotFrame.Size = UDim2.new(1, 0, 0, 30)
ShotFrame.BackgroundTransparency = 1
ShotFrame.Parent = ContentFrame

local ShotLabel = Instance.new("TextLabel")
ShotLabel.Size = UDim2.new(1, -50, 1, 0)
ShotLabel.BackgroundTransparency = 1
ShotLabel.Text = "Perfect Shot (E)"
ShotLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ShotLabel.Font = Enum.Font.GothamMedium
ShotLabel.TextSize = 14
ShotLabel.TextXAlignment = Enum.TextXAlignment.Left
ShotLabel.Parent = ShotFrame

local ShotToggleButton = Instance.new("TextButton")
ShotToggleButton.Size = UDim2.new(0, 40, 0, 20)
ShotToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
ShotToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ShotToggleButton.Text = ""
ShotToggleButton.Parent = ShotFrame

local ShotToggleCorner = Instance.new("UICorner")
ShotToggleCorner.CornerRadius = UDim.new(1, 0)
ShotToggleCorner.Parent = ShotToggleButton

local ShotToggleIndicator = Instance.new("Frame")
ShotToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
ShotToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
ShotToggleIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
ShotToggleIndicator.Parent = ShotToggleButton

local ShotIndicatorCorner = Instance.new("UICorner")
ShotIndicatorCorner.CornerRadius = UDim.new(1, 0)
ShotIndicatorCorner.Parent = ShotToggleIndicator

ShotToggleButton.MouseButton1Click:Connect(function()
    Config.AimbotEnabled = not Config.AimbotEnabled
    
    if Config.AimbotEnabled then
        local Tween = TweenService:Create(ShotToggleIndicator, TweenInfo.new(0.2), {
            Position = UDim2.new(1, -18, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(60, 255, 100)
        })
        Tween:Play()
    else
        local Tween = TweenService:Create(ShotToggleIndicator, TweenInfo.new(0.2), {
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        })
        Tween:Play()
    end
end)

local TimingFrame = Instance.new("Frame")
TimingFrame.Size = UDim2.new(1, 0, 0, 45)
TimingFrame.BackgroundTransparency = 1
TimingFrame.Parent = ContentFrame

local TimingLabel = Instance.new("TextLabel")
TimingLabel.Size = UDim2.new(1, 0, 0, 15)
TimingLabel.BackgroundTransparency = 1
TimingLabel.Text = "Shot Timing: 80%"
TimingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimingLabel.Font = Enum.Font.GothamMedium
TimingLabel.TextSize = 14
TimingLabel.TextXAlignment = Enum.TextXAlignment.Left
TimingLabel.Parent = TimingFrame

local TimingSlider = Instance.new("TextButton")
TimingSlider.Size = UDim2.new(1, 0, 0, 20)
TimingSlider.Position = UDim2.new(0, 0, 0, 22)
TimingSlider.BackgroundTransparency = 1
TimingSlider.Text = ""
TimingSlider.Parent = TimingFrame

local SliderBackground = Instance.new("Frame")
SliderBackground.Size = UDim2.new(1, 0, 0, 6)
SliderBackground.Position = UDim2.new(0, 0, 0.5, -3)
SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderBackground.BorderSizePixel = 0
SliderBackground.Parent = TimingSlider

local SliderBackgroundCorner = Instance.new("UICorner")
SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
SliderBackgroundCorner.Parent = SliderBackground

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.fromScale(0.6, 1)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBackground

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(1, 0)
SliderFillCorner.Parent = SliderFill

local IsSliderActive = false

local function UpdateSlider(input)
    local Percentage = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
    local Value = math.round(50 + Percentage * 50)
    Config.ShotPower = Value / 100
    TimingLabel.Text = "Shot Timing: " .. tostring(Value) .. "%"
    SliderFill.Size = UDim2.fromScale(Percentage, 1)
end

TimingSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSliderActive = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsSliderActive and input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSliderActive = false
    end
end)

local ReachFrame = Instance.new("Frame")
ReachFrame.Size = UDim2.new(1, 0, 0, 30)
ReachFrame.BackgroundTransparency = 1
ReachFrame.Parent = ContentFrame

local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(1, -50, 1, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Steal Ball Reach"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.GothamMedium
ReachLabel.TextSize = 14
ReachLabel.TextXAlignment = Enum.TextXAlignment.Left
ReachLabel.Parent = ReachFrame

local ReachToggleButton = Instance.new("TextButton")
ReachToggleButton.Size = UDim2.new(0, 40, 0, 20)
ReachToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
ReachToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ReachToggleButton.Text = ""
ReachToggleButton.Parent = ReachFrame

local ReachToggleCorner = Instance.new("UICorner")
ReachToggleCorner.CornerRadius = UDim.new(1, 0)
ReachToggleCorner.Parent = ReachToggleButton

local ReachToggleIndicator = Instance.new("Frame")
ReachToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
ReachToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
ReachToggleIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
ReachToggleIndicator.Parent = ReachToggleButton

local ReachIndicatorCorner = Instance.new("UICorner")
ReachIndicatorCorner.CornerRadius = UDim.new(1, 0)
ReachIndicatorCorner.Parent = ReachToggleIndicator

ReachToggleButton.MouseButton1Click:Connect(function()
    Config.StealReachEnabled = not Config.StealReachEnabled
    
    if Config.StealReachEnabled then
        local Tween = TweenService:Create(ReachToggleIndicator, TweenInfo.new(0.2), {
            Position = UDim2.new(1, -18, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(60, 255, 100)
        })
        Tween:Play()
    else
        local Tween = TweenService:Create(ReachToggleIndicator, TweenInfo.new(0.2), {
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        })
        Tween:Play()
    end
end)

local ReachMultiplierFrame = Instance.new("Frame")
ReachMultiplierFrame.Size = UDim2.new(1, 0, 0, 45)
ReachMultiplierFrame.BackgroundTransparency = 1
ReachMultiplierFrame.Parent = ContentFrame

local ReachMultiplierLabel = Instance.new("TextLabel")
ReachMultiplierLabel.Size = UDim2.new(1, 0, 0, 15)
ReachMultiplierLabel.BackgroundTransparency = 1
ReachMultiplierLabel.Text = "Reach: 1.5x"
ReachMultiplierLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachMultiplierLabel.Font = Enum.Font.GothamMedium
ReachMultiplierLabel.TextSize = 14
ReachMultiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
ReachMultiplierLabel.Parent = ReachMultiplierFrame

local ReachSlider = Instance.new("TextButton")
ReachSlider.Size = UDim2.new(1, 0, 0, 20)
ReachSlider.Position = UDim2.new(0, 0, 0, 22)
ReachSlider.BackgroundTransparency = 1
ReachSlider.Text = ""
ReachSlider.Parent = ReachMultiplierFrame

local ReachSliderBackground = Instance.new("Frame")
ReachSliderBackground.Size = UDim2.new(1, 0, 0, 6)
ReachSliderBackground.Position = UDim2.new(0, 0, 0.5, -3)
ReachSliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ReachSliderBackground.BorderSizePixel = 0
ReachSliderBackground.Parent = ReachSlider

local ReachSliderBackgroundCorner = Instance.new("UICorner")
ReachSliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
ReachSliderBackgroundCorner.Parent = ReachSliderBackground

local ReachSliderFill = Instance.new("Frame")
ReachSliderFill.Size = UDim2.fromScale(0.0263, 1)
ReachSliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ReachSliderFill.BorderSizePixel = 0
ReachSliderFill.Parent = ReachSliderBackground

local ReachSliderFillCorner = Instance.new("UICorner")
ReachSliderFillCorner.CornerRadius = UDim.new(1, 0)
ReachSliderFillCorner.Parent = ReachSliderFill

local IsReachSliderActive = false

local function UpdateReachSlider(input)
    local Value = math.round((10 + math.clamp((input.Position.X - ReachSliderBackground.AbsolutePosition.X) / ReachSliderBackground.AbsoluteSize.X, 0, 1) * 190) / 5) * 5
    Config.StealReachMultiplier = Value / 10
    ReachMultiplierLabel.Text = "Reach: " .. string.format("%.1f", Config.StealReachMultiplier) .. "x"
    ReachSliderFill.Size = UDim2.fromScale((Value - 10) / 190, 1)
end

ReachSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsReachSliderActive = true
        UpdateReachSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsReachSliderActive and input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateReachSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsReachSliderActive = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Config.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)
