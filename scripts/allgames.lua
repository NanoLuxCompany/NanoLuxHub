local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Plr = Players.LocalPlayer
local Clipon = false
local WallhackEnabled = false
local Minimized = false

-- GUI
local NanoLuxScriptHub = Instance.new("ScreenGui")
local BG = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UICorner1 = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local ToggleNoclip = Instance.new("TextButton")
local ToggleNoclipCorner = Instance.new("UICorner")
local ToggleWallhack = Instance.new("TextButton")
local ToggleWallhackCorner = Instance.new("UICorner")
local WalkSpeedInput = Instance.new("TextBox")
local WalkSpeedLabel = Instance.new("TextLabel")
local TeleportInput = Instance.new("TextBox")
local TeleportButton = Instance.new("TextButton")
local TeleportCorner = Instance.new("UICorner")

NanoLuxScriptHub.Name = "NanoLuxScriptHub"
NanoLuxScriptHub.Parent = CoreGui


BG.Name = "BG"
BG.Parent = NanoLuxScriptHub
BG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
BG.BackgroundTransparency = 0.5
BG.Position = UDim2.new(0.15, 0, 0.75, 0)
BG.Size = UDim2.new(0, 200, 0, 180)
BG.Active = true
BG.Draggable = true

UICorner.Parent = BG
UICorner.CornerRadius = UDim.new(0, 10)

-- Title
Title.Name = "Title"
Title.Parent = BG
Title.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
Title.BackgroundTransparency = 0.8
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.SourceSans
Title.Text = "NanoLux Script Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

UICorner1.Parent = Title
UICorner1.CornerRadius = UDim.new(0, 10)

-- Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = BG
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 18

-- Noclip Toggle
ToggleNoclip.Parent = BG
ToggleNoclip.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
ToggleNoclip.Position = UDim2.new(0.15, 0, 0.2, 0)
ToggleNoclip.Size = UDim2.new(0, 150, 0, 25)
ToggleNoclip.Font = Enum.Font.SourceSans
ToggleNoclip.Text = "Noclip (C)"
ToggleNoclip.TextColor3 = Color3.new(1, 1, 1)
ToggleNoclip.TextSize = 14
ToggleNoclipCorner.Parent = ToggleNoclip
ToggleNoclipCorner.CornerRadius = UDim.new(0, 8)

-- Wallhack Toggle
ToggleWallhack.Parent = BG
ToggleWallhack.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
ToggleWallhack.Position = UDim2.new(0.15, 0, 0.4, 0)
ToggleWallhack.Size = UDim2.new(0, 150, 0, 25)
ToggleWallhack.Font = Enum.Font.SourceSans
ToggleWallhack.Text = "Wallhack"
ToggleWallhack.TextColor3 = Color3.new(1, 1, 1)
ToggleWallhack.TextSize = 14
ToggleWallhackCorner.Parent = ToggleWallhack
ToggleWallhackCorner.CornerRadius = UDim.new(0, 8)

-- Walk Speed Input
WalkSpeedLabel.Parent = BG
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
WalkSpeedLabel.Size = UDim2.new(0, 80, 0, 20)
WalkSpeedLabel.Font = Enum.Font.SourceSans
WalkSpeedLabel.Text = "Walk Speed:"
WalkSpeedLabel.TextColor3 = Color3.new(1, 1, 1)
WalkSpeedLabel.TextSize = 14

WalkSpeedInput.Parent = BG
WalkSpeedInput.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
WalkSpeedInput.Position = UDim2.new(0.5, 0, 0.6, 0)
WalkSpeedInput.Size = UDim2.new(0, 80, 0, 20)
WalkSpeedInput.Font = Enum.Font.SourceSans
WalkSpeedInput.Text = "16"
WalkSpeedInput.TextColor3 = Color3.new(1, 1, 1)
WalkSpeedInput.TextSize = 14

-- Teleport Input
TeleportInput.Parent = BG
TeleportInput.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
TeleportInput.Position = UDim2.new(0.1, 0, 0.8, 0)
TeleportInput.Size = UDim2.new(0, 120, 0, 20)
TeleportInput.Font = Enum.Font.SourceSans
TeleportInput.PlaceholderText = "Ник игрока"
TeleportInput.TextColor3 = Color3.new(1, 1, 1)
TeleportInput.TextSize = 14

TeleportButton.Parent = BG
TeleportButton.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
TeleportButton.Position = UDim2.new(0.72, 0, 0.8, 0)
TeleportButton.Size = UDim2.new(0, 50, 0, 20)
TeleportButton.Font = Enum.Font.SourceSans
TeleportButton.Text = "ТП"
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.TextSize = 14
TeleportCorner.Parent = TeleportButton
TeleportCorner.CornerRadius = UDim.new(0, 8)

-- Functions
local function noclip()
    Clipon = not Clipon
    if Clipon then
        RunService.Stepped:Connect(function()
            if Clipon then
                for _, v in pairs(Plr.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function wallhack()
    WallhackEnabled = not WallhackEnabled
    if WallhackEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Plr then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Plr and player.Character then
                for _, v in pairs(player.Character:GetChildren()) do
                    if v:IsA("Highlight") then
                        v:Destroy()
                    end
                end
            end
        end
    end
end

local function teleportToPlayer(targetName)
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(player.Name:lower(), targetName:lower()) then
            Plr.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            break
        end
    end
end

-- Infinity Jump
UserInputService.JumpRequest:Connect(function()
    Plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

-- Events
ToggleNoclip.MouseButton1Click:Connect(noclip)
ToggleWallhack.MouseButton1Click:Connect(wallhack)
TeleportButton.MouseButton1Click:Connect(function()
    teleportToPlayer(TeleportInput.Text)
end)

WalkSpeedInput.FocusLost:Connect(function()
    Plr.Character.Humanoid.WalkSpeed = tonumber(WalkSpeedInput.Text) or 16
end)

CloseButton.MouseButton1Click:Connect(function()
    NanoLuxScriptHub:Destroy()
    blur:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Minimized = not Minimized
        BG.Visible = not Minimized
    elseif input.KeyCode == Enum.KeyCode.C then
        noclip()
    end
end)
