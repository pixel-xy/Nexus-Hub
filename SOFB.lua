local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
task.wait(1)

local function FindPlayerPlot()
    local Plots = workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    
    local PlotChildren = Plots:GetChildren()
    for _, PlotModel in pairs(PlotChildren) do
        if PlotModel:IsA("Model") then
            return PlotModel
        end
    end
    return nil
end

local PlayerPlot = FindPlayerPlot()
local DetectedPlotName = PlayerPlot and PlayerPlot.Name or "No detectada (Párate en tu base y recarga)"

local RayField = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = RayField:CreateWindow({
    Name = "Border RP: Base Tycoon 🏭",
    LoadingTitle = "Base Detectada: " .. DetectedPlotName,
    LoadingSubtitle = "by Gemini",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = Packages:WaitForChild("Knit")
local Services = Knit:WaitForChild("Services")
local PlotService = Services:WaitForChild("PlotService")
local PlotRF = PlotService:WaitForChild("RF")
local UpgradeRemote = PlotRF:WaitForChild("Upgrade")

local function GetBrainrotsList()
    if not PlayerPlot then
        return {"No tienes base asignada"}
    end
    
    local BrainrotsFolder = PlayerPlot:FindFirstChild("Brainrots")
    local BrainrotsList = {}
    
    if BrainrotsFolder then
        for _, Brainrot in pairs(BrainrotsFolder:GetChildren()) do
            if Brainrot:FindFirstChild("BrainrotModel") then
                if Brainrot:FindFirstChild("VisualAnchor") then
                    local Model = Brainrot:FindFirstChildWhichIsA("Model")
                    if Model then
                        table.insert(BrainrotsList, Model.Name)
                    end
                end
            end
        end
    end
    
    if #BrainrotsList == 0 then
        return {"Tu base está vacía"}
    end
    return BrainrotsList
end

local function AutoCollectCash()
    if not PlayerPlot then
        return
    end
    
    local Character = LocalPlayer.Character
    if Character then
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then
            return
        end
        
        local CashFolder = PlayerPlot:FindFirstChild("Cash")
        if CashFolder then
            for _, Cash in pairs(CashFolder:GetChildren()) do
                local TouchPart = Cash:FindFirstChild("TouchPart")
                if TouchPart then
                    pcall(function()
                        firetouchinterest(HumanoidRootPart, TouchPart, 0)
                        firetouchinterest(HumanoidRootPart, TouchPart, 1)
                    end)
                    
                    local CashChildren = Cash:GetChildren()
                    for _, Child in ipairs(CashChildren) do
                        if Child:IsA("BasePart") then
                            pcall(function()
                                firetouchinterest(HumanoidRootPart, Child, 0)
                                firetouchinterest(HumanoidRootPart, Child, 1)
                            end)
                        elseif Child:IsA("Model") then
                            local BasePart = Child:FindFirstChildWhichIsA("BasePart", true)
                            if BasePart then
                                pcall(function()
                                    firetouchinterest(HumanoidRootPart, BasePart, 0)
                                    firetouchinterest(HumanoidRootPart, BasePart, 1)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function AutoUpgradeAllPods()
    if not PlayerPlot then
        return
    end
    
    local PodsFolder = PlayerPlot:FindFirstChild("Pods")
    if PodsFolder then
        for _, Pod in pairs(PodsFolder:GetChildren()) do
            pcall(function()
                UpgradeRemote:InvokeServer(Pod.Name, 1)
            end)
        end
    end
end

local function AutoUpgradeSpecificPod()
    if not PlayerPlot then
        return
    end
    
    local PodsFolder = PlayerPlot:FindFirstChild("Pods")
    if PodsFolder then
        for _, Pod in pairs(PodsFolder:GetChildren()) do
            pcall(function()
                UpgradeRemote:InvokeServer(Pod.Name, 1)
            end)
        end
    end
end

local function GetActiveBrainrots()
    local ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
    local BrainrotList = {}
    
    if ActiveBrainrots then
        for _, Brainrot in ipairs(ActiveBrainrots:GetChildren()) do
            table.insert(BrainrotList, Brainrot.Name)
        end
    end
    
    if #BrainrotList == 0 then
        return {"No hay nada vivo ahora"}
    end
    return BrainrotList
end

local function FarmIndividualBrainrot()
    local ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
    if not ActiveBrainrots then
        return
    end
    
    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return
    end
    
    for _, Brainrot in ipairs(ActiveBrainrots:GetChildren()) do
        if Brainrot.Name == "ServerHitbox" then
            if Brainrot:FindFirstChild("Attachment") then
                if Brainrot:FindFirstChildOfClass("ProximityPrompt") then
                    HumanoidRootPart.CFrame = Brainrot:GetPivot()
                    task.wait(0.5)
                    fireproximityprompt(Brainrot:FindFirstChildOfClass("ProximityPrompt"))
                    task.wait(0.5)
                    local SavedCFrame = HumanoidRootPart.CFrame
                    HumanoidRootPart.CFrame = SavedCFrame
                    break
                end
            end
        end
    end
end

local function GetRarities()
    local SpawnedItems = workspace:FindFirstChild("SpawnedItems")
    local RarityList = {}
    
    if SpawnedItems then
        for _, Item in ipairs(SpawnedItems:GetChildren()) do
            for _, Child in ipairs(Item:GetChildren()) do
                if Child:IsA("Model") then
                    local RarityLabel = Child:FindFirstChild("Rarity", true)
                    if RarityLabel and RarityLabel:IsA("TextLabel") then
                        local RarityText = RarityLabel.Text
                        if RarityText ~= "" then
                            table.insert(RarityList, RarityText)
                        end
                    end
                end
            end
        end
    end
    
    if #RarityList == 0 then
        return {"Ninguna rareza encontrada"}
    end
    return RarityList
end

local function FarmRarityOnce()
    local ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
    if not ActiveBrainrots then
        return false
    end
    
    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return false
    end
    
    for _, Brainrot in ipairs(ActiveBrainrots:GetChildren()) do
        if Brainrot:IsA("Model") then
            local RarityLabel = Brainrot:FindFirstChild("Rarity", true)
            if RarityLabel and RarityLabel:IsA("TextLabel") then
                if Brainrot:FindFirstChild("Attachment") then
                    local ProximityPrompt = Brainrot:FindFirstChildOfClass("ProximityPrompt")
                    if ProximityPrompt then
                        HumanoidRootPart.CFrame = Brainrot:GetPivot()
                        task.wait(0.5)
                        fireproximityprompt(ProximityPrompt)
                        task.wait(0.5)
                        local SavedCFrame = HumanoidRootPart.CFrame
                        HumanoidRootPart.CFrame = SavedCFrame
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function GetZones()
    local ZonesList = {}
    local Zones = workspace:FindFirstChild("Zones")
    
    if Zones then
        for _, Zone in pairs(Zones:GetChildren()) do
            table.insert(ZonesList, Zone.Name)
        end
    end
    
    if #ZonesList == 0 then
        return {"No se encontraron zonas"}
    end
    return ZonesList
end

local MyBaseTab = Window:CreateTab("Mi Base", 4483362458)

MyBaseTab:CreateSection("Gestión de Dinero")
MyBaseTab:CreateToggle({
    Name = "💰 Auto-Collect Cash",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    AutoCollectCash()
                    task.wait(0.2)
                end
            end)
        end
    end
})

MyBaseTab:CreateSection("Mejora General (0.4s)")
MyBaseTab:CreateToggle({
    Name = "🔨 Auto-Upgrade TODOS los Pods",
    CurrentValue = false,
    Flag = "AutoUpgradeAllToggle",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    AutoUpgradeAllPods()
                    task.wait(0.4)
                end
            end)
        end
    end
})

MyBaseTab:CreateSection("Mejora Específica de Brainrot (0.4s)")
MyBaseTab:CreateButton({
    Name = "🔄 Refrescar Mis Brainrots",
    Callback = function()
        BrainrotDropdown:Refresh(GetBrainrotsList(), true)
        RayField:Notify({
            Title = "Actualizado",
            Content = "Lista de tus Brainrots actualizada.",
            Duration = 2
        })
    end
})

local BrainrotDropdown = MyBaseTab:CreateDropdown({
    Name = "Brainrot a Mejorar",
    Options = GetBrainrotsList(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "UpgradeDropdown",
    Callback = function() end
})

MyBaseTab:CreateToggle({
    Name = "🎯 Auto-Upgrade SELECCIONADO",
    CurrentValue = false,
    Flag = "AutoUpgradeSpecificToggle",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    AutoUpgradeSpecificPod()
                    task.wait(0.4)
                end
            end)
        end
    end
})

local StatsTab = Window:CreateTab("Mejoras Stats", 4483362458)

local StatPackages = ReplicatedStorage:WaitForChild("Packages")
local StatKnit = StatPackages:WaitForChild("Knit")
local StatServices = StatKnit:WaitForChild("Services")
local StatUpgradeService = StatServices:WaitForChild("StatUpgradeService")
local StatRF = StatUpgradeService:WaitForChild("RF")
local StatUpgradeRemote = StatRF:WaitForChild("Upgrade")

local RebirthPackages = ReplicatedStorage:WaitForChild("Packages")
local RebirthKnit = RebirthPackages:WaitForChild("Knit")
local RebirthServices = RebirthKnit:WaitForChild("Services")
local RebirthUpgradeService = RebirthServices:WaitForChild("StatUpgradeService")
local RebirthRF = RebirthUpgradeService:WaitForChild("RF")
local RebirthRemote = RebirthRF:WaitForChild("Rebirth")

StatsTab:CreateSection("Configuración de Compra")
StatsTab:CreateDropdown({
    Name = "Cantidad a Comprar",
    Options = {"1", "5", "10"},
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "StatMultiplierDropdown",
    Callback = function() end
})

StatsTab:CreateSection("Auto-Upgrades (0.4s)")

StatsTab:CreateToggle({
    Name = "📈 Auto Upgrade Reach",
    CurrentValue = false,
    Flag = "AutoReach",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    pcall(function()
                        StatUpgradeRemote:InvokeServer("Reach_Distance", 1)
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

StatsTab:CreateToggle({
    Name = "💪 Auto Upgrade Power",
    CurrentValue = false,
    Flag = "AutoPower",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    pcall(function()
                        StatUpgradeRemote:InvokeServer("Power", 1)
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

StatsTab:CreateToggle({
    Name = "🎒 Auto Upgrade Carry",
    CurrentValue = false,
    Flag = "AutoCarry",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    pcall(function()
                        StatUpgradeRemote:InvokeServer("GrabAmount", 1)
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

StatsTab:CreateSection("Renacimiento")

StatsTab:CreateToggle({
    Name = "⭐ Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    pcall(function()
                        RebirthRemote:InvokeServer()
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

local FarmNameTab = Window:CreateTab("Farm Nombre", 4483362458)

FarmNameTab:CreateButton({
    Name = "🔄 Actualizar Lista Nombres",
    Callback = function()
        BrainrotFarmDropdown:Refresh(GetActiveBrainrots(), true)
    end
})

local BrainrotFarmDropdown = FarmNameTab:CreateDropdown({
    Name = "Seleccionar Nombre",
    Options = GetActiveBrainrots(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "ActiveDropdown",
    Callback = function() end
})

FarmNameTab:CreateToggle({
    Name = "🎯 Auto-Farm Individual",
    CurrentValue = false,
    Flag = "FarmSingleToggle",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    FarmIndividualBrainrot()
                    task.wait(2)
                end
            end)
        end
    end
})

local FarmRarityTab = Window:CreateTab("Farm Rareza", 4483362458)

FarmRarityTab:CreateSection("Escaneo de Mapa")

FarmRarityTab:CreateButton({
    Name = "🔄 Buscar Rarezas Activas",
    Callback = function()
        RarityDropdown:Refresh(GetRarities(), true)
        RayField:Notify({
            Title = "Escaneo Listo",
            Content = "Lista de rarezas actualizada.",
            Duration = 2
        })
    end
})

local RarityDropdown = FarmRarityTab:CreateDropdown({
    Name = "Elegir Rareza a Farmear",
    Options = GetRarities(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "RarityDropdown",
    Callback = function() end
})

FarmRarityTab:CreateSection("Controles")

FarmRarityTab:CreateButton({
    Name = "🚀 Farmear UNA vez y regresar",
    Callback = function()
        local Success = FarmRarityOnce()
        if not Success then
            RayField:Notify({
                Title = "Aviso",
                Content = "No hay objetos de esa rareza.",
                Duration = 2
            })
        end
    end
})

FarmRarityTab:CreateToggle({
    Name = "🎯 Auto-Farmear esta Rareza",
    CurrentValue = false,
    Flag = "FarmRarityToggle",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    FarmRarityOnce()
                    task.wait(2)
                end
            end)
        end
    end
})

local IslandsTab = Window:CreateTab("Islas", 4483362458)

IslandsTab:CreateDropdown({
    Name = "Seleccionar Isla",
    Options = GetZones(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "ZoneDropdown",
    Callback = function() end
})

IslandsTab:CreateButton({
    Name = "🚀 Teletransportarse",
    Callback = function()
        local Zones = workspace:FindFirstChild("Zones")
        local Character = LocalPlayer.Character
        local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if Zones and HumanoidRootPart then
            local TargetZone = Zones:FindFirstChild("Zone1")
            if TargetZone then
                local TargetCFrame = TargetZone:IsA("Model") and TargetZone:GetPivot() or 
                                   (TargetZone:IsA("BasePart") and TargetZone.CFrame or 
                                   TargetZone:FindFirstChildWhichIsA("BasePart", true).CFrame)
                if TargetCFrame then
                    HumanoidRootPart.CFrame = TargetCFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
})

IslandsTab:CreateButton({
    Name = "🏠 Regresar a Mi Base",
    Callback = function()
        if PlayerPlot then
            local TouchPart = PlayerPlot:FindFirstChild("TouchPart", true) or 
                            PlayerPlot:FindFirstChildOfClass("Part", true)
            local Character = LocalPlayer.Character
            local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            
            if TouchPart and HumanoidRootPart then
                HumanoidRootPart.CFrame = TouchPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
})

local SettingsTab = Window:CreateTab("Ajustes", 4483362458)

SettingsTab:CreateButton({
    Name = "Cerrar Menú",
    Callback = function()
        RayField:Destroy()
    end
})
