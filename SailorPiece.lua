--!nocheck
--!nolint UnknownGlobal
-- Cancel old loops and connections
if (getgenv() :: any).SailorHub_Cancel then
    (getgenv() :: any).SailorHub_Cancel = true
end
if (getgenv() :: any).SailorHub_Connection then
    (getgenv() :: any).SailorHub_Connection:Disconnect()
end
if (getgenv() :: any).SailorHub_FPS then
    (getgenv() :: any).SailorHub_FPS:Disconnect()
end
(getgenv() :: any).SailorHub_Cancel = false
(getgenv() :: any).Config = nil -- Clear global config if any
(getgenv() :: any).CurrentIsland = "Unknown"
(getgenv() :: any).QuestAccepted = true; -- Default to true so normal farm works

-- Destroy old GUI if re-executing
local oldGui = game:GetService("CoreGui"):FindFirstChild("SailorHub")
if oldGui then
    oldGui:Destroy()
end

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

-- Config System
local function SaveConfig()
    pcall(function()
        local str = HttpService:JSONEncode(getgenv().Config)
        writefile("SailorHub_Config.json", str)
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile("SailorHub_Config.json") then
            local data = HttpService:JSONDecode(readfile("SailorHub_Config.json"))
            for i, v in pairs(data) do
                (getgenv().Config :: any)[i] = v
            end
        end
    end)
end

local Library = {}
Library.Colors = {
    BG = Color3.fromRGB(15,15,25), Sidebar = Color3.fromRGB(20,20,32),
    Content = Color3.fromRGB(25,25,38), TopBar = Color3.fromRGB(22,22,35),
    Accent = Color3.fromRGB(138,43,226), Accent2 = Color3.fromRGB(75,0,130), Text = Color3.fromRGB(245,245,255),
    Sub = Color3.fromRGB(160,160,185), Elem = Color3.fromRGB(32,32,48),
    TogOff = Color3.fromRGB(52,52,72), TogOn = Color3.fromRGB(138,43,226),
    Hover = Color3.fromRGB(48,48,68), Success = Color3.fromRGB(46,213,115),
    Warning = Color3.fromRGB(255,193,7), Error = Color3.fromRGB(255,71,87)
}
local C = Library.Colors
Library.Version = "v1.8.13"
Library.LastUpdated = "April 26, 2026 - 09:37 PM"

getgenv().Config = {
    SelectedWeapon = "None",
    AutoEquip = false,
    SelectedDungeon = "CidDungeon",
    SelectedDifficulty = "Normal", -- Kept Normal, removed duplicate below
    AutoKillDungeon = false,
    AutoVoteDifficulty = false,
    AutoReplayDungeon = false,
    AntiAFK = true,
    Skills = {false, false, false, false, false},
    AutoStats = {Melee = false, Defense = false, Sword = false, Power = false},
    StatAmount = 1,
    AutoCollectEggs = false,
    AutoBossFarm = false,
    AutoInfiniteTower = false,
    AutoStartWave = false,
    LastSuggestionTime = 0,
    SelectedQuestNPC = "QuestNPC1",
    AutoAcceptQuest = false,
    AutoFarm = false,
    AutoFarmQuest = false,
    AutoFarmAllNPCs = false,
    SelectedMob = "None",
    AttackDistance = 5,
    AttackPosition = "Above",
    SelectedEgg = "EasterEgg_HiddenEgg1",
    SelectedBoss = "None",
    LastReportTime = 0,
    AutoSummon = false,
    SelectedSummonBoss = "SaberBoss",
    AutoOpenChests = false,
    SelectedChest = "Common Chest",
    ChestAmount = 1,
    PityBoss = "None",
    MainBoss = "None",
    AutoPityFarm = false,
    MerchantItem = "Dungeon Key",
    MerchantAmount = 1,
    AutoBuyMerchant = false
}
local Config = getgenv().Config

function Library:CreateWindow(title, toggleKey)
    local main, toggleBtn
    local gui = Instance.new("ScreenGui")
    gui.Name = "SailorHub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    -- Improved Loading Screen with Gradient & Spinner
    local loader = Instance.new("Frame", gui)
    loader.Size = UDim2.new(1,0,1,0)
    loader.BackgroundColor3 = Color3.fromRGB(10,10,18)
    loader.ZIndex = 10000
    
    -- Add gradient background
    local gradient = Instance.new("UIGradient", loader)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10,10,18)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25,15,40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,18))
    }
    gradient.Rotation = 45
    
    local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    blur.Size = 24

    local lcontent = Instance.new("Frame", loader)
    lcontent.Size = UDim2.new(0,300,0,140)
    lcontent.Position = UDim2.new(0.5,-150,0.5,-70)
    lcontent.BackgroundTransparency = 1

    -- Spinner Icon
    local spinner = Instance.new("ImageLabel", lcontent)
    spinner.Size = UDim2.new(0, 40, 0, 40)
    spinner.Position = UDim2.new(0.5, -20, 0, -10)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://6031070940"
    spinner.ImageColor3 = C.Accent
    
    -- Animate Spinner
    local spinTween = TweenService:Create(spinner, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    spinTween:Play()

    local ltitle = Instance.new("TextLabel", lcontent)
    ltitle.Size = UDim2.new(1,0,0,30)
    ltitle.Position = UDim2.new(0,0,0,35)
    ltitle.Text = "âš“ SAILOR HUB âš“"
    ltitle.TextColor3 = C.Text
    ltitle.TextSize = 26
    ltitle.Font = Enum.Font.GothamBold
    ltitle.BackgroundTransparency = 1
    
    local titleGlow = Instance.new("TextLabel", ltitle)
    titleGlow.Size = UDim2.new(1,0,1,0)
    titleGlow.Text = ltitle.Text
    titleGlow.TextColor3 = C.Accent
    titleGlow.TextSize = 26
    titleGlow.Font = Enum.Font.GothamBold
    titleGlow.BackgroundTransparency = 1
    titleGlow.Position = UDim2.new(0,2,0,2)
    titleGlow.TextTransparency = 0.5
    titleGlow.ZIndex = 0

    local lstatus = Instance.new("TextLabel", lcontent)
    lstatus.Size = UDim2.new(1,0,0,20)
    lstatus.Position = UDim2.new(0,0,0,70)
    lstatus.Text = "Initializing Premium UI..."
    lstatus.TextColor3 = C.Sub
    lstatus.TextSize = 12
    lstatus.Font = Enum.Font.GothamMedium
    lstatus.BackgroundTransparency = 1

    local lbar_bg = Instance.new("Frame", lcontent)
    lbar_bg.Size = UDim2.new(1,0,0,6)
    lbar_bg.Position = UDim2.new(0,0,0,100)
    lbar_bg.BackgroundColor3 = C.Elem
    Instance.new("UICorner", lbar_bg).CornerRadius = UDim.new(1,0)

    local lbar = Instance.new("Frame", lbar_bg)
    lbar.Size = UDim2.new(0,0,1,0)
    lbar.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", lbar).CornerRadius = UDim.new(1,0)
    
    local barGradient = Instance.new("UIGradient", lbar)
    barGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.Accent),
        ColorSequenceKeypoint.new(1, C.Accent2)
    }

    local barGlow = Instance.new("Frame", lbar)
    barGlow.Size = UDim2.new(1,0,1,0)
    barGlow.BackgroundColor3 = C.Accent
    barGlow.BackgroundTransparency = 0.5
    Instance.new("UICorner", barGlow).CornerRadius = UDim.new(1,0)
    local uiGlowStroke = Instance.new("UIStroke", barGlow)
    uiGlowStroke.Color = C.Accent
    uiGlowStroke.Thickness = 2
    uiGlowStroke.Transparency = 0.5

    -- Background Loading Logic
    task.spawn(function()
        local steps = {
            {txt = "Checking Server Connection...", val = 0.25, fn = function() end},
            {txt = "Bypassing Anti-Cheat...", val = 0.5, fn = function() end},
            {txt = "Fetching Assets...", val = 0.75, fn = function() end},
            {txt = "Ready to Farm!", val = 1.0, fn = function() end}
        }

        for _, step in ipairs(steps) do
            lstatus.Text = step.txt
            TweenService:Create(lbar, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {Size = UDim2.new(step.val,0,1,0)}):Play()
            step.fn()
            task.wait(0.5)
        end

        spinTween:Cancel()
        local outTween = TweenService:Create(loader, TweenInfo.new(0.6), {BackgroundTransparency = 1})
        TweenService:Create(lstatus, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(ltitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(titleGlow, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(lbar_bg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(lbar, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(spinner, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        TweenService:Create(uiGlowStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(barGlow, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        
        TweenService:Create(blur, TweenInfo.new(0.8), {Size = 0}):Play()
        outTween:Play()
        outTween.Completed:Wait()
        
        loader:Destroy()
        blur:Destroy()
        
        if main then 
            main.Visible = true 
            main.Size = UDim2.new(0, 680, 0, 420)
            TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 720, 0, 460)}):Play()
        end
        if toggleBtn then 
            toggleBtn.Visible = true 
            toggleBtn.Size = UDim2.new(0,0,0,0)
            TweenService:Create(toggleBtn, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 55, 0, 55)}):Play()
        end
    end)


    print("Sailor UI Loaded: " .. Library.Version)

    main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,720,0,460)
    main.Position = UDim2.new(0.5,-360,0.5,-230)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel = 0
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
    
    -- Image Shadow for Premium Glow
    local glowShadow = Instance.new("ImageLabel", main)
    glowShadow.Name = "GlowShadow"
    glowShadow.BackgroundTransparency = 1
    glowShadow.Position = UDim2.new(0, -30, 0, -30)
    glowShadow.Size = UDim2.new(1, 60, 1, 60)
    glowShadow.ZIndex = 0
    glowShadow.Image = "rbxassetid://13112826725"
    glowShadow.ImageColor3 = C.Accent
    glowShadow.ImageTransparency = 0.6
    glowShadow.ScaleType = Enum.ScaleType.Slice
    glowShadow.SliceCenter = Rect.new(64, 64, 192, 192)

    -- Premium Outline
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = C.Accent
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.3

    -- TopBar with gradient
    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = C.TopBar
    top.BorderSizePixel = 0
    Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)
    -- Add gradient to top bar
    local topGradient = Instance.new("UIGradient", top)
    topGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.TopBar),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,35,52)),
        ColorSequenceKeypoint.new(1, C.TopBar)
    }
    topGradient.Rotation = 90
    local fix = Instance.new("Frame", top)
    fix.Size = UDim2.new(1,0,0,10)
    fix.Position = UDim2.new(0,0,1,-10)
    fix.BackgroundColor3 = C.TopBar
    fix.BorderSizePixel = 0

    local tl = Instance.new("TextLabel", top)
    tl.Size = UDim2.new(0,300,1,0)
    tl.Position = UDim2.new(0,15,0,0)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = C.Text
    tl.TextSize = 16
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local cls = Instance.new("TextButton", top)
    cls.Size = UDim2.new(0,40,0,40)
    cls.Position = UDim2.new(1,-40,0,0)
    cls.BackgroundTransparency = 1
    cls.Text = "X"
    cls.TextColor3 = C.Sub
    cls.TextSize = 16
    cls.Font = Enum.Font.GothamBold
    cls.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)

    -- Drag
    local drag,dI,dS,sP
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dS = i.Position
            sP = main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    top.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dI = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == dI and drag then
            local d = i.Position - dS
            main.Position = UDim2.new(sP.X.Scale, sP.X.Offset+d.X, sP.Y.Scale, sP.Y.Offset+d.Y)
        end
    end)

    -- Toggle key
    UIS.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == (toggleKey or Enum.KeyCode.K) then
            main.Visible = not main.Visible
        end
    end)
    
    -- Floating Toggle Button (Mobile/PC Friendly) - Premium
    toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Visible = false
    toggleBtn.Name = "SailorToggle"
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 10, 0.5, -27)
    toggleBtn.BackgroundColor3 = C.Accent
    toggleBtn.Image = "rbxassetid://6031070940"
    toggleBtn.ImageColor3 = C.Text
    toggleBtn.BorderSizePixel = 0
    toggleBtn.ZIndex = 1001
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0) -- Circular!
    
    -- Shadow for toggle button
    local toggleShadow = Instance.new("ImageLabel", toggleBtn)
    toggleShadow.BackgroundTransparency = 1
    toggleShadow.Position = UDim2.new(0, -15, 0, -15)
    toggleShadow.Size = UDim2.new(1, 30, 1, 30)
    toggleShadow.ZIndex = 1000
    toggleShadow.Image = "rbxassetid://13112826725"
    toggleShadow.ImageColor3 = C.Accent
    toggleShadow.ImageTransparency = 0.4
    toggleShadow.ScaleType = Enum.ScaleType.Slice
    toggleShadow.SliceCenter = Rect.new(64, 64, 192, 192)

    -- Add gradient to toggle button
    local toggleGradient = Instance.new("UIGradient", toggleBtn)
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.Accent),
        ColorSequenceKeypoint.new(1, C.Accent2)
    }
    toggleGradient.Rotation = 45
    
    -- Enhanced border with glow effect
    local btnStroke = Instance.new("UIStroke", toggleBtn)
    btnStroke.Color = Color3.new(1,1,1)
    btnStroke.Thickness = 1.5
    btnStroke.Transparency = 0.5
    
    -- Add pulsing animation to shadow instead of button size
    local pulseAnimation
    local function startPulse()
        pulseAnimation = TweenService:Create(toggleShadow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Size = UDim2.new(1, 45, 1, 45),
            ImageTransparency = 0.7
        })
        pulseAnimation:Play()
    end
    
    -- Hover effects
    toggleBtn.MouseEnter:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 60, 0, 60),
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.3), {
            Thickness = 2,
            Transparency = 0.2
        }):Play()
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 55, 0, 55),
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.3), {
            Thickness = 1.5,
            Transparency = 0.5
        }):Play()
    end)
    
    -- Draggable variables
    local isHolding = false
    local bDrag = false
    local bDS, bSP, startPos
    local dragThreshold = 10 -- Pixels before considering it a drag

    -- Click effect
    toggleBtn.MouseButton1Click:Connect(function()
        if bDrag then return end
        
        -- Toggle menu
        main.Visible = not main.Visible
        
        -- Premium Menu Open Animation
        if main.Visible then
            main.Size = UDim2.new(0, 680, 0, 420)
            TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 720, 0, 460)}):Play()
        end
        
        -- Spin toggle button
        TweenService:Create(toggleBtn, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Rotation = toggleBtn.Rotation + 360}):Play()
        
        -- Create ripple effect after toggle
        task.spawn(function()
            local ripple = Instance.new("Frame", toggleBtn)
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = Color3.new(1,1,1)
            ripple.BackgroundTransparency = 0.7
            ripple.BorderSizePixel = 0
            ripple.ZIndex = toggleBtn.ZIndex + 2
            Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
            
            TweenService:Create(ripple, TweenInfo.new(0.6), {
                Size = UDim2.new(2, 0, 2, 0),
                Position = UDim2.new(-0.5, 0, -0.5, 0),
                BackgroundTransparency = 1
            }):Play()
            
            game:GetService("Debris"):AddItem(ripple, 0.6)
        end)
    end)
    
    -- Start pulse animation on creation
    startPulse()

    -- Draggable Logic for Toggle Button (Fixed)
    toggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            isHolding = true
            bDrag = false
            bDS = i.Position
            bSP = toggleBtn.Position
            startPos = i.Position
            
            local connection
            connection = i.Changed:Connect(function() 
                if i.UserInputState == Enum.UserInputState.End then 
                    isHolding = false
                    if connection then connection:Disconnect() end
                    task.delay(0.1, function() bDrag = false end)
                end 
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(i)
        if isHolding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local distance = (i.Position - startPos).Magnitude
            if distance > dragThreshold then
                bDrag = true
            end
            
            if bDrag then
                local d = i.Position - bDS
                toggleBtn.Position = UDim2.new(bSP.X.Scale, bSP.X.Offset+d.X, bSP.Y.Scale, bSP.Y.Offset+d.Y)
            end
        end
    end)

    -- Sidebar (Now Scrolling for many tabs)
    local side = Instance.new("ScrollingFrame", main)
    side.Size = UDim2.new(0,150,1,-40)
    side.Position = UDim2.new(0,0,0,40)
    side.BackgroundColor3 = C.Sidebar
    side.BorderSizePixel = 0
    side.ScrollBarThickness = 2
    side.ScrollBarImageColor3 = C.Accent
    side.CanvasSize = UDim2.new(0,0,0,0)
    side.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local sl = Instance.new("UIListLayout", side)
    sl.Padding = UDim.new(0,4)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    local sp = Instance.new("UIPadding", side)
    sp.PaddingTop = UDim.new(0,8)
    sp.PaddingLeft = UDim.new(0,6)
    sp.PaddingRight = UDim.new(0,6)

    -- Content
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,-150,1,-40)
    content.Position = UDim2.new(0,150,0,40)
    content.BackgroundColor3 = C.Content
    content.BorderSizePixel = 0

    local window = {gui = gui, main = main, content = content, side = side, tabs = {}, activeTab = nil}

    -- User Count Label (Top Bar - Right Side)
    local countLabel = Instance.new("TextLabel", top)
    countLabel.Size = UDim2.new(0, 100, 1, 0)
    countLabel.Position = UDim2.new(1, -145, 0, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Recent Users: ..."
    countLabel.TextColor3 = C.Sub
    countLabel.TextSize = 10
    countLabel.Font = Enum.Font.GothamMedium
    countLabel.TextXAlignment = Enum.TextXAlignment.Right
    window.UserCountLabel = countLabel

    function window:CreateTab(name)
        local page = Instance.new("ScrollingFrame", content)
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = C.Accent
        page.BorderSizePixel = 0
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        local pl = Instance.new("UIListLayout", page)
        pl.Padding = UDim.new(0,6)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        local pp = Instance.new("UIPadding", page)
        pp.PaddingTop = UDim.new(0,10)
        pp.PaddingLeft = UDim.new(0,10)
        pp.PaddingRight = UDim.new(0,10)
        pp.PaddingBottom = UDim.new(0,180) -- Increased padding to prevent clipping of long dropdowns

        local btn = Instance.new("TextButton", side)
        btn.Size = UDim2.new(1,0,0,34)
        btn.BackgroundTransparency = 1
        btn.BackgroundColor3 = C.Accent
        btn.Text = name
        btn.TextColor3 = C.Sub
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
        
        -- Add hover effects
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent, TextColor3 = C.Text}):Play()
        end)
        btn.MouseLeave:Connect(function()
            if btn.BackgroundTransparency ~= 0.85 then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = C.Sub}):Play()
            end
        end)

        btn.MouseButton1Click:Connect(function()
            for _,t in pairs(self.tabs) do
                t.page.Visible = false
                t.btn.BackgroundTransparency = 1
                t.btn.TextColor3 = C.Sub
                if t.obj and t.obj.CloseAllDropdowns then
                    t.obj:CloseAllDropdowns()
                end
            end
            page.Visible = true
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = C.Text}):Play()
        end)

        local tab = {page = page, btn = btn}
        table.insert(self.tabs, tab)
        if #self.tabs == 1 then
            page.Visible = true
            btn.BackgroundTransparency = 0.85
            btn.TextColor3 = C.Text
        end

        local tabObj = {page = page, dropdowns = {}}
        tab.obj = tabObj

        function tabObj:CloseAllDropdowns()
            if tabObj.dropdowns then
                for _, d in pairs(tabObj.dropdowns) do
                    if d.lf then d.lf.Visible = false end
                    if d.h then d.h.ZIndex = 5 end
                end
            end
        end

        function tabObj:CreateToggle(name, default, callback)
            local h = Instance.new("Frame", page)
            h.Size = UDim2.new(1,0,0,38)
            h.BackgroundColor3 = C.Elem
            h.BorderSizePixel = 0
            Instance.new("UICorner", h).CornerRadius = UDim.new(0,7)
            
            -- Add hover effect for toggle container
            h.MouseEnter:Connect(function()
                TweenService:Create(h, TweenInfo.new(0.2), {BackgroundColor3 = C.Hover}):Play()
            end)
            h.MouseLeave:Connect(function()
                TweenService:Create(h, TweenInfo.new(0.2), {BackgroundColor3 = C.Elem}):Play()
            end)
            local l = Instance.new("TextLabel", h)
            l.Size = UDim2.new(1,-65,1,0)
            l.Position = UDim2.new(0,10,0,0)
            l.BackgroundTransparency = 1
            l.Text = name
            l.TextColor3 = C.Text
            l.TextSize = 12
            l.Font = Enum.Font.GothamMedium
            l.TextXAlignment = Enum.TextXAlignment.Left
            local tf = Instance.new("Frame", h)
            tf.Size = UDim2.new(0,40,0,20)
            tf.Position = UDim2.new(1,-50,0.5,-10)
            tf.BackgroundColor3 = default and C.TogOn or C.TogOff
            tf.BorderSizePixel = 0
            Instance.new("UICorner", tf).CornerRadius = UDim.new(1,0)
            
            -- Add gradient to toggle
            local togGradient = Instance.new("UIGradient", tf)
            togGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, default and C.TogOn or C.TogOff),
                ColorSequenceKeypoint.new(1, default and C.Accent2 or C.TogOff)
            }
            togGradient.Rotation = 90
            local ci = Instance.new("Frame", tf)
            ci.Size = UDim2.new(0,16,0,16)
            ci.Position = default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
            ci.BackgroundColor3 = Color3.new(1,1,1)
            ci.BorderSizePixel = 0
            Instance.new("UICorner", ci).CornerRadius = UDim.new(1,0)
            local on = default
            local b = Instance.new("TextButton", h)
            b.Size = UDim2.new(1,0,1,0)
            b.BackgroundTransparency = 1
            b.Text = ""
            b.MouseButton1Click:Connect(function()
                on = not on
                local targetColor = on and C.TogOn or C.TogOff
                local targetGradient = on and C.Accent2 or C.TogOff
                TweenService:Create(tf, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(ci, TweenInfo.new(0.2), {Position = on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
                
                -- Update gradient
                togGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, targetColor),
                    ColorSequenceKeypoint.new(1, targetGradient)
                }
                
                if callback then callback(on) end
            end)
            return h
        end

        function tabObj:CreateDropdown(name, options, default, multi, callback)
            local h = Instance.new("Frame", page)
            h.Size = UDim2.new(1,0,0,38)
            h.BackgroundColor3 = C.Elem
            h.BorderSizePixel = 0
            h.ClipsDescendants = false
            h.ZIndex = 5
            Instance.new("UICorner", h).CornerRadius = UDim.new(0,7)
            
            -- Add hover effect for dropdown container
            h.MouseEnter:Connect(function()
                TweenService:Create(h, TweenInfo.new(0.2), {BackgroundColor3 = C.Hover}):Play()
            end)
            h.MouseLeave:Connect(function()
                TweenService:Create(h, TweenInfo.new(0.2), {BackgroundColor3 = C.Elem}):Play()
            end)
            local l = Instance.new("TextLabel", h)
            l.Size = UDim2.new(0.4,0,1,0)
            l.Position = UDim2.new(0,10,0,0)
            l.BackgroundTransparency = 1
            l.Text = name
            l.TextColor3 = C.Text
            l.TextSize = 12
            l.Font = Enum.Font.GothamMedium
            l.TextXAlignment = Enum.TextXAlignment.Left
            local sel = multi and (default or {}) or (default or options[1])
            local db = Instance.new("TextButton", h)
            db.Size = UDim2.new(0.55,0,0,28)
            db.Position = UDim2.new(0.42,0,0.5,-14)
            db.BackgroundColor3 = C.TogOff
            db.BorderSizePixel = 0
            db.TextColor3 = C.Text
            db.TextSize = 11
            db.Font = Enum.Font.GothamMedium
            db.TextTruncate = Enum.TextTruncate.AtEnd
            db.Text = multi and (#sel > 0 and table.concat(sel,", ") or "Select...") or tostring(sel)
            db.ZIndex = 5
            Instance.new("UICorner", db).CornerRadius = UDim.new(0,5)
            
            -- Add gradient to dropdown button
            local dropGradient = Instance.new("UIGradient", db)
            dropGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, C.TogOff),
                ColorSequenceKeypoint.new(1, C.Elem)
            }
            dropGradient.Rotation = 90
            local lf = Instance.new("ScrollingFrame", h)
            lf.Size = UDim2.new(0.55,0,0,math.min(#options*28,150))
            lf.Position = UDim2.new(0.42,0,1,3)
            lf.BackgroundColor3 = C.Elem
            lf.BorderSizePixel = 0
            lf.Visible = false
            lf.ScrollBarThickness = 4
            lf.ScrollBarImageColor3 = C.Accent
            lf.ZIndex = 50
            lf.CanvasSize = UDim2.new(0,0,0,#options*28)
            lf.AutomaticCanvasSize = Enum.AutomaticSize.None
            Instance.new("UICorner", lf).CornerRadius = UDim.new(0,5)
            Instance.new("UIListLayout", lf).SortOrder = Enum.SortOrder.LayoutOrder

            local function populate(opts)
                for _,c in pairs(lf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                lf.CanvasSize = UDim2.new(0,0,0,#opts*28)
                lf.Size = UDim2.new(0.55,0,0,math.min(#opts*28,150))
                for _,o in ipairs(opts) do
                    local ob = Instance.new("TextButton", lf)
                    ob.Size = UDim2.new(1,0,0,28)
                    ob.BackgroundTransparency = 0.5
                    ob.BackgroundColor3 = C.Elem
                    ob.BorderSizePixel = 0
                    ob.Text = "  "..o
                    ob.TextColor3 = C.Sub
                    ob.TextSize = 11
                    ob.Font = Enum.Font.GothamMedium
                    ob.TextXAlignment = Enum.TextXAlignment.Left
                    ob.ZIndex = 50
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            local idx = table.find(sel, o)
                            if idx then table.remove(sel, idx) else table.insert(sel, o) end
                            db.Text = #sel > 0 and table.concat(sel,", ") or "Select..."
                            ob.TextColor3 = table.find(sel, o) and C.Accent or C.Sub
                        else
                            sel = o
                            db.Text = o
                            lf.Visible = false
                            -- Reset button color when selection is made
                            TweenService:Create(db, TweenInfo.new(0.2), {BackgroundColor3 = C.TogOff}):Play()
                            dropGradient.Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, C.TogOff),
                                ColorSequenceKeypoint.new(1, C.Elem)
                            }
                        end
                        if callback then callback(multi and sel or sel) end
                    end)
                    
                    -- Add hover effect for dropdown options
                    ob.MouseEnter:Connect(function()
                        TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundColor3 = C.Hover, TextColor3 = C.Text}):Play()
                    end)
                    ob.MouseLeave:Connect(function()
                        if not (multi and table.find(sel, o)) then
                            TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundColor3 = C.Elem, TextColor3 = C.Sub}):Play()
                        end
                    end)
                end
            end
            populate(options)
            table.insert(tabObj.dropdowns, {h = h, lf = lf})

            db.MouseButton1Click:Connect(function() 
                local wasVisible = lf.Visible
                tabObj:CloseAllDropdowns()
                lf.Visible = not wasVisible
                h.ZIndex = lf.Visible and 1000 or 5
                
                -- Animate dropdown button
                if lf.Visible then
                    TweenService:Create(db, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent}):Play()
                    dropGradient.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, C.Accent),
                        ColorSequenceKeypoint.new(1, C.Accent2)
                    }
                else
                    TweenService:Create(db, TweenInfo.new(0.2), {BackgroundColor3 = C.TogOff}):Play()
                    dropGradient.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, C.TogOff),
                        ColorSequenceKeypoint.new(1, C.Elem)
                    }
                end
            end)
            local dropObj = {refresh = function(_, newOpts)
                options = newOpts
                populate(newOpts)
            end}
            return h, dropObj
        end

        function tabObj:CreateSlider(name, min, max, default, suffix, callback)
            local h = Instance.new("Frame", page)
            h.Size = UDim2.new(1,0,0,50)
            h.BackgroundColor3 = C.Elem
            h.BorderSizePixel = 0
            Instance.new("UICorner", h).CornerRadius = UDim.new(0,7)
            local l = Instance.new("TextLabel", h)
            l.Size = UDim2.new(1,-10,0,20)
            l.Position = UDim2.new(0,10,0,4)
            l.BackgroundTransparency = 1
            l.Text = name..": "..default..(suffix or "")
            l.TextColor3 = C.Text
            l.TextSize = 12
            l.Font = Enum.Font.GothamMedium
            l.TextXAlignment = Enum.TextXAlignment.Left
            local bar = Instance.new("Frame", h)
            bar.Size = UDim2.new(1,-20,0,6)
            bar.Position = UDim2.new(0,10,0,34)
            bar.BackgroundColor3 = C.TogOff
            bar.BorderSizePixel = 0
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
            fill.BackgroundColor3 = C.Accent
            fill.BorderSizePixel = 0
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
            local knob = Instance.new("Frame", bar)
            knob.Size = UDim2.new(0,14,0,14)
            knob.Position = UDim2.new((default-min)/(max-min),-7,0.5,-7)
            knob.BackgroundColor3 = Color3.new(1,1,1)
            knob.BorderSizePixel = 0
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
            local sliding = false
            local ib = Instance.new("TextButton", bar)
            ib.Size = UDim2.new(1,0,0,20)
            ib.Position = UDim2.new(0,0,-1,0)
            ib.BackgroundTransparency = 1
            ib.Text = ""
            ib.MouseButton1Down:Connect(function() sliding = true end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local abs = bar.AbsolutePosition.X
                    local sz = bar.AbsoluteSize.X
                    local pct = math.clamp((i.Position.X - abs) / sz, 0, 1)
                    local val = math.floor(min + (max-min)*pct)
                    fill.Size = UDim2.new(pct,0,1,0)
                    knob.Position = UDim2.new(pct,-7,0.5,-7)
                    l.Text = name..": "..val..(suffix or "")
                    if callback then callback(val) end
                end
            end)
            return h
        end

        function tabObj:CreateButton(name, callback)
            local b = Instance.new("TextButton", page)
            b.Size = UDim2.new(1,0,0,36)
            b.BackgroundColor3 = C.Accent
            b.BorderSizePixel = 0
            b.Text = name
            b.TextColor3 = C.Text
            b.TextSize = 13
            b.Font = Enum.Font.GothamBold
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
            
            -- Add gradient to button
            local btnGradient = Instance.new("UIGradient", b)
            btnGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, C.Accent),
                ColorSequenceKeypoint.new(0.5, C.Accent2),
                ColorSequenceKeypoint.new(1, C.Accent)
            }
            btnGradient.Rotation = 90
            
            -- Hover effects
            b.MouseEnter:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent2}):Play()
                btnGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, C.Accent2),
                    ColorSequenceKeypoint.new(1, C.Accent)
                }
            end)
            b.MouseLeave:Connect(function()
                btnGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, C.Accent),
                    ColorSequenceKeypoint.new(0.5, C.Accent2),
                    ColorSequenceKeypoint.new(1, C.Accent)
                }
            end)
            
            -- Click effect
            b.MouseButton1Click:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(1,0,0,34)}):Play()
                task.wait(0.1)
                TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(1,0,0,36)}):Play()
                if callback then callback() end
            end)
            return b
        end

        function tabObj:CreateLabel(text)
            local l = Instance.new("TextLabel", page)
            l.Size = UDim2.new(1,0,0,22)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = C.Sub
            l.TextSize = 11
            l.Font = Enum.Font.GothamMedium
            l.TextXAlignment = Enum.TextXAlignment.Left
            return l
        end

        function tabObj:CreateTextBox(text, placeholder, callback)
            local tb_bg = Instance.new("Frame", page)
            tb_bg.Size = UDim2.new(1,0,0,60)
            tb_bg.BackgroundColor3 = C.Elem
            tb_bg.BorderSizePixel = 0
            Instance.new("UICorner", tb_bg)
            
            local t = Instance.new("TextLabel", tb_bg)
            t.Size = UDim2.new(1,-20,0,25)
            t.Position = UDim2.new(0,10,0,5)
            t.BackgroundTransparency = 1
            t.Text = text
            t.TextColor3 = C.Sub
            t.TextSize = 12
            t.Font = Enum.Font.GothamMedium
            t.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", tb_bg)
            box.Size = UDim2.new(1,-20,0,20)
            box.Position = UDim2.new(0,10,0,30)
            box.BackgroundColor3 = Color3.fromRGB(25,25,35)
            box.PlaceholderText = placeholder or "Enter text..."
            box.Text = ""
            box.TextColor3 = C.Text
            box.TextSize = 13
            box.Font = Enum.Font.Gotham
            box.BorderSizePixel = 0
            Instance.new("UICorner", box)
            
            box.FocusLost:Connect(function()
                callback(box.Text)
            end)
            box:GetPropertyChangedSignal("Text"):Connect(function()
                callback(box.Text)
            end)
            
            return tb_bg
        end

        function tabObj:CreateDiscordCard(name, invite, members, online)
            local dCard = Instance.new("Frame", page)
            dCard.Size = UDim2.new(1,-10,0,80)
            dCard.BackgroundColor3 = Color3.fromRGB(32,34,37)
            dCard.BorderSizePixel = 0
            Instance.new("UICorner", dCard).CornerRadius = UDim.new(0,8)

            local dIcon = Instance.new("ImageLabel", dCard)
            dIcon.Size = UDim2.new(0,50,0,50)
            dIcon.Position = UDim2.new(0,10,0.5,-25)
            dIcon.BackgroundColor3 = Color3.fromRGB(47,49,54)
            dIcon.Image = "rbxassetid://10651235308"
            Instance.new("UICorner", dIcon).CornerRadius = UDim.new(0,12)

            local dTitle = Instance.new("TextLabel", dCard)
            dTitle.Size = UDim2.new(1,-150,0,20)
            dTitle.Position = UDim2.new(0,70,0,15)
            dTitle.Text = name
            dTitle.TextColor3 = Color3.new(1,1,1)
            dTitle.TextSize = 15
            dTitle.Font = Enum.Font.GothamBold
            dTitle.TextXAlignment = Enum.TextXAlignment.Left
            dTitle.BackgroundTransparency = 1

            local dInfo = Instance.new("TextLabel", dCard)
            dInfo.Size = UDim2.new(1,-150,0,20)
            dInfo.Position = UDim2.new(0,70,0,35)
            dInfo.Text = "ðŸŸ¢ "..online.." Online  âšª "..members.." Members"
            dInfo.TextColor3 = Color3.fromRGB(185,187,190)
            dInfo.TextSize = 11
            dInfo.Font = Enum.Font.GothamMedium
            dInfo.TextXAlignment = Enum.TextXAlignment.Left
            dInfo.BackgroundTransparency = 1

            local dJoin = Instance.new("TextButton", dCard)
            dJoin.Size = UDim2.new(0,80,0,30)
            dJoin.Position = UDim2.new(1,-90,0.5,-15)
            dJoin.BackgroundColor3 = Color3.fromRGB(88,101,242)
            dJoin.Text = "Join"
            dJoin.TextColor3 = Color3.new(1,1,1)
            dJoin.Font = Enum.Font.GothamBold
            dJoin.TextSize = 13
            Instance.new("UICorner", dJoin).CornerRadius = UDim.new(0,4)
            dJoin.MouseButton1Click:Connect(function()
                setclipboard(invite)
                window:Notify("Discord", "Invite link copied to clipboard!")
            end)
            return dCard
        end

        return tabObj
    end

    function window:Notify(title, text)
        local n = Instance.new("Frame", gui)
        n.Size = UDim2.new(0,280,0,60)
        n.Position = UDim2.new(1,300,1,-80)
        n.BackgroundColor3 = C.TopBar
        n.BorderSizePixel = 0
        Instance.new("UICorner", n).CornerRadius = UDim.new(0,8)
        local nt = Instance.new("TextLabel", n)
        nt.Size = UDim2.new(1,-16,0,22)
        nt.Position = UDim2.new(0,8,0,6)
        nt.BackgroundTransparency = 1
        nt.Text = title
        nt.TextColor3 = C.Accent
        nt.TextSize = 13
        nt.Font = Enum.Font.GothamBold
        nt.TextXAlignment = Enum.TextXAlignment.Left
        local nc = Instance.new("TextLabel", n)
        nc.Size = UDim2.new(1,-16,0,20)
        nc.Position = UDim2.new(0,8,0,30)
        nc.BackgroundTransparency = 1
        nc.Text = text
        nc.TextColor3 = C.Sub
        nc.TextSize = 11
        nc.Font = Enum.Font.GothamMedium
        nc.TextXAlignment = Enum.TextXAlignment.Left
        TweenService:Create(n, TweenInfo.new(0.4), {Position = UDim2.new(1,-300,1,-80)}):Play()
        task.delay(4, function()
            TweenService:Create(n, TweenInfo.new(0.4), {Position = UDim2.new(1,300,1,-80)}):Play()
            task.wait(0.5)
            n:Destroy()
        end)
    end

    return window
end


-- Boss Data for Auto Farm
local BossData = {
    {Name = "JinwooBoss", Island = "Sailor"},
    {Name = "YujiBoss", Island = "Shibuya"},
    {Name = "GojoBoss", Island = "Shibuya"},
    {Name = "SukunaBoss", Island = "Shibuya"},
    {Name = "AizenBoss", Island = "HollowIsland"},
    {Name = "YamatoBoss", Island = "Judgement"},
    {Name = "StrongestShinobiBoss", Island = "Ninja"},
    {Name = "AlucardBoss", Island = "World"}
}

local summonBosses = {"SaberBoss", "QinShiBoss", "IchigoBoss", "GilgameshBoss", "BlessedMaidenBoss", "SaberAlterBoss", "MoonSlayerBoss", "IceQueenBoss", "GreatMage", "TrueAizen", "FinalAizen", "StrongestToday", "StrongestHistory", "Atomic"}

-- Load saved settings immediately
LoadConfig()

local Window = Library:CreateWindow("Sailor Piece Hub", Enum.KeyCode.K)

-- UI Setup
local MainTab = Window:CreateTab("Combat")
local FarmTab = Window:CreateTab("Farm")
local TeleportTab = Window:CreateTab("Teleport")
local DungeonTab = Window:CreateTab("Dungeon")
local CommunityTab = Window:CreateTab("Community")
local EventTab = Window:CreateTab("Event")
local StatsTab = Window:CreateTab("Stats")
local SummonTab = Window:CreateTab("Summon Boss")
local ChestTab = Window:CreateTab("Chest Opener")
local PityTab = Window:CreateTab("Auto Boss + Pity")
local MerchantTab = Window:CreateTab("Merchant")
local ReportTab = Window:CreateTab("Bug Report")
local ChangelogTab = Window:CreateTab("Changelog")

-- Quest Data Mapping
local QuestsData = {
    ["QuestNPC1"] = {Island="Starter", Mobs={"Thief"}},
    ["QuestNPC2"] = {Island="Starter", Mobs={"ThiefBoss"}},
    ["QuestNPC3"] = {Island="Jungle", Mobs={"Monkey"}},
    ["QuestNPC4"] = {Island="Jungle", Mobs={"MonkeyBoss"}},
    ["QuestNPC5"] = {Island="Desert", Mobs={"DesertBandit"}},
    ["QuestNPC6"] = {Island="Desert", Mobs={"DesertBoss"}},
    ["QuestNPC7"] = {Island="Snow", Mobs={"FrostRogue"}},
    ["QuestNPC8"] = {Island="Snow", Mobs={"SnowBoss"}},
    ["QuestNPC9"] = {Island="Shibuya", Mobs={"Sorcerer"}},
    ["QuestNPC10"] = {Island="Shibuya", Mobs={"PandaMiniBoss"}},
    ["QuestNPC11"] = {Island="HollowIsland", Mobs={"Hollow"}},
    ["QuestNPC12"] = {Island="Shinjuku", Mobs={"StrongSorcerer"}},
    ["QuestNPC13"] = {Island="Shinjuku", Mobs={"Curse"}},
    ["QuestNPC14"] = {Island="Slime", Mobs={"Slime"}},
    ["QuestNPC15"] = {Island="Academy", Mobs={"AcademyTeacher"}},
    ["QuestNPC16"] = {Island="Judgement", Mobs={"Swordsman"}},
    ["QuestNPC17"] = {Island="SoulDominion", Mobs={"Quincy"}},
    ["QuestNPC18"] = {Island="Ninja", Mobs={"Ninja"}},
    ["QuestNPC19"] = {Island="Lawless", Mobs={"ArenaFighter"}},
    ["Auto Farm Bunny"] = {Island="Easter", Mobs={"Bunny"}}
}

-- Remote Helper
local function GetRemote(folderName, remoteName)
    local rs = game:GetService("ReplicatedStorage")
    local folder = rs:FindFirstChild(folderName) or rs:FindFirstChild("Remotes") or rs:FindFirstChild("RemoteEvents")
    if folder then
        return folder:FindFirstChild(remoteName)
    end
    return nil
end

local function AbandonQuest()
    local r = GetRemote("RemoteEvents", "QuestAbandon")
    if r then r:FireServer("repeatable") end
end

local function TeleportToIsland(island)
    (getgenv() :: any).CurrentIsland = island
    local r = GetRemote("Remotes", "TeleportToPortal")
    if r then r:FireServer(island) end
end

local function AcceptQuest(npc)
    local r = GetRemote("RemoteEvents", "QuestAccept")
    if r then r:FireServer(npc) end
end

-- Combat Tab (Weapons & Attack)
local _, weaponDropdownObj = MainTab:CreateDropdown("Select Weapon", {"None"}, Config.SelectedWeapon or "None", false, function(v)
    Config.SelectedWeapon = v
    SaveConfig()
end)

MainTab:CreateToggle("Auto Equip", Config.AutoEquip, function(v)
    Config.AutoEquip = v
    SaveConfig()
end)

MainTab:CreateDropdown("Attack Position", {"Above", "Below", "Behind"}, Config.AttackPosition or "Above", false, function(v)
    Config.AttackPosition = v
    SaveConfig()
end)

MainTab:CreateSlider("Attack Distance", 1, 15, Config.AttackDistance or 5, " m", function(v)
    Config.AttackDistance = v
    SaveConfig()
end)

MainTab:CreateLabel("--- Auto Skills ---")
MainTab:CreateToggle("Auto Z (Skill 1)", false, function(v) Config.Skills[1] = v; SaveConfig() end)
MainTab:CreateToggle("Auto X (Skill 2)", false, function(v) Config.Skills[2] = v; SaveConfig() end)
MainTab:CreateToggle("Auto C (Skill 3)", false, function(v) Config.Skills[3] = v; SaveConfig() end)
MainTab:CreateToggle("Auto V (Skill 4)", false, function(v) Config.Skills[4] = v; SaveConfig() end)
MainTab:CreateToggle("Auto F (Skill 5)", false, function(v) Config.Skills[5] = v; SaveConfig() end)

MainTab:CreateLabel("--- Codes ---")
MainTab:CreateButton("Redeem All Codes", function()
    local codes = {
        "BIGGESTUPDATEYET", "SEA2FINALLY", "4SPECS", "SEABEASTS", "GOODFREECODE", 
        "850MVISITSWOAHH", "MOREGOODFREECODE", "OVER800KFOLLOWINSANE", "SORRYFORBADSEA2QUEST", 
        "500KFAVORITES", "900MVISITSTYSMM", "900KLIKESTYYY", "LASTRESTARTHOPEFULLY", 
        "YETANOTHERFREECODE", "BUGFIXESCODES", "YETANOTHERFREECODE2", "THEOTHERFREECODEMB"
    }
    local possibleNames = {"CodeRedeem", "RedeemCode", "Redeem", "Code", "PromoCode", "Codes"}
    local remote = nil
    for _, name in ipairs(possibleNames) do
        remote = GetRemote("RemoteEvents", name)
        if remote then break end
    end
    
    if remote then
        for _, code in ipairs(codes) do
            task.spawn(function()
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(code)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(code)
                    end
                end)
            end)
            task.wait(0.1)
        end
        Window:Notify("Codes", "All codes have been attempted!")
    else
        Window:Notify("Error", "Redeem remote not found!")
    end
end)

-- Farm Tab (Quests & Farming)
local questNPCs = {}
for i = 1, 19 do table.insert(questNPCs, "Quest NPC "..i) end
table.insert(questNPCs, "Auto Farm Bunny")

FarmTab:CreateDropdown("Select Quest NPC", questNPCs, Config.SelectedQuestNPC or "Quest NPC 1", false, function(v)
    local npcName = v
    if v:find("Quest NPC ") then
        npcName = v:gsub("Quest NPC ", "QuestNPC")
    end
    Config.SelectedQuestNPC = npcName
    SaveConfig()
    
    -- Auto Logic: Abandon -> Teleport -> Accept
    task.spawn(function()
        (getgenv() :: any).QuestAccepted = false -- Pause attack
        AbandonQuest()
        local qd = QuestsData[npcName]
        if qd then
            TeleportToIsland(qd.Island)
            task.wait(2)
            if npcName ~= "Auto Farm Bunny" then
                AcceptQuest(npcName)
                task.wait(1)
            end
        end
        (getgenv() :: any).QuestAccepted = true -- Resume attack
    end)
end)

FarmTab:CreateToggle("Auto Farm ALL NPCs", Config.AutoFarmAllNPCs, function(v)
    Config.AutoFarmAllNPCs = v
    SaveConfig()
end)

FarmTab:CreateToggle("Auto Farm Selected Quest", Config.AutoFarmQuest, function(v)
    Config.AutoFarmQuest = v
    SaveConfig()
    if v then
        task.spawn(function()
            (getgenv() :: any).QuestAccepted = false
            local npcName = Config.SelectedQuestNPC
            AbandonQuest()
            local qd = QuestsData[npcName]
            if qd then
                TeleportToIsland(qd.Island)
                task.wait(2)
                if npcName ~= "Auto Farm Bunny" then
                    AcceptQuest(npcName)
                    task.wait(1)
                end
            end
            (getgenv() :: any).QuestAccepted = true
        end)
    end
end)

-- Teleport Selection
local islands = {
    "Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya", "HollowIsland", 
    "Boss", "Dungeon", "Shinjuku", "Slime", "Academy", "Judgement", "Ninja", 
    "Lawless", "Tower", "Easter", "World", "SoulDominion"
}

TeleportTab:CreateDropdown("Select Island", islands, "Starter", false, function(v)
    -- Si el usuario viaja manualmente, apagamos los farms para que no lo jalen de vuelta
    Config.AutoFarm = false
    Config.AutoFarmQuest = false
    Config.AutoBossFarm = false
    Config.SelectedBoss = "None"
    SaveConfig()
    
    TeleportToIsland(v)
    Window:Notify("Teleport", "Traveling to: " .. v .. "\n(Auto Farm Disabled)")
end)

-- Dungeon Tab
DungeonTab:CreateToggle("Auto Infinite Tower", false, function(v)
    Config.AutoInfiniteTower = v
    SaveConfig()
end)

DungeonTab:CreateToggle("Auto Start Wave (Vote)", false, function(v)
    Config.AutoStartWave = v
    SaveConfig()
end)

DungeonTab:CreateDropdown("Select Dungeon", {"CidDungeon", "RuneDungeon", "DoubleDungeon"}, "CidDungeon", false, function(v)
    Config.SelectedDungeon = v
end)

DungeonTab:CreateButton("Start Dungeon", function()
    local args = {
        Config.SelectedDungeon
    }
    (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestDungeonPortal") :: any):FireServer(unpack(args))
    Window:Notify("Dungeon", "Requested portal for: " .. Config.SelectedDungeon)
end)

DungeonTab:CreateDropdown("Select Difficulty", {"Easy", "Medium", "Hard", "Extreme"}, "Easy", false, function(v)
    Config.SelectedDifficulty = v
end)

DungeonTab:CreateButton("Vote Difficulty", function()
    local args = {
        Config.SelectedDifficulty
    }
    (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveVote") :: any):FireServer(unpack(args))
    Window:Notify("Dungeon", "Voted for: " .. Config.SelectedDifficulty)
end)

DungeonTab:CreateToggle("Auto Kill Dungeon", Config.AutoKillDungeon, function(v)
    Config.AutoKillDungeon = v
    SaveConfig()
end)

DungeonTab:CreateToggle("Auto Vote Difficulty", Config.AutoVoteDifficulty, function(v)
    Config.AutoVoteDifficulty = v
    SaveConfig()
end)

DungeonTab:CreateToggle("Auto Replay Dungeon", Config.AutoReplayDungeon, function(v)
    Config.AutoReplayDungeon = v
    SaveConfig()
end)

-- Stats Tab
StatsTab:CreateLabel("--- Auto Stats ---")
StatsTab:CreateTextBox("Points to add at once:", tostring(Config.StatAmount or 1), function(v)
    Config.StatAmount = tonumber(v) or 1
    SaveConfig()
end)

for _, stat in ipairs({"Melee", "Defense", "Sword", "Power"}) do
    StatsTab:CreateToggle("Auto "..stat, Config.AutoStats[stat] or false, function(v)
        Config.AutoStats[stat] = v
        SaveConfig()
    end)
end

-- Event Tab
EventTab:CreateLabel("--- Easter Event ---")
EventTab:CreateToggle("Auto Collect All Eggs", Config.AutoCollectEggs, function(v)
    Config.AutoCollectEggs = v
    SaveConfig()
end)

local _eggDropdown, eggDropObj = EventTab:CreateDropdown("Select Egg in Map", {"None"}, "None", false, function(v)
    Config.SelectedEgg = v
    SaveConfig()
end)

EventTab:CreateButton("Refresh Egg List", function()
    local list = {"None"}
    local folder = workspace:FindFirstChild("EasterEggs")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            local name = v.Name
            if not name:find("SpawnPoints") and name ~= "HiddenEggs" and name ~= "TimedSpawnPoints" then
                table.insert(list, name)
            end
        end
    end
    eggDropObj:refresh(list)
    Window:Notify("Event", "Egg list updated!")
end)

EventTab:CreateButton("TP to Selected Egg", function()
    local targetName = Config.SelectedEgg
    if targetName == "None" then return end
    
    -- Temporarily stop farm to allow TP
    _G.currentTarget = nil
    
    local folder = workspace:FindFirstChild("EasterEggs")
    local e = folder and folder:FindFirstChild(targetName)
    
    if e then
        local p = e:FindFirstChild("ProximityPrompt", true)
        if p then
            player.Character.HumanoidRootPart.CFrame = p.Parent.CFrame * CFrame.new(0, 2, 0)
            Window:Notify("Success", "Arrived at " .. targetName)
        else
            player.Character.HumanoidRootPart.CFrame = e:GetPivot()
        end
    else
        Window:Notify("Error", "Egg not found! Try 'Refresh Egg List'")
    end
end)

-- Pity Tab Setup
PityTab:CreateLabel("--- Pity Status ---")
local PityLabel = PityTab:CreateLabel("Current Pity: Loading...")

PityTab:CreateLabel("--- Build Pity (25/25) ---")
PityTab:CreateLabel("Current Strategy: Auto-Summoning SaberBoss")

PityTab:CreateLabel("--- Main Boss (Pity Kill) ---")
local combinedBossList = {"None"}
for _, b in ipairs(BossData) do table.insert(combinedBossList, b.Name) end
for _, b in ipairs(summonBosses) do table.insert(combinedBossList, b) end

PityTab:CreateDropdown("Select Main Boss", combinedBossList, Config.MainBoss or "None", false, function(v)
    Config.MainBoss = v
    SaveConfig()
end)

PityTab:CreateToggle("Enable Pity Smart Farm", Config.AutoPityFarm, function(v)
    Config.AutoPityFarm = v
    if v then
        Config.AutoSummon = false
        Config.AutoBossFarm = false
        Config.AutoFarm = false
        Config.AutoFarmQuest = false
        Window:Notify("Pity Farm", "Other farms disabled to avoid conflicts.")
    end
    SaveConfig()
end)

PityTab:CreateLabel("--- How it works ---")
PityTab:CreateLabel("1. Kills 'Pity Boss' until 25/25")
PityTab:CreateLabel("2. When 25/25, goes to 'Main Boss'")
PityTab:CreateLabel("3. Resets back to step 1 after kill")

-- Pity Monitor Loop
task.spawn(function()
    while task.wait(1) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        pcall(function()
            local pityObj = player.PlayerGui:FindFirstChild("BossUI") 
                and player.PlayerGui.BossUI:FindFirstChild("MainFrame")
                and player.PlayerGui.BossUI.MainFrame:FindFirstChild("BossHPBar")
                and player.PlayerGui.BossUI.MainFrame.BossHPBar:FindFirstChild("Pity")
            
            if pityObj then
                PityLabel.Text = "Current Status: " .. pityObj.ContentText
            else
                PityLabel.Text = "Current Status: Pity UI not found"
            end
        end)
    end
end)

-- Boss Farm Logic
FarmTab:CreateLabel("--- Bosses ---")
FarmTab:CreateToggle("Auto Farm ALL Bosses", Config.AutoBossFarm, function(v)
    Config.AutoBossFarm = v
    SaveConfig()
end)

local bossNames = {"None"}
for _, b in ipairs(BossData) do table.insert(bossNames, b.Name) end
FarmTab:CreateDropdown("Farm Specific Boss", bossNames, "None", false, function(v)
    Config.SelectedBoss = v
    SaveConfig()
    if v ~= "None" then
        for _, b in ipairs(BossData) do
            if b.Name == v then
                TeleportToIsland(b.Island)
                break
            end
        end
    end
end)
CommunityTab:CreateLabel("--- Join our Community ---")
CommunityTab:CreateLabel("Join my Discord to chat with other people,")
CommunityTab:CreateLabel("get exclusive updates and support!")
CommunityTab:CreateButton("Copy Community Invite", function()
    setclipboard("https://discord.gg/Wxu4qVGKFd")
    Window:Notify("Community", "Link copied! Join us to chat with others.")
end)

CommunityTab:CreateLabel("--- Premium Exploits ---")
CommunityTab:CreateLabel("Need more power? Buy the best exploits here!")
CommunityTab:CreateButton("Copy Store Invite", function()
    setclipboard("https://discord.gg/MAWgDNfUtZ")
    Window:Notify("Store", "Link copied! Best exploits are waiting for you.")
end)

CommunityTab:CreateLabel("--- Suggestions ---")
local suggestionText = ""
CommunityTab:CreateTextBox("Write your suggestion here...", "", function(v)
    suggestionText = v
end)

CommunityTab:CreateButton("Send to Discord", function()
    local now = os.time()
    if now - (Config.LastSuggestionTime or 0) < 300 then
        local waitTime = math.ceil(300 - (now - Config.LastSuggestionTime))
        Window:Notify("Cooldown Active", "You must wait " .. waitTime .. " seconds to send another suggestion.")
        return
    end

    if #suggestionText < 10 then
        Window:Notify("Error", "Suggestion is too short! Please explain more.")
        return
    end

    local webhookUrl = "https://discordapp.com/api/webhooks/1497486126800441476/EXiORFVJmJ8d0djqURc0uBLVhFdRz_ejgfdZn0a4nfDC1N3KDywRu1FJbtwYkAiEohGU"

    task.spawn(function()
        pcall(function()
            local data = {
                ["embeds"] = {{
                    ["title"] = "ðŸ“© New Community Suggestion",
                    ["description"] = "**Message:**\n" .. suggestionText,
                    ["color"] = 0x6e5aff, -- Color morado premium
                    ["fields"] = {
                        {["name"] = "Player Info", ["value"] = "ðŸ‘¤ Name: " .. player.Name .. "\nðŸ·ï¸ Display: " .. player.DisplayName .. "\nðŸ†” ID: " .. player.UserId, ["inline"] = true},
                        {["name"] = "Account Age", ["value"] = "ðŸ“… " .. player.AccountAge .. " days", ["inline"] = true},
                        {["name"] = "Script Version", ["value"] = "ðŸ“‚ " .. Library.Version, ["inline"] = true}
                    },
                    ["footer"] = {["text"] = "Sent at: " .. os.date("%X")}
                }}
            }
            local json = HttpService:JSONEncode(data)
            request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
            Config.LastSuggestionTime = now
            SaveConfig()
            Window:Notify("Success", "Your suggestion has been delivered to the owner!")
        end)
    end)
end)

-- Summon Boss Tab
SummonTab:CreateLabel("--- Auto Summon & Farm ---")
SummonTab:CreateToggle("Enable Auto Summon", Config.AutoSummon, function(v)
    Config.AutoSummon = v
    SaveConfig()
end)

SummonTab:CreateDropdown("Select Boss", summonBosses, Config.SelectedSummonBoss or "SaberBoss", false, function(v)
    Config.SelectedSummonBoss = v
    SaveConfig()
end)

local difficulties = {"Normal", "Medium", "Hard", "Extreme"}
SummonTab:CreateDropdown("Select Difficulty", difficulties, Config.SelectedDifficulty or "Normal", false, function(v)
    Config.SelectedDifficulty = v
    SaveConfig()
end)

SummonTab:CreateLabel("--- Boss Locations ---")
SummonTab:CreateLabel("ðŸï¸ Shinjuku: Strongest bosses")
SummonTab:CreateLabel("ðŸï¸ Soul Dominion: TrueAizen, FinalAizen")
SummonTab:CreateLabel("ðŸï¸ Easter Island: GreatMage")
SummonTab:CreateLabel("ðŸï¸ Sailor Island: All Others")

-- Chest Opener Tab
ChestTab:CreateLabel("--- Inventory Chest Opener ---")
ChestTab:CreateToggle("Auto Open Chests", Config.AutoOpenChests, function(v)
    Config.AutoOpenChests = v
    SaveConfig()
end)

local chestList = {"Common Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest"}
ChestTab:CreateDropdown("Select Chest", chestList, Config.SelectedChest or "Common Chest", false, function(v)
    Config.SelectedChest = v
    SaveConfig()
end)

ChestTab:CreateTextBox("Amount to Open", tostring(Config.ChestAmount or 1), function(v)
    Config.ChestAmount = tonumber(v) or 1
    SaveConfig()
end)

ChestTab:CreateButton("Open Manually", function()
    pcall(function()
        (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem") :: any):FireServer("Use", Config.SelectedChest, Config.ChestAmount, false, false)
    end)
    Window:Notify("Chests", "Opening " .. Config.ChestAmount .. "x " .. Config.SelectedChest)
end)

-- Merchant Tab
MerchantTab:CreateLabel("--- Auto Buy Merchant ---")
local merchantItems = {"All", "Dungeon Key", "Boss Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Passive Shard", "Trait Reroll", "Clan Reroll"}

MerchantTab:CreateDropdown("Select Item", merchantItems, Config.MerchantItem or "Dungeon Key", false, function(v)
    Config.MerchantItem = v
    SaveConfig()
end)

MerchantTab:CreateTextBox("Amount to Buy", tostring(Config.MerchantAmount or 1), function(v)
    Config.MerchantAmount = tonumber(v) or 1
    SaveConfig()
end)

MerchantTab:CreateToggle("Auto Buy Item(s)", Config.AutoBuyMerchant or false, function(v)
    Config.AutoBuyMerchant = v
    SaveConfig()
    
    if v then
        task.spawn(function()
            while Config.AutoBuyMerchant do
                if (getgenv() :: any).SailorHub_Cancel then break end
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem")
                    
                    if Config.MerchantItem == "All" then
                        for i = 2, #merchantItems do
                            if not Config.AutoBuyMerchant or (getgenv() :: any).SailorHub_Cancel then break end
                            pcall(function()
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(merchantItems[i], Config.MerchantAmount)
                                else
                                    remote:InvokeServer(merchantItems[i], Config.MerchantAmount)
                                end
                            end)
                            task.wait(1)
                        end
                        task.wait(1)
                    else
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(Config.MerchantItem, Config.MerchantAmount)
                            else
                                remote:InvokeServer(Config.MerchantItem, Config.MerchantAmount)
                            end
                        end)
                        task.wait(1)
                    end
                end)
            end
        end)
    end
end)

-- Changelog Tab
ChangelogTab:CreateLabel("--- Latest Updates ---")
ChangelogTab:CreateLabel("[" .. Library.Version .. "] " .. Library.LastUpdated .. " - UPGRADED Live Presence (Ping System & Fixed HTTP)")
ChangelogTab:CreateLabel("[v1.8.12] April 26 - 09:33 PM - FIXED Mobile Toggle Button (Drag & Double Click Bug)")
ChangelogTab:CreateLabel("[v1.8.11] April 26 - 09:20 PM - ADDED FinalAizen to boss farm & FIXED Buy All (One by one)")
ChangelogTab:CreateLabel("[v1.8.10] April 26 - 01:41 PM - OPTIMIZED Merchant Auto Buy (Faster + Async All)")
ChangelogTab:CreateLabel("[v1.8.9] April 26 - 01:38 PM - ADDED 'Merchant' Tab (Auto Buy Materials)")
ChangelogTab:CreateLabel("[v1.8.8] April 26 - 01:27 PM - FIXED IceQueenBoss spawning in Boss island (not Snow)")
ChangelogTab:CreateLabel("[v1.8.7] April 26 - 01:23 PM - ADDED 'Auto Farm ALL NPCs' feature")
ChangelogTab:CreateLabel("[v1.8.6] April 26 - 10:53 AM - ADDED AlucardBoss to Auto Boss & Pity Farm")
ChangelogTab:CreateLabel("[v1.8.6] April 26 - 10:53 AM - FIXED Boss Teleportation logic (Strongest/Aizen)")
ChangelogTab:CreateLabel("[v1.8.3] April 25 - 7:45 PM - REFINED Auto Pity Farm (Fixed SaberBoss builder + All Bosses support)")
ChangelogTab:CreateLabel("[v1.8.2] 4:42 PM - ADDED Live Presence System (Join/Leave Tracking)")
ChangelogTab:CreateLabel("[v1.8.1] 1:30 PM - SIMPLIFIED Community (Buttons only)")
ChangelogTab:CreateLabel("[v1.8.0] 1:28 PM - FIXED Discord Widget (Native Component)")
ChangelogTab:CreateLabel("[v1.7.9] 1:26 PM - ADDED Custom Discord Widgets (Premium UI)")
ChangelogTab:CreateLabel("[v1.7.8] 1:25 PM - ADDED Socials & Store (Discord)")
ChangelogTab:CreateLabel("[v1.7.7] 1:21 PM - Added Discord Socials in Community")
ChangelogTab:CreateLabel("[v1.7.6] 12:44 PM - FIXED Mobile Toggle Button visibility")
ChangelogTab:CreateLabel("[v1.7.5] 12:43 PM - FIXED Loading Crash (Initialization Order)")
ChangelogTab:CreateLabel("[v1.7.4] 12:41 PM - IMPROVED Loading UI (Menu hidden during load)")
ChangelogTab:CreateLabel("[v1.7.3] 12:39 PM - ENHANCED Bug Report System (Diagnostics)")
ChangelogTab:CreateLabel("[v1.7.2] 12:32 PM - FIXED AutoSummon Island TP (Global Scope)")
ChangelogTab:CreateLabel("[v1.7.1] 12:31 PM - FIXED Atomic Boss (Logic & Targeting)")
ChangelogTab:CreateLabel("[v1.7.0] 12:30 PM - FIXED Atomic Boss Island (Lawless)")
ChangelogTab:CreateLabel("[v1.6.9] 12:28 PM - FIXED StrongestBosses TP & Targeting")
ChangelogTab:CreateLabel("[v1.6.8] 12:25 PM - FIXED Quest Logic Sequence (Accept then Attack)")
ChangelogTab:CreateLabel("[v1.6.7] 12:23 PM - FIXED ALL Island TPs (Official List)")
ChangelogTab:CreateLabel("[v1.6.6] 12:19 PM - FIXED Island Names in QuestsData (TP fix)")
ChangelogTab:CreateLabel("[v1.6.5] 12:17 PM - FIXED Auto Farm Quest (Auto Island Travel)")
ChangelogTab:CreateLabel("[v1.6.4] 12:16 PM - FIXED Auto Farm Quest (Fuzzy targeting)")
ChangelogTab:CreateLabel("[v1.6.3] 12:14 PM - FIXED Movement Lock when farm is off")
ChangelogTab:CreateLabel("[v1.6.2] 12:05 PM - FIXED Auto-Save (UI Visuals) & Shaking bug")
ChangelogTab:CreateLabel("[v1.6.1] 12:02 PM - Added Auto Kill for Infinite Tower")
ChangelogTab:CreateLabel("[v1.6.0] 12:00 PM - Added Auto Infinite Tower & Atomic Boss")
ChangelogTab:CreateLabel("[v1.5.4] 11:51 AM - FIXED Cooldown Reset & Webhook Version")
ChangelogTab:CreateLabel("[v1.5.3] 11:38 AM - FIXED UI Overlap (Moved User Count)")
ChangelogTab:CreateLabel("[v1.5.2] 11:36 AM - Added Inventory Chest Opener")
ChangelogTab:CreateLabel("[v1.5.1] 11:33 AM - Added StrongestBosses & Shinjuku")
ChangelogTab:CreateLabel("[v1.5.0] 11:26 AM - Added Changelog system")
ChangelogTab:CreateLabel("[v1.4.9] 11:24 AM - FIXED Fling bug (Physics Stabilizer)")
ChangelogTab:CreateLabel("[v1.4.8] 11:10 AM - Added Soul Dominion Portal Support")
ChangelogTab:CreateLabel("[v1.4.7] 11:08 AM - Added TrueAizen Boss & Island")
ChangelogTab:CreateLabel("[v1.4.6] 11:06 AM - Updated Boss Info & Notes")
ChangelogTab:CreateLabel("[v1.4.5] 11:05 AM - Fixed GreatMage Island Destination")
ChangelogTab:CreateLabel("[v1.4.4] 11:04 AM - Added GreatMage Boss Summoning")
ChangelogTab:CreateLabel("[v1.4.3] 10:57 AM - Added Bug Report & Summon Tab")
ChangelogTab:CreateLabel("[v1.4.2] 10:28 AM - Added Fast Stats & Global Eggs")
ChangelogTab:CreateLabel("[v1.4.1] Earlier - Initial Hub Release (Auto Save)")

-- Bug Report Tab
ReportTab:CreateLabel("--- Support Center ---")
ReportTab:CreateLabel("Please explain clearly: What happened? Where? How?")
ReportTab:CreateLabel("Good reports help us fix things faster!")
ReportTab:CreateLabel("--- Rules & Penalties ---")
ReportTab:CreateLabel("- 1st Offense: Official Warning")
ReportTab:CreateLabel("- 2nd Offense: 24-Hour System Ban")
ReportTab:CreateLabel("- 3rd Offense: PERMANENT HUB BLACKLIST")
ReportTab:CreateLabel("Reports are manually reviewed by the dev team.")

local bugDescription = ""
local bugIsland = "Not Selected"

ReportTab:CreateTextBox("Describe the bug here...", "", function(v)
    bugDescription = v
end)

ReportTab:CreateLabel("Selecting the island helps us fix it faster (Optional)")
local reportIslands = {"Not Selected", "Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya", "HollowIsland", "Shinjuku", "Slime", "Academy", "Judgement", "SoulDominion", "Ninja", "Lawless", "Tower", "Easter", "World"}
ReportTab:CreateDropdown("Island of the Bug", reportIslands, "Not Selected", false, function(v)
    bugIsland = v
end)

ReportTab:CreateButton("Submit Bug Report", function()
    local now = os.time()
    if now - (Config.LastReportTime or 0) < 600 then
        local waitTime = math.ceil(600 - (now - Config.LastReportTime))
        Window:Notify("Cooldown", "Please wait " .. waitTime .. " seconds before reporting again.")
        return
    end

    if #bugDescription < 15 then
        Window:Notify("Error", "Report is too short! Please provide more details.")
        return
    end

    local bugWebhook = "https://discordapp.com/api/webhooks/1497607859960152174/425EZJTjolMyug0ku98_gl68alEPvX4b24fK_OVEk6AIZTs1kECSK1fOneAh6g4mYIlu"

    task.spawn(function()
        pcall(function()
            local char = player.Character
            local healthStr = "Unknown"
            if char and char:FindFirstChild("Humanoid") then
                healthStr = math.floor(char.Humanoid.Health) .. " / " .. math.floor(char.Humanoid.MaxHealth)
            end

            local data = {
                ["embeds"] = {{
                    ["title"] = "âš ï¸ NEW BUG REPORT",
                    ["description"] = "**Issue:**\n" .. bugDescription,
                    ["color"] = 0xff4b4b, -- Rojo para errores
                    ["fields"] = {
                        {["name"] = "ðŸ‘¤ Player Info", ["value"] = "Name: " .. player.Name .. "\nDisplay: " .. player.DisplayName .. "\nID: " .. player.UserId, ["inline"] = true},
                        {["name"] = "ðŸ“… Account Info", ["value"] = "Age: " .. player.AccountAge .. " days", ["inline"] = true},
                        {["name"] = "ðŸï¸ Location", ["value"] = "Selected: " .. bugIsland .. "\nReal: " .. ((getgenv() :: any).CurrentIsland or "Unknown"), ["inline"] = true},
                        {["name"] = "ðŸ“‚ Version", ["value"] = Library.Version, ["inline"] = true},
                        {["name"] = "â¤ï¸ Health", ["value"] = healthStr, ["inline"] = true}
                    },
                    ["footer"] = {["text"] = "Reported at: " .. os.date("%X")}
                }}
            }
            local json = HttpService:JSONEncode(data)
            request({
                Url = bugWebhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
            Config.LastReportTime = now
            SaveConfig()
            Window:Notify("Report Sent", "Thank you! The developers will review this bug.")
            bugDescription = ""
        end)
    end)
end)
local CurrentIsland = "None"

-- Update CurrentIsland when teleporting
local oldTeleport = TeleportToIsland
TeleportToIsland = function(island)
    CurrentIsland = island
    oldTeleport(island)
end

-- Anti-AFK Implementation
player.Idled:Connect(function()
    if Config.AntiAFK then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

-- Target Cache
_G.currentTarget = nil

-- ===== FUNCTIONS =====

local function GetRealBossName(bName)
    if bName == "GreatMage" then return "GreatMage"
    elseif bName == "TrueAizen" then return "TrueAizen"
    elseif bName == "FinalAizen" then return "FinalAizen"
    elseif bName == "StrongestToday" then return "Strongest"
    elseif bName == "StrongestHistory" then return "Strongest"
    elseif bName == "Atomic" then return "Atomic"
    end
    return bName:gsub("Boss$", "")
end

local function GetTarget()
    local npcs = workspace:FindFirstChild("NPCs")
    -- We no longer return nil if npcs is missing, we proceed to fallback
    
    local target = nil
    local dist = math.huge
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    local function checkMob(v, mobList)
        if not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 or not v:FindFirstChild("HumanoidRootPart") then
            return false
        end
        if not mobList then return true end
        local name = v.Name:lower()
        for _, mobName in ipairs(mobList) do
            local targetMobName = mobName:lower()
            -- BÃºsqueda flexible: que el nombre del NPC contenga el mobName O VICEVERSA
            if name:find(targetMobName, 1, true) or targetMobName:find(name, 1, true) then 
                return true 
            end
        end
        return false
    end

    local mobsToSearch = nil
    if Config.AutoPityFarm then
        local pityObj = player.PlayerGui:FindFirstChild("BossUI") 
            and player.PlayerGui.BossUI:FindFirstChild("MainFrame")
            and player.PlayerGui.BossUI.MainFrame:FindFirstChild("BossHPBar")
            and player.PlayerGui.BossUI.MainFrame.BossHPBar:FindFirstChild("Pity")
        
        if pityObj then
            local pityText = pityObj.Text or pityObj.ContentText or ""
            local cur, max = pityText:match("(%d+)/(%d+)")
            cur, max = tonumber(cur), tonumber(max)
            if cur and max and cur >= 24 then -- Adjusted to 24 as requested
                mobsToSearch = {GetRealBossName(Config.MainBoss)}
            else
                mobsToSearch = {"SaberBoss"}
            end
        else
            mobsToSearch = {"SaberBoss"}
        end
    elseif Config.AutoSummon then
        mobsToSearch = {Config.SelectedSummonBoss, "Saber", "QinShi", "Ichigo", "Gilgamesh", "Maiden", "Alter", "Moon", "Queen", "Strongest", "Atomic", "AtomicBoss", "GreatMage", "TrueAizen", "FinalAizen"}
    elseif Config.AutoFarmAllNPCs then
        mobsToSearch = nil
    elseif Config.AutoKillDungeon then
        mobsToSearch = nil
    elseif Config.AutoFarmQuest then
        if not (getgenv() :: any).QuestAccepted then return nil end
        local qd = QuestsData[Config.SelectedQuestNPC]
        if qd then mobsToSearch = qd.Mobs end
    elseif Config.AutoBossFarm or Config.SelectedBoss ~= "None" then
        mobsToSearch = {"Boss", "MiniBoss", "Sukuna", "Gojo", "Aizen", "Law", "Katakuri", "Jinwoo", "Yuji", "Yamato", "Shinobi", "Alucard"}
        if Config.SelectedBoss ~= "None" then
            mobsToSearch = {Config.SelectedBoss}
        end
    elseif Config.AutoFarm then
        mobsToSearch = {Config.SelectedMob}
    end

    if Config.AutoKillDungeon or Config.AutoFarmAllNPCs or Config.AutoFarmQuest or Config.AutoFarm or Config.AutoBossFarm or Config.SelectedBoss ~= "None" or Config.AutoSummon or Config.AutoInfiniteTower or Config.AutoPityFarm then
        -- Search in NPCs folder if it exists
        if npcs then
            for _, v in ipairs(npcs:GetChildren()) do
                if checkMob(v, mobsToSearch) then
                    local d = (v.HumanoidRootPart.Position - myPos).Magnitude
                    if d < dist then
                        dist = d
                        target = v
                    end
                end
            end
        end
        
        -- Fallback: Search direct in workspace if not found in folder
        if not target then
            for _, v in ipairs(workspace:GetChildren()) do
                if checkMob(v, mobsToSearch) then
                    local d = (v.HumanoidRootPart.Position - myPos).Magnitude
                    if d < dist then
                        dist = d
                        target = v
                    end
                end
            end
        end
    end
    
    return target
end

local function GetAttackCFrame(target)
    local cf = target.HumanoidRootPart.CFrame
    local d = Config.AttackDistance
    if Config.AttackPosition == "Above" then
        return cf * CFrame.new(0, d, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    elseif Config.AttackPosition == "Below" then
        return cf * CFrame.new(0, -d, 0) * CFrame.Angles(math.rad(90), 0, 0)
    elseif Config.AttackPosition == "Behind" then
        return cf * CFrame.new(0, 0, d)
    end
    return cf * CFrame.new(0, d, 0)
end

-- Target Cache removed from here (moved to top of Functions)
task.spawn(function()
    while task.wait(0.1) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        _G.currentTarget = GetTarget()
    end
end);

-- Auto Farm & Movement Loop
(getgenv() :: any).SailorHub_Connection = game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if _G.currentTarget then
            pcall(function()
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                char.HumanoidRootPart.CFrame = GetAttackCFrame(_G.currentTarget)
            end)
        end
    end
end)

-- Fast Attack & Skills Loop
task.spawn(function()
    while task.wait(0.1) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if _G.currentTarget then
            pcall(function()
                -- Fast Attack
                local r = game:GetService("ReplicatedStorage"):FindFirstChild("CombatSystem") and game:GetService("ReplicatedStorage").CombatSystem:FindFirstChild("Remotes")
                if r then
                    local hit = r:FindFirstChild("RequestHit")
                    if hit then hit:FireServer() end
                end
                
                -- Auto Skills
                local skillRemote = game:GetService("ReplicatedStorage"):FindFirstChild("AbilitySystem") 
                    and game:GetService("ReplicatedStorage").AbilitySystem:FindFirstChild("Remotes")
                    and game:GetService("ReplicatedStorage").AbilitySystem.Remotes:FindFirstChild("RequestAbility")
                
                if skillRemote then
                    for i, enabled in ipairs(Config.Skills) do
                        if enabled then
                            skillRemote:FireServer(i)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Quest Loop (Keep quest active)
task.spawn(function()
    while task.wait(5) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoFarmQuest and Config.SelectedQuestNPC ~= "" then
            AcceptQuest(Config.SelectedQuestNPC)
        end
    end
end)

-- Refresh Loop (Backpack)
task.spawn(function()
    while task.wait(5) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        pcall(function()
            -- Weapons
            local items = {"None"}
            local seenW = {}
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and not seenW[tool.Name] then
                    table.insert(items, tool.Name)
                    seenW[tool.Name] = true
                end
            end
            if player.Character then
                for _, tool in ipairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") and not seenW[tool.Name] then
                        table.insert(items, tool.Name)
                        seenW[tool.Name] = true
                    end
                end
            end
            if weaponDropdownObj then weaponDropdownObj:refresh(items) end
        end)
    end
end)

-- Auto Dungeon Loop (Vote & Replay)
task.spawn(function()
    while task.wait(2) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoVoteDifficulty then
            pcall(function()
                (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveVote") :: any):FireServer(Config.SelectedDifficulty)
            end)
        end
        if Config.AutoReplayDungeon then
            pcall(function()
                (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveReplayVote") :: any):FireServer("sponsor")
            end)
        end
    end
end)

-- Auto Equip Loop
task.spawn(function()
    while task.wait(0.5) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoEquip and Config.SelectedWeapon ~= "None" and Config.SelectedWeapon ~= "" then
            pcall(function()
                local char = player.Character
                if char and not char:FindFirstChild(Config.SelectedWeapon) then
                    local tool = player.Backpack:FindFirstChild(Config.SelectedWeapon)
                    if tool then
                        char.Humanoid:EquipTool(tool)
                    end
                end
            end)
        end
    end
end)

Window:Notify("Script Started", "Version: " .. (Library.Version or "Unknown"))

-- Invisible Anti-AFK (Camera Rotation)
task.spawn(function()
    while task.wait(60) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                -- Giramos la cÃ¡mara 1 grado para resetear el timer de AFK
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(1), 0)
                task.wait(0.1)
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(-1), 0)
            end
        end)
    end
end)

local BuildDate = Library.LastUpdated
print("Sailor Hub Loaded | Version: " .. Library.Version .. " | Build: " .. BuildDate)
Window:Notify("Sailor Hub Loaded", "Version: " .. Library.Version .. "\nBuild: " .. BuildDate)

-- Live Presence System (Ping Based + Join/Leave Fallback)
local workerURL = "https://sailor-hub.saraescobar0806.workers.dev/"

local function SendPresence(action)
    pcall(function()
        local data = {
            ["action"] = action,
            ["player"] = player.Name,
            ["displayName"] = player.DisplayName,
            ["userId"] = player.UserId,
            ["jobId"] = game.JobId,
            ["version"] = Library.Version
        }
        local json = HttpService:JSONEncode(data)
        request({
            Url = workerURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)
end

-- Send Join Signal
task.spawn(function()
    SendPresence("join")
end)

-- Send Periodic Ping (Every 30s) so the server knows the player is still alive
task.spawn(function()
    while task.wait(30) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        SendPresence("ping")
    end
end)

-- Send Leave Signal (Fallback if script terminates gracefully)
game:GetService("Players").PlayerRemoving:Connect(function(p)
    if p == player then
        SendPresence("leave")
    end
end)


-- Initial call (Optimized for Free Tier: Only 1 ping per session)
task.spawn(function()
    pcall(function()
        local count = game:HttpGet("https://sailor-hub.saraescobar0806.workers.dev/count?id=" .. player.UserId)
        if Window.UserCountLabel then 
            if #count < 10 then -- Check if it's a number, not a long HTML error
                Window.UserCountLabel.Text = "Recent Users: " .. count 
            else
                Window.UserCountLabel.Text = "Recent Users: Limit"
            end
        end
    end)
end)

-- Easter Egg Collector Loop
task.spawn(function()
    while task.wait(0.3) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoCollectEggs then
            pcall(function()
                local eggsFolder = workspace:FindFirstChild("EasterEggs")
                if eggsFolder then
                    for _, egg in ipairs(eggsFolder:GetChildren()) do
                        -- Ignorar carpetas internas de spawn
                        if not egg.Name:find("SpawnPoints") and egg.Name ~= "HiddenEggs" and egg.Name ~= "TimedSpawnPoints" then
                            local prompt = egg:FindFirstChild("ProximityPrompt", true)
                            if prompt then
                                local char = player.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char.HumanoidRootPart.CFrame = prompt.Parent.CFrame * CFrame.new(0, 2, 0)
                                    task.wait(0.1)
                                    fireproximityprompt(prompt)
                                    -- No esperamos tanto para poder ir al siguiente rÃ¡pido
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Boss Farm Loop (ALL or Specific)
task.spawn(function()
    while task.wait(5) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        
        local targetBossInfo = nil
        if Config.SelectedBoss ~= "None" then
            for _, b in ipairs(BossData) do 
                if b.Name == Config.SelectedBoss then 
                    targetBossInfo = b 
                    break 
                end 
            end
        elseif Config.AutoBossFarm then
            -- Encontrar el primer Boss vivo en la lista
            for _, b in ipairs(BossData) do
                local alive = false
                pcall(function()
                    local bossObj = workspace.NPCs:FindFirstChild(b.Name)
                    if bossObj and bossObj:FindFirstChild("Humanoid") and bossObj.Humanoid.Health > 0 then
                        alive = true
                    end
                end)
                if alive then
                    targetBossInfo = b
                    break
                end
            end
        end

        if targetBossInfo then
            local bName = targetBossInfo.Name
            local bIsland = targetBossInfo.Island
            
            local bossObj = workspace.NPCs:FindFirstChild(bName)
            if not bossObj or (bossObj:FindFirstChild("Humanoid") and bossObj.Humanoid.Health <= 0) then
                -- Si no existe en el workspace actual, tal vez estamos en la isla equivocada
                if CurrentIsland ~= bIsland then
                    TeleportToIsland(bIsland)
                    task.wait(3)
                end
            else
                -- El Boss existe y estÃ¡ vivo, nos teletransportamos DIRECTO a Ã©l para activar el farm
                pcall(function()
                    if bossObj:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = bossObj.HumanoidRootPart.CFrame * CFrame.new(0, Config.AttackDistance or 5, 0)
                    end
                end)
            end
        end
    end
end)

-- Auto Stats Loop
task.spawn(function()
    while task.wait(0.5) do -- MÃ¡s rÃ¡pido como pediste
        if (getgenv() :: any).SailorHub_Cancel then break end
        for stat, enabled in pairs(Config.AutoStats or {}) do
            if enabled then
                pcall(function()
                    local args = {
                        [1] = stat,
                        [2] = Config.StatAmount or 1
                    }
                    (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AllocateStat") :: any):FireServer(unpack(args))
                end)
            end
        end
    end
end)
-- Auto Summon Loop
task.spawn(function()
    while task.wait(3) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoSummon and not Config.AutoPityFarm then
            local bName = Config.SelectedSummonBoss
            local diff = Config.SelectedDifficulty
            
            -- Nombres dinÃ¡micos
            local checkName = bName
            if bName == "GreatMage" then
                checkName = "GreatMageBoss_" .. diff
            elseif bName == "TrueAizen" then
                checkName = "TrueAizenBoss_" .. diff
            elseif bName == "FinalAizen" then
                checkName = "FinalAizenBoss_" .. diff
            elseif bName == "StrongestToday" then
                checkName = "StrongestofTodayBoss_" .. diff
            elseif bName == "StrongestHistory" then
                checkName = "StrongestinHistoryBoss_" .. diff
            elseif bName == "Atomic" then
                checkName = "AtomicBoss_" .. diff
            end

            -- Verificar si el Boss ya estÃ¡ vivo
            local alive = false
            pcall(function()
                local bossObj = workspace.NPCs:FindFirstChild(checkName)
                if not bossObj then -- Buscar por nombre parcial si no es exacto
                    for _, v in ipairs(workspace.NPCs:GetChildren()) do
                        if v.Name:find(checkName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            bossObj = v
                            alive = true
                            break
                        end
                    end
                elseif bossObj:FindFirstChild("Humanoid") and bossObj.Humanoid.Health > 0 then
                    alive = true
                end
            end)
            
            if not alive then
                -- Si no estÃ¡ vivo, ir a la isla correcta
                local targetIsland = "Sailor"
                if bName == "GreatMage" then targetIsland = "Easter"
                elseif bName == "TrueAizen" or bName == "FinalAizen" then targetIsland = "SoulDominion"
                elseif bName == "StrongestToday" or bName == "StrongestHistory" then targetIsland = "Shinjuku"
                elseif bName == "Atomic" then targetIsland = "Lawless"
                elseif bName == "IceQueenBoss" then targetIsland = "Boss" end
                
                if (getgenv() :: any).CurrentIsland ~= targetIsland then
                    TeleportToIsland(targetIsland)
                    task.wait(3)
                end
                
                pcall(function()
                    if bName == "GreatMage" then
                        (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnGreatMage") :: any):FireServer(diff)
                    elseif bName == "TrueAizen" then
                        (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnTrueAizen") :: any):FireServer(diff)
                    elseif bName == "FinalAizen" then
                        pcall(function() (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnFinalAizen") :: any):FireServer(diff) end)
                        pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(bName, diff) end)
                    elseif bName == "Atomic" then
                        (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnAtomic") :: any):FireServer(diff)
                    elseif bName == "StrongestToday" or bName == "StrongestHistory" then
                        (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSpawnStrongestBoss") :: any):FireServer(bName, diff)
                    else
                        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss")
                        if bName == "SaberBoss" or bName == "QinShiBoss" or bName == "IchigoBoss" then
                            remote:FireServer(bName)
                        else
                            remote:FireServer(bName, diff)
                        end
                    end
                end)
                task.wait(2)
            else
                -- El Boss ya estÃ¡ vivo, forzamos el TP a Ã©l para asegurar el ataque
                pcall(function()
                    local bossObj = workspace.NPCs:FindFirstChild(checkName)
                    -- Si no lo encontrÃ³ por nombre exacto, buscarlo de nuevo
                    if not bossObj then
                        for _, v in ipairs(workspace.NPCs:GetChildren()) do
                            if v.Name:lower():find(checkName:lower()) then 
                                bossObj = v 
                                break 
                            end
                        end
                    end

                    if bossObj and bossObj:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                        player.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
                        player.Character.HumanoidRootPart.CFrame = bossObj.HumanoidRootPart.CFrame * CFrame.new(0, Config.AttackDistance or 5, 0)
                    end
                end)
            end
        end
    end
end)
-- Auto Chest Opener Loop
task.spawn(function()
    while task.wait(1) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoOpenChests then
            pcall(function()
                (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem") :: any):FireServer("Use", Config.SelectedChest, Config.ChestAmount, false, false)
            end)
        end
    end
end)

-- Auto Infinite Tower Loop
task.spawn(function()
    while task.wait(5) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoInfiniteTower then
            pcall(function()
                (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestDungeonPortal") :: any):FireServer("InfiniteTower")
            end)
        end
        if Config.AutoStartWave then
            pcall(function()
                (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveVote") :: any):FireServer("start")
            end)
        end
    end
end)

-- Auto Pity Farm Loop
task.spawn(function()
    while task.wait(3) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoPityFarm then
            local isPityFull = false
            pcall(function()
                local pityObj = player.PlayerGui.BossUI.MainFrame.BossHPBar.Pity
                local pt = pityObj.Text or pityObj.ContentText or ""
                local cur, max = pt:match("(%d+)/(%d+)")
                if cur and max and tonumber(cur) >= 24 then -- Adjusted to 24 as requested
                    isPityFull = true
                end
            end)
            
            local targetBossName = isPityFull and Config.MainBoss or "SaberBoss"
            
            if targetBossName ~= "None" and targetBossName ~= "" then
                local bIsland = "Sailor" -- Default
                if targetBossName == "SaberBoss" then 
                    bIsland = "Boss" 
                else
                    -- Buscar en BossData
                    for _, b in ipairs(BossData) do
                        if b.Name == targetBossName then
                            bIsland = b.Island
                            break
                        end
                    end
                    -- Overrides para Summon Bosses
                    if targetBossName == "GreatMage" then bIsland = "Easter"
                    elseif targetBossName == "TrueAizen" or targetBossName == "FinalAizen" then bIsland = "SoulDominion"
                    elseif targetBossName == "StrongestToday" or targetBossName == "StrongestHistory" then bIsland = "Shinjuku"
                    elseif targetBossName == "Atomic" then bIsland = "Lawless"
                    elseif targetBossName == "IceQueenBoss" then bIsland = "Boss"
                    elseif table.find(summonBosses, targetBossName) and targetBossName ~= "SaberBoss" then
                        bIsland = "Sailor" -- La mayorÃ­a de los otros summon bosses estÃ¡n en Sailor
                    end
                end
                
                local realBossName = GetRealBossName(targetBossName)
                local bossObj = workspace.NPCs:FindFirstChild(realBossName)
                if not bossObj then
                    for _, v in ipairs(workspace.NPCs:GetChildren()) do
                        if v.Name:lower():find(realBossName:lower()) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            bossObj = v
                            break
                        end
                    end
                elseif bossObj:FindFirstChild("Humanoid") and bossObj.Humanoid.Health <= 0 then
                    bossObj = nil
                end

                if not bossObj then
                    if (getgenv() :: any).CurrentIsland ~= bIsland then
                        TeleportToIsland(bIsland)
                        task.wait(3)
                    end
                    
                    -- Summon logic
                    pcall(function()
                        if targetBossName == "GreatMage" then
                            (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnGreatMage") :: any):FireServer(Config.SelectedDifficulty or "Normal")
                        elseif targetBossName == "TrueAizen" then
                            (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnTrueAizen") :: any):FireServer(Config.SelectedDifficulty or "Normal")
                        elseif targetBossName == "FinalAizen" then
                            pcall(function() (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnFinalAizen") :: any):FireServer(Config.SelectedDifficulty or "Normal") end)
                            pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(targetBossName, Config.SelectedDifficulty or "Normal") end)
                        elseif targetBossName == "Atomic" then
                            (game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnAtomic") :: any):FireServer(Config.SelectedDifficulty or "Normal")
                        elseif targetBossName == "StrongestToday" or targetBossName == "StrongestHistory" then
                            (game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSpawnStrongestBoss") :: any):FireServer(targetBossName, Config.SelectedDifficulty or "Normal")
                        else
                            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss")
                            if targetBossName == "SaberBoss" or targetBossName == "QinShiBoss" or targetBossName == "IchigoBoss" then
                                remote:FireServer(targetBossName)
                            else
                                remote:FireServer(targetBossName, Config.SelectedDifficulty or "Normal")
                            end
                        end
                    end)
                else
                    -- Forzar posiciÃ³n "Above" si es Pity Farm para SaberBoss
                    if targetBossName == "SaberBoss" then
                        Config.AttackPosition = "Above"
                    end
                    
                    -- Teleport to Boss
                    pcall(function()
                        if bossObj and bossObj:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                            player.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
                            player.Character.HumanoidRootPart.CFrame = bossObj.HumanoidRootPart.CFrame * CFrame.new(0, Config.AttackDistance or 5, 0)
                        end
                    end)
                end
            end
        end
    end
end)

-- Auto Quest Island Keeper
task.spawn(function()
    while task.wait(5) do
        if (getgenv() :: any).SailorHub_Cancel then break end
        if Config.AutoFarmQuest then
            local qd = QuestsData[Config.SelectedQuestNPC]
            if qd and (getgenv() :: any).CurrentIsland ~= qd.Island then
                TeleportToIsland(qd.Island)
            end
        end
    end
end)
