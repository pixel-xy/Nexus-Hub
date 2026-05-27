local function playGGAnimation()
    local screenGui = Instance.new('ScreenGui', game.CoreGui)
    local ggLabel = Instance.new('TextLabel', screenGui)

    ggLabel.Size = UDim2.new(0, 500, 0, 300)
    ggLabel.Position = UDim2.new(0.5, -250, 0.5, -150)
    ggLabel.BackgroundTransparency = 1
    ggLabel.Text = 'GG'
    ggLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    ggLabel.Font = Enum.Font.PermanentMarker
    ggLabel.TextSize = 10
    ggLabel.Rotation = -10

    local ts = game:GetService('TweenService')

    ts:Create(ggLabel, TweenInfo.new(0.6, Enum.EasingStyle.Back), {TextSize = 180}):Play()
    task.wait(1.5)
    ts:Create(ggLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    screenGui:Destroy()
end

playGGAnimation()

local player = game.Players.LocalPlayer

if player.Character then
    player.Character:BreakJoints()
end

local char = player.CharacterAdded:Wait()
local hrp = char:WaitForChild('HumanoidRootPart', 10)

task.wait(1)

local myBase = nil
local myBaseName = nil
local shortestDist = math.huge

if hrp and workspace:FindFirstChild('Bases') then
    for _, base in pairs(workspace.Bases:GetChildren())do
        local homePart = base:FindFirstChild('Home')

        if homePart then
            local dist = (homePart.Position - hrp.Position).Magnitude

            if dist < shortestDist then
                shortestDist = dist
                myBase = base
                myBaseName = base.Name
            end
        end
    end
end

local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Window = Library:CreateWindow({
    Title = 'SONORA (BETA)',
    Center = true,
    AutoShow = true,
    TabWidth = 120,
    Footer = 'Base: ' .. (myBaseName or 'Wait...'),
})
local Tabs = {
    Home = Window:AddTab('Home'),
    Farm = Window:AddTab('Farm'),
    Tycoon = Window:AddTab('Tycoon'),
    Stats = Window:AddTab('Stats'),
}
local HomeGroup = Tabs.Home:AddLeftGroupbox('Map Management')
local FarmGroup = Tabs.Farm:AddLeftGroupbox('Brainrot Farming')
local TycoonGroup = Tabs.Tycoon:AddLeftGroupbox('Base Automation')
local ArcadeGroup = Tabs.Tycoon:AddRightGroupbox('Arcade / Tickets')
local StatsGroup = Tabs.Stats:AddLeftGroupbox('Speed Upgrades')
local MoveGroup = Tabs.Stats:AddRightGroupbox('Movement Controls')
local autoFarm = false
local detectTsunami = false
local autoCollectCash = false
local autoUpgrade = false
local autoTickets = false
local ticketSpeed = 1
local autoBuySpeed1 = false
local autoBuySpeed5 = false
local autoBuySpeed10 = false
local selectedRarity = 'Common'
local vipWallsRef = nil
local rarities = {
    'Celestial',
    'Common',
    'Cosmic',
    'Divine',
    'Epic',
    'Infinity',
    'Legendary',
    'Mythical',
    'Rare',
    'Secret',
    'Uncommon',
}
local PlotAction = game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('Net'):WaitForChild('RF/Plot.PlotAction')
local UpgradeSpeedRemote = game:GetService('ReplicatedStorage'):WaitForChild('RemoteFunctions'):WaitForChild('UpgradeSpeed')

task.spawn(function()
    while true do
        if autoTickets then
            local arcadeFolder = workspace:FindFirstChild('ArcadeEventConsoles')

            if arcadeFolder then
                for _, console in pairs(arcadeFolder:GetChildren())do
                    local part = console:FindFirstChildWhichIsA('BasePart') or console:FindFirstChild('Hitbox') or console:FindFirstChild('Part')

                    if part and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
                        firetouchinterest(player.Character.HumanoidRootPart, part, 0)
                        firetouchinterest(player.Character.HumanoidRootPart, part, 1)
                    end
                end
            end
        end

        task.wait(ticketSpeed)
    end
end)
task.spawn(function()
    while true do
        if autoCollectCash and myBase then
            local slotsFolder = myBase:FindFirstChild('Slots')

            if slotsFolder then
                for _, slot in pairs(slotsFolder:GetChildren())do
                    local collectPart = slot:FindFirstChild('Collect')
                    local pChar = player.Character

                    if collectPart and pChar and pChar:FindFirstChild('HumanoidRootPart') then
                        firetouchinterest(pChar.HumanoidRootPart, collectPart, 0)
                        firetouchinterest(pChar.HumanoidRootPart, collectPart, 1)
                    end
                end
            end
        end

        task.wait(0.8)
    end
end)
task.spawn(function()
    while true do
        if autoUpgrade and myBaseName then
            for i = 1, 40 do
                if not autoUpgrade then
                    break
                end

                local args = {
                    'Upgrade Brainrot',
                    myBaseName,
                    tostring(i),
                }

                pcall(function()
                    PlotAction:InvokeServer(unpack(args))
                end)
                task.wait(0.05)
            end
        end

        task.wait(0.8)
    end
end)
task.spawn(function()
    while true do
        if autoBuySpeed1 then
            pcall(function()
                UpgradeSpeedRemote:InvokeServer(1)
            end)
        end
        if autoBuySpeed5 then
            pcall(function()
                UpgradeSpeedRemote:InvokeServer(5)
            end)
        end
        if autoBuySpeed10 then
            pcall(function()
                UpgradeSpeedRemote:InvokeServer(10)
            end)
        end

        task.wait(0.5)
    end
end)

local function farmCycle()
    if not autoFarm or not myBase then
        return
    end

    local folder = workspace:FindFirstChild('ActiveBrainrots')

    if not folder then
        return
    end

    local rarityFolder = folder:FindFirstChild(selectedRarity)

    if rarityFolder then
        local items = rarityFolder:GetChildren()

        for _, item in ipairs(items)do
            local prompt = item:FindFirstChildWhichIsA('ProximityPrompt', true)
            local rootPart = item:FindFirstChild('Root') or item:FindFirstChild('Handle') or item:FindFirstChildWhichIsA('BasePart')

            if prompt and rootPart then
                local isSafe = true

                if detectTsunami then
                    local tsunamiFolder = workspace:FindFirstChild('ActiveTsunamis')

                    if tsunamiFolder then
                        for _, tsunami in pairs(tsunamiFolder:GetChildren())do
                            local tHitbox = tsunami:FindFirstChild('Hitbox') or tsunami:FindFirstChildWhichIsA('BasePart')

                            if tHitbox and (tHitbox.Position - rootPart.Position).Magnitude < 200 then
                                isSafe = false

                                break
                            end
                        end
                    end
                end
                if isSafe then
                    local myChar = player.Character

                    if not myChar or not myChar:FindFirstChild('HumanoidRootPart') then
                        return
                    end

                    myChar.HumanoidRootPart.CFrame = rootPart.CFrame

                    task.wait(0.35)
                    fireproximityprompt(prompt)
                    task.wait(0.1)

                    if myBase:FindFirstChild('Home') then
                        myChar.HumanoidRootPart.CFrame = myBase.Home.CFrame
                    end

                    return
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if autoFarm then
            farmCycle()
        end

        task.wait(0.5)
    end
end)
HomeGroup:AddToggle('VIPWallsToggle', {
    Text = 'Unlock VIPWalls',
    Default = false,
    Callback = function(Value)
        local mapShared = workspace:FindFirstChild('DefaultMap_SharedInstances')

        if mapShared then
            local walls = mapShared:FindFirstChild('VIPWalls')

            if Value then
                if walls then
                    vipWallsRef = walls
                    vipWallsRef.Parent = game.ReplicatedStorage
                end
            else
                if vipWallsRef then
                    vipWallsRef.Parent = mapShared
                    vipWallsRef = nil
                end
            end
        else
            Library:Notify('Error: DefaultMap_SharedInstances not found')
        end
    end,
})
HomeGroup:AddButton('Re-Scan Base', function()
    if player.Character then
        local p = player.Character.HumanoidRootPart
        local closest, minD = nil, math.huge

        for _, b in pairs(workspace.Bases:GetChildren())do
            if b:FindFirstChild('Home') then
                local d = (b.Home.Position - p.Position).Magnitude

                if d < minD then
                    minD = d
                    closest = b
                end
            end
        end

        if closest then
            myBase = closest
            myBaseName = closest.Name

            Library:Notify('Base Updated!')
        end
    end
end)
FarmGroup:AddDropdown('Rarity', {
    Values = rarities,
    Default = 2,
    Text = 'Rarity',
    Callback = function(v)
        selectedRarity = v
    end,
})
FarmGroup:AddToggle('FarmItems', {
    Text = 'Auto Farm Brainrots',
    Default = false,
    Callback = function(v)
        autoFarm = v
    end,
})
FarmGroup:AddToggle('TsunamiSafety', {
    Text = 'Detect Tsunami (Safety)',
    Default = false,
    Callback = function(v)
        detectTsunami = v
    end,
})
TycoonGroup:AddToggle('Collect', {
    Text = 'Auto Collect Cash',
    Default = false,
    Callback = function(v)
        autoCollectCash = v
    end,
})
TycoonGroup:AddToggle('Upgrade', {
    Text = 'Auto Upgrade Slots (1-40)',
    Default = false,
    Callback = function(v)
        autoUpgrade = v
    end,
})
ArcadeGroup:AddToggle('AutoTicket', {
    Text = 'Auto Recolect Game Ticket',
    Default = false,
    Callback = function(v)
        autoTickets = v
    end,
})
ArcadeGroup:AddSlider('TicketSpeed', {
    Text = 'Ticket Speed',
    Default = 1,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Callback = function(v)
        ticketSpeed = v
    end,
})
StatsGroup:AddToggle('BuySpeed1', {
    Text = 'Auto Buy Speed +1',
    Default = false,
    Callback = function(v)
        autoBuySpeed1 = v
    end,
})
StatsGroup:AddToggle('BuySpeed5', {
    Text = 'Auto Buy Speed +5',
    Default = false,
    Callback = function(v)
        autoBuySpeed5 = v
    end,
})
StatsGroup:AddToggle('BuySpeed10', {
    Text = 'Auto Buy Speed +10',
    Default = false,
    Callback = function(v)
        autoBuySpeed10 = v
    end,
})
MoveGroup:AddSlider('Speed', {
    Text = 'Walk Speed',
    Default = 16,
    Min = 16,
    Max = 400,
    Callback = function(v)
        if player.Character then
            player.Character.Humanoid.WalkSpeed = v
        end
    end,
})
MoveGroup:AddSlider('Jump', {
    Text = 'Jump Power',
    Default = 50,
    Min = 50,
    Max = 400,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild('Humanoid') then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = v
        end
    end,
})
player.CharacterAdded:Connect(function()
    if autoFarm or autoCollectCash then
        task.wait(1)
    end
end)
Library:Notify('Script Loaded - SONORA (BETA)', 5)
