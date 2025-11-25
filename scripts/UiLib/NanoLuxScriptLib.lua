local Library = {}
local LibraryName = tostring(math.random(100000,999999))

function Library:Toggle()
    if game.CoreGui:FindFirstChild(LibraryName) then
        game.CoreGui[LibraryName].Enabled = not game.CoreGui[LibraryName].Enabled
    end
end

function Library:Drag(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:ColorPicker(name, default, callback)
    local color = default or Color3.fromRGB(255, 255, 255)
    local h, s, v = color:ToHSV()
    local callback = callback or function() end

    local Picker = Instance.new("Frame")
    local Corner = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local Close = Instance.new("TextButton")
    local HueSat = Instance.new("ImageLabel")
    local HueSatCursor = Instance.new("Frame")
    local ValueSlider = Instance.new("Frame")
    local ValueFill = Instance.new("Frame")
    local ValueCursor = Instance.new("Frame")
    local Preview = Instance.new("Frame")
    local PreviewCorner = Instance.new("UICorner")

    Picker.Name = "ColorPicker"
    Picker.Parent = game.CoreGui[LibraryName]
    Picker.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    Picker.Position = UDim2.new(0.5, -150, 0.5, -150)
    Picker.Size = UDim2.fromOffset(300, 320)
    Picker.Visible = false
    Picker.ZIndex = 999

    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Picker

    Title.Name = "Title"
    Title.Parent = Picker
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(10, 5)
    Title.Size = UDim2.new(1, -50, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 1000

    Close.Name = "Close"
    Close.Parent = Picker
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -30, 0, 5)
    Close.Size = UDim2.fromOffset(25, 25)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 100, 100)
    Close.TextSize = 18
    Close.ZIndex = 1000
    Close.MouseButton1Click:Connect(function()
        Picker.Visible = false
    end)

    HueSat.Name = "HueSat"
    HueSat.Parent = Picker
    HueSat.BackgroundTransparency = 1
    HueSat.Position = UDim2.fromOffset(20, 50)
    HueSat.Size = UDim2.fromOffset(200, 200)
    HueSat.Image = "rbxassetid://4155801252"
    HueSat.ZIndex = 1000

    HueSatCursor.Name = "Cursor"
    HueSatCursor.Parent = HueSat
    HueSatCursor.BackgroundTransparency = 1
    HueSatCursor.Size = UDim2.fromOffset(12, 12)
    HueSatCursor.Position = UDim2.fromScale(s, 1 - v)
    HueSatCursor.ZIndex = 1002
    local cursorStroke = Instance.new("UIStroke", HueSatCursor)
    cursorStroke.Color = Color3.fromRGB(255, 255, 255)
    cursorStroke.Thickness = 2
    local cursorCorner = Instance.new("UICorner", HueSatCursor)
    cursorCorner.CornerRadius = UDim.new(1, 0)

    ValueSlider.Name = "ValueSlider"
    ValueSlider.Parent = Picker
    ValueSlider.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    ValueSlider.Position = UDim2.fromOffset(240, 50)
    ValueSlider.Size = UDim2.fromOffset(30, 200)
    ValueSlider.ZIndex = 1000
    local vsCorner = Instance.new("UICorner", ValueSlider)
    vsCorner.CornerRadius = UDim.new(0, 8)

    ValueFill.Name = "Fill"
    ValueFill.Parent = ValueSlider
    ValueFill.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    ValueFill.Size = UDim2.fromScale(1, 1)
    ValueFill.ZIndex = 1001
    local vg = Instance.new("UIGradient", ValueFill)
    vg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))}
    vg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}

    ValueCursor.Name = "Cursor"
    ValueCursor.Parent = ValueSlider
    ValueCursor.BackgroundTransparency = 1
    ValueCursor.Size = UDim2.fromOffset(36, 8)
    ValueCursor.Position = UDim2.new(0, -3, 1-v, -4)
    ValueCursor.ZIndex = 1002
    local vcStroke = Instance.new("UIStroke", ValueCursor)
    vcStroke.Color = Color3.fromRGB(255, 255, 255)
    vcStroke.Thickness = 2

    Preview.Name = "Preview"
    Preview.Parent = Picker
    Preview.BackgroundColor3 = color
    Preview.Position = UDim2.fromOffset(20, 270)
    Preview.Size = UDim2.fromOffset(250, 30)
    Preview.ZIndex = 1000
    PreviewCorner.CornerRadius = UDim.new(0, 8)
    PreviewCorner.Parent = Preview

    -- Logic
    local mouse = game.Players.LocalPlayer:GetMouse()
    local draggingHueSat = false
    local draggingValue = false

    HueSat.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHueSat = true
        end
    end)
    ValueSlider.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingValue = true
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHueSat = false
            draggingValue = false
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if draggingHueSat then
            local rel = Vector2.new(mouse.X - HueSat.AbsolutePosition.X, mouse.Y - HueSat.AbsolutePosition.Y)
            local clamped = Vector2.new(math.clamp(rel.X / 200, 0, 1), math.clamp(rel.Y / 200, 0, 1))
            s = clamped.X
            v = 1 - clamped.Y
            HueSatCursor.Position = UDim2.fromScale(s, 1 - v)
            color = Color3.fromHSV(h, s, v)
            Preview.BackgroundColor3 = color
            callback(color)
        end
        if draggingValue then
            local relY = math.clamp((mouse.Y - ValueSlider.AbsolutePosition.Y) / 200, 0, 1)
            v = 1 - relY
            ValueCursor.Position = UDim2.new(0, -3, v, -4)
            color = Color3.fromHSV(h, s, v)
            Preview.BackgroundColor3 = color
            callback(color)
        end
    end)

    HueSat.MouseMoved:Connect(function(x, y)
        if not draggingHueSat then return end
        local relX = math.clamp((x - HueSat.AbsolutePosition.X) / 200, 0, 1)
        local relY = math.clamp((y - HueSat.AbsolutePosition.Y) / 200, 0, 1)
        local angle = math.atan2(relY - 0.5, relX - 0.5)
        h = (angle + math.pi) / (math.pi * 2)
        ValueFill.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        color = Color3.fromHSV(h, s, v)
        Preview.BackgroundColor3 = color
        callback(color)
    end)

    return {
        Toggle = function()
            Picker.Visible = not Picker.Visible
        end,
        Set = function(c)
            color = c
            h, s, v = c:ToHSV()
            HueSatCursor.Position = UDim2.fromScale(s, 1 - v)
            ValueCursor.Position = UDim2.new(0, -3, v, -4)
            ValueFill.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Preview.BackgroundColor3 = c
            callback(c)
        end
    }
end

function Library:Create(xHubName,xGameName)
    local xHubName = xHubName or "UI Library"
    local xGameName = xGameName or "By Mapple#3045"
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local Sidebar = Instance.new("Frame")
    local SidebarCorner = Instance.new("UICorner")
    local Filler = Instance.new("Frame")
    local HubName = Instance.new("TextLabel")
    local Line = Instance.new("Frame")
    local ActualSide = Instance.new("ScrollingFrame")
    local ActualSideListLayout = Instance.new("UIListLayout")
    local SideLine = Instance.new("Frame")
    local GameName = Instance.new("TextLabel")
    local TabHolder = Instance.new("Frame")
    local Tabs = Instance.new("Folder")
    local TitleBar = Instance.new("Frame")
    local MinimizeBtn = Instance.new("TextButton")
    local CloseScriptBtn = Instance.new("TextButton")

    function ScrollSize()
        ActualSide.CanvasSize = UDim2.new(0, 0, 0, ActualSideListLayout.AbsoluteContentSize.Y)
    end

    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false 
    ScreenGui.Name = LibraryName

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(31, 30, 46)
    Main.Position = UDim2.new(0.278277636, 0, 0.281287253, 0)
    Main.Size = UDim2.new(0, 580, 0, 500) -- Increased height

    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main

    -- Title Bar
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Position = UDim2.new(0, 0, 0, -25)
    TitleBar.Size = UDim2.new(1, 0, 0, 25)
    
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Position = UDim2.new(1, -60, 0, 2)
    MinimizeBtn.Size = UDim2.fromOffset(20, 20)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.MouseButton1Click:Connect(function()
        Library:Toggle()
    end)

    CloseScriptBtn.Name = "CloseScript"
    CloseScriptBtn.Parent = TitleBar
    CloseScriptBtn.BackgroundTransparency = 1
    CloseScriptBtn.Position = UDim2.new(1, -30, 0, 2)
    CloseScriptBtn.Size = UDim2.fromOffset(20, 20)
    CloseScriptBtn.Text = "X"
    CloseScriptBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseScriptBtn.Font = Enum.Font.GothamBold
    CloseScriptBtn.TextSize = 16
    CloseScriptBtn.MouseButton1Click:Connect(function()
        game.CoreGui[LibraryName]:Destroy()
        getgenv().NanoLux_Closed = true
    end)

    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    Sidebar.Size = UDim2.new(0, 140, 0, 500)

    SidebarCorner.Name = "SidebarCorner"
    SidebarCorner.Parent = Sidebar

    Filler.Name = "Filler"
    Filler.Parent = Sidebar
    Filler.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    Filler.BorderSizePixel = 0
    Filler.Position = UDim2.new(0.930769145, 0, 0, 0)
    Filler.Size = UDim2.new(0, 9, 0, 500)

    HubName.Name = "HubName"
    HubName.Parent = Sidebar
    HubName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HubName.BackgroundTransparency = 1.000
    HubName.BorderSizePixel = 0
    HubName.Position = UDim2.new(0, 0, 0.024324324, 0)
    HubName.Size = UDim2.new(0, 140, 0, 21)
    HubName.Font = Enum.Font.Gotham
    HubName.Text = xHubName
    HubName.TextColor3 = Color3.fromRGB(255, 255, 255)
    HubName.TextSize = 16.000

    Line.Name = "Line"
    Line.Parent = Sidebar
    Line.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    Line.BorderSizePixel = 0
    Line.Position = UDim2.new(0.0642857179, 0, 0.148648649, 0)
    Line.Size = UDim2.new(0, 121, 0, 2)

    ActualSide.Name = "ActualSide"
    ActualSide.Parent = Sidebar
    ActualSide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ActualSide.BackgroundTransparency = 1.000
    ActualSide.BorderSizePixel = 0
    ActualSide.Position = UDim2.new(0, 0, 0.172972977, 0)
    ActualSide.Size = UDim2.new(0, 139, 0, 427)
    ActualSide.CanvasSize = UDim2.new(0,0,0,0)
    ActualSide.ScrollBarThickness = 0

    ActualSideListLayout.Name = "ActualSideListLayout"
    ActualSideListLayout.Parent = ActualSide
    ActualSideListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    SideLine.Name = "SideLine"
    SideLine.Parent = Sidebar
    SideLine.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SideLine.BorderSizePixel = 0
    SideLine.Position = UDim2.new(1, 0, 0, 0)
    SideLine.Size = UDim2.new(0, 2, 0, 500)

    GameName.Name = "GameName"
    GameName.Parent = Sidebar
    GameName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GameName.BackgroundTransparency = 1.000
    GameName.BorderSizePixel = 0
    GameName.Position = UDim2.new(-0.00714285718, 0, 0.0810810775, 0)
    GameName.Size = UDim2.new(0, 141, 0, 25)
    GameName.Font = Enum.Font.Gotham
    GameName.Text = xGameName
    GameName.TextColor3 = Color3.fromRGB(190, 190, 190)
    GameName.TextSize = 14.000

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = Main
    TabHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabHolder.BackgroundTransparency = 1.000
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0.244827583, 0, 0.024324324, 0)
    TabHolder.Size = UDim2.new(0, 438, 0, 482)

    Tabs.Name = "Tabs"
    Tabs.Parent = TabHolder

    Library:Drag(Main)

    local xTabs = {}
    
    function xTabs:Tab(Name,xVisible)
        local Name = Name or "Tab"
        local Tab = Instance.new("ScrollingFrame")
        local TabListLayout = Instance.new("UIListLayout")
        local TabButton = Instance.new("TextButton")
        
        ScrollSize()

        function Size()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
        end

        Tab.Name = "Tab"
        Tab.Parent = Tabs
        Tab.Active = true
        Tab.Visible = xVisible
        Tab.BackgroundColor3 = Color3.fromRGB(31, 30, 46)
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(0, 438, 0, 482)
        Tab.ScrollBarThickness = 5
        
        TabListLayout.Name = "TabListLayout"
        TabListLayout.Parent = Tab
        TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabListLayout.Padding = UDim.new(0, 5)

        TabButton.Name = "TabButton"
        TabButton.Parent = ActualSide
        TabButton.BackgroundColor3 = Color3.fromRGB(55, 74, 251)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(0, 139, 0, 35)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = Name
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14.000
        TabButton.ZIndex = 2

        Size()
        Tab.ChildAdded:Connect(Size)
        Tab.ChildRemoved:Connect(Size)

        if xVisible then 
            TabButton.BackgroundColor3 = Color3.fromRGB(55, 74, 251)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else 
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            TabButton.TextColor3 = Color3.fromRGB(190, 190, 190)
        end

        TabButton.MouseButton1Down:Connect(function()
            Size()
            for i,v in pairs(ActualSide:GetChildren()) do 
                if v:IsA("TextButton") then 
                    v.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                    v.TextColor3 = Color3.fromRGB(190, 190, 190)
                end
            end

            for i,v in pairs(Tabs:GetChildren()) do
                v.Visible = false
            end

            Tab.Visible = true
            game:GetService("TweenService"):Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                BackgroundColor3 = Color3.fromRGB(55, 74, 251)
            }):Play()
            game:GetService("TweenService"):Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end)

        local Elements = {}

        function Elements:Label(Name)
            local Name = Name or "Label"
            local LabelFunction = {}
            local LabelFrame = Instance.new("Frame")
            local LabelFrameCorner = Instance.new("UICorner")
            local Label = Instance.new("TextLabel")

            LabelFrame.Name = tostring(Name).."_Label"
            LabelFrame.Parent = Tab
            LabelFrame.BackgroundColor3 = Color3.fromRGB(55, 74, 251)
            LabelFrame.Position = UDim2.new(0.0456621014, 0, 0, 0)
            LabelFrame.Size = UDim2.new(0, 408, 0, 35)

            LabelFrameCorner.Name = "LabelFrameCorner"
            LabelFrameCorner.Parent = LabelFrame

            Label.Name = "Label"
            Label.Parent = LabelFrame
            Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Label.BackgroundTransparency = 1.000
            Label.BorderSizePixel = 0
            Label.Size = UDim2.new(0, 408, 0, 35)
            Label.Font = Enum.Font.Gotham
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 16.000

            Label.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(LabelFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(63, 83, 255)
                }):Play()
            end)
            Label.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(LabelFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(55, 74, 251)
                }):Play()
            end)

            function LabelFunction:UpdateLabel(Name)
                Label.Text = Name
                LabelHolder.Name = tostring(Name).."_Label"
            end
            return LabelFunction
        end

        function Elements:Button(Name,Callback)
            local Name = Name or "Button"
            local ButtonFunction = {}
            local Callback = Callback or function () end
            local ButtonFrame = Instance.new("Frame")
            local ButtonFrameCorner = Instance.new("UICorner")
            local Button = Instance.new("TextButton")
            local ButtonCorner = Instance.new("UICorner")
            local ButtonPadding = Instance.new("UIPadding")

            ButtonFrame.Name = tostring(Name).."_Button"
            ButtonFrame.Parent = Tab
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            ButtonFrame.Size = UDim2.new(0, 408, 0, 35)
            
            ButtonFrameCorner.Name = "ButtonFrameCorner"
            ButtonFrameCorner.Parent = ButtonFrame
            
            Button.Name = "Button"
            Button.Parent = ButtonFrame
            Button.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            Button.Size = UDim2.new(0, 408, 0, 35)
            Button.Font = Enum.Font.Gotham
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 16.000
            Button.Text = Name
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.ZIndex = 2
            
            ButtonCorner.Name = "ButtonCorner"
            ButtonCorner.Parent = Button
            
            ButtonPadding.Name = "ButtonPadding"
            ButtonPadding.Parent = Button
            ButtonPadding.PaddingLeft = UDim.new(0, 10)

            Button.MouseButton1Down:Connect(function()
                game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(55, 74, 251)
                }):Play()
                wait(0.1)
                game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                }):Play()
                pcall(Callback)
            end)

            Button.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(48, 51, 70)
                }):Play()
            end)
            Button.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                }):Play()
            end)

            function ButtonFunction:UpdateButton(Name)
                Button.Text = Name
                ButtonHolder.Name = tostring(Name).."_Button"
            end
            return ButtonFunction
        end

        function Elements:Toggle(Name,Callback)
            local Name = Name or "Toggle"
            local Callback = Callback or function() end
            local ToggleEnabled = false
            local ToggleFrame = Instance.new("Frame")
            local ToggleName = Instance.new("TextLabel")
            local ToggleNamePadding = Instance.new("UIPadding")
            local ToggleFrameCorner = Instance.new("UICorner")
            local ToggleCorner = Instance.new("UICorner")
            local ToggleCircle = Instance.new("ImageLabel")
            local ToggleButton = Instance.new("TextButton")
            local ToggleF = Instance.new("Frame")

            ToggleFrame.Name = tostring(Name).."_Toggle"
            ToggleFrame.Parent = Tab
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(0, 408, 0, 35)

            ToggleName.Name = "ToggleName"
            ToggleName.Parent = ToggleFrame
            ToggleName.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            ToggleName.BackgroundTransparency = 1.000
            ToggleName.BorderSizePixel = 0
            ToggleName.Size = UDim2.new(0, 347, 0, 35)
            ToggleName.Font = Enum.Font.Gotham
            ToggleName.Text = Name
            ToggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleName.TextSize = 16.000
            ToggleName.TextXAlignment = Enum.TextXAlignment.Left

            ToggleNamePadding.Name = "ToggleNamePadding"
            ToggleNamePadding.Parent = ToggleName
            ToggleNamePadding.PaddingLeft = UDim.new(0, 10)

            ToggleFrameCorner.Name = "ToggleFrameCorner"
            ToggleFrameCorner.Parent = ToggleFrame

            ToggleF.Name = "ToggleF"
            ToggleF.Parent = ToggleFrame
            ToggleF.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            ToggleF.BackgroundTransparency = 0
            ToggleF.BorderSizePixel = 0
            ToggleF.Position = UDim2.new(0.867647052, 0, 0.142857149, 0)
            ToggleF.Size = UDim2.new(0, 45, 0, 23)

            ToggleCorner.CornerRadius = UDim.new(0, 25)
            ToggleCorner.Name = "ToggleCorner"
            ToggleCorner.Parent = ToggleF

            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = ToggleF
            ToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Size = UDim2.new(0, 45, 0, 23)
            ToggleButton.Font = Enum.Font.SourceSans
            ToggleButton.Text = ""
            ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            ToggleButton.TextSize = 14.000

            ToggleCircle.Name = "ToggleCircle"
            ToggleCircle.Parent = ToggleF
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.BackgroundTransparency = 1.000
            ToggleCircle.Position = UDim2.new(0.093, 0,0.153, 0)
            ToggleCircle.Size = UDim2.new(0, 17, 0, 17)
            ToggleCircle.Image = "rbxassetid://3570695787"
            ToggleCircle.ScaleType = Enum.ScaleType.Slice
            ToggleCircle.SliceCenter = Rect.new(100, 100, 100, 100)
            ToggleCircle.SliceScale = 0.120

            ToggleButton.MouseButton1Down:Connect(function()
                ToggleEnabled = not ToggleEnabled
                if ToggleEnabled then 
                    game:GetService("TweenService"):Create(ToggleF, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(55, 74, 251)}):Play() 
                    game:GetService("TweenService"):Create(ToggleCircle, TweenInfo.new(0.3), {Position = UDim2.new(0.559, 0,0.153, 0)}):Play() 
                else
                    game:GetService("TweenService"):Create(ToggleF, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(55, 55, 75)}):Play() 
                    game:GetService("TweenService"):Create(ToggleCircle, TweenInfo.new(0.3), {Position = UDim2.new(0.093, 0,0.153, 0)}):Play() 
                end
                pcall(Callback,ToggleEnabled)
            end)
        end

        function Elements:Slider(Name,Min,Max,Callback)
            local Name = Name or "Slider"
            local Callback = Callback or function() end
            local Max = Max or 500
            local Min = Min or 16
            local SliderFrame = Instance.new("Frame")
            local SliderFrameCorner = Instance.new("UICorner")
            local SliderButton = Instance.new("TextButton")
            local SliderButtonCorner = Instance.new("UICorner")
            local SliderTrail = Instance.new("Frame")
            local SliderTrailCorner = Instance.new("UICorner")
            local SliderName = Instance.new("TextLabel")
            local SliderNamePadding = Instance.new("UIPadding")
            local SliderValue = Instance.new("TextLabel")
            local SliderValuePadding = Instance.new("UIPadding")

            SliderFrame.Name = tostring(Name).."_Slider"
            SliderFrame.Parent = Tab
            SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            SliderFrame.Size = UDim2.new(0, 408, 0, 50)

            SliderFrameCorner.Name = "SliderFrameCorner"
            SliderFrameCorner.Parent = SliderFrame

            SliderButton.Name = "SliderButton"
            SliderButton.Parent = SliderFrame
            SliderButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            SliderButton.BorderSizePixel = 0
            SliderButton.Position = UDim2.new(0.0242369417, 0, 0.639999986, 0)
            SliderButton.Size = UDim2.new(0, 389, 0, 10)
            SliderButton.Font = Enum.Font.SourceSans
            SliderButton.Text = ""
            SliderButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            SliderButton.TextSize = 14.000

            SliderButtonCorner.Name = "SliderButtonCorner"
            SliderButtonCorner.Parent = SliderButton

            SliderTrail.Name = "SliderTrail"
            SliderTrail.Parent = SliderButton
            SliderTrail.BackgroundColor3 = Color3.fromRGB(55, 74, 251)
            SliderTrail.Size = UDim2.new(0, 0, 0, 10)
            SliderTrail.BorderSizePixel = 0

            SliderTrailCorner.Name = "SliderTrailCorner"
            SliderTrailCorner.Parent = SliderTrail

            SliderName.Name = "SliderName"
            SliderName.Parent = SliderFrame
            SliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderName.BackgroundTransparency = 1.000
            SliderName.BorderSizePixel = 0
            SliderName.Size = UDim2.new(0, 320, 0, 26)
            SliderName.Font = Enum.Font.Gotham
            SliderName.Text = Name
            SliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderName.TextSize = 16.000
            SliderName.TextXAlignment = Enum.TextXAlignment.Left

            SliderNamePadding.Name = "SliderNamePadding"
            SliderNamePadding.Parent = SliderName
            SliderNamePadding.PaddingLeft = UDim.new(0, 10)

            SliderValue.Name = "SliderValue"
            SliderValue.Parent = SliderFrame
            SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.BackgroundTransparency = 1.000
            SliderValue.BorderSizePixel = 0
            SliderValue.TextTransparency = 0.000
            SliderValue.Position = UDim2.new(0.802061796, 0, 0, 0)
            SliderValue.Size = UDim2.new(0, 80, 0, 26)
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.Text = tostring(Min)
            SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.TextSize = 16.000
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right

            SliderValuePadding.Name = "SliderValuePadding"
            SliderValuePadding.Parent = SliderValue
            SliderValuePadding.PaddingRight = UDim.new(0, 10)

            local ms = game.Players.LocalPlayer:GetMouse()
            local uis = game:GetService("UserInputService")
            local Value = Min
            local mouse = game:GetService("Players").LocalPlayer:GetMouse();

            SliderButton.MouseButton1Down:Connect(function()
                Value = math.floor((((tonumber(Max) - tonumber(Min)) / 389) * SliderTrail.AbsoluteSize.X) + tonumber(Min)) or 0
                pcall(function()
                    Callback(Value)
                end)
                SliderTrail:TweenSize(UDim2.new(0, math.clamp(mouse.X - SliderTrail.AbsolutePosition.X, 0, 389), 0, 10), "InOut", "Linear", 0.05, true)
                moveconnection = mouse.Move:Connect(function()
                    SliderValue.Text = Value
                    Value = math.floor((((tonumber(Max) - tonumber(Min)) / 389) * SliderTrail.AbsoluteSize.X) + tonumber(Min))
                    pcall(function()
                        Callback(Value)
                    end)
                    SliderTrail:TweenSize(UDim2.new(0, math.clamp(mouse.X - SliderTrail.AbsolutePosition.X, 0, 389), 0, 10), "InOut", "Linear", 0.05, true)
                end)
                releaseconnection = uis.InputEnded:Connect(function(Mouse)
                    if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
                        Value = math.floor((((tonumber(Max) - tonumber(Min)) / 389) * SliderTrail.AbsoluteSize.X) + tonumber(Min))
                        pcall(function()
                            Callback(Value)
                        end)
                        SliderValue.Text = Value
                        moveconnection:Disconnect()
                        releaseconnection:Disconnect()
                    end
                end)
            end)
        end

        function Elements:Textbox(Name,Default,Callback)
            local Name = Name or "Textbox"
            local Default = Default or ""
            local Callback = Callback or function() end
            local TextboxFrame = Instance.new("Frame")
            local TextboxFrameCorner = Instance.new("UICorner")
            local TextboxName = Instance.new("TextLabel")
            local TextboxNamePadding = Instance.new("UIPadding")
            local Textbox = Instance.new("TextBox")
            local TextboxCorner = Instance.new("UICorner")

            TextboxFrame.Name = tostring(Name).."_Textbox"
            TextboxFrame.Parent = Tab
            TextboxFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            TextboxFrame.Size = UDim2.new(0, 408, 0, 35)

            TextboxFrameCorner.Name = "TextboxFrameCorner"
            TextboxFrameCorner.Parent = TextboxFrame

            TextboxName.Name = "TextboxName"
            TextboxName.Parent = TextboxFrame
            TextboxName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextboxName.BackgroundTransparency = 1.000
            TextboxName.BorderSizePixel = 0
            TextboxName.Size = UDim2.new(0, 235, 0, 35)
            TextboxName.Font = Enum.Font.Gotham
            TextboxName.Text = Name
            TextboxName.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextboxName.TextSize = 16.000
            TextboxName.TextXAlignment = Enum.TextXAlignment.Left

            TextboxNamePadding.Name = "TextboxNamePadding"
            TextboxNamePadding.Parent = TextboxName
            TextboxNamePadding.PaddingLeft = UDim.new(0, 10)

            Textbox.Name = "Textbox"
            Textbox.Parent = TextboxFrame
            Textbox.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            Textbox.BorderSizePixel = 0
            Textbox.Position = UDim2.new(0.610294104, 0, 0.171428576, 0)
            Textbox.Size = UDim2.new(0, 150, 0, 23)
            Textbox.Font = Enum.Font.Gotham
            Textbox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
            Textbox.PlaceholderText = Default
            Textbox.Text = ""
            Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
            Textbox.TextSize = 14.000

            TextboxCorner.Name = "TextboxCorner"
            TextboxCorner.Parent = Textbox

            Textbox.Focused:Connect(function()
                game:GetService("TweenService"):Create(Textbox, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(55, 74, 251)
                }):Play()
            end)

            Textbox.FocusLost:Connect(function()
                game:GetService("TweenService"):Create(Textbox, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(55, 55, 75)
                }):Play()
                Callback(Textbox.Text)
            end)
        end

        function Elements:Keybind(Name,xKey,Callback)
            local Name = Name or "Keybind"
            local Callback = Callback or function() end
            local Keyx = xKey.Name
            local KeybindFrame = Instance.new("Frame")
            local KeybindFrameCorner = Instance.new("UICorner")
            local KeybindName = Instance.new("TextLabel")
            local KeybindNamePadding = Instance.new("UIPadding")
            local KeybindButton = Instance.new("TextButton")
            local KeybindButtonCorner = Instance.new("UICorner")

            KeybindFrame.Name = tostring(Name).."_Keybind"
            KeybindFrame.Parent = Tab
            KeybindFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Size = UDim2.new(0, 408, 0, 35)
            
            KeybindFrameCorner.Name = "KeybindFrameCorner"
            KeybindFrameCorner.Parent = KeybindFrame
            
            KeybindName.Name = "KeybindName"
            KeybindName.Parent = KeybindFrame
            KeybindName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeybindName.BackgroundTransparency = 1.000
            KeybindName.BorderSizePixel = 0
            KeybindName.Size = UDim2.new(0, 235, 0, 35)
            KeybindName.Font = Enum.Font.Gotham
            KeybindName.Text = Name
            KeybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeybindName.TextSize = 16.000
            KeybindName.TextXAlignment = Enum.TextXAlignment.Left
            
            KeybindNamePadding.Name = "KeybindNamePadding"
            KeybindNamePadding.Parent = KeybindName
            KeybindNamePadding.PaddingLeft = UDim.new(0, 10)
            
            KeybindButton.Name = "KeybindButton"
            KeybindButton.Parent = KeybindFrame
            KeybindButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            KeybindButton.Position = UDim2.new(0.610294104, 0, 0.171428576, 0)
            KeybindButton.Size = UDim2.new(0, 150, 0, 23)
            KeybindButton.Font = Enum.Font.Gotham
            KeybindButton.Text = Keyx
            KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeybindButton.TextSize = 14.000
            KeybindButton.ZIndex = 2
            
            KeybindButtonCorner.Name = "KeybindButtonCorner"
            KeybindButtonCorner.Parent = KeybindButton

            KeybindButton.MouseButton1Click:connect(function() 
                game.TweenService:Create(KeybindButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(55, 74, 251)
                }):Play()
                KeybindButton.Text = ". . ."
                local v1, v2 = game:GetService('UserInputService').InputBegan:wait();
                if v1.KeyCode.Name ~= "Unknown" then
                    game.TweenService:Create(KeybindButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        BackgroundColor3 = Color3.fromRGB(55, 55, 75)
                    }):Play()
                    KeybindButton.Text = v1.KeyCode.Name
                    Keyx = v1.KeyCode.Name;
                end
            end)
    
            game:GetService("UserInputService").InputBegan:connect(function(a, gp) 
                if not gp then 
                    if a.KeyCode.Name == Keyx then 
                        Callback()
                    end
                end
            end)
        end

        function Elements:Dropdown(Name,Listx,Callback)
            local Name = Name or "Dropdown"
            local DropdownFunction = {}
            local Callback = Callback or function() end
            local opened = false 

            local DropdownFrame = Instance.new("Frame")
            local DropdownFrameCorner = Instance.new("UICorner")
            local DropdownName = Instance.new("TextLabel")
            local DropdownNamePadding = Instance.new("UIPadding")
            local DropdownIcon = Instance.new("ImageButton")
            local DropdownButton = Instance.new("TextButton")
            local DropList = Instance.new("ScrollingFrame")
            local DropListLayout = Instance.new("UIListLayout")

            DropdownFrame.Name = tostring(Name).."_Dropdown"
            DropdownFrame.Parent = Tab
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(0, 408, 0, 35)
            DropdownFrame.ZIndex = 10

            DropdownFrameCorner.Name = "DropdownFrameCorner"
            DropdownFrameCorner.Parent = DropdownFrame

            DropdownName.Name = "DropdownName"
            DropdownName.Parent = DropdownFrame
            DropdownName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownName.BackgroundTransparency = 1.000
            DropdownName.BorderSizePixel = 0
            DropdownName.Size = UDim2.new(0, 358, 0, 35)
            DropdownName.Font = Enum.Font.Gotham
            DropdownName.Text = Name
            DropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownName.TextSize = 16.000
            DropdownName.TextXAlignment = Enum.TextXAlignment.Left
            DropdownName.ZIndex = 11

            DropdownNamePadding.Name = "DropdownNamePadding"
            DropdownNamePadding.Parent = DropdownName
            DropdownNamePadding.PaddingLeft = UDim.new(0, 10)

            DropdownIcon.Name = "DropdownIcon"
            DropdownIcon.Parent = DropdownFrame
            DropdownIcon.BackgroundTransparency = 1.000
            DropdownIcon.Position = UDim2.new(0.914644599, 0, 0.140659884, 0)
            DropdownIcon.Size = UDim2.new(0, 25, 0, 25)
            DropdownIcon.ZIndex = 12
            DropdownIcon.Image = "rbxassetid://3926305904"
            DropdownIcon.ImageRectOffset = Vector2.new(604, 684)
            DropdownIcon.ImageRectSize = Vector2.new(36, 36)

            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = DropdownFrame
            DropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownButton.BackgroundTransparency = 1.000
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Size = UDim2.new(0, 408, 0, 35)
            DropdownButton.Font = Enum.Font.SourceSans
            DropdownButton.Text = ""
            DropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            DropdownButton.TextSize = 14.000
            DropdownButton.ZIndex = 13

            DropList.Name = "DropList"
            DropList.Parent = DropdownFrame
            DropList.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            DropList.BorderSizePixel = 0
            DropList.Position = UDim2.new(0, 0, 1, 0)
            DropList.Size = UDim2.new(0, 408, 0, 0)
            DropList.ScrollBarThickness = 0
            DropList.Visible = false
            DropList.ZIndex = 100
            DropList.CanvasSize = UDim2.new(0, 0, 0, 0)

            DropListLayout.Name = "DropListLayout"
            DropListLayout.Parent = DropList
            DropListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropListLayout.Padding = UDim.new(0, 3)

            local function updateDropListSize()
                local contentSize = DropListLayout.AbsoluteContentSize
                DropList.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
                local maxHeight = math.min(contentSize.Y, 200)
                DropList.Size = UDim2.new(0, 408, 0, maxHeight)
            end

            DropListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropListSize)

            -- Dropdown scroll fix
            DropList.MouseEnter:Connect(function()
                DropList.ScrollBarThickness = 5
            end)
            DropList.MouseLeave:Connect(function()
                DropList.ScrollBarThickness = 0
            end)

            DropdownButton.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(DropdownFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(48, 51, 70)
                }):Play()
            end)
            
            DropdownButton.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(DropdownFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                }):Play()
            end)

            DropdownButton.MouseButton1Down:Connect(function()
                if opened then 
                    opened = false
                    game:GetService("TweenService"):Create(DropList, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 408, 0, 0)
                    }):Play()
                    game:GetService("TweenService"):Create(DropdownIcon, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        ImageColor3 = Color3.fromRGB(255,255,255)
                    }):Play()
                    wait(0.1)
                    DropList.Visible = false
                else 
                    opened = true
                    DropList.Visible = true
                    updateDropListSize()
                    game:GetService("TweenService"):Create(DropdownIcon, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        ImageColor3 = Color3.fromRGB(55, 74, 251)
                    }):Play()
                end 
            end)

            for i,v in pairs(Listx) do 
                local Option = Instance.new("TextButton")
                local OptionCorner = Instance.new("UICorner")
                
                Option.Name = tostring(v).."_Option"
                Option.Parent = DropList
                Option.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                Option.Size = UDim2.new(0, 408, 0, 35)
                Option.Font = Enum.Font.Gotham
                Option.Text = v
                Option.TextColor3 = Color3.fromRGB(255, 255, 255)
                Option.TextSize = 16.000
                Option.ZIndex = 101

                OptionCorner.Name = "OptionCorner"
                OptionCorner.Parent = Option

                Option.MouseButton1Down:Connect(function()
                    Callback(v)
                    for a,b in pairs(DropList:GetChildren()) do 
                        if b:IsA("TextButton") then 
                            b.TextColor3 = Color3.fromRGB(255,255,255)
                        end 
                    end
                    game:GetService("TweenService"):Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        TextColor3 = Color3.fromRGB(55, 74, 251)
                    }):Play()
                    opened = false
                    game:GetService("TweenService"):Create(DropList, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 408, 0, 0)
                    }):Play()
                    game:GetService("TweenService"):Create(DropdownIcon, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        ImageColor3 = Color3.fromRGB(255,255,255)
                    }):Play()
                    wait(0.1)
                    DropList.Visible = false
                end)

                Option.MouseEnter:Connect(function()
                    game:GetService("TweenService"):Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        BackgroundColor3 = Color3.fromRGB(48, 51, 70)
                    }):Play()
                end)
                
                Option.MouseLeave:Connect(function()
                    game:GetService("TweenService"):Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                        BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                    }):Play()
                end)
            end

            function DropdownFunction:UpdateDropdown(List)
                for i,child in pairs(DropList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                for i,v in pairs(List) do 
                    local Option = Instance.new("TextButton")
                    local OptionCorner = Instance.new("UICorner")
                    
                    Option.Name = tostring(v).."_Option"
                    Option.Parent = DropList
                    Option.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                    Option.Size = UDim2.new(0, 408, 0, 35)
                    Option.Font = Enum.Font.Gotham
                    Option.Text = v
                    Option.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Option.TextSize = 16.000
                    Option.ZIndex = 101

                    OptionCorner.Name = "OptionCorner"
                    OptionCorner.Parent = Option

                    Option.MouseButton1Down:Connect(function()
                        Callback(v)
                        for a,b in pairs(DropList:GetChildren()) do 
                            if b:IsA("TextButton") then 
                                b.TextColor3 = Color3.fromRGB(255,255,255)
                            end 
                        end
                        game:GetService("TweenService"):Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            TextColor3 = Color3.fromRGB(55, 74, 251)
                        }):Play()
                        opened = false
                        game:GetService("TweenService"):Create(DropList, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            Size = UDim2.new(0, 408, 0, 0)
                        }):Play()
                        game:GetService("TweenService"):Create(DropdownIcon, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            ImageColor3 = Color3.fromRGB(255,255,255)
                        }):Play()
                        wait(0.1)
                        DropList.Visible = false
                    end)

                    Option.MouseEnter:Connect(function()
                        game:GetService("TweenService"):Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            BackgroundColor3 = Color3.fromRGB(48, 51, 70)
                        }):Play()
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        game:GetService("TweenService"):Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                        }):Play()
                    end)
                end
                updateDropListSize()
            end
            
            return DropdownFunction
        end

        function Elements:ColorPicker(Name, Default, Callback)
            local Name = Name or "ColorPicker"
            local Default = Default or Color3.fromRGB(255, 255, 255)
            local Callback = Callback or function() end
            
            local ColorPickerFrame = Instance.new("Frame")
            local ColorPickerFrameCorner = Instance.new("UICorner")
            local ColorPickerName = Instance.new("TextLabel")
            local ColorPickerNamePadding = Instance.new("UIPadding")
            local ColorPickerButton = Instance.new("TextButton")
            local ColorPickerPreview = Instance.new("Frame")
            local ColorPickerPreviewCorner = Instance.new("UICorner")
            
            ColorPickerFrame.Name = tostring(Name).."_ColorPicker"
            ColorPickerFrame.Parent = Tab
            ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            ColorPickerFrame.Size = UDim2.new(0, 408, 0, 35)
            
            ColorPickerFrameCorner.Name = "ColorPickerFrameCorner"
            ColorPickerFrameCorner.Parent = ColorPickerFrame
            
            ColorPickerName.Name = "ColorPickerName"
            ColorPickerName.Parent = ColorPickerFrame
            ColorPickerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ColorPickerName.BackgroundTransparency = 1.000
            ColorPickerName.BorderSizePixel = 0
            ColorPickerName.Size = UDim2.new(0, 235, 0, 35)
            ColorPickerName.Font = Enum.Font.Gotham
            ColorPickerName.Text = Name
            ColorPickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            ColorPickerName.TextSize = 16.000
            ColorPickerName.TextXAlignment = Enum.TextXAlignment.Left
            
            ColorPickerNamePadding.Name = "ColorPickerNamePadding"
            ColorPickerNamePadding.Parent = ColorPickerName
            ColorPickerNamePadding.PaddingLeft = UDim.new(0, 10)
            
            ColorPickerPreview.Name = "ColorPickerPreview"
            ColorPickerPreview.Parent = ColorPickerFrame
            ColorPickerPreview.BackgroundColor3 = Default
            ColorPickerPreview.BorderSizePixel = 0
            ColorPickerPreview.Position = UDim2.new(0.867647052, 0, 0.142857149, 0)
            ColorPickerPreview.Size = UDim2.new(0, 45, 0, 23)
            
            ColorPickerPreviewCorner.Name = "ColorPickerPreviewCorner"
            ColorPickerPreviewCorner.Parent = ColorPickerPreview
            ColorPickerPreviewCorner.CornerRadius = UDim.new(0, 4)
            
            ColorPickerButton.Name = "ColorPickerButton"
            ColorPickerButton.Parent = ColorPickerFrame
            ColorPickerButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ColorPickerButton.BackgroundTransparency = 1.000
            ColorPickerButton.BorderSizePixel = 0
            ColorPickerButton.Size = UDim2.new(0, 408, 0, 35)
            ColorPickerButton.Font = Enum.Font.SourceSans
            ColorPickerButton.Text = ""
            ColorPickerButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            ColorPickerButton.TextSize = 14.000
            
            local picker = Library:ColorPicker(Name, Default, function(color)
                ColorPickerPreview.BackgroundColor3 = color
                Callback(color)
            end)
            
            ColorPickerButton.MouseButton1Click:Connect(function()
                picker:Toggle()
            end)
            
            ColorPickerButton.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(ColorPickerFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(48, 51, 70)
                }):Play()
            end)
            
            ColorPickerButton.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(ColorPickerFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(40, 42, 60)
                }):Play()
            end)
            
            return {
                Set = function(color)
                    ColorPickerPreview.BackgroundColor3 = color
                    picker:Set(color)
                end
            }
        end

        return Elements
    end
    return xTabs
end
return Library
