--[[
    SMUGGLING SYSTEM v2.6
    Toggle Menu: [K]
    Features: Tabs, Executor Check, No Car Sinking, Smart Inventory, Discord Error UI, Auto Farm Box, Calculator, Safe Mode
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer

local fireproximityprompt = fireproximityprompt
local setclipboard = setclipboard

-- EXECUTOR CHECK
local executorName = (identifyexecutor and identifyexecutor()) or "Unknown"
local isSupported = true
if not writefile or not readfile or not fireproximityprompt then
    isSupported = false
end

-- Utility: Safe Get CoreGui
local function getParent()
    local success, _ = pcall(function() return CoreGui.Name end)
    if success then return CoreGui end
    return Player:WaitForChild("PlayerGui")
end

-- CLEANUP OLD INSTANCES (Prevents overlapping when executing again)
if getgenv().Smuggle_Kill then 
    pcall(function() getgenv().Smuggle_Kill() end) 
end
local parentGui = getParent()
for _, gui in pairs(parentGui:GetChildren()) do
    if gui.Name == "SmugglingSystem" or gui.Name == "SmuggleErrorSystem" or gui.Name == "SmuggleNotifSystem" then
        gui:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmugglingSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getParent()

-- ERROR HANDLING & UI SYSTEM
local ErrorGui = Instance.new("ScreenGui")
ErrorGui.Name = "SmuggleErrorSystem"
ErrorGui.ResetOnSpawn = false
ErrorGui.Parent = getParent()

local function ShowErrorUI(errText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 160)
    frame.Position = UDim2.new(0.5, -150, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
    frame.Parent = ErrorGui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 2
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ SCRIPT ERROR DETECTED"
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 50)
    desc.Position = UDim2.new(0, 10, 0, 35)
    desc.BackgroundTransparency = 1
    desc.Text = errText
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.Parent = frame

    local discordText = Instance.new("TextLabel")
    discordText.Size = UDim2.new(1, -20, 0, 20)
    discordText.Position = UDim2.new(0, 10, 0, 90)
    discordText.BackgroundTransparency = 1
    discordText.Text = "Report this in Discord: https://discord.gg/9E6AgcsT"
    discordText.TextColor3 = Color3.fromRGB(88, 101, 242)
    discordText.Font = Enum.Font.GothamBold
    discordText.TextSize = 11
    discordText.TextXAlignment = Enum.TextXAlignment.Left
    discordText.Parent = frame
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 120, 0, 30)
    copyBtn.Position = UDim2.new(0, 20, 0, 120)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    copyBtn.Text = "Copy Error"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 12
    copyBtn.Parent = frame
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 120, 0, 30)
    closeBtn.Position = UDim2.new(1, -140, 0, 120)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("El Paso Script Error:\n" .. errText .. "\nDiscord: https://discord.gg/9E6AgcsT")
            copyBtn.Text = "Copied!"
            task.delay(2, function() copyBtn.Text = "Copy Error" end)
        else
            copyBtn.Text = "Not Supported"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)
end

local function ReportError(context, err)
    local fullMsg = "[" .. context .. "] " .. tostring(err)
    warn(fullMsg)
    ShowErrorUI(fullMsg)
end

-- CONFIG SYSTEM
local ConfigFile = "ElPasoSmuggleConfig.json"
local Config = {
    AutoFarm = false,
    AutoFarmBox = false,
    ServerHop = false,
    HopMinutes = 15
}

local function SaveConfig()
    if writefile then
        local success, err = pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(Config))
        end)
        if not success then
            ReportError("SYSTEM ERROR - SaveConfig", err)
        end
    end
end

local function LoadConfig()
    if readfile then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result.AutoFarm ~= nil then Config.AutoFarm = result.AutoFarm end
            if result.AutoFarmBox ~= nil then Config.AutoFarmBox = result.AutoFarmBox end
            if result.ServerHop ~= nil then Config.ServerHop = result.ServerHop end
            if result.HopMinutes ~= nil then Config.HopMinutes = result.HopMinutes end
        end
    end
end
LoadConfig()

local AUTO_FARM_ENABLED = Config.AutoFarm
local AUTO_FARM_BOX_ENABLED = Config.AutoFarmBox
local MENU_VISIBLE = false

getgenv().Smuggle_Kill = function()
    AUTO_FARM_ENABLED = false
    AUTO_FARM_BOX_ENABLED = false
    Config.ServerHop = false
end

-- NOTIFICATION SYSTEM
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "SmuggleNotifSystem"
NotifGui.ResetOnSpawn = false
NotifGui.Parent = getParent()

local function ShowNotification(titleText, descText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 80)
    frame.Position = UDim2.new(1, 20, 1, -100) -- Starts off-screen
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.Parent = NotifGui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 2
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 40)
    desc.Position = UDim2.new(0, 10, 0, 30)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    
    local targetPos = UDim2.new(1, -280, 1, -100)
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    
    local closed = false
    local function closeNotif()
        if closed then return end
        closed = true
        local tw = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -100)})
        tw:Play()
        tw.Completed:Connect(function() frame:Destroy() end)
    end
    
    closeBtn.MouseButton1Click:Connect(closeNotif)
    task.delay(7, closeNotif)
end

-- MOBILE TOGGLE BUTTON
local MobileToggle = Instance.new("TextButton")
MobileToggle.Name = "MobileToggle"
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(0, 10, 0.5, -25)
MobileToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MobileToggle.Text = "S"
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.TextSize = 20
MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggle.Parent = ScreenGui

Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MobileToggle).Color = Color3.fromRGB(60, 60, 70)

local mDragging, mDragInput, mDragStart, mStartPos
MobileToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = true
        mDragStart = input.Position
        mStartPos = MobileToggle.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and mDragging then
        local delta = input.Position - mDragStart
        MobileToggle.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = false
    end
end)

-- MAIN MENU
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 340)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.Thickness = 2

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 80, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)

local SidebarFill = Instance.new("Frame")
SidebarFill.Size = UDim2.new(0, 10, 1, 0)
SidebarFill.Position = UDim2.new(1, -10, 0, 0)
SidebarFill.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SidebarFill.BorderSizePixel = 0
SidebarFill.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 50)
Title.Position = UDim2.new(0, 80, 0, 0)
Title.Text = "SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- TABS BUTTONS
local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(1, -10, 0, 40)
MainTabBtn.Position = UDim2.new(0, 5, 0, 20)
MainTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MainTabBtn.Text = "MAIN"
MainTabBtn.Font = Enum.Font.GothamBold
MainTabBtn.TextSize = 12
MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabBtn.Parent = Sidebar
Instance.new("UICorner", MainTabBtn).CornerRadius = UDim.new(0, 8)

local InfoTabBtn = Instance.new("TextButton")
InfoTabBtn.Size = UDim2.new(1, -10, 0, 40)
InfoTabBtn.Position = UDim2.new(0, 5, 0, 70)
InfoTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
InfoTabBtn.Text = "INFO"
InfoTabBtn.Font = Enum.Font.GothamBold
InfoTabBtn.TextSize = 12
InfoTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoTabBtn.Parent = Sidebar
Instance.new("UICorner", InfoTabBtn).CornerRadius = UDim.new(0, 8)

local StatsTabBtn = Instance.new("TextButton")
StatsTabBtn.Size = UDim2.new(1, -10, 0, 40)
StatsTabBtn.Position = UDim2.new(0, 5, 0, 120)
StatsTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
StatsTabBtn.Text = "CALC"
StatsTabBtn.Font = Enum.Font.GothamBold
StatsTabBtn.TextSize = 12
StatsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
StatsTabBtn.Parent = Sidebar
Instance.new("UICorner", StatsTabBtn).CornerRadius = UDim.new(0, 8)

local DiscordTabBtn = Instance.new("TextButton")
DiscordTabBtn.Size = UDim2.new(1, -10, 0, 40)
DiscordTabBtn.Position = UDim2.new(0, 5, 0, 170)
DiscordTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
DiscordTabBtn.Text = "DISCORD"
DiscordTabBtn.Font = Enum.Font.GothamBold
DiscordTabBtn.TextSize = 12
DiscordTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
DiscordTabBtn.Parent = Sidebar
Instance.new("UICorner", DiscordTabBtn).CornerRadius = UDim.new(0, 8)

-- MAIN CONTAINER
local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Size = UDim2.new(1, -100, 1, -60)
MainContainer.Position = UDim2.new(0, 90, 0, 50)
MainContainer.BackgroundTransparency = 1
MainContainer.ScrollBarThickness = 2
MainContainer.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = MainContainer
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 8)

local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(1, 0, 0, 40)
FarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FarmButton.Text = "AUTO SMUGGLE: " .. (Config.AutoFarm and "ON" or "OFF")
FarmButton.Font = Enum.Font.GothamBold
FarmButton.TextSize = 13
FarmButton.TextColor3 = Config.AutoFarm and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
FarmButton.LayoutOrder = 1
FarmButton.Parent = MainContainer
Instance.new("UICorner", FarmButton).CornerRadius = UDim.new(0, 8)

local FarmBoxButton = Instance.new("TextButton")
FarmBoxButton.Size = UDim2.new(1, 0, 0, 40)
FarmBoxButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FarmBoxButton.Text = "AUTO BOX: " .. (Config.AutoFarmBox and "ON" or "OFF")
FarmBoxButton.Font = Enum.Font.GothamBold
FarmBoxButton.TextSize = 13
FarmBoxButton.TextColor3 = Config.AutoFarmBox and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
FarmBoxButton.LayoutOrder = 2
FarmBoxButton.Parent = MainContainer
Instance.new("UICorner", FarmBoxButton).CornerRadius = UDim.new(0, 8)

local BoxWarningLabel = Instance.new("TextLabel")
BoxWarningLabel.Size = UDim2.new(1, 0, 0, 15)
BoxWarningLabel.BackgroundTransparency = 1
BoxWarningLabel.Text = "⚠️ You must be near a box to use Auto Box"
BoxWarningLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
BoxWarningLabel.Font = Enum.Font.GothamBold
BoxWarningLabel.TextSize = 10
BoxWarningLabel.LayoutOrder = 3
BoxWarningLabel.Parent = MainContainer

local DropdownButton = Instance.new("TextButton")
DropdownButton.Size = UDim2.new(1, 0, 0, 40)
DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
DropdownButton.Text = "Hop Time: " .. Config.HopMinutes .. " Min"
DropdownButton.Font = Enum.Font.GothamBold
DropdownButton.TextSize = 14
DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownButton.LayoutOrder = 4
DropdownButton.Parent = MainContainer
Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 8)

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, 0, 0, 120)
DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
DropdownList.Visible = false
DropdownList.LayoutOrder = 5
DropdownList.ScrollBarThickness = 4
DropdownList.Parent = MainContainer
Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 8)

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownList
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder

for i = 1, 50 do
    local Option = Instance.new("TextButton")
    Option.Size = UDim2.new(1, 0, 0, 25)
    Option.BackgroundTransparency = 1
    Option.Text = tostring(i) .. " Minutes"
    Option.TextColor3 = Color3.fromRGB(200, 200, 200)
    Option.Font = Enum.Font.Gotham
    Option.TextSize = 12
    Option.Parent = DropdownList
    
    Option.MouseButton1Click:Connect(function()
        Config.HopMinutes = i
        DropdownButton.Text = "Hop Time: " .. i .. " Min"
        DropdownList.Visible = false
        SaveConfig()
    end)
end
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 50 * 25)

local HopButton = Instance.new("TextButton")
HopButton.Size = UDim2.new(1, 0, 0, 40)
HopButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
HopButton.Text = "SERVER HOP: " .. (Config.ServerHop and "ON" or "OFF")
HopButton.Font = Enum.Font.GothamBold
HopButton.TextSize = 14
HopButton.TextColor3 = Config.ServerHop and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
HopButton.LayoutOrder = 6
HopButton.Parent = MainContainer
Instance.new("UICorner", HopButton).CornerRadius = UDim.new(0, 8)

local KeyInfo = Instance.new("TextLabel")
KeyInfo.Size = UDim2.new(1, 0, 0, 20)
KeyInfo.Text = "Press [K] to toggle menu"
KeyInfo.Font = Enum.Font.Gotham
KeyInfo.TextSize = 11
KeyInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
KeyInfo.BackgroundTransparency = 1
KeyInfo.LayoutOrder = 7
KeyInfo.Parent = MainContainer

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- INFO CONTAINER
local InfoContainer = Instance.new("ScrollingFrame")
InfoContainer.Size = UDim2.new(1, -100, 1, -60)
InfoContainer.Position = UDim2.new(0, 90, 0, 50)
InfoContainer.BackgroundTransparency = 1
InfoContainer.ScrollBarThickness = 3
InfoContainer.Visible = false
InfoContainer.Parent = MainFrame

local InfoLayout = Instance.new("UIListLayout")
InfoLayout.Parent = InfoContainer
InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoLayout.Padding = UDim.new(0, 15)

local function CreateInfoText(title, desc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 80)
    frame.BackgroundTransparency = 1
    frame.Parent = InfoContainer
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, 0, 0, 20)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = frame
    
    local dLabel = Instance.new("TextLabel")
    dLabel.Size = UDim2.new(1, 0, 0, 60)
    dLabel.Position = UDim2.new(0, 0, 0, 20)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = desc
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 11
    dLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    dLabel.TextWrapped = true
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.TextYAlignment = Enum.TextYAlignment.Top
    dLabel.Parent = frame
    
    return frame, dLabel
end

CreateInfoText("Executor Info (801)", "Current Executor: " .. executorName)
local statusFrame, statusLabel = CreateInfoText("Script Support Status (802)", "")
if isSupported then
    statusLabel.Text = "Fully Supported! Your executor supports all required functions."
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
else
    statusLabel.Text = "Not Fully Supported. Some features might not work properly on this executor."
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
end

CreateInfoText("Calculator / CALC Tab (803)", "Enter your target cash amount in the CALC tab. The script will automatically track your real-time earnings and calculate the exact ETA (Time left) to reach your goal.")
CreateInfoText("Auto Box Requirement (804)", "For safety and proper execution, make sure you are standing near the box pickup area before starting the Auto Box farm. Server Hop is not needed for this.")
CreateInfoText("Safe Mode Active (805)", "This script uses 100% safe direct proximity firing. There are no background AFK loops or fake click inputs that could trigger Adonis Anti-Cheat.")
CreateInfoText("Smart Inventory (806)", "The bot checks your backpack and character. It only buys the items you are missing, saving you time.")
CreateInfoText("Car Safety Notification (807)", "Teleports keep your car horizontal. If you try to start the SMUGGLE farm without being seated in a car, the script will warn you.")
CreateInfoText("Error Logging & Discord (808)", "If a script error occurs, a UI pop-up will appear allowing you to instantly copy the error and report it.")

InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    InfoContainer.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 20)
end)

-- STATS/CALC CONTAINER
local StatsContainer = Instance.new("ScrollingFrame")
StatsContainer.Size = UDim2.new(1, -100, 1, -60)
StatsContainer.Position = UDim2.new(0, 90, 0, 50)
StatsContainer.BackgroundTransparency = 1
StatsContainer.ScrollBarThickness = 2
StatsContainer.Visible = false
StatsContainer.Parent = MainFrame

local StatsLayout = Instance.new("UIListLayout")
StatsLayout.Parent = StatsContainer
StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatsLayout.Padding = UDim.new(0, 10)

local calcInfo = Instance.new("TextLabel")
calcInfo.Size = UDim2.new(1, 0, 0, 35)
calcInfo.BackgroundTransparency = 1
calcInfo.Text = "How to use: Type the exact number (e.g. 15000) and press Enter. Do not use commas or letters."
calcInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
calcInfo.Font = Enum.Font.Gotham
calcInfo.TextSize = 11
calcInfo.TextWrapped = true
calcInfo.Parent = StatsContainer

local targetBoxFrame = Instance.new("Frame")
targetBoxFrame.Size = UDim2.new(1, 0, 0, 40)
targetBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
targetBoxFrame.Parent = StatsContainer
Instance.new("UICorner", targetBoxFrame).CornerRadius = UDim.new(0, 8)

local targetBoxInput = Instance.new("TextBox")
targetBoxInput.Size = UDim2.new(1, -20, 1, 0)
targetBoxInput.Position = UDim2.new(0, 10, 0, 0)
targetBoxInput.BackgroundTransparency = 1
targetBoxInput.PlaceholderText = "Enter Target Cash (e.g. 10000)"
targetBoxInput.Text = ""
targetBoxInput.TextColor3 = Color3.fromRGB(255, 255, 255)
targetBoxInput.Font = Enum.Font.GothamBold
targetBoxInput.TextSize = 14
targetBoxInput.ClearTextOnFocus = false
targetBoxInput.Parent = targetBoxFrame

local currentCashLabel = Instance.new("TextLabel")
currentCashLabel.Size = UDim2.new(1, 0, 0, 30)
currentCashLabel.BackgroundTransparency = 1
currentCashLabel.Text = "Current Cash: $0"
currentCashLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
currentCashLabel.Font = Enum.Font.GothamBold
currentCashLabel.TextSize = 14
currentCashLabel.TextXAlignment = Enum.TextXAlignment.Left
currentCashLabel.Parent = StatsContainer

local missingCashLabel = Instance.new("TextLabel")
missingCashLabel.Size = UDim2.new(1, 0, 0, 30)
missingCashLabel.BackgroundTransparency = 1
missingCashLabel.Text = "Missing Cash: Target not set"
missingCashLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
missingCashLabel.Font = Enum.Font.GothamBold
missingCashLabel.TextSize = 14
missingCashLabel.TextXAlignment = Enum.TextXAlignment.Left
missingCashLabel.Parent = StatsContainer

local etaLabel = Instance.new("TextLabel")
etaLabel.Size = UDim2.new(1, 0, 0, 30)
etaLabel.BackgroundTransparency = 1
etaLabel.Text = "ETA: Waiting for target..."
etaLabel.TextColor3 = Color3.fromRGB(88, 175, 255)
etaLabel.Font = Enum.Font.GothamBold
etaLabel.TextSize = 14
etaLabel.TextXAlignment = Enum.TextXAlignment.Left
etaLabel.Parent = StatsContainer

local TargetCash = 0
local RecentGains = {}
local lastCashValue = 0
local lastGainTick = tick()
local cashValueObj = nil

local function FormatTime(seconds)
    if seconds <= 0 or seconds == math.huge then return "Calculating..." end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

local function UpdateStatsUI()
    if not cashValueObj then return end
    local current = cashValueObj.Value
    currentCashLabel.Text = "Current Cash: $" .. tostring(current)
    
    if TargetCash > 0 then
        local missing = TargetCash - current
        if missing <= 0 then
            missingCashLabel.Text = "Missing: $0 (Target Reached!)"
            missingCashLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            etaLabel.Text = "ETA: Done!"
        else
            missingCashLabel.Text = "Missing: $" .. tostring(missing)
            missingCashLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            
            local totalGain, totalTime = 0, 0
            for _, g in ipairs(RecentGains) do
                totalGain = totalGain + g.amount
                totalTime = totalTime + g.time
            end
            
            if totalGain > 0 and totalTime > 0 then
                local cps = totalGain / totalTime
                local sec = missing / cps
                etaLabel.Text = "ETA: " .. FormatTime(sec)
            else
                etaLabel.Text = "ETA: Calculating speed..."
            end
        end
    else
        missingCashLabel.Text = "Missing: Target not set"
        etaLabel.Text = "ETA: Waiting for target..."
    end
end

targetBoxInput.FocusLost:Connect(function()
    local val = tonumber(targetBoxInput.Text)
    if val then
        TargetCash = val
    else
        TargetCash = 0
        targetBoxInput.Text = ""
    end
    UpdateStatsUI()
end)

task.spawn(function()
    local leaderstats = Player:WaitForChild("leaderstats", 10)
    if leaderstats then
        cashValueObj = leaderstats:WaitForChild("Cash", 10)
        if cashValueObj then
            lastCashValue = cashValueObj.Value
            cashValueObj:GetPropertyChangedSignal("Value"):Connect(function()
                local newVal = cashValueObj.Value
                if newVal > lastCashValue then
                    local gain = newVal - lastCashValue
                    local timeTaken = tick() - lastGainTick
                    
                    if timeTaken > 0.1 and timeTaken < 300 then
                        table.insert(RecentGains, {amount = gain, time = timeTaken})
                        if #RecentGains > 10 then
                            table.remove(RecentGains, 1)
                        end
                    end
                    lastGainTick = tick()
                end
                lastCashValue = newVal
                UpdateStatsUI()
            end)
            UpdateStatsUI()
        end
    end
end)

-- DISCORD CONTAINER
local DiscordContainer = Instance.new("Frame")
DiscordContainer.Size = UDim2.new(1, -100, 1, -60)
DiscordContainer.Position = UDim2.new(0, 90, 0, 50)
DiscordContainer.BackgroundTransparency = 1
DiscordContainer.Visible = false
DiscordContainer.Parent = MainFrame

local D_Card = Instance.new("Frame")
D_Card.Size = UDim2.new(1, -20, 1, -20)
D_Card.Position = UDim2.new(0, 10, 0, 10)
D_Card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
D_Card.Parent = DiscordContainer
Instance.new("UICorner", D_Card).CornerRadius = UDim.new(0, 12)
local D_Stroke = Instance.new("UIStroke", D_Card)
D_Stroke.Color = Color3.fromRGB(88, 101, 242)
D_Stroke.Thickness = 2

local discordTitle = Instance.new("TextLabel")
discordTitle.Size = UDim2.new(1, 0, 0, 40)
discordTitle.Position = UDim2.new(0, 0, 0, 10)
discordTitle.BackgroundTransparency = 1
discordTitle.Text = "JOIN MY DISCORD"
discordTitle.Font = Enum.Font.GothamBlack
discordTitle.TextSize = 20
discordTitle.TextColor3 = Color3.fromRGB(88, 101, 242)
discordTitle.Parent = D_Card

local discordDesc = Instance.new("TextLabel")
discordDesc.Size = UDim2.new(1, -40, 0, 60)
discordDesc.Position = UDim2.new(0, 20, 0, 55)
discordDesc.BackgroundTransparency = 1
discordDesc.Text = "Get the latest updates, report bugs, suggest features, and chat with the community!"
discordDesc.Font = Enum.Font.Gotham
discordDesc.TextSize = 13
discordDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
discordDesc.TextWrapped = true
discordDesc.Parent = D_Card

local copyDiscordBtn = Instance.new("TextButton")
copyDiscordBtn.Size = UDim2.new(0, 180, 0, 35)
copyDiscordBtn.Position = UDim2.new(0.5, -90, 0, 125)
copyDiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
copyDiscordBtn.Text = "COPY LINK"
copyDiscordBtn.Font = Enum.Font.GothamBold
copyDiscordBtn.TextSize = 14
copyDiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyDiscordBtn.Parent = D_Card
Instance.new("UICorner", copyDiscordBtn).CornerRadius = UDim.new(0, 8)

local discordExtra = Instance.new("TextLabel")
discordExtra.Size = UDim2.new(1, -40, 0, 30)
discordExtra.Position = UDim2.new(0, 20, 0, 175)
discordExtra.BackgroundTransparency = 1
discordExtra.Text = "If you want me to add more features, just join my discord!"
discordExtra.Font = Enum.Font.GothamBold
discordExtra.TextSize = 12
discordExtra.TextColor3 = Color3.fromRGB(255, 200, 80)
discordExtra.TextWrapped = true
discordExtra.Parent = D_Card

copyDiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/9E6AgcsT")
        copyDiscordBtn.Text = "COPIED!"
        copyDiscordBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        task.delay(2, function()
            copyDiscordBtn.Text = "COPY LINK"
            copyDiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)
    else
        copyDiscordBtn.Text = "NOT SUPPORTED"
        copyDiscordBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        task.delay(2, function()
            copyDiscordBtn.Text = "COPY LINK"
            copyDiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)
    end
end)

-- TABS LOGIC UPDATE
local function switchTab(tabName)
    MainContainer.Visible = (tabName == "Main")
    InfoContainer.Visible = (tabName == "Info")
    StatsContainer.Visible = (tabName == "Stats")
    DiscordContainer.Visible = (tabName == "Discord")

    MainTabBtn.BackgroundColor3 = (tabName == "Main") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(25, 25, 30)
    MainTabBtn.TextColor3 = (tabName == "Main") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)

    InfoTabBtn.BackgroundColor3 = (tabName == "Info") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(25, 25, 30)
    InfoTabBtn.TextColor3 = (tabName == "Info") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)

    StatsTabBtn.BackgroundColor3 = (tabName == "Stats") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(25, 25, 30)
    StatsTabBtn.TextColor3 = (tabName == "Stats") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)

    DiscordTabBtn.BackgroundColor3 = (tabName == "Discord") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(25, 25, 30)
    DiscordTabBtn.TextColor3 = (tabName == "Discord") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end

MainTabBtn.MouseButton1Click:Connect(function() switchTab("Main") end)
InfoTabBtn.MouseButton1Click:Connect(function() switchTab("Info") end)
StatsTabBtn.MouseButton1Click:Connect(function() switchTab("Stats") end)
DiscordTabBtn.MouseButton1Click:Connect(function() switchTab("Discord") end)

-- Draggable Logic for Main Menu
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function toggleMenu()
    MENU_VISIBLE = not MENU_VISIBLE
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {GroupTransparency = MENU_VISIBLE and 0 or 1}):Play()
    if not MENU_VISIBLE then
        task.delay(0.4, function() if not MENU_VISIBLE then MainFrame.Visible = false end end)
    end
end

MobileToggle.MouseButton1Click:Connect(toggleMenu)

DropdownButton.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

HopButton.MouseButton1Click:Connect(function()
    Config.ServerHop = not Config.ServerHop
    SaveConfig()
    HopButton.Text = "SERVER HOP: " .. (Config.ServerHop and "ON" or "OFF")
    HopButton.TextColor3 = Config.ServerHop and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

-- UTILITY FUNCTIONS
local function getPath(root, ...)
    local current = root
    for _, name in ipairs({...}) do
        if not (current and typeof(current) == "Instance") then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function getVehicle(part)
    local current = part
    while current and current ~= workspace do
        if current:IsA("Model") and (current:FindFirstChildOfClass("VehicleSeat") or current:FindFirstChildOfClass("DriveSeat")) then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function isPlayerInCar()
    if not Player.Character then return false end
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return getVehicle(hum.SeatPart) ~= nil
    end
    return false
end

local function safeTeleport(pos)
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local TargetEntity = Character
    
    if Humanoid and Humanoid.SeatPart then
        TargetEntity = getVehicle(Humanoid.SeatPart) or Humanoid.SeatPart.Parent
    end

    local function clearVelocity(entity)
        for _, part in ipairs(entity:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                part.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end
        end
        if entity:IsA("BasePart") then
            entity.AssemblyLinearVelocity = Vector3.new(0,0,0)
            entity.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end

    local success, err = pcall(function()
        clearVelocity(TargetEntity)
        TargetEntity:PivotTo(CFrame.new(pos + Vector3.new(0, 5, 0)))
        task.wait(0.1)
        clearVelocity(TargetEntity)
    end)

    if not success then
        ReportError("SYSTEM ERROR - Teleport", err)
    end
end

local function firePrompt(prompt, amount)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    amount = amount or 1
    for i = 1, amount do
        if not AUTO_FARM_ENABLED and not AUTO_FARM_BOX_ENABLED then break end
        if fireproximityprompt then
            fireproximityprompt(prompt)
        end
        task.wait(0.85)
    end
end

local function getToolCount(itemName)
    local count = 0
    if Player.Character then
        for _, v in ipairs(Player.Character:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name, itemName) then
                count = count + 1
            end
        end
    end
    if Player.Backpack then
        for _, v in ipairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name, itemName) then
                count = count + 1
            end
        end
    end
    return count
end

local function runAutoFarm()
    while AUTO_FARM_ENABLED do
        local success, err = pcall(function()
            if not workspace:FindFirstChild("Smuggling") then
                task.wait(2)
                return
            end

            local watchModel = getPath(workspace, "Smuggling", "Items", "Fake Watch", "Main")
            local bagModel = getPath(workspace, "Smuggling", "Items", "Fake Designer Bag", "Main")
            local sarsModel = getPath(workspace, "Smuggling", "Items", "Sarsaparilla", "Main")
            
            -- SMART INVENTORY CHECK
            local watchCount = getToolCount("Fake Watch")
            local bagCount = getToolCount("Fake Designer Bag")
            local sarsCount = getToolCount("Sarsaparilla")

            if AUTO_FARM_ENABLED and watchCount < 3 and watchModel then
                safeTeleport(watchModel:GetPivot().Position)
                task.wait(1.5)
                local prompt = getPath(watchModel, "PromptAtt", "SmugglePurchasePrompt")
                if prompt then firePrompt(prompt, 3 - watchCount) end
            end

            if AUTO_FARM_ENABLED and bagCount < 3 and bagModel then
                safeTeleport(bagModel:GetPivot().Position)
                task.wait(1.5)
                local prompt = getPath(bagModel, "PromptAtt", "SmugglePurchasePrompt")
                if prompt then firePrompt(prompt, 3 - bagCount) end
            end

            if AUTO_FARM_ENABLED and sarsCount < 4 and sarsModel then
                safeTeleport(sarsModel:GetPivot().Position)
                task.wait(1.5)
                local prompt = getPath(sarsModel, "PromptAtt", "SmugglePurchasePrompt")
                if prompt then firePrompt(prompt, 4 - sarsCount) end
            end

            if not AUTO_FARM_ENABLED then return end
            task.wait(1)

            -- SELL ITEMS
            local gym = getPath(workspace, "Smuggling", "Props", "Sell", "Gymbro")
            if gym then
                safeTeleport(gym:GetPivot().Position)
                task.wait(0.8)
            end
            
            local sellPromptArea = getPath(workspace, "Smuggling", "Sell", "Prompt")
            local sellPrompt = sellPromptArea and sellPromptArea:FindFirstChild("SmuggleSellPrompt")
            if sellPromptArea and sellPrompt then
                safeTeleport(sellPromptArea:GetPivot().Position)
                task.wait(0.5)
                firePrompt(sellPrompt, 1)
            end
            
            if not AUTO_FARM_ENABLED then return end
            task.wait(1)

            -- LAUNDERING
            local laundFolder = getPath(workspace, "Smuggling", "Props", "Laundering")
            if laundFolder then
                local children = laundFolder:GetChildren()
                local target = nil
                for _, child in ipairs(children) do
                    if child:IsA("Model") or child:IsA("BasePart") then
                        target = child
                        break
                    end
                end
                
                if target then
                    safeTeleport(target:GetPivot().Position)
                    task.wait(0.5)
                    local nearest = nil
                    for _, p in pairs(target:GetDescendants()) do
                        if p:IsA("ProximityPrompt") then
                            nearest = p
                            break
                        end
                    end
                    if not nearest then
                        for _, p in pairs(workspace:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.Parent and p.Parent:IsA("BasePart") and (p.Parent.Position - target:GetPivot().Position).Magnitude < 15 then
                                nearest = p
                                break
                            end
                        end
                    end
                    
                    if nearest then
                        firePrompt(nearest, 1)
                    end
                end
            end
        end)

        if not success then
            ReportError("SYSTEM ERROR - AutoFarm Smuggle", err)
        end
        
        task.wait(2)
    end
end

local function runAutoFarmBox()
    while AUTO_FARM_BOX_ENABLED do
        local success, err = pcall(function()
            local boxTool = Player.Backpack:FindFirstChild("Box")
            local charBoxTool = Player.Character and Player.Character:FindFirstChild("Box")
            
            -- 1. Si no tenemos la caja, ir a agarrarla
            if not boxTool and not charBoxTool then
                local getPart = getPath(workspace, "Boxes", "Get")
                local getPrompt = getPath(workspace, "Boxes", "Get", "Attachment", "Box")
                
                if getPart and getPrompt then
                    safeTeleport(getPart:GetPivot().Position)
                    task.wait(0.15)
                    if fireproximityprompt then
                        fireproximityprompt(getPrompt)
                    end
                    task.wait(0.1) 
                else
                    task.wait(0.5)
                    return
                end
            end
            
            if not AUTO_FARM_BOX_ENABLED then return end
            
            boxTool = Player.Backpack:FindFirstChild("Box")
            charBoxTool = Player.Character and Player.Character:FindFirstChild("Box")
            
            -- 2. Equipar la caja ("Box") si está en la mochila
            if boxTool then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(boxTool)
                end
            end
            
            -- 3. Si ya tenemos la caja, ir a entregarla
            if boxTool or charBoxTool then
                local depositPart = getPath(workspace, "Boxes", "Deposit")
                local depositPrompt = getPath(workspace, "Boxes", "Deposit", "Attachment", "Prompt")
                
                if depositPart and depositPrompt then
                    safeTeleport(depositPart:GetPivot().Position)
                    task.wait(0.15)
                    if fireproximityprompt then
                        fireproximityprompt(depositPrompt)
                    end
                end
            end
        end)
        
        if not success then
            ReportError("SYSTEM ERROR - AutoFarm Box", err)
            task.wait(1)
        else
            task.wait(0.1) 
        end
    end
end

FarmButton.MouseButton1Click:Connect(function()
    if not Config.AutoFarm then
        if not isPlayerInCar() then
            ShowNotification("NO CAR DETECTED", "You are not sitting in a car! Please sit in a vehicle to prevent glitches.")
        end
        if Config.AutoFarmBox then
            Config.AutoFarmBox = false
            AUTO_FARM_BOX_ENABLED = false
            FarmBoxButton.Text = "AUTO BOX: OFF"
            FarmBoxButton.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end

    Config.AutoFarm = not Config.AutoFarm
    SaveConfig()
    
    AUTO_FARM_ENABLED = Config.AutoFarm
    FarmButton.Text = "AUTO SMUGGLE: " .. (AUTO_FARM_ENABLED and "ON" or "OFF")
    FarmButton.TextColor3 = AUTO_FARM_ENABLED and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    
    if AUTO_FARM_ENABLED then
        task.spawn(runAutoFarm)
    end
end)

FarmBoxButton.MouseButton1Click:Connect(function()
    if not Config.AutoFarmBox then
        if Config.AutoFarm then
            Config.AutoFarm = false
            AUTO_FARM_ENABLED = false
            FarmButton.Text = "AUTO SMUGGLE: OFF"
            FarmButton.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end

    Config.AutoFarmBox = not Config.AutoFarmBox
    SaveConfig()
    
    AUTO_FARM_BOX_ENABLED = Config.AutoFarmBox
    FarmBoxButton.Text = "AUTO BOX: " .. (AUTO_FARM_BOX_ENABLED and "ON" or "OFF")
    FarmBoxButton.TextColor3 = AUTO_FARM_BOX_ENABLED and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    
    if AUTO_FARM_BOX_ENABLED then
        task.spawn(runAutoFarmBox)
    end
end)

-- Server Hop Logic
local function doServerHop()
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if not success then
        ReportError("SYSTEM ERROR - ServerHop API Fetch", result)
        return
    end

    if success and result and result.data then
        local servers = result.data
        for i = 1, 50 do
            local server = servers[math.random(1, #servers)]
            if server.playing < server.maxPlayers and server.id ~= JobId then
                local s2, e2 = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player)
                end)
                if not s2 then
                    ReportError("SYSTEM ERROR - ServerHop Teleport", e2)
                end
                task.wait(2)
            end
        end
    end
end

task.spawn(function()
    local lastHopTime = tick()
    while task.wait(1) do
        if Config.ServerHop then
            if tick() - lastHopTime >= (Config.HopMinutes * 60) then
                doServerHop()
                lastHopTime = tick()
            end
        else
            lastHopTime = tick()
        end
    end
end)

-- Auto start on load if enabled
if AUTO_FARM_ENABLED then
    task.spawn(runAutoFarm)
elseif AUTO_FARM_BOX_ENABLED then
    task.spawn(runAutoFarmBox)
end

print("[SYSTEM] Loaded. V2.7 Clean Exec Active.")
