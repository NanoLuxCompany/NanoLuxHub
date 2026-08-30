-- NanoLux Notification Library — Apple-style
local Notification = {}
Notification.__index = Notification

local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ── ScreenGui ──────────────────────────────────────────────
local Gui = Instance.new("ScreenGui")
Gui.Name = "NanoLuxNotifications"
Gui.Parent = CoreGui
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999

-- ── Container (top-right) ──────────────────────────────────
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = Gui
Container.AnchorPoint = Vector2.new(1, 0)
Container.Position = UDim2.new(1, -16, 0, 16)
Container.Size = UDim2.new(0, 360, 1, -32)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = false

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.VerticalAlignment = Enum.VerticalAlignment.Top
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
Layout.Padding = UDim.new(0, 10)

-- ── Colors ─────────────────────────────────────────────────
local COLORS = {
    error   = { bg = Color3.fromRGB(255, 59, 48),  accent = Color3.fromRGB(255, 69, 58),  text = Color3.new(1,1,1) },
    success = { bg = Color3.fromRGB(52, 199, 89),  accent = Color3.fromRGB(48, 209, 88),  text = Color3.new(1,1,1) },
    warning = { bg = Color3.fromRGB(255, 204, 0),  accent = Color3.fromRGB(255, 214, 10), text = Color3.fromRGB(30,30,30) },
    info    = { bg = Color3.fromRGB(10, 132, 255), accent = Color3.fromRGB(0, 122, 255),  text = Color3.new(1,1,1) },
    message = { bg = Color3.fromRGB(142, 142, 147), accent = Color3.fromRGB(142, 142, 147), text = Color3.new(1,1,1) },
}

-- ── Icon symbols (unicode / fallback) ──────────────────────
local ICONS = {
    error   = "rbxassetid://6031265976",
    success = "rbxassetid://6031265976",
    warning = "rbxassetid://6031265976",
    info    = "rbxassetid://6031265976",
    message = "rbxassetid://6031265976",
}

-- ── Build one notification frame ───────────────────────────
local function buildNotif(type, title, text)
    local c = COLORS[type] or COLORS.info

    -- wrapper (clips children for smooth slide)
    local Wrap = Instance.new("Frame")
    Wrap.Name = "Notif_" .. type
    Wrap.AnchorPoint = Vector2.new(1, 0)
    Wrap.Position = UDim2.new(1, 400, 0, 0)
    Wrap.Size = UDim2.new(1, 0, 0, 0)
    Wrap.AutomaticSize = Enum.AutomaticSize.Y
    Wrap.BackgroundTransparency = 1
    Wrap.ClipsDescendants = true

    -- main card
    local Card = Instance.new("Frame")
    Card.Name = "Card"
    Card.Parent = Wrap
    Card.AutomaticSize = Enum.AutomaticSize.Y
    Card.Size = UDim2.new(1, 0, 0, 0)
    Card.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    Card.BorderSizePixel = 0

    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = c.accent
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- inner padding
    local Pad = Instance.new("UIPadding", Card)
    Pad.PaddingTop    = UDim.new(0, 14)
    Pad.PaddingBottom = UDim.new(0, 14)
    Pad.PaddingLeft   = UDim.new(0, 16)
    Pad.PaddingRight  = UDim.new(0, 44)

    -- layout
    local L = Instance.new("UIListLayout", Card)
    L.FillDirection = Enum.FillDirection.Horizontal
    L.VerticalAlignment = Enum.VerticalAlignment.Top
    L.Padding = UDim.new(0, 12)

    -- ── Accent strip (left) ──────────────────────────────
    local Strip = Instance.new("Frame")
    Strip.Name = "Strip"
    Strip.LayoutOrder = 0
    Strip.Parent = Card
    Strip.Size = UDim2.new(0, 4, 0, 0)
    Strip.AutomaticSize = Enum.AutomaticSize.Y
    Strip.BackgroundColor3 = c.accent
    Strip.BorderSizePixel = 0
    Instance.new("UICorner", Strip).CornerRadius = UDim.new(1, 0)

    -- ── Icon circle ──────────────────────────────────────
    local IconWrap = Instance.new("Frame")
    IconWrap.Name = "IconWrap"
    IconWrap.LayoutOrder = 1
    IconWrap.Parent = Card
    IconWrap.Size = UDim2.new(0, 36, 0, 36)
    IconWrap.BackgroundColor3 = c.accent
    IconWrap.BackgroundTransparency = 0.85
    IconWrap.BorderSizePixel = 0
    Instance.new("UICorner", IconWrap).CornerRadius = UDim.new(1, 0)

    local IconImg = Instance.new("ImageLabel")
    IconImg.Name = "Icon"
    IconImg.Parent = IconWrap
    IconImg.AnchorPoint = Vector2.new(0.5, 0.5)
    IconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconImg.Size = UDim2.new(0, 18, 0, 18)
    IconImg.BackgroundTransparency = 1
    IconImg.Image = ICONS[type] or ICONS.info
    IconImg.ImageColor3 = c.accent
    IconImg.ScaleType = Enum.ScaleType.Fit

    -- ── Text block ───────────────────────────────────────
    local TextBlock = Instance.new("Frame")
    TextBlock.Name = "TextBlock"
    TextBlock.LayoutOrder = 2
    TextBlock.Parent = Card
    TextBlock.Size = UDim2.new(1, -60, 0, 0)
    TextBlock.AutomaticSize = Enum.AutomaticSize.Y
    TextBlock.BackgroundTransparency = 1

    local TextLayout = Instance.new("UIListLayout", TextBlock)
    TextLayout.Padding = UDim.new(0, 3)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Name = "Title"
    TitleLbl.Parent = TextBlock
    TitleLbl.Size = UDim2.new(1, 0, 0, 20)
    TitleLbl.AutomaticSize = Enum.AutomaticSize.Y
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.Text = title or "Notification"
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.TextSize = 15
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.TextYAlignment = Enum.TextYAlignment.Top
    TitleLbl.TextWrapped = true

    local BodyLbl = Instance.new("TextLabel")
    BodyLbl.Name = "Body"
    BodyLbl.Parent = TextBlock
    BodyLbl.Size = UDim2.new(1, 0, 0, 0)
    BodyLbl.AutomaticSize = Enum.AutomaticSize.Y
    BodyLbl.BackgroundTransparency = 1
    BodyLbl.Font = Enum.Font.Gotham
    BodyLbl.Text = text or ""
    BodyLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    BodyLbl.TextSize = 13
    BodyLbl.TextXAlignment = Enum.TextXAlignment.Left
    BodyLbl.TextYAlignment = Enum.TextYAlignment.Top
    BodyLbl.TextWrapped = true

    -- hide body if empty
    if text == nil or text == "" then
        BodyLbl.Visible = false
    end

    -- ── Close button ─────────────────────────────────────
    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Parent = Card
    Close.LayoutOrder = 3
    Close.Size = UDim2.new(0, 24, 0, 24)
    Close.Position = UDim2.new(1, -36, 0, 14)
    Close.AnchorPoint = Vector2.new(0, 0)
    Close.BackgroundTransparency = 1
    Close.Font = Enum.Font.GothamBold
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(140, 140, 140)
    Close.TextSize = 20
    Close.AutoButtonColor = false

    -- hover
    local hoverConn
    hoverConn = Close.MouseEnter:Connect(function()
        Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    Close.MouseLeave:Connect(function()
        Close.TextColor3 = Color3.fromRGB(140, 140, 140)
    end)

    return Wrap, Close
end

-- ── Remove oldest if overflow ──────────────────────────────
local function trimOverflow()
    local count = #Container:GetChildren() - 1 -- minus Layout
    if count > 5 then
        local children = Container:GetChildren()
        for _, ch in ipairs(children) do
            if ch:IsA("Frame") and ch.Name:find("Notif_") and count > 5 then
                ch:Destroy()
                count = count - 1
            end
        end
    end
end

-- ── Animation helpers ──────────────────────────────────────
local function slideIn(wrap)
    local tween = TS:Create(wrap,
        TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = UDim2.new(1, 0, 0, 0) }
    )
    tween:Play()
    return tween
end

local function slideOut(wrap, cb)
    local tween = TS:Create(wrap,
        TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        { Position = UDim2.new(1, 400, 0, 0) }
    )
    tween.Completed:Connect(function()
        pcall(function() wrap:Destroy() end)
        if cb then pcall(cb) end
    end)
    tween:Play()
    return tween
end

-- ── PUBLIC API ─────────────────────────────────────────────
function Notification.new(notifType, heading, body, autoRemove, autoRemoveTime, callback)
    notifType = (notifType or "info"):lower()
    if not COLORS[notifType] then notifType = "info" end

    local Wrap, CloseBtn = buildNotif(notifType, heading, body)
    Wrap.Parent = Container
    Wrap.LayoutOrder = tick()

    -- slight delay so list layout settles
    task.defer(function()
        slideIn(Wrap)
    end)

    local removed = false
    local function dismiss()
        if removed then return end
        removed = true
        slideOut(Wrap, callback)
    end

    CloseBtn.MouseButton1Click:Connect(dismiss)

    if autoRemove then
        task.delay(autoRemoveTime or 3, dismiss)
    end

    local obj = setmetatable({
        Instance = Wrap,
        _dismiss = dismiss,
    }, Notification)

    task.defer(trimOverflow)
    return obj
end

function Notification:delete()
    if self._dismiss then self._dismiss() end
end

function Notification:changeHeading(txt)
    if self.Instance and self.Instance.Parent then
        local card = self.Instance:FindFirstChild("Card")
        if card then
            local tb = card:FindFirstChild("TextBlock")
            if tb then
                local t = tb:FindFirstChild("Title")
                if t then t.Text = txt end
            end
        end
    end
end

function Notification:changeBody(txt)
    if self.Instance and self.Instance.Parent then
        local card = self.Instance:FindFirstChild("Card")
        if card then
            local tb = card:FindFirstChild("TextBlock")
            if tb then
                local b = tb:FindFirstChild("Body")
                if b then
                    b.Text = txt or ""
                    b.Visible = txt ~= nil and txt ~= ""
                end
            end
        end
    end
end

function Notification:deleteTimeout(t)
    task.delay(t or 3, function() self:delete() end)
end

return Notification
