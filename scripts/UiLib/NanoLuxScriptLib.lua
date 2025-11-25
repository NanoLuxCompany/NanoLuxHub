local Library = {}
local LibraryName = tostring(math.random(100000,200000))..tostring(math.random(100000,200000))..tostring(math.random(100000,200000))

function Library:Toggle()
    if game.CoreGui:FindFirstChild(LibraryName).Enabled then 
        game.CoreGui:FindFirstChild(LibraryName).Enabled = false
    else 
        game.CoreGui:FindFirstChild(LibraryName).Enabled = true
    end
end

function Library:Close()
    if game.CoreGui:FindFirstChild(LibraryName) then
        game.CoreGui:FindFirstChild(LibraryName):Destroy()
    end
end

function Library:Drag(obj)
    local UserInputService = game:GetService("UserInputService")
    
    local gui = obj
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
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
    Main.Size = UDim2.new(0, 580, 0, 420)

    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main

    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    Sidebar.Size = UDim2.new(0, 140, 0, 420)

    SidebarCorner.Name = "SidebarCorner"
    SidebarCorner.Parent = Sidebar

    Filler.Name = "Filler"
    Filler.Parent = Sidebar
    Filler.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    Filler.BorderSizePixel = 0
    Filler.Position = UDim2.new(0.930769145, 0, 0, 0)
    Filler.Size = UDim2.new(0, 9, 0, 420)

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
    ActualSide.Size = UDim2.new(0, 139, 0, 347)
    ActualSide.CanvasSize = UDim2.new(0,0,0,0)
    ActualSide.ScrollBarThickness = 8

    ActualSideListLayout.Name = "ActualSideListLayout"
    ActualSideListLayout.Parent = ActualSide
    ActualSideListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    SideLine.Name = "SideLine"
    SideLine.Parent = Sidebar
    SideLine.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SideLine.BorderSizePixel = 0
    SideLine.Position = UDim2.new(1, 0, 0, 0)
    SideLine.Size = UDim2.new(0, 2, 0, 420)

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
    TabHolder.Size = UDim2.new(0, 438, 0, 402)

    Tabs.Name = "Tabs"
    Tabs.Parent = TabHolder

    local CloseButton = Instance.new("TextButton")
    local MinimizeButton = Instance.new("TextButton")

    CloseButton.Name = "CloseButton"
    CloseButton.Parent = Main
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.95, 0, 0.01, 0)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16.000
    CloseButton.ZIndex = 2

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = Main
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 193, 59)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(0.91, 0, 0.01, 0)
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 16.000
    MinimizeButton.ZIndex = 2

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 4)
    MinimizeCorner.Parent = MinimizeButton

    CloseButton.MouseButton1Down:Connect(function()
        Library:Close()
    end)

    MinimizeButton.MouseButton1Down:Connect(function()
        Library:Toggle()
    end)

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
        Tab.Size = UDim2.new(0, 438, 0, 402)
        Tab.ScrollBarThickness = 8
        
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
            DropList.ScrollBarThickness = 8
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

        function Elements:Colorpicker(Name, DefaultColor, Callback)
            local Name = Name or "Colorpicker"
            local DefaultColor = DefaultColor or Color3.fromRGB(255, 255, 255)
            local Callback = Callback or function() end
            local CurrentColor = DefaultColor
            local ColorpickerOpen = false

            local ColorpickerFrame = Instance.new("Frame")
            local ColorpickerFrameCorner = Instance.new("UICorner")
            local ColorpickerName = Instance.new("TextLabel")
            local ColorpickerNamePadding = Instance.new("UIPadding")
            local ColorpickerButton = Instance.new("TextButton")
            local ColorpickerButtonCorner = Instance.new("UICorner")
            local ColorPreview = Instance.new("Frame")
            local ColorPreviewCorner = Instance.new("UICorner")

            ColorpickerFrame.Name = tostring(Name).."_Colorpicker"
            ColorpickerFrame.Parent = Tab
            ColorpickerFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            ColorpickerFrame.BorderSizePixel = 0
            ColorpickerFrame.Size = UDim2.new(0, 408, 0, 35)
            
            ColorpickerFrameCorner.Name = "ColorpickerFrameCorner"
            ColorpickerFrameCorner.Parent = ColorpickerFrame
            
            ColorpickerName.Name = "ColorpickerName"
            ColorpickerName.Parent = ColorpickerFrame
            ColorpickerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ColorpickerName.BackgroundTransparency = 1.000
            ColorpickerName.BorderSizePixel = 0
            ColorpickerName.Size = UDim2.new(0, 235, 0, 35)
            ColorpickerName.Font = Enum.Font.Gotham
            ColorpickerName.Text = Name
            ColorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            ColorpickerName.TextSize = 16.000
            ColorpickerName.TextXAlignment = Enum.TextXAlignment.Left
            
            ColorpickerNamePadding.Name = "ColorpickerNamePadding"
            ColorpickerNamePadding.Parent = ColorpickerName
            ColorpickerNamePadding.PaddingLeft = UDim.new(0, 10)
            
            ColorpickerButton.Name = "ColorpickerButton"
            ColorpickerButton.Parent = ColorpickerFrame
            ColorpickerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            ColorpickerButton.Position = UDim2.new(0.610294104, 0, 0.171428576, 0)
            ColorpickerButton.Size = UDim2.new(0, 150, 0, 23)
            ColorpickerButton.Font = Enum.Font.Gotham
            ColorpickerButton.Text = ""
            ColorpickerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ColorpickerButton.TextSize = 14.000
            ColorpickerButton.ZIndex = 2
            
            ColorpickerButtonCorner.Name = "ColorpickerButtonCorner"
            ColorpickerButtonCorner.Parent = ColorpickerButton

            ColorPreview.Name = "ColorPreview"
            ColorPreview.Parent = ColorpickerButton
            ColorPreview.BackgroundColor3 = CurrentColor
            ColorPreview.BorderSizePixel = 0
            ColorPreview.Position = UDim2.new(0.05, 0, 0.15, 0)
            ColorPreview.Size = UDim2.new(0, 130, 0, 16)
            
            ColorPreviewCorner.Name = "ColorPreviewCorner"
            ColorPreviewCorner.Parent = ColorPreview

            -- Color Picker Window
            local ColorPickerWindow = Instance.new("Frame")
            local ColorPickerWindowCorner = Instance.new("UICorner")
            local ColorPickerTitle = Instance.new("TextLabel")
            local ColorPickerArea = Instance.new("Frame")
            local ColorWheel = Instance.new("ImageLabel")
            local ColorWheelCursor = Instance.new("Frame")
            local ColorWheelCursorCorner = Instance.new("UICorner")
            local BrightnessSlider = Instance.new("Frame")
            local BrightnessSliderCorner = Instance.new("UICorner")
            local BrightnessGradient = Instance.new("UIGradient")
            local BrightnessCursor = Instance.new("Frame")
            local BrightnessCursorCorner = Instance.new("UICorner")
            local RGBInputs = Instance.new("Frame")
            local RInput = Instance.new("TextBox")
            local GInput = Instance.new("TextBox")
            local BInput = Instance.new("TextBox")
            local HexInput = Instance.new("TextBox")
            local ConfirmButton = Instance.new("TextButton")
            local ConfirmButtonCorner = Instance.new("UICorner")

            ColorPickerWindow.Name = "ColorPickerWindow"
            ColorPickerWindow.Parent = ColorpickerFrame
            ColorPickerWindow.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
            ColorPickerWindow.BorderSizePixel = 0
            ColorPickerWindow.Position = UDim2.new(0, 0, 1, 5)
            ColorPickerWindow.Size = UDim2.new(0, 408, 0, 0)
            ColorPickerWindow.Visible = false
            ColorPickerWindow.ZIndex = 100

            ColorPickerWindowCorner.Name = "ColorPickerWindowCorner"
            ColorPickerWindowCorner.Parent = ColorPickerWindow

            ColorPickerTitle.Name = "ColorPickerTitle"
            ColorPickerTitle.Parent = ColorPickerWindow
            ColorPickerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ColorPickerTitle.BackgroundTransparency = 1.000
            ColorPickerTitle.Size = UDim2.new(0, 408, 0, 25)
            ColorPickerTitle.Font = Enum.Font.Gotham
            ColorPickerTitle.Text = "Color Picker"
            ColorPickerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            ColorPickerTitle.TextSize = 16.000

            -- Simplified color picker implementation
            local function UpdateColor(newColor)
                CurrentColor = newColor
                ColorPreview.BackgroundColor3 = newColor
                pcall(Callback, newColor)
            end

            ColorpickerButton.MouseButton1Click:Connect(function()
                ColorpickerOpen = not ColorpickerOpen
                if ColorpickerOpen then
                    ColorPickerWindow.Visible = true
                    game:GetService("TweenService"):Create(ColorPickerWindow, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 408, 0, 150)
                    }):Play()
                else
                    game:GetService("TweenService"):Create(ColorPickerWindow, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 408, 0, 0)
                    }):Play()
                    wait(0.2)
                    ColorPickerWindow.Visible = false
                end
            end)

            -- Simple RGB input implementation
            local function CreateRGBInput(name, position, defaultValue)
                local InputFrame = Instance.new("Frame")
                local InputLabel = Instance.new("TextLabel")
                local InputBox = Instance.new("TextBox")
                local InputCorner = Instance.new("UICorner")

                InputFrame.Name = name.."InputFrame"
                InputFrame.Parent = ColorPickerWindow
                InputFrame.BackgroundTransparency = 1
                InputFrame.Position = position
                InputFrame.Size = UDim2.new(0, 120, 0, 25)

                InputLabel.Name = name.."Label"
                InputLabel.Parent = InputFrame
                InputLabel.BackgroundTransparency = 1
                InputLabel.Size = UDim2.new(0, 30, 0, 25)
                InputLabel.Font = Enum.Font.Gotham
                InputLabel.Text = name..":"
                InputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputLabel.TextSize = 14.000
                InputLabel.TextXAlignment = Enum.TextXAlignment.Left

                InputBox.Name = name.."Input"
                InputBox.Parent = InputFrame
                InputBox.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
                InputBox.Position = UDim2.new(0, 35, 0, 0)
                InputBox.Size = UDim2.new(0, 80, 0, 25)
                InputBox.Font = Enum.Font.Gotham
                InputBox.PlaceholderText = defaultValue
                InputBox.Text = defaultValue
                InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.TextSize = 14.000

                InputCorner.Parent = InputBox

                return InputBox
            end

            -- Create RGB inputs
            local RInput = CreateRGBInput("R", UDim2.new(0, 10, 0, 40), "255")
            local GInput = CreateRGBInput("G", UDim2.new(0, 140, 0, 40), "255")
            local BInput = CreateRGBInput("B", UDim2.new(0, 270, 0, 40), "255")

            -- Hex input
            local HexFrame = Instance.new("Frame")
            HexFrame.Parent = ColorPickerWindow
            HexFrame.BackgroundTransparency = 1
            HexFrame.Position = UDim2.new(0, 10, 0, 75)
            HexFrame.Size = UDim2.new(0, 388, 0, 25)

            local HexLabel = Instance.new("TextLabel")
            HexLabel.Parent = HexFrame
            HexLabel.BackgroundTransparency = 1
            HexLabel.Size = UDim2.new(0, 40, 0, 25)
            HexLabel.Font = Enum.Font.Gotham
            HexLabel.Text = "Hex:"
            HexLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HexLabel.TextSize = 14.000
            HexLabel.TextXAlignment = Enum.TextXAlignment.Left

            local HexInput = Instance.new("TextBox")
            HexInput.Parent = HexFrame
            HexInput.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            HexInput.Position = UDim2.new(0, 45, 0, 0)
            HexInput.Size = UDim2.new(0, 100, 0, 25)
            HexInput.Font = Enum.Font.Gotham
            HexInput.PlaceholderText = "#FFFFFF"
            HexInput.Text = "#FFFFFF"
            HexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            HexInput.TextSize = 14.000
            Instance.new("UICorner", HexInput)

            -- Confirm button
            ConfirmButton.Name = "ConfirmButton"
            ConfirmButton.Parent = ColorPickerWindow
            ConfirmButton.BackgroundColor3 = Color3.fromRGB(55, 74, 251)
            ConfirmButton.Position = UDim2.new(0, 160, 0, 110)
            ConfirmButton.Size = UDim2.new(0, 80, 0, 30)
            ConfirmButton.Font = Enum.Font.Gotham
            ConfirmButton.Text = "Confirm"
            ConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ConfirmButton.TextSize = 14.000

            ConfirmButtonCorner.Parent = ConfirmButton

            -- Input handlers
            local function UpdateFromRGB()
                local r = math.clamp(tonumber(RInput.Text) or 255, 0, 255)
                local g = math.clamp(tonumber(GInput.Text) or 255, 0, 255)
                local b = math.clamp(tonumber(BInput.Text) or 255, 0, 255)
                
                RInput.Text = tostring(r)
                GInput.Text = tostring(g)
                BInput.Text = tostring(b)
                
                local newColor = Color3.fromRGB(r, g, b)
                HexInput.Text = "#" .. string.format("%02X%02X%02X", r, g, b)
                UpdateColor(newColor)
            end

            local function UpdateFromHex()
                local hex = HexInput.Text:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16) or 255
                    local g = tonumber(hex:sub(3,4), 16) or 255
                    local b = tonumber(hex:sub(5,6), 16) or 255
                    
                    RInput.Text = tostring(r)
                    GInput.Text = tostring(g)
                    BInput.Text = tostring(b)
                    
                    local newColor = Color3.fromRGB(r, g, b)
                    UpdateColor(newColor)
                end
            end

            RInput.FocusLost:Connect(UpdateFromRGB)
            GInput.FocusLost:Connect(UpdateFromRGB)
            BInput.FocusLost:Connect(UpdateFromRGB)
            HexInput.FocusLost:Connect(UpdateFromHex)

            ConfirmButton.MouseButton1Click:Connect(function()
                ColorpickerOpen = false
                game:GetService("TweenService"):Create(ColorPickerWindow, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 408, 0, 0)
                }):Play()
                wait(0.2)
                ColorPickerWindow.Visible = false
            end)

            -- Set initial values
            local r, g, b = math.floor(CurrentColor.R * 255), math.floor(CurrentColor.G * 255), math.floor(CurrentColor.B * 255)
            RInput.Text = tostring(r)
            GInput.Text = tostring(g)
            BInput.Text = tostring(b)
            HexInput.Text = "#" .. string.format("%02X%02X%02X", r, g, b)
        end

        return Elements
    end
    return xTabs
end

return Library
