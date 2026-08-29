-- ============================================================
--  Jxereas Ultra Notification Library v2.0
--  Красивые, плавные, настраиваемые уведомления для Roblox
-- ============================================================

local Notification = {}
Notification.__index = Notification

-- Сервисы
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Основной GUI (создаётся один раз)
local gui = Instance.new("ScreenGui")
gui.Name = "JxereasUltraNotifications"
gui.Parent = game:GetService("CoreGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- Контейнеры для разных позиций (чтобы не мешали друг другу)
local positions = {
    TopLeft =     { Anchor = Vector2.new(0,0), Pos = UDim2.new(0, 10, 0, 10), Align = "Left", Vertical = "Top" },
    TopCenter =   { Anchor = Vector2.new(0.5,0), Pos = UDim2.new(0.5, 0, 0, 10), Align = "Center", Vertical = "Top" },
    TopRight =    { Anchor = Vector2.new(1,0), Pos = UDim2.new(1, -10, 0, 10), Align = "Right", Vertical = "Top" },
    BottomLeft =  { Anchor = Vector2.new(0,1), Pos = UDim2.new(0, 10, 1, -10), Align = "Left", Vertical = "Bottom" },
    BottomCenter ={ Anchor = Vector2.new(0.5,1), Pos = UDim2.new(0.5, 0, 1, -10), Align = "Center", Vertical = "Bottom" },
    BottomRight = { Anchor = Vector2.new(1,1), Pos = UDim2.new(1, -10, 1, -10), Align = "Right", Vertical = "Bottom" },
}

-- Создаём контейнеры для каждой позиции
local containers = {}
for name, data in pairs(positions) do
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Parent = gui
    frame.AnchorPoint = data.Anchor
    frame.Position = data.Pos
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 340, 0, 0) -- ширина фиксирована, высота динамическая
    frame.ClipsDescendants = false  -- чтобы тени не обрезались

    -- Layout для вертикального расположения
    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.Parent = frame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment[data.Align]
    layout.VerticalAlignment = Enum.VerticalAlignment[data.Vertical]
    layout.Padding = UDim.new(0, 8)

    containers[name] = {
        Frame = frame,
        Layout = layout,
        MaxVisible = 6,  -- максимум уведомлений до удаления старых
        Notifications = {},
    }
end

-- ------------------------------------------------------------
--  Вспомогательные функции для создания элементов
-- ------------------------------------------------------------

local function createShadow(parent, size, color, transparency, blur)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = parent
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = size + UDim2.new(0, blur*2, 0, blur*2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316043073"  -- мягкая тень
    shadow.ImageColor3 = color
    shadow.ImageTransparency = transparency
    shadow.ZIndex = 0
    return shadow
end

local function createProgressBar(parent, color)
    local bar = Instance.new("Frame")
    bar.Name = "ProgressBar"
    bar.Parent = parent
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.Position = UDim2.new(0, 0, 1, -3)
    bar.ZIndex = 2

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = bar

    return bar
end

-- ------------------------------------------------------------
--  Создание шаблона уведомления (с дизайном)
-- ------------------------------------------------------------

local function createNotificationTemplate(name, theme)
    -- theme: { bg, accent, text, icon, sound, heading }
    local template = Instance.new("Frame")
    template.Name = name
    template.BackgroundTransparency = 1
    template.Size = UDim2.new(1, 0, 0, 70)  -- высота
    template.ClipsDescendants = false

    -- Основной фон (с градиентом)
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Parent = template
    main.BackgroundColor3 = theme.bg or Color3.fromRGB(30, 30, 35)
    main.BorderSizePixel = 0
    main.Size = UDim2.new(1, 0, 1, 0)
    main.ZIndex = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main

    -- Градиент фона
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.bg or Color3.fromRGB(30,30,35)),
        ColorSequenceKeypoint.new(1, (theme.bg and theme.bg:Lerp(Color3.new(1,1,1), 0.1)) or Color3.fromRGB(50,50,55))
    }
    gradient.Parent = main

    -- Тень (внешняя)
    local shadow = createShadow(main, UDim2.new(1, 20, 1, 20), Color3.new(0,0,0), 0.4, 12)

    -- Полоска акцента (слева)
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Parent = main
    accent.BackgroundColor3 = theme.accent or Color3.fromRGB(0, 120, 255)
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 6, 1, -10)
    accent.Position = UDim2.new(0, 6, 0, 5)
    accent.ZIndex = 2

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 4)
    accentCorner.Parent = accent

    -- Иконка (если есть)
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = main
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 24, 0.5, -14)
    icon.Image = theme.icon or ""
    icon.ImageColor3 = theme.accent or Color3.fromRGB(0, 120, 255)
    icon.ZIndex = 2

    -- Текстовый блок
    local textBlock = Instance.new("Frame")
    textBlock.Name = "TextBlock"
    textBlock.Parent = main
    textBlock.BackgroundTransparency = 1
    textBlock.Position = UDim2.new(0, theme.icon and 60 or 24, 0, 10)
    textBlock.Size = UDim2.new(1, theme.icon and -100 or -64, 1, -20)
    textBlock.ZIndex = 2

    -- Заголовок
    local heading = Instance.new("TextLabel")
    heading.Name = "Heading"
    heading.Parent = textBlock
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 22)
    heading.Font = Enum.Font.GothamBold
    heading.Text = theme.heading or "Уведомление"
    heading.TextColor3 = theme.text or Color3.fromRGB(255,255,255)
    heading.TextSize = 16
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.TextYAlignment = Enum.TextYAlignment.Bottom
    heading.ClipsDescendants = true

    -- Текст
    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.Parent = textBlock
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, 0, 1, -22)
    body.Position = UDim2.new(0, 0, 0, 22)
    body.Font = Enum.Font.GothamSemibold
    body.Text = "Текст уведомления"
    body.TextColor3 = (theme.text and theme.text:Lerp(Color3.new(1,1,1), 0.3)) or Color3.fromRGB(200,200,200)
    body.TextSize = 13
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.ClipsDescriptors = true

    -- Кнопка закрытия (крестик)
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "Close"
    closeBtn.Parent = main
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -10, 0, 10)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://9127564477"
    closeBtn.ImageColor3 = (theme.text and theme.text:Lerp(Color3.new(1,1,1), 0.5)) or Color3.fromRGB(180,180,180)
    closeBtn.ZIndex = 3

    -- Прогресс-бар (внизу)
    local progress = createProgressBar(main, theme.accent or Color3.fromRGB(0, 120, 255))
    progress.Visible = false  -- показывается только при автоудалении

    return template
end

-- ------------------------------------------------------------
--  Предустановленные темы
-- ------------------------------------------------------------

local themes = {
    error = {
        bg = Color3.fromRGB(45, 25, 30),
        accent = Color3.fromRGB(235, 77, 75),
        text = Color3.fromRGB(255, 230, 230),
        icon = "rbxassetid://9072920609",
        heading = "Ошибка",
        sound = 9127564477, -- звук ошибки (замените на свой)
    },
    info = {
        bg = Color3.fromRGB(25, 35, 55),
        accent = Color3.fromRGB(47, 128, 237),
        text = Color3.fromRGB(230, 240, 255),
        icon = "rbxassetid://9072944922",
        heading = "Информация",
    },
    success = {
        bg = Color3.fromRGB(25, 45, 35),
        accent = Color3.fromRGB(39, 174, 96),
        text = Color3.fromRGB(230, 255, 240),
        icon = "rbxassetid://9073052584",
        heading = "Успех",
    },
    warning = {
        bg = Color3.fromRGB(55, 45, 20),
        accent = Color3.fromRGB(241, 196, 15),
        text = Color3.fromRGB(255, 245, 210),
        icon = "rbxassetid://9072448788",
        heading = "Предупреждение",
    },
    message = {
        bg = Color3.fromRGB(40, 40, 45),
        accent = Color3.fromRGB(150, 150, 160),
        text = Color3.fromRGB(240, 240, 240),
        icon = "",
        heading = "Сообщение",
    },
}

-- ------------------------------------------------------------
--  Основной класс Notification
-- ------------------------------------------------------------

function Notification.new(notifType, heading, body, autoRemove, autoRemoveTime, callback, customPosition, customIcon)
    notifType = notifType:lower()
    local theme = themes[notifType]
    if not theme then
        error("Неизвестный тип уведомления: " .. notifType .. ". Доступны: error, info, success, warning, message")
    end

    -- Определяем позицию (по умолчанию BottomRight)
    local posKey = customPosition or "BottomRight"
    local container = containers[posKey]
    if not container then
        warn("Позиция '" .. posKey .. "' не найдена, используется BottomRight")
        container = containers.BottomRight
    end

    -- Клонируем шаблон
    local template = createNotificationTemplate(notifType, theme)
    local notif = template:Clone()
    notif.LayoutOrder = tick()  -- для очередности

    -- Заменяем иконку, если передана своя
    if customIcon then
        notif.Main.Icon.Image = customIcon
    end

    -- Устанавливаем тексты
    local headingLabel = notif.Main.TextBlock.Heading
    local bodyLabel = notif.Main.TextBlock.Body
    headingLabel.Text = heading or theme.heading or "Уведомление"
    bodyLabel.Text = body or ""

    -- Получаем ссылки
    local main = notif.Main
    local closeBtn = main.Close

    -- Прогресс-бар
    local progress = main.ProgressBar

    -- Флаг, что уведомление активно (для предотвращения двойного закрытия)
    local isAlive = true

    -- Функция закрытия (с анимацией)
    local function closeNotif()
        if not isAlive then return end
        isAlive = false

        -- Анимация исчезновения
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local goals = {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, -10),
            BackgroundTransparency = 1,
        }
        local tween = TweenService:Create(notif, tweenInfo, goals)
        tween:Play()
        tween.Completed:Wait()

        -- Удаляем из контейнера и списка
        pcall(function()
            notif:Destroy()
        end)
        for i, v in ipairs(container.Notifications) do
            if v == notif then
                table.remove(container.Notifications, i)
                break
            end
        end

        -- Вызов колбэка
        if callback and type(callback) == "function" then
            pcall(callback)
        end

        -- Проверяем, не нужно ли освободить место для следующих
        updateContainerHeight(container)
    end

    -- Обработчик кнопки закрытия
    closeBtn.MouseButton1Click:Connect(function()
        closeNotif()
    end)

    -- Добавляем в контейнер
    notif.Parent = container.Frame

    -- Сохраняем в список
    table.insert(container.Notifications, notif)

    -- Анимация появления (масштабирование + сдвиг)
    local startSize = UDim2.new(0.8, 0, 0.8, 0)
    local endSize = UDim2.new(1, 0, 1, 0)
    notif.Size = startSize
    notif.Position = UDim2.new(0, 0, 0, -20)
    notif.BackgroundTransparency = 1

    local appearTween = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = endSize,
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0,
    })
    appearTween:Play()

    -- Автоудаление с прогресс-баром
    if autoRemove then
        autoRemoveTime = autoRemoveTime or 4
        progress.Visible = true
        progress.Size = UDim2.new(1, 0, 0, 3)
        local totalTime = autoRemoveTime

        -- Анимация прогресса
        local progressTween = TweenService:Create(progress, TweenInfo.new(totalTime, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3),
        })
        progressTween:Play()

        task.delay(totalTime, function()
            if isAlive then
                closeNotif()
            end
        end)
    else
        progress.Visible = false
    end

    -- Обновляем высоту контейнера, чтобы вместить все
    updateContainerHeight(container)

    -- Возвращаем объект с методами
    local self = setmetatable({}, Notification)
    self._instance = notif
    self._close = closeNotif
    self._alive = function() return isAlive end
    return self
end

-- ------------------------------------------------------------
--  Методы экземпляра
-- ------------------------------------------------------------

function Notification:changeHeading(newHeading)
    if self._instance and self._instance.Parent then
        self._instance.Main.TextBlock.Heading.Text = newHeading
    end
end

function Notification:changeBody(newBody)
    if self._instance and self._instance.Parent then
        self._instance.Main.TextBlock.Body.Text = newBody
    end
end

function Notification:delete()
    if self._close then
        self._close()
    end
end

function Notification:deleteTimeout(timeout)
    timeout = timeout or 3
    task.delay(timeout, function()
        self:delete()
    end)
end

function Notification:changeTheme(primary, accent, textColor)
    if not self._instance or not self._instance.Parent then return end
    local main = self._instance.Main
    if primary then
        main.BackgroundColor3 = primary
        main.UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, primary),
            ColorSequenceKeypoint.new(1, primary:Lerp(Color3.new(1,1,1), 0.1))
        }
    end
    if accent then
        main.Accent.BackgroundColor3 = accent
        main.Icon.ImageColor3 = accent
        main.ProgressBar.BackgroundColor3 = accent
    end
    if textColor then
        main.TextBlock.Heading.TextColor3 = textColor
        main.TextBlock.Body.TextColor3 = textColor:Lerp(Color3.new(1,1,1), 0.3)
        main.Close.ImageColor3 = textColor:Lerp(Color3.new(1,1,1), 0.5)
    end
end

function Notification:setIcon(iconAsset)
    if self._instance and self._instance.Parent then
        self._instance.Main.Icon.Image = iconAsset
    end
end

-- ------------------------------------------------------------
--  Вспомогательные функции для управления контейнерами
-- ------------------------------------------------------------

local function updateContainerHeight(container)
    local frame = container.Frame
    local layout = container.Layout
    local notifs = container.Notifications

    -- Удаляем старые, если превышен лимит
    while #notifs > container.MaxVisible do
        local oldest = notifs[1]
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
        table.remove(notifs, 1)
    end

    -- Считаем высоту
    local totalHeight = 0
    local padding = layout.Padding.Offset
    for _, notif in ipairs(notifs) do
        if notif.Parent then
            totalHeight = totalHeight + notif.Size.Y.Offset + padding
        end
    end
    if #notifs > 0 then
        totalHeight = totalHeight - padding  -- убираем лишний паддинг после последнего
    end
    frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, totalHeight)
end

-- Подписываемся на изменение размера контейнера (для адаптации)
for _, container in pairs(containers) do
    container.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        updateContainerHeight(container)
    end)
    container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateContainerHeight(container)
    end)
end

-- ------------------------------------------------------------
--  Инициализация (можно добавить глобальные настройки)
-- ------------------------------------------------------------

-- Установка максимального количества уведомлений на позицию
function Notification.setMaxVisible(position, count)
    local container = containers[position]
    if container then
        container.MaxVisible = math.max(1, count)
        updateContainerHeight(container)
    end
end

-- Установка глобальной темы для всех новых уведомлений (можно расширить)

return Notification
