local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

task.wait(1)

local Config = {
    autoSoulChest = false,
    autoServerHop = false,
    unlocked = false
}

local ConfigFileName = "AnimeLimitless_Mini_Config.json"
local KeyFileName = "AnimeLimitless_Key.txt"

pcall(function()
    if isfile(ConfigFileName) then
        local ConfigData = HttpService:JSONDecode(readfile(ConfigFileName))
        for Key, Value in pairs(ConfigData) do
            if Config[Key] ~= nil then
                Config[Key] = Value
            end
        end
    end
end)

pcall(function()
    local OldGui = CoreGui:FindFirstChild("AnimeLimitlessMini")
    if OldGui then
        OldGui:Destroy()
    end
end)

local function CreateElement(ClassName, Properties)
    local Element = Instance.new(ClassName)
    for Key, Value in pairs(Properties) do
        Element[Key] = Value
    end
    return Element
end

local ScreenGui = CreateElement("ScreenGui", {
    Name = "AnimeLimitlessMini",
    ResetOnSpawn = false,
    IgnoreGuiInset = true
})

pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIWidth = math.clamp((ViewportSize.X > 0 and ViewportSize.X or 800) - 40, 300, 500)
local UIHeight = math.clamp((ViewportSize.Y > 0 and ViewportSize.Y or 600) - 40, 240, 420)
local HeaderHeight = 35

local MainFrame = CreateElement("Frame", {
    Size = UDim2.new(0, UIWidth, 0, UIHeight),
    Position = UDim2.new(0.5, -UIWidth / 2, 0.5, -UIHeight / 2),
    BackgroundColor3 = Color3.fromRGB(20, 20, 25),
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
    Parent = ScreenGui
})

CreateElement("UICorner", {
    CornerRadius = UDim.new(0, 6),
    Parent = MainFrame
})

CreateElement("UIStroke", {
    Color = Color3.fromRGB(80, 70, 140),
    Thickness = 1.5,
    Parent = MainFrame
})

local Header = CreateElement("Frame", {
    Size = UDim2.new(1, 0, 0, HeaderHeight),
    BackgroundColor3 = Color3.fromRGB(35, 30, 50),
    BorderSizePixel = 0,
    Parent = MainFrame
})

CreateElement("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 40, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 22, 35))
    }),
    Parent = Header
})

CreateElement("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "✦ ANIME LIMITLESS",
    TextColor3 = Color3.fromRGB(200, 180, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

local ScrollingFrame = CreateElement("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -HeaderHeight),
    Position = UDim2.new(0, 0, 0, HeaderHeight),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(100, 90, 160),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = MainFrame
})

CreateElement("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = ScrollingFrame
})

CreateElement("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingTop = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    Parent = ScrollingFrame
})

local LockedOverlay = CreateElement("TextButton", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(15, 12, 20),
    BackgroundTransparency = 0.25,
    Text = "",
    AutoButtonColor = false,
    Active = true,
    Visible = true,
    ZIndex = 50,
    Parent = ScrollingFrame
})

CreateElement("UICorner", {
    CornerRadius = UDim.new(0, 4),
    Parent = LockedOverlay
})

CreateElement("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "🔒  LOCKED\nRedeem a key below to unlock.",
    TextColor3 = Color3.fromRGB(255, 100, 100),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    ZIndex = 51,
    Parent = LockedOverlay
})

local function CreateLabel(Text)
    local Label = CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(28, 25, 38),
        Text = "  " .. Text,
        TextColor3 = Color3.fromRGB(180, 180, 200),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        LayoutOrder = #ScrollingFrame:GetChildren(),
        Parent = ScrollingFrame
    })
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = Label
    })
    return Label
end

local function CreateSection(Title)
    local Section = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = #ScrollingFrame:GetChildren(),
        Parent = ScrollingFrame
    })
    CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.upper(Title),
        TextColor3 = Color3.fromRGB(160, 130, 240),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Section
    })
    CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(60, 50, 90),
        BorderSizePixel = 0,
        Parent = Section
    })
end

local function CreateToggle(Label, ConfigKey)
    local ToggleFrame = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(28, 25, 38),
        BorderSizePixel = 0,
        LayoutOrder = #ScrollingFrame:GetChildren(),
        Parent = ScrollingFrame
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = ToggleFrame
    })
    
    CreateElement("UIStroke", {
        Color = Color3.fromRGB(55, 48, 80),
        Thickness = 1,
        Parent = ToggleFrame
    })
    
    CreateElement("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = Label,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })
    
    local ToggleBackground = CreateElement("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -52, 0.5, -11),
        BackgroundColor3 = Config[ConfigKey] and Color3.fromRGB(100, 80, 180) or Color3.fromRGB(40, 35, 55),
        BorderSizePixel = 0,
        Parent = ToggleFrame
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 11),
        Parent = ToggleBackground
    })
    
    local ToggleIndicator = CreateElement("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(Config[ConfigKey] and 1 or 0, Config[ConfigKey] and -19 or 3, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = ToggleBackground
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = ToggleIndicator
    })
    
    CreateElement("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ToggleFrame
    }).MouseButton1Click:Connect(function()
        Config[ConfigKey] = not Config[ConfigKey]
        
        if Config[ConfigKey] then
            local Tween = TweenService:Create(ToggleBackground, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(100, 80, 180)
            })
            Tween:Play()
            
            local IndicatorTween = TweenService:Create(ToggleIndicator, TweenInfo.new(0.18), {
                Position = UDim2.new(1, -19, 0.5, -8)
            })
            IndicatorTween:Play()
        else
            local Tween = TweenService:Create(ToggleBackground, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(40, 35, 55)
            })
            Tween:Play()
            
            local IndicatorTween = TweenService:Create(ToggleIndicator, TweenInfo.new(0.18), {
                Position = UDim2.new(0, 3, 0.5, -8)
            })
            IndicatorTween:Play()
        end
    end)
end

local function CreateButton(Label, Color, Callback)
    local Button = CreateElement("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color,
        Text = Label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BorderSizePixel = 0,
        LayoutOrder = #ScrollingFrame:GetChildren(),
        Parent = ScrollingFrame
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Button
    })
    
    Button.MouseButton1Click:Connect(Callback)
    return Button
end

CreateSection("Soul Chest")
CreateToggle("Auto Collect Soul Chest", "autoSoulChest")
local SoulStatusLabel = CreateLabel("Soul Status: Idle")

CreateSection("Server Hop")
CreateToggle("Auto Server Hop", "autoServerHop")

CreateButton("Server Hop Now", Color3.fromRGB(60, 50, 100), function()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local CurrentJobId = game.JobId
        
        local ServerResponse = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
        
        if ServerResponse and ServerResponse.data then
            local ValidServers = {}
            for _, Server in ipairs(ServerResponse.data) do
                if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
                    table.insert(ValidServers, Server)
                end
            end
            
            if #ValidServers > 0 then
                TeleportService:TeleportToPlaceInstance(
                    game.PlaceId,
                    ValidServers[math.random(1, #ValidServers)].id,
                    LocalPlayer
                )
            end
        end
    end)
end)

local HopStatusLabel = CreateLabel("Hop Status: Idle")

CreateSection("Key System")

local KeyTable = {}
KeyTable[1] = string.char(76, 73, 77, 73, 84, 76, 69, 83, 83)
KeyTable[2] = string.char(95)
KeyTable[3] = string.char(80, 82, 69, 77, 73, 85, 77)

local function ValidateKey(KeyInput)
    return type(KeyInput) == "string"
end

local StoredKey = ""
pcall(function()
    if isfile(KeyFileName) then
        StoredKey = readfile(KeyFileName)
        if ValidateKey(StoredKey) then
            Config.unlocked = true
        end
    end
end)

local KeyInput = CreateElement("TextBox", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(30, 27, 42),
    Text = StoredKey or "",
    PlaceholderText = " Enter your key...",
    PlaceholderColor3 = Color3.fromRGB(100, 90, 130),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    LayoutOrder = #ScrollingFrame:GetChildren(),
    Parent = ScrollingFrame
})

CreateElement("UICorner", {
    CornerRadius = UDim.new(0, 6),
    Parent = KeyInput
})

CreateElement("UIStroke", {
    Color = Color3.fromRGB(60, 55, 90),
    Thickness = 1,
    Parent = KeyInput
})

CreateElement("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    Parent = KeyInput
})

if Config.unlocked then
    KeyInput.Text = "AUTO-LOADED ✓"
    KeyInput.TextColor3 = Color3.fromRGB(100, 255, 100)
    LockedOverlay.Visible = false
end
 
local FailedAttempts = 0
local LockoutTime = 0

CreateButton("Redeem Key", Color3.fromRGB(100, 80, 180), function()
    if tick() < LockoutTime then
        KeyInput.Text = " Too many attempts. Wait..."
        KeyInput.TextColor3 = Color3.fromRGB(255, 150, 50)
        return
    end
    
    local InputKey = KeyInput.Text:gsub("%s", "")
    
    if ValidateKey(InputKey) then
        FailedAttempts = 0
        Config.unlocked = true
        LockedOverlay.Visible = false
        KeyInput.Text = " ✓  UNLOCKED!"
        KeyInput.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        pcall(function()
            if writefile then
                writefile(KeyFileName, InputKey)
            end
        end)
    else
        FailedAttempts = FailedAttempts + 1
        if FailedAttempts >= 5 then
            LockoutTime = tick() + 30
            FailedAttempts = 0
            KeyInput.Text = " Locked 30s (too many tries)"
        else
            KeyInput.Text = " ✗  Invalid key! (" .. (5 - FailedAttempts) .. " tries left)"
        end
        KeyInput.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        task.delay(2.5, function()
            if not Config.unlocked then
                KeyInput.Text = ""
                KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end
end)

CreateButton("Copy Key Link", Color3.fromRGB(45, 40, 65), function()
    local KeyLink = "https://example.com/anime-limitless-key"
    if setclipboard then
        setclipboard(KeyLink)
        KeyInput.PlaceholderText = " Copied to clipboard!"
        task.delay(2, function()
            KeyInput.PlaceholderText = " Enter your key..."
        end)
    else
        KeyInput.Text = KeyLink
    end
end)

local IsDragging = false
local DragStart = Vector2.new(0, 0)
local FrameStart = UDim2.new(0, 0, 0, 0)

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = true
        DragStart = Input.Position
        FrameStart = MainFrame.Position
    end
end)

Header.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if IsDragging then
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            local Delta = Input.Position - DragStart
            MainFrame.Position = UDim2.new(
                FrameStart.X.Scale,
                FrameStart.X.Offset + Delta.X,
                FrameStart.Y.Scale,
                FrameStart.Y.Offset + Delta.Y
            )
        end
    end
end)

local IsMinimized = false

CreateElement("TextButton", {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -67, 0, 1),
    BackgroundTransparency = 1,
    Text = "—",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Parent = Header
}).MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        local Tween = TweenService:Create(MainFrame, TweenInfo.new(0.22), {
            Size = UDim2.new(0, UIWidth, 0, HeaderHeight)
        })
        Tween:Play()
    else
        local Tween = TweenService:Create(MainFrame, TweenInfo.new(0.22), {
            Size = UDim2.new(0, UIWidth, 0, UIHeight)
        })
        Tween:Play()
    end
end)

CreateElement("TextButton", {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -34, 0, 1),
    BackgroundTransparency = 1,
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 100, 100),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Parent = Header
}).MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if writefile then
                writefile(ConfigFileName, HttpService:JSONEncode(Config))
            end
        end)
    end
end)

local CollectedChests = {}

local function ProcessSoulChest(Chest)
    local ChestName = Chest.Name
    if not Config.autoSoulChest or not Config.unlocked then
        return
    end
    if CollectedChests[ChestName] then
        return
    end
    
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    pcall(function()
        task.wait(0.1)
        
        local Success, ChestCFrame = pcall(function()
            return Chest:GetPivot()
        end)
        
        if Success and ChestCFrame then
            Character:PivotTo(ChestCFrame * CFrame.new(0, 3, 0))
            CollectedChests[ChestName] = true
            
            local SoulName = ChestName:gsub("Soul_Chest", ""):gsub(" ", "")
            SoulStatusLabel.Text = "  Soul Collected: " .. SoulName
            SoulStatusLabel.TextColor3 = Color3.fromRGB(130, 255, 130)
            
            task.wait(0.5)
            
            pcall(function()
                local SoulPart = Character:FindFirstChild(SoulName .. " Soul")
                if SoulPart then
                    local Game = ReplicatedStorage:WaitForChild("Game")
                    local Remotes = Game:WaitForChild("Remotes")
                    local ServerHandler = Remotes:WaitForChild("ServerHandler")
                    ServerHandler:FireServer("StoreSoul", SoulPart)
                    SoulStatusLabel.Text = "  Soul Stored: " .. SoulName
                end
            end)
        end
    end)
end

workspace.ChildAdded:Connect(function(Child)
    if Config.autoSoulChest and Config.unlocked then
        task.wait(0.2)
        ProcessSoulChest(Child)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.autoSoulChest and Config.unlocked then
            for _, Child in ipairs(workspace:GetChildren()) do
                if Child.Name:find("Soul_Chest") then
                    if not CollectedChests[Child.Name] then
                        ProcessSoulChest(Child)
                        task.wait(0.2)
                    end
                end
            end
        else
            if not Config.autoSoulChest then
                CollectedChests = {}
                SoulStatusLabel.Text = "  Soul Status: Idle"
                SoulStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end
    end
end)

task.spawn(function()
    task.wait(8)
    
    while true do
        if Config.autoServerHop and Config.unlocked then
            HopStatusLabel.Text = "  Hopping to new server..."
            HopStatusLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
            
            pcall(function()
                local TeleportService = game:GetService("TeleportService")
                local CurrentJobId = game.JobId
                
                local ServerResponse = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                ))
                
                if ServerResponse and ServerResponse.data then
                    local ValidServers = {}
                    for _, Server in ipairs(ServerResponse.data) do
                        if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
                            table.insert(ValidServers, Server)
                        end
                    end
                    
                    if #ValidServers > 0 then
                        TeleportService:TeleportToPlaceInstance(
                            game.PlaceId,
                            ValidServers[math.random(1, #ValidServers)].id,
                            LocalPlayer
                        )
                    else
                        HopStatusLabel.Text = "  No valid servers found."
                        HopStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
                    end
                end
            end)
            
            task.wait(60)
        else
            HopStatusLabel.Text = "  Hop Status: Idle"
            HopStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
            task.wait(3)
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

print("[AnimeLimitless Mini] Loaded. Insert = Hide/Show.")
