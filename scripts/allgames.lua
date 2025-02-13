local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Plr = Players.LocalPlayer
local Clipon = false
local Minimized = false


local NanoLuxScriptHub = Instance.new("ScreenGui")
local BG = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Toggle = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")
local Status = Instance.new("TextLabel")



NanoLuxScriptHub.Name = "NanoLuxScriptHub"
NanoLuxScriptHub.Parent = CoreGui


BG.Name = "BG"
BG.Parent = NanoLuxScriptHub
BG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
BG.BackgroundTransparency = 0.5
BG.Position = UDim2.new(0.15, 0, 0.75, 0)
BG.Size = UDim2.new(0, 200, 0, 100)
BG.Active = true
BG.Draggable = true


UICorner.Parent = BG
UICorner.CornerRadius = UDim.new(0, 10)


Title.Name = "Title"
Title.Parent = BG
Title.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
Title.BackgroundTransparency = 0.3
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.SourceSans
Title.Text = "NanoLux Script Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

Toggle.Parent = BG
Toggle.BackgroundColor3 = Color3.fromRGB(90, 0, 180)
Toggle.Position = UDim2.new(0.15, 0, 0.4, 0)
Toggle.Size = UDim2.new(0, 150, 0, 30)
Toggle.Font = Enum.Font.SourceSans
Toggle.Text = "Toggle"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 18
ToggleCorner.Parent = Toggle
ToggleCorner.CornerRadius = UDim.new(0, 8)


Status.Name = "Status"
Status.Parent = BG
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0.5, -20, 0.75, 0)
Status.Size = UDim2.new(0, 40, 0, 20)
Status.Font = Enum.Font.SourceSans
Status.Text = "OFF"
Status.TextColor3 = Color3.fromRGB(170, 0, 0)
Status.TextSize = 16

Toggle.MouseButton1Click:Connect(function()
    Clipon = not Clipon
    if Clipon then
        Status.Text = "ON"
        Status.TextColor3 = Color3.fromRGB(0, 185, 0)
        Stepped = RunService.Stepped:Connect(function()
            if Clipon then
                for _, b in pairs(Workspace:GetChildren()) do
                    if b.Name == Plr.Name then
                        for _, v in pairs(b:GetChildren()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                            end
                        end
                    end
                end
            else
                Stepped:Disconnect()
            end
        end)
    else
        Status.Text = "OFF"
        Status.TextColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
        BG.Visible = not BG.Visible
        Minimized = not BG.Visible
    end
end)
