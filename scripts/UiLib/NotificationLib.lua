-- Исправленная библиотека уведомлений
local Notification = {}
Notification.__index = Notification

local ts = game:GetService("TweenService")
local ss = game:GetService("SoundService")
local txtS = game:GetService("TextService")

-- Создаем основной GUI
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
notifsHolderFrame.Position = UDim2.new(1, -10, 1, -10)
notifsHolderFrame.Size = UDim2.new(0.25, 0, 0.3, 0)

-- Layout для уведомлений
local notifHolderListLayout = Instance.new("UIListLayout")
notifHolderListLayout.Name = "notifHolderListLayout"
notifHolderListLayout.Parent = notifsHolderFrame
notifHolderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifHolderListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifHolderListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifHolderListLayout.Padding = UDim.new(0, 4)

-- Функция для создания шаблона уведомления
local function createNotificationTemplate(name, bgColor, severityColor, icon, defaultHeading)
    local template = Instance.new("Frame")
    template.Name = name
    template.AnchorPoint = Vector2.new(1, 1)
    template.BackgroundColor3 = bgColor
    template.BorderSizePixel = 0
    template.BackgroundTransparency = 1
    template.Size = UDim2.new(1, 0, 0, 60)
    
    local templateFrame = Instance.new("Frame")
    templateFrame.Name = "templateFrame"
    templateFrame.Parent = template
    templateFrame.BackgroundColor3 = bgColor
    templateFrame.BorderSizePixel = 0
    templateFrame.Size = UDim2.new(1, 0, 1, 0)
    
    local templateCorner = Instance.new("UICorner")
    templateCorner.Name = "templateCorner"
    templateCorner.Parent = templateFrame
    templateCorner.CornerRadius = UDim.new(0, 6)
    
    -- Полоска severity
    local severityFrame = Instance.new("Frame")
    severityFrame.Name = "severityFrame"
    severityFrame.Parent = templateFrame
    severityFrame.BackgroundColor3 = severityColor
    severityFrame.Size = UDim2.new(0, 6, 1, 0)
    
    local severityCorner = Instance.new("UICorner")
    severityCorner.Name = "severityCorner"
    severityCorner.Parent = severityFrame
    severityCorner.CornerRadius = UDim.new(0, 3)
    
    -- Скрываем правый угол severity полоски
    local hideSeverityCornerFrame = Instance.new("Frame")
    hideSeverityCornerFrame.Name = "hideSeverityCornerFrame"
    hideSeverityCornerFrame.Parent = severityFrame
    hideSeverityCornerFrame.BackgroundColor3 = bgColor
    hideSeverityCornerFrame.BorderSizePixel = 0
    hideSeverityCornerFrame.Position = UDim2.new(0.5, 0, 0, 0)
    hideSeverityCornerFrame.Size = UDim2.new(0.5, 0, 1, 0)
    
    -- Иконка (если есть)
    if icon then
        local image = Instance.new("ImageLabel")
        image.Name = "image"
        image.Parent = templateFrame
        image.AnchorPoint = Vector2.new(0, 0.5)
        image.BackgroundTransparency = 1
        image.Position = UDim2.new(0, 15, 0.5, 0)
        image.Size = UDim2.new(0, 20, 0, 20)
        image.Image = icon
        image.ImageColor3 = severityColor
    end
    
    -- Область с текстом
    local informationFrame = Instance.new("Frame")
    informationFrame.Name = "informationFrame"
    informationFrame.Parent = templateFrame
    informationFrame.BackgroundTransparency = 1
    informationFrame.Position = UDim2.new(0, icon and 45 or 15, 0, 0)
    informationFrame.Size = UDim2.new(1, icon and -70 or -40, 1, 0)
    
    local headingText = Instance.new("TextLabel")
    headingText.Name = "headingText"
    headingText.Parent = informationFrame
    headingText.BackgroundTransparency = 1
    headingText.Size = UDim2.new(1, 0, 0, 25)
    headingText.Font = Enum.Font.GothamBold
    headingText.Text = defaultHeading
    headingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    headingText.TextSize = 14
    headingText.TextXAlignment = Enum.TextXAlignment.Left
    headingText.TextYAlignment = Enum.TextYAlignment.Bottom
    headingText.ClipsDescendants = true
    
    local bodyText = Instance.new("TextLabel")
    bodyText.Name = "bodyText"
    bodyText.Parent = informationFrame
    bodyText.BackgroundTransparency = 1
    bodyText.Position = UDim2.new(0, 0, 0, 25)
    bodyText.Size = UDim2.new(1, 0, 1, -25)
    bodyText.Font = Enum.Font.GothamSemibold
    bodyText.Text = "Текст уведомления"
    bodyText.TextColor3 = Color3.fromRGB(220, 220, 220)
    bodyText.TextSize = 12
    bodyText.TextWrapped = true
    bodyText.TextXAlignment = Enum.TextXAlignment.Left
    bodyText.TextYAlignment = Enum.TextYAlignment.Top
    bodyText.ClipsDescendants = true
    
    -- Кнопка закрытия
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "closeButton"
    closeButton.Parent = templateFrame
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -8, 0.5, 0)
    closeButton.Size = UDim2.new(0, 16, 0, 16)
    closeButton.Image = "rbxassetid://9127564477"
    closeButton.ImageColor3 = severityColor
    
    -- Скрываем правый угол основного фрейма
    local cornerHidingFrame = Instance.new("Frame")
    cornerHidingFrame.Name = "cornerHidingFrame"
    cornerHidingFrame.Parent = templateFrame
    cornerHidingFrame.AnchorPoint = Vector2.new(1, 0)
    cornerHidingFrame.BackgroundColor3 = bgColor
    cornerHidingFrame.BorderSizePixel = 0
    cornerHidingFrame.Position = UDim2.new(1, 0, 0, 0)
    cornerHidingFrame.Size = UDim2.new(0.1, 0, 1, 0)
    cornerHidingFrame.ZIndex = 0
    
    return template
end

-- Ошибка
local errorTemplate = createNotificationTemplate(
    "error", 
    Color3.fromRGB(40, 42, 60), -- Основной фон
    Color3.fromRGB(235, 77, 75)
    "rbxassetid://9072920609",
    "Ошибка"
)

-- Информация
local infoTemplate = createNotificationTemplate(
    "info", 
    Color3.fromRGB(40, 42, 60), -- Основной фон
    Color3.fromRGB(47, 128, 237),
    "rbxassetid://9072944922",
    "Информация"
)

-- Успех
local successTemplate = createNotificationTemplate(
    "success", 
    Color3.fromRGB(40, 42, 60), -- Основной фон
    Color3.fromRGB(39, 174, 96),
    "rbxassetid://9073052584",
    "Успех"
)

-- Предупреждение
local warningTemplate = createNotificationTemplate(
    "warning", 
    Color3.fromRGB(40, 42, 60), -- Основной фон
    Color3.fromRGB(241, 196, 15),
    "rbxassetid://9072448788",
    "Предупреждение"
)

-- Сообщение
local messageTemplate = createNotificationTemplate(
    "message", 
    Color3.fromRGB(40, 42, 60), -- Основной фон
    Color3.fromRGB(120, 120, 120),
    nil,
    "Сообщение"
)

-- Функции для управления уведомлениями
local function scaleNotifHolderMaxNotifs()
    local holderHeight = notifsHolderFrame.AbsoluteSize.Y
    local notifHeight = 60
    local padding = notifHolderListLayout.Padding.Offset
    
    local maxNotifs = math.floor(holderHeight / (notifHeight + padding))
    if maxNotifs < 1 then maxNotifs = 1 end
    
    local totalHeight = (notifHeight * maxNotifs) + (padding * (maxNotifs - 1))
    notifsHolderFrame.Size = UDim2.new(0.25, 0, 0, totalHeight)
end

local function deleteNotifsOutsideFrame()
    local contentHeight = notifHolderListLayout.AbsoluteContentSize.Y
    local frameHeight = notifsHolderFrame.AbsoluteSize.Y
    
    if contentHeight <= frameHeight then return end
    
    local overflow = contentHeight - frameHeight
    local notifHeight = 60 + notifHolderListLayout.Padding.Offset
    
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

-- Основная функция создания уведомления
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
    
    -- Функция открытия уведомления
    local function openNotif()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        ts:Create(notif.templateFrame, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end
    
    -- Функция закрытия уведомления
    local function closeNotif()
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local closeTween = ts:Create(notif.templateFrame, tweenInfo, {Position = UDim2.new(1, 0, 0, 0)})
        
        closeTween:Play()
        closeTween.Completed:Wait()
        
        if callback and type(callback) == "function" then
            pcall(callback)
        end
        
        notif:Destroy()
    end
    
    -- Обработчик кнопки закрытия
    notif.templateFrame.closeButton.MouseButton1Click:Connect(function()
        closeNotif()
    end)
    
    -- Добавляем в контейнер и анимируем
    notif.Parent = notifsHolderFrame
    openNotif()
    
    -- Автоудаление
    if autoRemove then
        autoRemoveTime = autoRemoveTime or 5
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

-- Методы для управления уведомлением
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
        
        if self.Instance:FindFirstChild("image") then
            self.Instance.image.ImageColor3 = secondary
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
