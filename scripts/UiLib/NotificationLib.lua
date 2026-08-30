-- ============================================================
-- Notification.lua — пересобранный визуал в стиле Apple
-- (тёмное стекло / translucency / squircle-бейджи / мягкие твины)
--
-- ВАЖНО: публичный API и внутренняя структура имён инстансов
-- полностью сохранены. Все методы и сигнатуры как в оригинале:
--   Notification.new(notifType, heading, body, autoRemove, autoRemoveTime, callback)
--   Notification:changeHeading(newHeading)
--   Notification:changeBody(newBody)
--   Notification:deleteTimeout(timeout)
--   Notification:delete()
--   Notification:changeColor(primary, secondary, textColor)
-- Типы: "error", "info", "message", "success", "warning"
-- ============================================================

local Notification = {}
Notification.__index = Notification

local ts = game:GetService("TweenService")
local ss = game:GetService("SoundService")
local txtS = game:GetService("TextService")

-- ============================================================
-- Дизайн-константы (Apple-style токены)
-- ============================================================
local NOTIF_WIDTH    = 340
local NOTIF_HEIGHT   = 72
local NOTIF_PADDING  = 10
local HOLDER_MARGIN  = 14
local CARD_RADIUS    = 14

local CARD_COLOR     = Color3.fromRGB(28, 28, 32)   -- тёмная стеклянная карточка
local HEADING_COLOR  = Color3.fromRGB(242, 242, 247) -- iOS label color
local BODY_COLOR     = Color3.fromRGB(199, 199, 204) -- iOS secondary label
local GLYPH_COLOR    = Color3.fromRGB(255, 255, 255) -- белый глиф на бейдже
local CLOSE_COLOR    = Color3.fromRGB(235, 235, 240)

-- Системные цвета iOS/macOS (dark-mode палитра)
local IOS_RED        = Color3.fromRGB(255, 69, 58)   -- systemRed
local IOS_BLUE       = Color3.fromRGB(10, 132, 255)  -- systemBlue
local IOS_GREEN      = Color3.fromRGB(48, 209, 88)   -- systemGreen
local IOS_YELLOW     = Color3.fromRGB(255, 214, 10)  -- systemYellow
local IOS_GRAY       = Color3.fromRGB(142, 142, 147) -- systemGray

local SHADOW_IMAGE   = "rbxassetid://1316045217"     -- классическая мягкая тень
local CLOSE_ICON     = "rbxassetid://9127564477"     -- тот же X, что и раньше

-- Тайминги анимаций (бархатный Quint вместо резкого Quad)
local OPEN_TWEEN     = TweenInfo.new(0.5,  Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CLOSE_TWEEN    = TweenInfo.new(0.3,  Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local HOVER_TWEEN    = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)

-- ============================================================
-- Основной GUI (имя и поведение — как в оригинале)
-- ============================================================
local notifications = Instance.new("ScreenGui")
notifications.Name = "JxereasNotifications"
notifications.Parent = game:GetService("CoreGui")
notifications.ZIndexBehavior = Enum.ZIndexBehavior.Global
notifications.ResetOnSpawn = false

-- Контейнер для уведомлений
local notifsHolderFrame = Instance.new("Frame")
notifsHolderFrame.Name = "notifsHolderFrame"
notifsHolderFrame.Parent = notifications
notifsHolderFrame.AnchorPoint = Vector2.new(1, 1)
notifsHolderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notifsHolderFrame.BackgroundTransparency = 1
notifsHolderFrame.BorderSizePixel = 0
notifsHolderFrame.ClipsDescendants = true
notifsHolderFrame.Position = UDim2.new(1, -HOLDER_MARGIN, 1, -HOLDER_MARGIN)
notifsHolderFrame.Size = UDim2.new(0, NOTIF_WIDTH, 0.5, 0)

-- Layout для уведомлений
local notifHolderListLayout = Instance.new("UIListLayout")
notifHolderListLayout.Name = "notifHolderListLayout"
notifHolderListLayout.Parent = notifsHolderFrame
notifHolderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifHolderListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifHolderListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifHolderListLayout.Padding = UDim.new(0, NOTIF_PADDING)

-- ============================================================
-- Функция для создания шаблона уведомления
-- Сигнатура и имена инстансов сохранены 1-в-1,
-- изменён только визуальный слой.
-- ============================================================
local function createNotificationTemplate(name, bgColor, severityColor, icon, defaultHeading)
    local template = Instance.new("Frame")
    template.Name = name
    template.AnchorPoint = Vector2.new(1, 1)
    template.BackgroundColor3 = bgColor
    template.BorderSizePixel = 0
    template.BackgroundTransparency = 1
    template.Size = UDim2.new(1, 0, 0, NOTIF_HEIGHT)

    -- ---------- Карточка (тёмное стекло) ----------
    local templateFrame = Instance.new("Frame")
    templateFrame.Name = "templateFrame"
    templateFrame.Parent = template
    templateFrame.BackgroundColor3 = bgColor
    templateFrame.BackgroundTransparency = 0.06 -- лёгкая прозрачность = frosted glass
    templateFrame.BorderSizePixel = 0
    templateFrame.Size = UDim2.new(1, 0, 1, 0)
    templateFrame.ZIndex = 1

    local templateCorner = Instance.new("UICorner")
    templateCorner.Name = "templateCorner"
    templateCorner.Parent = templateFrame
    templateCorner.CornerRadius = UDim.new(0, CARD_RADIUS)

    -- Стеклянный блик: сверху светлее, снизу темнее
    local glassGradient = Instance.new("UIGradient")
    glassGradient.Name = "glassGradient"
    glassGradient.Rotation = 90
    glassGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 198, 208)),
    })
    glassGradient.Parent = templateFrame

    -- Тонкая стеклянная обводка по контуру
    local glassStroke = Instance.new("UIStroke")
    glassStroke.Name = "glassStroke"
    glassStroke.Color = Color3.fromRGB(255, 255, 255)
    glassStroke.Transparency = 0.86
    glassStroke.Thickness = 1
    glassStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glassStroke.Parent = templateFrame

    -- ---------- Иконка (просто картинка, без бейджа и тени) ----------
    if icon then
        -- Тёмная подложка для обводки (слегка увеличена)
        local iconOutline = Instance.new("ImageLabel")
        iconOutline.Name = "iconOutline"
        iconOutline.Parent = templateFrame
        iconOutline.AnchorPoint = Vector2.new(0, 0.5)
        iconOutline.BackgroundTransparency = 1
        iconOutline.Position = UDim2.new(0, 15, 0.5, 0) -- Центрируем
        iconOutline.Size = UDim2.new(0, 30, 0, 30)      -- Размер больше (30 вместо 26) для канта
        iconOutline.Image = icon
        iconOutline.ImageColor3 = Color3.fromRGB(0, 0, 0) -- Чёрный цвет
        iconOutline.ImageTransparency = 0.55              -- Прозрачность (регулируй плотность обводки)
        iconOutline.ZIndex = 0                            -- Позади

        -- Основная белая иконка
        local image = Instance.new("ImageLabel")
        image.Name = "image"
        image.Parent = templateFrame
        image.AnchorPoint = Vector2.new(0, 0.5)
        image.BackgroundTransparency = 1
        image.Position = UDim2.new(0, 15, 0.5, 0) -- То же место
        image.Size = UDim2.new(0, 26, 0, 26)      -- Обычный размер
        image.Image = icon
        image.ImageColor3 = GLYPH_COLOR           -- Белая иконка
        image.ZIndex = 1                          -- Сверху
    end

    -- ---------- Область с текстом ----------
    local informationFrame = Instance.new("Frame")
    informationFrame.Name = "informationFrame"
    informationFrame.Parent = templateFrame
    informationFrame.BackgroundTransparency = 1
    informationFrame.Position = UDim2.new(0, icon and 50 or 16, 0, 0)
    informationFrame.Size = UDim2.new(1, icon and -86 or -52, 1, 0)

    local headingText = Instance.new("TextLabel")
    headingText.Name = "headingText"
    headingText.Parent = informationFrame
    headingText.BackgroundTransparency = 1
    headingText.Position = UDim2.new(0, 0, 0, 13)
    headingText.Size = UDim2.new(1, 0, 0, 18)
    headingText.Font = Enum.Font.GothamBold
    headingText.Text = defaultHeading
    headingText.TextColor3 = HEADING_COLOR
    headingText.TextSize = 13
    headingText.TextXAlignment = Enum.TextXAlignment.Left
    headingText.TextYAlignment = Enum.TextYAlignment.Bottom
    headingText.TextTruncate = Enum.TextTruncate.AtEnd
    headingText.ClipsDescendants = true

    local bodyText = Instance.new("TextLabel")
    bodyText.Name = "bodyText"
    bodyText.Parent = informationFrame
    bodyText.BackgroundTransparency = 1
    bodyText.Position = UDim2.new(0, 0, 0, 32)
    bodyText.Size = UDim2.new(1, 0, 0, 28)
    bodyText.Font = Enum.Font.Gotham
    bodyText.Text = "Текст уведомления"
    bodyText.TextColor3 = BODY_COLOR
    bodyText.TextSize = 12
    bodyText.TextWrapped = true
    bodyText.TextXAlignment = Enum.TextXAlignment.Left
    bodyText.TextYAlignment = Enum.TextYAlignment.Top
    bodyText.TextTruncate = Enum.TextTruncate.AtEnd
    bodyText.ClipsDescendants = true

    -- ---------- Кнопка закрытия (без лишних hover-анимаций) ----------
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "closeButton"
    closeButton.Parent = templateFrame
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 0.92
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -10, 0, 10)
    closeButton.Size = UDim2.new(0, 18, 0, 18)
    closeButton.Image = CLOSE_ICON
    closeButton.ImageColor3 = CLOSE_COLOR
    closeButton.ImageTransparency = 0.35
    closeButton.ScaleType = Enum.ScaleType.Fit

    local closeCorner = Instance.new("UICorner")
    closeCorner.Name = "closeCorner"
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(1, 0)

    -- Инстанс сохранён для совместимости changeColor() (невидимый)
    local cornerHidingFrame = Instance.new("Frame")
    cornerHidingFrame.Name = "cornerHidingFrame"
    cornerHidingFrame.Parent = templateFrame
    cornerHidingFrame.AnchorPoint = Vector2.new(1, 0)
    cornerHidingFrame.BackgroundColor3 = bgColor
    cornerHidingFrame.BackgroundTransparency = 1
    cornerHidingFrame.BorderSizePixel = 0
    cornerHidingFrame.Position = UDim2.new(1, 0, 0, 0)
    cornerHidingFrame.Size = UDim2.new(0.1, 0, 1, 0)
    cornerHidingFrame.ZIndex = 0

    -- ---------- Тонкий прогресс-бар автоудаления (внизу карточки) ----------
    local progressBar = Instance.new("Frame")
    progressBar.Name = "progressBar"
    progressBar.Parent = templateFrame
    progressBar.AnchorPoint = Vector2.new(0, 1)
    progressBar.BackgroundColor3 = severityColor
    progressBar.BackgroundTransparency = 0.35
    progressBar.BorderSizePixel = 0
    progressBar.Position = UDim2.new(0, 16, 1, -5)
    progressBar.Size = UDim2.new(1, -32, 0, 3)
    progressBar.Visible = false

    local progressCorner = Instance.new("UICorner")
    progressCorner.Name = "progressCorner"
    progressCorner.Parent = progressBar
    progressCorner.CornerRadius = UDim.new(1, 0)

    return template
end

-- ============================================================
-- Шаблоны уведомлений — iOS системные цвета
-- ============================================================
local errorTemplate = createNotificationTemplate(
    "error",
    CARD_COLOR,
    IOS_RED,
    "rbxassetid://9072920609",
    "Ошибка"
)

local infoTemplate = createNotificationTemplate(
    "info",
    CARD_COLOR,
    IOS_BLUE,
    "rbxassetid://9072944922",
    "Информация"
)

local successTemplate = createNotificationTemplate(
    "success",
    CARD_COLOR,
    IOS_GREEN,
    "rbxassetid://9073052584",
    "Успех"
)

local warningTemplate = createNotificationTemplate(
    "warning",
    CARD_COLOR,
    IOS_YELLOW,
    "rbxassetid://9072448788",
    "Предупреждение"
)

local messageTemplate = createNotificationTemplate(
    "message",
    CARD_COLOR,
    IOS_GRAY,
    nil,
    "Сообщение"
)

-- ============================================================
-- Функции для управления уведомлениями (логика без изменений)
-- ============================================================
local function scaleNotifHolderMaxNotifs()
    local holderHeight = notifsHolderFrame.AbsoluteSize.Y
    local notifHeight = NOTIF_HEIGHT
    local padding = notifHolderListLayout.Padding.Offset

    local maxNotifs = math.floor(holderHeight / (notifHeight + padding))
    if maxNotifs < 1 then maxNotifs = 1 end

    local totalHeight = (notifHeight * maxNotifs) + (padding * (maxNotifs - 1))
    notifsHolderFrame.Size = UDim2.new(0, NOTIF_WIDTH, 0, totalHeight)
end

local function deleteNotifsOutsideFrame()
    local contentHeight = notifHolderListLayout.AbsoluteContentSize.Y
    local frameHeight = notifsHolderFrame.AbsoluteSize.Y

    if contentHeight <= frameHeight then return end

    local overflow = contentHeight - frameHeight
    local notifHeight = NOTIF_HEIGHT + notifHolderListLayout.Padding.Offset

    local notifsToRemove = math.ceil(overflow / notifHeight)

    for i = 1, notifsToRemove do
        local oldestNotif = notifsHolderFrame:FindFirstChildOfClass("Frame")
        if oldestNotif then
            oldestNotif:Destroy()
        else
            break
        end
    end
end

-- ============================================================
-- Основная функция создания уведомления (сигнатура без изменений)
-- ============================================================
function Notification.new(notifType, heading, body, autoRemove, autoRemoveTime, callback)
    local notificationTypes = {
        error = errorTemplate,
        info = infoTemplate,
        message = messageTemplate,
        success = successTemplate,
        warning = warningTemplate
    }

    local template = notificationTypes[notifType:lower()]
    if not template then
        error("Неверный тип уведомления. Доступные: error, info, message, success, warning")
    end

    local notif = template:Clone()
    notif.templateFrame.Position = UDim2.new(1, 0, 0, 0)
    notif.LayoutOrder = tick()

    -- Устанавливаем текст
    notif.templateFrame.informationFrame.headingText.Text = heading or "Уведомление"
    notif.templateFrame.informationFrame.bodyText.Text = body or ""

    -- Функция открытия уведомления (плавный заезд справа, Quint-Out)
    local function openNotif()
        ts:Create(notif.templateFrame, OPEN_TWEEN, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end

    -- Функция закрытия уведомления (с защитой от зависания, как в оригинале)
    local function closeNotif()
        if not notif or not notif.Parent or not notif.templateFrame or not notif.templateFrame.Parent then
            return
        end
        local frame = notif.templateFrame
        -- Анимация скрытия, но не блокируем поток (горячая защита от зависания,
        -- если GUI будет уничтожен посреди твина).
        local finished = false
        local closeTween = ts:Create(frame, CLOSE_TWEEN, {Position = UDim2.new(1, 0, 0, 0)})
        closeTween.Completed:Connect(function()
            finished = true
        end)
        closeTween:Play()

        task.spawn(function()
            local waited = 0
            while not finished and waited < 1 do
                task.wait(0.05)
                waited = waited + 0.05
            end
            if callback and type(callback) == "function" then
                pcall(callback)
            end
            pcall(function()
                if notif and notif.Parent then
                    notif:Destroy()
                end
            end)
        end)
    end

    -- Обработчик кнопки закрытия
    notif.templateFrame.closeButton.MouseButton1Click:Connect(function()
        closeNotif()
    end)

    -- УБРАНО: все hover-анимации для кнопки закрытия (просто статичная кнопка)

    -- Добавляем в контейнер и анимируем
    notif.Parent = notifsHolderFrame
    openNotif()

    -- Автоудаление (+ прогресс-бар обратного отсчёта)
    if autoRemove then
        autoRemoveTime = autoRemoveTime or 5

        local progressBar = notif.templateFrame:FindFirstChild("progressBar")
        if progressBar then
            progressBar.Visible = true
            progressBar.Size = UDim2.new(1, -32, 0, 3)
            ts:Create(progressBar, TweenInfo.new(autoRemoveTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 3)}):Play()
        end

        task.delay(autoRemoveTime, function()
            if notif and notif.Parent then
                closeNotif()
            end
        end)
    end

    -- Создаем объект уведомления
    local notificationObj = setmetatable({}, Notification)
    notificationObj.Instance = notif
    notificationObj._closeFunction = closeNotif

    return notificationObj
end

-- ============================================================
-- Методы для управления уведомлением (без изменений поведения)
-- ============================================================
function Notification:changeHeading(newHeading)
    if self.Instance and self.Instance.Parent then
        self.Instance.templateFrame.informationFrame.headingText.Text = newHeading
    end
end

function Notification:changeBody(newBody)
    if self.Instance and self.Instance.Parent then
        self.Instance.templateFrame.informationFrame.bodyText.Text = newBody
    end
end

function Notification:deleteTimeout(timeout)
    timeout = timeout or 3
    task.delay(timeout, function()
        self:delete()
    end)
end

function Notification:delete()
    if self._closeFunction then
        self._closeFunction()
    end
end

function Notification:changeColor(primary, secondary, textColor)
    if not self.Instance or not self.Instance.Parent then return end

    local templateFrame = self.Instance.templateFrame

    if primary then
        templateFrame.BackgroundColor3 = primary
        templateFrame.cornerHidingFrame.BackgroundColor3 = primary
        templateFrame.severityFrame.hideSeverityCornerFrame.BackgroundColor3 = primary
    end

    if secondary then
        templateFrame.severityFrame.BackgroundColor3 = secondary
        templateFrame.closeButton.ImageColor3 = secondary

        -- прогресс-бар тоже в акцентный цвет
        local progressBar = templateFrame:FindFirstChild("progressBar")
        if progressBar then
            progressBar.BackgroundColor3 = secondary
        end

        -- совместимость со старой структурой (иконка прямо в templateFrame)
        local image = templateFrame:FindFirstChild("image")
        if image and image:IsA("ImageLabel") then
            image.ImageColor3 = GLYPH_COLOR -- всегда белая, без перекрашивания
        end
    end

    if textColor then
        templateFrame.informationFrame.headingText.TextColor3 = textColor
        templateFrame.informationFrame.bodyText.TextColor3 = textColor
    end
end

-- Обработчики изменения размеров
notifsHolderFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(scaleNotifHolderMaxNotifs)
notifHolderListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(deleteNotifsOutsideFrame)

-- Инициализация
scaleNotifHolderMaxNotifs()

return Notification
