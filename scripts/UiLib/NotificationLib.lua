--[[
	╔══════════════════════════════════════════════════════════════════════╗
	║                     AURA · NOTIFICATIONS  v2.0                       ║
	║        Полностью переписанная версия JxereasNotifications            ║
	╠══════════════════════════════════════════════════════════════════════╣
	║  ✦ Пружинная анимация появления: slide + fade + scale + блик         ║
	║  ✦ Стек плавно "подтягивается" при закрытии (раньше был рывок)       ║
	║  ✦ Прогресс-бар времени жизни с паузой при наведении курсора         ║
	║  ✦ Всплывающая иконка в цветном "чипе", свечение акцентной полоски   ║
	║  ✦ Мягкие тени, градиенты фона, аккуратная обводка                   ║
	║  ✦ Тёмная / светлая темы, звуки, лимит одновременных уведомлений     ║
	║  ✦ 100% обратная совместимость со СТАРЫМ API                         ║
	╠══════════════════════════════════════════════════════════════════════╣
	║  СТАРЫЙ ВЫЗОВ (как раньше — ничего менять не нужно):                 ║
	║    local n = Notify.new("Success", "Готово", "Скрипт загружен.",     ║
	║                         true, 5, function() print("закрыто") end)    ║
	║                                                                      ║
	║  НОВЫЙ ВЫЗОВ (таблица — удобнее):                                    ║
	║    local n = Notify.new({                                            ║
	║        Type     = "Info",            -- success/error/warning/info/  ║
	║        Title    = "Обновление",      -- message                      ║
	║        Text     = "Доступна новая версия меню.",                     ║
	║        Duration = 6,                 -- сек; nil = висеть вечно      ║
	║        Icon     = "rbxassetid://…",  -- опционально, своя иконка     ║
	║        Accent   = Color3.fromRGB(255, 120, 200),  -- свой цвет       ║
	║        Callback = function() end,                                    ║
	║    })                                                                ║
	║                                                                      ║
	║  МЕТОДЫ ОБЪЕКТА:                                                     ║
	║    n:changeHeading("…")   n:changeBody("…")    n:delete()            ║
	║    n:deleteTimeout(3)     n:changeColor(primary, secondary, text)    ║
	║    n:Update({ Title = "…", Text = "…" })                             ║
	║                                                                      ║
	║  МЕТОДЫ МОДУЛЯ:                                                      ║
	║    Notify.ClearAll()              -- убрать все                      ║
	║    Notify.SetPosition("TopRight") -- BottomRight / TopRight          ║
	║    Notify.SetTheme("Light")       -- тема для НОВЫХ уведомлений      ║
	║    Notify.Config.MaxVisible = 8   -- и другие настройки              ║
	╚══════════════════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players      = game:GetService("Players")

local Notification = {}
Notification.__index = Notification

--====================================================================--
--                          К О Н Ф И Г У Р А Ц И Я                    --
--====================================================================--
local Config = {
	Theme           = "Dark",        -- "Dark" | "Light"
	Position        = "BottomRight", -- "BottomRight" | "TopRight"
	Width           = 340,           -- ширина карточки, px
	Height          = 74,            -- высота карточки, px
	Margin          = 18,            -- отступ от края экрана
	Spacing         = 12,            -- расстояние между уведомлениями
	MaxVisible      = 6,             -- макс. одновременно на экране
	DefaultDuration = 5,             -- авто-закрытие по умолчанию, сек
	Shadows         = true,          -- мягкая тень под карточкой
	Sheen           = true,          -- блик, пробегающий при появлении
	HoverPause      = true,          -- пауза таймера при наведении
	Sounds          = false,         -- звуки (id — в TypePresets.Sound)
	SoundVolume     = 0.35,
}
Notification.Config = Config

--====================================================================--
--                              Т Е М Ы                                --
--====================================================================--
local Themes = {
	Dark = {
		Background    = Color3.fromRGB(17, 18, 23),
		Background2   = Color3.fromRGB(27, 29, 37),
		StrokeColor   = Color3.fromRGB(255, 255, 255),
		StrokeTransp  = 0.84,
		Title         = Color3.fromRGB(244, 246, 252),
		Body          = Color3.fromRGB(152, 158, 174),
		Close         = Color3.fromRGB(110, 116, 132),
		TrackTransp   = 0.90,
		SheenColor    = Color3.fromRGB(255, 255, 255),
	},
	Light = {
		Background    = Color3.fromRGB(255, 255, 255),
		Background2   = Color3.fromRGB(241, 244, 250),
		StrokeColor   = Color3.fromRGB(20, 22, 30),
		StrokeTransp  = 0.90,
		Title         = Color3.fromRGB(22, 24, 32),
		Body          = Color3.fromRGB(96, 102, 118),
		Close         = Color3.fromRGB(150, 154, 168),
		TrackTransp   = 0.86,
		SheenColor    = Color3.fromRGB(255, 255, 255),
	},
}

--====================================================================--
--                    Т И П Ы   У В Е Д О М Л Е Н И Й                  --
--====================================================================--
local TypePresets = {
	success = {
		Accent = Color3.fromRGB(62, 214, 152),
		Icon   = "rbxassetid://9073052584",
		Title  = "Успех",
		Sound  = nil, -- например "rbxassetid://6026984224"
	},
	error = {
		Accent = Color3.fromRGB(248, 106, 106),
		Icon   = "rbxassetid://9072920609",
		Title  = "Ошибка",
		Sound  = nil,
	},
	warning = {
		Accent = Color3.fromRGB(250, 190, 60),
		Icon   = "rbxassetid://9072448788",
		Title  = "Предупреждение",
		Sound  = nil,
	},
	info = {
		Accent = Color3.fromRGB(96, 165, 250),
		Icon   = "rbxassetid://9072944922",
		Title  = "Информация",
		Sound  = nil,
	},
	message = {
		Accent = Color3.fromRGB(170, 145, 250),
		Icon   = "rbxassetid://9072944922",
		Title  = "Сообщение",
		Sound  = nil,
	},
}
Notification.Types = TypePresets

-- Позиционирование контейнера и карточек
local Positions = {
	BottomRight = {
		HolderAP  = Vector2.new(1, 1),
		HolderPos = UDim2.new(1, -Config.Margin, 1, -Config.Margin),
		CardAP    = Vector2.new(1, 1),
		FromBottom = true,
	},
	TopRight = {
		HolderAP  = Vector2.new(1, 0),
		HolderPos = UDim2.new(1, -Config.Margin, 0, Config.Margin),
		CardAP    = Vector2.new(1, 0),
		FromBottom = false,
	},
}

--====================================================================--
--                           Х Е Л П Е Р Ы                             --
--====================================================================--
local function new(className, props, parent)
	local inst = Instance.new(className)
	for k, v in pairs(props) do
		inst[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function lerpColor(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

local function tween(obj, info, props)
	local ok, tw = pcall(function()
		return TweenService:Create(obj, info, props)
	end)
	if ok and tw then
		tw:Play()
		return tw
	end
	return nil
end

local function resolveGuiParent()
	if typeof(gethui) == "function" then
		local ok, res = pcall(gethui)
		if ok and typeof(res) == "Instance" then
			return res
		end
	end
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and coreGui then
		return coreGui
	end
	local lp = Players.LocalPlayer
	if lp then
		return lp:WaitForChild("PlayerGui")
	end
	return game:GetService("CoreGui")
end

local function playSound(id)
	if not (Config.Sounds and id) then return end
	task.spawn(function()
		local ok, snd = pcall(new, "Sound", {
			SoundId = id,
			Volume = Config.SoundVolume,
		}, SoundService)
		if ok and snd then
			snd.Ended:Connect(function()
				pcall(function() snd:Destroy() end)
			end)
			snd:Play()
		end
	end)
end

--====================================================================--
--                    К О Н Т Е Й Н Е Р   Э К Р А Н А                  --
--====================================================================--
local guiParent = resolveGuiParent()
do
	local old = guiParent:FindFirstChild("AuraNotifications")
	if old then
		pcall(function() old:Destroy() end)
	end
end

local gui = new("ScreenGui", {
	Name = "AuraNotifications",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
	DisplayOrder = 2147483647,
	IgnoreGuiInset = true,
}, guiParent)

local startPreset = Positions[Config.Position] or Positions.BottomRight
local holderFrame = new("Frame", {
	Name = "Holder",
	AnchorPoint = startPreset.HolderAP,
	Position = startPreset.HolderPos,
	Size = UDim2.new(0, Config.Width, 1, -Config.Margin * 2),
	BackgroundTransparency = 1,
	ClipsDescendants = false,
}, gui)

--====================================================================--
--                    С Т Е К   У В Е Д О М Л Е Н И Й                  --
--====================================================================--
local Active = {} -- [1] = самое старое (сверху), [#Active] = новое (снизу)

local function getPreset()
	return Positions[Config.Position] or Positions.BottomRight
end

-- Плавно расставляет все уведомления по своим слотам.
-- skipTween — элемент, который сам себя анимированно "заедет".
local function layoutStack(skipTween)
	local preset = getPreset()
	local offset = 0
	for i = #Active, 1, -1 do
		local item = Active[i]
		local target
		if preset.FromBottom then
			target = UDim2.new(1, 0, 1, -offset)
		else
			target = UDim2.new(1, 0, 0, offset)
		end
		offset += item._holder.Size.Y.Offset + Config.Spacing
		item._targetPos = target
		if item ~= skipTween and not item._closed then
			tween(item._holder,
				TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = target })
		end
	end
end

--====================================================================--
--                     Ф А Б Р И К А   К А Р Т О Ч К И                 --
--====================================================================--
local function createCard(theme, accent, iconId)
	local preset = getPreset()

	-- внешний "слот" (прозрачный), им двигает стек
	local holder = new("Frame", {
		Name = "slot",
		AnchorPoint = preset.CardAP,
		Size = UDim2.new(1, 0, 0, Config.Height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	-- мягкая тень
	local shadow
	if Config.Shadows then
		shadow = new("ImageLabel", {
			Name = "shadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 5),
			Size = UDim2.new(1, 50, 1, 50),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6014261993",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.55,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			ZIndex = 1,
		}, holder)
	end

	-- сама карточка (CanvasGroup = fade целиком + клип по скруглению)
	local card = new("CanvasGroup", {
		Name = "card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ZIndex = 2,
	}, holder)
	new("UICorner", { CornerRadius = UDim.new(0, 12) }, card)
	local gradient = new("UIGradient", {
		Color = ColorSequence.new(theme.Background, theme.Background2),
		Rotation = 100,
	}, card)
	local stroke = new("UIStroke", {
		Color = theme.StrokeColor,
		Transparency = theme.StrokeTransp,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, card)
	local scale = new("UIScale", { Scale = 0.92 }, card)

	-- свечение вокруг акцентной полоски
	local glow = new("Frame", {
		Name = "glow",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 11, 0.74, 0),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
	}, card)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, glow)

	-- акцентная полоска
	local accentBar = new("Frame", {
		Name = "accent",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.new(0, 4, 0.62, 0),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	}, card)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, accentBar)

	-- "чип" с иконкой
	local chip = new("Frame", {
		Name = "chip",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 22, 0.5, 0),
		Size = UDim2.new(0, 38, 0, 38),
		BackgroundColor3 = lerpColor(accent, theme.Background, 0.86),
		BorderSizePixel = 0,
	}, card)
	new("UICorner", { CornerRadius = UDim.new(0, 10) }, chip)
	new("UIStroke", {
		Color = accent,
		Transparency = 0.78,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, chip)
	local chipScale = new("UIScale", { Scale = 0 }, chip)
	local icon = new("ImageLabel", {
		Name = "icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		Image = iconId or "",
		ImageColor3 = accent,
	}, chip)

	-- текст
	local content = new("Frame", {
		Name = "content",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 74, 0.5, -4),
		Size = UDim2.new(1, -112, 1, -18),
		BackgroundTransparency = 1,
	}, card)
	local title = new("TextLabel", {
		Name = "title",
		Size = UDim2.new(1, 0, 0, 17),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = theme.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
	}, content)
	local body = new("TextLabel", {
		Name = "body",
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 1, -18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme.Body,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ClipsDescendants = true,
		Text = "",
	}, content)

	-- кнопка закрытия
	local closeBtn = new("ImageButton", {
		Name = "close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 9),
		Size = UDim2.new(0, 15, 0, 15),
		BackgroundTransparency = 1,
		Image = "rbxassetid://9127564477",
		ImageColor3 = theme.Close,
		AutoButtonColor = false,
		ZIndex = 3,
	}, card)

	-- прогресс-бар авто-закрытия
	local track = new("Frame", {
		Name = "track",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 22, 1, -8),
		Size = UDim2.new(1, -40, 0, 3),
		BackgroundColor3 = theme.Title,
		BackgroundTransparency = theme.TrackTransp,
		BorderSizePixel = 0,
		Visible = false,
	}, card)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
	local fill = new("Frame", {
		Name = "fill",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
	}, track)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

	-- блик (пробегает при появлении)
	local sheen
	if Config.Sheen then
		sheen = new("Frame", {
			Name = "sheen",
			Size = UDim2.new(0, 70, 1.9, 0),
			Position = UDim2.new(-0.45, 0, -0.45, 0),
			Rotation = 18,
			BackgroundColor3 = theme.SheenColor,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			ZIndex = 6,
		}, card)
		new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0.55),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}, sheen)
	end

	return {
		holder    = holder,
		shadow    = shadow,
		card      = card,
		gradient  = gradient,
		stroke    = stroke,
		scale     = scale,
		glow      = glow,
		accentBar = accentBar,
		chip      = chip,
		chipScale = chipScale,
		icon      = icon,
		title     = title,
		body      = body,
		closeBtn  = closeBtn,
		track     = track,
		fill      = fill,
		sheen     = sheen,
	}
end

--====================================================================--
--                 В Н У Т Р Е Н Н Я Я   Л О Г И К А                   --
--====================================================================--
function Notification:_startTimer(duration)
	local refs = self._refs
	self._remaining = duration
	self._endsAt = os.clock() + duration
	self._progressTw = tween(refs.fill,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ Size = UDim2.new(0, 0, 1, 0) })
	self._timerThread = task.delay(duration, function()
		self:delete()
	end)
end

function Notification:_pauseTimer()
	if not self._timerThread then return end
	pcall(task.cancel, self._timerThread)
	self._timerThread = nil
	self._remaining = math.max((self._endsAt or os.clock()) - os.clock(), 0)
	if self._progressTw then
		pcall(function() self._progressTw:Pause() end)
	end
end

function Notification:_resumeTimer()
	if self._closed or self._timerThread then return end
	if not self._remaining or self._remaining <= 0 then return end
	self._endsAt = os.clock() + self._remaining
	if self._progressTw then
		pcall(function() self._progressTw:Play() end)
	end
	local rem = self._remaining
	self._timerThread = task.delay(rem, function()
		self:delete()
	end)
end

function Notification:_enter()
	local refs = self._refs

	-- каскадная задержка, если уведомления летят пачкой
	local stagger = 0
	local now = os.clock()
	for _, it in ipairs(Active) do
		if it ~= self and it._enterClock and (now - it._enterClock) < 0.5 then
			stagger += 1
		end
	end
	self._enterClock = now
	local delayT = math.clamp(stagger * 0.06, 0, 0.3)

	task.delay(delayT, function()
		if self._closed then return end

		-- выезд из-за экрана + плавная подача на своё место
		tween(self._holder,
			TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = self._targetPos })

		-- проявление всей карточки
		tween(refs.card,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ GroupTransparency = 0 })

		-- лёгкий "подпрыг" масштаба
		tween(refs.scale,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 })

		-- всплытие иконки с пружинкой
		task.delay(0.12, function()
			if self._closed then return end
			tween(refs.chipScale,
				TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Scale = 1 })
		end)

		-- блик через карточку
		if refs.sheen then
			local sheen = refs.sheen
			task.delay(0.15, function()
				if sheen and sheen.Parent then
					local tw = tween(sheen,
						TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ Position = UDim2.new(1.5, 0, -0.45, 0) })
					if tw then
						tw.Completed:Connect(function()
							pcall(function() sheen:Destroy() end)
						end)
					end
				end
			end)
		end
	end)
end

function Notification:_exit(fast, skipLayout)
	if self._closed then return end
	self._closed = true
	local refs = self._refs

	if self._timerThread then
		pcall(task.cancel, self._timerThread)
		self._timerThread = nil
	end
	if self._progressTw then
		pcall(function() self._progressTw:Cancel() end)
		self._progressTw = nil
	end
	for _, conn in ipairs(self._conns) do
		pcall(function() conn:Disconnect() end)
	end
	self._conns = {}

	-- убрать из стека и подтянуть остальные
	for i, it in ipairs(Active) do
		if it == self then
			table.remove(Active, i)
			break
		end
	end
	if not skipLayout then
		layoutStack()
	end

	-- анимация ухода вправо + затухание
	local dur = fast and 0.22 or 0.32
	local yPos = self._holder.Position
	local outTarget = UDim2.new(1, 130, yPos.Y.Scale, yPos.Y.Offset)
	tween(self._holder,
		TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = outTarget })
	if refs.card and refs.card.Parent then
		tween(refs.card,
			TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ GroupTransparency = 1 })
	end

	-- колбэк и уничтожение — после анимации, как в оригинале
	local holder = self._holder
	local cb = self._callback
	task.delay(dur + 0.08, function()
		if cb and type(cb) == "function" then
			pcall(cb)
		end
		pcall(function()
			if holder and holder.Parent then
				holder:Destroy()
			end
		end)
	end)
end

--====================================================================--
--                С О З Д А Н И Е   У В Е Д О М Л Е Н И Я              --
--                                                                     --
--  Поддерживаются ДВА формата вызова:                                 --
--    Notification.new(type, heading, body, autoRemove, time, cb)      --
--    Notification.new({ Type=…, Title=…, Text=…, Duration=… })        --
--====================================================================--
function Notification.new(a1, a2, a3, a4, a5, a6)
	local opts
	if type(a1) == "table" then
		opts = a1
	else
		opts = {
			Type       = a1,
			Title      = a2,
			Text       = a3,
			AutoRemove = a4,
			Duration   = a5,
			Callback   = a6,
		}
	end

	local typeName = tostring(opts.Type or "info"):lower()
	local preset = TypePresets[typeName]
	assert(preset, ("[AuraNotify] Неизвестный тип '%s'. Доступные: success, error, warning, info, message"):format(typeName))

	local theme  = Themes[Config.Theme] or Themes.Dark
	local accent = (typeof(opts.Accent) == "Color3") and opts.Accent or preset.Accent
	local iconId = (type(opts.Icon) == "string") and opts.Icon or preset.Icon

	-- длительность / авто-удаление (совместимо со старым API)
	local duration = opts.Duration
	if duration == false then duration = nil end
	if duration == nil and opts.AutoRemove then
		duration = Config.DefaultDuration
	end
	if opts.AutoRemove == false then
		duration = nil
	end

	-- объект
	local self = setmetatable({}, Notification)
	self._closed    = false
	self._theme     = theme
	self._accent    = accent
	self._conns     = {}
	self._callback  = (type(opts.Callback) == "function") and opts.Callback or nil
	self._Remaining = nil

	local refs = createCard(theme, accent, iconId)
	self._refs   = refs
	self._holder = refs.holder
	self.Instance = refs.holder -- совместимость со старым API

	refs.title.Text = tostring(opts.Title or opts.Heading or preset.Title)
	refs.body.Text  = tostring(opts.Text or opts.Body or "")

	-- регистрируем в стеке и считаем слот
	table.insert(Active, self)
	layoutStack(self)

	-- стартовая позиция — за правым краем на высоте своего слота
	refs.holder.Position = UDim2.new(1, 120, self._targetPos.Y.Scale, self._targetPos.Y.Offset)
	refs.holder.Parent = holderFrame

	-- лимит одновременно видимых: старые быстро уезжают
	while #Active > Config.MaxVisible do
		Active[1]:_exit(true, true)
	end
	layoutStack()

	-- таймер авто-закрытия
	if duration and duration > 0 then
		refs.track.Visible = true
		self:_startTimer(duration)
	end

	-- наведение: подсветка + пауза таймера
	table.insert(self._conns, refs.holder.MouseEnter:Connect(function()
		if self._closed then return end
		tween(refs.stroke, TweenInfo.new(0.15), { Transparency = math.max(theme.StrokeTransp - 0.14, 0) })
		tween(refs.closeBtn, TweenInfo.new(0.15), { ImageColor3 = accent })
		if Config.HoverPause then
			self:_pauseTimer()
		end
	end))
	table.insert(self._conns, refs.holder.MouseLeave:Connect(function()
		if self._closed then return end
		tween(refs.stroke, TweenInfo.new(0.2), { Transparency = theme.StrokeTransp })
		tween(refs.closeBtn, TweenInfo.new(0.2), { ImageColor3 = theme.Close })
		if Config.HoverPause then
			self:_resumeTimer()
		end
	end))

	-- кнопка закрытия
	table.insert(self._conns, refs.closeBtn.MouseButton1Click:Connect(function()
		self:delete()
	end))

	-- поехали
	self:_enter()
	playSound(opts.Sound or preset.Sound)

	return self
end
Notification.Notify = Notification.new -- алиас

--====================================================================--
--                    М Е Т О Д Ы   О Б Ъ Е К Т А                      --
--====================================================================--
function Notification:changeHeading(newHeading)
	if self._closed then return end
	pcall(function()
		self._refs.title.Text = tostring(newHeading)
	end)
end

function Notification:changeBody(newBody)
	if self._closed then return end
	pcall(function()
		self._refs.body.Text = tostring(newBody)
	end)
end

function Notification:Update(opts)
	if self._closed then return end
	opts = opts or {}
	if opts.Title or opts.Heading then
		self:changeHeading(opts.Title or opts.Heading)
	end
	if opts.Text or opts.Body then
		self:changeBody(opts.Text or opts.Body)
	end
	if typeof(opts.Accent) == "Color3" then
		self:changeColor(nil, opts.Accent, nil)
	end
end

function Notification:deleteTimeout(timeout)
	timeout = timeout or 3
	task.delay(timeout, function()
		if not self._closed then
			self:delete()
		end
	end)
end

function Notification:delete()
	self:_exit(false)
end

function Notification:changeColor(primary, secondary, textColor)
	if self._closed then return end
	local refs = self._refs

	if typeof(primary) == "Color3" then
		refs.card.BackgroundColor3 = primary
		if refs.gradient then
			refs.gradient.Color = ColorSequence.new(primary, lerpColor(primary, Color3.new(1, 1, 1), 0.06))
		end
		refs.chip.BackgroundColor3 = lerpColor(self._accent, primary, 0.86)
	end

	if typeof(secondary) == "Color3" then
		self._accent = secondary
		refs.accentBar.BackgroundColor3 = secondary
		refs.glow.BackgroundColor3 = secondary
		refs.icon.ImageColor3 = secondary
		refs.fill.BackgroundColor3 = secondary
		refs.chip.BackgroundColor3 = lerpColor(secondary, refs.card.BackgroundColor3, 0.86)
		local chipStroke = refs.chip:FindFirstChildOfClass("UIStroke")
		if chipStroke then
			chipStroke.Color = secondary
		end
	end

	if typeof(textColor) == "Color3" then
		refs.title.TextColor3 = textColor
		refs.body.TextColor3 = lerpColor(textColor, Color3.new(0, 0, 0), 0.15)
	end
end

--====================================================================--
--                     М Е Т О Д Ы   М О Д У Л Я                       --
--====================================================================--
function Notification.ClearAll()
	local copy = {}
	for i, it in ipairs(Active) do
		copy[i] = it
	end
	for _, it in ipairs(copy) do
		it:delete()
	end
end

function Notification.SetPosition(pos)
	local p = Positions[pos]
	if not p then
		warn(("[AuraNotify] Неизвестная позиция '%s'. Доступные: BottomRight, TopRight"):format(tostring(pos)))
		return
	end
	Config.Position = pos
	holderFrame.AnchorPoint = p.HolderAP
	holderFrame.Position = p.HolderPos
	for _, it in ipairs(Active) do
		it._holder.AnchorPoint = p.CardAP
	end
	layoutStack()
end

function Notification.SetTheme(name)
	if Themes[name] then
		Config.Theme = name
	else
		warn(("[AuraNotify] Неизвестная тема '%s'. Доступные: Dark, Light"):format(tostring(name)))
	end
end

return Notification
