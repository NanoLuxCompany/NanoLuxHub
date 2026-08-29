-- ==============================================================
--            СУПЕР-КРАСИВАЯ СИСТЕМА УВЕДОМЛЕНИЙ
--        Стиль: тёмный, плавный, с анимациями и тенями
-- ==============================================================
local Notification = {}
Notification.__index = Notification

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- Настройки
local CONFIG = {
    Width = 0.3,                 -- ширина относительно экрана (макс.)
    MaxHeight = 0.4,             -- макс. высота контейнера
    Padding = 6,                 -- отступ между уведомлениями
    NotifHeight = 70,            -- высота одного уведомления
    CornerRadius = 8,
    ShowDuration = 5,            -- автоудаление через N сек (если nil - бесконечно)
    SoundEnabled = true,         -- звук при появлении
    SoundId = "rbxassetid://9120364228", -- приятный "пуф"
    Position = "BottomRight",    -- можно также "TopRight", "BottomLeft", "TopLeft"
}

-- Создаём ScreenGui для уведомлений
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "JxereasNotifications"
NotifGui.Parent = game:GetService("CoreGui")
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Контейнер (родитель для всех уведомлений)
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = NotifGui
Container.BackgroundTransparency = 1
Container.ClipsDescendants = false
Container.Size = UDim2.new(CONFIG.Width, 0, 0, 0)

-- Позиционируем контейнер в зависимости от настройки
local function setContainerPosition()
    if CONFIG.Position == "BottomRight" then
        Container.AnchorPoint = Vector2.new(1, 1)
        Container.Position = UDim2.new(1, -15, 1, -15)
    elseif CONFIG.Position == "TopRight" then
        Container.AnchorPoint = Vector2.new(1, 0)
        Container.Position = UDim2.new(1, -15, 0, 15)
    elseif CONFIG.Position == "BottomLeft" then
        Container.AnchorPoint = Vector2.new(0, 1)
        Container.Position = UDim2.new(0, 15, 1, -15)
    elseif CONFIG.Position == "TopLeft" then
        Container.AnchorPoint = Vector2.new(0, 0)
        Container.Position = UDim2.new(0, 15, 0, 15)
    end
end
setContainerPosition()

-- Layout для вертикального расположения
local Layout = Instance.new("UIListLayout")
Layout.Name = "Layout"
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
Layout.Padding = UDim.new(0, CONFIG.Padding)

-- Ограничение количества уведомлений по высоте
local function trimExcess()
    local contentHeight = Layout.AbsoluteContentSize.Y
    local maxHeight = Container.AbsoluteSize.Y
    if contentHeight <= maxHeight then return end

    local overflow = contentHeight - maxHeight
    local notifHeight = CONFIG.NotifHeight + CONFIG.Padding
    local toRemove = math.ceil(overflow / notifHeight)

    for i = 1, toRemove do
        local oldest = Container:FindFirstChildOfClass("Frame")
        if oldest then
            oldest:Destroy()
        else
            break
        end
    end
end

Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    local maxHeight = CONFIG.MaxHeight * workspace.CurrentCamera.ViewportSize.Y
    Container.Size = UDim2.new(CONFIG.Width, 0, 0, math.min(maxHeight, Container.AbsoluteSize.Y))
end)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(trimExcess)

-- Звук (создаём один раз)
local NotificationSound = Instance.new("Sound")
NotificationSound.Name = "NotificationSound"
NotificationSound.Parent = SoundService
NotificationSound.SoundId = CONFIG.SoundId
NotificationSound.Volume = 0.3

-- ========== Фабрика создания шаблона уведомления ==========
local function createNotificationTemplate(notifType)
    local colors = {
        info    = { bg = Color3.fromRGB(44, 47, 68), accent = Color3.fromRGB(55, 74, 251), icon = "rbxassetid://9072944922" },
        success = { bg = Color3.fromRGB(44, 68, 60), accent = Color3.fromRGB(39, 174, 96), icon = "rbxassetid://9073052584" },
        warning = { bg = Color3.fromRGB(68, 64, 44), accent = Color3.fromRGB(241, 196, 15), icon = "rbxassetid://9072448788" },
        error   = { bg = Color3.fromRGB(68, 44, 44), accent = Color3.fromRGB(235, 77, 75), icon = "rbxassetid://9072920609" },
        message = { bg = Color3.fromRGB(48, 48, 58), accent = Color3.fromRGB(160, 160, 180), icon = nil },
    }
    local c = colors[notifType] or colors.message

    -- Основной фрейм
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = c.bg
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, CONFIG.NotifHeight)
    frame.ClipsDescendants = true

    -- Тень (UIStroke + Shadow)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
    corner.Parent = frame

    -- Акцентная полоса слева
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Parent = frame
    accent.BackgroundColor3 = c.accent
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 6, 1, 0)

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 3)
    accentCorner.Parent = accent

    -- Скрываем правый угол полосы (чтобы был скруглён только левый край)
    local hideRight = Instance.new("Frame")
    hideRight.Name = "HideRight"
    hideRight.Parent = accent
    hideRight.BackgroundColor3 = c.bg
    hideRight.BorderSizePixel = 0
    hideRight.Position = UDim2.new(0.5, 0, 0, 0)
    hideRight.Size = UDim2.new(0.5, 0, 1, 0)

    -- Иконка (если есть)
    local iconLabel
    if c.icon then
        iconLabel = Instance.new("ImageLabel")
        iconLabel.Name = "Icon"
        iconLabel.Parent = frame
        iconLabel.BackgroundTransparency = 1
        iconLabel.Position = UDim2.new(0, 16, 0.5, -12)
        iconLabel.Size = UDim2.new(0, 24, 0, 24)
        iconLabel.Image = c.icon
        iconLabel.ImageColor3 = c.accent
        iconLabel.ZIndex = 2
    end

    -- Контейнер для текста
    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Parent = frame
    textContainer.BackgroundTransparency = 1
    textContainer.Position = UDim2.new(0, iconLabel and 52 or 16, 0, 6)
    textContainer.Size = UDim2.new(1, iconLabel and -90 or -50, 1, -12)

    -- Заголовок
    local heading = Instance.new("TextLabel")
    heading.Name = "Heading"
    heading.Parent = textContainer
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 26)
    heading.Font = Enum.Font.GothamBold
    heading.Text = "Заголовок"
    heading.TextColor3 = Color3.fromRGB(255, 255, 255)
    heading.TextSize = 16
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.TextYAlignment = Enum.TextYAlignment.Bottom
    heading.ClipsDescendants = true

    -- Тело
    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.Parent = textContainer
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 0, 0, 26)
    body.Size = UDim2.new(1, 0, 1, -26)
    body.Font = Enum.Font.Gotham
    body.Text = "Текст уведомления"
    body.TextColor3 = Color3.fromRGB(200, 200, 210)
    body.TextSize = 13
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.ClipsDescendants = true

    -- Кнопка закрытия (крестик)
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Parent = frame
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Image = "rbxassetid://9127564477"
    closeBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.ZIndex = 3

    -- Кнопки действий (будут добавляться динамически)
    local actionContainer = Instance.new("Frame")
    actionContainer.Name = "Actions"
    actionContainer.Parent = frame
    actionContainer.BackgroundTransparency = 1
    actionContainer.AnchorPoint = Vector2.new(1, 1)
    actionContainer.Position = UDim2.new(1, -10, 1, -8)
    actionContainer.Size = UDim2.new(0, 0, 0, 24)
    actionContainer.ZIndex = 2

    return {
        Frame = frame,
        Accent = accent,
        Icon = iconLabel,
        Heading = heading,
        Body = body,
        CloseBtn = closeBtn,
        Actions = actionContainer,
        Colors = c,
    }
end

-- ========== Основная функция создания уведомления ==========
function Notification.new(notifType, heading, body, options)
    notifType = notifType or "info"
    local opts = options or {}
    local autoRemove = opts.autoRemove ~= false
    local duration = opts.duration or CONFIG.ShowDuration
    local callback = opts.callback
    local buttons = opts.buttons or {} -- { {text = "OK", callback = function() end}, ... }

    local template = createNotificationTemplate(notifType)
    local frame = template.Frame

    -- Устанавливаем текст
    template.Heading.Text = heading or "Уведомление"
    template.Body.Text = body or ""

    -- Создаём объект уведомления
    local self = setmetatable({
        Frame = frame,
        Template = template,
        IsDestroyed = false,
        CloseCallback = callback,
    }, Notification)

    -- Функция закрытия (с анимацией)
    function self:close()
        if self.IsDestroyed then return end
        self.IsDestroyed = true

        local closeTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Position = UDim2.new(1.2, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            pcall(function() frame:Destroy() end)
            if self.CloseCallback then
                pcall(self.CloseCallback)
            end
        end)
    end

    -- Обработчик кнопки закрытия
    template.CloseBtn.MouseButton1Click:Connect(function()
        self:close()
    end)

    -- Добавляем кнопки действий
    if #buttons > 0 then
        local actionContainer = template.Actions
        local buttonWidth = 0
        for i, btn in ipairs(buttons) do
            local btnFrame = Instance.new("TextButton")
            btnFrame.Name = "ActionBtn_" .. i
            btnFrame.Parent = actionContainer
            btnFrame.BackgroundTransparency = 1
            btnFrame.Size = UDim2.new(0, 0, 1, 0)
            btnFrame.Font = Enum.Font.GothamBold
            btnFrame.Text = btn.text or "Кнопка"
            btnFrame.TextColor3 = template.Colors.accent
            btnFrame.TextSize = 13
            btnFrame.TextXAlignment = Enum.TextXAlignment.Right
            btnFrame.ZIndex = 3

            -- Рассчитываем ширину по тексту
            local textBounds = game:GetService("TextService"):GetTextSize(btnFrame.Text, btnFrame.TextSize, btnFrame.Font, Vector2.new(999, 24))
            local width = textBounds.X + 8
            btnFrame.Size = UDim2.new(0, width, 1, 0)
            buttonWidth = buttonWidth + width + 8

            btnFrame.MouseButton1Click:Connect(function()
                if btn.callback then
                    pcall(btn.callback)
                end
                self:close()
            end)

            btnFrame.MouseEnter:Connect(function()
                btnFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
            btnFrame.MouseLeave:Connect(function()
                btnFrame.TextColor3 = template.Colors.accent
            end)
        end
        -- Обновляем размер контейнера действий
        actionContainer.Size = UDim2.new(0, buttonWidth, 0, 24)
        -- Сдвигаем текст вверх, чтобы дать место кнопкам
        template.Body.Size = UDim2.new(1, 0, 1, -32)
    end

    -- Анимация появления (сдвиг + масштаб + затухание)
    frame.Position = UDim2.new(1.1, 0, 0, 0)
    frame.BackgroundTransparency = 1

    local appearTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0,
    })
    appearTween:Play()

    -- Звук
    if CONFIG.SoundEnabled then
        pcall(function() NotificationSound:Play() end)
    end

    -- Автоудаление
    if autoRemove and duration and duration > 0 then
        task.delay(duration, function()
            if not self.IsDestroyed then
                self:close()
            end
        end)
    end

    -- Вставляем в контейнер
    frame.Parent = Container
    frame.LayoutOrder = tick()

    return self
end

-- ========== Дополнительные методы ==========
function Notification:updateHeading(newHeading)
    if not self.IsDestroyed then
        self.Template.Heading.Text = newHeading
    end
end

function Notification:updateBody(newBody)
    if not self.IsDestroyed then
        self.Template.Body.Text = newBody
    end
end

function Notification:setCallback(func)
    if not self.IsDestroyed then
        self.CloseCallback = func
    end
end

-- ========== Глобальный доступ ==========
_G.Notification = Notification

return Notification
