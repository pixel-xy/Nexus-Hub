local REQUIRED_KEY = 'she gon call me good boy'
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local CoreGui = game:GetService('CoreGui')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')
local VirtualUser = game:GetService('VirtualUser')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer
local MY_PLOT_OBJ = nil
local MY_PLOT_NAME = 'Scanning...'
local autoCollect = false
local autoUpgrade = false
local autoFarm = false
local infJump = false
local speedEnabled = false
local walkSpeedVal = 16

local function get_gui_parent()
    local success, parent = pcall(function()
        return gethui()
    end)

    return success and parent or CoreGui
end
local function DetectClosestPlot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild('HumanoidRootPart', 10)

    if not hrp then
        return
    end

    local closestDist = math.huge
    local targetPlot = nil
    local map = workspace:FindFirstChild('Map')
    local bases = map and map:FindFirstChild('Bases')

    if bases then
        for _, plot in pairs(bases:GetChildren())do
            local sign = plot:FindFirstChild('PlotSign')
            local ownerPart = sign and sign:FindFirstChild('PlotOwner')

            if ownerPart then
                local dist = (hrp.Position - ownerPart.Position).Magnitude

                if dist < closestDist then
                    closestDist = dist
                    targetPlot = plot
                end
            end
        end
    end
    if targetPlot then
        MY_PLOT_OBJ = targetPlot
        MY_PLOT_NAME = targetPlot.Name
    else
        MY_PLOT_NAME = 'Not Found'
    end
end

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid')

        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
RunService.Stepped:Connect(function()
    if speedEnabled then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid')

        if h then
            h.WalkSpeed = walkSpeedVal
        end
    end
end)

local function PlayGGAnimation(onComplete)
    local ScreenGui = Instance.new('ScreenGui', get_gui_parent())

    ScreenGui.IgnoreGuiInset = true

    local Frame = Instance.new('Frame', ScreenGui)

    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
    Frame.BackgroundTransparency = 1

    local Text = Instance.new('TextLabel', Frame)

    Text.Size = UDim2.new(0, 0, 0, 0)
    Text.Position = UDim2.new(0.5, 0, 0.5, 0)
    Text.AnchorPoint = Vector2.new(0.5, 0.5)
    Text.Text = 'GG'
    Text.Font = Enum.Font.FredokaOne
    Text.TextColor3 = Color3.fromRGB(100, 255, 100)
    Text.BackgroundTransparency = 1

    TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.2}):Play()

    local pop = TweenService:Create(Text, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {
        Size = UDim2.new(0.5, 0, 0.3, 0),
        TextSize = 100,
    })

    pop:Play()
    pop.Completed:Wait()
    task.wait(1)
    TweenService:Create(Text, TweenInfo.new(0.5), {
        TextTransparency = 1,
        Size = UDim2.new(1, 0, 0.6, 0),
    }):Play()
    TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    ScreenGui:Destroy()

    if onComplete then
        onComplete()
    end
end
local function LoadMainScript()
    local char = LocalPlayer.Character

    if char and char:FindFirstChild('Humanoid') then
        char.Humanoid.Health = 0
    end

    LocalPlayer.CharacterAdded:Wait()
    task.wait(1)
    DetectClosestPlot()

    local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
    local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    local Window = Library:CreateWindow({
        Title = 'sUNC Script V3',
        Center = true,
        AutoShow = true,
    })
    local TabMain = Window:AddTab('Main')
    local TabFarm = Window:AddTab('Auto Farm')
    local TabTP = Window:AddTab('Teleports')
    local TabPlayer = Window:AddTab('Player')
    local GroupInfo = TabMain:AddLeftGroupbox('Status')

    GroupInfo:AddLabel('Owner of: ' .. MY_PLOT_NAME)
    GroupInfo:AddButton('Refresh Plot Detection', function()
        DetectClosestPlot()
        Library:Notify('Updated: ' .. MY_PLOT_NAME)
    end)

    local GroupAuto = TabMain:AddLeftGroupbox('Tycoon Manager')

    GroupAuto:AddToggle('AC', {
        Text = 'Auto Collect Money',
        Default = false,
    }):OnChanged(function(v)
        autoCollect = v

        task.spawn(function()
            while autoCollect do
                for i = 1, 35 do
                    if not autoCollect then
                        break
                    end
                    if ReplicatedStorage.Events:FindFirstChild('Collect') then
                        ReplicatedStorage.Events.Collect:FireServer('Platform' .. i)
                    end
                end

                task.wait(1)
            end
        end)
    end)
    GroupAuto:AddToggle('AU', {
        Text = 'Auto Upgrade All',
        Default = false,
    }):OnChanged(function(v)
        autoUpgrade = v

        task.spawn(function()
            while autoUpgrade do
                for i = 1, 50 do
                    if not autoUpgrade then
                        break
                    end
                    if ReplicatedStorage.Events:FindFirstChild('Upgrade') then
                        ReplicatedStorage.Events.Upgrade:FireServer('Platform' .. i)
                    end
                end

                task.wait(0.5)
            end
        end)
    end)

    local GroupFarm = TabFarm:AddLeftGroupbox('Brainrots Farm')

    GroupFarm:AddToggle('AF', {
        Text = 'Auto Farm Items',
        Default = false,
    }):OnChanged(function(v)
        autoFarm = v

        task.spawn(function()
            while autoFarm do
                pcall(function()
                    local folder = workspace.Map.Brainrots
                    local claim = workspace.Map.ClaimPart
                    local hrp = LocalPlayer.Character.HumanoidRootPart

                    for _, item in pairs(folder:GetChildren())do
                        if not autoFarm then
                            break
                        end

                        local box = item:FindFirstChild('Box') or item:FindFirstChildWhichIsA('BasePart', true)
                        local prompt = item:FindFirstChildOfClass('ProximityPrompt', true)

                        if box and prompt then
                            hrp.CFrame = box.CFrame

                            task.wait(0.25)
                            fireproximityprompt(prompt)
                            task.wait(0.1)

                            hrp.CFrame = claim:GetPivot() + Vector3.new(0, 3, 0)

                            task.wait(0.25)
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end)

    local GroupTP = TabTP:AddLeftGroupbox('Waypoints')

    GroupTP:AddButton('Goto End (Win Room)', function()
        local endPart = workspace:FindFirstChild('Map') and workspace.Map:FindFirstChild('End') and workspace.Map.End:FindFirstChild('EndPart')

        if endPart then
            LocalPlayer.Character.HumanoidRootPart.CFrame = endPart.CFrame + Vector3.new(0, 5, 0)

            Library:Notify('Teleported to End!', 3)
        else
            Library:Notify('End Part Not Found', 3)
        end
    end)
    GroupTP:AddButton('Goto My Plot (' .. MY_PLOT_NAME .. ')', function()
        if MY_PLOT_OBJ then
            local target = MY_PLOT_OBJ:FindFirstChild('PlotSign') and MY_PLOT_OBJ.PlotSign:FindFirstChild('PlotOwner')

            if target then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 5, 0)
            else
                LocalPlayer.Character.HumanoidRootPart.CFrame = MY_PLOT_OBJ:GetPivot() + Vector3.new(0, 5, 0)
            end
        else
            Library:Notify('Plat Not Found yet!', 3)
        end
    end)

    local GroupPlr = TabPlayer:AddLeftGroupbox('Character')

    GroupPlr:AddSlider('WS', {
        Text = 'WalkSpeed',
        Default = 16,
        Min = 16,
        Max = 400,
        Rounding = 0,
    }):OnChanged(function(v)
        walkSpeedVal = v
        speedEnabled = true
    end)
    GroupPlr:AddToggle('IJ', {
        Text = 'Infinite Jump',
        Default = false,
    }):OnChanged(function(v)
        infJump = v
    end)
    Library:Notify('Script Loaded & Plot Detected!', 5)
end
local function CreateKeySystem()
    local ScreenGui = Instance.new('ScreenGui', get_gui_parent())
    local Main = Instance.new('Frame', ScreenGui)

    Main.Size = UDim2.new(0, 320, 0, 250)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new('UICorner', Main).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new('UIStroke', Main)

    Stroke.Color = Color3.fromRGB(138, 43, 226)
    Stroke.Thickness = 2

    local Title = Instance.new('TextLabel', Main)

    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = 'SECURE ACCESS'
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local Note = Instance.new('TextLabel', Main)

    Note.Size = UDim2.new(0.9, 0, 0, 50)
    Note.Position = UDim2.new(0.05, 0, 0.15, 0)
    Note.Text = "Instructions: Click 'Copy Key', paste it into the box below, and press 'Login' to start."
    Note.TextColor3 = Color3.fromRGB(180, 180, 180)
    Note.TextWrapped = true
    Note.Font = Enum.Font.Gotham
    Note.TextSize = 12
    Note.BackgroundTransparency = 1

    local Input = Instance.new('TextBox', Main)

    Input.Size = UDim2.new(0.8, 0, 0, 40)
    Input.Position = UDim2.new(0.1, 0, 0.45, 0)
    Input.PlaceholderText = 'Paste Key Here...'
    Input.Text = ''
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Input.TextColor3 = Color3.new(1, 1, 1)

    Instance.new('UICorner', Input)

    local CopyBtn = Instance.new('TextButton', Main)

    CopyBtn.Size = UDim2.new(0.35, 0, 0, 35)
    CopyBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
    CopyBtn.Text = 'Copy Key'
    CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    CopyBtn.TextColor3 = Color3.new(1, 1, 1)

    Instance.new('UICorner', CopyBtn)

    local LoginBtn = Instance.new('TextButton', Main)

    LoginBtn.Size = UDim2.new(0.35, 0, 0, 35)
    LoginBtn.Position = UDim2.new(0.55, 0, 0.75, 0)
    LoginBtn.Text = 'Login'
    LoginBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    LoginBtn.TextColor3 = Color3.new(1, 1, 1)

    Instance.new('UICorner', LoginBtn)
    CopyBtn.MouseButton1Click:Connect(function()
        setclipboard(REQUIRED_KEY)

        CopyBtn.Text = 'Copied!'

        task.wait(1)

        CopyBtn.Text = 'Copy Key'
    end)
    LoginBtn.MouseButton1Click:Connect(function()
        if Input.Text == REQUIRED_KEY then
            ScreenGui:Destroy()
            PlayGGAnimation(LoadMainScript)
        else
            Input.Text = ''
            Input.PlaceholderText = 'Wrong Key!'
        end
    end)
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

CreateKeySystem()
