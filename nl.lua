-- NanoLuxHub - FIXED HITBOXES & TP VERSION (WITH ANTI-FLING & AUTO-INJECT)
-- UPDATED: autosave-on-change, improved autorinject (queue_on_teleport), keybinds saved
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/scripts/UiLib/NotificationLib.lua", true))()

local Library
local success, err = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/scripts/UiLib/NanoLuxScriptLib.lua", true))()
end)

if not success or not Library then
    warn("Failed to load UI Library: " .. tostring(err))
    Library = {
        Toggle = function() end,
        Create = function() return {Tab = function() return {} end} end
    }
end
local Window = Library:Create("NanoLuxHub","Ultimate Script")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings System
local SETTINGS_KEY = "NanoLuxHub_Settings_v3"
local settings = {
    -- Hitbox
    hitboxEnabled = false,
    hitboxSize = 20,
    hitboxTransparency = 0,
    
    -- Fling
    flingEnabled = false,
    flingTarget = nil,
    
    -- TP
    tpTarget = nil,
    
    -- Movement
    walkSpeed = 16,
    infinityJump = false,
    noclipEnabled = false,
    flyEnabled = false,
    flySpeed = 100,
    
    -- Anti-Fling
    antiFlingEnabled = false,
    maxOtherVel = 100,
    maxSelfVel = 250,
    savePosThreshold = 40,
    
    -- ESP
    nameESP = false,
    boxESP = false,
    radarESP = false,
    
    -- Colors
    boxColor = Color3.new(1, 0, 0),
    nameColor = Color3.new(1, 1, 1),
    radarColor = Color3.new(0, 1, 1),
    
    -- Keybinds
    toggleUIKey = Enum.KeyCode.LeftControl,
    noclipKey = Enum.KeyCode.N,
    flyKey = Enum.KeyCode.F
}

-- Load Settings
local function LoadSettings()
    local success, saved = pcall(function()
        if readfile then
            local content = readfile(SETTINGS_KEY)
            if content and #content > 0 then
                return HttpService:JSONDecode(content)
            end
        end
        return {}
    end)
    
    if success and saved then
        for key, value in pairs(saved) do
            if settings[key] ~= nil then
                -- Handle Color3 conversion
                if type(value) == "table" and value.r and value.g and value.b then
                    settings[key] = Color3.new(value.r, value.g, value.b)
                -- Handle EnumItem conversion (we saved numeric .Value)
                elseif key:find("Key") and type(value) == "number" then
                    local ok, keyCode = pcall(function()
                        return Enum.KeyCode[value]
                    end)
                    if ok and keyCode then
                        settings[key] = keyCode
                    end
                -- Handle other values
                else
                    settings[key] = value
                end
            end
        end
        return true
    end
    return false
end

-- Save Settings
local function SaveSettings()
    local settingsToSave = {}
    
    for key, value in pairs(settings) do
        if typeof(value) == "Color3" then
            settingsToSave[key] = {r = value.r, g = value.g, b = value.b}
        elseif typeof(value) == "EnumItem" then
            -- Save numeric Value to allow restoring by index
            settingsToSave[key] = value.Value
        else
            settingsToSave[key] = value
        end
    end
    
    local success = pcall(function()
        if writefile then
            writefile(SETTINGS_KEY, HttpService:JSONEncode(settingsToSave))
            return true
        end
        return false
    end)
    
    return success
end

-- Make settings auto-save on any assignment
-- (Set metatable AFTER LoadSettings to avoid massive writes during load; we'll set it below.)

-- Auto-Inject System
local function AutoReinject()
    -- Save settings at startup
    SaveSettings()
    
    -- Attempt to queue script on teleport (exploit env dependent)
    local QUEUE_URL = "https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/scripts/nl.lua"
    if queue_on_teleport then
        pcall(function()
            -- queue to fetch and run the raw script after teleport
            queue_on_teleport('loadstring(game:HttpGet("' .. QUEUE_URL .. '", true))()')
            Notification.new("info", "Auto-Inject", "queue_on_teleport установлен. Скрипт попытается авто-инжектнуться после телепорта.", true, 4)
        end)
    else
        -- If queue_on_teleport not available, still inform user and rely on LocalPlayerArrivedFromTeleport handler below
        Notification.new("warning", "Auto-Inject", "queue_on_teleport не обнаружен в вашей среде. Попробуйте среду, которая поддерживает queue_on_teleport для надёжного авто-инжекта.", true, 6)
    end

    -- Отслеживаем телепортацию (улучшенная версия)
    local teleportConnection
    -- LocalPlayerArrivedFromTeleport exists in some envs; protect with pcall
    pcall(function()
        if TeleportService and TeleportService.LocalPlayerArrivedFromTeleport then
            teleportConnection = TeleportService.LocalPlayerArrivedFromTeleport:Connect(function(loadingGui, dataTable)
                -- Игрок прибыл после телепортации - загружаем настройки
                task.wait(1) -- Ждём немного после загрузки
                if LoadSettings() then
					ApplySettings()
                end
            end)
        end
    end)
    
    -- Проверяем, нужно ли применять сохраненные настройки после загрузки
    spawn(function()
        task.wait(3) -- Ждём полной загрузки игры
        
        if LoadSettings() then
			ApplySettings()
        end
    end)
    
    return teleportConnection
end

-- Variables
local FlingActive = settings.flingEnabled
local FlingTarget = settings.flingTarget
local TPTarget = settings.tpTarget
local OriginalPosition = nil
local InfinityJump = settings.infinityJump
local NoclipActive = settings.noclipEnabled
local FlyActive = settings.flyEnabled
local FlySpeed = settings.flySpeed or 100
local BodyVelocity = nil
local FlyConnection = nil
local NoclipConnection = nil
local WalkSpeedConnection = nil
local AimTargetActive = false
local AimTargetConnection = nil
local AimTargetTarget = nil
local AimTargetAngle = 0 -- Store angle outside function
local AimTargetBodyPosition = nil -- Для стабильной орбиты (сервер не затирает позицию)

-- FIXED HITBOX SYSTEM
local HitboxConnection = nil
local hitboxEnabled = settings.hitboxEnabled
local hitboxTransparency = settings.hitboxTransparency
local originalHitboxSize = Vector3.new(1, 1, 1)
local hitboxSize = settings.hitboxSize
local hitboxParts = {} -- Store invisible hitbox parts for inside damage

-- ESP Variables
local NameESP = settings.nameESP
local ArrowESP = false
local BoxESP = settings.boxESP
local RadarESP = settings.radarESP
local ESPPlayers = {}
local ArrowESPObjects = {}
local BoxESPObjects = {}
local RadarESPObjects = {}
local OriginalSizes = {}
local OriginalHitboxSizes = {}

-- Anti-Fling Variables
local AntiFlingActive = settings.antiFlingEnabled
local AntiFlingConnection = nil
local PlayerData = {}
local LastSafeCFrame = nil
local MAX_OTHER_VEL = settings.maxOtherVel
local MAX_SELF_VEL = settings.maxSelfVel
local SAVE_POS_THRESHOLD = settings.savePosThreshold

-- Colors
local ESPColors = {
    Arrow = Color3.new(1, 1, 1),
    Box = settings.boxColor,
    Name = settings.nameColor,
    Radar = settings.radarColor
}

-- UI Toggle State
local UIToggled = false

-- Загружаем настройки при старте
LoadSettings()

-- Устанавливаем автосохранение на изменение settings
-- (метатаблица вызывает SaveSettings() при любом присваивании)
local settings_mt = {
    __newindex = function(t, k, v)
        rawset(t, k, v)
        pcall(SaveSettings)
    end
}
setmetatable(settings, settings_mt)

-- Запускаем систему авто-инжекта
local teleportConnection = AutoReinject()

-- Main Tab
local MainTab = Window:Tab("Main",false)
MainTab:Label("Character Modifications")

-- OPTIMIZED HITBOX SYSTEM
local hitboxPartsByPlayer = {} -- Store parts per player for easier cleanup

local function createHitboxParts(player, rootPart)
    if hitboxPartsByPlayer[player] then
        -- Clean up existing parts
        for _, part in pairs(hitboxPartsByPlayer[player]) do
            if part and part.Parent then
                part:Destroy()
            end
        end
    end
    hitboxPartsByPlayer[player] = {}
    
    -- Reduced grid size for better performance (2x2x2 instead of 3x3x3 = 8 parts instead of 27)
    local subHitboxSize = hitboxSize * 0.6
    local gridSize = 2
    local spacing = hitboxSize * 0.8
    
    for x = -0.5, 0.5, 1 do
        for y = -0.5, 0.5, 1 do
            for z = -0.5, 0.5, 1 do
                local subPart = Instance.new("Part")
                subPart.Name = "InvisibleHitbox_" .. player.Name
                subPart.Size = Vector3.new(subHitboxSize, subHitboxSize, subHitboxSize)
                subPart.Transparency = 1
                subPart.CanCollide = false
                subPart.Anchored = true
                subPart.CollisionGroup = "PlayerHitbox"
                subPart.Parent = player.Character
                
                local offset = Vector3.new(x * spacing, y * spacing, z * spacing)
                subPart.CFrame = rootPart.CFrame * CFrame.new(offset)
                
                table.insert(hitboxPartsByPlayer[player], subPart)
            end
        end
    end
end

local function updateHitboxPositions()
    -- Only update positions, don't recreate parts
    for player, parts in pairs(hitboxPartsByPlayer) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local spacing = hitboxSize * 0.8
            local partIndex = 1
            
            for x = -0.5, 0.5, 1 do
                for y = -0.5, 0.5, 1 do
                    for z = -0.5, 0.5, 1 do
                        if parts[partIndex] and parts[partIndex].Parent then
                            local offset = Vector3.new(x * spacing, y * spacing, z * spacing)
                            parts[partIndex].CFrame = rootPart.CFrame * CFrame.new(offset)
                        end
                        partIndex = partIndex + 1
                    end
                end
            end
        end
    end
end

local function updateHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local success, err = pcall(function()
                    rootPart.CanCollide = not hitboxEnabled
                    rootPart.Transparency = hitboxEnabled and hitboxTransparency or 0
                    rootPart.Size = hitboxEnabled and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or originalHitboxSize
                    rootPart.CollisionGroup = hitboxEnabled and "PlayerHitbox" or "Default"
                    
                    -- Create hitbox parts only if enabled and not already created
                    if hitboxEnabled then
                        if not hitboxPartsByPlayer[player] or #hitboxPartsByPlayer[player] == 0 then
                            createHitboxParts(player, rootPart)
                        end
                    else
                        -- Clean up parts when disabled
                        if hitboxPartsByPlayer[player] then
                            for _, part in pairs(hitboxPartsByPlayer[player]) do
                                if part and part.Parent then
                                    part:Destroy()
                                end
                            end
                            hitboxPartsByPlayer[player] = nil
                        end
                    end
                end)
                if not success then
                    -- Silent fail
                end
            end
        end
    end
end

-- Троттлинг хитбоксов: обновлять позиции раз в 0.1 сек вместо каждого кадра (сильно меньше грузит FPS)
local HITBOX_UPDATE_INTERVAL = 0.1
local lastHitboxUpdate = 0

local HitboxToggle = MainTab:Toggle("Hitbox",function(state)
    hitboxEnabled = state
    settings.hitboxEnabled = state
    -- SaveSettings() will be called automatically by metatable
    if state then
        if HitboxConnection then HitboxConnection:Disconnect() end
        -- Initial setup
        updateHitboxes()
        lastHitboxUpdate = tick()
        -- Обновляем позиции реже (раз в HITBOX_UPDATE_INTERVAL сек), не каждый кадр
        HitboxConnection = RunService.Heartbeat:Connect(function()
            if not hitboxEnabled then return end
            local now = tick()
            if now - lastHitboxUpdate >= HITBOX_UPDATE_INTERVAL then
                lastHitboxUpdate = now
                updateHitboxPositions()
            end
        end)
        Notification.new("success", "Hitbox", "Hitbox включен", true, 3)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
        end
        updateHitboxes()
        Notification.new("info", "Hitbox", "Hitbox выключен", true, 3)
    end
end)

MainTab:Slider("Hitbox Size",1,50,function(value)
    hitboxSize = value
    settings.hitboxSize = value
    -- metatable saves
    -- Recreate parts with new size
    if hitboxEnabled then
        for player, parts in pairs(hitboxPartsByPlayer) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createHitboxParts(player, player.Character:FindFirstChild("HumanoidRootPart"))
            end
        end
    end
    updateHitboxes()
end)

MainTab:Slider("Hitbox Transparency",0,100,function(value)
    hitboxTransparency = value / 100
    settings.hitboxTransparency = value / 100
    -- metatable saves
    updateHitboxes()
end)

-- Fling System
local FlingDropdown = MainTab:Dropdown("Fling Target",{"Loading..."},function(selected)
    FlingTarget = selected
    settings.flingTarget = selected
    Notification.new("info", "Fling Target", "Цель: " .. tostring(selected), true, 3)
end)

MainTab:Toggle("Fling",function(state)
    FlingActive = state
    settings.flingEnabled = state
    if state and FlingTarget and FlingTarget ~= "Loading..." and FlingTarget ~= "No players found" then
        Notification.new("success", "Fling", "Fling активирован для: " .. FlingTarget, true, 3)
        StartFling()
    else
        if state then
            Notification.new("error", "Fling", "Цель не найдена!", true, 3)
        else
            Notification.new("info", "Fling", "Fling деактивирован", true, 3)
        end
        StopFling()
    end
end)

-- TP System
local TPDropdown = MainTab:Dropdown("TP Target",{"Loading..."},function(selected)
    TPTarget = selected
    settings.tpTarget = selected
    Notification.new("info", "TP Target", "Цель: " .. tostring(selected), true, 3)
end)

local function TeleportToPlayer()
    if not TPTarget or TPTarget == "Loading..." or TPTarget == "No players found" then 
        Notification.new("error", "Teleport", "Цель не найдена!", true, 3)
        return 
    end
    
    local targetPlayer = Players:FindFirstChild(TPTarget)
    if not targetPlayer then
        for _, player in pairs(Players:GetPlayers()) do
            if string.find(string.lower(player.Name), string.lower(TPTarget or "")) then
                targetPlayer = player
                break
            end
        end
    end

    if targetPlayer and targetPlayer.Character then
        local myhrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local thrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myhrp and thrp then
            myhrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 0)
            Notification.new("success", "Teleport", "Телепортирован к: " .. targetPlayer.Name, true, 3)
        else
            Notification.new("error", "Teleport", "Ошибка телепортации!", true, 3)
        end
    else
        Notification.new("error", "Teleport", "Цель не найдена!", true, 3)
    end
end

MainTab:Button("TP to Player",function()
    TeleportToPlayer()
end)

-- AimTarget System
local AimTargetDropdown = MainTab:Dropdown("AimTarget",{"Loading..."},function(selected)
    AimTargetTarget = selected
    Notification.new("info", "AimTarget", "Цель: " .. tostring(selected), true, 3)
end)

local AimTargetToggle = MainTab:Toggle("AimTarget",function(state)
    AimTargetActive = state
    if state and AimTargetTarget and AimTargetTarget ~= "Loading..." and AimTargetTarget ~= "No players found" then
        StartAimTarget()
        Notification.new("success", "AimTarget", "AimTarget активирован для: " .. AimTargetTarget, true, 3)
    else
        if state then
            Notification.new("error", "AimTarget", "Цель не найдена!", true, 3)
        else
            Notification.new("info", "AimTarget", "AimTarget деактивирован", true, 3)
        end
        StopAimTarget()
    end
end)

function StartAimTarget()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        Notification.new("error", "AimTarget", "Персонаж не готов", true, 3)
        return
    end
    
    StopAimTarget()
    
    local targetPlayer = Players:FindFirstChild(AimTargetTarget)
    if not targetPlayer then
        for _, p in pairs(Players:GetPlayers()) do
            if string.find(string.lower(p.Name), string.lower(AimTargetTarget or "")) then
                targetPlayer = p
                break
            end
        end
    end
    
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notification.new("error", "AimTarget", "Цель не найдена", true, 3)
        AimTargetActive = false
        return
    end
    
    -- Reset angle when starting
    AimTargetAngle = 0
    
    local myhrp = Player.Character:FindFirstChild("HumanoidRootPart")
    local thrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myhrp or not thrp then return end
    
    -- Используем BodyPosition чтобы орбита не сбрасывалась сервером/физикой
    if AimTargetBodyPosition then AimTargetBodyPosition:Destroy() end
    AimTargetBodyPosition = Instance.new("BodyPosition")
    AimTargetBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    AimTargetBodyPosition.P = 20000
    AimTargetBodyPosition.D = 500
    AimTargetBodyPosition.Parent = myhrp
    
    local radius = 5
    local height = 3
    local rotationSpeed = 0.12
    
    -- Первая телепортация к цели
    myhrp.CFrame = thrp.CFrame + Vector3.new(0, height, 0)
    
    AimTargetConnection = RunService.Heartbeat:Connect(function()
        if not AimTargetActive or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            StopAimTarget()
            return
        end
        if not AimTargetBodyPosition or not AimTargetBodyPosition.Parent then
            StopAimTarget()
            return
        end
        
        local target = Players:FindFirstChild(AimTargetTarget)
        if not target then
            for _, p in pairs(Players:GetPlayers()) do
                if string.find(string.lower(p.Name), string.lower(AimTargetTarget or "")) then
                    target = p
                    break
                end
            end
        end
        
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            StopAimTarget()
            return
        end
        
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local trp = target.Character:FindFirstChild("HumanoidRootPart")
        if not root or not trp then return end
        
        -- Кружение: приращиваем угол и считаем позицию орбиты
        AimTargetAngle = AimTargetAngle + rotationSpeed
        local x = math.cos(AimTargetAngle) * radius
        local z = math.sin(AimTargetAngle) * radius
        local targetPos = trp.Position
        local orbitPos = targetPos + Vector3.new(x, height, z)
        
        AimTargetBodyPosition.Position = orbitPos
        -- Поворачиваем персонажа лицом к цели
        root.CFrame = CFrame.lookAt(root.Position, targetPos)
    end)
end

function StopAimTarget()
    AimTargetActive = false
    if AimTargetConnection then
        AimTargetConnection:Disconnect()
        AimTargetConnection = nil
    end
    if AimTargetBodyPosition then
        AimTargetBodyPosition:Destroy()
        AimTargetBodyPosition = nil
    end
end

-- Update player lists
function UpdatePlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(playerNames, player.Name)
        end
    end
    
    table.sort(playerNames, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    
    if #playerNames == 0 then
        playerNames = {"No players found"}
    end
    FlingDropdown:UpdateDropdown(playerNames)
    TPDropdown:UpdateDropdown(playerNames)
    
    -- Apply saved targets
    if settings.flingTarget and table.find(playerNames, settings.flingTarget) then
        FlingTarget = settings.flingTarget
    end
    if settings.tpTarget and table.find(playerNames, settings.tpTarget) then
        TPTarget = settings.tpTarget
    end
    
    -- Update AimTarget dropdown
    if AimTargetDropdown then
        AimTargetDropdown:UpdateDropdown(playerNames)
    end
end

-- Fling Logic
local getgenv = getgenv or function() return _G end
getgenv().OldPos = nil
getgenv().FPDH = workspace and workspace.FallenPartsDestroyHeight or 0

local function Message(Title, Text, Time)
    Notification.new("error", Title, Text, true, 3)
end

local function SkidFling_TargetPlayer(TargetPlayer)
    local ok, err = pcall(function()
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer and TargetPlayer.Character
        if not TCharacter then return end

        local THumanoid
        local TRootPart
        local THead
        local Accessory
        local Handle

        if TCharacter:FindFirstChildOfClass("Humanoid") then
            THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        end
        if THumanoid and THumanoid.RootPart then
            TRootPart = THumanoid.RootPart
        end
        if TCharacter:FindFirstChild("Head") then
            THead = TCharacter.Head
        end
        if TCharacter:FindFirstChildOfClass("Accessory") then
            Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        end
        if Accessory and Accessory:FindFirstChild("Handle") then
            Handle = Accessory.Handle
        end

        if Character and Humanoid and RootPart then
            if RootPart.Velocity.Magnitude < 50 then
                getgenv().OldPos = RootPart.CFrame
            end

            if THumanoid and THumanoid.Sit then
                return Message("Error", TargetPlayer.Name .. " сидит")
            end

            if THead then
                workspace.CurrentCamera.CameraSubject = THead
            elseif Handle then
                workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid and TRootPart then
                workspace.CurrentCamera.CameraSubject = THumanoid
            end

            if not TCharacter:FindFirstChildWhichIsA("BasePart") then
                return
            end

            local FPos = function(BasePart, Pos, Ang)
                if not RootPart or not Character then return end
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end

            local SFBasePart = function(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0
                repeat
                    if RootPart and THumanoid and BasePart then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle = Angle + 100
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    end
                until Time + TimeToWait < tick() or not FlingActive
            end

            local oldFPDH = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = 0/0

            local BV = Instance.new("BodyVelocity")
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

            if TRootPart then
                SFBasePart(TRootPart)
            elseif THead then
                SFBasePart(THead)
            elseif Handle then
                SFBasePart(Handle)
            else
                BV:Destroy()
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                workspace.CurrentCamera.CameraSubject = Humanoid
                workspace.FallenPartsDestroyHeight = oldFPDH
                return Message("Error", TargetPlayer.Name .. " нет валидных частей")
            end

            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.CurrentCamera.CameraSubject = Humanoid

            if getgenv().OldPos then
                repeat
                    if RootPart and Character then
                        RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                        Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                        Humanoid:ChangeState("GettingUp")
                        for _, part in pairs(Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                            end
                        end
                    end
                    task.wait()
                until not RootPart or (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                workspace.FallenPartsDestroyHeight = oldFPDH
            end
        else
            return Message("Error", "Ваш персонаж не готов")
        end
    end)
end

function StartFling()
    if FlingActive == false then return end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        Message("Error", "Ваш персонаж не готов")
        return
    end

    OriginalPosition = Player.Character.HumanoidRootPart.CFrame

    local targetPlayer = Players:FindFirstChild(FlingTarget)
    if not targetPlayer then
        for _, p in pairs(Players:GetPlayers()) do
            if string.find(string.lower(p.Name), string.lower(FlingTarget or "")) then
                targetPlayer = p
                break
            end
        end
    end

    if not targetPlayer then
        Message("Error", "Цель не найдена")
        FlingActive = false
        return
    end

    spawn(function()
        while FlingActive do
            if targetPlayer and targetPlayer.Parent then
                SkidFling_TargetPlayer(targetPlayer)
                task.wait(0.4)
            else
                local t = Players:FindFirstChild(FlingTarget)
                if t then
                    targetPlayer = t
                else
                    FlingActive = false
                end
            end
        end

        pcall(function()
            if OriginalPosition and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = Player.Character.HumanoidRootPart
                hrp.CFrame = OriginalPosition
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.RotVelocity = Vector3.new(0,0,0)
            end
        end)
    end)
end

function StopFling()
    FlingActive = false
end

-- Misc Tab
local MiscTab = Window:Tab("Misc",false)
MiscTab:Label("Movement & Teleport")

-- WalkSpeed
local CurrentWalkSpeed = settings.walkSpeed
MiscTab:Slider("Walk Speed",16,500,function(value)
    CurrentWalkSpeed = value
    settings.walkSpeed = value
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end)

-- Constantly fix player speed (prevent resets)
if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
WalkSpeedConnection = RunService.Heartbeat:Connect(function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid.WalkSpeed ~= CurrentWalkSpeed then
            humanoid.WalkSpeed = CurrentWalkSpeed
        end
    end
end)

MiscTab:Button("Reset Walk Speed",function()
    CurrentWalkSpeed = 16
    settings.walkSpeed = 16
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
    Notification.new("success", "WalkSpeed", "Скорость сброшена", true, 3)
end)

-- Infinity Jump
MiscTab:Toggle("Infinity Jump",function(state)
    InfinityJump = state
    settings.infinityJump = state
    if state then
        Notification.new("success", "Infinity Jump", "Бесконечный прыжок включен", true, 3)
    else
        Notification.new("info", "Infinity Jump", "Бесконечный прыжок выключен", true, 3)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfinityJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Noclip
local NoclipToggle = MiscTab:Toggle("Noclip",function(state)
    NoclipActive = state
    settings.noclipEnabled = state
    if state then
        StartNoclip()
        Notification.new("success", "Noclip", "Noclip включен", true, 3)
    else
        StopNoclip()
        Notification.new("info", "Noclip", "Noclip выключен", true, 3)
    end
end)

function StartNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        if NoclipActive and Player.Character then
            for _, part in pairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function StopNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

-- Fly System
local FlyToggle = MiscTab:Toggle("Fly",function(state)
    FlyActive = state
    settings.flyEnabled = state
    if state then
        StartFlying()
        Notification.new("success", "Fly", "Полёт включен", true, 3)
    else
        StopFlying()
        Notification.new("info", "Fly", "Полёт выключен", true, 3)
    end
end)

-- Fly Speed
MiscTab:Slider("Fly Speed",50,500,function(value)
    FlySpeed = value
    settings.flySpeed = value
end)

function StartFlying()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then 
        Notification.new("error", "Fly", "Персонаж не готов", true, 3)
        return 
    end

    StopFlying()

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    BodyVelocity.Parent = Player.Character.HumanoidRootPart

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyActive or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            StopFlying()
            return
        end

        local camera = Workspace.CurrentCamera
        local root = Player.Character.HumanoidRootPart

        local flyDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            flyDirection = flyDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            flyDirection = flyDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            flyDirection = flyDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            flyDirection = flyDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyDirection = flyDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            flyDirection = flyDirection - Vector3.new(0, 1, 0)
        end

        BodyVelocity.Velocity = flyDirection * FlySpeed
    end)
end

function StopFlying()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
end

-- Anti-Fling System
MiscTab:Label("Anti-Cheat & Protection")

-- Anti-Fling Toggle
MiscTab:Toggle("Anti-Fling",function(state)
    AntiFlingActive = state
    settings.antiFlingEnabled = state
    if state then
        StartAntiFling()
        Notification.new("success", "Anti-Fling", "Анти-флинг включен", true, 3)
    else
        StopAntiFling()
        Notification.new("info", "Anti-Fling", "Анти-флинг выключен", true, 3)
    end
end)

-- Anti-Fling Settings
MiscTab:Slider("Other Player Velocity Limit",100,300,function(value)
    MAX_OTHER_VEL = value
    settings.maxOtherVel = value
end)

MiscTab:Slider("Self Velocity Limit",250,500,function(value)
    MAX_SELF_VEL = value
    settings.maxSelfVel = value
end)

MiscTab:Slider("Save Position Threshold",40,100,function(value)
    SAVE_POS_THRESHOLD = value
    settings.savePosThreshold = value
end)

-- Anti-Fling Functions
local function SetupAntiFlingPlayer(plr)
    if plr == Player then return end

    local data = {
        Character = nil,
        Root = nil,
        Detected = false,
    }
    PlayerData[plr] = data

    local function OnChar(char)
        data.Character = char
        data.Root = nil
        data.Detected = false

        local success, result = pcall(function()
            char:WaitForChild("HumanoidRootPart", 5)
            data.Root = char:FindFirstChild("HumanoidRootPart")
        end)
        
        if not success then
            -- Silent fail
        end
    end

    if plr.Character then
        OnChar(plr.Character)
    end
    plr.CharacterAdded:Connect(OnChar)
end

function StartAntiFling()
    -- Initialize player data
    PlayerData = {}
    for _,plr in ipairs(Players:GetPlayers()) do
        SetupAntiFlingPlayer(plr)
    end
    
    -- Set up connections
    Players.PlayerAdded:Connect(SetupAntiFlingPlayer)
    Players.PlayerRemoving:Connect(function(plr)
        PlayerData[plr] = nil
    end)

    -- Start anti-fling heartbeat
    if AntiFlingConnection then AntiFlingConnection:Disconnect() end
    
    AntiFlingConnection = RunService.Heartbeat:Connect(function()
        if not AntiFlingActive then return end

        --------------------------------------------------------
        -- 1) АНТИ-ФЛИНГ ДЛЯ ДРУГИХ ИГРОКОВ
        --------------------------------------------------------
        for plr, data in pairs(PlayerData) do
            local root = data.Root
            local char = data.Character

            if root and char and char.Parent == Workspace then
                local success, lv, av = pcall(function()
                    return root.AssemblyLinearVelocity.Magnitude, root.AssemblyAngularVelocity.Magnitude
                end)
                
                if success then
                    if lv > MAX_OTHER_VEL or av > MAX_OTHER_VEL then
                        if not data.Detected then
                            Notification.new("warning", "Anti-Fling", "Fling detected: " .. plr.Name, true, 3)
                            data.Detected = true
                        end

                        -- аккуратно останавливаем, без ломания физики
                        pcall(function()
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                            root.CanCollide = false
                        end)
                    else
                        data.Detected = false
                        pcall(function()
                            root.CanCollide = true
                        end)
                    end
                end
            end
        end

        --------------------------------------------------------
        -- 2) АНТИ-ФЛИНГ ДЛЯ ТЕБЯ (НЕЙТРАЛИЗАЦИЯ)
        --------------------------------------------------------
        local char = Player.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local success, lv, av = pcall(function()
            return root.AssemblyLinearVelocity.Magnitude, root.AssemblyAngularVelocity.Magnitude
        end)
        
        if not success then return end

        -- если тебя кинуло
        if lv > MAX_SELF_VEL or av > MAX_SELF_VEL then
            if LastSafeCFrame then
                pcall(function()
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = LastSafeCFrame
                end)
                Notification.new("error", "Anti-Fling", "High velocity neutralized.", true, 3)
            end

        -- сохраняем безопасную позицию пока игрок движется нормально
        elseif lv < SAVE_POS_THRESHOLD and av < SAVE_POS_THRESHOLD * 2 then
            LastSafeCFrame = root.CFrame
        end
    end)
end

function StopAntiFling()
    if AntiFlingConnection then
        AntiFlingConnection:Disconnect()
        AntiFlingConnection = nil
    end
    
    -- Reset all player collisions
    for plr, data in pairs(PlayerData) do
        if data.Root then
            pcall(function()
                data.Root.CanCollide = true
            end)
        end
    end
    
    PlayerData = {}
    LastSafeCFrame = nil
end

-- ESP Tab
local ESPTab = Window:Tab("ESP",false)
ESPTab:Label("Visual ESP Features")

-- Name ESP
ESPTab:Toggle("Name ESP",function(state)
    NameESP = state
    settings.nameESP = state
    UpdateAllESP()
    if state then
        Notification.new("success", "ESP", "Name ESP включен", true, 3)
    else
        Notification.new("info", "ESP", "Name ESP выключен", true, 3)
    end
end)

-- Box ESP
ESPTab:Toggle("Box ESP",function(state)
    BoxESP = state
    settings.boxESP = state
    if state then
        StartBoxESP()
        Notification.new("success", "ESP", "Box ESP включен", true, 3)
    else
        StopBoxESP()
        Notification.new("info", "ESP", "Box ESP выключен", true, 3)
    end
end)

-- Radar ESP
ESPTab:Toggle("Radar ESP",function(state)
    RadarESP = state
    settings.radarESP = state
    if state then
        StartRadarESP()
        Notification.new("success", "ESP", "Radar ESP включен", true, 3)
    else
        StopRadarESP()
        Notification.new("info", "ESP", "Radar ESP выключен", true, 3)
    end
end)

-- Name ESP Functions
function CreateNameESP(player)
    if not player.Character then return nil end
    
    local head = player.Character:FindFirstChild("Head")
    if not head then
        -- If head doesn't exist, try to find it later
        player.Character:WaitForChild("Head", 5)
        head = player.Character:FindFirstChild("Head")
        if not head then return nil end
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameESP_" .. player.Name
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = math.huge
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = ESPColors.Name
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    return billboard
end

function UpdateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            UpdatePlayerESP(player)
        end
    end
end

function UpdatePlayerESP(player)
    if NameESP then
        if not ESPPlayers[player] then
            ESPPlayers[player] = CreateNameESP(player)
        elseif ESPPlayers[player] and (ESPPlayers[player].Parent == nil or not player.Character or not player.Character:FindFirstChild("Head")) then
            if ESPPlayers[player] then
                ESPPlayers[player]:Destroy()
            end
            ESPPlayers[player] = CreateNameESP(player)
        end
        if ESPPlayers[player] and ESPPlayers[player].TextLabel then
            ESPPlayers[player].TextLabel.TextColor3 = ESPColors.Name
        end
    else
        if ESPPlayers[player] then
            ESPPlayers[player]:Destroy()
            ESPPlayers[player] = nil
        end
    end
end

function CleanupPlayerESP(player)
    if ESPPlayers[player] then
        ESPPlayers[player]:Destroy()
        ESPPlayers[player] = nil
    end
end

-- Box ESP
local BoxUpdateConnection = nil

function StartBoxESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and not BoxESPObjects[player] then
            local lines = {
                Top = Drawing.new("Line"),
                Bottom = Drawing.new("Line"),
                Left = Drawing.new("Line"),
                Right = Drawing.new("Line")
            }
            for _, line in pairs(lines) do
                line.Visible = false
                line.Color = ESPColors.Box
                line.Thickness = 2
            end
            BoxESPObjects[player] = lines
        end
    end

    if BoxUpdateConnection then BoxUpdateConnection:Disconnect() end
    BoxUpdateConnection = RunService.RenderStepped:Connect(function()
        if not BoxESP then
            for pl, box in pairs(BoxESPObjects) do
                if box then
                    for _, line in pairs(box) do
                        pcall(function() line.Visible = false end)
                    end
                end
            end
            if BoxUpdateConnection then BoxUpdateConnection:Disconnect(); BoxUpdateConnection = nil end
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                local lines = BoxESPObjects[player]
                if not lines then
                    local newLines = {
                        Top = Drawing.new("Line"),
                        Bottom = Drawing.new("Line"),
                        Left = Drawing.new("Line"),
                        Right = Drawing.new("Line")
                    }
                    for _, line in pairs(newLines) do
                        line.Visible = false
                        line.Color = ESPColors.Box
                        line.Thickness = 2
                    end
                    BoxESPObjects[player] = newLines
                    lines = newLines
                end

                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local head = character:FindFirstChild("Head")
                        local headPos = head and Camera:WorldToViewportPoint(head.Position) or rootPos

                        local height = math.abs(headPos.Y - rootPos.Y) * 2
                        local width = height * 0.6

                        local topLeft = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                        local topRight = Vector2.new(rootPos.X + width/2, rootPos.Y - height/2)
                        local bottomLeft = Vector2.new(rootPos.X - width/2, rootPos.Y + height/2)
                        local bottomRight = Vector2.new(rootPos.X + width/2, rootPos.Y + height/2)

                        pcall(function()
                            lines.Top.From = topLeft
                            lines.Top.To = topRight
                            lines.Top.Visible = true

                            lines.Bottom.From = bottomLeft
                            lines.Bottom.To = bottomRight
                            lines.Bottom.Visible = true

                            lines.Left.From = topLeft
                            lines.Left.To = bottomLeft
                            lines.Left.Visible = true

                            lines.Right.From = topRight
                            lines.Right.To = bottomRight
                            lines.Right.Visible = true

                            for _, line in pairs(lines) do
                                line.Color = ESPColors.Box
                            end
                        end)
                    else
                        for _, line in pairs(lines) do
                            pcall(function() line.Visible = false end)
                        end
                    end
                else
                    for _, line in pairs(lines) do
                        pcall(function() line.Visible = false end)
                    end
                end
            end
        end
    end)
end

function StopBoxESP()
    if BoxUpdateConnection then
        BoxUpdateConnection:Disconnect()
        BoxUpdateConnection = nil
    end
    for _, box in pairs(BoxESPObjects) do
        if box then
            for _, line in pairs(box) do
                pcall(function() line:Remove() end)
            end
        end
    end
    BoxESPObjects = {}
end

-- Radar ESP
local RadarConnections = {}
local RadarBackground = nil
local RadarBorder = nil
local RadarLocalDot = nil
local RadarPlayerDots = {}

function StartRadarESP()
    RadarBackground = Drawing.new("Circle")
    RadarBackground.Visible = true
    RadarBackground.Transparency = 0.9
    RadarBackground.Color = Color3.fromRGB(10, 10, 10)
    RadarBackground.Position = Vector2.new(200, 200)
    RadarBackground.Radius = 80
    RadarBackground.Filled = true
    RadarBackground.Thickness = 1

    RadarBorder = Drawing.new("Circle")
    RadarBorder.Visible = true
    RadarBorder.Transparency = 0.75
    RadarBorder.Color = Color3.fromRGB(75, 75, 75)
    RadarBorder.Position = Vector2.new(200, 200)
    RadarBorder.Radius = 80
    RadarBorder.Filled = false
    RadarBorder.Thickness = 3

    RadarLocalDot = Drawing.new("Triangle")
    RadarLocalDot.Visible = true
    RadarLocalDot.Thickness = 1
    RadarLocalDot.Filled = true
    RadarLocalDot.Color = Color3.fromRGB(255, 255, 255)
    RadarLocalDot.PointA = Vector2.new(200, 194)
    RadarLocalDot.PointB = Vector2.new(197, 206)
    RadarLocalDot.PointC = Vector2.new(203, 206)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            CreateRadarDot(player)
        end
    end

    local radarUpdateConnection
    radarUpdateConnection = RunService.RenderStepped:Connect(function()
        if not RadarESP then
            radarUpdateConnection:Disconnect()
            return
        end

        if RadarLocalDot then
            RadarLocalDot.PointA = Vector2.new(200, 194)
            RadarLocalDot.PointB = Vector2.new(197, 206)
            RadarLocalDot.PointC = Vector2.new(203, 206)
        end

        for player, dot in pairs(RadarPlayerDots) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                UpdateRadarDotPosition(player, dot)
            else
                dot.Visible = false
            end
        end
    end)

    table.insert(RadarConnections, radarUpdateConnection)
end

function StopRadarESP()
    for _, connection in pairs(RadarConnections) do
        connection:Disconnect()
    end
    RadarConnections = {}

    for _, dot in pairs(RadarPlayerDots) do
        if dot then
            pcall(function() dot:Remove() end)
        end
    end
    RadarPlayerDots = {}

    if RadarBackground then pcall(function() RadarBackground:Remove() end); RadarBackground = nil end
    if RadarBorder then pcall(function() RadarBorder:Remove() end); RadarBorder = nil end
    if RadarLocalDot then pcall(function() RadarLocalDot:Remove() end); RadarLocalDot = nil end
end

function ApplySettings()
    hitboxEnabled = settings.hitboxEnabled
    hitboxSize = settings.hitboxSize
    hitboxTransparency = settings.hitboxTransparency

    FlingActive = settings.flingEnabled
    FlingTarget = settings.flingTarget
    TPTarget = settings.tpTarget

    CurrentWalkSpeed = settings.walkSpeed
    InfinityJump = settings.infinityJump
    NoclipActive = settings.noclipEnabled
    FlyActive = settings.flyEnabled
    FlySpeed = settings.flySpeed or 100

    AntiFlingActive = settings.antiFlingEnabled
    MAX_OTHER_VEL = settings.maxOtherVel
    MAX_SELF_VEL = settings.maxSelfVel
    SAVE_POS_THRESHOLD = settings.savePosThreshold

    NameESP = settings.nameESP
    BoxESP = settings.boxESP
    RadarESP = settings.radarESP
    ESPColors.Box = settings.boxColor
    ESPColors.Name = settings.nameColor
    ESPColors.Radar = settings.radarColor

    -- Sync toggle states
    if NoclipToggle then
        NoclipToggle:SetState(NoclipActive)
    end
    if FlyToggle then
        FlyToggle:SetState(FlyActive)
    end

    -- запускаем системы
    if hitboxEnabled then HitboxConnection = RunService.Stepped:Connect(updateHitboxes) end
    updateHitboxes()

    if NoclipActive then StartNoclip() end
    if FlyActive then StartFlying() end
    if AntiFlingActive then StartAntiFling() end

    if NameESP then UpdateAllESP() end
    if BoxESP then StartBoxESP() end
    if RadarESP then StartRadarESP() end
	Notification.new("success", "Auto-Inject", "Сохраненные настройки загружены!", true, 3)
end


function CreateRadarDot(player)
    local dot = Drawing.new("Circle")
    dot.Visible = false
    dot.Color = ESPColors.Radar
    dot.Radius = 3
    dot.Filled = true
    dot.Thickness = 1

    RadarPlayerDots[player] = dot
end

function UpdateRadarDotPosition(player, dot)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        dot.Visible = false
        return
    end

    local char = Player.Character
    if char and char.PrimaryPart then
        local function GetRelative(pos)
            local pmpart = char.PrimaryPart
            local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
            local newcf = CFrame.new(pmpart.Position, camerapos)
            local r = newcf:PointToObjectSpace(pos)
            return r.X, r.Z
        end

        local relx, rely = GetRelative(character.HumanoidRootPart.Position)
        local scale = 2
        local radarCenter = Vector2.new(200, 200)
        local newpos = radarCenter - Vector2.new(relx * scale, rely * scale)

        if (newpos - radarCenter).magnitude < 78 then
            dot.Position = newpos
            dot.Visible = true
            dot.Radius = 3
        else
            local direction = (newpos - radarCenter).Unit
            local edgePos = radarCenter + direction * 78
            dot.Position = edgePos
            dot.Visible = true
            dot.Radius = 2
        end
    end
end

-- Custom Tab
local CustomTab = Window:Tab("Custom",false)
CustomTab:Label("ESP Colors Customization")

-- Box Color Picker
CustomTab:Colorpicker("Box Color", ESPColors.Box, function(color)
    ESPColors.Box = color
    settings.boxColor = color
    for _, box in pairs(BoxESPObjects) do
        if box then
            for _, line in pairs(box) do
                pcall(function() line.Color = color end)
            end
        end
    end
end)

-- Name Color Picker
CustomTab:Colorpicker("Name Color", ESPColors.Name, function(color)
    ESPColors.Name = color
    settings.nameColor = color
    for _, esp in pairs(ESPPlayers) do
        if esp and esp.TextLabel then
            pcall(function() esp.TextLabel.TextColor3 = color end)
        end
    end
end)

-- Radar Color Picker
CustomTab:Colorpicker("Radar Color", ESPColors.Radar, function(color)
    ESPColors.Radar = color
    settings.radarColor = color
    for _, dot in pairs(RadarPlayerDots) do
        if dot then pcall(function() dot.Color = color end) end
    end
end)

-- Settings Tab
local SettingsTab = Window:Tab("Settings",false)
SettingsTab:Label("UI & Keybinds")

-- Keybinds now receive 'key' and save it into settings
SettingsTab:Keybind("Toggle UI",settings.toggleUIKey,function(key)
    if key then
        settings.toggleUIKey = key
        -- metatable saves
        Notification.new("info", "NanoLuxHub", "Toggle UI привязан к: " .. tostring(key), true, 3)
    end
    Library:Toggle()
    UIToggled = not UIToggled
    if UIToggled then
        Notification.new("info", "NanoLuxHub", "Скрипт свёрнут. Для разворачивания нажмите " .. tostring(settings.toggleUIKey), true, 5)
    else
        Notification.new("success", "NanoLuxHub", "Скрипт развёрнут", true, 3)
    end
end)

SettingsTab:Keybind("Noclip Keybind",settings.noclipKey,function(key)
    if key then
        settings.noclipKey = key
    end
    NoclipActive = not NoclipActive
    settings.noclipEnabled = NoclipActive
    -- Sync toggle state
    if NoclipToggle then
        NoclipToggle:SetState(NoclipActive)
    end
    if NoclipActive then
        StartNoclip()
        Notification.new("success", "Noclip", "Noclip включен", true, 3)
    else
        StopNoclip()
        Notification.new("info", "Noclip", "Noclip выключен", true, 3)
    end
end)

SettingsTab:Keybind("Fly Keybind",settings.flyKey,function(key)
    if key then
        settings.flyKey = key
    end
    FlyActive = not FlyActive
    settings.flyEnabled = FlyActive
    -- Sync toggle state
    if FlyToggle then
        FlyToggle:SetState(FlyActive)
    end
    if FlyActive then
        StartFlying()
        Notification.new("success", "Fly", "Полёт включен", true, 3)
    else
        StopFlying()
        Notification.new("info", "Fly", "Полёт выключен", true, 3)
    end
end)

-- Кнопка для ручного сохранения настроек
SettingsTab:Button("Save Settings Now", function()
    if SaveSettings() then
        Notification.new("success", "Settings", "Настройки сохранены!", true, 3)
    else
        Notification.new("error", "Settings", "Ошибка сохранения настроек!", true, 3)
    end
end)

SettingsTab:Button("Load Settings Now", function()
    if LoadSettings() then
        Notification.new("success", "Settings", "Настройки загружены!", true, 3)
        
        -- Применяем загруженные настройки
        hitboxEnabled = settings.hitboxEnabled
        hitboxSize = settings.hitboxSize
        hitboxTransparency = settings.hitboxTransparency
        FlingActive = settings.flingEnabled
        FlingTarget = settings.flingTarget
        TPTarget = settings.tpTarget
        CurrentWalkSpeed = settings.walkSpeed
        InfinityJump = settings.infinityJump
        NoclipActive = settings.noclipEnabled
        FlyActive = settings.flyEnabled
        FlySpeed = settings.flySpeed or 100
        AntiFlingActive = settings.antiFlingEnabled
        MAX_OTHER_VEL = settings.maxOtherVel
        MAX_SELF_VEL = settings.maxSelfVel
        SAVE_POS_THRESHOLD = settings.savePosThreshold
        NameESP = settings.nameESP
        BoxESP = settings.boxESP
        RadarESP = settings.radarESP
        ESPColors.Box = settings.boxColor
        ESPColors.Name = settings.nameColor
        ESPColors.Radar = settings.radarColor
        
        -- Sync toggle states when loading settings
        if NoclipToggle then
            NoclipToggle:SetState(NoclipActive)
        end
        if FlyToggle then
            FlyToggle:SetState(FlyActive)
        end
        
        -- Обновляем визуальные элементы
        updateHitboxes()
        UpdateAllESP()
        
        -- Restart systems if needed
        if NoclipActive then StartNoclip() else StopNoclip() end
        if FlyActive then StartFlying() else StopFlying() end
        if AntiFlingActive then StartAntiFling() else StopAntiFling() end
        if BoxESP then StartBoxESP() else StopBoxESP() end
        if RadarESP then StartRadarESP() else StopRadarESP() end
        
    else
        Notification.new("error", "Settings", "Ошибка загрузки настроек!", true, 3)
    end
end)

SettingsTab:Button("Reset All Settings", function()
    settings = {
        hitboxEnabled = false,
        hitboxSize = 20,
        hitboxTransparency = 0,
        flingEnabled = false,
        flingTarget = nil,
        tpTarget = nil,
        walkSpeed = 16,
        infinityJump = false,
        noclipEnabled = false,
        flyEnabled = false,
        antiFlingEnabled = false,
        maxOtherVel = 100,
        maxSelfVel = 250,
        savePosThreshold = 40,
        nameESP = false,
        boxESP = false,
        radarESP = false,
        boxColor = Color3.new(1, 0, 0),
        nameColor = Color3.new(1, 1, 1),
        radarColor = Color3.new(0, 1, 1),
        toggleUIKey = Enum.KeyCode.LeftControl,
        noclipKey = Enum.KeyCode.N,
        flyKey = Enum.KeyCode.F
    }
    
    -- reapply metatable so autosave continues working
    setmetatable(settings, settings_mt)
    SaveSettings()
    Notification.new("info", "Settings", "Все настройки сброшены!", true, 3)
end)

-- Player tracking and updates with improved character handling
local function setupPlayerESP(player)
    if player == Player then return end
    
    local function setupCharacter(char)
        if char then
            task.wait(0.5) -- Wait for character to fully load
            UpdatePlayerESP(player)
            if BoxESP and not BoxESPObjects[player] then
                local lines = {
                    Top = Drawing.new("Line"),
                    Bottom = Drawing.new("Line"),
                    Left = Drawing.new("Line"),
                    Right = Drawing.new("Line")
                }
                for _, line in pairs(lines) do
                    line.Visible = false
                    line.Color = ESPColors.Box
                    line.Thickness = 2
                end
                BoxESPObjects[player] = lines
            end
            if RadarESP and not RadarPlayerDots[player] then
                CreateRadarDot(player)
            end
        end
    end
    
    -- Setup for existing character
    if player.Character then
        setupCharacter(player.Character)
    end
    
    -- Setup for new characters
    player.CharacterAdded:Connect(function(char)
        setupCharacter(char)
    end)
    
    -- Clean up when character is removed
    player.CharacterRemoving:Connect(function()
        CleanupPlayerESP(player)
        if BoxESPObjects[player] then
            for _, line in pairs(BoxESPObjects[player]) do
                pcall(function() line:Remove() end)
            end
            BoxESPObjects[player] = nil
        end
        if RadarPlayerDots[player] then
            pcall(function() RadarPlayerDots[player]:Remove() end)
            RadarPlayerDots[player] = nil
        end
    end)
end

-- Handle local player character changes
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateAllESP()
end)

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    UpdatePlayerList()
    setupPlayerESP(player)
    SetupAntiFlingPlayer(player)
    Notification.new("info", "Player Joined", player.Name .. " присоединился к игре", true, 3)
end)

Players.PlayerRemoving:Connect(function(player)
    UpdatePlayerList()
    CleanupPlayerESP(player)
    if BoxESPObjects[player] then
        for _, line in pairs(BoxESPObjects[player]) do
            pcall(function() line:Remove() end)
        end
        BoxESPObjects[player] = nil
    end
    if RadarPlayerDots[player] then
        pcall(function() RadarPlayerDots[player]:Remove() end)
        RadarPlayerDots[player] = nil
    end
    PlayerData[player] = nil
    Notification.new("info", "Player Left", player.Name .. " покинул игру", true, 3)
end)

-- Initial setup
spawn(function()
    task.wait(2)
    UpdatePlayerList()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            setupPlayerESP(player)
            SetupAntiFlingPlayer(player)
        end
    end
    
    -- Apply initial settings
    if settings.hitboxEnabled then
        HitboxConnection = RunService.Stepped:Connect(updateHitboxes)
    end
    if settings.noclipEnabled then
        StartNoclip()
    end
    if settings.flyEnabled then
        StartFlying()
    end
    if settings.antiFlingEnabled then
        StartAntiFling()
    end
    if settings.nameESP then
        UpdateAllESP()
    end
    if settings.boxESP then
        StartBoxESP()
    end
    if settings.radarESP then
        StartRadarESP()
    end
end)

-- Auto-refresh player lists every 3 seconds
spawn(function()
    while true do
        task.wait(3)
        UpdatePlayerList()
    end
end)

-- Auto-refresh ESP every 5 seconds to handle character changes
spawn(function()
    while true do
        task.wait(5)
        if NameESP then
            UpdateAllESP()
        end
    end
end)

-- Full Script Unload Function
local function UnloadScript()
    -- Save settings before unloading
    SaveSettings()
    
    -- Stop all active features
    if HitboxConnection then
        HitboxConnection:Disconnect()
        HitboxConnection = nil
    end
    
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    
    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end
    
    if AntiFlingConnection then
        AntiFlingConnection:Disconnect()
        AntiFlingConnection = nil
    end
    
    if AimTargetConnection then
        AimTargetConnection:Disconnect()
        AimTargetConnection = nil
    end
    if AimTargetBodyPosition then
        AimTargetBodyPosition:Destroy()
        AimTargetBodyPosition = nil
    end
    
    -- Stop Fling
    StopFling()
    
    -- Stop ESP
    StopBoxESP()
    StopRadarESP()
    for _, esp in pairs(ESPPlayers) do
        if esp then
            esp:Destroy()
        end
    end
    ESPPlayers = {}
    
    -- Clean up hitbox parts
    for _, part in pairs(hitboxParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    hitboxParts = {}
    
    -- Reset player speed
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
    
    -- Reset hitboxes
    updateHitboxes()
    
    -- Reset noclip
    if Player.Character then
        for _, part in pairs(Player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    -- Destroy UI
    pcall(function()
        -- Find and destroy the ScreenGui
        for _, gui in pairs(game.CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui:FindFirstChild("Main") then
                gui:Destroy()
                break
            end
        end
    end)
    
    -- Clear all variables
    FlingActive = false
    NoclipActive = false
    FlyActive = false
    AimTargetActive = false
    hitboxEnabled = false
    
    Notification.new("info", "NanoLuxHub", "Скрипт полностью выгружен", true, 3)
    
    -- Wait a bit for notification to show, then clear script
    task.wait(1)
    
    -- Clear script from memory
    for i, v in pairs(getgenv()) do
        if type(v) == "function" and debug.getinfo(v).source:find("NanoLuxScript") then
            getgenv()[i] = nil
        end
    end
end

-- Кнопка закрыть вызывает анхук через callback в библиотеке
if Library and Library._onCloseCallback == nil then
    Library._onCloseCallback = UnloadScript
end

-- Cleanup on script termination
game:GetService("UserInputService").WindowFocused:Connect(function()
    SaveSettings()
end)

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
    SaveSettings()
end)

Notification.new("success", "NanoLuxHub", "Auto-Inject system loaded! Settings will persist through teleports.", true, 5)
